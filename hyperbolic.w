\input kotexgweb
\input luamplib.sty

% 그림들은 hyperbolic.mp 안에 fig_... 라는 이름으로 있다. 그 가운데 셋은
% 이 프로그램 자신이 hyperbolic-arcs.mp 에 적어 넣은 것이다.
\everymplib{input hyperbolic;}

\def\title{쌍곡 모눈종이}

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}
\def\dts{\mathinner{\ldotp\ldotp}}

@* 들어가며.
유클리드의 다섯째 공준---한 직선과 그 밖의 한 점이 주어지면 그 점을 지나면서
직선과 만나지 않는 직선은 오직 하나라는 것---은 이천 년 동안 기하학자들을
괴롭혔다. 앞의 넷에서 이것을 이끌어 내려는 시도가 줄을 이었다. 1733년,
이탈리아의 예수회 신부 Giovanni Saccheri는 {\it 모든 흠에서 벗어난 유클리드\/}라는
책을 내어 다섯째 공준을 부정하면 모순이 나온다는 것을 보이려 했다. 그는 그 부정에서
정리를 한참 이끌어 냈는데, 끝내 모순은 나오지 않았다. 그가 손에 쥔 것은 사실 새
기하학의 정리들이었다. 그런데도 그는 ``이는 직선의 본성에 어긋난다''고 적고
물러섰다. 신대륙에 발을 딛고도 되돌아 나온 셈이다.

@ Gauss는 젊어서 이미 알고 있었으나 발표하지 않았다. 1829년 Bessel에게 보낸
편지에 ``보이오티아 사람들의 아우성이 두렵다''고 적었다---그리스에서 보이오티아는
아둔함의 대명사였다. 헝가리의 Bolyai János는 1823년 아버지에게 ``무에서 이상하고
새로운 세계를 만들어 냈습니다''라고 알렸고, 러시아의 Lobachevsky는 1829년 카잔에서
먼저 활자로 찍어 냈다. Clifford는 뒷날 그를 ``기하학의 코페르니쿠스''라고 불렀다.

그 새 세계에서는 삼각형 세 각의 합이 $180^\circ$에 못 미친다. 늘 모자라고, 모자란
만큼이 곧 그 삼각형의 넓이다. 그래서 유클리드 평면에서는 될 수 없는 일이 된다:
각이 $36^\circ$, $45^\circ$, $90^\circ$인 삼각형만으로 평면 전체를 빈틈없이 덮을
수 있다. 그렇게 덮는 방법은 오직 하나뿐인데, 그것을 {\it 보는\/} 방법은 여럿이다.

@ 이 프로그램은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{hyperbolic.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/hyperbolic.w}를
\.{GWEB}으로 옮긴 것이다. 하는 일은 그 덮기의 좌표를 실제로 셈해서, 가지고 놀
{\it 모눈종이\/}를 만드는 것이다.

크누스가 이 프로그램을 지은 까닭은 Maurice Margenstern이 꼭짓점에 피보나치 표현으로
번호를 매긴 방법에 홀렸기 때문이다. Francine Herrmann과 Maurice Margenstern,
``A universal cellular automaton in the hyperbolic plane,'' {\sl Theoretical
Computer Science\/} {\bf 296} (2003), 327--364의 6절에 그 방법이 있다. 크누스는
이렇게 적었다: ``재미로, 그리고 경험 삼아 쓴다. 그래서 기본적인 무차별 대입을
쓰되, 무늬를 국소적으로도 전체적으로도 이해하는 데 도움이 될 만한 자료 구조를
곁들인다.''

@ 뼈대는 단순하다. 삼각형 하나를 놓고, 아직 모자라면 이미 아는 삼각형의 이웃을
차례로 구해 나간다. 그것이 전부다. 마지막에, 명령줄에 이름을 하나 주면 그림을
그릴 MetaPost 파일을 그 이름으로 적어 준다.

@c
package main

import (
	"fmt"
	"math"
	"os"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<첫 삼각형을 놓는다@>@;
	for k := 0; tptr < maxn; k++ {
		@<삼각형 |k|의 이웃을 구한다@>@;
	}
	@<그림 파일을 쓴다@>@;
}

@ 삼각형을 삼백 개쯤 구하면 볼 것은 다 본다. 소수 |hprime|은 해시표의 크기인데,
삼각형 하나가 표에 한 칸을 차지하니 넉넉히 두 배는 되어야 한다.

크누스는 꼭짓점 세 개의 번호를 열 비트씩 끊어 낱말 하나에 밀어 넣었다. 그래서
$3\cdot|maxn|<1024$라는 조건이 붙는다. 그때 그의 컴퓨터가 32비트였기 때문인데,
우리도 그대로 따랐다---조건을 지키는 한 아무 손해가 없고, 표를 뒤지는 일이
정수 하나 견주기로 끝난다.

@<상수@>=
const (
	maxn   = 300      // 셈해 낼 삼각형의 수. $3\cdot|maxn|<1024$이어야 한다
	hprime = 1009     // 소수. $2\cdot|maxn|$ 이상이어야 한다
	eps    = 0.000001 // 견줄 때 눈감아 줄 오차
)

@* 위 반평면. 쌍곡 평면을 종이에 그리려면 모형이 필요하다. Beltrami가 1868년에
처음 만들었고 Klein과 Poincaré가 뒤를 이었는데, 여기서 쓰는 것은 {\it 위 반평면\/}
모형이다. 점이란 $y>0$인 $(x,y)$이고, `직선'이란 $x$축에 중심을 둔 반원, 곧 어떤
중심~$c$와 반지름~$r>0$에 대해 $\theta$가 $0$에서 $\pi$까지 갈 때의 점
$(c+r\cos\theta,\;r\sin\theta)$들이다. 그러니 점 $(x,y)$ 하나와 각~$\theta$ 하나를
주면 거기를 그 방향으로 지나는 쌍곡 직선이 하나 정해진다:
$$c=x-y\cot\theta,\qquad r=y\csc\theta.$$

@<자료형@>=
type point struct{ x, y float64 }
type circle struct{ c, r float64 }

@ 두 점 $(x,y)$와 $(x',y')$을 지나는 쌍곡 직선은 하나뿐이고, 그 중심은
$$c={x^2+y^2-{x'}^2-{y'}^2\over 2(x-x')}
   ={x+x'\over2}+{y^2-{y'}^2\over2(x-x')}$$
이다. 오른쪽 꼴이 셈하기 좋다. ($x=x'$이면 $c=\infty$가 되어 `원'이 실은 곧은
세로선인데, 이 프로그램에서는 그런 일이 한 번밖에 없고 그것마저 따로 다루므로
걱정하지 않아도 된다.)

@<함수들@>=
func common(z, w point) circle {
	var t circle
	t.c = (z.x+w.x)/2 + ((z.y+w.y)/2)*((z.y-w.y)/(z.x-w.x))
	if math.Abs(t.c) < 0.00001 {
		t.c = 0
	}
	t.r = math.Sqrt((z.x-t.c)*(z.x-t.c) + z.y*z.y)
	return t
}

@* 되비추기. 이 프로그램에서 가장 중요한 셈은 점 하나를 쌍곡 직선에 대해
{\it 되비추는\/} 것이다. 직선의 중심이~$c$이고 반지름이~$r$일 때,
$(c+s\cos\theta,\;s\sin\theta)$의 되비침은 $st=r^2$인~$t$를 써서
$(c+t\cos\theta,\;t\sin\theta)$로 정한다. 이것이 쌍곡 평면의 자기동형사상이라는
것을 보일 수 있다. 유클리드 기하로 보면 원에 대한 반전(inversion)인데, 쌍곡
기하로 보면 거울에 비추는 것이다.

@<함수들@>=
func reflect(z point, l circle) point {
	alpha := l.r * l.r / ((z.x-l.c)*(z.x-l.c) + z.y*z.y)
	return point{l.c + alpha*(z.x-l.c), alpha * z.y}
}

@ 되비추기에 마음을 쓰는 까닭은 이렇다. 우리가 구하려는 덮기에서 삼각형 하나는
이웃을 셋 가진다. 그리고 그 이웃들은 각각 꼭짓점 하나를 맞은편 변에 대해
되비추어 얻어진다. 아래 삼각형 $ABC$를 보자.
$$\mplibcode fig_triangle; \endmplibcode$$
이웃 $A'BC$, $AB'C$, $ABC'$은 $A$를 $BC$에, $B$를 $C\!A$에, $C$를 $AB$에
되비추어 나온다. 이 짓을 되풀이하면 무늬 전체가 자란다.

@ 그림을 자세히 보면 이 무늬가 어떻게 생겼는지가 드러난다. 꼭짓점 하나를 둘러싼
각의 합은 어디서나 $360^\circ$여야 하므로, $A$ 둘레에는 삼각형이 넷, $B$ 둘레에는
여덟, $C$ 둘레에는 열 개가 모인다. 유클리드 평면이었다면 세 각의 합이
$180^\circ$라 이런 일이 아예 불가능하다.

쌍곡 평면에서는 세 각의 합이 늘 $180^\circ$보다 {\it 작고\/}, Gauss--Bonnet
정리에 따르면 모자란 만큼이 곧 넓이다. 우리 삼각형은
$$\pi-\left({\pi\over5}+{\pi\over4}+{\pi\over2}\right)={\pi\over20}$$
이니, 넓이가 정확히 $\pi/20$이다. 쌍곡 평면에서는 각만 보고 넓이를 안다.

@ 열 개가 $C$ 둘레에 모인다는 말에는 더 예쁜 뜻이 있다. 정오각형 하나를 가운데
점에서 다섯 꼭짓점과 다섯 변의 중점으로 갈라 보면 직각삼각형 열 개가 나오는데,
그 각이 바로 가운데에서 $360/10=36^\circ$, 꼭짓점에서 $90/2=45^\circ$, 변의
중점에서 $90^\circ$다. 곧 우리 무늬는 {\it 한 꼭짓점에 정오각형 넷이 모이는\/}
덮기를 잘게 쪼갠 것이다. Margenstern이 {\it 펜타그리드\/}라 부르며 세포 자동자를
돌린 바로 그 격자다. 오각형이 나오니 곧 보게 될 시작 좌표에 황금비가 나오는 것도
당연하다.

@ 덧붙이자면, 이 프로그램은 반지름 $r$이 아니라 $r^2$만 쓴다. 그러니 |circle|에
$r^2$을 담아 두어도 되었을 것이다. 크누스도 그 점을 적어 두었지만 ``이 물건을
들여다볼 때는 $r^2$보다 $r$이 편해서'' 그대로 두었다고 했다. 우리도 그대로 둔다.

@* 아는 것을 적어 두기. 알고리즘이 나아가는 동안 이미 본 점과 원이 자꾸 다시
나온다. 그러니 아는 것을 적어 두는 사전이 있어야 한다.

크누스는 처음에 해시표를 써 보았다가 그만두었다. 값이 꼭 같지는 않고 {\it 거의\/}
같은 경우를 한 칸으로 봐야 하는데, 해시는 그것을 못한다. 그래서 이분 검색 나무를
쓴다. 실제로 같아야 할 값들은 대개 $10^{-16}$ 안팎까지 맞아떨어졌고, 딱 떨어지는
일은 오히려 드물었다. 오차가 $10^{-11}$을 넘은 경우는 단 둘뿐이었으며 그때도
$1.1\times10^{-10}$ 정도였다.

@ 아래 두 함수는 주어진 점 또는 원이 사전의 몇 번인지를 돌려준다. 없으면 새로
적어 넣고 그 번호를 준다. 새로 적을 때마다 한 줄씩 찍어 두는데, 뒤에서 그림을
그릴 때 쓰는 좌표가 바로 이 번호들이다.

가지를 고르는 규칙이 좀 별나다. 먼저 $x$가 |eps| 안에서 같은지 보고, 같으면 $y$로
가르고, 다르면 $x$로 가른다. 이 순서 매기기는 엄밀히 말해 추이적이지 않다. 하지만
가까운 값을 한 칸으로 보려면 어차피 그런 값을 치러야 하고, 실제로 잘 듣는다.

@<함수들@>=
func savepoint(z point) int {
	q := &pleft[0]
	for p := *q; p != 0; p = *q {
		if math.Abs(hpoint[p].x-z.x) < eps {
			if math.Abs(hpoint[p].y-z.y) < eps {
				return p
			}
			if hpoint[p].y < z.y {
				q = &pleft[p]
			} else {
				q = &pright[p]
			}
		} else if hpoint[p].x < z.x {
			q = &pleft[p]
		} else {
			q = &pright[p]
		}
	}
	pptr++
	*q = pptr
	hpoint[pptr] = z
	fmt.Printf("z%d=(%.15g,%.15g)\n", pptr, z.x, z.y)
	return pptr
}

@ 원 쪽도 똑같다. 중심~$c$가 $x$ 노릇을, 반지름~$r$이 $y$ 노릇을 한다.

@<함수들@>=
func savecircle(l circle) int {
	q := &cleft[0]
	for p := *q; p != 0; p = *q {
		if math.Abs(hcircle[p].c-l.c) < eps {
			if math.Abs(hcircle[p].r-l.r) < eps {
				return p
			}
			if hcircle[p].r < l.r {
				q = &cleft[p]
			} else {
				q = &cright[p]
			}
		} else if hcircle[p].c < l.c {
			q = &cleft[p]
		} else {
			q = &cright[p]
		}
	}
	cptr++
	*q = cptr
	hcircle[cptr] = l
	fmt.Printf("l%d=(%.15g,%.15g)\n", cptr, l.c, l.r)
	return cptr
}

@ 나무의 뿌리는 |pleft[0]|과 |cleft[0]|에 둔다. 그래서 $0$번 칸은 점으로도 원으로도
쓰이지 않고, 번호는 $1$부터 매겨진다.

@<전역 변수@>=
var (
	hpoint        [3 * maxn]point  // 알고 있는 점들
	pptr          int              // 그 수
	pleft, pright [3 * maxn]int    // 이분 검색 나무의 이음줄
	hcircle       [3 * maxn]circle // 알고 있는 쌍곡 직선들
	cptr          int              // 그 수
	cleft, cright [3 * maxn]int
)

@* 삼각형 표. 자료 구조의 알맹이는 지금까지 알아낸 삼각형들의 표다. 삼각형 하나는
꼭짓점 셋, 변 셋, 이웃 셋을 가리키는 번호로 적힌다.

크누스는 이것들을 |v36|, |v45|, |v90|처럼 아홉 개의 이름 있는 항목으로 두고 뒤의
알고리즘도 세 벌로 나누어 적었다. 여기서는 첨자 셋으로 묶었다. 그러면 세 벌이
한 벌로 줄고, 세 벌을 견주어야 겨우 보이던 규칙이 눈에 드러난다. 규칙은 이렇다:
{\it 변 $j$는 꼭짓점 $j$의 맞은편이다.\/}

@<자료형@>=
type triangle struct {
	v [3]int // 꼭짓점이 |hpoint|의 몇 번인가
	e [3]int // 맞은편 변이 |hcircle|의 몇 번인가
	t [3]int // 그 변 너머 이웃이 |triang|의 몇 번인가
}

@ 첨자 $0$, $1$, $2$는 각각 $36^\circ$, $45^\circ$, $90^\circ$ 꼭짓점을 가리킨다.
이름을 붙여 두면 첫 삼각형을 놓을 때 읽기가 좋다.

@<상수@>=
const (
	a36 = 0
	a45 = 1
	a90 = 2
)

@ 표~|rest|는 ``$0,1,2$ 가운데 하나를 뺀 나머지 둘''을 커지는 차례로 적어 둔
것인데, 쓸모가 둘이다. |rest[i]|는 변~$i$ 말고 남은 두 변이고, |rest[j]|는 또한
변~$j$의 양 끝 꼭짓점이다. 위에 적은 규칙이 바로 이 한 표를 두 번 쓰게 해 준다.
표~|angle|은 이웃을 알릴 때 쓰는 이름이다.

@<전역 변수@>=
var (
	rest  = [3][2]int{{1, 2}, {0, 2}, {0, 1}}
	angle = [3]string{"36", "45", "90"}
)

@ 본 적 있는 삼각형은 해시표로 가려낸다. 꼭짓점 세 번호를 열 비트씩 이어 붙여
낱말~|w|를 만들고, 그것으로 표를 뒤진다. 부딪히면 한 칸씩 아래로 내려가며 찾는다.

@<함수들@>=
func savetriangle(v0, v1, v2 int) int {
	w := uint32(((v0<<10)+v1)<<10 + v2)
	h := int(w % hprime)
	for triple[h] != 0 {
		if triple[h] == w {
			return tripnum[h]
		}
		if h == 0 {
			h = hprime
		}
		h--
	}
	triple[h], tripnum[h] = w, tptr
	triang[tptr].v = [3]int{v0, v1, v2}
	tptr++
	return tripnum[h]
}

@ 삼각형을 담는 자리를 |maxn|보다 셋 넉넉히 잡는 까닭은, 바깥 반복문이 |tptr|을
살펴 멈추는데 한 바퀴 도는 동안 삼각형이 셋까지 늘 수 있기 때문이다.

@<전역 변수@>=
var (
	triple  [hprime]uint32 // 본 적 있는 꼭짓점 세 쌍
	tripnum [hprime]int    // 그 일련번호
	tptr    int            // 본 삼각형의 수
	triang  [maxn + 3]triangle
)

@* 첫 삼각형. 마중물로 $36^\circ$-$45^\circ$-$90^\circ$ 삼각형 하나가 있어야 한다.
가장 만만한 것은 복소평면에서 꼭짓점이 $e^{i\theta}$, $i/r$, $i$인 것인데, 여기서
$$r=\sqrt{\phi+\sqrt{\phi}},\qquad \cos\theta=1/\sqrt{\mskip1mu2\phi}$$
이고 $\phi=(1+\sqrt5\,)/2$는 황금비다. 오각형이 숨어 있으니 황금비가 나온다.

@<첫 삼각형을 놓는다@>=
	phi := (1 + math.Sqrt(5)) / 2
	a := savepoint(point{math.Sqrt(0.5 / phi), math.Sqrt(1 - 0.5/phi)})
	b := savepoint(point{0, 1 / math.Sqrt(phi+math.Sqrt(phi))})
	c := savepoint(point{0, 1})
	inner = hpoint[b].y
	@<0번 삼각형의 변을 구한다@>@;
	savetriangle(a, b, c)
	fmt.Printf("삼각형 0 = (z%d,z%d,z%d), 변 (*,%d,%d)\n",
		a, b, c, triang[0].e[a45], triang[0].e[a90])

@ 첫 삼각형의 변~|e36|은 $i/r$에서 $i$로 곧게 올라가는 세로선이다. 이 프로그램에서
곧은 세로선은 이것 하나뿐이다. 이 예외를 다루는 가장 손쉬운 길은 |e36|을 |e45|와
같게 놓아 버리는 것인데, 크누스는 이 수를 두고 ``도덕적으로 정당화하기 어려운
잔꾀''라고 실토했다. 왜 이것이 통하는지는 다음 장에서 밝혀진다.

@<0번 삼각형의 변을 구한다@>=
	triang[0].e[a45] = savecircle(circle{0, 1})
	triang[0].e[a36] = triang[0].e[a45]
	triang[0].e[a90] = savecircle(circle{hpoint[b].y, math.Sqrt2 * hpoint[b].y})

@ 안쪽 반지름 $1/r$은 뒤에서 그림을 그릴 때 다시 쓰이므로 적어 둔다.

@<전역 변수@>=
var inner float64 // 고리의 안쪽 반지름 $1/r$

@* 이웃 찾기. 조각을 맞추기 전에 밝혀 둘 것이 하나 있다. 우리는 무늬 {\it 전체\/}를
셈하지 않는다. 셈하는 것은 $\vert z\vert=1$과 $\vert z\vert=1/r$ 사이의 고리 가운데
복소평면 오른쪽 위 사분면에 든 부분뿐이다.

그것으로 충분한 까닭은 이렇다. 이 고리와 그다음 고리---$\vert z\vert=1/r$과
$\vert z\vert=1/r^2$ 사이---의 무늬는 서로 $\vert z\vert=1/r$에 대한 되비침이다.
그다음 고리의 무늬는 첫 고리를 $1/r^2$배로 줄인 것이고, 그다음은 또 그만큼
줄인 것이다. 그러니 고리 하나만 알면 나머지는 공짜다.

@ 고리로 가두는 일은 놀랄 만큼 싸게 든다. 중심~$c$가 $0$인 변 너머로는 이웃을
구하지 않으면 그만이다. 앞 장의 잔꾀가 통하는 것도 이 때문이다: 세로선 |e36|에
|e45|의 값 $(0,1)$을 넣어 두었으니 $c=0$이고, 따라서 그 너머는 애초에 넘겨다보지
않는다. 첫 삼각형이 세로 변을 가진 유일한 삼각형인 것도 같은 이유다.

@<삼각형 |k|의 이웃을 구한다@>=
	for i := 0; i < 3; i++ {
		if hcircle[triang[k].e[i]].c == 0 {
			continue
		}
		@<변 |i| 너머의 이웃을 구한다@>@;
	}
	@<이웃을 알린다@>@;

@ 꼭짓점~|i|를 맞은편 변에 되비추면 이웃 삼각형의 새 꼭짓점이 나온다. 나머지 두
꼭짓점은 그대로다. 그렇게 만든 세 쌍을 표에 넣어 보아 |tptr|이 늘었으면 처음 보는
삼각형이니 변까지 마저 구해 준다.

@<변 |i| 너머의 이웃을 구한다@>=
		vv := triang[k].v
		vv[i] = savepoint(reflect(hpoint[vv[i]], hcircle[triang[k].e[i]]))
		t := tptr
		triang[k].t[i] = savetriangle(vv[0], vv[1], vv[2])
		if tptr > t {
			@<새로 생긴 삼각형의 변을 구한다@>@;
		}

@ 새 삼각형은 변~|i|를 우리와 나눠 가진다. 남은 두 변은 새로 그어야 하는데,
변~$j$는 꼭짓점~$j$의 맞은편이니 나머지 두 꼭짓점을 잇는 쌍곡 직선이다. 그것이
바로 |rest| 표를 두 번 쓰는 대목이다.

@<새로 생긴 삼각형의 변을 구한다@>=
			triang[t].e[i] = triang[k].e[i]
			for _, j := range rest[i] {
				triang[t].e[j] = savecircle(common(
					hpoint[triang[t].v[rest[j][0]]],
					hpoint[triang[t].v[rest[j][1]]]))
			}
			@<새 삼각형을 알린다@>@;

@ @<새 삼각형을 알린다@>=
			fmt.Printf("삼각형 %d = (z%d,z%d,z%d), 변 (%d,%d,%d)\n", t,
				triang[t].v[0], triang[t].v[1], triang[t].v[2],
				triang[t].e[0], triang[t].e[1], triang[t].e[2])

@ 고리 밖으로 나가는 변은 이웃을 구하지 않았으니 알리지도 않는다.

@<이웃을 알린다@>=
	fmt.Printf("삼각형 %d의 이웃:", k)
	for i := 0; i < 3; i++ {
		if hcircle[triang[k].e[i]].c != 0 {
			fmt.Printf(" t%s=%d", angle[i], triang[k].t[i])
		}
	}
	fmt.Printf("\n")

@* 그림 그리기. 여기서부터는 원본에 없는 부분이다. 크누스는 프로그램이 뱉은
좌표를 손으로 골라 \.{hyperbolic.mp}에 옮겨 적었다. 그림 셋에 걸쳐 원이 육백
예순일곱 개다. 우리는 프로그램에게 그 일을 시킨다.

@<그림 파일을 쓴다@>=
	if len(os.Args) > 1 {
		@<메타포스트 파일을 만든다@>@;
	}

@ 파일에는 그림 셋이 |fig_annulus|, |fig_dual|, |fig_tiling|이라는 이름으로 들어간다.
그림을 오른쪽 위 사분원으로 잘라 내고 테두리를 두르는 일은 \.{hyperbolic.mp}에
|quarter|라는 매크로로 있으므로, 여기서는 반원 목록만 적으면 된다.

@<메타포스트 파일을 만든다@>=
		f, err := os.Create(os.Args[1])
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		defer f.Close()
		fmt.Fprint(f, mphead)
		@<고리 하나를 그린다@>@;
		@<안쪽 고리를 그린다@>@;
		@<반평면 전체를 그린다@>@;

@ @<상수@>=
const mphead = `% hyperbolic.go 가 적은 파일이다. 손대지 말 것.
% hyperbolic.mp 가 이것을 input 한다.
`

@ 반원 하나를 적는 일은 세 그림 모두에서 하므로 함수로 둔다. 자릿수는 여섯이면
넉넉하다---그림 한 장이 겨우 몇 인치인데 그보다 잘게 나눌 방법이 없다.

@<함수들@>=
func arcout(f *os.File, l circle) {
	fmt.Fprintf(f, " arc(%.6g,%.6g)\n", l.c, l.r)
}

@ 첫 그림은 우리가 셈해 낸 쌍곡 직선을 그대로 그린 것이다. $1$번만 빼는데,
그것이 바로 고리의 바깥 테두리 $\vert z\vert=1$ 자신이기 때문이다. 테두리는
|quarter|가 따로 그린다.

@<고리 하나를 그린다@>=
		fmt.Fprintln(f, "def fig_annulus =\nbeginfig(2);")
		for i := 2; i <= cptr; i++ {
			arcout(f, hcircle[i])
		}
		fmt.Fprintln(f, " quarter;\nendfig;\nenddef;")

@ 둘째 그림은 같은 직선들을 $\vert z\vert=1/r$에 대해 되비춘 것---곧 안쪽 고리의
무늬다. 중심이~$c$, 반지름이~$\rho$인 원을 원점 중심 반지름~$R$인 원에 대해
반전시키면 중심과 반지름이
$$c'={R^2c\over c^2-\rho^2},\qquad \rho'=\left\vert{R^2\rho\over c^2-\rho^2}
\right\vert$$
인 원이 된다. 여기서는 $R=1/r$이다.

@<함수들@>=
func invert(l circle) circle {
	d := l.c*l.c - l.r*l.r
	return circle{inner * inner * l.c / d, math.Abs(inner * inner * l.r / d)}
}

@ 이번에는 하나도 빼지 않는다. $1$번 직선의 되비침은 $\vert z\vert=1/r^2$이라는
어엿한 원이라 그릴 값이 있다.

@<안쪽 고리를 그린다@>=
		fmt.Fprintln(f, "def fig_dual =\nbeginfig(3);")
		for i := 1; i <= cptr; i++ {
			arcout(f, invert(hcircle[i]))
		}
		fmt.Fprintln(f, " quarter;\nendfig;\nenddef;")

@ 셋째 그림은 앞의 두 벌을 모두 가져다 놓고, 각각을 $1/r^2$배씩 거듭 줄여 원점
쪽으로 무한히 이어 붙인 것이다. 반지름이 $0.007$보다 작아지면 종이 위에서 잉크
얼룩과 구별되지 않으므로 거기서 멈춘다.@^Bond, James@>

(하필 $0.007$인 까닭이 궁금하다면, 크누스가 원본의 바로 이 대목에 붙여 둔 색인
항목을 보라. `Bond, James'다.)

@<반평면 전체를 그린다@>=
		fmt.Fprintln(f, "def fig_tiling =\nbeginfig(4);")
		for i := 1; i <= cptr; i++ {
			shrink(f, hcircle[i], i == 1)
			shrink(f, invert(hcircle[i]), false)
		}
		fmt.Fprintln(f, " quarter;\nendfig;\nenddef;")

@ 첫 그림에서 $1$번 직선을 뺐던 것과 같은 까닭으로, 여기서도 그 첫 항 하나만
건너뛴다. 줄인 것들은 모두 그린다.

@<함수들@>=
func shrink(f *os.File, l circle, skip bool) {
	q := inner * inner
	for ; l.r >= 0.007; l.c, l.r = l.c*q, l.r*q {
		if skip {
			skip = false
			continue
		}
		arcout(f, l)
	}
}

@* 돌려 보기. 돌리는 법은 이렇다.
$$\vbox{\halign{\.{#}\hfil\cr
go run hyperbolic.go hyperbolic-arcs.mp\cr}}$$
점 $214$개와 쌍곡 직선 $131$개, 삼각형 $301$개가 나온다. 눈 깜짝할 새다.

@ 크누스의 원본과 견주면 점과 원과 삼각형에 붙는 번호가 처음부터 끝까지 하나도
어긋나지 않는다. 그런데 좌표 값 자체는 절반쯤이 마지막 한두 자리에서 갈린다.
컴파일러가 $a\times b+c$를 곱셈과 덧셈 둘로 하느냐 융합 곱셈--덧셈 명령 하나로
하느냐를 저마다 다르게 고르기 때문인데, 실제로 \CEE/ 쪽도 그 선택을 끄고 다시
컴파일하면 자기 자신과 달라진다. 어긋나는 폭은 가장 큰 것이 상대오차
$3.3\times10^{-13}$이었다.

그래도 결과가 한 톨도 흔들리지 않는 까닭은 사전이 $10^{-6}$ 안에서 같은 값을 한
칸으로 보기 때문이다. 크누스가 해시표를 버리고 흐릿한 이분 나무를 고른 것은 자기
컴퓨터에서 값이 딱 떨어지지 않아서였는데, 덕분에 이 프로그램은 삼십 년 뒤 다른
언어 다른 기계로 옮겨 놓아도 같은 무늬를 그린다. 그림에 적히는 여섯 자리는
육백예순일곱 개가 모두 그가 손으로 옮겨 적은 것과 한 글자도 다르지 않다.

@ 첫 그림, 고리 하나에 놓인 무늬다. 바깥 테두리가 $\vert z\vert=1$, 안쪽으로
비어 보이는 곳의 경계가 $\vert z\vert=1/r\approx0.588$이다.
$$\mplibcode fig_annulus; \endmplibcode$$

@ 이것을 $\vert z\vert=1/r$에 대해 되비추면 안쪽 고리의 무늬가 된다. 바깥쪽이
비고 안쪽이 찬 것이 앞 그림과 정확히 뒤바뀌었다.
$$\mplibcode fig_dual; \endmplibcode$$

@ 그리고 둘을 모두 놓고 원점 쪽으로 거듭 줄여 이어 붙이면 오른쪽 반평면 전체의
무늬가 된다. 경계인 $x$축에 다가갈수록 삼각형이 잘아 보이지만, 쌍곡 자로 재면
모두 넓이가 꼭 같은 $\pi/20$이다. 작아 보이는 것은 종이의 사정일 뿐이다.
$$\mplibcode fig_tiling; \endmplibcode$$

@ 이런 그림을 처음 세상에 알린 사람은 수학자가 아니라 판화가였다. M. C. Escher는
1957년에 Coxeter가 보낸 쌍곡 덮기 그림 한 장을 보고 {\it 원의 극한\/}(Circle
Limit) 연작을 새겼다. 그는 Coxeter의 논문을 두고 ``저 요술''이라 부르며 수식은
하나도 읽지 못했다고 했지만, 정작 그 무늬가 어떻게 자라는지는 손으로 알아냈다.
Coxeter는 뒷날 Escher가 그은 선이 수학적으로 정확했다고 감탄했다.

크누스가 이 프로그램을 지은 것도 결국 같은 이유일 것이다. 무늬를 이해하는 가장
좋은 길은 그것을 직접 그려 보는 것이다.

@* 색인.
