\input kotexgweb
@i types.w
\datethis

\def\adj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-8mu\mathrel-\!}}
\def\dadj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-12mu\to\!}}
\def\0#1#2{\mathrel{\.{#1#2}}}

\def\title{동적 양방향 해밀턴 회로}

@* 들어가며.
마디가 $\{1,2,\ldots,n\}$인 양방향 그래프 $G$가 주어졌다고 하자. 이 프로그램은 동적
계획법을 조금 바꾼 방법으로, 유도 부분그래프 $G\mid\{1,2,\ldots,m\}$의 해밀턴 회로를
$m=1$, $2$, \dots,~$n$마다 모두 센다. 특히 $m=n$이면 $G$의 해밀턴 회로를 {\it 모두\/}
세는 셈이다. 이를테면 $G$가 $8\times20$ 판의 나이트+와지르 그래프이고 마디 번호를 열
순서로 매겼다면, $m=40$, $48$, \dots,~$160$일 때 $8\times5$, $8\times6$, \dots,
$8\times20$ 판의 닫힌 나이트+와지르 투어를 모두 세어 준다.

한번 알고 나면 착상은 단순한 편이지만 설명하기는 그리 쉽지 않다. 그래프 $G$의 변을
모은 집합이 다음 세 조건을 채우면 ``$m$-짜임''이라 부르자. (i)~$m$ 이하인 마디는
저마다 꼭 두 변에 나온다. (ii)~두 끝이 다 $m$보다 큰 변은 없다. (iii)~변들이 고리를
이루지 않는다. 그러면 $m$-짜임의 변들은 서로 떨어진 부분경로 몇 개를 이룬다. 물론
양방향 그래프의 경로이니, 가운데 마디의 양옆 기호는 같아야 한다.

이 프로그램은 변이 네 가지인 양방향 그래프를 다룬다. 바깥을 보는 변($u\0<>v$), 안으로
향하는 변($u\0<<v$), 안을 보는 변($u\0><v$), 밖으로 향하는 변($u\0>>v$)이다. 두
마디 $u$와 $v$ 사이에는 변이 넷까지 있을 수 있다. 양방향 그래프는 \.{ssbidiham.w}에서
자세히 소개했다.

@ 그래프 $G$의 ``$m$-경계'' $F_m$은 $m$보다 크면서 $\{1,\ldots,m\}$에서 닿을 수 있는
마디들의 집합이다. 어떤 $m$-짜임 안에서 $F_m$의 마디는 짜임 안의 차수가 $1$이냐
$2$냐 $0$이냐에 따라 ``바깥'', ``안쪽'', ``맨몸''으로 나뉜다. (부분경로가 $t$개이면
바깥 칸은 꼭 $2t$개다.) 바깥 마디는 ``샘''(source)이거나 ``싱크''(sink)다. 싱크 $v$를
새 변으로 늘리려면 그 변은 $v$를 향해야 한다. 곧 $v$로 들어오는 유향 변이거나 바깥을
보는 변이어야 한다. 마찬가지로 샘 $v$를 늘리는 새 변은 $v$에서 나가는 유향 변이거나
안을 보는 변이어야 한다. \.{dynadiham.w}와 달리 한 부분경로의 두 끝이 둘 다 샘이거나
둘 다 싱크일 수도 있다.

바깥, 안쪽, 맨몸 칸이 같고, 바깥 칸의 종류(샘인지 싱크인지)가 같고, 바깥 칸끼리
짝짓는 방식도 같으면 두 $m$-짜임은 {\it 동치\/}다.

이 프로그램은 $m=1$, $2$, \dots에 대해 동치류마다 $m$-짜임이 몇 개인지를 세고, 그
곁다리 셈들로 본래 할 일, 곧 $\{1,\ldots,m\}$ 위의 $m$-회로를 세는 일을 해낸다.
동치류는 경계의 마디마다 부호를 붙인 수열로 나타낸다. 안쪽 칸은 $0$, 맨몸 칸은
$1$이고, $j$번째 부분경로의 바깥 칸은 $2j+[\hbox{샘}]$이다($1\le j\le t$).

@ 예를 들어 $G$가 $4\times3$ 판의 나이트+와지르 그래프라 하자. 두 칸 $u$와 $v$ 사이에
나이트 움직임이 있으면 $u\0<>v$이고, 와지르 움직임이 있으면 $u\0><v$다. (``와지르''는
옛 장기 말로, 움직임이 넷뿐이다. 곧 룩과 킹이 다 할 수 있는 움직임이다.) 마디 이름을
1부터 12까지 대신 칸 이름 00, 10, 20, 30, 01, 11, \dots, 22, 32로 부르자. $4$-짜임
가운데 하나는 다음 변 일곱으로 되어 있다.
$$00\0<>21,\quad 00\0><01,\quad 10\0<>02,\quad 10\0><11,\quad 20\0<>01,\quad
20\0><30,\quad 30\0<>22.$$
그러니 부분경로가 $t=2$개다. 곧 $21\0<>00\0><01\0<>20\0><30\0<>22$와
$11\0><10\0<>02$다. 그래서 경계의 칸 (01, 11, 21, 31, 02, 12, 22, 32)의 부호는
차례로 (0, 2, 5, 1, 3, 1, 5, 1)이다. 첫 부분경로의 두 끝 21과 22가 둘 다 샘이라는
점을 눈여겨보라.

모든 $(m-1)$-짜임의 셈을 이미 알고 있다면 모든 $m$-짜임의 동치류를 찾아 세는 것은
어렵지 않다. $(m-1)$-짜임의 ``뒤''는 마디 $m$이 바깥이냐 안쪽이냐 맨몸이냐에 따라 새
변을 $1$개, $0$개, $2$개 보탤 뿐이기 때문이다.

@ 크누스가 붙인 내력을 옮긴다.

\medskip{\narrower\noindent
[{\it 내력:}\enspace 이 프로그램의 첫 판은 Peter Weigel이 2025년에 D.~E. Knuth의
{\mc DYNAHAM}을 바탕으로 썼다. 그 뒤 Knuth가 {\mc DYNAHAM}의 자료구조를 몇 가지
근본적으로 개선했고, 그것을 이 코드에도 알맞게 고쳐 넣었다.]\par}\medskip

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{dynabidiham.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/dynabidiham.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Sat, 29 Aug 2026 04:05:00 GMT}다. 연작의 마지막으로 옮겼지만, 유향판
\.{dynadiham.w}는 이 프로그램을 고쳐 지은 것이니 사실은 그쪽의 바탕이다.

두 프로그램은 거의 같다. 다른 곳은 두 군데다. 유향판은 호마다 반대 방향의 짝 호를
만들어 넣지만, 이 프로그램은 양방향 그래프를 그대로 읽고 빠진 짝 호만 채운다.
그리고 한 부분경로의 두 끝이 같은 종류일 수 있으니 트라이에서 끝점마다 두 부호의
자리를 다 둔다. 그래서 이 판도 \.{dynadiham.w}의 글과 코드를 가져다 쓰고 다른 곳만
고쳤다.

@ 그래프는 \.{SGB} 형식의 파일로 읽어 들인다. 그 일은 \pdfURL{go-sgb}%
{https://github.com/sjnam/go-sgb}의 |gbsave.RestoreGraph|가 해 준다. 프로그램이 찍는
말과 종료 부호는 원본 그대로 두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄
수 있다.

\.{dynadiham.w}에서처럼 제 고리는 원본이 거절하고, 바깥 마디에 변이 셋 붙는 경우도
원본이 거른다. 남은 결함 둘, 곧 압축한 트라이의 넘침을 제때 알아채지 못하는 것과
마디 없는 그래프에서 죽는 것은 똑같이 고쳤다. 큰 수가 넘칠 때 찍는 말의 오타도
고쳤다.

@ 뼈대는 이렇다. $m=1$, $2$, \dots마다 옛 트라이에 든 $(m-1)$-동치류를 하나씩 꺼내
그 뒤들을 새 트라이의 $m$-동치류에 보탠다.

@c
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"slices"
	@#
	"github.com/sjnam/go-sgb/gbgraph"
	"github.com/sjnam/go-sgb/gbsave"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	var j, k, t, x, ik, iv int
	@<명령줄을 처리한다@>@;
	@<초기화한다@>@;
	for m = 1; ; m++ {
		@<앞선 경계를 찍는다@>@;
		if wtptr == 0 {
			@<마지막 보고를 하고 끝낸다@>@;
		}
		@<$m$-동치류의 트라이를 $(m-1)$-동치류의 옛 트라이로 간수한다@>@;
		@<$m$-동치류를 받을 새 트라이를 연다@>@;
		@<옛 동치류마다 그 뒤를 새 트라이에 보탠다@>@;
		reportCycles(m)
	}
}

@ @<상수@>=
const (
	precision    = 100      // 십진 자릿수를 이만큼까지 다룬다
	progressMask = 0x1fffff // $2^{21}$ 걸음마다 진행을 알린다
	maxn         = 300      // 그래프의 마디는 많아야 이만큼
)

@ @<전역 변수@>=
var (
	m int            // 지금 다루는 짜임의 $m$
	n int            // 그래프 |g|의 마디 수
	g *gbgraph.Graph // 주어진 그래프
)

@ 원본은 표준 오류로 말을 아주 많이 한다. \CEE/의 표준 오류는 버퍼가 없지만, \GO/에서
글줄마다 시스템 호출을 하면 느리니 버퍼에 모은다. 원본이 |fflush(stderr)|를 하는
자리와 표준 출력에 쓰기 직전, 그리고 끝날 때마다 비운다. 그러면 두 흐름이 한
터미널에 섞여 나올 때의 차례도 원본과 같다.

@<전역 변수@>=
var errw = bufio.NewWriter(os.Stderr) // 표준 오류의 버퍼

@ 끝낼 때는 늘 버퍼를 비우고 끝낸다.

@<함수들@>=
func quit(code int) {
	errw.Flush()
	os.Exit(code)
}

@ 명령줄에는 그래프 파일 이름 하나만 온다.

원본은 마디 없는 그래프를 받으면 죽는다. 처음 경계 $\widehat F_0=\{1\}$을 찍으려고
|fr[0]|을 읽는데, 마디가 없으니 거기 든 $0$을 마디 번호로 알고 마디 배열 바로 앞을
짚기 때문이다. \.{AddressSanitizer}는 이것을 힙 넘침으로 잡는다. 이 판은 마디가 너무
많을 때처럼 거절한다. 말은 \.{ssbidiham.w}에서 지은 것을 그대로 쓰고, 종료 부호는
마디가 너무 많을 때와 같은 $-3$을 쓴다.

@<명령줄을 처리한다@>=
if len(os.Args) != 2 {
	fmt.Fprintf(errw, "Usage: %s foo.gb\n", os.Args[0])
	quit(-1)
}
var err error
if g, err = gbsave.RestoreGraph(os.Args[1]); err != nil {
	fmt.Fprintf(errw, "I couldn't reconstruct graph %s!\n", os.Args[1])
	quit(-2)
}
n = int(g.N)
if n > maxn {
	fmt.Fprintf(errw, "Recompile me: I allow at most %d vertices!\n", maxn)
	quit(-3)
}
if n == 0 {
	fmt.Fprintf(errw, "Sorry, graph %s has no vertices!\n", os.Args[1])
	quit(-3)
}
@<변 목록에 짝 호가 다 있는지 살핀다@>@;
fmt.Printf("Dynamic Hamiltonian cycles of the bidirected graph %s", g.ID)
fmt.Printf(" (%d vertices, %d edges):\n", n, g.M/2)

@ 마디 $u$와 $v$ 사이의 변은 $u$에 닿은 변 목록에 끝이 $v$인 항목을 두거나, $v$에
닿은 목록에 끝이 $u$인 항목을 두거나, 둘 다 해서 나타낸다. 이 프로그램의 자료구조
안에는 두 번 나타나지만 입력에서는 한 번만 적으면 된다. 앞서 말했듯 $u$와 $v$
사이에는 변이 넷까지, 가지마다 하나씩 있을 수 있다.

마디 $u$에 닿은 목록 안에서라면 길이를 $4$로 나눈 나머지가 변의 가지를 정한다.
길이가 $1$이면 $u\0<<v$, $0$이면 $u\0<>v$, $2$이면 $u\0><v$, $3$이면 $u\0>>v$다.
\.{ssbidiham.w}와 같은 약속이다.

@ 원본에는 이 코드를 Filip Stappers에게서 착안했다고 적혀 있다. 항목마다 상대편
목록에 짝 호가 있는지 찾아보고, 없으면 만들어 넣는다. 짝 호의 길이는 $1$과 $3$을
맞바꾸고 $0$과 $2$는 그대로 둔 것이다. 원본은 길이를 |int|에 담으니 여기서도
서른두 비트로 자른다.

이 약속에는 명세 밖의 틈이 하나 있다. 같은 가지의 변을 두 번 적으면, 낮은 번호
마디의 목록에 적은 것은 두 변으로 세고 높은 번호 마디의 목록에 적은 것은 한 변으로
센다. 짝 호는 한 번만 만들어 넣는데, 셈에는 낮은 번호 쪽 목록만 쓰기 때문이다. 이를테면
\.{ssbidiham.w}를 시험한 그래프 가운데 변 $0\0<<1$을 마디 $0$의 목록에 두 번 적은
세모에서, 이 프로그램은 회로를 둘로 센다. 같은 쌍 사이에 같은 가지가 하나뿐인 그래프에서는
탈이 없으니 원본대로 두었다.

@<변 목록에 짝 호가...@>=
for u := 0; u < n; u++ {
	for a := g.Vertices[u].Arcs; a != nil; a = a.Next {
		v, alen := int(g.Index(a.Tip)), int(int32(a.Len))
		if v == u {
			fmt.Fprintf(errw, "graph has a self-loop %s--%s (length %d)!\n",
				g.Vertices[u].Name, g.Vertices[v].Name, alen)
			quit(-4)
		}
		aalen := alen ^ (alen & 1 << 1) // 짝 호의 길이
		aa := g.Vertices[v].Arcs
		for ; aa != nil; aa = aa.Next {
			if int(g.Index(aa.Tip)) == u && (int(aa.Len)^aalen)&0x3 == 0 {
				break // 짝이 있다
			}
		}
		if aa == nil { // 짝이 없었지만 이제 생긴다
			g.NewArc(&g.Vertices[v], &g.Vertices[u], int64(aalen))
		}
	}
}

@* 낮은 수준의 셈.
크누스는 기본 연장을 모두 손수 지었다. 쉬운 것들이고 최적화할 필요도 없기
때문이다.

먼저 자릿수가 많은 수를 더하고 찍는 함수가 있어야 한다. 기수는 $10^{18}$이다.
$2^{63}$이 $9\cdot10^{18}$보다 크니 한 낱말에 들어가고 더해도 넘치지 않는다.

@<상수@>=
const (
	radix   = 1000000000000000000     // 기수 $10^{18}$
	maxprec = (precision + 17) / 18   // 큰 수 하나에 이만큼의 여덟 바이트 낱말
)

@ @<자료형@>=
type bignum struct {
	val [maxprec]int64 // 기수 $10^{18}$의 자리들, 낮은 자리부터
}

@ @<전역 변수@>=
var (
	zero  bignum // 상수 $0$
	one   bignum // 상수 $1$
	infty bignum // 가장 큰 큰 수
	prec  int    // 지금까지 필요했던 가장 큰 자릿수
)

@ @<초기화한다@>=
one.val[0] = 1
for k = 0; k < maxprec; k++ {
	infty.val[k] = radix - 1
}
prec = 1

@ 자릿수 |prec|은 모든 큰 수가 함께 쓴다. 어느 수가 한 자리 넘치면 |prec|을
늘리는데, 다른 수들의 윗자리는 늘 $0$이니 탈이 없다. 원본은 두 번째 수를 값으로
넘기지만 여기서는 포인터로 넘긴다. 두 인자가 같은 수를 가리키는 일은 없다.

@<함수들@>=
func addToBignum(x *bignum, delta *bignum) {
	c := int64(0)
	k := 0
	for ; k < prec; k++ {
		s := x.val[k] + delta.val[k] + c
		if s >= radix {
			c, x.val[k] = 1, s-radix
		} else {
			c, x.val[k] = 0, s
		}
	}
	if c != 0 {
		if prec == maxprec {
			@<큰 수가 넘쳤으니 그만둔다@>@;
		}
		prec++
		x.val[k] = c
	}
}

@ @<함수들@>=
func bignumComp(x, y *bignum) int {
	r := 0
	for k := 0; k < prec; k++ {
		if x.val[k] != y.val[k] {
			if x.val[k] < y.val[k] {
				r = -1
			} else {
				r = +1
			}
		}
	}
	return r
}

@ @<함수들@>=
func printBignum(w io.Writer, x *bignum) {
	k := prec - 1
	for k >= 0 && x.val[k] == 0 {
		k--
	}
	if k < 0 {
		fmt.Fprint(w, "0")
		return
	}
	fmt.Fprintf(w, "%d", x.val[k])
	for k > 0 {
		k--
		fmt.Fprintf(w, "%018d", x.val[k])
	}
}

@ 부호를 찍을 수 있는 글자로 바꾼다. 안쪽은 `\.\#', 맨몸은 `\.0'이고, 바깥 칸은 부분경로
번호 한 글자 뒤에 샘이면 `\.>', 싱크면 `\.<'를 붙인다. 원본은 정적 버퍼를 돌려주지만
여기서는 문자열을 돌려준다.

@<함수들@>=
func encode(x int) string {
	switch x {
	case 0:
		return "#"
	case 1:
		return "0"
	}
	c := byte('<') // 싱크
	if x&1 != 0 {
		c = '>' // 샘
	}
	x >>= 1
	d := byte('0' + x)
	if x >= 10 {
		d = byte('a' + x - 10)
	}
	return string([]byte{d, c})
}

@ 원본의 둘째 줄은 형식 문자열이 \.{\%lldd}라서 수 뒤에 글자 `\.d'가 하나 더 붙는다.
\.{dynaham.w}의 원본에는 이 오타가 없다. 이 판은 고친다.

@<큰 수가 넘쳤으니...@>=
fmt.Fprintf(errw, "\nSorry, I can't handle numbers bigger than 10^%d!\n", 18*maxprec)
fmt.Fprintf(errw, "I had found %d classes of %d-configs so far.\n", wtptr, m)
quit(-999)

@* 트라이 구조.
중심 자료구조는 동치류마다 항목이 하나씩 있는 커다란 사전이고, \.{dynaham.w}처럼
``트라이''로 짓는다. 마디는 포인터 배열 |mem|의 구간들에, 잎은 \&{bignum} 배열
|weight|에 담는다.

잎 하나는 열쇠 $a_0a_1\ldots a_{q-1}$로 가려낸다. 여기서 $0\le l<q$마다
$0\le a_l<2|deg|$이다. 트라이에는 열쇠의 앞머리 $a_0\ldots a_{l-1}$마다($0\le l<q$)
마디가 하나씩 있고, 수준 $l=0$의 뿌리 마디는 빈 앞머리를 나타낸다.

우리 트라이의 열쇠에는 특별한 성질이 있다. 앞의 부호 $a_0\ldots a_{l-1}$을 알면
$a_l$이 될 수 있는 값이 크게 줄어든다. 이를테면 $a_0$은 $0$, $1$, $2$, $3$ 가운데
하나일 수밖에 없다. 그리고 앞머리 2053 다음에는 $0$, $1$, $4$, $5$, $6$, $7$이 올 수 있다.
\.{dynadiham.w}와 달리 이미 나온 끝점의 두 번째 부호가 샘이든 싱크든 될 수 있기
때문이다.

원본에는 옛 판 이야기도 있다. 예전에는 마디 하나를 포인터 스무 개쯤의 배열로
나타냈는데, 돌아보니 대부분이 $0$이었다. 이를테면 열쇠의 마지막 부호만 빼고 다 알면
마지막 부호는 꼭 두 가지뿐이니, 수준 $q-1$의 마디에서는 포인터 둘 말고는 모두
$0$이었다. 그래서 \.{dynaham.w}에서 본 빽빽한 방식으로 바꾸었다.

@ 부호 $a_l$이 될 수 있는 값들은 성긴 집합으로 다스린다. 한 번 나왔지만 아직 두 번
나오지 않은 끝점 번호들을 배열 |tmap|의 앞쪽 |tms|칸에 늘어놓고, 아직 한 번도
나오지 않은 가장 작은 끝점 번호를 |tmx|에 둔다. 부분 역함수도 있다. $2c$나 $2c+1$이
한 번 나왔고 두 번은 아직이면 |c=tmap[itmap[c]]|다.

수준 $l$에서 앞머리 $a_0\ldots a_{l-1}$의 마디는 |mem|의 색인인 포인터
$p=p(a_0\ldots a_{l-1})$로 가려낸다. 부호 $a_l$이 될 수 있는 값이 차례로 $0$, $1$,
$2|tmap[0]|$, $2|tmap[0]|+1$, \dots, $2|tmap|[tms-1]+1$, $2|tmx|$, $2|tmx|+1$이면, 자식
마디 $p'=p(a_0\ldots a_l)$은 차례로 |mem[p]|, |mem[p+1]|, \dots, |mem[p+2*tms+3]|에
든다. 그
앞머리 다음에 그 부호가 아직 나오지 않았으면 그 자리는 $0$이다. (|tms|가 $0$일 수도
있다. 또 $0$과 $1$이 올 수 없는 경우도, $2|tmx|$와 $2|tmx|+1$이 올 수 없는 경우도
있다.)

부호가 $a_0\ldots a_{q-1}$인 잎은 |weight|$[p(a_0\ldots a_{q-1})-1]$에 있다. 동치류의
지금 무게를 나타내는 큰 수다.

다 짓고 난 트라이는 \.{dynaham.w}에서처럼 전위 순서의 비트열로 압축한다. 새 트라이를
지을 때는 긴 형식을 쓰고, 앞의 트라이는 압축형으로 들어 있다.

@ 원본은 커다란 배열 넷을 처음에 |malloc|으로 한꺼번에 잡는다. \.{dynaham.w}에서처럼
이 판은 네 배열을 조각으로 두고 필요한 만큼 늘리며, 크기의 상한은 넘침을 알리는 데만
쓴다. 원본의 ``I can't allocate the big tables!''는 그래서 이 판에 없다.

@<상수@>=
const (
	memsize    = 3000000000 // |mem|의 크기 상한
	wtsize     = 500000000  // 동치류 수의 상한
	oldmemsize = 450000000  // |oldmem|의 바이트 수 상한 (넉넉하다)
	deg        = 15         // 동치류의 부분경로 수는 이보다 적어야 한다
)

@ 조각을 늘리는 도우미다. 적어도 |n|칸이 되게 늘리고 새 칸은 $0$으로 둔다.

@<함수들@>=
func grow[T any](s []T, n int) []T {
	if n > len(s) {
		s = slices.Grow(s, n-len(s))
		s = s[:cap(s)]
	}
	return s
}

@ @<초기화한다@>=
mem = make([]uint32, 1<<16)
oldmem = make([]uint64, 1<<10)
weight = make([]bignum, 1<<10)
oldweight = make([]bignum, 1<<10)

@ 원본의 \.{memtyp}는 |unsigned int|다. 여기서는 |uint32|로 둔다.

@<전역 변수@>=
var (
	oldp                 uint32   // 지금 다루는 옛 무게
	contribs             int64    // 옛 동치류들이 보탠 횟수
	mem                  []uint32 // 큰 트라이의 포인터들
	oldmem               []uint64 // 압축한 비트열들
	memptr               uint32   // |mem|에서 처음으로 안 쓴 칸
	wtptr                uint32   // |weight|에서 처음으로 안 쓴 칸
	q, oldq              int      // 트라이 열쇠의 길이
	code                 [maxn]int // 새 트라이에서 찾는 열쇠
	oldcode              [maxn]int // 옛 트라이의 지금 열쇠
	weight, oldweight    []bignum  // 두 트라이의 잎
	minweight, maxweight bignum    // 가장 작은 무게와 가장 큰 무게
	count                [maxn + 1]bignum // 지금까지 센 해밀턴 $m$-회로의 수
	maxdeg               int      // 지금까지 본 가장 많은 부분경로 수
	pack                 uint64   // |oldmem|에 덧붙이려고 모으는 비트
	spack                int      // |pack|에 든 아직 간수하지 않은 비트 수
	owp, omp             int      // 압축하고 풀 때의 무게 포인터와 메모리 포인터
	maxmemptr, maxwtptr, maxomp int64 // 지금까지 본 가장 큰 값
	tmap, itmap, omap, iomap [deg]int // 트라이를 위한 성긴 집합들
	tms, tmx, oms, omx       int      // 그리고 그 포인터들
)

@ 다음은 주어진 열쇠, 곧 |code| 값들의 수열에 맞는 잎을 찾아 트라이를 내려가는
과정이다. 없으면 넣는다. 원본에서는 함수 \.{trielookup}이지만 부르는 곳이
|contribute| 하나뿐이니 그 안에 끼워 넣는 절로 둔다. 끝나면 |p|가 잎의 번호이고, 그
무게는 |weight[p-1]|이다. 뿌리 마디는 \.{dynaham.w}와 달리 |p=0|이다.

@<새 트라이에서 열쇠 |code|를 찾는다@>=
tms, tmx = 0, 1
p := uint32(0)
var pp uint32
for l := 0; l < q; l, p = l+1, mem[pp] {
	j := code[l]
	if j/2 == 0 {
		pp = p + uint32(j)
	} else if j/2 == tmx { // 앞서 나온 것보다 큰 부호
		@<|tmx|를 |tmap|에 넣고 그리로 간다@>@;
	} else { // 부호 |j/2|는 앞서 나온 끝점과 짝을 이룬다
		@<|j/2|를 |tmap|에서 빼고 그리로 간다@>@;
	}
	if mem[pp] == 0 { // $a_0\ldots a_l$은 처음이다
		if l+1 < q {
			@<수준 |l+1|에 새 마디를 마련한다@>@;
		} else {
			@<새 무게를 마련한다@>@;
		}
	}
}

@ @<|tmx|를 |tmap|에...@>=
if tmx > maxdeg {
	maxdeg = tmx
	if tmx >= deg {
		fmt.Fprintf(errw, "Overflow: number of subpaths must be less than %d!\n", deg)
		quit(-66)
	}
}
tmap[tms], itmap[tmx] = tmx, tms
tms++
tmx++
pp = p + 2*uint32(tms) + uint32(j&1)

@ @<|j/2|를 |tmap|에서...@>=
tms--
k, kk := tmap[tms], itmap[j/2]
tmap[kk], itmap[k] = k, kk
pp = p + 2 + 2*uint32(kk) + uint32(j&1)

@ 미묘한 점이 하나 있다. |l+2+tms=q|이면 |tmx|를 위한 칸을 두지 않는다. |tmx|는
두 번 나와야 하는데 남은 자리가 하나뿐이기 때문이다. 끝점 하나에는 칸이 둘씩(샘과
싱크) 든다.

원본은 |memptr|를 늘리기 전에 |mem[memptr]|과 |mem[memptr+1]|을 먼저 쓴다. 넘침을
따질 때 한 칸을 더 보아 두므로 그래도 안전하다. 이 판에서도 |mem|의 길이가 늘
|memptr+1|보다 크도록 늘려 둔다.

@<수준 |l+1|에 새 마디를...@>=
slots := tms // 이미 나온 끝점 부호를 위한 칸만 둔다
if l+1+tms < q { // $0$과 $1$을 위한 칸을 둔다
	mem[memptr], mem[memptr+1] = 0, 0 // 안전하다. 위를 보라
	memptr += 2
	slots = tms + 1
	if l+2+tms == q {
		slots = tms // 위를 보라
	}
}
if int64(memptr)+2*int64(slots)+1 >= memsize {
	fmt.Fprintf(errw, "Oops: Dictionary overflow (more than %d pointers)!\n", int64(memsize))
	quit(-666)
}
mem[pp] = memptr - 2
mem = grow(mem, int(memptr)+2*slots+2)
for s := 0; s < 2*slots; s++ {
	mem[int(memptr)+s] = 0
}
memptr += 2 * uint32(slots) // 이제도 |memptr+1|은 |memsize|보다 작다

@ @<새 무게를...@>=
wtptr++
mem[pp] = wtptr
if int64(wtptr) >= wtsize {
	fmt.Fprintf(errw, "Oops: Dictionary overflow (more than %d classes)!\n", int64(wtsize))
	quit(-6666)
}
weight = grow(weight, int(wtptr))
weight[wtptr-1] = zero

@ 다음은 |mem|에 든 트라이를 압축해 |oldmem|에 넣는 되돌이 함수다.
|tmap|, |itmap|, |tms|, |tmx|를 닮은 성긴 집합 |omap|, |iomap|, |oms|, |omx|가 하나
더 있다. 이 함수는 |l=0|, |p=0|, |d=4|로 부르고, 부르기 전에
|pack=spack=omp=owp=oms=0|, |omx=1|로 둔다.

@<함수들@>=
func compress(l int, p uint32, d int) { // |d|는 수준 |l|의 마디 |p|의 차수다
	if l == q {
		@<|weight[p-1]|을 간수한다@>@;
		return
	}
	j0 := 0
	if l+oms == q {
		j0 = 2
	}
	var bits uint64
	for j, k := j0, 0; k < d; j, k = j+1, k+1 {
		if mem[int(p)+j] != 0 {
			bits += 1 << k
		}
	}
	@<|bits|를 |oldmem|에 덧붙인다@>@;
	for j, k := j0, 0; k < d; j, k = j+1, k+1 {
		if bits&(1<<k) != 0 {
			@<자식 |j|로 내려가 압축한다@>@;
		}
	}
}

@ 자식으로 내려가기 전에 성긴 집합을 고치고, 돌아와서 되돌린다. 변수 |kk|가 $0$이면
|omx|를 새로 쓴 것이다.

@<자식 |j|로 내려가 압축한다@>=
var kk, kkk int
if j/2 > 0 {
	if j/2 > oms {
		omap[oms], iomap[omx] = omx, oms
		oms++
		omx++
		kk = 0
	} else {
		oms--
		kk, kkk = omap[oms], omap[j/2-1]
		omap[j/2-1], iomap[kk] = kk, j/2-1
	}
}
compress(l+1, mem[int(p)+j], childDeg(l, oms, q))
if j/2 > 0 { // 성긴 집합에 한 일을 되돌려야 한다
	if kk == 0 {
		oms--
		omx--
	} else {
		omap[j/2-1], omap[oms], iomap[kk] = kkk, kk, oms
		oms++
	}
}

@ 수준 |l+1|의 자식이 몇 갈래인지는 압축과 풀기가 똑같이 셈한다. 끝점 하나에
갈래가 둘씩이다. 남은 자리가 열린 끝점의 수와 같으면 열린 끝점만 올 수 있고, 하나 더
많으면 $0$과 $1$이 더해지며, 그보다 많으면 새 끝점도 올 수 있다.

@<함수들@>=
func childDeg(l, s, qq int) int {
	switch {
	case l+1+s == qq:
		return 2 * s
	case l+2+s == qq:
		return 2 * (s + 1)
	}
	return 2 * (s + 2)
}

@ 원본은 |oldmem|을 |oldmemsize|{\it 바이트\/}로 잡고서, 넘침은 낱말 색인 |omp|가
|oldmemsize|에 이르는지로 따진다. \.{dynaham.w}의 원본과 같은 결함이다. 이 원본에서도
|oldmemsize|만 $800$으로 줄이고 \.{AddressSanitizer}를 붙여 마디 $12$개짜리 무작위
양방향 그래프를 돌려 보니, 넘침을 알리지 못하고 힙 넘침으로 잡혔다. 이 판은 낱말 수
|oldmemsize/8|과 견준다.

@<|bits|를 |oldmem|에...@>=
if spack+d > bitsperword {
	oldmem = grow(oldmem, omp+1)
	oldmem[omp] = pack
	omp++
	pack, spack = bits, d
	if omp >= oldmemsize/8 {
		fmt.Fprintf(errw, "Oops: oldmem overflow (more than %d bytes)!\n", oldmemsize)
		quit(-666666)
	}
} else {
	pack += bits << spack
	spack += d
}

@ @<상수@>=
const bitsperword = 64 // |oldmem| 낱말 하나의 비트 수

@ 원본은 자릿수 |prec|만큼만 옮긴다. 그 위의 자리는 어느 무게에서나 $0$이니 통째로
옮겨도 같다.

@<|weight[p-1]|을 간수한다@>=
oldweight = grow(oldweight, owp+1)
oldweight[owp] = weight[p-1]
owp++

@ @<$m$-동치류의 트라이를 $(m-1)$-동치류의 옛 트라이로...@>=
fmt.Fprintf(errw, "There are %d %d-classes,\n", wtptr, m-1)
fmt.Fprintf(errw, " resulting from %d contributions and filling %d pointers.\n",
	contribs, memptr)
spack, omp, owp, oms, omx = 0, 0, 0, 0, 1
pack = 0
oldq = q
compress(0, 0, 4)
oldmem = grow(oldmem, omp+1)
oldmem[omp] = pack // 마지막 비트들을 간수한다
if int64(omp) > maxomp {
	maxomp = int64(omp)
}

@ 옛 동치류는 압축형에서 또 다른 되돌이 함수로 되찾는다. |compress|를 거울에 비춘
모양이다. 이 프로그램의 본 일은 이 함수가 수준 |oldq|에 이르러 옛 동치류 하나를
``찾아갈'' 때 일어난다. 이 함수는 |uncompress(0,4)|로 부르고, 부르기 전에
|spack=oldp=omp=oms=0|, |omx=1|, |pack=oldmem[0]|으로 둔다.

@<함수들@>=
func uncompress(l, d int) { // 수준 |l|의 차수 |d|인 마디를 푼다
	if l == oldq {
		@<무게가 |oldweight[oldp]|인 동치류 |oldcode|를 찾아간다@>@;
		oldp++
		return
	}
	@<|bits|에 |oldmem|의 다음 |d|비트를 넣는다@>@;
	j0 := 0
	if l+oms == oldq {
		j0 = 2
	}
	for j, k := j0, 0; k < d; j, k = j+1, k+1 {
		if bits&(1<<k) != 0 {
			@<자식 |j|의 부호를 적고 내려가 푼다@>@;
		}
	}
}

@ @<|bits|에 |oldmem|의...@>=
if spack+d > bitsperword {
	omp++
	pack, spack = oldmem[omp], 0
}
bits := pack >> spack
spack += d

@ 자리 |j|의 짝수·홀수가 싱크·샘을, |j/2|가 끝점을 가리킨다. 원본은 부호를
적은 다음에 성긴 집합을 고친다.

@<자식 |j|의 부호를...@>=
var kk, kkk int
switch {
case j/2 == 0:
	oldcode[l] = j
case j/2 > oms:
	oldcode[l] = 2*omx + j&1
	omap[oms], iomap[omx] = omx, oms
	omx++
	oms++
	kk = 0
default:
	oldcode[l] = 2*omap[j/2-1] + j&1
	oms--
	kk, kkk = omap[oms], omap[j/2-1]
	omap[j/2-1], iomap[kk] = kk, j/2-1
}
uncompress(l+1, childDeg(l, oms, oldq))
if j/2 > 0 { // 성긴 집합에 한 일을 되돌려야 한다
	if kk == 0 {
		oms--
		omx--
	} else {
		omap[j/2-1], omap[oms], iomap[kk] = kkk, kk, oms
		oms++
	}
}

@* 경계.
경계 $F_m$은 $m$보다 크면서 $m$ 이하인 마디 하나에라도 이웃한 마디의 집합이라고
정했다. 여기서 $u\adj v$는 $u\0<<v$나 $u\0<>v$나 $u\0><v$나
$u\0>>v$라는 뜻이다. 그러니 $F_0=\emptyset$이고
$F_m=\bigl(F_{m-1}\cup\{v\mid m\adj v$이고 $m<v\}\bigr)\setminus m$이다. 특히
$F_1=\{v\mid 1\adj v\}$은 마디 $1$의 이웃 집합이다. 눈여겨보면
$\vert F_m\vert\ge\vert F_{m-1}\vert-1$이고 $\vert F_m\vert\le n-m$이다.

우리 목적에는 $0\le m<n$마다 {\it 늘린\/} 경계 $\widehat F_m=F_m\cup\{m+1\}$로 일하는
편이 낫다. 그러면 $m+1$은 늘 $\widehat F_m$의 원소다. 특히 $\widehat F_0=\{1\}$이다.
이렇게 바꾸어도 동치류의 정의는 달라지지 않는다. 마디 $m+1$이 원래 $F_m$에 없었다면
늘 맨몸이기 때문이다. 늘린 경계를 쓰면 프로그램이 더 간단해진다는 것을 곧 보게
된다.

@ 경계는 $m$이 자라는 동안 성긴 집합으로 간수하는 것이 제격이다. 배열 |fr|은 마디들의
순열을 담고, 짝 배열 |ifr|은 그 역순열을 담는다. 배열 |fr|의 앞쪽 |q|칸이 지금의
경계다.

더 정확히 말하면 $1\le v\le n$마다 |fr[ifr[v]]=v|이고, $0\le k<n$마다
$1\le|fr[k]|\le n$이다. 마디 $v$가 $\widehat F_m$에 드는 것은 |ifr[v]<q|일 때이고
오직 그때뿐이다. (이 약속은 $0$에서 세는 색인과 $1$에서 세는 색인을 일부러 섞는다.
크누스가 설명하기 좋으라고 마디 이름을 $\{0,\ldots,n-1\}$ 대신 $\{1,\ldots,n\}$으로
골랐기 때문이다.)

경계의 원소를 늘어놓는 차례는 트라이의 열쇠를 지을 때 중요하다. 이 구현은 원소들을
정규한 차례로 둔다. 늘린 경계 $\widehat F_m$의 크기를 $q$라 하고,
$\bigl(\widehat F_{m-1}\cup\{m+1\}\bigr)\cap\widehat F_m$의 크기를 $q_0$이라 하자.
그러면 $0<k<q_0$과 $q_0<k<q$마다 |fr[k-1]<fr[k]|가 되게 한다. 특히 늘 |fr[0]=m+1|이다.

@<전역 변수@>=
var (
	fr   [maxn]int     // 지금 경계의 순열
	ifr  [maxn + 1]int // 그 역순열
	ofr  [maxn]int     // 앞선 경계의 복사본
	q0   int           // 중간 크기의 경계 (아래를 보라)
)

@ @<초기화한다@>=
for k = 0; k < n; k++ {
	fr[k], ifr[k+1] = k+1, k
}
q = 1
mem[0], mem[1], mem[2], mem[3] = 0, 1, 0, 0 // 안쪽 없음, 맨몸 하나(마디 $1$), 싱크와 샘 없음
memptr = 4 // 뿌리 마디의 포인터 넷
weight[0], wtptr = one, 1

@ 늘린 경계를 $\widehat F_{m-1}$에서 $\widehat F_m$으로 바꾸는 일은 세 단계다.
먼저 마디 $m$을 빼고 $m+1$을 맨 앞에 둔다. 그다음 $m$의 이웃 가운데 새로 들어올 것을
넣고, 끝으로 정렬한다.

@<$\widehat F_{m-1}$에서 $\widehat F_m$으로 바꾼다@>=
for j = 1; j < q; j++ {
	ofr[j] = fr[j]
}
oldq = q
iv = ifr[m+1] // `$m+1$'은 |fr|의 어디에 있나?
q--
if iv < q { // $F_{m-1}$에 있고 마지막 원소가 아니다
	x = fr[q] // $F_{m-1}$의 마지막 원소다
	fr[0] = m + 1
	ifr[m+1] = 0
	fr[q] = m
	ifr[m] = q
	fr[iv] = x
	ifr[x] = iv // 셋을 한 바퀴 돌려 바꾼다
} else {
	fr[0], ifr[m+1] = m+1, 0
	fr[iv], ifr[m] = m, iv // |m|과 |m+1|을 맞바꾼다
	if iv != q {
		q++ // 마지막 원소를 되살린다
	}
}
q0 = q
@<$\widehat F_m\setminus\widehat F_{m-1}$의 원소를 넣는다@>@;
@<경계를 정렬한다@>@;
@<옮겨 가는 데 쓸 대응표를 마련한다@>@;

@ 마디 $m$의 목록에는 이제 짝 호까지 다 들어 있으니, 변이 어느 쪽 목록에 적혔든
이웃을 모두 만난다. 제 고리는 그래프를 읽을 때 이미 거절했으니 $k=m$인 이웃은 없다.

@<$\widehat F_m\setminus\widehat F_{m-1}$의...@>=
for a := g.Vertices[m-1].Arcs; a != nil; a = a.Next {
	k = int(g.Index(a.Tip)) + 1 // |m|의 이웃의 번호
	if k < m {
		continue
	}
	ik = ifr[k] // |k|는 |fr|의 어디에 사나?
	if ik >= q { // |k|를 경계에 넣어야 한다
		x = fr[q]
		fr[q] = k
		ifr[k] = q
		fr[ik] = x
		ifr[x] = ik
		q++
	}
}

@ 앞쪽 $q_0$개와 뒤쪽을 따로 끼워 넣기 정렬한다. 원소 |fr[0]=m+1|은 제자리다.

@<경계를 정렬한다@>=
for k = 2; k < q0; k++ {
	if fr[k] < fr[k-1] {
		t = fr[k]
		for j = k - 1; ; j-- {
			fr[j+1], ifr[fr[j]] = fr[j], j+1
			if j == 0 || fr[j-1] < t {
				break
			}
		}
		fr[j], ifr[t] = t, j
	}
}
for k = q0 + 1; k < q; k++ {
	if fr[k] < fr[k-1] {
		t = fr[k]
		for j = k - 1; ; j-- {
			fr[j+1], ifr[fr[j]] = fr[j], j+1
			if j == q0 || fr[j-1] < t {
				break
			}
		}
		fr[j], ifr[t] = t, j
	}
}

@ $m$이 한 걸음 나아가 모든 $(m-1)$-동치류를 차례로 훑을 채비가 되면, 그 경계를
찍어 두기 좋은 때다.

@<앞선 경계를 찍는다@>=
fmt.Fprintf(errw, "\nThe frontier for %d-classes is", m-1)
for k = 0; k < q; k++ {
	fmt.Fprintf(errw, " %s", g.Vertices[fr[k]-1].Name)
}
fmt.Fprint(errw, ".\n")

@* 동치류의 정규한 열쇠.
지금의 늘린 경계가 마디 $q$개 $v_1\ldots v_q$로 되어 있을 때, 동치류 하나는 안에서
|mate[1]|\dots|mate[q]|라는 표로 나타낸다. 마디 $v_j$가 맨몸이면 |mate[j]=0|, 안쪽이면
|mate[j]=-1|이고, $v_j$와 $v_k$가 한 부분경로의 두 끝이면 |mate[j]=k|다. 바깥 칸
$v_j$가 샘인지 싱크인지는 |src[j]|에 따로 적는다. 샘이면 $1$이다.

이 나타냄은 앞에서 말한 부호 수열과 다르다. 그쪽에서는 경로의 두 끝이 번호가 같은
부호를 받았다.

트라이의 열쇠는 부호의 수열 |code[0]|부터 |code[q-1]|까지다. 그러니 |mate| 표를
|code| 수열로 바꿔야 한다.

@<|mate| 표를 열쇠로 바꾼다@>=
for t, k := 0, 1; k <= q; k++ {
	j := mate[k]
	if j <= 0 {
		code[k-1] = j + 1 // 안쪽은 $0$, 맨몸은 $1$
	} else if j > k {
		t += 2
		code[k-1], code[j-1] = t+src[k], t+src[j]
	}
}

@ 거꾸로 가는 일도 귀엽다.

@<옛 열쇠를 |oldmate| 표로 바꾼다@>=
for k := 1; k+k <= oldq; k++ {
	path[k] = 0
}
for k := 1; k <= oldq; k++ {
	j := oldcode[k-1]
	if j <= 1 {
		oldmate[k] = j - 1 // 안쪽이거나 맨몸이다
		continue
	}
	oldsrc[k] = j & 1 // 부호를 샘 표시와 경로 번호로 가른다
	j >>= 1
	if e := path[j]; e == 0 {
		path[j] = k
	} else {
		oldmate[k], oldmate[e] = e, k
	}
}

@ 원본의 이웃 목록 |nbr|은 크기가 |4*maxn|인 배열이다. 한 이웃에 네 가지 변이 다
있을 수 있기 때문이다. 그런데 겹친 호가 있는 그래프에서는 그보다도 많을 수 있다.
이 판은 조각으로 두어 그런 경우에도 넘치지 않게 했다. 짝 목록 |nbrtype|에는 그
이웃으로 가는 변의 가지, 곧 길이를 $4$로 나눈 나머지를 적는다. 원본의 주석은
$0$을 ``extro'', $1$을 ``indir'', $2$를 ``intro'', $3$을 ``outdir''라 부른다.

@<전역 변수@>=
var (
	path    [maxn]int     // 경로 번호나 끝점을 담는 일터
	mate    [maxn]int     // 동치류를 나타내는 표
	oldmate [maxn]int     // 옛 동치류를 나타내는 표
	bmate   [maxn]int     // 옮겨 갈 때 쓰는 바탕 짝 표
	src     [maxn]int     // |mate| 표의 바깥 칸이 샘인가
	oldsrc  [maxn]int     // |oldmate| 표의 바깥 칸이 샘인가
	bmatesrc [maxn]int    // |bmate| 표의 바깥 칸이 샘인가
	mp      [maxn + 1]int // 대응 함수 |map|: |map[x]=mp[1+x]|
	imap    [maxn]int     // |map|의 (대략의) 역함수
	r       int           // 마디 $m$의 이웃 가운데 $m$보다 큰 것의 수
	nbr     []int         // 그 이웃들의 경계 안 색인
	nbrtype []int         // 그 이웃으로 가는 변의 가지
	steps   int           // 지금까지 다룬 옛 동치류의 수
)

@* 옮겨 가기.
이 프로그램의 바탕 착상은, $(m-1)$-짜임의 동치류 무게를 모두 알면 $m$-짜임의 동치류
무게를 모두 셈할 수 있다는 것이다. 이 셈을 이해하려면 일반적인 경우의 특징을 거의
다 보여 주는 만만치 않은 예를 하나 보면 좋다.

그러니 $m=5$이고 그래프의 $4$-경계가 마디 수열 $(5,6,13,7,8)$인 경우를 보자. 또
마디 $5$의 이웃 가운데 $5$보다 큰 것은 $6$, $8$, $11$, $12$라고 하자.

앞의 프로그램에 따르면 그래프의 $5$-경계는 마디 수열 $(6,7,8,13,11,12)$가 된다.
(먼저 |fr| 배열의 앞쪽 다섯이 $(6,8,13,7,5)$로 바뀌고 $q$가 |oldq=5|에서 $q_0=4$로
준다. 그다음 $q$가 $6$으로 늘면서 $11$과 $12$가 제자리로 들어오고, 끝으로
정렬한다.)

@ $4$-동치류($4$-짜임의 동치류)의 트라이에서 마디 $u_1u_2u_3u_4u_5$는 그래프의 마디
$5$, $6$, $13$, $7$, $8$이 이 차례로 된 것이다. 그리고 |oldmate| 표는 이 마디들에
색인 $\{1,2,3,4,5\}$를 쓴다. 이를테면 어떤 동치류에서 마디 $6$과 $7$이 한
부분경로의 두 끝이면 그것들은 $u_2$와 $u_4$이니 |oldmate[2]=4|이고 |oldmate[4]=2|다.

$5$-경계의 마디 $v_1v_2v_3v_4v_5v_6$은 마찬가지로 그래프의 마디 $6$, $7$, $8$, $13$,
$11$, $12$가 이 차례로 된 것이다. 그래프의 마디 $6$과 $7$은 이제 $v_1$과 $v_2$다.
그러니 $4$-경계에서의 관계 |oldmate[2]=4|와 |oldmate[4]=2|는 $5$-경계에서
|mate[1]=2|와 |mate[2]=1|과 같다.

@ 그래서 두 이름 매김 사이의 관계를 나타내는 배열 |map|을 짓는 것이 자연스럽다.
이 예에서는 |map[1]=0|, |map[2]=1|, |map[3]=4|, |map[4]=2|, |map[5]=3|이다. 곧
|map[1]|은 늘 $0$이고, $1<j\le|oldq|$마다 $u_j=v_{map[j]}$다. 또 |map[-1]=-1|과
|map[0]=0|으로 둔다.

거꾸로 가는 배열 |imap|도 지을 수 있다. 이 예에서는 |imap[1]=2|, |imap[2]=4|,
|imap[3]=5|, |imap[4]=3|이다. 일반적으로 $1\le j\le q_0$마다 $v_j=u_{imap[j]}$이고,
$q_0$은 $5$-경계의 마디 가운데 $4$-경계에도 있던 것의 수다. (이 예에서는
$(m-1)$-경계가 공교롭게 $m+1=6$을 품고 있기 때문이다.) 그러면 대개
$1\le j\le q_0$마다 |mate[j]=map[oldmate[imap[j]]]|이고, $q_0<j\le q$마다
|mate[j]=0|이다. 또 |oldmate[0]=mate[0]=0|으로 둔다.

앞 문단의 ``대개''는 ``|oldmate[imap[j]]=1|일 때만 빼고''라는 뜻이다. |map[1]=0|이기
때문이다. 그 예외는 잠시 접어 두자.

\GO/에는 음수 색인이 없으니 |map[x]|를 |mp[1+x]|에 담는다. 원본도 그렇게 한다.

@<초기화한다@>=
mp[0] = -1 // |map[-1]=-1|

@ 가장 간단한 경우는 마디 $m$이 그 $(m-1)$-짜임 안에서 ``안쪽''인 동치류, 곧
|oldmate[1]=-1|인 경우다. 그러면 그 $(m-1)$-짜임은 이미 $m$-짜임이다. 그러니 번호만
알맞게 고쳐 $m$-짜임의 트라이에 보태면 된다. 이때의 |mate| 표를 |bmate|라 한다.

@<|oldmate|에서 |bmate| 표를 짓는다@>=
for j := 1; j <= q0; j++ {
	bmate[j] = mp[1+oldmate[imap[j]]] // |mp[x]=map[x-1]|
	bmatesrc[j] = oldsrc[imap[j]]
}
for j := q0 + 1; j <= q; j++ {
	bmate[j] = 0 // |bmatesrc[j]|는 상관없다
}

@ 짝 표를 |bmate|에서 가져오는 일은 세 곳에서 한다.

@<|bmate|를 |mate|로 옮긴다@>=
copy(mate[1:q+1], bmate[1:q+1])
copy(src[1:q+1], bmatesrc[1:q+1])

@ @<|bmate| 동치류를 보탠다@>=
@<|bmate|를 |mate|로 옮긴다@>@;
contribute()

@ 방금 말한 |contribute|는 $m$-동치류의 트라이를 고쳐 나가는 바탕 장치다.

@<함수들@>=
func contribute() {
	@<|mate| 표를 열쇠로 바꾼다@>@;
	@<새 트라이에서 열쇠 |code|를 찾는다@>@;
	addToBignum(&weight[p-1], &oldweight[oldp])
	contribs++
}

@ 예의 그래프에서 $5$의 이웃 가운데 $5$보다 큰 것 $(6,8,11,12)$는 공교롭게
$(v_1,v_3,v_5,v_6)$이기도 하다. 일반적으로 마디 $m$에게 $m$-경계 안의 이웃이 $r$개
있으면 그 색인들을 |nbr|에 늘어놓는다. 이 예에서는 $r=4$이고 |nbr[0]=1|, |nbr[1]=3|,
|nbr[2]=5|, |nbr[3]=6|이다.

@<옮겨 가는 데 쓸 대응표를...@>=
nbr, nbrtype = nbr[:0], nbrtype[:0]
for a := g.Vertices[m-1].Arcs; a != nil; a = a.Next {
	k = int(g.Index(a.Tip)) + 1 // |m|의 이웃의 번호
	if k < m {
		continue
	}
	nbrtype = append(nbrtype, int(a.Len&3))
	nbr = append(nbr, ifr[k]+1)
}
r = len(nbr)

@ 예외 없는 경우가 하나 더 있다. 마디 $m$이 ``맨몸''인 동치류, 곧 |oldmate[1]=0|인
경우다. 그러면 $m$-동치류에 보탤 것이 이웃 쌍마다 하나씩, $r\choose2$가지 있을 수
있다. 예에서는 ${4\choose2}=6$가지 가운데 하나가 $v_3\adj 5\adj v_6$이다. 되면 이
두 변을 |bmate|의 동치류에 보탠다. 효과는 유도된 변 $v_3\adj v_6$을 보태는 것과
같다.

(실은 양방향으로 맞춰야 한다. 이를테면 $v_3\0<>5\0<<v_6$이면 아무 일도 하지
않는다. 그리고 $v_3\0<>5\0><v_6$처럼 올바른 변 쌍이면 유도된 변은 $v_3\0<<v_6$이다.)

두 이웃 가운데 하나는 가지가 $0$이나 $1$이고 다른 하나는 $2$나 $3$이어야 한다.
그래야 마디 $m$을 지나는 두 변의 기호가 $m$의 양옆에서 같아진다. 그리고 새로 생기는
유도된 변의 두 끝이 샘이 될지 싱크가 될지는 가지의 낮은 비트가 정한다.

@<$m$이 맨몸일 때 알맞은 동치류들을 보탠다@>=
for i := 0; i < r; i++ {
	for ii := i + 1; ii < r; ii++ {
		var srci, srcii int
		if nbrtype[i]&2 == 0 { // 이웃 |i|는 바깥을 보거나 들어오는 변이다
			if nbrtype[ii]&2 == 0 {
				continue // 이웃 |ii|는 안을 보거나 나가는 변이어야 한다
			}
			srci = nbrtype[i]&1 ^ 1
			srcii = nbrtype[ii] & 1
		} else { // 이웃 |i|는 안을 보거나 나가는 변이다
			if nbrtype[ii]&2 != 0 {
				continue // 이웃 |ii|는 바깥을 보거나 들어오는 변이어야 한다
			}
			srci = nbrtype[i] & 1
			srcii = nbrtype[ii]&1 ^ 1
		}
		@<|bmate|를 |mate|로 옮긴다@>@;
		if addDerived(nbr[i], srci, nbr[ii], srcii) {
			contribute()
		}
	}
}

@ 끝으로 예외인 경우는 |oldmate[1]>0|일 때 생긴다. 그러면 $m$-동치류에 이웃마다
하나씩, $r$가지를 보탠다. 이를테면 |oldmate[1]=5|라 하자. 곧 $u_1$은 한 경로의
끝이고 그 다른 끝은 $u_5$, 곧 $v_{map[5]}=v_3$이다. (이것이 예외인 것은
|oldmate[imap[3]]=oldmate[5]=1|이기 때문이다.) 마디 $u_1$에서 $v_j$로 변을 보태는
것은 $v_3$과 $v_j$ 사이에 변을 보태는 것과 아주 비슷하다. 그러면 $v_3$에서 $v_j$로
가는 경로가 생기기 때문이다.

마디 $m$이 샘이면 새 변은 $m$에서 나가야 하고, 싱크면 $m$으로 들어와야 한다.

@<$m$이 바깥일 때 알맞은 동치류들을 보탠다@>=
for i := 0; i < r; i++ {
	var srci int
	if oldsrc[1] != 0 { // 나가야 한다. 안을 보거나 나가는 변이다
		if nbrtype[i]&2 == 0 {
			continue
		}
		srci = nbrtype[i] & 1
	} else { // 들어와야 한다. 바깥을 보거나 들어오는 변이다
		if nbrtype[i]&2 != 0 {
			continue
		}
		srci = nbrtype[i]&1 ^ 1
	}
	@<|bmate|를 |mate|로 옮긴다@>@;
	if addDerived(mp[1+oldmate[1]], oldsrc[oldmate[1]], nbr[i], srci) {
		contribute()
	}
}

@ 마디 $m+1$이 옛 경계에 없었으면 |imap[1]|이 $0$이어야 한다. 그래야 |bmate[1]|도
$0$이 된다. 있었으면 |imap[1]|은 $m+1$이 전에 있던 자리여야 한다.

@<옮겨 가는 데 쓸 대응표를...@>=
imap[1] = 0
for j = 2; j <= oldq; j++ {
	mp[j+1] = 1 + ifr[ofr[j-1]] // |map[j]=mp[j+1]|
	imap[mp[j+1]] = j
}

@* 유도된 변 보태기.
마디 $v_1\ldots v_q$의 쌍들 사이의 부분경로가 |mate| 표로 주어졌을 때, $v_i$와
$v_j$ 사이에 이음을 보탤 수 있는 것은 둘 다 안쪽이 아닐 때, 곧 |mate[i]>=0|이고
|mate[j]>=0|일 때뿐이다.

|srci=1|이면 $v_i$는 나가는 변이 필요한 샘이 되고, 아니면 들어오는 변이 필요한
싱크가 된다. |srcj|와 $v_j$도 마찬가지다.

그런 경우에는 $v_i$와 $v_j$가 맨몸인지 아닌지에 따라 네 갈래가 있다. 이를테면
$v_i$가 맨몸이고 $v_j$가 바깥이면, 양방향 규칙에 따라 |srcj=src[j]|는 안 된다.

뜻밖의 미묘한 점이 하나 있다. 마디 $m$이 바깥 마디이고 그 경로의 다른 끝에 이웃해
있으면 유도된 고리를 닫는 셈이다. 그때는 |bmate|에서 다른 끝이 맨몸으로 보이므로
|i==j|이고 둘 다 맨몸이다.

@ 원본은 둘 다 바깥이면서 |i==j|인 경우도 따로 거른다. 한 마디에 호가 셋 붙게 되기
때문이다. \.{dynaham.w}의 원본에는 없던 이 검사 덕분에, 거기서 고쳐야 했던 겹친
변의 결함이 여기에는 없다.

원본은 둘 다 맨몸이면서 |i==j|인 경우에 |goto cycle|로 고리를 다루는 절 한가운데로
뛴다. \GO/도 블록 밖으로 나가는 |goto|는 허락하니, 표찰 |cycle|을 함수 끝의 그
절 앞에 두었다.

@<함수들@>=
func addDerived(i, srci, j, srcj int) bool {
	if mate[i] < 0 || mate[j] < 0 {
		return false
	}
	@<한쪽이라도 맨몸이면 이음을 보탠다@>@;
	@<둘 다 바깥이면 두 부분경로를 잇는다@>@;
cycle:
	@<고리를 적어 두고 거짓을 돌려준다@>@;
}

@ 맨몸인 쪽은 짝과 샘 표시를 새로 얻는다. 바깥인 쪽은 안쪽이 되는데, 그 쪽이 이미
원하는 종류라면 호의 방향이 맞지 않으니 보탤 수 없다.

@<한쪽이라도 맨몸이면...@>=
if mate[i] == 0 { // $v_i$는 맨몸이다
	if mate[j] == 0 { // $v_j$는 맨몸이다
		if i == j {
			if srci == srcj {
				return false
			}
			goto cycle
		}
		mate[i], mate[j] = j, i
		src[i], src[j] = srci, srcj
		return true
	}
	// $v_j$는 바깥이다
	if src[j] == srcj {
		return false
	}
	mate[i] = mate[j]
	mate[mate[j]] = i
	mate[j] = -1 // $v_j$가 안쪽이 된다
	src[i] = srci
	return true
}
// $v_i$는 바깥이다
if mate[j] == 0 { // $v_j$는 맨몸이다
	if src[i] == srci {
		return false
	}
	mate[j] = mate[i]
	mate[mate[i]] = j
	mate[i] = -1 // $v_i$가 안쪽이 된다
	src[j] = srcj
	return true
}

@ @<둘 다 바깥이면...@>=
// $v_i$와 $v_j$가 다 바깥이다
if i == j {
	return false // $v_i$에 호가 셋 붙는다
}
if src[i] == srci || src[j] == srcj {
	return false
}
if mate[i] != j { // 두 부분경로를 잇는다
	mate[mate[i]] = mate[j]
	mate[mate[j]] = mate[i]
	mate[i], mate[j] = -1, -1
	return true
}

@ 부분경로의 두 끝을 이으면 물론 고리가 생긴다. 그때 고리의 마디는 모두 안쪽이 된다.
고리는 $m$-짜임에 있을 수 없으니 지금 동치류는 트라이에 보태지 않는다.

하지만 그 고리가 우리가 세려는 특별한 회로라면 중요하다. 그것은 다음 두 조건을
채우는 정수 $m'$이 있을 때이고 오직 그때뿐이다. (i)~그래프의 $m'$ 이하인 마디는
모두 안쪽이다. (ii)~$m'$보다 큰 마디는 모두 맨몸이다. 두 조건이 다 채워지면
해밀턴 $m'$-회로의 수에 보탠다.

$q_0\le k<q$인 경계 마디 |fr[k]|는 안쪽일 수 없다. 그 마디의 $m$ 이하인 이웃은 $m$
자신뿐이기 때문이다. 그러니 옳은 회로라면 |fr[0]=m+1|, |fr[1]=m+2|, \dots,
|fr|$[m'-m-1]=m'$이고 $m'-m\le q_0$이어야 한다.

@<고리를 적어 두고...@>=
mate[i], mate[j] = -1, -1
k := 1
for ; k <= q0; k++ {
	if mate[k] >= 0 {
		break // $v_k$는 안쪽이 아니다
	}
	if fr[k-1] != m+k {
		return false // |m+k|는 안쪽이 아니다
	}
}
for kk := k; kk <= q; kk++ {
	if mate[kk] != 0 {
		return false // |m+k| 이상인 경계 원소가 맨몸이 아니다
	}
}
fmt.Fprint(errw, "Class ")
printOldKey()
fmt.Fprint(errw, " contributes ")
printBignum(errw, &oldweight[oldp])
fmt.Fprintf(errw, " to a %d-cycle.\n", m+k-1)
addToBignum(&count[m+k-1], &oldweight[oldp])
return false

@ 옛 열쇠를 찍는 일은 네 곳에서 한다.

@<함수들@>=
func printOldKey() {
	for l := 0; l < oldq; l++ {
		errw.WriteString(encode(oldcode[l]))
	}
}

@* 트라이 훑기.
이 프로그램의 큰 반복은 ``옛'' 트라이, 곧 |oldmem|과 |oldweight|로 정해지는
트라이에 든 $(m-1)$-동치류를 모두 찾아가 그 뒤들을 $m$-동치류의 ``새'' 트라이에
보태는 일이다. 그 일은 |uncompress|의 수준 |oldq|에서 일어나며, 그때 |oldcode|
표에는 지금 찾아간 $(m-1)$-동치류가 들어 있다.

@<옛 동치류마다 그 뒤를...@>=
spack, oldp, omp, oms, omx, pack = 0, 0, 0, 0, 1, oldmem[0]
uncompress(0, 4)

@ @<무게가 |oldweight[oldp]|인 동치류...@>=
@<옛 열쇠를 |oldmate| 표로 바꾼다@>@;
@<눈여겨볼 동치류면 통계를 찍는다@>@;
@<|oldmate|에서 |bmate| 표를 짓는다@>@;
switch {
case oldmate[1] < 0:
	@<|bmate| 동치류를 보탠다@>@;
case oldmate[1] == 0:
	@<$m$이 맨몸일 때...@>@;
default:
	@<$m$이 바깥일 때...@>@;
}

@ 첫 동치류는 늘 찍고, 그 뒤로는 무게가 가장 작거나 가장 큰 것이 바뀔 때마다
찍는다. 또 $2^{21}$개마다 점을 하나 찍어 진행을 알린다.

@<눈여겨볼 동치류면...@>=
if oldp == 0 {
	@<첫 동치류의 통계를 찍는다@>@;
} else {
	@<뒤따르는 동치류의 통계를 찍는다@>@;
}

@ @<첫 동치류의...@>=
fmt.Fprint(errw, "The first one is ")
printOldKey()
fmt.Fprint(errw, "\nand its weight is ")
printBignum(errw, &oldweight[oldp])
fmt.Fprint(errw, ".\n")
minweight, maxweight = oldweight[oldp], oldweight[oldp]
steps, contribs = 0, 0
errw.Flush()

@ @<뒤따르는 동치류의...@>=
if bignumComp(&oldweight[oldp], &minweight) < 0 {
	minweight = oldweight[oldp]
	@<이 동치류의 무게를 찍는다@>@;
}
if bignumComp(&oldweight[oldp], &maxweight) > 0 {
	maxweight = oldweight[oldp]
	@<이 동치류의 무게를 찍는다@>@;
}
if steps&progressMask == progressMask {
	fmt.Fprint(errw, ".")
	errw.Flush()
}
steps++

@ @<이 동치류의 무게를...@>=
fmt.Fprint(errw, "Class ")
printOldKey()
fmt.Fprint(errw, " has weight ")
printBignum(errw, &oldweight[oldp])
fmt.Fprint(errw, ".\n")

@ @<$m$-동치류를 받을 새 트라이를...@>=
if int64(memptr) > maxmemptr {
	maxmemptr = int64(memptr)
}
if int64(wtptr) > maxwtptr {
	maxwtptr = int64(wtptr)
}
mem[0], mem[1], mem[2], mem[3], memptr, wtptr = 0, 0, 0, 0, 4, 0 // 뿌리 마디는 늘 있다
@<$\widehat F_{m-1}$에서 $\widehat F_m$으로 바꾼다@>@;

@ 해밀턴 $m'$-회로가 있으면 $\lfloor(m'-1)/2\rfloor$-짜임이 적어도 하나 있다. 하지만
$\lfloor(m'+1)/2\rfloor$-짜임은 하나도 없을 수 있다. 그러니 마지막 $m$-짜임을 찾은
뒤에 회로 수를 여럿 알려야 할 수도 있다.

@<마지막 보고를...@>=
errw.Flush()
fmt.Print("\n") // 원본은 이 빈 줄을 표준 출력에 찍는다
for k = m; k <= n; k++ {
	if k > m+m {
		break
	}
	reportCycles(k)
}
fmt.Fprintf(errw, "\nThat's all; there are no %d-configs!\n", m-1)
fmt.Fprintf(errw, "Storage requirements: %d memsize, %d omemsize,", maxmemptr+2, maxomp+1)
fmt.Fprintf(errw, " %d wtsize, %d maxprec, %d deg.\n", maxwtptr, 18*prec, maxdeg+1)
quit(0)

@ 해밀턴 $m$-회로의 수를 알린다. 표준 출력에 쓰기 전에 표준 오류의 버퍼를 비운다.

@<함수들@>=
func reportCycles(m int) {
	if bignumComp(&count[m], &one) >= 0 { // $0$이 아니면
		errw.Flush()
		fmt.Print("There are ")
		printBignum(os.Stdout, &count[m])
		fmt.Printf(" Hamiltonian %d-cycles.\n", m)
	}
}

@* 해 보기.
마디 $n$개의 모든 쌍 사이에 네 가지 변이 다 있는 완전 양방향 그래프에는 해밀턴
회로가 $(n-1)!\,2^{n-1}$개 있다(\.{ssbidiham.w}를 보라). 프로그램은 $n=3$, \dots,
$6$에서 $8$, $48$, $384$, $3840$개를 찾는다.

무향 그래프를 주면 변 하나가 두 끝의 목록에 같은 길이로 적혀 있다. \.{SGB}의 |board|가
짓는 변은 길이가 $1$이니, $u$의 목록에서 $u\0<<v$를, $v$의 목록에서 $v\0<<u$를 읽어
두 방향의 유향 변이 된다. 그래서 $6\times6$ 판의 나이트 그래프에서는
\.{dynadiham.w}처럼 $19724$개를 찾는다. 원본의 예처럼 나이트 움직임을 길이 $0$으로,
와지르 움직임을 길이 $2$로 적으면 나이트+와지르 투어를 센다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 \.{libgb}와 함께 컴파일해 이 판과 견주었다. 사용법을 알리는
말에 든 프로그램 이름만 빼고 표준 출력, 표준 오류, 종료 부호가 바이트까지 같은지를
보았다.

\smallskip
\item{$\bullet$} 원본이 옳은지는 \.{ssbidiham.w}를 시험할 때 쓴 무작위 양방향 그래프와
작은 그래프들로 보았다. 파이썬으로 짠 깊이 우선 탐색이 처음 $m$개 마디마다 부호 붙은
마디를 따라 한 바퀴 도는 길을 곧이곧대로 센다. 그래프 $65$개 가운데 $64$개에서 원본이
맞았다. 나머지 하나는 앞에서 말한 명세 밖의 틈, 곧 같은 가지의 변을 두 번 적은
그래프다.
\item{$\bullet$} 그 무작위 그래프들에 \.{AddressSanitizer}와
\.{UndefinedBehaviorSanitizer}를 붙여 돌려도 경고가 없었다. 마디 없는 그래프에서만
힙 넘침이 났다.
\smallskip

\noindent 이 판은 앞의 세 곳을 고친 \CEE/ 판과 그래프 $82$개(\.{ssbidiham.w}를 시험한
그래프들과 나이트 판 셋), 잘못된 명령줄 다섯에서 모두 바이트까지 같았다. 고치기 전의
원본과도 마디 없는 그래프만 빼고 모두 같았다. 명세 밖의 그래프에서도 원본과 같은 수를
낸다.

@* 색인.
