\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

\def\title{무한 여왕}

@* 들어가며.
무한 체스판의 $\infty$-여왕 문제에서, 해 가운데 사전순으로 가장 작은 것은 무엇일까? 곧 수열 $q_1$,
$q_2$, \dots를 생각하자. 여기서 $q_n$은 다음 세 집합 어디에도 들지 않는 가장 작은
양의 정수다.
$$\{q_k\mid 1\le k<n\},\qquad
\{q_k+k-n\mid 1\le k<n\},\qquad
\{q_k-k+n\mid 1\le k<n\}.$$
오른쪽과 아래쪽으로 끝없는 체스판의 $n$번째 가로줄에 여왕을 하나씩, 앞의 여왕들에게
잡히지 않는 가장 왼쪽 칸에 놓아 가는 셈이다. 이 수열은 1, 3, 5, 2, 4, 9, 11, 13,
15, 6, 8, 19, \dots로 시작하고, OEIS의 A065188이다.

$$\mplibcode
beginfig(1);
  u := 5mm;
  numeric qq[];
  qq1 = 1; qq2 = 3; qq3 = 5; qq4 = 2; qq5 = 4;
  qq6 = 9; qq7 = 11; qq8 = 13; qq9 = 15; qq10 = 6;
  for x = 1 upto 16: for y = 1 upto 10:
    draw unitsquare scaled u shifted ((x-1)*u, -y*u)
      withpen pencircle scaled .3pt withcolor .6white;
  endfor endfor
  for y = 1 upto 10:
    fill fullcircle scaled .55u shifted ((qq[y]-.5)*u, (.5-y)*u);
  endfor
  label.lft(btex \sevenrm 1 etex, (0, -.5u));
  label.lft(btex \sevenrm 5 etex, (0, -4.5u));
  label.lft(btex \sevenrm 10 etex, (0, -9.5u));
  label.top(btex \sevenrm 1 etex, (.5u, 0));
  label.top(btex \sevenrm 5 etex, (4.5u, 0));
  label.top(btex \sevenrm 10 etex, (9.5u, 0));
  label.top(btex \sevenrm 15 etex, (14.5u, 0));
  label.lft(btex $n$ etex, (-3mm, -5u));
  label.top(btex $q_n$ etex, (8u, 3mm));
endfig;
\endmplibcode$$
\figcap{처음 열 여왕. 가로줄 $n$의 여왕은 칸 $q_n$에 놓인다. 판은 오른쪽과 아래쪽으로
끝없이 이어진다.}

@ 크누스는 식 7.2.2--(6)에서 착상을 얻어 비트 벡터 셋 $a$, $b$, $c$를 두었다.
앞에서 구한 값들에 대해 $q_k$, $q_k+k$, $q_k-k$가 나왔는지를 적어 두는 것이다.
이를테면 $q_n$을 구하고 있을 때, $k<n$인 어떤 $k$에 대해 $q_k-k=r$이면 그리고
그때에만 $c_r=1$이다. 그러면 $q_n$은 $a_k=0$이고 $b_{k+n}=0$이고 $c_{k-n}=0$인 가장
작은 $k>0$이다.

알고 보니 이 수열에는 아름다운 구조가 가득하고, 그 덕에 계산이 아주 쉬워진다.
Neil Sloane이 2016년에 추측했고, 곧이어 그와 Jeffrey Shallit이 증명했다. 황금비를
$\phi$라 하자. 그러면 $a$의 첨자는 $0$부터 대략 $\phi n$까지, $b$의 첨자는 $0$부터
대략 $\phi^2n$까지, $c$의 첨자는 대략 $-\phi^{-2}n$부터 대략 $\phi^{-1}n$까지
걸친다. 특히 $c$에는 1인 비트가 $n$개 있고 $\phi^{-1}n+\phi^{-2}n=n$이니, $c$의
비트는 거의 모두 1이다. 게다가 $a$는 길이가 대략 $\phi^{-1}n$인 1의 줄로 시작한다.
그러니 $q_n$을 구할 때 살펴볼 비트는 몇 개로 한정된다.

멋지지 않은가?

이 구현은 비트 하나에 바이트 하나를 쓴다. 비트를 빽빽이 채우면 물론 $n$을 여덟 배
크게 할 수 있다.

또 하나의 특징은 $q_n$과 $\phi n$ 또는 $\phi^{-1}n$ 사이의 어긋남을 {\it 정확히\/}
계산하는 것이다. 이를테면 이 프로그램은 $q_{F_{40}}=F_{41}=\phi F_{40}+\phi^{-40}$임을
``안다''.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{infty-queens.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/infty-queens.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Fri, 03 Nov 2017 13:42:05 GMT}다. 프로그램이 찍는 말과 종료 부호는 원본 그대로
두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

원본의 첫 문단은 수열을 $q_0$부터 세고 $q_n$을 ``가장 작은 음 아닌 정수''라 한다.
그런데 그렇게 정의하면 $q_0=0$, $q_1=2$, $q_2=4$, \dots가 되어, 프로그램이 찍는
수열에서 첨자와 값을 하나씩 뺀 것이 된다. 프로그램과 원본의 나머지 설명, 곧 ``가장
작은 $k>0$''과 $q_{F_{40}}=F_{41}$은 $q_1$부터 세는 양의 정수를 따른다. 이를테면
프로그램은 $q_{55}=89$를 찍는데, $55=F_{10}$이고 $89=F_{11}$이다. 그래서 이 판은 첫
문단을 $q_1$부터 세도록 고쳤다.

@ 뼈대는 이렇다. 명령줄에서 받은 $n$까지 $q_n$을 구해 한 줄에 하나씩 찍는다. 곁들여
모은 통계는 표준 오류로 찍는다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
)

@<상수@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	var j int
	var k, n, q, r, s, t, nphiint int64
	var nphifrac uint64
	@<명령줄을 처리한다@>@;
	@<배열을 잡는다@>@;
	r, t, s = 0, 0, 1
	for n, nphiint, nphifrac = 1, 1, 1; n <= goal; n++ {
		@<$q=q_n$을 정한다. 메모리가 모자라면 |goto done|@>@;
		fmt.Fprintf(out, "%d\n", q)
		@<$q$에 관한 통계를 적는다@>@;
		@<|nphiint|와 |nphifrac|을 한 걸음 나아가게 한다@>@;
	}
done:
	@<마지막 통계를 찍는다@>@;
	out.Flush()
	errw.Flush()
}

@ 원본의 상수들이다. 변수 |ticks|는 한 판에 메모리를 몇 번 참조했는지를 센다. 크누스는
한 판에 많아야 |tickmax|번이면 되기를 바랐다.

@<상수@>=
const (
	slack       = 10                    // 메모리를 잡을 때의 어림
	phi         = 1.6180339887498948482 // 황금비
	tickmax     = 25                    // 한 판에 바라는 |ticks|의 상한
	deltamax    = 10
	pausethresh = 999999995
)

@ @<전역 변수@>=
var (
	goal    int64 // 명령줄 인자
	a, b, c []byte
	maxmema, maxmemb, minmemc, maxmemc int64
	ticks    int
	tickhist [tickmax + 1]int // 실행 시간의 도수 분포
	deltalominint, deltalomaxint, deltahiminint, deltahimaxint     int
	deltalominfrac, deltalomaxfrac, deltahiminfrac, deltahimaxfrac uint64
	deltalomin, deltalomax, deltahimin, deltahimax [deltamax + 1]int
	out  = bufio.NewWriter(os.Stdout) // 표준 출력의 버퍼
	errw = bufio.NewWriter(os.Stderr) // 표준 오류의 버퍼
)

@ 인자는 \CEE/의 |sscanf|처럼 읽는다. 앞의 빈칸과 부호를 받고, 수 뒤에 붙은 글자는
버린다. 그래서 `\.{12abc}'는 $12$다. 크기는 원본의 \.{int}처럼 $32$비트로 한정한다.

원본은 음수 $n$을 걸러 내지 않는다. 그러면 배열 크기가 음수가 될 수 있는데, $-4$까지는
크기가 음수가 되지 않아 ``$0$개를 계산했다''로 끝나고, $-5$부터는 음수 크기를
|calloc|에 넘겨 배열을 잡지 못했다며 멈춘다. 어느 쪽이든 우연이다. 이 판은 음수를
사용법 오류로 거절한다.

@<명령줄을 처리한다@>=
ok := len(os.Args) == 2
if ok {
	var g32 int32
	_, err := fmt.Sscanf(os.Args[1], "%d", &g32)
	goal = int64(g32)
	ok = err == nil && goal >= 0
}
if !ok {
	fmt.Fprintf(os.Stderr, "Usage: %s n\n", os.Args[0])
	os.Exit(-1)
}

@ 배열 $c$의 첨자는 음수까지 걸치므로 |minmemc|만큼 밀어서 담는다.

원본은 |maxmema|를 |(int)(phi*goal)+slack|으로 \.{int}에서 셈한다. 그래서 $n$이
대략 $13$억 $2700$만을 넘으면 넘치고(정의되지 않은 동작이다), 실제로는 배열 $a$를
잡지 못했다며 멈췄다. 이 판은 $64$비트로 셈한다. \.{Go}의 |make|는 실패하면 |nil|을
돌려주지 않고 프로그램을 끝내므로, 원본의 ``\.{Can't allocate}'' 말들은 옮기지
않았다.

@<배열을 잡는다@>=
maxmema = int64(phi*float64(goal)) + slack
maxmemb = maxmema + goal
maxmemc = maxmema - goal
minmemc = goal - maxmemc + 2*slack
a = make([]byte, maxmema)
b = make([]byte, maxmemb)
c = make([]byte, minmemc+maxmemc)

@* 수열 계산.
이 알고리즘에서 $s$는 $a_s=0$인 가장 작은 양의 정수다. 그리고 $t$는 $t=0$이거나 $c_t=1$인
가장 큰 정수다. 끝으로 $r$은 $c_{-r}=0$인 $t$ 이하의 가장 큰 음 아닌 정수다.

후보 $k$를 $s$부터 $n-r$까지 훑는다. 세 벡터가 모두 비어 있는 첫 $k$가 $q_n$이다.
그런 $k$가 없으면 새 대각선 $t+1$을 연다. 원본처럼 |goto|로 짰다. \.{Go}의 |goto|도
바깥 블록의 뒤쪽 이름표로 뛰는 것은 허락한다.

@<$q=q_n$을 정한다...@>=
ticks = 0
for k = s; k <= n-r; k++ {
	if k+n >= maxmemb {
		goto done
	}
	ticks++
	if b[k+n] == 0 {
		if k-n+minmemc < 0 {
			goto done
		}
		ticks++
		if c[k-n+minmemc] == 0 {
			ticks++
			if a[k] == 0 {
				@<$k$를 $q_n$으로 삼는다@>@;
				goto gotQ
			}
		}
	}
}
@<새 대각선을 열어 $q_n=n+t$로 삼는다@>@;
gotQ:

@ 칸 $k$를 차지했으면 세 벡터에 적는다. 그 칸이 $s$였다면 $s$를 다음 빈 칸으로
옮기고, 대각선 $k-n$이 $-r$이었다면 $r$을 다음 빈 대각선으로 옮긴다.

@<$k$를 $q_n$으로 삼는다@>=
q = k
ticks++
a[k] = 1
if k == s {
	for s = k + 1; ; s++ {
		ticks++
		if a[s] != 1 {
			break
		}
	}
}
ticks++
b[k+n] = 1
ticks++
c[k-n+minmemc] = 1
if k-n == -r {
	for r = n - k + 1; ; r++ {
		if r > minmemc {
			goto done
		}
		ticks++
		if c[minmemc-r] == 0 {
			break
		}
	}
}

@ @<새 대각선을 열어...@>=
t++
if t >= maxmemc {
	goto done
}
ticks++
c[t+minmemc] = 1
q = n + t
if q >= maxmema {
	goto done
}
ticks++
a[q] = 1
if q+n >= maxmemb {
	goto done
}
ticks++
b[q+n] = 1

@* 황금비의 배수.
크누스는 이 대목을 특히 즐겁게 짰다고 한다. 값 $n\phi$를 정수에 $\sum_{k\ge1}
x_k\phi^{-k}$를 더한 꼴로 나타낸다. 여기서 모든 $k$에 대해 $x_kx_{k+1}=0$이다.
이를테면 $9\phi=14+\phi^{-2}+\phi^{-4}+\phi^{-7}$이다. 정수 부분은 |nphiint|에, 분수
부분은 {\it 이진\/} 정수 $(\ldots x_3x_2x_1)_2$로 |nphifrac|에 둔다.

이 분수 부분은 {\sl The Art of Computer Programming\/}의 식 7.1.3--(147)에 나오는
{\it 음 피보나치 기수법\/}과 멋지게 이어진다. 이를테면 $9=F_{-7}+F_{-4}+F_{-2}$가
$9$의 음 피보나치 표현이다. 그러므로
$$\eqalign{9\phi&=(F_7-F_4-F_2)\phi
  =F_8-F_5-F_3-(-\phi)^{-7}+(-\phi)^{-4}+(-\phi)^{-2}\cr
  &=14+\phi^{-7}+\phi^{-4}+\phi^{-2}\cr}$$
이다. 여기서 $F_k\phi=F_{k+1}-(-\phi)^{-k}$를 썼다.

원본의 이 식은 $(F_6-F_4-F_2)\phi=F_7-F_5-F_3-\bigl((-\phi)^{-7}+(-\phi)^{-4}+
(-\phi)^{-2}$로 적혀 있다. 그런데 $F_6-F_4-F_2=8-3-1=4$라서 첨자가 하나씩 모자라고,
부호도 맞지 않으며, 괄호도 닫히지 않았다. 적힌 대로 셈하면 $14.56\ldots$이 아니라
$5.51\ldots$이 나온다. 위의 식이 고친 것이다.

@ 또 식 7.1.3--(149)는 $n$의 음 피보나치 표현에서 그다음 수의 표현으로 넘어가는
멋진 방법을 보여 준다. 그리고 연습 문제 7.1.3--45는 분수 부분끼리 견주기가 뜻밖에
쉽다는 것을 보여 준다. 분수 부분은 왼쪽에서 오른쪽이 아니라 오른쪽에서 왼쪽으로 사전순을
따르는데도(!) 그렇다.

비트 무늬 $x_1x_2\ldots$는 부호 없는 \.{uint64}에 담는다. 원본은 \.{long long}에
담고서 |0xaaaaaaaaaaaaaaaa|를 섞는데, 비트는 같다. 나는 $n\le200000$에서 |nphiint|가
$\lfloor n\phi\rfloor$이고 |nphiint|에 분수 부분을 더한 값이 $n\phi$와 $10^{-30}$ 안에서
같음을 따로 확인했다.

@<|nphiint|와 |nphifrac|을 한 걸음...@>=
nphiint++
if nphifrac&0x3 != 0 {
	nphiint++
}
{
	y := nphifrac ^ 0xaaaaaaaaaaaaaaaa
	z := y ^ (y + 1)
	z = z | (nphifrac & (z << 1))
	nphifrac ^= z ^ ((z + 1) >> 2)
}

@ 분수 부분 둘을 견준다. 두 무늬가 처음 다른 비트는 $x-y$의 가장 낮은 켜진 비트이고,
그것을 뽑는 것이 Rokicki의 요령 |(x-y)&(y-x)|다. 그 자리에서 $y$가 1이면 $y$ 쪽이
크다. 네 곳에서 부르므로 함수로 둔다.

@<함수들@>=
func compfrac(x, y uint64) bool {
	d := (x - y) & (y - x) // Rokicki의 요령
	return d&y != 0        // $x^R<y^R$이면 참
}

@* 통계.
값 $q_n$마다 |ticks|의 도수 분포를 쌓고, $q_n$이 어느 쪽 가지에 드는지에 따라 어긋남을
적는다. 수열의 값은 대략 $\phi n$ 근처(``위'', $q_n\ge n$)나 $\phi^{-1}n=\phi n-n$
근처(``아래'')에 온다. 어긋남의 최댓값과 최솟값이 새로 나올 때마다 표준 오류에 찍는다.

함수 |debug|는 $n$이 |pausethresh|를 넘으면 불린다. 원본에는 설명이 없지만, 디버거로
이 함수에 멈춤점을 걸어 두면 $n$이 $10$억 가까이 갔을 때 멈춰 세울 수 있다. 멈춤점을
걸 자리여야 하니, 한 곳에서만 부르지만 함수로 둔다.

@<$q$에 관한 통계를 적는다@>=
if n > pausethresh {
	debug("watch me now")
}
if ticks >= tickmax {
	tickhist[tickmax]++
} else {
	tickhist[ticks]++
}
if q >= n {
	@<위쪽 어긋남을 적는다@>@;
} else if q > nphiint-n {
	@<아래쪽 어긋남의 최댓값 쪽을 적는다@>@;
} else {
	@<아래쪽 어긋남의 최솟값 쪽을 적는다@>@;
}

@ @<함수들@>=
func debug(m string) {
	fmt.Fprintf(errw, "%s!\n", m)
}

@ 정수 부분이 같으면 분수 부분이 작을수록 어긋남 $q-n\phi$가 크다.

@<위쪽 어긋남을 적는다@>=
if q > nphiint {
	if q-nphiint > int64(deltahimaxint) ||
		(q-nphiint == int64(deltahimaxint) && compfrac(nphifrac, deltahimaxfrac)) {
		deltahimaxint, deltahimaxfrac = int(q-nphiint), nphifrac
		fmt.Fprintf(errw, "n=%d, deltahimax=%d,%x\n", n, deltahimaxint, deltahimaxfrac)
	}
	j = int(q - nphiint - 1)
	if j >= deltamax {
		deltahimax[deltamax]++
	} else {
		deltahimax[j]++
	}
} else {
	if q-nphiint < int64(deltahiminint) ||
		(q-nphiint == int64(deltahiminint) && compfrac(deltahiminfrac, nphifrac)) {
		deltahiminint, deltahiminfrac = int(q-nphiint), nphifrac
		fmt.Fprintf(errw, "n=%d, deltahimin=%d,%x\n", n, deltahiminint, deltahiminfrac)
	}
	j = int(nphiint - q)
	if j >= deltamax {
		deltahimin[deltamax]++
	} else {
		deltahimin[j]++
	}
}

@ @<아래쪽 어긋남의 최댓값 쪽을 적는다@>=
if q-(nphiint-n) > int64(deltalomaxint) ||
	(q-(nphiint-n) == int64(deltalomaxint) && compfrac(nphifrac, deltalomaxfrac)) {
	deltalomaxint, deltalomaxfrac = int(q-(nphiint-n)), nphifrac
	fmt.Fprintf(errw, "n=%d, deltalomax=%d,%x\n", n, deltalomaxint, deltalomaxfrac)
}
j = int(q - (nphiint - n) - 1)
if j >= deltamax {
	deltalomax[deltamax]++
} else {
	deltalomax[j]++
}

@ @<아래쪽 어긋남의 최솟값 쪽을 적는다@>=
if q-(nphiint-n) < int64(deltalominint) ||
	(q-(nphiint-n) == int64(deltalominint) && compfrac(deltalominfrac, nphifrac)) {
	deltalominint, deltalominfrac = int(q-(nphiint-n)), nphifrac
	fmt.Fprintf(errw, "n=%d, deltalomin=%d,%x\n", n, deltalominint, deltalominfrac)
}
j = int((nphiint - n) - q)
if j >= deltamax {
	deltalomin[deltamax]++
} else {
	deltalomin[j]++
}

@ 끝에 도수 분포들을 찍는다. 어긋남의 분포는 최솟값 쪽을 거꾸로 늘어놓고 세로 막대
뒤에 최댓값 쪽을 늘어놓는다.

@<마지막 통계를 찍는다@>=
fmt.Fprintf(errw, "OK, I computed %d elements of the sequence.\n", n-1)
fmt.Fprintf(errw, "tick histogram:")
for j = 0; j <= tickmax; j++ {
	fmt.Fprintf(errw, " %d", tickhist[j])
}
fmt.Fprintf(errw, "\n")
fmt.Fprintf(errw, "deltalo histogram:")
for j = deltamax; j >= 0; j-- {
	fmt.Fprintf(errw, " %d", deltalomin[j])
}
fmt.Fprintf(errw, " |")
for j = 0; j <= deltamax; j++ {
	fmt.Fprintf(errw, " %d", deltalomax[j])
}
fmt.Fprintf(errw, "\n")
fmt.Fprintf(errw, "deltahi histogram:")
for j = deltamax; j >= 0; j-- {
	fmt.Fprintf(errw, " %d", deltahimin[j])
}
fmt.Fprintf(errw, " |")
for j = 0; j <= deltamax; j++ {
	fmt.Fprintf(errw, " %d", deltahimax[j])
}
fmt.Fprintf(errw, "\n")

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 컴파일해 이 판과 견주었다. 사용법을 알리는 말에 든
프로그램 이름만 빼고 표준 출력, 표준 오류, 종료 부호가 바이트까지 같은지를 보았다.

\smallskip
\item{$\bullet$} 원본이 옳은지는 정의대로 짠 파이썬 탐욕 탐색과 견주어 보았다. 처음
$3000$항이 같았다.
\item{$\bullet$} 원본에 \.{AddressSanitizer}와 \.{UndefinedBehaviorSanitizer}를
붙여 $n=0$부터 $1500$까지 돌려 보니 경고가 없었고, 늘 $n$항을 모두 계산했다.
배열이 모자라 일찍 멈춘 적은 없다. 목표가 $n=10^8$일 때도 끝까지 계산했다.
\item{$\bullet$} 이 판은 $n=0$부터 $300$까지, 피보나치 수 몇과 $10^7$까지의 열의
거듭제곱들, 그리고 여러 모양의 명령줄에서 원본과 모두 같았다. 다른 것은 일부러 고친
음수 $n$ 둘뿐이다.
\smallskip

@* 색인.
