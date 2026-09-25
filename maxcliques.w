\input kotexgweb
@i types.w
\datethis

\mathchardef\AND="2026 % 비트별 and
\def\OR{\mathbin{\vert}} % 비트별 or

\def\title{극대 클리크}

@* 들어가며.
이것은 그래프의 극대 클리크를 모두 찾는 간단한 프로그램이다. 그래프는 마디가
많아야 $64$개이고, 인접 행렬로 주어진다.

알고리즘은 Moody와 Hollis가 낸 것으로, Jardine과 Sibson의 책 {\sl Mathematical
Taxonomy\/}(1971)의 부록 5에 나온다. 크누스는 이것을 ``오늘 서둘러'' 짰다고 한다.
그래프 이론에서 비트 조작을 쓰는 좋은 예라서 {\sl The Art of Computer
Programming\/}의 7.1.3절에 알맞겠다는 것이다.

줄여 말하면 이렇다. 마디 $v$마다 벡터 $\rho_v$와 $\delta_v$를 둔다. 벡터
$\rho_v$는 인접 행렬에서 $v$의 행이고, $\delta_v$는 자리 $v$만 $0$이고 나머지는
모두 $1$이다. ($\rho_v$의 자리 $v$는 늘 $1$이다. 곧 마디마다 제 자신과 이웃한다고
본다.) 그러면 마디 집합 $q$가 클리크일 필요충분조건은, 모든 마디 $v$에 걸쳐
$(v{\in}q?\,\rho_v{:}\,\delta_v)$를 비트별로 교차한 것이 $q$와 같은 것이다. 이는
쉽게 보일 수 있다. 그러니 클리크를 모두 찾으려면 그런 비트별 교차 $2^n$개를 모두
구해 겹치는 것을 버리면 된다. 극대 클리크를 모두 찾으려면 $2^n$개를 모두 구하고,
다른 것에 포함되는 클리크 $q$를 버리면 된다. 버리는 일을 훨씬 영리하게 하면 이것을
빠르게 할 수 있다.

@ 여기서 ``클리크''는 그래프의 완전 부분그래프를 모두 가리킨다. 그래프 이론의 옛
책들은 대개 클리크를 {\it 극대\/} 완전 부분그래프로 정의하지만, 그 용어는 이제
사라져 가고 있다. 옛 정의가 덜 바람직한 까닭이 있다. 이를테면 $G$의 클리크는
$\overline G$의 독립 집합과 같은 것이어야 좋은데, 옛 정의로는 그렇지 않다.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{maxcliques.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/maxcliques.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Fri, 21 Nov 2008 01:53:33 GMT}다.

입력 그래프는 \.{SGB} 형식의 파일로 주어진다. 그 파일 이름, 이를테면
`\.{foo.gb}'가 명령줄의 단 하나뿐인 인자다. 파일은 \pdfURL{go-sgb}%
{https://github.com/sjnam/go-sgb}의 |gbsave.RestoreGraph|로 읽는다. 크누스는 이
프로그램이 메모리를 몇 번 참조하는지(|mems|)와 작업 공간을 몇 낱말 쓰는지(|space|)를
재도록 계측해 두었다. 입출력은 빼고 잰다. 프로그램이 찍는 말과 종료 부호는 원본
그대로 두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

원본에는 이런 경고가 붙어 있다. ``메모리 넘침은 살피지 않는다. 튼튼한 프로그램으로
짠 것이 아니고, 실험 삼아 짰을 뿐이다.'' 옮기다 보니 결함 넷이 나왔다. 마디 없는
그래프에서 엉뚱한 것을 찍는 것, 작업 공간을 실제보다 적게 쓴 것으로 재는 것, 작업
공간이 넘치면 틀린 답을 조용히 내는 것, |mems|가 $32$비트를 넘으면 한 바퀴 도는
것이다. 모두 고쳤고, 저마다 그 자리에서 이야기한다. 맨 끝의 ``맞춰 보기''에 확인한
방법을 적었다.

@ 뼈대는 이렇다. 그래프를 읽고, 극대 클리크를 찾고, 찍는다.

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

@<상수@>@;
@<전역 변수@>@;

func main() {
	var i, j, k, l, m, n, p, q, r int
	var u, v, w uint64
	@<그래프를 읽는다@>@;
	@<극대 클리크를 찾는다@>@;
	@<극대 클리크를 찍는다@>@;
	fmt.Fprintf(out, "(The computation took %d mems, using %d words of workspace.)\n",
		mems, space)
	out.Flush()
}

@ 작업 공간 |work|의 크기는 원본대로 $100000$낱말로 둔다.

원본의 |mems|는 \.{unsigned int}라서 $2^{32}$을 넘으면 한 바퀴 돈다. 작업 공간이
넘치지 않는 그래프에서도 그렇게 된다. 마디 $30$개짜리 문--모저 그래프(삼각형 열
개의 여그래프)에 마디 셋을 확률 $0.9$로 이어 붙인 그래프에서, 이 판은 $4390690837$
mems를 세는데 원본은 거기서 $2^{32}$을 뺀 $95723541$을 찍었다. 극대 클리크
$62937$개 자체는 맞았다. 이 판은 $64$비트로 센다.

@<상수@>=
const size = 100000 // 작업 공간의 크기

@ @<전역 변수@>=
var (
	rho   [64]uint64   // 인접 행렬의 행들
	work  [size]uint64 // 작업 공간
	mems  uint64       // 메모리 참조 횟수
	space int          // 작업 공간을 가장 많이 쓴 낱말 수
	table [64]byte     // 드 브라윈 표
	out   = bufio.NewWriter(os.Stdout) // 표준 출력의 버퍼
)

@ @<그래프를 읽는다@>=
if len(os.Args) != 2 {
	fmt.Fprintf(os.Stderr, "Usage: %s inputgraph.gb\n", os.Args[0])
	os.Exit(-1)
}
g, err := gbsave.RestoreGraph(os.Args[1])
if err != nil {
	var pc gbgraph.PanicCode
	errors.As(err, &pc)
	fmt.Fprintf(os.Stderr, "I can't input the graph %s (panic code %d)!\n",
		os.Args[1], int64(pc))
	os.Exit(-2)
}
n = int(g.N)
if n > 64 {
	fmt.Fprintf(os.Stderr, "Sorry, that graph has %d vertices; ", n)
	fmt.Fprintf(os.Stderr, "I can't handle more than 64!\n")
	os.Exit(-3)
}
@<|rho| 표를 채운다@>@;

@ 행 |rho[j]|에는 제 자리 $j$를 켜 두고, 이웃마다 그 자리를 켠다.

@<|rho| 표를 채운다@>=
for j = 0; j < n; j++ {
	w = 1 << j
	for a := g.Vertices[j].Arcs; a != nil; a = a.Next {
		w |= 1 << g.Index(a.Tip)
	}
	rho[j] = w
}

@ 극대 클리크는 비트 벡터 |work[1]|부터 |work[m]|까지에 담겨 나온다. 벡터마다 켜진
비트의 자리를 차례로 찾아 그 마디의 이름을 찍는다. 가장 낮은 켜진 비트 $v$를 드
브라윈 수열을 곱해 찾는다. 곱 $v\cdot|deBruijn|$의 위쪽 여섯 비트는 $v$의 자리마다
모두 다르다. 상수 |deBruijn|은 길이 $64$인 가장 작은 드 브라윈 순환열이다.

@<상수@>=
const deBruijn = 0x03f79d71b4ca8b09 // 길이 $64$인 가장 작은 드 브라윈 순환열

@ @<극대 클리크를 찍는다@>=
fmt.Fprintf(out, "Graph %s has %d maximal cliques:\n", g.ID, m)
@<드 브라윈 표를 채운다@>@;
for k = 1; k <= m; k++ {
	for w = work[k]; w != 0; w ^= v {
		v = w & -w
		u = v * deBruijn
		j = int(table[u>>58])
		fmt.Fprintf(out, " %s", g.Vertices[j].Name)
	}
	fmt.Fprintf(out, "\n")
}

@ 앞 절의 룰러 함수 계산은 안쪽 반복문에 들지 않는다. 그러니 한 번에 한 비트씩
그냥 살피는 느린 방법을 써도 된다. 그래도 크누스는 경험을 쌓으려고 드 브라윈 방법을
썼다. 이 판도 따른다.

@<드 브라윈 표를 채운다@>=
for j, v = 0, 1; v != 0; j, v = j+1, v<<1 {
	u = v * deBruijn
	table[u>>58] = byte(j)
}

@* 알고리즘.
작업 공간 |work|는 처음 $i$개 마디에 대해 $\rho_v$나 $\delta_v$를 골라 비트별로
교차한 $2^i$개 가운데 극대인 것을 모두 담는다. 그런 것이 $m$개다.

다른 모든 마디와 이웃한 마디는 모든 항목에 그냥 실려 가므로 신경 쓸 까닭이 없다.
이 판은 그런 마디를 |rho[i]|가 $n$개의 1과 같은지로 알아본다. 그 값은
|work[size-1]|에 넣어 둔다.

원본은 $n$개의 1을 |w=1<<(n-1)|로 구한 |(w<<1)-1|로 만든다. $n=64$에서도 맞게
하려는 궁리인데, $n=0$이면 음수만큼 민다. \CEE/에서 이것은 정의되지 않은 동작이고,
실제로는 $64$비트가 모두 켜진 값이 나왔다. 그래서 원본은 마디 없는 그래프에서
``극대 클리크 하나''를 찍으며 없는 마디의 이름을 $64$개나 읽는다.
\.{AddressSanitizer}는 이것을 힙 넘침으로 잡는다. \.{Go}에서는 $64$비트 이상 밀면
$0$이 되므로 |1<<n-1|이 $n=0$부터 $64$까지 모두 맞다. 마디 없는 그래프의 극대
클리크는 빈 클리크 하나뿐이니, 이 판은 빈 줄 하나를 찍는다.

@<극대 클리크를 찾는다@>=
mems += 2
work[1] = 1<<n - 1 // $n$개의 1
work[size-1] = work[1]
m, space = 1, 4
for i = 0; i < n; i++ {
	mems += 2
	if rho[i] == work[size-1] {
		continue
	}
	v = 1 << i // 이제 살펴볼 새 마디
	@<|v|를 담은 항목이 뒤로 가게 |work|를 가른다@>@;
	@<|v|를 담은 항목 $u$를 $u\AND\rho_v$와 $u\AND\delta_v$로 바꾼다@>@;
}

@ 지금 형편을 그려 보자. 비트 $v$가 맨 왼쪽이라 하자. 그러면 |work[1]|부터
|work[m]|까지를 다음 꼴로 다시 늘어놓고 싶다.
$$\vcenter{\halign{#\thinspace&$#$\hfil\cr
0&\alpha_1\cr
 &\vdots\cr
0&\alpha_k\cr
1&\beta_1\cr
 &\vdots\cr
1&\beta_{m-k}\cr}}$$

이 반복문은 기수 교환 정렬의 가르기 단계와 닮았다. $u\AND v\ne0$인 항목 $u$가 늘
적어도 하나 있다. 편하게(그리고 빠르게) 하려고 |work[0]=0|을 늘 지켜 둔다. 그것이
|k|를 막는 파수꾼이다.

@<|v|를 담은 항목이 뒤로 가게 |work|를 가른다@>=
j, k = 1, m
for {
	for {
		mems++
		if work[j]&v != 0 {
			break
		}
		j++
	}
	for {
		mems++
		if work[k]&v == 0 {
			break
		}
		k--
	}
	if j > k {
		break
	}
	mems += 2
	work[j], work[k] = work[k], work[j]
	j, k = j+1, k-1
}

@ 이제 재미있는 대목이다. 여기서 $j=k+1$이다.

작업 공간의 $1$번부터 $k$번 항목은 다음 판으로 그냥 넘기면 된다. 앞의 표기로
$u=0\,\alpha_i$이면 $u\AND\rho_v\subseteq u\AND\delta_v=u$이고, $u$는 지금 극대이니
다른 어느 항목에도 들지 않기 때문이다.

그러니 남은 항목, 곧 |work[j]|부터 |work[m]|까지에 눈을 돌리면 된다. 이것들은
``쪼개야'' 한다. 지금 항목을 $u$라 하자. 이것을 $u'=u\AND\rho_v$와
$u''=u\AND\delta_v$로 쪼개고 싶다. 앞의 것 $u'=(1\beta)\AND\rho_v$는 새 판에
받아들이기 전에 다른 모든 앞의 것과 견주어야 한다. (자리 $v$가 1이라서 뒤의 것에는
들 수 없다.) 이미 만든 앞의 것에 들면 버린다. 거꾸로 그런 것들을 품으면 여럿을
버려야 할 수도 있다.

뒤의 것 $u''=(1\beta)\AND\delta_v=0\beta$는 다루기가 꽤 쉽다. 이것이 어떤 앞의 것
$(1\beta')\AND\rho_v$에 들려면 $\beta\subseteq\beta'$여야 한다. 그러면
$\beta=\beta'$이고 $1\beta\subseteq\rho_v$다. 따라서 $1\beta\not\subseteq\rho_v$이면,
$0\beta$가 넘겨 둔 항목 $0\alpha$ 어디에도 들지 않을 때에만 받아들인다.

@ 다음 단계들에서 작업 공간의 |p|번부터 |size-2|번까지는 잠정적으로 받아들인 앞의
것 $u'$들을 담는다. 그리고 $k+1$번부터 |l|번까지는 확정해 받아들인 뒤의 것
$u''$들을 담는다. 두 무리가 작업 공간의 양 끝에서 서로를 향해 자란다.

이렇게 짠 알고리즘은 연결 메모리를 쓰지 않으니 캐시에 너그러울 것이다.

원본에서는 |goto|가 세 이름표로 뛴다. \.{Go}의 |goto|도 바깥 블록의 뒤쪽 이름표로
뛰는 것은 허락하므로 |absorb|와 |secondEntry|는 그대로 두었다. 셋째
|done_with_u|는 반복문의 다음 차례로 가는 것뿐이라, 이름표 붙은 |continue|로 바꾸었다.

@<|v|를 담은 항목 $u$를 $u\AND\rho_v$와 $u\AND\delta_v$로 바꾼다@>=
l, p = k, size-1
nextU:
for ; j <= m; j++ {
	mems++
	u, q = work[j], size-2
	w = u & rho[i] // $w=u'$. |rho[i]|는 이미 읽어 왔다
	if u != w {
		@<$u'$를 앞의 것들과 견주어 잠정적으로 받아들인다@>@;
	}
absorb:
	@<$w$가 앞의 것들을 품을 수 있는 경우를 다룬다@>@;
	if u == w {
		continue
	}
secondEntry:
	w = u &^ v // $w=u''$
	for q = 1; q <= k; q++ {
		mems++
		if w&work[q] == w {
			continue nextU
		}
	}
	mems++
	l++
	work[l] = w // $u''$를 받아들인다
}
for m = l; p < size-1; p++ {
	mems += 2
	m++
	work[m] = work[p]
}

@ 앞의 것 $w$가 이미 있는 앞의 것에 들면 버리고 뒤의 것으로 간다. 거꾸로 이미 있는
것을 품으면 |absorb|로 간다. 둘 다 아니면 잠정적으로 받아들인다.

@<$u'$를 앞의 것들과 견주어 잠정적으로 받아들인다@>=
for ; q >= p; q-- {
	mems++
	if w&work[q] == w {
		goto secondEntry
	}
	if w&work[q] == work[q] {
		goto absorb
	}
}
mems++
p--
work[p] = w // $u'$를 잠정적으로 받아들인다
@<|space|를 고치고 넘침을 살핀다@>@;
goto secondEntry

@ 원본은 작업 공간이 넘치는지 살피지 않는다. 앞에 옮긴 경고대로다. 그런데 넘치면
죽지 않고 틀린 답을 조용히 낸다. 두 무리가 |work| 배열 {\it 안에서\/} 서로를 덮어쓸
뿐이라 \.{AddressSanitizer}도 잡지 못한다. 이를테면 삼각형 열한 개의 여그래프, 곧
마디 $33$개짜리 문--모저 그래프는 극대 클리크가 $3^{11}=177147$개인데, 원본은
$87499$개라고 답했다.

두 무리가 부딪치지 않으려면 |work[p-1]|이 아직 쓰는 아래쪽 항목 |work[m]| 위에
있어야 한다. 자리 |work[p-1]|은 다음 절의 파수꾼이 들어갈 곳이다. 곧 $p\ge m+2$여야 하는데, 이는
원본이 재는 사용량 $m+2+|size|-p$가 |size|를 넘지 않는다는 말과 같다. 그래서 이
판은 |space|를 늘릴 때마다 |size|와 견주어, 넘치면 알리고 멈춘다. 이 말과 종료
부호 $-4$는 이 판에서 지은 것이다.

@<|space|를 고치고 넘침을 살핀다@>=
if space < m+2+size-p {
	space = m + 2 + size - p
	if space > size {
		fmt.Fprintf(os.Stderr, "Oops: workspace overflow (more than %d words)!\n",
			size)
		os.Exit(-4)
	}
}

@ 끝으로 기수 교환 가르기와 닮은 반복문이 하나 더 필요하다. 이번에는 |w|에 드는
항목을 모두 아래로, 들지 않는 항목을 모두 위로 옮긴다. (사실 아래로는 아무것도 옮기지
않는다. 그 항목들은 버릴 것이기 때문이다.)

항목 $u$가 $w$와 다른 채로 여기 오면 첫 검사는 쓸데없다. $w\AND|work|[q]=|work|[q]$임을, 곧
$w\OR|work|[q]=w$임을 이미 알기 때문이다. 반복문의 순서를 바꾸고 $u=w$일 때만을 위해
일부를 따로 베껴 두면 피할 수 있지만, 크누스는 그런 까다로운 최적화까지는 하지
않았다.

원본은 여기서 |p|를 내려도 |space|를 고치지 않는다. 앞의 것을 잠정적으로 받아들일
때만 고친다. 그런데 $u=w$이고 품는 것이 없으면 $w$는 |work[p-1]|에 들어가고 |p|가
하나 내려간다. 그래서 원본이 찍는 작업 공간은 실제보다 작을 수 있다. 마디 $30$개짜리
문--모저 그래프에서 원본은 $59052$낱말을 썼다고 찍지만, 같은 셈법으로 따지면
$78735$낱말이다. 이 판은 여기서도 |space|를 고친다. 그래야 앞 절의 넘침 검사도
믿을 수 있다.

@<$w$가 앞의 것들을 품을 수 있는 경우를 다룬다@>=
mems++
r = p
work[p-1] = 0
for {
	for {
		mems++
		if w|work[q] == w {
			break
		}
		q--
	}
	for {
		mems++
		if w|work[r] != w {
			break
		}
		r++
	}
	if q < r {
		break
	}
	mems += 2
	work[q], work[r] = work[r], 0
	q, r = q-1, r+1
}
mems++
work[q] = w
p = q
@<|space|를 고치고 넘침을 살핀다@>@;

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 \.{libgb}와 함께 컴파일해 이 판과 견주었다. (요즘의
\.{macOS} 헤더는 매개변수 이름으로 |size|를 쓰므로, 원본의 매크로 |size|와 부딪쳐
컴파일되지 않는다. 대조용 \CEE/ 판에서는 이 이름만 바꾸었다.)

\smallskip
\item{$\bullet$} 답이 옳은지는 파이썬으로 짠 Bron--Kerbosch 알고리즘과 견주어
보았다. 마디 $1$개부터 $64$개까지의 무작위 그래프, 문--모저 그래프, 마디 없는
그래프 $77$개 가운데 $75$개에서 극대 클리크의 집합이 같았다. 나머지 둘은 마디
$64$개에 변의 확률이 $0.9$인 무작위 그래프로, 이 판은 작업 공간이 넘친다고 알리고
멈추었다. 원본은 거기서 극대 클리크가 $72629$개와 $73250$개라고 답했는데, 실제로는
$765373$개와 $692788$개다.
\item{$\bullet$} 앞의 네 곳을 고친 \CEE/ 판과 이 판의 표준 출력, 표준 오류, 종료
부호가 바이트까지 같은지를 보았다. 사용법을 알리는 말에 든 프로그램 이름만 뺐다.
그래프 $85$개(유향 그래프와 마디가 $65$개인 그래프도 섞었다)와 잘못된 명령줄 넷에서
모두 같았다.
\item{$\bullet$} 고치기 전의 원본과는, 작업 공간이 넘치지 않는 그래프 $79$개에서
마지막 줄만 빼고 모두 같았다. 마지막 줄의 |space|는 원본이 적게 재고, |mems|는
$2^{32}$을 넘으면 원본이 한 바퀴 돈다.
\smallskip

@* 색인.
