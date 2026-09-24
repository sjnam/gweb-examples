\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\adj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-8mu\mathrel-\!}}
\def\dadj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-12mu\to\!}}
\def\losub#1{^{\vphantom+}_{#1}} % $x^+_n+x\losub n$ 같은 자리에 쓴다
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

\def\0#1#2{\mathrel{\.{#1#2}}}

\def\title{양방향 그래프의 해밀턴 회로}

@* 들어가며.
이 프로그램은 주어진 양방향 그래프(bidirected graph)의 해밀턴 회로를 모두 찾는다.
쓰는 알고리즘이 재미있다. 회로를 이룰 변을 하나씩 골라 나가되, 고른 변이 최종
회로의 어느 자리에 놓일지는 모든 조각이 이어 붙기 전까지 모른다. 크누스는 보통의
유향 그래프를 다루는 {\mc SSDIHAM}을 바탕으로 이것을 지었다.

양방향 그래프는 Jack Edmonds와 Ellis L. Johnson이 1970년에 내놓았다. 크누스는
그런데도 마땅히 받아야 할 만큼 알려지지는 않았다고 적었다. 마디 $u$와 $v$ 사이의
변 하나에는 방향 기호 둘이 붙는다. 기호는 \.<나 \.>이니 가짓수는 넷이다.
\smallskip
$u\0<<v$ (``$u$에서 $v$로 가는 유향 변'')
\smallskip
$u\0<>v$ (``$u$와 $v$ 사이의 바깥을 보는 변'', extroverted)
\smallskip
$u\0><v$ (``$u$와 $v$ 사이의 안을 보는 변'', introverted)
\smallskip
$u\0>>v$ (``$v$에서 $u$로 가는 유향 변'')
\smallskip\noindent
(실은 정말로 다른 것은 셋뿐이다. $u\0<<v$와 $v\0>>u$는 같은 것이기 때문이다.)

@ 양방향 그래프에서 길이가 $k$인 {\it 경로\/}는 변 $k$개가 늘어선 것으로, 가운데
마디들의 양옆 기호가 서로 같아야 한다. 다시 말해 경로가 $u\0<<v$나 $u\0><v$로
시작하면 다음 변은 $v\0<<w$나 $v\0<>w$ 꼴이어야 한다. 마찬가지로 $u\0<>v$나
$u\0>>v$ 꼴의 변 다음에는 $v\0><w$나 $v\0>>w$가 와야 한다. 네 가지 변을 모두 보이는
길이 $4$인 회로를 하나 들면 이렇다.
$$w\0<<x\0<>y\0>>z\0><w$$
마디마다 양옆 기호가 같다. 마디 $w$와 $x$는 \.<로, $y$와 $z$는 \.>로 둘러싸여 있다.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{ssbidiham.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/ssbidiham.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Thu, 30 Oct 2025 04:12:19 GMT}다. 바탕이 된 {\mc SSDIHAM}과 그 바탕인
{\mc SSHAM}도 이 저장소에 \.{ssdiham.w}와 \.{ssham.w}로 옮겨 두었다. 세 프로그램은
뼈대가 같다. 원본이 {\mc SSDIHAM}과 다른 곳은 그래프를 읽어 들이는 자리와 해를
풀어 찍는 자리, 그리고 되추적에서 갈래를 되살리는 두어 줄뿐이고, 나머지는 거의 한 줄
한 줄 같다. 그래서 이 판도
\.{ssdiham.w}의 글과 코드를 거의 그대로 가져다 썼다.

그래프는 \.{SGB} 형식의 파일로 읽어 들인다. 그 일은 \pdfURL{go-sgb}%
{https://github.com/sjnam/go-sgb}의 |gbsave.RestoreGraph|가 해 준다.

프로그램이 찍는 말과 종료 부호는 원본 그대로 두었다. 그래야 두 프로그램의 출력을
바이트 단위로 견줄 수 있다. 다만 원본이 마디 없는 그래프에서 죽는 것은 고쳤다.
그 이야기는 그래프를 읽어 들이는 자리에서 한다.

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
	var i, j, k, d, t, u, v, w, mm int
	@<명령줄을 처리하고 그래프를 읽어 들인다@>@;
	@<그래프를 되추적에 맞게 준비한다@>@;
	imems, mems = mems, 0
	@<모든 해를 되추적으로 훑는다@>@;
done:
	@<결과를 알린다@>@;
	out.Flush()
	os.Exit(0)
}

@ 양방향 그래프의 마디는 많아야 |maxn|개다. 안에서는 마디 하나를 둘로 쪼개 쓰므로
배열은 대개 |2*maxn|칸이다.

@<상수@>=
const (
	maxn  = 1000     // 양방향 그래프의 마디는 많아야 이만큼
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
	mind        int             // 주어진 그래프의 가장 작은 차수
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

@ 원본은 마디가 하나도 없는 그래프를 받으면 죽는다. 그때는 가장 작은 차수 |mind|가
처음 값 |infty|로 남아 차수 $0$인 마디를 알리는 자리를 지나치고, 판을 벌이는
자리에서 보이는 마디가 없는데도 |makeinner|를 불러 |vis[-1]|을 짚는다. 원본은
세그멘테이션 오류로 끝나고, \GO/라면 범위 밖이라며 멈춘다. 바탕인 {\mc SSDIHAM}도
똑같이 죽는다. 그 바탕인 {\mc SSHAM}은 죽지는 않지만 있지도 않은 해를 $999$개나
센다. 이 판은 마디가 너무 많을 때처럼 거절하고 끝낸다. 크누스가 쓴 말이 없으니 말은
내가 지었다. \.{ssdiham.w}와 \.{ssham.w}도 같은 식으로 고쳤다.

@<그래프 파일을 읽어 들인다@>=
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
	if nn == 0 {
		fmt.Fprintf(os.Stderr, "Sorry, graph %s has no vertices!\n", os.Args[1])
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
이 프로그램은 양방향 그래프 |g|에서 출발해 양방향 회로 하나만 남을 때까지 변을
걷어내는 알고리즘이라고 볼 수 있다.

양방향 그래프 $B$를 해밀턴 회로의 수가 똑같은 무향 그래프 $G$로 바꾸는 간단한
방법이 있다. 양방향 그래프 $B$의 마디 $v$ 하나는 $G$의 마디 셋 $\{v^-,v,v^+\}$가
된다. 그리고 $B$의 변 $u\0<<v$는 $G$의 변 $u^-\adj v^+$가 되고, 변 $u\0<>v$는
$u^-\adj v^-$가, 변 $u\0><v$는 $u^+\adj v^+$가 된다. 또 $B$의 마디 $v$마다 $G$에는
변 둘 $v^-\adj v\adj v^+$가 있다. 그러면 $B$에 들어가며에서 본 길이 $4$인 회로가
있는 것과 $G$에 회로
$$w^+\adj w\adj w^-\adj x^+\adj x\adj x^-\adj y^-\adj y\adj y^+
\adj z^-\adj z\adj z^+\adj w^+$$
가 있는 것은 같은 말이다. 원본은 이 바꿈이 누구의 것인지 적지 않았지만,
{\mc SSDIHAM}에서 본 R. M. Karp의 바꿈(1972)을 넓힌 것이다. 유향 그래프는 변이 모두
$u\0<<v$ 꼴인 양방향 그래프이기 때문이다.

@ 이 바꿈을 쓰면 {\mc SSBIDIHAM}이 맞닥뜨린 양방향 그래프 문제를 {\mc SSHAM}이 이미
푼 무향 그래프 문제로 돌릴 수 있다. 하지만 더 잘할 수 있다. 첫째, 마디 $v$는 필요
없고 부호 붙은 마디 $v^-$와 $v^+$만 있으면 된다. 둘째, 남은 그래프에서 부호 붙은
마디 사이의 변은 두 끝 가운데 어느 하나의 차수가 $1$이면 회로에 반드시 넣게 할 수
있다.

그래서 사용자의 $n$마디 양방향 그래프를 계산하는 동안 $2n$마디 무향 그래프 |g|로
여긴다. 우리 목표는 |g|의 완전 매칭 가운데, 있지 않은 변 $n$개 $v^-\adj v^+$를
보태면 회로 하나가 되는 것을 모두 찾는 것이다.

그래프 |g|에서 마디 $v^-$의 차수는 $B$에서 $v$로부터 나가는 유향 변의 수에 $v$에
닿은 바깥을 보는 변의 수를 더한 것이다. 마디 $v^+$의 차수는 $v$로 들어오는 유향
변의 수에 $v$에 닿은 안을 보는 변의 수를 더한 것이다.

@ 원본에는 이 자리에 ``이 무향 그래프 |g|는 이분 그래프이고, 두 쪽에 마디가 $n$개씩
있다''는 문장이 하나 더 있다. {\mc SSDIHAM}에서 가져온 문장인데, 거기서는 옳다.
변이 모두 $u^-\adj v^+$ 꼴이라 $-$ 쪽과 $+$ 쪽을 잇기 때문이다. 하지만 여기서는
바깥을 보는 변과 안을 보는 변이 같은 부호끼리 잇는다. 이를테면 바깥을 보는 변 셋
$a\0<>b$, $b\0<>c$, $c\0<>a$는 |g|에서 세모 $a^-\adj b^-\adj c^-\adj a^-$가 되니,
|g|는 어떻게 갈라도 이분 그래프가 아니다. 프로그램은 이 성질에 기대지 않으므로
문장만 뺐다.

$$\mplibcode
beginfig(1);
  u := 17mm;
  for k = 0 upto 3:
    z[k] = (k*u, 0); z[k+4] = (k*u, -1.15u); z[k+8] = (k*u, -2.05u);
    draw z[k+4] -- z[k+8] dashed evenly withpen pencircle scaled .4pt;
  endfor
  pickup pencircle scaled .7pt;
  path cl, cg;
  cl = z3 {dir 250} .. (1.5u, -.5u) .. {dir 110} z0;
  cg = z11 {dir 250} .. (1.5u, -2.7u) .. {dir 110} z8;
  draw z0 -- z3; draw cl;
  label.top(btex \.< etex, .2[z0,z1]); label.top(btex \.< etex, .8[z0,z1]);
  label.top(btex \.< etex, .2[z1,z2]); label.top(btex \.> etex, .8[z1,z2]);
  label.top(btex \.> etex, .2[z2,z3]); label.top(btex \.> etex, .8[z2,z3]);
  label.rt(btex \.> etex, point .2 of cl); label.lft(btex \.< etex, point 1.8 of cl);
  label.lft(btex $w$ etex, z0); label.bot(btex $x$ etex, z1);
  label.bot(btex $y$ etex, z2); label.rt(btex $z$ etex, z3);
  pickup pencircle scaled 1pt;
  draw z4 -- z9; draw z5 -- z6; draw z10 -- z7; draw cg;
  for k = 0 upto 11: fill fullcircle scaled 3.5pt shifted z[k]; endfor
  label.top(btex $w^-$ etex, z4); label.top(btex $x^-$ etex, z5);
  label.top(btex $y^-$ etex, z6); label.top(btex $z^-$ etex, z7);
  label.lft(btex $w^+$ etex, z8); label.bot(btex $x^+$ etex, z9);
  label.bot(btex $y^+$ etex, z10); label.rt(btex $z^+$ etex, z11);
endfig;
\endmplibcode$$
\figcap{위는 들어가며에서 본 회로 $w\0<<x\0<>y\0>>z\0><w$다. 변마다 두 끝 가까이에
그 끝의 기호를 적었다. 아래는 그것을 나타내는 |g|다. 굵은 변 넷은 완전 매칭이고,
점선 넷 $v^-\adj v^+$를 보태면 회로 하나가 된다. 굵은 변 $x^-\adj y^-$와
$z^+\adj w^+$처럼 같은 부호끼리 잇는 변도 있다.}

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

@ 그래프 |g|의 변은 서로 반대로 달리는 호 한 쌍으로 여긴다. (이를테면 변
$u^+\adj v^+$는 실제로는 호 $u^+\dadj v^+$와 호 $v^+\dadj u^+$ 둘로 다룬다.) 변을
지울 때 둘 가운데 하나만 지워야 할 때가 잦다. 알고리즘이 둘 다에 매달리지는 않기
때문이다.

알고리즘은 쓸모없는 변을 걷어내기만 하는 것이 아니라 걷어내지 {\it 않을\/} 변을
고르기도 한다. 고른 변은 \&{edge} 구조체의 배열 |e|에 쌓인다. 구조체에는 마디 둘
|u|와 |v|가 들어 있다. 고른 변 가운데 $k$번째 것이 $s\adj t$이면, 어느 마디에서 가지를
쳤는지 또는 어느 마디가 방아쇠를 당겼는지에 따라 |e[k].u|${}=s$이고
|e[k].v|${}=t$이거나, |e[k].u|${}=t$이고 |e[k].v|${}=s$다.

@<자료형@>=
type edge struct {
	u, v int // 이 변이 잇는 마디 둘
}

@ @<전역 변수@>=
var (
	e    [maxn + 1]edge // 지금까지 고른 변들
	eptr int            // 지금까지 이만큼 골랐다
)

@ 마디 $s$의 부호를 뒤집은 것을 $\bar s$로 적자. (곧 $s=v^-$이면 $\bar s=v^+$이고,
그 거꾸로도 마찬가지다.) 고른 변들 가운데
$$\bar s_0\adj s_1,\ \bar s_1\adj s_2, \ \ldots, \ \bar s_{k-1}\adj s_k$$
꼴의 극대인 부분경로가 있고 $s_0$과 $\bar s_k$가 다른 어떤 고른 변에도 걸려 있지
않다면, $s_0$과 $\bar s_k$를 ``바깥'' 마디라 부르고 $\bar s_0$, $s_1$, $\bar s_1$,
\dots, $\bar s_{k-1}$, $s_k$를 ``안쪽''이라 부른다. 바깥도 안쪽도 아닌 마디는 ``맨몸''이다. 모든 마디는 맨몸으로
태어나 언젠가 옷을 입는다. 끝에 가면 마지막으로 고른 변의 두 마디만 빼고 모두
안쪽이 되고, 고른 변들이 곧 해밀턴 회로가 된다.

알고리즘이 나아가는 동안 마디 |v|마다 정수 둘이 딸린다. 짝 |vrt[v].m|과 차수
|vrt[v].d|다. 위의 부분경로에서 $s_0$의 짝은 $\bar s_k$이고 $\bar s_k$의 짝은
$s_0$이다. 그 규칙이 모든 바깥 마디의 짝을 정한다. 맨몸인 마디의 짝은 $-1$이다.
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
스탠퍼드 그래프베이스는 무향 그래프와 유향 그래프를 다루도록 설계되었을 뿐, 양방향
그래프는 염두에 두지 않았다. 그러니 양방향 그래프를 어떻게 나타낼지 정해야 한다.

크누스는 이 프로그램이 실험적이라고 적었다. 양방향성을 다뤄 보는 첫 시도라서, 우선은
다음처럼 조금 별난 방식으로 정해 두었다고 한다. 마디 $u$와 $v$ 사이의 변은 $u$에
닿은 변 목록에 끝이 $v$인 항목을 두거나, $v$에 닿은 변 목록에 끝이 $u$인 항목을
두거나, 둘 다 해서 나타낸다. (둘 다 주었다면 서로 맞아야 한다.) 마디 $u$와 $v$
사이에는 변이 넷까지, 가지마다 하나씩 있을 수 있다.

마디 $u$에 닿은 변 목록 안에서라면 길이를 $4$로 나눈 나머지가 변의 가지를 정한다.
\smallskip
\item{$\bullet$} 길이가 $1$이면 변 $u\0<<v$다.
\item{$\bullet$} 길이가 $0$이면 변 $u\0<>v$다.
\item{$\bullet$} 길이가 $2$이면 변 $u\0><v$다.
\item{$\bullet$} 길이가 $3$이면 변 $u\0>>v$다.
\smallskip\noindent
이를테면 보통의 유향 그래프는 호의 길이가 모두 $1$이면 그대로 양방향 그래프로
읽힌다.

@ 명령줄 선택항 가운데 하나는 입력 그래프를 무작위로 흩게 한다. 우리 그래프의 마디
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
|nbr|과 |adj|를 채운다. 가는 김에 제 고리가 있는지도 살핀다. 마디 $v$의 목록에 든
항목 하나는 길이에 따라 |g|의 변 하나가 되니, 두 끝의 이웃 목록에 서로를 넣는다.
앞서 본 변은 다시 넣지 않는다. 그러니 같은 변을 두 끝의 목록에 다 적어도, 같은
목록에 두 번 적어도 한 번으로 친다. 그렇게 센 변의 수가 |mm|이다.

@<|nbr|과 |adj| 배열을 만든다@>=
for i = 0; i < 2*nn; i++ {
	mems++
	for j = 0; j < 2*nn; j++ {
		mems++
		adj[i][j] = infty
	}
}
for mm, v = 0, 0; v < nn; v++ {
	rmems++
	vp := perm[v]
	mems += 2
	vrt[vp+vp].m, vrt[vp+vp+1].m = -1, -1
	mems++
	for a := g.Vertices[v].Arcs; a != nil; mems, a = mems+1, a.Next {
		@<항목 |a|를 자료구조에 넣는다@>@;
	}
}
if randomizing {
	@<이웃 목록을 뒤섞는다@>@;
	mems += rmems // |perm|이 항등이면 |rmems|는 무시한다
}

@ 길이 $l$은 $4$로 나눈 나머지만 본다. 원본은 |l&0x3|으로 거르므로 음수 길이도
$2$의 보수로 읽힌다. \GO/의 |&|도 부호 있는 정수를 $2$의 보수로 다루니 결과가
같다.

@<항목 |a|를...@>=
mems++
u = int(g.Index(a.Tip))
l := int(a.Len)
if u == v {
	fmt.Fprintf(os.Stderr, "graph %s has a self loop %s--%s!\n",
		os.Args[1], g.Vertices[v].Name, g.Vertices[u].Name)
	os.Exit(-44)
}
rmems++
up := perm[u]
var uu, vv int
switch l & 0x3 {
case 0:
	vv, uu = vp+vp, up+up
case 1:
	vv, uu = vp+vp, up+up+1
case 2:
	vv, uu = vp+vp+1, up+up+1
case 3:
	vv, uu = vp+vp+1, up+up
}
if adj[vv][uu] == infty { // 아직 보지 못한 변이다
	@<변 |vv|--|uu|를 넣는다@>@;
}

@ @<변 |vv|--|uu|를...@>=
mems++
d = vrt[vv].d
mems += 2
nbr[vv][d] = uu
mems += 2
adj[vv][uu] = d
mems++
vrt[vv].d, degree[vv] = d+1, d+1
mems++
dd := vrt[uu].d
mems += 2
nbr[uu][dd] = vv
mems += 2
adj[uu][vv] = dd
mems++
vrt[uu].d, degree[uu] = dd+1, dd+1
mm++

@ 마디의 이웃 목록은 모든 항목을 넣은 뒤에야 다 차므로, 흩는 일은 맨 나중에 한꺼번에
한다. 그 점이 목록 하나를 그 자리에서 채우던 {\mc SSDIHAM}과 다르다.

@<이웃 목록을 뒤섞는다@>=
for v = 0; v < 2*nn; v++ {
	mems++
	for j = 1; j < vrt[v].d; j++ {
		mems += 4
		k = int(rng.Unif(int64(j + 1)))
		mems += 2
		u, w = nbr[v][j], nbr[v][k]
		mems += 2
		nbr[v][j], nbr[v][k] = w, u
		mems += 2
		adj[v][w], adj[v][u] = j, k
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

@ 차수가 $0$인 마디가 있으면 해밀턴 회로가 있을 수 없다. 말할 때는 부호까지 붙여
어느 쪽이 막혔는지 알린다.

@<그래프의 크기를 알린다@>=
if mind < 1 {
	fmt.Fprintf(out, "There are no Hamiltonian cycles, because %s has degree 0!\n",
		name(curv))
	out.Flush()
	os.Exit(0)
}
fmt.Fprintf(os.Stderr, "OK, I've got a bidigraph with %d vertices, %d edges,\n", nn, mm)
fmt.Fprintf(os.Stderr, " and minimum degree %d.\n", mind)

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

@ 여기서 미묘한 점 하나를 짚어야겠다. 입력 양방향 그래프가 그냥 마디 둘 $\{0,1\}$에
변 둘 $0\0<<1\0<<0$이라 하자. 그러면 그것을 나타내는 그래프에는 마디 넷
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

{\mc SSDIHAM}은 |nd[level].i|를 무턱대고 하나 늘렸지만, 이 프로그램은 갈래가
남았을 때만 늘려 적는다. 갈래가 다했으면 이 수준은 곧 버려지니 적을 까닭이 없다.
그만큼 mem 하나를 아낀다. 갈래가 다했을 때 뿌리 수준이면 {\mc SSDIHAM}은 곧장
|done|으로 갔지만, 이 프로그램은 |backup|으로 간다. 거기서 수준이 $-1$이 되어 어차피
|done|으로 가니 하는 일은 같다.

@<|d|와 |curi|를 되살리고...@>=
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
{\mc SSDIHAM}에서는 변의 두 끝 가운데 어느 쪽이 $+$인지만 보면 다음 마디를 알았지만,
양방향 그래프에서는 그 요령이 통하지 않는다. 변 $u^-\adj v^-$처럼 두 끝의 부호가
같을 수 있기 때문이다. 그래서 부호를 버리고 무향 그래프처럼 푼다. 마디마다 회로에서
이웃한 두 마디를 |v1|과 |v2|에 적고, 마디 $0$에서 출발해 온 쪽이 아닌 이웃으로
한 걸음씩 나아가 다시 $0$에 닿을 때까지 따라간다.

마디가 둘뿐이면 두 이웃이 같은 마디다. 그래도 탈이 없다. 둘째 걸음에서 온 쪽과
견주는 |v1[path[k-1]] == path[k-2]|가 참이 되어 |v2|로 가는데, 그것이 곧 $0$이다.

@<지금 해를 풀어서 찍는다@>=
for k = 0; k < nn; k++ {
	v1[k] = -1
}
for k = 0; k < nn; k++ {
	i, j = e[k].u>>1, e[k].v>>1
	@<마디 |i|와 |j|를 서로의 이웃으로 적는다@>@;
}
@<마디 $0$에서 회로를 따라간다@>@;
for k = 0; k <= nn; k++ {
	fmt.Fprintf(out, "%s ", basename(path[k]))
}
fmt.Fprintf(out, "#%d\n", count)

@ @<마디 |i|와 |j|를 서로의...@>=
if v1[i] < 0 {
	v1[i] = j
} else {
	v2[i] = j
}
if v1[j] < 0 {
	v1[j] = i
} else {
	v2[j] = i
}

@ @<마디 $0$에서 회로를...@>=
path[0], path[1] = 0, v1[0]
for k = 2; ; k++ {
	if v1[path[k-1]] == path[k-2] {
		path[k] = v2[path[k-1]]
	} else {
		path[k] = v1[path[k-1]]
	}
	if path[k] == 0 {
		break
	}
}

@ @<전역 변수@>=
var (
	v1, v2 [maxn]int     // 마디 하나의 두 이웃
	path   [maxn + 1]int // 해밀턴 회로를 도는 차례
)

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
몇 가지 그래프에 돌려 보았다. 셈이 맞는지 손으로 따질 수 있는 것부터 보자. 서로
다른 두 마디 사이마다 네 가지 변이 다 있는 그래프를 완전 양방향 그래프라 하자.
마디가 $n\ge3$개이면 여기에는 해밀턴 회로가 $(n-1)!\,2^{n-1}$개 있다. 마디를 도는
차례는 무향 회로로 $(n-1)!/2$가지다. 그리고 마디마다 회로에서 닿은 두 변 가운데
어느 쪽이 $v^-$에 붙을지를 두 가지로 고를 수 있는데, 네 가지 변이 다 있으니 어떻게
골라도 알맞은 변이 있다. 그래서 $(n-1)!/2\cdot2^n$이다. 프로그램은 $n=3$, \dots,
$7$에서 $8$, $48$, $384$, $3840$, $46080$개를 찾는다.

$$\vbox{\halign{#\hfil\quad&\hfil#\quad&\hfil#\quad&\hfil#\cr
\rm 그래프&\rm 회로&\rm 탐색 나무의 마디&\rm mem\cr
\noalign{\smallskip}
완전 양방향 그래프, $n=3$&8&12&$238+1207$\cr
완전 양방향 그래프, $n=4$&48&78&$445+7598$\cr
완전 양방향 그래프, $n=5$&384&632&$716+59395$\cr
완전 양방향 그래프, $n=6$&3840&6330&$1051+593406$\cr
완전 양방향 그래프, $n=7$&46080&75972&$1450+7124375$\cr
$4\times5$ 판 격자 그래프&28&209&$2689+25207$\cr
$5\times6$ 판 나이트 그래프&16&2214&$5667+368624$\cr
$6\times6$ 판 나이트 그래프&19724&313048&$7821+49417287$\cr}}$$

@ 마디가 둘이면 위의 따짐은 통하지 않는다. 도는 차례가 $1/2$가지일 수는 없으니까.
마디 $0$과 $1$ 사이에 네 가지 변이 다 있으면 회로는 $\{0\0<<1,\,0\0>>1\}$과
$\{0\0<>1,\,0\0><1\}$ 둘인데, 공교롭게도 공식의 값 $1!\cdot2^1$과 같다. 프로그램도
둘을 찾는데, 해를 풀어 찍으면 두 줄이 모두 \.{v0 v1 v0}이다. 해를 찍을 때 부호를 버리기
때문이다.

@ 격자 그래프와 나이트 그래프는 \.{SGB}의 |board|로 지은 무향 그래프다. 무향 그래프는
변 하나를 두 끝의 목록에 같은 길이로 적는데, |board|가 짓는 변은 길이가 $1$이다.
그러니 이 프로그램은 $u$의 목록에서 $u\0<<v$를, $v$의 목록에서 $v\0<<u$를 읽는다.
앞에서 말한 ``둘 다 주었다면 서로 맞아야 한다''는 약속을 어기는 셈이고, 변 하나가
두 방향의 호가 된다. 그래서 이 프로그램에는 \.{ssdiham.w}가 보는 것과 똑같은 유향
그래프로 보인다. 회로의 수도 탐색 나무의 크기도 \.{ssdiham.w}와 같다. $4\times5$
판에서 찾은 $28$개는 그 판의 무향 해밀턴 회로 $14$개의 두 배이고, $6\times6$
판에서 찾은 $19724$개는 \.{ssham.w}가 센 $9862$개의 두 배다.

mem은 조금 다르다. $6\times6$ 판에서 \.{ssdiham.w}는 $7253+49677200$ mem을 쓰는데,
이 프로그램은 $7821+49417287$ mem을 쓴다. 앞의 수가 $568$ 큰 것은 그래프를
읽는 방식 때문이다. {\mc SSDIHAM}은 $v^-$ 쪽 차수를 레지스터에서 세지만, 이
프로그램은 변을 넣을 때마다 두 끝의 차수를 메모리에서 읽고 쓴다. 그래서 항목 하나에
mem이 넷 더 들어 $160$개에서 $640$이 늘고, 마디마다 둘씩 덜 들어 $72$가 준다. 뒤의 수가 $259913$ 작은 것은 갈래가 다했을 때
|nd[level].i|를 적지 않아 아끼는 mem 하나 때문이다. 원본에서 그 한 줄만
\.{ssdiham.w}처럼 되돌리면 뒤의 수가 $49677200$으로 꼭 같아지는 것을 확인했다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 \.{libgb}와 함께 컴파일해 이 판과 견주었다. 표준 출력,
표준 오류, 종료 부호가 모두 바이트까지 같은지를 보았다. 사용법을 알리는 말에 든
프로그램 이름만은 빼고 견주었다.

그래프는 \.{libgb}로 지어 저장한 $80$개와 없는 파일 하나다.

\smallskip
\item{$\bullet$} 무작위 양방향 그래프 $60$개. 마디는 $2$개에서 $13$개다. 두 마디
사이마다 네 가지 변을 저마다 정한 확률로 넣었다. 변을 한쪽 끝의 목록에만 적은 것,
두 끝에 다 적은 것, 길이에 $4$의 배수를 더하거나 빼서 음수 길이까지 섞은 것이
삼분의 일씩이다.
\item{$\bullet$} 앞에서 말한 마디 둘짜리 $0\0<<1\0<<0$과 네 가지 변이 다 있는 마디
둘짜리, 들어가며의 회로 $w\0<<x\0<>y\0>>z\0><w$(한쪽 끝에만 적은 것과 두 끝에 다
적은 것), 완전 양방향 그래프 다섯($n=3$--$7$), 격자 그래프와 나이트 그래프 셋.
\item{$\bullet$} 오류와 가장자리를 보려는 것들. 회로가 없는 길, 마디 하나, 바깥을
보는 변만 있어 $+$ 쪽 차수가 $0$인 세모, 차수가 $0$인 마디가 있는 유향 룩 그래프,
회로가 없는 유향 원환면 판, 같은 변을 두 번 적은 것, 제 고리가 있는 것, 그리고
마디가 $1040$개라 너무 큰 것이다.
\smallskip

\noindent 선택항은 \.{ssdiham.w}와 똑같이 주었다. 그래프마다 선택항 조합 $20$가지와
잘못된 선택항 $6$가지다.

@ 모두 $2132$번을 견주었고 어긋난 곳은 하나도 없었다. 다만 해가 수백만에서 억
단위에 이르는 무거운 그래프 여덟 개에서는 $184$번을, 선택항 \.{t50000}을 덧붙여 해
$5$만 개에서 멈추게 한 채로 견주었다. 그 여덟 개도 선택항 없이, \.{v128}로,
\.{s2 d100000000}으로는 끝까지 돌려 견주었다. 견준 출력은 모두 합쳐 $1.9$기가바이트
남짓이다.

마디 없는 그래프는 원본이 죽으므로 견줄 수 없다. 이 판은 \.{Sorry, graph ... has
no vertices!}라고 말하고 종료 부호 $254$로 끝난다.

@ 원본 알고리즘이 옳은지도 따로 보았다. 파이썬으로 짠 단순한 깊이 우선 탐색이 마디
$0$의 $v^-$ 쪽에서 떠나 부호 붙은 마디를 따라 한 바퀴 도는 길을 모두 세게 했다.
그러면 회로 하나를 꼭 한 번 센다. 해가 적당히 적은 그래프 $63$개에서 그 수가 원본이
센 수와 모두 같았다.

또 원본을 \.{AddressSanitizer}와 \.{UndefinedBehaviorSanitizer}를 붙여 컴파일하고
마디 없는 것을 뺀 그래프 $80$개에 선택항 조합 다섯 가지씩, $400$번을 돌려 보았다.
한 번도 경고가 나지 않았다. 원본의 결함은 앞에서 말한 둘, 곧 마디 없는 그래프에서
죽는 것과 틀린 ``이분 그래프'' 문장뿐이다.

@ 속도는 원본에 못 미친다. 마디 $12$개짜리 무작위 그래프에서 해 $2436$만 개를 찾는
데(mem $55$억 남짓) 원본은 $2.66$초, 이 판은 $5.2$초쯤 걸린다. 두 배쯤이다.
mem 셈을 모두 걷어낸 판은 $3.9$초이니, 벌어진 틈의 절반쯤이 mem을 세는 데서 온다.
\.{ssdiham.w}에서 따져 본 것처럼 \GO/는 |mems++|마다 메모리를 읽고 쓰기 때문이다.
나머지 절반은 mem 셈과 상관없이 \GO/ 판 자체가 느린 몫이다.

@* 색인.
