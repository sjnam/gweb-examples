\input kotexgweb
@i types.w
\datethis

\def\title{곱셈 뼈대 퍼즐}
\def\blank{\phantom{0}} % 고정폭 글꼴에서 숫자 한 칸만큼 비운다

@s bignum int

@* 들어가며.
이 프로그램은 Junya Take가 개척한 {\it 곱셈 뼈대\/} 퍼즐을 짓는다. 그의 퍼즐 하나를
보자. {\sl Journal of Recreational Mathematics\/ \bf38} (2014), 132쪽에 실린 글자
\.O 퍼즐이다.
@^Take, Junya@>
$$\vcenter{\halign{\hfil\tt#\cr
.......\cr
$\times$\hfil......\cr
\noalign{\medskip\hrule\medskip}
........\cr
OO.....\blank\cr
..O..O..\blank\blank\blank\cr
...O..O.\blank\blank\blank\blank\cr
...O..O\blank\blank\blank\blank\blank\cr
\noalign{\medskip\hrule\medskip}
....OO......\cr}}$$
글자 `\.O'는 모두 같은 숫자 $d$로, 점 `\..'은 저마다 $d$가 아닌 숫자로 바꾸어야
한다. (그리고 가장 높은 자리에는 0이 올 수 없다.) 답은 하나뿐이다.
$$\vcenter{\halign{\hfil\tt#\cr
2208068\cr
$\times$\hfil357029\cr
\noalign{\medskip\hrule\medskip}
19872612\cr
4416136\blank\cr
15456476\blank\blank\blank\cr
11040340\blank\blank\blank\blank\cr
6624204\blank\blank\blank\blank\blank\cr
\noalign{\medskip\hrule\medskip}
788344309972\cr}}$$
그런데 이 프로그램이 하려는 일은 이런 퍼즐을 {\it 푸는\/} 것이 아니다! 이런 퍼즐을
{\it 지어내는\/} 것이다. 다시 말해, 부분곱들과 최종 곱의 자릿수가 주어진 이진
패턴에 들어맞는 정수 $x$와 $y$를 찾는다.

패턴은 표준 입력 |stdin|으로 여러 줄에 걸쳐 들어오며, 별표가 특별한 숫자의 자리를
가리킨다. 이를테면 위 퍼즐의 `\.O' 모양은 이렇게 적는다.
$$\vcenter{\halign{\hfill\tt#\cr
.**.\cr
*..*\cr
*..*\cr
*..*\cr
.**.\cr}}$$

@ 이것은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{back-skeleton.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/back-skeleton.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Fri, 19 May 2017 04:50:42 GMT}다. 퍼즐을 푸는 프로그램은 흔하지만 퍼즐을
{\it 짓는\/} 프로그램은 드물어서, 나는 이것을 옮기지 않을 수 없었다.

옮기다가 버그 둘을 만났다. 하나는 쉼표 하나 때문에 조건 하나가 통째로 사라진
것인데, 그 탓에 원본은 바로 위에 보인 Take의 퍼즐을 찾지 못한다. 이 판은 그것을
고쳤다. 이야기는 맨 뒤에 적었다.

@ 위의 예에서 보듯, 곱하는 수에 0이 끼면 모양이 여러 가지로 ``어긋난다.'' 그래서
곱하는 수의 0 아닌 자릿수 개수 $m$을 정해 두고, 가능한 어긋남을 모두 해 본다.

두 번째 매개변수 $z$는 곱하는 수에 들어갈 수 있는 0의 개수의 최댓값이다. 두 값
모두 명령줄에서 받는다.

프로그램의 얼개는 이렇다. 크누스는 C의 매크로 |o|와 |oo|로 메모리 접근(mem)을
셌다. \GO/에는 매크로가 없으므로, 그 자리마다 |mems++|나 |mems+=2|를 문장 앞에
적는다. 크누스가 매크로를 붙인 곳에는 빠짐없이 그대로 옮겼으니, 끝에 찍히는 mem
수로 옮김이 옳은지 검산할 수 있다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

const (
	maxdigs = 22 // 다루는 가장 긴 수의 자릿수 더하기 2
	maxdim  = 8  // 패턴의 최대 크기
	maxm    = 8  // |m|은 이보다 작아야 한다
)

@<자료형@>
@<전역 변수@>
@<함수들@>

func main() {
	var d, i, ii, imax, j, k, kk, l, lc, lj, n, t, tt, x, pos, maxl int
	var printed bool // 지금 곱해지는 수로 된 해를 이미 찍었나?
	@<명령줄을 처리한다@>
	@<패턴을 읽는다@>
	@<곱셈 표를 만든다@>
	@<가장 작은 어긋남을 정한다@>
	for {
		@<패턴에서 자세한 명세를 만든다@>
		for d = 0; d < 10; d++ {
			if vbose > 0 {
				fmt.Fprintf(os.Stderr, " *=%d:\n", d)
			}
			@<지금의 어긋남과 특별한 숫자 $d$에 대한 해를 모두 찾는다@>
		}
		@<다음 어긋남으로 나아가되, 0이 너무 많아지면 |break|한다@>
	}
	out.Flush()
	fmt.Fprintf(os.Stderr, "모두 해 %d개, 노드 %d개, mem %d개.\n",
		count, nodes/10, mems)
	if unresolved > 0 {
		fmt.Fprintf(os.Stderr, "... 풀리지 않은 경우가 %d개다!\n", unresolved)
	}
}

@ 전역 변수는 대부분 크누스의 것 그대로다. 해는 한 줄에 수십 번씩 나누어 찍으므로,
표준 출력은 |bufio.Writer| |out|으로 모았다가 내보낸다.

@<전역 변수@>=
var (
	m          int    // 곱하는 수의 0 아닌 자릿수 개수
	z          int    // 곱하는 수의 0 개수의 최댓값
	vbose      int    // 얼마나 수다스럽게 굴 것인가
	buf        string // 패턴을 읽을 때 쓰는 버퍼
	rawpat     [maxdim][maxdim]bool // 날 패턴의 화소
	last       [maxdim]int          // 가장 오른쪽 별표의 위치
	count      int                  // 지금까지 찾은 해의 수
	nodes      uint64 // 되짚어 찾기 나무의 크기의 10배
	unresolved int    // 풀리지 않고 남은 경우의 수
	mems       uint64 // 메모리 접근 수
	out        = bufio.NewWriter(os.Stdout)
)

@ 크누스는 |sscanf|로 수를 읽었다. 나는 |strconv.Atoi|로 읽고, 인자가 모자라거나
수로 읽히지 않으면 사용법을 알린다.

@<명령줄을 처리한다@>=
var err1, err2 error
if len(os.Args) >= 3 {
	m, err1 = strconv.Atoi(os.Args[1])
	z, err2 = strconv.Atoi(os.Args[2])
}
if len(os.Args) < 3 || err1 != nil || err2 != nil {
	fmt.Fprintf(os.Stderr,
		"사용법: %s m z [자세히] [더자세히] < foo.dots\n", os.Args[0])
	os.Exit(-1)
}
if m < 2 || m >= maxm {
	fmt.Fprintf(os.Stderr, "m은 2와 %d 사이여야 한다. %d는 안 된다!\n",
		maxm-1, m)
	os.Exit(-2)
}
if m+z > maxdigs-2 {
	fmt.Fprintf(os.Stderr, "m+z는 %d 이하여야 한다. %d는 안 된다!\n",
		maxdigs-2, m+z)
	os.Exit(-3)
}
vbose = len(os.Args) - 3

@ 패턴의 행 수 $n$이 정해지면, 곱하는 수에는 0 아닌 자릿수가 적어도 $n-1$개
있어야 한다. 부분곱 $n-1$개와 최종 곱 하나가 패턴의 $n$행을 맡기 때문이다.

@<패턴을 읽는다@>=
in := bufio.NewScanner(os.Stdin)
for n, k = 0, 0; in.Scan(); n++ {
	if n >= maxdim {
		fmt.Fprintf(os.Stderr, "다시 컴파일하라. 입력은 %d줄까지만 받는다!\n",
			maxdim)
		os.Exit(-3)
	}
	@<패턴의 |n|번째 행을 읽는다@>
}
fmt.Fprintf(os.Stderr, "좋다, 행이 %d개이고 별표가 %d개인 패턴을 받았다.\n",
	n, k)
if m < n-1 {
	fmt.Fprintf(os.Stderr,
		"그러면 곱하는 수의 자릿수가 %d개는 있어야 한다. %d개로는 안 된다!\n",
		n-1, m)
	os.Exit(-2)
}

@ @<패턴의 |n|번째 행을 읽는다@>=
buf = in.Text()
for j = 0; j < len(buf); j++ {
	if buf[j] == '*' {
		if j >= maxdim {
			fmt.Fprintf(os.Stderr, "다시 컴파일하라. 한 행에는 %d칸까지만 받는다!\n",
				maxdim)
			os.Exit(-5)
		}
		mems += 2; rawpat[n][j] = true; k++; last[n] = j + 1
	}
}

@* 큰 수.
음 아닌 정수의 십진 덧셈을 꾸린다. 정수 하나는 바이트 배열로 나타내는데, 첫
바이트는 유효 자릿수의 개수이고 나머지 바이트는 자릿수 자체를 (오른쪽에서 왼쪽으로)
담는다. 나는 바이트 대신 |int|를 썼다. 형 변환을 곳곳에 적지 않으려는 것이다.

@<자료형@>=
type bignum [maxdigs]int

@ 이를테면 큰 수 하나를 다른 큰 수로 베끼기는 쉽다. 베끼기는 여러 곳에서 쓰므로
함수로 둔다. 이름을 |copy|로 하면 \GO/의 내장 함수를 가리므로 |bcopy|라 했다.
두 큰 수가 같은지 보는 것도 쉬운데, 크누스의 |isequal|은 한 곳에서만 쓰이므로 그
자리에 절로 끼워 넣었다.

@<함수들@>=
func bcopy(a, b *bignum) { // $a=b$
	lb := b[0]
	mems++
	for i := 0; i <= lb; i++ {
		mems += 2; a[i] = b[i]
	}
}

@ 기본 연산은 이것이다. 인자 |a|와 |b|가 같거나 |b|와 |c|가 같아도 괜찮다. (그러나
|a|와 |c|가 같으면 조심하라.)

마지막의 넘침 검사는 크누스의 것을 그대로 두었다. \GO/에서는 배열 밖에 쓰는
순간 먼저 |panic|이 나겠지만, 뒤에서 보듯 이 프로그램은 거기까지 가지 않는다.

@<함수들@>=
func add(a, b, c *bignum, p int) { // $a=b+10^p c$
	lb, lc := b[0], c[0]
	mems += 2
	if lc == 0 {
		bcopy(a, b)
		return
	}
	i := 1
	for ; i <= p && i <= lb; i++ {
		mems += 2; a[i] = b[i]
	}
	for k := 0; i <= lb || i <= lc+p || k != 0; i++ {
		d := k
		if i <= lb {
			mems++; d += b[i]
		}
		if i <= lc+p && i > p {
			mems++; d += c[i-p]
		}
		if d >= 10 {
			k, d = 1, d-10
		} else {
			k = 0
		}
		mems++; a[i] = d
	}
	mems++; a[0] = i - 1
	if i >= maxdigs {
		out.Flush()
		fmt.Fprintf(os.Stderr, "정수가 넘쳤다. %d자리보다 길다!\n", maxdigs-1)
		os.Exit(-666)
	}
	if a[a[0]] == 0 {
		fmt.Fprintf(os.Stderr, "왜?\n")
	}
}

@ 원시적인 곱셈 표도 하나 있으면 좋겠다. 큰 수 |cnst[k]|는 $0\le k\le81$인 $k$를
담는다. 한 자릿수끼리의 곱은 모두 여기 들어 있다.

@<곱셈 표를 만든다@>=
mems++; cnst[0][0] = 0
for k = 1; k < 10; k++ {
	mems += 2; cnst[k][0], cnst[k][1] = 1, k
}
for ; k <= 81; k++ {
	mems += 3; cnst[k][0], cnst[k][2], cnst[k][1] = 2, k/10, k%10
}

@ @<전역 변수@>=
var cnst [82]bignum

@* 어긋남과 제약.
번호가 $0\le k\le m$인 $k$번째 부분곱은 왼쪽으로 |off[k]|만큼 밀린다. ($k=m$일 때는 곱
전체, 곧 밀린 부분곱들의 합이다.) 그리고 $n$행 패턴 |rawpat|의 $k-(m+1-n)$번째
행이 주는 제약을 물려받는다.

패턴 |rawpat|의 자료는 ``왼쪽에서 오른쪽으로'' 적혀 있지만, 자릿수에 대한 제약은
``오른쪽에서 왼쪽으로'' 센다. 곧 |rawpat|의 0번째 열은 제약을 받는 가장 높은
자릿수를 가리킨다.

부분곱 $({}\ldots p_2p_1p_0)_{10}$에 대한 제약은 어떤 $i$에 대해서는 $p_i=d$이고
나머지에 대해서는 $p_i\ne d$라는 것이다. 이 제약을 큰 수 하나로 나타내는데,
``|d|''인 자리에는 1을, 다른 자리에는 0을 둔다.

이를테면 들어가며 절의 첫 퍼즐은 $m=5$, $z=1$이고, 어긋남은 (0, 1, 3, 4, 5),
제약은 (0, 1100000, 100100, 10010, 1001, 11000000)이다.

곱해지는 수나 부분곱의 길이에는 제약을 두지 않는다. 명시적으로 제약된 자리보다
왼쪽에 있는 자릿수는 모두 $d$와 달라야 한다는 것만 요구한다. 그러니 퍼즐 후보가
여럿 나오고, 그 가운데 일부는 답이 하나가 아닐 것이다.

@ @<가장 작은 어긋남을 정한다@>=
for i = 0; i < m; i++ {
	mems++; off[i] = i
}

@ 어긋남 표는 $s_0=0$이고 $s_{m-1}<m+z$인 조합 $s_0<s_1<\cdots<s_{m-1}$을 모두
사전식 차례로 훑는다.

@<다음 어긋남으로 나아가되, 0이 너무 많아지면 |break|한다@>=
for i = m - 1; i > 0; i-- {
	mems++
	if off[i] < i+z {
		break
	}
}
if i == 0 {
	break
}
mems++; off[i]++
for i++; i < m; i++ {
	mems += 2; off[i] = off[i-1] + 1
}

@ 날 패턴의 0번째 열이 최종 곱의 어느 자리 |pos|에 올지 골라야 한다. 그러면
$k$번째 부분곱의 $j$번째 열은 |pos-off[k]-j| 자리에 온다.

자리 |pos|를 가장 오른쪽(가장 작은 값)으로 두면, 적어도 한 제약은 1로 끝난다.
그 최솟값보다 |pos|가 크면 더 어려운 퍼즐이 된다. 이 프로그램은 |pos|를 가능한 최솟값에
컴파일할 때 정하는 매개변수 |slack|을 더한 값으로 둔다. Take는 $|slack|=1$인 예를
여럿 발표했고 크누스도 그런 경우를 살펴보고 싶어 했지만, 기본값은 $|slack|=0$이다.

패턴의 행 $i$는 $0\le i<n$에서 돈다. 원본은 여기서 $i\le m$까지 돌았다. 그러면
$i\ge n$에서 배열 |off|의 경계를 넘어 읽을 수 있다. 이 이야기도 맨 뒤에 적었다.

@<|pos|를 고른다@>=
for i, pos = 0, 0; i < n; i++ {
	mems += 2
	if off[m+1-n+i]+last[i] > pos {
		pos = off[m+1-n+i] + last[i]
	}
}
pos += slack - 1

@ @<전역 변수@>=
const slack = 0 // 더 어려운 퍼즐을 위해 패턴을 왼쪽으로 옮기는 양

@ 가끔 두 제약이 똑같을 때가 있는데, 그 사실을 알아 두고 싶다. 그래서 표 |id|를
두어, $c_j=c_k$일 때 그리고 그때만 |id[j]=id[k]|가 되게 한다.

@<제약을 세운다@>=
for k, ids = 0, 0; k <= m; k++ {
	mems++; i = k - (m + 1 - n); constr[k][0] = 0
	if i >= 0 {
		@<|constr[k]|에 패턴의 |i|번째 행을 옮긴다@>
	}
	for j = k - 1; j >= 0; j-- {
		@<|constr[j]|와 |constr[k]|가 같으면 |break|한다@>
	}
	if j >= 0 {
		mems += 2; id[k] = id[j]
	} else {
		mems++; id[k] = ids; ids++
	}
}

@ 제약을 세울 때는 제약된 자리들 아래를 먼저 0으로 지운 뒤, 행의 열을 오른쪽부터
옮긴다. 마지막으로 옮긴 1이 가장 높은 자리이므로, 그 자리가 곧 제약의 길이가 된다.

@<|constr[k]|에 패턴의 |i|번째 행을 옮긴다@>=
mems += 2
for j = pos - off[k] - last[i] + 1; j >= 0; j-- {
	mems++; constr[k][j] = 0
}
mems++
for j = last[i] - 1; j >= 0; j-- {
	mems++
	if rawpat[i][j] {
		mems += 3; constr[k][pos-off[k]-j+1] = 1
		constr[k][0] = pos - off[k] - j + 1
	} else {
		mems += 2; constr[k][pos-off[k]-j+1] = 0
	}
}

@ 크누스의 함수 |isequal|을 이 자리에 풀어 놓았다. 길이가 같고 자릿수가 모두
같으면 바깥 반복문을 빠져나간다. 첫 줄의 네 mem 가운데 둘은 함수를 부르는 쪽이,
둘은 길이를 견주는 쪽이 센 것이다.

@<|constr[j]|와 |constr[k]|가 같으면 |break|한다@>=
mems += 4
if constr[j][0] == constr[k][0] {
	for i = 1; i <= constr[j][0]; i++ {
		mems += 2
		if constr[j][i] != constr[k][i] {
			break
		}
	}
	if i > constr[j][0] {
		break
	}
}

@ @<전역 변수@>=
var (
	off    [maxm]int    // 부분곱의 오른쪽 빈칸 수
	constr [maxm]bignum // 십진수로 바꾼 제약 패턴
	id     [maxm]int    // 제약의 동치류 번호
	ids    int          // 동치류가 몇 개인가
)

@ @<패턴에서 자세한 명세를 만든다@>=
@<|pos|를 고른다@>
@<제약을 세운다@>
if vbose > 0 {
	fmt.Fprintf(os.Stderr, "어긋남")
	for k = 0; k <= m; k++ {
		fmt.Fprintf(os.Stderr, " %d", off[k])
	}
	fmt.Fprintf(os.Stderr, "에 대한 제약:")
	for k = 0; k <= m; k++ {
		fmt.Fprintf(os.Stderr, " ")
		@<큰 수 |constr[k]|를 찍는다@>
	}
	fmt.Fprintf(os.Stderr, ".\n")
}

@ 크누스의 함수 |print_bignum|도 여기서만 쓰이므로 절로 풀었다.

@<큰 수 |constr[k]|를 찍는다@>=
if constr[k][0] == 0 {
	fmt.Fprintf(os.Stderr, "0")
} else {
	for i = constr[k][0]; i > 0; i-- {
		fmt.Fprintf(os.Stderr, "%d", constr[k][i])
	}
}

@* 되짚어 찾기.
곱해지는 수를 $(a_l\ldots a_2a_1a_0)_{10}$이라 하자. 먼저 $a_0$에 $d$가 아닌 것을
모두 넣어 보고, 그다음 $a_0$와 어울리는 $a_1$을 모두 넣어 보고, 이런 식으로
나아간다. 큰 수의 크기에 한계가 있으므로 $l$의 상한은 $|maxdigs|-2-s_{m-1}$이다.
그러나 크누스는 정말로 큰 해가 자주 나올 것 같지는 않다고 했다.

(매개변수 |slack|이 양수이면 $a_0=0$을 막는다. 그런 해는 |slack|이 더 작을 때 이미 나왔을
것이기 때문이다.)

실행 중인 예제의 제약과 어긋남을 자세히 보면 기본 생각이 뚜렷해진다. 편의상 $d=1$이라
하자. 어긋남이 그러하므로 곱하는 수는 $(b_5b_4b_30b_1b_0)_{10}$이다. 부분곱
$(p_0,p_1,p_2,p_3,p_4,p_5)$는 차례로 $b_0$, $b_1$, $b_3$, $b_4$, $b_5$에 대한
것과 총합이다. 이들은 앞서 말한 대로 제약 (0, 1100000, 100100, 10010, 1001,
11000000)을 만족해야 한다.

이제 $a_0=3$이라 하자. 그러면 $b_5=7$이어야 한다. 부분곱 $p_4$가 1로 끝나게 하는 길은
그것뿐이다.

그리고 $b_5=7$이면 $b_0$, $b_1$, $b_3$, $b_4$는 7일 수 없다. 이 문제에서는 다섯
제약이 모두 다르므로, 어느 두 $b$도 같을 수 없기 때문이다. (두 $b$가 같으면 두
부분곱이 같고, 그러면 두 제약도 같아야 한다.)

더 나아가, $a_0=3$이면 $a_1=3$일 수 없다. 곱하는 수의 후보는 2부터 9까지인데,
$2\le k\le9$일 때 $33k\bmod100$의 값은 차례로 (66, 99, 32, 65, 98, 31, 64, 97)이고,
그 가운데 어느 것도 제약 10010에 맞지 않기 때문이다.

또 $a_0=3$이고 $a_1=4$이면 $b_5=7$이고 $b_4=5$여야 한다. 게다가 $a_2=4$는 제약 1001을
망친다. 곱 $443\times7$이 3101이기 때문이다. 값 $a_2\in\{3,8,9\}$도 안 된다. 제약
100100을 만족하는 곱하는 수 자릿수가 하나도 없기 때문이다. 그러니 $a_2$는 0, 2, 6
가운데 하나여야 한다.
(옮긴이가 셈해 보니 조금 다르다. 제약 100100이 막는 값은 $\{3,7,8,9\}$이고,
살아남는 값은 0, 2, 5, 6 넷이다. 그중 5는 $543\times4=2172$이므로 $b_3=4$로 통한다.
원본도 이 판도 실제로 이 넷을 시도한다. 틀린 것은 프로그램이 아니라 설명이다.)

이런 식으로 나아가면, 그리 멀리 가기 전에 곱해지는 수의 끝자리 후보가 대부분
걸러진다. 알맞은 $a_l$을 고를 때는 $0\le k<m$인 제약 $c_k$마다 아래 $l$자리를
살핀다. 곱하는 수의 자릿수 후보 가운데 0도 $d$도 아닌 여덟 개 중 적어도 하나는 그
제약을 만족해야 한다. 게다가 {\it 꼭\/} 하나만 통하면, 곱하는 수의 자릿수 $b_i$
하나가 특정한 값으로 강제된다.

곱하는 수의 자릿수가 충분히 강제되면 마지막 제약 $c_m$(곧 전체 곱에 대한 제약)을
따지기 시작할 수 있다. 이 프로그램은 나머지 $m$개 제약을 저마다 만족하는 방법 수의
곱이 어떤 문턱보다 작을 때만 그렇게 한다. 이를테면 $m=5$이고 지금의 ``상태''가
33121이라 하자. 곧 제약 $(c_0,c_1,c_2,c_3,c_4)$를 저마다 $(3,3,1,2,1)$가지로 만족할
수 있다는 뜻이다. 그러면 문턱이 18 이상일 때만 $c_m$을 시험한다.

아래 $l$자리만이 아니라 무한 정밀도로 만족되는 제약을 {\it 완전히\/} 만족되었다고
한다. 모든 제약이 완전히 만족되면 해를 얻은 것이다.

해를 하나 찾으면, 곱해지는 수 앞에 0 아닌 자릿수를 덧붙여 해를 늘릴 수 있을 때가
있다. 이를테면 $a=2208068$, $b=357029$, $d=4$가 \.O 패턴의 퍼즐이 됨을 안다.
그런데 $a=302208068$, $b=357029$, $d=4$도 퍼즐이 된다. 앞에 붙인 `30'은 부분곱에도
최종 곱에도 쓸데없는 4를 들여오지 않는다.

@ 이런 생각에서, 알고리즘 7.2.2B의 요리법을 따르는 표준적인 되짚어 찾기 틀이
나온다. 크누스의 단계 이름표 |b1|은 아무도 그리로 뛰지 않는다. \GO/는 쓰지 않는
이름표를 허락하지 않으므로 뺐다. 되짚어 찾기가 쓰는 변수를 모두 |main|의 첫머리에
선언해 둔 것도 \GO/ 때문이다. 문장 |goto|는 변수 선언을 건너뛸 수 없다.

@<지금의 어긋남과 특별한 숫자 $d$에 대한 해를 모두 찾는다@>=
mems++; maxl = maxdigs - 2 - off[m-1]
l = 0
@<자료 구조를 초기화한다@>
b2:
	nodes += 10
	if vbose > 1 {
		fmt.Fprintf(os.Stderr, "수준 %d,", l)
		@<|csize| 상태를 찍는다@>
	}
	if l >= maxl {
		@<드문 해가 있는지 살피고 |b5|로 간다@>
	}
	@<모든 제약이 완전히 만족되면 해를 찍는다@>
	x = 0

@ 단계 |b3|은 $a_l=x$를 시험하고, 통하면 한 수준 내려간다. 단계 |b4|는 다음
$x$로, 단계 |b5|는 한 수준 위로 간다.

@<지금의 어긋남과 특별한 숫자 $d$에 대한 해를 모두 찾는다@>=
b3:
	if slack != 0 && l == 0 && x == 0 {
		goto b4
	}
	if x == d {
		goto b4
	}
	if vbose > 2 {
		fmt.Fprintf(os.Stderr, " %d 시험\n", x)
	}
	@<$a_l=x$일 때 만족할 수 없는 제약이 있으면 |b4|로 간다@>
	mems++; a[l] = x
	if vbose > 1 {
		fmt.Fprintf(os.Stderr, "a[%d]=%d 시도\n", l, x)
	}
	@<자료 구조를 갱신한다@>
	l++
	goto b2
b4:
	if x == 9 {
		goto b5
	}
	x++
	goto b3
b5:
	l--
	if l >= 0 {
		if vbose > 1 {
			fmt.Fprintf(os.Stderr, "수준 %d로 돌아간다\n", l)
		}
		mems++; x = a[l]
		@<자료 구조를 되돌린다@>
		goto b4
	}

@ 어떤 자료 구조가 이 계산을 잘 받쳐 줄까? 먼저 큰 수의 배열이 있다.
배열 |ja[l][j]|는 주어진 수준에서 부분적인 곱해지는 수 $(a_l\ldots a_0)_{10}$의
$j$배를 담는다. 물론 |ja[l][j]|는 |ja[l-1][j]|에 $j\cdot10^{\mkern1mul}a_l$을 더한
것이다. 이 항목들은 필요한 $j$에 대해서만 계산한다. 배열 |stamp[l][j]|는 그 값을
마지막으로 계산한 노드 번호를 담는다. (실은 |nodes+x|를 담는다. 노드 수를 10씩
늘리는 까닭이 이것이다. 그러면 노드와 $x$의 쌍마다 도장이 모두 달라진다.)

또 배열 |choice[k]|는 제약 |k|에 대해 아직 배제되지 않은 곱하는 수의 0 아닌
자릿수를 늘어놓는다. 수준 |l|에서 그 크기는 |csize[l][k]|다. 사실 |choice[k]|는
$\{0,1,\ldots,9\}$의 순열이고 |where[k]|는 그 역순열이다. 수준 |l|에서 살아 있는
원소는 |where[k][j]<csize[l][k]|인 $j$들이다. 이렇게 짜 두면 되짚어 가면서 목록에서
원소를 지우기가 쉽다.

@<전역 변수@>=
var (
	ja       [maxdigs][10]bignum // 곱해지는 수의 배수들
	stamp    [maxdigs][10]uint64 // 그것들을 계산한 때
	choice   [maxm][10]int       // 쓸 수 있는 곱하는 수의 순위
	where    [maxm][10]int       // 순열 |choice[k]|의 역
	csize    [maxdigs][maxm]int  // 지금의 살아 있는 정도
	stack    [maxm]int           // 하나로만 만족되게 된 제약들
	stackptr int                 // 스택 |stack|의 지금 크기
	a        [maxdigs]int        // 곱해지는 수
	total    bignum              // 해인지 따질 때 쓰는 총합
)

@ 특별한 숫자 $d$가 0이면 곱하는 수에 0이 있어서는 안 된다. 곱하는 수의 자릿수도
퍼즐에서는 점으로 나오기 때문이다. 그러니 그런 어긋남은 탐색을 시작하지도 않는다.

@<자료 구조를 초기화한다@>=
if d == 0 && off[m-1] >= m {
	goto b5 // |d=0|이면 곱하는 수에 0을 막는다
}
for i, j = 0, 1; j < 10; j++ {
	if j != d {
		for k = 0; k < m; k++ {
			mems += 2; choice[k][i] = j; where[k][j] = i
		}
		i++
	}
}
for k = 0; k < m; k++ {
	mems += 4; csize[0][k] = i; choice[k][i] = d; where[k][d] = i
	where[k][0] = 9
} // |d=0|이면 |i=9|이고, 아니면 8이다

@ @<|csize| 상태를 찍는다@>=
for k = 0; k < m; k++ {
	fmt.Fprintf(os.Stderr, "%d", csize[l][k])
}
fmt.Fprintf(os.Stderr, "\n")

@ 제약마다 $a_l=x$를 시험한 뒤, 하나로 좁혀진 제약들의 숫자를 다른 제약들에서
지운다. 그리고 살아 있는 조합의 수가 문턱 |thresh| 이하이면 전체 곱의 제약도
시험한다.

@<$a_l=x$일 때 만족할 수 없는 제약이 있으면 |b4|로 간다@>=
for stackptr, k = 0, m-1; k >= 0; k-- {
	@<$a_l=x$일 때 제약 |k|를 만족할 수 없으면 |b4|로 간다@>
}
for stackptr > 0 {
	stackptr--; mems++; k = stack[stackptr]
	if vbose > 2 {
		fmt.Fprintf(os.Stderr, " b%d는 %d여야 한다\n", off[k], choice[k][0])
	}
	@<|choice[k][0]|을 $c_k$와 다른 모든 제약에서 지운다@>
}
mems++; t = csize[l+1][0]
for k = 1; k < m && t <= thresh; k++ {
	mems++; t *= csize[l+1][k]
}
if t <= thresh {
	@<전체 곱의 제약 $c_m$을 시험한다@>
	for stackptr > 0 {
		stackptr--; mems++; k = stack[stackptr]
		if vbose > 2 {
			fmt.Fprintf(os.Stderr, " b%d는 %d일 수밖에 없다\n", off[k], choice[k][0])
		}
		@<|choice[k][0]|을 $c_k$와 다른 모든 제약에서 지운다@>
	}
}

@ @<전역 변수@>=
const thresh = 25

@ 이제 프로그램의 심장에 왔다. 제약을 시험하면서, 수준 |l+1|에 가게 되면 쓸
자료도 함께 적어 둔다.

크누스는 목록의 원소가 통하면 이름표 |jok|로 뛰어 |continue|했다. 여기서는 그
자리에서 바로 |continue|한다.

@<$a_l=x$일 때 제약 |k|를 만족할 수 없으면 |b4|로 간다@>=
mems++; imax = csize[l][k] // 앞 수준에서 통한 곱하는 수는 몇 개였나?
for i = 0; i < imax; i++ {
	mems++; j = choice[k][i]
	@<$a_l=x$여도 |j|가 여전히 괜찮으면 |continue|한다@>
	if vbose > 2 {
		fmt.Fprintf(os.Stderr, " c%d가 선택지 %d를 잃는다\n", k, j)
	}
	imax--
	if imax == 0 {
		goto b4 // 마지막 선택지를 잃었다
	}
	if i != imax { // |j|를 맨 뒤로 보낸다(되짚기 쉽게)
		mems += 6
		choice[k][i] = choice[k][imax]; where[k][choice[k][imax]] = i
		choice[k][imax] = j; where[k][j] = imax
		i-- // 옮겨 온 원소를 다시 본다
	}
}
mems++; csize[l+1][k] = imax
if imax == 1 {
	mems++
	if csize[l][k] != 1 {
		mems++; stack[stackptr] = k; stackptr++
	}
}

@ 제약 |k|는 아래 |l|자리에 대해 이미 확인했고, 그 자리들은 $a_l$에 좌우되지 않는다.
그러니 제약의 |l|번째 자리 하나만 보는 ``점진적'' 시험으로 넉넉하다.

제약 |constr[k]|의 길이가 |l| 이하이면 그 자리의 제약 값 |tt|는 0이다. 원본은
바로 이 조건을 잃었다. 맨 뒤의 버그 이야기를 보라.

@<$a_l=x$여도 |j|가 여전히 괜찮으면 |continue|한다@>=
mems++
if stamp[l][j] != nodes+uint64(x) { // |ja[l]|을 이미 고쳤나?
	mems++; stamp[l][j] = nodes + uint64(x)
	mems += 2
	if l == 0 {
		bcopy(&ja[0][j], &cnst[x*j])
	} else {
		add(&ja[l][j], &ja[l-1][j], &cnst[x*j], l)
	}
}
mems += 2; t = 0
if ja[l][j][0] > l {
	t = ja[l][j][l+1]
}
mems++; tt = 0
if constr[k][0] > l {
	mems++; tt = constr[k][l+1]
}
if (tt == 1 && t == d) || (tt != 1 && t != d) {
	continue
}

@ 제약 $c_k$가 곱하는 수 자릿수 하나로 좁혀지면, 그 자릿수를 $c_k$와 다른 모든
제약의 목록에서 지운다. 그러다 어떤 목록이 비면 |b4|로 가고, 어떤 목록이 하나로
좁혀지면 그 제약도 스택에 쌓는다.

@<|choice[k][0]|을 $c_k$와 다른 모든 제약에서 지운다@>=
mems++; j = choice[k][0]
for kk = 0; kk < m; kk++ {
	mems += 2
	if id[kk] != id[k] {
		mems += 2; i = csize[l+1][kk] - 1; ii = where[kk][j]
		if ii <= i {
			if i == 0 {
				goto b4
			}
			mems++; csize[l+1][kk] = i
			if i == 1 {
				mems++; stack[stackptr] = kk; stackptr++
			}
			if ii != i {
				mems += 6
				choice[kk][ii] = choice[kk][i]; where[kk][choice[kk][i]] = ii
				choice[kk][i] = j; where[kk][j] = i
			}
		}
	}
}

@ 크누스에 따르면, 시험하는 동안 이미 한 일 말고는 자료 구조를 고칠 것이 없는 듯하다.
예외가 하나 있다. 곱해지는 수 앞에 0을 붙였을 때는 지금의 해를 이미 찍었을 수 있다.
그렇지 않으면 아직 찍지 않았다.

원본의 |printed|는 초기화되지 않은 지역 변수라서, 첫 노드에서 쓰레기 값을 읽었다.
\GO/는 변수를 0으로 초기화하므로 그런 일이 없다. 결과에는 영향이 없고, mem 수가
하나 달라질 수 있을 뿐이다.

@<자료 구조를 갱신한다@>=
if x != 0 {
	printed = false
}

@ 되돌리기는 전혀 필요 없는 것 같다. 이는 주로 |choice|와 |csize| 장치 덕분이고,
나머지 자료는 수준마다 새로 계산하기 때문이다. 크누스는 이 절을 비워 두었다.

@<자료 구조를 되돌린다@>=
// 할 일이 없다

@ 해를 찍기 전에 모든 제약이 하나로 좁혀졌는지 보고, 저마다 완전히 만족되는지
확인한다. 이름표 |nope|는 이 절의 끝, 곧 |x=0| 바로 앞이다.

@<모든 제약이 완전히 만족되면 해를 찍는다@>=
if printed {
	goto nope // 이 녀석은 이미 찍었다
}
for k = 0; k < m; k++ {
	mems++
	if csize[l][k] > 1 {
		goto nope
	}
}
for k = m - 1; k >= 0; k-- {
	@<제약 $c_k$가 완전히 만족되지 않으면 |nope|로 간다@>
}
@<제약 $c_m$이 완전히 만족되지 않으면 |nope|로 간다@>
@<해를 찍는다@>
nope:

@ @<제약 $c_k$가 완전히 만족되지 않으면 |nope|로 간다@>=
mems += 3; j = choice[k][0]; lj = ja[l-1][j][0]; lc = constr[k][0]
if lc > lj {
	goto nope // |d=0|이어도 옳다
}
for i = 1; i <= lj; i++ {
	mems++; t = ja[l-1][j][i]; tt = 0
	if i <= lc {
		mems++; tt = constr[k][i]
	}
	if (t == d && tt == 0) || (t != d && tt != 0) {
		goto nope
	}
}

@ 전체 곱은 강제된 부분곱들을 어긋남만큼 밀어 더해서 얻는다.

@<제약 $c_m$이 완전히 만족되지 않으면 |nope|로 간다@>=
mems += 4; add(&total, &ja[l-1][choice[0][0]], &ja[l-1][choice[1][0]], off[1])
for k = 2; k < m; k++ {
	mems += 3; add(&total, &total, &ja[l-1][choice[k][0]], off[k])
}
mems++; lj = total[0]; lc = constr[m][0]
if lc > lj {
	goto nope // |d=0|이어도 옳다
}
for i = 1; i <= lj; i++ {
	mems++; t = total[i]; tt = 0
	if i <= lc {
		mems++; tt = constr[m][i]
	}
	if (t == d && tt == 0) || (t != d && tt != 0) {
		goto nope
	}
}

@ 해를 찾으면 먼저 곱해지는 수, 곱하는 수, 부분곱들, 최종 곱의 길이를 찍는다.
(나중에 이 줄들을 정렬하면 답이 하나뿐인 퍼즐을 가려낼 수 있다.) 그다음 곱해지는
수, 곱하는 수, |d|, 해 번호를 찍는다.

@<해를 찍는다@>=
count++
for i = l - 1; a[i] == 0; i-- { // 곱해지는 수 앞쪽의 0을 건너뛴다
}
fmt.Fprintf(out, "%d,%d;", i+1, off[m-1]+1)
for k = 0; k < m; k++ {
	fmt.Fprintf(out, "%d|%d,", ja[l-1][choice[k][0]][0], off[k])
}
fmt.Fprintf(out, "%d, ", total[0])
for ; i >= 0; i-- {
	fmt.Fprintf(out, "%d", a[i])
}
fmt.Fprintf(out, " x ")
for k, i = m-1, off[m-1]; k >= 0; k, i = k-1, i-1 {
	for i > off[k] {
		fmt.Fprintf(out, "0"); i--
	}
	fmt.Fprintf(out, "%d", choice[k][0])
}
fmt.Fprintf(out, ",d=%d (#%d)\n", d, count)
printed = true

@ 곱해지는 수를 가장 긴 길이까지 만들었는데도, 곱하는 수의 자릿수를 모두 강제할
만큼 걸림돌을 찾지 못했을 수 있다. 그런 경우에는 제약 $m$(곱 전체에 대한 제약)을
아마 아직 다 시험하지 못했을 것이다. 그러니 해를 놓치지 않았다고 확신하려면
곱하는 수의 모든 선택을 되짚어 보아야 한다.

병적인 패턴이면 이런 일이 생길 수 있지만, 크누스는 자기가 관심 있는 경우에는
일어나지 않으리라 보았다. 그래서 이 드문 경우를 보고만 해 둔다. 추가 조사가
필요하면 나중에 이어 가면 된다.

(끝자리 $a_{l-1}$이 0이 아니면, 정밀도 |maxdigs|를 넘지 않고는 시험할 수 없는 아주 긴 해가
있을 수도 있다.)

@<드문 해가 있는지 살피고 |b5|로 간다@>=
for k = 0; k < m; k++ {
	mems++
	if csize[l][k] > 1 {
		break
	}
}
if k < m {
	unresolved++
	mems++
	if a[l-1] == 0 || showUnresolved {
		fmt.Fprintf(os.Stderr, "풀리지 않은 경우: d=%d, 어긋남", d)
		for k = 0; k < m; k++ {
			fmt.Fprintf(os.Stderr, " %d", off[k])
		}
		fmt.Fprintf(os.Stderr, ":\n a=...")
		for k = l - 1; k >= 0; k-- {
			fmt.Fprintf(os.Stderr, "%d", a[k])
		}
		fmt.Fprintf(os.Stderr, ", 상태 ")
		for k = 0; k < m; k++ {
			fmt.Fprintf(os.Stderr, "%d", csize[l][k])
		}
		fmt.Fprintf(os.Stderr, "!\n")
	}
}
goto b5

@ @<전역 변수@>=
const showUnresolved = false

@* 안쪽 반복문.
``맨 아랫줄'' 제약 $c_m$을 시험할 때는 곱하는 수의 자릿수 여러 개를 저마다 바꾸어
보아야 할 수 있다. 과정은 좀 지루하지만 곧이곧대로다. 아직 걸러지지 않은 $m$짝을
모두 도는 반복문일 뿐이고, 그런 $m$짝은 모두 |thresh|개 이하라는 것을 안다.

제약 $c_k$를 받는 곱하는 수의 자릿수는 목록 |choice[k]|의 앞쪽
|csize[l+1][k]|개 가운데 하나다. 그래서 그 자릿수를 첨자 |g[k]|로 나타낸다. 곧
시험하는 자릿수는 |choice[k][g[k]]|다.

그런 $m$짝 $g_0g_1\ldots g_{m-1}$마다, 제약 $c_m$이 오른쪽 $l+1$자리에서 성립하는지
본다. 성립하면 $0\le k<m$에 대해 |shadow[k]|의 비트 $g_k$를 1로 둔다. 그러면
$g_k$가 적어도 한 해에서 통한다는 표시가 된다.

그런 $m$짝을 다 돈 뒤에 해가 하나도 없었으면 되짚어 간다. 해가 있었으면 그림자를 보고
|csize|를 줄일 수 있는지 안다.

크누스는 이 단계를 더 멋지게 할 수도 있다고 적었다. 아래 $l$자리까지 맞춘 뒤에는 ``점진적''
으로만 일하고, 자릿수를 점점 더 높은 정밀도로 다시 계산하지 않는 것이다. (그러려면
아래 $l$자리에서 올라온 자리올림의 합을 저장해 두었다가 $(l+1)$번째 자리를 점진적으로
시험할 때 써야 한다.)

또 $c_m$은 자릿수가 알려지는 대로 한 자리씩 시험할 수 있으므로, 이 과정에서도
되짚어 찾기로 $m$짝을 많이 건너뛸 수 있다.

그러나 크누스는 이 단계가 병목이 되지 않으리라 보고 단순한 쪽을 골랐다.

@<전체 곱의 제약 $c_m$을 시험한다@>=
for k = 0; k < m; k++ {
	mems++; shadow[k] = 0
}
@<모든 $m$짝 $g_0\ldots g_{m-1}$을 돈다@>
mems++
if shadow[0] == 0 {
	goto b4 // 해가 없었다
}
for k = 0; k < m; k++ {
	mems += 2
	if shadow[k]+1 != 1<<csize[l+1][k] {
		@<목록 |choice[k]|에서 항목을 지운다@>
	}
}

@ 안쪽 반복문도 알고리즘 7.2.2B의 모양이다. 여기서도 아무도 뛰지 않는
이름표 |bb1|은 뺐다.

@<모든 $m$짝 $g_0\ldots g_{m-1}$을 돈다@>=
k = 0
bb2:
	if k == m {
		@<$c_m$을 지키는지 시험하고 |bb5|로 간다@>
	}
	g[k] = 0
bb3:
	@<|acc[k]|에 $k$번째 부분합의 아래 자릿수들을 담는다@>
	k++
	goto bb2
bb4:
	mems += 2; g[k]++
	mems++
	if g[k] < csize[l+1][k] {
		goto bb3
	}
bb5:
	k--
	if k >= 0 {
		goto bb4
	}

@ 부분합 |acc[k]|는 |acc[k-1]|에 $k$번째 부분곱을 |off[k]|만큼 밀어 더한 것이다.
아래 |l+1|자리만 계산하고, 그 위로 올라가는 자리올림은 버린다.

@<|acc[k]|에 $k$번째 부분합의 아래 자릿수들을 담는다@>=
mems += 3; j = choice[k][g[k]]; lj = ja[l][j][0]
for i = 0; ; i++ {
	mems++
	if i >= off[k] {
		break
	}
	mems += 2; acc[k][i] = acc[k-1][i]
}
for ii, kk = 1, 0; i <= l; i, ii = i+1, ii+1 {
	t = kk
	if k > 0 {
		mems++; t += acc[k-1][i]
	}
	if ii <= lj {
		mems++; t += ja[l][j][ii]
	}
	if t >= 10 {
		mems++; acc[k][i] = t - 10; kk = 1
	} else {
		mems++; acc[k][i] = t; kk = 0
	}
}

@ 이 절을 마칠 때 |k|는 언제나 |m|이다. 그래서 |bb5|에서 |k|를 하나 줄이면
마지막 자릿수로 돌아간다.

@<$c_m$을 지키는지 시험하고 |bb5|로 간다@>=
mems++; lc = constr[m][0]
for i = 0; i <= l; i++ {
	mems++; t = acc[m-1][i]
	if i < lc {
		mems++; tt = constr[m][i+1]
	} else {
		tt = 0
	}
	if (t == d && tt == 0) || (t != d && tt != 0) {
		goto noncomp
	}
}
if vbose > 2 {
	fmt.Fprintf(os.Stderr, " 통과 ")
	for k = m - 1; k >= 0; k-- {
		fmt.Fprintf(os.Stderr, "%d", choice[k][g[k]])
	}
	fmt.Fprintf(os.Stderr, "\n")
}
for k = 0; k < m; k++ {
	mems += 2; shadow[k] |= 1 << g[k]
}
noncomp:
goto bb5

@ 그림자에 비트가 서지 않은 자릿수는 어느 해에도 쓰이지 않으니 목록에서 지운다.
목록의 뒤쪽부터 훑으므로, 앞으로 옮겨 오는 원소는 이미 살아남기로 한 것이다.

@<목록 |choice[k]|에서 항목을 지운다@>=
mems++; imax = csize[l+1][k]
for i = imax - 1; i >= 0; i-- {
	mems++
	if shadow[k]&(1<<i) == 0 {
		mems++; j = choice[k][i]
		if vbose > 2 {
			fmt.Fprintf(os.Stderr, " b%d는 %d가 아니다\n", k, j)
		}
		imax--
		if i != imax {
			mems += 6
			choice[k][i] = choice[k][imax]; where[k][choice[k][imax]] = i
			choice[k][imax] = j; where[k][j] = imax
		}
	}
}
mems++; csize[l+1][k] = imax
if imax == 1 {
	mems++; stack[stackptr] = k; stackptr++
}

@ @<전역 변수@>=
var (
	acc    [maxm][maxdigs]int // 부분합
	g      [maxm]int          // 안쪽 반복문의 첨자
	shadow [maxm]int          // 해가 나온 비트들
)

@* 쉼표 하나가 삼킨 조건.
원본에서 점진적 시험의 한 줄은 이렇다.
$$\hbox{\tt o,tt=(constr[k][0]<=l? 0: o,constr[k][l+1]);}$$
뜻은 분명하다. 제약의 길이가 |l| 이하이면 |tt=0|, 아니면 |constr[k][l+1]|이다.
그런데 매크로 |o|는 |mems++|로 풀리고, C에서 쉼표 연산자는 조건 연산자보다 우선순위가
낮다. 그러니 괄호 안은
$$\hbox{\tt (constr[k][0]<=l? 0: mems++), constr[k][l+1]}$$
으로 묶이고, 그 값은 조건과 상관없이 언제나 |constr[k][l+1]|이다. 조건이 통째로
사라진 것이다. (가운데 피연산자에서는 쉼표가 문제없다. 원본의 다른 곳들은 모두
그렇게 썼다. 쉼표를 세 번째 피연산자에 둔 것은 이 한 곳뿐이다.)

사라진 조건이 지키던 칸은 제약의 길이 너머다. 원본은 그 칸들을 지우지 않으므로,
거기에는 앞선 어긋남의 제약이 남긴 1이 있을 수 있다. 그러면 ``이 자리는 $d$가 아니어야
한다''가 ``이 자리는 $d$여야 한다''로 뒤바뀌어, 옳은 곱하는 수 자릿수가 버려진다.

들어가며 절의 \.O 퍼즐이 바로 그렇게 된다. 어긋남 (0, 1, 3, 4, 5)에서 제약 $c_3$은
10010이라 길이가 5다. 그런데 바로 앞에 본 어긋남 (0, 1, 2, 3, 5)의 $c_3$은
100100이었고, 그 여섯 번째 칸의 1이 그대로 남아 있다. Take의 답
$2208068\times357029$을 따라 $a=08068$까지 내려가면, 수준 5에서 $5\times a$의 5번째
자리가 4여야 한다는 거짓 요구가 생긴다. 그 자리는 0이나 5일 수밖에 없으니, 제약
$c_3$은 마지막 선택지 5를 잃고 가지가 잘린다. 괄호 한 쌍이면 고쳐진다.
$$\hbox{\tt o,tt=(constr[k][0]<=l? 0: (o,constr[k][l+1]));}$$

\.O 패턴에 $m=5$, $z=1$을 주었을 때, 원본과 고친 판이 찾는 해는 이렇다.
$$\vbox{\halign{#\hfil&&\quad\hfil#\cr
&$d=1$&$d=2$&$d=3$&$d=4$&$d=8$&모두\cr
\noalign{\smallskip\hrule\smallskip}
원본&4707&0&0&0&0&4707\cr
고친 판&9490&5060&8284&22946&22371&68151\cr}}$$
원본이 찾는 4707개는 고친 판에도 모두 있다. 거짓 요구는 가지를 자르기만 하고, 해를
찍기 전의 완전한 검사는 제약을 옳게 읽기 때문이다. 그러니 원본은 해를 {\it 놓치기만\/}
한다. 원본은 Take의 퍼즐을 찾지 못하고, 고친 판은 그것을 47183번째 해로 찾는다.

@ 버그가 하나 더 있는데, 이것은 이 기계에서는 겉으로 드러나지 않았다. 원본은
|pos|를 고를 때 패턴의 행 $i$를 $0\le i\le m$에서 돌렸다. 패턴은 $n$행뿐이고
$m\ge n-1$이므로, $i\ge n$이면 |last[i]=0|이고 |off[m+1-n+i]|는 쓰지 않는 칸이다.
대개는 0이라 해가 없지만, $2m+1-n\ge|maxm|=8$이면 배열 |off| 밖을 읽는다. 이를테면
\.O 패턴($n=5$)에 $m=6$을 주면 |off[8]|을 읽는다. 경계 검사를 켜고 컴파일하면
실제로 걸린다. 밖에서 읽은 바이트가 |pos|보다 크면 패턴이 엉뚱한 자리로 밀린다.
내 기계에서는 해가 달라지지 않았고 mem 수만 달라졌다. 이 판은 $i<n$만 돈다.

사소한 것 셋을 덧붙인다. 원본은 앞서 말했듯 초기화되지 않은 |printed|를 읽는다.
본문의 |slack| 설명에는 Take의 이름이 ``Junja''로 적혀 있다. 그리고 되짚어 찾기
장의 예에서 $a_2$의 후보는 0, 2, 6이 아니라 0, 2, 5, 6이다.

@* 맞춰 보기.
이 판이 옳은지는 세 가지로 확인했다.

첫째, 원본에 위의 세 가지(괄호 한 쌍, $i<n$, |printed=0|)만 고친 C 프로그램과
견주었다. 표준 출력은 바이트 하나까지 같고, 노드 수와 mem 수도 같다.

둘째, 크누스의 장치(|choice|, |csize|, 그림자)를 하나도 쓰지 않는 독립 검사기를
따로 짰다. 곱하는 수를 모두 고정해 두고, 곱해지는 수를 오른쪽부터 한 자리씩 늘리며
부분곱과 총합의 그 자리를 곧이곧대로 따진다. 곱해지는 수의 길이는 이 프로그램과
같이 $|maxdigs|-3-s_{m-1}$자리까지 본다.

셋째, 곱해지는 수가 $10^7$보다 작은 해는 가장 무딘 방법으로도 찾았다. 곱해지는
수와 곱하는 수를 모두 늘어놓고 퍼즐의 조건을 직접 따지는 것이다. \.O 패턴에 $m=5$,
$z=1$이면 그런 해는 Take의 것 하나뿐이다. 원본은 그 하나를 찾지 못한다.

@ 대조에는 다섯 줄짜리 글자 열 개(\.C, \.H, \.I, \.L, \.O, \.T, \.U, \.V, \.X,
\.Z)에 $m=4,5,6$과 $z=0,1,2$를 곱한 90가지 경우를 썼다. 그 가운데 원본이 2분 안에
끝낸 47가지를 끝까지 견주었다. 몇 줄만 옮긴다.
$$\vbox{\halign{#\hfil\quad&&\hfil#\quad\cr
패턴&$m$&$z$&원본&이 판&검사기&풀리지 않음\cr
\noalign{\smallskip\hrule\smallskip}
\.O&5&1&4707&68151&68151&0\cr
\.O&5&2&8154&105936&105936&0\cr
\.H&5&2&0&1799&1799&0\cr
\.U&5&1&0&4638&4638&0\cr
\.X&4&2&804274&1983830&1983830&0\cr
\.V&4&2&1719904&2073379&2073379&0\cr
\.O&6&0&6538&6538&6538&0\cr
\.H&6&2&0&202&209&151\cr}}$$
결과는 이렇다.

\smallskip
\item{$\bullet$} 47가지 모두에서 이 판의 출력은 고친 C와 바이트 하나까지 같고, 노드
수와 mem 수도 같다.
\item{$\bullet$} 풀리지 않은 경우가 없는 34가지에서는 이 판의 해 목록이 검사기의
목록과 꼭 같다.
\item{$\bullet$} 풀리지 않은 경우가 있는 13가지에서는 이 판의 해가 모두 검사기의 해
가운데 있고, 검사기가 조금 더 찾는다. 이를테면 \.H 패턴에 $m=6$, $z=2$이면 빠진
7개가 모두 ``풀리지 않은 경우''로 보고된 곱해지는 수(116668917409 따위)의 것이다.
곱하는 수의 한 자리가 1이어도 4여도 패턴에 맞으니 |csize|가 끝내 1로 줄지 않은
것이다. 크누스가 밝혀 둔 한계 그대로이고, 그런 퍼즐은 어차피 답이 하나가 아니다.
\item{$\bullet$} 원본은 가짜 해를 한 번도 내지 않았다. 그러나 해가 있는 27가지
가운데 22가지에서 해를 덜 찾았고, 그 가운데 5가지에서는 하나도 찾지 못했다.
\smallskip

\noindent 나머지 43가지는 원본이 2분 안에 끝나지 않아 견주지 않았다.

@* 색인.
