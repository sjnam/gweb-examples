\input kotexgweb
\input luamplib.sty

% macros for non-centered displays
\outer\def\begindisplay{\obeylines\startdisplay}
{\obeylines\gdef\startdisplay#1
  {\catcode`\^^M=5$$#1\halign\bgroup\parindent=3pc\indent##\hfil&&\qquad##\hfil\cr}}
\outer\def\enddisplay{\crcr\egroup$$}

% 그림 셋(fig_digraph, fig_low, fig_fallacy)은 tarjan-strong.mp 안에 있다.
\everymplib{input tarjan-strong;}

\def\title{강한 성분}

% 크누스가 원본에서 쓴 화살. 유향그래프의 호를 뜻한다.
\def\dadj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-12mu\to\!}}

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}
\def\dts{\mathinner{\ldotp\ldotp}}

@* 들어가며.
유향그래프에서 꼭짓점 $u$가 $v$로 가는 길을 갖고 $v$도 $u$로 오는 길을 가지면, 그
둘은 서로 오갈 수 있다. 이 ``서로 오갈 수 있음''은 동치관계이고, 그래서 꼭짓점들은
몇 개의 덩어리로 깔끔하게 나뉜다. 그 덩어리를 {\it 강한 성분\/}(strong component)
이라 부른다.

강한 성분을 찾는 일은 유향그래프를 다루는 거의 모든 자리에서 첫걸음이 된다. 성분
하나를 점 하나로 오므리면 남는 것은 순환이 없는 그래프이고, 그러면 위상 정렬이
되고, 그러면 동적 계획법이 된다. 2-SAT도, 문법의 좌재귀 판정도, 웹 그래프의
덩어리 세기도 다 여기서 출발한다.

@ 이 프로그램은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{tarjan-strong.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/tarjan-strong.w}을
\.{GWEB}으로 옮긴 것이다. 크누스는 그것을 {\sl The Art of Computer Programming\/}
예비 분책~12a에 실릴 알고리즘 7.4.1.2T에 맞추어 썼고, 첫머리에 이렇게 적었다:
``성분 사이와 성분 안의 최소 연결을 출력하는 종과 호루라기를 죄다 달아 두었다.
그 기능들이 쓰는 메모리 참조는 기본 절차의 |mems|와 따로 센다.''

알고리즘 자체는 Robert Tarjan이 1972년에 낸 것이다 [{\sl SIAM Journal on
Computing\/} {\bf 1} (1972), 146--160]. 깊이 우선 탐색 한 번으로 모든 강한 성분을
찾아내며, 시간은 꼭짓점 수와 호의 수의 합에 비례한다.

@ 살펴볼 그래프는 명령줄에서 \.{.gb} 파일 이름으로 준다. 그래프의 호 몇 개를 지운
채로 보고 싶다면 그것도 명령줄에서 말할 수 있다: `\.{-$u$}~\.{--$v$}'라고 적으면
$u\dadj v$가 빠진다. 한 성분을 둘로 쪼개는 호가 무엇인지 손으로 더듬어 볼 때 쓴다.

@ 이 프로그램은 스탠퍼드 그래프베이스(\.{SGB})의 그래프 자료형을 그대로 쓴다. Go
판은 \pdfURL{\.{go-sgb}}{https://github.com/sjnam/go-sgb}에 있고, 돌리려면 그
모듈이 있어야 한다(\.{go get github.com/sjnam/go-sgb}). 이 저장소에서
\.{SGB}에 기대는 두 번째 프로그램이다---앞엣것은 \.{sham.w}였다.

@c
package main

import (
	"fmt"
	"os"
	"strings"
	@#
	"github.com/sjnam/go-sgb/gbgraph"
	"github.com/sjnam/go-sgb/gbsave"
)

// \.{SGB}의 자료형을 짧은 이름으로 그대로 쓴다.
type (
	Graph  = gbgraph.Graph
	Vertex = gbgraph.Vertex
	Arc    = gbgraph.Arc
)

@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 읽는다@>@;
	@<알고리즘을 돌린다@>@;
	@<작별 인사@>@;
}

@* 무엇을 찍는가.
그림~1의 그래프를 보자. 꼭짓점이 여섯이고 화살이 여덟이며, 강한 성분은 셋이다:
$\{a,b,c\}$와 $\{d,e\}$와 홀로 남은 $\{f\}$. 굵은 실선은 깊이 우선 탐색이 지나간
{\it 나무 화살\/}이고, 점선은 그 밖의 화살이다. 두 겹 점은 성분마다 하나씩 뽑히는
{\it 우두머리\/}다.

$$\mplibcode fig_digraph; \endmplibcode$$
\figcap{그림 1. 보기 그래프와 그 세 강한 성분. 탐색은 $f$에서 시작해
$f\dadj d\dadj b\dadj c\dadj a$로 내려간다.}

@ 이 그래프를 넣으면 프로그램은 이렇게 찍는다.
\begindisplay
	\vbox{\halign{#\hfil\cr
	\.{Strong components of example:}\cr
	\kern1em\.{inner e->d}\cr
	\kern1em\.{inner a->b}\cr
	\.{strong component b:}\cr
	\kern1em\.{tree b->c}\cr
	\kern1em\.{tree c->a}\cr
	\.{strong component d:}\cr
	\kern1em\.{tree d->e}\cr
	\.{strong component f:}\cr
	\kern1em\.{link f to d: f->d}\cr
	\kern1em\.{link f to b: f->a}\cr
	\kern1em\.{link d to b: d->b}\cr}}
\enddisplay

@ 그림~1의 그래프는 화살 여덟을 $a\dadj b$, $b\dadj c$, $c\dadj a$, $d\dadj e$,
$d\dadj b$, $e\dadj d$, $f\dadj d$, $f\dadj a$의 차례로 넣어 \.{.gb} 파일로 써
둔 것이다. 넣는 차례를 말해 두는 데는 까닭이 있다. 꼭짓점마다 딸린 호 목록이 어떤
차례로 놓이느냐에 따라 깊이 우선 탐색이 어느 화살을 먼저 보는지가 달라지고, 그러면
나무도 달라지고 찍히는 것도 달라진다. 답---어느 꼭짓점들이 한 성분인가---만은
물론 달라지지 않는다.

@ 줄마다 뜻이 있다. 출력 줄 \.{strong component}~$v$는 새 성분이 하나 완성됐고 그 우두머리가
$v$라는 말이다. 우두머리는 그 성분에서 깊이 우선 번호가 가장 작은 꼭짓점, 곧 탐색이
그 성분에 처음 발을 들일 때 밟은 꼭짓점이다.

딱지 \.{tree}와 \.{inner}는 성분 {\it 안\/}의 화살이다. 그중 \.{tree}는 나무
화살이고,
\.{inner}는 나무 화살만으로는 돌아올 수 없는 곳을 잇는 되돌아가는 화살이다. 둘을
합치면 그 성분은 여전히 강하게 이어져 있다. 위 보기에서 $\{a,b,c\}$가 받은 것은
나무 화살 $b\dadj c$, $c\dadj a$와 안쪽 화살 $a\dadj b$이니, 셋이 고리
$b\dadj c\dadj a\dadj b$를 이룬다. 남는 화살은 하나도 없다.

@ 꼭짓점 하나가 내놓는 안쪽 화살은 많아야 하나다. 그러니 성분에 $k$개의 꼭짓점이
있으면 나무 화살 $k-1$개에 안쪽 화살 $k$개 이하가 붙는다. 이것이 언제나 {\it
최소\/}라는 뜻은 아니다---강하게 이어진 채로 화살을 가장 적게 남기는 문제는
NP-완전이다. 크누스가 든 반례는 화살 다섯이면 된다: $1\dadj2$, $2\dadj3$,
$2\dadj4$, $3\dadj1$, $4\dadj3$에서 이 프로그램은 하나도 못 버리지만, 앞을
내다보는 알고리즘이라면 $2\dadj3$을 지울 수 있다. 그래도 군더더기는 거의 없고,
무엇보다 공짜로 얻어진다. 이 기능은 연습문제~66이 시킨 것이고, 거기서 나오는
나무 아닌 화살들은 {\it 귀 분해\/}(ear decomposition)의 일부이기도 하다.

출력 줄 \.{link $X$ to $Y$: $u$->$v$}는 성분 $X$에서 성분 $Y$로 건너가는 화살이
있다는
말이고, 그 증거로 실제 화살 $u\dadj v$ 하나를 댄다. 같은 성분 쌍에 대해서는 한
번만 찍는다. 위 보기에서 $f$는 $d$의 성분으로도 $b$의 성분으로도 건너갈 수 있고,
$d$의 성분은 $b$의 성분으로 건너갈 수 있다. 성분을 점으로 오므린 그래프가 바로
이 세 화살로 그려진다.

@* 타잔의 알고리즘.
깊이 우선 탐색을 하면서 꼭짓점을 밟는 차례대로 $1,2,3,\ldots$ 번호를 매기자. 이
번호를 $p(v)$라 쓴다. 탐색이 지나간 나무 화살들은 숲을 이룬다.

꼭짓점은 네 단계를 차례로 지난다. 처음에는 아직 못 본 것이고, 번호를 받으면
{\it 활성\/}이 되고, 자기 화살을 다 본 뒤에는 활성을 잃고, 마침내 어느 성분에
드는지 정해지면 {\it 자리 잡는다\/}. 알고리즘~T가 하는 일은 그 마지막 옮김을
제때에 해내는 것뿐이다.

@ 그 제때를 알려 주는 것이 $\.{LOW}$ 값이다. 크누스는 정의가 ``다소 까다롭고
기술적''이라고 미리 일러 둔다. 아직 자리 잡지 않은 $v$에 대해 $\.{LOW}(v)$는,
$v$에서 {\it 내림길\/}로 갈 수 있는 자리 잡지 않은 꼭짓점 $w$의 번호 가운데
가장 작은 것이다. 내림길이란 유향 경로
$$v=v_0\dadj v_1\dadj\cdots\dadj v_r=w\qquad(r\ge0)$$
가운데, $0<j<r$인 모든 $j$에 대해 화살 $v_j\dadj v_{j+1}$이 화살
$v_{j-1}\dadj v_j$보다 {\it 먼저 익은\/} 것을 말한다. 나무 화살 $v\dadj u$는
$u$가 활성을 잃을 때 익고, 나무 아닌 화살은 처음 보는 순간 익는다.

@ 이렇게 비틀어 놓은 데는 까닭이 있다. 이 정의라야 깊이 우선 탐색의 매 걸음에서
$\.{LOW}$ 값이 많아야 하나 바뀌고, 그래서 알고리즘이 그것을 그때그때 따라갈 수
있다.

눈여겨볼 것은 화살 하나만 보는 것이 아니라는 점이다. 이미 익은 화살을 타고 계속
갈 수 있으니, 나무 아닌 화살 $v\dadj u$를 만나면 $p(u)$가 아니라 $\.{LOW}(u)$
까지 물려받는다. 뒤에 볼 \.{T6}이 $p(u)$가 아니라 |vert[u].low|를 보는 까닭이다.
타잔의 1972년 원논문은 다른 정의를 썼고, 이 판은 J.~Eve와 R.~Kurki-Suonio
[{\sl Acta Informatica\/} {\bf 8} (1977), 303--314]에서 실마리를 얻은 것이다.

$$\mplibcode fig_low; \endmplibcode$$
\figcap{그림 2. 같은 그래프의 깊이 우선 나무. 괄호 안은 $(p,\.{LOW})$다. 점선은
나무 아닌 화살. 값이 $\.{LOW}(v)=p(v)$인 세 꼭짓점 $f,d,b$가 곧 성분의 우두머리다.}

@ 그리고 이 한 줄이 알고리즘의 전부다.

\medskip
\noindent{\bf 정리 T.} {\it 깊이 우선 탐색 도중 꼭짓점 $v$가 활성을 잃을 때,
$v$가 지금 웅덩이 성분의 우두머리일 필요충분조건은 $\.{LOW}(v)=p(v)$이다.\/}
\medskip

\noindent 크누스는 이것을 타잔의 ``비밀 소스''라 부른다. 뒷받침하는 것은
보조정리~S다. 아직 자리 잡지 않은 꼭짓점들을 밟은 차례로 늘어놓고 지금까지 본
화살만으로 강한 성분을 따지면, 그 성분들이 그 줄의 {\it 연속한 토막\/}이 되고,
토막마다 맨 앞 원소---우두머리---는 활성이며, 토막들은 나무 화살로 한 줄에
꿰인다.

@ 그래서 알고리즘은 이렇게 굴러간다. 깊이 우선으로 내려가면서 번호를 매기고,
올라오면서 $\.{LOW}$를 부모에게 물려준다. 어떤 꼭짓점 $v$가 활성을 잃을 때
$\.{LOW}(v)=p(v)$이면 성분 하나가 완성된 것이니, 아직 자리 잡지 않은 것들 가운데
$\.{LOW}$가 $p(v)$ {\it 이상\/}인 것을 모두 $v$의 성분으로 거두어들인다.

여기서 ``$\.{LOW}$가 같은 것끼리 한 성분''이라 말하고 싶어지는데, 그것은 참이
아니다. 식구의 $\.{LOW}$가 우두머리의 것보다 클 수 있다. 실제로 무작위 그래프
500개를 돌려 보니 그중 168개에서 그런 식구가 나왔다. 걷어 올리는 자를 등호가
아니라 `$\ge$'로 두는 것이 그래서 중요하다. 그림~2의 보기에서 값이
가지런한 것은 그저 그래프가 작아서다.

``아직 자리 잡지 않은 꼭짓점들''을 담아 두는 곳이 필요하다. 타잔의 원래
논문은 스택 하나를 쓴다. 알고리즘~T도 그렇다. 그 스택을 여기서는 |sink|라
부른다---쓰임을 다한 꼭짓점이 흘러들어 고이는 웅덩이라는 뜻이겠다.

@* 알고리즘 T의 밭들.
크누스의 알고리즘~T는 꼭짓점마다 밭 넷을 둔다. 원본은 그것들을 \.{SGB}의 다목적
필드(|u|, |v|, |w|, |x|, |y|)에 얹었다. 우리는 이름 붙인 구조체를 하나 만들어
꼭짓점 번호로 찾아 쓴다.

@<자료형@>=
// 꼭짓점 하나에 딸린 알고리즘~T의 밭들.
type Node struct {
	par  int  // \.{PARENT}: 나무에서의 부모
	low  int  // \.{LOW}, 또는 성분이 정해진 뒤에는 \.{REP}
	link int  // \.{LINK}: 여러 몫을 겸한다
	arc  *Arc // \.{ARC}: 이 꼭짓점으로 돌아왔을 때 이어서 볼 호
	from int  // 성분 사이 연결을 찍을 때만 쓴다
}

@ 밭마다 하는 일은 이렇다.

밭 |par|는 깊이 우선 나무에서의 부모다. 아직 밟지 않은 꼭짓점은 |null|이고, 나무의
뿌리는 파수꾼 |sent|를 가리킨다. 그러니 이 밭 하나가 ``밟았는가''와 ``어디서 왔는가''를
겸한다.

밭 |link|는 가장 바쁘다. 꼭짓점 $v$의 탐색이 도는 동안에는 $\.{LOW}(v)$를 낮춰 준
화살의
끝점을 가리킨다(아무도 낮추지 않았으면 |sent|). 책의 식~(11)은 여기에 |sent|
아니면 ``없음''만 담아 $\.{LOW}(v)=p(v)$인지를 표시하는데, 안쪽 화살을 찍으려면
누가 낮췄는지도 알아야 하므로 연습문제~66이 시킨 대로 끝점을 적어 둔다.
탐색이 끝나 |sink| 웅덩이로
들어가면 스택의 다음 칸을 가리키고, 성분이 확정돼 |settled| 목록으로 옮겨 가면
거기서 또 다음 칸을 가리킨다. 세 몫을 시차를 두고 나눠 맡는 셈이다.

밭 |arc|는 되돌아왔을 때 이어서 볼 호를 담는다. 되돌이 없이 깊이 우선 탐색을 하려면
꼭 있어야 하는 것이다.

@ 남은 것이 |low|인데, 여기가 재미있다. 알고리즘~T에서 이 밭은 두 얼굴을 갖는다.
꼭짓점 $v$의 성분이 아직 정해지지 않았으면 $\.{LOW}(v)$를 담고, 정해지고 나면 그 성분의
우두머리 $v'$를 담는다---책의 식~(12)에 $\.{SENT}+v'$로 적혀 있다. 곧 우두머리를
담을 때는 모든 $\.{LOW}$ 값보다 큰 값이 되도록 밑값을 얹는다는 말이다. 크누스는
이 겹치기를 타잔이 2021년에 알아챈 것이라고 적었다.

이 겹침은 단순한 절약이 아니라 알고리즘의 한 부분이다. 탐색 중에 이미 밟은 꼭짓점
$u$를 만나면 $\.{LOW}(u)$와 견주어 자기 값을 낮추는데, 만약 $u$의 성분이 이미
끝났다면 그래서는 안 된다. 그런데 그때 |low|에는 밑값이 얹힌 큰 수가 들어 있으니
비교가 저절로 실패한다. 따로 물어볼 것이 없다.

@ 크누스의 \CEE/ 원본은 이 두 얼굴을 공용체로 구현했다. 밭 |low|는 |v.I|(정수)이고
|rep|은 |v.V|(꼭짓점 포인터)인데 둘은 같은 낱말을 나눠 쓴다. 포인터 값은 언제나
$n$보다 훨씬 크니 위의 비교가 그대로 통한다---다만 정말 그런지 원본은 시작할 때
한 번 확인한다. 파수꾼 자리의 포인터를 정수로 읽은 \.{(g->vertices+g->n)->u.I}가
$n$보다 크지 않으면 ``\.{Vertex pointers come too early in memory!!}''를 찍고
$-666$으로 죽는 것이다. 크누스가 골라 둔 종료 코드에서 그가 이 가정을 얼마나
미덥지 않게 여겼는지가 읽힌다.

Go에는 공용체가 없다. 그렇다고 밭 둘로 쪼개면 ``지금 어느 얼굴인가''를 따로 물어야
하고, 그러면 메모리 참조가 하나 늘어 |mems| 계수가 원본과 어긋난다. 그래서 우리는
\CEE/ 원본이 한 대로가 아니라 {\it 책이 적은 대로\/} 한다: |low| 한 밭에 작은
정수 아니면 $\hbox{|rep0|}+v'$를 담는다. 꼭짓점을 $0$부터 $n-1$까지 번호 매기고
$\.{LOW}$ 값이 $1$부터 $n$까지이니 밑값 |rep0|은 $n+1$이면 넉넉하다.

그러면 저 $-666$ 확인은 통째로 사라진다. 기계가 포인터를 어디에 놓든 상관이 없는
자리로 옮겨 놓았기 때문이다.

@ 파수꾼도 마찬가지다. 라이브러리 \.{SGB}의 |NewGraph|는 꼭짓점 배열을 언제나 넉넉하게
잡아 두어 |g.Vertices[g.N]|이 실제로 있는 칸이므로, 알고리즘~T가 \.{SENT}라
부르는 파수꾼을 그 자리에 그대로 둘 수 있다. 우리에게 그것은 그저 번호 |n|이다.
없는 것을 뜻하는 |null|은 $-1$로 한다.

@<전역 변수@>=
const null = -1 // 없음(\CEE/의 \.{NULL})

var (
	mems, xmems uint64 // 기본 절차의 메모리 참조와, 덤으로 얹은 것들의 메모리 참조
	comps       int    // 지금까지 찾아낸 강한 성분의 수
	n           int    // 꼭짓점의 수
	sent        int    // 파수꾼 \.{SENT}의 번호. 곧 |n|이다
	rep0        int    // 우두머리를 |low|에 담을 때 얹는 밑값
	g           *Graph // 살펴보는 그래프
	vert        []Node // 꼭짓점마다의 밭들. 길이는 $|n|+1$
)

@ 메모리 참조를 세는 것은 크누스의 오랜 버릇이다. 원본은 \.{CWEB}의 매크로
`|o|'와 `|oo|'로 한 자리에 하나씩 얹는데, \.{GWEB}에는 매크로가 없으니 우리는
|mems++|와 |mems += 2|를 그대로 쓴다. 덤으로 얹은 기능이 쓰는 것은 |xmems|로
따로 센다. 이 계수가 원본과 한 번호도 어긋나지 않게 맞추는 것이 이 옮김의
숙제였다.

셈해 보면 알고리즘~T는 화살이 $m$개, 꼭짓점이 $n$개일 때 메모리를 많아야
$6m+14n$번 건드린다(책의 연습문제~63). 물론 실행 시간도 $m+n$에 비례한다.

@ 자잘한 도우미 둘. 꼭짓점 번호에서 이름을 얻는 것과, 호가 가리키는 꼭짓점의
번호를 얻는 것이다. 뒤엣것은 \.{SGB}의 |Index|를 부르는데, 그것이 하는 일은
\CEE/ 원본이 \.{a->tip-g->vertices}라고 쓸 때 하는 바로 그 뺄셈이다.

@<함수들@>=
func name(v int) string { return g.Vertices[v].Name }

func idx(v *Vertex) int { return int(g.Index(v)) }

@* 명령줄.
인자는 그래프 파일 하나에, 지울 호마다 두 낱말씩이다. 그러니 인자의 개수는 언제나
짝수여야 한다(프로그램 이름까지 세어서).

@<지역 변수@>=
var p, lowv int
var v, u, w, t, root, sink, settled int
var a *Arc

@ @<명령줄을 읽는다@>=
if len(os.Args)&1 == 1 {
	fmt.Fprintf(os.Stderr, "Usage: %s foo.gb [-U --V]*\n", os.Args[0])
	os.Exit(1)
}
gg, err := gbsave.RestoreGraph(os.Args[1])
if err != nil {
	fmt.Fprintf(os.Stderr, "I couldn't reconstruct graph %s!\n", os.Args[1])
	os.Exit(2)
}
g = gg
n = int(g.N)
sent, rep0 = n, n+1
vert = make([]Node, n+1)
@<필요하면 호를 지운다@>@;
@<무엇을 살펴보는지 알린다@>@;

@ 원본은 실패할 때마다 다른 값으로 죽는다($-1$, $-2$, $-3$, $-4$, 그리고 저
$-666$). Go에서는 종료 코드를 작은 양수로 두는 것이 예의라 $1$에서 $4$까지로
바꿨다. 자리마다 다른 값인 것은 그대로다.

@<무엇을 살펴보는지 알린다@>=
fmt.Printf("Strong components of %s", g.ID)
for p = 2; p < len(os.Args); p += 2 {
	fmt.Printf(" %s %s", os.Args[p], os.Args[p+1])
}
fmt.Printf(":\n")

@ 호를 지우는 일은 이름으로 찾아서 연결 리스트에서 빼내는 것이 전부다. 이름이
틀렸거나 그런 호가 없으면 그 자리에서 죽는다---조용히 넘어가면 엉뚱한 답을 보고
한참을 헤맬 테니까.

@<필요하면 호를 지운다@>=
for p = 2; p < len(os.Args); p += 2 {
	if os.Args[p][0] != '-' || !strings.HasPrefix(os.Args[p+1], "--") {
		fmt.Fprintf(os.Stderr, "improper command-line arguments %s %s!\n",
			os.Args[p], os.Args[p+1])
		os.Exit(3)
	}
	from, to := os.Args[p][1:], os.Args[p+1][2:]
	gone := false
	@<이름이 |from|인 꼭짓점에서 |to|로 가는 호를 빼낸다@>@;
	if !gone {
		fmt.Fprintf(os.Stderr, "I don't see the arc %s->%s!\n", from, to)
		os.Exit(4)
	}
}

@ @<이름이 |from|인 꼭짓점에서 |to|로 가는 호를 빼낸다@>=
for x := 0; x < n; x++ {
	if g.Vertices[x].Name != from {
		continue
	}
	var b, c *Arc
	for c = g.Vertices[x].Arcs; c != nil; b, c = c, c.Next {
		if c.Tip.Name == to {
			break
		}
	}
	if c != nil {
		if b != nil {
			b.Next = c.Next
		} else {
			g.Vertices[x].Arcs = c.Next
		}
		gone = true
	}
	break
}

@* 알고리즘.
이제 알고리즘~T다. 원본은 책의 단계 이름 \.{T1}부터 \.{T9}까지를 그대로 이름표로
달고 |goto|로 오간다. Go에도 |goto|가 있으니 우리도 그대로 둔다. 다른 데 같으면
반복문으로 풀어 쓰는 편이 낫겠지만, 여기서는 이름표가 곧 책의 쪽 번호 구실을
하므로 손대지 않는 것이 옳다.

한 가지 미리 일러둘 것: |lowv|는 지금 다루는 꼭짓점 $v$의 $\.{LOW}$ 값을 레지스터에
들고 있는 것이다. 밭 |vert[v].low|에 적혀 있을 수도 있고 아닐 수도 있다. 이 이중장부가
메모리 참조를 여럿 아낀다.

@<알고리즘을 돌린다@>=
vert[sent].low = 0
@<\.{T1}. 모든 꼭짓점을 밟지 않은 것으로 둔다@>@;
t2:
@<\.{T2}. 다음 뿌리를 찾는다@>@;
t3:
@<\.{T3}. 새 꼭짓점에 번호를 매긴다@>@;
t4:
@<\.{T4}--\.{T6}. 화살을 하나 본다@>@;
t7:
@<\.{T7}. 부모에게 되돌아갈 채비를 한다@>@;
t8:
@<\.{T8}. 성분 하나를 찍어낸다@>@;
t9:
@<\.{T9}. 부모로 돌아간다@>@;
done:
@<성분 사이의 연결을 찍는다@>@;

@ 파수꾼의 $\.{LOW}$를 $0$으로 둔 것은 위에서 이미 했다. 어떤 꼭짓점의
$\.{LOW}$도 $1$ 아래로는 못 가니, 웅덩이 바닥에 놓인 파수꾼은 언제나 ``더 낮은
것''으로 걸린다. 웅덩이를 비울 때 밑바닥을 따로 살피지 않아도 되는 까닭이다.
크누스가 연습문제~61로 물어 두었다.

@<\.{T1}. 모든 꼭짓점을 밟지 않은 것으로 둔다@>=
for w = 0; w < sent; w++ {
	mems++
	vert[w].par = null
}
p = 0 // 이 자리에서 |w|는 |sent|다
sink, settled = sent, null

@ 뿌리를 찾는 훑기는 번호가 큰 쪽에서 작은 쪽으로 내려간다. 변수 |w|는 \.{T1}이
끝난 자리에서 이어받아 쓰는 것이라, 한 번 지나간 자리를 다시 보는 일이 없다.
훑기가 $0$에 닿으면 모든 꼭짓점을 다 밟은 것이다.

@<\.{T2}. 다음 뿌리를 찾는다@>=
if w == 0 {
	goto done
}
w--
mems++
if vert[w].par != null {
	goto t2
}
v, root = w, w
vert[v].par = sent

@ 새로 밟은 꼭짓점에 번호를 매기고, 그 $\.{LOW}$를 자기 번호로 둔다. 밭 |link|를
|sent|로 두는 것은 ``아직 아무도 나를 낮추지 않았다''는 표시다.

@<\.{T3}. 새 꼭짓점에 번호를 매긴다@>=
mems++
a = g.Vertices[v].Arcs
p++
mems += 2
lowv, vert[v].low, vert[v].link = p, p, sent

@ 화살 하나를 보는 대목이 알고리즘의 심장이다. 끝점 $u$를 아직 밟지 않았으면
내려가고, 이미 밟았으면 $\.{LOW}$를 낮출 기회로 삼는다. 낮출 때 |link|에 $u$를
적어 두는 것이 나중에 안쪽 화살을 찍는 밑천이 된다.

@<\.{T4}--\.{T6}. 화살을 하나 본다@>=
if a == nil {
	goto t7
}
mems++
u, a = idx(a.Tip), a.Next
mems++
if vert[u].par == null {
	@<\.{T6}. 아직 밟지 않은 |u|로 내려간다@>@;
}
@<\.{T6}. 그래프 전체가 한 성분임이 드러났으면 일찍 끝낸다@>@;
mems++
if vert[u].low < lowv {
	mems += 2
	lowv = vert[u].low
	vert[v].low, vert[v].link = lowv, u
}
goto t4

@ 내려갈 때는 부모를 적고, 지금 보던 자리를 |arc|에 갈무리해 둔다. 돌아왔을 때
이어서 볼 곳이다.

@<\.{T6}. 아직 밟지 않은 |u|로 내려간다@>=
mems += 2
vert[u].par, vert[v].arc = v, a
v = u
goto t3

@* 일찍 끝내기.
크누스가 얹은 지름길이 하나 있다. 지금 본 화살이 뿌리로 되돌아가는 것이고, 게다가
번호 매기기가 이미 $n$까지 왔다면, 더 볼 것이 없다: 그래프 전체가 한 성분이다.

왜 그런가? 조건 $p=n$은 모든 꼭짓점이 이 나무 안에 들어와 번호를 받았다는 뜻이다.
그런데 앞선 뿌리들의 성분은 이미 다 확정돼 웅덩이에서 빠져나갔으므로, 웅덩이에
남아 있는 것과 지금 내려온 길 위에 있는 것이 곧 아직 정해지지 않은 전부다. 웅덩이에
고인 꼭짓점은 저마다 자기 조상까지 되돌아갈 수 있고, 그 조상은 지금 내려온 길 위에
있다. 그리고 지금 우리는 그 길 끝에서 뿌리로 가는 화살을 방금 보았다. 그러니
남은 것들은 모두 뿌리와 서로 오갈 수 있다. 책에서는 연습문제~62다.

이 지름길이 얼마나 버는지는 그래프 나름이다. 크누스는 빽빽한 그래프에서는 실행
시간이 흔히 $O(n)$까지 줄어든다고 적었다. 반대로, 일찍 끝내도 옳은데 이 조건으로는
잡히지 않는 경우도 있다. 꼭짓점이 $n=5$개이고 화살이
$1\dadj2$, $2\dadj3$, $3\dadj4$, $4\dadj2$, $3\dadj1$, $2\dadj5$, $5\dadj4$의
차례로 드러나는 경우가 그렇다.

@<\.{T6}. 그래프 전체가 한 성분임이 드러났으면 일찍 끝낸다@>=
if u == root && p == n {
	if v != root {
		fmt.Printf(" inner %s->%s\n", name(v), name(root))
	}
	for v != root {
		mems += 2
		vert[v].link, sink, v = sink, v, vert[v].par
	}
	mems++
	u, lowv = sent, 1
	goto t8
}

@ 지름길이 하는 일은 내려온 길 위의 꼭짓점을 모두 웅덩이에 부어 넣고, $v$를
뿌리로, |lowv|를 $1$로 맞추어 \.{T8}로 뛰는 것이다. 값이 $\hbox{|lowv|}=1$이면
웅덩이에 있는 모든 것이 걷힌다.

방금 본 화살 $v\dadj\hbox{|root|}$는 안쪽 화살로 내놓는다. 물론 $v$가 뿌리 자신이면
자기 자신으로 가는 고리이니 내놓지 않는다.

세 값을 한꺼번에 옮기는 대목도 짚어 두자.
$$\hbox{|vert[v].link, sink, v = sink, v, vert[v].par|}$$
이 한 줄은 \CEE/의 쉼표 연산자 \.{v->link=sink,sink=v,v=v->par}와 같은 일을 한다. Go는
오른쪽을 모두 먼저 셈한 뒤에 왼쪽에 넣으므로, 세 대입이 옛 $v$를 보고 한꺼번에
이뤄진다. 순서대로 셈하는 \CEE/와 결과가 같은지는 따져 볼 값어치가 있는데, 이
자리에서는 같다.

@* 부모로 되돌아가기.
꼭짓점 $v$의 화살을 다 보았으면 부모에게 돌아간다. 돌아가기 전에 두 가지를 한다:
$\.{LOW}(v)$가 $p(v)$와 같은지 보아 성분이 완성됐는지 가리고, 아니면 안쪽 화살을
내놓고 $\.{LOW}$를 부모에게 물려준다.

밭 |vert[v].link|가 |sent|라는 것은 아무도 $v$의 $\.{LOW}$를 낮추지 못했다는
뜻이니,
$\.{LOW}(v)=p(v)$이고 $v$는 우두머리다.

@<\.{T7}. 부모에게 되돌아갈 채비를 한다@>=
mems++
u = vert[v].par
mems++
if vert[v].link == sent {
	goto t8
}
if vert[v].link != null {
	fmt.Printf(" inner %s->%s\n", name(v), name(vert[v].link))
}
@<나무 아들 |v|에 비추어 |vert[u].low|를 고친다@>@;
mems++
vert[v].link, sink = sink, v
lowv = vert[u].low
goto t9

@ 여기서 |lowv|는 $\.{LOW}(v)$이고, |vert[v].low|에 적혀 있을 수도 아닐 수도
있다. 또 |vert[u].link|가 |sent|가 아니라면, \.{T6}이 거기에 $u$의 $\.{LOW}$를
책임진 나무 아닌 아들을 적어 두었을 수 있다.

경우가 셋이다. 새 값이 $\hbox{|lowv|}>\.{LOW}(u)$면 할 일이 없다. 반대로 새 값이
$\hbox{|lowv|}<\.{LOW}(u)$면 $\.{LOW}(u)$를 낮추고, 겸해서 |vert[u].link|를
|null|로 지운다---군더더기 안쪽 화살을 찍지 않기 위해서다. 낮춘 값 $\.{LOW}(u)$를
$v$에게서 물려받았으니 $u$가 스스로 내놓을 화살은 없다.

@<나무 아들 |v|에 비추어 |vert[u].low|를 고친다@>=
mems++
if lowv < vert[u].low {
	mems += 2
	vert[u].low, vert[u].link = lowv, null
}

@ 남은 것이 $\hbox{|lowv|}=\.{LOW}(u)$인 경우인데, 크누스는 여기서 한 번 미끄러졌다.
원본에 이렇게 적혀 있다:

\smallskip
{\narrower\noindent ``나는 처음에 \.{u->link}가 \.{sent}가 아니면 그것을 |NULL|로
두어도 된다고 생각했다. 꼭짓점 $v$가 이미 넉넉한 안쪽 화살을 내놓았으니 $u$가
\.{u->link}로 가는 화살을 또 내놓을 까닭이 없다고 여긴 것이다. 그것은 틀렸다.
꼭짓점 $v$가 $u$의 낮은 값을 그대로 베껴 왔을 수 있고, 그렇다면 $v$는 $u$로 가는
안쪽 화살 하나만 내놓은 채 $u$에 기대고 있을 것이기 때문이다.
($1\dadj2$, $2\dadj1$, $2\dadj3$, $3\dadj2$, $3\dadj1$을 생각해 보라.)''\par}
\smallskip

@ 크누스가 든 반례를 이름만 바꿔 그려 보자. 화살이 $a\dadj b$, $b\dadj a$,
$b\dadj c$, $c\dadj b$, $c\dadj a$이고, 탐색은 $c$에서 시작해 $c\dadj b\dadj a$로
내려간다.

$$\mplibcode fig_fallacy; \endmplibcode$$
\figcap{그림 3. 왼쪽이 옳은 답이다. 화살 $b\dadj c$를 빠뜨리면 남는 화살이
$c\dadj b\dadj a\dadj b$뿐이라, $a$에서도 $b$에서도 $c$로 돌아갈 길이 없다.}

@ $a$의 탐색이 끝났을 때를 보자. 꼭짓점 $a$는 화살 $a\dadj b$로 $\.{LOW}(a)=\.{LOW}(b)$를
얻었고 |link|에 $b$를 적어 두었다. 그래서 ``\.{inner a->b}''를 내놓는다. 그런데
$b$ 쪽은 그보다 앞서 화살 $b\dadj c$로 자기 $\.{LOW}$를 낮춰 두었고, |link|에는
$c$가 적혀 있다. 이제 $\hbox{|lowv|}=\.{LOW}(b)$이니 문제의 경우다.

여기서 $b$의 |link|를 지워 버리면 ``\.{inner b->c}''가 사라진다. 남는 것은 나무
화살 $c\dadj b$, $b\dadj a$와 안쪽 화살 $a\dadj b$뿐인데, 이것들만으로는 $c$로
돌아갈 수 없다. 꼭짓점 $a$가 내놓은 화살은 $b$까지밖에 데려다주지 않고, 거기서 앞으로
나아가려면 바로 $b$가 지운 화살이 필요하다. 그러니 그 경우에는 아무것도 하지
않는 것이 옳다.

정말 그런지 확인해 보았다. 원본에서 저 한 줄만 크누스가 처음에 생각했던 대로
고쳐 만든 판을 그림~3의 그래프에 돌리면, 과연 ``\.{inner b->c}''가 사라진다.

@* 성분 하나를 찍어낸다.
단계 \.{T8}에 이르렀다는 것은 $v$가 우두머리이고 성분 하나가 완성됐다는 뜻이다. 웅덩이
|sink|의 위쪽에서 $\.{LOW}$가 |lowv| 이상인 것들이 이 성분의 식구다.

@<\.{T8}. 성분 하나를 찍어낸다@>=
comps++
fmt.Printf("strong component %s:\n", name(v))
if vert[sink].low < lowv {
	@<홀로 선 성분@>@;
} else {
	@<웅덩이에서 식구들을 걷어 올린다@>@;
}
mems++
lowv = vert[u].low

@ 웅덩이 꼭대기가 벌써 낮으면 이 성분의 식구는 $v$ 하나뿐이다. 스스로를 우두머리로
적고 |settled| 목록 앞에 붙인다.

메모리 참조 |mems|를 둘 세는 것에 눈길이 갈 것이다. 하나는 방금 읽은 |vert[sink].low|의 몫이고
하나는 |vert[v].low|에 쓰는 몫이다. 원본이 그 읽기에 표를 붙이지 않고 여기에
`|oo|'를 붙인 것을 그대로 옮겼다.

@<홀로 선 성분@>=
mems += 2
vert[v].low = rep0 + v
xmems++
vert[v].link, settled = settled, v

@ 식구가 여럿이면 웅덩이에서 하나씩 걷어 올리며 우두머리를 적어 준다. 걷어 올린
꼭짓점은 저마다 부모가 있으니, 그 부모로 가는 나무 화살을 여기서 찍는다.

성분이 정해진 꼭짓점들의 목록 |settled|에는 웅덩이에서 걷어 낸 것들이 먼저 오고,
그 뒤에 $v$가, 그 뒤에 전에 있던 것들이 온다. 마지막에 |vert[t].link = v|로 두 토막을 잇는 까닭이다.

@<웅덩이에서 식구들을 걷어 올린다@>=
xmems++
vert[v].link, settled = settled, sink
for {
	mems++
	if vert[sink].low < lowv {
		break
	}
	xmems++
	fmt.Printf(" tree %s->%s\n", name(vert[sink].par), name(sink))
	mems++
	vert[sink].low = rep0 + v
	t = sink
	mems++
	sink = vert[sink].link
}
mems++
vert[v].low = rep0 + v
xmems++
vert[t].link = v

@ 돌아갈 곳이 파수꾼이면 이 나무를 다 본 것이니 새 뿌리를 찾으러 간다. 아니면
부모로 올라가 갈무리해 둔 자리에서 이어 본다.

@<\.{T9}. 부모로 돌아간다@>=
if u == sent {
	goto t2
}
mems++
v = u
a = vert[v].arc
goto t4

@* 성분 사이의 연결.
모든 성분이 정해지고 나면 |settled| 목록에 온 꼭짓점이 담겨 있다. 그것을 한 번
훑으며 화살마다 양 끝의 우두머리를 보면, 성분을 점으로 오므린 그래프가 나온다.
같은 성분 쌍을 두 번 찍지 않으려고 |from| 밭을 표시로 쓴다: $u$의 성분을 훑는
동안 $\hbox{|vert[w].from|}=u$이면 $u$에서 $w$로 가는 연결은 이미 찍은 것이다.

크누스는 이 대목을 자기 프로그램 {\mc ROGET\_COMPONENTS}의 \S17에서 거의 그대로
가져왔다고 적었다. 책에서는 연습문제~65다.

@<성분 사이의 연결을 찍는다@>=
for x := 0; x < sent; x++ {
	vert[x].from = null
}
for v = settled; v != null; {
	xmems += 2
	u = vert[v].low - rep0
	vert[u].from = u
	@<|v|에서 나가는 화살을 모두 본다@>@;
	xmems++
	v = vert[v].link
}

@ @<|v|에서 나가는 화살을 모두 본다@>=
xmems++
a = g.Vertices[v].Arcs
for a != nil {
	xmems += 2
	w = vert[idx(a.Tip)].low - rep0
	xmems++
	if vert[w].from != u {
		xmems++
		vert[w].from = u
		fmt.Printf(" link %s to %s: %s->%s\n",
			name(u), name(w), name(v), a.Tip.Name)
	}
	xmems++
	a = a.Next
}

@ @<작별 인사@>=
s := "s"
if comps == 1 {
	s = ""
}
fmt.Fprintf(os.Stderr, "Altogether %d strong component%s; %d+%d mems.\n",
	comps, s, mems, xmems)

@* 디버깅에 쓸 것들.
크누스는 원본 끝에 ``디버깅할 때 쓸모가 있을지 모르는'' 도우미 둘을 남겼다.
아무 데서도 부르지 않는다. 필요할 때 손으로 한 줄 끼워 넣으라는 것이다. Go는
쓰이지 않는 함수를 나무라지 않으니 그대로 옮겨 둔다.

@<함수들@>=
// 꼭짓점 하나를 사람이 읽을 이름으로.
func symlink(u int) string {
	switch {
	case u == n:
		return "END"
	case u >= 0 && u < n:
		return g.Vertices[u].Name
	default:
		return "??"
	}
}

@ 밭을 다 펼쳐 보이는 것. 밭 |low|의 두 얼굴을 |k <= n|으로 가리는 대목을 눈여겨보라.
\CEE/ 원본이 포인터 값이 크다는 데 기대어 쓴 바로 그 비교인데, 우리 쪽에서는 밑값을
$n+1$로 잡았으니 그대로 성립한다.

@<함수들@>=
func printVert(v int) {
	switch {
	case v == null:
		fmt.Fprintf(os.Stderr, "NULL")
	case v == n:
		fmt.Fprintf(os.Stderr, "SENT")
	case v < 0 || v > n:
		fmt.Fprintf(os.Stderr, " (out of range)")
	default:
		@<꼭짓점 |v|의 밭들을 찍는다@>@;
	}
	fmt.Fprintf(os.Stderr, "\n")
}

@ @<꼭짓점 |v|의 밭들을 찍는다@>=
fmt.Fprintf(os.Stderr, "%s:", name(v))
u := vert[v].par
if u == null {
	fmt.Fprintf(os.Stderr, " (unseen)")
	break
}
fmt.Fprintf(os.Stderr, " parent=%s", symlink(u))
if k := vert[v].low; k <= n {
	fmt.Fprintf(os.Stderr, " low=%d", k)
} else {
	fmt.Fprintf(os.Stderr, " rep=%s", name(k-rep0))
}
if vert[v].link != null {
	fmt.Fprintf(os.Stderr, " link=%s", symlink(vert[v].link))
}
if vert[v].arc != nil {
	fmt.Fprintf(os.Stderr, " arc=%s", symlink(idx(vert[v].arc.Tip)))
}
if vert[v].from != null {
	fmt.Fprintf(os.Stderr, " from=%s", symlink(vert[v].from))
}

@ 스택 하나를 훑어 찍는 것. 부르는 꼴은 |printStack(sink)|이나 |printStack(settled)|이다. 고리가 잘못 이어져 있으면 그것도 알려 준다.

@<함수들@>=
func printStack(top int) {
	v := top
	for ; v >= 0 && v < n; v = vert[v].link {
		fmt.Fprintf(os.Stderr, " %s", name(v))
	}
	if v != null && v != n {
		fmt.Fprintf(os.Stderr, " (bad link!)\n")
	} else {
		fmt.Fprintf(os.Stderr, "\n")
	}
}

@* 맞는지 확인하기.
옮긴 것이 옳은지 보려면 원본과 나란히 돌려 견주는 것이 제일이다. 크누스의 \CEE/
원본을 \.{SGB} 라이브러리와 함께 빌드하고, 같은 \.{.gb} 파일을 두 프로그램에
먹였다.

먼저 \.{SGB}가 품고 있는 진짜 그래프로. {\sl Roget's Thesaurus\/}의 1022개
범주를 서로 가리키는 5075개의 참조로 이은 그래프에서, 두 프로그램은 강한 성분
77개를 찾아냈고 찍어낸 1409줄이 한 글자도 다르지 않았다. 메모리 참조도
\.{32813+25509}로 같았다.

@ 다음은 무작위 대조다. 꼭짓점 1개에서 40개까지, 밀도 여러 가지로 만든 유향그래프
1600개에 --- 그 가운데 3할쯤에는 해밀턴 고리를 억지로 심어 앞서 본 지름길이
실제로 걸리게 했고, 4할쯤에는 호를 하나 지우는 명령줄 인자를 붙였다 --- 두
프로그램을 돌렸다. 표준 출력도 표준 오류도 종료 코드도 모두 같았다. 꼭짓점
200개에서 600개까지의 큰 그래프 15개에서도 마찬가지였다.

특히 |mems| 계수가 한 번도 어긋나지 않았다. 이것이 실은 가장 까다로운 요건이다.
답만 맞히는 것은 쉽지만, 원본이 표를 붙인 자리마다 똑같이 붙이려면 \CEE/의 쉼표
연산자가 무엇을 몇 번 읽는지를 한 줄씩 따져야 한다.

@ 원본과 글자까지 같다는 것만으로는 못 미더운 데가 하나 있다. 원본 자신이
틀렸을 수도 있으니까. 그래서 앞의 「무엇을 찍는가」 장에서 말로만 해 둔 주장들을 따로 검사했다.
꼭짓점 25개까지의 무작위 유향그래프 1500개에 대해, 코사라주 알고리즘으로 강한
성분을 따로 구해 놓고 네 가지를 물었다.

\smallskip
\item{(1)} 프로그램이 나눈 성분이 코사라주가 나눈 것과 같은가?
\item{(2)} \.{inner}로 찍은 화살이 정말 그래프에 있는 화살이고, 그 양 끝이 한
성분 안에 있는가?
\item{(3)} 성분마다 \.{tree}와 \.{inner} 화살만 남겨도 그 성분이 여전히
강하게 이어져 있는가?
\item{(4)} \.{link}로 찍은 것이 성분을 오므린 그래프의 화살 집합과 정확히
같은가---빠짐도 없고, 겹침도 없고, 증거로 댄 화살이 실제로 있는가?
\smallskip

\noindent 그리고 한 꼭짓점이 안쪽 화살을 둘 이상 내놓는 일이 없는지도 함께 보았다.
1500개 모두 통과했다.

@ 잊지 말아야 할 것이 하나 더 있다. 그래프를 담은 \.{.gb} 파일은 \CEE/ 쪽 \.{SGB}가 |save_graph|로
쓴 것을 Go 쪽 |gbsave.RestoreGraph|가 읽었다. 두 구현이 같은 파일을 같은 뜻으로
읽는다는 것까지 이 대조에 딸려 확인된 셈이다.

호 하나를 지워 성분이 갈라지는 것도 보았다. Roget 그래프에서
\.{-clergy}~\.{--churchdom} 하나를 빼면 성분이 77개에서 78개로 는다. 그 화살
하나가 두 덩어리를 붙들고 있었던 것이다.

@* 색인.
