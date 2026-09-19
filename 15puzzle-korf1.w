\input kotexgweb
@i types.w
\datethis

\def\title{15 퍼즐 (코르프 1)}

@* 들어가며.
이 프로그램은 이름난 ``15 퍼즐''의 최소 수 풀이를 찾는다. 방법은 리처드 코르프(Richard
E. Korf)가 내놓은 것이다 [{\sl Artificial Intelligence\/ \bf27} (1985), 97--109].
크누스는 이 일을 점점 더 빠르게 해내는 프로그램을 연작으로 썼고, 이것은 그 첫째다.
(연작의 영번째 프로그램 {\mc 15PUZZLE-KORF0}을 먼저 읽어 두어도 좋지만, 그 설명의
대부분은 여기에도 되풀이된다.) 크누스가 이 묶음을 쓴 주된 까닭은 그에게는 새로운
프로그래밍 방식 하나를 실험해 보는 것이었다. 그 방식은 아래에서 설명한다.

처음 배치는 명령줄에서 16진수 숫자
$\{\.0,\.1,\.2,\allowbreak\.3,\allowbreak\.4,\.5,\.6,\.7,\.8,\.9,\allowbreak
\.a,\.b,\.c,\.d,\.e,\.f\}$의 순열로 준다. 이 순열로 $4\times4$ 행렬의 행을 위에서
아래로, 왼쪽에서 오른쪽으로 채운다. 이를테면 `\.{159d26ae37bf48c0}'은 다음 처음
배치를 뜻한다.
$$\vcenter{\halign{&\enspace\tt#\cr
1&5&9&d\cr
2&6&a&e\cr
3&7&b&f\cr
4&8&c&0\cr
}}$$
숫자 \.0은 빈칸이다. 퍼즐을 푸는 한 걸음은 \.0을 그 이웃 하나와 맞바꾸는 것이다.
목표 배치는 언제나 이것이다.
$$\vcenter{\halign{&\enspace\tt#\cr
1&2&3&4\cr
5&6&7&8\cr
9&a&b&c\cr
d&e&f&0\cr
}}$$
(코르프의 목표 배치는 달라서 \.{0123456789abcdef}였다. 크누스는 수학적으로는 코르프의
관례가 더 낫다고 인정한다. 그러나 그것은 125년 된 전통과 어긋나므로, 크누스는
역사적인 관례를 지켰다. 원한다면 판을 $180^\circ$ 돌리고 0이 아닌 숫자~$x$를
$16-x$로 바꾸어 두 관례를 서로 바꿀 수 있다.)

@ 이것은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{15puzzle-korf1.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/15puzzle-korf1.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Tue, 23 Aug 2005 04:13:17 GMT}다.

원본의 152가지 경우는 전이가 하나도 틀리지 않았다. 크누스가 손으로 꼼꼼히
확인했다는 그대로다. 결함은 처음 배치가 이미 목표일 때 걸린 시간을 쓰레기 값으로
찍는 것 하나뿐이었다. 고친 이야기는 맨 뒤에 적었다.

@ 이제 프로그램의 얼개다. 원본은 모든 일을 |main| 안에서 한다. 판과 스택은 전역에
두고, 레지스터 변수 몇 개로 버틴다. 이 판도 그렇게 한다. 변수를 모두 |main|의
첫머리에서 선언하는 까닭이 있다. \GO/의 |goto|는 변수 선언을 건너뛸 수 없는데,
아래에서는 |goto|를 수백 번 쓴다.

@c
package main

import (
	"fmt"
	"os"
	"time"
)

@<전역 변수@>
@<함수들@>

func main() {
	var j, k, s, t, del, piece, moves int
	@<처음 배치를 입력한다@>
	@<코르프의 방법을 적용한다@>
win:
	@<결과를 출력한다@>
}

@ @<전역 변수@>=
var (
	board [4][4]int  // 지금 판
	start [16]int    // 처음 판
	stack [100]int   // 제어 스택
	timer time.Time // 이번 시도를 시작한 때
)

@ 열여섯 칸의 자리를 4진법 두 자리 수로 보자.
$$\vcenter{\halign{&\enspace#\cr
00&01&02&03\cr
10&11&12&13\cr
20&21&22&23\cr
30&31&32&33\cr
}}$$
그러면 각 칸은 행 번호~$r$와 열 번호~$c$로 정해지는 두 자리 부호 $(r,c)$가 된다.
여기서 $0\le r,c<4$다.

게다가 입력 숫자 \.1, \.2, \dots,~\.f를 다시 매겨, 저마다 마지막에 가 있을 자리
00, 01, \dots,~32와 같게 해 두면 편하다. 이 변환은 그저 1을 빼는 것이다. 그래서
\.0은 $-1$이 된다. 앞에서 든 처음 배치는 배열 |start|에 이렇게 들어간다.
$$\vcenter{\halign{&\enspace$\hfil#\hfil$\cr
00&10&20&30\cr
01&11&21&31\cr
02&12&22&32\cr
03&13&23&-1\cr
}}$$

@ 행과 열은 이렇게 뽑는다.

@<함수들@>=
func row(x int) int { return x >> 2 }
func col(x int) int { return x & 0x3 }

@ 처음 배치의 절반은 풀 수 없다. 순열이 홀수일 필요충분조건은 \.0이 홀수 번 움직여야
한다는 것이기 때문이다. 이 가능성 조건은 입력을 읽을 때 확인한다.

@<처음 배치를 입력한다@>=
if len(os.Args) != 2 {
	fmt.Fprintf(os.Stderr, "사용법: %s 처음배치\n", os.Args[0])
	os.Exit(-1)
}
@<16진수 숫자를 저마다 한 번씩 썼는지 확인한다@>
@<|start|를 채우며 순열의 반전 수를 센다@>
if (row(t)+col(t)+del)&0x1 == 0 {
	fmt.Printf("미안하지만 ... 그 처음 배치에서는 목표에 닿을 수 없다!\n")
	os.Exit(0)
}

@ 16진수 숫자 한 글자의 값을 돌려준다. 16진수 숫자가 아니면 $-1$이다.

@<함수들@>=
func hexval(b byte) int {
	switch {
	case b >= '0' && b <= '9':
		return int(b - '0')
	case b >= 'a' && b <= 'f':
		return int(b-'a') + 10
	}
	return -1
}

@ 이 단계에서는 |start|를 숫자마다 썼는지 적어 두는 표로 빌려 쓴다.

@<16진수 숫자를 저마다 한 번씩 썼는지 확인한다@>=
for j = 0; j < len(os.Args[1]); j++ {
	k = hexval(os.Args[1][j])
	if k < 0 {
		fmt.Fprintf(os.Stderr,
			"처음 배치에는 16진수 숫자(0123456789abcdef)만 써야 한다!\n")
		os.Exit(-2)
	}
	if start[k] != 0 {
		fmt.Fprintf(os.Stderr, "처음 배치에 %x 숫자가 두 번 나온다!\n", k)
		os.Exit(-3)
	}
	start[k] = 1
}
for k = 0; k < 16; k++ {
	if start[k] == 0 {
		fmt.Fprintf(os.Stderr, "처음 배치에 %x 숫자가 없다!\n", k)
		os.Exit(-4)
	}
}

@ 앞 절을 통과했으면 숫자가 정확히 열여섯 개다. 변수 |del|에는 반전 수를, 변수 |t|에는
빈칸의 자리를 남긴다.

@<|start|를 채우며 순열의 반전 수를 센다@>=
for del, j = 0, 0; j < 16; j++ {
	k = hexval(os.Args[1][j])
	start[j] = k - 1
	for s = 0; s < j; s++ {
		if start[s] > start[j] {
			del++ // 반전을 센다
		}
	}
	if k == 0 {
		t = j
	}
}

@* 코르프의 방법.
조각 $(r,c)$가 지금 판의 자리 $(r',c')$에 있다면, 그 조각은 제자리에 가기까지 적어도
$\vert r-r'\vert+\vert c-c'\vert$번 움직여야 한다. 열다섯 조각 모두에 대한 이 수들의
합을 $h$라 하자. 이 값은 ``맨해튼 거리 하한''이라고도 한다.

조각을 목표에 더 가깝게 하는 수를 {\it 행복한\/} 수라 하고, 그렇지 않은 수를 {\it 슬픈\/}
수라 하자. 코르프의 핵심 착상은 행복한 수만으로 된 풀이를 먼저 찾아보는 것이다.
(이를테면 처음 배치 \.{bc9e80df3412a756}에서는 모두 행복한 수 $h=56$개로 정말 이길 수
있다.) 그것이 실패하면 처음부터 다시 하되, 이번에는 행복한 수 $h+1$개와 슬픈 수
1개를 두어 본다. 그것도 실패하면 $k=2$, 3, \dots에 대해 행복한 수 $h+k$개와 슬픈 수
$k$개를 차례로 해 보고, 마침내 성공할 때까지 간다.

이 전략은 어리석게 들릴지 모른다. 새 $k$마다 이미 한 계산을 되풀이하기 때문이다.
그러나 실은 두 가지 까닭으로 빼어나다. (1)~$k$를 하나 정하면 탐색에 메모리가 거의
들지 않는다. 사실 크누스의 프로그램은 자료 전부에 500바이트도 쓰지 않는다.
(2)~$k=0$, 1, \dots,~$k_0$에 대한 실행 시간을 모두 더해도, $k=k_0$로 {\it 한 번\/}
실행하는 시간보다 그리 많지 않다. 실행 시간이 $k$에 대해 지수적으로 늘기 때문이다.

메모리가 적게 드는 것은 기억 없는 깊이 우선 탐색으로 모든 풀이를 훑어도 되기
때문이다. 15 퍼즐은 이 점에서 다른 많은 문제보다 훨씬 좋다. 사실 여기서 쓰는 눈먼 깊이
우선 탐색은 다른 응용에서는 흔히 나쁜 선택이다. 이미 ``가 보고 해 본'' 곳인 줄
모르고 같은 부분 문제를 거듭 탐색할 수 있기 때문이다. 그러나 15 퍼즐의 탐색 나무에는
겹치는 가지가 비교적 적다. 이를테면 앞서 본 배치로 되돌아오는 가장 짧은 순환은
$2\times2$ 부분 정사각형을 세 바퀴 도는 것뿐이고, 그 길이는 12다. 그러므로 나무의 어느
마디에서든 그 아래 다섯 층은 모두 서로 다른 배치이고, 여섯째 층에서야 중복이 조금
생긴다.

@ 덧붙여 둘 것이 있다. 맨해튼 거리는 꽤 약한 하한이고, 훨씬 나은 하한들이 알려져 있다.
크누스는 언젠가 이 연작의 뒷 프로그램에 그것들을 넣을 생각이었다. 여기서 택한 단순한
방법으로도 무작위 처음 배치는 대부분 적당한 시간 안에 푼다. 그러나 들어가며에서 든
전치의 예에는 너무 느리다. 그 예의 맨해튼 하한은 40인데 최단 풀이는 72수다. 그래서
그 문제의 $k$는 16이고, $k$가 하나 늘 때마다 경험적으로 앞의 경우보다 5.7배쯤 걸린다.
(그래서 크누스의 2004년식 옵테론 컴퓨터로 40.4시간이 걸렸다.)

게다가 지금 방식은 여러모로 더 낫게 할 수 있다. 크누스가 세어 보니 맨해튼 거리를
그대로 써도, 슬픈 수 없이 목표에 닿을 수 있는 배치가 88,728,779개나 있다. (놀랄 만큼
큰 수다. 크누스는 백만 개가 안 될 것이라 여겼다. 덧붙이면 그 가운데 정확히 114개가
목표까지의 거리가 최대인 56이고, 위에서 든 예가 그런 배치다.) 그 배치들의 표를
메모리에 두면, 마지막으로 허용된 슬픈 수는 표 안의 무언가로 가야 한다는 것을 알게
된다. 그러면 꽤 빨라질 수 있다. 코르프와 테일러는 다른 개선책을 여럿 내놓아, 1996년에
24 퍼즐의 무작위 문제를 실제로 풀었다 [{\sl AAAI National Conference Proceedings\/}
(1996), 1202--1207].

하나 더 있다. 크누스는 ``행복한''과 ``슬픈''이라는 용어가 너무 애달픈 것은 아닌지
걱정했다. ``내리막''과 ``오르막'' 수라고 불렀어야 했을까? 그는 독자의 의견을
청했다.

@ 메모리를 아낀다는 것은 계산 전체가 컴퓨터의 고속 캐시 안에서 이루어진다는 뜻이다.
물론 어려운 경우에는 배치를 수십억 개 살펴야 하므로, 깊이 우선 탐색의 안쪽 반복문을
짧게 하고 싶다.

이를테면 빈칸을 남쪽에서 $(r,c)$로 막 옮겼을 때 어떤 연산이 필요한지 보자. (곧 빈칸이
전에는 $(r+1,c)$에 있었다고 하자. 실제로는 {\it 조각\/} 하나를 남쪽으로 옮긴 것이지만,
{\it 빈칸\/}이 북쪽으로 간다고 생각하자.) $(r,c)$에서는 빈칸을 서쪽 $(r,c-1)$, 북쪽
$(r-1,c)$, 동쪽 $(r,c+1)$ 가운데 하나로 옮겨 본다. $(r,c)$가 가운데 칸인지, 가장자리
칸인지, 모서리 칸인지에 따라 가능한 수는 셋까지다. 그 가능성을 모두 해 본 다음에는
되짚어 가서, 우리를 여기로 보낸 남쪽 칸에서 다음 수를 둔다.

직접적인 구현은 프로그램 {\mc 15PUZZLE-KORF0}에 있고, 그 안쪽 반복문에는 검사가
많다. (1)~방향을 고른다. (2)~지금 $(r,c)$에서 그 방향으로 갈 수 있는지 본다. (3)~갈 수
있다면 그 수가 행복한지 슬픈지 본다. (4)~슬프다면 슬픈 수의 할당량을 넘었는지 본다.
(5)~목표에 닿았는지 본다. (6)~가능성을 다 썼는지 본다.

@ 그런 조건 분기는 요즘 컴퓨터의 파이프라인 구조를 망가뜨린다. 그래서 이 프로그램은
직선 코드로 그 대부분을 피한다. 사실상 유한 상태 오토마톤이 동작을 제어한다.
프로그램은 개념상 $4\times4\times4\times4=256$개의 작은 부분으로 되어 있고, 부분마다
조합 $(r,c,d,p)$가 하나씩 대응한다. 이 조합은 빈칸이 $(r,c)$에 있고, 방향~$p$에서 이
칸에 들어왔으며, 이제 빈칸을 방향~$d$로 옮기려 한다는 뜻이다.

(사실 256은 넉넉히 잡은 수다. 가장자리와 모서리에서는 불가능한 조합이 많기 때문이다.
이를테면 빈칸이 3열에 있을 때 동쪽으로 옮겨 보지는 않는다. 실제 경우의 수는 152이고,
그 가운데 48은 두었던 수를 무르기만 한다.)

크누스는 되풀이되는 조각 코드를 \CEE/ 전처리기의 매크로로 만들 수도 있었다. 그러나
그의 디버깅 도구는 매크로를 제대로 다루지 못했다. 그래서 되풀이되는 단계를 다른
층위의 매크로로, 곧 프로그램을 쳐 넣으면서 \.{emacs}로 처리했다. 그래도 코드를
텍스트 편집으로 다 풀어 쓴 것보다 읽기 좋게 하는 데는 \CEE/ 전처리기가 쓸모 있었다.

@ 크누스는 이 프로그램을 작은 모듈 152개로 쓰는 대신 작은 프로시저 152개로 쓸 수도
있었다. 그러나 얻는 것이 없었을 것이다. 그의 말로는 종신 재직권이 있는 정교수라,
|goto| 문을 쓴다고 잘릴 걱정은 없다. 서브루틴 호출의 부담이 있고, 여기서 만나는
상황에서는 ``꼬리 재귀''가 아주 쓸모 있다. 이 두 가지를 보고 크누스는 확신했다.
일부러 스파게티처럼 보이게 쓴 이 코드 대신 프로시저를 썼다면, 아무리 최신 컴파일러라도
이만큼 효율적인 것을 내놓지 못한다고. 프로시저 중심의 판이 쓰기에 더 쉬웠을 것도 아니다.

크누스가 보기에 이 방식의 흠은 하나뿐이다. 실수할 기회가 많다는 것이다. 이런
프로그램은 오타가 있어도 돌아가는 것처럼 보인다. 그래서 그는 책상에서 아주 꼼꼼히
확인해야 했다.

이렇게 되풀이한 것이 도움이 되었을까? 이제 프로그램은 컴퓨터의 일을 명령어 캐시에서
자료 캐시로 옮겼다. 자연스러운 벤치마크 하나는 \.{ca6098dfb73254e1}이다. 코르프의
원 논문에 실린 무작위 예 100개 가운데 가장 어려운 것이었다. (코르프는 자기 구현이
이 경우에 마디를 60억 개 넘게 탐색했다고 보고했다.) 크누스가 2000년에 산 애슬론
컴퓨터로 처음 시험했을 때, 이 난제를 푸는 데 8분 58초가 걸렸다. 견주어 보면
{\mc 15PUZZLE-KORF0}은 같은 기계에서 24분 26초가 걸린다. 코르프의 원래 실험은
1984년에 {\mc DEC} 2060의 파스칼 컴파일러로 4000분쯤 걸렸다. 그러니 크누스의
프로그램은 400배 넘게 빨라진 것이다. 그 가운데 160배쯤은 하드웨어가 좋아진 덕이고,
나머지 2.7배쯤은 여기서 택한 구현 기법 덕이다.

@ 들어가는 말은 이만하고 프로그램으로 가자.

변수 |moves|와 |t|에는 두 수를 한꺼번에 담는다. 위 여덟 비트는 슬픈 수의 개수이고,
아래 여덟 비트는 행복한 수의 개수다. 행복한 수와 슬픈 수를 하나씩 늘리려면
|0x101|을 더하면 된다.

@<코르프의 방법을 적용한다@>=
@<|moves|를 행복한 수의 최소 개수로 정한다@>
timer = time.Now()
if moves == 0 {
	goto win // 그러지 않으면 풀이가 $6+6$수가 된다!
}
for {
	timer = time.Now()
	t = moves // 바라는 개수는 $256\times(\hbox{슬픈 수})+(\hbox{행복한 수})$
	@<|t|수를 더 두는 풀이를 찾아본다@>
	fmt.Printf(" ... %d+%d수로는 풀이가 없다 (%d초)\n",
		moves&0xff, moves>>8, elapsed())
	moves += 0x101 // 할당량에 슬픈 수 하나와 행복한 수 하나를 더한다
}

@ 걸린 시간은 두 곳에서 찍는다.

@<함수들@>=
func elapsed() int {
	return int(time.Since(timer).Seconds())
}

@ @<|moves|를 행복한 수의 최소 개수로 정한다@>=
for j, moves = 0, 0; j < 16; j++ {
	if start[j] >= 0 {
		del = row(start[j]) - row(j)
		if del < 0 {
			del = -del
		}
		moves += del
		del = col(start[j]) - col(j)
		if del < 0 {
			del = -del
		}
		moves += del
	}
}

@ 주 제어 루틴은 스택이다. 스택의 각 칸에는 두 가지를 적는다. 왼쪽 16비트에는
남은 (슬픈 수, 행복한 수)의 개수~$t$가 있다. 되짚어 갈 때는 이 수를 되살린다. 오른쪽
16비트에는 스택에서 그보다 위에 있는 일을 모두 마친 다음에 실행할 루틴의 부호가 있다.

@ 방향은 이렇게 부호화한다. 동쪽$=0$, 북쪽$=1$, 서쪽$=2$, 남쪽$=3$. (복소평면에서
$i$의 거듭제곱을 떠올리면 된다.)

가능한 조합 $(r,c,d,p)$는 모두 부호 하나로 나타내어, 그것으로 곧장 분기할 수 있게
한다. 크누스는 네 좌표를 4진법 네 자리, 곧 8비트에 담았다. 이 판은 네 좌표를 16진법
네 자리에 하나씩 담는다. 그러면 $(r,c,d,p)$의 부호는 \hex{$rcdp$}이다. 이를테면 $(1,2,0,3)$은
|0x1203|이다. 그래서 아래의 분기표에서 부호와 이름표가 눈으로 바로 맞대어진다.

부호에는 $d$ 방향 하나만 해 보고 돌아가는 경우를 뜻하는 것도 있다. 크누스는 이것을
|tailcode(r,c,d)|라 불렀다. 이 판에서는 $p$ 자리에 \.f를 넣어 \hex{$rcd$f}로 적는다. 빈칸이
어느 쪽에서 들어왔는지 모른다는 뜻이다. 스택 맨 밑에 두는 특별한 부호 |bottom|은
달리 쓰이지 않는 $(0,0,1,1)$이다.

@<전역 변수@>=
const bottom = 0x0011 // 달리 쓰이지 않는 부호

@ 행복한지 슬픈지 복잡하게 검사하지 않으려고, 산술 계산 하나로 |del|을 만든다.
방향~$d$로 가는 수가 지금 슬프면 |0x100|이고, 행복하면 |0x001|이다. 이를테면 빈칸이
동쪽으로 가면 $(r,c+1)$의 조각이 $(r,c)$로 온다. 그 조각의 제자리 열이 $c$ 이하이면
행복하다. 그러면 $c-\\{col}(\\{piece})\ge0$이므로 2비트 밀어 0이 된다. 그렇지 않으면
음수를 밀어 $-1$이 되고, 아래 여덟 비트를 남기면 |0xff|다. 거기에 1을 더한다.

함수 |happy|가 그 셈을 한다. 방향마다 옮길 조각과 |happy|에 넘길 값은 이렇다.
$$\vbox{\halign{#\hfil\quad&$#$\hfil\quad&$#$\hfil\cr
동쪽&\\{board}[r][c+1]&c-\\{col}(\\{piece})\cr
북쪽&\\{board}[r-1][c]&\\{row}(\\{piece})-r\cr
서쪽&\\{board}[r][c-1]&\\{col}(\\{piece})-c\cr
남쪽&\\{board}[r+1][c]&r-\\{row}(\\{piece})\cr}}$$

@<함수들@>=
func happy(x int) int {
	return x>>2&0xff + 1 // $x\ge0$이면 1, 아니면 |0x100|
}

@ 원본의 매크로 |east|, |west|, |north|, |south|는 옮길 조각을 읽는 일과 |del|을 셈하는
일을 함께 한다. 나는 처음에 이것을 두 값을 돌려주는 함수로 옮겼다. 그랬더니 경우마다
진짜 함수 호출이 일어났다. 경우 152가지를 모두 품은 |main|은 \GO/ 컴파일러가 보기에
`큰' 함수다. 그런 함수에는 비용이 20 이하인 작은 함수만 인라인하는데, |east|의 비용은
26이었다. 호출이 레지스터를 흩뜨리니 |s|와 |t|도 메모리로 밀려났다. 그래서 조각을 읽는
일은 경우마다 그대로 적고, 셈만 |happy|로 뺐다. 비용이 8인 |happy|는 인라인된다.
이것만으로 실행 시간이 4분의 1쯤 줄어, 원본 C 프로그램보다도 조금 빨라졌다.
(|stack[s]|의 경계 검사도 의심했다. 그러나 |s|를 |uint8|로 두어 그 검사를 모두 없애 보아도
시간은 그대로였다.)

@ 이제 경우 하나가 무엇을 하는지 보자. 빈칸이 $(r,c)$에 있고 방향 $d$로 옮기려 한다.
먼저 옮길 조각과 |del|을 얻는다. 만약 $t\le\\{del}$이면 두 가지 가운데 하나다.
$t=\\{del}$이면 이 수로 이긴다. 그렇지 않으면 이 수를 둘 수 없으니 다음 방향으로
간다. 다음 방향은 스택에 쌓았을 경우와 같은 곳이다. 둘 수 있으면 조각을 $(r,c)$에
놓고, 다음에 할 일을 남은 수의 개수와 함께 스택에 쌓은 뒤, 새 자리의 첫 방향으로
뛴다.

$t=\\{del}$이면 정말 목표에 닿는다. 까닭은 이렇다. 행복한 수 하나는 $h$를 1 줄이고,
슬픈 수 하나는 1 늘린다. 그래서 $t$에 남은 행복한 수의 개수에서 슬픈 수의 개수를
뺀 것은 언제나 지금 판의 $h$와 같다. $t=|0x001|$이면 $h=1$이고, 행복한 수 하나로
$h=0$, 곧 목표가 된다. $t=|0x100|$이면 $h=-1$이어야 하니 그런 일은 없다.

빈칸이 새 자리 $(r',c')$에 들어온 방향은 $p'=(d+2)\bmod4$다. 거기서 해 볼 방향은
$p'-1$, $p'-2$, $p'-3$ (법 4) 순서이고, 판 밖으로 나가는 방향은 건너뛴다. 이렇게
돌다가 $p'$에 이르면 모든 방향을 해 본 것이다. 그때가 방향 $p'$로 무르는 경우 $(r',
c',p',p')$다.

원본에서 이름표는 모두 |switch| 문 안에 있고, 경우들이 서로 |goto|로 뛰어다닌다. 그런데
\GO/는 블록 안으로 뛰어드는 |goto|를 허락하지 않는다. |case| 절 하나하나가 블록이다.
그래서 이 판은 이름표 152개를 모두 한 블록에 나란히 두고, |switch| 문은 그 뒤에
따로 둔다. |switch|는 부호에 맞는 이름표로 뛰기만 한다. 첫 수들을 쌓은 다음에는 곧장
|switch|로 간다. 스택 맨 밑의 |bottom|을 만나면 |switch|를 빠져나오고, 그러면 이번
할당량으로는 풀이가 없다.

@<행동을 개시한다@>=
goto switcher
@<빈칸을 0열에서 동쪽으로 옮기는 경우들@>
@<빈칸을 1열에서 동쪽으로 옮기는 경우들@>
@<빈칸을 2열에서 동쪽으로 옮기는 경우들@>
@<빈칸을 1열에서 서쪽으로 옮기는 경우들@>
@<빈칸을 2열에서 서쪽으로 옮기는 경우들@>
@<빈칸을 3열에서 서쪽으로 옮기는 경우들@>
@<빈칸을 1행에서 북쪽으로 옮기는 경우들@>
@<빈칸을 2행에서 북쪽으로 옮기는 경우들@>
@<빈칸을 3행에서 북쪽으로 옮기는 경우들@>
@<빈칸을 0행에서 남쪽으로 옮기는 경우들@>
@<빈칸을 1행에서 남쪽으로 옮기는 경우들@>
@<빈칸을 2행에서 남쪽으로 옮기는 경우들@>
@<수를 무르는 경우들@>
switcher:
s--
t = stack[s] >> 16
switch stack[s] & 0xffff {
@<분기표@>
case bottom:
default:
	fmt.Fprintf(os.Stderr, "이런, 경우 %x에서 헷갈렸다!\n", stack[s])
}

@* 152가지 경우.
이제 경우 152가지를 차례로 적는다. 빈칸이 가는 방향과 출발하는 행이나 열로 묶었다.
원본과 마찬가지로 경우마다 코드가 거의 같으니, 한두 개만 꼼꼼히 읽고 나머지는
훑어보면 된다. 틀린 곳이 없다는 것은 맨 뒤에서 말하는 기계 검사로 확인했다.

@<빈칸을 0열에서 동쪽으로 옮기는 경우들@>=
r0c0d0p3: piece = board[0][1]; del = happy(0 - col(piece))
	if t <= del { if t == del { goto win }; goto r0c0d3p3 }
	board[0][0], stack[s], s, t = piece, t<<16+0x0033, s+1, t-del
	goto r0c1d0p2
@#
r1c0d0p1: piece = board[1][1]; del = happy(0 - col(piece))
	if t <= del { if t == del { goto win }; goto r1c0d3p1 }
	board[1][0], stack[s], s, t = piece, t<<16+0x1031, s+1, t-del
	goto r1c1d1p2
@#
r1c0d0p3: piece = board[1][1]; del = happy(0 - col(piece))
	if t <= del { if t == del { goto win }; goto r1c0d3p3 }
	board[1][0], stack[s], s, t = piece, t<<16+0x1033, s+1, t-del
	goto r1c1d1p2
@#
r2c0d0p1: piece = board[2][1]; del = happy(0 - col(piece))
	if t <= del { if t == del { goto win }; goto r2c0d3p1 }
	board[2][0], stack[s], s, t = piece, t<<16+0x2031, s+1, t-del
	goto r2c1d1p2
@#
r2c0d0p3: piece = board[2][1]; del = happy(0 - col(piece))
	if t <= del { if t == del { goto win }; goto r2c0d3p3 }
	board[2][0], stack[s], s, t = piece, t<<16+0x2033, s+1, t-del
	goto r2c1d1p2
@#
r3c0d0p1: piece = board[3][1]; del = happy(0 - col(piece))
	if t <= del { if t == del { goto win }; goto r3c0d1p1 }
	board[3][0], stack[s], s, t = piece, t<<16+0x3011, s+1, t-del
	goto r3c1d1p2

@ @<빈칸을 1열에서 동쪽으로 옮기는 경우들@>=
r0c1d0p2: piece = board[0][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r0c1d3p2 }
	board[0][1], stack[s], s, t = piece, t<<16+0x0132, s+1, t-del
	goto r0c2d0p2
@#
r0c1d0p3: piece = board[0][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r0c1d3p3 }
	board[0][1], stack[s], s, t = piece, t<<16+0x0133, s+1, t-del
	goto r0c2d0p2
@#
r1c1d0p1: piece = board[1][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r1c1d3p1 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1131, s+1, t-del
	goto r1c2d1p2
@#
r1c1d0p2: piece = board[1][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r1c1d3p2 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1132, s+1, t-del
	goto r1c2d1p2
@#
r1c1d0p3: piece = board[1][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r1c1d3p3 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1133, s+1, t-del
	goto r1c2d1p2
@#
r2c1d0p1: piece = board[2][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r2c1d3p1 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2131, s+1, t-del
	goto r2c2d1p2
@#
r2c1d0p2: piece = board[2][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r2c1d3p2 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2132, s+1, t-del
	goto r2c2d1p2
@#
r2c1d0p3: piece = board[2][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r2c1d3p3 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2133, s+1, t-del
	goto r2c2d1p2
@#
r3c1d0p1: piece = board[3][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r3c1d2p1 }
	board[3][1], stack[s], s, t = piece, t<<16+0x3121, s+1, t-del
	goto r3c2d1p2
@#
r3c1d0p2: piece = board[3][2]; del = happy(1 - col(piece))
	if t <= del { if t == del { goto win }; goto r3c1d2p2 }
	board[3][1], stack[s], s, t = piece, t<<16+0x3122, s+1, t-del
	goto r3c2d1p2

@ @<빈칸을 2열에서 동쪽으로 옮기는 경우들@>=
r0c2d0p2: piece = board[0][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r0c2d3p2 }
	board[0][2], stack[s], s, t = piece, t<<16+0x0232, s+1, t-del
	goto r0c3d3p2
@#
r0c2d0p3: piece = board[0][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r0c2d3p3 }
	board[0][2], stack[s], s, t = piece, t<<16+0x0233, s+1, t-del
	goto r0c3d3p2
@#
r1c2d0p1: piece = board[1][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r1c2d3p1 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1231, s+1, t-del
	goto r1c3d1p2
@#
r1c2d0p2: piece = board[1][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r1c2d3p2 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1232, s+1, t-del
	goto r1c3d1p2
@#
r1c2d0p3: piece = board[1][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r1c2d3p3 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1233, s+1, t-del
	goto r1c3d1p2
@#
r2c2d0p1: piece = board[2][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r2c2d3p1 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2231, s+1, t-del
	goto r2c3d1p2
@#
r2c2d0p2: piece = board[2][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r2c2d3p2 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2232, s+1, t-del
	goto r2c3d1p2
@#
r2c2d0p3: piece = board[2][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r2c2d3p3 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2233, s+1, t-del
	goto r2c3d1p2
@#
r3c2d0p1: piece = board[3][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r3c2d2p1 }
	board[3][2], stack[s], s, t = piece, t<<16+0x3221, s+1, t-del
	goto r3c3d1p2
@#
r3c2d0p2: piece = board[3][3]; del = happy(2 - col(piece))
	if t <= del { if t == del { goto win }; goto r3c2d2p2 }
	board[3][2], stack[s], s, t = piece, t<<16+0x3222, s+1, t-del
	goto r3c3d1p2

@ @<빈칸을 1열에서 서쪽으로 옮기는 경우들@>=
r0c1d2p0: piece = board[0][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r0c1d0p0 }
	board[0][1], stack[s], s, t = piece, t<<16+0x0100, s+1, t-del
	goto r0c0d3p0
@#
r0c1d2p3: piece = board[0][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r0c1d0p3 }
	board[0][1], stack[s], s, t = piece, t<<16+0x0103, s+1, t-del
	goto r0c0d3p0
@#
r1c1d2p1: piece = board[1][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c1d1p1 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1111, s+1, t-del
	goto r1c0d3p0
@#
r1c1d2p0: piece = board[1][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c1d1p0 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1110, s+1, t-del
	goto r1c0d3p0
@#
r1c1d2p3: piece = board[1][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c1d1p3 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1113, s+1, t-del
	goto r1c0d3p0
@#
r2c1d2p1: piece = board[2][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r2c1d1p1 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2111, s+1, t-del
	goto r2c0d3p0
@#
r2c1d2p0: piece = board[2][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r2c1d1p0 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2110, s+1, t-del
	goto r2c0d3p0
@#
r2c1d2p3: piece = board[2][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r2c1d1p3 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2113, s+1, t-del
	goto r2c0d3p0
@#
r3c1d2p1: piece = board[3][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r3c1d1p1 }
	board[3][1], stack[s], s, t = piece, t<<16+0x3111, s+1, t-del
	goto r3c0d1p0
@#
r3c1d2p0: piece = board[3][0]; del = happy(col(piece) - 1)
	if t <= del { if t == del { goto win }; goto r3c1d1p0 }
	board[3][1], stack[s], s, t = piece, t<<16+0x3110, s+1, t-del
	goto r3c0d1p0

@ @<빈칸을 2열에서 서쪽으로 옮기는 경우들@>=
r0c2d2p0: piece = board[0][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r0c2d0p0 }
	board[0][2], stack[s], s, t = piece, t<<16+0x0200, s+1, t-del
	goto r0c1d3p0
@#
r0c2d2p3: piece = board[0][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r0c2d0p3 }
	board[0][2], stack[s], s, t = piece, t<<16+0x0203, s+1, t-del
	goto r0c1d3p0
@#
r1c2d2p1: piece = board[1][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r1c2d1p1 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1211, s+1, t-del
	goto r1c1d3p0
@#
r1c2d2p0: piece = board[1][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r1c2d1p0 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1210, s+1, t-del
	goto r1c1d3p0
@#
r1c2d2p3: piece = board[1][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r1c2d1p3 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1213, s+1, t-del
	goto r1c1d3p0
@#
r2c2d2p1: piece = board[2][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c2d1p1 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2211, s+1, t-del
	goto r2c1d3p0
@#
r2c2d2p0: piece = board[2][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c2d1p0 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2210, s+1, t-del
	goto r2c1d3p0
@#
r2c2d2p3: piece = board[2][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c2d1p3 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2213, s+1, t-del
	goto r2c1d3p0
@#
r3c2d2p1: piece = board[3][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r3c2d1p1 }
	board[3][2], stack[s], s, t = piece, t<<16+0x3211, s+1, t-del
	goto r3c1d2p0
@#
r3c2d2p0: piece = board[3][1]; del = happy(col(piece) - 2)
	if t <= del { if t == del { goto win }; goto r3c2d1p0 }
	board[3][2], stack[s], s, t = piece, t<<16+0x3210, s+1, t-del
	goto r3c1d2p0

@ @<빈칸을 3열에서 서쪽으로 옮기는 경우들@>=
r0c3d2p3: piece = board[0][2]; del = happy(col(piece) - 3)
	if t <= del { if t == del { goto win }; goto r0c3d3p3 }
	board[0][3], stack[s], s, t = piece, t<<16+0x0333, s+1, t-del
	goto r0c2d3p0
@#
r1c3d2p1: piece = board[1][2]; del = happy(col(piece) - 3)
	if t <= del { if t == del { goto win }; goto r1c3d1p1 }
	board[1][3], stack[s], s, t = piece, t<<16+0x1311, s+1, t-del
	goto r1c2d3p0
@#
r1c3d2p3: piece = board[1][2]; del = happy(col(piece) - 3)
	if t <= del { if t == del { goto win }; goto r1c3d1p3 }
	board[1][3], stack[s], s, t = piece, t<<16+0x1313, s+1, t-del
	goto r1c2d3p0
@#
r2c3d2p1: piece = board[2][2]; del = happy(col(piece) - 3)
	if t <= del { if t == del { goto win }; goto r2c3d1p1 }
	board[2][3], stack[s], s, t = piece, t<<16+0x2311, s+1, t-del
	goto r2c2d3p0
@#
r2c3d2p3: piece = board[2][2]; del = happy(col(piece) - 3)
	if t <= del { if t == del { goto win }; goto r2c3d1p3 }
	board[2][3], stack[s], s, t = piece, t<<16+0x2313, s+1, t-del
	goto r2c2d3p0
@#
r3c3d2p1: piece = board[3][2]; del = happy(col(piece) - 3)
	if t <= del { if t == del { goto win }; goto r3c3d1p1 }
	board[3][3], stack[s], s, t = piece, t<<16+0x3311, s+1, t-del
	goto r3c2d2p0

@ @<빈칸을 1행에서 북쪽으로 옮기는 경우들@>=
r1c0d1p0: piece = board[0][0]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c0d0p0 }
	board[1][0], stack[s], s, t = piece, t<<16+0x1000, s+1, t-del
	goto r0c0d0p3
@#
r1c0d1p3: piece = board[0][0]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c0d0p3 }
	board[1][0], stack[s], s, t = piece, t<<16+0x1003, s+1, t-del
	goto r0c0d0p3
@#
r1c1d1p0: piece = board[0][1]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c1d0p0 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1100, s+1, t-del
	goto r0c1d2p3
@#
r1c1d1p2: piece = board[0][1]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c1d0p2 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1102, s+1, t-del
	goto r0c1d2p3
@#
r1c1d1p3: piece = board[0][1]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c1d0p3 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1103, s+1, t-del
	goto r0c1d2p3
@#
r1c2d1p0: piece = board[0][2]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c2d0p0 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1200, s+1, t-del
	goto r0c2d2p3
@#
r1c2d1p2: piece = board[0][2]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c2d0p2 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1202, s+1, t-del
	goto r0c2d2p3
@#
r1c2d1p3: piece = board[0][2]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c2d0p3 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1203, s+1, t-del
	goto r0c2d2p3
@#
r1c3d1p2: piece = board[0][3]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c3d3p2 }
	board[1][3], stack[s], s, t = piece, t<<16+0x1332, s+1, t-del
	goto r0c3d2p3
@#
r1c3d1p3: piece = board[0][3]; del = happy(row(piece) - 1)
	if t <= del { if t == del { goto win }; goto r1c3d3p3 }
	board[1][3], stack[s], s, t = piece, t<<16+0x1333, s+1, t-del
	goto r0c3d2p3

@ @<빈칸을 2행에서 북쪽으로 옮기는 경우들@>=
r2c0d1p0: piece = board[1][0]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c0d0p0 }
	board[2][0], stack[s], s, t = piece, t<<16+0x2000, s+1, t-del
	goto r1c0d1p3
@#
r2c0d1p3: piece = board[1][0]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c0d0p3 }
	board[2][0], stack[s], s, t = piece, t<<16+0x2003, s+1, t-del
	goto r1c0d1p3
@#
r2c1d1p0: piece = board[1][1]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c1d0p0 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2100, s+1, t-del
	goto r1c1d2p3
@#
r2c1d1p2: piece = board[1][1]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c1d0p2 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2102, s+1, t-del
	goto r1c1d2p3
@#
r2c1d1p3: piece = board[1][1]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c1d0p3 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2103, s+1, t-del
	goto r1c1d2p3
@#
r2c2d1p0: piece = board[1][2]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c2d0p0 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2200, s+1, t-del
	goto r1c2d2p3
@#
r2c2d1p2: piece = board[1][2]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c2d0p2 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2202, s+1, t-del
	goto r1c2d2p3
@#
r2c2d1p3: piece = board[1][2]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c2d0p3 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2203, s+1, t-del
	goto r1c2d2p3
@#
r2c3d1p2: piece = board[1][3]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c3d3p2 }
	board[2][3], stack[s], s, t = piece, t<<16+0x2332, s+1, t-del
	goto r1c3d2p3
@#
r2c3d1p3: piece = board[1][3]; del = happy(row(piece) - 2)
	if t <= del { if t == del { goto win }; goto r2c3d3p3 }
	board[2][3], stack[s], s, t = piece, t<<16+0x2333, s+1, t-del
	goto r1c3d2p3

@ @<빈칸을 3행에서 북쪽으로 옮기는 경우들@>=
r3c0d1p0: piece = board[2][0]; del = happy(row(piece) - 3)
	if t <= del { if t == del { goto win }; goto r3c0d0p0 }
	board[3][0], stack[s], s, t = piece, t<<16+0x3000, s+1, t-del
	goto r2c0d1p3
@#
r3c1d1p0: piece = board[2][1]; del = happy(row(piece) - 3)
	if t <= del { if t == del { goto win }; goto r3c1d0p0 }
	board[3][1], stack[s], s, t = piece, t<<16+0x3100, s+1, t-del
	goto r2c1d2p3
@#
r3c1d1p2: piece = board[2][1]; del = happy(row(piece) - 3)
	if t <= del { if t == del { goto win }; goto r3c1d0p2 }
	board[3][1], stack[s], s, t = piece, t<<16+0x3102, s+1, t-del
	goto r2c1d2p3
@#
r3c2d1p0: piece = board[2][2]; del = happy(row(piece) - 3)
	if t <= del { if t == del { goto win }; goto r3c2d0p0 }
	board[3][2], stack[s], s, t = piece, t<<16+0x3200, s+1, t-del
	goto r2c2d2p3
@#
r3c2d1p2: piece = board[2][2]; del = happy(row(piece) - 3)
	if t <= del { if t == del { goto win }; goto r3c2d0p2 }
	board[3][2], stack[s], s, t = piece, t<<16+0x3202, s+1, t-del
	goto r2c2d2p3
@#
r3c3d1p2: piece = board[2][3]; del = happy(row(piece) - 3)
	if t <= del { if t == del { goto win }; goto r3c3d2p2 }
	board[3][3], stack[s], s, t = piece, t<<16+0x3322, s+1, t-del
	goto r2c3d2p3

@ @<빈칸을 0행에서 남쪽으로 옮기는 경우들@>=
r0c0d3p0: piece = board[1][0]; del = happy(0 - row(piece))
	if t <= del { if t == del { goto win }; goto r0c0d0p0 }
	board[0][0], stack[s], s, t = piece, t<<16+0x0000, s+1, t-del
	goto r1c0d0p1
@#
r0c1d3p0: piece = board[1][1]; del = happy(0 - row(piece))
	if t <= del { if t == del { goto win }; goto r0c1d2p0 }
	board[0][1], stack[s], s, t = piece, t<<16+0x0120, s+1, t-del
	goto r1c1d0p1
@#
r0c1d3p2: piece = board[1][1]; del = happy(0 - row(piece))
	if t <= del { if t == del { goto win }; goto r0c1d2p2 }
	board[0][1], stack[s], s, t = piece, t<<16+0x0122, s+1, t-del
	goto r1c1d0p1
@#
r0c2d3p0: piece = board[1][2]; del = happy(0 - row(piece))
	if t <= del { if t == del { goto win }; goto r0c2d2p0 }
	board[0][2], stack[s], s, t = piece, t<<16+0x0220, s+1, t-del
	goto r1c2d0p1
@#
r0c2d3p2: piece = board[1][2]; del = happy(0 - row(piece))
	if t <= del { if t == del { goto win }; goto r0c2d2p2 }
	board[0][2], stack[s], s, t = piece, t<<16+0x0222, s+1, t-del
	goto r1c2d0p1
@#
r0c3d3p2: piece = board[1][3]; del = happy(0 - row(piece))
	if t <= del { if t == del { goto win }; goto r0c3d2p2 }
	board[0][3], stack[s], s, t = piece, t<<16+0x0322, s+1, t-del
	goto r1c3d3p1

@ @<빈칸을 1행에서 남쪽으로 옮기는 경우들@>=
r1c0d3p0: piece = board[2][0]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c0d1p0 }
	board[1][0], stack[s], s, t = piece, t<<16+0x1010, s+1, t-del
	goto r2c0d0p1
@#
r1c0d3p1: piece = board[2][0]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c0d1p1 }
	board[1][0], stack[s], s, t = piece, t<<16+0x1011, s+1, t-del
	goto r2c0d0p1
@#
r1c1d3p0: piece = board[2][1]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c1d2p0 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1120, s+1, t-del
	goto r2c1d0p1
@#
r1c1d3p1: piece = board[2][1]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c1d2p1 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1121, s+1, t-del
	goto r2c1d0p1
@#
r1c1d3p2: piece = board[2][1]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c1d2p2 }
	board[1][1], stack[s], s, t = piece, t<<16+0x1122, s+1, t-del
	goto r2c1d0p1
@#
r1c2d3p0: piece = board[2][2]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c2d2p0 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1220, s+1, t-del
	goto r2c2d0p1
@#
r1c2d3p1: piece = board[2][2]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c2d2p1 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1221, s+1, t-del
	goto r2c2d0p1
@#
r1c2d3p2: piece = board[2][2]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c2d2p2 }
	board[1][2], stack[s], s, t = piece, t<<16+0x1222, s+1, t-del
	goto r2c2d0p1
@#
r1c3d3p1: piece = board[2][3]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c3d2p1 }
	board[1][3], stack[s], s, t = piece, t<<16+0x1321, s+1, t-del
	goto r2c3d3p1
@#
r1c3d3p2: piece = board[2][3]; del = happy(1 - row(piece))
	if t <= del { if t == del { goto win }; goto r1c3d2p2 }
	board[1][3], stack[s], s, t = piece, t<<16+0x1322, s+1, t-del
	goto r2c3d3p1

@ 지루했다. 그래도 이런 절은 이것이 마지막이다.

@<빈칸을 2행에서 남쪽으로 옮기는 경우들@>=
r2c0d3p0: piece = board[3][0]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c0d1p0 }
	board[2][0], stack[s], s, t = piece, t<<16+0x2010, s+1, t-del
	goto r3c0d0p1
@#
r2c0d3p1: piece = board[3][0]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c0d1p1 }
	board[2][0], stack[s], s, t = piece, t<<16+0x2011, s+1, t-del
	goto r3c0d0p1
@#
r2c1d3p0: piece = board[3][1]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c1d2p0 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2120, s+1, t-del
	goto r3c1d0p1
@#
r2c1d3p1: piece = board[3][1]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c1d2p1 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2121, s+1, t-del
	goto r3c1d0p1
@#
r2c1d3p2: piece = board[3][1]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c1d2p2 }
	board[2][1], stack[s], s, t = piece, t<<16+0x2122, s+1, t-del
	goto r3c1d0p1
@#
r2c2d3p0: piece = board[3][2]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c2d2p0 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2220, s+1, t-del
	goto r3c2d0p1
@#
r2c2d3p1: piece = board[3][2]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c2d2p1 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2221, s+1, t-del
	goto r3c2d0p1
@#
r2c2d3p2: piece = board[3][2]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c2d2p2 }
	board[2][2], stack[s], s, t = piece, t<<16+0x2222, s+1, t-del
	goto r3c2d0p1
@#
r2c3d3p1: piece = board[3][3]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c3d2p1 }
	board[2][3], stack[s], s, t = piece, t<<16+0x2321, s+1, t-del
	goto r3c3d2p1
@#
r2c3d3p2: piece = board[3][3]; del = happy(2 - row(piece))
	if t <= del { if t == del { goto win }; goto r2c3d2p2 }
	board[2][3], stack[s], s, t = piece, t<<16+0x2322, s+1, t-del
	goto r3c3d2p1

@ $d=p$인 경우 $(r,c,d,p)$는 되짚어 가며 앞 판을 되살릴 때다.

무엇을 되살리는지 보자. 빈칸이 방향 $p$의 이웃 칸 $P$에서 $(r,c)$로 왔다면, 그때 $(r,c)$의
조각이 $P$로 갔다. 판에서 빈칸 자리의 값은 쓰지 않으므로, $(r,c)$에 남은 옛 값을
굳이 지우지 않았다. 그러나 여기서 둔 수들이 그 칸을 덮어썼다. 이제 빈칸을 $P$로
돌려보내려면 $P$에 가 있는 조각을 $(r,c)$에 다시 적으면 된다. $P$의 값은 그대로 두어도
된다. 빈칸 자리가 되기 때문이다.

@<수를 무르는 경우들@>=
@<0행과 1행에서 수를 무르는 경우들@>
@<2행과 3행에서 수를 무르는 경우들@>

@ @<0행과 1행에서 수를 무르는 경우들@>=
r0c0d0p0: board[0][0] = board[0][1]; goto switcher
r0c0d3p3: board[0][0] = board[1][0]; goto switcher
r0c1d0p0: board[0][1] = board[0][2]; goto switcher
r0c1d2p2: board[0][1] = board[0][0]; goto switcher
r0c1d3p3: board[0][1] = board[1][1]; goto switcher
r0c2d0p0: board[0][2] = board[0][3]; goto switcher
r0c2d2p2: board[0][2] = board[0][1]; goto switcher
r0c2d3p3: board[0][2] = board[1][2]; goto switcher
r0c3d2p2: board[0][3] = board[0][2]; goto switcher
r0c3d3p3: board[0][3] = board[1][3]; goto switcher
r1c0d0p0: board[1][0] = board[1][1]; goto switcher
r1c0d1p1: board[1][0] = board[0][0]; goto switcher
r1c0d3p3: board[1][0] = board[2][0]; goto switcher
r1c1d0p0: board[1][1] = board[1][2]; goto switcher
r1c1d1p1: board[1][1] = board[0][1]; goto switcher
r1c1d2p2: board[1][1] = board[1][0]; goto switcher
r1c1d3p3: board[1][1] = board[2][1]; goto switcher
r1c2d0p0: board[1][2] = board[1][3]; goto switcher
r1c2d1p1: board[1][2] = board[0][2]; goto switcher
r1c2d2p2: board[1][2] = board[1][1]; goto switcher
r1c2d3p3: board[1][2] = board[2][2]; goto switcher
r1c3d1p1: board[1][3] = board[0][3]; goto switcher
r1c3d2p2: board[1][3] = board[1][2]; goto switcher
r1c3d3p3: board[1][3] = board[2][3]; goto switcher

@ @<2행과 3행에서 수를 무르는 경우들@>=
r2c0d0p0: board[2][0] = board[2][1]; goto switcher
r2c0d1p1: board[2][0] = board[1][0]; goto switcher
r2c0d3p3: board[2][0] = board[3][0]; goto switcher
r2c1d0p0: board[2][1] = board[2][2]; goto switcher
r2c1d1p1: board[2][1] = board[1][1]; goto switcher
r2c1d2p2: board[2][1] = board[2][0]; goto switcher
r2c1d3p3: board[2][1] = board[3][1]; goto switcher
r2c2d0p0: board[2][2] = board[2][3]; goto switcher
r2c2d1p1: board[2][2] = board[1][2]; goto switcher
r2c2d2p2: board[2][2] = board[2][1]; goto switcher
r2c2d3p3: board[2][2] = board[3][2]; goto switcher
r2c3d1p1: board[2][3] = board[1][3]; goto switcher
r2c3d2p2: board[2][3] = board[2][2]; goto switcher
r2c3d3p3: board[2][3] = board[3][3]; goto switcher
r3c0d0p0: board[3][0] = board[3][1]; goto switcher
r3c0d1p1: board[3][0] = board[2][0]; goto switcher
r3c1d0p0: board[3][1] = board[3][2]; goto switcher
r3c1d1p1: board[3][1] = board[2][1]; goto switcher
r3c1d2p2: board[3][1] = board[3][0]; goto switcher
r3c2d0p0: board[3][2] = board[3][3]; goto switcher
r3c2d1p1: board[3][2] = board[2][2]; goto switcher
r3c2d2p2: board[3][2] = board[3][1]; goto switcher
r3c3d1p1: board[3][3] = board[2][3]; goto switcher
r3c3d2p2: board[3][3] = board[3][2]; goto switcher

@* 분기표.
원본에서는 |case| 표시가 경우의 코드 바로 앞에 붙어 있었다. 이 판에서는 그것을 한데
모아 분기표로 만든다. 부호의 네 자리가 이름표의 네 숫자와 같으니
틀린 줄이 있으면 눈에 띈다. 두 번째 부호가 붙은 줄은 그 경우가 첫 수의 |tailcode|를
겸한다는 뜻이다.

@ 빈칸을 동쪽으로 옮기는 경우들이다.

@<분기표@>=
case 0x0003, 0x000f: goto r0c0d0p3
case 0x1001: goto r1c0d0p1
case 0x1003, 0x100f: goto r1c0d0p3
case 0x2001: goto r2c0d0p1
case 0x2003, 0x200f: goto r2c0d0p3
case 0x3001, 0x300f: goto r3c0d0p1
case 0x0102: goto r0c1d0p2
case 0x0103, 0x010f: goto r0c1d0p3
case 0x1101: goto r1c1d0p1
case 0x1102: goto r1c1d0p2
case 0x1103, 0x110f: goto r1c1d0p3
case 0x2101: goto r2c1d0p1
case 0x2102: goto r2c1d0p2
case 0x2103, 0x210f: goto r2c1d0p3
case 0x3101: goto r3c1d0p1
case 0x3102, 0x310f: goto r3c1d0p2
case 0x0202: goto r0c2d0p2
case 0x0203, 0x020f: goto r0c2d0p3
case 0x1201: goto r1c2d0p1
case 0x1202: goto r1c2d0p2
case 0x1203, 0x120f: goto r1c2d0p3
case 0x2201: goto r2c2d0p1
case 0x2202: goto r2c2d0p2
case 0x2203, 0x220f: goto r2c2d0p3
case 0x3201: goto r3c2d0p1
case 0x3202, 0x320f: goto r3c2d0p2

@ 빈칸을 서쪽으로 옮기는 경우들이다.

@<분기표@>=
case 0x0120, 0x012f: goto r0c1d2p0
case 0x0123: goto r0c1d2p3
case 0x1121, 0x112f: goto r1c1d2p1
case 0x1120: goto r1c1d2p0
case 0x1123: goto r1c1d2p3
case 0x2121, 0x212f: goto r2c1d2p1
case 0x2120: goto r2c1d2p0
case 0x2123: goto r2c1d2p3
case 0x3121, 0x312f: goto r3c1d2p1
case 0x3120: goto r3c1d2p0
case 0x0220, 0x022f: goto r0c2d2p0
case 0x0223: goto r0c2d2p3
case 0x1221, 0x122f: goto r1c2d2p1
case 0x1220: goto r1c2d2p0
case 0x1223: goto r1c2d2p3
case 0x2221, 0x222f: goto r2c2d2p1
case 0x2220: goto r2c2d2p0
case 0x2223: goto r2c2d2p3
case 0x3221, 0x322f: goto r3c2d2p1
case 0x3220: goto r3c2d2p0
case 0x0323, 0x032f: goto r0c3d2p3
case 0x1321, 0x132f: goto r1c3d2p1
case 0x1323: goto r1c3d2p3
case 0x2321, 0x232f: goto r2c3d2p1
case 0x2323: goto r2c3d2p3
case 0x3321, 0x332f: goto r3c3d2p1

@ 빈칸을 북쪽으로 옮기는 경우들이다.

@<분기표@>=
case 0x1010, 0x101f: goto r1c0d1p0
case 0x1013: goto r1c0d1p3
case 0x1110, 0x111f: goto r1c1d1p0
case 0x1112: goto r1c1d1p2
case 0x1113: goto r1c1d1p3
case 0x1210, 0x121f: goto r1c2d1p0
case 0x1212: goto r1c2d1p2
case 0x1213: goto r1c2d1p3
case 0x1312: goto r1c3d1p2
case 0x1313, 0x131f: goto r1c3d1p3
case 0x2010, 0x201f: goto r2c0d1p0
case 0x2013: goto r2c0d1p3
case 0x2110, 0x211f: goto r2c1d1p0
case 0x2112: goto r2c1d1p2
case 0x2113: goto r2c1d1p3
case 0x2210, 0x221f: goto r2c2d1p0
case 0x2212: goto r2c2d1p2
case 0x2213: goto r2c2d1p3
case 0x2312: goto r2c3d1p2
case 0x2313, 0x231f: goto r2c3d1p3
case 0x3010, 0x301f: goto r3c0d1p0
case 0x3110, 0x311f: goto r3c1d1p0
case 0x3112: goto r3c1d1p2
case 0x3210, 0x321f: goto r3c2d1p0
case 0x3212: goto r3c2d1p2
case 0x3312, 0x331f: goto r3c3d1p2

@ 빈칸을 남쪽으로 옮기는 경우들이다.

@<분기표@>=
case 0x0030, 0x003f: goto r0c0d3p0
case 0x0130: goto r0c1d3p0
case 0x0132, 0x013f: goto r0c1d3p2
case 0x0230: goto r0c2d3p0
case 0x0232, 0x023f: goto r0c2d3p2
case 0x0332, 0x033f: goto r0c3d3p2
case 0x1030: goto r1c0d3p0
case 0x1031, 0x103f: goto r1c0d3p1
case 0x1130: goto r1c1d3p0
case 0x1131: goto r1c1d3p1
case 0x1132, 0x113f: goto r1c1d3p2
case 0x1230: goto r1c2d3p0
case 0x1231: goto r1c2d3p1
case 0x1232, 0x123f: goto r1c2d3p2
case 0x1331: goto r1c3d3p1
case 0x1332, 0x133f: goto r1c3d3p2
case 0x2030: goto r2c0d3p0
case 0x2031, 0x203f: goto r2c0d3p1
case 0x2130: goto r2c1d3p0
case 0x2131: goto r2c1d3p1
case 0x2132, 0x213f: goto r2c1d3p2
case 0x2230: goto r2c2d3p0
case 0x2231: goto r2c2d3p1
case 0x2232, 0x223f: goto r2c2d3p2
case 0x2331: goto r2c3d3p1
case 0x2332, 0x233f: goto r2c3d3p2

@ 0행과 1행에서 수를 무르는 경우들이다.

@<분기표@>=
case 0x0000: goto r0c0d0p0
case 0x0033: goto r0c0d3p3
case 0x0100: goto r0c1d0p0
case 0x0122: goto r0c1d2p2
case 0x0133: goto r0c1d3p3
case 0x0200: goto r0c2d0p0
case 0x0222: goto r0c2d2p2
case 0x0233: goto r0c2d3p3
case 0x0322: goto r0c3d2p2
case 0x0333: goto r0c3d3p3
case 0x1000: goto r1c0d0p0
case 0x1011: goto r1c0d1p1
case 0x1033: goto r1c0d3p3
case 0x1100: goto r1c1d0p0
case 0x1111: goto r1c1d1p1
case 0x1122: goto r1c1d2p2
case 0x1133: goto r1c1d3p3
case 0x1200: goto r1c2d0p0
case 0x1211: goto r1c2d1p1
case 0x1222: goto r1c2d2p2
case 0x1233: goto r1c2d3p3
case 0x1311: goto r1c3d1p1
case 0x1322: goto r1c3d2p2
case 0x1333: goto r1c3d3p3

@ 2행과 3행에서 수를 무르는 경우들이다.

@<분기표@>=
case 0x2000: goto r2c0d0p0
case 0x2011: goto r2c0d1p1
case 0x2033: goto r2c0d3p3
case 0x2100: goto r2c1d0p0
case 0x2111: goto r2c1d1p1
case 0x2122: goto r2c1d2p2
case 0x2133: goto r2c1d3p3
case 0x2200: goto r2c2d0p0
case 0x2211: goto r2c2d1p1
case 0x2222: goto r2c2d2p2
case 0x2233: goto r2c2d3p3
case 0x2311: goto r2c3d1p1
case 0x2322: goto r2c3d2p2
case 0x2333: goto r2c3d3p3
case 0x3000: goto r3c0d0p0
case 0x3011: goto r3c0d1p1
case 0x3100: goto r3c1d0p0
case 0x3111: goto r3c1d1p1
case 0x3122: goto r3c1d2p2
case 0x3200: goto r3c2d0p0
case 0x3211: goto r3c2d1p1
case 0x3222: goto r3c2d2p2
case 0x3311: goto r3c3d1p1
case 0x3322: goto r3c3d2p2

@* 시작과 끝.
안쪽 반복문의 코드는 이제 다 썼다. 남은 것은 두 가지뿐이다. (1)~모든 과정을
굴러가게 하는 것, 그리고 (2)~이 녀석을 결국 멈추게 하는 것.

시작하려면 첫 수를 어느 방향으로 둘지 맨 위(아니, 스택 맨 밑이라고 해야 할까?)
층에서 두세 가지, 많으면 네 가지 결정을 내려야 한다. |tailcode|는 바로 그 일을
하려고 만든 것이다.

과정이 멈추는 길은 둘이다. 풀이가 없거나(그러면 할당량을 늘려 다시 해야 한다), 이기는
길을 찾았거나. 첫째 경우는 아무것도 느리게 하지 않고 쉽게 다룬다. 스택 맨 밑에
특별한 부호 |bottom|을 두기만 하면 된다.

다른 경우, 곧 가장 좋은 경우는 맨 뒤로 미룬다.

@<|t|수를 더 두는 풀이를 찾아본다@>=
for j = 0; j < 16; j++ {
	board[row(j)][col(j)] = start[j]
	if start[j] < 0 {
		k = j
	}
}
stack[0], s = t<<16+bottom, 1
if col(k) != 3 {
	stack[s], s = t<<16+row(k)<<12+col(k)<<8+0x0f, s+1 // 첫 수는 동쪽
}
if row(k) != 0 {
	stack[s], s = t<<16+row(k)<<12+col(k)<<8+0x1f, s+1 // 첫 수는 북쪽
}
if col(k) != 0 {
	stack[s], s = t<<16+row(k)<<12+col(k)<<8+0x2f, s+1 // 첫 수는 서쪽
}
if row(k) != 3 {
	stack[s], s = t<<16+row(k)<<12+col(k)<<8+0x3f, s+1 // 첫 수는 남쪽
}
@<행동을 개시한다@>

@ 이겼다! 스택을 보면 어떻게 여기까지 왔는지 알 수 있으므로, 사용자에게 한 걸음마다
어느 조각을 밀지 쉽게 알려 줄 수 있다. 다만 마지막 두 걸음은 스택에 없다. 크누스의
교묘한 최적화 탓이다. 이기는 수는 스택에 아무것도 쌓기 전에 |win|으로 뛰고, 스택의 각
부호에 적힌 칸은 그 수를 두기 {\it 전의\/} 빈칸 자리이기 때문이다.

크누스는 처음에 그 두 걸음을 사용자의 연습 문제로 남길 생각이었다. 하, 하, 하, 참 우스운
농담이다. 그러나 너무 바보 같아 보였다. 그래서 그는 결국 손을 들고, 그 두 걸음을
처음부터 추론해 내는 법을 궁리했다.

스택에서 |tailcode|들을 건너뛰면 첫 수의 부호가 나오고, 거기 적힌 칸이 처음 빈칸
자리다. 그 뒤의 부호들을 차례로 읽으며 빈칸을 옮기고 옮긴 조각을 찍는다. 부호의 위
두 자리 \hex{$rc$}를 그대로 칸의 자리로 쓴다.

@<결과를 출력한다@>=
fmt.Printf("%d+%d수 풀이: ", moves&0xff, moves>>8)
if moves > 1 {
	for k = 1; stack[k]&0xf == 0xf; k++ {
	}
	for j = 0; j < 16; j++ {
		board[row(j)][col(j)] = start[j]
	}
	j = stack[k] & 0xffff >> 8
	for k++; k < s; k++ {
		del = stack[k] & 0xffff >> 8
		fmt.Printf("%x", board[del>>4][del&0xf]+1)
		board[j>>4][j&0xf], j = board[del>>4][del&0xf], del
	}
	@<마지막 두 걸음을 찍는다@>
} else {
	if moves == 1 {
		fmt.Printf("%x", start[0xf]+1)
	}
	fmt.Printf(" (%d초)\n", elapsed())
}

@ 이제 빈칸은 $j$에 있고, 두 걸음 뒤에 $(3,3)$에 가야 한다. 마지막 수는 $(3,2)$나
$(2,3)$에서 $(3,3)$으로 가는 것이다. 앞의 것이면 조각 \.f가, 뒤의 것이면 조각 \.c가
마지막에 움직인다. 그 앞 수에서 움직인 조각은 $j$로 와서 다시는 움직이지 않으므로
$j$의 제자리 조각이다.

$j=(3,1)$이면 가운데 칸은 $(3,2)$일 수밖에 없으니 \.{ef}이고, $j=(1,3)$이면 \.{8c}다. 그
밖에는 $j=(2,2)$뿐이고, 첫 걸음은 \.b다. 그다음은 지금 $(3,3)$에 있는 조각이다. 빈칸이
$j$에 있으니 이 칸의 값은 믿을 만하다.

@<마지막 두 걸음을 찍는다@>=
if j == 0x31 {
	fmt.Printf("ef\n")
} else if j == 0x13 {
	fmt.Printf("8c\n")
} else {
	fmt.Printf("b%x\n", board[3][3]+1)
}

@* 옮기며 고친 것.
원본의 경우 152가지는 기계로 하나하나 확인했다. 각 경우가 옮기는 조각과 |del|을
구하는 방향, 조각을 놓는 칸, 실패할 때 뛰는 곳과 스택에 쌓는 부호가 같은지, 그 부호가
시계 방향 순서의 다음 방향인지, 다음에 뛰는 곳이 새 칸의 첫 방향인지를 보았다.
|tailcode|가 붙은 경우 48개가 모두 다음에 무르기로 가는지도 보았다. 틀린 것은 하나도
없었다.

결함은 하나다. 처음 배치가 이미 목표이면 원본은 |timer|를 정하기 전에 |win|으로
뛴다. 그래서 전역 변수의 초기값 0부터 잰 시간, 곧 1970년부터의 초를 찍는다.
이를테면 처음 배치 \.{123456789abcdef0}에 원본은 걸린 시간을 \.{(1789790339 sec)}로
찍는다. 이 판은 |moves|를 센 다음 곧바로 |timer|를 정한다.

덧붙여, 원본은 |time(0)-timer|를 \.{\%d}로 찍는다. |time_t|가 64비트인 기계에서는
엄밀히 말해 정의되지 않은 동작이지만, 흔한 기계에서는 우연히 맞게 나온다.

@* 맞춰 보기.
원본 C 프로그램과 이 판을 처음 배치 1800개로 견주었다. 1500개는 목표에서 무작위로
120걸음까지 걸어 나가 얻은 배치이고, 300개는 16진수 숫자의 무작위 순열이다. 순열
가운데 152개는 풀 수 없는 배치였다. 한글로 옮긴 문구를 원본의 것으로 되돌리고 걸린
초를 지우면, 표준 출력이 바이트 하나까지 같다. 할당량마다 찍는 줄과 풀이 수순까지
같다. 명령줄 오류 네 가지도 문구와 종료 코드가 같다.

찍힌 풀이 1648개는 따로 검사했다. 처음 배치에 차례로 적용하면 한 걸음마다 빈칸과
이웃한 조각을 밀고, 끝에서 목표가 되며, 걸음 수가 찍힌 행복한 수와 슬픈 수의 합과
같다.

코르프의 난제 \.{ca6098dfb73254e1}은 두 판 모두 54+11, 곧 65수 풀이를 똑같이 찍는다.
2026년의 내 컴퓨터(애플 실리콘)에서 원본은 23.8초, 이 판은 22.1초 걸렸다. 크누스의
2000년식 애슬론보다 스무 배쯤 빠르다.

@* 색인.
