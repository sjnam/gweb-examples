\input kotexgweb
\input luamplib.sty
@i types.w

@* 들어가며.
거듭제곱 급수 $$F(x)=\sum_{i\ge0}F_i\,x^i=F_0+F_1x+F_2x^2+\cdots$$
는 끝없이 이어지지만, 그 계수 $F_0,F_1,F_2,\ldots$는 앞에서부터 하나씩 차례로
다룰 수 있다. 급수에 대한 재미있는 연산은 거의 모두---합, 곱, 합성, 역수, 역함수,
심지어 미분 방정식의 풀이까지---결과의 계수를 앞에서부터 하나씩 셈해 낼 수 있다.
결과의 $n$번째 계수를 얻는 데는 입력의 앞쪽 계수 몇 개만 있으면 되고, 그보다 뒤의
계수는 미리 알 필요가 없기 때문이다. 이렇게 필요한 만큼만 그때그때 셈하는 것이
바로 {\it 게으른 흐름\/}이다. 나는 맥일로이(M.~Douglas McIlroy)의 아름다운 논문
{\sl Squinting at Power Series\/}({\sl Software---Practice and Experience\/}
{\bf 20} (1990), 661--683)를 따라, 급수 하나를 {\it 유리수 계수가 흘러나오는
흐름\/}으로, 대수 연산 하나를 {\it 작은 동시 프로세스\/}로 구현한다.

급수를 나타내는 데는 맥일로이의 핵심 장치인 {\it 요구 채널\/}을 쓴다. 급수 하나는
채널 한 쌍, 곧 요구 채널과 자료 채널이다. 소비자가 요구 채널로 신호를 하나 보내야
비로소 생산자가 다음 계수를 셈해 자료 채널로 보낸다. 요구가 없으면 어떤 프로세스도
미리 셈하지 않으므로, 자기 자신으로 정의되는 급수---$X'=XF'$의 해인 $\exp$나
$\tan'=1+\tan^2$에서 나오는 $\tan$---도 끝없는 계산에 빠지지 않고 값이 나온다.
결국 급수 산술 전체가 채널로 이어진 고루틴 그물이 되고, 연산자 하나를 구현하는 일은
그 연산을 정의하는 식을 거의 그대로 옮겨 적는 일이 된다.

계수는 정확한 유리수(\GO/의 |math/big.Rat|)이므로 반올림 오차가 없다. 실행 중인
급수는 저마다 고루틴 그물이고, 그 그물의 수명은 문맥 |context.Context|가 관리한다.
생성기를 부를 때 문맥을 하나 넘기면, 그로부터 만들어지는 급수들이 모두 그 문맥을
물려받는다. 그 문맥을 취소하면 그물 전체가 멈추고 고루틴들이 모두 끝난다.

@ 나는 이 프로그램이 \GO/의 고루틴과 채널을 처음 배우는 사람에게 더없이 좋은
읽을거리라고 생각한다. 고루틴은 \GO/ 런타임이 관리하는 가벼운 실행 흐름이고, 채널은
고루틴들이 값을 주고받는 통로다. 동시성을 설명하는 글은 흔히 일꾼 풀이나 웹 서버를
예로 드는데, 거기서 동시성은 일을 빨리 끝내려는 수단일 뿐이다. 여기서는 사정이
다르다. 끝없는 대상을 유한한 기계로 다루려면 필요할 때 필요한 만큼만 셈해야 하고,
고루틴과 채널은 바로 그 일을 자연스럽게 해낸다. 멱급수의 재미는 덤이다.

이 생각이 \GO/와 얼마나 가까운지는 내력이 말해 준다. 맥일로이의 원래 프로그램은 롭
파이크(Rob Pike)의 언어 뉴스퀵(Newsqueak)으로 쓰였고, 뉴스퀵의 채널은 그대로 \GO/의
채널로 이어졌다. 그리고 \GO/의 저자들은 2009년에 이 프로그램을 \GO/로 옮겨 \GO/
저장소의 시험 \.{test/chan/powser1.go}와 \.{powser2.go}로 넣었다. 그 머리말은 이것이
``동시성 기본 도구의 시험''이라고 밝힌다. 언어를 만든 사람들이 고루틴과 채널이
제대로 도는지 보려고 고른 프로그램이니, 그것들을 배우는 데도 이만한 것이 드물다.
내 프로그램도 요구 채널 한 쌍으로 급수를 나타내는 뼈대는 같지만 세 군데가 다르다.
계수는 |int64| 분수 대신 |big.Rat|이라서 넘칠 걱정이 없다. 쪼개기는 값마다 고루틴을
한 세대씩 띄우는 두 갈래 고정의 방식 대신, 고루틴 하나가 버퍼를 쥐고 여러 갈래에
나누어 주는 서버로 짰다. 끝없이 도는 그물은 문맥으로 거둔다. 시험 프로그램은
|main|이 끝나면 고루틴이 모두 함께 사라지니 그럴 필요가 없었다.

읽어 가면서 \GO/의 동시성 도구를 차례로 만난다. 함수 |mkPS|에서는 버퍼 없는 채널로
두 고루틴이 만나는 법을, 메서드 |get|에서는 여러 채널을 한꺼번에 기다리는 |select|와
취소를 온 그물에 알리는 법을 본다. 함수 |Series|에서는 |go| 문으로 고루틴을 띄우고,
함수 |Split|에서는 고루틴 하나가 상태를 독차지해 잠금 없이 자료를 나누어 준다. 함수
|Mul|에서는 재귀 호출마다 고루틴이 새로 생기고, 함수 |Fix|에서는 급수가 제 출력을
제 입력으로 받는다. 맨 끝의 놀이터에서는 몇 줄짜리 보기로 $\tan x$와 카탈랑 수
따위를 뽑아 본다.

@ 설치한 사람이 {\sc SQUINT}가 제대로 동작하는지 확인할 수 있도록 시험 프로그램을
함께 둔다. 시험해 보려면 \.{go test}로 \.{squint\_test.go}를 돌리면 된다.

@(squint_test.go@>=
package squint

import (
	"context"
	"fmt"
	"testing"
)

@<시험 도우미@>
@<|Deriv| 시험@>
@<|Recip| 시험@>
@<보기@>

@ {\sc SQUINT}는 라이브러리이므로 \GO/ 코드에 |main| 함수가 없다. 다른 프로그램이
가져다 쓰는 함수 묶음일 뿐이다. 파일 \.{squint.go}의 얼개는 다음과 같다.

@p
package squint

import (
	"context"
	"math/big"
	"slices"
)

@<타입 정의@>
@<내부 함수들@>
@<공개 함수들@>

@ 구조체 |PS|는 실행 중인 급수를 가리키는 손잡이다. 요구 프로토콜에 쓰는 채널 둘과,
취소되면 급수를 끝내는 문맥을 담는다. 자료 채널 |dat|로는 계수 |*big.Rat|이 오가고,
요구 채널 |req|로는 아무 자료도 오가지 않으므로 원소 형이 크기가 0인 빈 구조체다.
채널은 참조 값이라서 |PS|를 값으로 복사해 넘겨도 복사본들이 모두 같은 채널을
가리킨다. 그래서 아래의 메서드들은 모두 값 수신자로 충분하다.

@<타입 정의@>=
type PS struct {
	ctx context.Context
	req chan struct{}
	dat chan *big.Rat
}

@ 함수 |mkPS|는 채널만 만들어 줄 뿐이고, 그 채널로 계수를 보낼 고루틴은 급수를
만드는 생성기나 연산자가 따로 띄운다. 함수 |make|에 용량을 주지 않았으므로 두
채널에는 버퍼가 없다. 버퍼 없는 채널에서는 보내는 쪽과 받는 쪽이 {\it 만나야\/} 값이
건너가고, 먼저 온 쪽은 상대가 올 때까지 기다린다.

그러면 자료 채널 하나만으로도 생산자와 소비자의 발걸음을 맞출 수 있지 않을까?
그렇지 않다. 생산자는 다음 값을 {\it 다 셈한 뒤에야\/} 보내기에서 기다리므로 늘 한
걸음 앞서 셈한다. 게다가 누가 언제 받을 준비가 되었는지 알 길이 없다. 요구 채널이
이 두 가지를 해결한다. 생산자는 요구가 와야 셈을 시작하고, 요구를 보낸 소비자는
지금 받을 준비가 되어 있다. 이 차이가 얼마나 큰지는 뒤의 |Split|에서 드러난다.
시험 삼아 요구 채널을 떼어 내고 돌려 보았더니, $1/(1-x)^2$을 셈하는 곱셈이 첫 다섯
항도 내지 못하고 멈추어 버렸다.

@<내부 함수들@>=
func mkPS(ctx context.Context) PS {
	return PS{ctx: ctx, req: make(chan struct{}), dat: make(chan *big.Rat)}
}

@* 요구 프로토콜.
이 그물에서 쓰는 말은 작은 메서드 네 개가 전부이고, 뒤에 나오는 연산자는 모두
이것들로 짓는다. 소비자는 메서드 |get|으로 급수에서 계수를 하나씩 끌어낸다. 요구를
보낸 다음 계수가 오기를 기다리는 것이다.

\GO/의 |select| 문은 여러 채널 연산을 한꺼번에 기다리다가 먼저 준비된 것 하나를
실행한다. 여기서는 보내기나 받기를 |ctx.Done()|에서 받기와 함께 기다린다. 메서드
|Done|이 돌려주는 채널로는 아무도 값을 보내지 않는다. 그 채널은 문맥이 취소되는
순간 닫힐 뿐이다. 닫힌 채널에서 받기는 언제나 곧바로 성공하므로, 한 번의 취소가 그
채널을 기다리던 모든 고루틴에 한꺼번에 전해진다. 고루틴 수천 개를 한 줄로 끝내는
방송인 셈이다. 그러니 그물이 취소된 뒤에도 영영 막혀 버리는 고루틴은 없다. 그때
|get|은 |ok|를 거짓으로 돌려줄 뿐이다.

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

@ 생산자 쪽 메서드는 이것을 거울에 비춘 꼴이다. 메서드 |awaitReq|는 요구가 올
때까지 기다리고, |send|는 받은 요구에 답해 계수 하나를 보내며, |put|은 그 둘을
차례로 한다. 메서드 |put|에서 눈여겨볼 점은, 프로세스가 {\it 입력을 하나도 요구하지
않고도 항을 먼저 내놓을 수 있다\/}는 것이다. 뒤에 나오는 자기 참조 정의들이 교착에
빠지지 않고 출발할 수 있는 것은 이 덕분이다.

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

@ 라이브러리를 쓰는 쪽에서는 공개 메서드 둘로 급수를 읽는다. 메서드 |Get|은 다음
계수 하나를 돌려주고(문맥이 취소된 뒤에는 |nil|을 돌려준다), |Take|는 다음 계수
|n|개를 모아 돌려주되 도중에 그물이 취소되면 그때까지 모은 것만 돌려준다.

쓰는 쪽이 꼭 기억할 것이 하나 있다. 급수를 다 쓰고 나면 문맥을 취소해야 한다.
요구를 기다리며 막혀 있는 고루틴은 쓰레기 수집기가 거두어 가지 않으므로, 취소하지
않으면 그물 전체가 프로그램이 끝날 때까지 남는다.

@<공개 함수들@>=
func (F PS) Get() *big.Rat {
	v, _ := F.get()
	return v
}

func (F PS) Take(n int) []*big.Rat {
	cs := make([]*big.Rat, 0, n)
	for range n {
		v, ok := F.get()
		if !ok {
			break
		}
		cs = append(cs, v)
	}
	return cs
}

@ 유리수 산술을 읽기 쉽게 하려고 한 줄짜리 감싸개 함수를 몇 개 둔다. 함수 |rat|은
유리수 $a/b$를 만들고, |radd|, |rmul|, |rneg|, |rinv|는 각각 덧셈, 곱셈, 부호
바꾸기, 역수다. 이들은 인자를 고치지 않고 늘 새 |*big.Rat|을 돌려준다. 계수 하나를
여러 소비자가 함께 쓰기도 하므로(뒤의 |Split|을 보라), 제자리에서 고치면 큰일 난다.

@<내부 함수들@>=
func rat(a, b int64) *big.Rat     { return big.NewRat(a, b) }
func radd(x, y *big.Rat) *big.Rat { return new(big.Rat).Add(x, y) }
func rmul(x, y *big.Rat) *big.Rat { return new(big.Rat).Mul(x, y) }
func rneg(x *big.Rat) *big.Rat    { return new(big.Rat).Neg(x) }
func rinv(x *big.Rat) *big.Rat    { return new(big.Rat).Inv(x) }

@* 생성기.
가장 단순한 급수는 문맥 하나만 있으면 만들 수 있다. 함수 |Series|는 주어진 계수들을
차례로 내보낸 다음 영원히 0을 내보내므로, 어떤 다항식이든 |Series|로 나타낼 수 있다.
여기서 |go| 문을 처음 만난다. 함수를 부를 때 앞에 |go|를 붙이면 그 함수는 새
고루틴에서 돌고, 부른 쪽은 기다리지 않고 곧바로 다음으로 넘어간다. 그래서 |Series|는
채널만 쥔 |S|를 곧바로 돌려주고, 계수를 내보내는 일은 뒤에 남은 고루틴이 맡는다. 그
고루틴은 함수 리터럴로 쓴 클로저라서 바깥의 |S|와 |cs|를 그대로 쓴다. 고루틴은 몇
킬로바이트의 스택으로 시작하는 가벼운 것이어서, 급수 하나에 고루틴을 몇 개씩 띄워도
아깝지 않다.

앞으로 나올 생산자들에 되풀이되는 꼴도 눈여겨보자. 고루틴 하나가 |put|을 거듭
부르다가, |put|이 거짓을 돌려주면(곧 그물이 취소되면) 곧바로 끝난다.

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

@ 급수 |Ones|는 $1+x+x^2+\cdots=1/(1-x)$이고, 급수 |X|는 $x$ 한 항뿐인 급수다.
함수 |X|는 계수 두 개짜리 |Series|로 간단히 정의되는데, 생성기를 다른 생성기로 지을
수 있음을 보여 준다.

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

@ 함수 |copyPS|는 출력 급수 |S|에 요구가 올 때마다 입력 급수 |I|에서 항을 하나 받아
넘겨준다. 앞의 몇 항은 손수 셈해 내보내고 나머지는 다른 급수에 맡기고 싶을 때 이것을
쓴다.

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
연산자의 본보기로 덧셈을 보자. 함수 |Add|는 요구가 올 때마다 두 입력에서 항을 하나씩
받아 그 합을 보낸다. 어느 쪽 입력이든 끝나면(곧 취소되면) 출력도 끝난다. 출력은
|F|의 문맥을 물려받는데, 한 그물에 속한 급수는 모두 같은 문맥을 쓴다고 본다.

코드에 |if !ok { return }|이 줄줄이 늘어선 것이 거슬릴지 모르겠다. 막힐 수 있는
곳은 모두 취소를 알아차리고 빠져나가야 하는 곳이기도 하다. 고루틴이 끝나는 길을
그렇게 하나하나 열어 둔 것이다.

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

@ 스칼라 곱 |Cmul|은 모든 항에 상수 |c|를 곱한다. 이것만 있으면 뺄셈은
$F-G=F+(-1)\,G$로 거저 얻는다.

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

@ 급수에 $x$를 곱하면 모든 계수가 한 자리씩 뒤로 밀린다. 그러니 먼저~$0$을 내보낸
다음 |F|를 그대로 옮겨 적으면 된다. 곱셈과 합성의 재귀식에 나오는 인수
``$x\cdot{}$''는 이렇게 출력을 한 항 늦추는 것으로 구현한다.

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
미분은 $\sum F_i x^i$를 $\sum i\,F_i x^{i-1}$로 바꾼다. 곧 상수항을 버리고, 남은
계수 $F_n$에는 저마다 그 차수 $n$을 곱한다.

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

@ 자기 참조 정의를 풀어 주는 열쇠는 적분이다. 적분 $\int F\,dx$는 상수항이 적분
상수 |c|이고 $n$번째 계수가 $F_{n-1}/n$이다. 결정적인 것은 함수 |Integ|가 {\it |F|에
아무것도 요구하기 전에 |c|부터 내보낸다\/}는 점이다. 거저 나오는 이 한 항 덕분에,
되먹임 고리가 교착에 빠지지 않고 계수를 계속 만들어 낸다.

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
어떤 연산은 급수 하나를 여러 곳에서 함께 읽어야 한다. 이를테면 곱셈은 두 입력의
꼬리를 저마다 두 곳에서 쓰고, 역수는 자기 자신을 다시 읽는다. 채널에서 받은 값은 한
번 읽으면 사라지므로, 채널 하나로는 같은 계수를 두 소비자에게 줄 수 없다. 그래서
함수 |Split|은 급수 |F| 하나를 서로 독립인 흐름 |n|개로 갈라, 가지마다 |F|의 계수를
빠짐없이 건네게 한다. 가지들은 저마다 다른 속도로 읽어도 된다. 앞선 가지가 이미
받았지만 뒤처진 가지가 아직 읽지 않은 계수는 버퍼에 담아 둔다.

@<공개 함수들@>=
func Split(F PS, n int) []PS {
	ctx := F.ctx
	outs := make([]PS, n)
	demand := make(chan int)
	@<가지마다 넘겨주는 고루틴을 띄운다@>@;
	@<버퍼 서버를 돌린다@>@;
	return outs
}

@ 가지마다 작은 고루틴이 하나씩 붙어서, 가지~|i|에 요구가 오면 공용 채널 |demand|로
번호 |i|를 보낸다. 그래야 서버 고루틴 하나가 모든 요구를 받으면서도 {\it 어느\/}
가지가 요구했는지 알 수 있다. 여러 고루틴이 한 채널로 보내고 한 고루틴이 받는 이런
모양을 {\it 팬인\/}(fan-in)이라 한다. 클로저는 저마다 제 |i|를 붙잡는다. \GO/~1.22부터는
반복 변수가 반복마다 새로 만들어지기 때문이다.

@<가지마다 넘겨주는 고루틴을 띄운다@>=
for i := range outs {
	outs[i] = mkPS(ctx)
	go func() {
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
	}()
}

@ 서버는 첨자 |base|부터의 계수를 버퍼 |buf|에 담아 두고, 가지마다 다음에 읽을
첨자를 |pos|에 적어 둔다. 모든 가지가 지나간 앞부분은 버리므로, 버퍼에는 뒤처진
가지가 아직 읽어야 할 계수만 남는다. 가지~|i|의 요구에 답하는 함수 |serve|는 그
가지에 |buf[pos[i]-base]|를 보내고 |pos[i]|를 하나 늘린 다음, 가장 느린 가지가 앞으로
나아갔으면 버퍼의 앞부분을 잘라 낸다.

변수 |buf|, |base|, |pos|, |waiting|은 오직 이 서버 고루틴만 만진다. 그래서 잠금이
하나도 필요 없다. \GO/의 격언 ``메모리를 공유해서 통신하지 말고, 통신해서 메모리를
공유하라''를 그대로 따른 것이다. 경쟁 탐지기를 켜고(\.{go test -race}) 시험을 돌려도
걸리는 것이 없다.

@<버퍼 서버를 돌린다@>=
go func() {
	var buf []*big.Rat // 첨자 base부터의 $F$ 계수
	base := 0
	pos := make([]int, n) // 가지마다 다음에 읽을 첨자
	var waiting []int     // $F$의 다음 항을 기다리는 가지
	pulling := false
	pulled := make(chan *big.Rat)
	serve := func(i int) bool {
		if !outs[i].send(buf[pos[i]-base]) {
			return false
		}
		pos[i]++
		if m := slices.Min(pos); m > base { // 모든 가지가 지나간 앞부분을 버린다
			buf = buf[m-base:]
			base = m
		}
		return true
	}
	@<요구를 시중들며 |F|의 새 항을 비동기로 가져온다@>@;
}()

@ 요구한 항이 이미 버퍼에 있으면 곧바로 답한다. 버퍼 끝을 넘는 항을 요구하면 |F|가
다음 계수를 내놓을 때까지 기다려야 하는데, 이때 서버가 그 자리에 멈춰 서서 기다리면
{\it 안 된다\/}. 재귀적인 정의(|Exp|, |Recip|, |Rev|)에서는 |F|가 그 항을 셈하는
도중에 돌고 돌아 바로 이 |Split|을 거쳐 앞쪽 항을 요구하기 때문이다. 서버가 멈춰
있으면 그 요구에 답할 수 없으니 교착이다. 그래서 |F|에서 새 항을 가져오는 일은 따로
띄운 고루틴에 맡긴다. 그동안 서버는 버퍼에 있는 항에 대한 요구에 계속 답하다가, 새
항이 채널 |pulled|로 도착하면 버퍼에 덧붙이고 기다리던 가지들에 나눠 준다. 막힐 수
있는 일을 고루틴에 맡기고 그 결과를 채널로 받아 |select|의 한 갈래로 삼는 것은
\GO/에서 두루 쓰는 수법이다.

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
급수를 $F=F_0+x\bar F$처럼 머리 계수 $F_0$과 꼬리 $\bar F$로 나누어 적자. 그러면
곱은 맥일로이의 식~(2)를 따른다.
$$FG=F_0G_0+x\,(F_0\bar G+G_0\bar F+x\,\bar F\bar G).$$
마지막 항에 두 꼬리의 곱이 다시 나오므로 이 식은 그야말로 재귀적이다. 나는 먼저
$F_0$과 $G_0$을 읽는다. 그러면 두 입력 채널에는 저마다 꼬리만 남는다. 다음으로 두
꼬리를 저마다 둘로 쪼개고, 세 성분 급수를 항별로 더해 곱의 꼬리를 셈한다. 안쪽의
|Mul|이 재귀 호출이고, 꼬리 하나를 두 곳에서 읽을 수 있게 해 주는 것이 |Split|이다.
그림으로 그리면 다음과 같다. 화살표는 계수가 흐르는 방향이고, 요구는 그 반대로
흐른다. 점선 상자는 같은 그물이 한 단 더 들어 있는 재귀 호출이다.
$$\mplibcode
beginfig(1);
  u := 1cm;
  def node(expr z, s) =
    draw unitsquare xscaled 2u yscaled .8u shifted (z - (u, .4u));
    label(textext(s), z);
  enddef;
  def link(expr a, b) =
    drawarrow (a + (u, 0)) -- (b - (u, 0));
  enddef;
  pickup pencircle scaled .6;
  z1 = (2.6u, 3u); z2 = (2.6u, 0);
  z3 = (6u, 4.2u); z4 = (6u, 1.5u); z5 = (6u, -1.2u);
  z6 = (9u, 1.5u); z7 = (12u, 1.5u);
  node(z1, "{\it Split\/}"); node(z2, "{\it Split\/}");
  node(z3, "{\it Cmul\/}$(G_0)$"); node(z5, "{\it Cmul\/}$(F_0)$");
  node(z6, "{\it Xmul\/}"); node(z7, "$+$");
  draw unitsquare xscaled 2u yscaled .8u shifted (z4 - (u, .4u)) dashed evenly;
  label(textext("{\it Mul\/}"), z4);
  drawarrow (0, 3u) -- (z1 - (u, 0));
  label.lft(textext("$\bar F$"), (0, 3u));
  drawarrow (0, 0) -- (z2 - (u, 0));
  label.lft(textext("$\bar G$"), (0, 0));
  link(z1, z3); link(z2, z5); link(z4, z6); link(z6, z7);
  drawarrow (z1 + (u, 0)) -- (z4 - (u, -.2u));
  drawarrow (z2 + (u, 0)) -- (z4 - (u, .2u));
  drawarrow (z3 + (u, 0)) -- (z7 - (u, -.25u));
  drawarrow (z5 + (u, 0)) -- (z7 - (u, .25u));
  drawarrow (z7 + (u, 0)) -- (z7 + (2u, 0));
  label.rt(textext("$FG$"), z7 + (2u, 0));
endfig;
\endmplibcode$$
곱의 항을 하나 더 요구할 때마다 재귀가 한 단 깊어지며 고루틴이 다섯 개쯤 새로
생긴다. 이를테면 $1/(1-x)^2$의 항을 마흔 개 뽑으면 고루틴이 이백 개쯤 생긴다.
고루틴이 가볍기에 망설임 없이 쓸 수 있는 설계다.

@<공개 함수들@>=
func Mul(F, G PS) PS {
	P := mkPS(F.ctx)
	go func() {
		if !P.awaitReq() {
			return
		}
		f, ok := F.get() // 이제 $F$와 $G$에는 꼬리만 남는다
		if !ok {
			return
		}
		g, ok := G.get()
		if !ok {
			return
		}
		if !P.send(rmul(f, g)) { // $F_0\cdot G_0$ 항
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

@ 머리 다음의 계수는 모두 세 급수 $F_0\bar G$, $G_0\bar F$, $x\,\bar F\bar G$의 같은
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
합성 $F(G)$는 식~(3)을 따른다. 다만 합성이 잘 정의되려면 $G_0=0$이어야 한다.
$$F(G)=F_0+x\,\bar G\,\bar F(G).$$
계수 $F_0$을 읽고 나면 |F|에는 $\bar F$가 남고, |G|의 머리(0이다)를 버리고 나면
|G|에는 $\bar G$가 남는다. 결과의 꼬리는 $\bar G$에 재귀 합성 $\bar F(G)$를 곱한
것이다. 인수 $x$는 첫 항 $F_0$을 먼저 보낸 뒤 |copyPS|로 넘기는 것만으로 저절로
처리된다.

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
		if _, ok := GG[0].get(); !ok { // $G_0$을 버린다(0이어야 한다)
			return
		}
		copyPS(Mul(GG[0], Subst(F, GG[1])), S)
	}()
	return S
}

@ 단항식을 대입한 $F(c\,x^n)$은 셈이 더 싸고 재귀도 필요 없다. 함수 |Msubst|는
$i$번째 계수에 $c^i$를 곱하고, 차수를 $n$배로 벌리려고 계수마다 뒤에 0을 $n-1$개
끼워 넣는다. 이를테면 $c=-1$, $n=2$로 두면 $1/(1-x)$가 $1/(1+x^2)$이 되는데, 이것을
적분하면 $\arctan x$가 나온다.

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
			for range n - 1 {
				if !S.put(rat(0, 1)) {
					return
				}
			}
		}
	}()
	return S
}

@* 재귀의 매듭 짓기.
함수 |Fix|는 $X=f(X)$를 만족하는 급수 $X$를 돌려준다. 먼저 빈 급수 $X$를 만들어
둘로 쪼갠 다음, 한 가지는 |f|에 넘겨 그 그물을 짓게 하고, |f|가 내놓는 결과를 다시
$X$로 옮겨 적는다. 다른 가지는 부르는 쪽에 돌려준다. 이것이 돌아가려면 정의가
{\it 생산적\/}이어야 한다. 곧 |f|의 그물은 입력에서 항을 하나라도 요구하기 전에 첫
항을 내놓아야 한다. 적분 상수부터 내보내는 |Integ|를 바깥에 두면 이 조건이 저절로
채워진다. 미분 방정식을 흐름으로 푸는 길이 바로 이것이다.

마지막 줄의 |go copyPS(f(XX[0]), X)|도 눈여겨보자. 문 |go|의 인자는 부르는 쪽
고루틴에서 먼저 셈한다. 따라서 |f|가 그물을 짓는 일은 |Fix| 안에서 곧바로 끝나고,
새 고루틴에서 도는 것은 |copyPS|뿐이다.

@<공개 함수들@>=
func Fix(ctx context.Context, f func(PS) PS) PS {
	X := mkPS(ctx)
	XX := Split(X, 2)
	go copyPS(f(XX[0]), X)
	return XX[1]
}

@ 지수 함수는 맥일로이의 논문에서 줄곧 나오는 예다. 지수 함수 $e^F$는($F_0=0$일 때)
미분 방정식 $X'=X\,F'$의 해이고, 이를 적분하면 고정점 방정식
$$X=1+\int X\,F'\,dx$$
가 된다. 함수 |Integ|가 아무것도 읽기 전에 첫 항~$1$을 내놓으므로 이 고리는
생산적이고, 계수가 하나씩 차례로 확정된다. 피카르 반복을 자료 흐름으로 돌리는 셈이다.

@<공개 함수들@>=
func Exp(F PS) PS {
	D := Deriv(F)
	return Fix(F.ctx, func(X PS) PS {
		return Integ(rat(1, 1), Mul(X, D))
	})
}

@* 역수와 되돌리기.
역수 $1/F$도($F_0\ne0$일 때) 고정점 방정식으로 나타낼 수 있다.
$$R={1\over F_0}\,(1-x\,\bar F\,R).$$
그래서 |R|을 둘로 쪼개어 한 가지를 오른쪽 식에 도로 넣는다. 계수 $F_0$을 읽고 나면
|F|에는 $\bar F$가 남는다. 첫 항은 $1/F_0$이고, 나머지 항은 $\bar F\,R$에 $-1/F_0$을
곱한 것이다. 인수 $x$는 따로 |Xmul|을 부르지 않아도, 첫 항을 먼저 보낸 뒤 |copyPS|로
넘기는 것만으로 한 자리 밀리므로 저절로 처리된다.

@<공개 함수들@>=
func Recip(F PS) PS {
	R := mkPS(F.ctx)
	RR := Split(R, 2)
	go func() {
		if !R.awaitReq() {
			return
		}
		f, ok := F.get() // 이제 $F$에는 $\bar F$가 남는다
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

@ 급수 되돌리기는 역함수를 구한다. 함수 |Rev|는 $F_0=0$이고 $F_1\ne0$인 급수 $F$를
받아, $F(R(x))=x$를 만족하는 급수 $R$을 돌려준다. 이제 $R=x\bar R$로 적으면 맥일로이의
식~(8)에서
$$\bar R={1\over F_1}\,\bigl(1-x\,\bar R^2\,\bar{\bar F}(R)\bigr)$$
이 나온다. 오른쪽에 $R$이 세 번 나오므로($\bar R^2$에 두 번, 합성 안에 한 번), |R|을
네 갈래로 쪼개어 셋은 이 정의에 쓰고 하나는 부르는 쪽에 돌려준다.

@<공개 함수들@>=
func Rev(F PS) PS {
	R := mkPS(F.ctx)
	RR := Split(R, 4)
	go func() {
		if !R.put(rat(0, 1)) { // $R_0 = 0$
			return
		}
		if !R.awaitReq() {
			return
		}
		if _, ok := F.get(); !ok { // $F_0$을 버린다(0이어야 한다)
			return
		}
		v, ok := F.get() // 이제 $F$에는 $\bar{\bar F}$가 남는다
		if !ok {
			return
		}
		f1 := rinv(v)
		if !R.send(f1) { // $R_1 = 1/F_1$
			return
		}
		W := Mul(Mul(tail(RR[0]), tail(RR[1])), Subst(F, RR[2])) // ${\bar R}^2 \cdot \bar{\bar F}(R)$
		c := rneg(f1)
		@<|R|의 남은 계수를 내보낸다@>@;
	}()
	return RR[3]
}

@ 첫 두 계수 $R_0=0$과 $R_1=1/F_1$은 이미 보냈다. 그다음 계수부터는 저마다 급수
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

@ 끝으로 함수 |tail|은 |F|의 상수항을 버려 꼬리 $\bar F$를 내놓는다. 맥일로이가
윗줄을 그어 나타내는 연산으로, 바로 앞에서 $R$로부터 $\bar R$을 얻는 데 썼다.

@<내부 함수들@>=
func tail(F PS) PS {
	T := mkPS(F.ctx)
	go func() {
		if !T.awaitReq() {
			return
		}
		if _, ok := F.get(); !ok { // 상수항을 버린다
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
고루틴 그물이 시험이 끝날 때 함께 정리된다.

@<시험 도우미@>=
func newCtx(t *testing.T) context.Context {
	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)
	return ctx
}

@ 함수 |checkTerms|는 급수 |F|의 앞쪽 계수들을 기댓값과 비교한다. 기댓값은 |"1"|,
|"-1/3"|처럼 문자열로 준다.

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

@* 놀이터.
이제 놀아 보자. \GO/의 시험 꾸러미는 이름이 \.{Example}로 시작하는 함수를 {\it
보기\/}로 다룬다. 보기가 표준 출력에 찍은 것을 함수 끝의 주석 \.{// Output:}과
견주므로, 보기는 문서이면서 시험이기도 하다. 보기마다 문맥을 만들고 끝날 때 |cancel|로
그물을 거두는 것도 눈여겨보자. 함수 |printTerms|는 급수의 앞쪽 계수 |n|개를 한 줄에
찍는다.

@<시험 도우미@>=
func printTerms(F PS, n int) {
	for i, c := range F.Take(n) {
		if i > 0 {
			fmt.Print(" ")
		}
		fmt.Print(c.RatString())
	}
	fmt.Println()
}

@ 먼저 서문에서 약속한 지수 함수다. 함수 |Exp|에 급수 $x$를 주면 $e^x$가 나오고, 그
계수는 $1/n!$이다.

@<보기@>=
func ExampleExp() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	printTerms(Exp(X(ctx)), 8)
	// Output: 1 1 1/2 1/6 1/24 1/120 1/720 1/5040
}

@ 서문에서 약속한 또 하나, 탄젠트다. 함수 $T=\tan x$는 $T'=1+T^2$과 $T(0)=0$을
만족하므로 고정점 방정식 $T=\int(1+T\cdot T)\,dx$의 해다. 함수 |Fix|가 건네는
|T|를 |Mul|에 두 번 넘길 수는 없다. 채널은 한 번 읽으면 사라지기 때문이다. 그래서
|Split|으로 먼저 둘로 가른다. 미분 방정식 하나가 코드 세 줄이 된다.

@<보기@>=
func ExampleFix() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	tan := Fix(ctx, func(T PS) PS {
		TT := Split(T, 2)
		return Integ(rat(0, 1), Add(Series(ctx, rat(1, 1)), Mul(TT[0], TT[1])))
	})
	printTerms(tan, 10)
	// Output: 0 1 0 1/3 0 2/15 0 17/315 0 62/2835
}

@ 고정점은 미분 방정식에만 쓰이지 않는다. 괄호 $n$쌍을 짝이 맞게 늘어놓는 가짓수인
카탈랑 수의 생성 함수 $C$는 $C=1+x\,C^2$을 만족한다. 이것도 받아 적기만 하면 된다.
식의 맨 앞 항~$1$은 |Series|가 아무것도 읽지 않고 내놓으므로 고리는 생산적이다.

@<보기@>=
func ExampleFix_catalan() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	cat := Fix(ctx, func(C PS) PS {
		CC := Split(C, 2)
		return Add(Series(ctx, rat(1, 1)), Xmul(Mul(CC[0], CC[1])))
	})
	printTerms(cat, 10)
	// Output: 1 1 2 5 14 42 132 429 1430 4862
}

@ 아크탄젠트는 $1/(1+x^2)$의 적분이다. 함수 |Msubst|로 $1/(1-x)$에 $-x^2$을 넣고
적분하면 된다.

@<보기@>=
func ExampleMsubst() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	atan := Integ(rat(0, 1), Msubst(Ones(ctx), rat(-1, 1), 2))
	printTerms(atan, 10)
	// Output: 0 1 0 -1/3 0 1/5 0 -1/7 0 1/9
}

@ 끝으로 아크탄젠트를 되돌리면 그 역함수인 탄젠트가 나와야 한다. 정말로 앞에서
미분 방정식으로 얻은 것과 같은 계수가 나온다. 전혀 다른 두 길이 같은 곳에 닿는
것을 보는 것은 언제나 즐겁다.

@<보기@>=
func ExampleRev() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	atan := Integ(rat(0, 1), Msubst(Ones(ctx), rat(-1, 1), 2))
	printTerms(Rev(atan), 10)
	// Output: 0 1 0 1/3 0 2/15 0 17/315 0 62/2835
}

@* 색인.
