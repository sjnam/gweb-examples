\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\title{파이 데이 퍼즐}

@s Writer int

@* 들어가며.
Johan de Ruiter는 2018년 3월 14일, 곧 파이 데이에 아름다운 퍼즐 하나를 내놓았다.
원주율 $\pi$의 처음 32자리를 바탕으로 한 퍼즐이다.
@^de Ruiter, Johan@>

이것은 다음과 같은 자기 지시적 문제의 특수한 경우다. 방향 그래프가 주어졌을 때,
꼭짓점마다 그 후속자들에 붙은 서로 다른 이름표의 개수를 이름표로 붙이는 방법을 모두
찾아라.

요한의 퍼즐에서는 이름표 일부가 주어지고, 나머지를 찾아야 한다. 그는 이 방향
그래프를 $10\times10$ 배열로 내놓았다. 칸마다 북, 남, 동, 서 가운데 한쪽을
가리키고, 그 칸의 후속자는 가리키는 쪽에 있는 칸들이다. 아래 그림에서 검은 굵은
숫자가 주어진 이름표다. 줄마다 왼쪽에서 오른쪽으로 읽어 내려가면
3141592653589793238462643383279\-5, 곧 $\pi$의 처음 32자리다. 회색 숫자는 이
프로그램이 찾아낸 나머지 이름표이고, 작은 화살표는 칸이 가리키는 쪽이다.

$$\mplibcode
beginfig(0);
u := 6.6mm;
string dir, giv, sol, dd, gg;
dir := "SWEWSWSSSSESWSSESWESESEESSESWWEESNSEWSWWEESSSSWWSWEEEWSESESSEESNSSNWNWNESNSESWSNNEEESWWWWNEENWNNWWNN";
giv := "3140105090002600000500000035890000000070903000000000000002030800000000462600000040000033000803020795";
sol := "3143135595742613571594761235897632135477983412675944411342439835124769462613252443331333359843126795";
for i=0 upto 10:
  draw (0,i*u)--(10u,i*u) withpen pencircle scaled .3pt;
  draw (i*u,0)--(i*u,10u) withpen pencircle scaled .3pt;
endfor
draw unitsquare scaled 10u withpen pencircle scaled .8pt;
for i=0 upto 9:
  for j=0 upto 9:
    k := 10i+j;
    z0 = ((j+.5)*u, (9.5-i)*u);
    dd := substring (k,k+1) of dir;
    z1 = if dd="N": (0,1) elseif dd="S": (0,-1) elseif dd="E": (1,0) else: (-1,0) fi;
    drawarrow (z0+.24u*z1)--(z0+.46u*z1) withpen pencircle scaled .35pt withcolor .55white;
    gg := substring (k,k+1) of giv;
    if gg<>"0":
      label(textext("{\bf " & gg & "}"), z0-.1u*z1);
    else:
      label(textext(substring (k,k+1) of sol), z0-.1u*z1) withcolor .5white;
    fi
    clearxy;
  endfor
endfor
endfig;
\endmplibcode$$

@ 이것은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{back-pi-day.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/back-pi-day.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Thu, 05 Jan 2023 00:17:04 GMT}다.

크누스는 조금 더 일반적인 방향 그래프에도 쓸 수 있게 이 프로그램을 짰다고 했다.
나중에 더 일반화할 마음이 생길 때를 대비한 것이다. 비트맵을 재미있게 쓰지만,
복잡하지는 않다.

@ 칸의 방향은 이름표 위의 네 비트에 담는다. 배열 |johan|의 항목은 방향과 주어진
이름표를 더한 것이고, 이름표가 주어지지 않은 칸에는 0을 더했다.

@<전역 변수@>=
var johan = [10][10]int{
	{S + 3, W + 1, E + 4, W + 0, S + 1, W + 0, S + 5, S + 0, S + 9, S + 0},
	{E + 0, S + 0, W + 2, S + 6, S + 0, E + 0, S + 0, W + 0, E + 0, S + 5},
	{E + 0, S + 0, E + 0, E + 0, S + 0, S + 0, E + 3, S + 5, W + 8, W + 9},
	{E + 0, E + 0, S + 0, N + 0, S + 0, E + 0, W + 0, S + 0, W + 7, W + 0},
	{E + 9, E + 0, S + 3, S + 0, S + 0, S + 0, W + 0, W + 0, S + 0, W + 0},
	{E + 0, E + 0, E + 0, W + 0, S + 0, E + 0, S + 0, E + 2, S + 0, S + 3},
	{E + 0, E + 8, S + 0, N + 0, S + 0, S + 0, N + 0, W + 0, N + 0, W + 0},
	{N + 4, E + 6, S + 2, N + 6, S + 0, E + 0, S + 0, W + 0, S + 0, N + 0},
	{N + 4, E + 0, E + 0, E + 0, S + 0, W + 0, W + 3, W + 3, W + 0, N + 0},
	{E + 0, E + 8, N + 0, W + 3, N + 0, N + 2, W + 0, W + 7, N + 9, N + 5}}

@ 프로그램의 얼개는 이렇다. 크누스는 C의 매크로 |o|, |oo|, |ooo|로 메모리
접근(mem)을 셌다. \GO/에는 매크로가 없으므로, 그 자리마다 |mems++|나 |mems+=2|를
문장 앞에 적는다. 크누스가 매크로를 붙인 곳에는 빠짐없이 그대로 옮겼으니, 끝에
찍히는 mem 수로 옮김이 옳은지 검산할 수 있다.

상수 |debug|가 참이면 진행 과정을 표준 오류로 자세히 찍는다. 크누스의 기본값이
참이라 나도 그대로 두었는데, 그러면 20만 줄 가까이 나온다.

@c
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

const (
	N      = 0 << 4 // 북
	S      = 1 << 4 // 남
	E      = 2 << 4 // 동
	W      = 3 << 4 // 서
	debug  = true   // 자세히 찍을까?
	verts  = 100    // 방향 그래프의 꼭짓점 수
	maxd   = 9      // 가장 큰 나가는 차수. 16보다 작아야 한다
	bitmax = 1 << (maxd + 1)
)

@<전역 변수@>
@<함수들@>

func main() {
	var a, d, g, i, j, k, l, q, t, u, v, x int
	var p uint64
	@<|nu| 표들을 계산한다@>
	@<그래프를 세운다@>
	@<비트맵을 초기화한다@>
	@<활성 목록을 초기화한다@>
	@<안정에 이른다@>
	@<답을 찍는다@>
}

@ 배열 |nu|, |gnu|, |un|은 저마다 $\nu k$, $2^{\nu k}$, $\rho k$를 담는다. 여기서
$\nu k$는 $k$의 1비트 개수이고, $\rho k$는 $k$에서 가장 낮은 1비트의 위치다. (배열
|un|은 한 비트짜리 $k$에만 쓰므로, 그때는 $\rho k=\lg k$다.)

@<전역 변수@>=
var (
	mems         int64        // 메모리 접근 수
	nu, gnu, un  [bitmax]int  // $\nu k$, $2^{\nu k}$, $\rho k$
	errw         = bufio.NewWriter(os.Stderr)
)

@ 표준 오류로 찍을 것이 많으므로 |errw|로 모았다가 내보낸다.

@<|nu| 표들을 계산한다@>=
mems++; gnu[0] = 1
for k = 0; k < bitmax; k += 2 {
	mems += 6
	nu[k] = nu[k>>1]; nu[k+1] = nu[k] + 1
	gnu[k] = gnu[k>>1]; gnu[k+1] = gnu[k] << 1
}
for k = 1; k <= maxd; k++ {
	mems++; un[1<<k] = k
}

@ 꼭짓점 |v|에서 나가는 호들은 Stanford GraphBase에서처럼 |arcs[v]|에서 시작한다.
꼭짓점 |v|로 {\it 들어오는\/} 거꾸로 된 호들은 |scra[v]|에서 시작한다.

크누스는 호 하나를 놓는 일을 매크로 |newarc|로 적었다. 나는 그것을 이름 있는 절로
두고, 네 방향에서 저마다 끼워 넣는다. 방향마다 후속자 |u|를 정해 주기만 하면 된다.

@<그래프를 세운다@>=
for i = 0; i < 10; i++ {
	for j = 0; j < 10; j++ {
		v = inx(i, j)
		name[v] = fmt.Sprintf("%02d", v)
		@<칸 $(i,j)$에서 나가는 호들을 놓는다@>
		@<나가는 차수 |d|가 너무 크면 멈춘다@>
		mems++; deg[v] = d
		if d <= 1 {
			known[v] = d // 이 이름표는 주어진 것으로 여겨도 된다
		}
	}
}

@ 북쪽을 가리키는 칸은 위쪽 칸들을 위에서부터, 남쪽을 가리키는 칸은 아래쪽 칸들을
맨 아래에서부터 후속자로 삼는다. 동과 서도 마찬가지로, 가장자리에서 가까운 쪽부터다.

@<칸 $(i,j)$에서 나가는 호들을 놓는다@>=
known[v] = -1
if johan[i][j]&0xf != 0 {
	known[v] = johan[i][j] & 0xf
}
d = 0
switch johan[i][j] >> 4 {
case N >> 4:
	for k = 0; k < i; k++ {
		u = inx(k, j)
		@<|v|에서 |u|로 가는 호를 놓는다@>
	}
case S >> 4:
	for k = 9; k > i; k-- {
		u = inx(k, j)
		@<|v|에서 |u|로 가는 호를 놓는다@>
	}
case E >> 4:
	for k = 9; k > j; k-- {
		u = inx(i, k)
		@<|v|에서 |u|로 가는 호를 놓는다@>
	}
case W >> 4:
	for k = 0; k < j; k++ {
		u = inx(i, k)
		@<|v|에서 |u|로 가는 호를 놓는다@>
	}
}

@ 호 하나마다 |tip|과 |next|의 칸 둘을 쓴다. 하나는 |v|의 나가는 목록에,
하나는 |u|의 들어오는 목록에 넣는다.

@<|v|에서 |u|로 가는 호를 놓는다@>=
mems += 8
arcptr++; next[arcptr] = arcs[v]; tip[arcptr] = u; arcs[v] = arcptr
arcptr++; next[arcptr] = scra[u]; tip[arcptr] = v; scra[u] = arcptr
d++

@ @<나가는 차수 |d|가 너무 크면 멈춘다@>=
if d > maxd {
	errw.Flush()
	fmt.Fprintf(os.Stderr, "%s의 나가는 차수는 %d 이하여야 한다. %d는 안 된다!\n",
		name[v], maxd, d)
	os.Exit(-1)
}

@ 칸 $(i,j)$의 번호는 $10i+j$다. 여러 곳에서 쓰므로 함수로 둔다.

@<함수들@>=
func inx(i, j int) int {
	return 10*i + j
}

@ 꼭짓점 |v|가 가질 수 있는 이름표의 집합은 $(|maxd|+1)$비트 수 |bits[v]|에 담는다.
이름표가 미리 주어졌으면 비트 하나뿐이고, 그렇지 않고 차수가 $d$이면
$2^1+2^2+\cdots+2^d$다. 후속자가 하나라도 있으면 이름표는 0일 수 없기 때문이다.

크누스는 이 반복문에서 쓰지 않는 변수 |l|에 주어진 이름표를 담았다. 나는 그 대입은
빼고 mem 계수만 남겼다.

@<비트맵을 초기화한다@>=
for i = 0; i < 10; i++ {
	for j = 0; j < 10; j++ {
		mems++; v = inx(i, j)
		if known[v] >= 0 {
			mems++; bits[v] = 1 << known[v]
		} else {
			mems += 2
			if deg[v] != 0 {
				bits[v] = 1<<(deg[v]+1) - 2
			} else {
				bits[v] = 1
			}
		}
	}
}

@* 안정성.
이 프로그램은 ``안정성''이라는 흥미로운 개념에 기댄다. 꼭짓점 |v|의 후속자가
$w_1$, \dots,~$w_d$라 하고, 다음을 만족하는 1비트 부호 $(x_1,\ldots,x_d)$를 모두
생각하자.
$$x_j\subseteq|bits|[w_j],\qquad y=|gnu|[x_1\mid\cdots\mid x_d]\subseteq|bits[v]|.$$
단순한 되짚어 찾기로, 그런 $x_j$를 모두 비트별 {\mc OR}한 $a_j$와, 그런 $y$를 모두
비트별 {\mc OR}한 $a_0$을 계산한다.

모든 $j$에 대해 $a_j=|bits|[w_j]$이고 $a_0=|bits|[v]$이면, 꼭짓점~|v|가
{\it 안정하다\/}고 한다. 그렇지 않으면 가능성의 수를 줄인 것이니, 한 걸음 나아간
것이다. (제약 만족 문제의 말로 하면, 꼭짓점 하나와 그 후속자들에 걸린 제약에 대해
일반화된 호 일관성을 맞추는 일이다.)

모든 꼭짓점이 안정해졌을 때 모든 비트맵의 크기가 1이기를 바란다.

그렇지 않으면 문제를 경우로 나누어야 할 것이다. 크누스는 그 다리는 꼭 건너야 할 때
건너겠다고 했다.

(여기서 짚어 둘 것이 있다. 안정성은 꽤 약한 조건이다. 이를테면
$|bits|[v]=2^{d+1}-1$이고 $|bits|[w_1]=\cdots=|bits|[w_d]$이면, $w_1$부터 $w_d$까지의
이름표에 가능성이 많이 남아 있어도 |v|는 안정하다. 그런데도 크누스는 이 코드를
쓰면서 낙관적이었고, 호기심도 있었다고 했다.)

@ 처음에는 모든 꼭짓점이 ``활성''이다. 주 알고리즘의 생각은 아주 단순하다. 활성
꼭짓점~|v|를 하나 골라 안정한지 시험하고, (적어도 잠시) 비활성으로 만든다. 그
시험이 $u\in\{v,w_1,\ldots,w_d\}$ 가운데 어느 |bits[u]|라도 바꾸었으면, $u$와 그
선행자들을 모두 활성으로 만든다. 그 꼭짓점들이 이제 불안정할 수 있기 때문이다. 이
내리막 과정은 완전히 안정해질 때까지 이어진다.

활성 꼭짓점의 목록은 |llink|와 |rlink|로 이은 이중 연결 목록이고, 머리는
|active|다.

꼭짓점마다 후속자 비트맵 |bits|$[w_j]$의 크기를 모두 곱한 |size[v]|를 둔다. 그래서
크기가 가장 작은 활성 꼭짓점을 되풀이해 고를 수 있다.

@<전역 변수@>=
const active = verts // 활성 목록의 머리

var (
	llink, rlink                           [verts + 1]int
	deg, arcs, scra, bits, isactive, known [verts]int
	size                                   [verts]uint64
	name                                   [verts]string // 꼭짓점 이름
	tip, next                              [2 * verts * verts]int
	arcptr                                 int // |tip|과 |next|에서 쓰고 있는 칸 수
)

@ @<활성 목록을 초기화한다@>=
for v = 0; v < verts; v++ {
	mems += 2; rlink[v] = v + 1
	llink[v] = active
	if v != 0 {
		llink[v] = v - 1
	}
	mems++
	for p, a = 1, arcs[v]; a != 0; a = next[a] {
		mems += 3; p *= uint64(nu[bits[tip[a]]])
		mems++
	}
	mems += 2; isactive[v] = 1; size[v] = p
}
mems += 2; llink[active] = active - 1; rlink[active] = 0

@ 디버깅할 때는 상태 정보를 찍고 싶을 것이다. 꼭짓점 하나를 찍는 |printvert|는
여러 곳에서 쓰므로 함수로 둔다. 이름 뒤 괄호 안에 가능한 이름표들을 16진 숫자로
늘어놓는다.

원본에는 활성 목록 전체를 찍는 |printact|도 있는데, 부르는 곳이 없다. 이 판에는
옮기지 않았다.

@<함수들@>=
func printvert(v int, stream io.Writer) {
	fmt.Fprintf(stream, "%s(", name[v])
	for b, d := bits[v], 0; 1<<d <= b; d++ {
		if 1<<d&b != 0 {
			fmt.Fprintf(stream, "%x", d)
		}
	}
	fmt.Fprintf(stream, ")")
}

@* 안정성 시험.
크누스가 이 프로그램을 쓰게 만든 재미있는 루틴이 여기 있다.

꼭짓점 |v|의 안정성 문제의 해 $(x_1,\ldots,x_d)$는 모두 합쳐 많아야 |size[v]|개다.
그러나 물론 그 수를 크게 줄이고 싶다. 아래 코드에서 가장 멋진 부분은 |goal| 비트의
계산이다. 그것으로 불가능한 부분해를 걸러 낸다.

수준 $l$까지 고른 부호의 {\mc OR}를 $s_l$이라 하면, 지금까지 나온 서로 다른
이름표는 $\nu s_l$개다. 남은 $d-l$개가 새 이름표를 더해도 그 수는 많아야 $d-l$만큼
늘 뿐이다. 그러니 $\nu s_l+t\in|bits[v]|$인 $0\le t\le d-l$이 있어야 한다.
비트맵 |goal[l]|은 그런 $2^{\nu s_l}$들의 집합이다. 이것은 뒤에서부터 쉽게 셈할 수
있다. 먼저 |goal[d]|는 |bits[v]|이고, |goal[k-1]|은 |goal[k]|와 그것을 한 칸
오른쪽으로 민 것의 {\mc OR}다. 수준 $k-1$에서는 서로 다른 이름표가 $k-1$개를 넘을
수 없으니, 그 위의 비트는 가려서 버린다.

이번에도 알고리즘 7.2.2B를 따른다. 크누스의 단계 이름표 |b1|은 아무도 그리로 뛰지
않는다. \GO/는 쓰지 않는 이름표를 허락하지 않으므로 뺐다.

@<|v|의 후속자 이름표들을 되짚어 찾는다@>=
mems += 4; w[0] = v; wb[0] = bits[v]; wbp[0] = 0
mems++
for a, d = arcs[v], 0; a != 0; a, d = next[a], d+1 {
	mems += 5; w[d+1] = tip[a]; wb[d+1] = bits[tip[a]]; wbp[d+1] = 0
	mems++
}
mems++
for k, g = d, bits[v]; k != 0; k-- {
	mems++; goal[k] = g; g = (g | g>>1) & (1<<k - 1)
}
l = 1

@ 단계 |b2|는 수준 |l|에서 가장 낮은 후보 비트부터 시작한다. 단계 |b3|은 부호 |x|를
시험하고, 통하면 한 수준 내려간다. 단계 |b4|는 다음으로 높은 후보 비트로, 단계
|b5|는 한 수준 위로 간다.

@<|v|의 후속자 이름표들을 되짚어 찾는다@>=
b2:
	if l > d {
		@<해를 기록하고 |b5|로 간다@>
	}
	mems++; x = wb[l] & -wb[l] // 가장 낮은 비트
b3:
	mems += 2; s[l] = s[l-1] | x
	mems += 2
	if gnu[s[l]]&goal[l] != 0 {
		mems++; move[l] = x; l++
		goto b2
	}
b4:
	for x <<= 1; ; x <<= 1 {
		mems++
		if x > wb[l] {
			break
		}
		if x&wb[l] != 0 {
			goto b3
		}
	}
b5:
	l--
	if l != 0 {
		mems++; x = move[l]
		goto b4
	}
@<비트맵이 바뀐 꼭짓점과 그 선행자들을 활성으로 만든다@>

@ 해 하나를 찾으면, 그 해에 쓰인 부호를 저마다 |wbp|에 모은다. 칸 0에는 |v|
자신의 이름표 $y$를 모은다.

@<해를 기록하고 |b5|로 간다@>=
if debug {
	@<찾은 해를 찍는다@>
}
for k = 1; k < l; k++ {
	mems += 2; wbp[k] |= move[k]
}
mems += 3; wbp[0] |= gnu[s[l-1]]
goto b5

@ 크누스의 함수 |printsol|은 여기서만 쓰이므로 절로 풀었다. 이를테면
`\.{\ 07->754727537}'은 꼭짓점 07의 후속자 아홉에 이름표 7, 5, 4, \dots, 7을 붙이는
해를 찾았다는 뜻이다.

@<찾은 해를 찍는다@>=
fmt.Fprintf(errw, " %s->", name[w[0]])
for k = 1; k <= d; k++ {
	fmt.Fprintf(errw, "%d", un[move[k]])
}
fmt.Fprintf(errw, "\n")

@ @<전역 변수@>=
var w, wb, wbp, goal, move, s [maxd + 1]int

@ 해가 하나도 없었으면 불가능한 문제를 받은 것이다.

@<비트맵이 바뀐 꼭짓점과 그 선행자들을 활성으로 만든다@>=
for k = 0; k <= d; k++ {
	mems += 2
	if wbp[k] != wb[k] {
		@<비트맵 |wbp[k]|가 비었으면 모순을 알리고 멈춘다@>
		mems++; u = w[k]
		mems += 2; bits[u] = wbp[k]
		if debug {
			fmt.Fprintf(errw, "  이제 ")
			printvert(u, errw)
			fmt.Fprintf(errw, "\n")
		}
		@<|u|를 활성으로 만든다@>
		@<꼭짓점 |w[k]|의 선행자들의 크기를 고치고 활성으로 만든다@>
	}
}

@ @<비트맵 |wbp[k]|가 비었으면 모순을 알리고 멈춘다@>=
if wbp[k] == 0 {
	errw.Flush()
	fmt.Fprintf(os.Stderr, "%s의 안정성을 시험하다가 모순에 이르렀다!\n",
		name[w[0]])
	os.Exit(-666)
}

@ 선행자 |u|의 크기 |size[u]|에는 |w[k]|의 옛 비트맵 크기가 인수로 들어 있다.
그것을 새 크기로 바꾼다.

@<꼭짓점 |w[k]|의 선행자들의 크기를 고치고 활성으로 만든다@>=
mems++
for a = scra[u]; a != 0; a = next[a] {
	mems++; u = tip[a]
	mems += 3; size[u] = size[u] / uint64(nu[wb[k]]) * uint64(nu[wbp[k]])
	@<|u|를 활성으로 만든다@>
	mems++
}

@ 활성으로 만든 꼭짓점은 목록의 끝에 붙이고, 다음 라운드에 속한다고 적는다.

@<|u|를 활성으로 만든다@>=
mems++
if isactive[u] == 0 {
	mems += 5
	t = llink[active]; rlink[t] = u; llink[active] = u; llink[u] = t
	rlink[u] = active
	mems++; isactive[u] = roundno + 1
}

@* 주 반복문.
만세! 이제 모든 것을 한데 모을 수 있다.

크기가 가장 작은 활성 항목을 고르고 싶을 뿐 아니라, 배열을 돌아가며 훑고도 싶다.
그래서 항목마다 한 ``라운드''에 많아야 한 번 고른다. 값 |isactive[v]|는 |v|가 어느
라운드에 활성이 되는지 알려 준다.

@<안정에 이른다@>=
for {
	mems++
	if rlink[active] == active {
		break
	}
	@<가장 이른 라운드에서 크기가 가장 작은 활성 꼭짓점 |v|를 고른다@>
	mems++; isactive[v] = 0; roundno = q
	mems += 4; u = llink[v]; t = rlink[v]; rlink[u] = t; llink[t] = u
	tests++
	if debug {
		fmt.Fprintf(errw, "%d: ", tests)
		printvert(v, errw)
		fmt.Fprintf(errw, " -> ")
		for a = arcs[v]; a != 0; a = next[a] {
			printvert(tip[a], errw)
		}
		fmt.Fprintf(errw, "\n")
	}
	@<|v|의 후속자 이름표들을 되짚어 찾는다@>
}

@ 라운드 번호가 가장 작은 꼭짓점들 가운데 크기가 가장 작은 것을 고르고, 크기가
같으면 목록에서 먼저 나온 것을 고른다.

@<가장 이른 라운드에서 크기가 가장 작은 활성 꼭짓점 |v|를 고른다@>=
mems++
for u, q = rlink[active], roundno+2; u != active; u = rlink[u] {
	mems++
	if isactive[u] < q {
		mems++; q = isactive[u]; p = size[u]; v = u
	} else if isactive[u] == q {
		mems++
		if size[u] < p {
			p = size[u]; v = u
		}
	}
	mems++
}

@ @<전역 변수@>=
var tests, roundno int

@ 끝으로 모든 꼭짓점과 그 이름표 집합을 표준 출력으로 찍는다. 모두 한 원소 집합이면
그것이 답이다.

@<답을 찍는다@>=
fmt.Fprintf(errw, "%d번 시험하고 %d라운드 만에 안정에 이르렀다. mem %d개.\n",
	tests, roundno, mems)
errw.Flush()
for v = 0; v < verts; v++ {
	if v != 0 {
		fmt.Printf(" ")
	}
	printvert(v, os.Stdout)
}
fmt.Printf("\n")

@* 맞춰 보기.
크누스의 낙관은 옳았다. 301번 시험하고 여섯 라운드 만에 모든 꼭짓점이 안정해지고,
그때 모든 비트맵의 크기가 1이다. 경우를 나눌 필요가 없었다. 그렇게 얻은 답이 들어가며
절의 그림에 회색으로 적은 이름표들이다.

이 판이 옳은지는 세 가지로 확인했다.

첫째, 원본 C 프로그램과 견주었다. 표준 출력은 바이트 하나까지 같다. 표준 오류로
나오는 19만 7천여 줄의 추적도, 내가 한글로 옮긴 두 문구를 빼면 같다. 끝의 mem 수
6865501도 같다.

둘째, 답이 퍼즐의 조건을 모두 만족하는지 따로 셈했다. 꼭짓점마다 그 이름표가
후속자들의 서로 다른 이름표 개수와 같고, 주어진 이름표 32개도 모두 그대로다.

셋째, 답이 하나뿐인지 크누스의 코드와 상관없이 셈했다. 꼭짓점마다 후속자 이름표의
조합을 모두 늘어놓아 걸러 내고, 그래도 후보가 여럿 남으면 가장 작은 꼭짓점에서
경우를 나누는 작은 탐색기를 따로 짰다. 그 탐색기도 답을 꼭 하나 찾고, 그 답은
이 프로그램의 것과 같다. 안정성 시험은 불가능한 이름표만 지우므로, 이것은 놀랄 일이
아니다. 안정해진 뒤 모든 비트맵이 한 원소 집합이라면, 그 답 말고는 답이 있을 수 없다.

@* 색인.
