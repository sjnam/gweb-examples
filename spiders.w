\input kotexgweb
\input luamplib.sty

% 그림은 spiders.mp 안에 fig_... 라는 이름의 매크로로 있다. 여기서 한 번 읽어
% 두고 그림 자리마다 이름만 부른다.
\everymplib{input spiders;}

\def\title{거미들}
\datethis

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}
\def\bit#1{\\{bit}[#1]}
\def\p#1{\overline#1}          % 잠든 노드에 씌우는 줄
\def\dts{\mathinner{\ldotp\ldotp}}
\let\from=\gets

@* 들어가며.
삼부작의 마지막이다. 짝꿍인 \.{koda-ruskey.w}는 {\it 숲\/}으로 주어진 조건의
아이디얼을 모두 늘어놓았고, 그다음 \.{li-ruskey.w}는 그 조건에 방향을 붙여
{\it 완전 비순환 다이그래프\/}까지 나아갔다. 그리고 여기, 크누스의
\pdfURL{\.{spiders.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/spiders.w}가 있다.
푸는 문제는 \.{li-ruskey.w}와 똑같지만, 방법이 다르고, 무엇보다 앞의 둘을
{\it 낡은 것\/}으로 만들어 버린다. 크누스 자신이 원문에서 앞의 두 프로그램을
``이제는 한물간(now-obsolete)'' 것이라고 부른다.

원문의 첫 문단은 \.{li-ruskey.w}의 그것과 거의 한 글자도 다르지 않다.
``이 프로그램의 목적은 아주 유쾌한 이론을 가진 예쁜 알고리즘을 구현하는 것이다.
그런데 미리 사과해 둘 것이, 이 알고리즘은 아무래도 꽤 미묘해서 바보에게 설명할
방법을 나는 도무지 생각해 내지 못했다. 그래도 이산수학과 전산학을 좋아하는 이라면
부디 견뎌 주시기 바란다.'' 밑에 깔린 이론의 얼개는 크누스와 Frank Ruskey가 함께
쓴 「Deconstructing coroutines」라는 글에 있지만, 프로그램은 그것만으로 홀로 서도록
쓰여 있다. 우리도 그렇게 하겠다---다만 훨씬 더 천천히.

@ 이 프로그램에는 나로서는 각별한 사연이 하나 있다. 크누스가 2001년 12월에
처음 쓴 코드에는 심각한 오류가 하나 숨어 있었다. 정점이 다섯인 아주 작은 거미
하나면 드러나는 것이었는데도 스물다섯 해를 살아남았다. 2026년에 내가 그것을
찾아 알렸고, 크누스는 고친 판을 올리면서 들어가는 말에 ``2001년 12월에 쓴
내 원래 판에는 심각한 오류가 있었고, 지금 판(2026년 6월)에서 고쳤다''고 적고,
고친 대목에는 ``여기 코드는 Soojin Nam의 것으로, 2026년에 내 원래 점화식이
치명적으로 잘못되었음을 친절히 짚어 주었다''고 덧붙였다. @^Nam, Soojin@>
그 대목이 어디이고 무엇이 잘못이었는지는 때가 되면 그림과 함께 찬찬히 보기로 한다.

@ 프로그램의 뼈대는 이렇다. 명령줄을 읽어 그래프를 나무 모양으로 세우고,
그 나무를 여러 번 훑으며 표를 채운 다음, 표만 보고 답을 한 걸음에 하나씩
찍어 낸다. 상수 |maxn|은 정점 수의 한계이면서 동시에 표 안에서 $\infty$
노릇도 한다---``그런 것은 없다''를 아주 큰 수로 적어 두면 비교 한 번으로
가려낼 수 있기 때문이다.
@c
package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

const maxn = 100

@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 읽는다@>@;
	@<자료구조를 마련한다@>@;
	@<답을 만들어 낸다@>@;
}

@* 문제.
다이그래프 하나가 주어진다. 방향을 못 본 척하고 보았을 때 사이클이 하나도 없으면
그 다이그래프를 {\it 완전 비순환\/}(totally acyclic)이라 한다. 우리가 할 일은 그
정점들에 $0$과 $1$을 붙이되
$$x\to y\ \Longrightarrow\ \bit x\le\bit y$$
가 되도록 붙이는 모든 방법을 찾는 것이다. 그냥 찾는 것이 아니라 {\it 그레이 경로\/}로,
곧 한 걸음에 비트 하나씩만 바뀌도록 죽 늘어놓아야 한다. 조건이 하나 더 붙는다.
{\it 뿌리\/}라 부르는 정점 $v$를 하나 정해 두는데, $\bit v$는 $0$에서 시작해서
경로 전체에서 딱 한 번만 바뀌어야 한다.

말이 길어지니 줄이자. 완전 비순환 다이그래프를 {\it 태드\/}(tad)라 하고,
연결된 태드를 {\it 거미\/}(spider)라 한다. 프로그램 이름이 여기서 왔다.

@ 뿌리에 붙은 조건이 왜 필요한지, 그리고 왜 더 욕심을 낼 수 없는지는 아주 작은
보기 하나로 알 수 있다. 정점이 셋인 거미 $x\to y\from z$를 보자. 조건을 지키는
라벨링은 다섯 가지뿐이고, 이들이 그레이 경로를 이루는 방법은 본질적으로
하나밖에 없다.
$$(000,\ 010,\ 011,\ 111,\ 110).$$
경로가 $110$에서 끝난다는 데 눈길이 간다. 곧 그레이 경로가 $11\ldots1$처럼
보기 좋은 자리에서 끝나라고 요구할 수는 없다는 뜻이다. 화살표를 모두 뒤집고
비트를 모두 뒤집은 쌍대 그래프를 생각하면, $00\ldots0$에서 시작하라고 요구할
수도 없음을 알게 된다. 그러니 ``뿌리 비트가 딱 한 번 바뀐다''는 것이 우리가
붙들 수 있는 가장 좋은 손잡이다.

[이 보기를 늘려 정점이 $\{x_1,x_2,\ldots,x_n\}$이고 변이 저마다 $x_{k-1}\to x_k$
아니면 $x_{k-1}\from x_k$인 그래프를 생각하면, 답의 개수가 연분수와 이어진다.
궁금한 이는 직접 따져 보시라.]

@ 태드를 글로 적는 데에는 오른쪽 폴란드 표기법의 변종을 쓴다. 점 \.{.} 하나는
``스택에 새 노드를 얹어라''라는 뜻이고, 부호 \.+ 나 \.- 는 스택 맨 위 둘을 $y$와
$x$라 할 때 ``변 $x\from y$(\.+ 일 때) 또는 $x\to y$(\.- 일 때)를 긋고 $y$를
스택에서 치워라''라는 뜻이다. 이를테면 변이 하나도 없는 네 정점짜리 다이그래프는
\.{....}이고, 다이그래프 $1\to2\from3$은 \.{...+-}, $2\to1\from3$은 \.{..+.+}이다.
점의 번호는 왼쪽에서 오른쪽으로 매긴다.

이 번호 매기기에는 뜻이 있다. \.+ 와 \.- 가 $y$를 $x$의 자식으로 삼는다고
보면 폴란드 표기법은 나무 구조를 암묵적으로 정해 주는데, 그 나무를
{\it 전위 순회\/}(preorder)한 차례가 바로 이 번호이다.

그리고 이 나무 구조 덕분에 다이그래프의 노드 하나하나가 부분나무를 하나씩
거느리게 되고, 그 부분나무는 그 자체로 거미다. 우리가 만들 그레이 경로는
그 작은 거미들의 그레이 경로를 요령껏 이어 붙여 얻는다. 노드 $k$가 거느리는
거미의 그레이 경로를 $G_k$라 부르겠다.

@* 나무로 읽기.
프로그램 안에서 노드 $k$의 어버이는 |par[k]|이다. 노드 $k$와 어버이를 잇는 변은
|sign[k]=1|이면 어버이 쪽으로, |sign[k]=0|이면 $k$ 쪽으로 향한다. 노드 $k$에
딸린 거미는 노드 $k$부터 |scope[k]|까지 (양끝을 넣어) 죽 이어진 번호들로
이루어진다---전위 순회 번호라서 부분나무가 언제나 구간 하나가 되기 때문이다.

자료구조를 세우는 김에 |rchild[k]|와 |lsib[k]|, 곧 노드 $k$의 맨 오른쪽 자식과
왼쪽 형제도 함께 계산해 둔다. 그러면 세 겹으로 이어진 나무가 된다.

@<전역 변수@>=
var (
	par   [maxn]int // 노드 $k$의 어버이
	sign  [maxn]int // $|par|[k]\to k$면 $0$, $|par|[k]\from k$면 $1$
	scope [maxn]int // 거미 $k$의 오른쪽 끝
	stack [maxn]int // 아직 |scope|가 정해지지 않은 정점들
	rchild, lsib [maxn]int // 훑고 다니기 위한 나무 링크
	n       int // 입력 그래프의 크기
	verbose int // 출력이 얼마나 수다스러울지
)

@ 잔심부름에 쓰는 색인 셋을 |main| 안에 둔다. 이름 있는 절들이 이들을 마구
주고받는데, 크누스의 원문이 꼭 그렇게 쓰고 있어서 그대로 따랐다. 특히 |l|은
나중에 진단 출력에서 한 번 더 쓰인다.
@<지역 변수@>=
var j, k, l int

@ 명령줄의 첫 인자가 그래프 명세이고, 둘째 인자를 주면 출력이 얼마나 수다스러울지
정한다. 음수면 라벨링조차 찍지 않고 세기만 하며, $1$이면 활동 목록을, $2$면
마련해 둔 표까지 함께 찍는다.
@<명령줄을 읽는다@>=
@<인자를 살핀다@>@;
for c := 0; c < len(spec); c++ {
	switch spec[c] {
	case '.':
		@<새 정점을 스택에 얹는다@>@;
	case '+', '-':
		@<스택 맨 위 둘을 변으로 잇는다@>@;
	default:
		die("파싱 오류: `%s'는 `.'나 `+'나 `-'로 시작해야 한다!", spec[c:])
	}
}
if n == 0 {
	die("정점이 하나도 없다!")
}
@<스택에 남은 것들의 |scope|를 채운다@>@;

@ @<인자를 살핀다@>=
args := os.Args[1:]
if len(args) < 1 || len(args) > 2 {
	die("사용법: spiders 그래프명세 [수다정도]")
}
if len(args) == 2 {
	v, err := strconv.Atoi(args[1])
	if err != nil {
		die("수다정도는 정수여야 한다: `%s'", args[1])
	}
	verbose = v
}
spec := args[0]

@ @<새 정점을 스택에 얹는다@>=
if n == maxn-1 {
	die("미안하지만 정점은 %d개까지만 다룰 수 있다!", maxn-1)
}
n++
stack[j] = n
j++

@ 변을 하나 그으면 그 자리에서 |scope[k]|를 알 수 있다. 노드 $k$가 스택에서
내려오는 순간까지 만들어진 정점이 곧 $k$의 부분나무를 이루기 때문이다.
@<스택 맨 위 둘을 변으로 잇는다@>=
if j < 2 {
	die("파싱 오류: `%s'는 `.'로 시작해야 한다!", spec[c:])
}
j--
k, l = stack[j], stack[j-1]
if spec[c] == '+' {
	sign[k] = 1
} else {
	sign[k] = 0
}
par[k], lsib[k], rchild[l] = l, rchild[l], k
scope[k] = n

@ 명세를 다 읽고도 스택에 남아 있는 것들은 주어진 다이그래프의 뿌리들이다.
이들에게는 어버이가 없으므로 가짜 정점 $0$을 어버이로 붙여 준다. 그러면 온
그래프가 정점 $0$을 뿌리로 하는 나무 하나가 되어 다루기가 한결 편하다. 남은
|scope|는 오른쪽에서 왼쪽으로 훑으며 채운다.
@<스택에 남은 것들의 |scope|를 채운다@>=
scope[0], sign[0] = n, 1
j--
rchild[0] = stack[j]
for k = n; j >= 0; j-- {
	l = stack[j]
	scope[l] = k
	k = l - 1
	if j > 0 {
		lsib[l] = stack[j-1]
	}
}

@* 가까이 있는 양 정점과 음 정점.
이제부터 줄곧 함께할 보기를 하나 세우자. 크누스가 원문에서 쓴 그림 그대로다.
$$\mplibcode fig_spider; \endmplibcode$$
\figcap{{\it 그림\/} 1: 보기로 삼을 거미. 모든 변은 아래에서 위로 향한다.
폴란드 표기법으로 \.{....+-.--..+-..-+}이고, 정점 $1$이 뿌리다.}

뿌리가 아닌 정점 $k$를 두고, $|par|[k]\to k$이면 {\it 양\/}(positive)이라 하고
$|par|[k]\from k$이면 {\it 음\/}(negative)이라 하자. 이 보기에서는
$\{2,3,5,6,9\}$가 양이고 $\{4,7,8\}$이 음이다.

@ 기호를 하나 더 들이자. 정점 $j$에서 $k$로 가는 방향 있는 길이 있으면 $j\to^*k$라
쓴다. 자, 거미 $k$에서 $j\to^*k$인 정점 $j$를 모조리 지워 보자. 남은 것은 조각
몇 개로 흩어지는데, 그 조각들의 뿌리는 모두 양의 정점이다. 그 뿌리들의 모임을
{\it $k$에 가까이 있는 양 정점들\/}이라 부르고 $U_k$라 쓴다. 마찬가지로
$k\to^*j$인 정점 $j$를 모조리 지우고 남은 조각들의 뿌리를 모으면
{\it $k$에 가까이 있는 음 정점들\/} $V_k$를 얻는다.
$$\mplibcode fig_uv; \endmplibcode$$
\figcap{{\it 그림\/} 2: 거미 $1$에서 $U_1$과 $V_1$을 얻는 법. 흐린 것이 지워지는
정점이고, 겹동그라미가 남은 조각들의 뿌리다.}

@ 이 두 집합이 왜 그리 중요한가? 거미 $k$의 라벨링 가운데 $\bit k=0$인 것들은
정확히, $j\to^*k$인 모든 $j$에 대해 $\bit j=0$으로 못 박고 나서 $u\in U_k$인
거미 $u$들을 저마다 마음대로 라벨링한 것들이기 때문이다. 마찬가지로 $\bit k=1$인
것들은 $k\to^*j$인 모든 $j$에 $\bit j=1$을 못 박고 $v\in V_k$인 거미 $v$들을
저마다 라벨링한 것들이다.

그러니 거미 $k$의 라벨링 개수를 $n_k$라 하면
$$n_k=\prod_{u\in U_k}n_u\;+\;\prod_{v\in V_k}n_v$$
가 된다. 앞의 항이 $\bit k=0$인 쪽, 뒤의 항이 $\bit k=1$인 쪽이다.

@ 집합 $U_k$와 $V_k$에는 눈여겨볼 짜임새가 있다. 정점 $k$의 양의 자식은 모두 $U_k$에
들어가고, 음의 자식은 모두 $V_k$에 들어간다. 이들을 $U_k$와 $V_k$의
{\it 주요\/}(principal) 원소라 부른다. 그리고 $U_k$의 주요하지 않은 원소는
저마다 어떤 주요 정점 $v\in V_k$ 하나에 대해 $U_v$에 들어간다. 그리고 $V_k$의
주요하지 않은 원소도 마찬가지로 어떤 주요 정점 $u\in U_k$에 대해 $V_u$에
들어간다. 우리 보기에서 $9$는 $U_1$의 주요하지 않은 원소이면서 $U_8$에도
들어가고, $4$는 $V_1$의 주요하지 않은 원소이면서 $V_2$에도 들어간다.

가짜 정점 $0$에 대해서도 약속을 해 두자. 주어진 다이그래프의 뿌리 $k$들은
어버이가 $0$이라고 했다. 이 가짜 정점 $0$이 그런 $k$들 모두에게 변을 보낸다고
보면 $U_0$은 곧 그 뿌리들의 모임이 되고, 전체 라벨링의 개수는
$\prod_{u\in U_0}n_u$가 된다. 이 약속에 따라 뿌리 정점들은 양이고, 정점 $0$
자신은 음으로 친다.

@ 보기로 삼은 거미는 이런 값들을 가진다.
$$\vbox{\halign{$\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#+{}$&$#\hfil={}$&\hfil#\cr
k&|sign|[k]&|scope|[k]&|par|[k]&|rchild|[k]&|lsib|[k]&U_k&V_k&
  \multispan3{\hfil$n_k$\hfil}\cr
\noalign{\vskip2pt}
0&1&9&0&1& &\{1\}&\{4,7,8\}\cr
1&0&9&0&8&0&\{2,6,9\}&\{4,7,8\}&48&12&60\cr
2&0&5&1&5&0&\{3,5\}&\{4\}&6&2&8\cr
3&0&4&2&4&0&\emptyset&\{4\}&1&2&3\cr
4&1&4&3&0&0&\emptyset&\emptyset&1&1&2\cr
5&0&5&2&0&3&\emptyset&\emptyset&1&1&2\cr
6&0&7&1&7&2&\emptyset&\{7\}&1&2&3\cr
7&1&7&6&0&0&\emptyset&\emptyset&1&1&2\cr
8&1&9&1&9&6&\{9\}&\emptyset&2&1&3\cr
9&0&9&8&0&0&\emptyset&\emptyset&1&1&2\cr}}$$
답이 모두 $60$가지라는 것을 맨 윗줄에서 읽을 수 있다.

@* 집합을 적지 않고 지니고 다니기.
집합 $U_1,\ldots,U_n$을 곧이곧대로 만들어 두고 싶지는 않다. 원소를 다 합한 수
$\vert U_1\vert+\cdots+\vert U_n\vert$가 $\Omega(n^2)$까지 커질 수 있기 때문이다.
점 \.{.}을 $n/2$개 찍고, \.{.-}를 $n/2$번 되풀이하고, \.-를 $n/2-1$개 더 붙인
입력이 그렇다. 다행히 이 집합들을
암묵적으로 담아 두는 예쁜 방법이 있고, 그것을 만드는 데에는 선형 시간이면 된다.

@ 양의 정점 $u$가 있고 뿌리는 아니라 하자. 그러면 $u\from v_1$인 어버이 $v_1\ne0$이
있다. 만일 $v_1$이 음이면 그 어버이 $v_2$를 보고, 이렇게 계속 올라가 처음으로
양인 정점 $v_j$를 만난다고 하자. 이 $v_j$를 $v_1$의 {\it 양의 시조\/}(positive
progenitor)라 부른다. 그것은 $v_2,\ldots,v_{j-1}$의, 그리고 자기 자신의 양의
시조이기도 하다. 정의를 그대로 뜯어보면
$$u\in U_k\iff k\in\{v_1,\ldots,v_j\}$$
임을 알 수 있고, 따라서 $k'$이 $k$의 양의 시조일 때
$$U_k=U_{k'}\cap\bigl[k\dts|scope|[k]\bigr]$$
가 성립한다. 곧 $U_k$는 $U_{k'}$에서 구간 하나를 잘라 낸 것에 지나지 않는다.

@ 그러니 $k$가 양의 정점일 때에만 $U_k$의 원소들을 실제로 하나로 꿰어 두면 된다.
그런 $U_k$들은 서로 겹치지 않는다. 여기에 {\it 모든\/} 정점 $k$에 대해 $U_k$의
가장 큰 원소가 무엇인지를 |umax[k]|에 적어 두면, 집합 $U_k$는
$$|umax|[k],\quad |prev|[|umax|[k]],\quad |prev|[|prev|[|umax|[k]]],\quad\ldots$$
을 $k$보다 작은 것이 나올 때까지 따라간 것이 된다. 음의 정점과 $V_k$에 대해서도
음의 시조를 써서 똑같이 하면 된다.
$$\mplibcode fig_prev; \endmplibcode$$
\figcap{{\it 그림\/} 3: 그림 1의 거미에서 만들어지는 두 사슬. 위는 양의 시조가
$1$인 것들, 아래는 음의 시조가 $0$인 것들이다. 저마다의 $U_k$와 $V_k$는 이 사슬의
한 토막일 뿐이다---시작점만 |umax|와 |vmax|로 달리 잡으면 된다. (양의 시조가
$2$인 사슬 $3,5$도 따로 있는데 그림에는 넣지 않았다.)}

정점 |k|가 양일 때 |umax[k]|가 $0$이라는 것은 $U_k=\emptyset$이라는 것과 같고,
이는 다시 $k$의 진짜 자손이 모두 음이라는 것과 같다. 정점 |k|가 음일 때
|vmax[k]|가 $0$인 것도 마찬가지다.

@ 나무를 전위 차례로 한 번 훑으면 |prev| 값 전부와, 양의 정점 $k$에 대한
|umax[k]|와 음의 정점 $k$에 대한 |vmax[k]|를 얻는다. 나머지 |umax|와 |vmax|
칸은 후위 차례를 거꾸로 한 번 더 훑어 채운다. 거꾸로 된 후위 차례는 왼쪽과
오른쪽을 뒤집은 숲에서의 전위 차례와 같기 때문이다.
@<자료구조를 마련한다@>=
for j = 1; j <= n; j++ {
	k = par[j]
	if sign[j] == 0 {
		ppro[j], npro[j] = j, npro[k]
		if k != 0 {
			prev[j] = umax[ppro[k]]
			umax[ppro[k]] = j
		} else {
			prev[j] = lsib[j] // $j$가 뿌리일 때의 특별한 경우
		}
	} else {
		npro[j], ppro[j] = j, ppro[k]
		prev[j] = vmax[npro[k]]
		vmax[npro[k]] = j
	}
}
@<거꾸로 된 후위 차례로 훑으며 남은 |umax|와 |vmax|를 채운다@>@;

@ 나무를 훑고 다니는 일은 제대로 굴러가기만 하면 참 즐겁다.

포인터 |ptr[k]|가 시조 $k$의 사슬 위를 한 방향으로만 흘러 내려가는 것이
요령이다. 노드들을 큰 번호에서 작은 번호로 만나므로 이 포인터는 되돌아갈 일이
없고, 그래서 이 절 전체가 선형 시간에 끝난다.
@<거꾸로 된 후위 차례로 훑으며 남은 |umax|와 |vmax|를 채운다@>=
lsib[0] = -1 // 보초
ptr[0] = vmax[0] // 이 포인터가 $V_0$ 위를 흘러간다
umax[0] = rchild[0]
for j = rchild[0]; ; {
	@<노드 |j|가 쓸 사슬을 알맞은 데까지 밀어 놓는다@>@;
	@<다음 노드로 옮겨 간다@>@;
}

@ 노드 $j$가 양이면 반대쪽인 $V_j$를 채워 줘야 하고, 음이면 $U_j$를 채워 줘야
한다. 어느 쪽이든 시조의 사슬을 |scope[j]| 아래로 내려올 때까지 밀어 두면
그 자리가 곧 답이다. 밀어 놓은 자리가 $j$보다 크면 그것이 찾던 최댓값이고,
그렇지 않으면 그 집합은 비어 있다.
@<노드 |j|가 쓸 사슬을 알맞은 데까지 밀어 놓는다@>=
if sign[j] == 0 {
	ptr[j] = umax[j] // 이 포인터가 $U_j$ 위를 흘러간다
	k = npro[j]
} else {
	ptr[j] = vmax[j]
	k = ppro[j]
}
l = ptr[k]
for l > scope[j] {
	l = prev[l]
}
ptr[k] = l
if l > j {
	if sign[j] == 0 {
		vmax[j] = l
	} else {
		umax[j] = l
	}
}

@ 오른쪽 자식이 있으면 거기로 내려가고, 없으면 왼쪽 형제가 있는 조상까지
올라갔다가 그 형제로 옮긴다. 보초 |lsib[0]=-1|이 이 올라가기를 멈춰 세우고,
동시에 순회가 끝났음을 알린다.
@<다음 노드로 옮겨 간다@>=
if rchild[j] != 0 {
	j = rchild[j]
} else {
	for lsib[j] == 0 {
		j = par[j]
	}
	j = lsib[j]
	if j < 0 {
		break
	}
}

@ 보기로 삼은 거미에서는 이런 값들이 나온다.
$$\vbox{\halign{$\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\quad&
                $\hfil#\hfil$\cr
k&|ppro|[k]&|npro|[k]&|prev|[k]&|umax|[k]&|vmax|[k]\cr
\noalign{\vskip2pt}
0&0&0&0&1&8\cr
1&1&0&0&9&8\cr
2&2&0&0&5&4\cr
3&3&0&0&0&4\cr
4&3&4&0&0&0\cr
5&5&0&3&0&0\cr
6&6&0&2&0&7\cr
7&6&7&4&0&0\cr
8&1&8&7&9&0\cr
9&9&8&6&0&0\cr}}$$

@ @<전역 변수@>=
var (
	ppro, npro [maxn]int // 시조
	prev [maxn]int // 같은 시조의 목록에서 하나 앞
	ptr [maxn]int // 그 목록 위를 흘러가는 포인터
	umax, vmax [maxn]int // $U_k$와 $V_k$의 가장 오른쪽 원소
)

@* 반사 그레이 코드로 이어 붙이기.
아하! 이제 그레이 경로를 어떻게 얻을지가 보이기 시작한다. 혼합 기수법의
반사 그레이 코드가 잘 알려져 있으니, 그것을 쓰면 $\bit k=0$인 거미 $k$의
라벨링들을 길이 $\prod_{u\in U_k}n_u$짜리 경로 $P_k$로 늘어놓을 수 있고,
$\bit k=1$인 것들도 길이 $\prod_{v\in V_k}n_v$짜리 경로 $Q_k$로 늘어놓을 수 있다.
남은 일은 $P_k$의 마지막 라벨링과 $Q_k$의 첫 라벨링이 $\bit k$ 하나에서만
다르도록 맞추는 것뿐이다. 그러면 $G_k$는 그냥 `$P_k,\,Q_k$'이다.

그런 라벨링이 무엇인지는 어렵지 않게 알 수 있다. 노드 $k$의 양의 자식 $u$마다
거미 $u$의 {\it 마지막\/} 라벨링을 놓고, 음의 자식 $v$마다 거미 $v$의
{\it 첫\/} 라벨링을 놓은 것이다. 이 라벨링을 앞으로 거미 $k$의
{\it 전이 라벨링\/}(transition labeling)이라 부르겠다.

@ 반사 그레이 코드에서는 자리마다 방향을 번갈아 바꿔 가며 훑는다. 여기서 $j\in U_k$이면
$P_k$ 안에서 경로 $G_j$를 모두
$$\delta_{jk}=\prod_{\scriptstyle u<j\atop\scriptstyle u\in U_k}n_u$$
번 훑게 되고, $j\in V_k$이면 $Q_k$ 안에서 $G_j$를
$\delta_{jk}=\prod_{v<j,\,v\in V_k}n_v$번 훑게 된다. 방향이 번갈아 바뀌므로
이 수가 홀수인지 짝수인지가 중요하다. 경로 $P_k$가 어디서 끝나고 $Q_k$가 어디서
시작하는지는 방금 알았으니, 나머지 절반---$P_k$가 어디서 {\it 시작\/}하고
$Q_k$가 어디서 {\it 끝나는지\/}---는 이 홀짝이 말해 준다.

@ 그런데 $\delta_{jk}$는 $2^n$만큼 커질 수 있다. 그런 $n$비트 산술을 하고 싶지는
않다. 요령은 표를 둘 더 두는 것이다. 표 |ueven[k]|와 |veven[k]|에는 $n_u$가 짝수인
$u\in U_k$ 가운데 가장 작은 것, $n_v$가 짝수인 $v\in V_k$ 가운데 가장 작은 것을
적어 둔다. (그런 원소가 없으면 $\infty$를 뜻하는 |maxn|을 적는다.) 그러면
$\delta_{jk}$가 홀수라는 것은 곧 $|ueven|[k]\ge j$라는 것과 같다---$j$보다 작은
$u$들의 곱이 홀수라는 것은 그 가운데 짝수가 하나도 없다는 뜻이기 때문이다.

정점 $0$의 |ueven|은 억지로 $\infty$로 만든다. 그래야 다이그래프의 연결 성분들이
서로 독립으로 굴러간다.

이 표들을 만드는 김에 |umin|과 |vmin|도 함께 만들어 둔다. 각각 $U_k$와 $V_k$의
가장 {\it 작은\/} 원소인데, 나중에 요긴하게 쓰인다.

@ 여기서 $n_j$의 홀짝을 알아내는 방법이 깜찍하다. 그 값 $n_j$는 두 곱의 합인데,
앞의 곱이 짝수라는 것은 |ueven[j]|가 $\infty$가 아니라는 것이고 뒤의 곱도
마찬가지다. 두 곱의 홀짝이 같아야 합이 짝수이므로, 결국 두 비교의 결과가
같은지만 보면 된다.
@<자료구조를 마련한다@>=
for k = 0; k <= n; k++ {
	ueven[k], veven[k], umin[k], vmin[k] = maxn, maxn, maxn, maxn
}
for j = n; j > 0; j-- {
	@<시조에게서 물려받는다@>@;
	@<어버이의 목록에 |j|를 등록한다@>@;
}
ueven[0] = maxn

@ 여기서도 ``자르기'' 성질이 그대로 쓰인다. 집합 $U_j$는 $U_{|ppro|[j]}$를 구간
$[j\dts|scope|[j]]$로 자른 것이므로, 시조의 가장 작은 원소가 그 구간 안에
들어오면 그대로 물려받고, 아니면 비어 있다는 뜻이 된다.
@<시조에게서 물려받는다@>=
k = ppro[j]
if umin[k] <= scope[j] {
	umin[j] = umin[k]
}
if ueven[k] <= scope[j] {
	ueven[j] = ueven[k]
}
k = npro[j]
if vmin[k] <= scope[j] {
	vmin[j] = vmin[k]
}
if veven[k] <= scope[j] {
	veven[j] = veven[k]
}

@ @<어버이의 목록에 |j|를 등록한다@>=
even := (ueven[j] < maxn) == (veven[j] < maxn) // $n_j$가 짝수인가?
k = par[j]
if sign[j] == 0 {
	umin[ppro[k]] = j
	if even {
		ueven[ppro[k]] = j
	}
} else {
	vmin[npro[k]] = j
	if even {
		veven[npro[k]] = j
	}
}

@ @<전역 변수@>=
var (
	umin, vmin [maxn]int // $U_k$와 $V_k$에서 가장 작은 것
	ueven, veven [maxn]int // $U_k$와 $V_k$에서 $n$이 짝수인 가장 작은 것
	bit [maxn]int // 지금의 라벨링
)

@* 미묘한 대목.
여기서 조금 미묘한 이야기가 나오는데, 그 대신 아주 큰 단순화를 준다.
이제 $j$가 $k$의 음의 자식이고 $|ueven|[k]<j$라 하자. 그러면 거미 $k$의 차례
안에서 거미 $j$가 갖는 처음 비트들은 거미 $j$ 혼자 있을 때의 처음 비트들과
같다. 그런데 $|ueven|[k]\ge j$이면, 그 처음 비트들은 거미 $j$의
{\it 전이\/} 비트들과 같아진다!

@ 왜 그런가? 노드 $j$가 음이므로, 거미 $k$ 안에서 $j$부터 |scope[j]|까지의
전이 비트들은 정의상 거미 $j$의 처음 비트들이다. 그 가운데 몇몇은 $0$이 되기를
강요당한다. 이를테면 $|bit|[k]\ge|bit|[j]$여야 하는데, 전이 비트는 |bit[k]|가
$0$일 때나 $1$일 때나 이 조건을 지켜야 하므로 $\bit j$는 $0$일 수밖에 없다.
그리고 $j$의 음의 자식들도 마찬가지다. 강요당하지 않는 전이 비트가 있다면, 그것은
$U_j$에 속하는 부분거미 $j'$들의 몫이고, 그 $U_j$는 곧
$U_k\cap[j\dts|scope|[j]]$이다.

조건 $|ueven|[k]<j$일 때는 그런 $j'$들이 거미 $k$의 시작과 전이 사이에서 방향을
번갈아 가며 짝수 번 훑린다. 그러니 라벨이 저마다 처음 값으로 돌아와 있다.
반면 $|ueven|[k]\ge j$이면 부분거미 $j'$이 짝수 번 훑리는 것은 $\delta_{j'k}$가
짝수일 때뿐인데, $\delta_{j'k}$가 짝수인 것과 $\delta_{j'j}$가 짝수인 것은 같은
말이다. 곱 $\delta_{j'j}$에는 있지만 $\delta_{j'k}$에는 없는 인수들이 모두 홀수이기
때문이다. 그러므로 거미 $j$의 전이 값들이 그대로 남아 있게 된다.

@ 이 단순화 덕분에 재귀 함수 셋만으로 처음 라벨링을 $O(n)$ 걸음에 만들 수 있다.
(걸음 수가 이렇게 되는 까닭은, 각 함수가 어떤 부분거미의 비트들을 정하는 데
쓰는 걸음이 그 비트 개수의 상수 배로 묶이기 때문이다. 형식을 갖춰 말하면,
$n_1+\cdots+n_t=n-1$일 때 $T_n\le a+(b+T_{n_1})+\cdots+(b+T_{n_t})$이면
귀납법으로 $T_n\le(a+b)n-b$가 나온다.)

우리 보기의 첫 라벨링은 부분거미 $2$의 첫 라벨링, 부분거미 $6$의 마지막 라벨링,
부분거미 $8$의 첫 라벨링을 쓴다. 그래서
$|bit|[1]\ldots|bit|[9]=000001100$이다.

원문은 여기에 이런 혼잣말을 한 줄 남겨 두었다. ``재귀도 아주 즐거운 일이다.
그런데 나는 왜 가끔 순회 쪽을 더 좋아할까?''

@ 함수 |setfirst|는 거미 $k$의 첫 라벨링을 |bit[k]|부터 |bit[scope[k]]|까지에
써넣는다. 양의 자식은 $\delta_{jk}$가 홀수면 제 첫 라벨링, 짝수면 제 마지막
라벨링에서 시작한다. 음의 자식은 앞 절의 미묘한 대목에 따라 갈린다.
@<함수들@>=
func setfirst(k int) {
	bit[k] = 0
	for j := rchild[k]; j != 0; j = lsib[j] {
		odd := ueven[k] >= j // $\delta_{jk}$가 홀수인가?
		if sign[j] == 0 {
			if odd {
				setfirst(j)
			} else {
				setlast(j)
			}
		} else if odd {
			setmid(j, 0) // 미묘한 대목에 따라
		} else {
			setfirst(j) // 모든 $i\in U_j$에 대해 $\delta_{ik}$가 짝수다
		}
	}
}

@ 함수 |setlast|는 |setfirst|를 거울에 비친 것이다. 양과 음을 맞바꾸고
|ueven|을 |veven|으로 바꾸면 그대로 나온다.
@<함수들@>=
func setlast(k int) {
	bit[k] = 1
	for j := rchild[k]; j != 0; j = lsib[j] {
		odd := veven[k] >= j
		if sign[j] == 1 {
			if odd {
				setlast(j)
			} else {
				setfirst(j)
			}
		} else if odd {
			setmid(j, 1) // 미묘한 대목의 쌍대에 따라
		} else {
			setlast(j)
		}
	}
}

@ 함수 |setmid|가 만드는 것이 전이 라벨링이다. 먼저 |bit[k]=b|로 놓은 다음, 양의
자식은 마지막 라벨링, 음의 자식은 첫 라벨링을 갖게 한다. 앞에서 ``$P_k$의 끝과
$Q_k$의 시작이 $\bit k$ 하나에서만 달라야 한다''고 한 그 라벨링이다. 조건이
전혀 갈리지 않는 것이 눈에 띈다.
@<함수들@>=
func setmid(k, b int) {
	bit[k] = b
	for j := rchild[k]; j != 0; j = lsib[j] {
		if sign[j] == 0 {
			setlast(j)
		} else {
			setfirst(j)
		}
	}
}

@* 활동 목록.
반사 그레이 코드는 원소들이 번갈아 능동과 수동이 되는 목록 하나로 예쁘게
만들어 낼 수 있다. (이를테면 {\sl 컴퓨터 프로그래밍의 예술\/}의 알고리즘
7.2.1.1L을 보라.) 여기서 마주한 문제에는 그 생각을 살짝 넓힌 것이 아주 잘 맞는다.
{\it 활동 목록\/}(active list) $L$을 하나 두는데, 그 원소들은 번갈아
{\it 깨어 있고\/} {\it 잠들어\/} 있다. 그리고 원소들은 때때로 $L$에 들어오거나
$L$에서 나간다. 규칙은 이렇다.
\smallskip
\itemitem{1)} 목록 $L$에서 깨어 있는 가장 큰 노드 $k$를 찾고, $k$보다 큰 원소들을
모두 깨운다.
\itemitem{2)} 만일 |bit[k]=0|이면 $|bit|[k]\gets1$로 놓고
 $L\gets(L\setminus U'_k)\cup V'_k$, 아니면 $|bit|[k]\gets0$로 놓고
 $L\gets(L\setminus V'_k)\cup U'_k$. 여기서 $U'_k$와 $V'_k$는 $U_k$와 $V_k$의
 {\it 주요 원소들\/}, 곧 $k$의 양의 자식들과 음의 자식들이다.
\itemitem{3)} 그리고 $k$를 재운다.
\smallskip\noindent
단계 1)에서 $L$의 원소가 모두 잠들어 있으면 거기서 멈춘다. 그때 모두 깨워 놓고
다시 시작하면 같은 라벨링들을 이번에는 거꾸로 훑게 된다.

@ 목록 $L$에 든 것이 정확히 무엇인지 짚어 두자. 곧 |bit[par[k]]=0|인 양의 정점 $k$와
|bit[par[k]]=1|인 음의 정점 $k$가 그것이다. 한마디로 $|sign|[k]=|bit|[|par|[k]]$이다.
우리 보기의 처음 활동 목록은 $L=\{1,2,3,5,6,7,9\}$이고, 처음에는 모두 깨어 있다.

목록을 적을 때는 원소 $k$ 옆에 지금의 |bit[k]|를 아래첨자로 달아 두면 편하다.
그러면 $k_0$ 뒤에는 언제나 $U_k$에 든 거미들의 부분목록이 따라오고, $k_1$ 뒤에는
$V_k$에 든 거미들의 부분목록이 따라온다. 이 약속대로 적으면 처음 활동 목록은
$$1_0\quad 2_0\quad 3_0\quad 5_0\quad 6_1\quad 7_1\quad 9_0$$
이다. 여기서 $9_0$이 깨어 있으니 |bit[9]|를 뒤집는다. 그러면 $L$은
$$1_0\quad 2_0\quad 3_0\quad 5_0\quad 6_1\quad 7_1\quad \p9_1$$
이 된다. 숫자 $9$ 위의 줄은 이 노드가 이제 잠들었다는 표시다.

@ 그다음 걸음은 |bit[7]|을 뒤집고 $9$를 깨운다. 처음 몇 걸음은 이렇게 간다.
$$\vbox{\halign{$#\hfil$&
 \quad\smash{\lower.5\baselineskip\hbox{$\cdots$ $\bit#$를 뒤집는다\hfil}}\cr
1_0\quad 2_0\quad 3_0\quad 5_0\quad 6_1\quad 7_1\quad 9_0&9\cr
1_0\quad 2_0\quad 3_0\quad 5_0\quad 6_1\quad 7_1\quad \p9_1&7\cr
1_0\quad 2_0\quad 3_0\quad 5_0\quad 6_1\quad \p7_0\quad 9_1&9\cr
1_0\quad 2_0\quad 3_0\quad 5_0\quad 6_1\quad \p7_0\quad \p9_0&6\cr
1_0\quad 2_0\quad 3_0\quad 5_0\quad \p6_0\quad 9_0&9\cr
1_0\quad 2_0\quad 3_0\quad 5_0\quad \p6_0\quad \p9_1&5\cr
1_0\quad 2_0\quad 3_0\quad \p5_1\quad 6_0\quad 9_1&9\cr
1_0\quad 2_0\quad 3_0\quad \p5_1\quad 6_0\quad \p9_0&6\cr
1_0\quad 2_0\quad 3_0\quad \p5_1\quad \p6_1\quad 7_0\quad 9_0\cr}}$$
비트 |bit[6]|이 $0$이 되면 $7$이 $L$에서 사라졌다가, |bit[6]|이 $1$로 돌아오면
다시 나타나는 것을 눈여겨보자. 조금 더 가면 |bit[3]|이 $1$로 바뀌고,
그러면 $4_0$이 싸움판에 뛰어든다.

@ 가장 극적인 변화는 첫 $n_2n_6n_9=48$개의 라벨링이 끝나고 |bit[1]|이 바뀔
때 일어난다.
$$\vbox{\halign{$#\hfil$&
 \quad\smash{\lower.5\baselineskip\hbox{$\cdots$ $\bit#$를 뒤집는다\hfil}}\cr
1_0\quad \p2_1\quad \p4_0\quad \p6_1\quad \p7_1\quad \p9_0&1\cr
\p1_1\quad 4_0\quad 7_1\quad 8_0\quad 9_0&9\cr
\p1_1\quad 4_0\quad 7_1\quad 8_0\quad \p9_1&8\cr
\p1_1\quad 4_0\quad 7_1\quad \p8_1&7\cr
\qquad\vdots&8\cr
\p1_1\quad \p4_1\quad \p7_1\quad \p8_0\quad 9_1&9\cr
\p1_1\quad \p4_1\quad \p7_1\quad \p8_0\quad \p9_0\cr}}$$
드디어 목록 전체가 잠든 자리에 이르렀다. 모두 $60$가지 라벨링을 만들어 낸 것이다.

@ 이 규칙만 따르면 비트 하나를 바꾸는 데 드는 일은, 전체에 걸쳐 평균을 내면
$O(1)$이다. 단계 1)에서 $k$를 왼쪽으로 훑어 찾고 단계 2)에서 $k$보다 큰 원소를
모두 옮겨 적어도 그렇다. 그런데 우리 구현은 평균 이야기에서 한 걸음 더 나간다.
준비에 드는 $O(n)$ 걸음을 마치고 나면, 비트 하나를 바꿀 때마다 하는 일이 상수 개로
{\it 묶인다\/}. 곧 Gideon Ehrlich가 말한 뜻에서 {\it 고리 없는\/}(loopless)
알고리즘이다 [{\sl Journal of the ACM\/ \bf20} (1973), 500--513].

@ 고리 없음으로 가는 첫걸음은 Ehrlich의 알고리즘 7.2.1.1L에 나오는
``초점 포인터''를 들이는 것이다. 대개 |focus[k]=k|인데, $k$가 잠들어 있고
$k$의 오른쪽 이웃이 깨어 있을 때만 다르다. 그럴 때 |focus[k]|는 $k$보다 작으면서
깨어 있는 가장 큰 $j$를 가리킨다.

활동 목록은 |left[k]|와 |right[k]|로 양쪽 이웃을 잇는 이중 연결 목록이고,
|left[0]|을 맨 오른쪽 원소로, |right[0]|을 맨 왼쪽 원소로 삼아 고리 모양으로
닫는다. 그러면 단계 1)에서 찾아야 할 $k$가 그냥 |focus[left[0]]|이다.
그리고 $k$ 오른쪽을 모두 깨우는 일은 |focus[left[0]]=left[0]|으로 끝나고, $k$를 재우는
일은 |focus[k]=focus[left[k]]|, |focus[left[k]]=left[k]| 두 줄로 끝난다.

@* 블록.
이제 단계 2)의 구현을 들여다볼 차례다. 여기가 계산의 심장이다.

노드 $k$의 양의 자식 $j$는 $V_j$가 비었을 때 {\it 단순하다\/}(simple)고 하고,
음의 자식은 $U_j$가 비었을 때 단순하다고 한다. 달리 말하면, 자기 자신을 넣어
자손이 모두 같은 부호일 때 단순하다. 부호가 같은 형제들은 언제나 한 덩어리로
활동 목록에 들어오고 나간다. 그러므로 $j$와 $j'$의 부호가 같고
$j=|lsib|[j']$이 단순하면, 이들이 들어오든 나가든 언제나
$|right|[j]=j'$이고 $|left|[j']=j$이다. 이런 링크는 준비 단계에서 한 번 이어
두면 그만이다. 반면 $j$가 오른쪽 이웃과 한 덩어리가 될 수 없을 때에는
|bstart[j]|를 계산해 둔다. 곧 $j$와 함께 한 {\it 블록\/}을 이루는 형제들 가운데
가장 왼쪽 것이다. (|bstart[j]=j|일 수도 있다.)

@ 아래의 준비 절이 |bstart|와 |left|, |right|의 처음 값을 정해 준다. 그러면서
때때로 없어서는 안 될 값 둘을 더 계산한다. 값 |umaxscope[k]|는 |bit[k]|가 $0$이
되는 전이 지점에서 활동 목록에 들어 있는 거미 $k$의 가장 큰 노드이고,
|vmaxscope[k]|는 |bit[k]|가 $1$이 될 때의 같은 것이다.

노드 번호가 큰 쪽에서 작은 쪽으로 내려가며 도는 것이 중요하다. 그래야 $k$를
다룰 때 $k$의 자식들이 이미 다 끝나 있다.
@<자료구조를 마련한다@>=
for k = n; k != 0; k-- {
	j = lsib[k]
	if j != 0 {
		left[k], right[j] = j, k
	} else {
		@<|k|와 그 형제들의 |bstart| 링크를 계산한다@>@;
	}
	@<|umaxscope[k]|와 |vmaxscope[k]|를 계산한다@>@;
}

@ 왼쪽 형제가 없는 $k$, 곧 맏이를 붙들고 형제들을 오른쪽으로 훑는다. 바깥
반복문이 큰 번호에서 작은 번호로 내려오므로, 맏이에 이를 때쯤이면 그 아우들의
|right| 링크가 이미 다 이어져 있다. 지금 보는 $j$가 오른쪽 이웃과 부호가 같고
단순하면 둘은 한 블록이니 그냥 지나가고, 그렇지 않으면 거기서 블록이 끊긴다.
@<|k|와 그 형제들의 |bstart| 링크를 계산한다@>=
for j, l = k, k; j != 0; j = right[j] {
	if right[j] != 0 && sign[j] == sign[right[j]] &&
		((sign[j] == 0 && vmax[j] == 0) || (sign[j] == 1 && umax[j] == 0)) {
		continue
	}
	bstart[j] = l
	l = right[j]
}

@ @<전역 변수@>=
var (
	left, right [maxn]int // 활동 목록에서의 이웃
	bstart [maxn]int // 여기서 끝나는 블록의 시작
	umaxscope, vmaxscope [maxn]int // |bit[k]|가 바뀔 때 살아남는 가장 큰 노드
	firstdeep, lastdeep [maxn]int // 첫/마지막 라벨링에서 가장 깊은 활동 자손
	middeep0, middeep1 [maxn]int // 두 전이 라벨링에서의 같은 것
	flag [maxn]int // 넣기나 빼기가 밀려 있으면 $0$이 아니다
	focus [maxn]int // 누가 깨어 있는지를 담은 포인터
)

@* 처음과 끝과 전이.
두 값 |umaxscope[k]|와 |vmaxscope[k]|는 |rchild[k]|가 단순할 때에만 쓰이게 된다.
그래도 모든 경우에 계산해 두는 편이 재미있다. 이 프로그램의 변종에서 쓸모가
생길지도 모르니.

함수 |setfirst|와 |setlast|와 |setmid|로 이끌었던 그 따짐이 여기서도 열쇠다.
비트 $i$가 거미 $k$의 첫 라벨링, 전이 라벨링, 마지막 라벨링에서 갖는 값을
저마다 $\alpha_{ik}$, $\tau_{ik}$, $\omega_{ik}$라 하자. 특히
$\alpha_{kk}=0$이고 $\omega_{kk}=1$이며 $\tau_{kk}$는 정의되지 않는다
($0$에서 $1$로 바뀌는 그 순간이기 때문이다). 범위 $k<i\le|scope|[k]$일 때는
$j\le i\le|scope|[j]$인 거미 $j$(곧 $k$의 자식)가 꼭 하나 있다. 그리고 다음
공식들이 $i$, $j$, $k$가 주어졌을 때 모든 것을 정해 준다.
$$\eqalign{\llap{$j$가 양이면,}\cr
\tau_{ik}&=\omega_{ij};\cr
\alpha_{ik}&=\cases{\omega_{ij},&$|ueven|[k]<j$일 때;\cr
                    \alpha_{ij},&$|ueven|[k]\ge j$일 때;\cr}\cr
\omega_{ik}&=\cases{\omega_{ij},&$|veven|[k]<j$일 때;\cr
                    \tau_{ij},  &$|veven|[k]\ge j$일 때, 그리고 $i=j$면 $1$.\cr}\cr
\noalign{\vskip4pt}
\llap{$j$가 음이면,}\cr
\tau_{ik}&=\alpha_{ij};\cr
\omega_{ik}&=\cases{\alpha_{ij},&$|veven|[k]<j$일 때;\cr
                    \omega_{ij},&$|veven|[k]\ge j$일 때;\cr}\cr
\alpha_{ik}&=\cases{\alpha_{ij},&$|ueven|[k]<j$일 때;\cr
                    \tau_{ij},  &$|ueven|[k]\ge j$일 때, 그리고 $i=j$면 $0$.\cr}\cr
}$$

@ 여기가 바로 크누스의 원래 코드가 잘못되어 있던 자리다. 원문에는
$$\\{umaxscope}[k]=\bigl(\\{umaxbit}[k]=1\ ?\ (\\{vmax}[j]\ ?\ \\{vmax}[j]:j):
\\{umaxscope}[j]\bigr),\qquad j=\\{umax}[k]$$
라는 한 줄과 그 쌍대가 있었다. 뜻은 옳았다---``|bit[k]|가 $0$인 전이 지점에서
활동 목록에 반드시 들어 있는 가장 큰 노드''. 그런데 가까운 정점 집합 안에
사슬이 겹겹이 들어앉으면, 정말로 살아남는 가장 깊은 노드가 $|vmax|[j]$보다
{\it 아래에\/} 있게 된다. 재귀가 한 층 얕은 데서 멈춰 버리는 것이다.
$$\mplibcode fig_bug; \endmplibcode$$
\figcap{{\it 그림\/} 4: 가장 작은 반례. 정점이 다섯인 이 거미에서
$|umax|[1]=2$, $|vmax|[2]=3$이므로 옛 공식은 $|umaxscope|[1]=3$을 내놓는다.
그런데 $|bit|[1]$이 뒤집히는 순간 거미 $2$는 제 마지막 라벨링
$|bit|[2]|bit|[3]|bit|[4]=111$에 있어서 노드 $4$가 아직 활동 목록에 살아 있다.
옳은 값은 $4$다. 값이 $3$이면 노드 $5$의 블록이 $4$ {\it 앞에\/} 이어져
목록의 차례가 흐트러지고, 그러면 |focus[left[0]]|이 더는 깨어 있는 가장 큰
노드를 돌려주지 못한다.}

이 거미의 올바른 라벨링은 열 가지인데 고치기 전의 프로그램은 여덟 가지를
찍고 나서 조건을 어기는 라벨링으로 걸어 나갔다. 어떤 입력에서는 아예 영영
돌기도 했다. 정점이 일곱 이하인 연결 거미 10,067개 가운데 416개가 그랬다.
그 가운데 375개는 조건을 어기는 라벨링을 찍어 냈고, 23개는 끝내 멈추지
않았으며, 나머지는 앞 절반은 옳은데 뒤 절반이 그 거울상이 아니었다.

@ 고치는 방법은 뜻을 그대로 계산하는 것이다. 값 |umaxscope[k]|는 거미 $k$가
$\bit k=0$짜리 전이 라벨링을 하고 있을 때 살아남는 가장 큰 노드이고, 그 라벨링은
바로 |setmid(k,0)|이 써넣는 것이다. 그러니 |setfirst|, |setlast|, |setmid|의
값을 돌려주는 짝을 만들면 된다. 네 값 |firstdeep[k]|, |lastdeep[k]|, |middeep0[k]|,
|middeep1[k]|를 저마다 |setfirst(k)|, |setlast(k)|, |setmid(k,0)|,
|setmid(k,1)|이 만드는 라벨링 아래에서 $k$의 가장 큰 활동 {\it 자손\/}(없으면
$0$)이라 하자. 넷 모두 $k$의 자식들만 한 번씩 훑으면 되는 점화식을 따르므로
준비 시간은 여전히 $O(n)$이다. 그리고 |umaxscope[k]|는 |middeep0[k]|(비었으면
$k$), |vmaxscope[k]|는 |middeep1[k]|(비었으면 $k$)가 된다.
@<|umaxscope[k]|와 |vmaxscope[k]|를 계산한다@>=
df, dl, d0, d1 := 0, 0, 0, 0
for j = rchild[k]; j != 0; j = lsib[j] {
	uodd, vodd := ueven[k] >= j, veven[k] >= j
	if sign[j] == 0 {
		@<양의 자식 |j|가 얼마나 깊이 살아 있는지 헤아린다@>@;
	} else {
		@<음의 자식 |j|가 얼마나 깊이 살아 있는지 헤아린다@>@;
	}
}
firstdeep[k], lastdeep[k] = df, dl
middeep0[k], middeep1[k] = d0, d1
umaxscope[k], vmaxscope[k] = k, k
if d0 != 0 {
	umaxscope[k] = d0
}
if d1 != 0 {
	vmaxscope[k] = d1
}

@ 양의 자식 $j$는 $\bit k$가 $0$일 때 목록에 있고 $1$일 때 없다. 그래서 $j$
자신은 |df|와 |d0|에만 보태진다. 노드 $j$가 거느린 자손이 어느 라벨링에 놓이는지는
|setfirst|와 |setlast|와 |setmid|가 하는 그대로다---첫 라벨링에서는
$\delta_{jk}$의 홀짝에 따라 제 첫 라벨링이거나 마지막 라벨링, 마지막
라벨링에서는 제 전이 라벨링이거나 마지막 라벨링, 두 전이 라벨링에서는 언제나
제 마지막 라벨링.
@<양의 자식 |j|가 얼마나 깊이 살아 있는지 헤아린다@>=
if uodd {
	df = max(df, j, firstdeep[j])
} else {
	df = max(df, j, lastdeep[j])
}
if vodd {
	dl = max(dl, middeep1[j])
} else {
	dl = max(dl, lastdeep[j])
}
d0 = max(d0, j, lastdeep[j])
d1 = max(d1, lastdeep[j])

@ 음의 자식은 거울에 비친 모습이다. 이번에는 $j$ 자신이 |dl|과 |d1|에만
보태지고, 자손은 첫 라벨링 쪽에서 전이를 쓴다.
@<음의 자식 |j|가 얼마나 깊이 살아 있는지 헤아린다@>=
if uodd {
	df = max(df, middeep0[j])
} else {
	df = max(df, firstdeep[j])
}
if vodd {
	dl = max(dl, j, lastdeep[j])
} else {
	dl = max(dl, j, firstdeep[j])
}
d0 = max(d0, firstdeep[j])
d1 = max(d1, j, firstdeep[j])

@ 기록을 남기는 뜻에서, 보기로 삼은 거미의 나머지 값들은 이렇다.
$$\vbox{\halign{$\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\enspace&
                $\hfil#\hfil$\cr
 &&&&&&\\{first}\ \ &\\{last}\ \ &\\{mid}\ \ &\\{mid}\ \ &\\{umax}\ \ &\\{vmax}\ \ \cr
k&|bstart|[k]&|umin|[k]&|ueven|[k]&|vmin|[k]&|veven|[k]&\\{deep}[k]&\\{deep}[k]&
\\{deep0}[k]&\\{deep1}[k]&\\{scope}[k]&
\\{scope}[k]\cr
\noalign{\vskip2pt}
0& &1&\infty&4&4\cr
1&1&2&2&4&4&                    9&9&9&9&9&9\cr
2&2&3&5&4&4&                    5&4&5&4&5&4\cr
3&3&\infty&\infty&4&4&          0&4&0&4&3&4\cr
4&4&\infty&\infty&\infty&\infty&0&0&0&0&4&4\cr
5&5&\infty&\infty&\infty&\infty&0&0&0&0&5&5\cr
6&6&\infty&\infty&7&7&          0&7&0&7&6&7\cr
7&7&\infty&\infty&\infty&\infty&0&0&0&0&7&7\cr
8&8&9&9&\infty&\infty&          9&0&9&0&9&8\cr
9&9&\infty&\infty&\infty&\infty&0&0&0&0&9&9\cr
}}$$

@* 미뤄 두었다가 고치기.
비트 |bit[k]|가 $0$에서 $1$로 바뀌면 $k$의 양의 자식 블록들을 활동 목록에서 빼고
음의 자식 블록들을 넣어야 한다. 맨 오른쪽 블록은 |rchild[k]|로 바로 닿을 수
있고, 나머지는 |bstart|와 |lsib| 링크를 따라가면 만난다.

그런데 우리 알고리즘은 고리가 없어야 하므로 이 손질을 한꺼번에 할 수가 없다.
그래서 맨 오른쪽 것만 실제로 해 놓고, 자료구조에 경고를 하나 심어 둔다.
빠진 정보가 정말로 필요해지기 전에 그다음 손질이 이루어지도록. 손질을 기다리는
노드들은 모두 깨어 있으므로 이렇게 미뤄 두어도 초점 포인터는 아무 영향을 받지
않는다.

@ 함수 |fixup|이 노드들이 활동 목록에 들고 나는 기본 장치다. 이 함수는 자식
블록 하나를 넣거나 빼는 것에 더해, 그 왼쪽 블록이 제때 손질되도록 깃발도 함께
꽂는다. 첫 인자 |k|가 양수면 블록 |k|를 넣으라는 뜻이고, 음수면 블록 $-|k|$를
빼라는 뜻이다. 둘째 인자 |l|은 그 일이 벌어질 자리, 곧 ``|l| 바로 앞''이다.
@<함수들@>=
func fixup(k, l int) {
	flag[l] = 0
	if k > 0 {
		@<블록 |k|를 |l| 앞에 넣고 돌아간다@>@;
	}
	@<블록 |k|를 |l| 앞에서 뺀다@>@;
}

@ 일단 돌기 시작하고 나면 |left[j]|와 |right[k]|는 블록 $k$가 지난번에
빠질 때의 값 그대로 이미 옳다. 그래도 그 사실을 쓰지는 않는다. 활동 목록을
처음 세울 때 |left[j]|와 |right[k]|를 미리 맞춰 놓는 일까지 걱정하고 싶지는
않아서다.
@<블록 |k|를 |l| 앞에 넣고 돌아간다@>=
j := bstart[k]
left[j] = left[l]
right[left[l]] = j
left[l] = k
right[k] = l
plant(true, j)
return

@ 빼는 쪽에는 사연이 하나 더 있다. 빠지는 블록 바로 왼쪽에, 부호가 반대이고
{\it 단순한\/} 블록이 들어오고 싶어 하며 서 있을 수 있다. 그럴 때는 나가는
것을 빼고 그 자리에 들어오는 것을 넣는다---한 번에 두 가지 일을 해 버리는 셈이다.
@<블록 |k|를 |l| 앞에서 뺀다@>=
k = -k
j := bstart[k]
i := lsib[j]
if left[l] != k {
	fmt.Printf("이런, fixup(%d,%d)가 헷갈렸다!\n", -k, l) // 일어날 리 없다
}
if i != 0 && sign[i] != sign[k] &&
	((sign[i] == 0 && vmax[i] == 0) || (sign[i] == 1 && umax[i] == 0)) {
	@<블록 |k| 자리에 블록 |i|를 대신 넣고 돌아간다@>@;
}
left[l] = left[j]
right[left[j]] = l
plant(false, j)

@ @<블록 |k| 자리에 블록 |i|를 대신 넣고 돌아간다@>=
left[l] = i
right[i] = l
m := bstart[i]
left[m] = left[j]
right[left[m]] = m
plant(true, m)
return

@ 남은 것이 깃발 꽂기다. 함수 |plant|는 방금 목록에 들어왔거나(|ins|가 참)
목록에서 나간 블록의 왼쪽 끝 |j|를 받아, 그 왼쪽 이웃 블록을 손질하라는 표를
남긴다. 규칙은 한 줄로 줄어든다---{\it 이웃의 부호가 같으면 이웃도 같은 일을
겪고, 다르면 반대 일을 겪는다.\/} 그래서 깃발의 부호는
$(|sign|[i]=|sign|[j])$와 |ins|가 같은지로 정해진다. 깃발을 꽂는 자리는 그
이웃 블록이 실제로 손대야 할 가장 왼쪽 노드인데, 그것이 바로 아까 만들어 둔
|umin|과 |vmin|이다.

원문은 이 몇 줄을 세 군데에 거의 같은 모양으로 되풀이해 적어 두었다. 위의
한 줄짜리 규칙을 알고 나면 셋이 하나로 합쳐진다. 이웃 블록이 비어 있을
수 있는 것은 |ins|가 참일 때뿐이라 |m < maxn| 검사가 필요한데, 빼는 쪽에서는
그 검사가 언제나 참이므로 두 경우를 한데 두어도 탈이 없다.
@<함수들@>=
func plant(ins bool, j int) {
	i := lsib[j]
	if i == 0 {
		return
	}
	same := sign[i] == sign[j]
	m := vmin[i]
	if sign[i] == 1 {
		m = umin[i]
	}
	if m < maxn {
		j = m
	}
	if same != ins {
		i = -i // 그다음 손질은 빼기다
	}
	flag[j] = i
}

@* 활동 목록에 불붙이기.
활동 목록은 애초에 어떻게 생겨나는가? 그것은 |bit| 표에서 만들어 낸다. 함수
|setfirst(0)|이 처음 라벨링을 써넣고 나면, ``$|sign|[k]=|bit|[|par|[k]]$인
$k$들''이라는 그 규칙을 왼쪽에서 오른쪽으로 그대로 읽으면 된다.
@<활동 목록에 불을 붙인다@>=
setfirst(0) // $|bit|[1]\ldots|bit|[n]$의 처음 값을 만든다
for l, k = 0, 0; k <= n; k++ {
	focus[k] = k
	if sign[k] == bit[par[k]] {
		right[l], left[k] = k, l
		l = k
	}
}
right[l], left[0] = 0, l // 맨 오른쪽 노드를 고리에 이어 붙인다

@* 돌리기.
이론에서 그랬듯 이제 실제로 고리 없는 구현을 지을 때가 왔다.

물론 걸음마다 찍어 내는 일은 고리를 쓴다. 그 출력은 |verbose|가 음수면 아예
생략된다.
@<답을 만들어 낸다@>=
@<활동 목록에 불을 붙인다@>@;
if verbose > 1 {
	@<마련해 둔 것들을 찍는다@>@;
}
done := false
for {
	count++
	if verbose >= 0 {
		@<지금의 비트들을 찍는다@>@;
	}
	@<활동 목록에서 잠들지 않은 맨 오른쪽 노드 |k|를 찾는다@>@;
	if k != 0 {
		if flag[k] != 0 {
			fixup(flag[k], k)
		}
		@<노드 |k|의 비트를 뒤집고 자식 블록을 갈아 끼운다@>@;
	} else if done {
		break
	} else {
		@<여기서 되돌아 거꾸로 만든다@>@;
		continue
	}
	@<노드 |k|를 재운다@>@;
}
fmt.Printf("모두 해서 %d/2가지.\n", count)

@ 활동 목록의 맨 오른쪽에서 |focus|를 딱 한 번 따라가면 잠든 노드들을 통째로
건너뛰어 원하는 $k$에 닿는다. 그러면서 |focus|를 제자리로 되돌려 놓는 이 한 줄이
곧 ``$k$보다 오른쪽에 있는 것들을 모두 깨우기''다.
@<활동 목록에서 잠들지 않은 맨 오른쪽 노드 |k|를 찾는다@>=
j = left[0]
k = focus[j]
focus[j] = j

@ 여기에 이르면 $k$보다 큰 노드는 모두 깨어 있고 |flag[k]=0|임이 보장된다.
@<노드 |k|를 재운다@>=
j = left[k]
focus[k] = focus[j]
focus[j] = j

@ @<여기서 되돌아 거꾸로 만든다@>=
fmt.Printf("...여기까지 %d개. 이제 거꾸로 만들어 간다:\n", count)
done = true

@ 원문은 |bit[k]|가 $0\to1$일 때와 $1\to0$일 때를 두 절로 나누어 적었는데,
둘은 완벽한 쌍대여서 새 비트값 |s| 하나만 두면 한 절로 합쳐진다. 자식 $j$가
활동 목록에 있다는 것은 $|sign|[j]=|bit|[k]$라는 뜻이었으니, 새 비트가 |s|가
되면 부호가 |s|인 자식들이 들어오고 부호가 $1-|s|$인 자식들이 나간다.

들어오든 나가든 손댈 자리를 알려 주는 것은 같은 값이다---$j$가 양이면
|vmin[j]|, 음이면 |umin[j]|. 그런데 $j$가 단순하면 그 값이 $\infty$인데, 그때가
|umaxscope|와 |vmaxscope|가 필요해지는 바로 그 자리다.
@<노드 |k|의 비트를 뒤집고 자식 블록을 갈아 끼운다@>=
s := 1 - bit[k]
bit[k] = s
j = rchild[k]
if j != 0 {
	if sign[j] == 0 {
		l = vmin[j]
	} else {
		l = umin[j]
	}
	if sign[j] != s {
		@<블록 |j|를 목록에서 뺀다@>@;
	} else {
		@<블록 |j|를 목록에 넣는다@>@;
	}
}

@ 빠지는 블록의 왼쪽 자리는 그 블록 안쪽에서 찾는다. 집합 $U_j$나 $V_j$가 비어
있지 않으면 그 가장 작은 원소가 지금 목록에 들어 있으니 그 앞이고, 비어
있으면---곧 $j$가 단순하면---블록 바로 오른쪽 이웃 앞이다.
@<블록 |j|를 목록에서 뺀다@>=
if l < maxn {
	fixup(-j, l)
} else {
	fixup(-j, right[j]) // $j$는 단순하다
}

@ 들어오는 쪽도 마찬가지인데, $j$가 단순할 때가 다르다. 그때는 블록이 거미 $k$가
차지하는 구간의 맨 끝에 붙어야 하고, 그 끝이 어디인지를 말해 주는 것이
|umaxscope[k]|와 |vmaxscope[k]|다. 앞에서 스물다섯 해 동안 숨어 있던 오류가
바로 이 한 줄이 잘못된 자리를 가리켰던 것이다.
@<블록 |j|를 목록에 넣는다@>=
if l < maxn {
	fixup(j, l)
} else if s == 1 {
	fixup(j, right[umaxscope[k]]) // $j$는 단순하다
} else {
	fixup(j, right[vmaxscope[k]])
}

@ @<전역 변수@>=
var (
	count int // 지금까지 찾은 라벨링의 개수
	asleep [maxn]int // 잠들었거나 목록에 없는 노드
)

@* 자세히 보기.
찍는 일이 남았다. 비트들을 왼쪽에서 오른쪽으로 늘어놓고, |verbose|가 $0$보다
크면 활동 목록의 모습을 뒤에 덧붙인다.
@<지금의 비트들을 찍는다@>=
var b strings.Builder
for k = 1; k <= n; k++ {
	b.WriteByte(byte('0' + bit[k]))
}
if verbose > 0 {
	@<활동 목록을 눈에 보이게 덧붙인다@>@;
}
fmt.Println(b.String())

@ 여기서는 활동 목록이 마땅히 어떠해야 하는지를 처음부터 다시 계산해서 지금의
링크와 견주어 본다. 어긋난 곳은 깃발이 꽂힌 노드가 뒤따르지 않을 때에만 알린다.
잠든 노드는 괄호로 감싸고, 깃발이 꽂힌 노드 앞에는 느낌표를 찍는다.
@<활동 목록을 눈에 보이게 덧붙인다@>=
@<누가 자고 있는지 |focus|를 따라가며 알아낸다@>@;
for k, j = 1, 0; k <= left[0]; k++ {
	if sign[k] != bit[par[k]] {
		continue
	}
	@<노드 |k|를 알맞은 모양으로 덧붙인다@>@;
	j = k
}

@ 초점 포인터의 뜻을 그대로 뒤집어 읽으면 누가 자고 있는지가 나온다.
값 |focus[k]|가 $k$ 자신이 아니면 그 사이의 노드들이 잠들어 있는 것이다.
@<누가 자고 있는지 |focus|를 따라가며 알아낸다@>=
for k = left[0]; ; k-- {
	j, k = k, focus[k]
	for ; j > k; j-- {
		asleep[j] = 1
		if flag[j] != 0 {
			fmt.Printf("\n이런, flag[%d]가 틀렸다!\n", j)
		}
	}
	if k == 0 {
		break
	}
	asleep[k] = 0
}

@ @<노드 |k|를 알맞은 모양으로 덧붙인다@>=
if asleep[k] != 0 {
	fmt.Fprintf(&b, " (%d)", k)
} else if flag[k] != 0 {
	fmt.Fprintf(&b, " !%d", k)
} else {
	fmt.Fprintf(&b, " %d", k)
}
if (k != right[j] || left[k] != j) && k > l {
	b.WriteString("[이런]")
}

@ 마지막으로, 사용자가 유별나게 자세한 출력을 부르면 마련해 둔 표를 통째로
찍는다.
@<마련해 둔 것들을 찍는다@>=
for k = 0; k <= n; k++ {
	c := '+'
	if sign[k] == 1 {
		c = '-'
	}
	fmt.Printf("%d(%c): scope=%d, par=%d, rchild=%d, lsib=%d,",
		k, c, scope[k], par[k], rchild[k], lsib[k])
	fmt.Printf(" ppro=%d, npro=%d, prev=%d, bstart=%d\n",
		ppro[k], npro[k], prev[k], bstart[k])
	fmt.Printf(" umin=%d, ueven=%d, umax=%d, umaxscope=%d,",
		umin[k], ueven[k], umax[k], umaxscope[k])
	fmt.Printf(" vmin=%d, veven=%d, vmax=%d, vmaxscope=%d\n",
		vmin[k], veven[k], vmax[k], vmaxscope[k])
	fmt.Printf(" firstdeep=%d, lastdeep=%d, middeep0=%d, middeep1=%d\n",
		firstdeep[k], lastdeep[k], middeep0[k], middeep1[k])
}

@ 잘못된 입력을 만나면 하소연하고 물러난다. 여러 군데서 부르므로 함수로 둔다.
@<함수들@>=
func die(format string, a ...any) {
	fmt.Fprintf(os.Stderr, format+"\n", a...)
	os.Exit(1)
}

@* 고리 없음에 대하여.
고리 없음을 얻겠다고 이렇게 몸을 비트는 것은 대개 권할 일이 못 된다. 실제로는
좀 더 곧이곧대로 짠 알고리즘보다 전체 실행 시간이 길어지기 때문이다. 그래도
고리 없음에는 학문적인 멋이 있다. 그러니 이 일을 알고리즘의 재치를 벼리는
연습문제로 삼아도 좋겠다.

(어쩌면 전체 실행 시간을 늦추지 않는 고리 없는 알고리즘도 있을지 모른다.
이를테면 \.{li-ruskey.w}의 고리 없는 구현은 꽤 빠르지만, 그 대신 준비에
$\Omega(n^2)$ 걸음과 $\Omega(n^2)$ 자리를 쓸 때가 있다. 그렇게 빠른 구현이
있다는 것은 완전 비순환 다이그래프에 여기서 쓴 접근보다 나은 길을 열어 줄
성질이 더 있을 수도 있다는 뜻이다. 더 나은 방법을 찾아보시라.)

@ 마지막으로 확인해 둘 것. 이 \GO/ 판은 크누스의 \.{CWEB} 원본과 글자 하나
다르지 않아야 한다. 정점이 일곱 이하인 연결 거미 10,067개 모두에 대해
{\tt ctangle}\thinspace+\thinspace{\tt gcc}로 지은 원본과 이 프로그램의 출력을
견주어 보았고, 활동 목록과 표까지 찍는 |verbose| 출력을 포함해 한 줄도
어긋나지 않았다. 그와 별개로, 같은 10,067개에 대해 이 프로그램이 찍어 낸 것이
정말로 조건을 지키는 라벨링 전부인지, 서로 다른지, 한 걸음에 한 비트만 바뀌는지,
뒤 절반이 앞 절반의 거울상인지, 뿌리 비트가 딱 한 번 바뀌는지를 따로 확인했다.

@* 색인.
