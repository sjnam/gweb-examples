\input kotexgweb
@i ../types.w
@s Bond int
\datethis

\def\title{결합으로 짓는 신장 나무의 그레이 순서}

@* 들어가며.
이 프로그램은 \.{grayspan}과 \.{spspan}의 생각을 하나로 합친다. 그 결과는 주어진
그래프의 신장 나무를 모두, 한 번에 변 하나씩만 바꾸며 만들어 내는 멋진 루틴이다.
게다가 ``효율이 보장된다.'' 변이 $m$개, 꼭짓점이 $n$개, 신장 나무가 $t$개일 때
전체 실행 시간이 $O(m+n+t)$라는 뜻이다.

독자는 \.{grayspan}과 \.{spspan}을 둘 다 알고 있어야 한다. 그 둘이 어떻게
돌아가는지는 여기서 되풀이하지 않는다. 다행히 이 저장소에 두 프로그램을 옮긴
문서가 다 있다.

@ 이것은 커누스의 \.{CWEB} 프로그램 \pdfURL{\.{grayspspan.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/grayspspan.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Tue, 29 Jun 2004 05:27:04 GMT}다.

그래프 파일은 \pdfURL{go-sgb}{https://github.com/sjnam/go-sgb}의
|gbsave.RestoreGraph|로 읽는다. 프로그램이 찍는 말과 종료 부호는 원본 그대로
두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

@ 명령줄의 첫 인자는 무향 그래프를 담은 파일의 이름이다. 파일은 Stanford
GraphBase(\.{SGB})가 그래프를 저장하는 형식이어야 한다. 인자를 더 주면 더 자세히
찍는다. 무엇을 주든 상관없고 개수만 본다. 아무것도 더 주지 않으면 가장 조용해서,
찾은 신장 나무의 수와 쓴 메모리 참조의 수만 찍는다.

@ 프로그램의 뼈대는 이렇다. 그래프를 읽어 살피고, 꼭짓점이 둘 이상이면 신장
나무를 모두 만든다. 꼭짓점이 하나뿐인 그래프에서는 나무를 하나도 세지 않는데,
원본이 그렇다.

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
	if n > 1 {
		@<신장 나무를 모두 만든다@>@;
	}
	fmt.Fprintf(out, "Altogether %.15g spanning trees, using %.15g mems.\n",
		count, mems)
	out.Flush()
}

@ 커누스는 늘 그렇듯 메모리 참조의 수 |mems|를 센다. 원본은 \.{CWEB}의 매크로
|o|, |oo|, \dots, |oooooo|로 한 자리에 하나부터 여섯까지 얹는다. \.{GWEB}에는
매크로가 없으니 나는 |mems++|와 |mems += 3| 따위를 그대로 쓴다.

매크로가 |for| 반복문의 머리에 든 자리는 이렇게 옮긴다. 조건에서 세는 것은 몸통
첫머리에서 세고, 다음 원소로 넘어가며 세는 것은 몸통 맨 끝에서 센다. 그러면
조건이 거짓이 되어 빠져나갈 때도, 몸통 가운데서 |break|로 빠져나갈 때도 셈이
원본과 어긋나지 않는다.

셈 |mems|와 나무의 수 |count|는 원본처럼 배정도 실수로 두고 \.{\%.15g}로 찍는다.
그리고 둘 다 |main|의 지역 변수로 둔다. \GO/ 컴파일러는 전역 변수를 레지스터에
붙들어 두지 않으므로, 문장마다 고치는 셈을 전역에 두면 프로그램이 눈에 띄게
느려진다. 이 저장소의 \.{grayspan}을 옮길 때 겪은 일이다. 그 대가로 다른 함수는
|mems|를 볼 수 없다. 메모리 참조를 세는 함수 |buildBond|와 |deleteBonds|는 제가
센 수를 돌려주고, 부르는 쪽이 그것을 더한다.

@<지역 변수@>=
var (
	mems  float64 // 메모리 참조의 수
	count float64 // 찾은 나무의 수
	n     int     // 꼭짓점의 수
	m     int     // 변의 수
	l     int     // 지금 줄인 수준
	k     int     // 지금 관심 있는 정수
	u, v, w *vertex // 지금 관심 있는 꼭짓점들
	e, ee, f *arc   // 지금 관심 있는 변들
	b        *Bond  // 지금 관심을 받는 결합
)

@ 아주 자세히 찍으라고 하면 일을 하나 할 때마다 한 줄을 찍는다. \GO/의
|os.Stdout|에는 버퍼가 없어서 그대로 두면 한 줄이 시스템 호출 한 번이니, 버퍼
|out|을 거친다. \CEE/의 |exit|와 달리 |os.Exit|는 버퍼를 비워 주지 않으니, 표준
출력에 무언가를 찍은 뒤에 멈추는 자리마다 |out.Flush()|를 부른다.

자세함의 정도는 원본에서 |argc|를 전역에 베껴 둔 |xargc|로 정하는 매크로다. 이
판에서는 불 값 둘을 전역에 둔다. 함수 |buildBond|도 그것을 보기 때문이다.

@<전역 변수@>=
var out = bufio.NewWriter(os.Stdout) // 표준 출력의 버퍼
var verbose, extraverbose bool      // 자세히 찍는가? 아주 자세히 찍는가?

@ 원본은 그래프를 읽지 못하면 \.{SGB}가 남긴 오류 부호 |panic_code|를 함께
알린다. 함수 |gbsave.RestoreGraph|는 그것을 오류 값으로 돌려준다.

@<그래프를 읽는다@>=
if len(os.Args) < 2 {
	fmt.Fprintf(os.Stderr, "Usage: %s foo.gb [[gory] details]\n", os.Args[0])
	os.Exit(-11)
}
verbose, extraverbose = len(os.Args) > 2, len(os.Args) > 3
g, err := gbsave.RestoreGraph(os.Args[1])
if err != nil {
	var pc gbgraph.PanicCode
	errors.As(err, &pc)
	fmt.Fprintf(os.Stderr,
		"Sorry, can't create the graph from file %s! (error code %d)\n",
		os.Args[1], int64(pc))
	os.Exit(-2)
}
@<그래프를 우리 구조체로 옮겨 담는다@>@;
@<저장 공간을 더 마련한다@>@;
@<그래프가 올바른지 살피고 일할 채비를 한다@>@;

@* 방법과 자료 구조.
이 프로그램의 바탕 생각은 맬컴 스미스(Malcolm Smith)의 석사 논문 {\sl Generating
spanning trees\/}(빅토리아 대학교, 1997)로 거슬러 올라간다. \.{grayspan}의
알고리즘을 고쳐, 변들을 ``결합''(bond)이라 부를 직병렬 부분 그래프로 바꾸어 놓는
것이다.

꼭짓점 |u|와 |v| 사이의 {\it 결합\/}은 주어진 그래프의 변이거나, 결합 여럿을
직렬로 이은 것이거나, 결합 여럿을 병렬로 이은 것이다. 이 프로그램의 알고리즘은
요컨대 \.{grayspan}의 방법으로 결합에 대한 신장 나무를 만들고, \.{spspan}의 방법으로
그에 대응하는 원래 변에 대한 신장 나무를 모두 만든다.

처음에는 변 하나하나를 가장 단순한 결합으로 본다고 하자. 그러면 겹친 결합이
있을 때 그것들을 병렬로 묶어 없앨 수 있다. 또 차수가~2인 꼭짓점은 거기 닿은 두
결합을 직렬로 묶어 없앨 수 있다. 차수가~1인 꼭짓점은 거기 닿은 결합과 함께
그래프에서 빼낼 수 있다. 그 결합이 신장 나무마다 꼭 들어가야 한다고 정해 두면
된다. 주어진 그래프가 연결되어 있다면 이런 줄이기를 거듭한 끝에 {\it 더 줄일 수
없는\/} 단순 그래프에 이른다. 그 그래프는 점 하나뿐인 자명한 것이거나, 모든
꼭짓점의 차수가 3~이상인 것이다.

예를 들어 자명하지 않은 것 가운데 가장 작은, 더 줄일 수 없는 그래프를 생각하자.
꼭짓점이 넷이고 어느 두 꼭짓점 사이에나 결합이 있는 그래프다. 꼭짓점을 $v_1$,
$v_2$, $v_3$, $v_4$, 결합을 $b_{12}$, $b_{13}$, $b_{14}$, $b_{23}$, $b_{24}$,
$b_{34}$라 하자. \.{grayspan}의 알고리즘이 이를테면 신장 나무 $b_{12}b_{13}b_{24}$를
내놓으면, \.{spspan}의 알고리즘으로 $b_{12}$, $b_{13}$, $b_{24}$의 1-구성과 나머지
결합 $b_{14}$, $b_{23}$, $b_{34}$의 0-구성을 모두 돌아가며 짝짓는다. 다음에
\.{grayspan}이 $b_{24}$를 $b_{34}$로 바꾸어 다음 신장 나무를 내놓으면, 이 바꿈은
결합~$b_{24}$의 지정 잎을 빼고 $b_{34}$의 지정 잎을 넣는 것에 해당한다. 그다음
\.{spspan}이 $b_{12}$, $b_{13}$, $b_{34}$의 1-구성과 $b_{14}$, $b_{23}$, $b_{24}$의
0-구성을 모두 돌아가며 짝짓는다.

실제로 이 프로그램이 하는 일은 방금 말한 것과 똑같지는 않다. 결합 $b_{12}$를 줄이면
남은 그래프가 줄어들어 자명한 것이 되어 버리기 때문이다. 그래서 \.{grayspan}의
알고리즘은 예전의 목표였던 $n=2$인 경우에 끝내 이르지 않는다. 그래도 개념으로는
\.{grayspan}에서처럼 변을 줄이고 다리가 아닌 변을 지우며 그래프 전체를 놓고
나아간다. 그리고 결합의 수가 하나 줄 때마다 계산의 더 많은 부분이 아주 효율적인
\.{spspan}의 영역으로 넘어간다.

@ 이 모든 장치를 받칠 자료 구조는 \.{spspan}에서 쓴 필드 |typ|, |val|, |des|,
|done|, |focus|, |rsib|를 담은 구조체 |Bond|로 꾸밀 수 있다. 여기에 |left|와
|right| 포인터가 더 있어야 한다. 가지 노드를 예전처럼 차례로 고정해 두지 않고
이중 연결 리스트에 담아야 하기 때문이다. 그리고 옛 결합에서 새 결합을 지을 때
쓰는 포인터 |lchild|, |lsib|, |scope|가 있고, 결합을 허물 때 쓰는 |lhist|와
|rhist|가 있다. 끝으로 이중 연결 리스트가 또 하나 있는데, 지금 신장 나무에 든 맨
윗 수준의 결합들을 담는다. 그 고리 필드를 |up|과 |down|이라 부른다.

필드 |num|은 이 판에서 더한 것이다. 결합의 번호로, 원본에서는 주소를 빼서
셈한다. 이름은 원본처럼 |Bond|다. 원본에는 |Bond James;|라는 선언이 있는데
``나의 작은 농담''이라는 주석이 달렸다. \GO/로 옮기면 |var James Bond|가 되어
농담이 오히려 더 그럴듯해진다. 쓰는 곳은 없다.

@<자료형@>=
type Bond struct {
	typ          int   // 직렬 결합이면 1, 병렬 결합이면 0, 지움 기록이면 2
	val          int   // 지금 신장 나무에 들었으면 1
	lchild       *Bond // 맨 왼쪽 자식. 잎이면 |nil|
	lsib         *Bond // 왼쪽 형제. 빙 돌아 이어진다
	rsib         *Bond // 오른쪽 형제. 빙 돌아 이어진다
	des          *Bond // 지정 자식
	done         *Bond // 한 바퀴 돌 때 마지막으로 지정할 자식
	scope        *Bond // 전위 순서로 마지막 가지 자손
	focus        *Bond // 그레이 곱을 다스리는 마법의 포인터
	left         *Bond // 작용 리스트의 왼쪽 이웃
	right        *Bond // 작용 리스트의 오른쪽 이웃
	up           *Bond // 나무 리스트의 위쪽 이웃
	down         *Bond // 나무 리스트의 아래쪽 이웃
	lsave, rsave *Bond // 한 경우에 되돌릴 때 쓴다
	lhist, rhist *arc  // 이 결합을 낳은 변들
	num          int   // 결합의 번호
}

@ 그래프에 변이 |m|개 있으면 변 하나짜리 기본 결합을 $1\le k\le m$에 대해
|bondbase[k]|에 둔다. 직렬과 병렬로 묶은 결합, 그리고 결합 지움을 되돌리기 위한
``지움 기록''은 그 뒤의 자리에 나중에 넣은 것을 먼저 꺼내는 차례로 들어간다.

작용 리스트의 머리 노드 |action|은 |bondbase[0]|이다. 나무 리스트의 머리 노드는
따로 둔 |treehead|이고, 원본처럼 그 주소를 |tree|라 부른다.

@<전역 변수@>=
var (
	bondbase        []Bond // 거의 모든 |Bond| 구조체가 사는 곳
	bondcount       int    // 지금 정의된 결합의 수
	topleaf         int    // 잎과 가지의 경계
	treehead        Bond   // 나무 리스트의 머리 노드
	tree            = &treehead
	action          *Bond // 작용 리스트의 머리 노드
	inbond, outbond *Bond // 다음에 넣을 결합과 뺄 결합
	James           Bond  // 나의 작은 농담
)

@ 원본의 매크로 |isleaf|는 결합의 주소를 |topleaf|와 견준다. 이 판은 맨 왼쪽
자식이 없는 결합을 잎으로 본다. 잎은 |lchild|가 처음부터 끝까지 |nil|이고, 가지를
지을 때는 반드시 |lchild|를 채우기 때문이다. 다만 지움 기록도 |lchild|가 |nil|일
수 있으니, 지움 기록이 섞일 수 있는 곳에서는 |typ|부터 본다.

원본의 매크로 |easy|는 메모리 참조 하나를 함께 센다. 메서드는 |mems|를 볼 수
없으니 부르는 쪽이 센다.

@<함수들@>=
func (b *Bond) isLeaf() bool { return b.lchild == nil }
@#
func (b *Bond) easy() bool { return b.typ == b.val }

@ 결합을 더 담을 자리를 마련한다. 원본은 결합 $3m$개 자리를 잡는다. 결합을 짓거나
지울 때마다 변이 적어도 하나씩 줄고 허물 때는 거꾸로 되니, 한때에 쓰는 자리는
$2m+1$개를 넘지 않는다. 변이 없는 그래프에서는 원본이 크기가 $0$인 자리에 머리
노드를 적는데, \GO/에서는 그것이 바로 범위 밖 접근이 되므로 나는 자리 하나를
더 잡는다.

@<저장 공간을 더 마련한다@>=
m = int(g.M / 2)
bondbase = make([]Bond, 3*m+1)
for i := range bondbase {
	bondbase[i].num = i
}
action = &bondbase[0]
action.left, action.right, action.typ, action.focus = action, action, 2, action
	// 작용 리스트는 비어서 시작한다
tree.up, tree.down = tree, tree // 나무 리스트도 그렇다

@ 꼭짓점 사이의 결합은 거의 늘 하던 대로 호로 나타낸다. 곧 |u|와 |v| 사이의
결합은 |u.arcs| 리스트에서 |e.tip==v|인 호 |e|로, 그리고 |v.arcs| 리스트에서
|f.tip==u|인 호 |f|로 나타나며, |f==e.mate|이고 |e==f.mate|다. 다만 \.{grayspan}에서
처럼 호 리스트를 이중으로 잇는다. 그래서 |e.prev.next==e.next.prev==e|이고,
리스트는 머리 노드라는 가짜 원소로 시작한다. 머리 노드는 |tip==nil|인 것으로
알아본다.

호에는 새 필드 |bond|를 두어 더 많은 정보를 담은 |Bond| 구조체를 가리키게 한다.

원본은 \.{SGB}의 꼭짓점과 호 레코드를 그대로 쓰고, 필요한 필드는 다목적 필드에
얹는다. 나는 \.{grayspan}에서처럼 이 프로그램에 필요한 필드만 가진 작은 구조체를
따로 만들고 읽은 그래프를 거기로 옮겨 담는다. 필드 이름은 원본의 매크로 이름을
따랐다. 원본은 짝 호를 주소 계산 |mate(e)|로 얻는데, go-sgb의 호에는 짝을
가리키는 필드 |Partner|가 있으니 그것을 따라 필드 |mate|를 채운다. 짝을 찾는 것은
원본에서 주소 계산일 뿐이라, 이 판에서 |e.mate|를 읽는 것도 메모리 참조로 세지
않는다.

@<자료형@>=
type vertex struct {
	arcs *arc    // 호 리스트의 머리 노드
	deg  int     // 지금의 차수
	mark int     // 표시
	bfs  *vertex // 너비 우선 탐색의 고리. |nil|이 아니면 이미 보았다
	dup  *arc    // 앞서 이 꼭짓점을 가리킨 호
	name string  // 꼭짓점의 이름
}
@#
type arc struct {
	tip        *vertex // 호가 가리키는 꼭짓점. 머리 노드면 |nil|
	next, prev *arc    // 이중 연결 리스트의 고리
	mate       *arc    // 같은 변을 이루는 반대쪽 호
	bond       *Bond   // 이 호가 나타내는 결합
}

@ 원본에서 표시 |mark|와 탐색 고리 |bfs|는 같은 다목적 필드를 나눠 쓴다. 정수와
포인터가 한 자리에 겹쳐 있으니, |bfs|를 |nil|로 되돌리면 |mark|도 $0$이 되고,
|mark|가 $0$이 아니면 |bfs|도 |nil|이 아닌 것으로 읽힌다. 이 판은 둘을 따로
두었다. 너비 우선 탐색을 하는 동안 살아 있는 꼭짓점은 모두 |mark|가 $0$이고,
탐색이 끝나면 |bfs|를 모두 |nil|로 되돌리니 두 판이 똑같이 움직인다.

꼭짓점 배열은 하나를 여벌로 더 잡는다. \.{SGB}도 꼭짓점 배열을 넉넉히 잡는데,
꼭짓점이 하나도 없는 그래프에서 원본은 그 여벌 자리를 첫 꼭짓점인 양 훑고
지나간다. 그때도 원본과 같은 말을 찍으려는 것이다. 여벌은 이름이 없고 호도 없다.

옮겨 담기는 두 번에 걸쳐 한다. 먼저 \.{SGB}의 호마다 우리 호를 하나씩 만들어
대응표 |ours|에 적고, 그다음에 다음 호와 짝 호를 잇는다. 리스트는 원본과 같은
차례로 홑으로 이어 두고, 이중으로 잇는 것은 원본처럼 그래프를 살피며 한다.

@<그래프를 우리 구조체로 옮겨 담는다@>=
all := make([]vertex, g.N+1)
vert = all[:g.N]
ours := make(map[*gbgraph.Arc]*arc)
for i := range vert {
	vert[i].name = g.Vertices[i].Name
	for x := g.Vertices[i].Arcs; x != nil; x = x.Next {
		ours[x] = &arc{tip: &all[g.Index(x.Tip)]}
	}
}
for i := range vert {
	vert[i].arcs = ours[g.Vertices[i].Arcs]
	for x := g.Vertices[i].Arcs; x != nil; x = x.Next {
		ours[x].next, ours[x].mate = ours[x.Next], ours[x.Partner]
	}
}

@ 원본은 그래프를 전역 변수 |gg|에 베껴 두고 진단 루틴에서 쓴다. 이 판에서는
꼭짓점의 슬라이스 |vert|가 그 구실을 한다.

@<전역 변수@>=
var vert []vertex // 그래프의 꼭짓점들

@ 호를 리스트에서 떼어 내는 것은 이중 연결 리스트의 늘 하는 일이다. 원본에서는
매크로 |delete|인데, \GO/의 |delete|는 맵에서 키를 지우는 내장 함수이니
\.{grayspan}에서처럼 이름을 |unlink|로 바꾸었다. 그 짝인 |undelete|는 |relink|다.
원본의 매크로에는 메모리 참조 넷이 들어 있는데, 함수는 |mems|를 볼 수 없으니
부르는 쪽에서 센다.

@<함수들@>=
func unlink(e *arc) {
	e.prev.next = e.next
	e.next.prev = e.prev
}
@#
func relink(e *arc) {
	e.next.prev = e
	e.prev.next = e
}

@* 진단 루틴.
지금의 자료를 들여다보는 간편한 방법 몇 가지다. 커누스가 디버거에서 부르려고
남겨 둔 것이라 프로그램 안에서 부르는 곳은 없다. 디버거에서 부를 것이니 버퍼를
거치지 않고 바로 찍는다.

다만 \GO/의 링커는 아무도 부르지 않는 함수를 실행 파일에서 빼 버린다. 디버거
\.{dlv}에서 부르려면 어디선가 한 번은 불러 두어야 한다. 그래도 남겨 두는 것은,
특히 |sanityCheck|가 자료 구조에 대한 가정들을 낱낱이 적은 증언이기 때문이다.

@<함수들@>=
func printGraph() { // 지금의 그래프를 찍는다
	for i := range vert {
		v := &vert[i]
		if v.mark >= 0 {
			fmt.Printf("Bonds from %s:", v.name)
			for e := v.arcs.next; e.tip != nil; e = e.next {
				fmt.Printf(" %s(%d)", e.tip.name, e.bond.num)
			}
			fmt.Printf("\n")
		}
	}
}

@ 결합 하나를 찍는다. 종류는 잎이면 \.l, 지움 기록이면 \.r, 직렬이면 \.s,
병렬이면 \.p로 나타낸다. 원본은 지움 기록의 |rhist|를 찍는다면서 |lhist|를 한 번
더 찍는다. 이 판은 |rhist|를 찍는다.

@<함수들@>=
func printBond(b *Bond) {
	var c byte
	switch {
	case b.typ == 2:
		c = 'r'
	case b.isLeaf():
		c = 'l'
	case b.typ == 1:
		c = 's'
	default:
		c = 'p'
	}
	fmt.Printf("%d:%c", b.num, c)
	if b.typ == 2 {
		fmt.Printf(" lhist=%d", b.lhist.bond.num)
		if b.rhist != nil {
			fmt.Printf(" rhist=%d", b.rhist.bond.num)
		}
	} else {
		fmt.Printf("%d", b.val)
		if b.lsib != nil {
			fmt.Printf(" lsib=%d, rsib=%d", b.lsib.num, b.rsib.num)
		}
		if !b.isLeaf() {
			if b.focus != b {
				fmt.Printf(" focus=%d", b.focus.num)
			}
			fmt.Printf(" lchild=%d, scope=%d, des=%d, done=%d",
				b.lchild.num, b.scope.num, b.des.num, b.done.num)
		}
	}
	fmt.Printf("\n")
}

@ 작용 리스트, 나무 리스트, 잎 전부를 찍는 함수들이다.

@<함수들@>=
func printAction() { // 지금의 작용 리스트를 찍는다
	for b := action.right; b != action; b = b.right {
		printBond(b)
	}
}
@#
func printTree() { // 지금의 나무 리스트를 찍는다
	for b := tree.down; b != tree; b = b.down {
		printBond(b)
	}
}
@#
func printLeaves() { // 잎을 모두 찍는다
	for i := 1; i <= topleaf; i++ {
		printBond(&bondbase[i])
	}
}

@ 자료 구조에 겹치는 것이 이렇게 많으니, 커누스는 실수로 무언가를 제자리에 두는
것을 잊지 않았다는 안심이 필요했다. ``자료 구조는 가장 약한 고리만큼만
튼튼하다.''

함수 |sanityCheck|는 커누스의 가정과 실제 상태가 어긋나는 것을 거의 다 찍어 내도록
지었다. 커누스는 이 프로그램을 디버깅할 때 이것으로 빈틈을 찾았고, 이것은 프로그램이
기대는 가장 중요한 구조적 가정들의 증언으로 남아 있다. 인자 |flags|의 비트로 무엇을
살필지 고른다. 1이면 그래프, 2면 작용 리스트, 4면 나무 리스트다.

@<함수들@>=
func sanityCheck(flags int) (bugs int) {
	var (
		u, v *vertex
		e    *arc
		b    *Bond
		k, n int
	)
	if flags&1 != 0 {
		@<그래프가 멀쩡한지 살핀다@>@;
	}
	if flags&2 != 0 {
		@<작용 리스트가 멀쩡한지 살핀다@>@;
	}
	if flags&4 != 0 {
		@<나무 리스트가 멀쩡한지 살핀다@>@;
	}
	return
}

@ @<그래프가 멀쩡한지 살핀다@>=
for i := range vert {
	v = &vert[i]
	if v.mark >= 0 {
		@<꼭짓점 |v|의 결합 리스트가 멀쩡한지 살핀다@>@;
	}
}

@ 여기서 찾아내는 ``버그'' 가운데 몇몇은 물론 어떤 맥락에서는 해가 없다. 커누스의
목표는 뜻밖일지 모르는 것에 눈길을 끌되, 어쨌든 계속 나아가는 것이다.

원본은 결합이 |bondbase|의 범위 안에 있는지를 주소로 견준다. 이 판은 번호로
견주고, |nil|이면 범위 밖으로 친다.

@<꼭짓점 |v|의 결합 리스트가 멀쩡한지 살핀다@>=
n++
if v.mark != 0 {
	bugs++
	fmt.Printf("Vertex %s is marked\n", v.name)
}
if (v.deg < 3 && v.deg != 0) || v.deg >= len(vert) {
	bugs++
	fmt.Printf("Vertex %s has degree %d\n", v.name, v.deg)
}
for k, e = 0, v.arcs; k <= v.deg; k, e = k+1, e.next {
	if e.prev.next != e || e.next.prev != e {
		bugs++
		fmt.Printf("Link failure at vertex %s, bond %d\n", v.name, k)
	}
	if k > 0 {
		@<호 |e|의 결합이 멀쩡한지 살핀다@>@;
	}
}
if e != v.arcs {
	bugs++
	fmt.Printf("Vertex %s has more than %d bonds\n", v.name, v.deg)
}

@ @<호 |e|의 결합이 멀쩡한지 살핀다@>=
b = e.bond
if b == nil || b.num <= 0 || b.num > bondcount {
	bugs++
	fmt.Printf("Vertex %s has bad bond %d\n", v.name, k)
} else if b.lhist != e && b.lhist != e.mate {
	bugs++
	fmt.Printf("Bond %d has bad lhist pointer\n", b.num)
}
if e.mate.bond != e.bond {
	bugs++
	fmt.Printf("Vertex %s has unmated bond %d\n", v.name, k)
}
if e.mate.tip != v {
	bugs++
	fmt.Printf("Vertex %s's bond %d has wrong mate tip\n", v.name, k)
}
if u = e.tip; u == nil {
	bugs++
	fmt.Printf("Vertex %s has bad tip %d\n", v.name, k)
} else if u.mark < 0 {
	bugs++
	fmt.Printf("Vertex %s points to deleted vertex %s\n", v.name, u.name)
}

@ 작용 리스트는 요컨대 결합들의 숲을 전위 순서로 늘어놓은 것이다.

@<작용 리스트가 멀쩡한지 살핀다@>=
if action.left.right != action || action.right.left != action {
	bugs++
	fmt.Printf("Link failure at head of action list\n")
}
for b = action.right; b != action; b = b.right {
	if b.val == 1 && (b.up == nil || b.up.down != b) {
		bugs++
		fmt.Printf("Bond %d isn't properly in the tree list\n", b.num)
	}
	if b.lsib != nil || b.rsib != nil {
		bugs++
		fmt.Printf("Top level bond %d has siblings\n", b.num)
	}
	if b.isLeaf() {
		bugs++
		fmt.Printf("Leaf %d is in the action list\n", b.num)
	} else {
		bugs += bondSanity(b)
		b = b.scope
	}
}

@ 결합 하나와 그 자손을 살피는 함수는 되부른다.

@<함수들@>=
func bondSanity(b *Bond) (bugs int) {
	var a, extent *Bond
	var j, k int
	extent = b
	if b.left.right != b || b.right.left != b {
		bugs++
		fmt.Printf("Link failure at bond %d\n", b.num)
	}
	for a, j, k = b.lchild, 0, 0; a != b.lchild || k == 0; a, k = a.rsib, k+1 {
		@<결합 |b|의 자식 |a|가 멀쩡한지 살핀다@>@;
	}
	if j == 0 {
		bugs++
		fmt.Printf("Bond %d doesn't designate any of its children\n", b.num)
	} else if b.done != b.des.lsib {
		bugs++
		fmt.Printf("Bond %d should be done at %d\n", b.num, b.des.lsib.num)
	}
	if b.scope != extent {
		bugs++
		fmt.Printf("Bond %d should have scope %d\n", b.num, extent.num)
	}
	return
}

@ @<결합 |b|의 자식 |a|가 멀쩡한지 살핀다@>=
if a == nil || a.num <= 0 || a.num > bondcount {
	bugs++
	fmt.Printf("Bond %d has a child out of range\n", b.num)
	break
}
if a.lsib.rsib != a || a.rsib.lsib != a {
	bugs++
	fmt.Printf("Sibling link failure at bond %d\n", a.num)
}
if a == b.des {
	j = 1
} else if a.val != b.typ {
	bugs++
	fmt.Printf("Bond %d should have value %d\n", a.num, b.typ)
}
if !a.isLeaf() {
	if a.left != extent {
		bugs++
		fmt.Printf("Preorder failure: bond %d doesn't follow %d\n",
			a.num, extent.num)
	}
	bugs += bondSanity(a)
	extent = a.scope
}

@ 그래프도 살폈다면(|flags&1|) 지금 꼭짓점의 수 |n|을 셈해 두었다.

@<나무 리스트가 멀쩡한지 살핀다@>=
if tree.up.down != tree || tree.down.up != tree {
	bugs++
	fmt.Printf("Link failure at head of tree list\n")
}
for b, k = tree.down, 0; b != tree; b, k = b.down, k+1 {
	if b.up.down != b || b.down.up != b {
		bugs++
		fmt.Printf("Link failure in tree list at bond %d\n", b.num)
	}
	if b.val != 1 {
		bugs++
		fmt.Printf("Bond %d in the tree list has value 0\n", b.num)
	}
}
if want := n - 1; flags&1 != 0 {
	if inbond == nil {
		want--
	}
	if k != want {
		bugs++
		fmt.Printf("The tree list holds %d bonds, not %d\n", k, want)
	}
}

@* 그래프 준비.
처음에는 주어진 그래프가 정말 무향인지, 그리고 변 요령으로 변의 짝을 찾을 수
있는지 확인하고 싶다. 또 그래프의 표현을 홑으로 이은 변에서 이중으로 이은
결합으로 바꾸고, 꼭짓점의 차수를 셈하고, 첫 신장 나무도 찾아야 한다.

이 모든 일은 그래프를 한 번 훑으며 쉽게 할 수 있다. 다음 코드는 본 꼭짓점마다
|v.mark=2|로 두고, 보았지만 아직 탐사하지 않은 꼭짓점을 스택에 쌓는다. (이
탐색은 너비 우선과 깊이 우선의 성격을 다 가졌다. 꼭짓점 하나를 탐사할 때는 그
이웃을 모두 본 다음에 다른 꼭짓점을 탐사하지만, 탐사할 새 꼭짓점은 마지막에 본
것부터 고른다.)

왜 |mark|를 2로 두는가? 0만 아니면 무엇이든 되는데, 이 부분이 끝나고 얼마 안 가
2로 두고 싶어지기 때문이다.

원본은 이 일에 앞서 꼭짓점의 |mark|를 모두 0으로 지운다. 이 판의 꼭짓점은 처음부터
모든 필드가 0이니 그럴 필요가 없다.

원본은 스택을 꼭짓점 배열의 다목적 필드에 얹어 |stack(k)|로 부른다. 이 판에서는
꼭짓점을 가리키는 포인터의 슬라이스 |stack|이다.

@<지역 변수@>=
var stack []*vertex // 스택

@ @<그래프가 올바른지 살피고 일할 채비를 한다@>=
stack = make([]*vertex, len(all))
if verbose {
	fmt.Fprintf(out, "Graph %s has the following edges:\n", g.ID)
}
v = &all[0]
stack[0], k, v.mark, n, m = v, 1, 2, 1, 0
for k > 0 { // $k$는 스택에 든 항목의 수다
	mems++
	k--
	v = stack[k]
	@<꼭짓점 |v|를 탐사한다@>@;
}
if int64(n) < g.N {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Oops, the graph isn't connected!\n")
	os.Exit(-4)
}
mems++
topleaf, bondcount = m, m

@ 꼭짓점 |v|마다 새 머리 노드 |f|를 만들고, 홑으로 이어진 리스트를 따라가며 호를
차례로 이중으로 잇고 차수를 센다. 원본은 고리를 만나면 이름표 |looky|로 뛰어 다음
호를 보는데, 이 판은 리스트에서 고리를 떼어 낸 뒤 |continue|로 넘어간다. 차수를
세고 |f|를 옮기는 일은 몸통 끝에서 하니 고리를 건너뛸 때는 하지 않는다.

@<꼭짓점 |v|를 탐사한다@>=
f = new(arc) // 새 머리 노드
f.next = v.arcs
e, v.arcs, v.deg = v.arcs, f, 0
for e != nil {
	u = e.tip
	if u == v { // 고리는 말없이 무시한다
		e = e.next
		f.next = e
		continue
	}
	e.prev = f
	@<호 |e|의 짝이 맞지 않으면 멈춘다@>@;
	@<변 |e|에 결합이 없으면 새로 매긴다@>@;
	@<꼭짓점 |u|를 처음 보았으면 쌓고 변 |e|를 나무 리스트에 넣는다@>@;
	v.deg++
	f, e = e, e.next
}
v.arcs.prev, f.next = f, v.arcs // 이중 연결을 마무리한다

@ 짝이 없거나 짝이 |v|를 가리키지 않으면 그래프가 무향이 아니다. 원본의 말은
``변 요령이 반대쪽 호를 찾지 못한다''인데, 이 판에서는 변 요령 대신 |Partner|를
따랐지만 같은 말을 찍는다.

@<호 |e|의 짝이 맞지 않으면 멈춘다@>=
if e.mate == nil || e.mate.tip != v {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Graph %s has an arc from %s to %s,\n",
		g.ID, u.name, v.name)
	fmt.Fprintf(os.Stderr, " but the edge trick doesn't find the opposite arc!\n")
	os.Exit(-3)
}

@ 결합의 번호는 변을 처음 만난 차례로 매긴다.

@<변 |e|에 결합이 없으면 새로 매긴다@>=
mems++
if e.bond == nil {
	mems += 3
	m++
	b = &bondbase[m]
	e.bond, e.mate.bond = b, b
	b.lhist = e
	if verbose {
		fmt.Fprintf(out, " %d: %s -- %s\n", m, v.name, u.name)
	}
}

@ 처음 보는 꼭짓점에 이르는 변들은 첫 신장 나무를 이룬다. 그 결합을 나무 리스트의
맨 아래에 넣는다.

@<꼭짓점 |u|를 처음 보았으면 쌓고 변 |e|를 나무 리스트에 넣는다@>=
mems++
if u.mark == 0 {
	mems += 3
	u.mark = 2
	stack[k] = u
	k++
	b = e.bond
	b.val = 1
	mems += 3
	n++
	b.up = tree.up
	tree.up.down = b
	tree.up = b
	b.down = tree
}

@* 줄이기.
이제 진짜 코드를 쓰기 시작하자. 이 프로그램은 이름표 |reduce|에 이를 때 결정적인
단계에 닿는다. 대략 \.{grayspan}이 이름표 |enter|에 이르는 자리에 해당한다.

이름표 |reduce|에 이르면 상태는 다음과 같다.

\smallskip\item{1)} 지금 그래프의 결합 $a_1\ldots a_l$이 줄여져 있고, 배열
|shrunk[1]|부터 |shrunk[l]|까지로 나타난다. 줄인 그래프의 신장 나무를 다 찾은
뒤에는 그것들을 도로 펴야 한다.

\smallskip\item{2)} 리스트 |tree|는 결합의 집합을 하나 정한다. 그 결합들은
|inbond!=nil|이면 지금 그래프의 신장 나무를, |inbond==nil|이면 거의 신장 나무를
이룬다. 다음에 만들 신장 나무는 그 결합을 모두 품어야 한다.

\smallskip\item{3)} 지금 그래프에 나란한 변이 있으면, 그 변은 |v.mark==2|인
꼭짓점 |v|에 닿아 있다.

\smallskip\item{4)} 지금 그래프에 차수가 3보다 작은 꼭짓점 |v|가 있으면
|v.mark>0|이다.

\smallskip\item{5)} 표시된 꼭짓점은 모두 스택에 있고, 스택에는 지금 항목이 |k|개
있다.

\smallskip\item{6)} 지금의 결합과 그 부분 결합은 모두 |bondbase[1]|부터
|bondbase[bondcount]|까지에 있다. 수준~|l|에 들어서기 전에 지은 것은
|bondbase[bonds[l]]|과 같거나 그 앞에 있다.

\smallskip\noindent
우리가 할 일은 표시를 모두 지우며, 그래프가 마침내 자명해질 때까지 더 복잡한
결합을 짓거나 나무 리스트의 결합을 줄여 그래프를 계속 줄이는 것이다.

원본은 |bonds(l)|과 $a_l$을 담은 |aa(l)|을 꼭짓점 배열의 다목적 필드에 얹는다. 이
판에서는 둘 다 수준으로 찾는 슬라이스다. 이름 |aa|는 결합을 허무는 코드가 호의
이름으로 쓰므로, $a_l$의 배열은 |shrunk|라 부른다.

@<지역 변수@>=
var (
	bonds  []int  // 수준 |l|에 들어설 때의 |bondcount|
	shrunk []*arc // 수준 |l|에서 줄인 결합 $a_l$의 변
)

@ 맨 아래에서 |goto reduce|로 돌아온다. 이름표가 |for| 문에 붙어 있으니 반복문을
처음부터 다시 도는 셈이다.

@<그래프가 자명해질 때까지 줄인다@>=
reduce:
for k > 0 {
	mems++
	k--
	v = stack[k]
	mems++
	if v.mark > 1 {
		@<꼭짓점 |v|에서 나가는 겹친 결합을 병렬로 묶는다@>@;
	}
	mems++
	if v.deg < 3 {
		@<꼭짓점 |v|를 없애고, 꼭짓점이 하나만 남으면 |goto trivialgraph|@>@;
	} else {
		mems++
		v.mark = 0
	}
}
// 이제 관련된 표시는 모두 0이고 그래프는 아직 자명하지 않다
mems++
l++
bonds[l] = bondcount
if extraverbose {
	fmt.Fprintf(out, "Entering level %d\n", l)
}
mems += 4
b = tree.down
tree.down = b.down
tree.down.up = tree
mems += 2
e = b.lhist // |b.lhist.bond==b|다
shrunk[l] = e
@<결합 |e|를 줄인다@>@;
goto reduce

@ 같은 꼭짓점 |u|를 가리키는 호를 두 번째로 만나면 앞서 만난 호 |u.dup|와 병렬로
묶는다.

@<꼭짓점 |v|에서 나가는 겹친 결합을 병렬로 묶는다@>=
mems += 2
for e = v.arcs.next; ; e = e.next {
	mems++
	if e.tip == nil {
		break
	}
	mems++
	e.tip.dup = nil
	mems++
}
for e = v.arcs.next; ; e = e.next {
	mems++
	if e.tip == nil {
		break
	}
	u = e.tip
	mems++
	if u.dup != nil {
		mems += buildBond(0, u.dup, e) // 새 병렬 결합을 짓는다
		mems++
		if u.mark == 0 {
			mems += 2
			u.mark = 1
			stack[k] = u
			k++
		}
	} else {
		mems++
		u.dup = e
	}
	mems++
}

@ 지운 꼭짓점은 $-1$로 표시한다. 디버깅을 위해서일 뿐이다.

@<꼭짓점 |v|를 없애고, 꼭짓점이 하나만 남으면 |goto trivialgraph|@>=
v.mark = -1
if v.deg == 2 {
	@<꼭짓점 |v|에서 나가는 결합 둘을 직렬로 묶는다@>@;
} else if v.deg == 1 {
	@<꼭짓점 |v|에서 나가는 결합을 꼭 넣기로 한다@>@;
} else {
	v.mark = 0      // 마지막 꼭짓점은 없어지지 않는다
	goto trivialgraph // |v.deg==0|이니 다른 꼭짓점은 남지 않았다
}

@ 꼭짓점 |v|에 닿은 결합 하나가 나무 리스트에 없다면, 나무 리스트는 거의 신장
나무만 정하고 있는 것이다. 그래서 |inbond|를 두어 나중에 신장 나무를 마저 채우게
한다. 그리고 |v|를 없앤다. 그러면 그 뒤로 나무 리스트는 남은 꼭짓점들의 신장
나무가 된다.

@<꼭짓점 |v|에서 나가는 결합을 꼭 넣기로 한다@>=
mems += 3
e = v.arcs.next
b = e.bond
mems++
u = e.tip
mems += deleteBonds(e.mate, nil) // |e.mate|를 떼고 |u.deg|를 줄인다
mems++
if b.val != 0 {
	mems += 4
	b.up.down = b.down
	b.down.up = b.up
} else {
	if inbond != nil {
		out.Flush()
		fmt.Fprintf(os.Stderr, "I've goofed (inbond doubly set)!\n")
		os.Exit(-5)
	}
	inbond = b
}
mems++
if u.mark == 0 {
	mems += 2
	u.mark = 1
	stack[k] = u
	k++
}

@ 여기에 미묘한 점이 하나 있다. 나무에 들지 않은 결합 둘을 직렬로 묶게 될 수도
있다. 꼭짓점 |v|가 지금의 거의 신장 나무로 닿을 수 없는 유일한 꼭짓점이면 그렇다.
그때는 |inbond|를 새 직렬 결합의 부분 결합 가운데 |buildBond|가 지정하지 {\it
않을\/} 것으로 두어야 한다.

@<꼭짓점 |v|에서 나가는 결합 둘을 직렬로 묶는다@>=
mems += 6
e = v.arcs.next
f = e.next
u, w = e.tip, f.tip
b = e.bond
mems++
if b.val == 0 {
	mems++
	b = f.bond
	mems++
	if b.val == 0 {
		if inbond != nil {
			out.Flush()
			fmt.Fprintf(os.Stderr, "I've doubly goofed (inbond set)!\n")
			os.Exit(-6)
		}
		inbond = b
	}
}
mems += buildBond(1, e, f) // 새 직렬 결합을 짓는다
@<꼭짓점 |u|와 |w|에 2로 표시한다@>@;

@ 직렬로 묶으면 양 끝 꼭짓점에 나란한 변이 생길 수 있으니 2로 표시한다.

@<꼭짓점 |u|와 |w|에 2로 표시한다@>=
mems++
if u.mark != 0 {
	mems++
	u.mark = 2
} else {
	mems += 2
	u.mark = 2
	stack[k] = u
	k++
}
mems++
if w.mark != 0 {
	mems++
	w.mark = 2
} else {
	mems += 2
	w.mark = 2
	stack[k] = w
	k++
}

@ 이 자리에서 그래프는 더 줄일 수 없으니 |v|는 |u|의 리스트에 한 번만 나온다.
변 |e|를 줄여 |u|를 |v|에 붙이려면, |u|의 리스트에 있는 호들의 짝이 |v|를
가리키게 고치고 |u|의 리스트를 통째로 |v|의 리스트에 끼워 넣는다. 머리 노드 |f|의
두 고리는 그대로 남겨 두었다가 펼 때 쓴다.

@<결합 |e|를 줄인다@>=
mems += 2
u, v = e.tip, e.mate.tip
mems += 2
for f = u.arcs.next; ; f = f.next {
	mems++
	if f.tip == nil {
		break
	}
	if f == e.mate {
		mems += 4
		unlink(f)
	} else {
		mems++
		f.mate.tip = v
	}
	mems++
}
mems += 4
unlink(e)
mems += 3
v.deg += u.deg - 2
mems++
ee = v.arcs // 이제 |f==u.arcs|다
@<꼭짓점 |u|의 리스트를 |v|의 리스트에 끼워 넣는다@>@;

@ @<꼭짓점 |u|의 리스트를 |v|의 리스트에 끼워 넣는다@>=
mems += 4
f.prev.next = ee.next
ee.next.prev = f.prev
mems += 3
f.next.prev = ee
ee.next = f.next
if extraverbose {
	fmt.Fprintf(out, " shrinking %d; now %s has degree %d\n",
		e.bond.num, v.name, v.deg)
}
mems += 2
u.mark, v.mark = -1, 2
k, stack[0] = 1, v

@* 주 알고리즘.
줄이기를 이해했으니 이 프로그램의 \.{grayspan} 쪽을 마무리할 수 있다. 낮은
수준의 세부만 빼고.

처음에는 꼭짓점을 모두 의심한다. 첫 신장 나무에서 마지막 변을 빼어 거의 신장
나무로 시작한다.

@<신장 나무를 모두 만든다@>=
bonds = make([]int, n+1)
shrunk = make([]*arc, n+1)
for k = 0; k < n; k++ {
	mems++
	stack[k] = &vert[k] // 처음에는 모든 꼭짓점이 의심스럽다
}
mems++
b = tree.up
b.val = 0 // 첫 나무의 마지막 변을 지운다
mems += 2
tree.up = b.up
tree.up.down = tree
if verbose {
	fmt.Fprint(out, "Start with the near-spanning edges")
	for b = tree.down; b != tree; b = b.down {
		fmt.Fprintf(out, " %d", b.num)
	}
	fmt.Fprint(out, "\n")
}
l = 0
@<그래프가 자명해질 때까지 줄인다@>@;
trivialgraph:
@<결합 |outbond|와 |inbond|를 바꾸어 새 신장 나무를 얻는다@>@;
@<작용 리스트에서 \.{spspan}의 알고리즘을 돌린다@>@;
for l > 0 {
	@<수준 |l|에 들어선 뒤로 그래프에 한 일을 모두 되돌린다@>@;
	mems++
	e = shrunk[l]
	@<결합 |e|를 편다@>@;
	l--
	@<결합 |e|가 다리가 아니면 지우고, |outbond=e.bond|로 두고,
		|goto reduce|@>@;
	mems += 6
	b = e.bond
	b.up = tree.up
	b.up.down = b
	tree.up = b
	b.down = tree
}

@ 펴고 나도 그래프는 여전히 더 줄일 수 없다.

@<결합 |e|를 편다@>=
mems += 5
u, v = e.tip, e.mate.tip
v.deg -= u.deg - 2
mems += 2
ee, f = v.arcs, u.arcs
mems += 4
ee.next = f.prev.next
ee.next.prev = ee
mems += 3
f.prev.next = f
f.next.prev = f
mems++
for f = f.next; ; f = f.next {
	mems++
	if f.tip == nil {
		break
	}
	mems++
	f.mate.tip = u
	mems++
}
mems += 8
relink(e)
relink(e.mate)
if extraverbose {
	fmt.Fprintf(out, " unshrinking %d; now %s has degree %d\n",
		e.bond.num, v.name, v.deg)
}
u.mark = 0 // $-1$이었다

@ 변 |e|가 다리인지는 \.{grayspan}에서처럼 |u|에서 |v|로 너비 우선 탐색을 해서
가린다. 필드 |bfs|가 큐를 잇고, 큐의 꼬리는 늘 |v|를 가리킨다. 그래서 |u=u.bfs|로
큐를 따라가다 |v|에 닿으면 큐가 빈 것이다.

@<결합 |e|가 다리가 아니면 지우고...@>=
mems += 2
u, v = e.tip, e.mate.tip
mems++
u.bfs = v
for w = u; u != v; u = u.bfs {
	mems += 2
	for f = u.arcs.next; ; f = f.next {
		mems++
		if f.tip == nil {
			break
		}
		@<호 |f|의 끝을 탐색에 넣는다@>@;
		mems++
	}
	mems++
}
if extraverbose {
	fmt.Fprintf(out, "Leaving level %d: %d is a bridge\n", l+1, e.bond.num)
}
@<|bfs| 고리를 모두 지운다@>@;

@ 탐색이 |e| 말고 다른 길로 |v|에 닿으면 |e|는 다리가 아니다.

@<호 |f|의 끝을 탐색에 넣는다@>=
mems++
if f.tip.bfs == nil {
	if f.tip == v {
		if f != e.mate {
			@<|bfs| 고리를 모두 지우고, |e|를 지우고, |goto reduce|@>@;
		}
	} else {
		mems += 2
		f.tip.bfs = v
		w.bfs = f.tip
		w = f.tip
	}
}

@ @<|bfs| 고리를 모두 지운다@>=
mems++
for u = e.tip; u != v; u = w {
	mems++
	w = u.bfs
	mems++
	u.bfs = nil
}

@ 변 |e|가 다리가 아니라는 것을 알아냈다.

@<|bfs| 고리를 모두 지우고, |e|를 지우고, |goto reduce|@>=
@<|bfs| 고리를 모두 지운다@>@;
outbond = e.bond
mems += deleteBonds(e, e.mate)
mems += 4
k = 2
stack[0], stack[1] = e.tip, e.mate.tip
mems += 2
e.tip.mark, e.mate.tip.mark = 1, 1
goto reduce

@ @<수준 |l|에 들어선 뒤로 그래프에 한 일을 모두 되돌린다@>=
mems++
for bondcount > bonds[l] {
	@<맨 나중에 지은 결합을 허문다@>@;
}

@ 프로그램이 |trivialgraph|에 이르면 |outbond|와 |inbond|는 다음 신장 나무에서
값이 저마다 0과~1이 될 결합을 가리킨다.

(예외: 처음 이르렀을 때는 |outbond|가 |nil|이고, 첫 신장 나무의 변 $n-2$개를 이미
찍었다. 마중물을 붓는 셈이다.)

결합 |inbond|는 맨 윗 수준의 결합이 아닐 수도 있다. 앞에서 말한 미묘한 점
때문이다. 그러나 |outbond|는 언제나 맨 윗 수준에 있다. 결합 |outbond|를 정할 때
그래프에서 떼어 냈기 때문이다.

@<결합 |outbond|와 |inbond|를 바꾸어 새 신장 나무를 얻는다@>=
count++
if verbose {
	fmt.Fprintf(out, "%.15g:", count)
}
if outbond != nil {
	for b = outbond; ; b = b.des {
		mems++
		b.val = 0
		if b.isLeaf() {
			break
		}
		mems++
	}
	if verbose {
		fmt.Fprintf(out, "-%d", b.num)
	}
}
if inbond == nil {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Internal error (no inbond)!\n")
	os.Exit(-7)
}
for b = inbond; ; b = b.des {
	mems++
	b.val = 1
	if b.isLeaf() {
		break
	}
	mems++
}
if verbose {
	fmt.Fprintf(out, "+%d", b.num)
	@<아주 자세히 찍으라면 나무의 변을 모두 찍는다@>@;
}
inbond, outbond = nil, nil

@ 아주 자세히 찍을 때는 지금 신장 나무에 든 잎, 곧 변을 모두 괄호 안에 찍는다.

@<아주 자세히 찍으라면 나무의 변을 모두 찍는다@>=
if extraverbose {
	fmt.Fprint(out, " (")
	for i := 1; i <= topleaf; i++ {
		if bondbase[i].val != 0 {
			fmt.Fprintf(out, " %d", i)
		}
	}
	fmt.Fprint(out, " )\n")
} else {
	fmt.Fprint(out, "\n")
}

@* 짓기.
주 그래프를 줄인다는 것은 결합을 더 짓는다는 말이다.

자료 구조가 복잡하면 사정이 바뀔 때마다 지루한 손질을 해야 한다는 나쁜 점이
있다. 프로그램의 이 부분은 커누스가 쓰기에 가장 재미없었던 곳이고, 엉뚱한 실수가
숨어들었을 가능성이 가장 큰 곳이다. 그래도 커누스는 이를 악물고 해냈다고 생각한다고
했다. (앤 라모트(Anne Lamott)라면 이 부분을 ``새 한 마리 한 마리씩'' 썼다고
했을 것이다.)

원본의 두 서브루틴 |makeseries|와 |makeparallel|은 저마다 한 곳에서만 불리니
서브루틴으로 만들 까닭은 없었다. 그러나 공통된 코드가 많아서, 커누스는 두 경우를
함께 다루는 루틴 하나를 써서 일을 간단히 했다. 그러면 실수할 가능성도 줄 것이다.
다만 메모리 참조는 그 서브루틴을 그 자리에 펼쳐 넣고 |t=0|과 |t=1|인 경우에 맞게
다듬은 것처럼 센다. 원본의 두 이름은 그 루틴을 부르는 매크로일 뿐이니, 이 판은
|buildBond(1, e, f)|와 |buildBond(0, e, f)|를 바로 쓴다.

@<함수들@>=
func buildBond(t int, aa, bb *arc) (mems float64) {
	var a, b, c, d *Bond
	var at, av, bt, bv int
	var u, v *vertex
	var ee *arc
	bondcount++
	c = &bondbase[bondcount]
	mems += 4
	c.typ, c.lhist, c.rhist, c.focus = t, aa, bb, c
	mems += 2
	a, b = aa.bond, bb.bond
	mems += 2
	av, at, bv, bt = a.val, a.typ, b.val, b.typ
	if t != 0 {
		@<새 직렬 결합을 위해 |aa|와 |bb|를 고친다@>@;
	} else {
		@<새 병렬 결합을 위해 |aa|와 |bb|를 고친다@>@;
	}
	mems += 2
	bb.mate.bond = aa.bond // 없어질 결합을 기억해 둔다
	mems += 2
	aa.bond, aa.mate.bond = c, c // |c.lhist.bond|가 |c|를 가리킨다
	@<결합 |a|와 |b|로 결합 |c|를 짓는다@>@;
	@<결합 |a|와 |b|를 나무 리스트에서 빼고 |c|의 지정 자식을 정한다@>@;
	return
}

@ 자식이 잎이냐 가지냐에 따라 네 경우로 나뉜다.

@<결합 |a|와 |b|로 결합 |c|를 짓는다@>=
if a.isLeaf() {
	if b.isLeaf() {
		@<잎과 잎으로 짓는다@>@;
	} else {
		@<잎과 가지로 짓는다@>@;
	}
} else if b.isLeaf() {
	@<가지와 잎으로 짓는다@>@;
} else {
	@<가지와 가지로 짓는다@>@;
}

@ 새 결합 |c|의 지정 자식은 이렇게 정한다. 두 결합의 값이 같거나 |b|의 값이 |t|와
같으면 |a| 쪽을 지정한다. 다만 |a|가 |c|와 같은 종류의 가지라서 |c|에 녹아들었으면
|a|의 지정 자식을 넘겨받는다. 그렇지 않으면 |b| 쪽을 마찬가지로 지정한다.

@<결합 |a|와 |b|를 나무 리스트에서 빼고 |c|의 지정 자식을 정한다@>=
if av != 0 {
	mems += 4
	a.up.down = a.down
	a.down.up = a.up
}
if bv != 0 {
	mems += 4
	b.up.down = b.down
	b.down.up = b.up
}
if av == bv || bv == t {
	if a.isLeaf() || at != t {
		mems++
		c.des = a
	} else {
		mems += 2
		c.des = a.des
	}
} else if b.isLeaf() || bt != t {
	mems++
	c.des = b
} else {
	mems += 2
	c.des = b.des
}
mems += 4
c.val, c.done = c.des.val, c.des.lsib
if c.val != 0 {
	mems += 5
	c.up = tree.up
	c.up.down = c
	tree.up = c
	c.down = tree
}

@ 새 직렬 결합은 그 짝과 맞아야 한다. 그래서 호 노드 |aa|를 한 리스트에서 다른
리스트로 옮긴다. 곧 |bb.mate|가 있던 자리에 |aa|를 앉힌다.

@<새 직렬 결합을 위해 |aa|와 |bb|를 고친다@>=
if extraverbose {
	fmt.Fprintf(out, " %d=series(%d,%d) between %s and %s\n",
		c.num, a.num, b.num, aa.tip.name, bb.tip.name)
}
mems += 4
ee = bb.mate
aa.prev, aa.next = ee.prev, ee.next
mems += 2
aa.next.prev = aa
aa.prev.next = aa
mems += 2
aa.mate.tip = bb.tip

@ 원본의 이 줄은 |oooo,delete(bb), delete(mate(bb)), u->deg--, v->deg--|다. 매크로
|delete|가 저마다 메모리 참조 넷을 더 세니 모두 열둘이다.

@<새 병렬 결합을 위해 |aa|와 |bb|를 고친다@>=
mems += 2
u, v = aa.tip, aa.mate.tip
if extraverbose {
	fmt.Fprintf(out, " %d=parallel(%d,%d) between %s and %s\n",
		c.num, a.num, b.num, u.name, v.name)
}
mems += 12
unlink(bb)
unlink(bb.mate)
u.deg--
v.deg--

@ @<잎과 잎으로 짓는다@>=
mems += 4
a.lsib, a.rsib, b.lsib, b.rsib = b, b, a, a
mems++
c.lchild = a
mems += 3
c.right = action.right
c.right.left = c
mems += 2
c.left = action
action.right = c
mems++
c.scope = c

@ 가지 |b|가 |c|와 같은 종류면 |b|는 |c|에 녹아들고, |b|의 자식들이 |a|와 함께
|c|의 자식이 된다. 다른 종류면 |b|는 그대로 |c|의 자식이 된다. 원본은 |scope|를
조건 연산자로 고르는데, \GO/에는 그것이 없으니 |if| 문으로 쓴다. 아래의 다른
경우들도 마찬가지다.

@<잎과 가지로 짓는다@>=
if bt != t {
	mems += 4
	a.lsib, a.rsib, b.lsib, b.rsib = b, b, a, a
	mems += 3
	c.right, c.scope = b, b.scope
} else {
	mems += 4
	a.rsib = b.lchild
	a.lsib = b.lchild.lsib
	mems += 2
	a.lsib.rsib = a
	a.rsib.lsib = a
	mems += 4
	c.right = b.right
	c.scope = b.scope
	if b.scope == b {
		c.scope = c
	}
}
mems++
c.lchild = a
mems += 2
c.left = b.left
mems += 2
c.right.left = c
c.left.right = c

@ @<가지와 잎으로 짓는다@>=
if at != t {
	mems += 4
	a.lsib, a.rsib, b.lsib, b.rsib = b, b, a, a
	mems += 4
	c.lchild = a
	c.right = a
	c.scope = a.scope
} else {
	mems += 4
	b.rsib = a.lchild
	b.lsib = a.lchild.lsib
	mems += 2
	b.lsib.rsib = b
	b.rsib.lsib = b
	mems += 4
	c.right, c.lchild = a.right, a.lchild
	mems += 2
	c.scope = a.scope
	if a.scope == a {
		c.scope = c
	}
}
mems += 2
c.left = a.left
mems += 2
c.right.left = c
c.left.right = c

@ 가지 둘을 묶는 경우가 가장 복잡하다. 먼저 가지 |a|와 그 자손들, 곧 작용
리스트에서 |a|부터 |d=a.scope|까지를 떼어 내고, |c|를 |b|의 자리에 넣는다.
그다음은 |a|와 |b|가 |c|에 녹아드는지에 따라 네 경우로 나뉜다.

@<가지와 가지로 짓는다@>=
mems += 3
d = a.scope
c.rsave = d.right
mems += 4
a.left.right = d.right
d.right.left = a.left
mems += 3
c.left = b.left
c.left.right = c
if at != t {
	@<녹지 않는 가지 |a|를 |c|의 맨 왼쪽 자식으로 둔다@>@;
} else if bt != t {
	@<가지 |a|는 녹이고 |b|는 그대로 자식으로 둔다@>@;
} else {
	@<가지 |a|와 |b|를 둘 다 녹인다@>@;
}

@ @<녹지 않는 가지 |a|를 |c|의 맨 왼쪽 자식으로 둔다@>=
mems += 2
c.lsave = a.left
mems += 3
c.lchild, c.right, a.left = a, a, c
if bt != t {
	mems += 4
	a.lsib, a.rsib, b.lsib, b.rsib = b, b, a, a
	mems += 2
	d.right, b.left = b, d
	mems += 3
	c.scope = b.scope
} else {
	mems += 4
	a.rsib = b.lchild
	a.lsib = b.lchild.lsib
	mems += 2
	a.rsib.lsib = a
	a.lsib.rsib = a
	mems += 3
	d.right = b.right
	d.right.left = d
	mems += 2
	c.scope = b.scope
	if b.scope == b {
		c.scope = d
	}
}

@ @<가지 |a|는 녹이고 |b|는 그대로 자식으로 둔다@>=
mems += 3
b.rsib = a.lchild
c.lchild = b.rsib
mems += 2
b.lsib = a.lchild.lsib
mems += 2
b.rsib.lsib = b
b.lsib.rsib = b
if d == a {
	mems++
	c.right = b
} else {
	mems += 4
	c.right, d.right, b.left = a.right, b, d
}
mems++
c.right.left = c
mems += 2
c.scope = b.scope

@ 둘 다 녹이면 두 형제 고리를 하나로 잇는다. 범위 |c.scope|는 |b|의 것이 있으면
그것이고, 없으면 |a|의 것이며, 그것도 없으면 |c| 자신이다.

@<가지 |a|와 |b|를 둘 다 녹인다@>=
if d == a {
	mems += 2
	c.right = b.right
} else {
	mems += 5
	c.right, d.right = a.right, b.right
	b.right.left = d
}
mems++
c.right.left = c
mems += 2
c.lchild = a.lchild
mems += 4
d = a.lchild.lsib
a.lchild.lsib = b.lchild.lsib
mems += 3
b.lchild.lsib.rsib = a.lchild
b.lchild.lsib = d
d.rsib = b.lchild
mems += 2
switch {
case b.scope != b:
	c.scope = b.scope
case a.scope != a:
	c.scope = a.scope
default:
	c.scope = c
}

@ 결합 한두 개를 그래프에서 잠시 지운다는 사실을 적어 두는 데는 훨씬 간단한
서브루틴을 쓴다. 두 번째 호 |bb|가 |nil|이면 결합 하나를 그 끝점과 함께 지운다.

@<함수들@>=
func deleteBonds(aa, bb *arc) (mems float64) {
	var a, c *Bond
	var u, v *vertex
	bondcount++
	c = &bondbase[bondcount]
	mems += 3
	c.typ, c.lhist, c.rhist = 2, aa, bb
	mems += 2
	u, a = aa.mate.tip, aa.bond
	mems++
	if bb != nil {
		v = bb.mate.tip
	} else {
		v = aa.tip
	}
	if extraverbose {
		fmt.Fprintf(out, " %d: deleting bond %d between %s and %s%s\n",
			c.num, a.num, u.name, endpoint(bb), v.name)
	}
	mems += 6
	unlink(aa)
	u.deg--
	if bb != nil {
		mems += 6
		unlink(bb)
		v.deg--
	}
	return
}

@ 결합 하나를 끝점과 함께 지우거나 되살릴 때는 꼭짓점 이름 앞에 \.{endpoint}를
붙여 찍는다. 원본은 조건 연산자로 쓰는데, 두 곳에서 쓰니 작은 함수로 둔다.

@<함수들@>=
func endpoint(bb *arc) string {
	if bb == nil {
		return "endpoint "
	}
	return ""
}

@* 허물기.
수준~1에 처음 이른 뒤로 그래프를 바꾼 것은 프로그램이 끝나기 전에 모두 되돌려야
한다. 다행히 바꾸는 일은 언제나 나중에 한 것을 먼저 되돌리는 차례로 엄격히
이루어진다. 그래서 ``춤추는 고리''의 원리를 써서, 지운 구조 안의 포인터들이
되돌려야 할 값을 아직 간직하고 있다는 사실을 이용할 수 있다.

그래서 커누스는 결합을 허무는 코드를, 짓는 코드를 보며 그것이 바꾼 것을 하나하나
되바꾸는 식으로 쓸 수 있었다. (이 말은 결합의 상태를 다스리는 필드 |prev|,
|next|, |bond|, |lchild|, |lsib|, |rsib|, |scope|, |left|, |right|를 바꾼 것에만
해당한다. 필드 |val|, |des|, |done|, |up|, |down|은 신장 나무에 따라 움직이니 눈감고
되돌려서는 안 된다. 필드 |focus|는 짓거나 허무는 동안에는 언제나 자기 자신을
가리킨다.)

(그래도 이 프로그래밍은 지루했고 실수하기 쉬웠다고 커누스는 한숨지었다.)

원본에서 이것은 서브루틴 |unbuildbond|인데, 부르는 곳이 하나뿐이라 이 판은 그
자리에 절로 끼워 넣는다. 원본이 |return|으로 빠져나가는 자리는 |continue|로 다음
결합으로 넘어간다. 쓰는 변수는 |main|의 지역 변수를 함께 쓰고, 모자라는 것은 더
둔다.

@<지역 변수@>=
var (
	a, c, d   *Bond // 허무는 결합 |c|와 그 두 자식, 그리고 도우미
	t, at, bt int  // |c|, |a|, |b|의 종류
	aa, bb    *arc // 결합 |c|를 낳은 변들
)

@ @<맨 나중에 지은 결합을 허문다@>=
c = &bondbase[bondcount]
bondcount--
mems += 3
t, aa, bb = c.typ, c.lhist, c.rhist
if t > 1 {
	@<지운 결합을 한두 개 되살린다@>@;
	continue
}
mems += 2
a, b = bb.mate.bond, bb.bond
mems++
bb.mate.bond = b
mems += 2
aa.bond, aa.mate.bond = a, a
mems += 2
at, bt = a.typ, b.typ
if t != 0 {
	@<옛 직렬 결합에서 |aa|와 |bb|를 되돌린다@>@;
} else {
	@<옛 병렬 결합에서 |aa|와 |bb|를 되돌린다@>@;
}
@<결합 |c|를 허물어 |a|와 |b|로 되돌린다@>@;
@<결합 |c| 대신 |a|와 |b|를 나무 리스트에 넣는다@>@;

@ @<결합 |c|를 허물어 |a|와 |b|로 되돌린다@>=
if a.isLeaf() {
	if b.isLeaf() {
		@<잎과 잎으로 지은 것을 허문다@>@;
	} else {
		@<잎과 가지로 지은 것을 허문다@>@;
	}
} else if b.isLeaf() {
	@<가지와 잎으로 지은 것을 허문다@>@;
} else {
	@<가지와 가지로 지은 것을 허문다@>@;
}

@ @<결합 |c| 대신 |a|와 |b|를 나무 리스트에 넣는다@>=
if c.val != 0 {
	mems += 4
	c.up.down = c.down
	c.down.up = c.up
}
if a.val != 0 {
	mems += 5
	a.up = tree.up
	a.up.down = a
	tree.up = a
	a.down = tree
}
if b.val != 0 {
	mems += 5
	b.up = tree.up
	b.up.down = b
	tree.up = b
	b.down = tree
}

@ 직렬로 지을 때 |aa|는 |bb.mate|의 자리에 앉았다. 이제 |bb.mate|를 제자리로
되돌리고, |aa|는 없앴던 꼭짓점 |v|의 리스트로 돌려보낸다. 그 리스트에는 호가
|aa|와 |bb| 둘뿐이었으니 |aa|의 앞은 머리 노드이고 뒤는 |bb|다.

@<옛 직렬 결합에서 |aa|와 |bb|를 되돌린다@>=
mems += 4
relink(bb.mate)
mems += 2
v = bb.mate.tip
aa.mate.tip, v.mark = v, 0
mems += 3
aa.prev, aa.next = v.arcs, bb
if extraverbose {
	fmt.Fprintf(out, " removing %d=series(%d,%d) between %s and %s\n",
		c.num, a.num, b.num, aa.tip.name, bb.tip.name)
}

@ 지운 차례의 거꾸로 되살린다. 원본의 줄은 |oooo,undelete(mate(bb)),
undelete(bb), u->deg++, v->deg++|이니 메모리 참조가 모두 열둘이다.

@<옛 병렬 결합에서 |aa|와 |bb|를 되돌린다@>=
mems += 2
u, v = aa.tip, aa.mate.tip
mems += 12
relink(bb.mate)
relink(bb)
u.deg++
v.deg++
if extraverbose {
	fmt.Fprintf(out, " removing %d=parallel(%d,%d) between %s and %s\n",
		c.num, a.num, b.num, u.name, v.name)
}

@ 맨 윗 수준 결합의 형제 고리는 아무도 들여다보지 않는다. 이 프로그램은 깔끔하려고,
그리고 혹시 있을 실수를 잡으려고 그것을 |nil|로 되돌릴 뿐, 메모리 참조는 세지
않는다.

@<잎과 잎으로 지은 것을 허문다@>=
a.lsib, a.rsib, b.lsib, b.rsib = nil, nil, nil, nil
mems += 3
action.right = c.right
action.right.left = action

@ 뻔하지 않은 것은 사용하지 않던 결합이 다시 무대에 오를 때 |des|를 셈하는
일이다. 녹아들었던 가지 |b|가 다시 살아나면, |c|가 |a|를 지정하고 있었으면 |b|의
값은 |b.typ|이고, 아니면 |c|의 값을 물려받는다. 값이 |b.typ|과 다르면 |b|는 |c|의
지정 자식을 지정해야 한다.

@<잎과 가지로 지은 것을 허문다@>=
if bt != t {
	a.lsib, a.rsib, b.lsib, b.rsib = nil, nil, nil, nil
	mems += 2
	b.left = c.left
} else {
	@<되살아나는 가지 |b|의 값과 지정 자식을 정한다@>@;
	mems += 4
	b.lchild.lsib = a.lsib
	a.lsib.rsib = b.lchild
	mems += 3
	b.done = b.des.lsib
	a.lsib, a.rsib = nil, nil
	mems += 2
	b.right.left = b
}
mems += 2
b.left.right = b

@ 이 계산은 세 곳에서 똑같이 한다. 지정 자식을 고치는 메모리 참조는 바로 뒤에
|b.des.lsib|를 읽으며 함께 센다.

@<되살아나는 가지 |b|의 값과 지정 자식을 정한다@>=
mems++
if c.des == a {
	mems++
	b.val = bt
} else {
	mems += 2
	b.val = c.val
}
if b.val != bt {
	b.des = c.des // 메모리 참조는 아래에서 센다
}

@ @<가지와 잎으로 지은 것을 허문다@>=
if at != t {
	a.lsib, a.rsib, b.lsib, b.rsib = nil, nil, nil, nil
	mems += 2
	a.left = c.left
} else {
	@<되살아나는 가지 |a|의 값과 지정 자식을 정한다@>@;
	mems += 4
	a.lchild.lsib = b.lsib
	b.lsib.rsib = a.lchild
	mems += 3
	a.done = a.des.lsib
	b.rsib, b.lsib = nil, nil
	mems += 2
	a.right.left = a
}
mems += 2
a.left.right = a

@ @<되살아나는 가지 |a|의 값과 지정 자식을 정한다@>=
mems++
if c.des == b {
	mems++
	a.val = at
} else {
	mems += 2
	a.val = c.val
}
if a.val != at {
	a.des = c.des
}

@ 같은 종류의 직렬 결합 둘을, 또는 병렬 결합 둘을 더 큰 결합 하나로 묶었다면,
|c.des|가 어느 쪽에 있는지 알아내려고 자식들을 뒤져야 할 수도 있다.

@<가지와 가지로 지은 것을 허문다@>=
mems += 3
d = a.scope
d.right = c.rsave
if at != t {
	@<가지 |a|를 |c|의 맨 왼쪽 자식 자리에서 되돌린다@>@;
} else {
	if d != a {
		mems += 2
		a.right.left = a
	}
	if bt != t {
		@<녹았던 가지 |a|를 되살리고 |b|를 되돌린다@>@;
	} else {
		@<녹았던 가지 |a|와 |b|를 둘 다 되살린다@>@;
	}
}
mems += 4
a.left.right = a
d.right.left = d

@ @<가지 |a|를 |c|의 맨 왼쪽 자식 자리에서 되돌린다@>=
mems += 2
a.left = c.lsave
if bt != t {
	a.lsib, a.rsib, b.lsib, b.rsib = nil, nil, nil, nil
	mems += 3
	b.left = c.left
	b.left.right = b
} else {
	@<되살아나는 가지 |b|의 값과 지정 자식을 정한다@>@;
	mems += 4
	b.lchild.lsib = a.lsib
	a.lsib.rsib = b.lchild
	mems += 3
	b.done = b.des.lsib
	mems += 4
	b.right.left = b
	b.left.right = b
	a.lsib, a.rsib = nil, nil
}

@ @<녹았던 가지 |a|를 되살리고 |b|를 되돌린다@>=
@<되살아나는 가지 |a|의 값과 지정 자식을 정한다@>@;
mems += 4
a.lchild.lsib = b.lsib
b.lsib.rsib = a.lchild
mems += 3
a.done = a.des.lsib
mems += 4
b.left = c.left
b.left.right = b
b.lsib, b.rsib = nil, nil

@ 둘 다 녹았던 경우에 |c|의 값이 |t|면 두 가지의 값도 |t|다. 그렇지 않으면
|c.des|에서 왼쪽 형제를 따라가다 처음 만나는 맨 왼쪽 자식이 |a|의 것인지 |b|의
것인지로, |c.des|가 어느 가지에 속했는지 안다.

@<녹았던 가지 |a|와 |b|를 둘 다 되살린다@>=
if c.val == t {
	mems += 2
	a.val, b.val = t, t
} else {
	@<지정 자식 |c.des|가 어느 가지의 것인지 찾는다@>@;
}
mems += 6
d = a.lchild.lsib
a.lchild.lsib = b.lchild.lsib
b.lchild.lsib = d
mems += 2
d.rsib = b.lchild
a.lchild.lsib.rsib = a.lchild
mems += 5
a.done, b.done = a.des.lsib, b.des.lsib
d = a.scope
mems += 4
b.right.left = b
b.left.right = b

@ @<지정 자식 |c.des|가 어느 가지의 것인지 찾는다@>=
mems += 3
for d = c.des; ; d = d.lsib {
	if d == a.lchild {
		mems += 3
		a.val, b.val, a.des = 1-t, t, c.des
		break
	} else if d == b.lchild {
		mems += 3
		b.val, a.val, b.des = 1-t, t, c.des
		break
	}
	mems++
}

@ 결합 하나를 끝점과 함께 지웠으면, 디버깅을 위해 그 끝점의 음수 표시를 지운다.

@<지운 결합을 한두 개 되살린다@>=
mems += 2
u, a = aa.mate.tip, aa.bond
mems++
if bb != nil {
	v = bb.mate.tip
} else {
	v = aa.tip
}
if bb != nil {
	mems += 6
	relink(bb)
	v.deg++
} else {
	v.mark = 0
}
mems += 6
relink(aa)
u.deg++
if extraverbose {
	fmt.Fprintf(out, " restoring bond %d between %s and %s%s\n",
		a.num, u.name, endpoint(bb), v.name)
}
if a.val != 0 {
	mems += 5
	a.up = tree.up
	a.up.down = a
	tree.up = a
	a.down = tree
}

@* 작용 리스트 고동치기.
좋다, 어려운 일은 다 끝났다. 프로그램의 조각 하나만 더 끼우면 된다. 그리고
\.{spspan}에서 남은 일을 멋지게 해내는 법을 이미 안다.

다만 \.{spspan}에서는 가지 노드가 배열에 전위 순서로 놓여 있어 왼쪽 이웃으로 가는
것이 포인터에서 하나를 빼는 일이었지만, 여기서는 작용 리스트의 |left| 고리를
따라간다. 그래서 메모리 참조를 하나씩 더 센다.

원본은 반복문 안에서 |Bond| 포인터 |q|, |l|, |r|을 새로 선언해 정수 |l|을 가린다.
\GO/도 그것을 허락하니 이 판도 그대로 둔다.

@<작용 리스트에서 \.{spspan}의 알고리즘을 돌린다@>=
for {
	var q, l, r *Bond
	mems++
	for r = action.left; ; r = r.left { // 맨 오른쪽의 쉽지 않은 노드를 찾는다
		mems++
		if !r.easy() {
			break
		}
		mems++
	}
	mems += 2
	b, r.focus = r.focus, r // 단계 (1)과 (3)
	if b == action {
		break
	}
	@<지정 자식 |b.des|를 바꾸고 새 신장 나무를 방문한다@>@;
	mems++
	if b.des == b.done {
		@<결합 |b|를 비활성으로 만든다@>@;
	}
}

@ 결합 |b|의 오른쪽에 있는 쉽지 않은 노드는 이제 모두 활성이다. 그리고 |l|은
|b.des|의 바로 앞 값이다.

@<결합 |b|를 비활성으로 만든다@>=
mems++
b.done = l
mems++
for l = b.left; ; l = l.left { // 왼쪽으로 처음 만나는 쉽지 않은 노드를 찾는다
	mems++
	if !l.easy() {
		break
	}
	mems++
}
mems += 3
b.focus, l.focus = l.focus, l

@ 사용자가 |verbose|를 바랐으면 신장 나무에 들어온 변과 나간 변만 찍는다.
부호 \.+와 \.-는 문자열 |"+-"|와 |"-+"|를 |k|로 짚어 고른다.

@<지정 자식 |b.des|를 바꾸고 새 신장 나무를 방문한다@>=
count++
mems += 2
l, r = b.des, b.des.rsib
mems++
k = b.val // |k==l.val!=r.val|
for q = l; ; q = q.des {
	mems++
	q.val = k ^ 1
	if q.isLeaf() {
		break
	}
	mems++
}
if verbose {
	fmt.Fprintf(out, "%.15g: %c%d", count, "+-"[k], q.num)
}
for q = r; ; q = q.des {
	mems++
	q.val = k
	if q.isLeaf() {
		break
	}
	mems++
}
if verbose {
	fmt.Fprintf(out, "%c%d", "-+"[k], q.num)
	@<아주 자세히 찍으라면 나무의 변을 모두 찍는다@>@;
}
mems++
b.des = r // ``방문''

@ 덧붙임. 커누스는 첫머리에서 내세운 효율을 증명하지 않았다고 했다. 지금은 증명을
적을 시간이 없어 미안하다는 것이다. 다만 증명의 바탕은 이런 사실이다. 꼭짓점이
$n$개이고 모든 꼭짓점의 차수가 3~이상인 연결 그래프에는 신장 나무가 언제나
$2^{n/2}$개보다 많다. 그러므로 다리를 찾는 일 따위에 드는 시간은 꼭짓점 수의
다항식이라, 점근적으로 나무를 쏟아 내는 데 드는 시간보다 작다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 \.{libgb}와 함께 컴파일해 이 판과 견주었다. (요즘의
\CEE/ 컴파일러는 반환형이 없는 원본의 |main|을 받지 않으니 \.{-std=gnu89}를
주었다.) 그래프는 \.{SGB}의 생성기로 만들어 저장한 것을 두 프로그램에 똑같이
먹였다.

\smallskip
\item{$\bullet$} 그래프는 모두 $369$개다. 완전 그래프 $K_1$--$K_8$, 순환 그래프
$C_3$--$C_{12}$, |board|로 만든 격자와 원환면과 말 그래프 열여덟, 미국 도시 그래프
|miles| 셋, 겹친 변이 있는 무작위 그래프 $300$개(셋에 하나꼴로 고리가 있고 몇은
유향이다), 듬성한 무작위 그래프 $20$개, 그리고 따로 만든 작은 것 열이다. 거기에는
꼭짓점이 없는 그래프, 꼭짓점 하나에 고리만 있는 그래프, 꼭짓점 둘에 변 하나인
그래프가 있다. 그 가운데 $281$개는 신장 나무를 끝까지 만들고, $72$개는
끊어진 그래프라고, $16$개는 무향이 아니라고 알린다.
\item{$\bullet$} 그래프마다 인자를 더 주지 않고, 그리고 나무가 $20$만 개 이하이면
하나 더 주고, $2$만 개 이하이면 둘 더 주어 돌렸다. 그렇게 $879$가지 모두에서 표준
출력, 표준 오류(말에 든 프로그램 이름은 빼고), 종료 부호가 바이트까지 같았다.
마지막 줄의 |mems|도 같다는 말이다. 인자가 없을 때, 그래프 파일이 없을 때, 첫
줄부터 엉망일 때의 말과 종료 부호도 같다. 다만 파일이 중간에 잘렸을 때는 오류
부호가 다르다. \.{SGB}는 어디가 망가졌는지에 따라 $20$에 $-8$부터 $5$까지를 더한
부호를 남기는데, go-sgb는 모두 $20$으로 돌려준다.
\item{$\bullet$} 커누스의 |sanitycheck|를 두 곳, 곧 줄이기를 마치고 수준에
들어서기 직전과 |trivialgraph|에서 부르게 고친 시험판을 \CEE/와 \GO/로 하나씩
만들어 견주었다. $369$개 그래프에서 그 출력까지 모두 같았다. 나오는 ``버그''는
두 가지뿐인데, 둘 다 신장 나무에 따라 움직이는 값에 관한 것이라 커누스가 말한
대로 그 맥락에서는 해가 없다. 고리, 범위, 전위 순서, 차수를 살피는 검사는 한
번도 걸리지 않았다.
\item{$\bullet$} 답이 옳은지는 원본과 따로 파이썬으로 따져 보았다. 나무가 $20$만
개 이하인 그래프 $272$개에서, 자세히 찍은 출력을 따라가며 나무마다 정말 신장
나무인지, 나무들이 모두 서로 다른지, 그리고 나무의 수가 행렬 나무 정리로 셈한
값과 같은지를 보았다. 모두 맞았다.
\smallskip

\noindent 빠르기도 견주었다. 완전 그래프 $K_{10}$의 나무 $10^8$개를 만드는 데
원본이 $1.69$초, 이 판이 $1.42$초 걸렸다. $5\times5$ 격자의 나무 $557568000$개에는
원본이 $9.0$초, 이 판이 $7.6$초다. 원본에서 |mems|는 전역 배정도 실수인데, 이
판에서는 지역 변수다. 이 저장소의 \.{spspan}은 원본보다 느렸는데 이 판은 빠른
까닭을 나는 거기서 찾는다.

@* 색인.
