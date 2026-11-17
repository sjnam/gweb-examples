\input kotexgweb
@i ../types.w
\datethis

\def\title{파이프 오르간의 소리}

@s Int int

@* 들어가며.
커누스와 그의 부인은 집에 파이프 오르간을 두고 있다. 나는 2014년 10월 23일에
커누스의 집을 찾아간 적이 있는데, 거실을 채운 그 웅장한 오르간을 보고 깜짝 놀랐다.
그러니 {\sl The Art of Computer Programming\/}, 4B권의 연습문제 7.2.2--79에서 그
오르간을 다시 만났을 때 반가울 수밖에 없었다.
@^Knuth, Donald Ervin@>

문제는 이렇다. 오르간에는 파이프가 812개 있고, 파이프마다 울리거나 잠자코 있으니
소리는 $2^{812}$가지가 날 수 있다. 그런데 파이프를 다루는 것은 여느 오르간
콘솔이다. 손과 발로 누르는 건반과 페달이 $56+56+32=144$개, 건반과 파이프의 이음을
정하는 켬·끔 스위치가 20개다. 그러니 실제로 낼 수 있는 소리는 많아야
$2^{164}$가지다. 파이프 $n$개가 울리는 소리 가운데 낼 수 있는 것의 개수를 $Q_n$이라
할 때, 작은 $n$에 대해 $Q_n$을 정확히 구하라는 것이 문제다.

커누스는 해답에서 물음 (a)부터 (h)까지 답하고, 끝에 생성함수
$$Q(z)=1+700z+173010z^2+\cdots+12z^{811}+z^{812}$$
을 적었다. 나는 이 해답을 하나하나 따져 보다가 두 곳이 틀렸음을 알았다. 하나는
물음 (g)의 답 $Q_{811}=12$로, 바른 값은 8이다. 다른 하나는 페달의 생성함수에 쓰인
함수 $h(w,z)$의 괄호다. 2026년 11월 18일에 이 둘을 커누스에게 알렸다.

@ 이 프로그램은 그 보고의 근거다. 해답을 쓰지 않고 소리를 처음부터 다시 세어,
책에 적힌 수와 하나하나 견준다. 세는 방법은 서로 기대지 않는 세 가지다.

\smallskip
\item{1.} 파이프 하나만 빠진 소리는 오르간 전체를 문제의 공식 그대로 따져 찾는다.
커플러까지 넣는다.
\item{2.} 파이프가 몇 개 안 되는 작은 소리는 모두 늘어놓는다.
\item{3.} 크기마다 모든 소리의 개수는 블록 위의 동적 계획으로 정확히 센다.
\smallskip

\noindent 그다음에 해답의 생성함수를 공식대로 셈해 마지막 셈과 견준다.

@c
package main

import (
	"fmt"
	"math/big"
	"math/bits"
	"strconv"
	"strings"
)

@<상수@>
@<자료형@>
@<함수들@>

func main() {
	@<늘 꺼져 있는 자리를 책의 답 (a)와 견준다@>
	@<파이프 하나만 빠진 소리를 오르간 전체에서 찾는다@>
	@<세 파트를 마련한다@>
	for _, d := range divs {
		@<|d|의 작은 소리를 모두 늘어놓는다@>
		@<|d|의 소리를 블록 위의 동적 계획으로 센다@>
		@<두 셈이 맞는지 본다@>
	}
	@<생성함수를 곱해 $Q(z)$를 얻는다@>
	@<셈한 계수를 책에 적힌 계수와 견준다@>
	@<커누스의 생성함수를 공식대로 셈해 견준다@>
	@<물음 (e)와 (f)를 확인한다@>
}

@* 오르간의 규칙.
건반은 비트 벡터 $s=s_0\ldots s_{55}$(스웰)와 $g=g_0\ldots g_{55}$(그레이트),
페달은 $p=p_0\ldots p_{31}$이고, 스위치는 $c=c_0\ldots c_{19}$다. 파이프는
$r_{i,j}$로 적는데 $0\le i<16$, $0\le j<56$이다. 문제가 정한 규칙은 이렇다.
$$\displaylines{
r_{i,j}=\cases{c_ip_j\lor c_{i+15}p_{j-12},&$i\in\{0,1\}$;\cr
  c_ip_j,&$i=2$;\cr}\qquad
r_{i,j}=\cases{(c_i\lor c_{i+1}[j<12])s^*_j,&$i=3$;\cr
  c_i[j\ge12]s^*_j,&$i\in\{4,8\}$;\cr
  c_is^*_j,&$i\in\{5,6,7\}$;\cr}\cr
r_{i,j}=\cases{(c_i\lor c_{i+1}[j<12])g^*_j,&$i=9$;\cr
  c_i[j\ge12]g^*_j,&$i=10$;\cr
  c_ig^*_j,&$i\in\{11,12\}$;\cr
  (c_{13}\lor c_{14})g^*_j,&$i=13$;\cr
  c_{14}g^*_j,&$i\in\{14,15\}$.\cr}\cr}$$
여기서 $j<0$이거나 $j\ge32$이면 $p_j=0$이고, $s^*_j=s_j\lor c_{17}g_j\lor
c_{18}p_j$, $g^*_j=g_j\lor c_{19}p_j$다. 오르간의 말로 하면 줄 0--2가 페달,
3--8이 스웰, 9--15가 그레이트이고, 스위치 $c_{17}$, $c_{18}$, $c_{19}$는
스웰을 그레이트에, 스웰을 페달에, 그레이트를 페달에 잇는 {\it 커플러\/}다.

@ 건반과 페달 144개에는 번호 $0\le k<144$를 하나씩 붙인다. 건반 $s_j$는 $j$,
건반 $g_j$는 $56+j$, 페달 $p_j$는 $112+j$다. 파이프 $(i,j)$의 자리는
$56i+j$다. 실제로는 없는 파이프의 자리도 있으니 자리는 모두 $16\times56=896$개다.

@<상수@>=
const (
	nkeys  = 144     // 건반과 페달의 수
	nslots = 16 * 56 // 파이프 자리의 수
)

@ 소리는 파이프 자리의 집합이므로 896비트로 담는다.

@<자료형@>=
type Bits [nslots / 64]uint64

@ 함수 |organ|은 스위치 |c|와 눌린 건반 |key|에서 울리는 파이프의 집합을 위의
규칙 그대로 셈한다. 프로그램의 모든 셈은 결국 이 함수를 거친다.

@<함수들@>=
func organ(c uint32, key *[nkeys]bool) (b Bits) {
	C := func(i int) bool { return c>>i&1 == 1 }
	p := func(j int) bool { return 0 <= j && j < 32 && key[112+j] }
	for j := 0; j < 56; j++ {
		ss := key[j] || C(17) && key[56+j] || C(18) && p(j) // $s^*_j$
		gs := key[56+j] || C(19) && p(j)                     // $g^*_j$
		for i := 0; i < 16; i++ {
			var v bool
			@<파이프 $(i,j)$가 울리는지 가려 |v|에 둔다@>
			if v {
				b.set(i, j)
			}
		}
	}
	return
}

@ 규칙의 줄마다 한 갈래다.

@<파이프 $(i,j)$가 울리는지 가려 |v|에 둔다@>=
switch {
case i <= 1:
	v = C(i) && p(j) || C(i+15) && p(j-12)
case i == 2:
	v = C(i) && p(j)
case i == 3 || i == 9:
	v = (C(i) || C(i+1) && j < 12) && (i == 3 && ss || i == 9 && gs)
case i == 4 || i == 8:
	v = C(i) && j >= 12 && ss
case i <= 7:
	v = C(i) && ss
case i == 10:
	v = C(i) && j >= 12 && gs
case i <= 12:
	v = C(i) && gs
case i == 13:
	v = (C(13) || C(14)) && gs
default:
	v = C(14) && gs
}

@ 규칙을 보면 $r_{i,j}$는 $c$를 고정할 때 항마다 건반 변수를 꼭 하나씩 담은 논리합이다.
그러니 여러 건반을 함께 누른 소리는 건반 하나씩 누른 소리의 합집합이다. 이 성질을
되풀이해 쓰므로 건반 하나만 누른 소리를 주는 함수를 둔다.

@<함수들@>=
func single(c uint32, k int) Bits {
	var key [nkeys]bool
	key[k] = true
	return organ(c, &key)
}

@ 비트 집합에는 몇 가지 연산이 있으면 된다.

@<함수들@>=
func (b *Bits) set(i, j int) { x := 56*i + j; b[x>>6] |= 1 << (x & 63) }

func (b Bits) count() (n int) {
	for _, w := range b {
		n += bits.OnesCount64(w)
	}
	return
}

@ 합집합, 부분집합인지 묻기, 그리고 원소를 차례로 늘어놓기다. 늘어놓을 때는
896비트를 한 칸씩 보지 않고 켜진 비트만 따라간다. 낱말 |w|에서 |w&(w-1)|은 가장
낮은 켜진 비트를 끈다. 처음에는 한 칸씩 보았는데, 작은 소리를 늘어놓는 동안 이
함수를 수천만 번 부르므로 프로그램 전체가 다섯 배 넘게 느렸다(35초 대 6초).

@<함수들@>=
func (b Bits) or(o Bits) (r Bits) {
	for t := range b {
		r[t] = b[t] | o[t]
	}
	return
}

func (b Bits) within(o Bits) bool {
	for t := range b {
		if b[t]&^o[t] != 0 {
			return false
		}
	}
	return true
}

func (b Bits) list() (r []int) {
	for t, w := range b {
		for ; w != 0; w &= w - 1 {
			r = append(r, 64*t+bits.TrailingZeros64(w))
		}
	}
	return
}

@ 작은 소리를 맵에 넣을 때는 자리 번호에 1을 더해 10비트씩 이어 붙인 값을 열쇠로
쓴다. 파이프 여섯 개까지 64비트에 들어간다. 빈 소리의 열쇠는 0이다. 조각을 만들지
않으려고 |list|를 거치지 않는다.

@<함수들@>=
func soundID(b Bits) (u uint64) {
	for t, w := range b {
		for ; w != 0; w &= w - 1 {
			u = u<<10 | uint64(64*t+bits.TrailingZeros64(w)+1)
		}
	}
	return
}

@ 결과는 책과 같은지 다른지를 한마디로 찍는다.

@<함수들@>=
func verdict(ok bool) string {
	if ok {
		return "같다"
	}
	return "다르다"
}

@ 이것으로 물음 (a)부터 확인할 수 있다. 스위치와 건반을 모두 켜면 있는 파이프는
모두 울린다. 해답 (a)는 늘 꺼져 있는 자리를 이렇게 적었다. $j\ge44$인 $(0,j)$와 $(1,j)$, $j\ge32$인 $(2,j)$, 그리고
$j<12$인 $(4,j)$, $(8,j)$, $(10,j)$다. 그 자리의 집합이 울리는 파이프의 여집합인지
본다.

@<늘 꺼져 있는 자리를 책의 답 (a)와 견준다@>=
var allKeys [nkeys]bool
for k := range allKeys {
	allKeys[k] = true
}
all := organ(1<<20-1, &allKeys)
var off Bits
for i := 0; i < 16; i++ {
	for j := 0; j < 56; j++ {
		if i <= 1 && j >= 44 || i == 2 && j >= 32 ||
			(i == 4 || i == 8 || i == 10) && j < 12 {
			off.set(i, j)
		}
	}
}
fmt.Printf("(a) 울리는 파이프는 %d개이고, 늘 꺼진 자리는 책과 %s.\n",
	all.count(), verdict(all.count()+off.count() == nslots &&
		all.or(off).count() == nslots))

@* 파이프 하나만 빠진 소리.
해답 (g)는 이렇게 말한다. ``$Q_{811}=12$ sounds lack only one pipe: With all inputs
1 except $p_j$, for $12\le j<24$, only $r_{2,j}$ is 0.'' 그런데 페달은
$p_0\ldots p_{31}$뿐이므로 $j+12\ge32$인 파이프 $(0,j+12)$와 $(1,j+12)$는
$c_{15}p_j$와 $c_{16}p_j$로만 울린다. 그러니 $20\le j<24$에서 $p_j$를 끄면 이 둘도
꺼져 파이프가 셋 빠진다. 이를테면 $p_{20}=0$이면 $(2,20)$, $(0,32)$, $(1,32)$가
빠진다. 바른 범위는 $12\le j<20$이고 $Q_{811}=8$이다.

이것을 손 논증에 기대지 않고 확인하려고 오르간 전체를, 커플러까지 넣어 따진다.
가장 쉬운 길은 설정 $2^{20}$가지와 건반 벡터를 모두 훑는 것이겠지만, 건반 벡터만
$2^{144}$가지다. 두 가지 성질이 길을 줄여 준다.

@ 하나는 단조성이다(물음 (b)). 입력을 늘리면 소리도 늘어나기만 한다. 그러니
설정 $c$에서 건반을 모두 눌러도 파이프가 811개 미만으로 울린다면, 그 $c$로는
811개짜리 소리를 낼 수 없다. 그런 $c$를 먼저 걸러 낸다.

@<파이프 하나만 빠진 소리를 오르간 전체에서 찾는다@>=
var cands []uint32
for c := uint32(0); c < 1<<20; c++ {
	if organ(c, &allKeys).count() >= 811 {
		cands = append(cands, c)
	}
}
@<후보 설정마다 건반 하나씩의 소리를 마련한다@>
var lack []string
for _, x := range all.list() {
	S := all
	S[x>>6] &^= 1 << (x & 63)
	@<소리 |S|를 낼 수 있으면 빠진 자리 |x|를 |lack|에 적는다@>
}
fmt.Printf("(g) 파이프를 811개 이상 울릴 수 있는 설정은 %d가지다.\n", len(cands))
fmt.Printf("    Q_811 = %d (책에는 12): %s 하나가 빠진 소리\n",
	len(lack), strings.Join(lack, " "))

@ 다른 하나는 앞에서 본 합집합 성질이다. 설정 $c$에서 소리 $S$를 낼 수 있는지
알려면, 소리가 $S$ 안에 머무는 건반을 모두 누르면 된다. 그것이 $S$ 안에서 낼 수
있는 가장 큰 소리이므로, $S$를 낼 수 있다는 것은 그 소리가 바로 $S$라는 것과 같다.
마지막 비교는 합집합 성질을 믿지 않고 |organ|으로 다시 셈한다.

@<후보 설정마다 건반 하나씩의 소리를 마련한다@>=
masks := make([][nkeys]Bits, len(cands))
for ci, c := range cands {
	for k := 0; k < nkeys; k++ {
		masks[ci][k] = single(c, k)
	}
}

@ @<소리 |S|를 낼 수 있으면 빠진 자리 |x|를 |lack|에 적는다@>=
for ci, c := range cands {
	var key [nkeys]bool
	for k := range key {
		key[k] = masks[ci][k].within(S)
	}
	if organ(c, &key) == S {
		lack = append(lack, fmt.Sprintf("(%d,%d)", x/56, x%56))
		break
	}
}

@* 세 파트로 나누기.
해답 (c)가 말하듯 커플러는 조수가 건반을 대신 눌러 주는 것으로 흉내 낼 수 있다.
건반 $s_j$와 $g_j$ 대신 $s^*_j$와 $g^*_j$를 누르면 된다. 그러니 커플러를 끄고 셈해도
낼 수 있는 소리는 같고, 그러면 페달, 스웰, 그레이트가 서로 아무것도 나누지 않는다.
파트마다 낼 수 있는 소리의 수를 $P_n$, $S_n$, $G_n$이라 하면 $Q(z)$는 세 생성함수의
곱 $P(z)S(z)G(z)$다.

파트 하나에는 스위치 몇 개, 건반들, 그리고 {\it 블록\/}들이 있다. 블록은 파이프를
나누지 않는 건반의 묶음이다. 스웰과 그레이트에서는 세로줄 $j$ 하나가 한 블록이다.
페달에서는 $p_j$가 세로줄 $j$와 $j+12$를 울리므로, $j$를 12로 나눈 나머지가 같은
페달끼리 한 블록이다. 나는 이것을 {\it 사슬\/}이라 부르겠다. 나머지가 $r<8$인
사슬에는 페달이 셋($p_r$, $p_{r+12}$, $p_{r+24}$), $8\le r<12$인 사슬에는 둘이다.

@ 스위치 설정에는 해답의 번호 $k$를 그대로 쓴다. 페달은
$k=(c_{16}c_{15}c_2c_1c_0)_2$, 스웰은 $k=(c_8c_7c_6c_5c_4c_3)_2$, 그레이트는
$k=(c_{14}c_{13}c_{12}c_{11}c_{10}c_9)_2$다. 필드 |switches|의 $t$번째 원소가
$k$의 비트 $t$에 해당하는 스위치다.

나머지 필드에는 셈한 결과를 담는다. 필드 |limit|은 늘어놓을 작은 소리의 크기
한도, |sounds|는 늘어놓은 소리마다 그것을 내는 가장 작은 $k$, |gf|는 파트의
생성함수, |perK|는 그것을 소리마다 가장 작은 $k$에 따라 나눈 몫이다.

@<자료형@>=
type division struct {
	name     string
	switches []int
	keys     []int
	blocks   [][]int
	limit    int
	sounds   map[uint64]int
	gf       poly
	perK     []poly
}

@ 설정 번호 $k$를 스위치 벡터로 바꾼다.

@<함수들@>=
func (d *division) setting(k int) (c uint32) {
	for t, sw := range d.switches {
		if k>>t&1 == 1 {
			c |= 1 << sw
		}
	}
	return
}

@ 페달은 작은 소리를 여섯 파이프까지, 스웰과 그레이트는 네 파이프까지 늘어놓는다.
더 늘리면 맵이 너무 커진다.

@<세 파트를 마련한다@>=
pedal := &division{name: "P", switches: []int{0, 1, 2, 15, 16}, limit: 6}
for j := 0; j < 32; j++ {
	pedal.keys = append(pedal.keys, 112+j)
}
for r := 0; r < 12; r++ {
	var chain []int
	for j := r; j < 32; j += 12 {
		chain = append(chain, 112+j)
	}
	pedal.blocks = append(pedal.blocks, chain)
}
@<스웰과 그레이트를 마련한다@>
divs := []*division{pedal, swell, great}

@ @<스웰과 그레이트를 마련한다@>=
swell := &division{name: "S", switches: []int{3, 4, 5, 6, 7, 8}, limit: 4}
great := &division{name: "G", switches: []int{9, 10, 11, 12, 13, 14}, limit: 4}
for j := 0; j < 56; j++ {
	swell.keys = append(swell.keys, j)
	swell.blocks = append(swell.blocks, []int{j})
	great.keys = append(great.keys, 56+j)
	great.blocks = append(great.blocks, []int{56 + j})
}

@* 작은 소리 늘어놓기.
첫 번째 셈은 가장 단순하다. 설정 $k$마다 건반 하나씩의 소리를 마련하고, 그 소리들의
합집합 가운데 파이프가 |limit|개 이하인 것을 깊이 우선으로 모두 만든다. 합집합
성질 덕분에 이것이 그 설정에서 낼 수 있는 작은 소리의 전부다. 설정을 $k$가 작은
것부터 훑으므로, 소리가 처음 나타날 때의 $k$가 그 소리를 내는 가장 작은 $k$다.

@<|d|의 작은 소리를 모두 늘어놓는다@>=
d.sounds = map[uint64]int{}
for k := 0; k < 1<<len(d.switches); k++ {
	c := d.setting(k)
	var masks []Bits
	for _, key := range d.keys {
		if m := single(c, key); m.count() > 0 {
			masks = append(masks, m)
		}
	}
	@<|masks|의 합집합 가운데 작은 것을 모두 |d.sounds|에 넣는다@>
}

@ 함수 |grow|는 재귀이므로 함수로 남긴다. 열쇠가 이미 있으면 더 작은 $k$가 먼저
넣은 것이다.

@<|masks|의 합집합 가운데 작은 것을 모두 |d.sounds|에 넣는다@>=
var grow func(start int, u Bits)
grow = func(start int, u Bits) {
	id := soundID(u)
	if _, ok := d.sounds[id]; !ok {
		d.sounds[id] = k
	}
	for t := start; t < len(masks); t++ {
		if v := u.or(masks[t]); v.count() <= d.limit {
			grow(t+1, v)
		}
	}
}
grow(0, Bits{})

@* 블록 위의 동적 계획.
두 번째 셈은 크기마다 모든 소리를 센다. 설정 $k$를 고정하면 블록들은 서로 따로
논다. 블록마다 그 건반들을 어떻게 누르느냐에 따라 {\it 무늬\/}, 곧 그 블록 파이프의
소리가 하나 정해진다. 그러니 소리 $S$를 낼 수 있다는 것은, 어떤 $k$가 있어서
블록마다 $S$의 몫이 그 $k$로 낼 수 있는 무늬라는 것이다.

그래서 블록마다 무늬와 그 무늬를 낼 수 있는 설정의 집합을 표로 만든다. 설정은
32가지나 64가지이므로 집합은 64비트 낱말 하나에 들어간다.

@<|d|의 소리를 블록 위의 동적 계획으로 센다@>=
nset := 1 << len(d.switches)
tabs := make([]map[Bits]uint64, len(d.blocks))
for bi, blk := range d.blocks {
	tabs[bi] = map[Bits]uint64{}
	for k := 0; k < nset; k++ {
		c := d.setting(k)
		for a := 0; a < 1<<len(blk); a++ {
			var key [nkeys]bool
			for t, kk := range blk {
				key[kk] = a>>t&1 == 1
			}
			tabs[bi][organ(c, &key)] |= 1 << k
		}
	}
}
@<블록을 하나씩 거치며 상태를 넓힌다@>
@<남은 상태를 가장 작은 $k$에 따라 모은다@>

@ 상태는 ``아직 가능한 설정의 집합''이다. 상태마다 거기 이르는 부분 소리의 수를
크기별로, 곧 다항식으로 지닌다. 블록 하나를 거칠 때 무늬마다 상태를 그 무늬의 설정
집합과 교차시키고, 다항식은 무늬의 크기만큼 민다. 교집합이 비면 버린다. 처음
상태는 모든 설정이다. \GO/에서 |uint64(1)<<64|는 0이므로 64가지일 때도 |full|은
모든 비트가 켜진 값이 된다.

@<블록을 하나씩 거치며 상태를 넓힌다@>=
full := uint64(1)<<nset - 1
dp := map[uint64]poly{full: unit()}
for _, t := range tabs {
	next := map[uint64]poly{}
	for m, p := range dp {
		for pat, pm := range t {
			m2 := m & pm
			if m2 == 0 {
				continue
			}
			next[m2] = next[m2].addShift(p, pat.count())
		}
	}
	dp = next
}

@ 끝까지 살아남은 상태 하나하나가 서로 다른 소리들을 센다. 그 소리들을 낼 수 있는
설정이 바로 그 상태이므로, 가장 작은 $k$는 상태의 가장 낮은 비트다. 그 $k$마다
따로 모으면 해답의 $P_k(z)$, $S_k(z)$, $G_k(z)$와 견줄 수 있다.

@<남은 상태를 가장 작은 $k$에 따라 모은다@>=
d.gf, d.perK = poly{}, make([]poly, nset)
for m, p := range dp {
	k := bits.TrailingZeros64(m)
	d.gf = d.gf.addShift(p, 0)
	d.perK[k] = d.perK[k].addShift(p, 0)
}

@ 다항식은 계수를 |big.Int|로 지닌 조각이다. 페달의 계수만 해도 $2^{64}$을 훌쩍
넘는다.

@<자료형@>=
type poly []*big.Int // $z^e$의 계수가 |p[e]|

@ 다항식 $1$과 $(1+z^n)^m$을 만든다. 둘째 것은 이항계수로 바로 적는다. 지수 $n$이
0이면 상수 $2^m$이 된다.

@<함수들@>=
func unit() poly { return poly{big.NewInt(1)} }

func onePlus(n, m int) (r poly) {
	for t := 0; t <= m; t++ {
		r = r.addTerm(new(big.Int).Binomial(int64(m), int64(t)), t*n)
	}
	return
}

@ 항 하나 더하기와, 밀어서 더하기다. 둘 다 새 조각을 돌려줄 수 있으니 결과를 다시
받아야 한다.

@<함수들@>=
func (a poly) addTerm(c *big.Int, e int) poly {
	for len(a) <= e {
		a = append(a, new(big.Int))
	}
	a[e].Add(a[e], c)
	return a
}

func (a poly) addShift(b poly, s int) poly {
	for e, c := range b {
		if c.Sign() != 0 {
			a = a.addTerm(c, e+s)
		}
	}
	return a
}

@ 해답의 공식을 셈하려면 $a+s\cdot b$, 곱, 거듭제곱이 있으면 된다.

@<함수들@>=
func (a poly) plus(s int64, b poly) (r poly) {
	r = r.addShift(a, 0)
	for e, c := range b {
		r = r.addTerm(new(big.Int).Mul(big.NewInt(s), c), e)
	}
	return
}

func (a poly) mul(b poly) (r poly) {
	for i, x := range a {
		for j, y := range b {
			if x.Sign() != 0 && y.Sign() != 0 {
				r = r.addTerm(new(big.Int).Mul(x, y), i+j)
			}
		}
	}
	return
}

@ 거듭제곱은 그냥 되풀이해 곱한다. 지수는 기껏해야 8이다.

@<함수들@>=
func (a poly) pow(n int) poly {
	r := unit()
	for ; n > 0; n-- {
		r = r.mul(a)
	}
	return r
}

@ 계수 읽기와 같음 비교는 조각의 길이에 매이지 않게 한다.

@<함수들@>=
func (a poly) coef(e int) *big.Int {
	if e < len(a) {
		return a[e]
	}
	return new(big.Int)
}

func (a poly) equal(b poly) bool {
	for e := 0; e < len(a) || e < len(b); e++ {
		if a.coef(e).Cmp(b.coef(e)) != 0 {
			return false
		}
	}
	return true
}

@ 작은 소리를 늘어놓은 셈과 동적 계획의 셈은 아무것도 나누지 않는다. 크기
|limit| 이하에서 두 셈이 설정 $k$마다 맞는지 본다. 소리의 크기는 열쇠의 비트
길이에서 알 수 있다. 맨 앞 10비트 묶음이 0이 아니기 때문이다.

@<두 셈이 맞는지 본다@>=
nk := 1 << len(d.switches)
small := make([][]int64, nk)
for k := range small {
	small[k] = make([]int64, d.limit+1)
}
for id, k := range d.sounds {
	small[k][(bits.Len64(id)+9)/10]++
}
ok := true
for k := range small {
	for n, c := range small[k] {
		ok = ok && d.perK[k].coef(n).Cmp(big.NewInt(c)) == 0
	}
}
fmt.Printf("%s: 늘어놓은 작은 소리(%d파이프까지)가 동적 계획과 설정마다 %s.\n",
	d.name, d.limit, verdict(ok))

@* 생성함수와 책의 계수.
이제 $Q(z)=P(z)S(z)G(z)$다.

@<생성함수를 곱해 $Q(z)$를 얻는다@>=
P, S, G := pedal.gf, swell.gf, great.gf
Q := P.mul(S).mul(G)

@ 해답에 적힌 계수를 표로 옮긴다. 생성함수마다 끝의 두 항은 ``$\cdots+12z^{374}+
z^{380}$''처럼 적혀 있으니, 그 두 항 사이와 뒤의 계수는 0이라는 뜻이다. 그것도
함께 본다.

@<셈한 계수를 책에 적힌 계수와 견준다@>=
type term struct {
	e int
	c string
}
for _, row := range []struct {
	name  string
	p     poly
	terms []term
}{
	{"P", P, []term{{0, "1"}, {1, "120"}, {2, "2336"}, {3, "22848"},
		{10, "324113168"}, {119, "8"}, {120, "1"}}},
	{"S", S, []term{{0, "1"}, {1, "312"}, {2, "9312"}, {3, "155720"},
		{10, "180657383126"}, {308, "12"}, {312, "1"}}},
	{"G", G, []term{{0, "1"}, {1, "268"}, {2, "8146"}, {3, "139452"},
		{10, "178087336020"}, {374, "12"}, {380, "1"}}},
	@<책에 적힌 $Q(z)$의 항@>
} {
	@<한 생성함수의 계수를 견주어 찍는다@>
}
@<비율 $Q_n/{812\choose n}$을 견준다@>
@<$S_n>G_n$인 범위를 찾는다@>

@ @<책에 적힌 $Q(z)$의 항@>=
{"Q", Q, []term{{0, "1"}, {1, "700"}, {2, "173010"}, {3, "18838948"},
	{4, "1054376915"}, {5, "38386611728"}, {6, "1039287557076"},
	{7, "22560539157160"}, {8, "410723052356833"}, {9, "6457608682396156"},
	{10, "89490036797524716"}, {811, "12"}, {812, "1"}}},

@ 다른 항만 찍는다.

@<한 생성함수의 계수를 견주어 찍는다@>=
var diff []string
for _, t := range row.terms {
	if got := row.p.coef(t.e).String(); got != t.c {
		diff = append(diff, fmt.Sprintf("z^%d의 계수가 책에는 %s, 셈은 %s",
			t.e, t.c, got))
	}
}
last, prev := row.terms[len(row.terms)-1].e, row.terms[len(row.terms)-2].e
for e := prev + 1; e < len(row.p); e++ {
	if e != last && row.p.coef(e).Sign() != 0 {
		diff = append(diff, fmt.Sprintf("z^%d의 계수가 0이 아니다", e))
	}
}
if diff == nil {
	diff = []string{"적힌 항이 모두 맞다"}
}
fmt.Printf("%s(z): %s\n", row.name, strings.Join(diff, "; "))

@ 해답은 $(Q_2/{812\choose2},\ldots,Q_{10}/{812\choose10})\approx(.5, .2, .06,
.01, .003, .0005, .00009, .00002, .000003)$이라고 적었다. 유효숫자 한 자리로
반올림해 견준다.

@<비율 $Q_n/{812\choose n}$을 견준다@>=
book := []string{".5", ".2", ".06", ".01", ".003", ".0005", ".00009", ".00002",
	".000003"}
okr := true
for n := 2; n <= 10; n++ {
	x, _ := new(big.Rat).SetFrac(Q[n], new(big.Int).Binomial(812, int64(n))).Float64()
	got, _ := strconv.ParseFloat(fmt.Sprintf("%.1g", x), 64)
	want, _ := strconv.ParseFloat(book[n-2], 64)
	okr = okr && got == want
}
fmt.Printf("Q_n/C(812,n)의 비율은 책과 %s.\n", verdict(okr))

@ 해답에는 ``Curiously we have $S_n>G_n$ for $1\le n\le107$''라는 말도 있다.

@<$S_n>G_n$인 범위를 찾는다@>=
m := 0
for S.coef(m+1).Cmp(G.coef(m+1)) > 0 {
	m++
}
rel := "="
if S.coef(m+1).Cmp(G.coef(m+1)) < 0 {
	rel = "<"
}
fmt.Printf("S_n > G_n은 1 <= n <= %d에서 성립하고, n = %d에서는 S_n %s G_n이다.\n",
	m, m+1, rel)

@* 커누스의 생성함수.
해답 (h)는 $G_k(z)$, $S_k(z)$, $P_k(z)$를 공식으로 준다. 이를테면 $G_k(z)$는
설정 $k$로 낼 수 있는 소리 가운데 더 작은 번호의 설정으로는 낼 수 없는 것을
센다. 동적 계획의 |perK|가 바로 그것이므로 $k$마다 견줄 수 있다. 먼저 두 파트가 함께 쓰는
$$f(n)=(1+z^n)^{56}-1,\qquad g(m,n)=(1+z^n)^{12}\bigl((1+z^m)^{44}-1\bigr)$$
이다.

@<함수들@>=
func f(n int) poly    { return onePlus(n, 56).plus(-1, unit()) }
func g(m, n int) poly { return onePlus(n, 12).mul(onePlus(m, 44).plus(-1, unit())) }

@ 견주는 틀은 세 파트가 같다. 공식이 셈한 |F|가 |perK[k]|와 다른 $k$를 모은다.
페달은 $h$의 두 꼴로 셈하고, 그 합의 $z^3$과 $z^{10}$ 계수도 찍는다.

@<커누스의 생성함수를 공식대로 셈해 견준다@>=
@<$G_k(z)$를 견준다@>
@<$S_k(z)$를 견준다@>
for _, v := range []struct {
	name string
	h    func(a, b int) poly
}{{"인쇄된 h", hPrinted}, {"고친 h", hFixed}} {
	var bad []string
	total := poly{}
	for k := 0; k < 32; k++ {
		@<책의 $P_k(z)$를 |v.h|로 셈해 |F|와 |kind|에 둔다@>
		total = total.plus(1, F)
		if !F.equal(pedal.perK[k]) {
			bad = append(bad, fmt.Sprintf("%d(%s)", k, kind))
		}
	}
	fmt.Printf("%s: P_k가 다른 k = [%s]; P_3 = %s, P_10 = %s\n", v.name,
		strings.Join(bad, " "), total.coef(3), total.coef(10))
}

@ 그레이트의 공식은 이렇다. 먼저 $G_0(z)=1$이고, $c_{13}c_{14}=1$이면 $G_k(z)=0$이다.
그 밖에는 $c_{10}=0$일 때 $G_k(z)=f(c_9+c_{11}+c_{12}+c_{13}+3c_{14})$,
$c_{10}=1$일 때 $G_k(z)=g(c_9+1+c_{11}+c_{12}+c_{13}+3c_{14},
1+c_{11}+c_{12}+c_{13}+3c_{14})$다.

@<$G_k(z)$를 견준다@>=
var badG []int
for k := 0; k < 64; k++ {
	c9, c10, c11, c12, c13, c14 := k&1, k>>1&1, k>>2&1, k>>3&1, k>>4&1, k>>5&1
	t := c11 + c12 + c13 + 3*c14
	F := unit()
	switch {
	case k == 0:
	case c13 == 1 && c14 == 1:
		F = poly{}
	case c10 == 0:
		F = f(c9 + t)
	default:
		F = g(c9+1+t, 1+t)
	}
	if !F.equal(great.perK[k]) {
		badG = append(badG, k)
	}
}
fmt.Printf("G_k: 공식이 동적 계획과 다른 k = %v\n", badG)

@ 스웰의 공식은 이렇다. 먼저 $S_0(z)=1$, $S_{32}(z)=(1+z)^{44}-1$이다. 그 밖에는
$c_4=c_8=0$일 때 $S_k(z)=f(c_3+c_5+c_6+c_7)$, $c_4+c_8>0$일 때
$S_k(z)=g\bigl(c_3+c_4+c_5+c_6+c_7+c_8,\max(c_3,c_4)+c_5+c_6+c_7\bigr)$다.

@<$S_k(z)$를 견준다@>=
var badS []int
for k := 0; k < 64; k++ {
	c3, c4, c5, c6, c7, c8 := k&1, k>>1&1, k>>2&1, k>>3&1, k>>4&1, k>>5&1
	F := unit()
	switch {
	case k == 0:
	case k == 32:
		F = onePlus(1, 44).plus(-1, unit())
	case c4 == 0 && c8 == 0:
		F = f(c3 + c5 + c6 + c7)
	default:
		F = g(c3+c4+c5+c6+c7+c8, max(c3, c4)+c5+c6+c7)
	}
	if !F.equal(swell.perK[k]) {
		badS = append(badS, k)
	}
}
fmt.Printf("S_k: 공식이 동적 계획과 다른 k = %v\n", badS)

@ 페달이 가장 까다롭다. 해답은 이렇게 적었다.
$$h(w,z)=(1+3wz^2+2w^2z^3+w^2z^4+w^3z^4)^8\bigl((1+2wz^2+w^2z^3)^4-1\bigr).$$
여덟제곱은 긴 사슬 여덟의 몫이고 네제곱은 짧은 사슬 넷의 몫이다. 사슬 하나에서
페달 몇 개를 누르느냐가 $w$의 지수, 울리는 파이프의 묶음이 $z$의 지수로 들어간다.
이를테면 스위치를 다 켜면 $w=z$, $z=z^2$이 되어, 긴 사슬에서 페달 하나만 누른 소리
셋이 $3wz^2=3z^5$, 곧 저마다 파이프 다섯이 된다.

그런데 그러면 $\bigl((\cdots)^4-1\bigr)$은 짧은 사슬 가운데 하나라도 울리는 소리만
남긴다. 스위치를 모두 켜고 $p_0$만 누른 소리 $\{(0,0),(1,0),(2,0),(0,12),(1,12)\}$는
다섯 스위치가 다 있어야 나므로 $P_{31}(z)$에 들어가야 하는데, $h(z,z^2)$는 이것을
세지 않는다. 빠진 것이 빈 소리 하나뿐이도록 하려면 괄호가
$$h(w,z)=(1+3wz^2+2w^2z^3+w^2z^4+w^3z^4)^8(1+2wz^2+w^2z^3)^4-1$$
이어야 한다. 두 꼴을 함께 셈해 본다. 둘 다 $h(z^a,z^b)$를 돌려준다.

@<함수들@>=
func chains(a, b int) (long, short poly) {
	long = unit().addTerm(big.NewInt(3), a+2*b).addTerm(big.NewInt(2), 2*a+3*b).
		addTerm(big.NewInt(1), 2*a+4*b).addTerm(big.NewInt(1), 3*a+4*b)
	short = unit().addTerm(big.NewInt(2), a+2*b).addTerm(big.NewInt(1), 2*a+3*b)
	return
}

func hPrinted(a, b int) poly {
	long, short := chains(a, b)
	return long.pow(8).mul(short.pow(4).plus(-1, unit()))
}

func hFixed(a, b int) poly {
	long, short := chains(a, b)
	return long.pow(8).mul(short.pow(4)).plus(-1, unit())
}

@ 페달의 경우는 해답대로다. 먼저 $P_{31}(z)=h(z,z^2)$이고, $0<k<31$에는 큰
경우가 셋 있다. 스위치가 $c_0c_{15}=c_1c_{16}=0$이면 $c_0+c_1+c_2=0$일 때
$P_k(z)=(1+z^{c_{15}+c_{16}})^{32}-(1+z^{c_{15}+c_{16}})^{20}$, 아닐 때
$P_k(z)=(1+z^{c_0+c_1+c_2+c_{15}+c_{16}})^{32}-1$이다. 그리고 $c_0=c_{15}$,
$c_1=c_{16}$, $c_2=0$이면 $P_k(z)=q(z^{c_0+c_1})$이다. 나머지는 모두
$P_k(z)=h(z^{c_0+c_1+c_2+c_{15}+c_{16}-2},z)$다. 경우의 이름은 결과를 찍을 때
쓴다.

@<책의 $P_k(z)$를 |v.h|로 셈해 |F|와 |kind|에 둔다@>=
c0, c1, c2, c15, c16 := k&1, k>>1&1, k>>2&1, k>>3&1, k>>4&1
e := c15 + c16
F, kind := unit(), "0"
switch {
case k == 0:
case k == 31:
	F, kind = v.h(1, 2), "31"
case c0*c15 == 0 && c1*c16 == 0 && c0+c1+c2 == 0:
	F, kind = onePlus(e, 32).plus(-1, onePlus(e, 20)), "첫째"
case c0*c15 == 0 && c1*c16 == 0:
	F, kind = onePlus(c0+c1+c2+e, 32).plus(-1, unit()), "첫째"
case c0 == c15 && c1 == c16 && c2 == 0:
	@<$q(z^{c_0+c_1})$를 |F|에 둔다@>
	kind = "둘째"
default:
	F, kind = v.h(c0+c1+c2+e-2, 1), "나머지"
}

@ 둘째 경우의 $q$는
$$q(z)=(1+3z^2+2z^3+z^4)^8(1+2z^2+z^3)^4-2(1+2z^2+z^3)^8(1+z^2)^4+(1+z^2)^8$$
이다. 여기에 $z^a$를 넣는다.

@<$q(z^{c_0+c_1})$를 |F|에 둔다@>=
a := c0 + c1
X := unit().addTerm(big.NewInt(3), 2*a).addTerm(big.NewInt(2), 3*a).
	addTerm(big.NewInt(1), 4*a)
Y := unit().addTerm(big.NewInt(2), 2*a).addTerm(big.NewInt(1), 3*a)
Z := onePlus(2*a, 1)
F = X.pow(8).mul(Y.pow(4)).plus(-2, Y.pow(8).mul(Z.pow(4))).plus(1, Z.pow(8))

@* 나머지 두 물음.
작은 소리를 늘어놓은 맵이 있으니 물음 (e)와 (f)도 바로 따질 수 있다. 커플러를 끈 채
셈했으므로 소리를 세 파트로 쪼개 파트마다 맵에 있는지 보면 된다.

물음 (f)의 답은 $Q_1=812-112=700$이다. 줄 14나 15의 파이프는 줄 13 없이 울릴 수
없기 때문이다. 파이프 하나짜리 소리를 세고, 그렇게 울릴 수 없는 파이프가 줄 14와
15의 112개 그대로인지 본다.

@<물음 (e)와 (f)를 확인한다@>=
var alone Bits
for _, d := range divs {
	for id := range d.sounds {
		if id != 0 && id < 1<<10 {
			alone[(id-1)>>6] |= 1 << ((id - 1) & 63)
		}
	}
}
var deep Bits
for j := 0; j < 56; j++ {
	deep.set(14, j)
	deep.set(15, j)
}
fmt.Printf("(f) Q_1 = %d이고, 혼자 울릴 수 없는 파이프는 줄 14와 15라는 것이 책과 %s.\n",
	alone.count(), verdict(alone.or(deep) == all && alone.count()+deep.count() == 812))
@<물음 (e)를 확인한다@>

@ 물음 (e)는 두 파이프 소리 $\{(i,40),(i',50)\}$를 언제 낼 수 있느냐다. 해답은
``$i\in\{2,14,15\}$이거나 $i'\in\{0,1,2,14,15\}$이거나, $i\ne i'$이면서
$3\le i,i'\le8$ 또는 $9\le i,i'\le15$일 때, 그리고 그때만 낼 수 없다''고 한다.
그 $16\times16$가지를 모두 본다.

@<물음 (e)를 확인한다@>=
okE := true
for i := 0; i < 16; i++ {
	for i2 := 0; i2 < 16; i2++ {
		book := !(i == 2 || i >= 14 || i2 <= 2 || i2 >= 14 ||
			i != i2 && (3 <= i && i <= 8 && 3 <= i2 && i2 <= 8 ||
				9 <= i && 9 <= i2))
		@<소리 $\{(i,40),(i2,50)\}$를 낼 수 있는지 |can|에 둔다@>
		okE = okE && can == book
	}
}
fmt.Printf("(e) 256가지 쌍의 판정이 책과 %s.\n", verdict(okE))

@ 파이프의 줄 번호로 파트가 갈린다.

@<소리 $\{(i,40),(i2,50)\}$를 낼 수 있는지 |can|에 둔다@>=
can := true
for t, d := range divs {
	var part Bits
	for _, x := range [][2]int{{i, 40}, {i2, 50}} {
		if x[0] >= []int{0, 3, 9}[t] && x[0] < []int{3, 9, 16}[t] {
			part.set(x[0], x[1])
		}
	}
	if _, ok := d.sounds[soundID(part)]; !ok {
		can = false
	}
}

@* 맺으며.
내 맥에서 프로그램은 6초쯤 돌고 다음을 알려 준다.

\smallskip
\item{$\bullet$} 울리는 파이프는 812개이고, 해답 (a), (e), (f)는 맞다. 물음 (e)는
256쌍을 모두 보았다.
\item{$\bullet$} 파이프를 811개 이상 울릴 수 있는 설정은 $2^{20}$가지 가운데
16가지다. 파이프 하나만 빠진 소리는 $(2,12)$부터 $(2,19)$까지 하나가 빠진 8가지뿐이다.
그러니 $Q_{811}=8$이고, $Q(z)$의 끝은 $8z^{811}+z^{812}$여야 한다.
\item{$\bullet$} 작은 소리를 늘어놓은 셈과 동적 계획은 세 파트 모두 설정마다 맞는다.
\item{$\bullet$} 해답에 적힌 $P(z)$, $S(z)$, $G(z)$의 계수, $Q_0$부터 $Q_{10}$까지,
비율 $Q_n/{812\choose n}$, 그리고 $1\le n\le107$에서 $S_n>G_n$이라는 말은 모두 맞다.
그다음 $n=108$에서는 $S_{108}<G_{108}$이다. 틀린 것은 $12z^{811}$ 하나다.
\item{$\bullet$} 해답의 $G_k(z)$와 $S_k(z)$는 64가지 $k$ 모두에서 맞다.
\item{$\bullet$} 인쇄된 $h$로 셈하면 $P_k(z)$가 $k=31$과 ``나머지'' 경우의 열 가지
$k$에서 어긋나고, 합은 $22704z^3$과 $324111196z^{10}$을 준다. 괄호를 고친 $h$로는 32가지
$k$가 모두 맞고 인쇄된 $22848z^3$과 $324113168z^{10}$이 나온다.
\smallskip

\noindent 계수는 맞고 공식만 어긋났으니, 커누스의 프로그램은 옳았고 조판하면서
괄호 하나가 잘못 들어간 것으로 보인다. 오르간에 바람이 모자라 811개짜리 소리는 어차피
낼 수 없다고 커누스는 적었다. 그래도 몇 가지인지는 바로 세어 두는 편이 좋겠다.

@* 색인.
