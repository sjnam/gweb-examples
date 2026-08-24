\input kotexgweb
\input luamplib.sty

% 그림 셋(fig_S, fig_T, fig_ST)은 matula.mp 안에 있다.
\everymplib{input matula;}

\def\title{마툴라의 부분나무}

\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}
\def\dts{\mathinner{\ldotp\ldotp}}

@* 들어가며.
그래프 하나가 다른 그래프 안에 들어 있는지 묻는 일---부분그래프 동형 문제---은
어렵기로 이름났다. 클리크 찾기도 해밀턴 경로 찾기도 그 특수한 경우이니, NP-완전인
것이 당연하다. 그런데 두 그래프가 모두 {\it 나무\/}라면 이야기가 달라진다. 다항
시간에 풀린다.

이 프로그램은 자유 나무~$S$가 다른 자유 나무~$T$의 부분나무와 동형인지를
가려낸다. David~W. Matula가 1978년에 펴낸 알고리즘을 쓴다 [{\sl Annals of
Discrete Mathematics\/} {\bf 2} (1978), 91--106]. 크누스는 이렇게 적었다:
``그의 알고리즘은 꽤 효율적이다. 사실은 그가 생각했던 것보다도 빠르다!''
나무 $S$의 마디가 $m$개, $T$의 마디가 $n$개일 때 실행 시간은 최악의 경우에도
$mn$에 $S$의 안쪽 차수의 최댓값의 제곱근을 곱한 것에 비례한다. 여기서 마디의
{\it 안쪽 차수\/}란 잎이 아닌 이웃의 수다.

@ Matula라는 이름이 낯익다면 그럴 만하다. 뿌리 있는 나무마다 자연수 하나를
소인수분해로 붙이는 {\it 마툴라 수\/}가 같은 사람의 것이다 [{\sl SIAM Review\/}
{\bf 10} (1968), 273]. 나무 $t$의 번호가 $n$이면, 뿌리에 아들 하나를 더 달아
만든 나무의 번호는 $n$번째 소수다. 크누스가 TAOCP 7.2.1.6절 연습문제에서 다룬다.

@ 이 프로그램은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{matula.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/matula.w}를
\.{GWEB}으로 옮긴 것이다. 옮길 만한 까닭이 하나 더 있다. 이 알고리즘의 알맹이가
{\it 이분 그래프 짝짓기\/}이고, 크누스 자신이 원본에 ``\.{HOPCROFT-KARP}에서
코드를 거의 다 훔쳐 왔다''고 적어 두었기 때문이다. 우리는 바로 앞서 그
\.{HOPCROFT-KARP}를 \.{hopcroft-karp.w}로 옮겨 두었으니, 이 글은 그것의
자연스러운 속편이다.

@ 두 나무는 명령줄에서 각각 ``부모 포인터''의 문자열로 준다. 마디 하나에 글자
하나다. 첫 글자는 언제나 \..으로, 있지도 않은 뿌리의 부모를 뜻한다. 그다음 글자는
언제나 \.0으로, 마디~$1$의 부모다. 그리고 $(k+1)$번째 글자가 마디~$k$의 부모인데,
$k$보다 작은 아무 수나 될 수 있다. \.9보다 큰 수는 소문자로, \.z($35$를 뜻한다)보다
큰 수는 대문자로 적는다. \.Z($61$)보다 큰 수는 지금으로서는 쓸 수 없다.

나무 $S$의 뿌리는 차수가~$1$이라고 가정한다. 그러니 뿌리이면서 잎이기도 하고,
$S$의 문자열에는 \.0이 딱 한 번만 나온다.

@ 이를테면 이런 나무 둘이 초기 시험에 쓰였다.
$$\eqalign{S&=\.{.0111444759a488cfch};\cr
T&=\.{.011345676965cc5ffh5cklfn55qjstuuwxxwwuCCuFCpppqrtGOHJRLMNO};\cr}$$
$T$ 안에서 $S$를 찾을 수 있겠는가?
$$\mplibcode fig_S; \endmplibcode$$
\figcap{나무 $S$. 마디 $19$개다.}
$$\mplibcode fig_T; \endmplibcode$$
\figcap{나무 $T$. 마디 $59$개다. 답은 마지막 장에 있다.}

@ 프로그램에는 계측기가 달려 있다. 여덟 바이트짜리 메모리를 짚은 횟수, 곧
{\it mem\/}을 센다. (실제로 짚는 것은 대개 네 바이트짜리 |int|인데, 이 프로그램은
같은 여덟 바이트 안에 있다고 알려진 네 바이트 둘을 함께 다루는 일이 드물다.)

\CEE/에서는 쉼표 연산자를 써서 |o,x=y[i]|처럼 셈과 계산을 한 줄에 얹는다.
\GO/에는 쉼표 연산자가 없으니, 값 하나를 셈하는 자리에서는 |mems++|를 앞에 붙이고,
반복문의 머리처럼 식 자리에서 세야 할 때는 |mems, k = mems+1, next[k]|라는 여럿
대입을 쓴다. 그래서 mem 수가 원본과 한 자리도 다르지 않다.

@ 뼈대는 짧다. 명령줄에서 두 나무를 읽어 들이고, 풀고, 알린다.

@c
package main

import (
	"fmt"
	"os"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 처리한다@>@;
	imems, mems = mems, 0
	if m > n {
		fmt.Fprintln(os.Stderr, "마디 수가 m > n이니 답이 없다!")
	} else {
		z = solve(1)
		@<답을 알린다@>@;
	}
	fmt.Fprintf(os.Stderr, "모두 해서 %d+%d mem.\n", imems, mems)
}

@ @<상수@>=
const (
	maxn        = 62       // 입력 방식을 바꾸면 훨씬 키울 수 있다
	maxg        = 2 * maxn // 소녀 수의 상한
	maxt        = maxn * maxg // 이분 그래프 변 수의 상한
	suboverhead = 10       // 함수 부름마다 매기는 mem
)

@ @<전역 변수@>=
var (
	mems  int64 // 메모리를 짚은 횟수
	imems int64 // 그 가운데 입력에 든 것
)

@ 마디 번호를 글자로, 글자를 마디 번호로 옮기는 일은 여기저기서 쓰인다. 원본은
매크로로 두었으니 mem을 매기지 않는다.

@<함수들@>=
func decode(c byte) int {
	switch {
	case c >= '0' && c <= '9':
		return int(c - '0')
	case c >= 'a' && c <= 'z':
		return int(c-'a') + 10
	case c >= 'A' && c <= 'Z':
		return int(c-'A') + 36
	}
	return -1
}

func encode(p int) byte {
	switch {
	case p < 10:
		return byte(p) + '0'
	case p < 36:
		return byte(p-10) + 'a'
	case p < 62:
		return byte(p-36) + 'A'
	}
	return '?'
}

@ @<지역 변수@>=
var d, e, g, k, m, n, p, q, v, z int

@ @<명령줄을 처리한다@>=
if len(os.Args) != 3 {
	fmt.Fprintf(os.Stderr, "쓰는 법: %s S의부모들 T의부모들\n", os.Args[0])
	os.Exit(1)
}
sarg, targ = os.Args[1], os.Args[2]
@<나무 $S$를 읽는다@>@;
@<나무 $T$를 읽는다@>@;

@ @<전역 변수@>=
var sarg, targ string // 명령줄에서 받은 두 나무

@* 나무를 담는 그릇.
나무의 마디마다 |node| 레코드를 하나씩 둔다. 항목이 넷이다: |child|(가장 최근에
달린 아들), |sib|(부모의 이전 아들), |deg|(이웃의 수), |arc|(부모로 가는 호의
번호). 밭 |deg|와 |arc|는 $S$에서는 쓰이지 않고 $T$에서만 필요하다. 같은 마디의
|deg|와 |arc|를 짚는 것은 mem 하나로 친다.

@<자료형@>=
type node struct {
	child int // 내 첫 아들은 누구인가
	sib   int // 부모의 다음 아들은 누구인가
	deg   int // 부모까지 넣어 이웃이 몇인가
	arc   int // 나에게서 부모로 가는 이음줄은 몇 번 호인가
}

@ @<전역 변수@>=
var (
	snode [maxn]node // $S$의 마디 $m$개
	tnode [maxn]node // $T$의 마디 $n$개
)

@ 읽어 들이기는 곧이곧대로다. 글자를 하나씩 풀어 부모를 알아내고, 그 부모의
아들 목록 앞에 매단다.

@<나무 $S$를 읽는다@>=
mems++
if sarg[0] != '.' {
	fmt.Fprintln(os.Stderr, "S의 뿌리는 부모가 `.'이어야 한다!")
	os.Exit(10)
}
for m = 1; ; m++ {
	mems++
	if m >= len(sarg) {
		break
	}
	@<$S$의 마디 |m|을 매단다@>@;
}

@ @<$S$의 마디 |m|을 매단다@>=
if m == maxn {
	fmt.Fprintf(os.Stderr, "미안하다, S의 마디는 많아야 %d개다!\n", maxn)
	os.Exit(11)
}
p = decode(sarg[m])
@<$S$의 부모 |p|가 옳은지 따진다@>@;
mems += 2
q, snode[p].child = snode[p].child, m // |m|이 첫 아들이 된다
mems++
snode[m].sib = q

@ @<$S$의 부모 |p|가 옳은지 따진다@>=
if p < 0 {
	fmt.Fprintf(os.Stderr, "S에 이상한 글자 `%c'가 있다!\n", sarg[m])
	os.Exit(12)
}
if p >= m {
	fmt.Fprintf(os.Stderr, "%c의 부모는 %c보다 작아야 한다!\n", encode(m), encode(m))
	os.Exit(13)
}
if p == 0 && m > 1 {
	fmt.Fprintln(os.Stderr, "S의 뿌리는 아들이 하나뿐이어야 한다!")
	os.Exit(13)
}

@ $T$ 쪽도 똑같다. 다만 뿌리의 아들 수에는 제한이 없다.

@<나무 $T$를 읽는다@>=
mems++
if targ[0] != '.' {
	fmt.Fprintln(os.Stderr, "T의 뿌리는 부모가 `.'이어야 한다!")
	os.Exit(20)
}
for n = 1; ; n++ {
	mems++
	if n >= len(targ) {
		break
	}
	@<$T$의 마디 |n|을 매단다@>@;
}
@<호에 번호를 매긴다@>@;
fmt.Fprintf(os.Stderr, "좋다, S의 마디 %d개와 T의 마디 %d개를 얻었다. 최대 차수는 %d.\n",
	m, n, maxdeg)

@ @<$T$의 마디 |n|을 매단다@>=
if n == maxn {
	fmt.Fprintf(os.Stderr, "미안하다, T의 마디는 많아야 %d개다!\n", maxn)
	os.Exit(21)
}
p = decode(targ[n])
if p < 0 {
	fmt.Fprintf(os.Stderr, "T에 이상한 글자 `%c'가 있다!\n", targ[n])
	os.Exit(22)
}
if p >= n {
	fmt.Fprintf(os.Stderr, "%c의 부모는 %c보다 작아야 한다!\n", encode(n), encode(n))
	os.Exit(23)
}
mems += 2
q, tnode[p].child = tnode[p].child, n
mems++
tnode[n].sib = q

@ 목표 나무~$T$에는 호가 $2(n-1)$개 있다. 뿌리가 아닌 마디마다 부모로 가는 것
하나와 그 반대 하나다. 마디 $u$에서 $v$로 가는 호에는 $0$부터 $2n-3$까지의 정수를
(deg($v$), $v$, $u$)의 사전식 차례로 매긴다. (엄밀히 말하면 둘째와 셋째 성분은
번호 차례가 아닐 수도 있다. 하지만 차수가~$d$인 꼭짓점에서 나가는 호 $d$개는
언제나 잇달아 놓이고, 그 첫 번째가 부모로 가는 호다.)

번호를 매기려면 차수가 같은 마디들의 목록이 있어야 하는데, |arc| 항목을 잠시
빌려 그것들을 엮는다.

@<함수들@>=
func fixdeg(p int) {
	var d, q int
	mems += suboverhead
	for mems, d, q = mems+1, 1, tnode[p].child; q != 0; mems, d, q = mems+1, d+1, tnode[q].sib {
		fixdeg(q)
	}
	if p != 0 { // |p|는 뿌리가 아니다. 부모까지 넣어 이웃이 |d|명이다
		mems += 3
		tnode[p].arc, tnode[p].deg, head[d] = head[d], d, p
	} else { // 뿌리는 잠시 $-1$이라는 이름으로 부른다
		mems += 3
		tnode[0].arc, tnode[0].deg, head[d-1] = head[d-1], d-1, -1
	}
}

@ |thresh[d]|에는 차수가 $d$ 이상인 마디의 첫 호 번호를 넣는다.

@<호에 번호를 매긴다@>=
fixdeg(0)
for d, e = 1, 0; e < 2*n-2; d++ {
	mems++
	thresh[d] = e
	for mems, p = mems+1, head[d]; p != 0; e, p = e+d, q {
		if p < 0 {
			p = 0
		}
		mems += 2
		q, tnode[p].arc = tnode[p].arc, e
	}
}
@<차수가 큰 쪽의 문턱도 채운다@>@;
@<쌍대 호에 번호를 매긴다@>@;

@ 이 대목에는 사연이 있다. 내가 옮기기 시작한 판에서 크누스는 남은 문턱을
$$\hbox{\.{for (maxdeg=d-1,emax=e;d<m;d++) o,thresh[d]=emax;}}$$
로 채웠다. 곧 차수가 $m-1$인 자리까지다. 그런데 |solve|는 |thresh[n+1]|을 |n|이
$T$의 최대 차수에 이를 때까지 읽는다. 그러니 $T$의 최대 차수가 $S$의 마디 수
이상이면 |thresh[maxdeg+1]|은 한 번도 채워진 적 없는 칸이 된다. 거기 있어야 할
값은 |emax|인데 실제로 읽히는 것은 $0$이다.

@ 최대 차수가 $61$이면 한 술 더 뜬다. 그 판의 |thresh|는 |maxn|칸이라 첨자가 $0$
부터 $61$까지인데 |thresh[62]|를 짚는다. 배열 밖이다. \CEE/ 표준으로는 무슨 일이
일어나도 좋은 자리이고, 무엇이 읽힐지는 링커가 그 주소에 무엇을 놓았느냐에
달린다. 내가 컴파일해 주소를 찍어 보니 마침 |tip[0]|과 겹쳤다. 배열 |tip|은 첨자를
언제나 $1$부터 쓰므로 그 칸은 끝까지 $0$인 채로 남고, 그래서 프로그램은 아무 일
없다는 듯 지나간다. \GO/에서는 그 자리에서 죽는다. 내가 이것을 알아챈 것도
옮겨 놓은 판이 거기서 멈춰 섰기 때문이다.

@ 값이 $0$인 덕에 답이 틀어지지는 않는다. 읽히는 값이 |e|와 같아야 반복문이 |n|을
잘못 올릴 텐데, |e|는 결코 $0$이 될 수 없기 때문이다. 그 |e|는 |thresh[r+1]|에서
시작하고 여기서 $r\ge1$이며, 나무에는 잎이 적어도 둘 있으니 |thresh[2]|는 $2$
이상이다.

그러나 지켜 주는 것이 이웃 칸의 값일 뿐이라는 것도 분명하다. 배열 |thresh| 바로 뒤에
칸을 하나 붙여 그 값을 골라 넣어 보았더니, $S=\.{.01}$이고 $T$가 별 모양으로 마디
$62$개일 때 이렇게 갈렸다.
$$\vbox{\halign{\hfil#\quad&#\hfil\cr
\noalign{\hrule\smallskip}
이웃 칸&답\cr
\noalign{\smallskip\hrule\smallskip}
$0$&\.{There are 61 places...}\quad(맞다)\cr
$61$&\.{There are 62 places...}\quad(틀리다)\cr
\noalign{\smallskip\hrule}}}$$
$61$이 들어 있으면 $e=61$, $n=61$에서 비교가 참이 되어 |n|이 $62$로 오르고, 이어서
|thresh[63]|까지 더 멀리 짚는다. 그 자리에 놓일 만한 전역들---|head|, |maxdeg|,
|vert|, |dual|, |tip|, |next|---은 모두 마디나 호의 번호를 담으니, 링커의 배치가
달랐다면 실제로 겪을 수 있는 일이었다.

@ 그래서 나는 배열을 한 칸 늘리고 |maxdeg+1|까지 반드시 채우도록 고쳐 두었다.
그런데 이 글을 쓰는 사이에 크누스가 사이트의 파일을 갈았다. 머리글 \.{Last-Modified}가
\.{Thu, 20 Aug 2026 18:40:21 GMT}인 새 판은 바로 이 두 자리를 이렇게 고쳤다.
$$\vbox{\halign{\.{#}\hfil\cr
-for (maxdeg=d-1,emax=e;d<m;d++) o,thresh[d]=emax;\cr
+o,maxdeg=d-1,thresh[d++]=e;\cr
+for (emax=e;d<m;d++) o,thresh[d]=emax;\cr
\noalign{\smallskip}
-int thresh[maxn];\cr
+int thresh[maxn+1];\cr}}$$
배열 크기는 내가 잡은 것과 글자까지 같다. 채우는 쪽은 모양이 다르다. 나는 반복문의
조건을 넓혔고 그는 문제의 칸을 한 줄로 먼저 써 넣은 뒤 |d|를 하나 올렸는데, 쓰이는
값도 드는 mem도 똑같다. 그러니 여기 있는 \GO/ 코드는 새 판을 그대로 옮긴 것이기도
하다. 남의 프로그램을 고쳤다기보다, 같은 자리에서 같은 결론에 다다른 셈이다.

@<차수가 큰 쪽의 문턱도 채운다@>=
for maxdeg, emax = d-1, e; d < m || d <= maxdeg+1; d++ {
	mems++
	thresh[d] = emax
}

@ 마디 $u$에서 $v$로 가는 호에는 쌍대가 있다. 거꾸로 $v$에서 $u$로 가는 호다. 부모로 가는
호에는 이미 번호를 매겼으니, 나머지가 그 쌍대다.

@<쌍대 호에 번호를 매긴다@>=
for p = 0; p < n; p++ {
	mems += 2
	e = tnode[p].arc
	if p == 0 {
		e--
	}
	for q = tnode[p].child; q != 0; mems, q = mems+1, tnode[q].sib {
		@<호 |q|와 그 쌍대를 맺어 준다@>@;
	}
}

@ @<호 |q|와 그 쌍대를 맺어 준다@>=
mems += 3
e++
a := tnode[q].arc
dual[a], dual[e] = e, a
mems += 4
vert[e], uert[a] = p, p
uert[e], vert[a] = q, q

@ 문턱 배열을 한 칸 넉넉히 잡은 것이 위에서 말한 손질이다.

@<전역 변수@>=
var (
	head   [maxn]int      // 차수별 목록의 머리
	maxdeg int            // 보아 온 최대 차수
	thresh [maxn + 1]int  // 차수가 큰 마디의 호가 어디서 시작하는가
	vert   [maxn + maxn]int // 호마다 그 출발 꼭짓점
	uert   [maxn + maxn]int // 호마다 그 도착 꼭짓점
	dual   [maxn + maxn]int // 호마다 그 쌍대
	emax   int              // 호의 총수
)

@* 지휘부.
계산 전체를 다스리는 것은 |sol|이라는 이차원 배열이다. 첫째 첨자~|p|는 $S$의
마디이고, 둘째 첨자~|e|는 $T$의 호다. 그 |e|가 $u$에서 $v$로 가는 호라 하고,
$u$에 뿌리를 두면서 $v$를 품는 $T$의 부분나무를 생각하자. 그것을
``부분나무~|e|''라 부르기로 한다. 이제 |p|에 뿌리를 둔 $S$의 부분나무를, |p|를 $v$에
맞추어 부분나무~|e|에 심을 길이 없으면 |sol[p][e]|를 $0$으로 둔다. 그렇지 않으면
$0$이 아닌 값을 두는데, 그 값에서 심는 법을 되짚어 낼 수 있다.

@ 착상은 단순하다. 작은 부분나무에서 큰 것으로 거슬러 올라가며 재귀로 푼다.
마디 $p$에게 아들이 $r$명 $q_1$, \dots, $q_r$ 있고, $v$에게 이웃이 $s+1$명 $u_0$,
\dots, $u_s$ 있다고 하자. 그리고 $1\le i\le r$과 $0\le j\le s$에 대해
$|sol|[q_i][e_j]$를 이미 셈해 두었다고 하자. 여기서 $e_j$는 $v$에서 $u_j$로 가는
호다. 그러면 Matula의 알고리즘이 $0\le j\le s$에 대한 $|sol|[p][|dual|[e_j]]$를
어떻게 셈하는지 알려 준다. 그렇게 |sol|의 행을 아래에서 위로 채워 나가면,
마침내 |sol[1]|이 $S$ {\it 전체\/}를 심을 수 있는지를 말해 준다.

@ 그 알맹이가 되는 작은 문제를 자세히 들여다보자. 이를테면
$|sol|[p][|dual|[e_0]]$이 $0$이어야 하는지 아닌지를 어떻게 아는가? 그것은
$u_0$에서 $v$로 가는 호 아래의 부분나무에 부분나무~|p|를 심으려는 것이다.
그리고 이 문제가 풀리는 것은, |p|의 아들 $q_i$마다 |v|의 서로 다른 아들 $u_j$를
짝지어 주되 $|sol|[q_i][e_j]$가 $0$이 아니게 할 수 있을 때, 오직 그때뿐이다.

아하, 그렇다. {\it 이분 그래프 짝짓기 문제\/}다! 그리고 이분 그래프 짝짓기에는
좋은 알고리즘이 있다!

@ 더 일반적으로, $u_j$가 $T$에서 $v$의 부모이고 $u_0$, \dots, $u_{j-1}$,
$u_{j+1}$, \dots, $u_s$가 아들인 문제를 생각해 보자. Matula는 이 작은 문제들이
$0$에서 $s$ 사이의 모든 $j$에 대해 본질적으로 같다는 것을 알아냈다. 닮은 문제들을
하나로 묶어 $n$배를 아끼는 아름다운 방법이다.

그래서 |solve|라는 재귀 함수를 쓴다. 마디~|p|를 받아 호~|e|마다 |sol[p][e]|의
값을 정하는 것이 그 일이다. 재귀의 바닥은 |p|가 잎일 때인데, 잎은 어디에나
심을 수 있다. 또 하나 쉬운 경우는 $T$의 부분나무~|e|가 차수가 너무 작아 아무것도
심을 수 없을 때다.

마디 |p|의 자손 |d| 가운데 심을 수 없는 것이 있으면 |solve|는 $-d$를 돌려준다.
그렇지 않으면 |sol[p]| 안의 $1$의 개수를 돌려준다.

@<함수들@>=
func solve(p int) int {
	@<|solve|의 지역 변수@>@;
	mems += suboverhead
	mems++
	q = snode[p].child
	if q == 0 {
		@<잎은 어디에나 심을 수 있다@>@;
	}
	@<아들들을 먼저 푼다@>@;
	@<차수가 모자란 호를 지운다@>@;
	@<호를 |n|개씩 묶어 훑는다@>@;
	return z
}

@ @<|solve|의 지역 변수@>=
var b, e, f, g, gg, i, j, k, l, m, n, q, r, t, tt, pp, qq int
var finalLevel, marks, verdict, z int

@ @<잎은 어디에나 심을 수 있다@>=
for e = 0; e < emax; e++ {
	mems++
	sol[p][e] = 1
}
return emax

@ 아들 가운데 하나라도 심을 수 없으면 $S$ 전체를 심을 수 없다.

@<아들들을 먼저 푼다@>=
for r = 0; q != 0; mems, r, q = mems+1, r+1, snode[q].sib {
	z = solve(q)
	if z <= 0 {
		if z != 0 {
			return z
		}
		return -q
	}
}

@ 이제 |p|의 모든 아들~|q|와 모든 호~|e|에 대해 |sol[q][e]|를 안다.

@<차수가 모자란 호를 지운다@>=
mems++
for z, e = 0, 0; e < thresh[r+1]; e++ {
	mems++
	sol[p][e] = 0
}

@ 호는 차수가 같은 것끼리 잇달아 놓여 있으므로, |n|개씩 한 묶음으로 다룰 수 있다.
그것이 Matula의 요령이다.

@<호를 |n|개씩 묶어 훑는다@>=
for n = r + 1; e < emax; e += n {
	@<|n|을 |vert[e]|의 차수까지 올린다@>@;
	verdict = 0
	@<Matula의 짝짓기 문제를 세운다@>@;
	if verdict == 0 {
		@<그 문제를 풀고 |sol[p]|을 고친다@>@;
	}
	@<판정대로 |sol[p]|$[e\dts e+n-1]$을 채운다@>@;
}

@ @<|n|을 |vert[e]|의 차수까지 올린다@>=
for {
	mems++
	if e != thresh[n+1] {
		break
	}
	n++
}

@ 크누스는 여기서 |goto| 둘로 빠져나간다. 아무도 걸림이 없어 몽땅 $1$이 되는
자리로 가는 \.{yes\_sol}과, 한 소년이 아무 데도 못 맞아 몽땅 $0$이 되는
\.{no\_sol}이다. \GO/에서는 판정을 담는 값 하나로 접었다.

@<판정대로 |sol[p]|$[e\dts e+n-1]$을 채운다@>=
if verdict > 0 {
	for k = 0; k < n; k++ {
		mems++
		sol[p][e+k] = 1
	}
	z += n
} else if verdict < 0 {
	for k = 0; k < n; k++ {
		mems++
		sol[p][e+k] = 0
	}
}

@ @<전역 변수@>=
var sol [maxn][maxg]int // 지휘부의 행렬

@* 호프크로프트--카프의 짝짓기.
이제 고전적인 HK 알고리즘을 구현한다. 이 대목의 이야기와 증명은 짝꿍 프로그램
\.{hopcroft-karp.w}에 다 있으니 여기서는 되풀이하지 않는다. 여기서 |p|의 아들들이 그
알고리즘의 ``소년'' 노릇을 하고, |v|의 이웃으로 가는 호들이 ``소녀'' 노릇을 한다.

여기서는 알고리즘이 조금 간단해진다. 우리가 관심 있는 것은 소년이 모두 짝을
얻는 경우뿐이기 때문이다. (우리 경우에는 소녀가 언제나 소년보다 많다.)

@ Matula의 짝짓기 문제에서 |p|는 아들 $q_1$, \dots, $q_r$을 가진 $S$의 꼭짓점이고,
|e|는 |v=vert[e]|에서 |u=uert[e]|로 가는 $T$의 호이며, |v|에게는 이웃 $u_0$,
\dots, $u_s$가 있다. 짝짓기 문제에는 소년이 $m\le r$명, 소녀가 $n=s+1$명 나온다.

이분 그래프를 담는 자료 구조는 단순하다. 소녀~|j|와 짝지을 수 있는 소년들은
|glink[j]|에서 시작해 |next|로 이어지고 $0$으로 끝나는 목록에 있다. 이음줄~|l|이
가리키는 소년은 |tip[l]|이다.

@<Matula의 짝짓기 문제를 세운다@>=
@<소녀 |n|명을 위한 표를 채비한다@>@;
for mems, t, m, b = mems+1, 0, 0, snode[p].child; b != 0; mems, b = mems+1, snode[b].sib {
	@<소년 |b|가 짝지을 수 있는 소녀를 적어 둔다@>@;
	if verdict != 0 {
		break
	}
}
if verdict == 0 && m == 0 {
	verdict = 1 // 소년마다 아무 소녀나 좋다
}

@ @<소녀 |n|명을 위한 표를 채비한다@>=
for g = e; g < e+n; g++ {
	mems += 4
	glink[g], imate[g] = 0, 0
	queue[g-e], iqueue[g] = g, g-e
}
f = n

@ 소년~|b|가 모든 소녀와 짝지을 수 있다면 이분 그래프에 넣을 까닭이 없다.
(이런 일은 꽤 잦다. 이를테면 |b|가 잎이면 언제나 그렇다. 그러니 미리 따져 두는
것이 슬기롭다.) 거꾸로 어떤 소년이 어느 소녀와도 못 짝짓는다면, 짝짓기가 없다는
것을 미리 안다.

HK 알고리즘은 |mate| 표로 소년마다의 지금 짝을 적어 두고, 소녀 쪽에는 역표
|imate|를 둔다. 짝이 없으면 $0$이다.

@<소년 |b|가 짝지을 수 있는 소녀를 적어 둔다@>=
for g = e; g < e+n; g++ {
	mems += 2
	if sol[b][dual[g]] == 0 {
		break
	}
}
if g == e+n {
	continue // |b|는 아무 데나 맞으니 뺀다
}
mems += 2
m++
mate[b], mark[b] = 0, 0
@<|b|가 맞는 소녀들을 목록에 매단다@>@;
if k == t {
	verdict = -1 // |b|는 어디에도 못 맞는다
}

@ @<|b|가 맞는 소녀들을 목록에 매단다@>=
for k, gg = t, e; gg < g; gg++ {
	mems += 4
	t++
	tip[t], next[t], glink[gg] = b, glink[gg], t
}
for g++; g < e+n; g++ {
	mems += 2
	if sol[b][dual[g]] != 0 {
		mems += 4
		t++
		tip[t], next[t], glink[g] = b, glink[g], t
	}
}

@ 이제 소년 |m|명, 소녀 |n|명, 변 |t|개짜리 이분 그래프가 생겼다. HK 알고리즘은
{\it 판\/}을 거듭한다. 한 판마다 서로 꼭짓점을 나눠 갖지 않으면서 가장 짧은 증대
경로들을 더 못 고를 때까지 고른다. 많아야 $2\sqrt n$판이면 증대 경로가 다한다.
그때 짝 없는 소년이 없으면---곧 짝 없는 소녀가 $n-m$명이면---답이 있는 것이다.

@<그 문제를 풀고 |sol[p]|을 고친다@>=
for {
	@<최단 증대 경로의 dag를 짓는다@>@;
	if finalLevel < 0 {
		break // 증대 경로가 없다
	}
	@<겹치지 않는 최단 증대 경로를 끝까지 거둔다@>@;
}
if f == n-m {
	@<답을 |sol[p]|에 갈무리한다@>@;
} else {
	verdict = -1
}

@ HK 알고리즘의 열쇠는, $\top$이라는 가짜 꼭짓점에서 $\bot$이라는 가짜 꼭짓점으로
가는 길이 최단 증대 경로와 일대일로 대응하는 방향 비순환 그래프를 짓는 것이다.
소년~$i$에서 어울리는 소녀로 가는 첫 화살이 |blink[i]|에 있고, 소녀에게는 나가는
화살이 그의 |imate| 하나뿐이며, $\top$은 짝 없는 소년들의 목록 |dlink|를 가진다.
배열 |mark|는 소년이 몇 층에서 dag에 들어왔는지를 하나 더해 적어 둔다.

@<최단 증대 경로의 dag를 짓는다@>=
finalLevel, tt = -1, t
marks, l, i, q = 0, 0, 0, f
for {
	qq = q
	for ; i < qq; i++ {
		mems++
		g = queue[i]
		@<소녀 |g|를 원하는 소년들을 훑는다@>@;
	}
	if q == qq {
		break // 다음 층으로 넘길 것이 없다
	}
	l++
}

@ @<소녀 |g|를 원하는 소년들을 훑는다@>=
for mems, k = mems+1, glink[g]; k != 0; mems, k = mems+1, next[k] {
	mems += 2
	b = tip[k]
	pp = mark[b]
	if pp == 0 {
		@<소년 |b|를 dag에 들인다@>@;
	} else if pp <= l {
		continue
	}
	mems += 4
	tt++
	tip[tt], next[tt], blink[b] = g, blink[b], tt
}

@ 꼭대기 층에 이른 뒤로는 그 층에 짝 없는 소년만 더 들인다. 아울러 |q|를 |qq|로
되돌려 dag가 더 자라지 못하게 한다.

@<소년 |b|를 dag에 들인다@>=
if finalLevel >= 0 {
	mems++
	if mate[b] != 0 {
		continue
	}
} else {
	mems++
	if mate[b] == 0 {
		finalLevel, dlink, q = l, 0, qq
	}
}
mems += 3
mark[b], marked[marks], blink[b] = l+1, b, 0
marks++
if mate[b] != 0 {
	mems += 2
	queue[q] = mate[b]
	q++
} else {
	mems += 2
	tt++
	tip[tt], next[tt], dlink = b, dlink, tt
}

@ @<전역 변수@>=
var (
	blink  [maxn]int // 소년마다 dag에서 나가는 첫 화살
	glink  [maxg]int // 소녀마다 짝 후보 목록의 머리
	next   [maxt + maxt + maxn]int
	tip    [maxt + maxt + maxn]int
	mate   [maxn]int
	imate  [maxg]int
	queue  [maxg]int // 너비 우선 탐색에서 본 소녀들
	iqueue [maxg]int // 앞의 |f|칸에 대한 역순열
	mark   [maxn]int // 소년이 dag의 어디에 나타나는가
	marked [maxn]int // 표시가 붙은 소년들
	dlink  int       // dag 안 짝 없는 소년 목록의 머리
	boy    [maxn]int // 깊이 우선 탐색에서 훑고 있는 소년들
)

@ 이제 $\top$에서 시작해 깊이 우선으로 내려가며 서로 겹치지 않는 증대 경로를
거둔다. 크누스의 |goto| 둘은 \.{hopcroft-karp.w}에서와 똑같이 반복문 하나로
접힌다.

@<겹치지 않는 최단 증대 경로를 끝까지 거둔다@>=
for dlink != 0 {
	mems += 2
	b, dlink = tip[dlink], next[dlink]
	l = finalLevel
	mems++
	boy[l] = b
	@<한 갈래를 깊이 우선으로 따라간다@>@;
}
@<모든 표시를 지운다@>@;

@ @<한 갈래를 깊이 우선으로 따라간다@>=
for {
	mems++
	if blink[b] != 0 {
		@<화살을 하나 따라간다@>@;
	}
	l++
	if l > finalLevel {
		break
	}
	mems++
	b = boy[l] // 한 층 물러선다
}

@ @<화살을 하나 따라간다@>=
mems += 3
g = tip[blink[b]]
blink[b] = next[blink[b]]
mems++
if imate[g] == 0 {
	@<짝짓기를 늘리고 이 갈래를 접는다@>@;
}
mems++
if mark[imate[g]] >= 0 {
	b, l = imate[g], l-1
	mems++
	boy[l] = b
}
continue

@ 여기서 $|g|=g_0$이고 $|b|=|boy[0]|=b_0$이 증대 경로의 첫머리다.

@<짝짓기를 늘리고 이 갈래를 접는다@>=
if l != 0 {
	fmt.Fprintln(os.Stderr, "어리둥절하다!")
} // 짝 없는 소녀는 $0$층에만 있어야 한다
@<짝 없는 소녀 목록에서 |g|를 뺀다@>@;
for {
	mems++
	mark[b] = -1
	mems += 3
	j, mate[b], imate[g] = mate[b], g, b
	if j == 0 {
		break // |b|에게 짝이 없었다
	}
	mems++
	l++
	g, b = j, boy[l]
}
break

@ @<짝 없는 소녀 목록에서 |g|를 뺀다@>=
f-- // |f|는 짝 없는 소녀의 수
mems++
j = iqueue[g] // |g|가 |queue|의 어디에 있는가
mems += 3
i = queue[f]
queue[j] = i
iqueue[i] = j

@ @<모든 표시를 지운다@>=
for marks != 0 {
	mems += 2
	marks--
	mark[marked[marks]] = 0
}

@* 절정.
그런데 HK 알고리즘이 소년 $m$명과 소녀 $n>m$명의 완전한 짝짓기를 찾아냈을 때,
우리가 정확히 무엇을 얻은 것인지는 머리를 좀 써야 알 수 있다.

우리가 할 일은 |sol|의 항목 |n|개를, 소녀마다 하나씩 고치는 것이다. 그 항목이
$0$이어야 하는 것은 그 소녀가 {\it 모든\/} 완전 짝짓기에서 짝을 가질 때, 오직
그때뿐이다. (그런 소녀는 부분그래프 동형에서 $T$의 $v$의 부모에 배정되고, 짝지어진
소녀들은 심기에서 |v|의 아들 몇에 배정되기 때문이다.)

@ 이를테면 이분 짝짓기가 유일하다면, |imate[g]|가 $0$이 아닐 때 오직 그때만
|sol[p][g]=0|으로 두면 된다. 그러나 대개는 서로 다른 소녀 집합을 쓰는 완전
짝짓기가 여럿 있다. Matula는 그의 논문 정리~3.4에서, 반드시 짝지어질 수밖에 없는
소녀와 그렇지 않은 소녀를 가려내기가 사실은 쉽다는 것을 알아냈다. 게다가---우리에게는
다행스럽게도---그 정보가 HK 알고리즘이 끝났을 때 dag 안에 고스란히 놓여 있다.

실제로, 모든 완전 짝짓기는 |g|를 품거나 아니면 dag 안에서 |g|에서 $\bot$으로 가는
길에 대응한다는 것을 어렵지 않게 확인할 수 있다. 그러므로---짜잔---짝을 풀어 줄 수
있는 소녀란 바로 |queue|의 앞 |q|칸에 있는 소녀들이다!

@<답을 |sol[p]|에 갈무리한다@>=
for k = 0; k < n; k++ {
	mems++
	sol[p][e+k] = 0
}
for k = 0; k < q; k++ {
	mems += 3
	z++
	sol[p][queue[k]] = 1
}
@<짝 정보도 갈무리한다@>@;

@ $S$를 $T$에 심을 수 있는지 아닌지만 알면 그만이라면 |sol|만으로 충분하다.
그러나 심은 모습을 실제로 보고 싶다면, 풀어 둔 짝짓기 문제의 답도 갈무리해 두는
편이 좋다. 나중에 그 계산을 되풀이하지 않아도 되니까.

어떻게 보면 어리석은 일이다. 다시 풀어야 할 짝짓기 문제는 얼마 되지 않으니,
|sol|에 들어가지도 않는 이 정보를 두느라 자리를 낭비하면서 얻는 시간은 보잘것없다.
그래도 그 속내가 재미있어 크누스는 밀고 나갔다.

배열 |solx[p]|$[e\dts e+n-1]$에는 마지막 |imate| 표를 넣고, |soly[p]|에는 |g|에서
$\bot$으로 가는 길의 이음줄을 넣는다.

@<짝 정보도 갈무리한다@>=
for g = e; g < e+n; g++ {
	mems += 2
	solx[p][g] = imate[g]
}
for k = 0; k < q; k++ {
	mems++
	g = queue[k]
	mems++
	if imate[g] != 0 {
		mems += 4
		soly[p][g] = tip[blink[imate[g]]]
	}
}

@ @<전역 변수@>=
var (
	solx [maxn][maxg]int // 이분 짝짓기의 |imate| 정보
	soly [maxn][maxg]int // 마지막 dag의 정보
)

@* 김빠지는 대목.
할 일을 다 하고도 아직 말을 하지 않았으니, 이제 무슨 일이 있었는지 알려 주어야
한다.

이 자리에서 |z|는 |solve(1)|의 값이다. 그것이 음수 $-d$이면 마디~|d|에 뿌리를 둔
$S$의 부분나무와 그 부모를 $T$에 동형으로 심을 수 없다는 뜻이다. 값이 $0$이면 마디~$1$의
모든 부분나무는 심을 수 있으나 $S$ 자신은 심을 수 없다는 뜻이다. 그 밖의 경우
|z|는 $S$의 마디~$0$을 부분나무~|e|의 뿌리에 맞추어 심을 수 있는 $T$의 호~|e|의
개수다. (이 값이 심는 방법의 총수는 아마 {\it 아닐\/} 것이다. 심기를 시작해 적어도
한 번 성공할 수 있는 자리의 수일 뿐이다.)

@<답을 알린다@>=
if z < 0 {
	fmt.Fprintf(os.Stderr, "실패. 마디 %c와 그 부모조차 심을 수 없다.\n", encode(-z))
} else {
	fmt.Fprintf(os.Stderr, "마디 1의 심기를 붙들어 맬 자리가 %d곳 있다.\n", z)
	if z != 0 {
		@<답 하나를 인쇄한다@>@;
	}
}

@ 마지막 할 일은 |sol|과 |solx|와 |soly|에 든 정보를 거두어, 찾아낸 심기 하나에서
$S$의 마디 $0$, $1$, \dots이 어디로 갔는지를 보여 주는 것이다.

그러려면 $S$의 뿌리 아닌 꼭짓점~|p|마다 |solarc[p]|라는 호를 하나씩 정해 준다.
그 호가 $v$에서 $u$로 간다면, 심기가 |p|를 $v$로, |p|의 부모를 $u$로 보낸다는
뜻이다. 이 호들은 |sol[1][e]=1|인 가장 오른쪽 |e|에서 시작해 위에서 아래로 정한다.

@<답 하나를 인쇄한다@>=
for e = emax - 1; ; e-- {
	mems++
	if sol[1][e] != 0 {
		break
	}
}
mems += 2
solarc[1] = e
for p = 1; p < m; p++ {
	mems++
	if snode[p].child != 0 {
		@<마디 |p|의 아들들에게 호를 나누어 준다@>@;
	}
}
@<찾아낸 심기를 적는다@>@;

@ @<마디 |p|의 아들들에게 호를 나누어 준다@>=
for q = snode[p].child; q != 0; mems, q = mems+1, snode[q].sib {
	mems++
	mate[q] = 0
}
mems += 2
z = solarc[p]
v = vert[z]
mems++
e, n = tnode[v].arc, tnode[v].deg
for g = e; g < e+n; g++ {
	mems += 3
	q = solx[p][g]
	imate[g] = q
	mate[q] = g
}
@<|imate[z]=0|이 되는 짝짓기를 찾는다@>@;
@<아들마다 호를 정해 준다@>@;

@ @<아들마다 호를 정해 준다@>=
mems++
g = e
for q = snode[p].child; q != 0; mems, q = mems+1, snode[q].sib {
	mems++
	if mate[q] != 0 {
		mems += 2
		solarc[q] = dual[mate[q]]
	} else {
		@<아무 데나 맞는 소년에게 짝을 고른다@>@;
	}
}

@ @<아무 데나 맞는 소년에게 짝을 고른다@>=
for {
	if g != z {
		mems++
		if imate[g] == 0 {
			break
		}
	}
	g++
}
mems += 2
solarc[q] = dual[g]
g++

@ 끝맺는 방식이 제법 귀엽다. {\it 증대하지 않는\/} 경로의 이론을 쓴다. (그 이론은
HK 알고리즘의 마지막, 완성되지 못한 dag의 짜임새에서 나오는데, 우리는 그 알맹이를
|soly[p]|에 갈무리해 두었다.)

@<|imate[z]=0|이 되는 짝짓기를 찾는다@>=
for k, g = 0, z; ; k = q {
	mems++
	q = imate[g]
	if q == 0 {
		break
	}
	mems++
	imate[g] = k
	mems++
	g = soly[p][g]
	mems++
	mate[q] = g
}
mems++
imate[g] = k

@ @<찾아낸 심기를 적는다@>=
mems += 2
fmt.Printf("%c", encode(uert[solarc[1]]))
for p = 1; p < m; p++ {
	mems += 2
	fmt.Printf(" %c", encode(vert[solarc[p]]))
}
fmt.Println()

@ @<전역 변수@>=
var solarc [maxn]int // 답에서 열쇠가 되는 호들

@* 돌려 보기.
돌리는 법은 이렇다.
$$\vbox{\halign{\.{#}\hfil\cr
go run matula.go .0111444759a488cfch .011345676965cc5ffh5cklfn55...\cr}}$$
그러면 이렇게 답한다.
$$\vbox{\halign{\.{#}\hfil\cr
좋다, S의 마디 19개와 T의 마디 59개를 얻었다. 최대 차수는 7.\cr
마디 1의 심기를 붙들어 맬 자리가 3곳 있다.\cr
모두 해서 1917+14760 mem.\cr
D C E H u F v w x G O W t y z N V s j\cr}}$$
마지막 줄이 답이다. 나무 $S$의 마디 $0$, $1$, \dots, $18$이 차례로 $T$의 어느 마디로
가는지를 적은 것이다.

@ 그러니 퍼즐을 풀었는가?
$$\mplibcode fig_ST; \endmplibcode$$
\figcap{$T$ 안에 자리 잡은 $S$. 굵게 그린 부분이 심긴 자리다.}

@ 이 그림에는 사연이 있다. 처음에 나는 이것을 연습문제~213의 답(fasc7a의 2024년
12월 5일 판, 205쪽)에 실린 그림에서 그대로 옮겨 왔다. 그런데 프로그램이 찍는 답과
견주어 보니 마디 열아홉 가운데 아홉이 어긋났다. 크누스의 그림은 마디~\.{4}에 달린
두 가지를 서로 바꿔 놓았다. $S$의 길 \.{5}--\.{9}--\.{a}--\.{b}를 $T$의
\.{t}--\.{s}--\.{j}--\.{5}에 놓고, $S$의 \.{c}에 달린 다섯 마디를 $T$의 \.{F}
쪽에 놓은 것이다.

@ 그렇게는 될 수 없다. 호 \.{u}/\.{F}의 부분나무는 마디가 \.{F}, \.{G}, \.{O},
\.{P}, \.{W} 다섯인데, 그 가운데 \.{F}의 이웃은 \.{u}와 \.{G}뿐이다. 아들이 둘인
\.{c}를 거기 앉히려면 이웃이 셋은 있어야 한다. 그래서 그 그림은 모자란 자리를 $T$에
없는 변 \.{F}--\.{O}와 \.{G}--\.{Q}를 그려 메웠다. 진짜 변인 \.{G}--\.{O}와
\.{H}--\.{Q}는 바로 옆에 회색으로 놓여 있다.

@ 더 재미있는 것은, 같은 답의~(f)에 실린 |sol| 행렬이 그 그림을 스스로 반박한다는
점이다. 거기에는 $|sol|[\.{c}][\.{u}/\.{F}]=0$이라고 똑똑히 적혀 있다. 곧 \.{c}에
뿌리 둔 부분나무는 \.{F}에 심을 수 없다는 말이다. 나는 그 행렬 $18\times116$칸을
모두 무식한 되돌이 탐색으로 다시 셈해 보았는데 한 칸도 다르지 않았다. 알고리즘도
프로그램도 옳다. 손으로 그린 그림 하나만 어긋난 것이다.

@ 유일성에 대한 말도 손볼 데가 있다. 답은 ``$\{0,2,3\}$의 자리바꿈을 빼면
유일하다''고 했지만, 낱낱이 세어 보면 심기는 $48$가지다. 자유도가 넷이기 때문이다.
마디 $\{0,2,3\}$의 자리바꿈이 $6$가지, \.{d}와 \.{e}를 맞바꾸는 것이 $2$가지,
\.{c}에 달린 두 다리 \.{f}--\.{g}와 \.{h}--\.{i}를 맞바꾸는 것이 $2$가지, 그리고
\.{b}를 \.{P}에 둘지 \.{W}에 둘지가 $2$가지다. $S$의 자기동형사상으로 나누어도
본질적으로 다른 답이 둘 남는다. 위의 그림은 그 가운데 프로그램이 찍는 것이다.

@ mem 수 $1917+14760$은 크누스의 \CEE/ 원본이 찍는 것과 한 자리도 다르지 않다.
쉼표 연산자가 없는 언어로 옮기면서도 메모리를 짚는 횟수까지 맞춘 셈이다.

맞추는 일이 늘 곧이곧대로였던 것은 아니다. 이를테면 소년을 dag에 들이는 대목에서
원본은 |o|를 \&{\char'46\char'46} 안에 넣어 두었다. 그러니 mem은 두 조건 가운데
{\it 한쪽에만\/} 매겨진다. 처음에 그것을 놓쳐 $119$개를 더 셌다.

@ 무작위로 나무 짝 $1100$개를 지어 원본과 견주었다. 나무 $S$는 마디 $2$개에서 $30$개까지,
$T$는 $62$개까지, 가지 뻗는 정도도 여러 가지로 두었다. 답도, 찍히는 심기도, mem
수도 모두 같았다. 예외는 하나도 없다.

문턱 배열을 고치기 전의 판과 견줄 때는 어긋나는 자리가 하나 있었다. 나무 $T$의 최대
차수가 $S$의 마디 수 이상이면 그쪽이 비워 두던 칸을 우리는 채우므로 입력 mem이
하나 더 들었다. 크누스의 새 판도 그 칸을 채우니, 이제 그 차이마저 없다. 이를테면
$S=\.{.01}$에 별 모양 $T$를 주면 옛 판은 $2043+903$, 새 판과 우리 판은 나란히
$2044+903$이다.

@* 색인.
