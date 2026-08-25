이 변경 파일은 크누스의 \.{matula-big.ch}를 우리 \.{GWEB} 판에 맞춘 것이다.
바꾸는 것은 결국 입력 방식 하나다. 명령줄에 부모 포인터 문자열을 주는 대신
{\it rectree\/} 형식의 파일 둘을 읽는다. 마디 이름이 글자 하나가 아니게 되니
마디 수의 한계가 $62$에서 $2000$으로 오른다. 적용:

    gtangle matula.w matula-big.ch     (-> 큰 나무를 다루는 matula.go)

그 대가로 뒤치다꺼리가 하나 딸려 온다. rectree 형식에는 ``$S$의 뿌리는 잎이어야
한다''는 약속이 없으므로, $S$를 읽은 뒤 뿌리를 잎으로 옮기고 마디 번호를 속으로
다시 매겨야 한다. 답을 찍을 때는 사용자가 준 번호로 되돌린다.


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
@ 두 나무는 {\it rectree\/} 형식의 파일 둘로 준다. 아래에 그 형식을 밝혀 두었다.
좀 별난 형식이지만, 크누스가 이 프로그램을 큰 무작위 나무로 시험하고 싶었기에
고른 것이다. 마디가 $n$개인 무작위 나무를 고르려면 $\Omega(2.9^n)$쯤 되는 아주
큰 수를 다루어야 해서 그는 셈을 Mathematica에 맡겼고, 그 프로그램
\.{randomfreetree.m}이 이 형식으로 나무를 뱉는다.

@ 이를테면 초기 시험에 쓰인 두 나무를 rectree로 적으면 이렇다.
$$\vtop{\halign{\tt#\hfil\cr
\char`\%\ example pattern tree S\cr
T19\_0.\cr
T19\_0=+1T18\_1.\cr
T18\_1=+2T1\_2+1T15\_4.\cr
T15\_4=+1T4\_5+1T4\_9+1T5\_13+1T1\_18.\cr
T5\_13=+2T2\_14.\cr
T4\_9=+1T3\_10.\cr
T3\_10=+2T1\_11.\cr
T4\_5=+1T3\_6.\cr
T3\_6=+1T2\_7.\cr}}\qquad
\vtop{\halign{\tt#\hfil\cr
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
(손으로 지은 것이지 \.{randomfreetree.m}이 뱉은 것은 {\it 아니다\/}.)
$T$ 안에서 $S$를 찾을 수 있겠는가? 아래 그림의 마디 이름은 이 rectree 명세의
마디 번호를 뒤섞은 것이다.
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
	fmt.Fprintf(os.Stderr, "쓰는 법: %s S의부모들 T의부모들\n", os.Args[0])
@y
	fmt.Fprintf(os.Stderr, "쓰는 법: %s S.rectree T.rectree\n", os.Args[0])
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

@ 이 프로그램은 $S$의 뿌리가 잎이기를 바란다. rectree가 그것을 보장하지 않으니
대개는 마디 번호를 모두 다시 매겨야 한다---적어도 속으로는. 겉으로 알릴 때는
번호를 매긴 적이 없다는 듯이 보여야 한다.

그래서 나무 $S$도 일단 |tnode|에 읽어 들인다. 그것을 뿌리가 잎이 되도록 손본
다음, 번호를 다시 매기며 |snode|로 옮긴다. 마디~|k|의 새 번호는 |snode[k].arc|에
넣는데, 그 밭은 $S$에서는 달리 쓸 데가 없다.

@<나무 $S$를 읽는다@>=
m = readRectree(sarg)
@<|tnode|의 뿌리를 잎으로 만든다@>@;
@<|tnode|를 |snode|로 옮기며 번호를 다시 매긴다@>@;

@ 크누스는 이 대목을 두고 ``이것이 이렇게 어려울 줄은 몰랐다. 내가 무엇을
놓쳤나? 자료 구조학의 아기자기한 연습문제다''라고 적었다.

마디~$0$은 마디~|m| 자리로 옮겨 간다. 그래야 남의 아들이나 형제가 될 수 있다.

@<|tnode|의 뿌리를 잎으로 만든다@>=
mems += 2
r, p = m, tnode[0].child
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
copyremap(p)
if gg != m {
	fmt.Fprintln(os.Stderr, "어리둥절하다!")
	os.Exit(666)
}
mems += 2
snode[0].arc = snode[m].arc

@ 이 재귀는 조금 까다롭다. 어떻게 설명하는 것이 가장 좋을지 모르겠다.
(독자를 위한 연습문제로 남긴다.)

@<함수들@>=
var gg int // 번호를 다시 매기며 세는 전역 계수기

func copyremap(r int) {
	var p, q int
	mems += suboverhead
	mems++
	snode[gg].deg = r // |deg|는 |arc|의 역 사상이다
	mems++
	snode[r].arc = gg // 사용자가 부르는 이름 |r|의 속 이름이 |gg|다
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

@ $T$ 쪽은 읽어 들이기만 하면 된다.

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
@<답을 알린다@>=
if z < 0 {
	fmt.Fprintf(os.Stderr, "실패. 마디 %c와 그 부모조차 심을 수 없다.\n", encode(-z))
} else {
	fmt.Fprintf(os.Stderr, "마디 1의 심기를 붙들어 맬 자리가 %d곳 있다.\n", z)
	if z != 0 {
		@<답 하나를 인쇄한다@>@;
	}
}
@y
@<답을 알린다@>=
if z < 0 {
	@<심을 수 없는 마디와 그 부모를 찾아 알린다@>@;
} else {
	fmt.Fprintf(os.Stderr, "마디 %d의 심기를 붙들어 맬 자리가 %d곳 있다.\n", snode[1].deg, z)
	if z != 0 {
		@<답 하나를 인쇄한다@>@;
	}
}

@ 속으로 매긴 번호가 아니라 사용자가 준 번호로 알려야 한다. 마디 |k|의 부모는
|k|를 아들로 두거나, |k|를 형제로 두는 마디를 거슬러 올라가면 만난다.

@<심을 수 없는 마디와 그 부모를 찾아 알린다@>=
k = -z
for p = k - 1; ; p-- {
	if snode[p].child == k {
		break
	} else if snode[p].sib == k {
		k = p
	}
}
fmt.Fprintf(os.Stderr, "실패. 마디 %d번과 그 부모 %d번조차 심을 수 없다.\n",
	snode[-z].deg, snode[p].deg)
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
@ 속 이름 |snode[p].arc|를 거쳐, 사용자가 준 번호 차례로 찍는다.

@<찾아낸 심기를 적는다@>=
for p = 0; p < m; p++ {
	mems++
	q = snode[p].arc // 번호를 다시 매기기 전에 |p|라 불리던 마디
	if q != 0 {
		mems += 2
		fmt.Printf(" %d", vert[solarc[q]])
	} else {
		mems += 2
		fmt.Printf(" %d", uert[solarc[1]])
	}
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
go run matula.go S.rectree T.rectree\cr}}$$
그러면 이렇게 답한다.
$$\vbox{\halign{\.{#}\hfil\cr
좋다, S의 마디 19개와 T의 마디 59개를 얻었다. 최대 차수는 7.\cr
...소년 1명을 소녀 2명에게 짝지운다\cr
...소년 1명을 소녀 3명에게 짝지운다\cr
(다섯 줄 줄임)\cr
...소년 3명을 소녀 5명에게 짝지운다\cr
마디 1의 심기를 붙들어 맬 자리가 3곳 있다.\cr
모두 해서 3221+14939 mem.\cr
36 35 38 37 27 40 41 42 43 29 30 31 32 26 25 24 45 46 28\cr}}$$
마지막 줄이 답이다. 나무 $S$의 마디 $0$, $1$, \dots, $18$이 차례로 $T$의 어느
마디로 가는지를 적은 것인데, 여기서 쓰는 번호는 rectree 파일에 적힌 번호다.
아래 그림의 이름과는 뒤섞여 있다.

@ @<전역 변수@>=
var record int // 여태 만난 가장 큰 짝짓기 문제

@ 그러니 퍼즐을 풀었는가?
@z
