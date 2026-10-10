\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\title{백스터 순열에서 플로어플랜으로}

@* 들어가며.
이 프로그램은 주어진 백스터 순열에 대응하는 플로어플랜을 계산한다. 크누스의
말로는 ``서둘러'' 짠 것이다. 관련된 개념과 용어는 {\sl The Art of Computer
Programming\/} 제4B권의 연습 문제 MPR--135와 7.2.2.1--372에 소개되어 있다.

입력 순열은 특별한 조건을 만족해야 한다. $k$가 주어졌을 때 $k$보다 작은 수 $s$를
``작은'' 수, $k+1$보다 큰 수 $l$을 ``큰'' 수라고 하자. 그러면
$$\displaylines{
\hskip3em\hbox{$k$가 $k+1$ 뒤에 오면, 그 사이에 이웃한 두 원소 $sl$이 없다;}
\hfill(*)\cr
\hskip3em\hbox{$k+1$이 $k$ 뒤에 오면, 그 사이에 이웃한 두 원소 $ls$가 없다.}
\hfill(**)\cr}$$
다시 말해, $P$에서 $k+1$이 $k$보다 앞에 오면 그 사이의 작은 수들은 모두 그 사이의
큰 수들보다 뒤에 와야 하고~$(*)$, 그렇지 않으면 그 사이의 작은 수들은 모두 큰
수들보다 {\it 앞에\/} 와야 한다~$(**)$. $(*)$와 $(**)$를 만족하는 순열을 {\it 백스터
순열\/}이라 한다.

@ 주어진 백스터 순열을 $P=p_1p_2\ldots p_n$이라 하자. 방이 수 $\{1,2,\ldots,n\}$인
플로어플랜을 만들 것이다. 그 방들의 대각선 순서는 그냥 $12\ldots n$이고,
반대각선 순서는 $p_1p_2\ldots p_n$이 된다.

플로어플랜에는 재미있는 ``네 방향'' 순서가 있다. 서로 다른 두 방 $j$와 $k$는 다음
네 관계 가운데 꼭 하나를 이룬다. $j$가 $k$의 왼쪽에 있거나($j\Rightarrow k$로
쓴다), $j$가 $k$의 위에 있거나($j\Downarrow k$), $j$가 $k$의 오른쪽에 있거나
($j\Leftarrow k$), $j$가 $k$의 아래에 있다($j\Uparrow k$). 대각선 순서는 ``위나
왼쪽''이라는 선형 순서이고, 반대각선 순서는 ``아래나 왼쪽''이라는 선형 순서다.

그러므로 다음과 같은 (멋진) 상황이 되어야 한다.
$$\eqalign{
j\Rightarrow k&\iff\hbox{$j<k$이고 $P$에서 $j$가 $k$ 앞에 온다};\cr
j\Downarrow k&\iff\hbox{$j<k$이고 $P$에서 $j$가 $k$ 뒤에 온다};\cr
j\Leftarrow k&\iff\hbox{$j>k$이고 $P$에서 $j$가 $k$ 뒤에 온다};\cr
j\Uparrow k&\iff\hbox{$j>k$이고 $P$에서 $j$가 $k$ 앞에 온다}.\cr
}$$
게다가 $P$에서 $j$가 $k$ 앞에 오는 것은 $q_j<q_k$인 것과 같다. 여기서
$q_1q_2\ldots q_n$은 순열 $P$의 역순열 $P^-$이다.

@ 어떤 순열이든 이 규칙에 따라 네 방향 순서를 하나 정한다. 그러나 플로어플랜에서
나올 수 있는 네 방향 순서를 정하는 것은 백스터 순열뿐이다. 이를테면 ``파이 순열''
3142는 1이 2의 왼쪽, 1이 3의 위, 1이 4의 왼쪽, 2가 3의 위, 2가 4의 위, 3이 4의
왼쪽인 네 방향 순서를 정한다. 플로어플랜에서 이런 일이 생기려면 방이 적어도 하나
더 있어야 한다. (이를테면 ``방 2.5''를 1의 오른쪽, 2의 아래, 3의 위, 4의 왼쪽에 둘
수 있다. 그 플로어플랜의 백스터 순열은 3 1 2.5 4 2다.)

번호를 다시 매기면 그 순열은 41352이고, 이 프로그램은 다음 플로어플랜을 내놓는다.
가운데의 방 3이 ``방 2.5''다.
$$\mplibcode
beginfig(1);
  u := 9mm;
  def room(expr a, b, c, d, s) =
    draw (a*u, c*u) -- (b*u, c*u) -- (b*u, d*u) -- (a*u, d*u) -- cycle;
    label(textext(s), (.5(a + b)*u, .5(c + d)*u));
  enddef;
  pickup pencircle scaled .8;
  room(0, 1, 1, 3, "1"); room(1, 3, 2, 3, "2"); room(1, 2, 1, 2, "3");
  room(0, 2, 0, 1, "4"); room(2, 3, 0, 2, "5");
endfig;
\endmplibcode$$
방 1, 2, 4, 5의 관계는 3142의 1, 2, 3, 4의 관계와 같다. 1은 2의 왼쪽이고 4의
위이고 5의 왼쪽이다. 2는 4와 5의 위에 있고, 4는 5의 왼쪽이다.

@ 플로어플랜의 방들은 ``경계''라고 부르는 가로 선분과 세로 선분으로 나뉜다. 경계는
서로 가로지르지 않는다. 내놓을 플로어플랜의 가로 경계는 $P$의 {\it 내림\/}, 곧
$p_k>p_{k+1}$인 자리의 수보다 둘 많다. 세로 경계는 {\it 오름\/}, 곧
$p_k<p_{k+1}$인 자리의 수보다 둘 많다.

덧붙여, $P$를 $P^R$로 바꾸는 것은 플로어플랜을 주대각선에 대해 뒤집는 것에
해당한다. $P$를 $P^C$로 바꾸는 것은 다른 대각선에 대해 뒤집는 것에, $P^-$로 바꾸는
것은 위아래를 뒤집는 것에 해당한다. 그래서 $P$를 뒤집고, 여순열로 바꾸고, 역순열로
바꾸어 얻는 여덟 백스터 순열은 플로어플랜에 할 수 있는 여덟 가지 표준적인
``등거리'' 변환에 대응한다.

@ 입력 순열은 표준 입력으로 $p_1$ $p_2$ \dots~$p_n$의 수열로 들어온다. 수 사이는
빈칸 문자로 가른다. 출력하는 플로어플랜은 짝 프로그램
{\mc FLOORPLAN-TO-TWINTREE}의 입력 형식을 따르는 명세이고, 방은 오름차순으로
늘어놓는다.

@ 이것은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{baxter-to-floorplan.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/baxter-to-floorplan.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Fri, 07 Apr 2023 06:43:32 GMT}다. 플로어플랜, 쌍둥이 나무, 백스터 순열 사이의
전단사를 다루는 크누스의 삼부작 가운데 셋째 편이다. 첫째 편
{\mc FLOORPLAN-TO-TWINTREE}가 플로어플랜에서 쌍둥이 나무를, 둘째 편
{\mc TWINTREE-TO-BAXTER}가 쌍둥이 나무에서 백스터 순열을 만들고, 이 프로그램이
다시 플로어플랜으로 돌려놓는다. 프로그램이 찍는 말과 종료 부호는 원본 그대로
두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

옮기다가 원본의 결함 둘을 만났다. 원소가 너무 많으면 배열 밖에 쓰는 것과, 넘치는
수를 엉뚱한 수로 읽어 받아들이는 것이다. 모두 고쳤고, 맨 뒤의 ``옮기며 고친 것''에
모아 적었다.

@ 크누스는 잘못된 자료를 만나면 |reject|로 종료 부호 $-666$을 내고 멈춘다. 원본에서는
매크로이고 이름이 |panic|이다. \GO/에서는 |panic|이 미리 정의된 이름이라 바꾸었다.
원본은 모순을 만났을 때 쓰는 |pan|도 정의하지만, 이 프로그램에서는 한 번도 쓰지
않으므로 옮기지 않았다.

@<함수들@>=
func reject(m string, k int) {
	fmt.Fprintf(os.Stderr, "%s! (%d)\n", m, k)
	os.Exit(-666)
}

@ 뼈대는 이렇다. 순열을 읽고, 백스터 순열인지 살피고, 플로어플랜을 계산해 찍는다.

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
	var i, j, k, l, m, n int
	@<순열을 읽는다@>@;
	@<백스터 순열인지 살핀다@>@;
	@<플로어플랜을 계산한다@>@;
	@<플로어플랜을 찍는다@>@;
	out.Flush()
}

@ @<상수@>=
const maxn = 1024

@ 원소마다 범위 안에 있는지 보고, 끝에 원소의 수가 가장 큰 원소와 같은지, 빠진
원소가 없는지를 본다. 그러는 김에 역순열 |q|를 계산한다.

원본은 원소의 수가 |maxn|을 넘는지를 다 읽은 뒤에야 본다. 그 전에 |p[n+1]|에 쓰니,
원소가 |maxn|개를 넘으면 배열 밖에 쓴다. 이 판은 |maxn+1|번째 원소를 읽으면 멈춘다.
이 말은 이 판에서 지은 것이다.

@<순열을 읽는다@>=
for m, n = 0, 0; readInt(&inx); n++ {
	if inx <= 0 || inx > maxn {
		reject("element out of range", inx)
	}
	if n == maxn {
		reject("more elements than maxn", maxn)
	}
	if inx > m {
		m = inx
	}
	p[n+1] = inx
}
@<원소의 수를 살피고 역순열을 계산한다@>@;

@ @<원소의 수를 살피고 역순열을 계산한다@>=
if m > n {
	reject("too few elements", m-n)
}
if m < n {
	reject("too many elements", n-m)
}
for k = 1; k <= n; k++ {
	q[p[k]] = k // 역순열을 계산한다
}
for k = 1; k <= n; k++ {
	if q[k] == 0 {
		reject("missing element", k)
	}
}

@ 원본은 \CEE/의 |fscanf|로 정수를 읽는다. 빈칸 문자를 건너뛰고, 부호가 있으면
읽고, 숫자를 읽는다. 숫자가 하나도 없거나 입력이 끝나면 실패이고, 그러면 원본은
거기서 읽기를 그만둔다.

수가 넘칠 때는 다르다. 원본의 |fscanf|가 |int|에 담기에 너무 큰 수를 만나면
\CEE/ 표준으로는 정의되지 않은 동작이다. 내 컴퓨터에서는 $2^{32}$로 나눈 나머지를
읽었다. 그래서 `\.{2 4294967297}'을 순열 `\.{2 1}'로 받아들였다. 이 판은 수를 그대로
읽는다. 다만 읽던 값이 $2^{40}$을 넘으면 그 뒤의 자리는 버린다. 어차피 범위 밖이라
거절되니, 넘치지만 않으면 된다.

@<함수들@>=
func readInt(p *int) bool {
	c, err := in.ReadByte()
	for err == nil && (c == ' ' || c >= '\t' && c <= '\r') {
		c, err = in.ReadByte()
	}
	if err != nil {
		return false
	}
	neg := c == '-'
	if c == '-' || c == '+' {
		if c, err = in.ReadByte(); err != nil {
			return false
		}
	}
	@<숫자들을 읽어 |*p|에 담는다@>@;
}

@ 숫자가 아닌 글자를 만나면 되돌려 놓는다.

@<숫자들을 읽어 |*p|에 담는다@>=
if c < '0' || c > '9' {
	in.UnreadByte()
	return false
}
v := 0
for ; err == nil && c >= '0' && c <= '9'; c, err = in.ReadByte() {
	if v < 1<<40 {
		v = 10*v + int(c-'0')
	}
}
if err == nil {
	in.UnreadByte()
}
if neg {
	v = -v
}
*p = v
return true

@ @<전역 변수@>=
var (
	inx  int // |readInt|로 읽는 원소
	p, q [maxn + 1]int
	in   = bufio.NewReader(os.Stdin)
	out  = bufio.NewWriter(os.Stdout)
)

@ 다음 검사는 이차 시간이 걸릴 수도 있다. 크누스가 되도록 간단하게 짰기 때문이다.

백스터 성질을 선형 시간에 시험하고 싶다면 꾀를 부리는 방법이 있다. (1)~순열~$P$를
{\mc OFFLINE-TREE-INSERTION}에 넣는다. (2)~그것을 뒤집은 $P^R$도
{\mc OFFLINE-TREE-INSERTION}에 넣는다. (3)~두 출력을 고쳐 쌍둥이 나무를 만들고, 그
쌍둥이 나무를 {\mc TWINTREE-TO-BAXTER}에 넣는다. (4)~그 결과를 $P$와 견준다. $P$가
백스터 순열이면 $P$가 그대로 돌아온다. [사실 거의 같은 방법을 Johnson M. Hart가
{\sl International Journal of Computer and Information Sciences\/ \bf9} (1980),
307--321에 발표했다. 두 접근법을 견주어 보면 배울 것이 있다.]

[이 검사를 빼면 반대각선 순열이~$P$인 플로어플랜을 얻는다. 그러나 $P$가 백스터
순열이 아니면 그 플로어플랜의 {\it 대각선\/} 순열은 1~2~\dots~$n$이 아니다.]

@ $k=1$에는 작은 수가 없고 $k=n-1$에는 큰 수가 없으니, $k$는 2부터 $n-2$까지만 보면
된다. $k$와 $k+1$ 사이에 있는 원소는 $k$도 $k+1$도 아니니, 그 사이에서는 $k$보다 큰
것이 곧 $k+1$보다 큰 것이다.

@<백스터 순열인지 살핀다@>=
for k = 2; k < n-1; k++ {
	if q[k] < q[k+1] {
		for l = q[k] + 1; l < q[k+1]-1; l++ {
			if p[l] > k && p[l+1] < k {
				reject("not Baxter **", k)
			}
		}
	} else {
		for l = q[k+1] + 1; l < q[k]-1; l++ {
			if p[l] < k && p[l+1] > k {
				reject("not Baxter *", k)
			}
		}
	}
}

@* 핵심 알고리즘.
여기서는 특히 멋진 방법을 쓸 수 있다. Eyal Ackerman, Gill Barequet, Ron Y. Pinter의
통찰 덕분이다 [{\sl Discrete Applied Mathematics\/ \bf154} (2006), 1674--1684].
$P$를 따라 걸어가며 방마다 네 경계 |lft|, |bot|, |rt|, |top|을 체계적으로 채울 수
있다. 최종 평면도에 무언가를 보태는 사이사이에 작고 한정된 걸음만 쓰므로 선형
시간이 걸린다.

알고리즘은 스택 둘 |RLmin|과 |RLmax|를 유지한다. 두 스택은 지금까지 읽은 순열에서
오른쪽에서 왼쪽으로 본 최솟값들과 최댓값들을 담는다. |RLmin|에 있는 방은 꼭
|lft|와 |bot|은 채웠지만 |top|은 아직 채우지 않은 방들이다. |RLmax|에 있는 방은 꼭
|lft|와 |bot|은 채웠지만 |rt|는 아직 채우지 않은 방들이다.

배열 |bot|과 |top|의 값은 가로 경계의 번호이고, |lft|와 |rt|의 값은 세로 경계의
번호다.

끝에 가서 채우지 않은 |rt|와 |top|은 채울 필요가 없다. 그 값은 0이고, 그것이 바로
우리가 바라는 값이다.

크누스는 이 알고리즘이 ``믿기 어려울 만큼 좋다''고 했다! 그러나 옳다. 반대각선
순서로 플로어플랜을 한 걸음씩 짓는 것으로 볼 수 있기 때문이다.

@<플로어플랜을 계산한다@>=
minptr, maxptr, j = 1, 1, p[1]
RLmin[0], RLmax[0], lft[j], bot[j] = j, j, n, n
for k = 1; k < n; k++ {
	i, j = p[k], p[k+1] // |i|는 |RLmin|과 |RLmax| 둘 다의 꼭대기에 있다
	if i < j {
		@<새 세로 경계를 만든다@>@;
	} else {
		@<새 가로 경계를 만든다@>@;
	}
}

@ 오름 $i<j$에서는 새 세로 경계 $n-k$를 만든다. 그것이 $i$의 오른쪽 경계이자 $j$의
왼쪽 경계다. $i$는 $j$보다 작으니 더는 오른쪽에서 왼쪽으로 본 최댓값이 아니다.
|RLmax|에서 $j$보다 작은 방들도 모두 오른쪽 경계가 이 새 경계로 정해진다. $j$의 아래
경계는 |RLmax|에 남은 꼭대기 방의 위 경계이고, 그런 방이 없으면 맨 아래 경계 $n$이다.

@<새 세로 경계를 만든다@>=
lft[j], rt[i] = n-k, n-k
maxptr--
RLmin[minptr] = j
minptr++
for maxptr > 0 && RLmax[maxptr-1] < j {
	maxptr--
	rt[RLmax[maxptr]] = n - k
}
if bot[j] = n; maxptr > 0 {
	bot[j] = top[RLmax[maxptr-1]]
}
RLmax[maxptr] = j
maxptr++

@ 내림 $i>j$에서는 가로와 세로, 최솟값과 최댓값을 맞바꾸어 똑같이 한다.

@<새 가로 경계를 만든다@>=
bot[j], top[i] = n-k, n-k
minptr--
RLmax[maxptr] = j
maxptr++
for minptr > 0 && RLmin[minptr-1] > j {
	minptr--
	top[RLmin[minptr]] = n - k
}
if lft[j] = n; minptr > 0 {
	lft[j] = rt[RLmin[minptr-1]]
}
RLmin[minptr] = j
minptr++

@ @<전역 변수@>=
var (
	lft, bot, rt, top [maxn + 1]int
	RLmin, RLmax      [maxn]int // 두 스택
	minptr, maxptr    int       // 지금의 스택 크기
)

@ 경계의 번호를 $n$에서 빼서 이름을 붙인다. 그러면 가로 경계 \.{y0}이 맨 아래,
세로 경계 \.{x0}이 맨 왼쪽이 된다.

@<플로어플랜을 찍는다@>=
for k = 1; k <= n; k++ {
	fmt.Fprintf(out, "%d y%d y%d x%d x%d\n", k, n-top[k], n-bot[k], n-lft[k], n-rt[k])
}

@* 옮기며 고친 것.
원본의 결함은 둘이었다. 저마다 그 자리에서 이야기했으니 여기서는 모아만 둔다.

\smallskip
\item{$\bullet$} 원소의 수가 |maxn|을 넘는지를 다 읽은 뒤에야 보아서, 그 전에 배열
|p| 밖에 쓴다. 원소 1100개를 넣으면 \.{UndefinedBehaviorSanitizer}가 |p[1025]|에
쓰는 것을 잡는다. 이 판은 ``\.{more elements than maxn}''을 종료 부호 $-666$과
함께 내고 멈춘다.
\item{$\bullet$} \CEE/의 |fscanf|는 |int|에 담기에 너무 큰 수를 엉뚱한 수로 읽는다.
내 컴퓨터에서는 \.{4294967297}이 1이 되어, `\.{2 4294967297}'을 순열 `\.{2 1}'로
받아들였다. 이 판은 수를 그대로 읽어 범위 밖이라고 거절한다.
\smallskip

\noindent 원본의 |main|은 `\.{void main(void)}'이라 제대로 끝나도 종료 부호가
정해지지 않는다. 이 판은 0을 돌려준다. 서술에는 영어 문장의 작은 오타가 둘
있었다. $j\Uparrow k$ 뒤에 군더더기 `$<$'가 붙은 것과, ``if and only if''에서
``if''가 하나 빠진 것이다. 번역하면서 저절로 고쳐졌다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀어 컴파일하고 이 판과 견주었다. (요즘의 \.{clang}은 원본을
받아 주지 않아서 \.{-std=gnu89}로 컴파일했다.) 견준 것은 표준 출력과 표준 오류가
바이트까지 같은지다.

\smallskip
\item{$\bullet$} 크기 8까지의 순열을 빈 순열까지 모두, 곧 $46234$개를 넣었다.
출력이 모두 원본과 같았다. 원본과 이 판 모두 백스터 순열 $13373$개만 받아들였다.
\item{$\bullet$} 받아들인 $13373$개의 플로어플랜이 정말 플로어플랜인지는 원본과 따로
따져 보았다. 경계마다 좌표를 가장 긴 경로로 정하고, 방들의 넓이의 합이 전체와
같은지, 어느 두 방도 겹치지 않는지, 경계마다 양쪽의 방들이 같은 구간을 빈틈없이
덮는지를 보았다. 모두 맞았다. (이 판정은 첫째 편에서 찾은, 원본이 조용히 받아들이던
잘못된 명세를 바르게 거절한다.)
\item{$\bullet$} 들어가며에 적은 주장들도 크기 7까지의 백스터 순열 $2618$개에서
확인했다. 같은 경계를 사이에 둔 이웃의 사슬로 네 방향 관계를 정하면, 그것이 앞의
네 규칙과 맞았다. 가로 경계와 세로 경계의 수는 내림과 오름의 수보다 둘씩 많았다.
$P^R$, $P^C$, $P^-$은 저마다 주대각선, 다른 대각선, 위아래에 대해 뒤집은 플로어플랜을
낳았다.
\item{$\bullet$} 형식이 잘못된 입력 $20000$개를 넣었다. 원소가 겹치거나 빠지거나 범위
밖인 것, 부호나 잡글자가 섞인 것, 탭이나 \.{CR LF}로 가른 것이다. 출력이 모두 원본과
같았다.
\item{$\bullet$} 무작위 순열에서 크기 1024까지의 백스터 순열 $200$개를 만들었다.
이진 탐색 나무로 쌍둥이 나무를 만들어 {\mc TWINTREE-TO-BAXTER}에 넣는 것이다. 출력이
원본과 같았다.
\item{$\bullet$} 삼부작의 세 편을 모두 이 \.{GWEB} 판들로 엮어 크기 8까지의 백스터
순열 $13373$개를 한 바퀴 돌렸다. 이 프로그램으로 플로어플랜을 만들고, 변경 파일을
적용한 {\mc FLOORPLAN-TO-TWINTREE}로 쌍둥이 나무를 만들고, {\mc TWINTREE-TO-BAXTER}로
백스터 순열을 얻었다. 모두 처음 순열로 돌아왔다.
\smallskip

@* 색인.
