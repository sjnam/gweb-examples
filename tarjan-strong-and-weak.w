\input kotexgweb
\input luamplib.sty

% macros for non-centered displays
\outer\def\begindisplay{\obeylines\startdisplay}
{\obeylines\gdef\startdisplay#1
  {\catcode`\^^M=5$$#1\halign\bgroup\parindent=3pc\indent##\hfil&&\qquad##\hfil\cr}}
\outer\def\enddisplay{\crcr\egroup$$}

% 그림 둘(fig_wdigraph, fig_weak)은 tarjan-strong-and-weak.mp 안에 있다.
% 그 파일은 앞 글의 tarjan-strong.mp를 읽어 도우미 매크로를 나눠 쓴다.
\everymplib{input tarjan-strong-and-weak;}

\def\title{강한 성분과 약한 성분}

% 크누스가 원본에서 쓴 화살. 유향그래프의 호를 뜻한다.
\def\dadj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-12mu\to\!}}

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}
\def\dts{\mathinner{\ldotp\ldotp}}

@* 들어가며.
바로 앞에서 우리는 크누스의 \.{tarjan-strong.w}를 옮기며 타잔의 강한 성분
알고리즘---알고리즘 7.4.1.2T---을 찬찬히 뜯어보았다. 크누스의 프로그램 목록에는
그 이웃으로 \.{tarjan-strong-and-weak.w}가 있다. 같은 알고리즘~T에다 알고리즘
7.4.1.2W를 얹은 것이다. 이 글은 그것을 옮긴다.

@ 그런데 여기서 말하는 {\it 약한 성분\/}은 흔히 그 이름으로 부르는 것이 아니다.
보통 ``약하게 이어진 성분''이라 하면 화살표를 다 지우고 남는 무향그래프의 연결
성분을 뜻한다. 그것은 합집합 찾기로 몇 줄이면 끝나는 일이라, \.{SRANK}니
\.{HIT}이니 \.{WHIT}이니 하는 밭을 다섯 개나 더 두고 아홉 단계짜리 알고리즘을
돌릴 까닭이 없다.

크누스가 말하는 약한 성분은 다른 것이다. 그리고 나는 예비 분책~12a를 갖고 있지
않아서 책의 정의를 그대로 옮겨 적을 수 없었다. 그래서 하는 수 없이 거꾸로 갔다.
프로그램을 여러 그래프에 돌려 보고 무엇을 세는지 알아낸 것이다. 그 이야기를
먼저 하고 코드로 들어가자.

@ 이 프로그램은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{tarjan-strong-and-weak.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/tarjan-strong-and-weak.w}을
\.{GWEB}으로 옮긴 것이다. 앞 글과 마찬가지로 스탠퍼드 그래프베이스(\.{SGB})의
그래프를 읽으며, Go 판인 \pdfURL{\.{go-sgb}}{https://github.com/sjnam/go-sgb}가
있어야 돌아간다. 살펴볼 그래프는 명령줄에서 \.{.gb} 파일 이름으로 주고,
`\.{-$u$}~\.{--$v$}'라고 적으면 $u\dadj v$를 지운 채로 볼 수 있다.

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

@* 약한 성분이란 무엇인가.
유향그래프에서 $u$가 $v$에 닿을 수 있다는 관계는 {\it 준순서\/}다: 자기 자신에
닿고, 닿는 것에 닿으면 또 닿는다. 여기에 대칭성만 없다. 그런데 서로 닿는 것들을
한 점으로 오므리면---곧 강한 성분으로 오므리면---대칭인 짝이 사라져 어엿한
{\it 부분 순서\/}가 된다.

부분 순서에서 두 원소는 셋 중 하나다: $x<y$이거나, $y<x$이거나, 아무 관계도
없거나. 마지막 경우를 {\it 비교 불가능\/}이라 한다. 오므린 그래프의 점들을
꼭짓점으로 하고 비교 불가능한 짝마다 변을 그으면 그래프가 하나 나온다. 그것을
{\it 비교 불가능 그래프\/}라 부르자.

\medskip
\noindent{\bf 약한 성분은 이 비교 불가능 그래프의 연결 성분이다.}
\medskip

@ 그림으로 보는 편이 빠르다. 꼭짓점 일곱에 화살 아홉인 그래프를 보자.

$$\mplibcode fig_wdigraph; \endmplibcode$$
\figcap{그림 1. 보기 그래프. 강한 성분은 여섯이고, 그중 하나만 식구가
둘이다($c$와 $d$가 서로 오간다). 화살은 위로만 간다.}

@ 이것을 오므리면 점 여섯짜리 부분 순서가 되고, 그 비교 불가능 그래프는 세
조각으로 끊어진다.

$$\mplibcode fig_weak; \endmplibcode$$
\figcap{그림 2. 왼쪽은 오므린 그래프와, 거기에 넣을 수 있는 두 개의 자름선.
오른쪽은 그 비교 불가능 그래프이고, 이어져 있는 것끼리가 한 약한 성분이다.
$e<f$이므로 그 둘 사이에는 변이 없지만, $g$가 둘 다와 비교 불가능이라 셋이
한 덩어리가 된다.}

@ 왼쪽 그림의 자름선이 곧 오른쪽 그림의 덩어리다. 이것이 우연이 아니다.
비교 불가능 그래프의 연결 성분들을 $P_1,P_2,\ldots,P_m$이라 하자. 서로 다른
덩어리에 든 두 원소가 비교 가능한 것은 정의에서 곧바로 나온다---변이 없으니까.
게다가 그 방향이 덩어리 전체에서 한결같다. $P_i$ 안에서 변으로 이어진 짝
$x\parallel x'$과 바깥의 $y$를 보자. 만약 $x<y$이면서 $y<x'$이라면 $x<x'$이 되어
$x\parallel x'$에 어긋난다. 그러니 이웃한 둘은 $y$에 대해 같은 쪽에 서고, $P_i$가
이어져 있으니 $P_i$ 전체가 같은 쪽이다. 그러니 덩어리들 자체가 한 줄로 늘어서고, 부분 순서는
$$P=P_1\oplus P_2\oplus\cdots\oplus P_m$$
꼴로 쪼개진다. 이것을 {\it 순서열 합\/}(ordinal sum)이라 한다. 약한 성분은
곧 부분 순서를 순서열 합으로 가장 잘게 쪼갠 조각들인 셈이다.

@ 이 정의가 보통 말하는 ``약하게 이어짐''과 얼마나 다른지는 극단을 보면 대뜸
드러난다. 화살이 하나도 없는 그래프에서는 모든 짝이 비교 불가능이니 비교 불가능
그래프가 완전그래프이고, 약한 성분은 {\it 하나\/}다. 반대로 $1\dadj2\dadj\cdots
\dadj k$인 사슬에서는 모든 짝이 비교 가능이니 변이 하나도 없고, 약한 성분은
$k$개다. 보통의 뜻이었다면 정확히 반대로 나왔을 것이다.

크누스의 프로그램을 실제로 돌려 보면 그대로다. 꼭짓점 셋에 화살이 없으면 ``1
weak component''라 하고, $a\dadj b\dadj c$이면 ``3 weak components''라 한다.

@ 이 풀이가 옳은지는 무식하게 확인했다. 도달 가능성 폐포를 다 구해서 비교 불가능
그래프를 짓고 그 연결 성분을 세는 프로그램을 따로 써서, 무작위 그래프 2500개---그
가운데는 사슬, 추이적 토너먼트, 층으로 나눈 그래프처럼 순서 구조가 뚜렷한 것들을
일부러 많이 섞었다---에 대해 크누스의 프로그램과 견주었다. 한 번도 어긋나지
않았다. 약한 성분의 수가 1부터 20까지 골고루 나왔으니 어쩌다 맞은 것도 아니다.

@* 자름선은 어디에 놓이는가.
알고리즘~W가 어떻게 굴러갈 수 있는지는 앞 절의 순서열 합에서 곧바로 나온다.
$P=P_1\oplus\cdots\oplus P_m$이면 아래 조각의 모든 원소가 위 조각의 모든 원소보다
작으므로, 부분 순서를 아무렇게나 한 줄로 늘어놓아도(곧 어떤 {\it 선형 확장\/}을
잡아도) 조각들은 언제나 {\it 연속한 토막\/}으로 나타난다.

그런데 타잔의 알고리즘이 강한 성분을 내놓는 차례가 바로 그런 한 줄이다. 성분
하나가 완성되는 것은 그 성분이 닿을 수 있는 성분이 모두 완성된 뒤이므로, 나오는
차례는 위에서 아래로다. 그래서 $i$번째로 나온 성분에 $\.{SRANK}=n-i$를 주면
$v$가 $u$에 닿을 때 $\.{SRANK}(v)<\.{SRANK}(u)$가 된다.

@ 그러니 알고리즘~W가 할 일은 이것뿐이다. 성분을 위에서부터 하나씩 받으면서,
새로 온 성분 $v$ 바로 위에 자름선을 넣을 수 있는지 묻는다. 넣을 수 있으면
새 조각이 시작되고, 없으면 $v$는 위쪽 조각들과 한 덩어리가 된다.

자름선을 넣을 수 있는 조건은 간단하다: $v$가 지금까지 나온 {\it 모든\/} 성분보다
아래여야 한다. 하나라도 비교 불가능한 것이 있으면 그 자리에 변이 생기니 자를 수
없고, 그 성분이 든 조각부터 아래로는 모두 한 덩어리가 되어야 한다. 이 ``덩어리
합치기''가 뒤에 볼 |wcomps--| 반복문의 정체다.

@* 밭이 아홉 개.
알고리즘~T가 쓰는 밭은 넷이었다(\.{PARENT}, \.{LOW}/\.{REP}, \.{LINK}, \.{ARC}).
알고리즘~W가 다섯을 더 쓴다: \.{SRANK}, \.{SRC}, \.{HIT}, \.{WHIT}, \.{WLINK}.
합쳐서 아홉이다.

그런데 \.{SGB}의 꼭짓점에는 다목적 필드가 여섯뿐이다. 그래서 크누스는 꼭짓점을
$n+1$개 더 할당해 놓고 밭 하나(|ext|)를 그리로 가는 포인터로 써서 여섯 개를
더 빌려 온다. 다섯을 얻으려고 하나를 내주는 셈이다.

Go로 옮기면 이 대목이 통째로 없어진다. 우리는 어차피 이름 붙인 구조체를 만들어
꼭짓점 번호로 찾아 쓰니, 밭이 아홉이든 열이든 그냥 적으면 그만이다. 메모리
참조를 세는 데도 아무 차이가 없다---원본도 |ext|를 거쳐 가는 것을 따로 세지
않기 때문이다.

@<자료형@>=
// 꼭짓점 하나에 딸린 알고리즘~T와~W의 밭들.
type Node struct {
	par   int  // \.{PARENT}: 나무에서의 부모
	low   int  // \.{LOW}, 또는 성분이 정해진 뒤에는 \.{REP}
	link  int  // \.{LINK}: 여러 몫을 겸한다
	arc   *Arc // \.{ARC}: 되돌아왔을 때 이어서 볼 호
	srank int  // \.{SRANK}: 강한 성분이 나온 차례를 거꾸로 센 것
	hit   bool // \.{HIT}
	whit  bool // \.{WHIT}
	wlink int  // \.{WLINK}
	src   int  // \.{SRC}
}

@ 앞 글에서 길게 이야기한 |low| 밭의 두 얼굴은 여기서도 그대로다. 성분이 정해지기
전에는 $\.{LOW}(v)$를, 정해진 뒤에는 우두머리를 담는다. \CEE/ 원본은 그것을
공용체로 겹쳐 두고 포인터 값이 $n$보다 크다는 데 기대지만(그래서 아니면
$-666$으로 죽지만), Go에는 공용체가 없으니 우리는 책이 적은 대로 한 밭에
$\hbox{|rep0|}+v'$를 담는다. 자세한 사연은 앞 글에 적어 두었다.

@<전역 변수@>=
const null = -1 // 없음(\CEE/의 |NULL|)

var (
	debugging     bool   // 켜면 성분마다 밭을 죄다 찍는다
	mems, xmems   uint64 // 알고리즘~T와, 알고리즘~W의 메모리 참조
	comps, wcomps int    // 강한 성분과 약한 성분의 수
	n             int    // 꼭짓점의 수
	wpsr          int    // 지금 |wp|의 |srank|
	c1p           bool   // 경우~$1'$인가?
	sent, rep0    int    // 파수꾼의 번호와, 우두머리를 담을 때 얹는 밑값
	g             *Graph // 살펴보는 그래프
	vert          []Node // 꼭짓점마다의 밭들. 길이는 $|n|+1$
	settled       int    // 성분이 정해진 꼭짓점들의 목록
)

@ 도우미 둘은 앞 글의 것과 같다. 꼭짓점 번호에서 이름을 얻는 것과, 호가 가리키는
꼭짓점의 번호를 얻는 것이다.

@<함수들@>=
func name(v int) string { return g.Vertices[v].Name }

func idx(v *Vertex) int { return int(g.Index(v)) }

@* 명령줄.
명령줄을 읽는 대목은 앞 글과 한 글자도 다르지 않다. 인자의 개수는 짝수여야 하고,
첫 인자가 그래프 파일이며, 그 뒤로 두 낱말씩이 지울 호를 가리킨다.

@<지역 변수@>=
var p, lowv int
var v, u, w, t, root, sink, wp, prev int
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

@ @<무엇을 살펴보는지 알린다@>=
fmt.Printf("Strong components of %s", g.ID)
for p = 2; p < len(os.Args); p += 2 {
	fmt.Printf(" %s %s", os.Args[p], os.Args[p+1])
}
fmt.Printf(":\n")

@ @<필요하면 호를 지운다@>=
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

@* 알고리즘 T, 간추린 판.
알고리즘~T는 앞 글에서 단계마다 뜯어보았으니 여기서는 달라진 곳만 짚는다. 이
프로그램은 성분 안의 최소 연결이니 성분 사이의 연결이니 하는 덤을 얹지 않는다.
그래서

\smallskip
\item{$\bullet$} \.{T6}에서 $\.{LOW}$를 낮출 때 |vert[v].link|에 그 화살의
끝점을 적어 두지 않고 그냥 |null|로 지운다. 안쪽 화살을 찍을 일이 없으므로
누가 낮춰 주었는지 기억할 까닭도 없다.
\item{$\bullet$} \.{T7}에서 안쪽 화살을 찍지 않고, |lowv|를 부모의 것으로
되돌리지도 않는다. 그 일은 \.{T9}가 한꺼번에 한다.
\item{$\bullet$} 성분 하나를 찍어낼 때 식구를 낱낱이 \.{+}로 찍는다. 대신
\.{tree}니 \.{inner}니 하는 줄은 없다.
\smallskip

\noindent 그 대신 \.{SRANK}와 \.{SRC}를 마련하고 알고리즘~W를 부른다.

@<알고리즘을 돌린다@>=
vert[sent].low, vert[sent].hit, vert[sent].srank = 0, false, n
wpsr = n
wp, prev = sent, sent
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
@<약한 성분을 갱신한다@>@;
t9:
@<\.{T9}. 부모로 돌아간다@>@;
done:

@ 파수꾼에 세 가지를 심어 두는 것으로 시작한다. $\.{LOW}=0$은 웅덩이 바닥
노릇을, $\.{HIT}$가 거짓인 것은 \.{W4}의 훑기가 멈출 자리를, $\.{SRANK}=n$은
어떤 성분의 |srank|보다도 크다는 것을 맡는다.

@<\.{T1}. 모든 꼭짓점을 밟지 않은 것으로 둔다@>=
for w = 0; w < sent; w++ {
	mems++
	vert[w].par = null
	xmems += 2
	vert[w].hit, vert[w].whit = false, false
}
p = 0 // 이 자리에서 |w|는 |sent|다
sink, settled = sent, null

@ @<\.{T2}. 다음 뿌리를 찾는다@>=
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

@ @<\.{T3}. 새 꼭짓점에 번호를 매긴다@>=
mems++
a = g.Vertices[v].Arcs
p++
mems += 2
lowv, vert[v].low, vert[v].link = p, p, sent

@ @<\.{T4}--\.{T6}. 화살을 하나 본다@>=
if a == nil {
	goto t7
}
mems++
u, a = idx(a.Tip), a.Next
mems++
if vert[u].par == null {
	mems += 2
	vert[u].par, vert[v].arc = v, a
	v = u
	goto t3
}
@<\.{T6}. 그래프 전체가 한 성분임이 드러났으면 일찍 끝낸다@>@;
mems++
if vert[u].low < lowv {
	mems += 2
	lowv = vert[u].low
	vert[v].low, vert[v].link = lowv, null
}
goto t4

@ 지름길은 앞 글의 것과 같다. 뿌리로 되돌아가는 화살을 보았는데 번호 매기기가
이미 $n$까지 왔다면 그래프 전체가 한 성분이다. 안쪽 화살을 찍지 않으니 그
대목만 빠졌다.

@<\.{T6}. 그래프 전체가 한 성분임이 드러났으면 일찍 끝낸다@>=
if u == root && p == n {
	for v != root {
		mems += 2
		vert[v].link, sink, v = sink, v, vert[v].par
	}
	mems++
	u, lowv = sent, 1
	goto t8
}

@ @<\.{T7}. 부모에게 되돌아갈 채비를 한다@>=
mems++
u = vert[v].par
mems++
if vert[v].link == sent {
	goto t8
}
mems++
if lowv < vert[u].low {
	mems += 2
	vert[u].low, vert[u].link = lowv, null
}
mems++
vert[v].link, sink = sink, v
goto t9

@ @<\.{T9}. 부모로 돌아간다@>=
if u == sent {
	goto t2
}
mems += 2
v = u
a = vert[v].arc
lowv = vert[v].low
goto t4

@* 성분 하나를 찍어낸다.
여기서 |srank|와 |src|가 심어진다. |srank|는 앞에서 본 대로 나온 차례를 거꾸로
센 것이고, |src|는 바로 앞에 나온 성분을 가리킨다. 그러니 |src|를 따라가면 이미
나온 성분들을 최근 것부터 거슬러 훑을 수 있다. 알고리즘~W의 \.{W4}가 그 길을
걷는다.

@<\.{T8}. 성분 하나를 찍어낸다@>=
comps++
xmems += 2
vert[v].srank, vert[v].src = n-comps, prev
prev = v
fmt.Printf("strong component %s(%d):\n", name(v), vert[v].srank)
xmems++
vert[v].link = sink
t = v
@<웅덩이에서 식구들을 걷어 올린다@>@;
mems++
vert[v].low = rep0 + v
xmems++
vert[t].link = settled
settled = v

@ 걷어 올린 식구는 \.{+} 한 글자를 앞세워 찍는다. 우두머리는 이미 머리글에
나왔으므로 다시 찍지 않는다.

|t|는 마지막으로 걷어 올린 꼭짓점이다(하나도 없었으면 |v| 자신). 성분 안의
꼭짓점들이 |link|로 이어져 있고 그 꼬리가 |t|이니, |vert[t].link|에 예전
|settled|를 이어 붙이면 목록이 그대로 늘어난다.

@<웅덩이에서 식구들을 걷어 올린다@>=
for {
	mems++
	if vert[sink].low < lowv {
		break
	}
	fmt.Printf("+%s\n", name(sink))
	mems++
	vert[sink].low = rep0 + v
	t = sink
	mems++
	sink = vert[sink].link
}

@* 알고리즘 W.
성분 하나가 완성될 때마다 알고리즘 7.4.1.2W의 \.{W2}부터 \.{W8}까지가 돈다.
크누스는 여기에 책의 연습문제에 나오는 손질 둘을 이미 얹어 두었다. 하나는
\.{W8}에서 $\.{WP}\gets v$로 두지 않는 것이다---그의 \.{WP}는 새로 시작한
조각의 우두머리가 아니라 그 {\it 위\/} 조각의 우두머리다. 또 하나는 \.{HIT}을
경우~$1'$에서만 심는 것이다.

이 대목에서 |u|와 |w|는 알고리즘~T의 것과 다른 뜻으로 쓰인다. 원본은 블록 안에서
같은 이름을 새로 선언해 바깥 것을 가린다. Go에서도 그렇게 할 수 있으니 그대로
따랐다.

@<약한 성분을 갱신한다@>=
{
	var u, w, up, vp int // 바깥의 |u|, |w|를 가린다
	@<\.{W2}. |v|에서 나가는 화살을 훑어 |whit|과 |vp|를 정한다@>@;
	@<\.{W3}. 위쪽 조각들을 어디까지 합쳐야 하는지 본다@>@;
w4:
	@<\.{W4}. |v|가 위쪽 모두보다 아래인지 |src| 길을 걸어 본다@>@;
w5:
	@<\.{W5}. 새 조각을 연다@>@;
w6:
	@<\.{W6}. |v|의 |wlink|를 적고 찍는다@>@;
	@<\.{W7}. |whit|을 되돌리고 |hit|을 심는다@>@;
	if debugging {
		printSettled()
	}
}

@ \.{W2}는 성분 $v$의 식구들이 내는 화살을 모두 훑는다. 성분 밖으로 나가는
화살의 끝점---곧 $v$가 곧바로 닿는 성분---마다 |whit|을 세우고, 그중 |srank|가
가장 작은 것을 |vp|에 담는다. 그러니까 |vp|는 $v$ 바로 위에 있는 것들 가운데
가장 낮은 것이다.

식구들은 |settled|의 앞쪽에 |v|부터 |t|까지 늘어서 있다. 그 토막만 훑으면 된다.

@<\.{W2}. |v|에서 나가는 화살을 훑어 |whit|과 |vp|를 정한다@>=
w = settled
vp = sent
for {
	xmems++
	a = g.Vertices[w].Arcs
	for a != nil {
		xmems += 2
		u = vert[idx(a.Tip)].low - rep0
		if u != v {
			xmems++
			vert[u].whit = true
			xmems++
			if vert[u].srank < vert[vp].srank {
				vp = u
			}
		}
		xmems++
		a = a.Next
	}
	if w == t {
		break
	}
	xmems++
	w = vert[w].link
}

@ 성분 $v$가 나가는 화살을 하나도 갖지 않았다면($\hbox{|vp|}=\hbox{|sent|}$)
$v$는 그 무엇보다도 아래가 아니다. 곧 이미 나온 모든 성분과 비교 불가능이니,
지금까지의 조각이 몇이었든 그것들과 $v$가 죄다 한 덩어리가 된다. 그래서
|wcomps|를 $1$로 {\it 되돌린다}. 처음 볼 때 눈을 의심하게 되는 줄인데,
알고 보면 이 알고리즘에서 가장 시원한 한 수다.

그렇지 않으면 |vp|가 지금 조각의 우두머리 |wp|보다 위에 있는 동안 조각들을
하나씩 합쳐 올라간다. |c1p|는 이 반복문이 한 번도 돌지 않았음을---곧 경우~$1'$
임을---기억해 둔다.

@<\.{W3}. 위쪽 조각들을 어디까지 합쳐야 하는지 본다@>=
if vp == sent {
	wp, wcomps, wpsr = sent, 1, n
	goto w6
}
xmems++
w = vert[v].src
c1p = true
for {
	xmems++
	if vert[vp].srank < wpsr {
		break
	}
	w = wp
	c1p = false
	wcomps--
	xmems += 2
	wp = vert[w].wlink
	wpsr = vert[wp].srank
}
u = w

@ 이제 물을 것은 하나다: $v$가 위쪽 성분 {\it 모두\/}보다 아래인가? |src| 길을
따라 위로 거슬러 오르며, 만나는 성분마다 $v$가 곧바로 닿는지(|whit|) 본다.
닿지 않는 것이 하나라도 있으면 그것과 $v$는 비교 불가능이니 자를 수 없다.
파수꾼까지 무사히 닿으면 모두보다 아래인 것이니 새 조각을 연다.

닿는 성분은 건너뛰어도 되는데, |hit|이 심어진 것은 그 뒤로도 줄줄이 건너뛸 수
있다. 그래서 안쪽 반복문은 |hit|이 이어지는 동안 내달린다. 그러면서
|vert[up].src|를 새 자리로 당겨 두는 것이 합집합 찾기에서 낯익은 {\it 길
줄이기\/}다. 다음에 이 길을 걸을 때는 훌쩍 건너뛴다.

@<\.{W4}. |v|가 위쪽 모두보다 아래인지 |src| 길을 걸어 본다@>=
if u == sent {
	wcomps++
	goto w5
}
xmems++
if !vert[u].whit {
	goto w6
}
xmems++
up = u
u = vert[u].src
for {
	xmems++
	if !vert[u].hit {
		break
	}
	xmems += 2
	u = vert[u].src
	vert[up].src = u
}
goto w4

@ 새 조각이 열렸으니 조각의 우두머리를 |w|로 옮긴다. 그리고 경우~$1$이었다면
---곧 \.{W3}의 합치기가 한 번도 돌지 않았다면---$v$의 |src|를 파수꾼으로 끊어
둔다. 이러면 다음 사람이 |src| 길을 걸을 때 $v$에서 곧장 꼭대기로 간다.

@<\.{W5}. 새 조각을 연다@>=
xmems++
wp = w
wpsr = vert[wp].srank
if c1p {
	xmems++
	c1p = false
	vert[v].src = sent
}

@ @<\.{W6}. |v|의 |wlink|를 적고 찍는다@>=
xmems++
vert[v].wlink = wp
fmt.Printf(" weak to %s(%d)\n", symlink(wp), wpsr)

@ 마지막으로 \.{W2}가 세운 |whit|을 모두 되돌린다. 겸사겸사 경우~$1'$이었다면
|hit|을 심는다. |c1p|가 거짓일 때는 |srank|를 읽지도 않는다는 데 눈길을 두자.
\CEE/의 |&&|가 앞이 거짓이면 뒤를 셈하지 않으므로 원본은 그 자리에 표를
붙이지 않았고, 우리도 그대로 따라야 계수가 맞는다.

@<\.{W7}. |whit|을 되돌리고 |hit|을 심는다@>=
w = settled
for {
	xmems++
	a = g.Vertices[w].Arcs
	for a != nil {
		xmems += 2
		u = vert[idx(a.Tip)].low - rep0
		if u != v {
			xmems++
			vert[u].whit = false
			@<경우 $1'$이면 |hit|을 심는다@>@;
		}
		xmems++
		a = a.Next
	}
	if w == t {
		break
	}
	xmems++
	w = vert[w].link
}

@ @<경우 $1'$이면 |hit|을 심는다@>=
if c1p {
	xmems++
	if vert[u].srank < wpsr {
		xmems++
		vert[u].hit = true
	}
}

@ @<작별 인사@>=
s, ws := "s", "s"
if comps == 1 {
	s = ""
}
if wcomps == 1 {
	ws = ""
}
fmt.Fprintf(os.Stderr,
	"Altogether %d strong component%s and %d weak component%s;", comps, s, wcomps, ws)
fmt.Fprintf(os.Stderr, " %d+%d mems.\n", mems, xmems)

@* 돌려 보기.
그림~1의 그래프를 넣으면 이렇게 찍힌다.

\begindisplay
	\vbox{\halign{#\hfil\cr
	\.{Strong components of example:}\cr
	\.{strong component a(6):}\cr
	\kern1em\.{weak to END(7)}\cr
	\.{strong component b(5):}\cr
	\kern1em\.{weak to a(6)}\cr
	\.{strong component c(4):}\cr
	\.{+d}\cr
	\kern1em\.{weak to a(6)}\cr
	\.{strong component g(3):}\cr
	\kern1em\.{weak to c(4)}\cr
	\.{strong component f(2):}\cr
	\kern1em\.{weak to c(4)}\cr
	\.{strong component e(1):}\cr
	\kern1em\.{weak to c(4)}\cr}}
\enddisplay

\noindent 그리고 표준 오류로 ``\.{Altogether 6 strong components and 3 weak
components; 107+181 mems.}''

@ 괄호 안의 수가 |srank|다. 맨 먼저 완성된 성분이 $a$이고 $\.{SRANK}=6$을
받았다. 꼭짓점이 일곱이니 파수꾼의 $\.{SRANK}$가 $7$이라, 맨 위 조각인 $\{a\}$는
``\.{weak to END(7)}''---위에 아무것도 없다---고 말한다.

\.{weak to} 뒤에 오는 것은 $v$가 든 조각 {\it 바로 위\/} 조각의 우두머리다.
$b$와 $c$가 한 조각이니 둘 다 $a$를 가리키고, $g$와 $f$와 $e$가 한 조각이니
셋 다 그 위 조각의 우두머리인 $c$를 가리킨다. 조각의 우두머리는 그 조각에서
|srank|가 가장 작은 것---곧 가장 나중에 나온 것---이다.

@ 한 가지 일러둘 것이 있다. 이 줄은 {\it 찍히는 그 순간의\/} 이야기다. 나중에
아래쪽에서 조각들이 합쳐지면 이미 찍힌 줄은 낡은 것이 되는데, 프로그램은 되돌아가
고치지 않는다. 마지막까지 남는 참말은 |wcomps|와, |wp|에서 |wlink|를 따라
꼭대기까지 이어지는 사슬이다. 위 보기에서는 합치기가 한 번도 일어나지 않아
찍힌 것이 모두 그대로 맞다.

@* 디버깅에 쓸 것들.
크누스가 남긴 도우미들이다. 여기 것은 앞 글의 것보다 좀 더 자란다. 우두머리에게만
있는 밭들---|srank|, |hit|, |whit|, |wlink|, |src|---을 함께 찍고, |settled|
목록을 통째로 훑는 것도 하나 붙었다. 전역 변수 |debugging|을 켜면 성분마다
그것이 돈다.

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

@ @<함수들@>=
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

@ |low|의 두 얼굴을 |k <= n|으로 가리는 것은 앞 글과 같다. 우두머리인지는
|low|에 자기 자신이 담겨 있는지로 안다.

@<꼭짓점 |v|의 밭들을 찍는다@>=
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
if vert[v].low == rep0+v {
	@<우두머리에게만 있는 밭들을 찍는다@>@;
}

@ @<우두머리에게만 있는 밭들을 찍는다@>=
fmt.Fprintf(os.Stderr, " srank=%d", vert[v].srank)
if vert[v].hit {
	fmt.Fprintf(os.Stderr, " hit")
}
if vert[v].whit {
	fmt.Fprintf(os.Stderr, " whit")
}
fmt.Fprintf(os.Stderr, " wlink=%s", symlink(vert[v].wlink))
fmt.Fprintf(os.Stderr, " src=%s", symlink(vert[v].src))

@ @<함수들@>=
func printSettled() {
	for w := settled; w != null; w = vert[w].link {
		printVert(w)
	}
}

@* 맞는지 확인하기.
앞 글에서와 같은 방식으로 대조했다. 크누스의 \CEE/ 원본을 \.{SGB} 라이브러리와
함께 빌드하고, 같은 \.{.gb} 파일을 두 프로그램에 먹여 표준 출력과 표준 오류와
종료 코드를 견주었다.

{\sl Roget's Thesaurus\/} 그래프에서 두 프로그램은 강한 성분 77개와 약한 성분
{\it 하나\/}를 찾아냈고, 메모리 참조도 \.{33708+37631}로 같았다. 약한 성분이
하나라는 것은 뜻밖이 아니다---1022개나 되는 범주가 얽힌 그래프라면 비교 불가능한
짝이 얼마든지 있어 비교 불가능 그래프가 넉넉히 이어진다.

@ 무작위 대조는 두 갈래로 했다. 하나는 앞 글에서 쓴 것과 같은 그래프 1615개다.
다른 하나는 알고리즘~W를 일부러 괴롭히려고 만든 것으로, 사슬과 추이적 토너먼트와
층으로 나눈 그래프 600개다. 이런 것들은 순서 구조가 뚜렷해 조각이 여럿 생긴다.
실제로 약한 성분의 수가 1부터 20까지 골고루 나왔으니, \.{W3}의 합치기 반복문도
\.{W4}의 |src| 걷기도 넉넉히 돌아 보았을 것이다. 여기에 꼭짓점 200개에서
600개까지의 큰 그래프 15개를 보탰다. 모두 한 글자도 다르지 않았고 |mems| 계수도
어긋나지 않았다.

@* 색인.
