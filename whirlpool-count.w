\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\falling#1{^{\ff{#1}}}
\def\ff#1{\mkern1mu\underline{\mkern-1mu#1\mkern-2mu}\mkern2mu}
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

\def\title{소용돌이 순열 세기}

@* 들어가며.
이 프로그램은 $m$과 $n$을 받아 $m\times n$ ``소용돌이 순열''(whirlpool permutation)의
수를 센다. 크누스는 {\mc HISTOSCAPE-COUNT}에서 영감을 얻었다고 한다.

소용돌이 순열이 뭐냐고? 좋은 질문이다. 크기가 $m\times n$인 행렬에는 $2\times2$ 부분행렬이
$(m-1)(n-1)$개 있다. 크기 $m\times n$의 소용돌이 순열은 원소 $mn$개의 순열 가운데, 그런
부분행렬마다 네 원소의 상대 순서가 ``소용돌이''인 것이다. 곧 가장 작은 것에서 가장 큰
것까지 시계 방향이든 반시계 방향이든 한 바퀴 도는 길을 따른다.

그러니 $2\times2$ 소용돌이 순열은 꼭 여덟 개다. 행렬의 원소를 위에서 아래로, 왼쪽에서
오른쪽으로 $abcd$라 하면 1243, 1423, 2134, 2314, 3241, 3421, 4132, 4312다. 간단히
가려내려면 $a:b$, $b:d$, $d:c$, $c:a$를 견주면 된다. `$<$'의 개수가 홀수여야 한다.
(그러면 `$>$'의 개수도 홀수다.)

$$\mplibcode
beginfig(1);
  u := 9mm;
  def cell(expr p, s) =
    draw unitsquare scaled u shifted p withpen pencircle scaled .4pt;
    label(s, p + (.5u, .5u));
  enddef;
  def arr(expr a, b) =
    drawarrow a -- b
      cutbefore fullcircle scaled 4mm shifted a
      cutafter fullcircle scaled 4mm shifted b
      withpen pencircle scaled .6pt withcolor .45white;
  enddef;
  pair p[];
  p1 = (.5u, 1.5u); p2 = (1.5u, 1.5u); p3 = (.5u, .5u); p4 = (1.5u, .5u);
  cell((0, u), btex $1$ etex); cell((u, u), btex $2$ etex);
  cell((0, 0), btex $4$ etex); cell((u, 0), btex $3$ etex);
  arr(p1, p2); arr(p2, p4); arr(p4, p3);
  cell((3u, u), btex $1$ etex); cell((4u, u), btex $2$ etex);
  cell((3u, 0), btex $3$ etex); cell((4u, 0), btex $4$ etex);
  arr(p1 + (3u, 0), p2 + (3u, 0)); arr(p2 + (3u, 0), p3 + (3u, 0));
  arr(p3 + (3u, 0), p4 + (3u, 0));
endfig;
\endmplibcode$$
\figcap{왼쪽 $1243$은 1에서 4까지 시계 방향으로 한 바퀴 돌므로 소용돌이다.
네 쌍 $a:b$, $b:d$, $d:c$, $c:a$를 견주면 `$<$'가 셋이다. 오른쪽 $1234$는 Z자로 가로지르므로
소용돌이가 아니고, `$<$'가 둘이다.}

@ 세는 방법은 크누스가 전에 본 적 없다는, 꽤 머리가 어지러운 동적 계획법의
변종이다. 원소 $t$개의 순열에서 원소 $n+1$개를 나타내야 하는데 $t$는 많아야 $mn$이고,
그런 부분 순열은 $(mn)\falling{n+1}$개까지 된다. 그러니 $m$과 $n$이 꽤 작지 않으면
풀 수 없다. 그래도 풀 {\it 수 있을\/} 때는 조금 짜릿하다. 셈 $t\falling{n+1}$개를
메모리에 담는 아주 흥미로운 방법을 쓰기 때문이다.

같은 방법으로, $2\times2$ 부분행렬들이 네 원소의 상대 순서에만 달린 아무 관계든
만족하는 순열 행렬도 셀 수 있다. (그러니 부분행렬 $(m-1)(n-1)$개마다 제약 $2^{24}$가지
가운데 아무것이나 걸 수 있다. 앞에 늘어놓은 여덟 가지 순서만 받는 소용돌이는 셀 수
없이 많은 경우 가운데 하나일 뿐이다.)

크기가 $m\ge n$인 편이 낫다. 그래도 크누스는 시험 삼아 $m<n$인 경우도 돌려 본다고 했다.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{whirlpool-count.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/whirlpool-count.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Wed, 06 May 2020 03:57:15 GMT}다. 프로그램이 찍는 말과 종료 부호는 원본 그대로
두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

옮기다 보니 원본에서 결함이 나왔다. 크기 $8\times4$와 $7\times5$에서는 셈이 $64$비트를
넘어 한 바퀴 돌아 틀린 답을 낸다. 설명에도 잘못 적힌 곳이 몇 있다. 모두 그 자리에서
이야기한다.

원본의 첫 문단은 소용돌이 순열을 ``원소 $(mn)!$개의 순열''이라 했는데, 원소 $mn$개의
순열이라야 맞다. 이 판은 고쳐 옮겼다.

@ 뼈대는 이렇다. 제약 $(i,j)$, 곧 $(i-1,j-1)$에서 $(i,j)$까지의 $2\times2$
부분행렬마다 한 번씩 셈을 새로 고친다. 그리고 $j=0$일 때는 새 가로줄을 시작할 뿐 제약이 없다.

@c
package main

import (
	"fmt"
	"os"
)

@<상수@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	var a, b, c, d, i, j, k, p, q, r, mn, t, tt, kk, bb, cc, pdel int
	@<명령줄을 처리한다@>@;
	for i = 1; i < m; i++ {
		for j = 0; j < n; j++ {
			@<제약 $(i,j)$를 다룬다@>@;
		}
	}
	@<모두 더해 찍는다@>@;
}

@ @<상수@>=
const (
	maxn  = 8
	maxmn = 36
)

@ @<전역 변수@>=
var (
	m, n     int                  // 명령줄 인자
	count    []uint64             // 셈들을 담는 커다란 배열
	newcount [maxmn]uint64        // 옛 셈들을 갈아 치울 셈들
	mems     uint64               // 여덟 바이트 낱말의 메모리 참조 횟수
	x        [maxn + 1]int        // 훑고 있는 첨자들
	ay       [maxn + 1]int
	l, u     [maxmn]int
	tpow     [maxmn + 1]int       // 내림 거듭제곱 $t\falling{n+1}$
)

@ 인자는 \CEE/의 |sscanf|처럼 읽는다. 앞의 빈칸과 부호를 받고, 수 뒤에 붙은 글자는
버린다. 크기는 원본의 \.{int}처럼 $32$비트로 한정한다. \GO/의 |make|는 실패하면
|nil|을 돌려주지 않고 프로그램을 끝내므로, 셈 배열을 잡지 못했다는 원본의 말은 옮기지
않았다.

@<명령줄을 처리한다@>=
{
	var m32, n32 int32
	ok := len(os.Args) == 3
	if ok {
		_, err1 := fmt.Sscanf(os.Args[1], "%d", &m32)
		_, err2 := fmt.Sscanf(os.Args[2], "%d", &n32)
		ok = err1 == nil && err2 == nil
	}
	if !ok {
		fmt.Fprintf(os.Stderr, "Usage: %s m n\n", os.Args[0])
		os.Exit(-1)
	}
	m, n = int(m32), int(n32)
}
mn = m * n
if m < 2 || m > maxn || n < 2 || n > maxn || mn > maxmn {
	fmt.Fprintf(os.Stderr, "Sorry, m and n should be between 2 and %d, with mn<=%d!\n",
		maxn, maxmn)
	os.Exit(-2)
}
@<내림 거듭제곱 |tpow|를 채운다@>@;
count = make([]uint64, tpow[mn])

@ 셈 배열의 크기 $(mn)\falling{n+1}$은 $2^{31}$보다 작아야 한다. 그래서 받아들이는
크기는 $n=2$일 때 $m\le8$, $n=3$일 때 $m\le8$, $n=4$일 때 $m\le8$, $n=5$일 때 $m\le7$,
$n=6$일 때 $m\le4$, $n=7$일 때 $m=2$뿐이다. 가장 큰 $4\times6$은 셈 배열이
$14$\,GB다.

@<내림 거듭제곱...@>=
for k = n + 1; k <= mn; k++ {
	var acc uint64 = 1
	for j = 0; j <= n; j++ {
		acc *= uint64(k - j)
	}
	if acc >= 0x80000000 {
		fmt.Fprintf(os.Stderr, "Sorry, mn\\falling(n+1) must be less than 2^31!\n")
		os.Exit(-666)
	}
	tpow[k] = int(acc)
}

@* 부분 순열의 표현.
원소 $t+1$개의 순열에서 정해진 원소 $n+1$개를 나타내고 싶다고 하자. 이를테면 $n=3$,
$t=8$이고, 순열 $y_0\ldots y_8$의 마지막 네 원소가 $y_5y_6y_7y_8=3142$일 수 있다.
그런 부분 순열은 $(t+1)\falling{n+1}$개이고, 정수 변수 $n+1$개 $x_{t-n}$, \dots,
$x_{t-1}$,~$x_t$로 간결하게 나타낼 수 있다. 여기서 $0\le x_j\le j$다. 규칙은 $x_j$가
$y_j-w_j$라는 것이다. 여기서 $w_j$는 $y_j$가 ``뒤집는'' 원소의 수, 곧 $y_j$의
오른쪽에 있으면서 $y_j$보다 작은 원소의 수다. 앞의 예에서 $w_5w_6w_7w_8=2010$이니
$x_5x_6x_7x_8=1132$다. (거꾸로 $x_5x_6x_7x_8=3141$이면 $y_5y_6y_7y_8=6251$이다.)

@ 이 표현에는 아름다운 성질이 있고, 우리는 그것을 써먹는다. 순열 $\{0,\ldots,t\}$의
순열 $y_0\ldots y_t$ 하나는 $\{0,\ldots,t+1\}$의 순열 $y'_0\ldots y'_{t+1}$을
$t+2$개 낳는다. 값 $y'_{t+1}$을 마음대로 고르고 $y'_j=y_j+\hbox{[$y_j{\ge}y'_{t+1}$]}$로
두면 된다. 이를테면 $t=8$이고 $y_5y_6y_7y_8=3142$이면, $y_0\ldots y_8$에서 얻는 열
순열의 $y'_5y'_6y'_7y'_8y'_9$는 42530, 42531, 41532, 41523, 31524, 31425, 31426,
31427, 31428, 31429다. 그리고 이 마지막 다섯 원소의 표현 $x'_5x'_6x'_7x'_8x'_9$는
차례로 그저 11320, 11321, \dots, 11329다! 일반적으로 $0\le j\le t$이면 $x'_j=x_j$이고,
$x'_{t+1}=y'_{t+1}$은 아무 값이나 된다.

원본은 이 표현들을 31420, 31421, \dots, 31429라 했다. 그것은 $y_5y_6y_7y_8$에
$y'_9$를 붙인 것이다. 앞 절에서 $x_5x_6x_7x_8=1132$였으니 11320부터 11329까지라야
맞다. 이를테면 42530의 $w$는 $31010$이라 $x'$은 $11320$이다.

@ 이제 머리가 어지러운 대목이다. 첨자 $(x_{t-n},\ldots,x_t)$의 설정마다 셈
$c(x_{t-n},\ldots,x_t)$를 두고 싶다. 그런데 $t$를 $t+1$로 올릴 때 기존의 셈을 하나도
덮어쓰지 않도록 메모리에 두고 싶다. 특히 $x'_{t+1}\le t-n$이면
$c(x'_{t+1-n},\ldots,x'_t,x'_{t+1})$을 앞 판에서 $c(x'_{t+1},x_{t+1-n},\ldots,x_t)$가
있던 바로 그 자리에 둔다. 그러나 $x'_{t+1}>t-n$이면
$c(x'_{t+1-n},\ldots,x'_t,x'_{t+1})$을 이전에 쓰지 않은 새 자리에 둔다.

그래서 $t$마다 다른 메모리 사상 $\mu_t$를 쓴다. 계산의 $t$번째 판에서 셈
$c(x_{t-n},x_{t-n+1},\ldots,x_t)$는 다음 자리에 있다.
$$\mu_t(x_{t-n},x_{t-n+1},\ldots,x_t)$$

@ 앞의 예를 $n=3$인 소용돌이 순열에 적용해 보자. 처음 세 가로줄에 든 순열을
$y_0\ldots y_8$이라 하자. 여기서 $y_6y_7y_8$이 셋째 가로줄이고 $y_5$는 둘째 가로줄의
마지막 원소다. (이것은 $\{0,\ldots,8\}$의 순열로, 행렬 전체를 채울 $\{0,\ldots,3m-1\}$의
최종 순열에서의 상대 순서를 나타낸다.) 이 시점에는 셈 $c(x_5,x_6,x_7,x_8)$을 이미
구해 두었다. 이것은 부분 소용돌이 순열 가운데 $y_5y_6y_7y_8$이 주어진 값인 것이 몇
개인지를 알려 준다. 특히 $c(1,1,3,2)$는 $y_5y_6y_7y_8=3142$인 것을 센다.

다음 판으로 가려면, $\{0,\ldots,9\}$의 부분 순열 $y'_0\ldots y'_9$ 가운데
$y'_6y'_7y'_8y'_9$가 주어진 값인 것이 몇 개인지를 알면 된다. 둘째 가로줄은 이제 앞으로의
계산과 상관없다. 이는 $y_6y_7y_8=142$인 순열이 몇 개인지 묻는 것과 같다. 답은
$c(0,1,3,2)+c(1,1,3,2)+c(2,1,3,2)+c(3,1,3,2)+c(4,1,3,2)+c(5,1,3,2)$다. 이것들이
$y_5y_6y_7y_8=0142$, 3142, 5142, 6142, 7142, 8142인 순열을 세기 때문이다.

이 여섯 셈 $c(k,1,3,2)$는 $0\le k\le5$에 대해 $\mu_8(k,1,3,2)$ 자리에 있다. 다음
판에서는 $c'(x'_6,x'_7,x'_8,x'_9)=c'(1,3,2,x'_9)$가 그 합이 되기를 바란다. 이 새 셈은
$\mu_9(1,3,2,x'_9)$ 자리에 놓인다. 그러니 $0\le k\le5$일 때
$\mu_9(1,3,2,k)=\mu_8(k,1,3,2)$이면 좋겠다.

@ 사상 $\lambda_t$를
$$\eqalign{\lambda_t(x_{t-n},\ldots,x_t)
 &=\bigl(\cdots((x_tt+x_{t-1})(t-1)+x_{t-2})\cdots\bigr)(t-n+1)+x_{t-n}\cr
 &=x_t t\falling n+x_{t-1}(t-1)\falling{n-1}+\cdots+x_{t-n}(t-n)\falling0\cr}$$
로 두자. 이것은 $(x_t\ldots x_{t-n})$을 기수 $(t+1,t,\ldots,t-n+1)$로 나타낸 표준 혼합
기수 표현이다. 각 $x_j$가 $0$부터 $j$까지 움직이면 $\lambda_t(x_{t-n},\ldots,x_t)$는
$\lambda_t(0,\ldots,0)=0$부터 $\lambda_t(t-n,\ldots,t)=(t+1)\falling{n+1}-1$까지
움직인다. 그러니 덮어쓰기를 피할 까닭만 없다면 $\lambda_t$가 $\mu_t$로 가장 자연스러운
선택이다. (원본의 식에는 마지막 항 앞의 `$+$'가 빠져 있어 채웠다.)

대신 $\lambda_t$는 $x_t$가 충분히 클 때만 쓴다. 곧
$$\mu_t(x_{t-n},\ldots,x_t)=\cases{
\lambda_t(x_{t-n},\ldots,x_t),&$x_t\ge t-n$이면;\cr
\mu_{t-1}(x_t,x_{t-n},\ldots,x_{t-1}),&$x_t\le t-n-1$이면\cr}$$
으로 정의한다. 이 되부름은 $\mu_n=\lambda_n$에서 끝난다. 값 $x_n$은 늘 $0$ 이상이기
때문이다. 또 $\mu_{n+1}=\lambda_{n+1}$임도 보일 수 있다.

@ 앞의 예로 돌아가, $\mu_8(k,1,3,2)$는 무엇일까? 마지막 인자가 $2\le4$이므로 이것은
$\mu_7(2,k,1,3)$이다. 그리고 $3\le3$이므로 $\mu_6(3,2,k,1)$이고, 이는
$\mu_5(1,3,2,k)$다. 그러므로 결국 $k\le1$이면 값은 $\lambda_4(k,1,3,2)=68+k$이고,
$2\le k\le5$이면 $\lambda_5(1,3,2,k)=60k+34$다.

이 프로그램은 $x_j$를 자리 $x_{j\bmod(n+1)}$에 둔다. 그러면 $\mu_t$와 $\lambda_t$의
인자는 늘 다음 자리들에 있다.
$$(x_{(t+1)\bmod(n+1)},x_{(t+2)\bmod(n+1)},\ldots,x_{t\bmod(n+1)})$$ 함수 |mu|는 세 곳에서 부르므로 함수로 둔다.

@<함수들@>=
func mu(t int) int {
	var r, a, p, tt int
	for r, tt = t%(n+1), t; ; tt, r = tt-1, prev(r) {
		mems++
		if x[r] >= tt-n {
			break
		}
	}
	mems++
	p = x[r]
	for r, a = prev(r), 0; a < n; a, r = a+1, prev(r) {
		mems++
		p = p*(tt-a) + x[r]
	}
	return p
}

@ 자리 번호는 $0$부터 $n$까지 고리를 이룬다. 원본의 |(r?r-1:n)|을 함수로 둔다.

@<함수들@>=
func prev(r int) int {
	if r == 0 {
		return n
	}
	return r - 1
}

@* 되추적.
알고리즘 7.2.1.2X와 거의 같은 되추적이 $x_{t-n+1}\ldots x_t$와 $y_{t-n+1}\ldots y_t$의
모든 조합을 한꺼번에 멋지게 훑는다. 그러면서 $x_{t-n}$이 $0$부터 $t-n$까지 움직일 때
$y_{t-n}$이 될 수 있는 값들을 보여 주는 연결 리스트도 마련해 준다.

이 알고리즘은 $\{0,\ldots,t\}$의 ``$n$-변이''를 모두 만든다. 곧 그 집합에서 서로 다른
정수 $n$개를 고른 $n$짝 $a_0\ldots a_{n-1}$을 모두 만든다. 여기서 $a_j$는 앞의 논의에서
$y_{t-j}$에 해당한다.

원본처럼 단계 이름을 이름표로 두고 |goto|로 짰다. \GO/의 |goto|는 블록 안으로만 뛰지
않으면 되므로 그대로 옮길 수 있다. 원본의 이름표 |x1|과 |x4|로는 아무도 뛰지 않는다.
\GO/는 쓰지 않는 이름표를 허락하지 않으니 절 이름으로만 남겼다.

@<$x$들과 $y$들을 만든다@>=
@<단계 X1: 연결 리스트를 차리고 $k=0$으로 둔다@>@;
@<단계 X2--X4: $a_k$를 고르고 한 단계 들어간다@>@;
@<단계 X5--X6: 다음 $a_k$로 가거나 물러난다@>@;

@ @<단계 X1...@>=
for k = 0; k <= t; k++ {
	mems++
	l[k] = k + 1
}
mems++
l[t+1] = 0 // 고리 모양 연결 리스트
k, kk = 0, t%(n+1)

@ 단계 X2에서 $n$짝이 다 찼으면 방문한다. 아니면 리스트의 첫 값을 $a_k$로 삼고(X3),
그 값을 리스트에서 빼고 한 단계 들어간다(X4).

@<단계 X2--X4...@>=
x2:
if k == n {
	@<$a_0\ldots a_{n-1}$을 방문하고 |goto x6|@>@;
}
mems += 2
p = t + 1
q = l[p]
x[kk] = 0
x3:
mems++
ay[k] = q
mems += 3
u[k] = p
l[p] = l[q]
k++
kk = prev(kk)
goto x2

@ 단계 X5는 $a_k$를 리스트의 다음 값으로 바꾼다. 리스트가 끝났으면 X6에서 한 단계
물러나며 빼 두었던 값을 리스트에 되돌린다.

@<단계 X5--X6...@>=
x5:
mems++
p = q
q = l[p]
if q <= t {
	mems += 2
	x[kk]++
	goto x3
}
x6:
k--
if k >= 0 {
	if kk == n {
		kk = 0
	} else {
		kk++
	}
	mems += 3
	p = u[k]
	q = ay[k]
	l[p] = q
	goto x5
}

@ 여기서 ``안쪽 반복문''의 계산을 한다. 셈 $c(x_{t-n},\ldots,x_t)$를
$0\le x_{t-n}\le t-n$에 걸쳐 모두 써서, $t$를 올릴 수 있게 셈을 새로 고친다. 배열
$a_{n-1}\ldots a_0$은 앞의 논의의 $y_{t-n+1}\ldots y_t$에 해당한다. 이제 $y_{t-n}$,
곧 $a_n$이 될 수 있는 값을 모두 훑고 싶다. 다행히 바로 그 값들을 담은 연결 리스트가
|l[t+1]|에서 시작한다.

@<$a_0\ldots a_{n-1}$을 방문하고...@>=
@<할 수 있으면 $c(x_{t-n},\ldots,x_t)$가 |count[p+pdel*x[kk]]|가 되도록 |p|와
  |pdel|을 찾는다@>@;
for d = 0; d <= t+1; d++ {
	mems++
	newcount[d] = 0
}
mems += 2
b, c = ay[n-1], ay[0]
if b < c {
	bb, cc = b, c
} else {
	bb, cc = c, b // 작은 것과 큰 것
}
@<새 셈 |newcount|를 모은다@>@;
@<새 셈을 |count|에 적는다@>@;
goto x6

@ 새 가로줄을 시작할 때($j=0$)는 제약이 없다. 그 밖에는 소용돌이 제약을 따른다.
네 원소 가운데 $a$가 가운데 값이 아니면 $d$는 $b$와 $c$ 사이에 와야 하고, $a$가
가운데 값이면 $d$는 그 바깥에 와야 한다.

원본은 셈을 \.{unsigned long long}에 담고 넘침을 살피지 않는다. 그런데 $8\times4$와
$7\times5$에서는 셈이 $2^{64}$을 넘는다. 셈만 $128$비트로 바꾼 판을 따로 만들어 돌려
보니, $8\times4$에서는 마지막 판의 셈 $2416$만여 개 가운데 $491$만여 개가, $7\times5$에서는
$11$억 $6867$만여 개 가운데 $10$억 $3877$만여 개가 $2^{64}$ 이상이었다. 그래서 원본의
답은 둘 다 틀렸다.
$$\vbox{\halign{#\hfil\quad&\hfil$#$\quad&\hfil$#$\cr
&\hbox{원본의 답}&\hbox{$128$비트로 센 답}\cr
$8\times4$&219973998497990105098125312&278588168022148184390533120\cr
$7\times5$&1063541244469255428209447936&714725373434115538566299325440\cr}}$$
원본이 찍는 가장 큰 셈도 \.{\%lld}로 찍혀 음수가 된다. 나머지 크기에서는 넘치지 않았다. 이 판은 덧셈마다 올림이 났는지 살펴, 났으면 알리고 멈춘다. 이 말과 종료 부호
$-5$는 이 판에서 지은 것이다.

@<새 셈 |newcount|를 모은다@>=
carry := false
for mems, a, x[kk] = mems+2, l[t+1], 0; a <= t; mems, a, x[kk] = mems+2, l[a], x[kk]+1 {
	var tmp uint64
	if pdel != 0 {
		tmp = count[p+x[kk]*pdel]
	} else {
		tmp = count[mu(t-n)] // |pdel=0|이면 |mu(t)=mu(t-n)|
	}
	if j == 0 { // 제약 없이 새 가로줄을 시작한다
		newcount[0] += tmp
		carry = carry || newcount[0] < tmp
	} else if a < bb || a > cc { // |a|가 가운데가 아닐 때의 소용돌이 제약
		for d = bb + 1; d <= cc; d++ {
			mems += 2
			newcount[d] += tmp
			carry = carry || newcount[d] < tmp
		}
	} else { // |d|가 가운데가 아닐 때의 소용돌이 제약
		for d = 0; d <= bb; d++ {
			mems += 2
			newcount[d] += tmp
			carry = carry || newcount[d] < tmp
		}
		for d = cc + 1; d <= t+1; d++ {
			mems += 2
			newcount[d] += tmp
			carry = carry || newcount[d] < tmp
		}
	}
}
if carry {
	fmt.Fprintf(os.Stderr, "Sorry, a count exceeded 2^64 at constraint (%d,%d)!\n", i, j)
	os.Exit(-5)
}

@ 새 셈을 적는다. 앞의 $t-n+1$개는 옛 셈이 있던 자리에 그대로 덮어쓰고, 나머지는
$\mu_{t+1}$이 정하는 새 자리에 둔다.

@<새 셈을 |count|에 적는다@>=
if pdel != 0 {
	for d = 0; d <= t-n; d++ {
		mems += 2
		count[p+d*pdel] = newcount[pick(j, d)]
	}
	for ; d <= t+1; d++ {
		mems += 3
		x[kk] = d
		count[mu(t+1)] = newcount[pick(j, d)]
	}
} else {
	for d = 0; d <= t+1; d++ {
		mems += 3
		x[kk] = d
		count[mu(t+1)] = newcount[pick(j, d)]
	}
}

@ 원본의 |j?d:0|이다. 곧 $j=0$이면 새 셈은 |newcount[0]| 하나뿐이다.

@<함수들@>=
func pick(j, d int) int {
	if j != 0 {
		return d
	}
	return 0
}

@ 앞의 $\mu_8(k,1,3,2)$ 예가 보여 주듯이 이 단계의 임무는 때로 불가능하다. 그러나 주소
체계는 대개 단순해서, 크누스는 그 사실을 써먹기로 했다. (물론 섣부른 최적화가
프로그래밍에서 모든 악의 뿌리임을 알면서다.) 불가능한 경우에는 |pdel=0|으로 두고
그때마다 |mu|를 부른다.

@<할 수 있으면...@>=
for tt, a, r = t, 0, t%(n+1); a < n; a, tt, r = a+1, tt-1, prev(r) {
	mems++
	if x[r] >= tt-n {
		break
	}
}
if a == n {
	pdel = 0 // 어려운 경우
} else {
	for p, pdel, a = 0, 0, 0; a <= n; a, r = a+1, prev(r) {
		if r != kk {
			p, pdel = p*(tt+1-a)+x[r], pdel*(tt+1-a)
		} else {
			p, pdel = p*(tt+1-a), pdel*(tt+1-a)+1
		}
	}
}

@ 제약 $(i,j)$를 다룰 때 지금까지 채운 칸은 $t+1=ni+j$개다. 첫 가로줄 다음 칸($t=n-1$)
에서는 제약이 없으니, 원소 $n+1$개의 순열마다 셈을 $1$로 둔다.

@<제약 $(i,j)$를 다룬다@>=
t = n*i + j - 1
if t < n {
	for p = 0; p < tpow[n+1]; p++ {
		mems++
		count[p] = 1
	}
	continue
}
@<$x$들과 $y$들을 만든다@>@;
fmt.Fprintf(os.Stderr, " done with %d,%d ..%d, %d mems\n", i, j, count[0], mems)

@* 합계.
끝으로 셈을 모두 더한다. 합계는 $2^{64}$을 넘을 수 있으므로 크누스는 $10^{18}$ 단위로
끊어 |newcount[1]|과 |newcount[0]|에 나누어 모은다. 가장 큰 셈과 그 자리도 찾아 찍는다.

셈 하나를 통째로 더하고 $10^{18}$을 한 번만 빼므로, 이 방법은 셈이 저마다
$10^{18}$보다 작아야 맞는다. 셈이 넘치지 않는 크기에서 가장 큰 셈은 $6\times5$의
$26656410228893480$이니 넉넉하다.

@<모두 더해 찍는다@>=
newcount[0], newcount[1], newcount[2] = 0, 0, 0
for p = tpow[mn] - 1; p >= 0; p-- {
	if count[p] > newcount[2] {
		newcount[2], pdel = count[p], p
	}
	mems++
	newcount[0] += count[p]
	if newcount[0] >= thresh {
		mems += 3
		newcount[0] -= thresh
		newcount[1]++
	}
}
fmt.Fprintf(os.Stderr, "(Maximum count %d is obtained for params", newcount[2])
for q = mn - n - 1; q < mn; q++ {
	fmt.Fprintf(os.Stderr, " %d", pdel%(q+1))
	pdel /= q + 1
}
fmt.Fprintf(os.Stderr, ")\n")
if newcount[1] == 0 {
	fmt.Printf("Altogether %d %dx%d whirlpool perms (%d mems).\n",
		newcount[0], m, n, mems)
} else {
	fmt.Printf("Altogether %d%018d %dx%d whirlpool perms (%d mems).\n",
		newcount[1], newcount[0], m, n, mems)
}

@ @<상수@>=
const thresh = 1000000000000000000

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 컴파일해 이 판과 견주었다. 사용법을 알리는 말에 든
프로그램 이름만 빼고 표준 출력, 표준 오류, 종료 부호가 바이트까지 같은지를 보았다.

\smallskip
\item{$\bullet$} 원본이 옳은지는 \CEE/로 짠 전수 탐색과 견주어 보았다. 칸을 차례로
채우며 $2\times2$ 부분행렬이 찰 때마다 `$<$'의 개수가 홀수인지 살핀다. 크기 $2\times2$부터
$3\times4$, $4\times3$, $2\times6$까지 열한 가지에서 모두 같았다. 원본이 받아들이는
크기에서는 $m\times n$과 $n\times m$의 답도 서로 같다.
\item{$\bullet$} 셈이 넘치는지는 덧셈마다 올림을 세는 판으로 모든 크기에서 보았고,
넘치는 두 크기의 참값은 셈만 $128$비트로 바꾼 판으로 구했다.
\item{$\bullet$} 이 판은 원본이 받아들이는 크기 $31$가지 가운데 넘치는 두 가지를 뺀
$29$가지와 잘못된 명령줄 아홉에서 원본과 모두 같았다. 크기 $8\times4$와 $7\times5$에서는
넘침을 알리고 멈춘다.
\smallskip

@* 색인.
