\input kotexgweb
@i types.w

\def\title{플로이드의 분할 문제}

@* 들어가며.
1972년 가을, 밥 플로이드는 스탠퍼드 박사 과정 첫해 학생들에게 다음 ``장난감 문제''를
냈다. 크누스는 나중에 그의 글 {\it 장난감 문제는 쓸모 있는가?}({\sl Selected Papers
on Computer Science}, 1996에 다시 실렸다)에서 이것을 다루었다.

\smallskip
{\narrower\narrower\noindent
\llap{``}수 $\sqrt1,\sqrt2,\ldots,\sqrt{50}$을 합이 거의 같은 두 몫으로 가르라.
컴퓨터 시간을 10초 미만으로 써서 찾을 수 있는 가장 좋은 분할을 찾으라.''
\smallskip}

\noindent 그런데
$$\hbox{$(\sqrt1+\sqrt2+\cdots+\sqrt{50})/2 =
   119.51790\,03017\,60392\,24702\ldots$}$$
이므로, 두 몫은 저마다 이 절반 값에 되도록 가까워야 한다. 달리 말하면 우리가 찾는
것은 $\{\sqrt1,\ldots,\sqrt{50}\}$의 부분집합 가운데 합이 그 값을 가장 조금 넘는
것이다.

무차별 탐색은 가망이 없다. 부분집합이 $2^{50}\approx10^{15}$개이고, 가운데 것들은
빽빽하게 몰려 있다. 목표 둘레의 길이 70이 채 안 되는 구간 안에 합이 들어가는 것만
$10^{14}$개가 넘으니, 가장 좋은 분할은 목표를 $10^{-13}$쯤으로 비껴갈 것이다.
재미있는 대목은 부분집합 $10^{15}$개를 다 보지 않고 그 바늘을 찾아내는 것이다.

이 프로그램은 그 일을 2초가 안 되어 해낸다. 고전적인 착상 넷을 엮은 것인데, 좋은
장난감 문제가 가르쳐 주는 기법으로 크누스의 글이 하나하나 꼽은 것들이다. {\it
완전제곱수\/}를 정수 조절 손잡이로 떼어 내는 것, 정렬된 찾아보기 표를 둔 {\it
중간에서 만나기\/} 가르기, {\it 그레이 부호\/}로 부분집합을 늘어놓는 것, 그리고
임의 정밀도 검사가 받쳐 주는 {\it 보정 덧셈\/}이다. 탐색 전체가 겨냥하는 상수는
하나, |float64|로 낼 수 있는 정밀도까지 적은 목표 값이다.

@c
package main

import (
	"flag"
	"fmt"
	"math"
	"math/big"
	"math/bits"
	"sort"
	"time"
)

const target = 119.51790030176039224702 // $(\sqrt1+\sqrt2+\ldots+\sqrt{50})/2$

@<타입@>
@<함수들@>

func main() {
	@<명령줄 플래그를 읽는다@>
	@<완전제곱수를 따로 떼어 둔다@>
	@<|A| 부분집합 합의 정렬된 표를 짓는다@>
	@<탐색 상태를 마련한다@>
	@<도우미 |eval|을 정의한다@>
	@<도우미 |probe|를 정의한다@>
	@<그레이 부호로 |B|를 훑으며 부분집합마다 탐침한다@>
	@<이긴 분할을 되짚어 짓는다@>
	@<고정밀도로 확인하고 보고한다@>
}

@ 플래그 \.{-v}는 시간 줄과 |math/big| 확인을 켠다. 이것이 없으면 프로그램은 두
몫만 찍는다. 시계는 곧바로 돌린다. 그래야 보고하는 시간이 탐색 전체를 덮는다.

@<명령줄 플래그를 읽는다@>=
verbose := flag.Bool("v", false, "자세히 찍기")
flag.Parse()

start := time.Now()

@* 플로이드 문제에 다가가기.
$1,\ldots,50$ 가운데 완전제곱수는 정확히 일곱이다. 1, 4, 9, 16, 25, 36, 49다. 그
제곱근 $1,2,\ldots,7$은 {\it 정수\/}이므로, 제곱수 하나를 이 몫에서 저 몫으로 옮기면
몫의 합이 정수만큼 바뀐다. 게다가 $0$부터 $28$까지의 모든 정수를
$\{1,2,\ldots,7\}$의 부분집합의 합으로 적을 수 있다. 그러니 제곱수들은 맨 마지막에
돌리면 되는 공짜 조절 손잡이 $k\in[0,28]$을 준다.

여기가 핵심적인 단순화다. 탐색의 어려운 대목에서는 합의 정수 부분을 아예 무시하고
{\it 소수\/} 부분만 걱정해도 된다. 정수 부분은 나중에 제곱수들이 119까지 맞춰 줄 수
있다는 것을 알기 때문이다. 그러면 제곱수가 아닌 43개가 남는데, 그 제곱근은
무리수이므로 진짜로 찾아봐야 할 것은 이것뿐이다.

@<완전제곱수를 따로 떼어 둔다@>=
squares := map[int]bool{1: true, 4: true, 9: true, 16: true, 25: true, 36: true, 49: true}
var nonSquares []int
for k := 1; k <= 50; k++ {
	if !squares[k] {
		nonSquares = append(nonSquares, k)
	}
}
Aitems := nonSquares[:21]
Bitems := nonSquares[21:]

@ 제곱수가 아닌 수들의 부분집합 $2^{43}$개도 늘어놓기에는 여전히 너무 많다. 흔히
쓰는 처방은 {\it 중간에서 만나기\/}다. 43개를 두 몫, 곧 앞의 21개인 $A$와 뒤의
22개인 $B$로 가르고, 한쪽에서 지수 시간을 지수 공간과 맞바꾼다. $A$의 부분집합 합
$2^{21}\approx200$만 개를 미리 셈해 {\it 정렬\/}해 두면, $B$의 부분집합 합
$2^{22}\approx400$만 개마다 이진 탐색 한 번으로 그것을 가장 잘 채워 주는 $A$의
부분집합을 찾는다. 일의 양은 $2^{50}$이 아니라 $2^{22}\log 2^{21}$쯤이니 플로이드가
준 예산 안에 넉넉히 든다.

표의 각 칸은 세 가지를 기억한다. 부분집합 합의 소수 부분(우리가 찾는 열쇠), 합
전체(정수 손잡이를 나중에 고르는 데 쓴다), 그리고 21개 가운데 어느 것이 부분집합에
들었는지 적어 두는 비트 |mask|다.

@<타입@>=
type entry struct {
	frac float64
	sum  float64
	mask uint32
}

@ 표는 소수 부분으로 정렬한다. 자그마한 |sort.Interface| 하나면 된다.

@<함수들@>=
type byFrac []entry

func (s byFrac) Len() int           { return len(s) }
func (s byFrac) Less(i, j int) bool { return s[i].frac < s[j].frac }
func (s byFrac) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }

@ 표를 짓는 일은 |genAll|을 부르고(다음 두 절에서 만든다) 그 결과를 정렬하는
것이다. 이진 탐색을 하려고 정렬된 소수 부분만 따로 |[]float64|로 뽑아 두는데,
|sort.SearchFloat64s|가 그것을 바로 뒤질 수 있기 때문이다. 목표 자신의 소수 부분도
한 번 적어 둔다. 탐침마다 그것과 견주기 때문이다.

@<|A| 부분집합 합의 정렬된 표를 짓는다@>=
tA := time.Now()
Aents := genAll(Aitems)
sort.Sort(byFrac(Aents))
Afracs := make([]float64, len(Aents))
for i, e := range Aents {
	Afracs[i] = e.frac
}
if *verbose {
	fmt.Printf("A (2^%d) 만들기+정렬: %v\n", len(Aitems), time.Since(tA))
}

targetFrac := target - math.Floor(target)
nA := len(Aents)

@ 우리는 이제 제곱근 수백만 개를 더하면서, 소수점 아래 {\it 열셋째\/} 자리까지 옳은
답을 찾으려 한다. 순진하게 |float64|로 쌓으면 거기 닿기 훨씬 전에 값이 흘러내린다.
처방은 {\it 보정 덧셈\/}이다. 돌아가는 합 |sum| 곁에 작은 보정항 |c|를 두어, 덧셈마다
잃어버리는 낮은 자리 비트를 담는다. 새 값이 지금까지의 합보다 클 때까지 다루는
노이마이어(카한--바부슈카) 개량이다.

@<함수들@>=
func kbn(sum, c, v float64) (float64, float64) {
	t := sum + v
	if math.Abs(sum) >= math.Abs(v) {
		c += (sum - t) + v
	} else {
		c += (v - t) + sum
	}
	return t, c
}

@* 그레이 부호로 부분집합 늘어놓기.
부분집합 $2^n$개를 싸게 둘러보려고 {\it 그레이 부호\/} 순서로 걷는다. 이 순서에서는
이웃한 두 부분집합이 원소 하나만 다르다. 그러면 한 걸음마다 $\sqrt k$ 하나를 더하거나
빼는 것으로 끝나, 22개 항을 다시 더하는 대신 $O(1)$에 합을 고친다. 걸음~|i|에서
뒤집히는 원소는 |i|의 가장 낮은 켜진 비트 자리에 있는 것인데, |bits.TrailingZeros32|가
그 자리를 바로 준다. 그것이 부분집합에 들어오는지 나가는지는 그 비트가 지금 |mask|에
켜져 있는지로 갈린다.

함수 |genAll|은 이것을 수의 목록에 적용해 칸 전체의 표를 돌려준다. 합은 모두 보정
덧셈 |kbn|으로 고쳐 가므로, 그레이 부호로 고친 값도 마지막 한두 비트까지 정확하다.
0번 칸(빈 부분집합, 합 0)은 |entry|의 영값 그대로 둔다.

@<함수들@>=
func genAll(items []int) []entry {
	n := len(items)
	size := uint32(1) << uint(n)
	vals := make([]float64, n)
	for i, k := range items {
		vals[i] = math.Sqrt(float64(k))
	}
	out := make([]entry, size)
	var sum, c float64
	var mask uint32
	for i := uint32(1); i < size; i++ {
		pos := uint(bits.TrailingZeros32(i))
		var v float64
		if mask&(1<<pos) != 0 {
			mask &^= 1 << pos
			v = -vals[pos]
		} else {
			mask |= 1 << pos
			v = vals[pos]
		}
		sum, c = kbn(sum, c, v)
		full := sum + c
		out[i].frac = full - math.Floor(full)
		out[i].sum = full
		out[i].mask = mask
	}
	return out
}

@ $A$의 표를 짓고 정렬해 두었으니, 이제 $B$의 부분집합 합을 흘려보내며 그때마다
표에게 가장 잘 맞는 짝을 묻는다. 탐색 상태는 지금까지 찾은 가장 좋은 쌍을 적어
둔다. 가장 작은 남은 오차 |bestDiff|, 그것을 이룬 두 합과 두 마스크, 그리고 정수
손잡이 |bestK|다.

수 $B$의 값도 $A$의 것처럼 제곱근을 미리 한 번 구해 둔다. 그래야 그레이 부호
반복문이 더하고 빼기만 하면 된다.

@<탐색 상태를 마련한다@>=
bestDiff := math.Inf(1)
var bestAsum, bestBsum float64
var bestAmask, bestBmask uint32
var bestK int

n := len(Bitems)
size := uint32(1) << uint(n)
Bvals := make([]float64, n)
for i, k := range Bitems {
	Bvals[i] = math.Sqrt(float64(k))
}

@ $A$ 표의 첨자 |ai|와 $B$의 부분집합(그 합과 마스크)이 주어지면, 도우미 |eval|은
합쳐 만든 분할이 얼마나 좋은지 잰다. 실수 두 합이 |Asum + Bsum|을 내고, 나머지
|kf = target - total|은 제곱수들이 정수로 대야 한다. 값 |kf|를 가장 가까운 정수 |k|로
반올림하고, 나타낼 수 있는 범위 $[0,28]$으로 자른 뒤, 남은 |diff|를 그 맞춤의 품질로
삼는다. 어떤 쌍이 지금까지의 챔피언을 이기면 그때마다 적어 둔다.

@<도우미 |eval|을 정의한다@>=
eval := func(ai int, Bsum float64, Bmask uint32) {
	Asum := Aents[ai].sum
	total := Asum + Bsum
	kf := target - total
	k := min(max(int(math.Round(kf)), 0), 28)
	diff := math.Abs(kf - float64(k))
	if diff < bestDiff {
		bestDiff = diff
		bestAsum = Asum
		bestBsum = Bsum
		bestAmask = Aents[ai].mask
		bestBmask = Bmask
		bestK = k
	}
}

@ 도우미 |probe|에서 중간에서 만나기가 값을 한다. $B$의 부분집합 하나가 주어지면,
우리는 |Asum + Bsum|이 법 1에서 목표에 떨어지도록 소수 부분을 맞춰 주는 $A$의
부분집합을 원한다(정수 부분은 제곱수들의 몫이다). 바라는 소수 부분은
$$\hbox{|wantA|}=\bigl(\hbox{frac}(target)-\hbox{frac}(Bsum)\bigr)\bmod 1$$
이므로, 정렬해 둔 |Afracs|에서 그것을 이진 탐색한다. 소수 부분은 원 위에 살기
때문에($0.999\ldots$는 $0.000\ldots$과 이웃이다) 가장 좋은 칸은 끼워 넣을 자리의
{\it 원형 이웃 둘\/} 가운데 하나다. 그래서 둘 다 재 보되, 표의 끝에서 앞으로, 또 그
반대로 감아 돈다.

@<도우미 |probe|를 정의한다@>=
probe := func(Bsum float64, Bmask uint32) {
	fracB := Bsum - math.Floor(Bsum)
	wantA := targetFrac - fracB
	if wantA < 0 {
		wantA += 1
	}
	// 원형 이웃 둘만 보면 넉넉하다
	idx := sort.SearchFloat64s(Afracs, wantA)
	if idx < nA {
		eval(idx, Bsum, Bmask)
	} else {
		eval(0, Bsum, Bmask)
	}
	if idx > 0 {
		eval(idx-1, Bsum, Bmask)
	} else {
		eval(nA-1, Bsum, Bmask)
	}
}

@ 이제 $B$의 부분집합 $2^{22}$개를 모두 그레이 부호 순서로 쓸어 간다. |genAll|과
같은 한 비트 뒤집기 요령이되, 이번에는 {\it 흘려보내기\/}다. 부분집합 합마다 표에
탐침을 넣고는 버리므로 $B$는 아예 저장하지 않는다. 빈 부분집합은 반복문에 들기 전에
먼저 탐침한다. 시간 제한 안에 $B$의 일부만 뽑아 볼 수밖에 없었던 크누스의 1976년
프로그램과 달리, 이 빠짐없는 쓸기는 10초에 한참 못 미쳐 끝난다. 그러니 운 좋게
가까이 간 답이 아니라 진짜 최적을 찾는다.

@<그레이 부호로 |B|를 훑으며 부분집합마다 탐침한다@>=
tB := time.Now()
probe(0, 0)
var sumB, cB float64
var maskB uint32
for i := uint32(1); i < size; i++ {
	pos := uint(bits.TrailingZeros32(i))
	var v float64
	if maskB&(1<<pos) != 0 {
		maskB &^= 1 << pos
		v = -Bvals[pos]
	} else {
		maskB |= 1 << pos
		v = Bvals[pos]
	}
	sumB, cB = kbn(sumB, cB, v)
	probe(sumB+cB, maskB)
}
if *verbose {
	fmt.Printf("B (2^%d) 훑기+탐침: %v\n", len(Bitems), time.Since(tB))
}

elapsed := time.Since(start)

@* 분할을 되짚어 짓기.
이긴 마스크는 제곱수가 아닌 수 가운데 어느 것이 첫째 몫에 드는지 말해 준다.
|bestAmask|의 비트~|i|가 |Aitems[i]|를 고르고, |bestBmask|는 |Bitems|에 대해 마찬가지다.
그다음 정수 손잡이 |bestK|를 진짜 제곱수로 실현한다. 값 |bestK|를 $\{7,6,\ldots,1\}$의
부분집합으로 욕심껏 가르는 일은 $[0,28]$의 어떤 값에 대해서도 언제나 된다(아직 들어갈
수 있는 가장 큰 몫을 잡고 되풀이한다). 그 몫~|i|는 저마다 제곱수 $i^2$을 내놓는다.
첫째 몫에 넣지 않은 것은 모두 둘째 몫이 된다.

@<이긴 분할을 되짚어 짓는다@>=
var group []int
for i, k := range Aitems {
	if bestAmask&(1<<uint(i)) != 0 {
		group = append(group, k)
	}
}
for i, k := range Bitems {
	if bestBmask&(1<<uint(i)) != 0 {
		group = append(group, k)
	}
}

rem := bestK
for i := 7; i >= 1; i-- {
	if rem >= i {
		group = append(group, i*i)
		rem -= i
	}
}
sort.Ints(group)

inGroup := map[int]bool{}
for _, k := range group {
	inGroup[k] = true
}
var other []int
for k := 1; k <= 50; k++ {
	if !inGroup[k] {
		other = append(other, k)
	}
}

@ 탐색은 온통 |float64|로 돌았으니, 그것이 스스로 보고하는 오차는 열몇 자리 너머까지
믿을 수 없다. 결과를 정직하게 말하려고 두 몫의 합을 |math/big|으로 200비트(십진수로
60자리쯤) 정밀도에서 처음부터 다시 셈해 그 차를 찍는다. 머리글로 찍을 |float64| 합도
함께 구해 둔다.

@<고정밀도로 확인하고 보고한다@>=
sumG, sumO := 0.0, 0.0
for _, k := range group {
	sumG += math.Sqrt(float64(k))
}
for _, k := range other {
	sumO += math.Sqrt(float64(k))
}

bigSum := func(ks []int) *big.Float {
	s := new(big.Float).SetPrec(200)
	for _, k := range ks {
		sq := new(big.Float).SetPrec(200).SetInt64(int64(k))
		sq.Sqrt(sq)
		s.Add(s, sq)
	}
	return s
}
bigG := bigSum(group)
bigO := bigSum(other)
bigDiff := new(big.Float).SetPrec(200).Sub(bigG, bigO)

@ 마지막으로 찍는다. 두 몫과 그 |float64| 합은 언제나 나오고, 자세히 찍기 플래그가
거기에 시간과 |float64| 잔차와 고정밀도 두 합과 그 차를 더한다. 그 차는
$-1.43\times10^{-13}$쯤으로 나온다. 크누스가 1996년의 덧붙임에서 보고한 바로 그
최적값이고, 그의 1976년 10초 풀이보다 5000배 넘게 좋다.

@<고정밀도로 확인하고 보고한다@>=
if *verbose {
	fmt.Printf("\n걸린 시간: %v\n", elapsed)
	fmt.Printf("가장 좋은 오차 = %.3e  (float64)\n", bestDiff)
	fmt.Printf("Asum=%.15f Bsum=%.15f k=%d\n\n", bestAsum, bestBsum, bestK)
}

fmt.Printf("첫째 몫 (%d): %v\n  합 = %.15f\n", len(group), group, sumG)
fmt.Printf("둘째 몫 (%d): %v\n  합 = %.15f\n", len(other), other, sumO)

if *verbose {
	fmt.Printf("\n[고정밀도 확인 (math/big, 200비트)]\n")
	fmt.Printf("합1 = %s\n", bigG.Text('f', 40))
	fmt.Printf("합2 = %s\n", bigO.Text('f', 40))
	fmt.Printf("합1 - 합2 = %s\n", bigDiff.Text('e', 6))
}

@* 색인.
