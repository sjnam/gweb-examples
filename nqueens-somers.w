\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\title{소머즈의 N 여왕}

% 타자체 안의 세로 막대. TeX 파트에 막대를 그대로 적으면 \.{GWEB}이 코드 구간으로 읽는다.
\def\OR{\char'174}

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

% 그림들이 함께 쓰는 정의. 뒤따르는 \mplibcode 토막이 물려받도록
% \mplibcodeinherit 을 켜 둔다.
\mplibcodeinherit{enable}
\mplibcode
numeric sq; sq := 14pt;                 % 칸 한 변의 길이
% i줄(위에서부터 0) j자리(왼쪽에서부터 0)의 칸
vardef cell(expr i, j) =
  ((0,0)--(sq,0)--(sq,sq)--(0,sq)--cycle) shifted (j*sq, -(i+1)*sq)
enddef;
% 너비 n칸, 높이 r줄의 판. 칸을 번갈아 칠한다.
def board(expr n, r) =
  for i = 0 upto r-1: for j = 0 upto n-1:
    if odd(i+j): fill cell(i, j) withcolor .88white; fi
  endfor endfor
  draw (0,0)--(n*sq,0)--(n*sq,-r*sq)--(0,-r*sq)--cycle;
enddef;
def queen(expr i, j) =
  fill fullcircle scaled .62sq shifted center cell(i, j);
enddef;
def opencell(expr i, j) =
  fill cell(i, j) withcolor (1, .82, .55);
enddef;
\endmplibcode

@* 들어가며.
$N\times N$ 체스판에 여왕 $N$개를 서로 잡지 못하게 놓는 방법은 몇 가지인가?
어느 두 여왕도 같은 가로줄, 같은 세로줄, 같은 대각선에 있으면 안 된다. 보통의
$8\times8$ 판에서는 $92$가지다. 가우스가 1800년대 중반에 들여다본 문제이고,
오늘날에는 되짚어 찾기(backtracking)를 가르치는 교과서마다 나온다.

$4\times4$ 판에는 해가 둘 있다. 서로 거울상이지만 다른 해로 친다.

$$\mplibcode
beginfig(1);
  board(4, 4);
  queen(0,1); queen(1,3); queen(2,0); queen(3,2);
  picture a; a := currentpicture; currentpicture := nullpicture;
  board(4, 4);
  queen(0,2); queen(1,0); queen(2,3); queen(3,1);
  picture b; b := currentpicture; currentpicture := nullpicture;
  draw a; draw b shifted (7sq, 0);
endfig;
\endmplibcode$$
\figcap{{\sl 그림 1.} $4\times4$ 판의 두 해. 오른쪽은 왼쪽을 세로축에 비춘 것이다.}

@ 제프 소머즈(Jeff Somers)는 2002년 4월에 이 문제의 해를 {\it 세는\/} \CEE/
프로그램을 공개했다. 그는 인공지능 강좌를 들을까 하다가, 그 강좌가 쓰는 {\mc LISP}의
예제 프로그램이 $8$ 여왕의 해 {\it 하나\/}를 찾는 데 한참 걸리는 것을 보았다.
그래서 \CEE/로 해를 {\it 모두\/} 찾는 데 그보다 덜 걸리는 프로그램을 짜 보겠다고
마음먹었고, 그렇게 되었다. 그 뒤로 마이클 에이브러시(Michael Abrash)의 글에 힘입어
그 프로그램을 줄곧 다듬었다고 한다.

그렇게 다듬은 결과가 이 문서의 주제다. 그의 페이지에 따르면 이 프로그램은 당시
$23\times23$ 판의 ``세계 기록''을 세운 실뱅 피옹(Sylvain Pion)과 조엘얀
푸레(Joel-Yann Fourr\'e)의 프로그램보다 두 배쯤, 티머시 롤프(Timothy Rolfe)의
프로그램보다 열 배까지 빨랐다. 비결은 네 가지다.

\smallskip
\item{1.} 판의 한 줄을 $N$비트 정수 하나로 나타낸다.
\item{2.} 대각선의 위협을 줄마다 한 칸씩 밀어, 비트의 자리가 곧 막힌 칸이 되게 한다.
\item{3.} 놓아 볼 칸을 고를 때 가장 낮은 1비트를 연산 둘로 뽑는다.
\item{4.} 거울 대칭으로 일을 절반으로 줄이고, 재귀 대신 스택을 쓴다.
\smallskip

\noindent 나는 이 넷을 하나씩 풀어 설명하면서 그의 프로그램을 \GO/로 옮기려 한다.

@ 원본은 소머즈의 페이지
\pdfURL{``Jeff Somers's N Queens Solutions''}%
{http://users.rcn.com/liusomers/nqueen_demo/nqueens.html}에서 받는 압축 파일
\.{jmsnqueens.zip} 안의 \.{nq.c}다. 2002년 4월에 쓴 것이다. 옮긴 프로그램은 원본과
같은 말을 찍는다. 다만 판을 찍는 기능을 명령줄 선택항으로 두었다. 원본에서는
소스의 한 줄을 주석에서 풀어야 했다.

@ 프로그램의 뼈대는 이렇다. 명령줄을 읽고, 시작 시각을 찍고, 해를 세고, 걸린
시간과 해의 수를 찍는다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"time"
)

@<상수@>
@<전역 변수@>
@<함수들@>

func main() {
	var n int              // 판의 크기
	var printBoards bool   // 해를 판으로 찍을까?
	@<명령줄을 읽는다@>
	t1 := time.Now()
	@<머리말을 찍는다@>
	@<해를 센다@>
	t2 := time.Now()
	@<걸린 시간을 찍는다@>
	@<해의 수를 찍는다@>
	out.Flush()
}

@ 명령줄에는 판의 크기 $N$ 하나를 준다. 그 앞에 \.{-p}를 붙이면 해를 판으로
찍는다. 소머즈는 판을 찍는 판을 \.{nqprint}라는 실행 파일로 따로 내놓았는데,
여기서는 선택항 하나로 합쳤다.

원본은 인자가 틀리면 안내를 찍고 종료 부호 $0$으로 끝난다. 그대로 두었다. 크기를
|atoi|로 읽으므로 수가 아닌 인자는 $0$이 되어 범위 검사에 걸린다. 함수
|strconv.Atoi|도 실패하면 $0$을 돌려주니 같은 일이 일어난다.

@<명령줄을 읽는다@>=
args := os.Args[1:]
if len(args) > 0 && args[0] == "-p" {
	printBoards, args = true, args[1:]
}
if len(args) != 1 {
	@<머리말의 첫 두 줄을 찍는다@>
	fmt.Fprintf(out, "This program calculates the total number of solutions "+
		"to the N Queens problem.\n")
	fmt.Fprintf(out, "Usage: nq [-p] <width of board>\n")
	out.Flush()
	return
}
n, _ = strconv.Atoi(args[0])
if n < minBoard || n > maxBoard {
	fmt.Fprintf(out, "Width of board must be between %d and %d, inclusive.\n",
		minBoard, maxBoard)
	out.Flush()
	return
}

@ 판의 크기는 $1$부터 $32$까지 받는다. 원본은 $2$부터 받는다. $1\times1$ 판을 왜
따로 다루어야 하는지는 거울 대칭을 이야기할 때 말하겠다. 위쪽 끝은 원본에서
해의 수를 담는 정수의 폭이 정했다. 윈도에서는 $64$비트 정수로 $21$까지, 다른
곳에서는 |unsigned long|으로 $18$까지였다. 우리는 해의 수를 |uint64|에 담는다.
그러면 $N=27$의 해 $234{,}907{,}967{,}154{,}122{,}528$개까지 넉넉히 담긴다. 판의
한 줄도 |uint64| 하나에 담으니 $32$는 그저 둥근 값이다. 실제로는 시간이 먼저
바닥난다.

@<상수@>=
const (
	minBoard = 1  // 가장 작은 판
	maxBoard = 32 // 가장 큰 판
)

@ 표준 출력에는 버퍼를 단다. 판을 찍을 때는 글자 하나마다 |Fprintf|를 부르는데,
\GO/의 |os.Stdout|에는 버퍼가 없어 그때마다 시스템 호출이 일어나기 때문이다.
그래서 머리말을 찍은 뒤와 프로그램을 마칠 때 버퍼를 비운다.

@<전역 변수@>=
var out = bufio.NewWriter(os.Stdout) // 표준 출력의 버퍼

@ 머리말은 원본 그대로다. 소머즈의 이름과 연락처를 찍는다. 문자열 안의 골뱅이는
\.{GWEB}의 제어 문자라서 두 번 겹쳐 적어야 한다.

@<머리말의 첫 두 줄을 찍는다@>=
fmt.Fprintf(out, "N Queens program by Jeff Somers.\n")
fmt.Fprintf(out, "\tallagash98@@yahoo.com or jsomers@@alumni.williams.edu\n")

@ 시각은 \CEE/의 |ctime|과 같은 꼴로 찍는다. 그 꼴을 \GO/의 시각 형식으로 적으면
|ctime| 상수가 된다.

@<머리말을 찍는다@>=
@<머리말의 첫 두 줄을 찍는다@>
fmt.Fprintf(out, "Start: \t %s", t1.Format(ctime))
out.Flush()

@ @<상수@>=
const ctime = "Mon Jan _2 15:04:05 2006\n" // \CEE/의 |ctime|이 찍는 꼴

@* 판을 비트로.
되짚어 찾기의 얼개는 누구나 안다. 맨 윗줄에 여왕을 하나 놓고, 그 여왕이 차지하는
세로줄과 대각선을 적어 둔다. 다음 줄에서는 그것들을 피해 여왕을 놓고, 또 적어
둔다. 어느 줄에도 놓을 자리가 없으면 한 줄 위로 돌아가 그 줄의 여왕을 다음 빈
자리로 옮긴다. 소머즈의 프로그램도 이 얼개 그대로다. 다른 것은 ``적어 둔다''를
하는 방식이다.

한 줄에 칸이 $N$개이니, 그 줄의 칸들에 대한 예/아니오를 $N$비트 정수 하나에 담을
수 있다. 비트~$j$가 $j$번 칸이다. 이를테면 ``이 줄에서 여왕을 놓아도 되는 칸''이
$N$비트 하나가 된다. 그러면 여러 칸을 한꺼번에 따지는 일이 기계어 한두 개로
끝난다. $N$개의 1로 이루어진 |mask|는 판 안의 칸 전부를 나타낸다.

그림은 이진수를 적을 때처럼 비트 $0$을 {\it 오른쪽\/}에 그린다. 그래야 그림의 칸과
이진수의 자리가 나란히 맞는다. (판을 찍는 루틴은 거꾸로 비트 $0$을 왼쪽에 찍는다.
하지만 모든 해는 거울상도 해이니 아무래도 좋다.)

@ 이제 세 가지 위협을 적는다. 위쪽 줄들에 놓인 여왕들이 지금 줄의 어느 칸을
막는지가 궁금하다.

세로줄은 쉽다. 여왕이 $j$번 칸에 있으면 그 아래 모든 줄의 $j$번 칸이 막힌다.
그러니 지금까지 놓은 여왕들의 비트를 {\mc OR}로 모으기만 하면 된다. 이것이 |cols|다.

대각선이 이 방법의 묘미다. $r$줄 $j$번 칸의 여왕은 $r+k$줄에서 $j-k$번 칸과
$j+k$번 칸을 막는다. 아래로 한 줄 내려갈 때마다 막는 칸이 한쪽으로 한 칸씩
비껴간다. 그러니 대각선의 위협을 모은 비트열을 줄을 내려갈 때마다 {\it 한 칸씩
밀면\/} 된다. 비트 번호가 줄어드는 쪽으로 가는 위협은 오른쪽으로 밀고(|>>1|),
늘어나는 쪽으로 가는 위협은 왼쪽으로 민다(|<<1|). 그러면 어느 줄에서든 비트열의
자리가 곧 그 줄에서 막힌 칸이다. 소머즈는 앞의 것을 ``음의 대각선''(|negd|), 뒤의
것을 ``양의 대각선''(|posd|)이라 불렀다.

$$\mplibcode
beginfig(2);
  board(8, 4);
  % 여왕은 비트 5, 곧 왼쪽에서 2번 자리
  queen(0, 2);
  pickup pencircle scaled 1.2pt;
  drawarrow center cell(0,2) -- center cell(3,2) withcolor .45white;
  drawarrow center cell(0,2) -- center cell(3,5) withcolor (.1,.3,.8);
  drawarrow center cell(0,2) -- center cell(2,0) withcolor (.75,.15,.1);
  pickup defaultpen;
  numeric cx[]; cx1 := 9sq; cx2 := 13.5sq; cx3 := 18sq;
  label.rt(btex \.{cols} etex, (cx1, -.5sq));
  label.rt(btex \.{negd} etex, (cx2, -.5sq));
  label.rt(btex \.{posd} etex, (cx3, -.5sq));
  label.rt(btex \.{00100000} etex, (cx1, -1.5sq));
  label.rt(btex \.{00010000} etex, (cx2, -1.5sq));
  label.rt(btex \.{01000000} etex, (cx3, -1.5sq));
  label.rt(btex \.{00100000} etex, (cx1, -2.5sq));
  label.rt(btex \.{00001000} etex, (cx2, -2.5sq));
  label.rt(btex \.{10000000} etex, (cx3, -2.5sq));
  label.rt(btex \.{00100000} etex, (cx1, -3.5sq));
  label.rt(btex \.{00000100} etex, (cx2, -3.5sq));
  label.rt(btex \.{00000000} etex, (cx3, -3.5sq));
  label.bot(btex 비트 7 etex, center cell(3,0) - (0, .9sq));
  label.bot(btex 비트 0 etex, center cell(3,7) - (0, .9sq));
endfig;
\endmplibcode$$
\figcap{{\sl 그림 2.} 맨 윗줄 비트 $5$에 놓은 여왕이 아래 세 줄에서 막는 칸들과, 그
줄들의 세 비트열. 회색은 세로줄(|cols|), 파랑은 오른쪽으로 밀리는 대각선(|negd|),
빨강은 왼쪽으로 밀리는 대각선(|posd|)이다. 셋째 줄의 |posd|에서는 비트가 판 밖으로
밀려났다.}

@ 그림~2의 셋째 줄 |posd|를 보자. 여왕의 대각선이 판의 왼쪽 가장자리를 넘어가,
비트가 비트~$8$로 밀려났다. 그런 비트는 |mask|와 {\mc AND}하면 떨어진다. 오른쪽으로
미는 |negd|는 비트~$0$ 아래로 밀려난 것이 저절로 사라지니 따로 할 일이 없다. 그래서
지금 줄에서 여왕을 놓아도 되는 칸은 이렇다.
$$\hbox{\.{mask \&\^ (cols[r] \OR{} negd[r] \OR{} posd[r])}}$$
연산자 \.{\&\^}는 \GO/의 ``{\mc AND NOT}''이다. 이 문서의 코드에서는 |&^|로 찍힌다.
\CEE/라면 \.{mask \& \~(...)}라고 적을 것이다. 어떤 칸이든 셋 가운데 하나라도 막으면 놓을 수 없다.

@ 줄을 내려갈 때 세 비트열을 새로 만드는 일도 한 줄씩이다. 방금 놓은 여왕의
비트 |lsb|를 보태고, 대각선 둘은 한 칸씩 민다.
$$\vbox{\halign{\.{#}\hfil\cr
cols[r+1] = cols[r] \OR{} lsb\cr
negd[r+1] = (negd[r] \OR{} lsb) >> 1\cr
posd[r+1] = (posd[r] \OR{} lsb) << 1\cr}}$$
원본은 줄마다 이 셋을 배열에 따로 간수한다. 되짚어 올라갈 때 되돌리는 셈이 전혀
필요 없게 하려는 것이다. 위쪽 줄의 값이 배열에 그대로 남아 있으니 그리로 돌아가기만
하면 된다.

@* 가장 낮은 1비트.
여왕을 놓아도 되는 칸들의 비트열 |bitfield|를 얻었다. 이제 그 칸들을 하나씩 해
보아야 한다. 칸을 $0$번부터 차례로 훑을 수도 있지만, 소머즈는 1비트만 곧장 뽑아
쓴다. 비결은 이 식이다.
$$\hbox{|lsb = -bitfield & bitfield|}$$
이 식은 |bitfield|의 1비트 가운데 가장 낮은 것 하나만 남긴다.

왜 그런지는 2의 보수를 떠올리면 안다. 부호를 바꾸는 것은 모든 비트를 뒤집고
$1$을 더하는 것이다. 이를테면 $x=\.{01101000}$이면 이렇다.
$$\vbox{\halign{\hfil#\quad&\.{#}\cr
$x$&01101000\cr
$\lnot x$&10010111\cr
$-x=\lnot x+1$&10011000\cr
$-x\mathbin{\&}x$&00001000\cr}}$$
뒤집은 $\lnot x$에서는 $x$의 가장 낮은 1비트 아래가 모두 1이 된다. 거기에 $1$을
더하면 자리올림이 그 1들을 쓸어 가다가, 바로 $x$의 가장 낮은 1비트 자리에서
멈춘다. 그래서 그 위로는 $x$와 모든 비트가 반대이고, 그 자리만 $x$와 같이 1이다.
{\mc AND}를 하면 그 한 자리만 남는다.

\GO/에서는 부호 없는 정수에도 단항 |-|를 쓸 수 있다. 그 뜻이 $2^{64}$을 법으로 한
부정이라서 2의 보수와 꼭 같다. 원본은 부호 없는 |bitfield|를 굳이 부호 있는 정수로
바꾸어 부정하고, ``2의 보수 기계를 가정한다''고 적었다. \GO/에서는 그런 가정이
필요 없다.

@ 소머즈는 같은 비트를 |bitfield ^ (bitfield & (bitfield-1))|로 얻을 수도 있지만
그쪽이 느리다고 적었다. 연산이 셋이기 때문이다. 뽑은 비트는 |bitfield &^= lsb|로
끈다. 그래야 다음에 같은 칸을 다시 해 보지 않는다.

@* 되짚어 찾기를 스택으로.
재귀로 적으면 이 알고리즘은 몇 줄이다. 줄 $r$에서 할 일은 이렇다. 놓아도 되는 칸의
비트열 |bitfield|를 계산하고, 그것이 빌 때까지 가장 낮은 비트를 하나씩 뽑아
그 자리에 여왕을 놓은 채로 줄 $r+1$을 부른다. 마지막 줄에 여왕을 놓으면 해를
하나 센다.

소머즈는 재귀를 쓰지 않는다. 함수 호출은 되돌아갈 주소와 지역 변수들을 쌓고
꺼내는데, 이 알고리즘이 줄마다 기억해야 할 것은 사실 하나뿐이기 때문이다. 바로
그 줄에서 {\it 아직 해 보지 않은\/} 칸들의 비트열이다. 세 위협 비트열은 줄마다
배열에 남아 있고, 놓은 여왕은 |queen| 배열에 남아 있다. 그래서 그는 해 보지 않은
칸들의 비트열만 스택 |stack|에 쌓는다.

한 줄 내려갈 때는 지금 줄의 남은 비트열을 쌓고, 새 줄의 비트열을 계산한다. 지금
줄의 비트열이 비면 스택에서 윗줄의 남은 비트열을 꺼낸다. 스택의 바닥 |stack[0]|은
파수꾼이다. 그것을 꺼냈다는 것은 첫 줄까지 다 해 보았다는 뜻이다. 원본은 이
파수꾼에 $-1$을 넣어 두지만 그 값을 쓰는 곳은 없다. 스택 포인터가 바닥에 닿았는지를
볼 뿐이다.

@ 줄 번호 |numrows|는 사실 없어도 된다. 스택의 높이에서 알 수 있기 때문이다.
원본의 주석도 그렇게 말한다. 그래도 따로 두는 편이 읽기 쉽고, 빠르기도 하다.

@<전역 변수@>=
var numsolutions uint64 // 지금까지 센 해의 수(대칭으로 줄인 것)

@ 이제 알고리즘의 심장, 원본이 ``결정적인 반복문''이라 부른 곳이다. 가장 낮은
비트를 뽑고, 비트열이 비었으면 윗줄로 돌아가고, 아니면 그 칸에 여왕을 놓는다.
마지막 줄이 아니면 한 줄 내려가고, 마지막 줄이면 해를 하나 센다.

비트열이 비었는지 보기 {\it 전에\/} |lsb|부터 계산하는 차례에 주목하자. 비었을 때는
헛일이지만 해가 없다. 비트열이 $0$이면 |lsb|도 $0$일 뿐이다. 소머즈가 굳이 이렇게
둔 것은 계산과 판단을 겹쳐 두려는 뜻으로 보인다.

@<결정적인 반복문@>=
for {
	lsb = -bitfield & bitfield
	if bitfield == 0 {
		sp--
		bitfield = stack[sp] // 윗줄의 남은 비트열
		if sp == 0 { // 파수꾼에 닿았다
			break
		}
		numrows--
		continue
	}
	bitfield &^= lsb // 이 칸을 다시 해 보지 않도록 끈다
	queen[numrows] = lsb
	if numrows < boardMinus {
		@<한 줄 내려간다@>
		continue
	}
	@<해를 하나 찾았다@>
}

@ 한 줄 내려간다. 지금 줄의 남은 비트열을 쌓고, 새 줄의 세 위협 비트열과 놓아도
되는 칸의 비트열을 계산한다.

원본은 세 비트열을 배열에 적은 다음, 놓아도 되는 칸을 계산할 때 그 배열에서
도로 읽는다. 나도 처음에는 그대로 옮겼다. 그런데 그렇게 두면 이 판이 원본보다
$30$퍼센트쯤 느렸다. 방금 적은 값을 다시 읽는 일을 \CEE/ 컴파일러는 레지스터에서
해치우지만, \GO/ 컴파일러는 그러지 못하는 모양이다. 그래서 세 값을 지역 변수
|c|, |ng|, |ps|에 먼저 계산해 두고, 배열에는 적기만 하고, 계산은 지역 변수로 한다.
알고리즘은 한 치도 다르지 않은데 $N=16$에서 $4.26$초가 $3.66$초로 줄었다.

@<한 줄 내려간다@>=
r := numrows
numrows++
c, ng, ps := cols[r]|lsb, (negd[r]|lsb)>>1, (posd[r]|lsb)<<1
cols[numrows], negd[numrows], posd[numrows] = c, ng, ps
stack[sp] = bitfield; sp++
bitfield = mask &^ (c | ng | ps)

@ 마지막 줄에 여왕을 놓았으면 해를 하나 찾은 것이다. 여기서 소머즈는 작은 지름길을
하나 낸다. 마지막 줄의 남은 비트열을 쳐다보지도 않고 곧장 윗줄의 것을 꺼낸다.

그래도 되는 까닭이 있다. 마지막 줄에 이르렀을 때 위쪽 $N-1$개의 여왕이 세로줄
$N-1$개를 차지하고 있다. 그러니 남은 세로줄은 하나뿐이고, 마지막 줄에 놓아도 되는
칸은 많아야 하나다. 그 하나를 방금 썼으니 남은 비트열은 늘 $0$이다. 그것을
확인하려고 반복을 한 번 더 도는 대신 건너뛰는 것이다.

@<해를 하나 찾았다@>=
if printBoards {
	@<해와 그 거울상을 찍는다@>
}
numsolutions++
sp--
bitfield = stack[sp]
numrows--

@* 거울에 비추어 절반만.
판을 세로축에 비추면 해는 해로 간다. 그리고 해는 결코 자기 자신의 거울상이 될 수
없다. 첫 줄의 여왕을 보자. 그것이 가운데가 아닌 칸에 있으면 거울상에서는 반대쪽
칸에 있으니 다른 해다. 판의 너비가 홀수여서 가운데 칸에 있다면, 둘째 줄의 여왕이
가운데 칸에 있을 수 없으니(같은 세로줄이다) 거울상에서 둘째 줄이 달라진다.
그러니 해들은 서로 거울상인 짝으로 나뉜다. 짝마다 하나씩만 세고 두 배 하면 된다.

어느 쪽을 셀지는 첫 줄로 정한다.

\smallskip
\item{$\bullet$} 판의 너비가 짝수면 첫 줄의 여왕을 비트 번호가 낮은 절반에만 놓아
본다. 높은 절반에 놓인 해들은 그 거울상들이다.
\item{$\bullet$} 판의 너비가 홀수면 두 번에 나누어 센다. 첫 번째로 첫 줄의 여왕을
가운데를 뺀 낮은 절반에 놓아 본다. 두 번째로 첫 줄의 여왕을 가운데 칸에 놓고,
{\it 둘째\/} 줄의 여왕을 낮은 절반에만 놓아 본다.
\smallskip

\noindent 어느 경우든 탐색 나무의 절반 남짓만 훑는다. 홀수 판에서 가운데 칸에서
시작하는 가지는 둘째 줄에서 반으로 준다.

$$\mplibcode
beginfig(3);
  board(5, 5);
  opencell(0, 3); opencell(0, 4);
  label.bot(btex 첫 번째 탐색 etex, (2.5sq, -5.4sq));
  picture a; a := currentpicture; currentpicture := nullpicture;
  board(5, 5);
  opencell(1, 4);
  fill cell(1,3) withcolor .6white;
  queen(0, 2);
  label.bot(btex 두 번째 탐색 etex, (2.5sq, -5.4sq));
  picture b; b := currentpicture; currentpicture := nullpicture;
  draw a; draw b shifted (9sq, 0);
endfig;
\endmplibcode$$
\figcap{{\sl 그림 3.} $5\times5$ 판에서 여왕을 놓아 보는 칸(주황). 비트 $0$이
오른쪽이다. 두 번째 탐색에서 둘째 줄의 비트 $1$(짙은 회색)은 가운데 여왕의 대각선에
막히니 처음부터 열어 두지 않는다.}

@ 이 논법이 통하지 않는 판이 하나 있다. $1\times1$ 판의 유일한 해는 자기 자신의
거울상이다. 첫 줄의 여왕이 가운데 칸에 있는데, 거울상을 다르게 만들어 줄 둘째 줄이
없기 때문이다. 원본이 판의 크기를 $2$부터 받는 까닭이 이것이다. 이 판은 $1$을 곧바로
답하고, \.{-p}를 주었으면 그 판도 판 찍기 루틴과 같은 꼴로 찍는다. $2\times2$와
$3\times3$ 판에는 해가 없으니 논법이 틀릴 일도 없다.

@<해를 센다@>=
if n == 1 {
	numsolutions = 1 // 거울 논법이 통하지 않는 단 하나의 판
	if printBoards {
		fmt.Fprintf(out, "*** Solution #: 1 ***\nQ \n\n")
	}
} else {
	@<소머즈의 방법으로 절반을 세고 두 배 한다@>
}

@ 원본의 함수 |Nqueen|이 여기다. 한 곳에서만 부르니 이름 있는 절로 두었다.

배열 이름은 원본의 헝가리식 이름을 줄였다. |queen|은 |aQueenBitRes|, |cols|는
|aQueenBitCol|, |negd|는 |aQueenBitNegDiag|, |posd|는 |aQueenBitPosDiag|,
|stack|은 |aStack|이다. 스택은 파수꾼 하나와 줄마다 하나씩이면 되지만, 원본대로
두 칸을 넉넉히 둔다. 파수꾼 자리에 넣는 |^uint64(0)|은 모든 비트가 1인 수다. 여기서
|^|는 비트를 모두 뒤집는 단항 연산자인데, 이 문서의 코드에는 배타적 논리합과 같은
기호로 찍힌다.

@<소머즈의 방법으로 절반을 세고 두 배 한다@>=
var (
	queen, cols, negd, posd [maxBoard]uint64 // 줄마다
	stack   [maxBoard + 2]uint64            // 줄마다 아직 해 보지 않은 칸
	sp      int                              // 스택의 꼭대기
	numrows int                              // 지금 줄
	lsb     uint64                           // 가장 낮은 1비트
	bitfield uint64                          // 지금 줄에서 해 볼 칸
)
odd := n & 1                // 판의 너비가 홀수면 1
boardMinus := n - 1         // 마지막 줄의 번호
mask := uint64(1)<<n - 1    // 1이 $N$개
stack[0] = ^uint64(0)       // 파수꾼
for i := 0; i < 1+odd; i++ {
	if i == 0 {
		@<첫 줄의 낮은 절반을 연다@>
	} else {
		@<첫 줄 가운데에 여왕을 놓고, 둘째 줄의 낮은 절반을 연다@>
	}
	@<결정적인 반복문@>
}
numsolutions *= 2 // 거울상들을 센다

@ 첫 번째 탐색은 보통의 탐색과 같되, 첫 줄에서 비트 $0$부터 $\lfloor N/2\rfloor-1$까지만
연다. 홀수 판이면 가운데 비트 $\lfloor N/2\rfloor$는 빠진다. 이를테면 $N=5$면
|bitfield|는 \.{00011}, $N=7$이면 \.{0000111}이다.

식 |1<<half - 1|을 \CEE/의 눈으로 읽으면 안 된다. \GO/에서는 밀기가 빼기보다 먼저
묶이므로 이것은 $2^{\it half}-1$이다. \CEE/에서는 거꾸로 빼기가 먼저 묶여 같은 식이
$2^{{\it half}-1}$이 된다. 원본이 \.{(1 << half) - 1}이라고 괄호를 친 것은 그래서다.
앞 절의 |mask|도 마찬가지다.

@<첫 줄의 낮은 절반을 연다@>=
half := n >> 1
bitfield = 1<<half - 1
sp = 1
queen[0] = 0
cols[0], posd[0], negd[0] = 0, 0, 0

@ 두 번째 탐색은 홀수 판에서만 한다. 첫 줄은 가운데 칸 하나뿐이니 여왕을 거기
놓은 채로 시작한다. 둘째 줄의 세 위협 비트열은 그 여왕에서 곧바로 나온다. 첫 줄에는
해 볼 칸이 더 없으니 스택에는 $0$을 쌓는다.

둘째 줄의 비트열은 |(bitfield-1)>>1|이다. 가운데 비트 하나만 선 수에서 $1$을 빼면
그 아래 비트가 모두 1이 된다. 이를테면 $N=7$이면 \.{0001000}이 \.{0000111}이
된다. 그것을 한 칸 오른쪽으로 밀면 \.{0000011}이다. 가운데 바로 옆 칸은 어차피
대각선에 막히니, 처음부터 빼 두는 셈이다.

@<첫 줄 가운데에 여왕을 놓고, 둘째 줄의 낮은 절반을 연다@>=
bitfield = 1 << (n >> 1)
numrows = 1
queen[0] = bitfield
cols[0], posd[0], negd[0] = 0, 0, 0
cols[1] = bitfield
negd[1] = bitfield >> 1
posd[1] = bitfield << 1
sp = 1
stack[sp] = 0; sp++ // 첫 줄은 이 한 칸뿐이다
bitfield = (bitfield - 1) >> 1

@* 판 찍기.
선택항 \.{-p}를 주면 찾은 해마다 판을 찍는다. 원본의 함수 |printtable|이다. 우리는
짝마다 하나씩만 찾으니, 찾은 해와 그 거울상을 함께 찍는다. 해의 번호는 짝마다 둘씩
나아간다.

줄 |i|의 여왕 |queen[i]|는 이미 1비트 하나뿐이다. 원본은 거기서 가장 낮은 비트를
다시 뽑는데, 할 필요가 없는 일이라 뺐다. 판의 왼쪽 칸이 비트~$0$이다. 거울상은
비트 $N-1-j$를 $j$번째 칸에 찍어 얻는다.

@<해와 그 거울상을 찍는다@>=
for k := 0; k < 2; k++ {
	fmt.Fprintf(out, "*** Solution #: %d ***\n", 2*(numsolutions+1)+uint64(k)-1)
	for i := 0; i < n; i++ {
		row := queen[i]
		for j := 0; j < n; j++ {
			if k == 0 && (row>>j)&1 != 0 || k == 1 && row&(1<<(n-j-1)) != 0 {
				fmt.Fprintf(out, "Q ")
			} else {
				fmt.Fprintf(out, ". ")
			}
		}
		fmt.Fprintf(out, "\n")
	}
	fmt.Fprintf(out, "\n")
}

@* 결과 찍기.
걸린 시간은 원본처럼 초 단위로 찍는다. 원본의 |difftime|은 초 단위 시각 둘의 차이니,
두 시각의 초를 빼면 같은 값이 된다. 한 시간이나 일 분을 넘으면 시, 분, 초로도 풀어
찍는다.

@<걸린 시간을 찍는다@>=
fmt.Fprintf(out, "End: \t%s", t2.Format(ctime))
intsecs := int(t2.Unix() - t1.Unix())
fmt.Fprintf(out, "Calculations took %d second%s.\n", intsecs, plural(intsecs))
hours := intsecs / 3600
intsecs -= hours * 3600
mins := intsecs / 60
intsecs -= mins * 60
if hours > 0 || mins > 0 {
	fmt.Fprintf(out, "Equals ")
	if hours > 0 {
		fmt.Fprintf(out, "%d hour%s, ", hours, plural(hours))
	}
	if mins > 0 {
		fmt.Fprintf(out, "%d minute%s and ", mins, plural(mins))
	}
	fmt.Fprintf(out, "%d second%s.\n", intsecs, plural(intsecs))
}

@ @<해의 수를 찍는다@>=
if numsolutions != 0 {
	fmt.Fprintf(out, "For board size %d, %d solution%s found.\n",
		n, numsolutions, plural(numsolutions))
} else {
	fmt.Fprintf(out, "No solutions found.\n")
}

@ 원본은 삼항 연산자로 복수형의 \.s를 붙인다. 그 일이 다섯 곳에서 나오고, 그 가운데
넷은 |int|, 하나는 |uint64|라서 제네릭 함수 하나로 두었다.

@<함수들@>=
func plural[T int | uint64](x T) string {
	if x == 1 {
		return ""
	}
	return "s"
}

@* 얼마나 빠른가.
소머즈는 $800$\thinspace MHz 펜티엄~III에서 잰 시간을 남겼다. 나는 같은 판을 이
글을 쓰는 기계(Apple M1 Max)에서 재 보았다. 원본 \.{nq.c}를 \.{-O2}로 컴파일한 것과
이 프로그램을 나란히 두었다.

$$\vbox{\halign{\hfil$#$\quad&\hfil#\quad&\hfil#\quad&\hfil#\quad&\hfil#\cr
N&\rm 해의 수&\rm 펜티엄~III&\.{nq.c}&\rm 이 판\cr
\noalign{\smallskip}
14&365596&0:00:01&0.080&0.090\cr
15&2279184&0:00:04&0.485&0.539\cr
16&14772512&0:00:23&3.211&3.576\cr
17&95815104&0:02:38&22.59&25.04\cr
18&666090624&0:19:26&170.3&185.7\cr}}$$
\noindent 펜티엄~III의 시간은 소머즈의 표에서 옮긴 것이고(시:분:초), 뒤의 둘은 초다.
$N$이 하나 늘 때마다 시간이 일곱 배 남짓 는다. 스무 해 남짓 뒤의 이 기계에서 원본은
그때보다 일곱 배쯤 빠르다. 이 판은 원본보다 $10$퍼센트쯤 느린데, 앞에서 말한 대로
방금 적은 값을 도로 읽지 않게 고치기 전에는 $30$퍼센트쯤 느렸다.

@ 스택이 정말 재귀보다 빠른지도 궁금했다. 그래서 같은 알고리즘을 재귀 함수로 짜서
견주었다. 줄마다 세 위협 비트열을 인자로 넘기고, 놓아도 되는 칸을 가장 낮은
비트부터 하나씩 해 보는 흔한 모양이다. 거울 대칭도 똑같이 썼다.

$$\vbox{\halign{\hfil$#$\quad&\hfil#\quad&\hfil#\quad&\hfil#\cr
N&\rm 원본 그대로 옮긴 판&\rm 이 판(스택)&\rm 재귀판\cr
\noalign{\smallskip}
16&4.155&3.576&3.459\cr
17&29.29&25.04&24.45\cr
18&219.2&185.7&179.8\cr}}$$
\noindent 재귀판이 조금 빠르다. 처음에 원본을 그대로 옮긴 판과 견주었을 때는 차이가
$20$퍼센트나 되어 놀랐다. 먼저 \GO/가 배열을 짚을 때마다 넣는 경계 검사를 의심했지만,
검사를 끄고 컴파일해도(\.{-gcflags=-B}) 시간이 그대로였다. 범인은 앞에서 고친 곳, 곧
방금 배열에 적은 세 값을 도로 읽는 일이었다. 그것을 고치자 차이가 $3$퍼센트쯤으로
줄었다. 지금의 비트열을 지역 변수에 두고 내려갈 때만 네 값을 한꺼번에 쌓는 변형도
짜 보았는데, 그것도 재귀판과 비슷했다.

남은 차이는 거의 비긴 셈이다. 나는 이렇게 짐작한다. 소머즈가 이 프로그램을 다듬던
2002년의 32비트 x86은 범용 레지스터가 여덟 개뿐이었고, 인자를 메모리 스택으로 넘겼고,
호출마다 프레임을 세웠다 허물었다. 줄마다 기억할 값이 하나뿐인 알고리즘에 그것은 큰
낭비였으니 스택은 옳은 선택이었다. 지금은 사정이 다르다. \GO/는 인자를 레지스터로
넘기고, 이 기계에는 범용 레지스터가 서른 개 남짓 있고, 되돌아갈 주소는 프로세서가
거의 틀림없이 미리 짐작한다. 반대로 명시적 스택판도 줄마다 배열 넷과 스택에 값을
적으니, 메모리를 오가는 양은 재귀판이 호출 프레임에 흘리는 양과 크게 다르지 않다.
스무 해 전 기계의 비싼 호출을 피하려던 기법이, 호출이 싸진 지금은 본전치기가 된
것이다. 그래도 나는 소머즈의 스택을 그대로 두었다. 이 글이 설명하려는 것이 그의
기법이기 때문이다.

@* 옮기며 바꾼 것.
알고리즘은 한 군데도 바꾸지 않았다. 바꾼 것은 가장자리뿐이다.

\smallskip
\item{$\bullet$} 해의 수와 비트열을 |uint64|에 담아 판의 크기를 $32$까지 받는다.
원본은 윈도에서 $21$, 다른 곳에서 $18$까지였다.
\item{$\bullet$} $1\times1$ 판을 받고 $1$을 답한다. 원본은 거울 논법이 이 판에서
깨지므로 받지 않았다.
\item{$\bullet$} 판을 찍는 기능을 선택항 \.{-p}로 두었다. 원본은 소스의 주석을 풀어
다시 컴파일해야 했다.
\item{$\bullet$} 원본은 윈도가 아닌 곳에서 |unsigned long|인 해의 수를 \.{\%d}로
찍는다. 형식과 인자의 폭이 맞지 않는 것이다. 해의 수가 $2^{31}$보다 작은 $18$까지만
받으니 드러나지 않았을 뿐이다. \GO/의 \.{\%d}는 인자의 형을 보고 찍으므로 그런
어긋남이 없다.
\smallskip

@* 맞춰 보기.
원본 \.{nq.c}를 \.{-O2}로 컴파일해 기준으로 삼았다.

\smallskip
\item{$\bullet$} 해의 수. $N=1$부터 $18$까지 이 판이 낸 수가 온라인 정수열
사전(OEIS)의 A000170, 곧 소머즈의 표와 모두 같다. $N=2$부터 $18$까지는 원본이 낸
수와도 같다.
\item{$\bullet$} 판 찍기. $N=1$부터 $10$까지 \.{-p}로 찍은 판을 모두 읽어 들여, 모든
순열을 훑는 무차별 풀이의 해 집합과 견주었다. 빠진 것도, 겹친 것도, 틀린 것도
없고, 번호도 $1$부터 빈틈없이 이어진다.
\item{$\bullet$} 원본의 |printtable| 호출을 주석에서 풀어 컴파일한 것과, $N=2$부터
$10$까지 출력이 바이트까지 같다. 다른 것은 시각을 찍은 두 줄뿐이다.
\item{$\bullet$} 인자가 없을 때, 범위 밖일 때, 수가 아닐 때의 안내 문장도 원본과
같다. 사용법 줄에 \.{[-p]}가 붙고, 받는 범위의 두 수가 다를 뿐이다.
\smallskip

@* 색인.
