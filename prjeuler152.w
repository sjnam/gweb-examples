\input kotexgweb
@i types.w

\def\title{프로젝트 오일러 152번}
\def\sq#1{{1\over#1^2}}

@* 들어가며. 프로젝트 오일러 152번 문제는 이렇게 묻는다.
\smallskip
{\narrower\narrower\narrower\noindent
서로 다른 정수를 써서 수 $1\over2$을 제곱의 역수들의 합으로 적는 방법은 여럿 있다.
이를테면 수 $\{2,3,4,5,7,12,15,20,28,35\}$를 쓸 수 있다.
$$
{1\over2}=\sq2+\sq3+\sq4+\sq5+\sq7+\sq{12}+\sq{15}+\sq{20}+\sq{28}+\sq{35}
$$
사실 2부터 45까지의 정수만 써도 그렇게 적는 방법이 정확히 셋 있고, 나머지 둘은
다음과 같다.
$$\{2,3,4,6,7,9,10,20,28,35,36,45\},\qquad
  \{2,3,4,6,7,9,12,15,28,30,35,36,45\}.$$

\noindent 그러면 2부터 80까지의 서로 다른 정수를 써서 $1\over2$을 제곱의 역수들의
합으로 적는 방법은 몇 가지인가?
\smallskip
}

\noindent 공식 답은 301이다. 순진하게 찾으려면 $\{2,\ldots,80\}$의 부분집합을 모두
살펴야 하니 $2^{79}$가지가 되어 도무지 될 일이 아니다. 이 프로그램은 탐색 공간을
확 줄여 주는 정수론적 관찰 몇 가지를 써먹은 다음, 중간에서 만나기로 늘어놓는다.

@c
package main

import (
	"flag"
	"fmt"
	"math/bits"
	"slices"
	"strings"
)

@<타입 정의@>
@<함수들@>

func main() {
	all := flag.Bool("all", false, "301가지 답을 저마다 분모 집합으로 찍는다")
	flag.Parse()

	@<줄인 탐색 공간을 짓는다@>
	@<분모를 없앤다@>
	@<중간에서 만난다@>

	if count != 301 {
		panic(fmt.Sprintf("퇴행: %d가 나왔는데 301이어야 한다", count))
	}

	if !*all {
		return
	}

	@<답을 찍는다@>
}

@* 수학으로 가지치기. 핵심적인 관찰은 분모 대부분이 옳은 답에 결코 끼어들 수
없다는 것이다. 7보다 큰 소수 $p$가 어떤 분모에 나타난다고 하자. 분모를 없애고 나면,
$p$의 가장 높은 거듭제곱을 담은 항들의 몫이 그 거듭제곱을 법으로 하여 서로 지워져야
한다.

7보다 큰 소수는 거의 모두 그럴 수 없다. 이 합동 조건이 후보를 거의 다 없앤다. 이
논증을 마치고 나면 소인수가 $\{2,3,5,7\}$에 드는 분모만 살아남는다.

그런 수를 {\sl 7-평활수\/}라 한다. 정수 $2\le n\le 80$ 가운데 그런 값은 정확히
39개다. 여기에 특별한 덩어리 하나가 더 살아남는다.
$$
\sq{13}+\sq{39}+\sq{52}.
$$
이 분모 셋은 언제나 함께 나와야 한다. 그러므로 탐색 항목 하나로 나타낼 수 있다.
그래서 문제 전체가 다음 마흔 개 가운데 고르는 일로 줄어든다.

\item{$\bullet$} 낱낱의 7-평활수 분모 39개
\item{$\bullet$} 덩어리 $\{13,39,52\}$ 하나

이 줄이기가 정수론이 하는 핵심적인 일이다.

@ 후보를 나타내 보자. 탐색 항목 하나는 분모 하나이거나 분모 덩어리다.

@<타입 정의@>=
type item struct {
	denoms []int64
}

@ 유리수 산술을 정수 산술로 바꾸려고 공통분모를 셈한다.

@<함수들@>=
func gcd(a, b int64) int64 {
	for b != 0 {
		a, b = b, a%b
	}
	return a
}
@#
func lcm(a, b int64) int64 {
	return a / gcd(a, b) * b
}

@ 양의 정수는 소인수가 모두 $\{2,3,5,7\}$에 들면 7-평활수다.

@<함수들@>=
func isSevenSmooth(a int64) bool {
	if a <= 0 {
		return false
	}
	for p := range slices.Values([]int64{2, 3, 5, 7}) {
		for a%p == 0 {
			a /= p
		}
	}
	return a == 1
}

@ 앞의 39개 항목은 살아남은 7-평활수 분모다. 마지막 항목은 반드시 함께 와야 하는
덩어리 $\{13,39,52\}$다.

@<줄인 탐색 공간을 짓는다@>=
var items []item
for a := int64(2); a <= 80; a++ {
	if isSevenSmooth(a) {
		items = append(items, item{denoms: []int64{a}})
	}
}
items = append(items, item{denoms: []int64{13, 39, 52}})

@* 정수 부분집합 합으로 바꾸기. 모든 항목에 나오는 모든 분모에 대해
$D = {\rm lcm}(n^2)$이라 하자. 그러면 제곱의 역수는 저마다 정수로 나타낼 수 있다.
$$\sq n = {D/n^2\over D}.$$
그래서 원래의 식이 정수의 부분집합 합 문제가 된다.

@<분모를 없앤다@>=
D := int64(1)
for it := range slices.Values(items) {
	for a := range slices.Values(it.denoms) {
		D = lcm(D, a*a)
	}
}
target := D / 2

vals := make([]int64, len(items))
for i, it := range items {
	for a := range slices.Values(it.denoms) {
		vals[i] += D / (a * a)
	}
}

@* 중간에서 만나기. 가지를 치고도 탐색 대상이 마흔 개 남는다. 곧바로 찾으려면
부분집합을 $2^{40}\approx 10^{12}$번 셈해 보아야 한다. 그러지 말고 항목을 스무 개씩
두 몫으로 가르자. 왼쪽 부분집합마다 그 합을 셈해 두고, 오른쪽 부분집합마다
$\hbox{target} - \hbox{sum}$을 왼쪽 합들 사이에서 찾는다. 그러면 복잡도가
$2^{20}+2^{20}$쯤으로 줄어 얼마든지 해 볼 만해진다.

@ 부분집합을 모두 늘어놓으려면 보통은 부분집합 합을 그때마다 처음부터 다시 셈해야
한다. 그레이 부호가 그 일을 덜어 준다. 그레이 부호에서 이웃한 두 부분집합은 비트
하나만 다르므로, 돌아가는 합을 한 번 더하거나 빼는 것으로 고칠 수 있다. 그래서
부분집합 만들기가 $O(n2^n)$에서 $O(2^n)$으로 준다.

@<함수들@>=
func forEachGray(vals []int64, visit func(mask uint32, sum int64)) {
	var s int64
	visit(0, 0) // 공집합
	for k := 1; k < (1 << uint(len(vals))); k++ {
		b := bits.TrailingZeros(uint(k))
		if (k^(k>>1))&(1<<uint(b)) != 0 {
			s += vals[b]
		} else {
			s -= vals[b]
		}
		visit(uint32(k^(k>>1)), s)
	}
}

@ @<중간에서 만난다@>=
mid := len(vals) / 2
left, right := vals[:mid], vals[mid:]

lm := make(map[int64]int64, 1<<uint(mid))
forEachGray(left, func(_ uint32, s int64) { lm[s]++ })

var count int64
forEachGray(right, func(_ uint32, s int64) { count += lm[target-s] })

fmt.Println(count)

@* 답 되찾기. 세는 단계는 답이 몇 가지인지만 정한다. 플래그 \.{-all}을 주면 답마다
그것을 내는 분모 집합을 실제로 되짚어 짓는다.

@<함수들@>=
func denomsOf(items []item, base int, mask uint32) []int64 {
	var ds []int64
	for i := 0; mask != 0; i, mask = i+1, mask>>1 {
		if mask&1 != 0 {
			ds = append(ds, items[base+i].denoms...)
		}
	}
	return ds
}

@ @<함수들@>=
func findSolutions(items []item, vals []int64, target int64) [][]int64 {
	mid := len(vals) / 2
	left := make(map[int64][]uint32)
	forEachGray(vals[:mid], func(mask uint32, s int64) {
		left[s] = append(left[s], mask)
	})

	var sols [][]int64
	forEachGray(vals[mid:], func(rmask uint32, s int64) {
		for _, lmask := range left[target-s] {
			ds := append(denomsOf(items, 0, lmask), denomsOf(items, mid, rmask)...)
			slices.Sort(ds)
			sols = append(sols, ds)
		}
	})

	slices.SortFunc(sols, slices.Compare) // 사전순으로, 출력이 늘 같도록
	return sols
}

@ @<답을 찍는다@>=
sols := findSolutions(items, vals, target)
for i, ds := range sols {
	terms := make([]string, len(ds))
	for j, d := range ds {
		terms[j] = fmt.Sprintf("1/%d\u00b2", d)
	}
	fmt.Printf("%3d: 1/2 = %s\n", i+1, strings.Join(terms, " + "))
}

@* 색인.
