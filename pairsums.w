\input kotexgweb
@i types.w

\def\title{쌍 곱의 합}

@* 들어가며.
배열의 {\it 값\/}을, 자리 쌍 $i<j$ 모두에 대해 그 두 성분의 곱을 더한 것으로 하자.
$$\mathop{\rm value}(A)=\sum_{i<j}A_iA_j.$$
(자리가 다르면 수가 같아도 다른 쌍으로 센다.) 배열 하나가 주어지면, 우리는 그
배열의 비어 있지 않은 {\it 부분 배열\/}, 곧 잇닿은 토막이 가질 수 있는 가장 큰 값을
찾고자 한다. 성분이 하나뿐인 토막에는 쌍이 없으니 값이~$0$이고, 그것이 답의
아래끝이다.

배열은 길 수 있다. 성분이 $n=5\cdot10^5$개까지이고 저마다 $[-10^3,10^3]$에 든다.
부분 배열은 $\Theta(n^2)$개이므로 위끝에서는 하나씩 해 보는 것이 가망 없다. 이
문제의 즐거움은 간단한 대수 하나가 이것을 {\it 직선 가족의 위 포락선\/}에 대한
물음으로 바꾸어 놓고, 그 물음에 리차오 트리가 $O(n\log n)$ 시간에 답한다는 데 있다.

@ 입력은 첫 줄에 $n$, 다음 줄에 성분 $n$개다. 값 $n$이 50만까지 가므로 버퍼를 둔
낱말 훑개로 읽는다. 답은 정수 하나다.

@c
package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
)

@<직선과 리차오 트리@>

func main() {
	sc := bufio.NewScanner(os.Stdin)
	sc.Buffer(make([]byte, 1<<20), 1<<26)
	sc.Split(bufio.ScanWords)
	readInt := func() int64 {
		sc.Scan()
		v, _ := strconv.ParseInt(sc.Text(), 10, 64)
		return v
	}

	n := int(readInt())
	a := make([]int64, n)
	for i := range a {
		a[i] = readInt()
	}

	@<리차오 트리로 푼다@>
}

@* 리차오 트리.
합의 제곱은 대각 부분과 비대각 부분으로 갈라진다.
$$\Bigl(\sum_i A_i\Bigr)^2=\sum_i A_i^2+2\sum_{i<j}A_iA_j.$$
그러므로 토막의 합을 $S=\sum A_i$, 제곱의 합을 $Q=\sum A_i^2$이라 하면
$$\mathop{\rm value}=\sum_{i<j}A_iA_j={S^2-Q\over2}$$
이다. 분자 $S^2-Q$는 $2\sum_{i<j}A_iA_j$와 같아 짝수이니, 값은 언제나 정확히
정수다. 우리는 $S^2-Q$를 크게 만들고 마지막에 이긴 값을 반으로 나눌 것이다.

@ 성분의 누적합을 $P_k=A_0+\cdots+A_{k-1}$, 성분 제곱의 누적합을
$R_k=A_0^2+\cdots+A_{k-1}^2$이라 하자($P_0=R_0=0$). 자리
$i,\ldots,j-1$에 걸친 부분 배열, 곧 누적합 첨자로는 $i<j$인 것은 $S=P_j-P_i$와
$Q=R_j-R_i$를 가지므로
$$S^2-Q=(P_j-P_i)^2-(R_j-R_i)$$
이다. 이제 오른쪽 끝 $j$를 고정하고 이것을 왼쪽 끝~$i$의 함수로 보자.
$$(P_j-P_i)^2-(R_j-R_i)=\underbrace{(P_j^2-R_j)}_{j\hbox{\sevenrm 가 정하는 몫}}
   +\underbrace{\bigl[(-2P_i)\,P_j+(P_i^2+R_i)\bigr]}_{\hbox{\sevenrm 직선 }\ell_i
   \hbox{\sevenrm 의 }P_j\hbox{\sevenrm 에서의 값}}.$$
그러니 왼쪽 끝 후보~$i$는 저마다 직선
$$\ell_i(t)=(-2P_i)\,t+(P_i^2+R_i)$$
을 내놓고, 주어진~$j$에 가장 좋은 왼쪽 끝은 $t=P_j$에서 제 직선이 가장 높은 것이다.
오른쪽 끝 $j$를 왼쪽에서 오른쪽으로 쓸어 가며, 자리~$i$가 쓸 수 있는 왼쪽 끝이 되는
순간에 $\ell_i$를 넣고, 지금까지의 직선 가운데 점 $P_j$에서 가장 높은 것을 묻는다.

@ 직선 |line|은 $y=a\,x+b$다. 계수도 결과도 |int64| 안에 머문다. 기울기의 크기는
많아야 $2\cdot5\cdot10^8$이고 질의하는 점은 많아야 $5\cdot10^8$이니, 곱은
$5\cdot10^{17}$ 아래여서 범위 안에 넉넉히 든다.

@<직선과 리차오 트리@>=
type line struct{ a, b int64 }
@#
func (l line) at(x int64) int64 { return l.a*x + l.b }

@ 마디 하나는 $x$ 값의 구간 $[lo,hi]$와, 그 중점에서 지금 이기고 있는 직선과, 두
반쪽을 맡을 자식 둘을 가진다. 갓 만든 마디는 $-\infty$에 누운 보초 직선으로
시작하므로, 처음 들어오는 진짜 직선이 언제나 그것을 이긴다.

@<직선과 리차오 트리@>=
type liChao struct {
	lo, hi      int64
	ln          line
	left, right *liChao
}
@#
func newLiChao(lo, hi int64) *liChao {
	return &liChao{lo: lo, hi: hi, ln: line{0, math.MinInt64 / 4}}
}

@ 직선을 넣는 |add|는 새 직선을 마디의 챔피언과 두 곳, 곧 $lo$와 $mid$에서 견준다.
새것이 중점에서 이기면 그것을 여기에 두고 옛 직선을 끌어내린다. 이제 진 쪽이
여전히 가장 좋을 수 있는 곳은 많아야 한쪽, 곧 끝점 검사에서도 진 쪽뿐이다. 그래서
바로 그 자식으로 재귀한다. 중점은 산술 밀기로 셈하는데, 이것은 $-\infty$ 쪽으로
내림하므로 여기 나오는 음수 좌표에서도 옳게 움직인다.

@<직선과 리차오 트리@>=
func (t *liChao) add(nw line) {
	m := (t.lo + t.hi) >> 1
	bl := nw.at(t.lo) > t.ln.at(t.lo)
	bm := nw.at(m) > t.ln.at(m)
	if bm {
		t.ln, nw = nw, t.ln
	}
	switch {
	case t.lo == t.hi:
		return
	case bl != bm:
		if t.left == nil {
			t.left = newLiChao(t.lo, m)
		}
		t.left.add(nw)
	default:
		if t.right == nil {
			t.right = newLiChao(m+1, t.hi)
		}
		t.right.add(nw)
	}
}

@ 질의는 챔피언의 $x$에서의 높이를 잡고, $x$를 담은 한쪽 자식으로 그것을 낫게
한다. 더 좋은 직선이 숨어 있을 수 있는 곳은 거기뿐이다.

@<직선과 리차오 트리@>=
func (t *liChao) query(x int64) int64 {
	best := t.ln.at(x)
	m := (t.lo + t.hi) >> 1
	if x <= m {
		if t.left != nil {
			best = max(best, t.left.query(x))
		}
	} else if t.right != nil {
		best = max(best, t.right.query(x))
	}
	return best
}

@ 배열에 음수 성분이 있으므로 기울기 $-2P_i$도 질의하는 점 $P_j$도 정렬된 차례로
오지 않는다. 그래서 단조성을 쓰는 보통의 볼록 껍질 요령은 쓸 수 없다. 리차오 트리는
일반적인 경우를 다룬다. 이것은 있을 수 있는 $x$ 값의 범위 위에 놓인 세그먼트
트리인데, 마디마다 그 마디의 중점에서 가장 높은 직선 하나를 들고 있다가 진 쪽을
그것이 아직 이길 수 있는 반쪽으로 밀어 내린다. 직선을 넣는 일도 한 점에서 최댓값을
묻는 일도 층마다 마디 하나씩만 들르므로, 둘 다 $O(\log V)$가 든다. 여기서 $V$는 좌표
범위의 너비다. 넣기가 $n$번이고 묻기가 $n$번이니 탐색 전체는 $O(n\log V)$다.

@ 풀이는 누적합 배열을 짓고, 관찰된 $P$의 범위에 걸친 리차오 트리를 연 다음,
오른쪽 끝~$j$를 쓸어 간다. 걸음마다 $P_j$에서 가장 좋은 직선을 읽고, $j$가 정하는
몫 $P_j^2-R_j$를 보태고, 그러고 나서 자리~$j$를 앞으로 쓸 왼쪽 끝으로 받아들인다.
돌아가는 최댓값이 $S^2-Q$이고, 그것을 반으로 나누면 답이다.

@<리차오 트리로 푼다@>=
@<누적합 |p|와 |r|를 짓는다@>@;
@<|p|의 범위에 트리를 연다@>@;
best := int64(math.MinInt64)
tree.add(line{-2 * p[0], p[0]*p[0] + r[0]})
for j := 1; j <= n; j++ {
	g := p[j]*p[j] - r[j] + tree.query(p[j])
	best = max(best, g)
	if j < n {
		tree.add(line{-2 * p[j], p[j]*p[j] + r[j]})
	}
}
fmt.Println(best / 2)

@ @<누적합 |p|와 |r|를 짓는다@>=
p := make([]int64, n+1)
r := make([]int64, n+1)
for k := 1; k <= n; k++ {
	p[k] = p[k-1] + a[k-1]
	r[k] = r[k-1] + a[k-1]*a[k-1]
}

@ 질의하는 점도 직선을 견주는 자리도 모두 $P$의 값이므로, $[\min P,\max P]$에 걸친
트리면 넉넉히 넓다.

@<|p|의 범위에 트리를 연다@>=
lo, hi := p[0], p[0]
for _, v := range p {
	lo = min(lo, v)
	hi = max(hi, v)
}
tree := newLiChao(lo, hi)

@* 색인.
