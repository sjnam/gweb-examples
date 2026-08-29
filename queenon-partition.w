\input kotexgweb
\input luamplib.sty

% 그림 둘(fig_cells, fig_map)은 queenon-partition.mp 안에 있다.
\everymplib{input queenon-partition;}

\def\title{심킨의 쪼개기}
\font\logo=logo10
\def\MP{{\logo METAPOST}}
\datethis

\def\dts{\mathinner{\ldotp\ldotp}}
\def\half{{1\over2}}

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

@* 들어가며.
Michael Simkin이 $n\times n$ 정사각 격자에서 $2N\times 2N$ 정사각 격자로 가는
야릇한 대응 하나를 정의했다. 뒤쪽 격자는 너비 $2N$의 마름모 꼴로 잘라낸 다음
$45^\circ$ 돌린 것이다. 그는 $n\ge N^2$일 때 이 대응을 쓴다.

@ Simkin이 그것을 어디에 썼는가 하면, 오랫동안 열려 있던 $n$-퀸 문제의 세는
문제에 썼다. 서로 잡지 않게 퀸 $n$개를 $n\times n$ 판에 놓는 방법의 수 $Q(n)$이
$$Q(n)=\bigl((1+o(1))\,n\,e^{-\alpha}\bigr)^n,\qquad \alpha\approx1.94$$
임을 그가 2021년에 밝혔다. 그 증명은 판을 여기서 볼 쪼개기로 나누어 다룬다.
크누스가 그 쪼개기를 눈으로 보려고 지은 프로그램이 \.{QUEENON-PARTITION}이고,
이 글은 그것을 \.{GWEB}으로 옮긴 것이다.

@ $1\le i,j\le n$일 때 $n\times n$ 격자의 칸 $(ij)$를 열린 집합
$$(ij)=\{(x,y)\mid i-1<nx<i,\ j-1<ny<j\}$$
으로 둔다. (모든 것을 단위 정사각형 $[0\dts1]\times[0\dts1]$에 들어가도록
줄여 놓았다.)

$1\le I,J\le 2N$일 때 잘라 돌린 $2N\times2N$ 격자의 칸 $[IJ]$는 닫힌 집합
$$[IJ]=\{(x,y)\mid 0\le x,y\le 1,\ I-1\le N(x+y)\le I,\
                                   J-1\le N(1+y-x)\le J\}$$
이다. (Simkin의 식을 조금 옮겨 놓은 것인데, 프로그램으로 짜기에는 이편이 더
편하다.) 이를테면 $N=4$일 때의 칸들은 이렇다.
$$\mplibcode fig_cells; \endmplibcode$$
\figcap{$N=4$일 때의 칸 $[IJ]$. 이름표는 $I$와 $J$를 나란히 적은 것이다.}

@ 눈여겨볼 것은 칸 $[IJ]$가 넓이 $1/(2N^2)$인 마름모이거나, 넓이 $1/(4N^2)$인
직각이등변삼각형이거나, 빈 것이라는 점이다. $I\le N$일 때 비지 않은 칸은
$J=N+1-I$(위를 가리키는 삼각형), $N+1-I<J<N+I$(마름모), $J=N+I$(오른쪽을
가리키는 삼각형)에서 나온다. $I>N$일 때는 $J=I-N$(왼쪽을 가리키는 삼각형),
$I-N<J<3N+1-I$(마름모), $J=3N+1-I$(아래를 가리키는 삼각형)에서 나온다.
그러니 마름모는 $0+2+\cdots+(2N-2)+(2N-2)+\cdots+2+0=2N^2-2N$개이고 삼각형은
$4N$개다. $I$가 같거나 $J$가 같은 칸들은 한 대각선 위에 놓인다. 칸 $[IJ]$의
중심점은 $z_{IJ}=(I-J+N,\,I+J-N-1)/(2N)$이다.

@ 대응 $(ij)\mapsto[IJ]$의 규칙은 이렇다. $(ij)\cap[IJ]$의 넓이가 양수가 되는
가장 작은 $I$를 찾는다. 그런 $[IJ]$가 같은 $I$로 둘이라면 $J$가 {\it 큰\/}
쪽을 고른다. 그쪽이 다른 쪽의 북서쪽에 놓인다. 이를테면 $N=4$, $n=17$일 때의
대응은 이렇다.
$$\mplibcode fig_map; \endmplibcode$$
\figcap{$N=4$, $n=17$일 때의 대응 $(ij)\mapsto[IJ]$. 칸 $(ij)$의 색은 $I$와 $J$의
홀짝으로 정한다. 둘 다 짝수면 흰색, $J$만 홀수면 빨강, $I$만 홀수면 초록,
둘 다 홀수면 파랑이다. 같은 색 덩어리 하나가 칸 $[IJ]$ 하나로 간다.}

@ 셈을 쉽게 하려고 사실상 $nN\times nN$ 격자를 짓는다. 그 화소 하나하나는
($nN$으로 줄여 단위 정사각형에 맞추면) 어느 한 $(ij)$에 속한다. 그리고 화소는
저마다 어느 한 $[IJ]$에 통째로 속하거나, $[IJ]$와 $[I(J+1)]$ 사이의 대각선으로
갈리거나, $[IJ]$와 $[(I+1)J]$ 사이의 대각선으로 갈리거나, 두 대각선 모두로 갈려
$[IJ]$, $[(I+1)J]$, $[I(J+1)]$, $[(I+1)(J+1)]$ 넷에 걸친다.

@ 이 프로그램은 그 배정을 그림으로 그리는 \MP\ 파일을 뱉는다. 위의 둘째 그림이
바로 그렇게 나온 것이다.

이 저장소의 \.{queenon-partition.mp}에 그림 둘이 |fig_cells|와 |fig_map|이라는
이름으로 들어 있다. luamplib이 조판하는 동안 직접 그리므로 |mpost|를 따로 부를
까닭이 없다. 둘째 그림의 |row| 줄들은 이 프로그램에 $N=4$, $n=17$을 주어 뱉은 것을
그대로 옮겨 놓은 것이다.

@ 뼈대는 짧다. 명령줄을 읽고, 대응을 셈하고, 두 가지로 알리고, \MP\ 파일을 쓴다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

@<상수@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<명령줄을 처리한다@>@;
	@<대응을 셈한다@>@;
	@<대응을 알린다@>@;
	@<여럿이 하나로 몰린 크기를 알린다@>@;
	@<\MP\ 파일을 뱉는다@>@;
	out.Flush()
}

@ 알릴 것이 $n\times n$개나 되니 표준 출력을 버퍼에 담아 둔다. $n=512$면 숫자를
$262144$번 찍는데, 그때마다 시스템 부름을 하나씩 하면 견딜 수 없다.

@<전역 변수@>=
var out = bufio.NewWriter(os.Stdout)

@ 그만둘 때는 언제나 버퍼를 먼저 비운다. 그러지 않으면 이미 찍은 것이 사라진다.

@<함수들@>=
func die(code int, format string, a ...any) {
	out.Flush()
	fmt.Fprintf(os.Stderr, format, a...)
	os.Exit(code)
}

@* 명령줄.
$N$과 $n$을 그 차례로 명령줄에 적어 준다.

@<상수@>=
const (
	maxN = 16
	maxn = 512
)

@ @<전역 변수@>=
var (
	N, n    int // 명령줄 인자
	nn, Nnn int // $n+n$과 $N\cdot nn$
)

@ 원본은 종료 부호로 $-1$과 $-2$를 쓰지만 \GO/에서는 $0$과 $125$ 사이를 권한다.
그래서 $1$과 $2$를 쓴다.

@<명령줄을 처리한다@>=
bad := len(os.Args) != 3
if !bad {
	var e1, e2 error
	N, e1 = strconv.Atoi(os.Args[1])
	n, e2 = strconv.Atoi(os.Args[2])
	bad = e1 != nil || e2 != nil
}
if bad {
	die(1, "쓰는 법: %s N n\n", os.Args[0])
}
if N < 1 || N > maxN {
	die(2, "다시 컴파일하라. 지금은 N이 1과 %d 사이여야 한다!\n", maxN)
}
if n < 1 || n > maxn {
	die(2, "다시 컴파일하라. 지금은 n이 1과 %d 사이여야 한다!\n", maxn)
}
if n < N*N {
	fmt.Fprintln(os.Stderr, "조심하라: n이 N^2보다 작다!")
}
nn = n + n
Nnn = N * nn

@* 대응 셈하기.
배열 |ass|가 대응을 담는다. $(ij)\mapsto[IJ]$이면 |ass[i-1][j-1]|에
|I<<16 - J|를 담는다. 이렇게 담아 두면 값이 작은 쪽이 곧 $I$가 작은 쪽이고,
$I$가 같으면 $J$가 큰 쪽이다. 앞 절의 규칙이 바라던 바로 그 순서다.

@<전역 변수@>=
var ass [maxn][maxn]int

@ 함수 |IJset(x,xd,y,yd,i,j)|는 단위 정사각형의 점 $(x+|xd|/2,\,y+|yd|/2)/(nN)$에
맞선 좌표 $I$와 $J$를 알아내어 |ass[i][j]|에 담는다. 이미 더 작은 값이 들어 있으면
그대로 둔다.

@<함수들@>=
func IJset(x, xd, y, yd, i, j int) {
	I := (x + x + xd + y + y + yd + nn) / nn
	J := (Nnn + y + y + yd - x - x - xd + nn) / nn
	acc := I<<16 - J
	if acc < ass[i][j] {
		ass[i][j] = acc
	}
}

@ 이것은 {\mc 무식한 힘}이다.

@<대응을 셈한다@>=
for i := range n {
	for j := range n {
		ass[i][j] = N << 17 // $\infty$
	}
}
for x := range n * N {
	for y := range n * N {
		i, j := x/N, y/N // $nN\times nN$ 격자의 화소를 하나씩 본다
		IJset(x, 0, y, 1, i, j) // $(x,y+\half)$의 칸
		IJset(x, 2, y, 1, i, j) // $(x+1,y+\half)$의 칸
		IJset(x, 1, y, 0, i, j) // $(x+\half,y)$의 칸
		IJset(x, 1, y, 2, i, j) // $(x+\half,y+1)$의 칸
	}
}

@* 알리기.
담아 둔 값에서 $I$와 $J$를 도로 꺼내는 일은 여기저기서 쓰인다. 원본은 매크로다.

@<함수들@>=
func Ipart(a int) int { return a>>16 + 1 }

func Jpart(a int) int { return -a & 0xffff }

@ 마디 번호를 글자 하나로 줄여 적는다. $62$개까지만 되고 그보다 크면 \.?다.

@<함수들@>=
func encode(t int) byte {
	switch {
	case t < 10:
		return byte('0' + t)
	case t < 36:
		return byte('a' + t - 10)
	case t < 62:
		return byte('A' + t - 36)
	}
	return '?'
}

@ 배정은 맨 윗줄($j=n$)부터 준다. 행렬 좌표가 아니라 데카르트 좌표를 흉내내려는
것이다.

@<대응을 알린다@>=
for j := n - 1; j >= 0; j-- {
	for i := range n {
		fmt.Fprintf(out, " %c%c",
			encode(Ipart(ass[i][j])), encode(Jpart(ass[i][j])))
	}
	fmt.Fprintln(out)
}

@ 칸 $[IJ]$ 하나에 칸 $(ij)$가 몇 개나 몰리는지도 알린다.

@<전역 변수@>=
var IJcount [2 * maxN][2 * maxN]int

@ @<여럿이 하나로 몰린 크기를 알린다@>=
for i := range n {
	for j := range n {
		k := ass[i][j]
		IJcount[Ipart(k)-1][Jpart(k)-1]++
	}
}
for j := N + N - 1; j >= 0; j-- {
	for i := 0; i < N+N; i++ {
		fmt.Fprintf(out, "%4d", IJcount[i][j])
	}
	fmt.Fprintln(out)
}

@* \MP\ 파일 뱉기.
마지막으로 배정을 그림으로 그리는 \MP\ 파일을 쓴다. 이름에 $N$과 $n$을 박아
넣으므로 여러 번 돌려도 서로 덮어쓰지 않는다.

@<\MP\ 파일을 뱉는다@>=
name := fmt.Sprintf("/tmp/queenon-partition-%d-%d.mp", N, n)
f, err := os.Create(name)
if err != nil {
	die(5, "쓰려고 열 수 없는 파일이 있다: `%s'!\n", name)
}
mp := bufio.NewWriter(f)
fmt.Fprintf(mp, "%% produced by %s %d %d\n", os.Args[0], N, n)
fmt.Fprintf(mp, "N=%d; n=%d;\n", N, n)
mp.WriteString(mpUnits)
mp.WriteString(mpColors)
mp.WriteString(mpRowDef)
@<줄마다 색 부호를 뱉는다@>@;
mp.WriteString(mpTail)
if mp.Flush() != nil || f.Close() != nil {
	die(5, "쓰다가 탈이 난 파일이 있다: `%s'!\n", name)
}
fmt.Fprintf(os.Stderr, "좋다, %s 파일 `%s'를 썼다.\n", "METAPOST", name)

@ 원본은 \MP\ 코드를 |fprintf| 스무남은 줄로 한 줄씩 뱉는다. \GO/에는 여러 줄
문자열이 있으니 \MP\ 코드를 \MP\ 코드답게 그대로 적어 둘 수 있다. 셋으로 나누어
저마다 무엇을 하는지 말해 두겠다.

먼저 단위다. 판 하나의 너비를 $N$센티미터로 잡고, 칸 하나의 너비 |h|를 그것을
$n$으로 나눈 값으로 둔다. 그리고 |x!y|를 격자 좌표에서 실제 좌표로 옮기는
연산자로 정의한다.

@<상수@>=
const mpUnits = `numeric h,u; u=1cm; n*h=N*u;
primarydef x!y = (x*u,y*u) enddef;

`

@ 다음은 색이다. 칸 하나를 칠한 그림 넷을 미리 만들어 |pic[]|에 담아 둔다.
글자 \.W는 빈 그림, \.R은 빨강, \.B는 파랑, \.G는 초록이다. 그림을 미리 만들어
두면 나중에 칸마다 도형을 새로 그리지 않고 그림을 옮겨 찍기만 하면 된다.

@<상수@>=
const mpColors = `string ch;
picture pic[];
pic[ASCII "W"]=nullpicture;
currentpicture:=nullpicture;
fill (0,0)--(h,0)--(h,h)--(0,h)--cycle withcolor red;
pic[ASCII "R"]=currentpicture;
fill (0,0)--(h,0)--(h,h)--(0,h)--cycle withcolor blue;
pic[ASCII "B"]=currentpicture;
fill (0,0)--(h,0)--(h,h)--(0,h)--cycle withcolor green;
pic[ASCII "G"]=currentpicture;
currentpicture:=nullpicture;

`

@ 셋째는 |row| 매크로다. 글자 하나가 칸 하나이므로, 문자열 하나가 판의 한 줄을
그린다. 부를 때마다 |ny|가 하나씩 올라가니 줄 번호를 셀 필요도 없다.

@<상수@>=
const mpRowDef = `newinternal ny;
def row expr s =
  ny:=ny+1;
  for j=0 upto length s-1:
    ch:=substring(j,j+1) of s;
    draw pic[ASCII ch] shifted (j*h,ny*h);
  endfor
enddef;

beginfig(0)
ny:=-1;
`

@ 칸의 색은 $I$와 $J$의 홀짝으로 정한다. 원본은 |switch| 넷으로 갈라 놓았지만,
$2(I\bmod2)+(J\bmod2)$가 곧 $0$, $1$, $2$, $3$이니 글자 넷을 담은 문자열
\.{"WRGB"}에서 그 자리를 뽑으면 그만이다.

@<줄마다 색 부호를 뱉는다@>=
for j := n - 1; j >= 0; j-- {
	mp.WriteString("row \"")
	for i := range n {
		k := ass[i][j]
		mp.WriteByte("WRGB"[2*(Ipart(k)&1)+(Jpart(k)&1)])
	}
	mp.WriteString("\"\n")
}

@ 마지막으로 격자와 대각선을 얹고 그림을 닫는다. 이 대각선들이 잘라 돌린
$2N\times2N$ 눈금이고, 같은 색 덩어리 하나가 그 눈금의 칸 하나에 맞선다.

@<상수@>=
const mpTail = `for i=0 upto n: draw (0,i*h)--(n*h,i*h); draw (i*h,0)--(i*h,n*h); endfor
for i=0 upto N-1:
  draw 0!i--(N-i)!N;
  draw i!0--N!(N-i);
  draw 0!(N-i)--(N-i)!0;
  draw i!N--N!i;
endfor
endfig;
bye.
`

@* 맞춰 보기.
크누스의 \CEE/ 원본을 함께 세워 놓고 견주었다. $N$을 $1$에서 $8$까지, $n$을
$1$에서 $80$까지 모두 짝지은 $640$가지에 $N=16$, $n=512$ 같은 큰 것 아홉을
더해 $649$번 돌렸다. 표준 출력도, 뱉어 놓은 \MP\ 파일도, 종료 부호도, 표준
오류에 나오는 파일 이름도 다르지 않았다. 이 글의 둘째 그림에 박아 놓은
|row| 줄들도 원본이 $N=4$, $n=17$에서 뱉는 것과 똑같다.

@ 원본과 다른 곳은 셋인데 모두 언어에서 온 것이다. 종료 부호를 양수로 바꾸었고,
표준 출력을 버퍼에 담았고(원본의 \CEE/ 표준 출력은 저절로 그리 된다), \MP\
코드를 |fprintf| 스무남은 줄 대신 여러 줄 문자열 넷으로 적었다.

@* 색인.
