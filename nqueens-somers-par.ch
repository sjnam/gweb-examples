이 변경 파일은 소머즈의 N 여왕 셈을 고루틴 여럿으로 나누어 돌린다. 탐색 나무에서
첫 두 줄의 여왕을 정하면 그 아래는 서로 독립인 부분 나무이므로, 그 짝들을 작업으로
늘어놓고 일꾼 고루틴들이 원자적 계수기로 하나씩 받아 간다. 결정적인 반복문은 한
글자도 바꾸지 않는다. 일꾼 안에 같은 이름의 지역 변수를 두고 그 절을 그대로 끼운다.
판 찍기(-p)는 뺐다. 적용:

    gtangle nqueens-somers.w nqueens-somers-par.ch   (-> 병렬 nqueens-somers.go)
    ./nqueens-somers 18 [workers]                   (workers를 빼면 코어 수)

이 기계(코어 10개: 성능 8, 효율 2)에서 N=18이 186초에서 27초로, 7배쯤 준다.
해의 수는 순차판과 같다.

@x
같은 말을 찍는다. 다만 판을 찍는 기능을 명령줄 선택항으로 두었다. 원본에서는
소스의 한 줄을 주석에서 풀어야 했다.
@y
같은 말을 찍는다. 다만 이 병렬판에는 판을 찍는 기능이 없고, 대신 일꾼 고루틴
여럿이 탐색을 나누어 맡는다.
@z

@x
	"os"
	"strconv"
	"time"
@y
	"os"
	"runtime"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
@z

@x
	var printBoards bool   // 해를 판으로 찍을까?
@y
	var workers int        // 일꾼 고루틴의 수
@z

@x
@ 명령줄에는 판의 크기 $N$ 하나를 준다. 그 앞에 \.{-p}를 붙이면 해를 판으로
찍는다. 소머즈는 판을 찍는 판을 \.{nqprint}라는 실행 파일로 따로 내놓았는데,
여기서는 선택항 하나로 합쳤다.

원본은 인자가 틀리면 안내를 찍고 종료 부호 $0$으로 끝난다. 그대로 두었다. 크기를
|atoi|로 읽으므로 수가 아닌 인자는 $0$이 되어 범위 검사에 걸린다. 함수
|strconv.Atoi|도 실패하면 $0$을 돌려주니 같은 일이 일어난다.

@<명령줄을 읽는다@>=
args := os.Args[1:]
if len(args) > 0 && args[0] == "-p" {
	printBoards, args = true, args[1:]
}
if len(args) != 1 {
	@<머리말의 첫 두 줄을 찍는다@>
	fmt.Fprintf(out, "This program calculates the total number of solutions "+
		"to the N Queens problem.\n")
	fmt.Fprintf(out, "Usage: nq [-p] <width of board>\n")
	out.Flush()
	return
}
n, _ = strconv.Atoi(args[0])
if n < minBoard || n > maxBoard {
	fmt.Fprintf(out, "Width of board must be between %d and %d, inclusive.\n",
		minBoard, maxBoard)
	out.Flush()
	return
}

@y
@ 명령줄에는 판의 크기 $N$을 주고, 그 뒤에 일꾼 고루틴의 수를 덧붙일 수 있다.
덧붙이지 않으면 |runtime.NumCPU()|, 곧 이 기계의 논리 코어 수만큼 띄운다. 수가
아니거나 $1$보다 작으면 하나로 한다. 판을 찍는 선택항 \.{-p}는 없다. 여러 일꾼이
한꺼번에 찍으면 판이 뒤섞이고, 원본처럼 해의 번호를 매길 수도 없기 때문이다.

원본은 인자가 틀리면 안내를 찍고 종료 부호 $0$으로 끝난다. 그대로 두었다. 크기를
|atoi|로 읽으므로 수가 아닌 인자는 $0$이 되어 범위 검사에 걸린다. 함수
|strconv.Atoi|도 실패하면 $0$을 돌려주니 같은 일이 일어난다.

@<명령줄을 읽는다@>=
args := os.Args[1:]
if len(args) < 1 || len(args) > 2 {
	@<머리말의 첫 두 줄을 찍는다@>
	fmt.Fprintf(out, "This program calculates the total number of solutions "+
		"to the N Queens problem.\n")
	fmt.Fprintf(out, "Usage: nq <width of board> [workers]\n")
	out.Flush()
	return
}
n, _ = strconv.Atoi(args[0])
if n < minBoard || n > maxBoard {
	fmt.Fprintf(out, "Width of board must be between %d and %d, inclusive.\n",
		minBoard, maxBoard)
	out.Flush()
	return
}
workers = runtime.NumCPU()
if len(args) == 2 {
	workers, _ = strconv.Atoi(args[1])
}
if workers < 1 {
	workers = 1
}

@z

@x
@<해를 하나 찾았다@>=
if printBoards {
	@<해와 그 거울상을 찍는다@>
}
numsolutions++
@y
@<해를 하나 찾았다@>=
numsolutions++
@z

@x
	numsolutions = 1 // 거울 논법이 통하지 않는 단 하나의 판
	if printBoards {
		fmt.Fprintf(out, "*** Solution #: 1 ***\nQ \n\n")
	}
@y
	numsolutions = 1 // 거울 논법이 통하지 않는 단 하나의 판
@z

@x
@ 원본의 함수 |Nqueen|이 여기다. 한 곳에서만 부르니 이름 있는 절로 두었다.

배열 이름은 원본의 헝가리식 이름을 줄였다. |queen|은 |aQueenBitRes|, |cols|는
|aQueenBitCol|, |negd|는 |aQueenBitNegDiag|, |posd|는 |aQueenBitPosDiag|,
|stack|은 |aStack|이다. 스택은 파수꾼 하나와 줄마다 하나씩이면 되지만, 원본대로
두 칸을 넉넉히 둔다. 파수꾼 자리에 넣는 |^uint64(0)|은 모든 비트가 1인 수다. 여기서
|^|는 비트를 모두 뒤집는 단항 연산자인데, 이 문서의 코드에는 배타적 논리합과 같은
기호로 찍힌다.

@<소머즈의 방법으로 절반을 세고 두 배 한다@>=
var (
	queen, cols, negd, posd [maxBoard]uint64 // 줄마다
	stack   [maxBoard + 2]uint64            // 줄마다 아직 해 보지 않은 칸
	sp      int                              // 스택의 꼭대기
	numrows int                              // 지금 줄
	lsb     uint64                           // 가장 낮은 1비트
	bitfield uint64                          // 지금 줄에서 해 볼 칸
)
odd := n & 1                // 판의 너비가 홀수면 1
boardMinus := n - 1         // 마지막 줄의 번호
mask := uint64(1)<<n - 1    // 1이 $N$개
stack[0] = ^uint64(0)       // 파수꾼
for i := 0; i < 1+odd; i++ {
	if i == 0 {
		@<첫 줄의 낮은 절반을 연다@>
	} else {
		@<첫 줄 가운데에 여왕을 놓고, 둘째 줄의 낮은 절반을 연다@>
	}
	@<결정적인 반복문@>
}
numsolutions *= 2 // 거울상들을 센다

@y
@ 원본의 함수 |Nqueen|이 여기다. 병렬판에서는 이 절이 일을 나눈다.

탐색 나무에서 첫 두 줄의 여왕을 정하면, 그 아래는 다른 가지와 아무것도 나눠 쓰지
않는 부분 나무다. 그래서 먼저 첫 두 줄의 여왕 짝을 모두 늘어놓아 작업 목록 |tasks|를
만들고, 일꾼 |workers|개가 그것을 하나씩 받아 센다. 첫 줄만으로 나누면 고르지 않다.
$N=16$이면 대칭으로 줄인 첫 줄의 후보가 여덟뿐이고, 가장자리 칸의 부분 나무는
가운데 칸의 것보다 훨씬 작아서 먼저 끝난 일꾼이 논다. 두 줄로 나누면 작업이 백 개
남짓이 되어 고르게 퍼진다. 홀수 판의 두 번째 탐색도 ``가운데 칸과 둘째 줄의 한
칸''으로 똑같이 나뉜다.

작업 목록은 원본의 두 탐색이 시작하는 방식을 그대로 따라 만든다. 그래서 순차판에서
두 탐색의 첫머리를 맡던 두 절이 여기서는 작업을 만드는 절이 된다.

@<소머즈의 방법으로 절반을 세고 두 배 한다@>=
type task struct{ q0, q1 uint64 } // 첫 줄과 둘째 줄의 여왕
var tasks []task
odd := n & 1                // 판의 너비가 홀수면 1
boardMinus := n - 1         // 마지막 줄의 번호
mask := uint64(1)<<n - 1    // 1이 $N$개
for i := 0; i < 1+odd; i++ {
	if i == 0 {
		@<첫 줄의 낮은 절반을 연다@>
	} else {
		@<첫 줄 가운데에 여왕을 놓고, 둘째 줄의 낮은 절반을 연다@>
	}
}
@<일꾼들을 띄워 작업을 나누어 센다@>
numsolutions *= 2 // 거울상들을 센다

@ 일꾼마다 원본의 상태를 통째로 따로 든다. 배열 넷과 스택, 스택의 꼭대기, 지금 줄,
비트열 둘, 그리고 해의 셈이다. 이름을 순차판과 똑같이 지어 두었으니
|@<결정적인 반복문@>|을 한 글자도 바꾸지 않고 일꾼 안에 끼울 수 있다.

배열 이름은 원본의 헝가리식 이름을 줄였다. |queen|은 |aQueenBitRes|, |cols|는
|aQueenBitCol|, |negd|는 |aQueenBitNegDiag|, |posd|는 |aQueenBitPosDiag|,
|stack|은 |aStack|이다. 파수꾼 자리에 넣는 |^uint64(0)|은 모든 비트가 1인 수다.
여기서 |^|는 비트를 모두 뒤집는 단항 연산자인데, 이 문서의 코드에는 배타적 논리합과
같은 기호로 찍힌다.

일꾼의 셈 |numsolutions|는 전역 변수와 이름이 같아서 그것을 가린다. 바로 그 덕에
|@<해를 하나 찾았다@>|의 |numsolutions++|가 일꾼 제 것을 늘린다. 모두 끝나면
일꾼들의 셈을 전역 셈에 더한다. 해 하나마다 공유 변수를 원자적으로 늘리면 여러
코어가 캐시 줄 하나를 두고 다투어 느려진다.

다음 작업은 공유 계수기 |next|를 원자적으로 하나 늘려 받는다. 먼저 끝낸 일꾼이 다음
것을 가져가니, 작업의 크기가 고르지 않아도 균형이 맞는다. 고루틴은
|sync.WaitGroup|의 |Go|로 띄우고, 모두 끝나기를 기다린다.

@<일꾼들을 띄워 작업을 나누어 센다@>=
var wg sync.WaitGroup
var next int64 = -1 // 마지막으로 나누어 준 작업
counts := make([]uint64, workers)
for w := range counts {
	wg.Go(func() {
		var (
			queen, cols, negd, posd [maxBoard]uint64 // 줄마다
			stack        [maxBoard + 2]uint64       // 줄마다 아직 해 보지 않은 칸
			sp, numrows  int                         // 스택의 꼭대기, 지금 줄
			lsb, bitfield uint64                     // 가장 낮은 1비트, 해 볼 칸
			numsolutions uint64                      // 이 일꾼의 셈
		)
		stack[0] = ^uint64(0) // 파수꾼
		for {
			k := int(atomic.AddInt64(&next, 1))
			if k >= len(tasks) {
				break
			}
			@<작업 |tasks[k]|를 받아 셋째 줄에서 시작한다@>
			@<결정적인 반복문@>
		}
		counts[w] = numsolutions
	})
}
wg.Wait()
for _, c := range counts {
	numsolutions += c
}

@ 작업 하나는 첫 두 줄의 여왕 |t.q0|와 |t.q1|을 정해 둔 상태다. 셋째 줄의 세 위협
비트열은 그 둘에서 곧바로 나온다. 둘째 줄의 비트열을 거치지 않고 한 번에 적으면
아래와 같다.

스택에는 파수꾼 위에 $0$을 둘 쌓는다. 첫 두 줄에는 이 작업에서 해 볼 칸이 더
없다는 뜻이다. 그러면 셋째 줄을 다 해 보았을 때 반복문이 $0$ 둘을 꺼내며
올라가다가 파수꾼에 닿아 멈추고, 일꾼은 다음 작업으로 간다. 원본이 홀수 판의 두
번째 탐색에서 쓴 요령을 한 줄 더 넓힌 것이다.

셋째 줄이 마지막 줄인 $N=3$에서도 이대로 맞게 돈다. $N=2$에는 서로 잡지 않는 두
여왕을 첫 두 줄에 놓을 방법이 없으니 작업이 아예 생기지 않는다.

@<작업 |tasks[k]|를 받아 셋째 줄에서 시작한다@>=
t := tasks[k]
cols[2] = t.q0 | t.q1
negd[2] = (t.q0>>1 | t.q1) >> 1
posd[2] = (t.q0<<1 | t.q1) << 1
stack[1], stack[2], sp = 0, 0, 3
numrows = 2
bitfield = mask &^ (cols[2] | negd[2] | posd[2])

@z

@x
@ 첫 번째 탐색은 보통의 탐색과 같되, 첫 줄에서 비트 $0$부터 $\lfloor N/2\rfloor-1$까지만
연다. 홀수 판이면 가운데 비트 $\lfloor N/2\rfloor$는 빠진다. 이를테면 $N=5$면
|bitfield|는 \.{00011}, $N=7$이면 \.{0000111}이다.

식 |1<<half - 1|을 \CEE/의 눈으로 읽으면 안 된다. \GO/에서는 밀기가 빼기보다 먼저
묶이므로 이것은 $2^{\it half}-1$이다. \CEE/에서는 거꾸로 빼기가 먼저 묶여 같은 식이
$2^{{\it half}-1}$이 된다. 원본이 \.{(1 << half) - 1}이라고 괄호를 친 것은 그래서다.
앞 절의 |mask|도 마찬가지다.

@<첫 줄의 낮은 절반을 연다@>=
half := n >> 1
bitfield = 1<<half - 1
sp = 1
queen[0] = 0
cols[0], posd[0], negd[0] = 0, 0, 0

@y
@ 첫 번째 탐색의 작업들이다. 첫 줄의 여왕 |q0|를 비트 번호가 낮은 절반에서 하나씩
고르고, 둘째 줄에서 그 여왕에 막히지 않는 칸마다 작업을 하나 만든다. 둘째 줄의
위협은 |q0| 자신과, 그것을 양쪽으로 한 칸씩 민 것이다. 가장 낮은 비트를 뽑고 끄는
일은 결정적인 반복문에서와 같이 |-f & f|와 |&^=|로 한다.

식 |uint64(1)<<(n>>1) - 1|을 \CEE/의 눈으로 읽으면 안 된다. \GO/에서는 밀기가
빼기보다 먼저 묶이므로 이것은 $2^{\lfloor N/2\rfloor}-1$이다. \CEE/에서는 거꾸로 빼기가
먼저 묶인다. 원본이 \.{(1 << half) - 1}이라고 괄호를 친 것은 그래서다.

@<첫 줄의 낮은 절반을 연다@>=
for f := uint64(1)<<(n>>1) - 1; f != 0; f &^= -f & f {
	q0 := -f & f
	for bf := mask &^ (q0 | q0>>1 | q0<<1); bf != 0; bf &^= -bf & bf {
		tasks = append(tasks, task{q0, -bf & bf})
	}
}

@z

@x
@ 두 번째 탐색은 홀수 판에서만 한다. 첫 줄은 가운데 칸 하나뿐이니 여왕을 거기
놓은 채로 시작한다. 둘째 줄의 세 위협 비트열은 그 여왕에서 곧바로 나온다. 첫 줄에는
해 볼 칸이 더 없으니 스택에는 $0$을 쌓는다.

둘째 줄의 비트열은 |(bitfield-1)>>1|이다. 가운데 비트 하나만 선 수에서 $1$을 빼면
그 아래 비트가 모두 1이 된다. 이를테면 $N=7$이면 \.{0001000}이 \.{0000111}이
된다. 그것을 한 칸 오른쪽으로 밀면 \.{0000011}이다. 가운데 바로 옆 칸은 어차피
대각선에 막히니, 처음부터 빼 두는 셈이다.

@<첫 줄 가운데에 여왕을 놓고, 둘째 줄의 낮은 절반을 연다@>=
bitfield = 1 << (n >> 1)
numrows = 1
queen[0] = bitfield
cols[0], posd[0], negd[0] = 0, 0, 0
cols[1] = bitfield
negd[1] = bitfield >> 1
posd[1] = bitfield << 1
sp = 1
stack[sp] = 0; sp++ // 첫 줄은 이 한 칸뿐이다
bitfield = (bitfield - 1) >> 1

@y
@ 두 번째 탐색의 작업들이다. 홀수 판에서만 만든다. 첫 줄의 여왕은 가운데 칸에 있고,
둘째 줄은 원본대로 |(q0-1)>>1|의 칸들만 연다. 가운데 비트 하나만 선 수에서 $1$을
빼면 그 아래 비트가 모두 1이 되고, 그것을 한 칸 오른쪽으로 밀면 가운데 바로 옆 칸이
빠진다. 그 칸은 어차피 대각선에 막힌다.

@<첫 줄 가운데에 여왕을 놓고, 둘째 줄의 낮은 절반을 연다@>=
q0 := uint64(1) << (n >> 1)
for bf := (q0 - 1) >> 1; bf != 0; bf &^= -bf & bf {
	tasks = append(tasks, task{q0, -bf & bf})
}

@z

@x
@* 판 찍기.
선택항 \.{-p}를 주면 찾은 해마다 판을 찍는다. 원본의 함수 |printtable|이다. 우리는
짝마다 하나씩만 찾으니, 찾은 해와 그 거울상을 함께 찍는다. 해의 번호는 짝마다 둘씩
나아간다.

줄 |i|의 여왕 |queen[i]|는 이미 1비트 하나뿐이다. 원본은 거기서 가장 낮은 비트를
다시 뽑는데, 할 필요가 없는 일이라 뺐다. 판의 왼쪽 칸이 비트~$0$이다. 거울상은
비트 $N-1-j$를 $j$번째 칸에 찍어 얻는다.

@<해와 그 거울상을 찍는다@>=
for k := 0; k < 2; k++ {
	fmt.Fprintf(out, "*** Solution #: %d ***\n", 2*(numsolutions+1)+uint64(k)-1)
	for i := 0; i < n; i++ {
		row := queen[i]
		for j := 0; j < n; j++ {
			if k == 0 && (row>>j)&1 != 0 || k == 1 && row&(1<<(n-j-1)) != 0 {
				fmt.Fprintf(out, "Q ")
			} else {
				fmt.Fprintf(out, ". ")
			}
		}
		fmt.Fprintf(out, "\n")
	}
	fmt.Fprintf(out, "\n")
}

@y
@* 판 찍기.
병렬판은 판을 찍지 않는다. 판을 보려면 이 변경 파일 없이 짠 순차판에 \.{-p}를 준다.

@z

@x
것이다. 그래도 나는 소머즈의 스택을 그대로 두었다. 이 글이 설명하려는 것이 그의
기법이기 때문이다.
@y
것이다. 그래도 나는 소머즈의 스택을 그대로 두었다. 이 글이 설명하려는 것이 그의
기법이기 때문이다.

@ 병렬판은 이 기계의 코어 열 개(성능 코어 여덟, 효율 코어 둘)로 이만큼 빨라진다.
시간은 초다.
$$\vbox{\halign{\hfil$#$\quad&\hfil#\quad&\hfil#\quad&\hfil#\cr
N&\rm 순차판&\rm 병렬판(일꾼 $10$)&\rm 배\cr
\noalign{\smallskip}
16&3.576&0.484&7.4\cr
17&25.04&3.402&7.4\cr
18&185.7&26.72&6.9\cr}}$$
$N=17$에서 일꾼의 수를 바꾸어 보면 이렇다.
$$\vbox{\halign{\hfil#\quad&&\hfil#\quad\cr
\rm 일꾼&1&2&4&6&8&10\cr
\rm 시간&27.89&14.32&7.320&4.947&3.829&3.393\cr}}$$
\noindent 일꾼 여덟까지는 거의 곧게 는다. 여덟이면 일꾼 하나의 $7.3$배다. 거기서
둘을 더 붙여도 $8.2$배에 그치는 것은 그 둘이 효율 코어이기 때문이다.

일꾼 하나로 돌리면 순차판보다 $10$퍼센트쯤 느린데, 그 까닭은 찾지 못했다. 첫 두
줄을 미리 정해 두니 훑는 노드는 오히려 조금 적은데도 그렇다. 일꾼이 끌어다 쓰는
바깥 변수 |mask|와 |boardMinus|를 일꾼 안의 사본으로 바꾸어 보았고, 일꾼의 배열이
힙으로 나가지 않고 스택에 머무는 것도 확인했지만, 둘 다 아니었다.
@z

@x
\item{$\bullet$} 판을 찍는 기능을 선택항 \.{-p}로 두었다. 원본은 소스의 주석을 풀어
다시 컴파일해야 했다.
@y
\item{$\bullet$} 판을 찍는 기능은 없다. 순차판에는 선택항 \.{-p}로 있다. 대신 첫 두
줄로 탐색을 나누어 고루틴 여럿에 맡긴다.
@z

@x
같다. 사용법 줄에 \.{[-p]}가 붙고, 받는 범위의 두 수가 다를 뿐이다.
\smallskip
@y
같다. 사용법 줄에 \.{[-p]}가 붙고, 받는 범위의 두 수가 다를 뿐이다.
\item{$\bullet$} 병렬판. $N=1$부터 $16$까지를 일꾼 $1$, $2$, $3$, $10$개로 돌린
$64$가지가 모두 맞고, $N=12$까지는 경쟁 탐지기(\.{-race})를 붙여 돌렸다. $N=17$과
$18$도 맞다.
\smallskip
@z
