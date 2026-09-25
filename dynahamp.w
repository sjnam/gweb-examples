\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\adj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-8mu\mathrel-\!}}
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

\def\title{동적 해밀턴 경로}

@* 들어가며.
마디가 $\{1,2,\ldots,n\}$인 그래프 $G$가 주어졌다고 하자. 이 프로그램은 동적 계획법을
조금 바꾼 방법으로, 유도 부분그래프 $G\mid\{1,2,\ldots,m\}$의 해밀턴 경로를
$m=1$, $2$, \dots,~$n$마다 모두 센다. 특히 $m=n$이면 $G$의 해밀턴 경로를 {\it 모두\/}
세는 셈이다. 이를테면 $G$가 $8\times20$ 판의 나이트 그래프이고 마디 번호를 열 순서로
매겼다면, $m=24$, $32$, \dots,~$160$일 때 $8\times3$, $8\times4$, \dots, $8\times20$
판의 열린 나이트 투어를 모두 세어 준다.

크누스는 해밀턴 {\it 회로\/}를 세는 {\mc DYNAHAM}을 서둘러 고쳐 이것을 지었다고
적었다. 그러니 이것을 파고들기 전에 그 프로그램부터 읽고 이해하는 것이 좋다. 이
저장소에는 \.{dynaham.w}로 옮겨 두었다. 가장 큰 차이는 이 프로그램이 늘린 그래프
$G^+=G\adj K_1$로 일한다는 것이다. $G^+$는 $G$에 새 마디 `$n+1$'을 하나 보탠 것이고,
새 마디는 옛 마디 모두와 이웃한다. 그러면 $G$의 해밀턴 경로는 $G^+$의 해밀턴 회로와
하나씩 뻔하게 맞선다. 경로의 두 끝을 새 마디에 이으면 회로가 되기 때문이다. 더 나아가
$G\mid\{1,2,\ldots,m\}$의 해밀턴 경로는 $G^+\mid\{1,2,\ldots,m,n+1\}$의 해밀턴 회로와
하나씩 맞선다.

@ 그다음은 \.{dynaham.w}와 같다. 그래프 $G^+$의 변을 모은 집합이 다음 세 조건을 채우면
``$m$-짜임''이라 부른다. (i)~$m$ 이하인 마디는 저마다 꼭 두 변에 나온다. (ii)~두 끝이
다 $m$보다 큰 변은 없다. (iii)~변들이 고리를 이루지 않는다. 경계 $F_m$은 $m$보다
크면서 $\{1,\ldots,m\}$에서 닿을 수 있는 마디들의 집합이고, 그 마디들은 짜임 안의
차수에 따라 ``바깥'', ``안쪽'', ``맨몸''으로 나뉜다. 바깥, 안쪽, 맨몸 칸이 같고 바깥
칸끼리 짝짓는 방식도 같은 두 짜임은 동치다.

이 프로그램은 $m=1$, $2$, \dots에 대해 동치류마다 $m$-짜임이 몇 개인지를 세고, 그
곁다리 셈들로 본래 할 일, 곧 $\{1,\ldots,m,n+1\}$ 위의 $(m+1)$-회로를 세는 일을
해낸다. 동치류는 경계의 마디마다 부호를 붙인 수열로 나타낸다. 맨몸은 $0$, $j$번째
부분경로의 바깥 칸은 $j$, 안쪽은 $-1$이다.

@ 예를 들어 $G$가 $4\times3$ 판의 나이트 그래프라 하자. 마디 이름을 1부터 13까지
대신 칸 이름 00, 10, 20, 30, 01, 11, \dots, 22, 32로 부르고, 새 마디는 `!'라 하자.
처음 두 마디 $\{00,10\}$에 닿지 않는 변을 모두 빼면 $G^+$에는 변이 일곱 남는다.
$\{00\adj12,\ 00\adj21,\ 00\adj{!},\ 10\adj02,\ 10\adj22,\ 10\adj31,\ 10\adj{!}\}$이다.
여기서 $2$-짜임이 열여덟 개 나온다.

\smallskip
\item{$\bullet$} $00\adj{!}\adj10$을 품는 것이 여섯. 00은 12나 21과, 10은 세 이웃 가운데
하나와 이어진다.
\item{$\bullet$} ${!}\adj00$을 품고 00이 12나 21과 이어지며, 10이 세 이웃 가운데 둘과
이어지는 것이 여섯.
\item{$\bullet$} ${!}\adj10$과 $12\adj00\adj21$을 품고 10이 이웃 하나와 이어지는 것이
셋.
\item{$\bullet$} $12\adj00\adj21$을 품고 10이 이웃 둘과 이어지는 것이 셋.
\smallskip

\noindent 이를테면 $12\adj00\adj{!}\adj10\adj02$로 된 $2$-짜임에서 경계의 마디
({!},\ 21, 31, 02, 12, 22)의 부호는 차례로 ($-1$, 0, 0, 1, 1, 0)이다. 그리고
$12\adj00\adj{!}$과 $02\adj10\adj31$로 된 $2$-짜임의 부호는 차례로 (1, 0, 2, 2, 1,
0)이다. (원본에는 뒤의 변이 \.{\$02\\adj10\\31\$}로 적혀 \.{\\adj} 하나가 빠져 있다.)

$$\mplibcode
beginfig(1);
  u := 16mm;
  def boxed(expr pic) = unfill bbox pic; draw pic; enddef;
  for x = 0 upto 3: for y = 0 upto 2:
    z[10x+y] = (x*u, y*u);
    draw unitsquare scaled u shifted (z[10x+y] - (.5u, .5u))
      withpen pencircle scaled .3pt withcolor .6white;
  endfor endfor
  for x = 0 upto 1:
    fill unitsquare scaled u shifted (z[10x] - (.5u, .5u)) withcolor .9white;
    draw unitsquare scaled u shifted (z[10x] - (.5u, .5u))
      withpen pencircle scaled .3pt withcolor .6white;
  endfor
  z99 = (.5u, -1.2u);
  draw z12 -- z0 -- z99 -- z10 -- z2 withpen pencircle scaled 1.2pt;
  for x = 0 upto 3: for y = 0 upto 2:
    fill fullcircle scaled 3pt shifted z[10x+y];
  endfor endfor
  fill fullcircle scaled 4pt shifted z99;
  boxed(thelabel.llft(btex \sevenrm 00 etex, z0 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 10 etex, z10 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 20 etex, z20 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 30 etex, z30 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 01 etex, z1 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 11 etex, z11 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 21 etex, z21 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 31 etex, z31 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 02 etex, z2 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 12 etex, z12 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 22 etex, z22 + (.48u, .48u)));
  boxed(thelabel.llft(btex \sevenrm 32 etex, z32 + (.48u, .48u)));
  boxed(thelabel.urt(btex $0$ etex, z21 - (.46u, .46u)));
  boxed(thelabel.urt(btex $0$ etex, z31 - (.46u, .46u)));
  boxed(thelabel.urt(btex $1$ etex, z2 - (.46u, .46u)));
  boxed(thelabel.urt(btex $1$ etex, z12 - (.46u, .46u)));
  boxed(thelabel.urt(btex $0$ etex, z22 - (.46u, .46u)));
  label.bot(btex $!$ etex, z99);
  label.rt(btex $-1$ etex, z99 + (3pt, 0));
endfig;
\endmplibcode$$
\figcap{$4\times3$ 판에서 본 $2$-짜임 $12\adj00\adj{!}\adj10\adj02$. 칸의 오른쪽 위는 칸
이름, 왼쪽 아래는 경계 칸의 부호다. 회색 칸 둘이 처음 두 마디이고, 판 아래의 점이
새 마디 `!'다. 새 마디는 모든 칸과 이웃하지만 여기서는 고른 변만 그렸다.}

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{dynahamp.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/dynahamp.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Sat, 29 Aug 2026 04:05:24 GMT}다. 이름 끝의 p는 path, 곧 경로다.

원본은 \.{dynaham.w}의 원본과 거의 한 줄 한 줄 같다. 새 마디 $n+1$을 늘 경계의 맨
앞 |fr[0]|에 두느라 경계와 짝 표의 색인이 하나씩 밀렸을 뿐이다. 그래서 이 판도
\.{dynaham.w}의 글과 코드를 가져다 쓰고, 다른 곳만 고쳤다. 트라이의 설명처럼 두
프로그램에 똑같은 긴 이야기는 짧게 줄였으니 \.{dynaham.w}를 함께 보면 좋다.

원본에서 달라진 것이 몇 가지 더 있다. 트라이 포인터가 서른두 비트 \.{memtyp}에서
예순네 비트로 넓어졌고, 부호의 상한 |deg|가 $9$에서 $10$으로 늘었다. 마지막 보고의
꼴도 조금 다르다.

@ 그래프는 \.{SGB} 형식의 파일로 읽어 들인다. 그 일은 \pdfURL{go-sgb}%
{https://github.com/sjnam/go-sgb}의 |gbsave.RestoreGraph|가 해 준다. 프로그램이 찍는
말과 종료 부호는 원본 그대로 두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄
수 있다.

\.{dynaham.w}에서 고친 결함 넷이 이 원본에도 그대로 있다. 겹친 변과 제 고리가 있는
그래프에서 틀린 수를 내는 것, 압축한 트라이의 넘침을 제때 알아채지 못하는 것, 마디
없는 그래프에서 죽는 것이다. 여기서도 똑같이 고쳤다.

@ 뼈대는 이렇다. $m=1$, $2$, \dots마다 옛 트라이에 든 $(m-1)$-동치류를 하나씩 꺼내
그 뒤들을 새 트라이의 $m$-동치류에 보탠다.

@c
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"slices"
	@#
	"github.com/sjnam/go-sgb/gbgraph"
	"github.com/sjnam/go-sgb/gbsave"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	var j, k, t, x, ik, iv int
	@<명령줄을 처리한다@>@;
	@<초기화한다@>@;
	for m = 1; ; m++ {
		@<앞선 경계를 찍는다@>@;
		if wtptr == 0 {
			@<마지막 보고를 하고 끝낸다@>@;
		}
		@<$m$-동치류의 트라이를 $(m-1)$-동치류의 옛 트라이로 간수한다@>@;
		@<$m$-동치류를 받을 새 트라이를 연다@>@;
		@<옛 동치류마다 그 뒤를 새 트라이에 보탠다@>@;
		reportPaths(m)
	}
}

@ @<상수@>=
const (
	precision    = 100      // 십진 자릿수를 이만큼까지 다룬다
	progressMask = 0x1fffff // $2^{21}$ 걸음마다 진행을 알린다
	maxn         = 300      // 입력 그래프의 마디는 |maxn|개보다 적어야 한다
)

@ @<전역 변수@>=
var (
	m int            // 지금 다루는 짜임의 $m$
	n int            // 그래프 |g|의 마디 수
	g *gbgraph.Graph // 주어진 그래프
)

@ 원본은 표준 오류로 말을 아주 많이 한다. \CEE/의 표준 오류는 버퍼가 없지만, \GO/에서
글줄마다 시스템 호출을 하면 느리니 버퍼에 모은다. 원본이 |fflush(stderr)|를 하는
자리와 표준 출력에 쓰기 직전, 그리고 끝날 때마다 비운다. 그러면 두 흐름이 한
터미널에 섞여 나올 때의 차례도 원본과 같다.

@<전역 변수@>=
var errw = bufio.NewWriter(os.Stderr) // 표준 오류의 버퍼

@ 끝낼 때는 늘 버퍼를 비우고 끝낸다.

@<함수들@>=
func quit(code int) {
	errw.Flush()
	os.Exit(code)
}

@ 명령줄에는 그래프 파일 이름 하나만 온다.

원본은 마디 없는 그래프를 받으면 죽는다. 처음 경계 $\widehat F_0=\{1\}$을 찍으려고
|fr[0]|을 읽는데, 마디가 없으니 거기 든 $0$을 마디 번호로 알고 마디 배열 바로 앞을
짚기 때문이다. \.{AddressSanitizer}는 이것을 힙 넘침으로 잡는다. 이 판은 마디가 너무
많을 때처럼 거절한다. 말은 \.{ssbidiham.w}에서 지은 것을 그대로 쓰고, 종료 부호는
마디가 너무 많을 때와 같은 $-3$을 쓴다. (이 원본에서는 늘린 경계
$\widehat F_0=\{1,n+1\}$의 둘째 칸 |fr[1]|이 $0$으로 남아 같은 일이 생긴다.)

새 마디 $n+1$에는 이름 `\.!'를 붙인다. \.{SGB}의 그래프는 마디 배열 끝에 여분의
칸을 마련해 두는데, go-sgb도 그렇다. 원본은 그 칸 |g->vertices+n|에 이름을 적고,
여기서도 |g.Vertices[n]|에 적는다. 새 마디에는 변이 없다. 새 마디와의 이웃 관계는
프로그램이 따로 다룬다.

@<명령줄을 처리한다@>=
if len(os.Args) != 2 {
	fmt.Fprintf(errw, "Usage: %s foo.gb\n", os.Args[0])
	quit(-1)
}
var err error
if g, err = gbsave.RestoreGraph(os.Args[1]); err != nil {
	fmt.Fprintf(errw, "I couldn't reconstruct graph %s!\n", os.Args[1])
	quit(-2)
}
n = int(g.N)
if n >= maxn {
	fmt.Fprintf(errw, "Recompile me: I allow at most %d vertices!\n", maxn-1)
	quit(-3)
}
if n == 0 {
	fmt.Fprintf(errw, "Sorry, graph %s has no vertices!\n", os.Args[1])
	quit(-3)
}
g.Vertices[n].Name = "!" // 새 마디에 이름을 붙인다
fmt.Printf("Dynamic Hamiltonian paths of the graph %s", g.ID)
fmt.Printf(" (%d vertices, %d edges):\n", n, g.M/2)

@* 낮은 수준의 셈.
크누스는 기본 연장을 모두 손수 지었다. 쉬운 것들이고 최적화할 필요도 없기
때문이다.

먼저 자릿수가 많은 수를 더하고 찍는 함수가 있어야 한다. 기수는 $10^{18}$이다.
$2^{63}$이 $9\cdot10^{18}$보다 크니 한 낱말에 들어가고 더해도 넘치지 않는다.

@<상수@>=
const (
	radix   = 1000000000000000000     // 기수 $10^{18}$
	maxprec = (precision + 17) / 18   // 큰 수 하나에 이만큼의 여덟 바이트 낱말
)

@ @<자료형@>=
type bignum struct {
	val [maxprec]int64 // 기수 $10^{18}$의 자리들, 낮은 자리부터
}

@ @<전역 변수@>=
var (
	zero  bignum // 상수 $0$
	one   bignum // 상수 $1$
	infty bignum // 가장 큰 큰 수
	prec  int    // 지금까지 필요했던 가장 큰 자릿수
)

@ @<초기화한다@>=
one.val[0] = 1
for k = 0; k < maxprec; k++ {
	infty.val[k] = radix - 1
}
prec = 1

@ 자릿수 |prec|은 모든 큰 수가 함께 쓴다. 어느 수가 한 자리 넘치면 |prec|을
늘리는데, 다른 수들의 윗자리는 늘 $0$이니 탈이 없다. 원본은 두 번째 수를 값으로
넘기지만 여기서는 포인터로 넘긴다. 두 인자가 같은 수를 가리키는 일은 없다.

@<함수들@>=
func addToBignum(x *bignum, delta *bignum) {
	c := int64(0)
	k := 0
	for ; k < prec; k++ {
		s := x.val[k] + delta.val[k] + c
		if s >= radix {
			c, x.val[k] = 1, s-radix
		} else {
			c, x.val[k] = 0, s
		}
	}
	if c != 0 {
		if prec == maxprec {
			@<큰 수가 넘쳤으니 그만둔다@>@;
		}
		prec++
		x.val[k] = c
	}
}

@ @<함수들@>=
func bignumComp(x, y *bignum) int {
	r := 0
	for k := 0; k < prec; k++ {
		if x.val[k] != y.val[k] {
			if x.val[k] < y.val[k] {
				r = -1
			} else {
				r = +1
			}
		}
	}
	return r
}

@ @<함수들@>=
func printBignum(w io.Writer, x *bignum) {
	k := prec - 1
	for k >= 0 && x.val[k] == 0 {
		k--
	}
	if k < 0 {
		fmt.Fprint(w, "0")
		return
	}
	fmt.Fprintf(w, "%d", x.val[k])
	for k > 0 {
		k--
		fmt.Fprintf(w, "%018d", x.val[k])
	}
}

@ @<큰 수가 넘쳤으니...@>=
fmt.Fprintf(errw, "\nSorry, I can't handle numbers bigger than 10^%d!\n", 18*maxprec)
fmt.Fprintf(errw, "I had found %d classes of %d-configs so far.\n", wtptr, m)
quit(-999)

@* 트라이 구조.
중심 자료구조는 커다란 사전 하나로, 동치류마다 항목이 하나씩 있다. 이것을 단순한
``트라이''로 짓는다.

트라이는 계산하는 동안 자란다. 마디는 거대한 포인터 배열 |mem|의 구간들에 담고,
잎은 거대한 \&{bignum} 배열 |weight|의 원소에 담는다.

잎 하나는 열쇠 $a_0a_1\ldots a_{q-1}$로 가려낸다. 여기서 $0\le l<q$마다
$-1\le a_l<|deg|$이다. 트라이에는 열쇠의 앞머리 $a_0\ldots a_{l-1}$마다($0\le l<q$)
마디가 하나씩 있다. 수준 $l=0$의 뿌리 마디는 빈 앞머리를 나타낸다.

@ 이 프로그램의 옛 판들은 마디 하나를 포인터 열 개쯤의 배열로 나타냈다. 포인터는
저마다 $0$이거나 자식 마디 또는 잎의 번호였다. 그 착상도 잘 돌았고 많은 실험을
해냈다. 그런데 돌아보니 포인터 대부분이 $0$이었다. 이를테면 열쇠의 마지막 부호만
빼고 다 알면 마지막 부호 $a_{q-1}$이 될 수 있는 것은 많아야 둘이다. 그러니 수준
$q-1$의 마디에서 $0$이 아닌 포인터는 많아야 둘이었다! 이 프로그램에서는 메모리가
귀하다. 그래서 크누스는 더 복잡하지만 훨씬 빽빽한 방식으로 바꾸었다.

우리 트라이의 열쇠에는 특별한 성질이 있다. 앞의 부호 $a_0\ldots a_{l-1}$을 알면
$a_l$이 될 수 있는 값이 크게 줄어든다. 이를테면 $a_0$은 $-1$, $0$, $1$ 가운데
하나일 수밖에 없다. 그리고 앞머리 1021 다음에는 $-1$, $0$, $2$, $3$만 올 수 있다.

@ 부호 $a_l$이 될 수 있는 값들은 성긴 집합으로 다스린다. 한 번 나왔지만 아직 두 번
나오지 않은 양의 부호들을 배열 |tmap|의 앞쪽 |tms|칸에 늘어놓고, 아직 한 번도 나오지
않은 가장 작은 양의 부호를 |tmx|에 둔다. 거꾸로 가는 부분 역함수도 있다. 부호 $c$가
한 번 나왔고 두 번은 아직이면 |c=tmap[itmap[c]]|다.

수준 $l$에서 앞머리 $a_0\ldots a_{l-1}$의 마디는 |mem|의 색인인 포인터
$p=p(a_0\ldots a_{l-1})$로 가려낸다. 부호 $a_l$이 될 수 있는 값이 차례로 $-1$, $0$,
|tmap[0]|, \dots, |tmap[tms-1]|, |tmx|이면, 자식 마디 $p'=p(a_0\ldots a_l)$은 차례로
|mem[p-1]|, |mem[p]|, |mem[p+1]|, \dots, |mem[p+tms]|, |mem[p+tms+1]|에 든다. 그
앞머리 다음에 그 부호 $a_l$이 아직 나오지 않았으면 그 자리는 $0$이다. (|tms|가 $0$일
수도 있다. 또 $-1$과 $0$이 올 수 없는 경우도, |tmx|가 올 수 없는 경우도 있다.)

(크누스는 이렇게 적었다. 이 방식을 이해하고 메모리를 얼마나 아끼는지 보고 나면,
복잡해도 꽤 아름답다고 여기게 될지도 모른다. 가까운 앞날에 AI가 찾아낼 성싶지 않다는
점에서 특히 그렇다!)

열쇠 전체 $a_0\ldots a_{q-1}$에 맞는 잎은 같은 $p$의 정의를 써서
|weight|$[p(a_0\ldots a_{q-1})-1]$에 있다. 동치류 $a_0\ldots a_{q-1}$의 지금 무게를
나타내는 큰 수다.

@ 다 짓고 난 트라이는 훨씬 짧게 압축할 수 있다. 포인터가 $d$개인 잎 아닌 마디를
$d$비트로 줄이고, 그것들을 전위 순서로 잇는다. 잎의 무게도 전위 순서로 늘어선다.
아래 프로그램은 $(m-1)$-동치류의 트라이에서 $m$-동치류의 트라이를 지을 때 긴 형식을
쓰고, 앞의 트라이는 압축형으로 들어 있다. 두 형식의 자세한 예는 \.{dynaham.w}에
옮겨 두었다.

@ 원본은 커다란 배열 넷을 처음에 |malloc|으로 한꺼번에 잡는다. 포인터 |mem|은
$3\times10^9$칸, 무게 배열 둘은 저마다 $10^9$칸이니 가상 메모리로 백 기가바이트를
넘는다. \CEE/에서는 운영체제가 실제로 건드린 쪽만 내주니 괜찮지만, \GO/에서 그만한
조각을 잡는 것은 미덥지 않다. 그래서 이 판은 네 배열을 조각으로 두고 필요한 만큼
늘린다. 크기의 상한 |memsize|, |wtsize|, |oldmemsize|는 원본 그대로 두어 넘침을
알리는 데 쓴다. 그러니 원본의 ``I can't allocate the big tables!''는 이 판에 없다.
메모리가 모자라면 \GO/ 실행기가 알아서 멈춘다.

크누스의 설명으로는 |oldmemsize|가 |memsize/8|보다 조금 커야 한다. 왜 그럴까? 좀
까다로운데, |memsize/8|바이트면 대략 |memsize|비트이고 그만큼이 필요하다. 그런데
|oldmem|은 예순네 비트 낱말로 되어 있고 작은 비트열이 두 낱말에 걸치지 않도록 대개
예순 비트쯤만 채우니 몇 비트씩 버려진다. 어쨌든 |mem| 자체가 대개 |8*memsize|나
|16*memsize|바이트를 차지하니 |oldmem|은 하찮은 편이다.

@<상수@>=
const (
	memsize    = 3000000000 // |mem|의 크기 상한
	wtsize     = 1000000000 // 동치류 수의 상한
	oldmemsize = 450000000  // |oldmem|의 바이트 수 상한 (넉넉하다)
	deg        = 10         // 열쇠의 부호는 이보다 작아야 한다
)

@ 조각을 늘리는 도우미다. 적어도 |n|칸이 되게 늘리고 새 칸은 $0$으로 둔다.

@<함수들@>=
func grow[T any](s []T, n int) []T {
	if n > len(s) {
		s = slices.Grow(s, n-len(s))
		s = s[:cap(s)]
	}
	return s
}

@ @<초기화한다@>=
mem = make([]uint64, 1<<16)
oldmem = make([]uint64, 1<<10)
weight = make([]bignum, 1<<10)
oldweight = make([]bignum, 1<<10)

@ 원본은 트라이 포인터를 |unsigned long long|으로 두고, 색인들은 |long long|으로
둔다. 여기서는 |uint64|와 |int|로 둔다. \GO/의 |int|는 예순네 비트다.

@<전역 변수@>=
var (
	oldp                 int      // 지금 다루는 옛 무게
	contribs             int64    // 옛 동치류들이 보탠 횟수
	mem                  []uint64 // 큰 트라이의 포인터들
	oldmem               []uint64 // 압축한 비트열들
	memptr               int      // |mem|에서 처음으로 안 쓴 칸
	wtptr                int      // |weight|에서 처음으로 안 쓴 칸
	q, oldq              int      // 트라이 열쇠의 길이
	code                 [maxn]int // 새 트라이에서 찾는 열쇠
	oldcode              [maxn]int // 옛 트라이의 지금 열쇠
	weight, oldweight    []bignum  // 두 트라이의 잎
	minweight, maxweight bignum    // 가장 작은 무게와 가장 큰 무게
	count                [maxn + 1]bignum // 지금까지 센 해밀턴 $m$-경로의 수
	maxdeg               int      // 지금까지 본 가장 큰 가지 수
	pack                 uint64   // |oldmem|에 덧붙이려고 모으는 비트
	spack                int      // |pack|에 든 아직 간수하지 않은 비트 수
	owp, omp             int      // 압축하고 풀 때의 무게 포인터와 메모리 포인터
	maxmemptr, maxwtptr int // 지금까지 본 가장 큰 값
	maxomp              int // 지금까지 본 가장 큰 |omp|
	tmap, itmap, omap, iomap [deg]int // 트라이를 위한 성긴 집합들
	tms, tmx, oms, omx       int      // 그리고 그 포인터들
)

@ 다음은 주어진 열쇠, 곧 |code| 값들의 수열에 맞는 잎을 찾아 트라이를 내려가는
과정이다. 없으면 넣는다. 원본에서는 함수 \.{trielookup}이지만 부르는 곳이
|contribute| 하나뿐이니 여기서는 그 안에 끼워 넣는 절로 둔다. 끝나면 |p|가 잎의
번호이고, 그 무게는 |weight[p-1]|이다.

수준 |l|에서 $a_l=|code[l]|$로 가지를 칠 때, 쓸 수 있는 양의 부호는 앞에서 말한 대로
대개 |tmap|의 앞쪽 |tms|칸과 |tmx|다. 아직 안 쓴 값 |tmx|는 쓸 수 없을 때도 있다.

@<새 트라이에서 열쇠 |code|를 찾는다@>=
tms, tmx = 0, 1
p := uint64(1)
var pp uint64
for l := 0; l < q; l, p = l+1, mem[pp] {
	j := code[l]
	if j <= 0 {
		pp = uint64(int(p) + j)
	} else if j == tmx { // 앞서 나온 것보다 큰 부호
		@<|tmx|를 |tmap|에 넣고 그리로 간다@>@;
	} else { // 앞서 나온 부호와 짝을 이룬다
		@<|j|를 |tmap|에서 빼고 그리로 간다@>@;
	}
	if mem[pp] == 0 { // $a_0\ldots a_l$은 처음이다
		if l+1 < q {
			@<수준 |l+1|에 새 마디를 마련한다@>@;
		} else {
			@<새 무게를 마련한다@>@;
		}
	}
}

@ @<|tmx|를 |tmap|에...@>=
if tmx > maxdeg {
	maxdeg = tmx
	if tmx == deg {
		fmt.Fprintf(errw, "Overflow: code digits must be less than %d!\n", deg)
		quit(-66)
	}
}
tmap[tms], itmap[tmx] = tmx, tms
tms++
tmx++
pp = p + uint64(tms)

@ @<|j|를 |tmap|에서...@>=
tms--
k, kk := tmap[tms], itmap[j]
tmap[kk], itmap[k] = k, kk
pp = p + 1 + uint64(kk)

@ 미묘한 점이 하나 있다. |l+2+tms=q|이면 |tmx|를 위한 칸을 두지 않는다. |tmx|는 두
번 나와야 하는데 남은 자리가 하나뿐이기 때문이다.

원본은 |memptr|를 늘리기 전에 |mem[memptr]|과 |mem[memptr+1]|을 먼저 쓴다. 넘침을
따질 때 한 칸을 더 보아 두므로 그래도 안전하다. 이 판에서도 |mem|의 길이가 늘
|memptr+1|보다 크도록 늘려 둔다.

@<수준 |l+1|에 새 마디를...@>=
slots := tms // 이미 나온 양의 부호를 위한 칸만 둔다
if l+1+tms < q { // $\bar1$과 $0$을 위한 칸을 둔다
	mem[memptr], mem[memptr+1] = 0, 0 // 안전하다. 위를 보라
	memptr += 2
	slots = tms + 1
	if l+2+tms == q {
		slots = tms // 위를 보라
	}
}
if memptr+slots+1 >= memsize {
	fmt.Fprintf(errw, "Oops: Dictionary overflow (more than %d pointers)!\n", int64(memsize))
	quit(-666)
}
mem[pp] = uint64(memptr - 1)
mem = grow(mem, memptr+slots+2)
for s := 0; s < slots; s++ {
	mem[memptr+s] = 0
}
memptr += slots // 이제도 |memptr+1|은 |memsize|보다 작다

@ @<새 무게를...@>=
wtptr++
mem[pp] = uint64(wtptr)
if wtptr >= wtsize {
	fmt.Fprintf(errw, "Oops: Dictionary overflow (more than %d classes)!\n", int64(wtsize))
	quit(-6666)
}
weight = grow(weight, wtptr)
weight[wtptr-1] = zero

@ 다음은 |mem|에 든 트라이를 압축해 그와 같은 것을 |oldmem|에 넣는 되돌이 함수다.
|oldmem|에 채운 비트열은 읽기 좋은 쪽이 아니라 편한 쪽을 따라, 큰 쪽 먼저와 작은 쪽
먼저가 묘하게 섞인 차례로 놓인다.

|tmap|, |itmap|, |tms|, |tmx|를 닮은 성긴 집합 |omap|, |iomap|, |oms|, |omx|가
하나 더 있다. (모두 전역 변수다.)

이 함수는 |l=0|, |p=1|, |d=3|으로 부르고, 부르기 전에
|pack=spack=omp=owp=oms=0|, |omx=1|로 둔다.

@<함수들@>=
func compress(l int, p uint64, d int) { // |d|는 수준 |l|의 마디 |p|의 차수다
	if l == q {
		@<|weight[p-1]|을 간수한다@>@;
		return
	}
	j0 := -1
	if l+oms == q {
		j0 = 1
	}
	var bits uint64
	for j, k := j0, 0; k < d; j, k = j+1, k+1 {
		if mem[int(p)+j] != 0 {
			bits += 1 << k
		}
	}
	@<|bits|를 |oldmem|에 덧붙인다@>@;
	for j, k := j0, 0; k < d; j, k = j+1, k+1 {
		if bits&(1<<k) != 0 {
			@<자식 |j|로 내려가 압축한다@>@;
		}
	}
}

@ 자식으로 내려가기 전에 성긴 집합을 고치고, 돌아와서 되돌린다. 변수 |kk|가 $0$이면
|omx|를 새로 쓴 것이다.

@<자식 |j|로 내려가 압축한다@>=
var kk, kkk int
if j > 0 {
	if j > oms {
		omap[oms], iomap[omx] = omx, oms
		oms++
		omx++
		kk = 0
	} else {
		oms--
		kk, kkk = omap[oms], omap[j-1]
		omap[j-1], iomap[kk] = kk, j-1
	}
}
compress(l+1, mem[int(p)+j], childDeg(l, oms, q))
if j > 0 { // 성긴 집합에 한 일을 되돌려야 한다
	if kk == 0 {
		oms--
		omx--
	} else {
		omap[j-1], omap[oms], iomap[kk] = kkk, kk, oms
		oms++
	}
}

@ 수준 |l+1|의 자식이 몇 갈래인지는 압축과 풀기가 똑같이 셈한다. 남은 자리가 열린
부호의 수와 같으면 열린 부호만 올 수 있고, 하나 더 많으면 $-1$과 $0$이 더해지며,
그보다 많으면 새 부호도 올 수 있다.

@<함수들@>=
func childDeg(l, s, qq int) int {
	switch {
	case l+1+s == qq:
		return s
	case l+2+s == qq:
		return s + 2
	}
	return s + 3
}

@ 원본은 |oldmem|을 |oldmemsize|{\it 바이트\/}로 잡고서, 넘침은 낱말 색인 |omp|가
|oldmemsize|에 이르는지로 따진다. 예순네 비트 낱말로는 |oldmemsize/8|개만 잡았으니,
압축한 트라이가 그 사이 크기일 때는 넘침을 알리지 못한 채 잡은 곳 너머에 쓴다.
원본에서 |oldmemsize|만 $800$으로 줄이고 \.{AddressSanitizer}를 붙여 $6\times6$
나이트 그래프를 돌려 보니, 낱말 $100$개 너머에 쓰다가 힙 넘침으로 잡혔다. (그
그래프에는 낱말 $65135$개가 든다.) 이 판은 낱말 수 |oldmemsize/8|과 견준다. 말에
``바이트''라고 적힌 것과도 이쪽이 맞는다.

@<|bits|를 |oldmem|에...@>=
if spack+d > bitsperword {
	oldmem = grow(oldmem, omp+1)
	oldmem[omp] = pack
	omp++
	pack, spack = bits, d
	if omp >= oldmemsize/8 {
		fmt.Fprintf(errw, "Oops: oldmem overflow (more than %d bytes)!\n", oldmemsize)
		quit(-666666)
	}
} else {
	pack += bits << spack
	spack += d
}

@ @<상수@>=
const bitsperword = 64 // |oldmem| 낱말 하나의 비트 수

@ 원본은 자릿수 |prec|만큼만 옮긴다. 그 위의 자리는 어느 무게에서나 $0$이니 통째로
옮겨도 같다.

@<|weight[p-1]|을 간수한다@>=
oldweight = grow(oldweight, owp+1)
oldweight[owp] = weight[p-1]
owp++

@ @<$m$-동치류의 트라이를 $(m-1)$-동치류의 옛 트라이로...@>=
fmt.Fprintf(errw, "There are %d %d-classes,\n", wtptr, m-1)
fmt.Fprintf(errw, " resulting from %d contributions and filling %d pointers.\n",
	contribs, memptr)
spack, omp, owp, oms, omx = 0, 0, 0, 0, 1
pack = 0
oldq = q
compress(0, 1, 3)
oldmem = grow(oldmem, omp+1)
oldmem[omp] = pack // 마지막 비트들을 간수한다
if omp > maxomp {
	maxomp = omp
}

@ 옛 동치류는 압축형에서 또 다른 되돌이 함수로 되찾는다. |compress|를 거울에 비춘
모양이다.

이 프로그램의 본 일은 실은 이 함수가 수준 |oldq|에 이르러 옛 동치류 하나를
``찾아갈'' 때 일어난다. 옛 동치류들은 사전순과 어렴풋이 닮은 특별한 차례로 찾아가고,
그러면서 마디마다의 앞머리인 |oldcode| 값을 되살린다.

이 함수는 |uncompress(0,3)|으로 부르고, 부르기 전에 |spack=oldp=omp=oms=0|,
|omx=1|, |pack=oldmem[0]|으로 둔다.

@<함수들@>=
func uncompress(l, d int) { // 수준 |l|의 차수 |d|인 마디를 푼다
	if l == oldq {
		@<무게가 |oldweight[oldp]|인 동치류 |oldcode|를 찾아간다@>@;
		oldp++
		return
	}
	@<|bits|에 |oldmem|의 다음 |d|비트를 넣는다@>@;
	j0 := -1
	if l+oms == oldq {
		j0 = 1
	}
	for j, k := j0, 0; k < d; j, k = j+1, k+1 {
		if bits&(1<<k) != 0 {
			@<자식 |j|의 부호를 적고 내려가 푼다@>@;
		}
	}
}

@ @<|bits|에 |oldmem|의...@>=
if spack+d > bitsperword {
	omp++
	pack, spack = oldmem[omp], 0
}
bits := pack >> spack
spack += d

@ @<자식 |j|의 부호를...@>=
var kk, kkk int
switch {
case j <= 0:
	oldcode[l] = j
case j > oms:
	oldcode[l] = omx
	omap[oms], iomap[omx] = omx, oms
	omx++
	oms++
	kk = 0
default:
	oldcode[l] = omap[j-1]
	oms--
	kk, kkk = omap[oms], omap[j-1]
	omap[j-1], iomap[kk] = kk, j-1
}
uncompress(l+1, childDeg(l, oms, oldq))
if j > 0 { // 성긴 집합에 한 일을 되돌려야 한다
	if kk == 0 {
		oms--
		omx--
	} else {
		omap[j-1], omap[oms], iomap[kk] = kkk, kk, oms
		oms++
	}
}

@* 경계.
경계 $F_m$은 $m$보다 크면서 $m$ 이하인 마디 하나에라도 이웃한 마디의 집합이라고
정했다. 그러니 $F_0=\emptyset$이고
$F_m=\bigl(F_{m-1}\cup\{v\mid m\adj v$이고 $m<v\}\bigr)\setminus m$이다. 특히
$F_1=\{v\mid 1\adj v\}$은 마디 $1$의 이웃 집합이다. 눈여겨보면
$\vert F_m\vert\ge\vert F_{m-1}\vert-1$이고 $\vert F_m\vert\le n+1-m$이다. 새 마디
$n+1$은 모든 마디와 이웃하니 $m\ge1$이면 늘 $F_m$에 든다.

우리 목적에는 $0\le m<n$마다 {\it 늘린\/} 경계 $\widehat F_m=F_m\cup\{m+1,n+1\}$로
일하는 편이 낫다. 그러면 $m+1$과 $n+1$은 늘 $\widehat F_m$의 원소다. 특히
$\widehat F_0=\{1,n+1\}$이다. 이렇게 바꾸어도 동치류의 정의는 달라지지 않는다. 마디
$m+1$이 원래 $F_m$에 없었다면 늘 맨몸이고, $n+1$은 $F_0$ 말고는 모든 경계에 이미 있기
때문이다. 늘린 경계를 쓰면 프로그램이 더 간단해진다는 것을 곧 보게
된다.

@ 경계는 $m$이 자라는 동안 성긴 집합으로 간수하는 것이 제격이다. 배열 |fr|은 마디들의
순열을 담고, 짝 배열 |ifr|은 그 역순열을 담는다. 배열 |fr|의 앞쪽 |q|칸이 지금의
경계다.

더 정확히 말하면 $1\le v\le n+1$마다 |fr[ifr[v]]=v|이고, $0\le k\le n$마다
$1\le|fr[k]|\le n+1$이다. 마디 $v$가 $\widehat F_m$에 드는 것은 |ifr[v]<q|일 때이고
오직 그때뿐이다. (이 약속은 $0$에서 세는 색인과 $1$에서 세는 색인을 일부러 섞는다.
크누스가 설명하기 좋으라고 $G^+$의 마디 이름을 $\{0,\ldots,n\}$ 대신
$\{1,\ldots,n+1\}$로 골랐기 때문이다.)

경계의 원소를 늘어놓는 차례는 트라이의 열쇠를 지을 때 중요하다. 이 구현은 원소들을
정규한 차례로 둔다. 늘린 경계 $\widehat F_m$의 크기를 $q$라 하고,
$\bigl(\widehat F_{m-1}\cup\{m+1\}\bigr)\cap\widehat F_m$의 크기를 $q_0$이라 하자.
그러면 |fr[0]=n+1|이고, $1<k<q_0$과 $q_0<k<q$마다 |fr[k-1]<fr[k]|가 되게 한다.
특히 $m=n$인 뻔한 경우만 빼면 늘 |fr[1]=m+1|이다.

@<전역 변수@>=
var (
	fr   [maxn]int     // 지금 경계의 순열
	ifr  [maxn + 1]int // 그 역순열
	ofr  [maxn]int     // 앞선 경계의 복사본
	q0   int           // 중간 크기의 경계 (아래를 보라)
)

@ @<초기화한다@>=
fr[0], ifr[n+1] = n+1, 0
for k = 1; k <= n; k++ {
	fr[k], ifr[k] = k, k
}
q = 2
mem[0], mem[2], mem[1], memptr = 0, 0, 1, 3
weight[0], wtptr = one, 1

@ 늘린 경계를 $\widehat F_{m-1}$에서 $\widehat F_m$으로 바꾸는 일은 세 단계다.
먼저 마디 $m$을 빼고 $m+1$을 새 마디 다음 자리 |fr[1]|에 둔다. 그다음 $m$의 이웃 가운데 새로 들어올 것을
넣고, 끝으로 정렬한다.

@<$\widehat F_{m-1}$에서 $\widehat F_m$으로 바꾼다@>=
for j = 1; j < q; j++ {
	ofr[j] = fr[j]
}
oldq = q
iv = ifr[m+1] // `$m+1$'은 |fr|의 어디에 있나?
q--
if iv < q { // $F_{m-1}$에 있고 마지막 원소가 아니다
	x = fr[q] // $F_{m-1}$의 마지막 원소다
	fr[1] = m + 1
	ifr[m+1] = 1
	fr[q] = m
	ifr[m] = q
	fr[iv] = x
	ifr[x] = iv // 셋을 한 바퀴 돌려 바꾼다
} else {
	fr[1], ifr[m+1] = m+1, 1
	fr[iv], ifr[m] = m, iv // |m|과 |m+1|을 맞바꾼다
	if iv != q {
		q++ // 마지막 원소를 되살린다
	}
}
q0 = q
@<$\widehat F_m\setminus\widehat F_{m-1}$의 원소를 넣는다@>@;
@<경계를 정렬한다@>@;
@<옮겨 가는 데 쓸 대응표를 마련한다@>@;

@ 원본은 $m$의 이웃 $k$ 가운데 $k<m$인 것만 건너뛴다. 그래서 마디 $m$에 제 고리가
있으면 $k=m$인 이웃이 경계에 끼어든다. 이때 $m$은 방금 경계 밖으로 옮겨 두었으니
|ifr[m]>=q|이고, 그대로 경계에 들어간다. 원본은 그러고 나서 $m$을 제 이웃인 양
동치류에 이어 붙여 틀린 수를 셈하고, \.{UndefinedBehaviorSanitizer}가 배열 바깥을
짚는다고 알리기도 한다. 제 고리는 해밀턴 경로에 들 수 없으니 이 판은 $k\le m$을
건너뛴다. 이웃 목록 |nbr|을 짓는 자리도 똑같이 고쳤다.

@<$\widehat F_m\setminus\widehat F_{m-1}$의...@>=
for a := g.Vertices[m-1].Arcs; a != nil; a = a.Next {
	k = int(g.Index(a.Tip)) + 1 // |m|의 이웃의 번호
	if k <= m {
		continue
	}
	ik = ifr[k] // |k|는 |fr|의 어디에 사나?
	if ik >= q { // |k|를 경계에 넣어야 한다
		x = fr[q]
		fr[q] = k
		ifr[k] = q
		fr[ik] = x
		ifr[x] = ik
		q++
	}
}

@ 앞쪽 $q_0$개와 뒤쪽을 따로 끼워 넣기 정렬한다. 원소 |fr[0]=n+1|과 |fr[1]=m+1|은
제자리다.

@<경계를 정렬한다@>=
for k = 3; k < q0; k++ {
	if fr[k] < fr[k-1] {
		t = fr[k]
		for j = k - 1; ; j-- {
			fr[j+1], ifr[fr[j]] = fr[j], j+1
			if j == 1 || fr[j-1] < t {
				break
			}
		}
		fr[j], ifr[t] = t, j
	}
}
for k = q0 + 1; k < q; k++ {
	if fr[k] < fr[k-1] {
		t = fr[k]
		for j = k - 1; ; j-- {
			fr[j+1], ifr[fr[j]] = fr[j], j+1
			if j == q0 || fr[j-1] < t {
				break
			}
		}
		fr[j], ifr[t] = t, j
	}
}

@ $m$이 한 걸음 나아가 모든 $(m-1)$-동치류를 차례로 훑을 채비가 되면, 그 경계를
찍어 두기 좋은 때다.

@<앞선 경계를 찍는다@>=
fmt.Fprintf(errw, "\nThe frontier for %d-classes is", m-1)
for k = 0; k < q; k++ {
	fmt.Fprintf(errw, " %s", g.Vertices[fr[k]-1].Name)
}
fmt.Fprint(errw, ".\n")

@* 동치류의 정규한 열쇠.
지금의 늘린 경계가 마디 $q$개 $v_1\ldots v_q$로 되어 있을 때, 동치류 하나는 안에서
|mate[1]|\dots|mate[q]|라는 표로 나타낸다. 마디 $v_j$가 맨몸이면 |mate[j]=0|, 안쪽이면
|mate[j]=-1|이고, $v_j$와 $v_k$가 한 부분경로의 두 끝이면 |mate[j]=k|다.

이 나타냄은 앞에서 말한 부호 수열과 다르다. 그쪽에서는 경로의 두 끝이 같은 부호를
받았다.

트라이의 열쇠는 부호의 수열 |code[0]|부터 |code[q-1]|까지다. 그러니 |mate| 표를
|code| 수열로 바꿔야 한다.

@<|mate| 표를 열쇠로 바꾼다@>=
for t, k := 0, 1; k <= q; k++ {
	j := mate[k]
	if j <= 0 {
		code[k-1] = j
	} else if j > k {
		t++
		code[k-1], code[j-1] = t, t
	}
}

@ 거꾸로 가는 일도 귀엽다.

@<옛 열쇠를 |oldmate| 표로 바꾼다@>=
for k := 1; k+k <= oldq; k++ {
	path[k] = 0
}
for k := 1; k <= oldq; k++ {
	j := oldcode[k-1]
	if j <= 0 {
		oldmate[k] = j
	} else if e := path[j]; e == 0 {
		path[j] = k
	} else {
		oldmate[k], oldmate[e] = e, k
	}
}

@ 원본의 이웃 목록 |nbr|은 크기가 |maxn|인 배열이다. 그런데 겹친 변이 있는
그래프에서는 한 마디의 이웃이 마디 수보다 많을 수 있다. 이 판은 조각으로 두어 그런
경우에도 넘치지 않게 했다.

@<전역 변수@>=
var (
	path    [maxn]int     // 경로 번호나 끝점을 담는 일터
	mate    [maxn]int     // 동치류를 나타내는 표
	oldmate [maxn]int     // 옛 동치류를 나타내는 표
	bmate   [maxn]int     // 옮겨 갈 때 쓰는 바탕 짝 표
	mp      [maxn + 1]int // 대응 함수 |map|: |map[x]=mp[1+x]|
	imap    [maxn]int     // |map|의 (대략의) 역함수
	r       int           // 마디 $m$의 이웃 가운데 $m$보다 큰 것의 수
	nbr     []int         // 그 이웃들의 경계 안 색인
	steps   int           // 지금까지 다룬 옛 동치류의 수
)

@* 옮겨 가기.
이 프로그램의 바탕 착상은, $(m-1)$-짜임의 동치류 무게를 모두 알면 $m$-짜임의 동치류
무게를 모두 셈할 수 있다는 것이다. 이 셈을 이해하려면 일반적인 경우의 특징을 거의
다 보여 주는 만만치 않은 예를 하나 보면 좋다.

그러니 $m=5$, $n=19$이고 그래프 $G^+$의 $4$-경계가 마디 수열
$(20,5,6,13,7,8)$인 경우를 보자. 또 마디 $5$의 이웃 가운데 $5$보다 큰 것은 $6$, $8$,
$11$, $12$, $20$이라고 하자.

앞의 프로그램에 따르면 그래프의 $5$-경계는 마디 수열 $(20,6,7,8,13,11,12)$가 된다.
(먼저 |fr| 배열의 앞쪽 여섯이 $(20,6,8,13,7,5)$로 바뀌고 $q$가 |oldq=6|에서
$q_0=5$로 준다. 그다음 $q$가 $7$로 늘면서 $11$과 $12$가 제자리로 들어오고, 끝으로
정렬한다.)

@ $4$-동치류($4$-짜임의 동치류)의 트라이에서 마디 $u_1u_2u_3u_4u_5u_6$은 $G^+$의
마디 $20$, $5$, $6$, $13$, $7$, $8$이 이 차례로 된 것이다. 그리고 |oldmate| 표는 이
마디들에 색인 $\{1,2,3,4,5,6\}$을 쓴다. 이를테면 어떤 동치류에서 마디 $6$과 $7$이 한
부분경로의 두 끝이면 그것들은 $u_3$과 $u_5$이니 |oldmate[3]=5|이고 |oldmate[5]=3|이다.

$5$-경계의 마디 $v_1v_2v_3v_4v_5v_6v_7$은 마찬가지로 $G^+$의 마디 $20$, $6$, $7$, $8$,
$13$, $11$, $12$가 이 차례로 된 것이다. 마디 $6$과 $7$은 이제 $v_2$와 $v_3$이다.
그러니 $4$-경계에서의 관계 |oldmate[3]=5|와 |oldmate[5]=3|은 $5$-경계에서
|mate[2]=3|과 |mate[3]=2|와 같다.

@ 그래서 두 이름 매김 사이의 관계를 나타내는 배열 |map|을 짓는 것이 자연스럽다.
이 예에서는 |map[1]=1|, |map[2]=0|, |map[3]=2|, |map[4]=5|, |map[5]=3|,
|map[6]=4|이다. 곧 |map[1]|은 늘 $1$, |map[2]|는 늘 $0$이고, $2<j\le|oldq|$마다
$u_j=v_{map[j]}$다. 또 |map[-1]=-1|과
|map[0]=0|으로 둔다.

거꾸로 가는 배열 |imap|도 지을 수 있다. 이 예에서는 |imap[1]=1|, |imap[2]=3|,
|imap[3]=5|, |imap[4]=6|, |imap[5]=4|이다. 일반적으로 $1\le j\le q_0$마다 $v_j=u_{imap[j]}$이고,
$q_0$은 $5$-경계의 마디 가운데 $4$-경계에도 있던 것의 수다. (이 예에서는
$(m-1)$-경계가 공교롭게 $m+1=6$을 품고 있기 때문이다.) 그러면 대개
$1\le j\le q_0$마다 |mate[j]=map[oldmate[imap[j]]]|이고, $q_0<j\le q$마다
|mate[j]=0|이다. 또 |oldmate[0]=mate[0]=0|으로 둔다.

앞 문단의 ``대개''는 ``|oldmate[imap[j]]=2|일 때만 빼고''라는 뜻이다. |map[2]=0|이기
때문이다. 그 예외는 잠시 접어 두자.

\GO/에는 음수 색인이 없으니 |map[x]|를 |mp[1+x]|에 담는다. 원본도 그렇게 한다.

@<초기화한다@>=
mp[0], mp[2] = -1, 1 // |map[-1]=-1|, |map[1]=1|
imap[1] = 1

@ 가장 간단한 경우는 마디 $m$이 그 $(m-1)$-짜임 안에서 ``안쪽''인 동치류, 곧
|oldmate[2]=-1|인 경우다. 그러면 그 $(m-1)$-짜임은 이미 $m$-짜임이다. 그러니 번호만
알맞게 고쳐 $m$-짜임의 트라이에 보태면 된다. 이때의 |mate| 표를 |bmate|라 한다.

@<|oldmate|에서 |bmate| 표를 짓는다@>=
for j := 1; j <= q0; j++ {
	bmate[j] = mp[1+oldmate[imap[j]]] // |mp[x]=map[x-1]|
}
for j := q0 + 1; j <= q; j++ {
	bmate[j] = 0
}

@ @<|bmate| 동치류를 보탠다@>=
copy(mate[1:q+1], bmate[1:q+1])
contribute()

@ 방금 말한 |contribute|는 $m$-동치류의 트라이를 고쳐 나가는 바탕 장치다.

@<함수들@>=
func contribute() {
	@<|mate| 표를 열쇠로 바꾼다@>@;
	@<새 트라이에서 열쇠 |code|를 찾는다@>@;
	addToBignum(&weight[p-1], &oldweight[oldp])
	contribs++
}

@ 예의 그래프에서 $5$의 이웃 가운데 $5$보다 큰 것 $(20,6,8,11,12)$는 공교롭게
$(v_1,v_2,v_4,v_6,v_7)$이기도 하다. 일반적으로 마디 $m$에게 $m$-경계 안의 이웃이 $r$개
있으면 그 색인들을 |nbr|에 늘어놓는다. 이 예에서는 $r=5$이고 |nbr[0]=1|, |nbr[1]=2|,
|nbr[2]=4|, |nbr[3]=6|, |nbr[4]=7|이다. 새 마디는 모든 마디의 이웃이니 늘
|nbr[0]=1|이다. 그 이웃 관계는 그래프에 변으로 적혀 있지 않으니 여기서 손수 넣는다.

@<옮겨 가는 데 쓸 대응표를...@>=
nbr = append(nbr[:0], 1)
for a := g.Vertices[m-1].Arcs; a != nil; a = a.Next {
	k = int(g.Index(a.Tip)) + 1 // |m|의 이웃의 번호
	if k <= m {
		continue
	}
	nbr = append(nbr, ifr[k]+1)
}
r = len(nbr)

@ 예외 없는 경우가 하나 더 있다. 마디 $m$이 ``맨몸''인 동치류, 곧 |oldmate[2]=0|인
경우다. 그러면 $m$-동치류에 보탤 것이 이웃 쌍마다 하나씩, $r\choose2$가지 있을 수
있다. 예에서는 ${5\choose2}=10$가지 가운데 하나가 $v_4\adj 5\adj v_7$이다. 되면 이
두 변을 |bmate|의 동치류에 보탠다. 효과는 유도된 변 $v_4\adj v_7$을 보태는 것과
같다.

@<$m$이 맨몸일 때 알맞은 동치류들을 보탠다@>=
for i := 0; i < r; i++ {
	for ii := i + 1; ii < r; ii++ {
		copy(mate[1:q+1], bmate[1:q+1])
		if addDerived(nbr[i], nbr[ii]) {
			contribute()
		}
	}
}

@ 끝으로 예외인 경우는 |oldmate[2]>0|일 때 생긴다. 그러면 $m$-동치류에 이웃마다
하나씩, $r$가지를 보탠다. 이를테면 |oldmate[2]=6|이라 하자. 곧 $u_2$는 한 경로의
끝이고 그 다른 끝은 $u_6$, 곧 $v_{map[6]}=v_4$다. (이것이 예외인 것은
|oldmate[imap[4]]=oldmate[6]=2|이기 때문이다.) 마디 $5$에서 $v_j$로 변을 보태는
것은 $v_4$와 $v_j$ 사이에 변을 보태는 것과 아주 비슷하다. 그러면 $v_4$에서 $v_j$로
가는 경로가 생기기 때문이다.

@<$m$이 바깥일 때 알맞은 동치류들을 보탠다@>=
for i := 0; i < r; i++ {
	copy(mate[1:q+1], bmate[1:q+1])
	if addDerived(mp[1+oldmate[2]], nbr[i]) {
		contribute()
	}
}

@ 마디 $m+1$이 옛 경계에 없었으면 |imap[2]|가 $0$이어야 한다. 그래야 |bmate[2]|도
$0$이 된다. 있었으면 |imap[2]|는 $m+1$이 전에 있던 자리여야 한다.

@<옮겨 가는 데 쓸 대응표를...@>=
imap[2] = 0
for j = 3; j <= oldq; j++ {
	mp[j+1] = 1 + ifr[ofr[j-1]] // |map[j]=mp[j+1]|
	imap[mp[j+1]] = j
}

@* 유도된 변 보태기.
마디 $v_1\ldots v_q$의 쌍들 사이의 부분경로가 |mate| 표로 주어졌을 때, $v_i$와
$v_j$ 사이에 이음을 보탤 수 있는 것은 둘 다 안쪽이 아닐 때, 곧 |mate[i]>=0|이고
|mate[j]>=0|일 때뿐이다.

그런 경우에는 $v_i$와 $v_j$가 맨몸인지 아닌지에 따라 네 갈래가 있다.

뜻밖의 미묘한 점이 하나 있다. 마디 $m$이 바깥 마디이고 그 경로의 다른 끝에
이웃해 있으면 유도된 고리를 닫는 셈이다. 그때는 |bmate|에서 다른 끝이 맨몸으로
보이므로 |i==j|이고 둘 다 맨몸이다.

@ 원본은 |i==j|를 둘 다 맨몸일 때만 따진다. 단순 그래프에서는 그것으로 넉넉하다. 그런데
겹친 변이 있으면 맨몸인 $m$의 이웃 목록에 같은 마디 $v$가 두 번 나올 수 있고, $v$가
바깥 마디일 수도 있다. 그러면 원본은 ``두 부분경로를 잇는'' 갈래로 들어가
|mate[w]=w|라는 엉터리 짝을 만든다. 여기서 $w$는 $v$의 짝이다. 그 뒤로는 트라이의
열쇠가 깨져 틀린 수를 셈하거나 배열 바깥을 짚고 죽는다. 이를테면 마디 넷에 변 $1\adj2$, $1\adj3$,
$1\adj4$와 두 겹의 $2\adj4$, $3\adj4$가 있는 그래프에서 원본은 $4$-경로가 $18$개라고
하는데, 옳은 수는 $16$이다. 바깥 마디에 변 둘을 한꺼번에 붙일 수는 없으니 이 판은
그때 거짓을 돌려준다. 마디 $v$가 맨몸이면 원본대로 고리를 닫는다. 두 마디 $m$과 $v$
사이의 겹친 변 둘이 이루는 $2$-회로인데, 새 마디가 안쪽이 아니니 경로로 세지는
않는다.

@<함수들@>=
func addDerived(i, j int) bool {
	if mate[i] < 0 || mate[j] < 0 {
		return false
	}
	if i == j && mate[i] > 0 {
		return false // 바깥 마디에 변 둘을 붙일 수는 없다
	}
	switch {
	case mate[i] == 0 && mate[j] == 0: // $v_i$와 $v_j$가 맨몸이다
		if i != j {
			mate[i], mate[j] = j, i
			return true
		}
	case mate[i] == 0: // $v_i$는 맨몸이고 $v_j$는 바깥이다
		mate[i] = mate[j]
		mate[mate[j]] = i
		mate[j] = -1 // $v_j$가 안쪽이 된다
		return true
	case mate[j] == 0: // $v_j$는 맨몸이고 $v_i$는 바깥이다
		mate[j] = mate[i]
		mate[mate[i]] = j
		mate[i] = -1 // $v_i$가 안쪽이 된다
		return true
	case mate[i] != j: // 두 부분경로를 잇는다
		mate[mate[i]] = mate[j]
		mate[mate[j]] = mate[i]
		mate[i], mate[j] = -1, -1
		return true
	}
	@<고리를 적어 두고 거짓을 돌려준다@>@;
}

@ 부분경로의 두 끝을 이으면 물론 고리가 생긴다. 그때 고리의 마디는 모두 안쪽이 된다.
고리는 $m$-짜임에 있을 수 없으니 지금 동치류는 트라이에 보태지 않는다.

하지만 그 고리가 우리가 세려는 특별한 회로라면 중요하다. 그것은 다음 두 조건을
채우는 정수 $m'$이 있을 때이고 오직 그때뿐이다. (i)~그래프의 $m'$ 이하인 마디는
모두 안쪽이다. (ii)~$m'$보다 큰 마디는 모두 맨몸이다. 두 조건이 다 채워지면
해밀턴 $m'$-경로의 수에 보탠다. 새 마디 $n+1$도 안쪽이어야 한다. 경로의 두 끝이
새 마디에 이어져 회로가 닫혔다는 뜻이기 때문이다.

$q_0\le k<q$인 경계 마디 |fr[k]|는 안쪽일 수 없다. 그 마디의 $m$ 이하인 이웃은 $m$
자신뿐이기 때문이다. 그러니 옳은 회로라면 |fr[1]=m+1|, |fr[2]=m+2|, \dots,
|fr|$[m'-m]=m'$이고 $m'-m<q_0$이어야 한다.

@<고리를 적어 두고...@>=
mate[i], mate[j] = -1, -1
if mate[1] >= 0 {
	return false // $n+1$은 안쪽이 아니다
}
k := 2
for ; k <= q0; k++ {
	if mate[k] >= 0 {
		break // $v_k$는 안쪽이 아니다
	}
	if fr[k-1] != m+k-1 {
		return false // |m+k-1|은 안쪽이 아니다
	}
}
for kk := k; kk <= q; kk++ {
	if mate[kk] != 0 {
		return false // |m+k-1| 이상인 경계 원소가 맨몸이 아니다
	}
}
fmt.Fprint(errw, "Class ")
printOldKey()
fmt.Fprint(errw, " contributes ")
printBignum(errw, &oldweight[oldp])
fmt.Fprintf(errw, " to a %d-path.\n", m+k-2)
addToBignum(&count[m+k-2], &oldweight[oldp])
return false

@ 옛 열쇠를 찍는 일은 네 곳에서 한다. 부호 $-1$은 `\.\#'로, $10$ 이상은 소문자로
적는다.

@<함수들@>=
func printOldKey() {
	for l := 0; l < oldq; l++ {
		x := oldcode[l]
		switch {
		case x < 0:
			errw.WriteByte('#')
		case x < 10:
			errw.WriteByte(byte('0' + x))
		default:
			errw.WriteByte(byte('a' + x - 10))
		}
	}
}

@* 트라이 훑기.
이 프로그램의 큰 반복은 ``옛'' 트라이, 곧 |oldmem|과 |oldweight|로 정해지는
트라이에 든 $(m-1)$-동치류를 모두 찾아가 그 뒤들을 $m$-동치류의 ``새'' 트라이에
보태는 일이다. 그 일은 |uncompress|의 수준 |oldq|에서 일어나며, 그때 |oldcode|
표에는 지금 찾아간 $(m-1)$-동치류가 들어 있다.

@<옛 동치류마다 그 뒤를...@>=
spack, oldp, omp, oms, omx, pack = 0, 0, 0, 0, 1, oldmem[0]
uncompress(0, 3)

@ @<무게가 |oldweight[oldp]|인 동치류...@>=
@<옛 열쇠를 |oldmate| 표로 바꾼다@>@;
@<눈여겨볼 동치류면 통계를 찍는다@>@;
@<|oldmate|에서 |bmate| 표를 짓는다@>@;
switch {
case oldmate[2] < 0:
	@<|bmate| 동치류를 보탠다@>@;
case oldmate[2] == 0:
	@<$m$이 맨몸일 때...@>@;
default:
	@<$m$이 바깥일 때...@>@;
}

@ 첫 동치류는 늘 찍고, 그 뒤로는 무게가 가장 작거나 가장 큰 것이 바뀔 때마다
찍는다. 또 $2^{21}$개마다 점을 하나 찍어 진행을 알린다.

@<눈여겨볼 동치류면...@>=
if oldp == 0 {
	@<첫 동치류의 통계를 찍는다@>@;
} else {
	@<뒤따르는 동치류의 통계를 찍는다@>@;
}

@ @<첫 동치류의...@>=
fmt.Fprint(errw, "The first one is ")
printOldKey()
fmt.Fprint(errw, "\nand its weight is ")
printBignum(errw, &oldweight[oldp])
fmt.Fprint(errw, ".\n")
minweight, maxweight = oldweight[oldp], oldweight[oldp]
steps, contribs = 0, 0
errw.Flush()

@ @<뒤따르는 동치류의...@>=
if bignumComp(&oldweight[oldp], &minweight) < 0 {
	minweight = oldweight[oldp]
	@<이 동치류의 무게를 찍는다@>@;
}
if bignumComp(&oldweight[oldp], &maxweight) > 0 {
	maxweight = oldweight[oldp]
	@<이 동치류의 무게를 찍는다@>@;
}
if steps&progressMask == progressMask {
	fmt.Fprint(errw, ".")
	errw.Flush()
}
steps++

@ @<이 동치류의 무게를...@>=
fmt.Fprint(errw, "Class ")
printOldKey()
fmt.Fprint(errw, " has weight ")
printBignum(errw, &oldweight[oldp])
fmt.Fprint(errw, ".\n")

@ @<$m$-동치류를 받을 새 트라이를...@>=
if memptr > maxmemptr {
	maxmemptr = memptr
}
if wtptr > maxwtptr {
	maxwtptr = wtptr
}
mem[0], mem[1], mem[2], memptr, wtptr = 0, 0, 0, 3, 0 // 뿌리 마디는 늘 있다
@<$\widehat F_{m-1}$에서 $\widehat F_m$으로 바꾼다@>@;

@ 해밀턴 $m'$-회로가 있으면 $\lfloor(m'-1)/2\rfloor$-짜임이 적어도 하나 있다. 하지만
$\lfloor(m'+1)/2\rfloor$-짜임은 하나도 없을 수 있다. 그러니 마지막 $m$-짜임을 찾은
뒤에 회로 수를 여럿 알려야 할 수도 있다.

@<마지막 보고를...@>=
fmt.Fprint(errw, "\n")
for k = m; k <= n; k++ {
	if k > m+m {
		break
	}
	reportPaths(k)
}
fmt.Fprintf(errw, "\nThat's all; there are no %d-configs!\n", m-1)
fmt.Fprintf(errw, "Storage requirements: %d memsize, %d deg, %d wtsize, %d maxprec.\n",
	maxmemptr, maxdeg+1, maxwtptr, 18*prec)
quit(0)

@ 해밀턴 $m$-경로의 수를 알린다. 표준 출력에 쓰기 전에 표준 오류의 버퍼를 비운다.

@<함수들@>=
func reportPaths(m int) {
	if bignumComp(&count[m], &one) >= 0 { // $0$이 아니면
		errw.Flush()
		fmt.Print("There are ")
		printBignum(os.Stdout, &count[m])
		fmt.Printf(" Hamiltonian %d-paths.\n", m)
	}
}

@* 해 보기.
나이트 판을 \.{SGB}의 |board|로 지어 마디 번호를 열 순서로 매기고 돌려 보았다. 그러면
$m=3k$일 때의 $m$-경로 수가 곧 $3\times k$ 판의 열린 나이트 투어 수다. 방향을 따지지
않으니 투어의 두 방향은 하나로 센다.

$$\vbox{\halign{#\hfil\quad&\hfil#\cr
\rm 판&\rm 열린 나이트 투어\cr
\noalign{\smallskip}
$3\times4$&8\cr
$3\times10$&3048\cr
$3\times20$&1322849752\cr
$3\times40$&88731128253706442928\cr
$6\times6$&3318960\cr
$6\times8$&24964893804\cr}}$$

$6\times6$ 판의 $3318960$은 방향까지 센 열린 나이트 투어의 수로 알려진 $6637920$의
꼭 절반이다. $6\times8$ 판은 이 판으로 $45$초 걸린다.

@* 맞춰 보기.
\.{dynaham.w}에서 한 것을 그대로 되풀이했다. 원본을 \.{ctangle}로 풀고 \.{libgb}와
함께 컴파일해 이 판과 견주었고, 사용법을 알리는 말에 든 프로그램 이름만 빼고 표준
출력, 표준 오류, 종료 부호가 바이트까지 같은지를 보았다.

\smallskip
\item{$\bullet$} 원본은 단순 그래프 $40$개에서 해밀턴 경로의 수가 파이썬으로 곧이곧대로
센 수와 모두 같았다. 겹친 변이나 제 고리가 있는 그래프에서는 \.{dynaham.w}와 똑같이
틀렸다.
\item{$\bullet$} 원본에 이 판과 같은 네 곳의 고침을 넣은 \CEE/ 판은 겹친 변과 제 고리가
있는 것까지 그래프 $105$개에서 모두 맞았고, \.{AddressSanitizer}와
\.{UndefinedBehaviorSanitizer}의 경고도 없었다.
\item{$\bullet$} 이 판은 그 고친 \CEE/ 판과 그래프 $193$개, 잘못된 명령줄 넷에서 모두
같았다. 고치기 전의 원본과는 제 고리가 없는 단순 그래프와 나이트 판 $50$개, 잘못된
명령줄 셋에서 모두 같았다.

@* 색인.
