\input kotexgweb
@i types.w
\datethis

\def\adj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-8mu\mathrel-\!}}
\def\dadj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-12mu\to\!}}

\def\title{해밀턴 회로}

@* 들어가며.
이 프로그램은 주어진 그래프의 해밀턴 회로를 모두 찾는다. 쓰는 알고리즘이 재미있다.
회로를 이룰 변을 하나씩 골라 나가되, 고른 변이 최종 회로의 어느 자리에 놓일지는
모든 조각이 이어 붙기 전까지 모른다. 크누스는 원본에 이렇게 적어 두었다.

\medskip{\narrower\noindent
그 중요한 착상은 Geoffrey Selby의 학위논문(1970)에서 나왔고, Silvano Martello가
1983년에 {\mc MRV} 가지치기 heuristic을 얹어 넓혔다. 나는 2001년에 Selby의 방식을
따로 다시 찾아냈는데, 내 것은 조금 더 대칭적이다. 내 변형에서는 부분경로들이 모두
같은 자격을 지니므로, 으뜸 부분경로 한쪽 끝을 늘리는 방법만 놓고 가지를 칠 까닭이
없다. 내가 처음 구현한 {\mc HAMDANCE}는 춤추는 연결을 썼다. 여기서는 대신 성긴
집합(sparse set) 자료구조를 쓴다.\par}\medskip

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{ssham.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/ssham.w}를
\.{GWEB}으로 옮긴 것이다. 이 저장소에는 이미 \.{sham.w}가 있다. 그것은 크누스의
\.{SGB} 시연 프로그램 {\mc SHAM}을 옮긴 것으로, $8\times9$ 판 기사 그래프의
{\it 대칭\/} 해밀턴 회로만 센다. 이번 것은 앞에 \.s가 하나 더 붙은 {\mc SSHAM}이고,
대칭이든 아니든 회로를 모두 센다. 이름이 닮았을 뿐 알고리즘은 전혀 다르다.

그래프는 \.{SGB} 형식의 파일로 읽어 들인다. 그 일은 \pdfURL{go-sgb}%
{https://github.com/sjnam/go-sgb}의 |gbsave.RestoreGraph|가 해 준다.

@ 다른 프로그램들({\mc SSXCC} 따위)과 마찬가지로 이 프로그램도 실행 시간을
``mem'' 단위로 알린다. 여덟 바이트짜리 메모리 낱말을 읽거나 쓸 때마다 하나씩
세고, 이미 레지스터에 있는 자료를 다룰 때는 세지 않는다. (그래프를 읽어 들이거나
결과를 찍는 데 드는 일은 알리는 mem 수에 들어가지 않는다.)

\CEE/에서는 쉼표 연산자를 써서 |o,x=y[i]|처럼 셈과 계산을 한 줄에 얹는다.
\GO/에는 쉼표 연산자가 없으니, 값 하나를 셈하는 자리에서는 |mems++|를 앞에 붙이고,
반복문의 뒤처리처럼 식 자리에서 세야 할 때는 |mems, k = mems+1, act[k].rlink|라는
여럿 대입을 쓴다. 그래서 mem 수가 원본과 한 자리도 다르지 않다.

\CEE/의 |int|는 네 바이트이므로, 원본은 |m|과 |d|처럼 나란한 네 바이트 둘을 한
낱말에 담아 mem 하나로 함께 짚는다. \GO/의 |int|는 여덟 바이트라 사정이 다르지만,
셈은 원본 그대로 둔다. 세는 것은 우리 기계가 실제로 짚는 낱말 수가 아니라 크누스가
설계한 알고리즘의 값이기 때문이다.

@ 뼈대는 짧다. 명령줄을 읽고, 그래프를 준비하고, 되추적하고, 알린다.

@c
package main

import (
	"fmt"
	"io"
	"os"
	"strconv"
	@#
	"github.com/sjnam/go-sgb/gbflip"
	"github.com/sjnam/go-sgb/gbgraph"
	"github.com/sjnam/go-sgb/gbsave"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 처리하고 그래프를 읽어 들인다@>@;
	@<그래프를 되추적에 맞게 준비한다@>@;
	imems, mems = mems, 0
	@<모든 해를 되추적으로 훑는다@>@;
done:
	@<결과를 알린다@>@;
}

@ @<지역 변수@>=
var i, j, k, d, t, u, v, w, mm int

@ @<상수@>=
const (
	maxn  = 1000 // 마디는 많아야 이만큼
	infty = maxn // 어떤 마디 번호보다도 크다
)

@ @<전역 변수@>=
var (
	g     *gbgraph.Graph // 주어진 그래프
	mems  int64          // 메모리를 짚은 횟수
	imems int64          // 그 가운데 그래프를 준비하는 데 든 것
	rmems int64          // 무작위로 섞을 때만 세는 것
)

@* 명령줄.
명령줄 첫머리에는 그래프 이름이 온다. \.{foo.gb}처럼 \.{SGB} 형식으로 담긴
파일이다. 그 뒤로는 해를 얼마나 찍을지, 진단 정보를 얼마나 낼지를 고르는 선택항이
따라올 수 있다.

쓸 수 있는 선택항은 이렇다.
\smallskip
\item{$\bullet$}
`\.v$\langle\,$정수$\,\rangle$'는 |showChoices| 따위의 이진 부호를 더한 값으로,
|os.Stderr|에 낼 여러 가지 수다스러운 출력을 켜고 끈다.
\item{$\bullet$}
`\.m$\langle\,$정수$\,\rangle$'는 해를 $m$개마다 하나씩 찍게 한다.
(기본값 \.{m0}은 세기만 한다.)
\item{$\bullet$}
`\.s$\langle\,$정수$\,\rangle$'는 입력 그래프의 자료를 무작위로 흩는다.
(해가 고르게 무작위로 나온다는 뜻은 결코 아니고, 그저 다른 차례를 맛보게 해 준다.)
\item{$\bullet$}
`\.d$\langle\,$정수$\,\rangle$'는 |delta|를 정한다. 앞선 보고 뒤로 mem이 대략
|delta|만큼 쌓일 때마다 |os.Stderr|에 진행 상황을 알린다. (기본값 $10^{10}$)
\item{$\bullet$}
`\.t$\langle\,$양의 정수$\,\rangle$'는 해를 이만큼 찾으면 멈추게 한다.
\item{$\bullet$}
`\.T$\langle\,$정수$\,\rangle$'는 |timeout|을 정한다. 어떤 수준에 들어설 때
|mems > timeout|이면 그 자리에서 그만둔다.
\item{$\bullet$}
`\.n$\langle\,$정수$\,\rangle$'는 입력 그래프의 앞쪽 |n|개 마디만 남기고 나머지를
버린다. (기본값 |maxn|)

@ @<상수@>=
const (
	showBasics    = 1   // 기본 통계; 이것이 기본값이다
	showChoices   = 2   // 되추적 기록
	showDetails   = 4   // 더 자세한 설명
	showRawSols   = 64  // 해를 호가 더해진 차례대로 보인다
	showProfile   = 128 // 탐색 나무의 옆모습
	showFullState = 256 // 완전한 상태 보고
)

@ 해와 마디의 개수를 담는 것들은 원본에서 |unsigned long long|이다. \GO/에는
부호 없는 예순네 자리 정수 |uint64|가 있지만, 여기서는 |int64|로 둔다. 견줌과
셈이 훨씬 편하고, $2^{63}$개를 넘게 셀 일은 없다.

@<전역 변수@>=
var (
	randomSeed  int64 // |gbflip|의 씨앗
	randomizing bool  // 선택항 `\.s'가 주어졌나?
	rng         *gbflip.RNG
	vbose       = showBasics // 수다스러움의 정도
	spacing     int64        // $k$가 |spacing|의 배수일 때 $k$번째 해를 찍는다
	maxl        int          // 실제로 다다른 가장 깊은 수준
	count       int64        // 지금까지 찾은 해
	delta       int64 = 10000000000 // 이만큼 mem이 쌓일 때마다 알린다
	thresh      int64 = 10000000000 // |mems|가 이를 넘으면 알린다
	maxcount    int64 = 1<<63 - 1   // 해를 이만큼 찾으면 멈춘다
	timeout     int64 = 0x1fffffffffffffff // mem이 이만큼 들면 포기한다
	nodes       int64 // 탐색 나무의 크기
	profile     [maxn + 1]int64 // 탐색 나무의 수준마다 마디가 몇인가
	nn          int   // 주어진 그래프의 마디 수
	nmax        = maxn // 마디 번호의 윗자락
	mind, maxd  int    // 주어진 그래프의 가장 작은 차수와 가장 큰 차수
)

@ 같은 선택항이 여러 번 나오면 맨 앞의 것이 이긴다. 명령줄을 뒤에서 앞으로 훑기
때문이다.

문자열을 정수로 새기는 일이 일곱 군데에서 되풀이되니, 자리에서 클로저 둘을 지어
쓴다. 어딘가에서 새기기에 실패하면 |bad|가 서고, 그러면 쓰는 법을 알리고 그만둔다.

@<명령줄을 처리하고 그래프를 읽어 들인다@>=
{
	bad := len(os.Args) < 2
	setInt := func(s string, p *int) {
		if x, err := strconv.Atoi(s); err != nil {
			bad = true
		} else {
			*p = x
		}
	}
	setInt64 := func(s string, p *int64) {
		if x, err := strconv.ParseInt(s, 10, 64); err != nil {
			bad = true
		} else {
			*p = x
		}
	}
	@<선택항을 훑는다@>@;
	@<그래프 파일을 읽어 들인다@>@;
	if bad {
		@<쓰는 법을 알리고 그만둔다@>@;
	}
}
if randomizing {
	rng = gbflip.New(randomSeed)
}

@ @<선택항을 훑는다@>=
for j := len(os.Args) - 1; j > 1; j-- {
	arg := os.Args[j]
	if arg == "" {
		bad = true
		continue
	}
	switch arg[0] {
	case 'v':
		setInt(arg[1:], &vbose)
	case 'm':
		setInt64(arg[1:], &spacing)
	case 's':
		setInt64(arg[1:], &randomSeed)
		randomizing = true
	case 'd':
		setInt64(arg[1:], &delta)
		thresh = delta
	case 't':
		setInt64(arg[1:], &maxcount)
	case 'T':
		setInt64(arg[1:], &timeout)
	case 'n':
		setInt(arg[1:], &nmax)
	default: // 알아볼 수 없는 선택항이다
		bad = true
	}
}

@ @<그래프 파일을 읽어 들인다@>=
if !bad {
	var err error
	if g, err = gbsave.RestoreGraph(os.Args[1]); err != nil {
		fmt.Fprintf(os.Stderr, "%s에서 그래프를 되살릴 수 없다: %v!\n", os.Args[1], err)
		bad = true
	} else {
		nn = int(g.N)
		if nn > nmax {
			nn = nmax
		}
		if nn > maxn {
			fmt.Fprintf(os.Stderr,
				"미안하지만 그래프 %s는 마디가 너무 많다 (%d>%d)!\n",
				os.Args[1], nn, maxn)
			os.Exit(2)
		}
	}
}

@ @<쓰는 법을 알리고 그만둔다@>=
fmt.Fprintf(os.Stderr,
	"쓰는 법: %s foo.gb [v<n>] [m<n>] [s<n>] [d<n>] [t<n>] [T<n>] [n<n>]\n",
	os.Args[0])
os.Exit(1)

@ 결과는 이렇게 알린다.

@<결과를 알린다@>=
if vbose&showProfile != 0 {
	@<옆모습을 찍는다@>@;
}
if vbose&showBasics != 0 {
	fmt.Fprintf(os.Stderr, "모두 해서 해 %d개, 마디 %d개,", count, nodes)
	fmt.Fprintf(os.Stderr, " %d+%d mem.\n", imems, mems)
}

@ @<옆모습을 찍는다@>=
fmt.Fprintln(os.Stderr, "옆모습:")
for l := 1; l <= maxl; l++ {
	fmt.Fprintf(os.Stderr, "%3d: %d\n", l, profile[l])
}

@* 자료구조.
이 프로그램은 그래프 |g|에서 출발해 회로 하나만 남을 때까지 변을 걷어내는
알고리즘이라고 볼 수 있다.

그래서 그래프 |g|를 성긴 집합으로 나타낸다. 자꾸만 작아지는 그래프의 지금 모습을
간수하는 데 이만한 것이 없다. 착상은 이렇다. 배열 둘 |nbr|과 |adj|를 두고, 마디
|v|마다 한 줄씩 준다. 마디 |v|의 이웃이 |g| 안에 |d|개라면, 그 이웃들은 |nbr[v]|의
앞쪽 |d|칸에 (아무 차례로나) 늘어선다. 그리고 |nbr[v][k]=u|이고 $0\le k<d$이면
|adj[v][u]=k|다. 곧 이런 붙박이 관계가 있다.
$$\hbox{|nbr[v][adj[v][u]] = u|}$$
이웃을 지우려면 오른쪽으로 밀고 |d|를 줄이면 되고, 되살리려면 |d|를 늘리기만 하면
된다. 게다가 |u|가 |v|의 이웃이 아니면 |adj[v][u]|는 있을 수 없는 값 |infty|를
지닌다. 그러니 |adj| 행렬은 인접 행렬 구실도 함께 한다.

@<전역 변수@>=
var (
	nbr, adj [maxn][maxn]int // |g|를 성긴 집합으로 나타낸 것
	degree   [maxn]int       // 입력 그래프에서의 차수 (진단할 때만 쓴다)
)

@ 그래프 |g|의 변은 서로 반대로 달리는 호 한 쌍으로 여긴다. (다시 말해 변
$u\adj v$는 실제로는 호 $u\dadj v$와 호 $v\dadj u$ 둘로 다룬다.) 변을 지울 때
둘 가운데 하나만 지워야 할 때가 잦다. 알고리즘이 둘 다에 매달리지는 않기 때문이다.

알고리즘은 쓸모없는 변을 걷어내기만 하는 것이 아니라 걷어내지 {\it 않을\/} 변을
고르기도 한다. 고른 변은 \&{edge} 구조체의 배열 |e|에 쌓인다. 구조체에는 마디 둘
|u|와 |v|가 들어 있다. $k$번째로 고른 변이 $u\adj v$이면 |e[k].u=u|이고
|e[k].v=v|다.

@<자료형@>=
type edge struct {
	u, v int // 이 변이 잇는 마디 둘
}

@ @<전역 변수@>=
var (
	e    [maxn + 1]edge // 지금까지 고른 변들
	eptr int            // 지금까지 이만큼 골랐다
)

@ 고른 변들은 최종 회로의 부분경로 하나 또는 여럿을 이룬다.
$$v_0\adj v_1\adj \cdots\adj v_k$$
가 고른 부분경로이고 $v_0$과 $v_k$가 지금까지 고른 변 가운데 하나에만 걸려 있다면,
$v_0$과 $v_k$를 ``바깥'' 마디라 부르고 $\{v_1,\ldots,v_{k-1}\}$을 ``안쪽''이라
부른다. 바깥도 안쪽도 아닌 마디는 ``맨몸''이다. 모든 마디는 맨몸으로 태어나 언젠가
옷을 입는다. 끝에 가면 마지막으로 고른 변의 두 마디만 빼고 모두 안쪽이 되고, 고른
변들이 곧 해밀턴 회로가 된다.

알고리즘이 나아가는 동안 마디 |v|마다 정수 둘이 딸린다. 짝 |vrt[v].m|과 차수
|vrt[v].d|다. 위의 부분경로에서 $v_0$의 짝은 $v_k$이고 $v_k$의 짝은 $v_0$이다.
그 규칙이 모든 바깥 마디의 짝을 정한다. 맨몸인 마디의 짝은 $-1$이라고 두는데, 이는
필요충분조건이다. 안쪽 마디의 짝 값은 정해져 있지 않다. 다만 음수가 아니라는 것만은
확실하다.

마디 $v$가 바깥이거나 맨몸이면 |vrt[v].d|는 $v$에 닿아 있으면서 아직 고르지도
않았고 최종 경로에서 아직 배제되지도 않은 변의 수다. (마찬가지로 안쪽 마디의 차수는
정해져 있지 않다. 안쪽 마디는 알고리즘의 눈에 아예 보이지 않는다.)

두 값을 한꺼번에 짚을 수 있도록 \&{vert} 구조체 하나에 담아 둔다. 원본에서는
\.{mate(v)}와 \.{deg(v)}라는 매크로로 이 두 자리를 부른다.

@<자료형@>=
type vert struct {
	m, d int // 이 마디의 짝과 차수
}

@ @<전역 변수@>=
var vrt [maxn]vert

@ 앞서 말했듯 안쪽 마디는 알고리즘의 눈에 보이지 않는다. 배열 |vis|는 보이는
마디---곧 맨몸이거나 바깥인 것---를 늘어놓는다. 이 또한 성긴 집합이다. 마디들의
순열을 담되 보이지 않는 것들을 뒤로 몬다. 짝인 |ivis|에는 그 역순열이 들어 있어
이런 관계가 성립한다.
$$\hbox{|vis[k]=v| \qquad $\Leftrightarrow$ \qquad |ivis[v]=k|}$$
마디 |v|가 보이는 것은 |ivis[v]<visible|일 때이고 오직 그때뿐이다. 따라서
|ivis[v]>=visible|인 것이 |v|가 안쪽이라는 말과 같다.

@<전역 변수@>=
var (
	vis, ivis [maxn]int // 보임을 성긴 집합으로 나타낸 것
	visible   int       // 지금 이만큼이 보인다
)

@ 마디 하나를 안쪽으로 밀어 넣는 일은 두 군데에서 부른다. 원본에서는 매크로다.

@<함수들@>=
func makeinner(v int) {
	mems++
	visible--
	vv := vis[visible]
	mems++
	k := ivis[v]
	mems += 2
	vis[visible], ivis[v] = v, visible
	mems += 2
	vis[k], ivis[vv] = vv, k
}

@ @<초기화한다@>=
for k = 0; k < nn; k++ {
	mems += 2
	vis[k], ivis[k] = k, k
}
visible = nn

@ 있는 호 하나를 |u|에서 |v|로 지우는 일은 이렇게 한다. 마디 |u|는 보이고
|v|는 지금 |u|의 이웃이라고, 곧 |adj[u][v] < vrt[u].d|라고 가정한다.

원본은 \.{remove\_arc}를 실전판에서 \&{inline}으로 두어도 된다고 적었다. 그래서 부르는
값으로 mem을 따로 매기지 않는다. \GO/에서도 마찬가지다. 컴파일러가 이만한 함수는
저절로 펼친다.

$k=d$인지 미리 보는 것은 여기서 mem 여섯을 아껴 준다. 갈래 예측을 어지럽히는 값을
치르는 것이니, 늘 슬기로운 셈은 아니다.

@<함수들@>=
func removeArc(u, v int) {
	mems++
	d := vrt[u].d - 1
	mems += 2
	k := adj[u][v] // $k\le d$라고 가정한다
	if k != d {
		mems += 2
		w := nbr[u][d]
		mems += 4
		nbr[u][d], nbr[u][k] = v, w
		adj[u][v], adj[u][w] = d, k
	}
	mems++
	vrt[u].d = d
}

@ 지금의 부분해에 들어 있는 바깥 마디들은 두겹 연결 리스트로 이어 둔다. 리스트의
각 칸은 \&{pair} 구조체로, 왼쪽과 오른쪽을 가리키는 |llink|와 |rlink|를 지닌다.
리스트의 머리도 \&{pair} 구조체인데, 이름이 |head|다.

마디 |v|가 바깥 마디인 것은 짝 |act[v]|가 |head|에서 닿을 수 있는 리스트에 들어
있을 때이고 오직 그때뿐이다. 리스트에 넣는 일을 |v|를 ``살린다''고 하고, 빼내는
일을 ``재운다''고 하자.

@<자료형@>=
type pair struct {
	llink, rlink int // 두겹 연결 리스트에서 왼쪽과 오른쪽으로 가는 연결
}

@ @<상수@>=
const head = maxn // |act| 배열 안 리스트 머리의 자리

@ @<전역 변수@>=
var act [maxn + 1]pair

@ @<초기화한다@>=
mems++
act[head].llink, act[head].rlink = head, head // 활성 리스트는 비어서 시작한다

@ 살리고 재우는 일도 원본에서는 매크로다. 재우는 일에는 안쪽으로 밀어 넣는 일이
딸려 온다.

@<함수들@>=
func activate(v int) {
	mems++
	l := act[head].llink
	mems += 2
	act[l].rlink, act[head].llink = v, v
	mems++
	act[v].llink, act[v].rlink = l, head
}

func deactivate(v int) {
	mems++
	l, r := act[v].llink, act[v].rlink
	mems += 2
	act[l].rlink, act[r].llink = r, l
	makeinner(v)
}

@* 그래프 들이기.
명령줄 선택항 가운데 하나는 입력 그래프를 무작위로 흩게 한다. 우리 그래프의 마디
|k|는 읽어 들인 그래프의 마디 |perm[k]|에 맞선다. 여기서 |perm[0]|, \dots,
|perm[nn-1]|은 무작위 순열이다. 마디 이름을 알아내는 |name|은 그러니 역순열
|iperm|을 거친다.

@<전역 변수@>=
var (
	perm  [maxn]int // 이 프로그램과 입력 그래프 사이의 마디 대응
	iperm [maxn]int // 그 역대응
)

@ @<함수들@>=
func name(v int) string { return g.Vertices[iperm[v]].Name }

@ @<그래프를 되추적에 맞게 준비한다@>=
@<초기화한다@>@;
if randomizing {
	@<마디 번호를 뒤섞는다@>@;
} else {
	for j = 0; j < nn; j++ {
		perm[j], iperm[j] = j, j
	}
}
@<|nbr|과 |adj| 배열을 만든다@>@;
@<차수를 살펴 가장 작은 것과 가장 큰 것을 찾는다@>@;
@<그래프의 크기를 알린다@>@;

@ @<마디 번호를 뒤섞는다@>=
for j = 0; j < nn; j++ {
	mems += 4
	k = int(rng.Unif(int64(j + 1)))
	mems += 3
	perm[j], perm[k] = perm[k], j
}
for j = 0; j < nn; j++ {
	iperm[perm[j]] = j
}

@ 여기서 그래프를 우리 자료구조로 옮긴다. \.{SGB}의 호 리스트를 훑으면서
|nbr|과 |adj|를 채우고, 가는 김에 제 고리와 겹친 변이 있는지도 살핀다. 마디
번호가 |nmax|를 넘는 것은 그냥 건너뛴다.

@<|nbr|과 |adj| 배열을 만든다@>=
for i = 0; i < nn; i++ {
	mems++
	for j = 0; j < nn; j++ {
		mems++
		adj[i][j] = infty
	}
}
mm = 0
for v = 0; v < nn; v++ {
	rmems++
	vp := perm[v]
	mems += 2 // |nbr[vp]|와 |adj[vp]|를 짚는 값. 아래 반복문에서 쓴다
	d = 0
	mems++
	for a := g.Vertices[v].Arcs; a != nil; mems, a = mems+1, a.Next {
		@<호 |a|를 자료구조에 넣는다@>@;
	}
	mems++
	vrt[vp].m, vrt[vp].d = -1, d
	degree[vp] = d
	if randomizing {
		@<이웃 목록을 뒤섞는다@>@;
	}
}
if randomizing {
	mems += rmems // |perm|이 항등이면 |rmems|는 무시한다
}

@ @<호 |a|를 자료구조에 넣는다@>=
mems++
u = int(g.Index(a.Tip))
if u >= nmax {
	continue
}
if u == v {
	fmt.Fprintf(os.Stderr, "그래프 %s에 제 고리가 있다: %s--%s!\n",
		os.Args[1], g.Vertices[v].Name, g.Vertices[u].Name)
	os.Exit(44)
}
rmems++
up := perm[u]
if adj[vp][up] != infty {
	fmt.Fprintf(os.Stderr, "그래프 %s에 겹친 변이 있다: %s--%s!\n",
		os.Args[1], g.Vertices[v].Name, g.Vertices[u].Name)
	os.Exit(4)
}
mems += 2
nbr[vp][d], adj[vp][up] = up, d
d++
mm++

@ @<이웃 목록을 뒤섞는다@>=
for j = 1; j < d; j++ {
	mems += 4
	k = int(rng.Unif(int64(j + 1)))
	mems += 2
	u, w = nbr[vp][j], nbr[vp][k]
	mems += 2
	nbr[vp][j], nbr[vp][k] = w, u
	mems += 2
	adj[vp][w], adj[vp][u] = j, k
}

@ 차수가 $2$인 맨몸 마디는 곧바로 방아쇠 목록에 오른다. 왜 그런지는 잠시 뒤에
말한다. 가는 김에 그래프가 정말 무향인지도 확인한다. 한쪽으로만 난 호가 있으면
알고리즘의 가정이 무너지기 때문이다.

@<차수를 살펴 가장 작은 것과 가장 큰 것을 찾는다@>=
mind, maxd = infty, 0
for u = 0; u < nn; u++ {
	mems++
	if vrt[u].d < mind {
		mind, curv = vrt[u].d, u
	}
	mems++
	if vrt[u].d > maxd {
		maxd = vrt[u].d
	}
	if vrt[u].d == 2 {
		mems++
		trigger[trigptr] = u
		trigptr++
	}
	for v = 0; v < nn; v++ {
		if u != v && adj[u][v] != infty && adj[v][u] == infty {
			fmt.Fprintf(os.Stderr, "그래프 %s에 한쪽으로만 난 호가 있다: %s--%s!\n",
				os.Args[1], name(u), name(v))
			os.Exit(5)
		}
	}
}

@ @<그래프의 크기를 알린다@>=
if mind < 2 {
	fmt.Printf("해밀턴 회로가 없다. 마디 %s의 차수가 %d이기 때문이다!\n",
		name(curv), mind)
	os.Exit(0)
}
fmt.Fprintf(os.Stderr, "좋다, 마디 %d개에 변 %d개인 그래프를 얻었다.\n", nn, mm/2)
fmt.Fprintf(os.Stderr, " 가장 작은 차수는 %d, 가장 큰 차수는 %d이다.\n", mind, maxd)

@* 손으로 들여다보기.
손으로 벌레를 잡을 때 쓰라고 원본은 상태를 찍는 작은 함수 몇을 남겨 두었다.
프로그램 어디에서도 부르지 않는다. 디버거 안에서 사람이 부르는 것이다. 옮기면서
그대로 두었다. 자료구조가 무엇을 뜻하는지 이만큼 또렷이 말해 주는 것도 없기
때문이다.

@<함수들@>=
func printEdges() {
	for k := 0; k < eptr; k++ {
		fmt.Printf("%s--%s\n", name(e[k].u), name(e[k].v))
	}
}

@ 마디 하나를 찍을 때는 이웃 목록을 통째로 보이되, 지금 살아 있는 이웃과 이미
지워진 이웃 사이에 세로 막대를 세운다. 그 뒤에 짝과 처지를 붙인다.

@<함수들@>=
func printVert(v int) {
	fmt.Printf("%s:", name(v))
	for k := 0; ; k++ {
		if k == vrt[v].d {
			fmt.Print("|")
		} else {
			fmt.Print(" ")
		}
		if k == degree[v] {
			break
		}
		fmt.Printf("%s", name(nbr[v][k]))
	}
	switch {
	case vrt[v].m < 0:
		fmt.Print(" 맨몸\n")
	case ivis[v] >= visible:
		fmt.Printf(" 짝 %s, 안쪽\n", name(vrt[v].m))
	default:
		fmt.Printf(" 짝 %s\n", name(vrt[v].m))
	}
}

func printVerts() {
	for v := 0; v < nn; v++ {
		fmt.Printf("%d,", v)
		printVert(v)
	}
}

func printActives() {
	for v := act[head].rlink; v != head; v = act[v].rlink {
		fmt.Printf(" %s", name(v))
	}
	fmt.Println()
}

@ 다음은 지금 상태의 자료구조가 성한지를 꼼꼼히 되짚는 함수다. 다만 총알을 다
막아내려 들지는 않는다. 이를테면 |act| 배열의 연결이 범위를 벗어나지 않았다고
가정하고, |vis|와 |ivis|가 서로 역순열인지는 아예 살피지도 않는다.

@<상수@>=
const sanityChecking = false // 벌레가 의심스러우면 |true|로 바꾼다

@ @<함수들@>=
func sanity() {
	pv, av := head, act[head].rlink
	for ; av != head; pv, av = av, act[av].rlink {
		@<활성 마디 |av|를 살핀다@>@;
	}
	if act[head].llink != pv {
		fmt.Fprintln(os.Stderr, "머리의 llink가 잘못됐다!")
	}
	for v := 0; v < nn; v++ {
		@<마디 |v|의 이웃 관계를 살핀다@>@;
	}
}

@ @<활성 마디 |av|를 살핀다@>=
if act[av].llink != pv {
	fmt.Fprintf(os.Stderr, "%s의 llink가 잘못됐다!\n", name(av))
}
if ivis[av] >= visible {
	fmt.Fprintf(os.Stderr, "활성 마디가 보이지 않는다: %s!\n", name(av))
}
switch mv := vrt[av].m; {
case mv < 0:
	fmt.Fprintf(os.Stderr, "활성 마디 %s에 짝이 없다!\n", name(av))
case mv >= nn:
	fmt.Fprintf(os.Stderr, "활성 마디 %s의 짝이 엉뚱하다!\n", name(av))
case vrt[mv].m != av:
	fmt.Fprintf(os.Stderr, "%s의 짝의 짝이 제가 아니다!\n", name(av))
case adj[av][mv] < vrt[av].d:
	fmt.Fprintf(os.Stderr, "%s에서 그 짝으로 가는 호가 남아 있다!\n", name(av))
}

@ @<마디 |v|의 이웃 관계를 살핀다@>=
for k := 0; k < degree[v]; k++ {
	if adj[v][nbr[v][k]] != k {
		fmt.Fprintf(os.Stderr, "잘못된 자리가 있다: nbr[%s][%d]\n", name(v), k)
	}
}
for u := 0; u < nn; u++ {
	if adj[v][u] != infty && nbr[v][adj[v][u]] != u {
		fmt.Fprintf(os.Stderr, "잘못된 자리가 있다: adj[%s][%s]\n", name(v), name(u))
	}
}
if ivis[v] < visible && eptr < nn { // |v|는 바깥이거나 맨몸이다
	@<보이는 마디 |v|의 이웃들이 성한지 살핀다@>@;
}

@ @<보이는 마디 |v|의 이웃들이 성한지 살핀다@>=
for k := 0; k < vrt[v].d; k++ {
	u := nbr[v][k]
	if ivis[u] >= visible {
		fmt.Fprintf(os.Stderr, "안쪽 마디 %s에 닿은 이웃이 있다: %s\n", name(u), name(v))
	} else if adj[u][v] >= vrt[u].d {
		fmt.Fprintf(os.Stderr, "사라진 호가 있다: %s--%s\n", name(v), name(u))
	}
}

@* 마디와 스택과 방아쇠 목록.
되추적 과정은 탐색 나무의 마디들을 훑는 일에 맞선다. 그 훑기를 \&{node} 구조체의
배열에 상태를 간수하면서 다스린다. 지금 수준의 정보는 |nd[level]|에 있고, 언젠가는
|nd[level-1]|, \dots, |nd[0]|에서 하던 일로 되돌아간다.

그러니 |nd|는 이 알고리즘을 다스리는 스택이다.

@<자료형@>=
type node struct {
	v int // 가지를 치고 있는 활성 마디 |curv|
	m int // 지금까지 고른 변의 수
	i int // |curv|의 지금 이웃 |curu|의 색인 |curi|
	d int // |curi|가 될 수 있는 가짓수, 곧 |curv|의 차수
	s int // 보이는 마디의 수
	t int // 방아쇠 목록에서의 밑자리 (아래를 보라)
	a int // 활성 스택에서의 밑자리 (아래를 보라)
}

@ 스택 둘이 |nd|와 나란히 움직이되 자라는 빠르기는 다르다. 마디들의 짝과 차수를
적어 두는 |savestack|과, 어느 마디가 활성이었는지를 적어 두는 |actstack|이다.
|savestack|은 수준마다 꼭 |nn|칸씩 자란다.

@<전역 변수@>=
var (
	level     int              // 가지친 깊이
	nd        [maxn]node       // 뿌리에서 지금 수준까지의 마디들
	trigger   [maxn * maxn]int // 맨몸인 채 차수가 $2$가 된 마디들
	trigptr   int              // 방아쇠 목록에 든 마디의 수
	savestack [maxn * maxn]vert // 수준마다 보이는 마디들의 자료
	saveptr   int               // |savestack|에 쌓인 칸 수
	actstack  [maxn * maxn]int  // 수준마다의 활성 마디 목록
	actptr    int               // |actstack|에 쌓인 칸 수
)

@ @<전역 변수@>=
var (
	curt, curu, curv, curw int // 지금 눈여겨보는 마디들
	curi                   int // 지금 고른 이웃의 색인
)

@ 맨몸인 마디 |v|의 차수가 지금 그래프에서 $2$라면, 어떤 해밀턴 회로든 |v|에 닿는
변 둘을 반드시 품는다. 그런 |v|를 |trigger|라는 목록에 넣어 둔다. 기회가 닿는 대로
그 변들을 골라 버리고 싶기 때문이다.

@ 마디 |u|가 맨몸일 수도 있는 자리에서는 |removeArc| 대신 |removex|를 부른다.
|removex|는 때가 되면 |u|를 방아쇠로 만들어 주기 때문이다.

(덧붙임. |u|가 맨몸이지만 곧 바깥이 될 자리에서는 |removeArc|를 부르기도 한다.
모든 자리에서 |removex|를 쓰는 것보다 그편이 빠르다.)

@<함수들@>=
func removex(u, v int) {
	mems++
	d := vrt[u].d - 1
	if vrt[u].m < 0 && d == 2 {
		mems++
		trigger[trigptr] = u
		trigptr++
	}
	mems += 2
	k := adj[u][v] // $k\le d$라고 가정한다
	if k != d {
		mems += 2
		w := nbr[u][d]
		mems += 4
		nbr[u][d], nbr[u][k] = v, w
		adj[u][v], adj[u][w] = d, k
	}
	mems++
	vrt[u].d = d
}

@* 앞으로 나아가기.
여기서는 되추적 과정의 흔한 꼴을 따른다. (그리고 크누스는 늘 하던 대로 |goto|를
쓴다.) 이 경우에는 판을 처음 벌이는 일이 좀 까다로우니, 뿌리 아닌 수준을 다루는
프로그램을 먼저 자리잡고 이해한 다음으로 그 부팅 계산을 미룬다.

\GO/에도 |goto|와 표찰이 있으니 옮기기는 곧이곧대로다. 다만 규칙 하나를 지켜야
한다. 앞으로 뛰는 |goto|는 변수 선언을 뛰어넘을 수 없다. 그래서 이 대목에서 새로
쓰는 이름은 모두 |main|의 맨 앞에서 미리 밝혔거나 블록 안에 가두었다.

@<모든 해를 되추적으로 훑는다@>=
@<되추적을 띄운다@>@;
advance:
@<방아쇠 목록에 있는 것들에 옷을 입힌다@>@;
if sanityChecking {
	sanity()
}
@<수준 하나를 새로 연다@>@;
if eptr >= nn-1 {
	@<해인지 살펴보고 |backup|으로 간다@>@;
}
@<mem이 넉넉히 쌓였으면 특별한 일을 한다@>@;
@<차수가 가장 작은 바깥 마디를 |curv|로 잡는다@>@;
if d == 0 {
	goto backup
}
@<가지칠 마디를 안쪽으로 올리고 상태를 적어 둔다@>@;
tryMove:
@<|curv|에서 |nbr[curv][curi]|로 가는 변을 고른다@>@;
goto advance
backup:
@<한 수준 물러난다@>@;
tryAgain:
@<|d|와 |curi|를 되살리고 |curi|를 늘린다@>@;
if curi >= d {
	goto backup
}
@<이 수준에서 한 나머지 변경을 되돌린다@>@;
if level != 0 {
	if sanityChecking {
		sanity()
	}
	goto tryMove
}
@<뿌리 수준에서 나아간다@>@;

@ 수준 하나를 새로 열 때마다 탐색 나무의 마디를 하나 지난 셈이다. 그 수를 세고,
가장 깊이 내려간 자리를 적어 두고, 옆모습을 부탁받았으면 그것도 채운다.

@<수준 하나를 새로 연다@>=
nodes++
level++
if level > maxl {
	maxl = level
}
if vbose&showProfile != 0 {
	profile[level]++
}
if vbose&showDetails != 0 {
	fmt.Fprintf(os.Stderr, "수준 %d에 들어선다:\n", level)
}

@ 가지칠 마디 |curv|를 정했으면 그 마디에서 나가는 변 하나를 고를 차례다. 변의
한쪽 끝은 이미 |curv|로 정해졌으니 |e[eptr].u|에 적어 두고, |curv|를 안쪽으로
올린 다음, 되돌아올 자리를 적어 둔다.

@<가지칠 마디를 안쪽으로 올리고 상태를 적어 둔다@>=
e[eptr].u = curv // 배열 |e|에는 mem을 매기지 않는다
mems++
trigptr = nd[level-1].t
@<|curv|를 바깥에서 안쪽으로 올린다@>@;
if sanityChecking {
	sanity()
}
curi = 0
@<나중에 되추적하려고 지금 상태를 적어 둔다@>@;

@ 뿌리보다 더 물러날 곳은 없다. 그러면 볼일이 끝난 것이다.

@<한 수준 물러난다@>=
level--
if level < 0 {
	goto done
}
if vbose&showDetails != 0 {
	fmt.Fprintf(os.Stderr, "수준 %d까지 되돌아간다\n", level)
}

@ 여기가 어떤 변을 회로에 반드시 넣도록 강요하는 자리다. 차수가 $2$인 맨몸 마디가
방아쇠 목록에 올라와 있기 때문이다. 목록을 헤쳐 나가는 사이에 형편이 바뀔 수도
있다. 맨몸이던 마디가 그새 활성이 되었을지 모른다.

실은 맨몸 마디 하나에 옷을 입히면 잔물결이 일어 다른 맨몸 마디들이 방아쇠 목록에
새로 들어오기도 한다. 그러니 아래 반복문에서 |trigptr|은 움직이는 과녁이다.

한 가지 경우만은 조심스럽게 다뤄야 한다. 마디 |v|의 이웃 둘이 서로 짝이라면 우리는
회로 하나를 완성하도록 강요당한다. 그것이 옳은 일이려면 그 회로가 모든 마디를
품어야 한다.

이 반복문이 끝나면 남은 맨몸 마디의 차수는 모두 $3$ 이상이다.

@<방아쇠 목록에 있는 것들에 옷을 입힌다@>=
mems++
j = 0
if level != 0 {
	j = nd[level-1].t
}
for ; j < trigptr; j++ {
	@<방아쇠 |trigger[j]|를 살펴 옷을 입힌다@>@;
}

@ 짧은 회로가 강요되거나 차수가 모자라면 이 가지는 죽었다. 그러면 |tryAgain|으로
뛰어 다음 갈래를 본다.

@<방아쇠 |trigger[j]|를 살펴 옷을 입힌다@>=
mems++
v = trigger[j]
mems++
if vrt[v].m >= 0 {
	continue // 마디 |v|는 이제 맨몸이 아니다
}
if vrt[v].d < 2 {
	if vbose&showDetails != 0 {
		fmt.Fprintf(os.Stderr, "이런, %s의 차수가 모자란다\n", name(v))
	}
	goto tryAgain
}
mems += 3
u, w = nbr[v][0], nbr[v][1]
mems++
if vrt[u].m == w && eptr != nn-2 {
	if vbose&showDetails != 0 {
		fmt.Fprintf(os.Stderr, "이런, 짧은 회로가 강요된다: %s--%s--%s--...%s\n",
			name(u), name(v), name(w), name(u))
	}
	goto tryAgain
}
@<변 $u\adj v$와 $v\adj w$를 골라 |v|에 옷을 입힌다@>@;

@ 이제 마디 |v|는 맨몸이고 서로 짝이 아닌 |u|와 |w|에만 이어져 있다. 그러니 변
둘을 고른 뒤에 |u|와 |w|가 각각 맨몸(B)이었는지 바깥(O)이었는지에 따라 네 갈래로
갈린다.

@<변 $u\adj v$와 $v\adj w$를 골라 |v|에 옷을 입힌다@>=
e[eptr].u, e[eptr].v = u, v
eptr++
vprint()
e[eptr].u, e[eptr].v = v, w
eptr++
vprint()
mems++
vrt[v].m = v
makeinner(v)
mems++
if vrt[u].m < 0 {
	mems++
	if vrt[w].m < 0 {
		@<BBB를 OIO로 올린다@>@;
	} else {
		@<BBO를 OII로 올린다@>@;
	}
} else {
	mems++
	if vrt[w].m < 0 {
		@<OBB를 IIO로 올린다@>@;
	} else {
		@<OBO를 III로 올린다@>@;
	}
}

@ @<함수들@>=
func vprint() {
	if vbose&showChoices != 0 {
		fmt.Fprintf(os.Stderr, "     %s--%s\n",
			name(e[eptr-1].u), name(e[eptr-1].v))
	}
}

@ 여기서 미묘한 점 하나를 짚어야겠다. 입력 그래프가 그냥 완전 그래프 $K_3$이라
하자. 마디는 $\{0,1,2\}$이고 변은 $0\adj 1\adj 2\adj 0$이다. 그러면 모든 마디가
곧바로 방아쇠 목록에 오른다. 첫 승격 |trigger[0]=0|은 강요된 변 $1\adj 0$과
$0\adj 2$를 낳는다. 그러면 $1$과 $2$는 더는 맨몸이 아니니 아무것도 일으키지
못한다. 게다가 둘은 서로 짝이 되고, 둘 사이의 변은 (|makemates|가) 지워 버려
차수가 $0$이 된다! 그래도 탈이 없다. 변을 |nn-1|개 고른 뒤로는 알고리즘이 결코
가지를 치지 않기 때문이다.

@<BBB를 OIO로 올린다@>=
activate(u)
activate(w)
removeArc(u, v)
removeArc(w, v)
makemates(u, w)

@ @<함수들@>=
func makemates(u, w int) {
	mems += 3
	if adj[w][u] < vrt[w].d { // 마디 |u|는 |w|의 이웃이다
		removeArc(w, u)
		removeArc(u, w)
	}
	mems += 2
	vrt[u].m, vrt[w].m = w, u
}

@ 마디 |u|가 이미 바깥이라면 |u|는 안쪽이 되어 사라진다. 그러니 |u|에 닿아 있던
다른 호들을 모두 걷어내야 한다.

@<OBB를 IIO로 올린다@>=
activate(w)
removeArc(w, v)
mems += 2
for k = vrt[u].d - 1; k >= 0; k-- {
	mems++ // |nbr[u]|를 짚는 값은 위에서 이미 셌다
	t = nbr[u][k]
	if t != v {
		removex(t, u)
	}
}
mems++
makemates(vrt[u].m, w)
deactivate(u)

@ @<BBO를 OII로 올린다@>=
activate(u)
removeArc(u, v)
mems += 2
for k = vrt[w].d - 1; k >= 0; k-- {
	mems++ // |nbr[w]|를 짚는 값은 위에서 이미 셌다
	t = nbr[w][k]
	if t != v {
		removex(t, w)
	}
}
mems++
makemates(vrt[w].m, u)
deactivate(w)

@ 마지막 경우에는 |u|와 |w|가 둘 다 바깥 마디다. 우리는 |eptr=nn|일 때에 한해
둘이 서로 짝이 되도록 솜씨 좋게 꾸며 두었다. 그때는 해밀턴 회로의 변이 이미 모두
골라진 뒤다.

(이를테면 입력 그래프가 순환 그래프 $C_4$인 경우를 보자. 변은
$0\adj1\adj2\adj3\adj0$이다. 그러면 |trigger[0]=0|이 변 $1\adj0$과 $0\adj3$을
고른다. |trigger[1]=1|은 $1$이 더는 맨몸이 아니므로 아무것도 하지 않는다. 그다음
|trigger[2]=2|가 바라던 대로 변 $1\adj2$와 $2\adj3$을 고른다. $1$과 $3$이 서로
짝인데도 그렇다. 뒤따르는 |trigger[3]=3|은 또 아무것도 하지 않는다.)

@<OBO를 III로 올린다@>=
if eptr != nn {
	mems += 2
	for k = vrt[u].d - 1; k >= 0; k-- {
		mems++
		t = nbr[u][k]
		if t != v {
			removex(t, u)
		}
	}
	mems += 2
	for k = vrt[w].d - 1; k >= 0; k-- {
		mems++
		t = nbr[w][k]
		if t != v {
			removex(t, w)
		}
	}
	mems += 2
	makemates(vrt[u].m, vrt[w].m)
	deactivate(u)
	deactivate(w)
}

@ 가지를 칠 마디로는 차수가 가장 작은 바깥 마디를 고른다. {\mc MRV} heuristic이다.

@<차수가 가장 작은 바깥 마디를 |curv|로 잡는다@>=
mems += 2
curv = act[head].rlink
k = curv
d = vrt[curv].d
for ; k != head; mems, k = mems+1, act[k].rlink {
	if vbose&showDetails != 0 {
		fmt.Fprintf(os.Stderr, " %s(%d)", name(k), vrt[k].d)
	}
	mems++
	if vrt[k].d < d {
		curv, d = k, vrt[k].d
	}
}
if vbose&showDetails != 0 {
	fmt.Fprintf(os.Stderr, ", %s(%d)에서 가지를 친다\n", name(curv), d)
}

@ 마디 |curv|의 이웃 |d|개는 |curv|의 목록에 그대로 남는다. 하지만 |curv|는
{\it 그들의\/} 목록에서 지워진다.

@<|curv|를 바깥에서 안쪽으로 올린다@>=
mems++
for k = 0; k < d; k++ {
	mems++ // |nbr[curv]|를 짚는 값은 위에서 이미 셌다
	u = nbr[curv][k]
	removex(u, curv)
}
deactivate(curv)

@ @<|curv|에서 |nbr[curv][curi]|로 가는 변을 고른다@>=
mems++
curu = nbr[curv][curi]
mems++
curw = vrt[curv].m
e[eptr].v = curu
eptr++
if vbose&showChoices != 0 {
	fmt.Fprintf(os.Stderr, "%3d: %s--%s (%d개 중 %d번째)\n",
		level, name(e[eptr-1].u), name(e[eptr-1].v), d, curi+1)
}
mems++
curt = vrt[curu].m
if curt < 0 { // 마디 |curu|는 맨몸이다
	makemates(curu, curw)
	activate(curu)
} else { // 마디 |curu|는 바깥이다
	makemates(curt, curw)
	mems += 2
	for k = vrt[curu].d - 1; k >= 0; k-- {
		mems++
		u = nbr[curu][k]
		removex(u, curu)
	}
	deactivate(curu)
}

@* 되추적하기.
탐색 나무를 헤매다 보면 아직 가 보지 않은 갈래로 되돌아가고 싶을 때가 잦다.

원본에서는 |nd[level].v|와 |nd[level].m|을 함께 짚는 데 mem 하나면 된다. 서른두
자리 \&{int} 둘이 같은 예순네 자리 낱말에 들어앉기 때문이다. 다른 짝들도 마찬가지다.

(mem 세기에 관한 덧붙임. $d=1$일 때 |m| 자리를 적어 두어야 하는 까닭은 오로지
|printState|가 그것을 들여다보기 때문이다. 그러니 그 값을 매기는 것은 $d>1$일
때뿐이다.)

@<나중에 되추적하려고 지금 상태를 적어 둔다@>=
mems++
nd[level].d, nd[level].i = d, curi
mems++
nd[level].s, nd[level].t = visible, trigptr
nd[level].v, nd[level].m = curv, eptr
if d > 1 {
	mems++ // |nd[level].m|을 적어 두는 값. 위를 보라
	@<보이는 마디와 활성 마디를 스택에 쌓는다@>@;
}
mems++
nd[level].a = actptr

@ @<보이는 마디와 활성 마디를 스택에 쌓는다@>=
saveptr = level * nn
for k = 0; k < visible; k++ {
	mems++
	u = vis[k]
	mems += 2
	savestack[saveptr+u] = vrt[u]
}
mems++
for u = act[head].rlink; u != head; mems, u = mems+1, act[u].rlink {
	actstack[actptr] = u
	actptr++
}

@ Peter Weigel이 일러 준 대로, 여기서는 가장 요긴한 상태 변수 둘만 먼저 되살린다.
그 둘이 나머지는 되살릴 것도 없다고 말해 줄지 모르기 때문이다.

@<|d|와 |curi|를 되살리고 |curi|를 늘린다@>=
mems++
d = nd[level].d
curi = nd[level].i + 1
if curi < d {
	mems++
	nd[level].i = curi
}

@ @<이 수준에서 한 나머지 변경을 되돌린다@>=
mems++
actptr = nd[level].a
v = head
k = 0
if level != 0 {
	mems++
	k = nd[level-1].a
}
for ; k < actptr; k++ {
	mems++
	u = actstack[k]
	mems += 2
	act[v].rlink, act[u].llink = u, v
	v = u
}
mems += 2
act[v].rlink, act[head].llink = head, v
mems++
visible, trigptr = nd[level].s, nd[level].t
@<보이는 마디들의 짝과 차수를 되살린다@>@;
mems++
curv, eptr = nd[level].v, nd[level].m

@ @<보이는 마디들의 짝과 차수를 되살린다@>=
saveptr = level * nn
for k = 0; k < visible; k++ {
	mems++
	u = vis[k]
	mems += 2
	vrt[u] = savestack[saveptr+u]
}

@* 열매 거두기.
모든 마디가 이어지고 나면 더 고를 것이 없다. 그런 경우는 대개 옳은 해밀턴 회로를
찾은 것인데, 마지막 연결 하나는 아직 채워 넣어야 할 때가 많다.

이 자리에서 활성 마디는 정확히 둘이어야 한다.

@<해인지 살펴보고 |backup|으로 간다@>=
if eptr < nn {
	@<바깥 마디 둘이 이웃이 아니면 |backup|으로 간다@>@;
	e[eptr].u, e[eptr].v = act[head].llink, act[head].rlink
	eptr++
	vprint()
}
count++
if spacing != 0 && count%spacing == 0 {
	@<이 해를 찍는다@>@;
}
if count >= maxcount {
	goto done
}
goto backup

@ 이 자리에서 우리는 해밀턴 {\it 경로\/} 하나를 이룬 셈이다. 그것이 해밀턴 회로가
되려면 두 바깥 마디가 서로 이웃이어야 하고, 그것으로 충분하다.

@<바깥 마디 둘이 이웃이 아니면 |backup|으로 간다@>=
mems++
u, v = act[head].llink, act[head].rlink
mems += 2
if adj[u][v] == infty {
	goto backup
}

@ @<이 해를 찍는다@>=
nd[level].i, nd[level].d = 0, 1
nd[level].m = eptr
if vbose&showRawSols != 0 {
	fmt.Printf("\n%d:\n", count)
	printState(os.Stdout)
} else {
	@<지금 해를 풀어서 찍는다@>@;
}

@ 배열 |e|에 쌓인 변들은 골라진 차례대로 있을 뿐, 회로를 도는 차례가 아니다.
그래서 마디마다 이웃 둘을 |v1|과 |v2|에 모아 두고, 마디 $0$에서 출발해 회로를
한 바퀴 따라간다.

@<지금 해를 풀어서 찍는다@>=
{
	for k := 0; k < nn; k++ {
		v1[k] = -1
	}
	for k := 0; k < nn; k++ {
		x, y := e[k].u, e[k].v
		@<마디 |x|와 |y|를 서로의 이웃으로 적는다@>@;
	}
	path[0], path[1] = 0, v1[0]
	for k := 2; ; k++ {
		if v1[path[k-1]] == path[k-2] {
			path[k] = v2[path[k-1]]
		} else {
			path[k] = v1[path[k-1]]
		}
		if path[k] == 0 {
			break
		}
	}
	for k := 0; k <= nn; k++ {
		fmt.Printf("%s ", name(path[k]))
	}
	fmt.Printf("#%d\n", count)
}

@ @<마디 |x|와 |y|를 서로의 이웃으로 적는다@>=
if v1[x] < 0 {
	v1[x] = y
} else {
	v2[x] = y
}
if v1[y] < 0 {
	v1[y] = x
} else {
	v2[y] = x
}

@ @<전역 변수@>=
var (
	v1, v2 [maxn]int    // 어떤 마디의 이웃 둘
	path   [maxn + 1]int // 해밀턴 회로를 도는 차례
)

@ 탐색 나무 안에서 우리가 어디까지 왔는지를 통째로 찍는 함수다. 수준마다 한 줄씩
내는데, 그 수준에서 강요되어 딸려 온 변들을 먼저 들여쓰고 그다음에 고른 변을 적는다.

@<함수들@>=
func printState(f io.Writer) {
	for j, l := 0, 0; l <= level; j, l = j+1, l+1 {
		for j < nd[l].m {
			fmt.Fprintf(f, "      %s--%s\n", name(e[j].u), name(e[j].v))
			j++
		}
		if l == 0 {
			@<뿌리 수준의 상태 줄을 찍고 |j|를 되돌린다@>@;
		} else if j < nn {
			@<수준 |l|의 상태 줄을 찍는다@>@;
		}
	}
}

@ @<수준 |l|의 상태 줄을 찍는다@>=
kl := 1
if nd[l].d != 1 {
	kl = nd[l].i + 1
}
fmt.Fprintf(f, " %3d: %s--%s (%d개 중 %d번째)\n",
	l, name(e[j].u), name(e[j].v), nd[l].d, kl)

@ 뿌리 수준의 |nd[0].v|가 음수라면, 그 수준은 첫 변들을 방아쇠 목록에서 받아
시작한 것이므로 ``고른'' 변이 없다.

@<뿌리 수준의 상태 줄을 찍고 |j|를 되돌린다@>=
if nd[0].v >= 0 || nd[0].d > 1 {
	fmt.Fprintf(f, "   0: (%d개 중 %d번째)\n", nd[0].d, nd[0].i+1)
}
j-- // 반복문의 |j++|를 메워 준다

@* 판 벌이기.
프로그램은 거의 다 되었다. 그런데 되추적 수준 $0$에서 판을 제대로 벌여 공을
굴리기 시작하는 방법을 아직 정하지 않았다.

차수가 $2$인 마디가 그래프에 하나라도 있으면 걱정할 것이 없다. 그런 경우에는
|trigger| 목록이 활성 마디를 둘 넘게 마련해 준다. 하지만 모든 마디의 차수가 $3$
이상이라면 나머지 계산의 씨앗이 될 바깥 마디를 우리 손으로 마련해야 한다.

앞의 (쉬운) 경우에는 |curv|를 $-1$로 둔다. 뒤의 경우에는 차수가 가장 작은 마디
|curv|를 잡고 그 이웃을 하나씩 시험한다. (더 정확히 말하면, |curv|에서 다른 마디
|u|로 가는 변을 품는 해밀턴 회로를 모두 찾고 나면 그 변을 그래프에서 아주
지워 버리고, |curv|든 다른 마디든 이웃이 둘만 남을 때까지 이 일을 되풀이한다.)

@ 원본에서는 표찰 |force|가 |else| 블록 안에 있다. \GO/는 블록 안으로 뛰어들 수
없으니 표찰 |record| 하나를 더 두어 같은 흐름을 만든다.

@<되추적을 띄운다@>=
level = 0
d = mind - 1
if d == 1 {
	curv = -1
	goto record
}
curi = 0
force:
@<뿌리 수준에서 변 하나를 고른다@>@;
record:
@<나중에 되추적하려고 지금 상태를 적어 둔다@>@;

@ @<뿌리 수준에서 변 하나를 고른다@>=
mems += 2
curu = nbr[curv][d-curi]
e[0].u, e[0].v = curv, curu
eptr = 1
if vbose&showChoices != 0 {
	fmt.Fprintf(os.Stderr, "  0: %s--%s (%d개 중 %d번째)\n",
		name(e[0].u), name(e[0].v), d, curi+1)
}
activate(curu)
activate(curv)
makemates(curu, curv)

@ 뿌리 수준으로 되돌아오면 모든 마디가 다시 맨몸이다. 뿌리 수준에서 앞서 시험한
변은 이제 그래프에 없으니, 그 변의 두 마디 가운데 하나 또는 둘의 차수가 $2$가
되었을 수 있다. 그런 경우에는 방아쇠 목록이 마지막 판을 끝낼 길을 마련해 준다.

@<뿌리 수준에서 나아간다@>=
mems++
curu = vrt[curv].m // 앞서 쓰던 변 |curv|--|curu|는 이제 사라졌다
mems++
act[head].llink, act[head].rlink = head, head // 활성인 것이 하나도 없다
actptr = 0
mems += 2
vrt[curu].m, vrt[curv].m = -1, -1 // 모두 맨몸이다
visible = nn
@<차수가 $2$가 된 마디를 방아쇠에 올린다@>@;
if trigptr == 0 {
	goto force
}
mems += 2
nd[0].v = -1
nd[0].a, eptr = 0, 0
if vbose&showChoices != 0 {
	fmt.Fprintf(os.Stderr, "  0: (%d개 중 %d번째)\n", d, curi+1)
}
goto advance

@ @<차수가 $2$가 된 마디를 방아쇠에 올린다@>=
trigptr = 0
if vrt[curu].d == 2 {
	trigger[0] = curu
	trigptr = 1
}
if vrt[curv].d == 2 {
	trigger[trigptr] = curv
	trigptr++
}

@* 진행 보고.
이 알고리즘이 일하는 모습을 지켜보는 것은 꽤 재미있다. 그래서 지켜볼 길을 몇 가지
마련해 두었다.

@<mem이 넉넉히 쌓였으면 특별한 일을 한다@>=
if delta != 0 && mems >= thresh {
	thresh += delta
	if vbose&showFullState != 0 {
		printState(os.Stderr)
	} else {
		@<진행 상황을 알린다@>@;
	}
}
if mems >= timeout {
	fmt.Fprintln(os.Stderr, "시간 초과!")
	goto done
}

@ 오래 도는 동안에는 얼마나 나아갔는지 가늠할 길이 있으면 도움이 된다. 아래는
탐색 나무 안의 우리 자리를 어림해 보이는 문자열을 찍는다. 문자열은 빈칸으로 나뉜
글자 쌍들로 이루어지고, 쌍 하나가 탐색 나무의 가지 하나를 나타낸다. 어떤 마디의
자손이 $d$개이고 우리가 그 가운데 $k$번째를 붙들고 있으면, 두 글자가 각각 $k$와
$d$를 간단한 부호로 나타낸다. 곧 값 $0$, $1$, \dots, $61$을
$$\.0,\ \.1,\ \dots,\ \.9,\ \.a,\ \.b,\ \dots,\ \.z,\ \.A,\ \.B,\ \dots,\.Z$$
로 적는다. $61$보다 큰 값은 모두 `\.*'로 보인다. 계산이 나아감에 따라 이 문자열이
사전순으로 커진다는 점을 눈여겨보라.

그 문자열에 이어, 전체 진행의 어림값을 분수로 셈해 붙인다. 탐색 나무의 가지 뻗음이
고르다는 na\"\i ve한 가정에 기댄 값이다. 나무가 마디 하나뿐이면 어림값은 $.5$이고,
그렇지 않고 첫 선택이 `$d$개 중 $k$번째'이면 $(k-1)/d$에 $1/d$ 곱하기 $k$번째
부분나무의 어림값(되돌이로 셈한다)을 더한 값이다. (이 어림은 경우에 따라 크게
어긋날 수 있지만, 적어도 단조롭게 자라는 편이다.)

@<진행 상황을 알린다@>=
{
	fmt.Fprintf(os.Stderr, " %d mem 뒤: 해 %d개,", mems, count)
	f, fd := 0.0, 1.0
	for l := 0; l < level; l++ {
		dl := nd[l].d
		kl := 1
		if dl != 1 {
			kl = nd[l].i + 1
		}
		fd *= float64(dl)
		f += float64(kl-1) / fd // 수준 |l|의 선택은 $d$개 중 $k$번째다
		fmt.Fprintf(os.Stderr, " %c%c", digit(kl), digit(dl))
	}
	fmt.Fprintf(os.Stderr, " %.5f\n", f+0.5/fd)
}

@ @<함수들@>=
func digit(k int) byte {
	switch {
	case k < 10:
		return byte('0' + k)
	case k < 36:
		return byte('a' + k - 10)
	case k < 62:
		return byte('A' + k - 36)
	}
	return '*'
}

@* 맞춰 보기.
입력이 될 \.{.gb} 파일은 \.{SGB}의 그래프 생성기로 짓는다. go-sgb에도 같은
생성기와 |gbsave.SaveGraph|가 있어서, 이를테면
$$\hbox{|g, _ := gbbasic.Board(6, 6, 0, 0, 5, 0, false)|}$$
로 $6\times6$ 판의 기사 그래프를 짓고 저장하면 크누스의 \CEE/ 판이 뱉는 파일과
바이트 하나까지 똑같은 것이 나온다. 그 그래프의 답은 $9862$인데, $6\times6$ 판
닫힌 기사 순회의 수로 이미 알려진 값이다.

@ 크누스의 \CEE/ 원본을 함께 세워 놓고 견주었다. 마디 $6$개에서 $14$개까지의
무작위 그래프 $60$개에 $C_4$와 왕 그래프, 기사 그래프 둘을 더한 $64$개를, 선택항
조합 $13$가지로 돌렸다. 모두 $845$번을 견주었고 어긋난 곳은 하나도 없었다. 찾은
해도, 찍히는 차례도, 수다스러운 되추적 기록도, 옆모습도, 진행 보고의 문자열과
어림값도, 그리고 mem 수도 모두 같았다. 이를테면 $6\times6$ 기사 그래프는 양쪽 모두
$2265+4671495$ mem이다.

무작위로 흩는 \.s 선택항까지 맞다. go-sgb의 |gbflip|이 \.{SGB}의 |gb_flip|과 같은
수열을 내주기 때문이다. 씨앗이 같으면 마디 번호도 이웃 목록도 똑같이 흩어지고,
그래서 mem 수까지 나란하다.

@ 원본과 다른 곳이 네 군데 있다. 모두 알고리즘이 아니라 언어에서 온 것이다.

첫째, 표찰 |record|를 하나 더 두었다. \GO/는 블록 안으로 뛰어들 수 없기 때문인데,
앞에서 이미 말했다.

둘째, 그만둘 때의 종료 부호를 양수로 바꾸었다. 원본은 |exit(-44)|처럼 음수를 쓰지만
\GO/에서는 $0$과 $125$ 사이를 권한다. 그래서 $44$, $4$, $5$, $2$, $1$을 쓴다.

셋째, 원본의 |confusion| 함수를 옮기지 않았다. 크누스가 ``결코 불리지 않기를 바라는
함수''라고 적어 둔 그대로 어디에서도 부르지 않으니, \GO/에서라면 그런 자리는
|panic|이 맡을 몫이다.

넷째, 선택항을 새기는 눈이 조금 더 매섭다. \CEE/의 |sscanf|는 \.{t100x}에서
$100$만 떼어 가고 뒤의 찌꺼기를 눈감아 주지만, |strconv.Atoi|는 그것을 잘못된
입력으로 물리친다.

@* 색인.
