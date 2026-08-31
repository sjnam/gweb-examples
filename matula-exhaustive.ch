이 변경 파일은 크누스의 \.{matula-exhaustive.ch}를 우리 \.{GWEB} 판에 맞춘
것이다. 나무 둘을 받아 한 번 푸는 대신, 마디가 $m$개인 자유 나무와 마디가 $n$개인
자유 나무의 {\it 모든 짝\/}을 낱낱이 푼다. 적용:

    gtangle matula.w matula-exhaustive.ch   (-> 모든 짝을 훑는 matula.go)

자유 나무를 하나도 빠뜨리지 않고 한 번씩만 만들어 내는 일이 이 판의 알맹이다.
TAOCP 연습문제 7.2.1.6--90의 이론을 따라 방향 숲의 정규 층 수열로 트라이를 짓고,
거기서 한중심 나무와 두중심 나무를 차례로 꺼낸다.

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
$$\mplibcode fig_S; \endmplibcode$$
\figcap{나무 $S$. 마디 $19$개다.}
$$\mplibcode fig_T; \endmplibcode$$
\figcap{나무 $T$. 마디 $59$개다. 답은 마지막 장에 있다.}
@y
@ 이 판은 나무 둘을 받는 대신, 마디가 $m$개인 자유 나무 $S$와 마디가 $n$개인
자유 나무 $T$의 모든 짝을 낱낱이 시험한다. 크누스는 {\mc GRACEFUL-TREES}의 나무
만드는 루틴을 손질해 이 판을 지었다고 적었다.

@ 그러니 명령줄에 주는 것은 나무가 아니라 수 둘, $m$과 $n$이다. 이를테면 $m=4$,
$n=6$이라 하면 마디 넷짜리 자유 나무 $2$그루와 마디 여섯짜리 자유 나무 $6$그루를
모두 짝지어 $12$가지를 푼다. 자유 나무는 뿌리도 차례도 없는 나무이므로, 마디
수가 같아도 그루 수는 훨씬 적다. 마디가 $16$개인 자유 나무는 $19320$그루다.
@z

@x
@ 뼈대는 짧다. 명령줄에서 두 나무를 읽어 들이고, 풀고, 알린다.

@c
package main

import (
	"fmt"
	"os"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 처리한다@>@;
	imems, mems = mems, 0
	if m > n {
		fmt.Fprintln(os.Stderr, "마디 수가 m > n이니 답이 없다!")
	} else {
		z = solve(1)
		@<답을 알린다@>@;
	}
	fmt.Fprintf(os.Stderr, "모두 해서 %d+%d mem.\n", imems, mems)
}
@y
@ 뼈대가 조금 길어졌다. 명령줄에서 $m$과 $n$을 읽고, 자유 나무를 죄다 찾아낼
트라이를 둘 지은 다음, $S$와 $T$의 모든 짝에 대해 문제를 풀고 결과를 갈무리한다.

@c
package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 처리한다@>@;
	@<마디 $m$개짜리 자유 나무의 트라이를 짓는다@>@;
	@<마디 $n$개짜리 자유 나무의 트라이를 짓는다@>@;
	imems, mems = mems, 0
	sfam.first()
	@<나무 $S$를 |snode|에 세운다@>@;
	for {
		tfam.first()
		@<나무 $T$를 |tnode|에 세운다@>@;
		for {
			startmems = mems
			z = solve(1)
			@<이 짝의 결과를 갈무리한다@>@;
			if !tfam.next() {
				break
			}
			@<나무 $T$를 |tnode|에 세운다@>@;
		}
		if !sfam.next() {
			break
		}
		@<나무 $S$를 |snode|에 세운다@>@;
	}
	@<끝인사를 한다@>@;
}
@z

@x
@ @<상수@>=
const (
	maxn        = 62       // 입력 방식을 바꾸면 훨씬 키울 수 있다
	maxg        = 2 * maxn // 소녀 수의 상한
	maxt        = maxn * maxg // 이분 그래프 변 수의 상한
	suboverhead = 10       // 함수 부름마다 매기는 mem
)
@y
@ 마디 수의 상한이 확 줄었다. 자유 나무를 모조리 훑는 판이니 $62$는 꿈도 꿀 수
없는 수다. 마디가 $16$개 이하인 자유 나무만 해도 $32508$그루다.

@<상수@>=
const (
	maxn        = 16    // 더 키울 수는 있지만 크게는 못 키운다
	maxtrees    = 32768 // 마디가 $16$개 이하인 자유 나무는 $32508$그루다
	maxmtrees   = 128   // 마디가 $7$개인 방향 나무는 $115$그루다
	maxg        = 2 * maxn // 소녀 수의 상한
	maxt        = maxn * maxg // 이분 그래프 변 수의 상한
	suboverhead = 10       // 함수 부름마다 매기는 mem
)
@z

@x
@ @<전역 변수@>=
var (
	mems  int64 // 메모리를 짚은 횟수
	imems int64 // 그 가운데 입력에 든 것
)
@y
@ @<전역 변수@>=
var (
	mems   int64 // 메모리를 짚은 횟수
	imems  int64 // 그 가운데 트라이를 짓는 데 든 것
	mm, nn int   // 명령줄에서 받은 $m$과 $n$
)
@z

@x
@ @<지역 변수@>=
var d, e, g, k, m, n, p, q, v, z int
@y
@ @<지역 변수@>=
var d, e, k, m, n, p, q, r, s, z int
@z

@x
@ @<명령줄을 처리한다@>=
if len(os.Args) != 3 {
	fmt.Fprintf(os.Stderr, "쓰는 법: %s S의부모들 T의부모들\n", os.Args[0])
	os.Exit(1)
}
sarg, targ = os.Args[1], os.Args[2]
@<나무 $S$를 읽는다@>@;
@<나무 $T$를 읽는다@>@;

@ @<전역 변수@>=
var sarg, targ string // 명령줄에서 받은 두 나무

@* 나무를 담는 그릇.
@y
@ @<명령줄을 처리한다@>=
{
	bad := len(os.Args) != 3
	if !bad {
		var e1, e2 error
		mm, e1 = strconv.Atoi(os.Args[1])
		nn, e2 = strconv.Atoi(os.Args[2])
		bad = e1 != nil || e2 != nil
	}
	if bad {
		fmt.Fprintf(os.Stderr, "쓰는 법: %s m n\n", os.Args[0])
		os.Exit(1)
	}
}
if mm < 3 || mm > nn || nn > maxn {
	fmt.Fprintf(os.Stderr, "미안하다, 나는 2 < m <= n <= %d만 다루도록 맞춰져 있다.\n",
		maxn)
	os.Exit(2)
}
m, n = mm, nn

@* 모든 자유 나무의 트라이.
$m=\lfloor(n-1)/2\rfloor$이라 하자. (이 절에서만 쓰는 $m$이다. 명령줄에서 받은
$S$의 마디 수와는 상관없다.) TAOCP 연습문제 7.2.1.6--90의 이론에 따르면, 마디가
$n$개인 자유 나무는 한중심이거나 두중심이다. 중심이 하나뿐이면 나머지 마디들이
방향 숲을 이루는데, 그 숲에는 크기가 $m$을 넘는 나무가 없다. 중심이 둘이면 두
중심의 아들들이 저마다 크기 $m$의 방향 숲을 이룬다. 두중심인 경우는 $n$이 짝수일
때만 생긴다.

@ 그래서 우리는 크기가 $n$보다 작고 크기 $m$을 넘는 나무를 품지 않는 방향 숲을
모두 표로 만든다. 마디가 $t$개인 방향 숲은 정규 층 수열 $c_1\ldots c_t$로 나타낸다.
여기서 $c_k$는 전위 순회에서 $k$번째 마디의 깊이다. 한 집안에서 형제 부분나무들의
부분 문자열이 사전식으로 커지지 않는 차례로 늘어서면 그 수열을 정규라 한다.

수열 $c_1\ldots c_t$가 크기 $m$을 넘는 나무 없는 방향 숲의 정규 수열이면 그것을
{\it 옳다\/}고 하자. 이를테면 $m=4$라 하자. 수열 $02010101$은 층 수열이 아니어서
옳지 않다. (층 수열에서는 언제나 $c_{k+1}\le c_k+1$이다.) 수열 $01110120$은
정규가 아니어서 옳지 않다($0111<012$). 수열 $01201111$은 $01111$이 크기 $5$인
나무라서 옳지 않다. 수열 $01201120$은 정규가 아니어서 옳지 않다($1<12$). 수열
$01201110$은 옳고 $012012010$도 옳다. 우리가 할 일은 $t<n$인 옳은
$c_1\ldots c_t$를 모두 표로 만드는 것이다.

@ 옳은 수열을 $t=1$부터 $t=2$, \dots, $t=n-1$까지 차례로 만든다. $t$가 정해지면
연습문제 7.2.1.6--90에서처럼 사전식으로 작아지는 차례로 만드는데, 맨 처음 것은
가장 큰 것---곧 순환 수열 $012\ldots(m{-}1)012\ldots(m{-}1)0\ldots$의 앞
$t$자리---이다.

수열 $c_1\ldots c_t$가 옳으면 $t>1$일 때 그 앞자락 $c_1\ldots c_{t-1}$도 옳다.
$c_t>0$일 때 그 사전식 앞 것 $c_1\ldots c_{t-1}(c_t{-}1)$도 옳다. 그러니 옳은
수열들은 트라이를 이룬다.

@ 트라이는 배열 둘로 짓는다. 하나는 |up|, 하나는 |lev|다. 칸~$k$가
$c_1\ldots c_t$를 나타내면 $|lev|[k]=c_t$이고, |up[k]|는 $c_1\ldots c_{t-1}$을
나타내며, $c_t>0$이면 $k+1$이 $c_1\ldots c_{t-1}(c_t{-}1)$을 나타낸다.

크누스는 이 배열을 \.{c}라 불렀다. 우리는 |lev|라 부른다. \GO/에서는 \.{c}가 문자
하나를 받는 매개변수 이름으로 이미 쓰이고 있어 헷갈리기 때문이다.

여기에 부모 포인터 수열 $p_1\ldots p_t$도 함께 셈해 |np|라는 셋째 배열에 담는다.
칸~$k$가 $c_1\ldots c_t$를 나타내면 $|np|[k]=p_t$다. 이를테면 $012110121010$에
맞선 부모 포인터는 $012110454070$이다.

@<전역 변수@>=
var (
	up   [maxtrees]int // 트라이에서의 부모
	down [maxtrees]int // 트라이에서의 맨 왼쪽 아들
	lev  [maxtrees]int // 트라이의 $c_t$ 좌표
	np   [maxtrees]int // 트라이의 $p_t$ 좌표
	ptr  int           // |up|, |lev|, |np|의 첫 빈 칸
	cc   [maxn + 1]int // 지금 보고 있는 층 수열
	pp   [maxn + 1]int // 지금 보고 있는 부모 수열
	start [maxn + 1]int // 크기별 숲이 어디서 시작하는가
)

@ 함수 |maketrie(n)|이 끝나면, $1\le t\le n$에 대해 |start[t]|는 크기가 |t|보다
작으면서 크기가 $\lfloor(n-1)/2\rfloor$를 넘는 나무를 품지 않는 숲의 개수다.

(이 함수는 |n>2|라고 가정한다.)

@<함수들@>=
func maketrie(n int) {
	var i, j, k, l, m, q, t, cstar int
	m = (n - 1) >> 1
	mems++
	start[1], k, ptr = 1, 1, 2 // |up[1]=lev[1]=0|이 첫 수열 $c_1$을 맡는다
	mems += 2
	cc[0], pp[0] = -1, -1 // ``숲보다 한 층 위''
	for t = 1; t < n-1; t++ {
		@<수열 $c_1\ldots c_t$에서 $c_1\ldots c_{t+1}$을 만든다@>@;
	}
	mems += 2
	if start[m+1]-start[m] > maxmtrees {
		fmt.Fprintf(os.Stderr, "maxmtrees를 %d 이상으로 하여 다시 컴파일하라!\n",
			start[m+1]-start[m])
		os.Exit(66)
	}
	mems++
	start[n] = ptr
}

@ 여기 들어설 때 |k=start[t]|다.

|k>start[t]|일 때 칸~$k$의 셈은 칸~$k-1$의 셈과 겹치는 데가 많다. 그러니 다듬을
여지가 꽤 있다. 하지만 오늘은 단순한 쪽을 골랐다고 크누스는 적었다.

@<수열 $c_1\ldots c_t$에서 $c_1\ldots c_{t+1}$을 만든다@>=
mems++
for start[t+1] = ptr; k < start[t+1]; k++ {
	@<칸~|k|의 수열을 |cc|와 |pp|에 펼친다@>@;
	@<수열 $c_1\ldots c_t$ 뒤에 올 수 있는 가장 큰 층 $c^*$를 찾는다@>@;
	mems++
	down[k] = ptr
	@<새 마디의 부모 |q|를 찾는다@>@;
	@<층이 $c^*$인 것부터 $0$인 것까지 트라이 칸을 만든다@>@;
}

@ 트라이를 거슬러 올라가며 수열을 통째로 펼쳐 놓는다. 그러면서 맨 오른쪽 뿌리의
자리를 |q|에 적어 둔다. 그 자리부터 끝까지가 마지막 나무다.

@<칸~|k|의 수열을 |cc|와 |pp|에 펼친다@>=
q = -1
for i, j = t, k; i != 0; i-- {
	mems += 4
	cc[i], pp[i] = lev[j], np[j]
	if cc[i] == 0 && q < 0 {
		q = i
	}
	mems++
	j = up[j]
}

@ 여기서 할 일은 층 수열 $c_1\ldots c_t$ 뒤에 옳게 올 수 있는 가장 큰 층 $c^*$를
알아내는 것이다.

@<수열 $c_1\ldots c_t$ 뒤에 올 수 있는 가장 큰 층 $c^*$를 찾는다@>=
if q+m == t+1 {
	cstar = 0 // 마지막 나무가 이미 마디 |m|개를 채웠다
} else {
	mems++
	l = cc[t]
	cstar = l + 1
	for j = t; l >= 0; l-- {
		@<층~|l|에서 정규인지 따진다@>@;
		mems++
		j = pp[j]
	}
}

@ 이 자리에서 |j|는 |cc[j]=l|인 가장 큰 값이다. 곧 |j|는 층~|l|에 있는 |t|의
조상이다. |j|에게 왼쪽 형제가 있으면, |j|에서 시작하는 부분 문자열이 그 형제에서
시작하는 부분 문자열을 넘지 않도록 필요한 만큼 |cstar|를 줄인다.

@<층~|l|에서 정규인지 따진다@>=
mems++
if cc[j-1] >= l { // 그렇다, 왼쪽 형제가 있다
	for q = j - 1; ; q-- { // 그 부분나무가 어디서 시작하는지 찾는다
		mems++
		if cc[q] <= l {
			break
		}
	}
	for i = 1; j+i <= t; i++ {
		mems += 2
		if cc[q+i] != cc[j+i] {
			break
		}
	}
	@<사전식 차례를 지키도록 |cstar|를 줄인다@>@;
}

@ @<사전식 차례를 지키도록 |cstar|를 줄인다@>=
if j+i > t {
	mems++
	if cstar > cc[q+i] {
		cstar = cc[q+i]
	}
} else if cc[q+i] < cc[j+i] {
	fmt.Fprintln(os.Stderr, "어리둥절하다!") // 앞의 사전식 견줌이 어긋났다
}

@ 새로 붙일 마디는 층~$c^*$에 놓인다. 그 마디의 부모는 층 $c^*-1$에 있는 |t|의
조상이니, |pp|를 그만큼 거슬러 올라가면 만난다.

@<새 마디의 부모 |q|를 찾는다@>=
mems++
q = t
for j = cc[t] - cstar; j >= 0; j-- {
	mems++
	q = pp[q]
}

@ @<층이 $c^*$인 것부터 $0$인 것까지 트라이 칸을 만든다@>=
for j = cstar; j >= 0; j-- {
	mems += 4
	up[ptr], lev[ptr], np[ptr] = k, j, q
	q = pp[q]
	ptr++
}

@* 나무 한 그루씩 꺼내기.
트라이가 다 되었으니 이제 마디가 |size|개인 자유 나무를 하나씩 꺼내 쓸 차례다.
$S$ 쪽과 $T$ 쪽이 하는 일이 똑같으므로---쓰는 트라이와 마디 수만 다르다---둘을
|family| 하나로 묶었다. 크누스는 이 대목을 $S$용과 $T$용으로 두 벌 적어 두었다.

밭 |par|가 지금 꺼내 놓은 나무다. 뿌리는 $0$이고 마디~$k$의 부모가 |par[k]|다
($1\le k<|size|$). 밭 |upar|에는 |par|를 채우며 트라이의 어디를 지나왔는지를
적어 둔다. 다음 나무로 옮겨 갈 때 바뀌는 것은 대개 끝자락뿐이라, 이미 지나온
자리를 만나면 그 위는 손댈 것이 없기 때문이다.

@<자료형@>=
type family struct {
	size                       int            // 나무의 마디 수
	up, np                     *[maxtrees]int // 이 나무들이 쓰는 트라이
	start, stop                int            // 한중심 나무가 놓인 칸
	shortstart, shortstop      int            // 두중심 반쪽이 놓인 칸
	phase, step, stepx, serial int            // 돌림을 다스리는 것들
	par, upar                  [maxn + 1]int  // 지금 나무의 부모들과 지나온 자리
}

@ @<전역 변수@>=
var (
	sfam, tfam family        // 나무 $S$와 $T$를 꺼내는 곳
	mup, mp    [maxtrees]int // $m$마디 나무를 위한 |up|과 |np|의 사본
)

@ 트라이는 $m$ 쪽을 먼저 짓고 $n$ 쪽을 나중에 짓는다. 둘째 |maketrie|가 |up|과
|np|를 덮어쓰므로 첫째 것은 |mup|과 |mp|에 베껴 둔다.

@<마디 $m$개짜리 자유 나무의 트라이를 짓는다@>=
maketrie(m)
mems++
for k = 1; k < start[m]; k++ {
	mems += 4
	mup[k], mp[k] = up[k], np[k]
}
sfam.size, sfam.up, sfam.np = m, &mup, &mp
mems += 2
sfam.start, sfam.stop = start[m-1], start[m]
if m&1 == 0 {
	mems += 2
	sfam.shortstart, sfam.shortstop = start[(m>>1)-1], start[m>>1]
}

@ @<마디 $n$개짜리 자유 나무의 트라이를 짓는다@>=
maketrie(n)
tfam.size, tfam.up, tfam.np = n, &up, &np
mems += 2
tfam.start, tfam.stop = start[n-1], start[n]
if n&1 == 0 {
	mems += 2
	tfam.shortstart, tfam.shortstop = start[(n>>1)-1], start[n>>1]
}

@ 트라이 칸 |j0|에서 거슬러 올라가며 |par[k0]|, |par[k0-1]|, \dots를 |kstop|보다
큰 자리까지 채운다. 두중심 나무의 오른쪽 반은 마디 번호가 |off|만큼 밀려 있다.

@<함수들@>=
func (a *family) fill(k0, kstop, j0, off int) {
	for k, j := k0, j0; k > kstop; k-- {
		mems += 4
		a.par[k] = a.np[j] + off
		j = a.up[j]
		a.upar[k] = j
	}
}

@ 이쪽은 이미 지나온 자리를 만나면 멈춘다.

@<함수들@>=
func (a *family) refill(k0, j0, off int) {
	for k, j := k0, j0; k != 0; k-- {
		mems += 3
		a.par[k] = a.np[j] + off
		j = a.up[j]
		mems++
		if j == a.upar[k] {
			break // 여기는 이미 다녀갔다
		}
		mems++
		a.upar[k] = j
	}
}

@ 첫 나무는 한중심 구간의 첫 칸에서 나온다.

@<함수들@>=
func (a *family) first() {
	a.phase, a.step, a.serial = 0, a.start, 0
	a.fill(a.size-1, 0, a.step, 0)
}

@ 다음 나무로 넘어간다. 더 없으면 |false|를 돌려준다. 한중심 나무를 다 쓰고 나면
마디 수가 짝수일 때에 한해 두중심 나무로 넘어간다.

@<함수들@>=
func (a *family) next() bool {
	a.serial++
	if a.phase != 0 {
		@<두중심 나무를 한 걸음 옮긴다. 다 했으면 |false|@>@;
	} else {
		a.step++
		switch {
		case a.step < a.stop:
			a.refill(a.size-1, a.step, 0)
		case a.size&1 != 0:
			return false // 마디 수가 홀수면 두중심 나무는 없다
		default:
			@<첫 두중심 나무를 세운다@>@;
		}
	}
	return true
}

@ 두중심 나무는 크기가 |size/2|인 나무 둘을 겹쳐 돌린다. 왼쪽 반은 |step|이,
오른쪽 반은 |stepx|가 가리키며 |step| $\le$ |stepx|를 지킨다.

@<첫 두중심 나무를 세운다@>=
a.phase, a.step = 1, a.shortstart
a.fill(a.size>>1-1, 0, a.shortstart, 0)
@<|step|에서 시작하는 오른쪽 반을 세운다@>@;

@ @<|step|에서 시작하는 오른쪽 반을 세운다@>=
a.stepx = a.step
a.fill(a.size-1, a.size>>1, a.stepx, a.size>>1)

@ @<두중심 나무를 한 걸음 옮긴다. 다 했으면 |false|@>=
a.stepx++
if a.stepx != a.shortstop {
	a.refill(a.size-1, a.stepx, a.size>>1)
} else {
	a.step++
	if a.step == a.shortstop {
		return false
	}
	a.refill(a.size>>1-1, a.step, 0)
	@<|step|에서 시작하는 오른쪽 반을 세운다@>@;
}

@ 알릴 때는 나무를 부모 포인터 문자열로 되살려 보인다. 원래 프로그램이 명령줄에서
받던 바로 그 꼴이다. 이 함수는 알리는 데만 쓰이므로 mem을 매기지 않는다.

@<함수들@>=
func (a *family) nth(k int) string {
	s := make([]byte, a.size)
	s[0] = '.'
	if a.start+k < a.stop {
		@<한중심 나무 |k|를 적는다@>@;
	} else {
		@<두중심 나무 |k|를 적는다@>@;
	}
	return string(s)
}

@ @<한중심 나무 |k|를 적는다@>=
for j, t := a.size-1, a.start+k; j != 0; j-- {
	s[j] = encode(a.np[t])
	t = a.up[t]
}

@ 두중심 나무의 번호 |k|는 왼쪽 반과 오른쪽 반의 짝 $(i,i+k')$을 삼각수 꼴로
늘어놓은 것이다. 그 짝을 되찾아 왼쪽 반, 가운데 마디, 오른쪽 반의 차례로 적는다.

@<두중심 나무 |k|를 적는다@>=
h := a.size >> 1
d := a.shortstop - a.shortstart
k -= a.stop - a.start
i := 0
for k >= d {
	k -= d
	i++
	d--
}
for j, t := h-1, a.shortstart+i; j != 0; j-- {
	s[j] = encode(a.np[t])
	t = a.up[t]
}
s[h] = '0'
for j, t := a.size-1, a.shortstart+i+k; j > h; j-- {
	s[j] = encode(h + a.np[t])
	t = a.up[t]
}

@* 나무를 담는 그릇.
@z

@x
@ @<전역 변수@>=
var (
	snode [maxn]node // $S$의 마디 $m$개
	tnode [maxn]node // $T$의 마디 $n$개
)
@y
@ 배열을 한 칸씩 늘렸다. 뒤에서 $S$의 뿌리를 잎으로 옮길 때 마디~$0$을 잠깐
마디~$m$ 자리에 놓아 두는데, $m$이 |maxn|과 같을 수 있기 때문이다. \CEE/에서는
배열 밖을 짚어도 대개 아무 일 없이 지나가지만 \GO/는 그 자리에서 죽는다.

@<전역 변수@>=
var (
	snode [maxn + 1]node // $S$의 마디 $m$개
	tnode [maxn + 1]node // $T$의 마디 $n$개
)
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
@ 이제 |par| 배열이 가리키는 자유 나무를 실제 자료 구조로 세울 차례다. $S$ 쪽은
Matula의 알고리즘이 뿌리를 잎으로 두기를 바라므로 손이 조금 더 간다. 먼저 |tnode|에
자유 나무를 세우고, 잎 하나를 뿌리 자리로 옮긴 다음, |tnode|를 |snode|로 베끼며
번호를 다시 매긴다. (크누스는 이 대목을 {\mc MATULA-BIG}에서 가져왔다고 적었다.)

@<나무 $S$를 |snode|에 세운다@>=
mems++
tnode[0].child, tnode[0].sib = 0, 0
for k = 1; k < m; k++ {
	mems++
	p = sfam.par[k]
	mems += 2
	q, tnode[p].child = tnode[p].child, k
	mems++
	tnode[k].child, tnode[k].sib = 0, q
}
@<|tnode|의 뿌리를 잎으로 만든다@>@;
@<|tnode|를 |snode|로 베끼며 번호를 다시 매긴다@>@;

@ 크누스는 이 대목을 두고 ``이것이 이렇게 어려울 줄은 몰랐다. 내가 무엇을
놓쳤나? 자료 구조학의 아기자기한 연습문제다''라고 적었다.

마디~$0$은 마디~|m| 자리로 옮겨 간다. 그래야 남의 아들이나 형제가 될 수 있다.

@<|tnode|의 뿌리를 잎으로 만든다@>=
mems += 2
r, p = m, tnode[0].child
tnode[r].child, tnode[r].sib = p, 0
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

@ @<|tnode|를 |snode|로 베끼며 번호를 다시 매긴다@>=
gg = 0
for k = 0; k < m; k++ {
	mems++
	snode[k].child, snode[k].sib = 0, 0
}
copyremap(p)
if gg != m {
	fmt.Fprintln(os.Stderr, "아주 어리둥절하다!")
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

@ $T$ 쪽은 |tnode|에 그대로 세우면 된다. 다만 나무를 갈아 끼울 때마다 호를 다시
매겨야 하고, 차수별 목록의 머리 |head|도 미리 비워 두어야 한다. 나무를 한 번만
읽던 판에서는 그럴 까닭이 없었다.

@<나무 $T$를 |tnode|에 세운다@>=
mems++
tnode[0].child, tnode[0].sib = 0, 0
for k = 1; k < n; k++ {
	mems++
	head[k] = 0
	mems++
	p = tfam.par[k]
	mems += 2
	q, tnode[p].child = tnode[p].child, k
	mems++
	tnode[k].child, tnode[k].sib = 0, q
}
@<호에 번호를 매긴다@>@;
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
	fmt.Fprintf(os.Stderr, " ...소년 %d명을 소녀 %d명에게 짝지운다 (%s,%s)\n",
		m, n, sfam.nth(sfam.serial), tfam.nth(tfam.serial))
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

@ 마지막 할 일은 |sol|과 |solx|와 |soly|에 든 정보를 거두어, 찾아낸 심기 하나에서
$S$의 마디 $0$, $1$, \dots이 어디로 갔는지를 보여 주는 것이다.

그러려면 $S$의 뿌리 아닌 꼭짓점~|p|마다 |solarc[p]|라는 호를 하나씩 정해 준다.
그 호가 $v$에서 $u$로 간다면, 심기가 |p|를 $v$로, |p|의 부모를 $u$로 보낸다는
뜻이다. 이 호들은 |sol[1][e]=1|인 가장 오른쪽 |e|에서 시작해 위에서 아래로 정한다.

@<답 하나를 인쇄한다@>=
for e = emax - 1; ; e-- {
	mems++
	if sol[1][e] != 0 {
		break
	}
}
mems += 2
solarc[1] = e
for p = 1; p < m; p++ {
	mems++
	if snode[p].child != 0 {
		@<마디 |p|의 아들들에게 호를 나누어 준다@>@;
	}
}
@<찾아낸 심기를 적는다@>@;

@ @<마디 |p|의 아들들에게 호를 나누어 준다@>=
for q = snode[p].child; q != 0; mems, q = mems+1, snode[q].sib {
	mems++
	mate[q] = 0
}
mems += 2
z = solarc[p]
v = vert[z]
mems++
e, n = tnode[v].arc, tnode[v].deg
for g = e; g < e+n; g++ {
	mems += 3
	q = solx[p][g]
	imate[g] = q
	mate[q] = g
}
@<|imate[z]=0|이 되는 짝짓기를 찾는다@>@;
@<아들마다 호를 정해 준다@>@;

@ @<아들마다 호를 정해 준다@>=
mems++
g = e
for q = snode[p].child; q != 0; mems, q = mems+1, snode[q].sib {
	mems++
	if mate[q] != 0 {
		mems += 2
		solarc[q] = dual[mate[q]]
	} else {
		@<아무 데나 맞는 소년에게 짝을 고른다@>@;
	}
}

@ @<아무 데나 맞는 소년에게 짝을 고른다@>=
for {
	if g != z {
		mems++
		if imate[g] == 0 {
			break
		}
	}
	g++
}
mems += 2
solarc[q] = dual[g]
g++

@ 끝맺는 방식이 제법 귀엽다. {\it 증대하지 않는\/} 경로의 이론을 쓴다. (그 이론은
HK 알고리즘의 마지막, 완성되지 못한 dag의 짜임새에서 나오는데, 우리는 그 알맹이를
|soly[p]|에 갈무리해 두었다.)

@<|imate[z]=0|이 되는 짝짓기를 찾는다@>=
for k, g = 0, z; ; k = q {
	mems++
	q = imate[g]
	if q == 0 {
		break
	}
	mems++
	imate[g] = k
	mems++
	g = soly[p][g]
	mems++
	mate[q] = g
}
mems++
imate[g] = k

@ @<찾아낸 심기를 적는다@>=
mems += 2
fmt.Printf("%c", encode(uert[solarc[1]]))
for p = 1; p < m; p++ {
	mems += 2
	fmt.Printf(" %c", encode(vert[solarc[p]]))
}
fmt.Println()

@ @<전역 변수@>=
var solarc [maxn]int // 답에서 열쇠가 되는 호들
@y
@ 이 판은 심기 하나하나를 찍지 않는다. 짝이 너무 많기 때문이다. |z|가 양수인지만
보고 세어 둘 뿐이다. 그래서 원본에 있던 인쇄 대목---|solarc|를 정하고 |solx|와
|soly|를 거슬러 읽어 $S$의 마디가 저마다 어디로 갔는지 보이는 부분---은 여기
없다. 그 값들을 셈해 두기는 하지만 아무도 들여다보지 않는다.
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
$$\mplibcode fig_ST; \endmplibcode$$
\figcap{$T$ 안에 자리 잡은 $S$. 굵게 그린 부분이 심긴 자리다.}

@ 이 그림에는 사연이 있다. 처음에 나는 이것을 연습문제~213의 답(fasc7a의 2024년
12월 5일 판, 205쪽)에 실린 그림에서 그대로 옮겨 왔다. 그런데 프로그램이 찍는 답과
견주어 보니 마디 열아홉 가운데 아홉이 어긋났다. 크누스의 그림은 마디~\.{4}에 달린
두 가지를 서로 바꿔 놓았다. $S$의 길 \.{5}--\.{9}--\.{a}--\.{b}를 $T$의
\.{t}--\.{s}--\.{j}--\.{5}에 놓고, $S$의 \.{c}에 달린 다섯 마디를 $T$의 \.{F}
쪽에 놓은 것이다.

@ 그렇게는 될 수 없다. 호 \.{u}/\.{F}의 부분나무는 마디가 \.{F}, \.{G}, \.{O},
\.{P}, \.{W} 다섯인데, 그 가운데 \.{F}의 이웃은 \.{u}와 \.{G}뿐이다. 아들이 둘인
\.{c}를 거기 앉히려면 이웃이 셋은 있어야 한다. 그래서 그 그림은 모자란 자리를 $T$에
없는 변 \.{F}--\.{O}와 \.{G}--\.{Q}를 그려 메웠다. 진짜 변인 \.{G}--\.{O}와
\.{H}--\.{Q}는 바로 옆에 회색으로 놓여 있다.

@ 더 재미있는 것은, 같은 답의~(f)에 실린 |sol| 행렬이 그 그림을 스스로 반박한다는
점이다. 거기에는 $|sol|[\.{c}][\.{u}/\.{F}]=0$이라고 똑똑히 적혀 있다. 곧 \.{c}에
뿌리 둔 부분나무는 \.{F}에 심을 수 없다는 말이다. 나는 그 행렬 $18\times116$칸을
모두 무식한 되돌이 탐색으로 다시 셈해 보았는데 한 칸도 다르지 않았다. 알고리즘도
프로그램도 옳다. 손으로 그린 그림 하나만 어긋난 것이다.

@ 유일성에 대한 말도 손볼 데가 있다. 답은 ``$\{0,2,3\}$의 자리바꿈을 빼면
유일하다''고 했지만, 낱낱이 세어 보면 심기는 $48$가지다. 자유도가 넷이기 때문이다.
마디 $\{0,2,3\}$의 자리바꿈이 $6$가지, \.{d}와 \.{e}를 맞바꾸는 것이 $2$가지,
\.{c}에 달린 두 다리 \.{f}--\.{g}와 \.{h}--\.{i}를 맞바꾸는 것이 $2$가지, 그리고
\.{b}를 \.{P}에 둘지 \.{W}에 둘지가 $2$가지다. $S$의 자기동형사상으로 나누어도
본질적으로 다른 답이 둘 남는다. 위의 그림은 그 가운데 프로그램이 찍는 것이다.

@ mem 수 $1917+14760$은 크누스의 \CEE/ 원본이 찍는 것과 한 자리도 다르지 않다.
쉼표 연산자가 없는 언어로 옮기면서도 메모리를 짚는 횟수까지 맞춘 셈이다.

맞추는 일이 늘 곧이곧대로였던 것은 아니다. 이를테면 소년을 dag에 들이는 대목에서
원본은 |o|를 \&{\char'46\char'46} 안에 넣어 두었다. 그러니 mem은 두 조건 가운데
{\it 한쪽에만\/} 매겨진다. 처음에 그것을 놓쳐 $119$개를 더 셌다.

@ 무작위로 나무 짝 $1100$개를 지어 원본과 견주었다. 나무 $S$는 마디 $2$개에서 $30$개까지,
$T$는 $62$개까지, 가지 뻗는 정도도 여러 가지로 두었다. 답도, 찍히는 심기도, mem
수도 모두 같았다. 예외는 하나도 없다.

문턱 배열을 고치기 전의 판과 견줄 때는 어긋나는 자리가 하나 있었다. 나무 $T$의 최대
차수가 $S$의 마디 수 이상이면 그쪽이 비워 두던 칸을 우리는 채우므로 입력 mem이
하나 더 들었다. 크누스의 새 판도 그 칸을 채우니, 이제 그 차이마저 없다. 이를테면
$S=\.{.01}$에 별 모양 $T$를 주면 옛 판은 $2043+903$, 새 판과 우리 판은 나란히
$2044+903$이다.

@y
@* 거둬들이기.
짝 하나를 풀 때마다 그 결과와 걸린 시간을 갈무리한다.

@<이 짝의 결과를 갈무리한다@>=
emems = mems - startmems
if z > 0 {
	mems += 2
	msols[sfam.serial]++
	nsols[tfam.serial]++
	totsols++
}
@<달린 시간의 통계를 갱신한다@>@;

@ 짝 하나를 푸는 데 든 mem의 평균과 분산과 최댓값을 Welford의 방법으로 간수한다.
{\sl 준수치적 알고리즘\/} 4.2.2--(16)을 보라.

@<달린 시간의 통계를 갱신한다@>=
samp += 1.0
if emems > ememsmax {
	ememsmax, shardest, thardest = emems, sfam.serial, tfam.serial
}
del := float64(emems) - ememsmean
ememsmean += del / samp
ememsvar += del * (float64(emems) - ememsmean)

@ @<전역 변수@>=
var (
	startmems                 int64   // 이 짝을 풀기 시작할 때의 mem
	emems, ememsmax           int64   // 이 짝에 든 mem과 그 최댓값
	shardest, thardest        int     // 가장 힘들었던 짝
	ememsmean, ememsvar, samp float64 // Welford의 셋
	msols, nsols              [maxtrees]int
	totsols                   int64 // 심을 수 있었던 짝의 수
	record                    int   // 여태 만난 가장 큰 짝짓기 문제
)

@ 마지막으로 무엇을 보았는지 알린다.

@<끝인사를 한다@>=
fmt.Printf("마디 %d개짜리 나무 %d그루와 마디 %d개짜리 나무 %d그루, 모두 %.6g가지를 살펴보았다.\n",
	m, sfam.serial, n, tfam.serial, samp)
fmt.Printf("그 가운데 S를 T에 심을 수 있는 것은 %d가지였다.\n", totsols)
@<mem으로 잰 달린 시간을 알린다@>@;
fmt.Printf("가장 힘든 짝은 %d mem이 들었고 S=%s, T=%s이었다.\n",
	ememsmax, sfam.nth(shardest), tfam.nth(thardest))
@<$S$와 $T$의 양 끝을 알린다@>@;
fmt.Printf("이 셈에 모두 해서 %d+%d mem이 들었다.\n", imems, mems)

@ 붙는 것은 표준 오차다. \CEE/의 \.{\%g}는 유효숫자 여섯 자리를 쓰고 뒤따르는
$0$을 떼어 낸다. \GO/의 \.{\%g}는 값을 되살릴 수 있는 가장 짧은 꼴을 쓰므로 그대로
두면 자릿수가 달라진다. 그래서 \.{\%.6g}라 적어 원본과 같은 꼴로 맞추었다.

@<mem으로 잰 달린 시간을 알린다@>=
errbar := 0.0
if ememsvar != 0 {
	errbar = math.Sqrt(ememsvar / (samp * (samp - 1.0)))
}
fmt.Printf("잰 달린 시간은 %.6g +- %.6g mem이었다.\n", ememsmean, errbar)

@ 나무 $S$ 하나가 몇 그루의 $T$에 심기는지, 그 수가 여태 본 것 가운데 가장 크거나
가장 작을 때마다 그 나무를 찍는다. 들여쓰기가 깊은 쪽이 큰 쪽이다. $T$ 쪽도
마찬가지로, $T$ 하나에 심을 수 있는 $S$가 몇 그루인지를 본다.

@<$S$와 $T$의 양 끝을 알린다@>=
fmt.Println("S를 심을 수 있는 T의 수가 양 끝인 것들:")
for k, p, q = 0, 0, tfam.serial; k < sfam.serial; k++ {
	if msols[k] >= p {
		p = msols[k]
		fmt.Printf("   %s:%d\n", sfam.nth(k), p)
	}
	if msols[k] <= q {
		q = msols[k]
		fmt.Printf(" %s:%d\n", sfam.nth(k), q)
	}
}
fmt.Println("T에 심을 수 있는 S의 수가 양 끝인 것들:")
for k, p, q = 0, 0, sfam.serial; k < tfam.serial; k++ {
	if nsols[k] >= p {
		p = nsols[k]
		fmt.Printf("   %s:%d\n", tfam.nth(k), p)
	}
	if nsols[k] <= q {
		q = nsols[k]
		fmt.Printf(" %s:%d\n", tfam.nth(k), q)
	}
}

@* 돌려 보기.
돌리는 법은 이렇다.
$$\vbox{\halign{\tt#\hfil\cr
go run matula.go 4 6\cr}}$$
그러면 이렇게 답한다.
$$\vbox{\halign{\tt#\hfil\cr
\ ...소년 1명을 소녀 2명에게 짝지운다 (.002,.01030)\cr
\ ...소년 1명을 소녀 3명에게 짝지운다 (.002,.01030)\cr
\ ...소년 1명을 소녀 4명에게 짝지운다 (.002,.01000)\cr
마디 4개짜리 나무 2그루와 마디 6개짜리 나무 6그루, 모두 12가지를 살펴보았다.\cr
그 가운데 S를 T에 심을 수 있는 것은 10가지였다.\cr
잰 달린 시간은 187 +- 30.7349 mem이었다.\cr
가장 힘든 짝은 376 mem이 들었고 S=.002, T=.01030이었다.\cr
S를 심을 수 있는 T의 수가 양 끝인 것들:\cr
\ \ \ .000:5\cr
\ .000:5\cr
\ \ \ .002:5\cr
\ .002:5\cr
T에 심을 수 있는 S의 수가 양 끝인 것들:\cr
\ \ \ .01030:2\cr
\ .01030:2\cr
\ \ \ .01000:2\cr
\ .01000:2\cr
\ .00000:1\cr
\ .01034:1\cr
\ \ \ .01033:2\cr
\ \ \ .00033:2\cr
이 셈에 모두 해서 276+4839 mem이 들었다.\cr}}$$

@ 나무는 원래 프로그램이 명령줄에서 받던 부모 포인터 문자열로 보인다. 마디가 넷인
자유 나무는 \.{.000}(별)과 \.{.002}(길) 둘뿐이고, 마디가 여섯인 것은 여섯 그루다.
그 $2\times6=12$가지를 모두 풀어 $10$가지에서 $S$를 $T$에 심을 수 있었다.

앞의 세 줄은 짝짓기 문제가 여태보다 커질 때마다 나오는 것으로, 표준 오류로
간다. 나머지는 표준 출력으로 간다.

@ 양 끝을 보이는 대목은 여태 본 것 가운데 최고나 최저를 만날 때마다 한 줄씩
찍으므로 같은 나무가 두 번 나오기도 한다. 들여쓰기가 깊은 쪽이 최고, 얕은 쪽이
최저다. 위의 예에서 마디 여섯짜리 나무 \.{.00000}(별)에는 마디 넷짜리 나무가
하나밖에 못 들어가고, \.{.01030}이나 \.{.01033}에는 둘 다 들어간다.

@ 크누스의 \CEE/ 원본과 견주었다. $3\le m\le n\le16$인 짝 가운데 나무 그루 수의
곱이 $200000$ 이하인 것을 모두, 곧 짝 $79$가지를 돌렸다. 표준 출력도 표준
오류도 종료 부호도 다르지 않았고, 찍히는 나무와 mem 수까지 한 자리도 어긋나지
않았다. 이를테면 $m=8$, $n=8$은 양쪽 모두 $2407+426125$ mem이다.

@ 이 판에는 손댈 곳이 몇 있었다. 원본은 $S$용과 $T$용으로 나무를 꺼내는 코드를
두 벌 적어 두었는데, 우리는 |family| 하나로 묶었다. 트라이와 마디 수만 다르고 하는
일은 똑같기 때문이다. 부모 포인터 문자열을 만드는 \.{make\_sstring}과 \.{make\_tstring}도
같은 까닭으로 |nth| 하나가 되었다.

배열 |snode|와 |tnode|는 한 칸씩 늘렸다. 원본은 $m$이 |maxn|과 같을 때 배열 밖을
짚는데, \CEE/에서는 대개 아무 일 없이 지나가지만 \GO/는 그 자리에서 죽는다.

그리고 크누스가 \.{c}라 부른 트라이 배열은 |lev|가 되었다. \GO/에서는 \.{c}가 이미
글자 하나를 받는 매개변수 이름으로 쓰이고 있기 때문이다.
@z

