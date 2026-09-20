\input kotexgweb
@i types.w
@s T int

\def\title{거듭제곱 급수 곁눈질하기}

@* 들어가며.
거듭제곱 급수
$$F(x)=\sum_{i\ge0}F_i\,x^i=F_0+F_1x+F_2x^2+\cdots$$
는 무한한 것이지만, 그 계수 $F_0,F_1,F_2,\ldots$는 한 번에 하나씩 온다. 그리고 급수
위의 재미있는 연산은 거의 모두---합, 곱, 합성, 역수, 함수의 역, 심지어 미분 방정식의
풀이까지---계수를 하나씩 셈할 수 있고, 꼭 보아야 할 것보다 앞을 내다볼 일이 없다.
그것이 바로 {\it 게으른 흐름\/}의 모습이다. 이 꾸러미는 맥일로이(M.~Douglas
McIlroy)의 어여쁜 논문 {\sl Squinting at Power Series\/}({\sl
Software---Practice and Experience\/} {\bf 20} (1990), 661--683)를 따라, 급수마다
{\it 유리수 계수의 흐름\/}으로, 대수적 연산마다 {\it 작은 동시 프로세스\/}로
실현한다.

표현은 맥일로이의 핵심 장치인 {\it 요구 채널\/}이다. 급수는 채널 한 쌍이다.
소비자가 요구 채널로 표를 하나 보내야 비로소 생산자가 다음 계수를 셈해 자료 채널로
보낸다. 어떤 프로세스도 요구보다 앞서 달리지 않으므로, 자기 자신으로 정의된
급수---$X'=XF'$의 풀이인 $\exp$나 $\tan'=1+\tan^2$에서 나오는 $\tan$---마저
달아나지 않고 값이 매겨진다. 급수의 산술 전체가 채널로 이어진 고루틴 그물이 되고,
연산자 하나를 쓰는 일은 거의 그 정의하는 식을 받아 적는 일이 된다.

계수는 정확한 유리수(\GO/의 |math/big.Rat|)이므로 반올림으로 잃는 것이 없다. 돌고
있는 급수는 저마다 고루틴 그물이고, 그 수명은 |context.Context|가 다스린다. 생성기가
하나를 받고, 거기서 나온 급수는 그것을 물려받으며, 그것을 취소하면 그물 전체가
내려간다.

@ 설치한 사람이 {\sc squint}가 제대로 도는지 알아볼 수 있도록 검증 프로그램을 함께
둔다. 시험하려면 그저 \.{squint\_test.go}를 돌리면 된다.

@(squint_test.go@>=
package squint

import (
	"context"
	"testing"
)

@<시험 도우미@>
@<|Deriv| 시험@>
@<|Recip| 시험@>

@ {\sc squint}의 \GO/ 코드에는 주 루틴이 없다. 시스템의 적재 루틴을 거쳐 더 높은
층의 프로그램에 끼워 넣을 함수 묶음일 뿐이다. 파일 \.{squint.go}의 얼개는 이렇다.

@p
package squint

import (
	"context"
	"math/big"
)

@<타입 정의@>
@<내부 함수들@>
@<공개 함수들@>

@ 값 |PS|는 돌고 있는 급수를 쥐는 손잡이다. 요구 프로토콜의 채널 둘과, 취소되면
급수를 끝내는 문맥을 담는다. 계수 |dat|는 |*big.Rat|이고, 요구 |req|는 자료를 나르지
않으니 빈 구조체다. 함수 |mkPS|는 채널을 만든다. 그것을 채우는 고루틴은 그 급수를
만든 생성기나 연산자가 띄운다.

@<타입 정의@>=
type PS struct {
	ctx context.Context
	req chan struct{}
	dat chan *big.Rat
}

@ @<내부 함수들@>=
func mkPS(ctx context.Context) PS {
	return PS{ctx: ctx, req: make(chan struct{}), dat: make(chan *big.Rat)}
}

@* 요구 프로토콜.
자그마한 메서드 넷이 이 그물의 어휘 전부다. 아래의 연산자는 모두 이것들로 짓는다.
소비자는 |get|으로 급수를 몰아간다. 요구를 놓고 계수를 기다리는 것이다. 주고받기의
두 쪽이 저마다 문맥과 경주하므로, 취소된 그물은 결코 멈춰 서지 않는다. 그럴 때
|get|은 그저 |ok|를 거짓으로 알린다.

@<내부 함수들@>=
func (F PS) get() (v *big.Rat, ok bool) {
	select {
	case F.req <- struct{}{}:
	case <-F.ctx.Done():
		return nil, false
	}
	select {
	case v = <-F.dat:
		return v, true
	case <-F.ctx.Done():
		return nil, false
	}
}

@ 생산자 쪽은 거울에 비친 모습이다. 메서드 |awaitReq|는 요구가 올 때까지 막고,
|send|는 이미 받은 요구에 계수 하나를 건네며, |put|은 그 둘을 차례로 한다. 곧
기다렸다가 건넨다. 메서드 |put|에 대해 가장 중요한 사실은, 프로세스가 {\it 입력을
하나도 요구하지 않고 먼저 항을 내놓을 수 있다\/}는 것이다. 뒤에 나오는 자기 참조
정의들이 교착에 빠지지 않고 시작할 수 있는 것이 바로 그 덕이다.

@<내부 함수들@>=
func (F PS) awaitReq() bool {
	select {
	case <-F.req:
		return true
	case <-F.ctx.Done():
		return false
	}
}

func (F PS) send(v *big.Rat) bool {
	select {
	case F.dat <- v:
		return true
	case <-F.ctx.Done():
		return false
	}
}

func (F PS) put(v *big.Rat) bool {
	return F.awaitReq() && F.send(v)
}

@ 공개된 접근자 둘이 부르는 쪽에서 급수를 읽게 해 준다. 메서드 |Get|은 계수 하나를
요구하고(문맥이 취소된 뒤에는 |nil|이다), |Take|는 앞의 |n|개를 모으되 그물이 도중에
내려가면 일찍 멈춘다.

@<공개 함수들@>=
func (F PS) Get() *big.Rat {
	v, _ := F.get()
	return v
}

func (F PS) Take(n int) []*big.Rat {
	cs := make([]*big.Rat, 0, n)
	for i := 0; i < n; i++ {
		v, ok := F.get()
		if !ok {
			break
		}
		cs = append(cs, v)
	}
	return cs
}

@ 한 줄짜리 감싸개 몇이 유리수 산술을 읽기 좋게 해 준다. 함수 |rat|은 $a/b$를 짓고,
|radd|, |rmul|, |rneg|, |rinv|는 우리에게 필요한, 값을 바꾸지 않는 산술이다. 저마다
새 |*big.Rat|을 돌려주므로 함께 쓰는 계수가 덮어써질 일이 없다.

@<내부 함수들@>=
func rat(a, b int64) *big.Rat     { return big.NewRat(a, b) }
func radd(x, y *big.Rat) *big.Rat { return new(big.Rat).Add(x, y) }
func rmul(x, y *big.Rat) *big.Rat { return new(big.Rat).Mul(x, y) }
func rneg(x *big.Rat) *big.Rat    { return new(big.Rat).Neg(x) }
func rinv(x *big.Rat) *big.Rat    { return new(big.Rat).Inv(x) }

@* 생성기.
가장 단순한 급수는 문맥 하나만 있으면 나온다. 함수 |Series|는 주어진 계수를 흘려보낸
뒤로는 영원히 0을 보내므로, 어떤 다항식이든 |Series|다. 아래의 생산자마다 되풀이되는
모습을 눈여겨보자. |put|을 도는 고루틴이 있고, |put|이 그물의 취소를 알리는 순간
돌아간다.

@<공개 함수들@>=
func Series(ctx context.Context, cs ...*big.Rat) PS {
	S := mkPS(ctx)
	go func() {
		for _, c := range cs {
			if !S.put(c) {
				return
			}
		}
		for S.put(rat(0, 1)) {
		}
	}()
	return S
}

@ 급수 |Ones|는 $1+x+x^2+\cdots=1/(1-x)$이고, |X|는 급수 $x$ 자신이다. 급수 |X|는
두 항짜리 |Series|일 뿐인데, 생성기들이 어떻게 엮이는지 보여 준다.

@<공개 함수들@>=
func Ones(ctx context.Context) PS {
	S := mkPS(ctx)
	go func() {
		for S.put(rat(1, 1)) {
		}
	}()
	return S
}

func X(ctx context.Context) PS { return Series(ctx, rat(0, 1), rat(1, 1)) }

@ 함수 |copyPS|는 급수 |I|를 출력 채널 |S|로 요구마다 한 항씩 넘겨준다. 프로세스가
앞의 몇 항을 손수 셈한 다음 나머지 출력을 다른 급수에 미룰 수 있게 해 주는 풀이다.

@<내부 함수들@>=
func copyPS(I, S PS) {
	for {
		if !S.awaitReq() {
			return
		}
		v, ok := I.get()
		if !ok {
			return
		}
		if !S.send(v) {
			return
		}
	}
}

@* 항별 연산.
덧셈이 연산자의 본보기다. 요구가 올 때마다 두 입력에서 항을 하나씩 끌어와 그 합을
보낸다. 어느 쪽 입력이든 끝나면(취소되면) 출력도 끝난다.

@<공개 함수들@>=
func Add(F, G PS) PS {
	S := mkPS(F.ctx)
	go func() {
		for {
			if !S.awaitReq() {
				return
			}
			f, ok := F.get()
			if !ok {
				return
			}
			g, ok := G.get()
			if !ok {
				return
			}
			if !S.send(radd(f, g)) {
				return
			}
		}
	}()
	return S
}

@ 스칼라 곱 |Cmul|은 모든 항을 상수 |c|로 키운다. 그러면 뺄셈은 공짜다.
$F-G=F+(-1)\,G$이기 때문이다.

@<공개 함수들@>=
func Cmul(c *big.Rat, F PS) PS {
	S := mkPS(F.ctx)
	go func() {
		for {
			if !S.awaitReq() {
				return
			}
			f, ok := F.get()
			if !ok {
				return
			}
			if !S.send(rmul(c, f)) {
				return
			}
		}
	}()
	return S
}

func Sub(F, G PS) PS { return Add(F, Cmul(rat(-1, 1), G)) }

@ $x$를 곱하는 일은 모든 계수를 한 자리씩 밀어 올린다. 먼저~$0$을 내보내고 |F|를
옮겨 적는 것이다. 이 한 항의 미룸이 곱과 합성의 재귀에 나오는 ``$x\cdot{}$'' 인수를
실현하는 방법이다.

@<공개 함수들@>=
func Xmul(F PS) PS {
	S := mkPS(F.ctx)
	go func() {
		if !S.put(rat(0, 1)) {
			return
		}
		copyPS(F, S)
	}()
	return S
}

@* 미적분.
미분은 $\sum F_i x^i$을 $\sum i\,F_i x^{i-1}$로 보낸다. 상수항을 버리고, 살아남은
$n$번째 계수에 $n$을 곱한다.

@<공개 함수들@>=
func Deriv(F PS) PS {
	D := mkPS(F.ctx)
	go func() {
		if !D.awaitReq() {
			return
		}
		if _, ok := F.get(); !ok { // 상수항을 버린다
			return
		}
		for n := int64(1); ; n++ {
			f, ok := F.get()
			if !ok {
				return
			}
			if !D.send(rmul(rat(n, 1), f)) {
				return
			}
			if !D.awaitReq() {
				return
			}
		}
	}()
	return D
}

@ @<|Deriv| 시험@>=
func TestDeriv(t *testing.T) {
	// ${d\over dx} 1/(1-x) = 1/(1-x)^2 = 1 + 2x + 3x^2 +\ldots$
	checkTerms(t, "deriv(Ones)", Deriv(Ones(newCtx(t))),
		[]string{"1", "2", "3", "4", "5", "6"})
}

@ 적분은 자기 참조 정의로 가는 열쇠다. 적분 $\int F\,dx$는 상수항이 |c|(적분
상수)이고 $n$번째 계수가 $F_{n-1}/n$이다. 결정적인 것은 |Integ|가 {\it |F|에서
아무것도 요구하기 전에 |c|를 내보낸다\/}는 점이다. 그 공짜 한 항이 되먹임 고리를
교착 대신 생산으로 만든다.

@<공개 함수들@>=
func Integ(c *big.Rat, F PS) PS {
	I := mkPS(F.ctx)
	go func() {
		if !I.put(c) {
			return
		}
		for n := int64(1); ; n++ {
			if !I.awaitReq() {
				return
			}
			f, ok := F.get()
			if !ok {
				return
			}
			if !I.send(rmul(rat(1, n), f)) {
				return
			}
		}
	}()
	return I
}

@* 급수 쪼개기.
어떤 연산은 급수 하나를 여러 곳에서 한꺼번에 읽어야 한다. 곱은 제 두 꼬리를 도로
먹이고, 역수는 자기 자신을 가리킨다. 맨 채널은 두 번 읽을 수 없으므로, 함수 |Split|은
급수 하나를 서로 독립인 흐름 |n|개로 바꾸어 저마다 |F|의 모든 계수를 건네게 한다.
가지들은 서로 다른 속도로 달려도 된다. 이미 나왔지만 가장 느린 가지가 아직 읽지 않은
계수는 줄에 담아 둔다.

@<공개 함수들@>=
func Split(F PS, n int) []PS {
	ctx := F.ctx
	outs := make([]PS, n)
	demand := make(chan int)
	@<가지마다 넘겨주는 고루틴을 띄운다@>@;
	@<버퍼 서버를 돌린다@>@;
	return outs
}

@ 가지마다 자그마한 고루틴이 하나씩 있어서 ``가지~|i|에 요구가 왔다''를 함께 쓰는
|demand| 채널 위의 메시지 |i|로 바꾼다. 그래야 아래의 서버 하나가 {\it 어느\/} 가지가
묻는지 알 수 있다.

@<가지마다 넘겨주는 고루틴을 띄운다@>=
for i := range outs {
	outs[i] = mkPS(ctx)
	go func(i int) {
		for {
			select {
			case <-outs[i].req:
			case <-ctx.Done():
				return
			}
			select {
			case demand <- i:
			case <-ctx.Done():
				return
			}
		}
	}(i)
}

@ 서버는 첨자 |base|부터의 계수를 미끄러지는 |buf|에 들고, 가지마다 어디까지 읽었는지
|pos|에 적어 둔다. 모든 가지가 어떤 첨자를 지나가면 그 앞부분을 버리므로, 줄에는 아직
뒤처진 가지가 필요로 하는 것만 남는다. 가지~|i|를 시중드는 |serve|는 그것에
|buf[pos[i]-base]|를 건네고 한 칸 나아가게 하며, 가장 느린 가지가 움직이면 버퍼를
잘라 낸다.

@<버퍼 서버를 돌린다@>=
go func() {
	var buf []*big.Rat // 첨자 base부터의 $F$ 계수
	base := 0
	pos := make([]int, n) // 가지마다 다음에 읽을 첨자
	var waiting []int     // $F$의 다음 항에 막힌 가지
	pulling := false
	pulled := make(chan *big.Rat)
	serve := func(i int) bool {
		if !outs[i].send(buf[pos[i]-base]) {
			return false
		}
		pos[i]++
		min := pos[0]
		for _, p := range pos[1:] {
			if p < min {
				min = p
			}
		}
		if min > base { // 모든 가지가 앞부분을 다 썼다
			buf = buf[min-base:]
			base = min
		}
		return true
	}
	@<요구를 시중들며 |F|의 새 항을 비동기로 가져온다@>@;
}()

@ 이미 버퍼에 있는 항을 바라는 요구는 그 자리에서 시중든다. 버퍼 끝을 넘어가는
요구는 |F|가 다음 계수를 내놓기를 기다려야 하는데, 그것을 가져오려고 서버를 막아
세우면 {\it 안 된다\/}. 재귀적인 정의(|Exp|, |Recip|, |Rev|)에서는 바로 그 항을
내놓는 일이 돌고 돌아 이 쪼개기를 거쳐 앞선 항을 요구하기 때문이다. 그래서 가져오는
일은 제 고루틴에서 한다. 그동안 서버는 버퍼에 있는 요구를 계속 시중들다가, 새 항이
|pulled|로 오면 그것을 접어 넣는다.

@<요구를 시중들며 |F|의 새 항을 비동기로 가져온다@>=
for {
	select {
	case i := <-demand:
		if pos[i]-base < len(buf) {
			if !serve(i) {
				return
			}
			continue
		}
		waiting = append(waiting, i)
		if !pulling {
			pulling = true
			go func() {
				v, ok := F.get()
				if !ok {
					return
				}
				select {
				case pulled <- v:
				case <-ctx.Done():
				}
			}()
		}
	case v := <-pulled:
		pulling = false
		buf = append(buf, v)
		w := waiting
		waiting = nil
		for _, i := range w {
			if !serve(i) {
				return
			}
		}
	case <-ctx.Done():
		return
	}
}

@* 곱셈.
급수를 $F=F_0+x\bar F$로 적어 머리 계수를 꼬리 $\bar F$에서 떼어 내자. 그러면 곱은
맥일로이의 식~(2)를 따른다.
$$FG=F_0G_0+x\,(F_0\bar G+G_0\bar F+x\,\bar F\bar G).$$
이것은 참으로 재귀적이다. 마지막 항에 두 꼬리의 곱이 필요하기 때문이다. 우리는
$F_0$과 $G_0$을 읽고(그러면 두 입력 채널은 저마다 제 꼬리를 나른다), 두 꼬리를 쪼개고,
세 성분 급수를 맞추어 그것을 셈한다. 안쪽의 |Mul|이 재귀이고, 꼬리를 도로 먹이는 일을
합법으로 만들어 주는 것이 |Split|이다.

@<공개 함수들@>=
func Mul(F, G PS) PS {
	P := mkPS(F.ctx)
	go func() {
		if !P.awaitReq() {
			return
		}
		f, ok := F.get() // 이제 $F$와 $G$는 제 꼬리를 나른다
		if !ok {
			return
		}
		g, ok := G.get()
		if !ok {
			return
		}
		if !P.send(rmul(f, g)) { // $F0\cdot G0$ 항
			return
		}
		FF := Split(F, 2)
		GG := Split(G, 2)
		fG := Cmul(f, GG[0])
		gF := Cmul(g, FF[0])
		xFG := Xmul(Mul(FF[1], GG[1])) // 재귀
		@<꼬리 급수 셋의 합을 내보낸다@>@;
	}()
	return P
}

@ 머리 다음부터는 곱의 모든 계수가 $F_0\bar G$, $G_0\bar F$, $x\,\bar F\bar G$의 같은
자리 계수를 더한 것이다.

@<꼬리 급수 셋의 합을 내보낸다@>=
for {
	if !P.awaitReq() {
		return
	}
	a, ok := fG.get()
	if !ok {
		return
	}
	b, ok := gF.get()
	if !ok {
		return
	}
	c, ok := xFG.get()
	if !ok {
		return
	}
	if !P.send(radd(radd(a, b), c)) {
		return
	}
}

@* 합성과 대입.
합성 $F(G)$는, 수렴하도록 $G_0=0$이라 할 때, 식~(3)을 따른다.
$$F(G)=F_0+x\,\bar G\,\bar F(G).$$
값 $F_0$을 읽으면 |F|는 $\bar F$를 나르게 되고, |G|의 (0인) 머리를 버리면 |G|는
$\bar G$를 나르게 된다. 그러면 결과의 꼬리는 $\bar G$에 재귀적인 합성을 곱한 것이다.

@<공개 함수들@>=
func Subst(F, G PS) PS {
	S := mkPS(F.ctx)
	go func() {
		GG := Split(G, 2)
		if !S.awaitReq() {
			return
		}
		f, ok := F.get()
		if !ok {
			return
		}
		if !S.send(f) {
			return
		}
		if _, ok := GG[0].get(); !ok { // $G0$을 버린다(0이어야 한다)
			return
		}
		copyPS(Mul(GG[0], Subst(F, GG[1])), S)
	}()
	return S
}

@ 단항식 대입 $F(c\,x^n)$은 더 싸고 재귀도 필요 없다. $i$번째 계수에 $c^i$를 곱하고,
거듭제곱을 벌려 놓으려고 계수마다 뒤에 0을 $n-1$개 끼워 넣는다. $c=-1$, $n=2$로 두면
$1/(1-x)$가 $1/(1+x^2)$이 되는데, 그것이 $\arctan$ 예의 씨앗이다.

@<공개 함수들@>=
func Msubst(F PS, c *big.Rat, n int) PS {
	S := mkPS(F.ctx)
	go func() {
		ci := rat(1, 1)
		for {
			if !S.awaitReq() {
				return
			}
			f, ok := F.get()
			if !ok {
				return
			}
			if !S.send(rmul(ci, f)) {
				return
			}
			ci = rmul(ci, c)
			for k := 0; k < n-1; k++ {
				if !S.put(rat(0, 1)) {
					return
				}
			}
		}
	}()
	return S
}

@* 재귀의 매듭 짓기.
함수 |Fix|는 $X=f(X)$를 만족하는 급수 $X$를 돌려준다. 새 $X$를 쪼개어 |f|가 그 한
벌로 제 그물을 짓게 하고, 그 결과를 다시 $X$로 옮겨 적는다. 이것이 돌아가려면 정의가
{\it 생산적\/}이어야 한다. 곧 |f|의 그물이 항을 하나 요구하기 전에 제 첫 항을
내놓아야 하는데, 적분 상수를 앞세워 내보내는 |Integ|로 시작하면 바로 그것이
보장된다. 미분 방정식이 흐름이 되는 길이다.

@<공개 함수들@>=
func Fix(ctx context.Context, f func(PS) PS) PS {
	X := mkPS(ctx)
	XX := Split(X, 2)
	go copyPS(f(XX[0]), X)
	return XX[1]
}

@ 지수 함수는 그 논문이 내내 드는 예다. 지수 $e^F$는($F_0=0$일 때) $X'=X\,F'$의
풀이이고, 곧 고정점
$$X=1+\int X\,F'\,dx$$
이다. 적분 |Integ|가 아무것도 읽기 전에 맨 앞의~$1$을 대 주므로 고리는 생산적이고
항마다 수렴한다. 피카르의 반복을 자료 흐름으로 돌리는 것이다.

@<공개 함수들@>=
func Exp(F PS) PS {
	D := Deriv(F)
	return Fix(F.ctx, func(X PS) PS {
		return Integ(rat(1, 1), Mul(X, D))
	})
}

@* 역수와 되돌리기.
역수 $1/F$는($F_0\ne0$일 때) 그 자체로 고정점이다.
$$R={1\over F_0}\,(1-x\,\bar F\,R).$$
그래서 |R|을 쪼개어 한 벌을 도로 곱해 넣는다. 값 $F_0$을 읽으면 |F|는 $\bar F$를
나르게 된다. 첫 항은 $1/F_0$이고, 나머지는 $-1/F_0$에 $\bar F\,R$을 곱한 것이다(여기서
|Xmul|은 |copyPS|가 항을 한 자리 미루는 데 숨어 있다).

@<공개 함수들@>=
func Recip(F PS) PS {
	R := mkPS(F.ctx)
	RR := Split(R, 2)
	go func() {
		if !R.awaitReq() {
			return
		}
		f, ok := F.get() // 이제 $F$는 $\bar F$를 나른다
		if !ok {
			return
		}
		r0 := rinv(f)
		if !R.send(r0) {
			return
		}
		copyPS(Cmul(rneg(r0), Mul(F, RR[0])), R)
	}()
	return RR[1]
}

@ @<|Recip| 시험@>=
func TestRecip(t *testing.T) {
	// $1/(1/(1-x)) = 1 - x$
	checkTerms(t, "recip(Ones)", Recip(Ones(newCtx(t))),
		[]string{"1", "-1", "0", "0", "0", "0"})
}

@ 되돌리기는 함수의 역을 찾는다. $F_0=0$이고 $F_1\ne0$인 $F$가 주어지면, |Rev|는
$F(R(x))=x$인 $R$을 돌려준다. $R=x\bar R$로 적으면 식~(8)에서
$$\bar R={1\over F_1}\,\bigl(1-x\,\bar R^2\,\bar{\bar F}(R)\bigr)$$
이 나온다. 오른쪽에 $R$이 세 번 나오므로($\bar R^2$에 두 번, 합성 안에 한 번) 그물은
그것을 네 갈래로 쪼갠다. 셋은 제 정의에 쓰고, 하나는 부르는 쪽에 준다.

@<공개 함수들@>=
func Rev(F PS) PS {
	R := mkPS(F.ctx)
	RR := Split(R, 4)
	go func() {
		if !R.put(rat(0, 1)) { // $R0 = 0$
			return
		}
		if !R.awaitReq() {
			return
		}
		if _, ok := F.get(); !ok { // $F0$을 버린다(0이어야 한다)
			return
		}
		v, ok := F.get() // 이제 $F$는 $\bar{\bar F}$를 나른다
		if !ok {
			return
		}
		f1 := rinv(v)
		if !R.send(f1) { // $R1 = 1/F1$
			return
		}
		W := Mul(Mul(tail(RR[0]), tail(RR[1])), Subst(F, RR[2])) // ${\bar R}^2 \cdot \bar{\bar F}(R)$
		c := rneg(f1)
		@<|R|의 남은 계수를 내보낸다@>@;
	}()
	return RR[3]
}

@ $R_0=0$과 $R_1=1/F_1$을 이미 보냈으니, 그다음 계수는 저마다
$W=\bar R^2\,\bar{\bar F}(R)$의 다음 항에 $-1/F_1$을 곱한 것이다.

@<|R|의 남은 계수를 내보낸다@>=
for {
	if !R.awaitReq() {
		return
	}
	w, ok := W.get()
	if !ok {
		return
	}
	if !R.send(rmul(c, w)) {
		return
	}
}

@ 끝으로 함수 |tail|은 |F|의 상수항을 버려 $\bar F$를 내놓는다. 맥일로이가 윗줄로
적는 연산이고, 위에서 $R$에서 $\bar R$을 얻는 데 썼다.

@<내부 함수들@>=
func tail(F PS) PS {
	T := mkPS(F.ctx)
	go func() {
		if !T.awaitReq() {
			return
		}
		if _, ok := F.get(); !ok { // 버린다
			return
		}
		v, ok := F.get()
		if !ok {
			return
		}
		if !T.send(v) {
			return
		}
		copyPS(F, T)
	}()
	return T
}

@ 함수 |newCtx|는 시험이 끝날 때 취소되는 문맥을 돌려준다. 그래야 시험마다 띄운
프로세스 그물이 내려간다.

@<시험 도우미@>=
func newCtx(t *testing.T) context.Context {
	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)
	return ctx
}

@ 함수 |checkTerms|는 F의 앞쪽 계수를 바라는 유리수와 견준다. 바라는 값은 "1",
"-1/3"처럼 문자열로 준다.

@<시험 도우미@>=
func checkTerms(t *testing.T, name string, F PS, want []string) {
	t.Helper()
	for i, w := range want {
		got := F.Get().RatString()
		if got != w {
			t.Fatalf("%s: %d번째 항이 %s인데 %s여야 한다", name, i, got, w)
		}
	}
}

@* 색인.
