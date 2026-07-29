\input kotexgweb
\input pic

\def\title{완전 자릿수 불변수}

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

@* 들어가며.
이 글은 Knuth의 \.{CWEB} 프로그램 \pdfURL{\.{back-pdi.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/back-pdi.w}를
\.{GWEB}으로 옮긴 것이다.
백트래킹의 좋은 예제인 데다, 자리올림만 있으면 되는 다중정밀 산술을 비트 기교로
푸는 대목(\.{TAOCP}의 연습문제 7.1.3--100)이 곁들여 있어 옮길 맛이 났다. 원문의
논평을 충실히 따르되, 어투는 내 식으로 풀어 썼다.

$153$은 제 자릿수를 저마다 세제곱해 더하면 도로 제자신이 되는 놀라운 수이다.
$153=1^3+5^3+3^3.$ 이런 수를 {\it 완전 자릿수 불변수\/}(perfect digital
invariant, PDI)라 부른다. 차수 $m$의 PDI란, 십진 표기의 각 자릿수를 $m$제곱해
모두 더하는 연산 $\pi_m$에 대해 $\pi_m x=x$를 만족하는 정수 $x$다.
이 프로그램은 주어진 $m$에 대해 그런 $x$를 {\it 남김없이\/}
찾는다. (자릿수의 개수가 마침 $m$과 같은 특별한 경우---$153$처럼---만 따로
{\it 암스트롱 수\/}라 부르기도 하지만, 여기서 찾는 것은 지수 $m$을 고정한 더 넓은
가족이다.)

먼저 그런 $x$의 자릿수가 기껏해야 $m+1$개임을 어렵지 않게 보일 수 있다.
$10^p\le x<10^{p+1}$이면 $x$는 $p+1$자리인데, $p>m$일 때는
$\pi_m x\le(p+1)9^m<10^{p+1}\hbox{이 아니라}\quad\pi_m x<10^p\le x$
가 되어 $\pi_m x=x$가 될 수 없다. 사실의 핵심은 $(m+1)9^m<10^{m+1}$이라는 부등식
하나다. 그러니 자릿수는 $m+1$개면 넉넉하고, 우리는 그 $m+1$개의 자릿수를
$9\ge x_1\ge x_2\ge\cdots\ge x_{m+1}\ge0$
처럼 {\it 내림차순\/}으로 하나씩 고르며 백트래킹한다. $\pi_m$은 자릿수의 순서에
무관하니, 순서를 정해 두면 같은 다중집합을 한 번씩만 훑게 된다. $m$이 작다면
그런 자릿수 열이 ${m+10\choose9}$가지뿐이라 통째로 훑을 수도 있다---$m=40$이면
약 25억 가지다. 하지만 아래에서 세울 상$\cdot$하계는 그보다 훨씬 매섭게 가지를
쳐 낸다.

@c
package main

import (
	"fmt"
	"os"
	"strconv"
)

const (
	maxm    = 1000
	maxdigs = 1 + maxm/15 // 다중정밀 수 하나가 차지하는 8바이트 워드 수
)

@<전역 변수@>
@<보조 루틴@>

func main() {
	var (
		j, k, l, p, r, t, pd, alt, blt, xl int
		change bool
	)
	@<커맨드라인을 처리한다@>
	@<거듭제곱 표를 미리 계산한다@>
	@<모든 경우를 백트래킹한다@>
	fmt.Fprintf(os.Stderr, "m=%d에 대해 해가 모두 %d개 (노드 %d개, mem %d개).\n",
		m, count, nodes, mems)
	if vbose > 0 { @<프로파일을 출력한다@> }
}

@ 전역 변수는 대부분 레벨을 첨자로 갖는 큰 배열이다. |goto|가 선언을 건너뛰지
못하는 Go의 제약 때문에, 탐색이 쓰는 작업 배열은 패키지 전역으로 둔다. 레벨 |l|은
$1$부터 $m+2$까지 갈 수 있으므로 배열은 |maxm+3|칸으로 넉넉히 잡았다.

원문은 곳곳에 계산기 이용 횟수(mem)를 헤아리는 계수기를 심어 두었다.Knuth가 알고리즘의
실제 비용을 재는 방식인데, 최적화 컴파일러가 서브루틴을 인라인하고 분포 배열을 한 8바이트
워드에 팩킹했다고 {\it 가정하고\/} 메모리 참조를 센다. (실제로는 디버깅이 편하도록
원소들을 풀어서 들고 다닌다.) 그 계수를 원문 그대로 옮겨, 끝에 노드 수와 함께 찍는다.
깊이별로 방문한 노드 수를 세는 |profile|도 그대로다. 두 값 모두 원문과 한 치도 어긋나지
않으니, 옮김이 옳았는지 검산하는 잣대로 삼기에 좋다.

@<전역 변수@>=
var (
	m       int   // 명령줄에서 받는 거듭제곱 차수
	mdigs   int   // 다중정밀 산술이 실제로 쓰는 워드 수
	vbose   int   // 얼마나 수다스럽게 굴 것인가
	count   int   // 지금까지 찾은 해의 수
	nodes   int64 // 방문한 탐색 노드 수
	mems    int64 // 헤아린 계산기 이용 횟수(mem)
	thresh  int64 = 10_000_000_000 // 다음 중간 보고 시점
	profile [maxm + 3]int64
)

@ 원문의 |argc<2|${} \lor {}$|sscanf(...)!=1|처럼, 인자가 없는 경우와 숫자로 못 읽는 경우를
한 조건으로 묶어 사용법 안내를 한 번만 둔다.
@<커맨드라인을 처리한다@>=
var perr error
if len(os.Args) >= 2 {
	m, perr = strconv.Atoi(os.Args[1])
}
if len(os.Args) < 2 || perr != nil {
	fmt.Fprintf(os.Stderr, "사용법: %s m [프로파일] [자세히] [더자세히]\n", os.Args[0])
	os.Exit(1)
}
vbose = len(os.Args) - 2
if m < 2 || m > maxm {
	fmt.Fprintf(os.Stderr, "m은 2와 %d 사이여야 합니다 (%d은 안 됩니다)!\n", maxm, m)
	os.Exit(2)
}
mdigs = 1 + m/15

@* 까다로운 산술.
꽤 큰 수를 다루면서 그 십진 자릿수를 들여다봐야 한다. 그런데 컴퓨터는 이진법이고,
$10$의 거듭제곱으로 나누기를 되풀이하고 싶지는 않다. 그래서 나는 수를
{\it 십육진법으로 코딩한 십진수\/}로 들고 다닌다: 8바이트 워드 하나에 십진 자릿수
$15$개를 니블(nybble, 4비트) 하나에 하나씩 담되, 각 니블은 $0$부터 $9$까지의 값만
갖는다. 덧셈만 이 형식 위에서 직접 할 줄 알면 된다. 이를테면 |0x344159959|와
|0x271828043|을 더해 마치 십진수를 더한 것처럼 |0x615988002|를 얻는 식이다.

@<보조 루틴@>=
func add(p, q, r []uint64) { // |p|와 |q|를 더해 |r|에
	var c uint64
	for k := 0; k < mdigs; k++ {
		@<|c+p[k]|를 |q[k]|에 더해 |r[k]|와 자리올림 |c|를 얻는다@>@;
	}
	if c != 0 { // 일어나서는 안 되는 일이다
		fmt.Fprintf(os.Stderr, "넘침!\n")
		os.Exit(999)
	}
}

@ 자리올림 |c|를 |y|가 아니라 |x|에 더해야 한다는 점이 재미있다. 안 그러면
결과에 십진법 아닌 니블 \.{a}$\ldots$\.{f}가 튀어나올 수 있다.

바탕은 잘 알려진 이진 십진 덧셈 기교다. 각 니블에 $6$을 미리 얹어 두면, 니블 합이
$10$ 이상일 때 이진 자리올림이 위 니블로 자연스럽게 넘어간다. 그러고 나서 자리올림이
일어나지 {\it 않은\/} 니블에서만 도로 $6$을 빼면 십진 덧셈이 완성된다.
@<|c+p[k]|를 |q[k]|에 더해 |r[k]|와 자리올림 |c|를 얻는다@>=
mems++; x := p[k] + c                             // |x|는 이제 비십진 니블을 가질 수 있다
mems++; y := q[k] + 0x666666666666666             // 니블 사이 자리올림은 아직 없다
tt := x + y
w := (tt ^ x ^ y) & 0x1111111111111110    // 니블 사이 자리올림이 여기서 드러난다
w = (w ^ 0x1111111111111110) >> 3
tt -= w + (w << 1)                        // 자리올림 없던 곳에서 $6$을 뺀다
mems++; r[k] = tt & 0xfffffffffffffff
c = tt >> 60

@ 비결은 두 걸음이다. 먼저 한쪽 덧수의 모든 니블에 $6$을 얹는다(코드의
|q[k]+0x66..6|). 그러면 니블 합이 $10$ 이상인 칸에서는 얹은 $6$이 넘침을 $16$
너머로 밀어, 이진 자리올림이 위 니블로 저절로 넘어간다. 다음으로, 자리올림이
나지 {\it 않은\/} 칸에서만 도로 $6$을 뺀다(코드의 |tt -= w+(w<<1)|). 마스크 |w|는
자리올림이 없던 자리마다 값 $2$를 세워 두므로, 거기에 $w+2w=3w$를 빼는 것이 곧
$6$을 빼는 일이 된다. 자리올림 |c|를 |y|가 아니라 |x|에 얹는 까닭도 여기 있다:
$6$을 얹은 |y| 쪽에 더 얹으면 십진법 아닌 니블 \.{a}$\ldots$\.{f}가 튀어나올 수
있기 때문이다.

@ 백문이 불여일견이니, 앞서 든 $344159959+271828043$을 이 형식으로 더해 보자.
\medskip
\centerline{\pic{back-pdi-1.pdf}}
\figcap{{\sl 그림} 1: 두 덧수의 니블 합이 $10$ 이상인 칸(음영)에서 이진 자리올림이
위 니블로 넘어간다. 얹었던 $6$을 자리올림이 없던 칸에서만 도로 빼면, 십진 덧셈이
십육진 니블 위에서 그대로 완성된다.}

오른쪽 끝부터 따라가 보면 기교가 손에 잡힌다. 첫 칸은 $9+3=12$라 십진 자리올림이
나고 결과 자리는 $2$다. 다음 세 칸도 $5{+}4{+}1$, $9{+}0{+}1$, $9{+}8{+}1$로 줄줄이
$10$을 넘겨 $0,0,8$을 남기며 올림을 위로 밀어 올린다. 그 위 네 칸은 올림 없이
$8,9,5$가 그대로 앉고, 왼쪽에서 둘째 칸 $4+7=11$에서 마지막 올림이 나 맨 앞이
$6$이 된다. 음영 친 다섯 칸이 바로 올림이 난 자리다.

@ 프로그램 초입에 $0^m,1^m,2^m,\ldots,9^m$의 표가 필요하다. 그러니 덧셈만으로 이걸
왜 못 만들겠는가? |kmult|는 큰 수 |a|를 한 자릿수 |k|배로 곱한다---모두 덧셈으로.
@<보조 루틴@>=
func kmult(k int, a []uint64) { // |a|를 $k$배로
	switch k {
	case 8:
		add(a, a, a)
		fallthrough
	case 4:
		add(a, a, a)
		fallthrough
	case 2:
		add(a, a, a)
	case 6:
		add(a, a, a)
		fallthrough
	case 3:
		add(a, a, z[:]); add(a, z[:], a)
	case 5:
		add(a, a, z[:]); add(z[:], z[:], z[:]); add(a, z[:], a)
	case 9:
		add(a, a, z[:]); add(z[:], z[:], z[:]); add(z[:], z[:], z[:]); add(a, z[:], a)
	case 7:
		add(a, a, z[:]); add(a, z[:], z[:]); add(z[:], z[:], z[:]); add(a, z[:], a)
	case 0, 1:
	}
}

@ 이제 표를 채운다. |table[1][k]|를 $k$에서 시작해 |k|배씩 $m-1$번 곱하면 $k^m$이
되고, 거기에 $k^m$을 거듭 더하면 $j\cdot k^m$들이 줄줄이 나온다.
@<거듭제곱 표를 미리 계산한다@>=
for k = 1; k < 10; k++ {
	table[1][k][0] = uint64(k)
	for j = 2; j <= m; j++ {
		kmult(k, table[1][k][:]) // $k^m$을 만든다
	}
	for j = 2; j <= m+1; j++ {
		add(table[1][k][:], table[j-1][k][:], table[j][k][:]) // $j\cdot k^m$
	}
}

@ @<전역 변수@>=
var (
	table [maxm + 2][10][maxdigs]uint64 // 미리 계산한 $j\cdot k^m$의 표
	z     [maxdigs]uint64               // 큰 수를 담는 임시 버퍼
)

@ 다중정밀 수 |num|의 자리 |p|(니블 하나)를 꺼내는 짧은 도우미다.
@<보조 루틴@>=
func nybb(num []uint64, p int) int {
	return int((num[p/15] >> (4 * (p % 15))) & 0xf)
}

@ 디버깅할 때나 수다스럽게 돌 때, 다중정밀 수의 모든 자리를 보고 싶다. 자리 |t|
바로 앞에는 세로줄을 하나 그어 접두의 경계를 표시한다.
@<보조 루틴@>=
func printnum(num []uint64, t int) {
	for k := m; k >= 0; k-- {
		if t == k {
			fmt.Fprint(os.Stderr, "|")
		}
		fmt.Fprintf(os.Stderr, "%d", nybb(num, k))
	}
}

@ 이것으로 산술은 채비가 됐다. 몇 가지 셈속을 정리해 두자. 8바이트 워드 하나에
십진 자리를 왜 $16$개가 아니라 $15$개만 담는가? 니블 $16$개를 꽉 채우면 덧셈의
자리올림이 워드 밖으로 빠져나갈 자리가 없기 때문이다. 맨 위 니블 하나를 비워 두면
그 자리가 자리올림의 임시 거처가 되어, |add|는 워드마다 |c=tt>>60|으로 넘겨받은
올림을 다음 워드로 실어 나른다. 그래서 $m+1$자리 수 하나에 |maxdigs|$=1+m/15$개의
워드가 든다.

|add|가 다루는 수는 |mdigs| 워드, 곧 십진 $15\cdot|mdigs|$자리까지다. 우리가
쓰는 가장 큰 수는 경계 $b_l$인데 그 값이 $10^{m+1}$을 넘지 않으니, |mdigs|$=1+m/15$
워드면 넉넉하다. 곱셈도 나눗셈도 없이 오로지 덧셈과 비트 연산만으로 이 모든
다중정밀 셈이 돌아간다는 것이---나로서는---이 프로그램에서 가장 마음에 드는
대목이다.

한 걸음 더 나아가면, 이 프로그램이 다중정밀로 하는 연산은 사실상 덧셈 {\it 하나뿐\/}
이다. 두 큰 수의 크기 비교조차 따로 두지 않았다. 뒤에서 경계 $a_l$과 $b_l$을 견줄
때는, 둘이 나눠 갖는 공통 접두 바로 아래 자리 하나---|alt|와 |blt|---만 |nybb|로
꺼내 비교하면 그만이기 때문이다. 뺄셈이 아쉬워 보이는 자리에서도, ``얼마나
모자란가''는 미리 더해 둔 합 |sig|와 거듭제곱 표 |table|의 값으로 갈음한다. 그러니
이 장에 담긴 것은 |add| 하나와, 그것으로 지은 |kmult|와 |table|, 그리고 자리를
들여다보는 |nybb|가 전부다. 남은 프로그램은 오로지 이 셋 위에서만 논다.

끝으로 사소하지만 요긴한 성질 하나. |add|는 |p|, |q|, |r|가 모두 같은 배열이어도
옳게 돈다. 각 워드에서 읽기를 쓰기보다 먼저 마치기 때문이다. |kmult|가
|add(a,a,a)|처럼 제자리 덧셈을 태연히 부를 수 있는 것이 이 덕이다.

@* 알고리즘.
이 프로그램은 전형적인 백트래킹 프로그램의 뼈대에 몇 가지 비틀기를 더한 구조다.
그 비틀기 하나가 상태 변수 |pd|인데, 레벨 |l-1|에서 둔 수가 {\it 강제된\/} 것이었을
때 $0$이 아니다. (그런 경우는 드물지만 중요하다.)
@<모든 경우를 백트래킹한다@>=
@<자료 구조를 초기화한다@>@;
b2:
	profile[l]++; nodes++
	@<mem이 문턱을 넘었으면 중간 상태를 보고한다@>@;
	@<부모의 분포를 물려받고 |xl|을 더한다@>@;
	mems+=2; mems+=2 // 팩킹했다면 |pdist|와 |dist|를 옮기는 데 드는 두 mem씩
	if pd != 0 {
		@<강제된 수를 흡수한다@>@;
	} else {
		if r == 0 {
			goto b5 // 새 자릿수 |xl|을 받아들일 자리가 없다
		}
		r--
		add(sig[l-1][:], table[1][xl][:], sig[l][:])
	}
	if l > m+1 {
		@<해를 출력하고 |b5|로 간다@>@;
	}

@ |b3|은 경계를 따져 이 가지를 접을지 판단하고, 접지 않으면 |move|가 다음
레벨로 나아간다.
@<모든 경우를 백트래킹한다@>=
b3:
	if vbose > 1 {
		fmt.Fprintf(os.Stderr, "레벨 %d, %d 시도 (mem %d)\n", l, xl, mems)
	}
	@<|xl| 이하가 불가능함이 쉽게 드러나면 |b5|로 간다@>@;
move:
	@<다음 레벨로 나아간다@>@;

@ 한 레벨에서 더 시도할 자릿수가 남았으면 |b4|가 |xl|을 하나 낮춰 다시 시도하고,
다 떨어졌으면 |b5|가 한 레벨 물러나며 상태를 되돌린다. |l|이 $0$까지 줄면 탐색이
끝난다.
@<모든 경우를 백트래킹한다@>=
b4:
	if xl != 0 {
		xl--
		mems++; pd = pdist[l][xl] // |dist[l][xl]|은 $0$이었다
		goto b3
	}
b5:
	l--
	if l != 0 {
		mems++; pd = pdsave[l]
		if pd != 0 {
			goto b5
		}
		@<레벨 |l|의 이전 상태를 복원한다@>@;
		goto b4
	}

@ 계산이 오래 걸릴 때를 위해, mem이 $10^{10}$을 넘을 때마다 지금까지의 프로파일을
한 줄 찍어 진척을 알린다.
@<mem이 문턱을 넘었으면 중간 상태를 보고한다@>=
if mems >= thresh {
	thresh += 10000000000
	fmt.Fprintf(os.Stderr, "%d mem 지난 뒤:", mems)
	for k = 2; k <= l; k++ {
		fmt.Fprintf(os.Stderr, " %d", profile[k])
	}
	fmt.Fprintf(os.Stderr, "\n")
}

@ 레벨 |l|이 하는 일은, $x_1,\ldots,x_{l-1}$이 이미 정해졌다고 보고 해 $x$의 $l$번째로
큰 자릿수 $x_l$을 정하는 것이다.

핵심 발상은 경계 $a_l$과 $b_l$을 계산해 두는 데 있다. $x_1,\ldots,x_{l-1}$이 주어진
값을 갖고 $x_l$이 어떤 문턱값 |xl| 이하라면 반드시 $a_l\le x\le b_l$이 성립한다.
이 경계들도 다른 모든 다중정밀 수처럼 $m+1$자리 수 $a_{lm}\ldots a_{l0}$과
$b_{lm}\ldots b_{l0}$이다. 둘은 길이 $m+1-t$의 공통 접두 $p_m\ldots p_{t+1}$을
나눠 갖는다. 즉 $a_l<b_l$이면 $0\le t\le m$이고 $a_{lt}<b_{lt}$다.

@ 요점은 이렇다. 다중집합 $P=\{p_m,\ldots,p_{t+1}\}$의 자릿수 하나하나가 $x$에
반드시 나타나고, 다중집합 $D=\{d_1,\ldots,d_{t-1}\}$(이미 고른 자릿수들)의 하나하나도
그렇다. 따라서 $S=P\cup D$의 자릿수는 어느 해 $x$에나 들어 있어야 한다. (자릿수
$d$가 다중집합 $A$에 $a$번, $B$에 $b$번 나타나면 $A\cup B$에는 $\max(a,b)$번
나타남을 기억하자.)

자릿수 |d|는 $D$에 |dist[l][d]|번, $P$에 |pdist[l][d]|번 나타난다. |d>xl|이면
|pdist[l][d]<=dist[l][d]|여야 한다. |d=xl|이면 $|pd|=\max(0,|pdist[l][d]|-|dist[l][d]|)$로
둔다. 이를테면 |xl|이 $D$에는 세 번, $P$에는 한 번 나타나면 $pd=0$이지만, $P$에 세
번, $D$에 한 번이면 $pd=2$가 되어 $x_l=x_{l+1}=|xl|$을 {\it 강제로\/} 골라야 한다.

@ |r|을 |x|의 아직 모르는 자릿수 개수라 하자. (|pd=0|일 때 이는 $m+1$에서
$\vert S\vert$를 뺀 값이다.) $a_{lt}<b_{lt}<|xl|$이면 $r>0$이고, 모르는 자릿수 하나가
$a_{lt}$와 $b_{lt}$ 사이(양끝 포함)에 놓인다.

|xl|이 줄면 경계가 조여지고, 그러면 접두가 더 길어질 수 있다. 그것이 바로 우리가
바라는 바다. 계산을 편히 하려고 알려진 자릿수들의 거듭제곱 합
$$|sig[l]|=\sum_{k=0}^{|xl|-1}|pdist[l][k]|\cdot k^m
          +\sum_{k=|xl|}^9|dist[l][k]|\cdot k^m+|pd|\cdot|xl|^m$$
을 늘 최신으로 유지한다.

@ 레벨을 첨자로 갖는 나머지 작업 배열들이다. 여기서 원문과 딱 하나 다르게 했다.
원문은 이 배열들을 |maxm+1|칸으로 잡는데, 앞서 보았듯 |l|은 해를 찍는 순간
$m+2$까지 오른다. 그래서 $m$이 |maxm|이면 |sig[m+2]|를 비롯한 접근이 배열을 두 칸
넘어선다. 원문이 |profile|만은 |maxm+3|으로 잡아 둔 것을 보면, |l|이 $m+2$까지
감을 알면서도 나란한 이 배열들의 크기는 미처 맞추지 못한 듯하다. (작은 |maxm|으로
$m=|maxm|$을 돌려 보면 엉뚱한 해가 쏟아진다.) 여기서는 모두 |maxm+3|으로 통일해
그 경계 넘침을 없앴다.
@<전역 변수@>=
var(
	dist   [maxm + 3][16]int
	pdist  [maxm + 3][16]int
	a      [maxm + 3][maxdigs]uint64
	b      [maxm + 3][maxdigs]uint64
	sig    [maxm + 3][maxdigs]uint64
	x      [maxm + 3]int
	rsave  [maxm + 3]int
	tsave  [maxm + 3]int
	pdsave [maxm + 3]int
)

@ 뿌리 레벨에서는 |b2|를 정말 하고 싶지 않아서, 초기화가 끝나면 곧장 |b3|으로 뛴다.
@<자료 구조를 초기화한다@>=
l = 1
pd = 0
pdsave[1] = 0
alt = 0
blt = 9
t = m
r = m + 1
xl = 9
profile[1] = 1
goto b3

@ |b2|에 들어오면 부모 레벨의 분포를 물려받고, 이번에 시도하는 자릿수 |xl| 하나를
$D$에 더한다.
@<부모의 분포를 물려받고 |xl|을 더한다@>=
for k = 0; k < 10; k++ {
	pdist[l][k] = pdist[l-1][k]
	if k == xl {
		dist[l][k] = dist[l-1][k] + 1
	} else {
		dist[l][k] = dist[l-1][k]
	}
}

@ @<다음 레벨로 나아간다@>=
mems+=2; tsave[l] = t; rsave[l] = r
mems++; pdsave[l] = pd
mems++; x[l] = xl
l++
goto b2

@ 해를 찾으면 고른 순서 $x_1\ldots x_{m+1}$과, 그 자릿수들이 실제로 이루는 수
|sig[l]|($=\pi_m x=x$)을 나란히 찍는다.
@<해를 출력하고 |b5|로 간다@>=
count++
fmt.Printf("%d: ", count)
for k = 1; k <= m+1; k++ {
	fmt.Printf("%d", x[k])
}
fmt.Printf("->")
for k = m; k >= 0; k-- {
	fmt.Printf("%d", nybb(sig[l][:], k))
}
fmt.Printf("\n")
goto b5

@ 이 코드가 도는 시점에 |sig[l]|, |dist[l]|, |pdist[l]|은 물론 |xl|, |t|, |r|,
|alt|, |blt|가 모두 최신이라고 가정한다. 여기서 경계 $a_l$과 $b_l$을 다시 계산해
보고, 그 결과 $x_l\le|xl|$이 불가능하다고 판명되면 |b5|로 물러난다.
@<|xl| 이하가 불가능함이 쉽게 드러나면 |b5|로 간다@>=
loop:
	if t >= 0 {
		change = false
		@<$a_l$과 $b_l$을 다시 계산한다@>@;
		if vbose > 2 {
			fmt.Fprint(os.Stderr, " a=")
			printnum(a[l][:], t)
			fmt.Fprint(os.Stderr, ",b=")
			printnum(b[l][:], t)
			fmt.Fprint(os.Stderr, "\n")
		}
		if change {
			goto loop // $a_l$이나 $b_l$, 또는 둘 다 개선되었다
		}
		for alt == blt {
			@<현재 접두를 늘리거나 |b5|로 간다@>@;
		}
		if change {
			goto loop
		}
	}

@ 접두 바로 다음 자리의 값 |alt|와 |blt|는 앞날에 대한 중요한 제약이다. 이들을
조일 수 있으면 대개 더 조일 수 있고, 때로는 접두마저 늘릴 수 있다.
@<$a_l$과 $b_l$을 다시 계산한다@>=
if blt < xl {
	if r == 0 {
		goto b5
	}
	add(sig[l][:], table[1][alt][:], a[l][:]) // $a_l\gets|sig[l]|+|alt|^m$
	add(sig[l][:], table[1][blt][:], b[l][:])
	add(b[l][:], table[r-1][xl][:], b[l][:]) // $b_l\gets|sig[l]|+|blt|^m+(r-1)|xl|^m$
} else {
	for k = 0; k < mdigs; k++ {
		mems+=2; a[l][k] = sig[l][k] // $a_l\gets|sig[l]|$
	}
	add(sig[l][:], table[r][xl][:], b[l][:]) // $b_l\gets|sig[l]|+r\cdot|xl|^m$
}
@<개선된 |alt|와 |blt|를 반영한다@>@;

@ @<개선된 |alt|와 |blt|를 반영한다@>=
mems++
if alt != nybb(a[l][:], t) {
	if alt > nybb(a[l][:], t) {
		fmt.Fprintf(os.Stderr, "혼란 (a가 줄었다)!\n")
		os.Exit(13)
	}
	alt = nybb(a[l][:], t)
	if blt < xl {
		change = true
	}
}
mems++
if blt != nybb(b[l][:], t) {
	if blt < nybb(b[l][:], t) {
		fmt.Fprintf(os.Stderr, "혼란 (b가 늘었다)!\n")
		os.Exit(14)
	}
	blt = nybb(b[l][:], t)
	if blt < xl {
		change = true
	}
}

@ 여기가 가장 섬세하고 가장 중요한 대목이다. |x|의 자릿수 하나를 새로 알게 되어
접두를 한 자리 늘린다.

덧붙여, |goto| 없이는 코드를 되풀이하지 않고 짜기 어려운 ``흐름도''의 흥미로운
예이기도 하다. 두 조건 $A$, $B$와 두 동작 $\alpha$, $\beta$가 있다고 하자. $A$이고
$B$이면 $\alpha$ 다음 $\beta$를, $A$이고 $B$가 아니면 아무것도, $A$가 아니면 $\beta$만
하고 싶다. |goto| 없이 하려면 $A$를 두 번 평가하거나 $\beta$를 두 번 적어야 한다.
@<현재 접두를 늘리거나 |b5|로 간다@>=
mems++; p = pdist[l][blt]
if blt >= xl {
	mems++
	if p < dist[l][blt] {
		goto okay // ``필요한'' |goto|다!
	}
	if blt > xl {
		goto b5 // 이런, 그 자릿수는 이미 다 찼다
	}
	pd = p + 1 - dist[l][blt] // |pd|가 (아직 아니었다면) 양수가 된다
}
r--
if r < 0 {
	goto b5
}
add(sig[l][:], table[1][blt][:], sig[l][:]) // |xl|보다 작은, 새로 알게 된 자릿수
okay:
	mems++; pdist[l][blt] = p + 1
	t--
	change = true
	if t < 0 {
		break
	}
	mems+=2; alt = nybb(a[l][:], t); blt = nybb(b[l][:], t)

@ @<레벨 |l|의 이전 상태를 복원한다@>=
mems+=2; t = tsave[l]; r = rsave[l]
if t >= 0 {
	mems+=2
	alt = nybb(a[l][:], t)
	blt = nybb(b[l][:], t)
} else {
	alt = 9
	blt = 9
}
mems++; xl = x[l]

@ |dist|가 |pdist|를 ``따라잡는'' 중일 때는 |sig|를 바꾸지 않는다. 접두에 이미
나타난 자릿수는 벌써 셈에 넣었기 때문이다---|xl| 하나가 올 줄 알고 있었고, 이제야
도착한 것뿐이다. (|t|와 |r|도 그대로 둔다.)
@<강제된 수를 흡수한다@>=
if vbose > 1 {
	fmt.Fprintf(os.Stderr, "레벨 %d, 그 %d는 강제되었다\n", l, xl)
}
for k = 0; k < mdigs; k++ {
	mems+=2; sig[l][k] = sig[l-1][k]
}
pd--
if pd != 0 {
	goto move
}

@ 마지막으로, 깊이별 노드 수를 보고 싶을 때를 위한 프로파일 출력이다.
@<프로파일을 출력한다@>=
fmt.Fprintf(os.Stderr, "프로파일:          1\n")
for k = 2; k <= m+2; k++ {
	fmt.Fprintf(os.Stderr, "%19d\n", profile[k])
}

@* 색인.
