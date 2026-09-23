\input kotexgweb
\input luamplib.sty
\mplibcodeinherit{enable}
@i types.w
\datethis

\def\title{정사각형 자르기}
\def\adj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-8mu\mathrel-\!}}
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

@* 들어가며.
정사각형을 주어진 개수의 조각으로 잘라서, 그 조각들을 다시 맞추면 주어진 다른
모양이 꽉 차게 하고 싶다. 크누스가 ``실험 삼아'' 쓴 이 프로그램이 그 일을 한다.
모든 것은 칸 단위로 하고 ``대각선으로 자르기''는 없다. 조각은 돌릴 수는 있지만
뒤집을 수는 없다.

조각이 한 덩어리로 이어져 있을 것은 요구하지 않는다. 크누스는 제약을 더 얹고
싶으면 변경 파일로 하라고 했다.

표준 입력으로는 마침표와 별표로 된 줄들이 들어온다. 별표가 모양에 쓰이는 칸이다.
별표의 수는 완전제곱수여야 한다. 그래야 같은 넓이의 정사각형이 있다.

바라는 조각의 수는 명령줄 인자로 준다.

@ 이것은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{back-dissect.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/back-dissect.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Fri, 25 May 2018 23:47:43 GMT}다.

프로그램이 찍는 말은 원본의 영어를 그대로 두었다. 그래야 두 프로그램의 출력을
바이트 단위로 견줄 수 있다. 옮기다가 원본의 결함 둘을 만났다. 고쳤고, 이야기는
맨 뒤에 적었다.

@ 프로그램의 뼈대는 이렇다. 명령줄을 읽고, 모양을 읽고, 해를 모두 찾고, 셈한 것을
알린다.

변수 이름은 원본을 따랐다. 함수 |main|의 지역 변수도 원본처럼 한데 모아 두고 여러
절에서 돌려 쓴다. 원본은 |goto|를 아낌없이 쓰는데, \GO/의 |goto|는 새 변수가 눈에
들어오는 자리로는 뛰지 못한다. 변수를 모두 맨 앞에서 선언해 두면 그 걱정이 없다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
)

@<상수@>
@<자료형@>
@<전역 변수@>
@<함수들@>

func main() {
	var a, b, dd, i, j, k, l, ll, lll, m, n, nn, slack int
	@<명령줄을 처리한다@>
	@<모양을 읽는다@>
	@<해를 모두 찾는다@>
	@<실행 통계를 알린다@>
}

@ 입력은 $32$줄, 줄마다 $32$칸까지다. 조각은 $7$개까지다.

@<상수@>=
const (
	maxn = 32 // 입력의 줄 수와 줄마다의 칸 수의 한계
	maxd = 7  // 조각 수의 한계
)

@ 인자는 조각의 수 $d$ 하나이고, 그 뒤에 무엇이든 더 적으면 적은 개수만큼 수다스러워진다.
\CEE/의 |sscanf|처럼 \GO/의 |fmt.Sscanf|도 앞의 빈칸을 건너뛰고 수 뒤의 찌꺼기는
따지지 않으므로, \.{3x}를 $3$으로 읽는 것까지 원본과 같다.

@<명령줄을 처리한다@>=
if len(os.Args) < 2 {
	fmt.Fprintf(os.Stderr, "Usage: %s d [verbose] [extra verbose] < foo.dots\n",
		os.Args[0])
	os.Exit(-1)
}
if k, _ = fmt.Sscanf(os.Args[1], "%d", &d); k != 1 {
	fmt.Fprintf(os.Stderr, "Usage: %s d [verbose] [extra verbose] < foo.dots\n",
		os.Args[0])
	os.Exit(-1)
}
if d < 2 || d > maxd {
	fmt.Fprintf(os.Stderr, "The number of pieces should be between 2 and %d, not %d!\n",
		maxd, d)
	os.Exit(-2)
}
vbose = len(os.Args) - 2

@ @<전역 변수@>=
var (
	d      int // 명령줄 인자: 색의 수, 곧 조각의 수
	vbose  int // 수다의 정도
	maxrow int // 모양에 쓰인 가장 큰 행 번호
	maxcol int // 모양에 쓰인 가장 큰 열 번호
)

@ 칸 $(i,j)$는 수 하나 |place(i,j)|로 나타낸다. 정사각형의 칸이든 모양의 칸이든
마찬가지다. 함수 |place|는 음수도 마다하지 않아서, 옮김의 양 $(a,b)$도 같은
방식으로 적을 수 있다. 그러면 칸을 옮기는 일이 덧셈 한 번이 된다.

@<함수들@>=
func place(i, j int) int { return i*maxn + j }

@ 모양을 한 줄씩 읽는다. 원본은 크기 $37$바이트의 버퍼에 |fgets|로 읽는데, 그러면
긴 줄이 여러 토막으로 끊긴다. 이 판은 줄을 통째로 읽는다. 그 까닭은 맨 뒤에
적었다.

@<모양을 읽는다@>=
for i, nn = 0, 0; ; i++ {
	buf, err := in.ReadString('\n')
	if buf == "" && err != nil {
		break
	}
	if i >= maxn {
		fmt.Fprintf(os.Stderr, "Recompile me: I allow at most %d lines of input!\n",
			maxn)
		os.Exit(-3)
	}
	@<모양의 |i|행을 읽는다@>
}
@<입력이 제대로 된 크기인지 살핀다@>

@ 별표가 나올 때마다 그 칸을 |site|에 적고 이름을 붙인다. 모양의 칸 $(i,j)$의 이름은
\.{$ii$b$jj$}이다. 여기서 $ii$와 $jj$는 두 자리로 적은 $i$와 $j$다. 이름이 있으면
모양의 칸이고 없으면 빈 칸이니, 이름이 곧 모양의 지도 구실도 한다.

@<모양의 |i|행을 읽는다@>=
for j = 0; j < len(buf) && buf[j] != '\n'; j++ {
	if buf[j] == '*' {
		if j > maxcol {
			maxcol = j
			if j >= maxn {
				fmt.Fprintf(os.Stderr, "Recompile me: I allow at most %d columns of input!\n",
					maxn)
				os.Exit(-5)
			}
		}
		site[nn] = place(i, j); nn++
		bname[place(i, j)] = fmt.Sprintf("%02db%02d", i, j)
	}
}

@ 모양에 별표가 |nn|개 있다면, 정사각형 한 변의 길이 $n$은 $\sqrt{nn}$이다.
정사각형의 칸 $(i,j)$에는 \.{$ii$a$jj$}라는 이름을 붙인다.

종료 부호 $-666$은 원본의 것이다. 운영체제는 그 아래 여덟 비트만 보므로 셸에는
$102$로 보인다.

@<입력이 제대로 된 크기인지 살핀다@>=
maxrow = i - 1
if maxrow < 0 {
	fmt.Fprintf(os.Stderr, "There was no input!\n")
	os.Exit(-666)
}
fmt.Fprintf(os.Stderr, "OK, I've got a shape with %d lines and %d cells.\n",
	i, nn)
for n = 1; n*n < nn; n++ {
} // 모양에는 별표가 |nn|개 있다
if n*n != nn {
	fmt.Fprintf(os.Stderr, "The number of cells should be a positive perfect square!\n")
	os.Exit(-4)
}
for i = 0; i < n; i++ {
	for j = 0; j < n; j++ {
		aname[place(i, j)] = fmt.Sprintf("%02da%02d", i, j)
	}
}
complement = place(n-1, n-1)

@ @<전역 변수@>=
var (
	in    = bufio.NewReader(os.Stdin) // 모양을 읽어 들일 곳
	aname [maxn * maxn]string         // 정사각형의 칸들의 이름
	bname [maxn * maxn]string         // 모양의 칸들의 이름
	site  [maxn * maxn]int            // 모양의 칸들이 있는 자리
)

@* 알고리즘.
문제의 특별한 경우 하나를 들여다보며 감을 잡고 개념을 분명히 해 보자. 입력이
$$\vcenter{\halign{\tt#\hfil\cr
****\cr *..*\cr .***\cr}}$$
이고, 별표로 적힌 칸들을 $d=2$개의 조각으로 잘라 $3\times3$ 정사각형으로 맞추고
싶다고 하자. (원문에는 ``여덟 칸''이라고 적혀 있지만 세어 보면 아홉 칸이다.)
방법 하나는 금방 보일 것이다. 맨 왼쪽 열의 두 칸을 떼어 내 $90^\circ$ 돌린 다음,
나머지 일곱 칸이 벌린 ``턱'' 사이에 끼우면 된다. 컴퓨터가 이것을 찾아내게 하려면
어떻게 해야 할까?

일반적인 문제의 해는 정사각형을 $d$가지 색으로 칠하는 방법으로 볼 수 있다.
정사각형의 칸들은 $0\le i,j<n$인 $(i,j)$이고, 이 칸들 하나하나가 다른 모양의 서로
다른 자리 $(i',j')$로 옮겨져야 한다. 옮기는 방법은 돌리기와 밀기다. 같은 색의
칸들은 돌리는 양도 미는 양도 같아야 한다. 앞의 예에서는 칸들을
$$\vcenter{\halign{\tt#\hfil\cr
111\cr221\cr111\cr}}$$
로 칠할 수 있다. 색~\.1인 칸들은 오른쪽으로 한 칸 밀고, 색~\.2인 칸들은 이를테면
정사각형의 가운데를 축으로 시계 방향으로 $90^\circ$ 돌린 다음 왼쪽으로 한 칸 민다.
그러면 결과가
$$\vcenter{\halign{\tt#\hfil\cr
2111\cr 2..1\cr .111\cr}}$$
로, 바라던 대로다. 이 두 가지 색칠이 표준 출력으로 나간다.

@ 쓸 수 있는 옮김의 양은 언제나 정해진 집합을 이룬다. 그것을 $(a_0,b_0)$, $(a_1,b_1)$,
\dots, $(a_{m-1},b_{m-1})$이라고 하자. 정사각형을 그만큼 밀었을 때 다른 모양과 적어도 한
칸이 겹치는 양들이다. 예제에는 그런 옮김이 $m=29$개 있다. 곧
$\bar2\bar2$,
$\bar2\bar1$,
$\bar20$,
$\bar21$,
$\bar22$,
$\bar23$,
$\bar1\bar2$,
$\bar1\bar1$,
$\bar10$,
$\bar11$,
$\bar12$,
$\bar13$,
$0\bar2$,
$0\bar1$,
$00$,
$01$,
$02$,
$03$,
$1\bar2$,
$1\bar1$,
$10$,
$11$,
$12$,
$13$,
$2\bar1$,
$20$,
$21$,
$22$,
$23$이다. (여기서 $\bar2$는 $-2$를 뜻한다. 프로그램은 행과 열의 좌표 $(i,j)$를 쓰므로
옮김의 왼쪽 좌표는 아래로 미는 양이고 오른쪽 좌표는 오른쪽으로 미는 양이다. 이
목록에는 $-2\le a\le2$이고 $-2\le b\le 3$인 $(a,b)$가 $2\bar2$ 하나만 {\it 빼고\/}
모두 들어 있다. 정사각형을 아래로 둘, 왼쪽으로 둘 밀면 다른 모양과 한 칸도 겹치지
않기 때문이다.)

옮기는 방법 하나는 $0\le s<m$이고 $0\le t<4$인 짝 $(s,t)$로 나타낼 수 있다.
``시계 방향으로 $90t$도 돌린 다음 $(a_s,b_s)$만큼 민다''는 뜻이다. 아래 알고리즘의
바깥 반복문은 옮기는 방법들의 모든 열 $(s_1,t_1)$, \dots, $(s_d,t_d)$를 훑고, 그
방법들로 이루어진 이분 매칭 문제를 푼다. 이를테면 $(s_1,t_1)$이 ``오른쪽으로 한 칸
밀기''이고 $(s_2,t_2)$가 ``$90$도 돌린 다음 왼쪽으로 한 칸 밀기''라면, 완전 매칭이
예제의 해를 나타내는 이분 그래프의 변은 색~\.1에 대해
$$
\.{0a0}\adj\.{0b1},\quad
\.{0a1}\adj\.{0b2},\quad
\.{0a2}\adj\.{0b3},\quad
\.{1a2}\adj\.{1b3},\quad
\.{2a0}\adj\.{2b1},\quad
\.{2a1}\adj\.{2b2},\quad
\.{2a2}\adj\.{2b3}
$$
이고 색~\.2에 대해
$$
\.{0a0}\adj\.{0b1},\quad
\.{0a2}\adj\.{2b1},\quad
\.{1a0}\adj\.{0b0},\quad
\.{1a1}\adj\.{1b0}
$$
이다. (여기서 \.{0a0}은 정사각형의 $0$행 $0$열에 있는 칸이고, \.{0b0}은 다른 모양의
$0$행 $0$열에 있는 칸이다. 프로그램이 실제로 찍는 이름은 두 자리씩 적은
\.{00a00}과 \.{00b00}이다.) 변 $\.{0a0}\adj\.{0b1}$이 색마다 한 번씩 {\it 두 번\/}
나오는 것에 눈여겨보자. 거기서 {\it 또 다른\/} 해가 나온다.
$$\vcenter{\halign{\tt#\hfil\cr
211\cr221\cr111\cr}}\qquad
\vcenter{\halign{\tt#\hfil\cr
2211\cr 2..1\cr .111\cr}}$$

@ 이 예제를 프로그램에 먹이면 해가 {\it 셋\/} 나온다. 크누스가 든 두 해는 셋째와
둘째다. 어느 것이나 정사각형을 통째로 돌려 놓은 모습이고 색 이름도 서로 바뀌어 있다.
까닭은 곧 보게 된다. 첫째 해는 크누스가 들지 않은 것이다. 정사각형의 가운데 열 아래쪽 두
칸을 떼어 모양의 맨 왼쪽 열로 보낸다.

$$\mplibcode
u := 4mm;
def cellbox(expr i, j, o) =
  (unitsquare scaled u shifted (o + (j*u, -(i+1)*u)))
enddef;
def pat(expr s, w, i, j) =
  if (i < 0) or (j < 0) or (j >= w) or (i*w + j >= length s): "."
  else: substring (i*w + j, i*w + j + 1) of s fi
enddef;
def grid(expr s, w, h, o) =
  for i = 0 upto h - 1: for j = 0 upto w - 1:
    if pat(s, w, i, j) <> ".":
      fill cellbox(i, j, o) withcolor (1.02 - .16 * scantokens pat(s, w, i, j)) * white;
      draw cellbox(i, j, o) withpen pencircle scaled .2pt;
    fi
  endfor endfor
  for i = 0 upto h - 1: for j = 0 upto w - 1:
    if pat(s, w, i, j) <> ".":
      if pat(s, w, i - 1, j) <> pat(s, w, i, j):
        draw (o + (j*u, -i*u)) -- (o + ((j+1)*u, -i*u)) withpen pencircle scaled 1.2pt; fi
      if pat(s, w, i + 1, j) <> pat(s, w, i, j):
        draw (o + (j*u, -(i+1)*u)) -- (o + ((j+1)*u, -(i+1)*u)) withpen pencircle scaled 1.2pt; fi
      if pat(s, w, i, j - 1) <> pat(s, w, i, j):
        draw (o + (j*u, -i*u)) -- (o + (j*u, -(i+1)*u)) withpen pencircle scaled 1.2pt; fi
      if pat(s, w, i, j + 1) <> pat(s, w, i, j):
        draw (o + ((j+1)*u, -i*u)) -- (o + ((j+1)*u, -(i+1)*u)) withpen pencircle scaled 1.2pt; fi
    fi
  endfor endfor
enddef;
def sol(expr sq, n, sh, w, h, o) =
  grid(sq, n, n, o);
  drawarrow (o + ((n+.3)*u, -.5n*u)) -- (o + ((n+1.5)*u, -.5n*u));
  grid(sh, w, h, o + ((n+1.8)*u, 0));
enddef;
beginfig(1);
  sol("222212212", 3, "12221..2.222", 4, 3, (0, 0));
  sol("211212222", 3, "11221..2.222", 4, 3, (10.8u, 0));
  sol("212212222", 3, "12221..2.222", 4, 3, (21.6u, 0));
  label(btex 해~1 etex, (4.4u, -3.8u));
  label(btex 해~2 etex, (15.2u, -3.8u));
  label(btex 해~3 etex, (26u, -3.8u));
endfig;
\endmplibcode$$
\figcap{예제의 세 해. 왼쪽이 정사각형, 오른쪽이 다른 모양이다. 색 번호가 클수록
칸이 짙고, 굵은 선이 자르는 선이다.}

@ 해의 수가 대략 $d!$분의 일로 준다. 색들을 서로 바꾸어도 해는 달라지지 않으니
$$(s_1,t_1)\le (s_2,t_2)\le\cdots\le (s_d,t_d)\qquad\hbox{(사전식으로)}$$
라고 가정해도 되기 때문이다. 게다가 $t_1=0$이라고 가정하면 또 $4$분의 일로 준다.
정사각형은 돌려도 제 모양이기 때문이다. 앞의 그림에서 해~2와 해~3이 크누스의 해를
돌려 놓은 모습인 것이 이 때문이다.

(크누스는 `$\le$' 대신 `$<$'를 써서 $(s_1,t_1)<\cdots<(s_d,t_d)$라고 적을 수도 있었다고
했다. 조각 수 $d$가 가장 작은 해에서는 $(s_k,t_k)=(s_{k+1},t_{k+1})$인 경우가 나오지
않는다. 그런 경우에는 색 $k$와 $k+1$을 하나로 합칠 수 있기 때문이다. 하지만 문제를
넓혀 제약을 더 얹으면 같은 경우가 생길 수도 있다. 이를테면 색마다 칸들이 이어져
있기를 바라거나 칸의 수에 한계를 둘 수도 있다.)

생겨나는 매칭 문제의 대부분은 대번에 풀 수 없다는 것이 드러난다. 외톨이 꼭짓점이 있기
때문이다. 나머지도 대부분은 아주 쉽게 풀린다. 차수가 $1$인 꼭짓점이 많아서 그
짝이 강제되기 때문이다. 알고리즘은 $s_1\le\cdots\le s_d$인 옮김의 집합 ${m+d-1\choose d}$개를
모두 들여다보되, 그 옮김들이 주어진 모양의 칸을 모두 덮을 때만 더 파고든다. 그런
때에는 $t_2$, \dots,~$t_d$의 선택 $4^{d-1}$가지를 따져 보는데, 그 회전들이
정사각형의 칸을 모두 덮을 때만 매칭에 들어간다.

이를테면 예제에서 모양의 칸을 넷보다 많이 덮는 옮김은 $00$, $01$, $02$뿐이다. 두
옮김으로 아홉 칸을 덮어야 하니 이 가운데 적어도 하나는 있어야 한다. 그러니
${m+d-1\choose d}$는 겁낼 만큼 많은 부분 문제가 아니다.

@ 옮기는 방법들의 열 $(s_1,\ldots,s_d)$를 사전식 순서로 훑는 바깥 반복문이다. 다음
열로 넘어갈 때는 끝에서부터 $m-1$에 이른 자리를 건너뛰고, 처음으로 더 키울 수 있는
자리 $k$를 하나 키운 다음 그 뒤를 모두 같은 값으로 채운다.

원본은 이 건너뛰기에 $k>0$이라는 조건을 달지 않았다. 이 조건이 왜 필요한지는 맨
뒤에서 이야기한다.

@<해를 모두 찾는다@>=
@<쓸 수 있는 옮김의 표를 만든다@>
for {
	@<모양이 $\{s_1,\ldots,s_d\}$로 덮이지 않으면 |shapenot|으로 간다@>
	counta++
	@<회전의 열 $(t_2,\ldots,t_d)$를 모두 훑는다@>
shapenot:
	for k = d; k > 0 && s[k] == m-1; k-- {
	}
	if k == 0 {
		break
	}
	for j = s[k] + 1; k <= d; k++ {
		s[k] = j
	}
}

@ 회전의 열 $(t_2,\ldots,t_d)$는 네 진법의 수처럼 센다. 이웃한 두 색의 옮김과 회전이
똑같으면 건너뛴다.

앞에서 사전식 순서를 가정한다고 했지만, 코드가 실제로 막는 것은 $s$의 순서와
이웃한 짝이 똑같은 경우뿐이다. 그러니 $s_k=s_{k+1}$이면서 $t_k>t_{k+1}$인 열도 걸러지지
않는다. 그런 열은 색 $k$와 $k+1$을 맞바꾼 열과 같은 해를 내니, 색 이름만 다른 해가
두 번 찍힌다. 이를테면 예제를 $d=3$으로 돌리면 해 $919$개 가운데 $58$개가 그렇게
나온 것이다. 출력이 원본과 같도록 이 판도 그대로 두었다.

@<회전의 열 $(t_2,\ldots,t_d)$를 모두 훑는다@>=
for k = 2; k <= d; k++ {
	t[k] = 0
}
for {
	for k = 2; k <= d; k++ {
		if s[k] == s[k-1] && t[k] == t[k-1] {
			goto squarenot
		}
	}
	@<정사각형이 $\{(s_1,t_1),\ldots,(s_d,t_d)\}$로 덮이지 않으면 |squarenot|으로 간다@>
	countb++
	@<완전 매칭이 있는지 살핀다@>
squarenot:
	for k = d; t[k] == 3; k-- {
		t[k] = 0
	}
	if k == 1 {
		break
	}
	t[k]++
}

@ 쓸 수 있는 옮김의 표를 만든다. 옮김 $(a,b)$마다 정사각형을 그만큼 밀었을 때 겹치는
모양의 칸들을 모아 |bcover|에 적고, 옮김 자체는 |shift|에 |place(a,b)|로 적는다.

원본은 |bcover|를 $4\cdot32^2\times32^2$ 크기의 정수 배열로 두고(16메가바이트다) 칸의
수를 따로 |bcovered|에 적는다. 이 판은 옮김마다 겹치는 칸만큼의 조각(slice)을 붙이고,
칸의 수는 그 길이로 대신한다.

@<쓸 수 있는 옮김의 표를 만든다@>=
for m, a = 0, 1-n; a <= maxrow; a++ {
	for b = 1 - n; b <= maxcol; b++ {
		var cov []int // 이 옮김이 덮는 모양의 칸들
		for i = max(-a, 0); i < n && a+i <= maxrow; i++ {
			for j = max(-b, 0); j < n && b+j <= maxcol; j++ {
				if bname[place(a+i, b+j)] != "" {
					cov = append(cov, place(a+i, b+j))
				}
			}
		}
		@<|cov|가 비지 않았으면 옮김 $(a,b)$를 표에 넣는다@>
	}
}
if vbose > 0 {
	fmt.Fprintf(os.Stderr, "There are %d legal shifts.\n", m)
}

@ @<|cov|가 비지...@>=
if len(cov) > 0 {
	if vbose > 1 {
		fmt.Fprintf(os.Stderr, " S[%d]=(%d,%d)\n", m, a, b)
	}
	shift = append(shift, place(a, b))
	bcover = append(bcover, cov)
	m++
}

@ 모양이 덮이는지 살핀다. 먼저 넓이만 따진다. 옮김들이 덮는 칸의 수를 모두 더한 것이
|nn|보다 작으면 볼 것도 없다. 넉넉하면 그 넉넉한 만큼이 |slack|이다. 두 번 덮이는
칸이 나올 때마다 |slack|을 하나씩 깎는데, 깎을 것이 없으면 어딘가 덮이지 않은 칸이
있다는 뜻이다.

@<모양이 $\{s_1,\ldots,s_d\}$로...@>=
for slack, k = -nn, 1; k <= d; k++ {
	slack += len(bcover[s[k]])
}
if slack < 0 {
	goto shapenot
}
for k = 0; k < nn; k++ {
	blen[site[k]] = 0
}
for k = 1; k <= d; k++ {
	for _, l = range bcover[s[k]] {
		if blen[l] == 0 {
			blen[l] = 1
		} else {
			if slack == 0 {
				goto shapenot
			}
			slack--
			blen[l]++
		}
	}
}

@ 두 번째로 덮이는지를 살피는 김에 변의 표도 만든다. 변 하나는 그 색과 이웃의 자리로
나타낸다. 함수 |pack|이 둘을 정수 하나에 담는다. 아래 $16$비트가 자리이고 그 위가
색이다.

정사각형의 칸 |ll|에는 |alen[ll]|개의 변 |aa[ll][0]|, \dots가 있고, 모양의 칸 |l|에는
|blen[l]|개의 변 |bb[l][0]|, \dots가 있다. 변 하나는 양쪽 끝에 한 번씩 적힌다.
같은 색의 칸들은 서로 다른 자리로 가므로, 한 칸에 걸리는 변은 색마다 많아야 하나다.
그러니 칸마다 |maxd|칸이면 넉넉하다.

@<함수들@>=
func pack(c, p int) int { return c<<16 + p }

@ 모양의 칸 |l|을 옮김 |j|만큼 되돌리면 정사각형의 칸 |ll|이 나온다. 거기에 회전
|t[k]|를 거꾸로 적용한다. $90^\circ$ 회전은 $(i,j)\mapsto(j,n-1-i)$이고,
$180^\circ$ 회전은 |complement|에서 빼기 한 번이다.

@<정사각형이 $\{(s_1,t_1),\ldots,(s_d,t_d)\}$로...@>=
for k = 0; k < nn; k++ {
	blen[site[k]] = 0
}
for i = 0; i < n; i++ {
	for j = 0; j < n; j++ {
		alen[place(i, j)] = 0
	}
}
for slack, k = -nn, 1; k <= d; k++ {
	slack += len(bcover[s[k]])
}
for k = 1; k <= d; k++ {
	j = s[k]
	for _, l = range bcover[j] {
		@<모양의 칸 |l|에 닿는 정사각형의 칸 |ll|을 찾는다@>
		if alen[ll] != 0 {
			if slack == 0 {
				goto squarenot
			}
			slack--
		}
		aa[ll][alen[ll]] = pack(k, l); alen[ll]++
		bb[l][blen[l]] = pack(k, ll); blen[l]++
	}
}

@ @<모양의 칸 |l|에 닿는...@>=
ll = l - shift[j]
if t[k]&1 != 0 {
	q, r := ll/maxn, ll%maxn
	ll = place(r, n-1-q) // 시계 방향으로 돌린다
}
if t[k]&2 != 0 {
	ll = complement - ll
}

@ @<전역 변수@>=
var (
	alen       [maxn * maxn]int       // 정사각형의 칸마다 남은 변의 수
	blen       [maxn * maxn]int       // 모양의 칸마다 남은 변의 수
	aa         [maxn * maxn][maxd]int // 정사각형 쪽의 변들
	bb         [maxn * maxn][maxd]int // 모양 쪽의 변들
	shift      []int                  // 옮김들의 양
	complement int                    // $180^\circ$ 회전에 쓰는 값
	bcover     [][]int                // 옮김마다 덮는 칸들
	s          [maxd + 1]int          // 지금의 옮김의 열
	t          [maxd + 1]int          // 지금의 회전의 열
)

@* 미리 짝짓기.
그 모든 고리를 뛰어넘고 나면 완전 매칭 문제 하나가 남는다. 그런데 그 매칭 문제는 대개
아주 시시하다. 그러니 무언가 멋진 것을 하기 전에 쉬운 경우부터 걸러 내는 것이 좋다.

대부분의 경우 몇몇 수는 강제된다. 정사각형의 칸 하나에 짝이 될 수 있는 모양의 칸이
하나뿐이거나, 그 반대이기 때문이다. 먼저 그런 뻔한 수부터 모두 둔다.

이 절의 코드는 |goto done|으로 매칭 문제를 버린다. 이름표 |done|은 이 절의 맨 끝에
있고, 곧바로 다음 회전으로 넘어간다.

@<완전 매칭이 있는지 살핀다@>=
if vbose > 1 {
	@<매칭 문제를 표준 오류에 보인다@>
}
@<정사각형 쪽에서 강제된 수를 두거나 |done|으로 간다@>
countc++
@<모양 쪽에서 강제된 수를 두거나 |done|으로 간다@>
@<남은 강제된 수를 모두 둔다@>
countd++
@<남은 이분 그래프의 완전 매칭을 모두 찾는다@>
done:

@ 매칭 문제를 보일 때도, 강제된 수를 둔 뒤에 남은 문제를 보일 때도, 정사각형의 칸
하나와 그 변들을 한 줄에 적는다. 변은 모양의 칸의 이름 뒤에 점과 색을 붙여 적는다.
두 곳에서 쓰므로 함수로 둔다.

@<함수들@>=
func printEdges(p int) {
	fmt.Fprintf(os.Stderr, "  %s --", aname[p])
	for k := 0; k < alen[p]; k++ {
		fmt.Fprintf(os.Stderr, " %s.%d", bname[aa[p][k]&0xffff], aa[p][k]>>16)
	}
	fmt.Fprintf(os.Stderr, "\n")
}

@ @<매칭 문제를 표준 오류에 보인다@>=
fmt.Fprintf(os.Stderr, " Trying to match")
for k = 1; k <= d; k++ {
	fmt.Fprintf(os.Stderr, " %d^%d", s[k], t[k])
}
fmt.Fprintf(os.Stderr, ":\n")
for i = 0; i < n; i++ {
	for j = 0; j < n; j++ {
		printEdges(place(i, j))
	}
}

@ 정사각형의 칸을 차례로 본다. 변이 둘 이상이면 아직 짝을 못 지은 칸의 목록 |alist|에
넣는다. 변이 하나뿐이면 그 짝이 강제되니 곧바로 짝짓는다. 짝지은 두 칸에는 그 변의
색을 칠한다.

@<정사각형 쪽에서 강제된 수를 두거나 |done|으로 간다@>=
for acount, i = 0, 0; i < n; i++ {
	for j = 0; j < n; j++ {
		p := place(i, j)
		if alen[p] > 1 {
			apos[p] = acount; alist[acount] = p; acount++
		} else {
			l = aa[p][0] & 0xffff
			if blen[l] == 0 {
				goto done // 모양의 그 자리는 이미 찼다
			}
			acolor[p] = aa[p][0] >> 16; bcolor[l] = acolor[p]
			if blen[l] == 1 {
				blen[l] = 0
			} else {
				@<모양의 자리 |l|로 가는 다른 변을 모두 없앤다@>
			}
		}
	}
}

@ 크누스는 ``섣부른 최적화는 프로그래밍에서 모든 악의 뿌리''라는 말을 인용하고는,
그래도 특별한 경우에 이 프로그램을 빠르게 만들고 싶은 마음을 참을 수 없었다고 했다.

변을 없애면 |alist|에 있는 정사각형의 칸의 |alen|이 $1$로 줄어 수가 더 강제될 수도
있다. 그 걱정은 나중에 한다.

변 하나는 양쪽 끝에 한 번씩 적혀 있으니, 모양 쪽의 변을 없앨 때는 정사각형 쪽에 적힌
``맞은편 판'' |opp|도 찾아 없애야 한다. 그것은 목록의 마지막 변을 그 자리로 옮겨 와
지운다.

@<모양의 자리 |l|로 가는...@>=
for k = 0; k < blen[l]; k++ {
	ll = bb[l][k] & 0xffff
	if ll != p {
		opp := bb[l][k]&0xffff0000 + l // 이 변의 맞은편 판
		dd = alen[ll] - 1; alen[ll] = dd
		if dd == 0 {
			goto done
		}
		for a = 0; aa[ll][a] != opp; a++ {
		}
		if a > dd {
			debug("ahi")
		}
		if a != dd {
			aa[ll][a] = aa[ll][dd]
		}
	}
}
blen[l] = 0

@ 이번에는 모양 쪽에서 같은 일을 한다. 변이 둘 이상인 모양의 칸은 목록 |blist|에
넣고, 하나뿐인 칸은 곧바로 짝짓는다. 그러고 나면 두 목록의 길이가 같아야 한다.

@<모양 쪽에서 강제된 수를 두거나 |done|으로 간다@>=
if acount != 0 {
	for bcount, i = 0, 0; i < nn; i++ {
		l = site[i]
		if blen[l] == 0 {
			continue // 이 칸은 이미 강제로 짝지었다
		}
		if blen[l] > 1 {
			bpos[l] = bcount; blist[bcount] = l; bcount++
		} else {
			ll = bb[l][0] & 0xffff
			if alen[ll] == 0 {
				goto done // 정사각형의 그 자리는 이미 찼다
			}
			acolor[ll] = bb[l][0] >> 16; bcolor[l] = acolor[ll]
			acount--
			@<정사각형의 칸 |ll|을 쉬게 한다@>
		}
	}
	if acount != bcount {
		debug("count mismatch")
	}
}

@ 짝지은 정사각형의 칸 |ll|을 |alist|에서 빼고, |l| 말고 다른 모양의 칸으로 가는
변들을 모두 없앤다. 이 절은 두 곳에 끼워진다.

@<정사각형의 칸 |ll|을 쉬게 한다@>=
j = apos[ll]
if j != acount {
	lll = alist[acount]; alist[j] = lll; apos[lll] = j
}
if alen[ll] != 1 {
	for k = 0; k < alen[ll]; k++ {
		lll = aa[ll][k] & 0xffff
		if lll != l {
			opp := aa[ll][k]&0xffff0000 + ll // 이 변의 맞은편 판
			dd = blen[lll] - 1; blen[lll] = dd
			if dd == 0 {
				goto done
			}
			for b = 0; bb[lll][b] != opp; b++ {
			}
			if b > dd {
				debug("bhi")
			}
			if b != dd {
				bb[lll][b] = bb[lll][dd]
			}
		}
	}
	alen[ll] = 0
}

@ 조심할 것이 있다. 여기서 |acount|와 |bcount|를 조금 까다롭게 쓴다. 두 목록의 길이는
늘 같으니 |acount| 하나로 둘 다 나타내고, |bcount|에는 지난번의 |acount|를 넣어 둔다.
한 바퀴 돌아도 달라진 것이 없으면 멈춘다. (크누스는 ``약한 저항력을 다시 한 번
사과한다''고 적었다.)

@<남은 강제된 수를 모두 둔다@>=
for acount != 0 {
	for i = 0; i < acount; i++ {
		if ll = alist[i]; alen[ll] == 1 {
			@<|ll|에서 수를 강제한다@>
		}
	}
	for i = 0; i < acount; i++ {
		if l = blist[i]; blen[l] == 1 {
			@<|l|에서 수를 강제한다@>
		}
	}
	if acount == bcount {
		break
	}
	bcount = acount
}

@ 목록에서 칸 하나를 뺄 때는 마지막 칸을 그 자리로 옮겨 온다. 옮겨 온 칸도 살펴야
하니 |i|를 하나 되돌린다.

@<|ll|에서 수를 강제한다@>=
acount--
if i < acount {
	lll = alist[acount]; alist[i] = lll; apos[lll] = i; i--
}
l = aa[ll][0] & 0xffff
acolor[ll] = aa[ll][0] >> 16; bcolor[l] = acolor[ll]
@<모양의 칸 |l|을 쉬게 한다@>

@ @<모양의 칸 |l|을 쉬게 한다@>=
j = bpos[l]
if j < acount {
	lll = blist[acount]; blist[j] = lll; bpos[lll] = j
}
if blen[l] != 1 {
	for k = 0; k < blen[l]; k++ {
		lll = bb[l][k] & 0xffff
		if lll != ll {
			opp := bb[l][k]&0xffff0000 + l // 이 변의 맞은편 판
			dd = alen[lll] - 1; alen[lll] = dd
			if dd == 0 {
				goto done
			}
			for a = 0; aa[lll][a] != opp; a++ {
			}
			if a > dd {
				debug("chi")
			}
			if a != dd {
				aa[lll][a] = aa[lll][dd]
			}
		}
	}
}

@ @<|l|에서 수를 강제한다@>=
acount--
if i < acount {
	lll = blist[acount]; blist[i] = lll; bpos[lll] = i; i--
}
ll = bb[l][0] & 0xffff
acolor[ll] = bb[l][0] >> 16; bcolor[l] = acolor[ll]
@<정사각형의 칸 |ll|을 쉬게 한다@>

@ @<전역 변수@>=
var (
	alist, blist   [maxn * maxn]int // 아직 짝짓지 않은 칸들의 목록
	apos, bpos     [maxn * maxn]int // 그 목록의 역
	acount, bcount int              // 그 목록의 길이
	acolor, bcolor [maxn * maxn]int // 해의 색칠
	count          uint64           // 해의 수
	counta, countb, countc, countd, counte uint64 // 요긴한 자리에 닿은 횟수
)

@ 요긴한 자리에 닿은 횟수 다섯은 맨 끝에 통계로 찍힌다. 모양을 덮은 옮김의
집합(|counta|), 정사각형까지 덮은 회전의 열(|countb|), 정사각형 쪽의 강제를
견딘 문제(|countc|), 모든 강제를 견딘 문제(|countd|), 그리고 춤까지 춰야 했던
문제(|counte|)의 수다.

또 하나는 결코 불리지 않아야 할 함수다. ``있을 수 없는 일''이 일어나면 표준 출력을
비우고 표준 오류에 알린다.

@<함수들@>=
func debug(s string) {
	out.Flush()
	fmt.Fprintf(os.Stderr, "***%s!\n", s)
}

@* 매칭.
가끔은 정말로 할 일이 있다.

크누스는 처음에는 이 문제가 좀처럼 어렵지 않으리라고 생각했다. 그래서 알고리즘
7.2.2B를 따라 무식하게 되짚어 찾기만 썼다. 그런데 뜻밖에 많은 큰 부분 문제가
나왔다. 그래서 {\mc DANCE}를 뜯어고쳐 원래의 춤추는 링크 알고리즘을 넣었다.

나는 이 부분을 내 라이브러리
\pdfURL{dancing-cells}{https://github.com/sjnam/dancing-cells}로 바꿔 보기도 했다.
매칭 문제마다 \.{DLX} 텍스트를 지어 넘기면 된다. 다만 같은 두 칸 사이에 색만 다른
변이 둘 있으면 이름만으로는 두 옵션을 가려낼 수 없어서, 색마다 색 붙은 부 아이템을
하나씩 얹어야 했다. 해의 집합은 원본과 같았다. 그런데 한 매칭 문제 안에서 해가 나오는
순서가 달라서 원본과 바이트 단위로 견줄 수 없게 되고, 수다스럽게 돌릴 때 찍는 춤의
기록도 사라지고, 텍스트를 짓고 읽는 값 때문에 두 배쯤 느렸다. 그래서 크누스의 춤을
그대로 옮겼다.

@<남은 이분 그래프의 완전 매칭을 모두 찾는다@>=
if acount == 0 {
	@<해를 찍는다@>
} else {
	@<춤에 쓰는 지역 변수@>
	counte++
	if vbose > 1 {
		@<남은 매칭 문제를 표준 오류에 보인다@>
	}
	@<춤을 준비한다@>
	@<춤춘다@>
}

@ @<남은 매칭 문제를 표준 오류에 보인다@>=
fmt.Fprintf(os.Stderr, " which reduces to:\n")
for i = 0; i < acount; i++ {
	printEdges(alist[i])
}

@ 프로그램 {\mc DANCE}는 정확 덮개 문제를 풀려고 만든 것이다. 이분 매칭은 그 가운데
특히 쉬운 경우다. 덮어야 할 열은 모두 주 열이고, 행마다 주 열이 꼭 두 개씩 있다.

정확 덮개 행렬의 열 하나는 \&{column} 구조체 하나로 나타내고, 행 하나는 \&{node}
구조체들의 연결 리스트로 나타낸다. 행렬의 $0$ 아닌 성분마다 노드가 하나씩 있다.

더 자세히 말하면 노드들은 행 안에서 양방향으로 빙 둘러 이어진다. 열 안에서도 빙 둘러
이어진다. 열의 리스트에는 머리 노드가 있고 행의 리스트에는 없다. 열의 머리 노드는
\&{column} 구조체의 일부이고, 그 구조체에는 열에 관한 정보가 더 들어 있다.

노드에는 필드가 여섯 있다. 넷은 앞에서 말한 양방향 리스트의 포인터이고, 다섯째는
노드가 들어 있는 열을 가리키고, 여섯째는 이 노드를 지금 풀고 있는 자르기 문제에
잇는다.

@s node int
@s column int

@<자료형@>=
type node struct {
	left, right *node   // 행에서 앞과 뒤
	up, down    *node   // 열에서 앞과 뒤
	col         *column // 이 노드가 든 열
	info        int     // 이 변의 정사각형 자리, 모양 자리, 색
}

@ \&{column} 구조체에는 필드가 다섯 있다. 필드 |head|는 노드 리스트의 머리에 서는
노드다. 필드 |len|은 머리를 빼고 그 리스트에 든 노드의 수다. 필드 |name|은 사용자가
정한 이름이다. 필드 |next|와 |prev|는 이 열이 양방향 리스트에 들어 있을 때 이웃한
열들을 가리킨다.

되짚어 찾기가 나아가는 동안, 노드의 행이 부분해의 다른 행들에 가로막히면 그 노드는 열
리스트에서 빠진다. 하지만 되짚어 찾기가 끝나면 자료 구조는 원래 상태로 돌아가 있다.

필드 이름 |len|은 \GO/의 내장 함수와 이름이 같다. 필드 이름은 |c.len|처럼 늘 무엇의
필드로만 쓰이니 부딪히지 않는다.

@<자료형@>=
type column struct {
	head       node    // 리스트의 머리
	len        int     // 이 열의 리스트에 지금 든, 머리 아닌 노드의 수
	name       string  // 찍을 때 쓰는 열의 이름
	prev, next *column // 이 열의 이웃들
}

@ 열 구조체 하나를 뿌리 |root|라고 부른다. 뿌리는 덮어야 할 열들의 리스트의 머리이고,
이름이 비어 있다는 것으로 알아볼 수 있다.

원본은 뿌리를 |col_array[0]|의 다른 이름으로 두었다. 이 판에서는 그것을 가리키는
포인터다.

@<전역 변수@>=
var root = &colArray[0] // 덮이지 않은 열들로 들어가는 문

@ 춤에만 쓰는 지역 변수들이다. 원본은 여기서 |j|와 |k|를 새로 선언하고 |x|도
선언하지만, 이 판은 |main|의 |j|와 |k|를 그대로 쓴다. 춤이 끝나면 그 값은 어디서도
쓰이지 않는다. 쓰이지 않는 |x|는 \GO/가 허락하지 않으므로 뺐다.

@<춤에 쓰는 지역 변수@>=
var (
	curCol  *column
	curNode *node
	level   int
	bestCol *column // 가지를 칠 열
	minlen  int
)

@ 열은 남은 칸마다 하나, 곧 정사각형 쪽과 모양 쪽에 |acount|개씩 있다. 노드는 변마다
둘이다. 남은 정사각형의 칸 하나에는 변이 많아야 $d$개이니 노드는 모두
$2n^2d$개를 넘지 못한다.

원본은 노드 배열을 $32^4\cdot7$칸으로 잡는다. 노드 하나가 $48$바이트이니 350메가바이트다.
\CEE/에서는 건드리지 않은 쪽이 메모리를 차지하지 않으니 해가 없지만, 쓸데없이 크다.
이 판은 앞의 한계만큼 잡는다.

@<상수@>=
const (
	maxCols  = 2 * maxn * maxn        // 열의 수의 한계
	maxNodes = 2 * maxn * maxn * maxd // 노드의 수의 한계
)

@ @<전역 변수@>=
var (
	colArray   [maxCols + 1]column // 열이 사는 곳
	nodeArray  [maxNodes]node      // 노드가 사는 곳
	acol, bcol [maxn * maxn]*column
	choice     [maxn * maxn]*node // 수준마다 고른 행과 열
)

@ 춤을 준비한다. 남은 칸마다 열을 하나씩 두고 뿌리에 이은 다음, 변마다 노드 두 개로
된 행을 하나씩 만든다.

원본은 포인터를 하나씩 늘려 가며 배열을 훑는다. \GO/에는 포인터 산술이 없으니 첨자로
훑는다.

@<춤을 준비한다@>=
for i = 0; i < acount; i++ {
	ll, l = alist[i], blist[i]
	acol[ll] = &colArray[i+i+1]; colArray[i+i+1].name = aname[ll]
	bcol[l] = &colArray[i+i+2]; colArray[i+i+2].name = bname[l]
}
root.prev = &colArray[acount+acount]
root.prev.next = root
for k = 1; k <= acount+acount; k++ {
	curCol = &colArray[k]
	curCol.head.up = &curCol.head; curCol.head.down = &curCol.head
	curCol.len = 0
	curCol.prev = &colArray[k-1]; colArray[k-1].next = curCol
}
for j, i = 0, 0; i < acount; i++ {
	ll = alist[i]
	for k = 0; k < alen[ll]; k++ {
		@<|ll|의 |k|번째 변의 노드를 만든다@>
	}
}

@ 변 하나의 두 노드는 서로를 왼쪽과 오른쪽 이웃으로 삼는다. 두 노드를 저마다 제 열의
맨 아래에 붙인다. 필드 |info|에는 색을 $24$비트 위에, 모양의 자리를 $12$비트 위에,
정사각형의 자리를 맨 아래에 담는다. 자리는 |place(31,31)|${}=1023$을 넘지 않으니
$12$비트면 된다. 여기서 |j|는 다음에 쓸 노드의 첨자다.

@<|ll|의 |k|번째 변의 노드를 만든다@>=
l = aa[ll][k] & 0xffff
x, y := &nodeArray[j], &nodeArray[j+1]
x.left, x.right, x.col = y, y, acol[ll]
y.left, y.right, y.col = x, x, bcol[l]
x.info = aa[ll][k]>>16<<24 + l<<12 + ll; y.info = x.info
for _, p := range [2]*node{x, y} {
	p.up = p.col.head.up; p.col.head.up.down = p
	p.col.head.up = p; p.down = &p.col.head
	p.col.len++
}
j += 2

@ 모든 정확 덮개를 만들어 내는 전략은 이렇다. 덮어야 할 열들 가운데 덮기가 가장
어려워 보이는 열, 곧 리스트가 가장 짧은 열을 늘 고른다. 그리고 깊이 우선 탐색으로
모든 가능성을 훑는다.

이 알고리즘의 멋진 데는 리스트를 관리하는 방식이다. 깊이 우선 탐색은 자료 구조를
나중에 넣은 것부터 먼저 꺼내는 식으로 관리한다는 뜻이다. 그러면 되돌아갈 때 리스트에서
뺀 원소를 도로 넣는 데 보조 표가 하나도 필요 없다. 우리는 쓰레기 수집을 하지 않으니,
양방향 리스트에서 빠진 노드는 예전 이웃을 기억하고 있다.

기본 연산은 ``열 덮기''다. 열을 덮어야 할 열의 리스트에서 빼고, 그 열의 행들을
``가로막는'' 것이다. 곧 이 열의 리스트에 든 노드의 행에 속한 노드들을 다른
리스트에서 뺀다.

@<춤춘다@>=
level = 0
forward:
	@<|bestCol|을 가지 칠 가장 좋은 열로 정한다@>
	cover(bestCol)
	curNode = bestCol.head.down; choice[level] = curNode
advance:
	if curNode == &bestCol.head {
		goto backup
	}
	if vbose > 1 {
		fmt.Fprintf(os.Stderr, "L%d: %s %s\n",
			level, curNode.col.name, curNode.right.col.name)
	}
	@<|curNode|의 다른 열을 모두 덮는다@>
	if root.next == root {
		@<해를 적고 |recover|로 간다@>
	}
	level++
	goto forward
backup:
	uncover(bestCol)
	if level == 0 {
		goto done
	}
	level--
	curNode = choice[level]; bestCol = curNode.col
recover:
	@<|curNode|의 다른 열을 모두 되살린다@>
	curNode = curNode.down; choice[level] = curNode
	goto advance

@ 행이 가로막히면 그 행은 덮고 있는 열의 리스트만 빼고 모든 리스트에서 빠진다. 그러니
노드가 리스트에서 두 번 빠지는 일은 없다.

원본의 |cover|에는 갱신 횟수를 세는 지역 변수 |k|가 있지만 그 값은 어디에도 쓰이지
않는다. 이 판에서는 뺐다.

@<함수들@>=
func cover(c *column) {
	l, r := c.prev, c.next
	l.next, r.prev = r, l
	for rr := c.head.down; rr != &c.head; rr = rr.down {
		for nn := rr.right; nn != rr; nn = nn.right {
			uu, dd := nn.up, nn.down
			uu.down, dd.up = dd, uu
			nn.col.len--
		}
	}
}

@ 되살리기는 정확히 거꾸로 한다. 그러면 포인터들이 절묘하게 짜인 춤을 추며 거의
마법처럼 예전 상태로 돌아간다.

@<함수들@>=
func uncover(c *column) {
	for rr := c.head.up; rr != &c.head; rr = rr.up {
		for nn := rr.left; nn != rr; nn = nn.left {
			uu, dd := nn.up, nn.down
			uu.down, dd.up = nn, nn
			nn.col.len++
		}
	}
	l, r := c.prev, c.next
	l.next, r.prev = c, c
}

@ @<|curNode|의 다른 열을 모두 덮는다@>=
cover(curNode.right.col)

@ 행을 양방향으로 잇느라 |left| 링크까지 둔 것은, 여기서 열들을 올바른 순서,
곧 덮은 것의 거꾸로 되살리기 위해서다. (함수 |uncover| 자체는 |right| 링크만
있어도 제 일을 할 수 있었다.) (곰곰이 생각해 보라.)

(그러니 이분 매칭이라는 특별한 경우에는 이 구현이 지나치다.)

@<|curNode|의 다른 열을 모두 되살린다@>=
uncover(curNode.left.col)

@ 가지 칠 열은 리스트가 가장 짧은 것이다. 처음 값 |maxNodes|는 어떤 열의 길이보다도
크기만 하면 된다.

@<|bestCol|을 가지 칠...@>=
minlen = maxNodes
if vbose > 2 {
	fmt.Fprintf(os.Stderr, "Level %d:", level)
}
for curCol = root.next; curCol != root; curCol = curCol.next {
	if vbose > 2 {
		fmt.Fprintf(os.Stderr, " %s(%d)", curCol.name, curCol.len)
	}
	if curCol.len < minlen {
		bestCol, minlen = curCol, curCol.len
	}
}
if vbose > 2 {
	fmt.Fprintf(os.Stderr, " branching on %s(%d)\n", bestCol.name, minlen)
}

@ 덮어야 할 열이 다 덮이면 완전 매칭 하나를 얻은 것이다. 수준마다 고른 행의 |info|를
풀어 두 칸에 색을 칠하고 해를 찍는다.

@<해를 적고 |recover|로 간다@>=
if vbose > 1 {
	fmt.Fprintf(os.Stderr, "(a good dance)\n")
}
for k = 0; k <= level; k++ {
	j = choice[k].info
	acolor[j&0xfff] = j >> 24; bcolor[(j>>12)&0xfff] = j >> 24
}
@<해를 찍는다@>
goto recover

@* 해를 찍는다.
해는 표준 출력으로 찍는다. 먼저 해의 번호와 그 해를 낳은 옮기는 방법의 열
$s_1^{t_1}$, \dots, $s_d^{t_d}$를 적고, 그 아래에 정사각형과 모양의 색칠을 나란히
보인다.

변수 |OK|는 크누스가 남겨 둔 것이다. 이 선언이 있으면 변경 파일에서 해를 거르기가
쉬워진다. 이를테면 조각마다 칸이 이어져 있기를 바란다면, |OK|를 거짓으로 만드는
검사만 끼워 넣으면 된다.

@<해를 찍는다@>=
{
	OK := true // 이 선언은 변경 파일을 쉽게 쓰게 한다
	if OK {
		count++
		fmt.Fprintf(out, "Solution %d, from", count)
		for k = 1; k <= d; k++ {
			fmt.Fprintf(out, " %d^%d", s[k], t[k])
		}
		fmt.Fprintf(out, ":\n")
		@<정사각형과 모양의 색칠을 나란히 찍는다@>
		out.Flush()
	}
}

@ 모양이 정사각형보다 낮을 수도 높을 수도 있으니 둘 가운데 긴 쪽까지 찍는다. 모양의
빈칸은 마침표로 보인다.

@<정사각형과 모양의 색칠을...@>=
for i = 0; i < n || i <= maxrow; i++ {
	for j = 0; j < n; j++ {
		if i < n {
			out.WriteByte(byte('0' + acolor[place(i, j)]))
		} else {
			out.WriteByte(' ')
		}
	}
	if i <= maxrow {
		out.WriteString("  ")
		for j = 0; j <= maxcol; j++ {
			if bname[place(i, j)] != "" {
				out.WriteByte(byte('0' + bcolor[place(i, j)]))
			} else {
				out.WriteByte('.')
			}
		}
	}
	out.WriteByte('\n')
}

@ 해는 버퍼 |out|에 모았다가 하나를 다 찍을 때마다 비운다. 원본의 \CEE/ 표준
입출력은 출력이 터미널로 가면 줄마다 비우고 파일로 가면 모아 둔다. 그래서
수다스럽게 돌리면 터미널에서 해와 표준 오류의 말이 차례대로 섞여 보인다. \GO/의
|os.Stdout|에는 버퍼가 없어 글자 하나를 찍을 때마다 시스템 호출을 한 번씩 하고, 버퍼를 끝에만
비우면 섞여 보이는 순서가 흐트러진다. 해마다 비우면 그 둘 사이의 알맞은 자리다.

@<전역 변수@>=
var out = bufio.NewWriter(os.Stdout) // 해를 찍을 버퍼

@ 끝으로 셈한 것을 알린다. 해의 수, 쓸 수 있는 옮김의 수, 그리고 요긴한 자리에 닿은
다섯 횟수다.

@<실행 통계를 알린다@>=
out.Flush()
fmt.Fprintf(os.Stderr, "%d solutions; run stats %d,%d,%d,%d,%d,%d.\n",
	count, m, counta, countb, countc, countd, counte)

@* 해 보기.
옮긴 김에 이름난 자르기 둘을 먹여 보았다. 첫째는 계단 자르기다. 크기가 $4\times9$인 직사각형을
두 조각으로 잘라 $6\times6$ 정사각형을 만든다. 프로그램은 해를 꼭 둘 찾는데, 서로의
거울상이다. 조각을 뒤집을 수 없으니 둘 다 따로 나온다. 통계는
\.{2 solutions; run stats 126,90,4,2,2,0}이다. 옮김의 쌍 $8001$개 가운데 모양을 덮는
것이 $90$개였고, 거기에 회전까지 붙여 정사각형도 덮는 것이 $4$가지였고, 춤까지 가야 한 문제는 하나도 없었다.
강제된 수만으로 풀린 것이다.

둘째는 피타고라스의 정리를 칸으로 보이는 것이다. 크기가 $4\times4$인 정사각형과
$3\times3$인 정사각형을 나란히 놓은 모양
$$\vcenter{\halign{\tt#\hfil\cr
****....\cr ****....\cr ****.***\cr ****.***\cr .....***\cr}}$$
을 잘라 $5\times5$ 정사각형을 만들어 보자. 두 조각으로는 해가 없다. 세 조각이면 해가
$21$개 나오는데, 어느 것이나 조각 하나가 둘 이상의 덩어리로 흩어져 있다. 크누스가
조각이 이어져 있기를 요구하지 않는다고 한 것이 이런 뜻이다. 네 조각이면 해가
$130341$개 나오고, 그 가운데 $6852$개는 조각이 모두 한 덩어리다. (한 조각은 돌리고 밀
뿐이니, 정사각형에서 이어져 있으면 모양에서도 이어져 있다.) 뒤집지 않고 이어진 조각으로
자르려면 네 조각이 든다는 것을 이렇게 알 수 있다. 이 셈은 $3$초쯤 걸린다.

그림의 오른쪽은 이어진 네 조각 해 가운데 가장 큰 조각이 가장 작은 것, 곧 $9$칸인
것의 하나다(해 $109780$). 원본은 이어져 있는지를 살피지 않으므로, 이런 해를 고르는
것은 변경 파일이 |OK|를 거짓으로 만드는 검사로 할 일이다. 나는 출력을 걸러서 셌다.

$$\mplibcode
beginfig(2);
  sol("222222222222111222111222111111111111", 6,
      "111222222111222222111111222111111222", 9, 4, (0, 0));
  sol("3331133311333112211122224", 5,
      "2211....2211....2411.3332111.333.....333", 8, 5, (19u, 0));
  label(btex 계단 자르기 etex, (8u, -7u));
  label(btex 피타고라스, 네 조각 etex, (26.4u, -7u));
endfig;
\endmplibcode$$
\figcap{왼쪽은 $6\times6$ 정사각형을 두 조각으로 잘라 $4\times9$ 직사각형을 만드는
계단 자르기이고, 오른쪽은 $5\times5$ 정사각형을 네 조각으로 잘라 $4\times4$와
$3\times3$을 나란히 놓은 모양을 만드는 해의 하나다.}

@* 옮기며 고친 것.
원본에서 결함 둘을 찾았다.

첫째는 칸이 {\it 하나\/}뿐인 모양에서 일어난다. 입력이 \.{*} 하나이면 $n=1$이고, 쓸
수 있는 옮김은 $00$ 하나뿐이라 $m=1$이다. 그러면 모든 $s_k$가 $m-1=0$이고, 원본의
|shapenot| 뒤 반복문은 $k=d$, \dots,~$1$을 지나 $k=0$에 이른다. 그런데 $s_0$도 $0$이라
반복문은 멈추지 않고 $s_{-1}$을 읽는다. 배열 밖이다. 원본을 \.{-fsanitize=undefined}로
컴파일하면 ``\.{index -1 out of bounds for type 'int[8]'}''이라고 알린다. 그 뒤는
운에 달렸다. 내 기계에서는 $d=2$이면 버스 오류로 죽고(종료 부호 $138$), $d=7$이면
해를 $5000$개 남짓 찍다가 세그멘테이션 오류로 죽는다. 표준 출력의 버퍼에 남은 것은
날아간다.

이 판은 반복문에 $k>0$이라는 조건을 달았다. 그러면 $k=0$에서 멈추고 바깥 반복문이
끝난다. 옮김이 둘 이상이면 $s_0=0\ne m-1$이라 원래도 $k=0$에서 멈추었으니, 다른
입력의 결과는 한 글자도 달라지지 않는다. 고친 판은 \.{*}를 $d=2$로 풀어 해 $6$개를
찍는다. 칸 하나를 색~\.1이나 \.2로 칠하는 두 가지가, $1\times1$ 정사각형을 돌리는
세 가지 $t_2=1$, $2$, $3$마다 한 번씩 나온다. 시시하지만 틀리지는 않다.

@ 둘째는 입력의 긴 줄이다. 원본은 크기 $37$바이트의 버퍼에 |fgets|로 한 줄을 읽는다.
그러면 한 번에 $36$글자까지만 읽히고, 그보다 긴 줄은 다음 번 |fgets|가 이어 읽는다.
그 나머지가 {\it 다음 줄\/}로 세어진다. 별표는 $32$째 칸까지만 쓸 수 있으니 긴 줄은
오른쪽이 마침표로 채워진 줄일 텐데, 그런 줄을 쓸 일은 얼마든지 있다.

그러면 두 가지 일이 생긴다. 글자가 꼭 $36$개인 줄은 줄바꿈 글자만 다음 토막으로
남기므로 빈 줄 하나가 몰래 끼어든다. 이를테면 \.{**} 뒤에 마침표 $34$개를 붙인 줄과
\.{**}라는 줄을 먹이면, 원본은 ``$3$줄''이라고 하고 두 줄 사이에 빈 줄이 낀 모양을
풀어 해 $4$개를 낸다. 이 판은 $2\times2$ 정사각형으로 읽어 \.{**}/\.{**}와 똑같은
해 $58$개를 낸다. 또 $37$째 칸 이후에 있는 별표는 다음 줄의 앞쪽으로 소리 없이
옮겨 간다. 이를테면 \.{**} 뒤에 마침표 $35$개와 별표 하나를 붙인 줄은, 원본에서는
두 줄로 쪼개져 마지막 별표가 둘째 줄의 둘째 칸에 놓인다. 원본은 그 엉뚱한 모양을 멀쩡히
푼다. 이 판은 줄을 통째로 읽으므로 그 별표가 $38$째 칸에 있다고 보고 ``\.{Recompile me: I
allow at most 32 columns of input!}''라며 멈춘다.

@ 고치지 않은 것도 적어 둔다. 앞에서 말했듯 코드는 $(s_k,t_k)$의 사전식 순서를 다
강제하지 않아서 색 이름만 다른 해를 두 번 찍을 때가 있다. 출력이 원본과 같도록 이
판도 그렇게 두었다. 해를 셀 때는 이것을 헤아려야 한다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀어 컴파일해 이 판과 견주었다. 원본은 옛 \CEE/의 암묵적 |int|를
쓰므로 요즘 컴파일러에서는 \.{-std=gnu89}를 주어야 한다. 표준 출력, 표준 오류, 종료
부호가 모두 바이트까지 같은지를 보았다. 사용법을 알리는 말에 든 프로그램 이름만은
빼고 견주었다.

\smallskip
\item{$\bullet$} 무작위 모양 $700$개. 칸의 수는 $4$에서 $25$까지의 완전제곱수이고(가끔
하나 모자라게 해서 거절되는 길도 보았다), 반은 한 덩어리로 자라게 하고 반은 칸을
아무렇게나 흩었다. 줄 끝의 마침표를 떼거나, 마지막 줄바꿈을 빼거나, 빈 줄을 덧붙이기도
했다. 조각은 $2$에서 $4$개, 수다는 $0$에서 $3$단계다. 원본이 $20$초 안에 끝내지 못한
$3$개를 빼고 $697$개가 같다. 해가 하나라도 나온 것이 $348$개, 춤까지 가야 한 것이 $298$개이고,
찍힌 해는 모두 $1360$만 개 남짓이다. $75$개는 입력이 거절되는 길로 끝났다.
\item{$\bullet$} 명령줄과 입력의 가장자리 $32$가지. 인자가 없거나 수가 아니거나 범위
밖일 때, \.{3x}처럼 수 뒤에 찌꺼기가 붙거나 앞에 빈칸이 붙을 때, 입력이 비었거나 빈 줄뿐일 때, 칸의
수가 제곱수가 아닐 때, 줄이 $33$개일 때, 별표가 $33$째 칸에 있을 때와 $32$째 칸에
있을 때, 수다를 $4$단계까지 올렸을 때다.
\item{$\bullet$} 칸 하나짜리 모양과 긴 줄의 $9$가지는 원본이 틀리게 굴므로, 원본에 앞의
두 결함만 고친 판과 견주어 같았다.
\item{$\bullet$} 앞 장의 예제들도 같다. 피타고라스 모양을 네 조각으로 푼 $16$메가바이트에
조금 못 미치는 출력도 바이트까지 같다.
\smallskip

\noindent 속도는 원본에 조금 못 미친다. 피타고라스 모양을 네 조각으로 풀 때 원본은
$2.0$초, 이 판은 $2.7$초가 걸린다. 경계 검사를 끄고 컴파일하면(\.{-gcflags=-B})
$2.3$초이니 차이의 절반쯤은 배열 경계 검사이고, 해마다 버퍼를 비우는 값은
$0.1$초가 안 된다.

@* 색인.
