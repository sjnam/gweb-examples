이 변경 파일은 크누스의 \.{matula-big-planted.ch}를 우리 \.{GWEB} 판에 맞춘
것이다. \.{matula-big.ch}에서 갈라져 나온 판인데, 목표 나무~$T$ 하나만 rectree
파일로 받고 무늬 나무~$S$는 $T$에서 잎을 무작위로 지워 만든다. 그러니 $S$는
반드시 $T$의 부분나무이고, 알고리즘이 그것을 얼마나 빨리 찾아내는지를 재게 된다.
적용:

    gtangle matula.w matula-big-planted.ch     (-> 심어 놓고 찾는 matula.go)

난수는 SGB의 것을 쓴다(\.{go get github.com/sjnam/go-sgb}). 씨앗이 같으면
크누스의 \CEE/ 판과 똑같은 잎을 지우므로, 답도 mem 수도 그대로 견줄 수 있다.


@x
@ 두 나무는 명령줄에서 각각 ``부모 포인터''의 문자열로 준다. 마디 하나에 글자
하나다. 첫 글자는 언제나 \..으로, 있지도 않은 뿌리의 부모를 뜻한다. 그다음 글자는
언제나 \.0으로, 마디~$1$의 부모다. 그리고 $(k+1)$번째 글자가 마디~$k$의 부모인데,
$k$보다 작은 아무 수나 될 수 있다. \.9보다 큰 수는 소문자로, \.z($35$를 뜻한다)보다
큰 수는 대문자로 적는다. \.Z($61$)보다 큰 수는 지금으로서는 쓸 수 없다.

나무 $S$의 뿌리는 차수가~$1$이라고 가정한다. 그러니 뿌리이면서 잎이기도 하고,
$S$의 문자열에는 \.0이 딱 한 번만 나온다.

@ 이를테면 이런 나무 둘이 초기 시험에 쓰였다.
$$\eqalign{S&=\.{.0111444759a488cfch};\cr
T&=\.{.011345676965cc5ffh5cklfn55qjstuuwxxwwuCCuFCpppqrtGOHJRLMNO};\cr}$$
$T$ 안에서 $S$를 찾을 수 있겠는가?
@y
@ 이 판에서는 목표 나무~$T$ 하나만 {\it rectree\/} 형식의 파일로 준다. 그 형식은
아래에 밝혀 두었다. 무늬 나무~$S$는 $T$에서 잎을 $d$개 지워 얻는데, 한 개를 지울
때마다 그때 남아 있는 잎 가운데 하나를 고르게 뽑는다. 그러니 $S$는 반드시 $T$의
부분나무다---알고리즘이 그것을 찾아내는 데 얼마나 걸리는지 보려는 것일 뿐이다.
지울 잎의 수~$d$와 난수의 씨앗은 명령줄에서 준다.

@ 이를테면 초기 시험에 쓰인 나무~$T$를 rectree로 적으면 이렇다.
$$\vtop{\halign{\tt#\hfil\cr
\char`\%\ example target tree T\cr
T59\_0.\cr
T59\_0=+2T1\_1+1T56\_3.\cr
T56\_3=+1T55\_4.\cr
T55\_4=+1T54\_5.\cr
T54\_5=+1T6\_6+1T6\_12+1T6\_18+1T23\_24+1T6\_47+1T6\_53.\cr
T6\_53=+1T3\_54+1T2\_57.\cr
T3\_54=+1T2\_55.\cr
T6\_47=+2T1\_48+1T3\_50.\cr
T3\_50=+1T2\_51.\cr
T23\_24=+1T22\_25.\cr
T22\_25=+1T21\_26.\cr
T21\_26=+1T18\_27+1T2\_45.\cr
T18\_27=+1T1\_28+1T6\_29+1T5\_35+1T5\_40.\cr
T5\_40=+1T4\_41.\cr
T4\_41=+1T3\_42.\cr
T3\_42=+2T1\_43.\cr
T5\_35=+2T1\_36+1T2\_38.\cr
T6\_29=+1T3\_30+2T1\_33.\cr
T3\_30=+2T1\_31.\cr
T6\_18=+1T1\_19+2T2\_20.\cr
T6\_12=+2T1\_13+1T3\_15.\cr
T3\_15=+1T2\_16.\cr
T6\_6=+2T2\_7+1T1\_11.\cr}}$$
아래 그림의 두 나무가 크누스가 처음 시험에 쓴 것이다. 이 판에서 $S$는 잎을 지워
얻으므로 그림의 $S$와 꼭 같지는 않다. 마디 이름도 이 rectree 명세의 번호를 뒤섞은
것이다.
@z
@x
import (
	"fmt"
	"os"
)
@y
import (
	"bufio"
	"fmt"
	"os"
	"strconv"

	"github.com/sjnam/go-sgb/gbflip"
)
@z
@x
	maxn        = 62       // 입력 방식을 바꾸면 훨씬 키울 수 있다
@y
	maxn        = 2000     // rectree 형식이니 마음껏 키울 수 있다
@z

@x
var d, e, g, k, m, n, p, q, v, z int
@y
var d, e, g, k, m, n, p, q, r, s, v, z int
@z

@x
if len(os.Args) != 3 {
	fmt.Fprintf(os.Stderr, "쓰는 법: %s S의부모들 T의부모들\n", os.Args[0])
	os.Exit(1)
}
sarg, targ = os.Args[1], os.Args[2]
@<나무 $S$를 읽는다@>@;
@<나무 $T$를 읽는다@>@;
@y
if len(os.Args) != 4 {
	fmt.Fprintf(os.Stderr, "쓰는 법: %s T.rectree 지울잎수 씨앗\n", os.Args[0])
	os.Exit(1)
}
targ = os.Args[1]
@<지울 잎의 수와 씨앗을 읽는다@>@;
rng = gbflip.New(int64(seed))
@<나무 $S$를 읽는다@>@;
@<나무 $T$를 읽는다@>@;

@ @<지울 잎의 수와 씨앗을 읽는다@>=
var err error
del, err = strconv.Atoi(os.Args[2])
if err != nil {
	fmt.Fprintf(os.Stderr, "지울 잎의 수 `%s'를 알아볼 수 없다!\n", os.Args[2])
	os.Exit(1)
}
seed, err = strconv.Atoi(os.Args[3])
if err != nil {
	fmt.Fprintf(os.Stderr, "씨앗 `%s'을 알아볼 수 없다!\n", os.Args[3])
	os.Exit(1)
}

@ @<전역 변수@>=
var (
	del, seed int         // 명령줄에서 받은 값
	rng       *gbflip.RNG // SGB의 난수기
)
@z
@x
@* 나무를 담는 그릇.
나무의 마디마다 |node| 레코드를 하나씩 둔다. 항목이 넷이다: |child|(가장 최근에
달린 아들), |sib|(부모의 이전 아들), |deg|(이웃의 수), |arc|(부모로 가는 호의
번호). 밭 |deg|와 |arc|는 $S$에서는 쓰이지 않고 $T$에서만 필요하다. 같은 마디의
|deg|와 |arc|를 짚는 것은 mem 하나로 친다.
@y
@* 되풀이하는 나무 형식.
rectree 형식으로 자유 나무를 적으려면 겹겹의 확인 절차를 지켜야 한다. 사람을
정직하게 만들려는 것이니, 손으로 적기보다 기계에 맡기는 편이 낫다.

파일의 첫머리에는 주석을 두어도 된다. 맨 왼쪽에 \.\% 하나를 찍으면 그 줄은
주석이다. 그다음이 {\it 주 줄\/}인데, 나무 전체의 틀을 잡는다. 모양이 셋 중
하나다.
\smallskip
\item{가)} \.{T$n$\_0.} 마디가 $n$개이고 마디~$0$에서 시작하는 나무다.

\item{나)} \.{T$m$\_0,T$m$\_$m$.} 마디가 $2m$개인 나무인데, 마디 $m$개짜리
나무 \.{T$m$\_0}과 \.{T$m$\_$m$}의 뿌리를 이음줄로 이어 만든다.

\item{다)} \.{2T$m$\_0.} 마디가 $2m$개인 나무인데, 마디 $m$개짜리 나무
\.{T$m$\_0}을 똑같이 둘 지어 그 뿌리를 이음줄로 잇는다.
\smallskip\noindent
나)와 다)는 \.{randomfreetree.m}이 중심이 둘인 자유 나무를 지을 때 내놓는
모양이다. (rectree로 적힌 나무의 중심이 어디에 있어도 상관은 없다.)

주 줄 다음의 줄들은 마디가 셋 이상인 부분나무를 하나씩 정의하는데, {\it 언제나
나중에 나온 것을 먼저 푸는 차례\/}로 늘어놓는다. 부분나무의 이름은
\.{T$k$\_$o$} 꼴이고, $k$는 마디 수, $o$는 뿌리 마디의 번호다. 마디가 $k$개인
부분나무의 정의는 저마다 한 줄을 차지한다. 이름 바로 뒤에 \.=을 붙이고, 마디를
모두 합해 $k-1$개가 되는 부분나무들의 합을 적은 다음 \..으로 닫는다. 항마다
이름 앞에 정수~$j$를 두어 그것을 $j$벌 두라는 뜻으로 삼는다. 그러니
`\.{$j$T$k$\_$o$}' 다음 항의 시작 번호는 $o+jk$여야 한다.

@* 나무를 담는 그릇.
나무의 마디마다 |node| 레코드를 하나씩 둔다. 항목이 넷이다: |child|(가장 최근에
달린 아들), |sib|(부모의 이전 아들), |deg|(이웃의 수), |arc|(부모로 가는 호의
번호). 밭 |deg|와 |arc|는 $T$에서 쓰이고, $S$에서는 마디 번호를 다시 매기는 데
쓴다. 같은 마디의 |deg|와 |arc|를 짚는 것은 mem 하나로 친다.
@z

@x
	snode [maxn]node // $S$의 마디 $m$개
	tnode [maxn]node // $T$의 마디 $n$개
@y
	snode [maxn + 1]node // $S$의 마디 $m$개와 하나 더
	tnode [maxn + 1]node // $T$의 마디 $n$개와 하나 더
@z
@x
@ 읽어 들이기는 곧이곧대로다. 글자를 하나씩 풀어 부모를 알아내고, 그 부모의
아들 목록 앞에 매단다.

@<나무 $S$를 읽는다@>=
mems++
if sarg[0] != '.' {
	fmt.Fprintln(os.Stderr, "S의 뿌리는 부모가 `.'이어야 한다!")
	os.Exit(10)
}
for m = 1; ; m++ {
	mems++
	if m >= len(sarg) {
		break
	}
	@<$S$의 마디 |m|을 매단다@>@;
}

@ @<$S$의 마디 |m|을 매단다@>=
if m == maxn {
	fmt.Fprintf(os.Stderr, "미안하다, S의 마디는 많아야 %d개다!\n", maxn)
	os.Exit(11)
}
p = decode(sarg[m])
@<$S$의 부모 |p|가 옳은지 따진다@>@;
mems += 2
q, snode[p].child = snode[p].child, m // |m|이 첫 아들이 된다
mems++
snode[m].sib = q

@ @<$S$의 부모 |p|가 옳은지 따진다@>=
if p < 0 {
	fmt.Fprintf(os.Stderr, "S에 이상한 글자 `%c'가 있다!\n", sarg[m])
	os.Exit(12)
}
if p >= m {
	fmt.Fprintf(os.Stderr, "%c의 부모는 %c보다 작아야 한다!\n", encode(m), encode(m))
	os.Exit(13)
}
if p == 0 && m > 1 {
	fmt.Fprintln(os.Stderr, "S의 뿌리는 아들이 하나뿐이어야 한다!")
	os.Exit(13)
}

@ $T$ 쪽도 똑같다. 다만 뿌리의 아들 수에는 제한이 없다.

@<나무 $T$를 읽는다@>=
mems++
if targ[0] != '.' {
	fmt.Fprintln(os.Stderr, "T의 뿌리는 부모가 `.'이어야 한다!")
	os.Exit(20)
}
for n = 1; ; n++ {
	mems++
	if n >= len(targ) {
		break
	}
	@<$T$의 마디 |n|을 매단다@>@;
}
@<호에 번호를 매긴다@>@;
fmt.Fprintf(os.Stderr, "좋다, S의 마디 %d개와 T의 마디 %d개를 얻었다. 최대 차수는 %d.\n",
	m, n, maxdeg)

@ @<$T$의 마디 |n|을 매단다@>=
if n == maxn {
	fmt.Fprintf(os.Stderr, "미안하다, T의 마디는 많아야 %d개다!\n", maxn)
	os.Exit(21)
}
p = decode(targ[n])
if p < 0 {
	fmt.Fprintf(os.Stderr, "T에 이상한 글자 `%c'가 있다!\n", targ[n])
	os.Exit(22)
}
if p >= n {
	fmt.Fprintf(os.Stderr, "%c의 부모는 %c보다 작아야 한다!\n", encode(n), encode(n))
	os.Exit(23)
}
mems += 2
q, tnode[p].child = tnode[p].child, n
mems++
tnode[n].sib = q
@y
@ 이제 rectree 파일을 읽어 |tnode| 배열에 나무를 놓는 함수를 짓는다.

나무를 세우는 동안 |child| 밭은 아직 마무리하지 못한 마디들을 잇는 쌓개 노릇을
하고, |deg| 밭에는 부분나무의 크기를, |arc| 밭에는 몇 벌을 복제해야 하는지를
적어 둔다.

@<함수들@>=
func readRectree(filename string) int {
	var i, j, k, p, q, r, s, typ, stack, n, size, off, rightoff, rep int
	mems += suboverhead
	@<파일을 열고 주석을 건너뛴다@>@;
	@<주 줄을 처리한다@>@;
	for stack >= 0 {
		@<쌓여 있는 부분나무 정의를 하나 처리한다@>@;
	}
	@<복제본을 만든다@>@;
	@<중심이 둘이면 손질한다@>@;
	mems++
	return tnode[0].deg
}

@ 줄 하나를 읽어 |buf|에 담는다. \CEE/의 |fgets|가 하던 일인데, 거기서처럼 끝에
널 바이트를 하나 붙여 둔다. 그래야 줄 끝을 한 칸 지나쳐 짚어도 탈이 없다.
(\GO/의 문자열은 범위를 벗어나면 그 자리에서 죽는다.)

@<함수들@>=
func getline() bool {
	line, err := infile.ReadString('\n')
	if line == "" && err != nil {
		return false
	}
	buf = line + "\x00"
	return true
}

func from(i int) string { // 오류 메시지에 쓸 나머지. 끝 표시는 뺀다
	return buf[i : len(buf)-1]
}

@ @<전역 변수@>=
var (
	infile *bufio.Reader // 읽고 있는 rectree 파일
	buf    string        // 방금 읽어 들인 줄
)

@ @<파일을 열고 주석을 건너뛴다@>=
f, err := os.Open(filename)
if err != nil {
	fmt.Fprintf(os.Stderr, "`%s'를 읽으려고 열 수 없다!\n", filename)
	os.Exit(99)
}
infile = bufio.NewReader(f)
for {
	if !getline() {
		fmt.Fprintf(os.Stderr, "rectree 파일 `%s'가 주 줄도 없이 끝났다\n", filename)
		os.Exit(98)
	}
	mems++
	if buf[0] != '%' {
		break
	}
}

@ 주 줄은 나무 전체의 틀을 잡는다. 마디 $2m$개짜리를 두 벌로 짓는 다)의 경우에는
|typ|이 $2$, 서로 다른 둘을 잇는 나)의 경우에는 $1$, 예사로운 가)의 경우에는
$0$이다.

@<주 줄을 처리한다@>=
mems++
if buf[0] == '2' {
	typ, tnode[0].arc, p = 2, 2, 1
} else {
	typ, p, tnode[0].arc = 0, 0, 0
}
@<부분나무 이름을 읽는다@>@;
if off != 0 {
	fmt.Fprintf(os.Stderr, "주 부분나무는 0에서 시작해야 한다!\n...%s", from(q))
	os.Exit(104)
}
mems += 2
n, tnode[0].deg = size, size
tnode[0].child, tnode[0].sib, stack = -1, 0, 0
@<중심이 둘인 주 줄을 마저 읽는다@>@;
@<마디 |n|개를 위한 자리를 비운다@>@;
mems++
if buf[p] != '.' {
	fmt.Fprintf(os.Stderr, "주 줄이 `.'으로 끝나지 않았다!\n%s", from(0))
	os.Exit(106)
}

@ @<중심이 둘인 주 줄을 마저 읽는다@>=
if typ == 2 {
	n += n
} else {
	mems++
	if buf[p] == ',' {
		typ, p = 1, p+1
		@<부분나무 이름을 읽는다@>@;
		if off != n {
			fmt.Fprintf(os.Stderr, "둘째 주 부분나무는 %d에서 시작해야 한다!\n...%s", off, from(q))
			os.Exit(105)
		}
		mems++
		tnode[0].sib, stack = n, n
		n += size
	}
}

@ @<마디 |n|개를 위한 자리를 비운다@>=
if n > maxn {
	fmt.Fprintf(os.Stderr, "나무가 너무 크다. maxn이 %d이기 때문이다!\n...%s", maxn, from(q))
	os.Exit(102)
}
for k = 1; k <= n; k++ {
	mems += 2
	tnode[k].child, tnode[k].sib, tnode[k].deg, tnode[k].arc = 0, 0, 0, 0
}
if typ == 1 {
	mems++
	tnode[stack].deg = n - stack // |tnode[stack].child|는 이미 $0$이다
}

@ 부분나무의 이름 \.{T$k$\_$o$}를 읽어 |size|와 |off|에 담는다. 읽기 시작한
자리는 |q|에 남겨 두는데, 오류를 알릴 때 쓴다.

@<부분나무 이름을 읽는다@>=
mems++
if buf[p] != 'T' {
	fmt.Fprintf(os.Stderr, "부분나무 이름이 T로 시작하지 않는다!\n...%s", from(p))
	os.Exit(100)
}
q, p = p, p+1
for size = 0; ; p++ {
	mems++
	if buf[p] < '0' || buf[p] > '9' {
		break
	}
	size = 10*size + int(buf[p]-'0')
}
if size == 0 {
	fmt.Fprintf(os.Stderr, "부분나무의 크기가 없거나 0이다!\n...%s", from(q))
	os.Exit(101)
}
if buf[p] != '_' {
	fmt.Fprintf(os.Stderr, "부분나무 이름에 `_'가 없다!\n...%s", from(q))
	os.Exit(103)
}
p++
for off = 0; ; p++ {
	mems++
	if buf[p] < '0' || buf[p] > '9' {
		break
	}
	off = 10*off + int(buf[p]-'0')
}

@ 쌓개의 꼭대기에 있는 부분나무를 하나 꺼내 그 정의를 읽는다. 마디가 둘 이하인
부분나무는 모양이 뻔하니 줄을 쓰지 않는다.

@<쌓여 있는 부분나무 정의를 하나 처리한다@>=
mems += 2
k, stack, s = stack, tnode[stack].child, tnode[stack].deg
mems++
if s >= 2 {
	tnode[k].child = k + 1
} else {
	tnode[k].child = 0
}
if s > 2 {
	@<마디 |k|의 정의를 한 줄 읽는다@>@;
}

@ @<마디 |k|의 정의를 한 줄 읽는다@>=
if !getline() {
	fmt.Fprintf(os.Stderr, "rectree 파일 `%s'가 T%d_%d를 정의하기 전에 끝났다!\n", filename, s, k)
	os.Exit(107)
}
p = 0
@<부분나무 이름을 읽는다@>@;
if size != s || off != k {
	fmt.Fprintf(os.Stderr, "rectree 파일 `%s'가 T%d_%d를 정의하지 않는다!\n %s", filename, s, k, from(0))
	os.Exit(108)
}
mems++
if buf[p] != '=' {
	fmt.Fprintf(os.Stderr, "T%d_%d의 정의에 `='가 없다!\n %s", s, k, from(0))
	os.Exit(109)
}
p++
rightoff = k + 1
@<마디 |k|의 부분나무들을 정의한다@>@;
@<정의가 제대로 닫혔는지 따진다@>@;

@ @<정의가 제대로 닫혔는지 따진다@>=
if buf[p] != '.' {
	fmt.Fprintf(os.Stderr, "T%d_%d의 정의 뒤에 `.'이 없다!\n %s", s, k, from(0))
	os.Exit(112)
}
if rightoff != k+s {
	fmt.Fprintf(os.Stderr, "T%d_%d의 정의에 마디가 %d개 있다!\n %s", s, k, rightoff-k, from(0))
	os.Exit(113)
}

@ 항 하나하나가 \.{$j$T$k$\_$o$} 꼴이다. 그런 항을 만날 때마다 마디 |j|를
쌓개에 얹어 두었다가 나중에 풀어낸다.

@<마디 |k|의 부분나무들을 정의한다@>=
for {
	mems++
	if buf[p] != '+' {
		break
	}
	q, p = p, p+1
	for rep = 0; ; p++ {
		mems++
		if buf[p] < '0' || buf[p] > '9' {
			break
		}
		rep = 10*rep + int(buf[p]-'0')
	}
	if rep == 0 {
		fmt.Fprintf(os.Stderr, "되풀이 수가 없거나 0이다!\n...%s", from(q))
		os.Exit(110)
	}
	@<부분나무 이름을 읽는다@>@;
	if off != rightoff {
		fmt.Fprintf(os.Stderr, "그 부분나무는 %d에서 시작해야 한다!\n...%s", rightoff, from(q))
		os.Exit(111)
	}
	@<항 하나를 쌓개에 얹는다@>@;
}

@ @<항 하나를 쌓개에 얹는다@>=
mems += 2
j = rightoff
tnode[j].deg, tnode[j].child = size, stack
if rep > 1 {
	tnode[j].arc = rep // 이 mem은 이미 매겼다
}
stack = j
rightoff += rep * size
if buf[p] == '+' {
	tnode[j].sib = rightoff
}

@ 여기까지 오면 나무가 다 놓였다. 다만 여러 벌 두라고 한 부분나무를 아직
복제하지 않았다.

복제본 안에 또 복제본이 있을 수 있다. 그래도 손보기는 쉽다. 할 일을 찾을 때는
아래에서 위로 훑고, 복제할 때는 위에서 아래로 하면 된다. (제법 귀엽다.) 어느
것도 두 번 하지 않으니 걸리는 시간은 마디 수에 비례한다.

@<복제본을 만든다@>=
for p = n - 1; p >= 0; p-- {
	mems++
	if tnode[p].arc == 0 {
		continue
	}
	s, j = tnode[p].deg, tnode[p].deg*tnode[p].arc
	mems++
	tnode[p].arc = 0 // 흔적을 지운다
	mems += 2
	i, tnode[p].sib = tnode[p].sib, p+s // 복제본이 |p|의 형제가 된다
	@<부분나무 하나를 |j/s|벌로 늘린다@>@;
	mems++
	tnode[k-s].sib = i // 맨 오른쪽 형제가 |p|의 본디 형제를 물려받는다
}

@ @<부분나무 하나를 |j/s|벌로 늘린다@>=
for k = p + s; k < p+j; k++ {
	mems++
	q, r = tnode[k-s].child, tnode[k-s].sib
	if q != 0 {
		mems++
		tnode[k].child = q + s
	}
	if r != 0 {
		mems++
		tnode[k].sib = r + s
	}
}

@ @<중심이 둘이면 손질한다@>=
if typ != 0 {
	mems++
	p = tnode[0].sib // 뿌리의 형제가 뿌리의 아들이 된다
	mems += 2
	tnode[p].sib, tnode[0].child = tnode[0].child, p
	tnode[0].sib = 0
	mems++
	tnode[0].deg = n
}

@ 나무 $S$를 얻으려면 먼저 $T$를 세워야 한다. 그 잎을 쳐 내야 하기 때문이다.

@<나무 $S$를 읽는다@>=
n = readRectree(targ)
if n <= del+2 {
	fmt.Fprintf(os.Stderr, "마디가 %d개뿐인 나무에서 %d개나 지우고 싶지는 않다!\n", n, del)
	os.Exit(200)
}
@<잎을 |del|개 하나씩 지운다@>@;

@ 잎을 지우는 이 방법은 뿌리 있는 나무의 짜임새를 지키되, 뿌리가 잎이 되면 그것도
지울 수 있게 한다. 먼저 모든 마디의 차수를 (부모는 빼고) 세면서 뿌리가 아닌 잎을
가려내는데, 그러는 김에 부모가 누구인지도 함께 적고 잎들을 목록에 늘어놓는다.
그다음 그 목록에서 아무 것이나 골라 지운다. 잎 하나를 지우면 그 부모의 차수가
하나 줄어드니, 부모가 다음 판에서 잎이 될 수도 있다.

부모는 |tnode|의 |arc| 밭에, 잎 목록은 |snode|의 |arc| 밭에 잠시 넣어 둔다. 지금은
둘 다 놀고 있는 밭이다. 여기서 |z|는 그때그때의 뿌리이고, |gg|는 잎의 수다. 잎을
지우면 그 부모 자리에 $-1$을 넣어 표시한다.

@<잎을 |del|개 하나씩 지운다@>=
z, gg = 0, 0
leafprep(0)
m = n - del
for ; del != 0; del-- {
	mems++
	d = 0
	if tnode[z].deg == 1 { // 뿌리도 잎인가?
		d = 1
	}
	r = int(rng.Unif(int64(gg + d))) // 잎을 아무거나 하나 고른다
	if r == gg {
		mems += 3
		z = tnode[z].child // 뿌리를 지운다
	} else {
		@<잎 |r|을 지우고 그 자리를 메운다@>@;
	}
}
restructure(z) // 이제 부모가 음수인 마디를 정말로 걷어낸다

@ @<잎 |r|을 지우고 그 자리를 메운다@>=
mems++
q = snode[r].arc
mems += 2
p, tnode[q].arc = tnode[q].arc, -1
mems += 2
tnode[p].deg--
if tnode[p].deg != 0 {
	mems++
	gg--
	p = snode[gg].arc
}
mems++
snode[r].arc = p // |q| 자리에 다른 잎을 앉힌다

@ 여기에는 크누스가 못 보고 지나친 자리가 하나 있다. 뿌리를 지울 때
|tnode[z].child|를 그대로 새 뿌리로 삼는데, 그 아들은 이미 지워진 마디일 수 있다.
밭 |deg|는 잎을 지울 때마다 줄여 두므로 살아 있는 아들의 수를 옳게 세지만,
|child|와 |sib|는 |restructure|가 맨 마지막에 손볼 때까지 낡은 채로 남아 있기
때문이다. 죽은 마디가 뿌리가 되면 |copyremap|이 엉뚱한 나무를 훑게 되고, 프로그램은
``어리둥절하다''를 찍고 멈춘다.

마디 $127$개짜리 나무 하나로 재어 보니 씨앗 $200$개 가운데 이만큼에서 그랬다.
$$\vbox{\halign{\hfil#\quad&#\hfil\cr
\noalign{\hrule\smallskip}
지우는 잎의 수&멈춘 씨앗\cr
\noalign{\smallskip\hrule\smallskip}
$100$&$0$\cr
$110$&$1$\cr
$116$&$12$\cr
$120$&$48$\cr
$124$&$134$\cr
\noalign{\smallskip\hrule}}}$$
$S$가 작아질수록 뿌리를 지우는 일이 잦아지니 자주 만난다. 고치기는 어렵지 않다.
마디 |q|를 |tnode[z].child|에서 시작해 |tnode[q].arc|가 음수인 동안 |tnode[q].sib|로
옮겨 간 뒤, 그 |q|를 새 뿌리로 삼으면 된다. 그러나 여기서는 고치지 않았다. 이 변경 파일이 하려는 일은 크누스의 것을 그대로 옮기는
것이고, mem 수까지 한 자리도 다르지 않아야 하기 때문이다. 크누스의 \CEE/ 판도
같은 입력에서 똑같이 멈춘다.

@ @<함수들@>=
func leafprep(p int) int {
	var d, q int
	mems += suboverhead
	for mems, d, q = mems+1, 0, tnode[p].child; q != 0; mems, q = mems+1, tnode[q].sib {
		d++
		tnode[q].arc = p
		if leafprep(q) == 0 {
			mems++
			snode[gg].arc = q
			gg++
		}
	}
	mems++
	tnode[p].deg = d
	return d
}

@ |restructure|는 |child|와 |sib| 밭을 다시 쓸 만하게 만든다.

@<함수들@>=
func restructure(p int) {
	var q int
	mems += suboverhead
	mems++
	q = tnode[p].child
	@<지워진 마디를 건너뛴다@>@;
	mems++
	tnode[p].child = q
	for q != 0 {
		mems++
		if tnode[q].child != 0 {
			restructure(q)
		}
		mems++
		p, q = q, tnode[q].sib
		@<지워진 마디를 건너뛴다@>@;
		mems++
		tnode[p].sib = q
	}
}

@ 조건 둘을 \&{\char'46\char'46}로 이은 자리다. 뒤엣것은 |q|가 $0$이 아닐 때만
따지므로 mem도 그때만 매긴다.

@<지워진 마디를 건너뛴다@>=
for q != 0 {
	mems++
	if tnode[q].arc >= 0 {
		break
	}
	mems++
	q = tnode[q].sib
}

@ 바라던 만큼 잎을 쳐 냈다. 그래도 아직 끝이 아니다. 이 프로그램은 $S$의 뿌리가
잎이기를 바라기 때문이다. 마디 번호를 속으로 모두 다시 매겨야 한다.

그래서 |tnode|를 뿌리가 잎이 되도록 손본 다음, 번호를 다시 매기며 |snode|로
옮긴다.

@<나무 $S$를 읽는다@>=
@<|tnode|의 뿌리를 잎으로 만든다@>@;
@<|tnode|를 |snode|로 옮기며 번호를 다시 매긴다@>@;

@ 크누스는 이 대목을 두고 ``이것이 이렇게 어려울 줄은 몰랐다. 내가 무엇을
놓쳤나? 자료 구조학의 아기자기한 연습문제다''라고 적었다.

마디~|z|는 마디~|n| 자리로 옮겨 간다. 그래야 (|z|가 $0$일 때에도) 남의 아들이나
형제가 될 수 있다.

@<|tnode|의 뿌리를 잎으로 만든다@>=
mems += 2
r, p = n, tnode[z].child
tnode[r].child = p
for {
	mems++
	q = tnode[p].child
	if q == 0 {
		break
	}
	@<|p|를 뿌리로 삼되 그 아들 |q|는 남겨 둔다@>@;
}
mems += 3
s = tnode[p].sib
tnode[p].sib, tnode[p].child = 0, r
tnode[r].child = s // 이제 |p|가 뿌리다

@ @<|p|를 뿌리로 삼되 그 아들 |q|는 남겨 둔다@>=
mems++
k, s = tnode[p].sib, tnode[q].sib
mems++
tnode[p].sib = 0
mems++
tnode[q].sib = r
mems++
tnode[r].child, tnode[r].sib = k, s
r, p = p, q

@ @<|tnode|를 |snode|로 옮기며 번호를 다시 매긴다@>=
gg = 0
copyremap(p)
if gg != m {
	fmt.Fprintln(os.Stderr, "어리둥절하다!")
	os.Exit(666)
}
mems += 2
snode[z].arc = snode[n].arc

@ 이 재귀는 조금 까다롭다. 어떻게 설명하는 것이 가장 좋을지 모르겠다.
(독자를 위한 연습문제로 남긴다.)

@<함수들@>=
var gg int // 번호를 다시 매기며 세는 전역 계수기

func copyremap(r int) {
	var p, q int
	mems += suboverhead
	gg++
	mems++
	p = tnode[r].child
	if p == 0 {
		return
	}
	mems++
	snode[gg-1].child = gg // 번호를 고친 아들 포인터를 옮긴다
	for {
		q = gg // |p|가 갖게 될 속 이름
		copyremap(p)
		mems++
		p = tnode[p].sib
		if p == 0 {
			return
		}
		mems++
		snode[q].sib = gg // 번호를 고친 형제 포인터를 옮긴다
	}
}

@ 그리고 $T$를 다시 읽는다. $S$를 만드느라 |tnode|를 헤집어 놓았기 때문이다.

@<나무 $T$를 읽는다@>=
n = readRectree(targ)
@<호에 번호를 매긴다@>@;
fmt.Fprintf(os.Stderr, "좋다, S의 마디 %d개와 T의 마디 %d개를 얻었다. 최대 차수는 %d.\n",
	m, n, maxdeg)
@z
@x
if verdict == 0 && m == 0 {
	verdict = 1 // 소년마다 아무 소녀나 좋다
}
@y
if verdict == 0 && m == 0 {
	verdict = 1 // 소년마다 아무 소녀나 좋다
}
if verdict == 0 && m*n > record {
	record = m * n
	fmt.Fprintf(os.Stderr, " ...소년 %d명을 소녀 %d명에게 짝지운다\n", m, n)
}
@z

@x
@ @<찾아낸 심기를 적는다@>=
mems += 2
fmt.Printf("%c", encode(uert[solarc[1]]))
for p = 1; p < m; p++ {
	mems += 2
	fmt.Printf(" %c", encode(vert[solarc[p]]))
}
fmt.Println()
@y
@ @<찾아낸 심기를 적는다@>=
mems += 2
fmt.Printf("%d", uert[solarc[1]])
for p = 1; p < m; p++ {
	mems += 2
	fmt.Printf(" %d", vert[solarc[p]])
}
fmt.Println()
@z
@x
@* 돌려 보기.
돌리는 법은 이렇다.
$$\vbox{\halign{\.{#}\hfil\cr
go run matula.go .0111444759a488cfch .011345676965cc5ffh5cklfn55...\cr}}$$
그러면 이렇게 답한다.
$$\vbox{\halign{\.{#}\hfil\cr
좋다, S의 마디 19개와 T의 마디 59개를 얻었다. 최대 차수는 7.\cr
마디 1의 심기를 붙들어 맬 자리가 3곳 있다.\cr
모두 해서 1917+14760 mem.\cr
D C E H u F v w x G O W t y z N V s j\cr}}$$
마지막 줄이 답이다. 나무 $S$의 마디 $0$, $1$, \dots, $18$이 차례로 $T$의 어느 마디로
가는지를 적은 것이다.

@ 그러니 퍼즐을 풀었는가?
@y
@* 돌려 보기.
돌리는 법은 이렇다.
$$\vbox{\halign{\.{#}\hfil\cr
go run matula.go T.rectree 5 42\cr}}$$
나무 $T$에서 잎을 다섯 개 지워 $S$를 만들라는 말이고, $42$는 난수의 씨앗이다.
그러면 이렇게 답한다.
$$\vbox{\halign{\.{#}\hfil\cr
좋다, S의 마디 54개와 T의 마디 59개를 얻었다. 최대 차수는 7.\cr
...소년 1명을 소녀 4명에게 짝지운다\cr
(네 줄 줄임)\cr
...소년 6명을 소녀 7명에게 짝지운다\cr
마디 1의 심기를 붙들어 맬 자리가 2곳 있다.\cr
모두 해서 5750+36561 mem.\cr
2 0 1 3 4 5 18 22 23 19 20 47 48 ... 53 54 55 57 58\cr}}$$
마지막 줄이 답이다. 씨앗이 같으면 크누스의 \CEE/ 판과 똑같은 잎을 지우므로, 답도
mem 수도 그대로 견줄 수 있다. 여기 적은 두 수도 그의 판이 찍는 것과 같다.

@ @<전역 변수@>=
var record int // 여태 만난 가장 큰 짝짓기 문제

@ 그러니 퍼즐을 풀었는가?
@z
