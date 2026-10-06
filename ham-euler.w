\input kotexgweb
@i types.w
\datethis

\def\adj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-8mu\mathrel-\!}}

\def\title{오일러의 방법으로 해밀턴 순환 찾기}

@* 들어가며.
이 프로그램은 오일러가 1759년에 내놓은 방법으로 그래프의 해밀턴 순환을 찾아본다.
그래프~$G$의 경로 하나가 주어졌을 때 오일러는 요령 넷을 썼다.
\smallskip
\item{(1)} 마지막 꼭짓점에서 새 꼭짓점으로 가는 변을 덧붙여 경로를 늘인다.
\item{(2)} 경로의 방향을 뒤집는다.
\item{(3)} 꼴이 $x\adj y\adj\cdots\adj z\adj x$인 순환 경로를 순환 경로
$y\adj\cdots\adj z\adj x\adj y$로 바꾼다.
\item{(4)} 꼴이 $w\adj\cdots\adj x\adj y\adj\cdots\adj z$이고 $z\adj x$인 경로를
$w\adj\cdots\adj x\adj z\adj\cdots\adj y$로 바꾼다.
\smallskip
\noindent 요령 (4)는 경로의 끝 $z$에서 앞쪽의 $x$로 가는 변을 넣고 $x\adj y$를
빼서, $y$부터 $z$까지의 꼬리를 뒤집어 붙이는 것이다. 꼭짓점 집합은 그대로다.

요령 (1)을 쓸 수 있으면, 곧 지금까지 아는 가장 긴 경로보다 긴 것을 얻으면, 그때까지의
경로는 모두 잊고 처음부터 다시 한다. 그럴 수 없으면 메모리가 바닥나거나 네 요령이
더는 새것을 내놓지 않을 때까지 계속 찾는다.

@ 메모리를 아끼려고 요령 (2)와 (3)으로 경로를 정규형으로 만든다. 순환이 아닌
경로는 첫 꼭짓점이 마지막 꼭짓점보다 작은 것만 기억하고, 순환 경로는 첫 꼭짓점이
가장 작고 둘째 꼭짓점이 마지막 꼭짓점보다 작은 것만 기억한다. 기억해 둔 경로들은
거대한 그래프~$H$의 꼭짓점으로 볼 수 있고, 우리는 $H$에서 너비 우선 탐색을 하는
셈이다. 크누스는 그것들을 ``초꼭짓점''(supervertex)이라 부른다.

오일러가 관심을 둔 것은 나이트 투어였다. 크누스의 말로는, $G$가 나이트 그래프이면
순환이 아닌 초꼭짓점은 $H$에서 이웃이 많아야 $14$개이고, 순환인 초꼭짓점은 이웃이
$12n$개보다 적다.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{ham-euler.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/ham-euler.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Wed, 16 Apr 2025 23:41:31 GMT}다.

그래프 파일은 \pdfURL{go-sgb}{https://github.com/sjnam/go-sgb}의
|gbsave.RestoreGraph|로 읽고, 난수는 같은 꾸러미의 |gbflip|에서 얻는다. 이것은
\.{SGB}의 \CEE/ 판 |gb_flip|과 똑같은 수열을 낸다. 프로그램이 찍는 말과 종료 부호는
원본 그대로 두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.
옮기다가 원본의 결함 다섯을 만났다. 고쳤고, 이야기는 맨 뒤에 적었다.

@ 명령줄은 `\.{ham-euler foo.gb seed [v0] [v1] ...}'이다. 첫 인자는 \.{SGB} 형식의
그래프 파일이고, 둘째는 난수의 씨앗이다. 그 뒤에 꼭짓점 이름을 늘어놓으면 그것이
처음 경로가 된다. 없으면 무작위로 고른 꼭짓점 하나가 처음 경로다.

표준 출력에는 새 초꼭짓점을 찾을 때마다 그 경로를 한 줄로 찍는다. 순환이 아닌
경로는 꼭짓점 이름마다 앞에 빈칸을 두고, 순환 경로는 첫 이름 앞의 빈칸을 뺀다.
줄 끝의 `\.{\#$a$>$b$}'는 이 초꼭짓점의 고리 번호 $a$와, 그것을 낳은 초꼭짓점의
고리 번호 $b$다. 경로가 길어질 때마다 ``\.{Breakthru}''를 알린다. 표준 오류에는
거리마다 지금까지 찾은 것의 수를 알리고, 끝에 모두 합친 것을 알린다.

@ 크기를 정하는 상수들은 원본 그대로다. 꼭짓점 번호 하나를 \.{10}비트에 담으므로
꼭짓점은 많아야 $1024$개이고, $64$비트 낱말 하나에 꼭짓점 여섯을 담는다. 메모리
|mem|은 $2^{27}$낱말, 곧 1기가바이트다.

@<상수@>=
const (
	maxn         = 1024 // $G$의 꼭짓점은 많아야 이만큼
	bitsPerVert  = 10   // 꼭짓점 하나를 담는 비트 수
	vertsPerOcta = 6    // 낱말 하나에 담는 꼭짓점 수
	logmemsize   = 27
	memsize      = 1 << logmemsize
	memmask      = memsize - 1
	loghashsize  = 12
	hashsize     = 1 << loghashsize
	hashmask     = hashsize - 1
)

@ 원본은 |1<<bitsPerVert>=maxn|이고 |bitsPerVert*vertsPerOcta<=64|인지를 실행할
때 살피고, 아니면 ``다시 컴파일해 달라''며 종료 부호 $-666$으로 멈춘다. 상수끼리의
관계이니 나는 컴파일할 때 살핀다. 배열의 길이가 음수이면 \GO/는 컴파일하지 않는다.
그래서 이 두 줄은 조건이 어긋나면 컴파일되지 않고, 종료 부호 $-666$은 쓸 일이
없어졌다.

@<상수@>=
var _ [1<<bitsPerVert - maxn]struct{}
var _ [64 - bitsPerVert*vertsPerOcta]struct{}

@ 프로그램의 뼈대는 이렇다. 명령줄을 처리해 그래프를 읽고, 그래프를 준비하고,
오일러의 방법을 쓰고, 셈한 것을 알린다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
	@#
	"github.com/sjnam/go-sgb/gbflip"
	"github.com/sjnam/go-sgb/gbgraph"
	"github.com/sjnam/go-sgb/gbsave"
)

@<상수@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 처리해 그래프를 읽는다@>@;
	@<그래프를 준비한다@>@;
	@<오일러의 방법을 쓴다@>@;
	@<셈한 것을 알린다@>@;
}

@ 원본의 |main|에는 이름표 |done|이 있지만 아무도 그리로 뛰지 않는다. \GO/는
쓰지 않는 이름표를 허락하지 않으므로 뺐다.

원본이 \CEE/의 |printf|로 찍는 표준 출력은 |out|이라는 버퍼를 거친다. 새
초꼭짓점마다 한 줄을 찍으니 버퍼 없이는 너무 느리다. 다만 |os.Exit|는 버퍼를
비워 주지 않으니, 멈추는 자리마다 |out.Flush()|를 먼저 부른다. 표준 오류에 무언가를
알릴 때도 먼저 부른다. 원본을 단말기에서 돌릴 때 보이는 차례가 그렇기 때문이다.

@<셈한 것을 알린다@>=
out.Flush()
fmt.Fprintf(os.Stderr, "Altogether %d updates;", updates)
fmt.Fprintf(os.Stderr, " found %d cycle%s and %d noncycle%s of size %d.\n",
	cycles, plural(cycles), noncycles, plural(noncycles), pathlen)
fmt.Fprintf(os.Stderr, "Dictionary size %.1f (mean), %d (max).\n",
	dictave, dictmax)

@ 원본은 `|cycles==1?"":"s"|'처럼 삼항 연산자로 복수형을 고른다. \GO/에는
삼항 연산자가 없으니 작은 함수를 둔다. 끝에서 한 번, 거리마다 한 번 부른다.

@<함수들@>=
func plural(x int) string {
	if x == 1 {
		return ""
	}
	return "s"
}

@ @<전역 변수@>=
var out = bufio.NewWriterSize(os.Stdout, 1<<16) // 표준 출력의 버퍼

@ 명령줄에 인자가 모자라거나 그래프를 읽지 못하면 원본은 둘 다 사용법을 알린다.

@<명령줄을 처리해 그래프를 읽는다@>=
if len(os.Args) > 2 {
	g, _ = gbsave.RestoreGraph(os.Args[1])
}
if g == nil {
	fmt.Fprintf(os.Stderr, "Usage: %s foo.gb seed [v0] [v1] ...\n", os.Args[0])
	os.Exit(-1)
}
n = int(g.N)
if n > maxn {
	fmt.Fprintf(os.Stderr, "Sorry, I allow only %d vertices, not %d!\n", maxn, n)
	os.Exit(-2)
}
@<꼭짓점이 하나도 없으면 멈춘다@>@;
@<씨앗을 읽어 난수 발생기를 초기화한다@>@;
@<처음 경로를 읽는다@>@;

@ 원본은 씨앗을 \CEE/의 |sscanf|로 읽는다. 그래서 앞의 빈칸과 부호를 받아 주고,
`\.{12abc}'처럼 뒤에 무엇이 붙어도 앞의 수만 읽는다. \GO/의 |fmt.Sscanf|도 꼭
그렇게 한다. 다른 것은 수가 |int32|를 넘칠 때뿐이다. \CEE/의 |sscanf|에서 그것은
정의되지 않은 동작이고, 내 기계에서는 $2^{32}$을 법으로 감겨 들어갔다. \GO/는
넘친다고 알리니 이 판은 그런 씨앗을 잘못된 씨앗으로 다룬다.

@<씨앗을 읽어 난수 발생기를 초기화한다@>=
if k, _ := fmt.Sscanf(os.Args[2], "%d", &seed); k != 1 {
	fmt.Fprintf(os.Stderr, "bad random seed `%s'!\n", os.Args[2])
	os.Exit(-7)
}
rng = gbflip.New(int64(seed))

@ 처음 경로의 꼭짓점은 이름으로 찾는다. 경로에는 꼭짓점이 많아야 $n$개 있으니
그 뒤의 인자는 보지 않는다. 경로를 주지 않으면 무작위로 고른 꼭짓점 하나를 쓴다.
값 |pathlen|은 경로의 길이가 아니라 경로에 든 꼭짓점의 수다.

@<처음 경로를 읽는다@>=
for k = 0; k < n && k+3 < len(os.Args); k++ {
	for j = 0; j < n; j++ {
		if os.Args[k+3] == g.Vertices[j].Name {
			break
		}
	}
	if j == n {
		fmt.Fprintf(os.Stderr, "Vertex `%s' isn't in the graph!\n", os.Args[k+3])
		os.Exit(-3)
	}
	@<꼭짓점 |j|가 이미 경로에 있으면 멈춘다@>@;
	path[k] = j
}
if k == 0 { // 경로를 주지 않았으면 무작위로 고른 꼭짓점 하나를 쓴다
	k = 1
	path[0] = int(rng.Unif(int64(n)))
}
pathlen = k

@ @<지역 변수@>=
var (
	g              *gbgraph.Graph // 주어진 그래프
	seed           int32          // 명령줄의 씨앗
	rng            *gbflip.RNG    // 난수 발생기
	i, j, k, t     int            // 이것저것 셀 때
	iu, iv         int            // 지금 관심 있는 꼭짓점의 번호
	acc            uint64         // 경로를 풀 때 쓰는 낱말
)

@ 그래프를 준비할 차례다. 꼭짓점마다 이웃들을 무작위 차례로 늘어놓는다.

변마다 난수 하나를 붙이기도 한다. 경로에 든 변들의 난수를 더하면 좋은 해시 부호가
되기 때문이다. 크누스는 아예 인접 행렬 |adj|를 두고 거기에 그 무게를 적는 것이
가장 낫다고 했다. 무게에는 늘 비트 $30$을 켜 두어, 변이 있으면 |adj|가 $0$이
아니게 한다.

원본은 |a->tip>v|일 때, 곧 끝점의 번호가 더 클 때만 무게를 뽑는다. 변 하나가 두
번 무게를 받지 않게 하는 것이다. 무게는 꼭짓점마다 그 호들을 처음 차례대로 보며
뽑고, 그다음에 그 꼭짓점의 이웃들을 섞는다. 이 차례가 원본과 같아야 난수열이 같다.

@<그래프를 준비한다@>=
for iv = 0; iv < n; iv++ {
	tmp = tmp[:0]
	for a := g.Vertices[iv].Arcs; a != nil; a = a.Next {
		iu = int(g.Index(a.Tip))
		tmp = append(tmp, iu)
		if iu > iv {
			adj[iv][iu] = uint32(rng.Next() | 1<<30)
			adj[iu][iv] = adj[iv][iu]
		}
	}
	@<꼭짓점 |iv|의 이웃들을 섞어 |nbr[iv]|에 늘어놓는다@>@;
}
@<처음 경로의 해시 부호를 셈한다@>@;

@ 원본은 꼭짓점의 호 리스트 자체를 섞는다. 꼭짓점 배열의 다목적 필드 |u.A|를
임시 배열로 빌려 쓰는 재주를 부리는데, 그 재주에는 탈이 있다. 이야기는 맨 뒤에
적었다. 이 판은 꼭짓점 번호의 배열 |tmp|를 따로 쓴다.
매번 남은 것 가운데 하나를 고르게 골라 내놓고, 그 자리에 맨 끝 것을 옮겨 둔다.

섞은 결과는 이웃의 번호를 담은 슬라이스 |nbr[iv]|에 둔다. 탐색은 호 리스트 대신
그것을 훑는다. 매번 |a.Tip|에서 꼭짓점 번호를 셈하지 않아도 되니 그편이 빠르다.

고리, 곧 제 자신으로 가는 호는 섞기에는 끼우되 |nbr|에는 넣지 않는다. 섞기에
끼우는 것은 난수열을 원본과 맞추려는 것이고, |nbr|에서 빼는 것은 원본의 결함을
고치려는 것이다. 까닭은 맨 뒤에 적었다.

@<꼭짓점 |iv|의 이웃들을 섞어 |nbr[iv]|에 늘어놓는다@>=
for i, j = 0, len(tmp); i < j; i++ {
	k = int(rng.Unif(int64(j - i)))
	if tmp[k] != iv {
		nbr[iv] = append(nbr[iv], tmp[k])
	}
	tmp[k] = tmp[j-i-1]
}

@ 처음 경로가 정말 경로인지 살피며 해시 부호를 셈한다.

@<처음 경로의 해시 부호를 셈한다@>=
for pathhash, j = 0, 1; j < pathlen; j++ {
	if adj[path[j-1]][path[j]] == 0 {
		fmt.Fprintf(os.Stderr, "Oops: `%s' isn't adjacent to `%s'!\n",
			g.Vertices[path[j-1]].Name, g.Vertices[path[j]].Name)
		os.Exit(-4)
	}
	pathhash += adj[path[j-1]][path[j]]
}

@ 원본에서 |adj|는 |int|의 배열이고 해시 부호는 |unsigned int|다. 해시 부호를
셈할 때 무게들은 부호 없는 수로 바뀌어 $2^{32}$을 법으로 더하고 뺀다. 이 판은
처음부터 |adj|를 |uint32|로 두어 같은 셈을 한다.

@<전역 변수@>=
var (
	n        int                  // $G$의 꼭짓점 수
	pathlen  int                  // 지금 경로들에 든 꼭짓점 수
	adj      [maxn][maxn]uint32   // 변 무게의 인접 행렬
	nbr      [maxn][]int          // 섞은 이웃들의 번호
	tmp      []int                // 섞을 때 쓰는 임시 배열
	path     [maxn]int            // 지금 경로
	oldpath  [maxn]int            // 새 경로를 낳는 앞 경로
	where    [maxn]int            // |oldpath|의 역순열
	save     [maxn]int            // 임시 저장소
	pathhash uint32               // |path|의 해시 부호 전체
	oldhash  uint32               // |oldpath|의 해시 부호 전체
)

@* 자료 구조.
이미 한 일을 넉넉히 기억해 두어야 같은 경로를 두 번 만들지 않는다. 처음
초꼭짓점에서 거리가 |d|인 초꼭짓점들을 보며 거리 |d+1|인 것들을 만드는 동안, 거리
|d-1|과 |d|에서 본 초꼭짓점을 모두 알고 있어야 한다는 뜻이다. 그러나 거리가
|d-1|보다 작은 것들은 잊어도 괜찮다. 너비 우선 탐색에서 거리 |d|인 꼭짓점의 이웃은
거리가 |d-1|, |d|, |d+1| 가운데 하나이기 때문이다.

기억해 둔 초꼭짓점들은 |uint64| 정수의 큰 배열 |mem|에 이어진 낱말들의 덩이로
담는다. 덩이마다 첫 낱말에는 해시 부호 전체와, 잘린 해시 부호가 같은 다른
초꼭짓점으로 가는 고리가 들어 있다. 그 뒤로 낱말 $\lceil m/t\rceil$개가 따르는데,
$m$은 지금 경로들에 든 꼭짓점 수이고 |t=vertsPerOcta|는 낱말 하나에 담는 꼭짓점
수다. 메모리는 순환 대기열로 쓴다. |mem[memsize-1]| 다음은 |mem[0]|이다.

그래서 고리 |l|은 자리 |(l*b)%memsize|에서 시작하는 낱말 |b|개짜리 덩이를
가리킨다. 여기서 $b=1+\lceil m/t\rceil$다. 고리 |l|이 거리 |d-1|인 초꼭짓점의 첫
고리보다 작으면 |nil|로 여긴다.

덩이의 첫 낱말은 더 정확히 말하면 위쪽 32비트가 고리이고 아래쪽 32비트가 해시
부호 전체다.

@<전역 변수@>=
var (
	mem            [memsize]uint64 // 큰 메모리 배열
	prevstart      int             // 거리 |d-1|의 첫 덩이
	curstart       int             // 거리 |d|의 첫 덩이
	curptr         int             // 지금 초꼭짓점의 덩이
	nextstart      int             // 거리 |d+1|의 첫 덩이
	nextptr        int             // 다음 초꼭짓점의 덩이
	curlink        int             // |curptr|에 대응하는 고리
	nextlink       int             // |nextptr|에 대응하는 고리
	curd           int             // |d|
	cutoff         int             // 이보다 작은 고리는 |nil|로 여긴다
	nextcutoff     int             // |d|가 늘 때 쓸 |cutoff|
	nextnextcutoff int             // |d|가 늘 때 쓸 |nextcutoff|
	blocksize      int             // 덩이의 크기. |pathlen|에 따라 정해진다
	cyclic         bool            // 지금 경로는 순환인가?
	hashhead       [hashsize]int   // 해시 리스트의 머리들
	updates        int             // 갱신 횟수
	cycles         int             // 찾은 순환 경로의 수
	noncycles      int             // 찾은 순환 아닌 경로의 수
	dictsize       int             // 지금 사전에 든 것의 수
	dictmax        int             // 지금까지 가장 큰 |dictsize|
	dictave        float64         // 갱신마다 본 |dictsize|의 평균
)

@ 1기가바이트짜리 배열 |mem|을 전역 배열로 둔 데에는 까닭이 둘 있다. 첫째로,
\GO/의 전역 배열은 \CEE/의 것처럼 실행 파일의 \.{BSS} 영역에 놓인다. 운영 체제는
실제로 건드린 쪽만 메모리를 내주니 작은 그래프에서는 메모리를 거의 쓰지 않는다.
둘째로, 첨자를 |memmask|로 거른 뒤에 쓰면 컴파일러가 범위를 넘지 않음을 알아서
경계 검사를 빼 준다. 슬라이스로는 그렇게 되지 않는다.

@ 초꼭짓점 하나를 다루기 시작할 때, 그 경로를 배열 |oldpath|에 풀어 놓는다. 역순열
|where|도 함께 채운다. 한 단계 안에서 만드는 경로들은 꼭짓점 집합이 모두 같으니,
|where|의 나머지 자리는 그 단계를 시작할 때 둔 $-1$ 그대로다.

@<덩이 |curptr|를 푼다@>=
oldhash = uint32(mem[curptr])
for j, i, k, acc = 1, 0, 0, mem[mmod(curptr+1)]; k < pathlen; k++ {
	oldpath[k] = int(acc & (1<<bitsPerVert - 1))
	where[oldpath[k]] = k
	acc >>= bitsPerVert
	if i++; i == vertsPerOcta {
		j++
		i, acc = 0, mem[mmod(curptr+j)]
	}
}
cyclic = adj[oldpath[0]][oldpath[pathlen-1]] != 0
if debugging {
	@<|oldpath|와 |oldhash|가 맞는지 살핀다@>@;
}

@ 원본의 매크로 |mmod|는 순환 대기열의 첨자를 거르는 함수가 된다. 인라인되니
느려지지 않는다.

@<함수들@>=
func mmod(x int) int { return x & memmask }

@ 원본은 디버깅할 때 켜는 상수 |debugging|을 둔다. 꺼 두면 컴파일러가 아래 검사를
통째로 버린다.

@<상수@>=
const debugging = false // 풀어 낸 경로를 살필 것인가?

@ @<|oldpath|와 |oldhash|가 맞는지 살핀다@>=
var h uint32
for k = 1; k < pathlen; k++ {
	h += adj[oldpath[k-1]][oldpath[k]]
}
if cyclic {
	h += adj[oldpath[k-1]][oldpath[0]]
}
if oldhash != h {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Sanity check failure!\n")
	os.Exit(-6666)
}

@ 새것일지 모를 경로를 만들면 그것을 덩이 |nextptr|에 싸 넣는다. 싸 넣다가 거리
|d-1|의 첫 덩이에 닿으면 메모리가 넘친 것이다.

@<경로 |path|를 덩이 |nextptr|에 싸 넣는다@>=
for j, i, k, acc = 1, 0, 0, 0; k < pathlen; k++ {
	acc += uint64(path[k]) << (i * bitsPerVert)
	if i++; i == vertsPerOcta {
		if mmod(nextptr+j) == prevstart {
			memoverflow()
		}
		mem[mmod(nextptr+j)] = acc
		acc, i = 0, 0
		j++
	}
}
if i != 0 {
	if mmod(nextptr+j) == prevstart {
		memoverflow()
	}
	mem[mmod(nextptr+j)] = acc
}

@ 원본에서 메모리가 넘쳤다고 알리는 코드에는 이름표 |memoverflow|가 붙어 있고,
다른 두 곳에서 |goto|로 그리로 간다. 그런데 그 이름표는 |if| 블록 안에 있으니,
블록 안으로 뛰어드는 |goto|를 허락하지 않는 \GO/로는 그대로 옮길 수 없다. 세 곳에서
부르는 함수로 둔다.

@<함수들@>=
func memoverflow() {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Overflow (memsize=%d, dictsize=%d)!\n",
		memsize, dictsize)
	os.Exit(-9)
}

@ 경로는 정규형으로 만든 다음에야 싸 넣는다. 앞에서 말했듯 순환이 아닌 경로는
그것을 뒤집은 것과 같고, 순환 경로는 그것을 순환 이동한 것들 및 그것을 뒤집어
순환 이동한 것들과 모두 같다.

순환인지는 첫 꼭짓점과 마지막 꼭짓점이 이웃인지로 가린다. 순환이면 그 닫는 변의
무게도 해시 부호에 더한다. 꼭짓점이 둘뿐인 경로도 이 기준으로는 순환이다. 같은
변을 두 번 지나는 셈인데, 다음 단계로 넘어가는 데에는 아무 탈이 없다.

@<경로 |path|를 정규형으로 만든다@>=
if adj[path[0]][path[pathlen-1]] != 0 {
	cyclic = true
	pathhash += adj[path[0]][path[pathlen-1]]
	for j, k = 0, 1; k < pathlen; k++ {
		if path[k] < path[j] {
			j = k
		}
	}
	if j != 0 {
		@<경로를 왼쪽으로 |j|만큼 순환 이동한다@>@;
	}
	if path[1] > path[pathlen-1] {
		for i, j = 1, pathlen-1; i < j; i, j = i+1, j-1 {
			path[i], path[j] = path[j], path[i]
		}
	}
} else {
	cyclic = false
	if path[0] > path[pathlen-1] {
		for i, j = 0, pathlen-1; i < j; i, j = i+1, j-1 {
			path[i], path[j] = path[j], path[i]
		}
	}
}

@ 크누스는 이렇게 적었다. ``경로를 제자리에서 순환 이동하는 교묘한 방법들이 있다는
것은 안다. 그러나 나는 메모리는 모자라지 않고 내 시간은 모자란다. 그러니 보조
배열을 쓴다.''

\GO/의 |copy|는 겹치는 구간도 바르게 옮겨 주니 세 번의 |copy|로 쓴다.

@<경로를 왼쪽으로 |j|만큼 순환 이동한다@>=
copy(save[:j], path[:j])
copy(path[:pathlen-j], path[j:pathlen])
copy(path[pathlen-j:pathlen], save[:j])

@ 이제 할 너비 우선 탐색의 기본 동작은, 지금 초꼭짓점의 이웃인 경로를 하나 만들고
그것이 처음 보는 것이면 알려진 초꼭짓점들에 보태는 것이다. 함수 |upd|가 뒤의
일을 맡는다.

해시 리스트를 따라가며 해시 부호 전체가 같고 싸 넣은 낱말들까지 모두 같은 덩이를
찾는다. 고리가 |cutoff|보다 작으면 잊은 것이니 리스트가 거기서 끝난 것으로 본다.

@<함수들@>=
func upd() {
	var h, i, j, k, l, ll, nextl int
	var acc uint64
	updates++
	@<경로 |path|를 정규형으로 만든다@>@;
	@<경로 |path|를 덩이 |nextptr|에 싸 넣는다@>@;
	h = int(pathhash & hashmask)
	for l = hashhead[h]; l >= cutoff; l = nextl {
		ll = (blocksize * l) & memmask
		nextl = int(mem[ll] >> 32)
		if (mem[ll]^uint64(pathhash))&0xffffffff != 0 {
			continue // |ll|에서는 맞지 않는다
		}
		for j = 1; j < blocksize; j++ {
			if mem[(ll+j)&memmask] != mem[(nextptr+j)&memmask] {
				break
			}
		}
		if j < blocksize {
			continue
		}
		break // 같은 것을 찾았다
	}
	if l < cutoff {
		@<새 초꼭짓점을 사전에 넣는다@>@;
	}
	@<통계를 고친다@>@;
}

@ 새 초꼭짓점은 해시 리스트의 맨 앞에 넣는다. 고리 번호는 $32$비트에 담으니
$2^{32}-1$에 이르면 멈춘다.

@<새 초꼭짓점을 사전에 넣는다@>=
if cyclic {
	cycles++
} else {
	noncycles++
}
@<경로 |path|를 찍는다@>@;
mem[nextptr] = uint64(hashhead[h])<<32 + uint64(pathhash)
hashhead[h] = nextlink
if nextlink == 0xffffffff {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Link overflow!\n")
	os.Exit(-667)
}
nextlink++
nextptr = mmod(nextptr + blocksize)
dictsize++
if nextptr == prevstart {
	memoverflow()
}

@ 경로를 찍는 것은 이 프로그램에서 가장 자주 하는 일 가운데 하나다. 그래서
|fmt.Fprintf| 대신 버퍼에 글자를 곧바로 쓴다.

@<경로 |path|를 찍는다@>=
for k = 0; k < pathlen; k++ {
	if k > 0 || !cyclic {
		out.WriteByte(' ')
	}
	out.WriteString(name[path[k]])
}
fmt.Fprintf(out, " #%d>%d\n", nextlink, curlink)

@ 꼭짓점 이름은 |g|를 거치지 않고 찾도록 따로 모아 둔다. 함수 |upd|가 |g|를 보지
않아도 되게 하려는 것이다.

@<전역 변수@>=
var name []string // 꼭짓점의 이름들

@ @<그래프를 준비한다@>=
name = make([]string, n)
for k = 0; k < n; k++ {
	name[k] = g.Vertices[k].Name
}

@ 사전의 크기는 갱신마다 재어 평균과 최댓값을 낸다. 평균은 이어 가며 고친다.

@<통계를 고친다@>=
if dictsize > dictmax {
	dictmax = dictsize
}
dictave += (float64(dictsize) - dictave) / float64(updates)

@* 너비 우선 탐색.
좋다. 거리~|d|인 초꼭짓점 하나를 어떻게 다루는지 정하자. 순환이 아닌 경로에는
요령 (1)과 (4)를 양 끝에서 쓰고, 순환 경로에는 모든 꼭짓점에서 쓴다.

@<초꼭짓점 |curptr|의 이웃들을 살핀다@>=
@<덩이 |curptr|를 푼다@>@;
if !cyclic {
	@<순환 아닌 경로 |oldpath|의 이웃들을 살핀다@>@;
} else {
	@<순환 경로 |oldpath|의 이웃들을 살핀다@>@;
}

@ 원본의 매크로 |update|는 함수 |upd|를 부르고, 만든 경로가 순환이면서 꼭짓점을
다 품지 못했으면 이름표 |shortcut|으로 간다. 왜 그런지는 뒤의 ``모두 엮기''에서
말한다. 원본에서 이것은 `|cyclic&pathlen<n|'이라고 적혀 있다. 비교가 비트별 |&|보다
먼저 묶이니 |cyclic&&pathlen<n|과 같은 뜻이다.

@<경로 |path|를 사전에 넣고, 짧은 순환이면 |shortcut|으로 간다@>=
upd()
if cyclic && pathlen < n {
	goto shortcut
}

@ 순환이 아닌 경로에서는 먼저 마지막 꼭짓점 $v$의 이웃 $u$를 본다. 이웃이 경로
밖에 있으면 요령 (1)로 경로가 늘어난다. 돌파구다! 경로 안에 있으면, 곧
$u$가 |oldpath[k]|이면 요령 (4)로 |oldpath[k+1]|부터 끝까지를 뒤집는다. 그때 변
$u\adj v$를 넣고 변 |oldpath[k]|${}\adj{}$|oldpath[k+1]|을 빼니, 해시 부호도
그만큼 고친다. 바로 앞 꼭짓점 |oldpath[pathlen-2]|는 이미 $v$와 이어져 있으니
건너뛴다.

다음에는 첫 꼭짓점에서 같은 일을 한다. 경로를 뒤집어 놓고 하는 것과 같다.

@<순환 아닌 경로 |oldpath|의 이웃들을 살핀다@>=
@<마지막 꼭짓점에서 요령 (1)과 (4)를 쓴다@>@;
@<첫 꼭짓점에서 요령 (1)과 (4)를 쓴다@>@;

@ @<마지막 꼭짓점에서 요령 (1)과 (4)를 쓴다@>=
iv = oldpath[pathlen-1]
for _, iu = range nbr[iv] {
	k = where[iu] // |k>=0|이면 |iu==oldpath[k]|다
	if k < 0 {
		copy(path[:pathlen], oldpath[:pathlen])
		path[pathlen] = iu
		pathhash = oldhash + adj[iu][iv]
		goto breakthru
	}
	if k == pathlen-2 {
		continue // 이미 $u\adj v$임을 알았다
	}
	for j = 0; j <= k; j++ {
		path[j] = oldpath[j]
	}
	for i = pathlen - 1; i > k; i, j = i-1, j+1 {
		path[j] = oldpath[i]
	}
	pathhash = oldhash + adj[iu][iv] - adj[iu][oldpath[k+1]]
	@<경로 |path|를 사전에 넣고, 짧은 순환이면 |shortcut|으로 간다@>@;
}

@ 첫 꼭짓점의 이웃이 |oldpath[k]|이면 |oldpath[0]|부터 |oldpath[k-1]|까지를 뒤집는다.
새 꼭짓점은 경로의 맨 앞에 붙인다.

@<첫 꼭짓점에서 요령 (1)과 (4)를 쓴다@>=
iv = oldpath[0]
for _, iu = range nbr[iv] {
	k = where[iu]
	if k < 0 {
		copy(path[1:pathlen+1], oldpath[:pathlen])
		path[0] = iu
		pathhash = oldhash + adj[iu][iv]
		goto breakthru
	}
	if k == 1 {
		continue // 이미 $u\adj v$임을 알았다
	}
	for i = 0; i < k; i++ {
		path[i] = oldpath[k-1-i]
	}
	for j = k; j < pathlen; j++ {
		path[j] = oldpath[j]
	}
	pathhash = oldhash + adj[iu][iv] - adj[iu][oldpath[k-1]]
	@<경로 |path|를 사전에 넣고, 짧은 순환이면 |shortcut|으로 간다@>@;
}

@ 순환 경로에서는 모든 꼭짓점 $v=x_j$와 그 이웃 $u=x_k$를 본다. 순환 위에서 $v$와
이웃한 $x_{j\pm1}$은 건너뛴다. 남은 것은 순환의 현(chord)이다. 현 $x_j\adj x_k$를
넣고 순환에서 변 둘을 빼면 순환이 아닌 경로 둘이 나온다. 하나는 $x_{k-1}$에서
거꾸로 $x_j$까지 간 다음 현을 건너 $x_k$부터 앞으로 가는 것이고, 다른 하나는
$x_{j+1}$에서 앞으로 $x_k$까지 간 다음 현을 건너 $x_j$부터 거꾸로 가는 것이다.

순환 경로의 해시 부호에는 닫는 변의 무게도 들어 있다. 그래서 새 경로의 부호는 현의
무게를 더하고 뺀 두 변의 무게를 빼서 얻는다.

원본은 순환 위의 앞 꼭짓점을 `|j?oldpath[j-1]:oldpath[pathlen-1]|'처럼 삼항
연산자로 고른다. 나는 \GO/에 삼항 연산자가 없으니 나머지 셈
|oldpath[(j+pathlen-1)%pathlen]|으로 쓴다. 다음 꼭짓점은 |oldpath[(j+1)%pathlen]|다.

@<순환 경로 |oldpath|의 이웃들을 살핀다@>=
for j = 0; j < pathlen; j++ {
	iv = oldpath[j]
	for _, iu = range nbr[iv] {
		k = where[iu]
		if k < 0 {
			@<꼭짓점 |iu|를 |oldpath[j]| 앞에 붙인 경로를 만든다@>@;
			goto breakthru
		}
		if k == j-1 || k == j+1 || k == j-1+pathlen || k == j+1-pathlen {
			continue
		}
		@<현 |iv|${}\adj{}$|iu|로 첫째 경로를 만든다@>@;
		@<경로 |path|를 사전에 넣고, 짧은 순환이면 |shortcut|으로 간다@>@;
		@<현 |iv|${}\adj{}$|iu|로 둘째 경로를 만든다@>@;
		@<경로 |path|를 사전에 넣고, 짧은 순환이면 |shortcut|으로 간다@>@;
	}
}

@ 첫째 경로는 $x_{k-1}$, $x_{k-2}$, \dots, $x_j$, $x_k$, $x_{k+1}$, \dots,
$x_{j-1}$이다. 빠지는 변은 $x_{k-1}\adj x_k$와 $x_{j-1}\adj x_j$다.

@<현 |iv|${}\adj{}$|iu|로 첫째 경로를 만든다@>=
for t, i = 0, k-1; ; i-- {
	if i < 0 {
		i = pathlen - 1
	}
	path[t] = oldpath[i]
	t++
	if i == j {
		break
	}
}
for i = k; t < pathlen; i++ {
	if i >= pathlen {
		i = 0
	}
	path[t] = oldpath[i]
	t++
}
pathhash = oldhash + adj[iu][iv] - adj[iu][oldpath[(k+pathlen-1)%pathlen]] -
	adj[oldpath[j]][oldpath[(j+pathlen-1)%pathlen]]

@ 둘째 경로는 $x_{j+1}$, $x_{j+2}$, \dots, $x_k$, $x_j$, $x_{j-1}$, \dots,
$x_{k+1}$이다. 빠지는 변은 $x_k\adj x_{k+1}$과 $x_j\adj x_{j+1}$이다.

@<현 |iv|${}\adj{}$|iu|로 둘째 경로를 만든다@>=
for t, i = 0, j+1; ; i++ {
	if i >= pathlen {
		i = 0
	}
	path[t] = oldpath[i]
	t++
	if i == k {
		break
	}
}
for i = j; t < pathlen; i-- {
	if i < 0 {
		i = pathlen - 1
	}
	path[t] = oldpath[i]
	t++
}
pathhash = oldhash + adj[iu][iv] - adj[iu][oldpath[(k+1)%pathlen]] -
	adj[oldpath[j]][oldpath[(j+1)%pathlen]]

@ 순환에 든 꼭짓점 $x_j$에게 순환 밖의 이웃 $u$가 있으면, 순환을 $x_j$에서 끊고
$u$를 앞에 붙여 경로를 늘일 수 있다. 곧 $u\adj x_j\adj x_{j+1}\adj\cdots\adj
x_{j-1}$이다. 빠지는 변은 $x_{j-1}\adj x_j$다.

이 코드는 여기와 뒤의 |shortcut|, 두 곳에서 쓴다. 원본은 두 곳에 같은 코드를
적었는데, 해시 부호를 하나는 |oldhash|에서, 하나는 |pathhash|에서 셈한다. 나는
|shortcut|에서 |oldhash|를 미리 맞춰 두고 이 절 하나를 두 곳에 끼워 넣는다.

사실 순환 초꼭짓점을 기억하는 것은 꼭짓점을 다 품었을 때뿐이니, 이 탐색에서
|k<0|인 일은 일어나지 않는다. 그래도 원본처럼 남겨 둔다.

@<꼭짓점 |iu|를 |oldpath[j]| 앞에 붙인 경로를 만든다@>=
copy(path[1:pathlen-j+1], oldpath[j:pathlen])
copy(path[pathlen-j+1:pathlen+1], oldpath[:j])
path[0] = iu
pathhash = oldhash + adj[iu][iv] - adj[oldpath[(j+pathlen-1)%pathlen]][oldpath[j]]

@* 모두 엮기.
기본 기능은 다 만들었다. 남은 것은 조각들을 잇는 일뿐이다. 크누스는 ``다익스트라라면
이것을 먼저 했겠지. 나도 그랬어야 했을지 모른다''고 적었다.

미묘한 점 하나. 크누스는 첫 고리가 $0$이 아니라 $1$이기를 바랐다. 그래서 |mem|에서
처음 채우는 덩이는 자리 |blocksize|에서 시작한다.

순환을 찾았으면, 그 순환의 모든 꼭짓점이 순환 안에만 이웃을 갖는 경우가 아니라면
언제나 돌파구를 낼 수 있다. 크누스는 주어진 그래프가 연결되어 있다고 가정한다.
그러니 |pathlen=n|이 아니면 순환을 사전에 넣을 까닭이 없다. 짧은 순환을 만들면
곧바로 |shortcut|으로 가서, 순환 밖에 이웃을 가진 꼭짓점을 찾아 경로를 늘인다.
그런 꼭짓점이 없으면 그래프가 연결되어 있지 않은 것이다.

이 절의 이름표들이 하는 일은 이렇다. 이름표 |shortcut|은 짧은 순환에서 돌파구를
내고, |breakthru|는 돌파구를 알리며 경로를 늘이고, |firstpath|는 새 길이의 경로로
탐색을 처음부터 시작한다.

@<오일러의 방법을 쓴다@>=
goto firstpath
shortcut:
@<짧은 순환 |path|에서 순환 밖의 이웃을 찾아 경로를 늘인다@>@;
fmt.Fprint(out, "* ") // 지름길은 특별한 돌파구다
breakthru:
fmt.Fprintf(out, "Breakthru after %d cycles, %d noncycles!\n", cycles, noncycles)
pathlen++
firstpath:
@<길이 |pathlen|인 경로들의 탐색을 준비한다@>@;
@<경로 |path|를 사전에 넣고, 짧은 순환이면 |shortcut|으로 간다@>@;
nextstart, nextnextcutoff, curlink = nextptr, nextlink, 1
for curd = 0; ; curd++ {
	@<거리 |curd|까지 찾은 것을 알린다@>@;
	if curstart == nextstart {
		break
	}
	for curptr = curstart; curptr != nextstart; curptr, curlink =
		mmod(curptr+blocksize), curlink+1 {
		@<초꼭짓점 |curptr|의 이웃들을 살핀다@>@;
	}
	prevstart, curstart, nextstart = curstart, nextstart, nextptr
	dictsize -= nextcutoff - cutoff
	cutoff, nextcutoff, nextnextcutoff = nextcutoff, nextnextcutoff, nextlink
}

@ 경로 |path|는 정규형이니 첫 꼭짓점부터 차례로 보며 순환 밖의 이웃을 찾는다.
값 |oldpath|와 |where|를 그 순환으로 맞추고 |oldhash|도 맞춰 두면, 앞에서 만든
절을 그대로 쓸 수 있다.

순환 밖의 이웃이 하나도 없으면 연결 성분 하나의 해밀턴 순환을 이미 찍은 것이다.
원본은 그것을 알리고 종료 부호 $0$으로 멈춘다.

@<짧은 순환 |path|에서 순환 밖의 이웃을 찾아 경로를 늘인다@>=
for j = 0; j < pathlen; j++ {
	oldpath[j] = path[j]
	where[oldpath[j]] = j
}
oldhash = pathhash
for j = 0; j < pathlen; j++ {
	iv = oldpath[j]
	for _, iu = range nbr[iv] {
		if where[iu] < 0 {
			break
		}
	}
	if where[iu] < 0 {
		break
	}
}
if where[iu] >= 0 {
	out.Flush()
	fmt.Fprintf(os.Stderr, "* The graph isn't connected!\n")
	os.Exit(0) // 연결 성분 하나의 해밀턴 순환을 찍었다
}
@<꼭짓점 |iu|를 |oldpath[j]| 앞에 붙인 경로를 만든다@>@;

@ 덩이의 크기는 경로의 길이에 따라 정해진다. 해시 리스트를 비우고, 고리 번호를
$1$부터 다시 매긴다. 앞 단계의 덩이들은 |mem|에 남아 있지만, 해시 리스트에서 닿을
수 없으니 없는 것과 같다.

@<길이 |pathlen|인 경로들의 탐색을 준비한다@>=
blocksize = 1 + (pathlen+vertsPerOcta-1)/vertsPerOcta
for k = 0; k < n; k++ {
	where[k] = -1
}
clear(hashhead[:])
cycles, noncycles, curlink, dictsize = 0, 0, 0, 0
prevstart, curstart, nextptr = blocksize, blocksize, blocksize
cutoff, nextcutoff, nextlink = 1, 1, 1
fmt.Fprintf(out, "Paths and cycles of length %d:\n", pathlen)

@ @<거리 |curd|까지 찾은 것을 알린다@>=
out.Flush()
fmt.Fprintf(os.Stderr, " len %d after distance %d: %d cycle%s, %d noncycle%s\n",
	pathlen, curd, cycles, plural(cycles), noncycles, plural(noncycles))

@* 나이트 투어.
옮긴 김에 오일러의 과녁이던 $8\times8$ 체스판의 나이트 그래프에 돌려 보았다. 그래프는
\.{SGB}의 |board(8,8,0,0,5,0,0)|로 만든다. 꼭짓점 이름 \.{$i$.$j$}는 $i$행 $j$열의
칸이다.

씨앗을 $1$부터 $8$까지 주어 보니, 어느 것이든 눈 깜짝할 새에 꼭짓점 $64$개짜리
경로에 이르고, 그 단계의 거리 $2$에서 $4$ 사이에서 첫 닫힌 투어를 찾았다. 아래는
씨앗 $1$로 찾은 첫 투어다. 칸마다 나이트가 몇 번째로 밟는지를 적었다. $64$번째
칸에서 첫 칸으로 돌아가면 투어가 닫힌다.
$$\vbox{\offinterlineskip\halign{&\hbox to 1.8em{\strut\hfil#\hfil}\cr
 1&42&17&54&13&38&19&34\cr
16&55& 2&39&18&35&12&37\cr
41&64&43&14&53&20&33&50\cr
56&15&40& 3&44&51&36&11\cr
63& 4&61&52&21&10&49&32\cr
60&57&26&45&48&31&22& 9\cr
 5&62&59&28& 7&24&47&30\cr
58&27& 6&25&46&29& 8&23\cr}}$$
\noindent 그 뒤로도 프로그램은 멈추지 않는다. 새 초꼭짓점이 바닥날 때까지 너비 우선
탐색을 이어 가니, $8\times8$에서는 메모리가 넘칠 때까지 간다. 씨앗 $1$로 $60$초를
돌리니 거리 $6$까지 닫힌 투어 $7888$개와 열린 경로 $326906$개를 찍었다.

@* 옮기며 고친 것.
원본에서 결함 다섯을 찾았다. 모두 원본이 미리 살피지 않는 입력에서 일어난다.

첫째, 원본은 처음 경로에 같은 꼭짓점이 두 번 나와도 받아들인다. 그러면 역순열
|where|가 깨지고, 알고리즘은 단순하지 않은 경로를 경로로 여긴 채 나아간다.
이를테면 꼭짓점 \.{a}부터 \.{f}까지가 차례로 이어지고 \.{a}${}\adj{}$\.{c}가 더
있는 그래프에서 처음 경로를 `\.{a b a}'로 주면, 원본은 꼭짓점 여섯 개짜리
그래프에서 ``꼭짓점 일곱 개짜리 경로'' `\.{a b a c d e f}'를 찾았다고 알린다.
꼭짓점이 $1024$개인 그래프라면 배열 |path|의 끝을 넘어 쓸 수도 있다. 이 판은
같은 꼭짓점이 두 번 나오면 알리고, 원본이 쓰지 않던 종료 부호 $-5$로 멈춘다.

@<꼭짓점 |j|가 이미 경로에 있으면 멈춘다@>=
for i = 0; i < k; i++ {
	if path[i] == j {
		fmt.Fprintf(os.Stderr, "Vertex `%s' appears twice in the path!\n",
			os.Args[k+3])
		os.Exit(-5)
	}
}

@ 둘째, 원본은 같은 변이 거듭 나오는 다중 그래프에서 메모리를 망가뜨린다. 이웃을
섞을 때 꼭짓점 배열의 다목적 필드를 임시 배열로 빌려 쓰는데, 차수가 $d$인
꼭짓점을 섞으려면 |vert(0)|부터 |vert(d-1)|까지가 필요하다. 단순 그래프라면 차수가
$n-1$을 넘지 않으니 괜찮다. 그러나 다중 그래프에서는 차수가 꼭짓점 수를 넘을 수
있고, 그러면 꼭짓점 배열의 끝을 넘어 쓴다. 이를테면 꼭짓점 셋에 변 열세 개인 무작위
다중 그래프에서, 원본은 해밀턴 순환 하나를 찾는 데 갱신을 $5$번 했다고 알렸다.
고친 판은 $3$번이다. 원본을 \.{AddressSanitizer}와 함께 컴파일하면
`|vert(j)->tmp=a|'에서 힙 버퍼 넘침을 알리며 멈춘다. 이 판은 따로 둔 슬라이스
|tmp|를 쓰니 그런 일이 없다.

@ 셋째, 그래프에 고리가 있으면 원본은 끝나지 않는다. 고리 $v\adj v$는 경로 안의
이웃처럼 보인다. 순환 아닌 경로의 끝 $v$에서는 $k$가 |pathlen-1|이 되어 해시
부호를 셈할 때 배열 밖의 |oldpath[pathlen]|을 읽고, 첫 꼭짓점에서는
|oldpath[-1]|을 읽는다. 순환 경로에서는 $k=j$가 되어, 같은 순환을 돌려 적은 경로를
만들면서 같은 변의 무게를 두 번 뺀다. 어느 쪽이든 해시 부호가 틀리니 같은 경로가
새것으로 보이고, 그 틀린 부호에서 다시 틀린 부호가 나온다. 순환 $C_4$의 두
꼭짓점에 고리를 단 그래프에서, 원본은 해밀턴 순환 하나뿐인 그래프에서 ``순환''을
수백 개씩 늘려 가며 1기가바이트 넘게 찍다가 내가 멈출 때까지 돌았다.

고리는 해밀턴 경로에 쓸모가 없다. 이 판은 이웃 목록 |nbr|에 고리를 넣지 않는다.
섞을 때는 원본처럼 고리도 세어 넣으므로 난수열은 원본과 같고, 고리가 없는
그래프에서는 출력이 원본과 똑같다.

@ 넷째, 꼭짓점이 하나도 없는 그래프를 주면 원본은 끝나지 않는다. 처음 경로를
주지 않으면 |gb_unif_rand(0)|을 부르는데, 그 안에서 $0$으로 나누게 된다. 내
기계(\.{arm64})에서는 $0$으로 나눈 몫이 $0$이라 거절 표본 추출이 영원히 거절만
한다. \GO/의 |rng.Unif(0)|은 $0$으로 나누었다며 공황에 빠진다. 이 판은 꼭짓점이
없다고 알리고, 원본이 쓰지 않던 종료 부호 $-8$로 멈춘다.

@<꼭짓점이 하나도 없으면 멈춘다@>=
if n == 0 {
	fmt.Fprintf(os.Stderr, "Sorry, the graph has no vertices!\n")
	os.Exit(-8)
}

@ 다섯째, 원본은 이웃이 하나도 없는 꼭짓점을 섞고 나서 초기화하지 않은 포인터 |b|를
쓴다. 이웃을 섞는 반복문은 한 번도 돌지 않았는데 그 뒤의 `|b->next=nil|'은
그대로 하기 때문이다. 그 앞 꼭짓점의 마지막 호가 |b|에 남아 있으면 이미 |nil|인
것에 다시 |nil|을 쓰니 탈이 없지만, 첫 꼭짓점이 고립되어 있으면 |b|는 아무것도
가리키지 않는다. 원본을 \.{-O2}로 컴파일하면 운 좋게 돌았지만 \.{-O0}으로 컴파일하면
세그먼테이션 오류로 죽었다. 이 판은 호 리스트 대신 슬라이스 |nbr|를 채우니 그런
일이 없다.

@ 결함이라고 하기는 어렵지만 적어 둘 것이 둘 있다.

먼저, 이 프로그램은 무향 그래프를 전제한다. 유향 그래프를 주면 인접 행렬 |adj|는
번호가 큰 쪽으로 가는 호로만 채워지고 이웃 목록은 나가는 호로 채워지니, 두 가지가
서로 맞지 않는다. 그러면 그래프에 없는 변으로 이은 ``경로''를 찍기도 한다. 원본도
꼭 그렇게 하므로 이 판도 그대로 두었다.

@ 다음으로, 원본은 고리 번호를 |unsigned int|로 세면서 해시 리스트의 머리
|hashhead|와 다음 고리 |nextl|은 |int|에 담는다. 그러니 고리 번호가 $2^{31}$에 이르면 음수가 되어 |cutoff|보다 작아
보이고, 해시 리스트가 거기서 끊긴다. 그러면 이미 본 초꼭짓점을 새것으로 여기게
된다. 한 단계에서 새 초꼭짓점을 $2^{31}$개 넘게 찾아야 하는 일이고, 그 하나하나를
한 줄씩 찍으니 출력이 수백 기가바이트에 이르러야 하므로 시험해 보지는 않았다. 이
판은 고리 번호를 $64$비트 |int|에 담으니, 원본이 멈추는 $2^{32}-1$까지 바르게 센다.
@s unsigned int

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 \.{libgb}와 함께 컴파일해 이 판과 견주었다. 앞의 다섯
결함을 고친 \CEE/ 판도 따로 만들어 함께 견주었다. 견준 것은 표준 출력, 표준 오류,
종료 부호가 바이트까지 같은지다.

\smallskip
\item{$\bullet$} 그래프는 \.{SGB}의 생성기로 만들어 저장한 것들이다. 완전 그래프,
순환 그래프, 격자와 원환면, 입방체, 바퀴, $K_{3,4}$, 피터슨 그래프, 킹 그래프,
$3\times3$부터 $8\times8$까지의 나이트 그래프 스물하나, $4\times4\times4$ 격자, 미국
도시 그래프 |miles|, 무작위 다중 그래프 $348$개를 썼다. 고리가 있는 것, 유향인 것,
고립된 꼭짓점이 있는 것, 끊어진 것, 꼭짓점이 없는 것도 섞었다.
\item{$\bullet$} 원본과는 그래프 $415$개에 씨앗을 다섯씩 주어 $2075$가지를 견주었다.
원본이 끝나지 않는 고리 있는 그래프와 꼭짓점 없는 그래프는 뺐다. $2028$가지가 같았다.
원본이 $5$초 안에 끝내지 못한 큰 나이트 그래프와 $4\times4\times4$ 격자의 $39$가지는
건너뛰었다. 나머지 $8$가지는 모두 차수가 꼭짓점 수를 크게 넘는 다중 그래프 둘에서
나왔고, 둘째 결함 때문에 원본이 갱신 횟수를 틀리게 센 것이다.
\item{$\bullet$} 고친 \CEE/ 판과는 고리 있는 그래프와 꼭짓점 없는 그래프까지 넣어
그래프 $416$개에 씨앗을 다섯씩 주어 $2080$가지를 견주었다. 모두 같았다.
\item{$\bullet$} 처음 경로를 명령줄로 준 경우, 이웃하지 않는 꼭짓점, 없는 꼭짓점,
잘못된 씨앗, 꼭짓점이 $1024$개를 넘는 그래프 따위의 경우도 원본과 같았다. 다른
것은 사용법을 알리는 말에 든 프로그램 이름과, 앞에서 말한 넘치는 씨앗뿐이다.
\item{$\bullet$} 꼭짓점이 꼭 $1024$개인 $32\times32$ 격자에서는 두 프로그램 모두
메모리가 넘쳐 종료 부호 $-9$로 멈췄다. 그때까지 찍은 $5.1$기가바이트가 바이트까지
같았다.
\item{$\bullet$} 답이 옳은지는 원본과 따로 파이썬으로 따져 보았다. 꼭짓점 이름이
서로 다른 무향 그래프 $813$가지에서, 찍힌 줄마다 정말 그래프의 단순 경로인지, 순환
표시가 맞는지, 정규형인지, 한 단계 안에서 같은 경로가 두 번 나오지 않는지, 고리
번호가 차례대로 매겨지는지를 보았다. 모두 맞았다.
\smallskip

\noindent 빠르기도 견주었다. $32\times32$ 격자에서 메모리가 넘칠 때까지 원본이
$77.7$초, 이 판이 $20.3$초 걸렸다. 표준 출력은 버렸다. 차이는 거의 다 출력에서
난다. 원본은 경로마다 꼭짓점 $1023$개의 이름을 하나씩 |printf|로 찍는데, 이 판은 버퍼에
글자를 곧바로 쓴다. 두 프로그램에서 경로를 찍는 줄을 빼고 셈만 견주면 원본이
$11.9$초, 이 판이 $14.4$초로 오히려 원본이 조금 빠르다.

@* 색인.
