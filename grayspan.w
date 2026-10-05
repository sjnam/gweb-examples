\input kotexgweb
@i types.w
\datethis

\def\title{신장 나무의 그레이 순서}

@* 들어가며.
이 프로그램은 주어진 그래프의 신장 나무를 모두 만들어 낸다. 다만 한 나무에서 다음
나무로 넘어갈 때마다 변을 꼭 하나씩만 바꾼다. 반사 이진 그레이 부호가 이웃한 두
낱말 사이에서 비트를 하나만 바꾸듯이, 신장 나무들을 이웃한 둘이 변 하나만 다르게
늘어놓는 것이다. 이름 \.{grayspan}이 거기서 왔다.

크누스는 이것을 ``조금 서둘러'' 짰다고 적었다. 그런 알고리즘을 실험해 보려고였다.
바탕 생각은 대부분 맬컴 스미스(Malcolm Smith)의 석사 논문 {\sl Generating spanning
trees\/}(빅토리아 대학교, 1997)에서 가져왔다. 그 논문에는 점근적으로 더 나은 성능을
보장하는 복잡한 변형들도 있는데, 크누스는 그런 ``방울과 호루라기''는 나중에 달아
보겠다고 했다.

@ 명령줄의 첫 인자는 무향 그래프를 담은 파일의 이름이다. 파일은 Stanford
GraphBase(\.{SGB})가 그래프를 저장하는 형식이어야 한다. 그래프에 같은 변이 거듭
나와도 되지만, 고리, 곧 꼭짓점에서 제 자신으로 돌아오는 변은 있으면 안 된다.

인자를 더 주면 더 자세히 찍는다. 무엇을 주든 상관없고 개수만 본다. 아무것도 더
주지 않으면 가장 조용해서, 찾은 신장 나무의 수와 쓴 메모리 참조의 수만 찍는다.
인자를 하나 더 주면 변마다 번호를 매겨 알리고, 첫 나무를 통째로 찍은 다음, 그
뒤로는 나무마다 빼는 변과 넣는 변만 찍는다. 둘을 더 주면 알고리즘이 하는 일을
낱낱이 찍는다.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{grayspan.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/grayspan.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Tue, 29 Jun 2004 05:27:03 GMT}다.

그래프 파일은 \pdfURL{go-sgb}{https://github.com/sjnam/go-sgb}의
|gbsave.RestoreGraph|로 읽는다. 프로그램이 찍는 말과 종료 부호는 원본 그대로
두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다. 옮기다가 원본의
결함 하나를 만났다. 고쳤고, 이야기는 맨 뒤에 적었다.

@ 프로그램의 뼈대는 이렇다. 그래프를 읽어 살피고, 알고리즘을 초기화하고, 신장
나무를 모두 만들고, 셈한 것을 알린다.

@c
package main

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	@#
	"github.com/sjnam/go-sgb/gbgraph"
	"github.com/sjnam/go-sgb/gbsave"
)

@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<그래프를 읽는다@>@;
	@<알고리즘을 초기화한다@>@;
	@<신장 나무를 모두 만든다@>@;
	fmt.Fprintf(out, "Altogether %.15g spanning trees, using %.15g mems.\n",
		count, mems)
	out.Flush()
}

@ 크누스는 늘 그렇듯 메모리 참조의 수 |mems|를 센다. 원본은 \.{CWEB}의 매크로
|o|, |oo|, \dots, |ooooo|로 한 자리에 하나부터 다섯까지 얹는다. \.{GWEB}에는
매크로가 없으니 나는 |mems++|와 |mems += 3| 따위를 그대로 쓴다.

까다로운 것은 매크로가 |for| 반복문의 조건 안에 든 자리다. \GO/의 조건에는 식만
쓸 수 있으니, 조건에서 읽는 값은 몸통 첫머리에서 한 번 세고 반복문이 조건에서
끝날 때 한 번 더 센다. 몸통 가운데서 |goto|로 빠져나가는 반복문도 있는데, 거기서는
다음 원소로 넘어가며 읽는 값을 몸통 맨 끝에서 센다. 그래야 빠져나가는 자리에서도
셈이 원본과 한 번호도 어긋나지 않는다.

셈 |mems|와 나무의 수 |count|는 원본처럼 배정도 실수로 둔다. 수가 $10^{15}$을
넘으면 \.{\%.15g}가 지수 꼴로 찍는데, 그때도 원본과 같은 글자가 나오게 하려는
것이다.

@<지역 변수@>=
var (
	mems  float64 // 메모리 참조의 수
	count float64 // 찾은 나무의 수
)

@ 원본에서 |mems|와 |count|는 전역 변수다. 처음 옮길 때 나도 그렇게 두었더니,
나무가 $10^8$개인 그래프에서 원본이 $2.2$초 걸리는 일을 이 판은 $3.1$초 걸렸다.
둘을 |main|의 지역 변수로 옮기자 $1.6$초로 줄어 오히려 원본보다 빨라졌다. 셈은
고친 것이 없으니 차이는 오로지 |mems|가 어디 사느냐에 있다.

까닭은 이렇게 짐작한다. 이 프로그램은 거의 모든 문장마다 |mems|를 고친다.
\GO/ 컴파일러는 전역 변수를 레지스터에 붙들어 두지 않으니, 고칠 때마다
메모리에서 읽고 더하고 도로 쓴다. 앞의 덧셈이 메모리에 다 쓰여야 다음 덧셈이
읽을 수 있으니, 덧셈들이 한 줄로 늘어서 서로를 기다린다. 지역 변수는 레지스터에
둘 수 있어 그런 기다림이 없다.

그 대가로 함수는 |mems|를 볼 수 없다. 원본의 매크로 |delete|와 |undelete|에는
메모리 참조 넷이 들어 있는데, 이 판에서 그것을 맡는 함수 |unlink|와 |relink|는
세지 않고, 부르는 쪽이 대신 센다.

@<전역 변수@>=
var out = bufio.NewWriter(os.Stdout) // 표준 출력의 버퍼

@ 자세히 찍으라고 하면 나무 하나마다 한 줄을 찍는다. \GO/의 |os.Stdout|에는
버퍼가 없어서 그대로 두면 한 줄이 시스템 호출 한 번이니, 버퍼 |out|을 거친다.
그러면 \CEE/의 |exit|와 달리 |os.Exit|는 버퍼를 비워 주지 않는다는 것을 기억해야
한다. 표준 출력에 무언가를 찍은 뒤에 멈추는 자리마다 |out.Flush()|를 부른다.
표준 오류에 알리는 말이 있으면 그보다 먼저 부른다. 원본을 단말기에서 돌릴 때
보이는 차례가 그렇기 때문이다.

@<지역 변수@>=
var (
	n            int      // 꼭짓점의 수
	k            int      // 지금 관심 있는 정수
	u, v, w      *vertex  // 지금 관심 있는 꼭짓점들
	e, f, ff     *arc     // 지금 관심 있는 호들
	vert         []vertex // 꼭짓점들
	verbose      bool     // 자세히 찍는가?
	extraverbose bool     // 아주 자세히 찍는가?
)

@ 원본은 그래프를 읽지 못하면 \.{SGB}가 남긴 오류 부호 |panic_code|를 함께
알린다. 함수 |gbsave.RestoreGraph|는 그것을 오류 값으로 돌려준다.

@<그래프를 읽는다@>=
if len(os.Args) < 2 {
	fmt.Fprintf(os.Stderr, "Usage: %s foo.gb [[gory] details]\n", os.Args[0])
	os.Exit(1)
}
verbose, extraverbose = len(os.Args) > 2, len(os.Args) > 3
g, err := gbsave.RestoreGraph(os.Args[1])
if err != nil {
	var pc gbgraph.PanicCode
	errors.As(err, &pc)
	fmt.Fprintf(os.Stderr,
		"Sorry, can't create the graph from file %s! (error code %d)\n",
		os.Args[1], int64(pc))
	os.Exit(-1)
}
n = int(g.N)
@<그래프를 살피고 일할 채비를 한다@>@;

@* 그래프 준비.
그래프가 최소한의 기준을 갖추었는지 살피는 김에 꼭짓점마다 차수도 센다. 알고리즘이
그것을 쓴다.

이 프로그램은 \.{SGB}의 보통 관례를 벗어나 꼭짓점 |v|에서 나가는 호들을 {\it
이중\/} 연결 리스트로 잇는다. 필드 |v.arcs|는 머리 노드 $h$를 가리키고, |v|에서
나가는 호들은 |h.next|, |h.next.next|, \dots{} 차례로 이어지다가 다시 $h$로
돌아온다. 이 리스트의 호 노드 |e|는 모두 |e.next.prev==e.prev.next==e|를
만족한다. 머리 노드는 |h.tip==nil|이라는 것으로 알아본다.

변의 ``길이'' 필드 |len|은 변을 알아보는 번호로 바꾸어 쓴다. 찍을 때 쓰려는
것이다.

@ 원본은 \.{SGB}의 꼭짓점과 호 레코드를 그대로 쓰고, 필요한 필드는 다목적 필드에
얹는다. 차수 |deg|는 |u.I|에, 뒷고리 |prev|는 |a.A|에 얹는 식이다. 그런데
go-sgb에서는 다목적 필드 하나가 다섯 갈래를 모두 가진 48바이트짜리 구조체라,
꼭짓점 하나가 312바이트, 호 하나가 128바이트나 된다. 그래서 나는 이 프로그램에
필요한 필드만 가진 작은 구조체 둘을 따로 만들고, 읽은 그래프를 거기로 옮겨 담기로
했다. 필드 이름은 원본의 매크로 이름을 따랐다.

@<자료형@>=
type vertex struct {
	arcs *arc    // 호 리스트의 머리 노드
	deg  int     // 지금의 차수
	bfs  *vertex // 너비 우선 탐색의 고리. |nil|이 아니면 이미 보았다
	name string  // 꼭짓점의 이름
}

@ 무향 그래프의 변 하나는 방향이 반대인 호 둘로 적힌다. \.{SGB}의 \CEE/ 판은
그 둘을 메모리에 나란히 놓아 두므로, 한쪽 호의 주소로 다른 쪽 주소를 계산해 낼
수 있다. 크누스는 이것을 ``변 요령''(edge trick)이라 부르고, 원본의 매크로
|mate(e)|가 바로 그 계산이다. \GO/에는 포인터 산술이 없다. 대신 go-sgb의 호에는
짝을 가리키는 필드 |Partner|가 있으니, 그것을 따라 우리 호의 필드 |mate|를
채운다.

원본에서 짝을 찾는 것은 주소 계산일 뿐이라 메모리를 건드리지 않고, 그래서
|mems|도 세지 않는다. 이 판에서 |e.mate|를 읽는 것은 진짜 메모리 참조지만, 셈은
원본에 맞추어 세지 않는다.

@<자료형@>=
type arc struct {
	tip        *vertex // 호가 가리키는 꼭짓점. 머리 노드면 |nil|
	next, prev *arc    // 이중 연결 리스트의 고리
	mate       *arc    // 같은 변을 이루는 반대쪽 호
	link       *arc    // 호에서 호로 잇는 고리
	len        int     // 변의 번호
}

@ 옮겨 담기는 두 번에 걸쳐 한다. 먼저 \.{SGB}의 호마다 우리 호를 하나씩 만들어
대응표 |ours|에 적는다. 그다음에 꼭짓점마다 호 리스트를 이중으로 이으며 원본이
하는 검사를 그대로 한다. 짝을 검사하려면 짝 호가 이미 만들어져 있어야 하는데,
짝은 대개 다른 꼭짓점의 리스트에 들어 있으니 두 번에 나눌 수밖에 없다.

꼭짓점이 하나도 없는 그래프는 맨 처음에 걸러 낸다. 원본에는 이 검사가 없다.
까닭은 맨 뒤에 적었다.

@<그래프를 살피고 일할 채비를 한다@>=
@<꼭짓점이 하나도 없으면 멈춘다@>@;
vert = make([]vertex, n)
ours := make(map[*gbgraph.Arc]*arc)
for i := range vert {
	vert[i].name = g.Vertices[i].Name
	for a := g.Vertices[i].Arcs; a != nil; a = a.Next {
		ours[a] = &arc{tip: &vert[g.Index(a.Tip)]}
	}
}
if verbose {
	fmt.Fprintf(out, "Graph %s has the following edges:\n", g.ID)
}
for i := range vert {
	v = &vert[i]
	@<꼭짓점 |v|의 호들을 이중으로 이으며 살핀다@>@;
}

@ 꼭짓점마다 새 머리 노드를 만들고, \.{SGB}의 호 리스트를 따라가며 우리 호를
차례로 잇고 차수를 센다. 호가 하나도 없으면 고립된 꼭짓점이니 멈춘다.

@<꼭짓점 |v|의 호들을 이중으로 이으며 살핀다@>=
f = new(arc) // 새 머리 노드
v.arcs = f
for a := g.Vertices[i].Arcs; a != nil; a = a.Next {
	e = ours[a]
	e.prev, f.next = f, e
	u = e.tip
	@<호 |e|가 고리이거나 짝이 맞지 않으면 멈춘다@>@;
	@<호 |e|가 번호가 더 큰 꼭짓점을 가리키면 변에 번호를 매긴다@>@;
	v.deg++
	f = e
}
v.arcs.prev, f.next = f, v.arcs // 이중 연결을 마무리한다
if v.deg == 0 {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Graph %s has an isolated vertex %s!\n",
		g.ID, v.name)
	os.Exit(-5)
}

@ 짝이 없거나 짝이 |v|를 가리키지 않으면 그래프가 무향이 아니다. 원본의 말은
``변 요령이 반대쪽 호를 찾지 못한다''인데, 이 판에서는 변 요령 대신 |Partner|를
따랐지만 같은 말을 찍는다.

@<호 |e|가 고리이거나 짝이 맞지 않으면 멈춘다@>=
if u == v {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Oops, there's a loop from %s to itself!\n", v.name)
	os.Exit(-3)
}
if e.mate = ours[a.Partner]; e.mate == nil || e.mate.tip != v {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Oops: There's an arc from %s to %s,\n",
		u.name, v.name)
	fmt.Fprintf(os.Stderr, " but the edge trick doesn't find the opposite arc!\n")
	os.Exit(-4)
}

@ 변에 번호를 매길 때, 변마다 한 번만 매기도록 끝점의 번호가 더 큰 쪽을 가리키는
호에서만 매긴다. 원본은 여기서 꼭짓점의 포인터 둘을 크기로 견주는데, \GO/는
포인터끼리 크기를 견주지 못하므로 \.{SGB}의 |Index|로 얻은 번호를 견준다.

@<호 |e|가 번호가 더 큰 꼭짓점을 가리키면 변에 번호를 매긴다@>=
if g.Index(a.Tip) > int64(i) {
	k++
	e.len, e.mate.len = k, k
	if verbose {
		fmt.Fprintf(out, " %d: %s -- %s\n", k, v.name, u.name)
	}
}

@ 크누스는 디버깅할 때 쓸지도 모른다며 이런 함수를 남겨 두었다. 꼭짓점 하나에서
나가는 호들을 찍는다. 디버거에서 부를 것이라 버퍼를 거치지 않고 바로 찍는다.

다만 \GO/의 링커는 아무도 부르지 않는 함수를 실행 파일에서 빼 버린다. 디버거에서
부르려면 어디선가 한 번은 불러 두어야 한다.

@<함수들@>=
func printArcs(v *vertex) {
	fmt.Printf("Arcs leading from %s:\n", v.name)
	for a := v.arcs.next; a.tip != nil; a = a.next {
		fmt.Printf(" %d (to %s)\n", a.len, a.tip.name)
	}
}

@* 방법.
그래프 $G$에 꼭짓점이 $n>1$개 있다고 하자. 스미스의 알고리즘의 기본 생각은 $G$의
신장 나무를 모두 만들어 내되, 첫 나무가 주어진 {\it 거의 나무\/}(near-tree)를
품게 하는 것이다. 거의 나무란 순환을 이루지 않는 변 $n-2$개의 집합을 말한다.
꼭짓점이 둘뿐이면 일은 쉽다. 변들을 모두 늘어놓기만 하면 된다.

꼭짓점이 $n>2$개이고 거의 나무가 $\{e_1,\ldots,e_{n-2}\}$라면 이렇게 한다. 먼저
변~$e_1$을 줄여, 곧 그 두 끝점을 하나로 붙여 그래프 $G\cdot e_1$을 만든다. 그래프
$G$의 신장 나무 가운데 $e_1$을 품는 것은 모두 $G\cdot e_1$의 신장 나무에 $e_1$을
덧붙여 얻는다. 그러니 거의 나무 $\{e_2,\ldots,e_{n-2}\}$로 시작해 $G\cdot e_1$의
신장 나무를 모두 되부름으로 만든다. 그런 나무가 하나도 없으면 멈춘다. 그때는
$G\cdot e_1$이 연결되어 있지 않으니 $G$도 연결되어 있지 않고, $G$에는 신장 나무가
없다. 그렇지 않으면 $G\cdot e_1$의 마지막 신장 나무가 $f_1\ldots f_{n-2}$였다고
하자. 그러면 변~$e_1$을 지우고, 남은 그래프 $G\setminus e_1$의 신장 나무를 거의
나무 $\{f_1,\ldots,f_{n-2}\}$로 시작해 모두 만들면 일이 끝난다.

@ 이 프로그램은 변의 배열 $a_1\ldots a_{n-1}$을 두고 그 되부름을 곧바로 구현한다.
수준~$l$에 들어설 때 $a_1\ldots a_{l-1}$에는 나무에 넣을 변들이 있고, 그 변들은
지금 그래프에서 이미 줄여져 있다. 자리~$a_l$은 사실상 비어 있고, 나머지
$a_{l+1}\ldots a_{n-1}$에는 다음에 만들 신장 나무에 들어가야 할 거의 나무의
변들이 있다.

``다리,'' 곧 지우면 지금 그래프가 끊어지는 변은 지우지 않는다. 수준~$l$에서
다리가 아닌 변 |e|를 지우면 |changeE=e|로 둔다. 바로 앞에 찾은 신장 나무가
$a_1\ldots a_{n-1}$이었다면, 다음에 찾을 나무는 어떤 새 변~$e'$에 대해 $a_1\ldots
a_{l-1}a_{l+1}\ldots a_{n-1}e'$가 된다. 앞 나무에서 변 |changeE|를 빼고 $e'$를
넣은 것이다.

원본은 배열 원소 $a_l$을 꼭짓점 배열의 다목적 필드에 얹어 |aa(l)|로 부른다. 또
다른 다목적 필드 |del(l)|은 다리에 닿기 전에 지운 변들의 스택을 가리키고, 이
스택의 변들은 필드 |link|로 이어진다. 이 판에서는 둘 다 수준으로 찾는 슬라이스
|aa|와 |del|로 둔다.

@<지역 변수@>=
var (
	l       int    // 지금의 수준
	changeE *arc   // 다음에 바뀔지 모를 변
	aa      []*arc // 변 $a_l$
	del     []*arc // 수준 $l$에서 가장 최근에 지운 변
)

@ 크누스는 ``노련한 독자라면 프로그램의 이 부분에 한 반복문에서 다른 반복문
안으로 뛰어드는 |goto|가 있다고 놀라지 않을 것''이라 적었다. 셋째 반복문에서
다리가 아닌 변을 지우고 나면, 첫째 반복문의 몸통 한가운데 있는 이름표 |enter|로
뛰어든다.

\GO/는 블록 안으로 뛰어드는 |goto|를 허락하지 않는다. 블록 밖으로 뛰어나오는
것은 허락한다. 그래서 나는 첫째 반복문을 이름표 |descend|와 |bottom|으로 풀어
썼다. 그러면 |enter|가 함수 몸통의 맨 바깥 블록에 놓이고, 셋째 반복문에서
거기로 가는 것은 블록 밖으로 뛰어나오는 것이 된다.

꼭짓점이 둘뿐이면 첫째 반복문은 한 번도 돌지 않는다. 그때를 위해 |v|를 미리
꼭짓점 하나로 둔다. 맨 아래 수준이 |v|의 호들을 훑기 때문이다.

@<신장 나무를 모두 만든다@>=
changeE = nil
v = &vert[0] // 이 줄은 $n=2$일 때만 쓸모가 있다
l = 1
descend:
if l >= n-1 {
	goto bottom
}
mems++
del[l] = nil
enter:
@<수준 |l|에 들어서며 변 |aa[l+1]|을 줄인다@>@;
l++
goto descend
bottom:
@<맨 아래 수준에서 남은 변을 하나씩 넣어 본다@>@;
for l--; l > 0; l-- {
	e = aa[l]
	u, v = e.tip, e.mate.tip
	@<꼭짓점 |u|를 되살려 변 |e|를 편다@>@;
	@<변 |e|가 다리가 아니면 지우고, |changeE=e|로 두고, |enter|로 간다@>@;
bridge:
	@<수준 |l|에 들어선 뒤로 지운 변을 모두 되살린다@>@;
}

@ 변을 줄일 때는 차수가 작은 끝점을 큰 끝점에 붙인다. 차수가 작은 쪽의 리스트를
훑어야 하기 때문이다.

@<수준 |l|에 들어서며 변 |aa[l+1]|을 줄인다@>=
mems += 3
e = aa[l+1]
u, v = e.tip, e.mate.tip
mems += 2
if u.deg > v.deg {
	v, e = u, e.mate
	u = e.tip
}
@<꼭짓점 |u|를 |v|로 바꾸어 변 |e|를 줄인다@>@;
mems++
aa[l] = e

@ 맨 아래 수준에서는 꼭짓점이 둘만 남았다. 그 둘 사이의 변을 하나씩 $a_{n-1}$에
넣으면 그것이 저마다 신장 나무다.

@<맨 아래 수준에서 남은 변을 하나씩 넣어 본다@>=
mems++
for e = v.arcs.next; e.tip != nil; e = e.next {
	mems += 3 // 조건의 |e.tip|, |aa[l]|에 넣기, 다음 |e.next|
	aa[l] = e
	@<변 |changeE|를 |e|로 바꾸어 새 신장 나무를 낸다@>@;
	changeE = e
}
mems++ // 마지막 조건의 |e.tip|

@ 첫 나무는 통째로 찍고, 그 뒤로는 바뀐 변만 찍는다. 아주 자세히 찍을 때는
나무마다 통째로 찍고 바뀐 변을 괄호 안에 덧붙인다.

@<변 |changeE|를 |e|로 바꾸어 새 신장 나무를 낸다@>=
count++
if verbose {
	if changeE == nil || extraverbose {
		fmt.Fprintf(out, "%.15g:", count)
		for k = 1; k < n; k++ {
			fmt.Fprintf(out, " %d", aa[k].len)
		}
		if extraverbose && changeE != nil {
			fmt.Fprintf(out, " (-%d+%d)\n", changeE.len, e.len)
		} else {
			fmt.Fprintf(out, "\n")
		}
	} else {
		fmt.Fprintf(out, "%.15g: -%d+%d\n", count, changeE.len, e.len)
	}
}

@ 변 |e|를 줄여 |u|와 |v|를 붙이려면, |u|의 인접 리스트를 |v|의 것에 끼워 넣고
|u|를 가리키던 것을 모두 |v|를 가리키게 고친다. 그런 것들은 |u|의 리스트에 있는
호들의 짝의 |tip| 필드에 있다.

변 |e|가 |e.tip==u|를 만족한다는 것을 눈여겨 두자. 그러니 |e|는 |v|의 리스트에,
|e.mate|는 |u|의 리스트에 있다. 그래서 |u|와 |v| 사이의 변을 지울 때 |e|
자신도 함께 지워지고, |e.link|에서 시작하는 리스트에는 적어도 |e.mate|가 들어
있다.

@<꼭짓점 |u|를 |v|로 바꾸어 변 |e|를 줄인다@>=
mems += 2
k = u.deg + v.deg
@<꼭짓점 |u|의 호들을 |v|로 옮기고 겹친 변은 지운다@>@;
mems += 2
e.link, v.deg = ff, k
if extraverbose {
	fmt.Fprintf(out, "level %d: Shrinking %d; now %s has degree %d\n",
		l, e.len, v.name, v.deg)
}
@<꼭짓점 |u|의 리스트를 |v|의 리스트에 끼워 넣는다@>@;

@ 꼭짓점 |u|와 |v| 사이에 있던 변들은 모두 지운다. 그대로 두면 고리가 되기
때문이다. 지운 변들은 필드 |link|로 이어 두어 나중에 되살릴 수 있게 한다. 차수
|k|는 지운 변마다 둘씩 줄어든다. 두 끝이 모두 붙은 꼭짓점에 있었기 때문이다.

@<꼭짓점 |u|의 호들을 |v|로 옮기고 겹친 변은 지운다@>=
mems++
for f, ff = u.arcs.next, nil; f.tip != nil; f = f.next {
	mems += 2 // 조건의 |f.tip|, 다음 |f.next|
	if f.tip == v {
		unlink(f)
		unlink(f.mate)
		k -= 2
		mems += 9 // 떼어 내기 둘에 넷씩, 그리고 |f.link|
		f.link, ff = ff, f
	} else {
		mems++
		f.mate.tip = v
	}
}
mems++ // 마지막 조건의 |f.tip|

@ 호를 리스트에서 떼어 내는 것은 이중 연결 리스트의 늘 하는 일이다. 원본에서는
매크로 |delete|인데, \GO/의 |delete|는 맵에서 키를 지우는 내장 함수이니 이름을
|unlink|로 바꾸었다. 메모리 참조 넷은 부르는 쪽에서 센다.

@<함수들@>=
func unlink(e *arc) {
	e.prev.next = e.next
	e.next.prev = e.prev
}

@ 반복문이 끝나면 |f|는 |u|의 머리 노드에 와 있다. 이제 |u|의 리스트를 통째로
|v|의 머리 노드 바로 뒤에 끼워 넣는다. 머리 노드 |f|의 두 고리 |f.next|와
|f.prev|는 그대로 남겨 둔다. 펼 때 그것으로 |u|의 리스트를 도로 떼어 낸다.

@<꼭짓점 |u|의 리스트를 |v|의 리스트에 끼워 넣는다@>=
mems++
ff = v.arcs // 이제 |f==u.arcs|다
mems += 4
f.prev.next = ff.next
ff.next.prev = f.prev
mems += 3
f.next.prev = ff
ff.next = f.next

@ 펴기에는 ``춤추는 고리''(dancing links)의 원리를 쓴다. 지운 노드들의 |prev|와
|next| 필드에는 아직 쓸 만한 정보가 남아 있다는 사실을 이용하는 것이다. 다만
지운 차례의 거꾸로 되살려야 한다.

@<꼭짓점 |u|를 되살려 변 |e|를 편다@>=
mems += 2
f, ff = u.arcs, v.arcs
mems += 3
ff.next = f.prev.next
mems++
ff.next.prev = ff
mems += 3
f.prev.next = f
f.next.prev = f
for f = f.prev; f.tip != nil; f = f.prev {
	mems += 3 // 조건의 |f.tip|, |f.mate.tip|, 다음 |f.prev|
	f.mate.tip = u
}
mems++ // 마지막 조건의 |f.tip|
@<꼭짓점 |u|와 |v| 사이의 변들을 되살린다@>@;
if extraverbose {
	fmt.Fprintf(out, "level %d: Unshrinking %d; now %s has degree %d\n",
		l, e.len, v.name, v.deg)
}

@ 줄일 때 지운 변들의 리스트 |e.link|를 따라가며 되살린다. 줄일 때는 한 변의 두
호를 |f|, |f.mate| 차례로 지웠으니 되살릴 때는 거꾸로 한다. 줄이기 전의 |v|의
차수는 지금의 차수에 되살린 호의 수를 더하고 |u|의 차수를 뺀 것이다.

@<꼭짓점 |u|와 |v| 사이의 변들을 되살린다@>=
mems += 2
for f, k = e.link, v.deg; f != nil; f = f.link {
	mems += 9 // 되살리기 둘에 넷씩, 그리고 다음 |f.link|
	k += 2
	relink(f.mate)
	relink(f)
}
mems += 2
v.deg = k - u.deg

@ 이것이 |unlink|의 짝이다. 역시 메모리 참조 넷은 부르는 쪽에서 센다.

@<함수들@>=
func relink(e *arc) {
	e.next.prev = e
	e.prev.next = e
}

@ 다리를 알아보는 데에는 먼저 그래프가 성길 때 흔히 빨리 답을 주는 어림 방법을
써 본다. 꼭짓점 |u|의 차수가~$1$인지 보는 것이다. 또 |e.link.link!=nil|이면
|u|와 |v| 사이에 다른 변이 있었다는 뜻이다. 그 둘로 안 되면 막무가내로 너비
우선 탐색을 해서, |e|를 거치지 않고 |u|에서 |v|로 갈 수 있는지 본다.

크누스는 이렇게 덧붙였다. ``이 알고리즘을 책에 실을 때에는 알고리즘을 짧게 하려고
두 어림 방법을 빼게 될 것 같다. 너비 우선 탐색만으로도 두 경우가 그리 큰 셈을
더하지 않고 풀린다. 다만 지금은 그것들이 얼마나 쓸모 있는지 보려는 것이다.''

다리이면 이름표 |bridge|로 간다. 그것은 이 절을 부르는 반복문 몸통에, 이 절 바로
뒤에 있다.

@<변 |e|가 다리가 아니면 지우고, |changeE=e|로 두고, |enter|로 간다@>=
mems++
if u.deg == 1 {
	if extraverbose {
		fmt.Fprintf(out, "level %d: %d is a bridge with endpoint %s\n",
			l, e.len, u.name)
	}
	goto bridge
}
mems++
if e.link.link != nil {
	@<변 |e|가 다른 변과 나란하다고 알린다@>@;
	goto nonbridge
}
@<너비 우선 탐색으로 다리인지 알아본다@>@;
nonbridge:
changeE = e
@<변 |e|를 지우고 |enter|로 간다@>@;

@ 리스트 |e.link|에는 |e.mate|가 들어 있으니, 그 첫 호가 |e|와 번호가 같으면
둘째 호가 나란한 다른 변이다. 원본은 이것을 삼항 연산자로 한 줄에 적는데,
\GO/에는 삼항 연산자가 없으니 조건문으로 푼다. 변수 |k|를 빌려 쓰지만, 이
뒤에서 |k|는 새로 값을 받은 다음에야 쓰이니 괜찮다.

@<변 |e|가 다른 변과 나란하다고 알린다@>=
if extraverbose {
	if k = e.link.len; k == e.len {
		k = e.link.link.len
	}
	fmt.Fprintf(out, "level %d: %d is parallel to %d\n", l, e.len, k)
}

@ 너비 우선 탐색의 대기열은 꼭짓점의 필드 |bfs|로 잇는다. 대기열의 맨 끝 꼭짓점의
|bfs|는 |v|를 가리키게 해 두어, 대기열을 따라가다 |v|에 닿으면 끝난 줄 안다. 필드
|bfs|가 |nil|이 아니면 이미 본 꼭짓점이다.

탐색이 끝나면 대기열을 처음부터 따라가며 |bfs| 필드를 모두 |nil|로 되돌린다.
원본은 그 일을 하는 똑같은 반복문을 두 군데에 적었는데, 나는 그것을 이름 있는 절
하나로 두고 두 군데에서 끼워 넣는다.

@<너비 우선 탐색으로 다리인지 알아본다@>=
mems++
u.bfs, w = v, u
for u != v {
	@<꼭짓점 |u|의 이웃을 대기열에 넣고, |v|에 닿으면 |nonbridge|로 간다@>@;
	mems++ // 다음 |u.bfs|
	u = u.bfs
}
if extraverbose {
	fmt.Fprintf(out, "level %d: %d is a bridge\n", l, e.len)
}
@<대기열의 |bfs| 고리를 모두 지운다@>@;
goto bridge

@ 꼭짓점 |v|의 |bfs|는 늘 |nil|이니, |u|에서 나가는 호 가운데 |v|에 닿는 것은
빠짐없이 걸린다. 그 가운데 |e.mate|만은 변 |e| 자신이니 빼고 본다. 다른 길로
|v|에 닿았으면 다리가 아니다.

@<꼭짓점 |u|의 이웃을 대기열에 넣고, |v|에 닿으면 |nonbridge|로 간다@>=
mems += 2 // |u.arcs.next|
for f = u.arcs.next; f.tip != nil; f = f.next {
	mems += 2 // 조건의 |f.tip|과 |f.tip.bfs|
	if f.tip.bfs == nil {
		if f.tip == v {
			if f != e.mate {
				@<대기열의 |bfs| 고리를 모두 지운다@>@;
				goto nonbridge
			}
		} else {
			mems += 2
			f.tip.bfs, w.bfs = v, f.tip
			w = f.tip
		}
	}
	mems++ // 다음 |f.next|
}
mems++ // 마지막 조건의 |f.tip|

@ 대기열은 |e.tip|, 곧 처음의 |u|에서 시작한다.

@<대기열의 |bfs| 고리를 모두 지운다@>=
mems++
for u = e.tip; u != v; u = w {
	mems += 2 // |u.bfs|를 읽고 지운다
	w = u.bfs
	u.bfs = nil
}

@ 다리가 아닌 변을 지울 때는 그 변을 수준 |l|의 스택 |del[l]|에 얹는다. 필드
|link|는 줄일 때 쓴 리스트를 가리키고 있었지만, 그 리스트는 방금 펼 때 다 썼으니
덮어써도 된다.

@<변 |e|를 지우고 |enter|로 간다@>=
if extraverbose {
	fmt.Fprintf(out, "level %d: deleting %d\n", l, e.len)
}
mems += 3
e.link, del[l] = del[l], e
unlink(e)
unlink(e.mate)
mems += 10 // 떼어 내기 둘에 넷씩, 그리고 차수 둘
e.tip.deg--
v.deg--
goto enter

@ 다리에 닿았으면 수준 |l|에 들어선 뒤로 지운 변들을 모두 되살리고 한 수준
올라간다. 스택 |del[l]|에는 나중에 지운 변이 위에 있으니, 그것을 따라가면 저절로
지운 차례의 거꾸로 되살리게 된다.

@<수준 |l|에 들어선 뒤로 지운 변을 모두 되살린다@>=
mems++
for e = del[l]; e != nil; e = e.link {
	mems += 13 // 차수 둘, 되살리기 둘에 넷씩, 다음 |e.link|
	e.mate.tip.deg++
	e.tip.deg++
	relink(e.mate)
	relink(e)
	if extraverbose {
		fmt.Fprintf(out, "undeleting %d\n", e.len)
	}
}

@* 시작하기.
거의 다 되었다. 남은 것은 쑥스러운 자잘한 일 하나다. 펌프에 마중물을 붓듯 처음의
거의 나무 $a_2\ldots a_{n-1}$을 마련해야 한다. 크누스는 다른 방법들보다 조금 빠른
것 같다며 깊이 우선 탐색을 썼고, 하는 김에 그래프가 연결되어 있는지도 살핀다.

탐색은 사실 스택을 쓰는 훑기다. 꼭짓점 |v|의 호들을 훑으며 아직 보지 않은
꼭짓점 |u|를 만날 때마다 그리로 가는 변을 $a_k$에 적고 |u|를 스택에 얹는다. 스택은
필드 |bfs|로 잇고, 그 꼭대기가 |w|다. 그렇게 해서 $a_{n-1}$부터 $a_1$까지
채우는데, 사실은 $n-1$개를 다 채운 신장 나무다. 수준~$1$에 들어서면 $a_2\ldots
a_{n-1}$만 쓰고 $a_1$은 덮어쓴다.

스택의 바닥에는 파수꾼으로 첫 꼭짓점 |vert[0]|을 둔다. 그것은 탐색이 떠나는
꼭짓점이기도 해서, 자기 |bfs|가 자기를 가리킨다.

원본은 처음에 첫 꼭짓점 말고 모든 꼭짓점의 |bfs|를 |nil|로 둔다. \.{SGB}가
다목적 필드를 파일에서 읽어 들이니 무엇이 들어 있을지 모르기 때문이다. 우리
꼭짓점은 새로 만든 것이라 이미 |nil|이니 그 반복문은 뺐다. 거기에는 |mems|를 세지
않으니 셈은 같다.

@<알고리즘을 초기화한다@>=
aa, del = make([]*arc, n), make([]*arc, n)
k = n - 1
mems++
v = &vert[0]
w = v
w.bfs = w // 파수꾼은 |vert[0]|이다
for {
	@<꼭짓점 |v|의 이웃 가운데 처음 보는 것을 스택에 얹는다@>@;
	if w == &vert[0] {
		break
	}
	mems++
	v, w = w, w.bfs
}
fmt.Fprintf(out, "Oops, the graph isn't connected!\n")
out.Flush()
os.Exit(0)
connected:
@<꼭짓점의 |bfs| 필드를 모두 지우고 거의 나무를 알린다@>@;

@ 처음 보는 이웃 |u|를 만나면 그리로 가는 변을 $a_k$에 적는다. 그렇게 $n-1$개를
적으면 모든 꼭짓점을 본 것이니, 탐색을 멈추고 이름표 |connected|로 간다.

@<꼭짓점 |v|의 이웃 가운데 처음 보는 것을 스택에 얹는다@>=
mems += 2 // |v.arcs.next|
for e = v.arcs.next; e.tip != nil; e = e.next {
	mems += 2 // 조건의 |e.tip|과 |u.bfs|
	if u = e.tip; u.bfs == nil {
		mems++
		aa[k] = e
		if k--; k == 0 {
			goto connected
		}
		mems++
		u.bfs, w = w, u
	}
	mems++ // 다음 |e.next|
}
mems++ // 마지막 조건의 |e.tip|

@ 여기에 오면 모든 꼭짓점을 보았으니 |bfs| 필드가 모두 |nil|이 아니다. 스택에
남은 꼭짓점들은 스택의 고리까지 들고 있다. 너비 우선 탐색이 그 필드를 깨끗한
채로 받아야 하니 모두 지운다.

@<꼭짓점의 |bfs| 필드를 모두 지우고 거의 나무를 알린다@>=
for i := range vert {
	mems++
	vert[i].bfs = nil
}
if extraverbose {
	fmt.Fprintf(out, "Depth-first search yields the following spanning tree:\n")
	@<배열 |aa|를 찍는다@>@;
}
if verbose {
	fmt.Fprintf(out, "(%.15g mems for initialization)\n", mems)
}

@ 원본에서는 이것이 ``마지막 디버깅 도우미''라는 함수 |print_a|다. 부르는 곳이
여기 하나뿐이라 나는 이름 있는 절로 두었다.

@<배열 |aa|를 찍는다@>=
for k = 1; k < n; k++ {
	fmt.Fprintf(out, " a%d=%d (%s -- %s)\n",
		k, aa[k].len, aa[k].tip.name, aa[k].mate.tip.name)
}

@* 옮기며 고친 것.
원본은 꼭짓점이 하나도 없는 그래프를 받으면 세그먼테이션 오류로 죽는다. 첫
꼭짓점 |g->vertices|를 파수꾼으로 삼아 그 |bfs| 필드에 값을 적는데, 꼭짓점이
없으니 그 자리가 없는 것이다. 이를테면 \.{SGB}의 |gb_new_graph(0)|로 만든 그래프를
저장해 원본에 주면 종료 부호 $139$로 끝난다.

꼭짓점이 하나뿐인 그래프는 원본도 제대로 거른다. 고리가 아닌 변이 있을 수 없으니,
고리가 있으면 고리라고, 없으면 고립된 꼭짓점이라고 알린다. 꼭짓점이 없는 그래프도
같은 식으로 다루는 것이 자연스럽다. 이 판은 ``꼭짓점이 없다''고 알리고 새 종료
부호 $-6$으로 멈춘다.

@<꼭짓점이 하나도 없으면 멈춘다@>=
if n == 0 {
	fmt.Fprintf(os.Stderr, "Graph %s has no vertices!\n", g.ID)
	os.Exit(-6)
}

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 \.{libgb}와 함께 컴파일해 이 판과 견주었다. (요즘의
\CEE/ 컴파일러는 반환형이 없는 원본의 |main|을 받지 않으니 \.{-std=gnu89}를
주었다.) 그래프는 \.{SGB}의 생성기로 만들어 저장한 것을 두 프로그램에 똑같이
먹였다.

\smallskip
\item{$\bullet$} 그래프는 모두 $396$개다. 완전 그래프 $K_1$--$K_9$, 순환 그래프
$C_3$--$C_{12}$, 격자 아홉과 원환면 여섯, 입방체 둘, 바퀴 둘, $K_{3,4}$, 킹
그래프 하나와 나이트 그래프 둘, 미국 도시 그래프 |miles|, |subsets|로 만든
그래프, 변마다 둘씩 겹친 $K_4$, 무작위 다중 그래프 $348$개, 그리고 손으로 만든
것 셋이다. 손으로 만든 것은 다리와 나란한 변이 섞인 사슬, 고립된 꼭짓점 없이
끊어진 그래프, 꼭짓점이 없는 그래프다. 원환면 $2\times n$에도 나란한 변이 생긴다.
무작위 그래프에는 고리가 있는 것, 유향인 것, 고립된 꼭짓점이 있는 것, 끊어진
것이 고루 섞였다.
\item{$\bullet$} 그래프마다 인자를 더 주지 않고, 하나 더 주고, 둘 더 주어 세 번
돌렸다. 다만 나무가 $39675$개에서 $10^8$개인 큰 그래프 여덟은 자세히 찍는 두 번을
뺐다. 그렇게 $1172$가지 가운데, 꼭짓점이 없는 그래프의 세 가지만 빼고 표준 출력,
표준 오류, 종료 부호가 모두 바이트까지 같았다. 마지막 줄의 |mems|도, 초기화에 쓴
|mems|도 같다는 말이다. 무작위 그래프 가운데는 나무가 $2400$만 개에 가까운 것도
있는데, 그것도 아주 자세히 찍은 출력까지 같았다.
\item{$\bullet$} 인자가 없을 때(말에 든 프로그램 이름은 빼고), 그래프 파일이
없을 때, 체크섬이 틀릴 때, 첫 줄부터 엉망일 때의 말과 종료 부호도 같다. 다만 파일이 중간에 망가졌을 때는 오류
부호가 다를 수 있다. \.{SGB}는 어디가 망가졌는지에 따라 $20$에 $-8$부터 $5$까지를
더한 부호를 남기는데, go-sgb는 모두 $20$으로 돌려준다. 이를테면 중간에서 잘린
파일에 원본은 $15$를, 이 판은 $20$을 찍는다.
\item{$\bullet$} 답이 옳은지는 원본과 따로 파이썬으로 따져 보았다. 나무가
$15$만 개 이하인 그래프 $282$개에서, 아주 자세히 찍은 나무마다 정말 신장
나무인지, 나무들이 모두 서로 다른지, 이웃한 두 나무가 변 하나만 다른지, 그리고
나무의 수가 행렬 나무 정리로 셈한 값과 같은지를 보았다. 꼭짓점의 이름이 겹쳐서
검사기가 꼭짓점을 가려내지 못한 $K_{3,4}$와 사슬 그래프 둘만 빼고 모두 맞았다. 그
둘의 나무 수는 닫힌 식으로 셈한 $3^3\cdot4^2=432$개, $2\cdot1\cdot3=6$개와 같다.
\smallskip

\noindent 빠르기도 견주었다. 나무가 $10^8$개인 |subsets| 그래프에서 원본이
$2.2$초, 이 판이 $1.6$초 걸렸다. 완전 그래프 $K_9$의 나무 $4782969$개를 아주
자세히 찍을 때는 원본이 $4.0$초, 이 판이 $2.9$초다.

@* 색인.
