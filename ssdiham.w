\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\adj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-8mu\mathrel-\!}}
\def\dadj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-12mu\to\!}}
\def\losub#1{^{\vphantom+}_{#1}} % $x^+_n+x\losub n$ 같은 자리에 쓴다
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

\def\title{유향 해밀턴 회로}

@* 들어가며.
이 프로그램은 주어진 유향 그래프의 해밀턴 회로를 모두 찾는다. 쓰는 알고리즘이
재미있다. 회로를 이룰 변을 하나씩 골라 나가되, 고른 변이 최종 회로의 어느 자리에
놓일지는 모든 조각이 이어 붙기 전까지 모른다. 크누스는 무향 그래프를 다루는
{\mc SSHAM}을 바탕으로 이것을 지었다. 원본에는 이런 내력이 적혀 있다.

\medskip{\narrower\noindent
{\mc SSHAM}에서 말했듯 기본 착상은 Geoffrey Selby가 1970년에 내놓았다. Selby는
무향 그래프를 두고 설명했지만, 유향 그래프도 비슷하게 다룰 수 있다고 적었다. 그렇게
고쳐 쓴 것은 그의 지도교수 Nicos Christofides로, 그의 책 {\sl Graph Theory\/}(1975)의
10.2.3절에 있다. Silvano Martello는 1983년에 여기에 {\mc MRV} 가지치기 heuristic을
얹었다. 나는 2001년에 Selby의 방식을 따로 다시 찾아냈는데, 내 것은 조금 더
대칭적이다. 하지만 유향판은 이제야 구현했다.\par}\medskip

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{ssdiham.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/ssdiham.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Wed, 02 Apr 2025 09:24:18 GMT}다. 바탕이 된 {\mc SSHAM}도 이 저장소에
\.{ssham.w}로 옮겨 두었으니 함께 읽으면 좋다. 두 프로그램은 뼈대가 같고, 차이는
주로 유향 그래프를 무향 그래프로 바꾸는 한 수에 있다.

그래프는 \.{SGB} 형식의 파일로 읽어 들인다. 그 일은 \pdfURL{go-sgb}%
{https://github.com/sjnam/go-sgb}의 |gbsave.RestoreGraph|가 해 준다.

프로그램이 찍는 말과 종료 부호는 원본 그대로 두었다. 그래야 두 프로그램의 출력을
바이트 단위로 견줄 수 있다. 이 점은 말을 한글로 옮긴 \.{ssham.w}와 다르다.

@ 다른 프로그램들({\mc SSXCC} 따위)과 마찬가지로 이 프로그램도 실행 시간을
``mem'' 단위로 알린다. 여덟 바이트짜리 메모리 낱말을 읽거나 쓸 때마다 하나씩
세고, 이미 레지스터에 있는 자료를 다룰 때는 세지 않는다. (그래프를 읽어 들이거나
결과를 찍는 데 드는 일은 알리는 mem 수에 들어가지 않는다.)

\CEE/에서는 쉼표 연산자를 써서 |o,x=y[i]|처럼 셈과 계산을 한 줄에 얹는다.
\GO/에는 쉼표 연산자가 없으니, 값 하나를 셈하는 자리에서는 |mems++|를 앞에 붙이고,
반복문의 뒤처리처럼 식 자리에서 세야 할 때는 |mems, k = mems+1, act[k].rlink|라는
여럿 대입을 쓴다. 그래서 mem 수가 원본과 한 자리도 다르지 않다.

@ 뼈대는 짧다. 명령줄을 읽고, 그래프를 준비하고, 되추적하고, 알린다.

원본은 |goto|를 아낌없이 쓴다. \GO/의 |goto|는 새 변수가 눈에 들어오는 자리로는
뛰지 못하므로, |main|의 지역 변수는 원본처럼 모두 맨 앞에서 선언한다.

@c
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
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
	var i, j, k, d, t, u, v, w int
	@<명령줄을 처리하고 그래프를 읽어 들인다@>@;
	@<그래프를 되추적에 맞게 준비한다@>@;
	imems, mems = mems, 0
	@<모든 해를 되추적으로 훑는다@>@;
done:
	@<결과를 알린다@>@;
	out.Flush()
	os.Exit(0)
}

@ 유향 그래프의 마디는 많아야 |maxn|개다. 안에서는 마디 하나를 둘로 쪼개 쓰므로
배열은 대개 |2*maxn|칸이다.

@<상수@>=
const (
	maxn  = 1000     // 유향 그래프의 마디는 많아야 이만큼
	infty = 2 * maxn // 우리 그래프의 어떤 마디 번호보다도 크다
)

@ 해와 탐색 나무의 크기와 mem 수를 담는 것들은 원본에서 |unsigned long long|이다.
이 판도 |uint64|로 둔다. 이를테면 원본은 선택항 \.{t-1}을 $2^{64}-1$로 읽는데, 그런
것까지 같게 하려면 부호가 없어야 한다.

@<전역 변수@>=
var (
	g     *gbgraph.Graph // 주어진 그래프
	mems  uint64         // 메모리를 짚은 횟수
	imems uint64         // 그 가운데 그래프를 준비하는 데 든 것
	rmems uint64         // 무작위로 섞을 때만 세는 것
)

@ 해는 표준 출력으로 찍는다. 해가 많을 수 있으니 버퍼에 모았다가, 원본이
|fflush(stdout)|를 하는 자리마다 비운다.

@<전역 변수@>=
var out = bufio.NewWriter(os.Stdout) // 해를 찍을 버퍼

@* 명령줄.
명령줄 첫머리에는 그래프 이름이 온다. 파일 \.{foo.gb}처럼 \.{SGB} 형식으로 담긴
파일이다. 그 뒤로는 해를 얼마나 찍을지, 진단 정보를 얼마나 낼지를 고르는 선택항이
따라올 수 있다.

쓸 수 있는 선택항은 이렇다.
\smallskip
\item{$\bullet$}
`\.v$\langle\,$정수$\,\rangle$'는 |showChoices| 따위의 이진 부호를 더한 값으로,
표준 오류에 낼 여러 가지 수다스러운 출력을 켜고 끈다.
\item{$\bullet$}
`\.m$\langle\,$정수$\,\rangle$'는 해를 $m$개마다 하나씩 찍게 한다.
(기본값 \.{m0}은 세기만 한다.)
\item{$\bullet$}
`\.s$\langle\,$정수$\,\rangle$'는 입력 그래프의 자료를 무작위로 흩는다.
(해가 고르게 무작위로 나온다는 뜻은 결코 아니고, 그저 다른 차례를 맛보게 해 준다.)
\item{$\bullet$}
`\.d$\langle\,$정수$\,\rangle$'는 |delta|를 정한다. 앞선 보고 뒤로 mem이 대략
|delta|만큼 쌓일 때마다 표준 오류에 진행 상황을 알린다. (기본값 $10^{10}$)
\item{$\bullet$}
`\.t$\langle\,$양의 정수$\,\rangle$'는 해를 이만큼 찾으면 멈추게 한다.
\item{$\bullet$}
`\.T$\langle\,$정수$\,\rangle$'는 |timeout|을 정한다. 어떤 수준에 들어설 때
|mems > timeout|이면 그 자리에서 그만둔다.

@ @<상수@>=
const (
	showBasics    = 1   // 기본 통계; 이것이 기본값이다
	showChoices   = 2   // 되추적 기록
	showDetails   = 4   // 더 자세한 설명
	showRawSols   = 64  // 해를 변이 더해진 차례대로 보인다
	showProfile   = 128 // 탐색 나무의 옆모습
	showFullState = 256 // 완전한 상태 보고
)

@ @<전역 변수@>=
var (
	randomSeed  int        // |gbflip|의 씨앗
	randomizing bool       // 선택항 `\.s'가 주어졌나?
	rng         *gbflip.RNG // 흩을 때 쓰는 난수 발생기
	vbose       = showBasics // 수다스러움의 정도
	spacing     int          // $k$가 |spacing|의 배수일 때 $k$번째 해를 찍는다
	maxl        int          // 실제로 다다른 가장 깊은 수준
	count       uint64       // 지금까지 찾은 해
	delta       uint64 = 10000000000 // 이만큼 mem이 쌓일 때마다 알린다
	thresh      uint64 = 10000000000 // |mems|가 이를 넘으면 알린다
	maxcount    uint64 = 0xffffffffffffffff // 해를 이만큼 찾으면 멈춘다
	timeout     uint64 = 0x1fffffffffffffff // mem이 이만큼 들면 포기한다
	nodes       uint64          // 탐색 나무의 크기
	profile     [maxn + 1]uint64 // 탐색 나무의 수준마다 마디가 몇인가
	nn          int             // 주어진 그래프의 마디 수
	mind        int             // 주어진 그래프의 가장 작은 들어오는 차수나 나가는 차수
)

@ 같은 선택항이 여러 번 나오면 맨 앞의 것이 이긴다. 명령줄을 뒤에서 앞으로 훑기
때문이다.

원본은 |sscanf|로 수를 새기고, 새기지 못하면 |k|에 $0$ 아닌 값을 남긴다. \GO/의
|fmt.Sscanf|도 앞의 빈칸을 건너뛰고 수 뒤의 찌꺼기는 따지지 않으니, \.{t100x}를
$100$으로 읽는 것까지 원본과 같다. 이 점도 |strconv.Atoi|를 쓴 \.{ssham.w}와 다르다.

@<명령줄을 처리하고 그래프를 읽어 들인다@>=
@<선택항을 훑는다@>@;
if len(os.Args) < 2 {
	k = 1
}
if k == 0 {
	@<그래프 파일을 읽어 들인다@>@;
}
if k != 0 {
	fmt.Fprintf(os.Stderr,
		"Usage: %s foo.gb [v<n>] [m<n>] [s<n>] [d<n>] [t<n>] [T<n>]\n",
		os.Args[0])
	os.Exit(-1)
}
if randomizing {
	rng = gbflip.New(int64(randomSeed))
}

@ 선택항 하나를 새기지 못하거나 알아볼 수 없는 글자로 시작하면 |k|를 $0$ 아닌 값으로
둔다. 빈 인자도 원본에서는 첫 글자가 |'\0'|이라 알아볼 수 없는 선택항이 된다.

@<선택항을 훑는다@>=
for j, k = len(os.Args)-1, 0; j > 1; j-- {
	arg := os.Args[j]
	if arg == "" {
		k = 1
		continue
	}
	switch arg[0] {
	case 'v':
		k |= scanInt(arg[1:], &vbose)
	case 'm':
		k |= scanInt(arg[1:], &spacing)
	case 's':
		k |= scanInt(arg[1:], &randomSeed)
		randomizing = true
	case 'd':
		k |= scanUint(arg[1:], &delta)
		thresh = delta
	case 't':
		k |= scanUint(arg[1:], &maxcount)
	case 'T':
		k |= scanUint(arg[1:], &timeout)
	default:
		k = 1 // 알아볼 수 없는 선택항이다
	}
}

@ 수를 새기는 도우미 둘이다. 새기지 못하면 $1$을 돌려준다. 원본의 |%lld|는 부호
있는 수를 새겨 부호 없는 변수에 넣으므로, 둘째 도우미도 |int64|로 새긴 다음
|uint64|로 바꾼다.

@<함수들@>=
func scanInt(s string, p *int) int {
	if n, _ := fmt.Sscanf(s, "%d", p); n != 1 {
		return 1
	}
	return 0
}

func scanUint(s string, p *uint64) int {
	var x int64
	if n, _ := fmt.Sscanf(s, "%d", &x); n != 1 {
		return 1
	}
	*p = uint64(x)
	return 0
}

@ @<그래프 파일을 읽어 들인다@>=
var err error
if g, err = gbsave.RestoreGraph(os.Args[1]); err != nil {
	fmt.Fprintf(os.Stderr, "I couldn't reconstruct graph %s!\n", os.Args[1])
	k = 1
} else {
	nn = int(g.N)
	if nn > maxn {
		fmt.Fprintf(os.Stderr, "Sorry, graph %s has too many vertices (%d>%d)!\n",
			os.Args[1], nn, maxn)
		os.Exit(-2)
	}
}

@ 결과는 이렇게 알린다.

@<결과를 알린다@>=
if vbose&showProfile != 0 {
	@<옆모습을 찍는다@>@;
}
if vbose&showBasics != 0 {
	s := "s"
	if count == 1 {
		s = ""
	}
	fmt.Fprintf(os.Stderr, "Altogether %d solution%s, %d nodes,", count, s, nodes)
	fmt.Fprintf(os.Stderr, " %d+%d mems.\n", imems, mems)
}

@ 잘못된 추론을 잡아내려고, 결코 불리지 않기를 바라는 함수 하나를 둔다. 원본의
|exit|는 표준 출력의 버퍼를 비우고 끝나니 여기서도 비운다.

@<함수들@>=
func confusion(m string) {
	out.Flush()
	fmt.Fprintf(os.Stderr, "This can't happen: %s!\n", m)
	os.Exit(666)
}

@* 자료구조.
이 프로그램은 유향 그래프 |g|에서 출발해 방향이 있는 회로 하나만 남을 때까지 호를
걷어내는 알고리즘이라고 볼 수 있다.

1972년에 R. M. Karp는 어떤 유향 그래프 $D$든 해밀턴 회로의 수가 똑같은 무향 그래프
$G$로 바꾸는 간단한 방법을 고안했다. 유향 그래프 $D$의 마디 $v$ 하나는 $G$의 마디
셋 $\{v^-,v,v^+\}$가 되고, $D$의 호 $u\dadj v$ 하나는 $G$의 변 $u^-\adj v^+$가
된다. 또 $D$의 마디 $v$마다 $G$에는 변 둘 $v^-\adj v\adj v^+$가 있다. 그러면 $D$에
방향이 있는 회로 $v_0\dadj v_1\dadj\cdots\dadj v_n=v_0$이 있는 것과 $G$에 회로
$$v_0^+\adj v\losub0\adj v_0^-\adj v_1^+\adj v\losub1\adj v_1^-\adj \cdots\adj
v_n^+=v_0^+$$
가 있는 것은 같은 말이다.

@ 이 바꿈을 쓰면 {\mc SSDIHAM}이 맞닥뜨린 유향 그래프 문제를 {\mc SSHAM}이 이미
푼 무향 그래프 문제로 돌릴 수 있다. 하지만 더 잘할 수 있다. 첫째, 마디 $v$는 필요
없고 $v^-$와 $v^+$만 있으면 된다. 둘째, 남은 그래프에서 $u^-$나 $v^+$의 차수가
$1$이면 호 $u\dadj v$, 곧 변 $u^-\adj v^+$를 회로에 반드시 넣게 할 수 있다.

그래서 사용자의 $n$마디 유향 그래프를 계산하는 동안 $2n$마디 무향 그래프 |g|로
여긴다. 이 |g|는 이분 그래프이고, 두 쪽에 마디가 $n$개씩 있다. 우리 목표는 |g|의
완전 매칭 가운데, 있지 않은 변 $n$개 $v^-\adj v^+$를 보태면 회로 하나가 되는 것을
모두 찾는 것이다.

$$\mplibcode
beginfig(1);
  u := 9mm;
  for k = 0 upto 2:
    z[k] = (0, -k*u); z[k+3] = (2.2u, -k*u);
    draw z[k] -- z[k+3] dashed evenly withpen pencircle scaled .4pt;
  endfor
  draw z0 -- z4 withpen pencircle scaled 1pt;
  draw z1 -- z5 withpen pencircle scaled 1pt;
  draw z2 -- z3 withpen pencircle scaled 1pt;
  draw z0 -- z5 withpen pencircle scaled .4pt;
  for k = 0 upto 5: fill fullcircle scaled 3.5pt shifted z[k]; endfor
  label.lft(btex $0^-$ etex, z0); label.lft(btex $1^-$ etex, z1);
  label.lft(btex $2^-$ etex, z2);
  label.rt(btex $0^+$ etex, z3); label.rt(btex $1^+$ etex, z4);
  label.rt(btex $2^+$ etex, z5);
  z10 = (-5u, .1u); z11 = (-6.3u, -2.1u); z12 = (-3.7u, -2.1u);
  def arc(expr p, a, b) =
    drawarrow p cutbefore fullcircle scaled 9pt shifted a
      cutafter fullcircle scaled 9pt shifted b
  enddef;
  arc(z10 -- z11, z10, z11);
  arc(z11 -- z12, z11, z12);
  arc(z12 -- z10, z12, z10);
  arc(z10 {dir 0} .. {dir -95} z12, z10, z12) withpen pencircle scaled .4pt;
  label(btex $0$ etex, z10); label(btex $1$ etex, z11); label(btex $2$ etex, z12);
endfig;
\endmplibcode$$
\figcap{왼쪽은 마디 셋에 호 넷인 유향 그래프이고 오른쪽은 그것을 나타내는 |g|다.
호 $u\dadj v$는 변 $u^-\adj v^+$가 된다. 굵은 변 셋은 완전 매칭이고, 점선 셋
$v^-\adj v^+$를 보태면 회로 하나가 되니 해밀턴 회로 $0\dadj1\dadj2\dadj0$에
맞선다. 가는 변 $0^-\adj2^+$는 호 $0\dadj2$다.}

@ 그래프 |g|는 성긴 집합으로 나타낸다. 자꾸만 작아지는 그래프의 지금 모습을
간수하는 데 이만한 것이 없다. 착상은 이렇다. 배열 둘 |nbr|과 |adj|를 두고, 마디
|v|마다 한 줄씩 준다. 마디 |v|의 이웃이 |g| 안에 |d|개라면, 그 이웃들은 |nbr[v]|의
앞쪽 |d|칸에 (아무 차례로나) 늘어선다. 그리고 |nbr[v][k]=u|이고 $0\le k<d$이면
|adj[v][u]=k|다. 곧 이런 붙박이 관계가 있다.
$$\hbox{|nbr[v][adj[v][u]] = u|}$$
이웃을 지우려면 오른쪽으로 밀고 |d|를 줄이면 되고, 되살리려면 |d|를 늘리기만 하면
된다. 게다가 |u|가 |v|의 이웃이 아니면 |adj[v][u]|는 있을 수 없는 값 |infty|를
지닌다. 그러니 |adj| 행렬은 인접 행렬 구실도 함께 한다.

마디 $v^-$와 $v^+$는 안에서 각각 정수 $2v$와 $2v+1$로 나타낸다. 여기서
$0\le v<|nn|$이다.

@<전역 변수@>=
var (
	nbr, adj [2 * maxn][2 * maxn]int // |g|를 성긴 집합으로 나타낸 것
	degree   [2 * maxn]int           // 우리 그래프에서의 차수 (진단할 때만 쓴다)
)

@ 그래프 |g|의 변은 서로 반대로 달리는 호 한 쌍으로 여긴다. (다시 말해 변
$u^-\adj v^+$는 실제로는 호 $u^-\dadj v^+$와 호 $v^+\dadj u^-$ 둘로 다룬다.) 변을
지울 때 둘 가운데 하나만 지워야 할 때가 잦다. 알고리즘이 둘 다에 매달리지는 않기
때문이다.

알고리즘은 쓸모없는 변을 걷어내기만 하는 것이 아니라 걷어내지 {\it 않을\/} 변을
고르기도 한다. 고른 변은 \&{edge} 구조체의 배열 |e|에 쌓인다. 구조체에는 마디 둘
|u|와 |v|가 들어 있다. 고른 변 가운데 $k$번째 것이 $u^-\adj v^+$이면, 어느 마디에서 가지를
쳤는지 또는 어느 마디가 방아쇠를 당겼는지에 따라 |e[k].u|${}=u^-$이고
|e[k].v|${}=v^+$이거나, |e[k].u|${}=v^+$이고 |e[k].v|${}=u^-$다.

@<자료형@>=
type edge struct {
	u, v int // 이 변이 잇는 마디 둘
}

@ @<전역 변수@>=
var (
	e    [maxn + 1]edge // 지금까지 고른 변들
	eptr int            // 지금까지 이만큼 골랐다
)

@ 고른 변들 가운데 극대인 부분경로
$$v_0^-\adj v_1^+,\ v_1^-\adj v_2^+, \ \ldots, \ v_{k-1}^-\adj v_k^+$$
가 있고 $v_0^+$와 $v_k^-$가 다른 어떤 고른 변에도 걸려 있지 않다면, $v_0^+$와
$v_k^-$를 ``바깥'' 마디라 부르고 $\{v_0^-,v_1^+,v_1^-,\ldots,v_{k-1}^-,v_k^+\}$를
``안쪽''이라 부른다. 바깥도 안쪽도 아닌 마디는 ``맨몸''이다. 모든 마디는 맨몸으로
태어나 언젠가 옷을 입는다. 끝에 가면 마지막으로 고른 변의 두 마디만 빼고 모두
안쪽이 되고, 고른 변들이 곧 해밀턴 회로가 된다.

알고리즘이 나아가는 동안 마디 |v|마다 정수 둘이 딸린다. 짝 |vrt[v].m|과 차수
|vrt[v].d|다. 위의 부분경로에서 $v_0^+$의 짝은 $v_k^-$이고 $v_k^-$의 짝은
$v_0^+$이다. 그 규칙이 모든 바깥 마디의 짝을 정한다. 맨몸인 마디의 짝은 $-1$이다.
안쪽 마디의 짝 값은 정해져 있지 않다. 다만 음수가 아니라는 것만은 확실하다.

마디 $v$가 바깥이거나 맨몸이면 |vrt[v].d|는 $v$에 닿아 있으면서 아직 고르지도
않았고 최종 경로에서 아직 배제되지도 않은 변의 수다. (마찬가지로 안쪽 마디의 차수는
정해져 있지 않다. 안쪽 마디는 알고리즘의 눈에 아예 보이지 않는다.)

두 값을 한꺼번에 짚을 수 있도록 \&{vert} 구조체 하나에 담아 둔다. 원본에서는
\.{mate(v)}와 \.{deg(v)}라는 매크로로 이 두 자리를 부른다.

@<자료형@>=
type vert struct {
	m, d int // 이 마디의 짝과 차수
}

@ 배열 |vrt|에는 한 칸을 더 둔다. 활성 리스트의 머리 |head|가 바로 그 번호이기
때문이다. 원본에서 활성 리스트가 비었을 때 |deg(head)|를 읽는 일은 생기지 않지만,
만에 하나 생겨도 \GO/가 범위 밖이라며 멈추지 않게 했다.

@<전역 변수@>=
var vrt [2*maxn + 1]vert

@ 원본의 디버깅 함수들은 마디 이름을 \.{a0-}처럼 찍는다. 원본에서는 |name(v)|가
|printf|의 인자 둘로 펼쳐지는 매크로다. 여기서는 문자열 하나를 돌려주는 함수로
둔다.

@<함수들@>=
func basename(v int) string { return g.Vertices[iperm[v]].Name }

func name(v int) string {
	if v&1 != 0 {
		return basename(v>>1) + "+"
	}
	return basename(v>>1) + "-"
}

@ 앞서 말했듯 안쪽 마디는 알고리즘의 눈에 보이지 않는다. 배열 |vis|는 보이는
마디---곧 맨몸이거나 바깥인 것---를 늘어놓는다. 이 또한 성긴 집합이다. 마디들의
순열을 담되 보이지 않는 것들을 뒤로 몬다. 짝인 |ivis|에는 그 역순열이 들어 있어
이런 관계가 성립한다.
$$\hbox{|vis[k]=v| \qquad $\Leftrightarrow$ \qquad |ivis[v]=k|}$$
마디 |v|가 보이는 것은 |ivis[v]<visible|일 때이고 오직 그때뿐이다. 따라서
|ivis[v]>=visible|인 것이 |v|가 안쪽이라는 말과 같다.

@<전역 변수@>=
var (
	vis, ivis [2 * maxn]int // 보임을 성긴 집합으로 나타낸 것
	visible   int           // 지금 이만큼이 보인다
)

@ 마디 하나를 안쪽으로 밀어 넣는 일은 여러 군데에서 부른다. 원본에서는 매크로다.

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
for k = 0; k < 2*nn; k++ {
	mems += 2
	vis[k], ivis[k] = k, k
}
visible = 2 * nn

@ 있는 호 하나를 |u|에서 |v|로 지우는 일은 이렇게 한다. 마디 |u|는 보이고
|v|는 지금 |u|의 이웃이라고, 곧 |adj[u][v] < vrt[u].d|라고 가정한다.

원본은 \.{remove\_arc}를 실전판에서 \&{inline}으로 두어도 된다고 적었다. 그래서 부르는
값으로 mem을 따로 매기지 않는다.

여기서 $k=d$인지 미리 보는 것은 mem 여섯을 아껴 준다. 갈래 예측을 어지럽히는 값을
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
const head = 2 * maxn // |act| 배열 안 리스트 머리의 자리

@ @<전역 변수@>=
var act [2*maxn + 1]pair

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
|perm[nn-1]|은 무작위 순열이다. 마디 이름을 알아내는 |basename|은 그러니 역순열
|iperm|을 거친다.

@<전역 변수@>=
var (
	perm  [maxn]int // 이 프로그램과 입력 그래프 사이의 마디 대응
	iperm [maxn]int // 그 역대응
)

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
@<차수를 살펴 가장 작은 것을 찾는다@>@;
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

@ 여기서 그래프를 우리 자료구조로 옮긴다. 입력 그래프의 호 리스트를 훑으면서
|nbr|과 |adj|를 채우고, 가는 김에 제 고리와 겹친 호가 있는지도 살핀다. 호 $v\dadj u$
하나는 |g|의 변 $v^-\adj u^+$가 되니, 두 마디의 이웃 목록에 서로를 넣는다. 마디
$v^-$의 목록은 이 자리에서 다 채워지지만, 마디 $u^+$의 목록은 여러 $v$를 거치며
하나씩 늘어난다.

@<|nbr|과 |adj| 배열을 만든다@>=
for i = 0; i < 2*nn; i++ {
	mems++
	for j = 0; j < 2*nn; j++ {
		mems++
		adj[i][j] = infty
	}
}
for v = 0; v < nn; v++ {
	rmems++
	vp := perm[v]
	mems += 2 // |nbr[vp+vp]|와 |adj[vp+vp]|를 짚는 값. 아래 반복문에서 쓴다
	d = 0
	mems++
	for a := g.Vertices[v].Arcs; a != nil; mems, a, d = mems+1, a.Next, d+1 {
		@<호 |a|를 자료구조에 넣는다@>@;
	}
	mems++
	vrt[vp+vp].m, vrt[vp+vp].d = -1, d
	degree[vp+vp] = d
	mems++
	vrt[vp+vp+1].m = -1
	if randomizing {
		@<마디 $v^-$의 이웃 목록을 뒤섞는다@>@;
	}
}
if randomizing {
	@<마디 $v^+$의 이웃 목록을 뒤섞는다@>@;
	mems += rmems // |perm|이 항등이면 |rmems|는 무시한다
}

@ @<호 |a|를 자료구조에 넣는다@>=
mems++
u = int(g.Index(a.Tip))
if u == v {
	fmt.Fprintf(os.Stderr, "graph %s has a self loop %s--%s!\n",
		os.Args[1], g.Vertices[v].Name, g.Vertices[u].Name)
	os.Exit(-44)
}
rmems++
up := perm[u]
if adj[vp+vp][up+up+1] != infty {
	fmt.Fprintf(os.Stderr, "graph %s has a repeated arc %s--%s!\n",
		os.Args[1], g.Vertices[v].Name, g.Vertices[u].Name)
	os.Exit(-4)
}
mems += 2
nbr[vp+vp][d], adj[vp+vp][up+up+1] = up+up+1, d
mems++
ud := vrt[up+up+1].d
mems += 2
nbr[up+up+1][ud] = vp + vp
mems += 2
adj[up+up+1][vp+vp] = ud
mems++
vrt[up+up+1].d, degree[up+up+1] = ud+1, ud+1

@ @<마디 $v^-$의 이웃 목록을 뒤섞는다@>=
for j = 1; j < d; j++ {
	mems += 4
	k = int(rng.Unif(int64(j + 1)))
	mems += 2
	u, w = nbr[vp+vp][j], nbr[vp+vp][k]
	mems += 2
	nbr[vp+vp][j], nbr[vp+vp][k] = w, u
	mems += 2
	adj[vp+vp][w], adj[vp+vp][u] = j, k
}

@ 마디 $v^+$의 목록은 모든 호를 넣은 뒤에야 다 차므로 따로 뒤섞는다.

@<마디 $v^+$의 이웃 목록을 뒤섞는다@>=
for v = 0; v < nn; v++ {
	mems++
	for j = 1; j < vrt[v+v+1].d; j++ {
		mems += 4
		k = int(rng.Unif(int64(j + 1)))
		mems += 2
		u, w = nbr[v+v+1][j], nbr[v+v+1][k]
		mems += 2
		nbr[v+v+1][j], nbr[v+v+1][k] = w, u
		mems += 2
		adj[v+v+1][w], adj[v+v+1][u] = j, k
	}
}

@ 차수가 $1$인 맨몸 마디는 곧바로 방아쇠 목록에 오른다. 왜 그런지는 잠시 뒤에
말한다. 가는 김에 |adj|가 대칭인지도 확인한다. 우리가 지은 그래프는 저절로 대칭이니
이것은 벌레를 잡는 그물일 뿐이다.

@<차수를 살펴 가장 작은 것을 찾는다@>=
for mind, u = infty, 0; u < 2*nn; u++ {
	mems++
	if vrt[u].d < mind {
		mind, curv = vrt[u].d, u
	}
	if vrt[u].d == 1 {
		mems++
		trigger[trigptr] = u
		trigptr++
	}
	for v = 0; v < 2*nn; v++ {
		if adj[u][v] != infty && adj[v][u] == infty {
			confusion("asymmetry")
		}
	}
}

@ 차수가 $0$인 마디가 있으면 해밀턴 회로가 있을 수 없다. 마디 $v^-$의 차수는 $v$에서
나가는 호의 수이고, $v^+$의 차수는 $v$로 들어오는 호의 수다.

@<그래프의 크기를 알린다@>=
if mind < 1 {
	s := "out"
	if curv&1 != 0 {
		s = "in"
	}
	fmt.Fprintf(out, "There are no Hamiltonian cycles, because %s has %sdegree 0!\n",
		basename(curv>>1), s)
	out.Flush()
	os.Exit(0)
}
fmt.Fprintf(os.Stderr, "OK, I've got a digraph with %d vertices, %d arcs,\n", nn, g.M)
fmt.Fprintf(os.Stderr, " and minimum indegree or outdegree %d.\n", mind)

@* 손으로 들여다보기.
손으로 벌레를 잡을 때 쓰라고 원본은 상태를 찍는 작은 함수 몇을 남겨 두었다.
프로그램 어디에서도 부르지 않는다. 디버거 안에서 사람이 부르는 것이다. \GO/의
링커는 아무도 부르지 않는 함수를 실행 파일에서 빼 버리니, 디버거에서 부르려면
어디선가 한 번은 불러 두어야 한다.

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
	case vrt[v].m < 0 && ivis[v] < visible:
		fmt.Print(" bare\n")
	case vrt[v].m < 0:
		fmt.Print(" inner\n")
	case ivis[v] >= visible:
		fmt.Printf(" mate %s, inner\n", name(vrt[v].m))
	default:
		fmt.Printf(" mate %s\n", name(vrt[v].m))
	}
}

func printVerts() {
	for v := 0; v < 2*nn; v++ {
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
	pv, v := head, act[head].rlink
	for ; v != head; pv, v = v, act[v].rlink {
		@<활성 마디 |v|를 살핀다@>@;
	}
	if act[head].llink != pv {
		fmt.Fprintf(os.Stderr, "llink of head is bad!\n")
	}
	for v := 0; v < 2*nn; v++ {
		@<마디 |v|의 이웃 관계를 살핀다@>@;
	}
}

@ @<활성 마디 |v|를...@>=
if act[v].llink != pv {
	fmt.Fprintf(os.Stderr, "llink of %s is bad!\n", name(v))
}
if ivis[v] >= visible {
	fmt.Fprintf(os.Stderr, "active %s is invisible!\n", name(v))
}
switch u := vrt[v].m; {
case u < 0:
	fmt.Fprintf(os.Stderr, "active %s has no mate!\n", name(v))
case u >= 2*nn:
	fmt.Fprintf(os.Stderr, "active %s has bad mate!\n", name(v))
case vrt[u].m != v:
	fmt.Fprintf(os.Stderr, "mate(mate(%s))!=%s!\n", name(v), name(v))
case adj[v][u] < vrt[v].d:
	fmt.Fprintf(os.Stderr, "there's an arc from %s to its mate!\n", name(v))
}

@ @<마디 |v|의 이웃 관계를...@>=
for k := 0; k < degree[v]; k++ {
	if adj[v][nbr[v][k]] != k {
		fmt.Fprintf(os.Stderr, "Bad nbr[%s][%d]!\n", name(v), k)
	}
}
for u := 0; u < 2*nn; u++ {
	if adj[v][u] != infty && nbr[v][adj[v][u]] != u {
		fmt.Fprintf(os.Stderr, "Bad adj[%s][%s]!\n", name(v), name(u))
	}
}
if ivis[v] < visible && eptr < nn { // |v|는 바깥이거나 맨몸이다
	@<보이는 마디 |v|가 성한지 살핀다@>@;
}

@ 맨몸 마디 $u^-$의 짝꿍 $u^+$는 늘 함께 맨몸이다. 곧 한쪽만 맨몸인 마디가 있으면
탈이다.

@<보이는 마디 |v|가...@>=
if vrt[v].m < 0 && vrt[v^1].m >= 0 && ivis[v^1] < visible {
	fmt.Fprintf(os.Stderr, "%s is half bare!\n", name(v))
}
for k := 0; k < vrt[v].d; k++ {
	u := nbr[v][k]
	if ivis[u] >= visible {
		fmt.Fprintf(os.Stderr, "inner %s is touched by %s!\n", name(u), name(v))
	} else if adj[u][v] >= vrt[u].d {
		fmt.Fprintf(os.Stderr, "arc %s to %s is missing!\n", name(u), name(v))
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
스택 |savestack|은 수준마다 꼭 |2*nn|칸씩 자란다.

@<전역 변수@>=
var (
	level     int                    // 가지친 깊이
	nd        [maxn + 1]node         // 뿌리에서 지금 수준까지의 마디들
	trigger   [maxn * 2 * maxn]int   // 맨몸인 채 차수가 $1$이 된 마디들
	trigptr   int                    // 방아쇠 목록에 든 마디의 수
	savestack [maxn * 2 * maxn]vert  // 수준마다 보이는 마디들의 자료
	saveptr   int                    // |savestack|에 쌓인 칸 수
	actstack  [maxn * 2 * maxn]int   // 수준마다의 활성 마디 목록
	actptr    int                    // |actstack|에 쌓인 칸 수
)

@ 맨몸인 마디 |v|의 차수가 지금 그래프에서 $1$이라면, 어떤 해밀턴 회로든 |v|에 닿는
그 변을 반드시 품는다. 그런 |v|를 |trigger|라는 목록에 넣어 둔다. 기회가 닿는 대로
그 변을 골라 버리고 싶기 때문이다.

마디 |u|가 맨몸일 수도 있는 자리에서는 |removeArc| 대신 |removex|를 부른다.
함수 |removex|는 때가 되면 |u|를 방아쇠로 만들어 주기 때문이다.

(덧붙임. 마디 |u|가 맨몸이지만 곧 바깥이 될 자리에서는 |removeArc|를 부르기도 한다.
모든 자리에서 |removex|를 쓰는 것보다 그편이 빠르다.)

@<함수들@>=
func removex(u, v int) {
	mems++
	d := vrt[u].d - 1
	if vrt[u].m < 0 && d == 1 {
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

@<모든 해를 되추적으로 훑는다@>=
@<되추적을 띄운다@>@;
advance:
@<방아쇠 목록에 있는 것들에 옷을 입히거나 |tryAgain|으로 간다@>@;
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
	if level != 0 {
		goto backup
	}
	goto done
}
@<이 수준에서 한 나머지 변경을 되돌린다@>@;
if level != 0 {
	if sanityChecking {
		sanity()
	}
	goto tryMove
}
@<뿌리 수준에서 나아간다@>@;

@ @<전역 변수@>=
var (
	curt, curu, curv, curw int // 지금 눈여겨보는 마디들
	curi                   int // 지금 고른 이웃의 색인
)

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
	fmt.Fprintf(os.Stderr, "Entering level %d:\n", level)
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
	fmt.Fprintf(os.Stderr, "Back to level %d\n", level)
}

@ 여기가 어떤 변을 회로에 반드시 넣도록 강요하는 자리다. 차수가 $1$인 맨몸 마디가
방아쇠 목록에 올라와 있기 때문이다. 목록을 헤쳐 나가는 사이에 형편이 바뀔 수도
있다. 맨몸이던 마디가 그새 활성이 되었을지 모른다.

실은 맨몸 마디 하나에 옷을 입히면 잔물결이 일어 다른 맨몸 마디들이 방아쇠 목록에
새로 들어오기도 한다. 그러니 아래 반복문에서 |trigptr|은 움직이는 과녁이다.

이 반복문이 끝나면 남은 맨몸 마디의 차수는 모두 $2$ 이상이다.

@<방아쇠 목록에 있는 것들에 옷을...@>=
mems++
j = 0
if level != 0 {
	j = nd[level-1].t
}
for ; j < trigptr; j++ {
	@<방아쇠 |trigger[j]|를 살펴 옷을 입힌다@>@;
}

@ 이웃이 하나도 남지 않았으면 이 가지는 죽었다. 그러면 |tryAgain|으로 뛰어 다음
갈래를 본다. 이웃이 하나 남았으면 그 변 $v\adj u$를 고른다. 그러면 |v|는 안쪽이 되고
그 짝꿍 |v^1|이 바깥이 된다. 곁에서 $u$도 옷을 입는다.

@<방아쇠 |trigger[j]|를...@>=
mems++
v = trigger[j]
mems++
if vrt[v].m >= 0 {
	continue // 마디 |v|는 이제 맨몸이 아니다
}
mems++
if ivis[v] >= visible {
	continue // 마디 |v|는 이제 보이지 않는다
}
if vrt[v].d == 0 {
	if vbose&showDetails != 0 {
		fmt.Fprintf(os.Stderr, "oops, no neighbors for %s\n", name(v))
	}
	goto tryAgain
}
mems += 2
u = nbr[v][0] // 이제 |v|는 맨몸이고 |u|에만 이어져 있다
e[eptr].u, e[eptr].v = v, u // 배열 |e|에는 mem을 매기지 않는다
eptr++
vprint()
makeinner(v)
activate(v ^ 1)
@<|u|에 닿은 다른 호들을 걷어낸다@>@;
mems++
w = vrt[u].m
if w < 0 {
	@<BB를 OO로 올린다@>@;
} else {
	@<BO를 OI로 올린다@>@;
}

@ 마디 |u|는 이제 |v|와 짝지어졌으니 다른 누구와도 이어질 수 없다. 그러니 |u|를
다른 마디들의 목록에서 지운다.

@<|u|에 닿은 다른 호들을...@>=
mems += 2
for k = vrt[u].d - 1; k >= 0; k-- {
	mems++ // |nbr[u]|를 짚는 값은 위에서 이미 셌다
	t = nbr[u][k]
	if t != v {
		removex(t, u)
	}
}

@ 고른 변을 보이는 일은 여러 자리에서 한다. 원본에서는 매크로다.

@<함수들@>=
func vprint() {
	if vbose&showChoices != 0 {
		fmt.Fprintf(os.Stderr, "     %s--%s\n", name(e[eptr-1].u), name(e[eptr-1].v))
	}
}

@ 여기서 미묘한 점 하나를 짚어야겠다. 입력 유향 그래프가 그냥 마디 둘 $\{0,1\}$에
호 둘 $0\dadj 1\dadj 0$이라 하자. 그러면 그것을 나타내는 그래프에는 마디 넷
$\{0^-,0^+,1^-,1^+\}$와 변 둘 $0^-\adj1^+$, $1^-\adj0^+$가 있다. 네 마디의 차수가
모두 $1$이니 곧바로 방아쇠 목록에 오른다. 첫 승격 |trigger[0]|${}=0^-$은 강요된 변
$0^-\adj1^+$를 낳는다. 그러면서 $0^-$과 $1^+$는 안쪽이 되고 $0^+$와 $1^-$은
바깥이, 곧 활성이 된다. 이제 $0^+$, $1^-$, $1^+$는 더는 맨몸이 아니니 아무것도
일으키지 못한다. 게다가 $1^-$과 $0^+$는 서로 짝이 되고, 둘 사이의 변은
(|makemates|가) 지워 버려 차수가 $0$이 된다! 그래도 탈이 없다. 변을 |nn-1|개 고른
뒤로는 알고리즘이 결코 가지를 치지 않기 때문이다.

@<BB를 OO로 올린다@>=
makeinner(u)
activate(u ^ 1)
makemates(u^1, v^1)

@ 두 바깥 마디를 짝지을 때, 둘 사이에 변이 남아 있으면 지운다. 그 변을 고르면 해밀턴
회로보다 짧은 회로가 생기기 때문이다.

@<함수들@>=
func makemates(u, w int) {
	mems += 3
	if adj[w][u] < vrt[w].d { // 마디 |u|는 |w|의 이웃이다
		removeArc(w, u)
		removeArc(u, w)
	}
	mems += 2
	vrt[u].m, vrt[w].m = w, u
}

@ @<BO를 OI로 올린다@>=
deactivate(u)
makemates(v^1, w)

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
	fmt.Fprintf(os.Stderr, ", branching on %s(%d)\n", name(curv), d)
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

@ 마디 $u^-$이 맨몸인 것과 그 짝꿍 $u^+$가 맨몸인 것은 같은 말이라는 (재미있는)
사실을 쓴다.

@<|curv|에서 |nbr[curv][curi]|로 가는 변을 고른다@>=
mems++
curu = nbr[curv][curi]
mems++
curw = vrt[curv].m
e[eptr].v = curu
eptr++
if vbose&showChoices != 0 {
	fmt.Fprintf(os.Stderr, "%3d: %s--%s (%d of %d)\n",
		level, name(e[eptr-1].u), name(e[eptr-1].v), curi+1, d)
}
mems++
curt = vrt[curu].m
mems += 2
for k = vrt[curu].d - 1; k >= 0; k-- {
	mems++ // |nbr[curu]|를 짚는 값은 위에서 이미 셌다
	u = nbr[curu][k]
	removex(u, curu)
}
if curt < 0 { // 마디 |curu|는 맨몸이다
	makeinner(curu)
	activate(curu ^ 1)       // |curu|의 짝꿍이 바깥이 되고
	makemates(curu^1, curw) // |curv|의 짝과 짝지어진다
} else { // 마디 |curu|는 바깥이다
	makemates(curt, curw)
	deactivate(curu)
}

@* 되추적하기.
탐색 나무를 헤매다 보면 아직 가 보지 않은 갈래로 되돌아가고 싶을 때가 잦다.

원본에서는 |nd[level].v|와 |nd[level].i|를 함께 짚는 데 mem 하나면 된다. 서른두
자리 \&{int} 둘이 같은 예순네 자리 낱말에 들어앉기 때문이다. 다른 짝들도 마찬가지다.
\GO/의 |int|는 여덟 바이트라 사정이 다르지만, 셈은 원본 그대로 둔다. 세는 것은 우리
기계가 실제로 짚는 낱말 수가 아니라 크누스가 설계한 알고리즘의 값이기 때문이다.

가지가 하나뿐이면($d=1$) 되돌아올 일이 없으니 스택에 쌓지 않는다. 그때는
|nd[level].v|와 |nd[level].i|도 적지 않는다.

@<나중에 되추적하려고 지금 상태를 적어 둔다@>=
mems++
nd[level].d, nd[level].m = d, eptr
mems++
nd[level].s, nd[level].t = visible, trigptr
if d > 1 {
	mems++
	nd[level].v, nd[level].i = curv, curi
	@<보이는 마디와 활성 마디를 스택에 쌓는다@>@;
}
mems++
nd[level].a = actptr

@ @<보이는 마디와 활성 마디를...@>=
saveptr = level * 2 * nn
for k = 0; k < visible; k++ {
	mems++
	u = vis[k]
	mems += 2
	savestack[saveptr+u] = vrt[u]
}
for mems, u = mems+1, act[head].rlink; u != head; mems, u = mems+1, act[u].rlink {
	actstack[actptr] = u
	actptr++
}

@ Peter Weigel이 일러 준 대로, 여기서는 가장 요긴한 상태 변수 둘만 먼저 되살린다.
그 둘이 나머지는 되살릴 것도 없다고 말해 줄지 모르기 때문이다.

@<|d|와 |curi|를 되살리고...@>=
mems += 2
d = nd[level].d
nd[level].i++
curi = nd[level].i

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
saveptr = level * 2 * nn
for k = 0; k < visible; k++ {
	mems++
	u = vis[k]
	mems += 2
	vrt[u] = savestack[saveptr+u]
}

@* 열매 거두기.
모든 마디가 이어지고 나면 더 고를 것이 없다. 그런 경우는 대개 옳은 해밀턴 회로를
찾은 것인데, 마지막 연결 하나는 아직 채워 넣어야 한다.

이 자리에서 활성 마디는 정확히 둘이어야 한다.

(|eptr==nn|일 수는 없다. 이 프로그램은 |eptr|이 |nn-1|일 때 결코 |eptr|을 늘리지
않기 때문이다.)

@<해인지 살펴보고 |backup|으로 간다@>=
if eptr == nn {
	confusion("eptr")
}
@<바깥 마디 둘이 이웃이 아니면 |backup|으로 간다@>@;
e[eptr].u, e[eptr].v = act[head].llink, act[head].rlink
eptr++
vprint()
count++
if spacing != 0 && count%uint64(spacing) == 0 {
	@<이 해를 찍는다@>@;
}
if count >= maxcount {
	goto done
}
goto backup

@ 이 자리에서 우리는 해밀턴 {\it 경로\/} 하나를 이룬 셈이다. 그것이 해밀턴 회로가
되려면 두 바깥 마디가 서로 이웃이어야 하고, 그것으로 충분하다.

@<바깥 마디 둘이 이웃이 아니면...@>=
mems++
u, v = act[head].llink, act[head].rlink
mems += 2
if adj[u][v] == infty {
	goto backup
}

@ 원본의 |spacing|은 부호 있는 |int|이고 |count|는 부호 없는 수다. \CEE/는 나머지를
셈하기 전에 |spacing|을 부호 없는 수로 바꾸니, \.{m-3}처럼 음수를 주면 사실상 아무
해도 찍지 않는다. 변환 |uint64(spacing)|이 그것을 그대로 따른다.

해를 찍기 전에 이 수준의 기록을 ``$1$개 중 $1$번째''로 고쳐 둔다. 뒤이어 부를 수
있는 |printState|가 해의 마지막 변을 고른 변으로 보이게 하려는 것이다.

@<이 해를 찍는다@>=
nd[level].i, nd[level].d = 0, 1
nd[level].m = eptr
if vbose&showRawSols != 0 {
	fmt.Fprintf(out, "\n%d:\n", count)
	printState(out)
} else {
	@<지금 해를 풀어서 찍는다@>@;
}
out.Flush()

@ 배열 |e|에 쌓인 변들은 골라진 차례대로 있을 뿐, 회로를 도는 차례가 아니다.
그런데 유향 그래프에서는 풀기가 쉽다. 변 $u^-\adj v^+$는 호 $u\dadj v$이니 $u$의
다음이 $v$다. 변의 두 끝 가운데 어느 쪽이 $+$인지만 보면 된다. 그렇게 마디마다 다음
마디를 |succ|에 적고, 마디 $0$에서 출발해 한 바퀴 따라간다.

@<지금 해를 풀어서 찍는다@>=
for k = 0; k < nn; k++ {
	i, j = e[k].u, e[k].v
	if i&1 != 0 {
		succ[j>>1] = i >> 1
	} else {
		succ[i>>1] = j >> 1
	}
}
for j, k = 0, 0; j <= nn; j, k = j+1, succ[k] {
	fmt.Fprintf(out, "%s ", basename(k))
}
fmt.Fprintf(out, "#%d\n", count)

@ @<전역 변수@>=
var succ [maxn]int // 유향 그래프의 마디 하나의 다음 마디

@ 탐색 나무 안에서 우리가 어디까지 왔는지를 통째로 찍는 함수다. 수준마다 한 줄씩
내는데, 그 수준에서 강요되어 딸려 온 변들을 먼저 들여쓰고 그다음에 고른 변을 적는다.
표준 출력으로도 표준 오류로도 찍으니 쓸 곳을 인자로 받는다.

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
fmt.Fprintf(f, " %3d: %s--%s (%d of %d)\n",
	l, name(e[j].u), name(e[j].v), kl, nd[l].d)

@ 뿌리 수준의 |nd[0].v|가 음수라면, 그 수준은 첫 변들을 방아쇠 목록에서 받아
시작한 것이므로 ``고른'' 변이 없다.

@<뿌리 수준의 상태 줄을 찍고 |j|를 되돌린다@>=
if nd[0].v >= 0 || nd[0].d > 1 {
	fmt.Fprintf(f, "   0: (%d of %d)\n", nd[0].i+1, nd[0].d)
}
j-- // 반복문의 |j++|를 메워 준다

@* 판 벌이기.
프로그램은 거의 다 되었다. 그런데 되추적 수준 $0$에서 판을 제대로 벌여 공을
굴리기 시작하는 방법을 아직 정하지 않았다.

차수가 $1$인 마디가 그래프에 하나라도 있으면 걱정할 것이 없다. 그런 경우에는
|trigger| 목록이 활성 마디를 적어도 둘 마련해 준다. 하지만 모든 마디의 차수가 $2$
이상이라면 나머지 계산의 씨앗이 될 바깥 마디를 우리 손으로 마련해야 한다.

앞의 (쉬운) 경우에는 |nd[0].v|를 $-1$로 둔다. 뒤의 경우에는 차수가 가장 작은 마디
|curv|를 잡아 |nd[0].v=curv|로 두고 그 이웃을 하나씩 시험한다. (더 정확히 말하면,
|curv|에서 다른 마디 |u|로 가는 변을 품는 해밀턴 회로를 모두 찾고 나면 그 변을
그래프에서 아주 지워 버리고, |curv|든 다른 마디든 이웃이 하나만 남을 때까지 이
일을 되풀이한다.)

@ 원본에서는 표찰 |force|가 |else| 블록 안에 있고, 뿌리 수준에서 나아가는 자리가
블록 밖에서 그리로 뛴다. \GO/는 블록 안으로 뛰어들 수 없으니 블록을 풀었다. 쉬운
경우는 |goto advance|로 곧장 나아가고, 어려운 경우는 블록 없이 표찰 |force| 아래를
지나 그대로 |advance|로 흘러간다. 파일 \.{ssham.w}가 표찰 |record|를 하나 더 둔 것과는
조금 다른 모양이지만 하는 일은 같다.

@<되추적을 띄운다@>=
level = 0
d = mind
if d == 1 {
	mems += 2
	nd[0].v, nd[0].d = -1, d
	goto advance
}
curi = 0
force:
@<뿌리 수준에서 변 하나를 고른다@>@;

@ @<뿌리 수준에서 변 하나를...@>=
if act[head].llink != head || act[head].rlink != head {
	confusion("root")
}
mems += 2
curu = nbr[curv][d-1-curi]
e[0].u, e[0].v = curv, curu
eptr = 1
if vbose&showChoices != 0 {
	fmt.Fprintf(os.Stderr, "  0: %s--%s (%d of %d)\n",
		name(e[0].u), name(e[0].v), curi+1, d)
}
@<나중에 되추적하려고 지금 상태를 적어 둔다@>@;
@<뿌리 수준의 변 양 끝에 닿은 다른 호들을 걷어낸다@>@;
makeinner(curu)
makeinner(curv)
activate(curu ^ 1)
activate(curv ^ 1)
makemates(curu^1, curv^1)

@ @<뿌리 수준의 변 양 끝에...@>=
mems += 2
for k = vrt[curu].d - 1; k >= 0; k-- {
	mems++ // |nbr[curu]|를 짚는 값은 위에서 이미 셌다
	t = nbr[curu][k]
	if t != curv {
		removex(t, curu)
	}
}
mems += 2
for k = vrt[curv].d - 1; k >= 0; k-- {
	mems++ // |nbr[curv]|를 짚는 값은 위에서 이미 셌다
	t = nbr[curv][k]
	if t != curu {
		removex(t, curv)
	}
}

@ 뿌리 수준으로 되돌아오면 모든 마디가 다시 맨몸이다. 뿌리 수준에서 앞서 시험한
변은 이제 그래프에 없으니, 그 변의 두 마디 가운데 하나 또는 둘의 차수가 $1$이
되었을 수 있다. 그런 경우에는 방아쇠 목록이 마지막 판을 끝낼 길을 마련해 준다.

@<뿌리 수준에서 나아간다@>=
mems++
curu = e[0].v // 앞서 쓰던 변 |curv|--|curu|는 이제 사라진다
removeArc(curv, curu)
removeArc(curu, curv)
@<차수가 $1$이 된 마디를 방아쇠에 올린다@>@;
if trigptr == 0 {
	goto force
}
nd[0].v, eptr = -1, 0
if vbose&showChoices != 0 {
	fmt.Fprintf(os.Stderr, "  0: (%d of %d)\n", curi+1, d)
}
goto advance

@ @<차수가 $1$이 된 마디를...@>=
trigptr = 0
if vrt[curu].d == 1 {
	trigger[0] = curu
	trigptr = 1
}
if vrt[curv].d == 1 {
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
		printProgress()
	}
}
if mems >= timeout {
	fmt.Fprintf(os.Stderr, "TIMEOUT!\n")
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
고르다는 순진한 가정에 기댄 값이다. 나무가 마디 하나뿐이면 어림값은 $.5$이고,
그렇지 않고 첫 선택이 `$d$개 중 $k$번째'이면 $(k-1)/d$에 $1/d$ 곱하기 $k$번째
부분나무의 어림값(되돌이로 셈한다)을 더한 값이다. (이 어림은 경우에 따라 크게
어긋날 수 있지만, 적어도 단조롭게 자라는 편이다.)

@<함수들@>=
func printProgress() {
	fmt.Fprintf(os.Stderr, " after %d mems: %d sols,", mems, count)
	f, fd := 0.0, 1.0
	for l := 0; l < level; l++ {
		d := nd[l].d
		k := 1
		if d != 1 {
			k = nd[l].i + 1
		}
		fd *= float64(d)
		f += float64(k-1) / fd // 수준 |l|의 선택은 $d$개 중 $k$번째다
		fmt.Fprintf(os.Stderr, " %c%c", digit(k), digit(d))
	}
	fmt.Fprintf(os.Stderr, " %.5f\n", f+0.5/fd)
}

@ 글자 부호를 짓는 일은 $k$와 $d$ 두 곳에서 한다.

@<함수들@>=
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

@ 옆모습을 찍는 자리에서 원본은 전역 변수 |level|을 반복 변수로 쓴다. 이 뒤로
|level|을 쓸 일이 없으니 그대로 따랐다.

@<옆모습을 찍는다@>=
fmt.Fprintf(os.Stderr, "Profile:\n")
for level = 1; level <= maxl; level++ {
	fmt.Fprintf(os.Stderr, "%3d: %d\n", level, profile[level])
}

@* 해 보기.
몇 가지 그래프에 돌려 보았다. 셈이 맞는지 손으로 따질 수 있는 것부터 보자. 마디가
$n$개인 완전 유향 그래프, 곧 서로 다른 두 마디 사이에 두 방향의 호가 다 있는
그래프에는 해밀턴 회로가 $(n-1)!$개 있다. 출발점을 고정하고 나머지 마디의 차례를
정하면 되기 때문이다. 프로그램은 $n=4$, $5$, $6$, $7$에서 $6$, $24$, $120$, $720$개를
찾는다.

$$\vbox{\halign{#\hfil\quad&\hfil#\quad&\hfil#\quad&\hfil#\cr
\rm 그래프&\rm 회로&\rm 탐색 나무의 마디&\rm mem\cr
\noalign{\smallskip}
완전 유향 그래프, $n=4$&6&9&$237+1242$\cr
완전 유향 그래프, $n=5$&24&40&$366+5276$\cr
완전 유향 그래프, $n=6$&120&205&$523+26363$\cr
완전 유향 그래프, $n=7$&720&1236&$708+157521$\cr
$5\times6$ 판 나이트 그래프&16&2214&$5231+370355$\cr
$6\times6$ 판 나이트 그래프&19724&313048&$7253+49677200$\cr}}$$

@ 나이트 그래프는 \.{SGB}의 |board(6,6,0,0,5,0,0)|로 지은 무향 그래프다. 무향
그래프의 변 하나는 두 방향의 호로 적혀 있으니, 이 프로그램에는 호가 양쪽으로 다 난
유향 그래프로 보인다. 그러면 무향 해밀턴 회로 하나가 도는 방향에 따라 유향 회로
둘이 된다. 실제로 $6\times6$ 판에서 찾은 $19724$개는 \.{ssham.w}가 같은 그래프에서
찾은 $9862$개의 꼭 두 배이고, $5\times6$ 판의 $16$개는 그 판의 닫힌 나이트 투어
$8$개의 두 배다.

같은 그래프를 두고 두 프로그램이 쓰는 mem을 견주면 재미있다. \.{ssham.w}는
$6\times6$ 판에서 $2265+4671495$ mem을 쓰는데, 이 프로그램은 $7253+49677200$ mem으로
열 배 남짓 쓴다. 탐색 나무도 $37064$마디 대 $313048$마디로 여덟 배 남짓 크다.
회로를 두 방향으로 다 찾으니 그 가운데 두 배는 당연하다. 나머지가 어디서 오는지는
따져 보지 않았다. 무향 그래프라는 것을 아는 프로그램이 그만큼 유리한 셈이다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 \.{libgb}와 함께 컴파일해 이 판과 견주었다. 표준 출력,
표준 오류, 종료 부호가 모두 바이트까지 같은지를 보았다. 사용법을 알리는 말에 든
프로그램 이름만은 빼고 견주었다.

그래프는 \.{libgb}로 지어 저장한 $75$개와 없는 파일 하나다.

\smallskip
\item{$\bullet$} 무작위 유향 그래프 $60$개. 마디는 $2$개에서 $13$개, 호가 날 확률은
$30$에서 $90$퍼센트다.
\item{$\bullet$} 앞에서 말한 마디 둘짜리 $0\dadj1\dadj0$, 회로 하나뿐인 $C_3$, 그림의
그래프, 완전 유향 그래프 넷($n=4$--$7$), 나이트 그래프 둘($5\times6$, $6\times6$).
\item{$\bullet$} 오류와 가장자리를 보려는 것들. 회로가 없는 길, 마디 하나, 나가는
차수가 $0$인 마디가 있는 유향 룩 그래프, 회로가 없는 유향 원환면 판, 그리고 제 고리가
있는 것과 겹친 호가 있는 것이다.
\smallskip

\noindent 그래프마다 선택항 조합 $20$가지와 잘못된 선택항 $6$가지를 주었다. 조합에는
수다의 모든 부호(\.{v2}, \.{v4}, \.{v64}, \.{v128}, \.{v256}), 해를 찍는 간격
\.{m1}과 \.{m3}, 무작위로 흩는 \.{s}, 진행 보고의 \.{d}, 해의 수를 자르는 \.{t},
mem을 자르는 \.{T}, 같은 선택항을 두 번 준 것, \.{t-1}과 \.{m-3} 같은 음수가 들어
있다. 잘못된 것은 모르는 글자, 수가 빠진 것, 빈 인자, \.{t2x}처럼 찌꺼기가 붙은
것 따위다. $6\times6$ 나이트 그래프는 오래 걸리므로 조합을 넷만 주었다.

@ 모두 $1962$번을 견주었고 어긋난 곳은 하나도 없었다. 다만 그 가운데 $27$번은 호가
빽빽한 그래프라 해가 수억 개에 이르므로, 선택항 \.{t50000}을 덧붙여 해 $5$만 개에서
멈추게 한 채로 견주었다. 찾은 해도, 찍히는 차례도,
수다스러운 되추적 기록도, 옆모습도, 진행 보고의 문자열과 어림값도, 그리고 mem 수도
모두 같았다. 견준 출력은 모두 합쳐 $7$기가바이트 남짓이다. 무작위로 흩는 \.s
선택항까지 맞는 것은 go-sgb의 |gbflip|이 \.{SGB}의 |gb_flip|과 같은 수열을 내주기
때문이다.

또 원본을 \.{AddressSanitizer}와 \.{UndefinedBehaviorSanitizer}를 붙여 컴파일하고
$6\times6$ 나이트 그래프를 뺀 그래프 $74$개에 선택항 조합 다섯 가지씩, $370$번을
돌려 보았다. 한 번도 경고가 나지 않았다. 이번에는 옮기며 고칠 결함을 찾지 못했다.

@ 속도는 원본에 못 미친다. 호가 빽빽한 마디 $13$개짜리 무작위 그래프에서 해
$300$만 개를 찾는 데(mem $7$억 남짓) 원본은 $0.18$초, 이 판은 $0.61$초가 걸린다.
배열 경계 검사를 꺼도(\.{-gcflags=-B}) 거의 그대로이고, 프로파일 기반 최적화로
|removex|를 인라인하게 해도 그렇다. 시간의 절반쯤은 mem을 세는 데 든다. 셈을 모두
걷어낸 판은 $0.33$초다. \CEE/ 컴파일러는 뜨거운 반복문 안에서 전역 변수 |mems|를
레지스터에 담아 두지만, \GO/는 |mems++|마다 메모리를 읽고 쓰기 때문이다. 셈을 한데
모으면 빨라지겠지만, 원본의 |o|, |oo|, |ooo|를 한 자리씩 좇아 적는 것이 이 판의
요점이라 그대로 두었다.

@* 색인.
