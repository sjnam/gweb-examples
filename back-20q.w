\input kotexgweb
\input luamplib.sty

% 그림은 back-20q.mp 안에 fig_... 라는 이름의 매크로로 있다. 여기서 한 번 읽어
% 두고 그림 자리마다 이름만 부른다.
\everymplib{input back-20q;}

\def\title{스무 문제}
\datethis

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}
\def\dts{\mathinner{\ldotp\ldotp}}
\def\opt#1{\hbox{(#1)}}

% 표 666을 크누스의 책과 같은 모양으로 짠다. 문제 줄은 폭 전체를 쓰고 보기
% 다섯은 \halign의 다섯 칸에 나란히 선다. \q는 \noalign으로 펼쳐지므로 정렬
% 한가운데에서도 쓸 수 있다. 번호는 1.9em 상자 안에서 오른쪽에 붙인다.
\def\q#1#2{\noalign{\noindent
  \hbox to1.9em{\hfil{\bf #1.}\kern.4em}#2\par}}
\def\qrule{\medskip\hrule\medskip}

@* 들어가며.
Don Woods가 만든 {\it 스무 문제\/}는 객관식 시험이다. 문제가
스물, 보기는 저마다 다섯. 그런데 문제들이 하나같이 {\it 자기 자신을 가리킨다\/}.
``답이 A인 첫 문제는 몇 번인가'', ``답이 D인 문제는 몇 개인가'', ``이 시험에서
받을 수 있는 최고 점수는 얼마인가'' 같은 것들이다. 그래서 답안지를 채우는 일이
곧 커다란 논리 퍼즐을 푸는 일이 된다.

이 프로그램은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{back-20q.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/back-20q.w}를
\GO/로 옮긴 것이다. 하는 일은 이렇다. 스무 개의 답 가운데 적어도 열여덟 개는
맞는다고 보고, 어느 것과 어느 것을 틀리게 할지 명령줄로 지정하면, 그 무늬에
들어맞는 답안지를 하나도 빠짐없이 찾아낸다.

@ 문제들에는 사연이 있다. Don Woods는 2000년에 처음 이 스무 문제를 내놓았는데,
2001년에 뜻하지 않은 답안지가 수십 벌이나 있다는 것---퍼즐 세계의 말로 하면
``익어 버렸다''(cooked)는 것---을 알게 되었다. 그래서 문제를 고쳤는데, 새 문제도
또 익어 버렸다! 2015년에 크누스가 바로 이 프로그램의 도움을 받아, 그리고 Woods
본인과 의논해 가며 다시 다듬은 것이 지금의 판이다. 원래의 맛은 그대로 두면서,
이번에는---적어도 여기 적힌 바로는---익지 않는다.

원문에서 크누스는 이렇게 덧붙인다. ``논리 추론은 까다로울 수 있다. 아래 코드가
버그를 드러낼 만큼 훤히 들여다보이면 좋겠는데.'' 그 바람은 절반쯤만 이루어졌다.
공개된 판에는 결이 다른 오류가 둘 있고, 우리는 그 둘을 만나는 자리마다 짚어
가며 고칠 것이다.

@ 프로그램의 뼈대는 여느 되돌아가기(backtracking) 프로그램과 같다. 명령줄을
읽고, 아무 제약이 없는 상태에서 출발해, 문제를 하나씩 정해 가며 앞뒤가 맞는지
살피고, 막히면 되돌아온다.
@c
package main

import (
	"fmt"
	"os"
	"strconv"
)

@<상수@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 읽는다@>@;
	@<처음 제약을 놓는다@>@;
	@<모든 경우를 되짚어 훑는다@>@;
done:
	@<셈한 것을 알린다@>@;
}

@ 다섯 보기에 $0$부터 $4$까지 번호를 준다. 그리고 ``아직 가능한 보기들''을
비트 다섯 개짜리 집합으로 다루기 위해, 보기마다 비트 하나씩을 맡긴다.
이를테면 |AA+DD|는 ``A와 D가 아직 살아 있다''는 뜻이다.
@<상수@>=
const (
	A = iota // 첫째 보기
	B
	C
	D
	E
)

const (
	AA = 1 << A
	BB = 1 << B
	CC = 1 << C
	DD = 1 << D
	EE = 1 << E
)

@ 상수 |tag|는 잠시 뒤에 설명한다. 되돌리기 스택의 크기는 $20\times20\times6$쯤
이면 넉넉하지 싶은데, 넉넉하게 백만으로 잡았다. 그리고 |delta|는 셈이 오래
걸릴 때 형편을 얼마 만에 한 번씩 알릴지를 정한다.
@<상수@>=
const (
	tag       = 20          // 꼬리표가 놓이는 자리의 어긋남
	stackSize = 1000000     // 되돌리기 스택의 크기
	delta     = 10000000000 // 이만큼 mem마다 형편을 알린다
)

@ 크누스의 프로그램이 늘 그렇듯 {\it mem\/}, 곧 메모리 참조 횟수를 센다.
원문에서는 매크로 |o|와 |oo|가 이 일을 \CEE/의 콤마 연산자로 슬쩍 끼워 넣지만
\GO/에는 그런 재주가 없으니, |mems++|를 앞줄에 그냥 적는다.
@<전역 변수@>=
var (
	mems, nodes, count uint64 // 메모리 참조, 검색나무의 크기, 찾은 답안지 수
	thresh             uint64 = delta // 다음 보고를 할 때
	profile            [22]uint64 // 레벨마다 지나간 노드 수
	false1, false2     int // 명령줄로 받은 두 수
	score              int // 이번 판에서 나오는 답안지의 점수
	falsity            [21]int // 이 문제의 답은 틀려야 하는가?
	believe3           bool // $3$번을 믿어도 되는가?
	vbose              int // 얼마나 수다스럽게 찍을까?
)

@ 잔심부름에 쓰는 색인들을 |main| 안에 둔다. 이름 있는 절들이 이들을 마구
주고받는데, 크누스의 원문이 꼭 그렇게 쓰고 있어서 그대로 따랐다.
@<지역 변수@>=
var i, j, k, l, p, q, t, u, x, y int
var reallyBad bool

@ 명령줄의 두 인자가 ``틀려야 하는 답''의 번호다. 숫자 $0$을 주면 그런 것이 없다는
뜻이니, \.{0 0}이면 스무 문제를 모두 맞히는 답안지를 찾는다. 셋째 인자를 붙이면
(무엇이든) 출력이 수다스러워지고, 넷째, 다섯째를 더 붙이면 더 수다스러워진다.
@<명령줄을 읽는다@>=
if len(os.Args) < 3 {
	usage()
}
false1, false2 = num(os.Args[1]), num(os.Args[2])
score = 20
if false1 > 0 && false1 <= 20 {
	falsity[false1] = 1
	score--
}
if false2 > 0 && false2 <= 20 && false2 != false1 {
	falsity[false2] = 1
	score--
}
believe3 = falsity[3] == 0
vbose = len(os.Args) - 3
@<$6$번이 틀렸다면 할 일이 없다@>@;

@ 왜 그런지는 $6$번을 만날 때 보기로 하고, 여기서는 결과만 쓴다. 곧 $6$번은
틀릴 수가 없다. 그러니 $6$번을 틀리라고 시키면 답은 하나도 없다.
@<$6$번이 틀렸다면 할 일이 없다@>=
if falsity[6] != 0 {
	if vbose != 0 {
		fmt.Fprintln(os.Stderr, "6번은 틀릴 수가 없다.")
	}
	goto done
}

@ 잘못된 명령줄을 만나면 하소연하고 물러난다. 두 함수 모두 여러 곳에서 부른다.
@<함수들@>=
func usage() {
	fmt.Fprintf(os.Stderr, "사용법: %s 틀린것1 틀린것2 [수다]\n", os.Args[0])
	os.Exit(1)
}

func num(s string) int {
	v, err := strconv.Atoi(s)
	if err != nil {
		usage()
	}
	return v
}

@* 스무 문제.
프로그램을 읽기 전에 문제부터 보자. 종이와 연필을 꺼내 직접 풀어 보아도 좋다.
답은 이 글 맨 끝에 있다.
\medskip
{\ninepoint \baselineskip=12pt
\centerline{\bf 표 666}
\smallskip
\centerline{{\it 스무 문제} ({\it 연습문제} 7.2.2--71)}
\qrule
\tabskip=0pt
\halign to\hsize{#\hfil\tabskip=0pt plus1fil
 &#\hfil&#\hfil&#\hfil&#\hfil\tabskip=0pt\cr
\q{1}{답이 A인 첫 문제는:}
\opt{A}~1&\opt{B}~2&\opt{C}~3&\opt{D}~4&\opt{E}~5\cr
\q{2}{이 문제와 답이 같은 다음 문제는:}
\opt{A}~4&\opt{B}~6&\opt{C}~8&\opt{D}~10&\opt{E}~12\cr
\q{3}{답이 똑같은 이웃한 두 문제는 오직:}
\opt{A}~15와 16&\opt{B}~16과 17&\opt{C}~17과 18&\opt{D}~18과 19&
 \opt{E}~19와 20\cr
\q{4}{이 문제의 답은 다음 두 문제의 답과 같다:}
\opt{A}~10과 13&\opt{B}~14와 16&\opt{C}~7과 20&\opt{D}~1과 15&
 \opt{E}~8과 12\cr
\q{5}{14번의 답은:}
\opt{A}~B&\opt{B}~E&\opt{C}~C&\opt{D}~A&\opt{E}~D\cr
\q{6}{이 문제의 답은:}
\opt{A}~A&\opt{B}~B&\opt{C}~C&\opt{D}~D&\opt{E}~그 가운데 없다\cr
\q{7}{가장 자주 나오는 답 하나는:}
\opt{A}~A&\opt{B}~B&\opt{C}~C&\opt{D}~D&\opt{E}~E\cr
\q{8}{똑같이 자주 나오는 답들을 빼고 볼 때, 가장 드문 답은:}
\opt{A}~A&\opt{B}~B&\opt{C}~C&\opt{D}~D&\opt{E}~E\cr
\q{9}{답이 맞았으면서 이 문제와 답이 같은 문제들의 번호를 모두 더하면:}
\opt{A}~$\in[59\dts62]$&\opt{B}~$\in[52\dts55]$&\opt{C}~$\in[44\dts49]$&
 \opt{D}~$\in[59\dts67]$&\opt{E}~$\in[44\dts53]$\cr
\q{10}{17번의 답은:}
\opt{A}~D&\opt{B}~B&\opt{C}~A&\opt{D}~E&\opt{E}~틀렸다\cr
\q{11}{답이 D인 문제의 개수는:}
\opt{A}~2&\opt{B}~3&\opt{C}~4&\opt{D}~5&\opt{E}~6\cr
\q{12}{이 문제와 답이 같은 {\it 다른\/} 문제의 개수는, 답이 다음인 문제의
 개수와 같다:}
\opt{A}~B&\opt{B}~C&\opt{C}~D&\opt{D}~E&\opt{E}~그 가운데 없다\cr
\q{13}{답이 E인 문제의 개수는:}
\opt{A}~5&\opt{B}~4&\opt{C}~3&\opt{D}~2&\opt{E}~1\cr
\q{14}{어떤 답도 정확히 이만큼 나오지는 않는다:}
\opt{A}~2&\opt{B}~3&\opt{C}~4&\opt{D}~5&\opt{E}~그 가운데 없다\cr
\q{15}{답이 A인 홀수 번호 문제들의 집합은:}
\opt{A}~$\{7\}$&\opt{B}~$\{9\}$&\opt{C}~$\{11\}$이 아니다&\opt{D}~$\{13\}$&
 \opt{E}~$\{15\}$\cr
\q{16}{8번의 답은 다음 문제의 답과 같다:}
\opt{A}~3&\opt{B}~2&\opt{C}~13&\opt{D}~18&\opt{E}~20\cr
\q{17}{10번의 답은:}
\opt{A}~C&\opt{B}~D&\opt{C}~B&\opt{D}~A&\opt{E}~맞았다\cr
\q{18}{답이 모음인 소수 번호 문제의 개수는:}
\opt{A}~소수&\opt{B}~제곱수&\opt{C}~홀수&\opt{D}~짝수&\opt{E}~0\cr
\q{19}{답이 B인 마지막 문제는:}
\opt{A}~14&\opt{B}~15&\opt{C}~16&\opt{D}~17&\opt{E}~18\cr
\q{20}{이 시험에서 받을 수 있는 최고 점수는:}
\opt{A}~18&\opt{B}~19&\opt{C}~20&\opt{D}~정해지지 않는다&\cr
&&&\multispan2\opt{E}~이 문제를 틀려야만 얻을 수 있다\hfil\cr}
\medskip\hrule}
\medskip
\noindent 여기서 A와 E는 {\it 모음\/}이고, 소수 번호 문제란 2, 3, 5, 7, 11,
13, 17, 19번이다.

@* 작전.
부분 정보는 모두 |mem|이라는 작은 배열에 담는다. 자리 |mem[1]|부터
|mem[20]|까지에는 문제마다 아직 지워지지 않은 보기들의 비트맵이 들어간다.
그다음 스무 자리, 곧 |mem[tag+1]|부터 |mem[tag+20]|까지에는 {\it 꼬리표\/}가
붙는다. 값이 $0$이 아니면 ``이 문제는 레벨 21에서 다시 한번 확인해야 한다''는
뜻이다.

문제를 둘로 나누는 셈이다. 그 자리에서 값싸게 앞뒤가 안 맞는 것을 잡아낼 수
있으면 잡아내고, 스무 답이 다 정해져야만 판가름 나는 것은 미뤄 둔다.
이를테면 ``답이 D인 문제의 개수''는 마지막에 세어 보아야 알 수 있다.

@ 값이 바뀔 때마다 옛 값을 되돌리기 스택에 쌓아 둔다. 어떤 자리 |mem[p]|가 $a$에서 $b$로
바뀌면 |(p<<8)+a|를 스택에 얹는다. 레벨 |l|에 들어설 때 스택에 몇 개가 쌓여
있었는지는 |frame[l]|에 적어 둔다. 되돌아올 때는 거기까지 벗겨 내면 된다.

크누스는 A, B, C, D, E의 개수에 위아래 한계를 두고 다니는 것도 생각해 보았다고
적었다. 그런데 그 방법은 실수하기 쉬워 보였고, 손으로 몇 번 해 보니 그런 재주를
부리지 않아도 쓸 만한 가지치기가 가능했다고 한다.
@<전역 변수@>=
var (
	mem       [41]int // 되돌아가기의 대상이 되는 상태
	stack     [stackSize]int // |mem|의 변경을 되돌리기 위해
	stackptr  int // 스택에 지금 몇 개가 쌓여 있는가
	frame     [21]int // 레벨마다의 스택 높이
)

@ 처음에는 스무 답이 모두 자유롭다.
@<처음 제약을 놓는다@>=
for q = 1; q <= 20; q++ {
	mems++; mem[q] = AA + BB + CC + DD + EE
}

@ 어떤 문제는 검색나무의 뿌리 가까이에서 다루는 편이 훨씬 낫다. 그래서 부분
답안지를 지어 가는 차례를 미리 정해 둔다. 이 차례는 끝까지 바뀌지 않는다.
그러니 이를테면 1번을 다룰 때에는 2번과 3번을 비롯한 여럿이 이미 정해져 있음을
알고 쓸 수 있다.

3번을 맨 앞에 두는 것이 특히 좋다. 그 답이 맞아야 한다면, |loguy|와 |higuy|라
부르는 한 쌍만 빼고는 이웃한 두 답이 같아서는 안 된다는 강력한 조건이 곧바로
생기기 때문이다.
$$\mplibcode fig_order; \endmplibcode$$
\figcap{{\it 그림\/} 1: 문제를 푸는 차례. 왼쪽이 먼저다. 위에 걸린 활은
``이 문제를 다루려면 저 문제가 이미 정해져 있어야 한다''는 뜻이고, 코드가
그 앞뒤 관계에 기대는 자리마다 본문에서 짚어 둔다.}

@ @<전역 변수@>=
var (
	order = [21]int{0, 3, 15, 20, 19, 2, 1, 17, 10, 5, 4, 16, 11, 13, 14, 7, 18, 6, 8, 12, 9}
	loguy, higuy int // 답이 같아도 되는 이웃 한 쌍
	rho = [32]int{-1, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4,
	 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0} // 5비트 수의 줄자 함수
)

@ 표 |rho|는 {\it 줄자 함수\/}(ruler function)이다. 인자 $y$의 가장 낮은 $1$비트가
몇 번째인지를 돌려준다. 비트맵에서 아직 살아 있는 보기 가운데 가장 앞의 것을
고를 때 쓰고, 비트가 하나만 남았을 때 그것이 무슨 글자인지 읽을 때도 쓴다.

편의를 위한 작은 함수 셋을 먼저 만들어 두자. 함수 |pack|은 ``이 문제의 답을
이 글자로 놓았고, 그 답은 맞아야(틀려야) 한다''는 세 정보를 정수 하나에
담는다. 아래의 커다란 스위치가 이 정수로 갈린다.
@<함수들@>=
func pack(u, q, x int) int { return u<<8 + q<<3 + x }

func letter(q, x int) byte {
	if falsity[q] != 0 {
		return byte('a' + x) // 틀려야 하는 답은 소문자로 적는다
	}
	return byte('A' + x)
}

@ 함수 |eq|와 |ne|는 |mem[q]|를 한 번 읽고 견주기만 한다. 굳이 함수로 만든
까닭은 mem을 정확히 한 번만 세기 위해서다. \GO/의 |&&|(\&\&)가 짧은 회로로 끊기면
뒤의 |eq|는 아예 불리지 않으므로, 원문의 콤마 연산자 트릭과 셈이 똑같아진다.

함수 |clash|는 앞으로 스무 번쯤 쓰인다. 어떤 주장이 참인지 아닌지를 |holds|로
받아, 그것이 우리가 바라는 바(|u|가 $0$이면 참이어야, $1$이면 거짓이어야)와
어긋나는지 답한다.
@<함수들@>=
func eq(q, b int) bool { mems++; return mem[q] == b }
func ne(q, b int) bool { mems++; return mem[q] != b }

func clash(u int, holds bool) bool { return holds == (u != 0) }

@* 이웃으로 번지는 강제.
배열 |mem[1]|부터 |mem[20]|까지의 값은 오직 |remov|와 |force| 두 함수로만
바뀐다. 함수 |remov|는 문제 |q|에서 보기 |x|를 지우고 남은 비트맵을 돌려준다.
지울 것이 없으면 아무 일도 하지 않는다.

여기에 한 가지가 더 있다. 3번을 믿어도 된다면(곧 3번의 답이 맞아야 한다면)
비트맵이 딱 한 비트로 줄어든 순간 그 문제 번호를 |pstack|에 얹어 둔다.
그것이 이웃으로 번져 갈 씨앗이다.
@<함수들@>=
func remov(q, x int) int {
	t := 1 << x
	mems++; b := mem[q]
	if b&t == 0 {
		return b
	}
	if vbose > 2 {
		fmt.Fprintf(os.Stderr, "(%d: %d번은 %c가 아니다)\n", stackptr, q, letter(q, x))
	}
	bb := b - t
	mems++; mem[q] = bb
	mems++; stack[stackptr] = q<<8 + b
	stackptr++
	if believe3 && bb != 0 && bb&(bb-1) == 0 {
		mems++; pstack[pstackptr] = q
		pstackptr++
	}
	return bb
}

@ 함수 |force|는 |x|만 남기고 나머지를 모두 버린다. 보기 |x|가 이미 없었다면
{\it 거짓\/}을 돌려주는데, 이는 ``이 길은 막혔다''는 뜻이다.
@<함수들@>=
func force(q, x int) bool {
	t := 1 << x
	mems++; b := mem[q]
	if b&t == 0 {
		return false
	}
	if b != t {
		if vbose > 2 {
			fmt.Fprintf(os.Stderr, "(%d: %d번은 %c다)\n", stackptr, q, letter(q, x))
		}
		mems++; mem[q] = t
		mems++; stack[stackptr] = q<<8 + b
		stackptr++
		if believe3 {
			mems++; pstack[pstackptr] = q
			pstackptr++
		}
	}
	return true
}

@ 함수 |deny|는 |remov|를 감싸면서 두 가지를 더 본다. 마지막 보기까지 지워
버리면 막힌 것이고, |loguy|와 |higuy|는 답이 같아야 하는 짝이므로 한쪽에서
지운 것은 다른 쪽에서도 지워야 한다.

여러 문제에서 같은 보기를 한꺼번에 지울 일이 잦아, 목록을 받는 |denyAll|과
구간을 받는 |denyRange|도 함께 둔다. 어느 하나라도 막히면 곧바로 멈춘다.
@<함수들@>=
func deny(q, x int) bool {
	if remov(q, x) == 0 {
		return false
	}
	if q == loguy && remov(higuy, x) == 0 {
		return false
	}
	if q == higuy && remov(loguy, x) == 0 {
		return false
	}
	return true
}

func denyAll(x int, qs ...int) bool {
	for _, q := range qs {
		if !deny(q, x) {
			return false
		}
	}
	return true
}

func denyRange(x, lo, hi int) bool {
	for q := lo; q <= hi; q++ {
		if !deny(q, x) {
			return false
		}
	}
	return true
}

@ 이제 번지기다. 3번이 명령줄에서 틀리도록 지정되지 않았다면, |loguy|와
|higuy| 한 쌍을 빼고는 이웃한 두 답이 같을 수 없다. 그래서 |mem| 한 자리의
변화가 옆으로 번져 간다.
$$\mplibcode fig_prop; \endmplibcode$$
\figcap{{\it 그림\/} 2: 5번부터 9번까지에 남은 보기가 차례로 CD, AC, BD, ABE,
BCD라 하자. 여기서 8번을 B로 못박으면 7번은 D밖에 될 수 없고, 그러면 6번도
A밖에 될 수 없다. 9번도 B를 잃는다. 이렇게 한 번의 변화가 사슬처럼 이어진다.}

@ 번지기를 처리하는 것이 |pstack| 하나다. 비트가 하나로 줄어든 문제들이 거기
쌓여 있으니, 하나씩 꺼내어 양옆에 알려 준다. 알려 주다 보면 또 새로 하나가
되는 것이 생겨 |pstack|에 얹히고, 그렇게 저절로 끝까지 번진다.

이 절은 두 곳에서 쓰인다. 답을 하나 골랐을 때, 그리고 고르지 {\it 않기로\/}
했을 때다.
@<강제된 결과를 이웃으로 퍼뜨린다@>=
for pstackptr != 0 {
	pstackptr--
	mems++; t = pstack[pstackptr]
	mems += 2; j = rho[mem[t]]
	if vbose > 3 {
		fmt.Fprintf(os.Stderr, "(%d%c에서 퍼뜨린다)\n", t, 'A'+j)
	}
	@<오른쪽 이웃에게 알린다@>@;
	@<왼쪽 이웃에게 알린다@>@;
}

@ 오른쪽 이웃이 |higuy|라면---곧 지금 보는 것이 |loguy|라면---둘은 답이 같아야
하므로 지우는 것이 아니라 못박는다. 그렇지 않고 오른쪽에 이웃이 있으면 같은
글자를 지운다.
@<오른쪽 이웃에게 알린다@>=
if t == loguy {
	if !force(t+1, j) {
		goto bad
	}
} else if t < 20 {
	if !deny(t+1, j) {
		goto bad
	}
}

@ @<왼쪽 이웃에게 알린다@>=
if t == higuy {
	if !force(t-1, j) {
		goto bad
	}
} else if t > 1 {
	if !deny(t-1, j) {
		goto bad
	}
}

@ @<전역 변수@>=
var (
	pstack    [21]int // 번져 나갈 씨앗들
	pstackptr int // 씨앗이 몇 개 쌓여 있는가
)

@* 되돌아가기.
문제마다의 논리를 끼워 넣을 환경을 이제 짓는다. 얼개는 크누스의 되돌아가기
알고리즘 그대로다. 레이블 |b2|에서 레벨 |l|의 문제를 집어 들고, |b3|에서 남은 보기
가운데 가장 앞의 것을 골라 커다란 스위치로 들어간다. 스위치는 반드시
|okay|(그럴듯하다), |bad|(막혔다), |postpone|(나중에 보자) 가운데 하나로
빠져나온다.
@<모든 경우를 되짚어 훑는다@>=
l, stackptr = 1, 0
b2:
	nodes++
	profile[l]++
	if mems >= thresh {
		@<형편을 알리고 |thresh|를 올린다@>@;
	}
	if l > 20 {
		@<답인지 확인하고 |b5|로 간다@>@;
	}
	mems += 2; q = order[l]; u = falsity[q]
	mems++; y = mem[q]
b3:
	if y == 0 {
		fmt.Fprintln(os.Stderr, "어리둥절하다!")
		os.Exit(1)
	}
	p = stackptr
	mems++; x = rho[y]
	pstackptr = 0
	if vbose > 1 {
		fmt.Fprintf(os.Stderr, "레벨 %d(%d), %d%c 시도\n", l, p, q, letter(q, x))
	}
	switch pack(u, q, x) {
	@<큰 스위치의 갈래들@>@;
	default:
		fmt.Fprintf(os.Stderr, "있을 수 없는 경우 %d%c!\n", q, letter(q, x))
		os.Exit(1)
	}
@<한 걸음 나아가거나, 물러서거나@>@;

@ 갈래가 |postpone|으로 빠져나오면 꼬리표를 하나 세우고 그대로 |okay|로
흘러든다. 꼬리표도 되돌리기 스택에 쌓아 두어야 함을 잊지 말자.
@<한 걸음 나아가거나, 물러서거나@>=
postpone:
	mems += 2; mem[tag+q] = 1; stack[stackptr] = (q + tag) << 8
	stackptr++
	if vbose > 1 {
		fmt.Fprintf(os.Stderr, "(%d: %d%c를 미룬다)\n", stackptr-1, q, letter(q, x))
	}
okay:
	if !force(q, x) {
		goto bad
	}
	@<강제된 결과를 이웃으로 퍼뜨린다@>@;
	mems++; frame[l] = p
	l++
	goto b2
@<막혔을 때@>@;

@ 막혔다는 것은 |x|가 문제 |q|의 답일 수 없다는 뜻이다. 그러면 |b4|로 가서
|x|를 지워 보는데, 지우는 것마저 막히면(|reallyBad|) 이 레벨에서는 더 해 볼
것이 없으니 한 층 물러선다.
@<막혔을 때@>=
bad:
	if reallyBad {
		reallyBad = false // |x|를 고를 수도, 안 고를 수도 없다
		goto b5
	}
	for stackptr > p {
		@<저장해 둔 것을 하나 되돌린다@>@;
	}
b4:
	reallyBad = true
	pstackptr = 0
	if !deny(q, x) { // |x|가 마지막 보기였다면 여기서 물러선다
		goto bad
	}
	@<강제된 결과를 이웃으로 퍼뜨린다@>@;
	reallyBad = false
	y -= 1 << x // 이제 |y|는 |mem[q]|와 같아야 한다
	if y != mem[q] {
		fmt.Fprintln(os.Stderr, "내가 망쳤다!")
		os.Exit(1)
	}
	goto b3
@<한 층 물러선다@>@;

@ 한 층 물러설 때에는 그 레벨에 들어설 때의 상태로 되돌린 다음, 그때 고르려
했던 보기를 다시 꺼내어 |b4|로 간다. 레벨이 $0$이 되면 다 끝난 것이다.
@<한 층 물러선다@>=
b5:
	l--
	if l != 0 {
		mems += 2; q = order[l]; u = falsity[q]
		mems++; p = frame[l]
		for stackptr > p {
			@<저장해 둔 것을 하나 되돌린다@>@;
		}
		mems += 2; y = mem[q]; x = rho[y]
		goto b4
	}

@ @<저장해 둔 것을 하나 되돌린다@>=
mems++; stackptr--
t = stack[stackptr]
mems++; mem[t>>8] = t & 0x1f

@ @<형편을 알리고 |thresh|를 올린다@>=
fmt.Fprintf(os.Stderr, "mem %d 지난 뒤: l=%d, stackptr=%d\n", mems, l, stackptr)
thresh += delta

@ @<셈한 것을 알린다@>=
fmt.Fprintf(os.Stderr, "모두 해서 답 %d가지 (mem %d, 노드 %d).\n", count, mems, nodes)
if vbose != 0 {
	fmt.Fprintln(os.Stderr, "레벨별 노드 수:          1")
	for k = 2; k <= 21; k++ {
		fmt.Fprintf(os.Stderr, "%19d\n", profile[k])
	}
}

@ 레벨 21에 이르면 스무 답이 모두 하나로 정해진 것이다. 미뤄 둔 확인을 이제
모두 해야 한다. 그 전에 답의 분포부터 세어 둔다. 7, 8, 11, 12, 13, 14번이
이 분포를 본다.
@<답인지 확인하고 |b5|로 간다@>=
@<답의 분포를 센다@>@;
for q = 1; q <= 20; q++ {
	mems++
	if mem[tag+q] == 0 {
		continue
	}
	mems += 2; x = rho[mem[q]]
	mems++; u = falsity[q]
	if vbose > 1 {
		fmt.Fprintf(os.Stderr, "%d%c 확인\n", q, letter(q, x))
	}
	switch pack(u, q, x) {
	@<미룬 스위치의 갈래들@>@;
	default:
		fmt.Fprintf(os.Stderr, "있을 수 없는 미룬 경우 %d%c!\n", q, letter(q, x))
		os.Exit(1)
	}
}
@<답안지 하나를 찍는다@>@;
goto b5

@ 값 |trick|은 14번이 쓸 잔재주인데, 거기서 설명한다.
@<답의 분포를 센다@>=
{
	dA, dB, dC, dD, dE := 0, 0, 0, 0, 0
	for q = 1; q <= 20; q++ {
		mems++
		switch mem[q] {
		case AA:
			dA++
		case BB:
			dB++
		case CC:
			dC++
		case DD:
			dD++
		default:
			dE++
		}
	}
	mems += 5
	dist[A], dist[B], dist[C], dist[D], dist[E] = dA, dB, dC, dD, dE
	trick = 1<<dA + 1<<dB + 1<<dC + 1<<dD + 1<<dE
}

@ @<전역 변수@>=
var (
	dist  [5]int // A, B, C, D, E가 몇 번씩 나오는가
	tie   [5]int // 다른 것과 개수가 같은 보기들
	trick int
)

@ @<답안지 하나를 찍는다@>=
count++
fmt.Printf("%d: ", count)
for q = 1; q <= 20; q++ {
	fmt.Printf("%c", letter(q, rho[mem[q]]))
}
fmt.Println()

@* 문제 하나하나.
이제 스무 문제를 하나씩 옮겨 적는다. 문제마다 원문의 영어를 우리말로 옮긴
것을 먼저 적고, 그 뜻을 코드로 바꾸는 논리를 밝힌다. 앞뒤 관계에 기대는
자리에서는 그것도 함께 적어 둔다.

커다란 스위치의 갈래는 저마다 |okay|, |bad|, |postpone| 가운데 하나로 나가고,
미룬 스위치의 갈래는 조건이 어긋나면 |b5|로 나가며 그렇지 않으면 그냥 끝난다.

원문은 갈래를 백 개 남짓 하나하나 펼쳐 적었지만, 여기서는 보기 다섯이 문제
글 안에서 이미 표를 이루는 곳---이를테면 2번의 ``4, 6, 8, 10, 12''---은 표로
묶었다. 뜻이 달라지지 않았음은 맨 뒤에서 낱낱이 확인한다.

@ ``1. 답이 A인 첫 문제는: \opt{A}~1 \opt{B}~2 \opt{C}~3 \opt{D}~4 \opt{E}~5''

답이 맞아야 한다면 쉽다. 곧 $x+1$번이 A라는 첫 문제이니, 그보다 앞은 모두 A가
아니고 $x+1$번은 A다.
@<큰 스위치의 갈래들@>=
case pack(0, 1, A):
	goto okay
case pack(0, 1, B), pack(0, 1, C), pack(0, 1, D), pack(0, 1, E):
	if !denyRange(A, 1, x) || !force(x+1, A) {
		goto bad
	}
	goto okay

@ 답이 틀려야 한다면 이야기가 미묘해진다. 여기서 차례가 힘을 발휘한다. 1번을
다룰 때 2번과 3번은 이미 정해져 있으므로, 그 둘 가운데 A가 보이면 ``A인 첫
문제는 $x+1$번''이라는 주장은 그 자리에서 거짓이 된다.

그렇지 않다면 $x+1$번이 A가 아니기만 하면 된다. 다만 \opt{E}일 때는 4번과
5번을 아직 모르므로 미뤄 둔다. 그리고 \opt{A}는 애초에 불가능하다---1번의
답이 A인데 ``A인 첫 문제가 1번''이 거짓일 수는 없다.
@<큰 스위치의 갈래들@>=
case pack(1, 1, A):
	goto bad
case pack(1, 1, B), pack(1, 1, C), pack(1, 1, D), pack(1, 1, E):
	for i = 2; i <= x && i <= 3; i++ {
		if eq(i, AA) {
			goto okay
		}
	}
	if x < E {
		if !deny(x+1, A) {
			goto bad
		}
		goto okay
	}
	goto postpone

@ 미뤄 둔 확인은 조건이 어긋나면 |b5|로 나간다. 여기서는 4번이 A가 아니고
5번이 A라면 ``A인 첫 문제는 5번''이 참이 되어 버리므로 물러선다.
@<미룬 스위치의 갈래들@>=
case pack(1, 1, E):
	if ne(4, AA) && eq(5, AA) {
		goto b5
	}

@ ``2. 이 문제와 답이 같은 다음 문제는:
\opt{A}~4 \opt{B}~6 \opt{C}~8 \opt{D}~10 \opt{E}~12''

답이 맞아야 한다면, 3번부터 그 앞까지는 같은 글자가 나오면 안 되고 지목한
자리는 같은 글자여야 한다.
@<큰 스위치의 갈래들@>=
case pack(0, 2, A), pack(0, 2, B), pack(0, 2, C), pack(0, 2, D), pack(0, 2, E):
	k = nextsame[x]
	if !denyRange(x, 3, k-1) || !force(k, x) {
		goto bad
	}
	goto okay

@ 답이 틀려야 한다면 3번이 열쇠다. 3번은 이미 정해져 있으므로, 3번이 같은
글자라면 ``다음 자리는 $k$번''이라는 주장은 곧바로 거짓이다. \opt{A}는 4번
하나만 지우면 되지만, 나머지는 4번부터 $k$번까지를 다 보아야 하니 미룬다.
@<큰 스위치의 갈래들@>=
case pack(1, 2, A):
	if ne(3, AA) && !deny(4, A) {
		goto bad
	}
	goto okay
case pack(1, 2, B), pack(1, 2, C), pack(1, 2, D), pack(1, 2, E):
	if eq(3, 1<<x) {
		goto okay
	}
	goto postpone

@ @<미룬 스위치의 갈래들@>=
case pack(1, 2, B), pack(1, 2, C), pack(1, 2, D), pack(1, 2, E):
	k = nextsame[x]
	for i = 4; i < k; i++ {
		if eq(i, 1<<x) {
			break // 더 앞에서 같은 답이 나오니 주장은 거짓
		}
	}
	if i == k && eq(k, 1<<x) {
		goto b5
	}

@ @<전역 변수@>=
var nextsame = [5]int{4, 6, 8, 10, 12}

@ ``3. 답이 똑같은 이웃한 두 문제는 오직:
\opt{A}~15와 16 \opt{B}~16과 17 \opt{C}~17과 18 \opt{D}~18과 19
\opt{E}~19와 20''

이 문제가 맨 처음에 오는 까닭이 여기 있다. 답이 맞아야 한다면 |loguy|와
|higuy|가 정해지고, 그 순간부터 온 프로그램에 ``이웃한 답은 다르다''는
규칙이 깔린다. 앞에서 본 번지기가 바로 이 규칙이다.
@<큰 스위치의 갈래들@>=
case pack(0, 3, A), pack(0, 3, B), pack(0, 3, C), pack(0, 3, D), pack(0, 3, E):
	loguy, higuy = 15+x, 16+x
	goto okay
case pack(1, 3, A), pack(1, 3, B), pack(1, 3, C), pack(1, 3, D), pack(1, 3, E):
	goto postpone

@ 답이 틀려야 한다면 아무 규칙도 얻지 못하므로 끝까지 미룬다. 확인은 두
걸음이다. 먼저 15번부터 20번까지가 주장한 무늬와 정확히 맞는지 본다. 하나라도
어긋나면 주장은 이미 거짓이니 좋다. 정확히 맞는다면, 1번부터 15번 사이에
같은 이웃이 하나라도 있어야 ``오직''이 깨진다. 그마저 없다면 주장이 참이
되어 버리므로 물러선다.
@<미룬 스위치의 갈래들@>=
case pack(1, 3, A), pack(1, 3, B), pack(1, 3, C), pack(1, 3, D), pack(1, 3, E):
	mems++
	for i = 15; i < 20; i++ {
		mems++
		if (mem[i] == mem[i+1]) != (i == 15+x) {
			break
		}
	}
	if i < 20 {
		break // 주장과 어긋나는 곳이 벌써 있다
	}
	mems++
	for i = 1; i < 15; i++ {
		mems++
		if mem[i] == mem[i+1] {
			break
		}
	}
	if i == 15 {
		goto b5
	}

@ ``4. 이 문제의 답은 다음 두 문제의 답과 같다:
\opt{A}~10과 13 \opt{B}~14와 16 \opt{C}~7과 20 \opt{D}~1과 15
\opt{E}~8과 12''

차례를 보면 1, 10, 15, 20번이 4번보다 앞선다. 답이 맞아야 한다면 지목한 둘을
같은 글자로 못박기만 하면 된다.
@<큰 스위치의 갈래들@>=
case pack(0, 4, A), pack(0, 4, B), pack(0, 4, C), pack(0, 4, D), pack(0, 4, E):
	if !force(same4[x][0], x) || !force(same4[x][1], x) {
		goto bad
	}
	goto okay

@ 답이 틀려야 한다면 둘 가운데 하나만 달라도 된다. 이미 정해진 것을 보고
곧바로 판가름 낼 수 있으면 그렇게 하고, 아니면 미룬다. \opt{D}는 1번과 15번이
모두 이미 정해져 있으니 미룰 것도 없다.
@<큰 스위치의 갈래들@>=
case pack(1, 4, A):
	if ne(10, AA) {
		goto okay
	}
	goto postpone
case pack(1, 4, B), pack(1, 4, E):
	goto postpone
case pack(1, 4, C):
	if ne(20, CC) {
		goto okay
	}
	goto postpone
case pack(1, 4, D):
	if ne(1, DD) || ne(15, DD) {
		goto okay
	}
	goto bad

@ 미룬 확인에서는 아직 보지 않은 쪽만 보면 된다. \opt{A}는 10번이 이미 A임을
알고 왔으니 13번만, \opt{C}는 20번이 이미 C이니 7번만 보면 된다.
@<미룬 스위치의 갈래들@>=
case pack(1, 4, A):
	if eq(13, AA) {
		goto b5
	}
case pack(1, 4, B):
	if eq(14, BB) && eq(16, BB) {
		goto b5
	}
case pack(1, 4, C):
	if eq(7, CC) {
		goto b5
	}
case pack(1, 4, E):
	if eq(8, EE) && eq(12, EE) {
		goto b5
	}

@ @<전역 변수@>=
var same4 = [5][2]int{{10, 13}, {14, 16}, {7, 20}, {1, 15}, {8, 12}}

@ ``5. 14번의 답은: \opt{A}~B \opt{B}~E \opt{C}~C \opt{D}~A \opt{E}~D''

가장 단순한 문제다. 맞아야 하면 못박고, 틀려야 하면 지운다.
@<큰 스위치의 갈래들@>=
case pack(0, 5, A), pack(0, 5, B), pack(0, 5, C), pack(0, 5, D), pack(0, 5, E):
	if !force(14, q5ans[x]) {
		goto bad
	}
	goto okay
case pack(1, 5, A), pack(1, 5, B), pack(1, 5, C), pack(1, 5, D), pack(1, 5, E):
	if !deny(14, q5ans[x]) {
		goto bad
	}
	goto okay

@ @<전역 변수@>=
var q5ans = [5]int{B, E, C, A, D}

@ ``6. 이 문제의 답은:
\opt{A}~A \opt{B}~B \opt{C}~C \opt{D}~D \opt{E}~그 가운데 없다''

이 문제는 무슨 답을 골라도 맞는다. \opt{A}를 골랐으면 ``이 문제의 답은
A''이니 참이고, \opt{E}를 골랐으면 ``A도 B도 C도 D도 아니다''인데 답이
E이니 역시 참이다. 그래서 6번은 {\it 틀릴 수가 없다\/}. 앞에서 명령줄을 읽자마자
물러났던 까닭이다.
@<큰 스위치의 갈래들@>=
case pack(0, 6, A), pack(0, 6, B), pack(0, 6, C), pack(0, 6, D), pack(0, 6, E):
	goto okay
case pack(1, 6, A), pack(1, 6, B), pack(1, 6, C), pack(1, 6, D), pack(1, 6, E):
	goto bad

@ 7, 8, 9, 11, 12, 13, 14번은 하나같이 답 스물의 분포를 보아야 판가름 난다.
그러니 커다란 스위치에서는 아무 일도 하지 않고 그저 미룬다.
@<큰 스위치의 갈래들@>=
case pack(0, 7, A), pack(0, 7, B), pack(0, 7, C), pack(0, 7, D), pack(0, 7, E),
	pack(1, 7, A), pack(1, 7, B), pack(1, 7, C), pack(1, 7, D), pack(1, 7, E),
	pack(0, 8, A), pack(0, 8, B), pack(0, 8, C), pack(0, 8, D), pack(0, 8, E),
	pack(1, 8, A), pack(1, 8, B), pack(1, 8, C), pack(1, 8, D), pack(1, 8, E),
	pack(0, 9, A), pack(0, 9, B), pack(0, 9, C), pack(0, 9, D), pack(0, 9, E),
	pack(1, 9, A), pack(1, 9, B), pack(1, 9, C), pack(1, 9, D), pack(1, 9, E),
	pack(0, 11, A), pack(0, 11, B), pack(0, 11, C), pack(0, 11, D), pack(0, 11, E),
	pack(1, 11, A), pack(1, 11, B), pack(1, 11, C), pack(1, 11, D), pack(1, 11, E),
	pack(0, 12, A), pack(0, 12, B), pack(0, 12, C), pack(0, 12, D), pack(0, 12, E),
	pack(1, 12, A), pack(1, 12, B), pack(1, 12, C), pack(1, 12, D), pack(1, 12, E),
	pack(0, 13, A), pack(0, 13, B), pack(0, 13, C), pack(0, 13, D), pack(0, 13, E),
	pack(1, 13, A), pack(1, 13, B), pack(1, 13, C), pack(1, 13, D), pack(1, 13, E),
	pack(0, 14, A), pack(0, 14, B), pack(0, 14, C), pack(0, 14, D), pack(0, 14, E),
	pack(1, 14, A), pack(1, 14, B), pack(1, 14, C), pack(1, 14, D), pack(1, 14, E):
	goto postpone

@ ``7. 가장 자주 나오는 답 하나는:
\opt{A}~A \opt{B}~B \opt{C}~C \opt{D}~D \opt{E}~E''

``가장 자주 나오는 답 {\it 하나\/}''라는 말씨가 중요하다. 여러 개가 나란히
1등이어도 그 가운데 아무거나 하나면 참이다. 그러니 자기보다 많이 나온 것이
없기만 하면 된다.
@<미룬 스위치의 갈래들@>=
case pack(0, 7, A), pack(0, 7, B), pack(0, 7, C), pack(0, 7, D), pack(0, 7, E),
	pack(1, 7, A), pack(1, 7, B), pack(1, 7, C), pack(1, 7, D), pack(1, 7, E):
	mems++; j = dist[x]
	for i = 0; i < 5; i++ {
		mems++
		if dist[i] > j {
			break
		}
	}
	if clash(u, i == 5) {
		goto b5
	}

@ ``8. 똑같이 자주 나오는 답들을 빼고 볼 때, 가장 드문 답은:
\opt{A}~A \opt{B}~B \opt{C}~C \opt{D}~D \opt{E}~E''

이번에는 1등이 여럿이면 안 된다는 것이 아니라, 개수가 같은 것끼리는 아예
{\it 셈에서 뺀다\/}는 뜻이다. 그래서 먼저 짝이 있는 것들을 표시하고, 짝이 없는
것들 가운데 가장 작은 개수를 찾는다. 그런 것이 하나도 없으면 $100$이라는
있을 수 없는 값이 남고, 그러면 어떤 보기도 참이 되지 못한다.
@<미룬 스위치의 갈래들@>=
case pack(0, 8, A), pack(0, 8, B), pack(0, 8, C), pack(0, 8, D), pack(0, 8, E),
	pack(1, 8, A), pack(1, 8, B), pack(1, 8, C), pack(1, 8, D), pack(1, 8, E):
	for i = 0; i < 5; i++ {
		mems++; tie[i] = 0
	}
	@<개수가 같은 것끼리 짝지어 표시한다@>@;
	@<짝 없는 것들 가운데 가장 드문 개수를 |j|에 담는다@>@;
	if clash(u, j == dist[x]) {
		goto b5
	}

@ @<개수가 같은 것끼리 짝지어 표시한다@>=
for i = 0; i < 5; i++ {
	for j = i + 1; j < 5; j++ {
		mems += 2
		if dist[i] == dist[j] {
			mems += 2
			tie[i], tie[j] = 1, 1
		}
	}
}

@ @<짝 없는 것들 가운데 가장 드문 개수를 |j|에 담는다@>=
j = 100
for i = 0; i < 5; i++ {
	mems++
	if tie[i] != 0 {
		continue
	}
	mems++
	if dist[i] < j {
		j = dist[i]
	}
}

@ ``9. 답이 맞았으면서 이 문제와 답이 같은 문제들의 번호를 모두 더하면:
\opt{A}~$\in[59\dts62]$ \opt{B}~$\in[52\dts55]$ \opt{C}~$\in[44\dts49]$
\opt{D}~$\in[59\dts67]$ \opt{E}~$\in[44\dts53]$''

``답이 맞았으면서''라는 단서에 눈길이 간다. 틀리기로 되어 있는 문제는 번호를
더하지 않는다. 그리고 9번 자신도 답이 맞아야만 셈에 들어간다.
@<미룬 스위치의 갈래들@>=
case pack(0, 9, A), pack(0, 9, B), pack(0, 9, C), pack(0, 9, D), pack(0, 9, E),
	pack(1, 9, A), pack(1, 9, B), pack(1, 9, C), pack(1, 9, D), pack(1, 9, E):
	j = 0
	for i = 1; i <= 20; i++ {
		mems++
		if falsity[i] != 0 {
			continue
		}
		mems++
		if mem[i] == 1<<x {
			j += i
		}
	}
	if clash(u, q9lo[x] <= j && j <= q9hi[x]) {
		goto b5
	}

@ @<전역 변수@>=
var (
	q9lo = [5]int{59, 52, 44, 59, 44}
	q9hi = [5]int{62, 55, 49, 67, 53}
)

@ ``10. 17번의 답은:
\opt{A}~D \opt{B}~B \opt{C}~A \opt{D}~E \opt{E}~틀렸다''

앞의 넷은 5번과 똑같은 모양이다. \opt{E}만 다르다. 17번이 틀리기로 되어 있는지는
명령줄에서 이미 정해졌으니, 그 자리에서 참거짓이 갈린다.
@<큰 스위치의 갈래들@>=
case pack(0, 10, A), pack(0, 10, B), pack(0, 10, C), pack(0, 10, D):
	if !force(17, q10ans[x]) {
		goto bad
	}
	goto okay
case pack(0, 10, E):
	mems++
	if falsity[17] == 1 {
		goto okay
	}
	goto bad
case pack(1, 10, A), pack(1, 10, B), pack(1, 10, C), pack(1, 10, D):
	if !deny(17, q10ans[x]) {
		goto bad
	}
	goto okay
case pack(1, 10, E):
	mems++
	if falsity[17] == 1 {
		goto bad
	}
	goto okay

@ @<전역 변수@>=
var q10ans = [4]int{D, B, A, E}

@ ``11. 답이 D인 문제의 개수는:
\opt{A}~2 \opt{B}~3 \opt{C}~4 \opt{D}~5 \opt{E}~6''
@<미룬 스위치의 갈래들@>=
case pack(0, 11, A), pack(0, 11, B), pack(0, 11, C), pack(0, 11, D), pack(0, 11, E),
	pack(1, 11, A), pack(1, 11, B), pack(1, 11, C), pack(1, 11, D), pack(1, 11, E):
	mems++
	if clash(u, dist[D] == x+2) {
		goto b5
	}

@ ``12. 이 문제와 답이 같은 {\it 다른\/} 문제의 개수는, 답이 다음인 문제의
개수와 같다: \opt{A}~B \opt{B}~C \opt{C}~D \opt{D}~E \opt{E}~그 가운데 없다''

여기서 \opt{E}는 `A'와 사뭇 다르다. ``그 가운데 없다''는 \opt{A}, \opt{B},
\opt{C}, \opt{D}가 모두 거짓이라는 뜻이다.

그리고 더 미묘한 데가 있다. 우리가 정말 E 대신 A를 골랐다면 |dist| 표 자체가
달라졌을 것이기 때문이다. 12번의 답으로 E를 골랐다고 하자. 그때 12\opt{A}는
``답이 A인 다른 문제의 개수가 답이 B인 문제의 개수와 같다''는 뜻이 {\it 아니라\/},
``답이 E인 다른 문제의 개수가 답이 B인 문제의 개수와 같다''는 뜻이다.
그러니 12E는 |dist[B]|, |dist[C]|, |dist[D]|가 모두 $|dist|[E]-1$과 다를 때에만
참이다. 반면 12A는 $|dist|[A]-1=|dist|[B]$일 때에만 참이다. 알아들으셨는지?
@<미룬 스위치의 갈래들@>=
case pack(0, 12, A), pack(0, 12, B), pack(0, 12, C), pack(0, 12, D),
	pack(1, 12, A), pack(1, 12, B), pack(1, 12, C), pack(1, 12, D):
	mems += 2
	if clash(u, dist[x]-1 == dist[x+1]) {
		goto b5
	}
case pack(0, 12, E), pack(1, 12, E):
	mems++; j = dist[E] - 1
	holds := true
	for _, c := range [3]int{B, C, D} {
		mems++
		if j == dist[c] {
			holds = false
			break
		}
	}
	if clash(u, holds) {
		goto b5
	}

@ ``13. 답이 E인 문제의 개수는:
\opt{A}~5 \opt{B}~4 \opt{C}~3 \opt{D}~2 \opt{E}~1''

보기가 거꾸로 늘어서 있으니 $5-x$다.
@<미룬 스위치의 갈래들@>=
case pack(0, 13, A), pack(0, 13, B), pack(0, 13, C), pack(0, 13, D), pack(0, 13, E),
	pack(1, 13, A), pack(1, 13, B), pack(1, 13, C), pack(1, 13, D), pack(1, 13, E):
	mems++
	if clash(u, dist[E] == 5-x) {
		goto b5
	}

@ ``14. 어떤 답도 정확히 이만큼 나오지는 않는다:
\opt{A}~2 \opt{B}~3 \opt{C}~4 \opt{D}~5 \opt{E}~그 가운데 없다''

여기서는 잔재주를 쓰지 않을 수 없다. \opt{E}는 2, 3, 4, 5가 모두 |dist| 표에
나타난다는 뜻이다. 그런데 |dist|의 합은 $20$이므로, 넷이 다 나타난다면
남은 하나는 $20-2-3-4-5=6$일 수밖에 없다! 그러니 이 조건은
|trick|이 $2^2+2^3+2^4+2^5+2^6$, 곧 |0x7c|일 때에만 성립한다.
@<미룬 스위치의 갈래들@>=
case pack(0, 14, A), pack(0, 14, B), pack(0, 14, C), pack(0, 14, D),
	pack(1, 14, A), pack(1, 14, B), pack(1, 14, C), pack(1, 14, D):
	holds := true
	for i = 0; i < 5; i++ {
		mems++
		if dist[i] == x+2 {
			holds = false
			break
		}
	}
	if clash(u, holds) {
		goto b5
	}
case pack(0, 14, E), pack(1, 14, E):
	if clash(u, trick == 0x7c) {
		goto b5
	}

@ ``15. 답이 A인 홀수 번호 문제들의 집합은:
\opt{A}~$\{7\}$ \opt{B}~$\{9\}$ \opt{C}~$\{11\}$이 아니다 \opt{D}~$\{13\}$
\opt{E}~$\{15\}$''

15번 자신이 홀수 번호라는 데서 재미가 시작된다. 답이 맞으면서 \opt{A}라면
집합이 $\{7\}$인데, 답이 A인 15번이 그 집합에 들어 있어야 하니 어긋난다.
\opt{E}도 마찬가지로 어긋난다. 뒤집어 말하면 답이 틀려야 하는 \opt{A}와
\opt{E}는 언제나 그럴듯하다---15번이 집합을 이미 망쳐 놓았기 때문이다.
@<큰 스위치의 갈래들@>=
case pack(0, 15, A), pack(0, 15, E):
	goto bad
case pack(1, 15, A), pack(1, 15, E):
	goto okay

@ 답이 맞으면서 \opt{B}나 \opt{D}라면 지목한 하나만 A이고 나머지 홀수 번호는
모두 A가 아니어야 한다. 홀수 번호는 1, 3, 5, 7, 9, 11, 13, 15, 17, 19인데
15번은 답이 B나 D이니 저절로 빠진다.
@<큰 스위치의 갈래들@>=
case pack(0, 15, B), pack(0, 15, D):
	i, j = 9, 13
	if x == D {
		i, j = 13, 9
	}
	if !force(i, A) || !denyAll(A, 11, j, 1, 3, 5, 7, 17, 19) {
		goto bad
	}
	goto okay

@ 나머지는 미룬다. 다만 차례상 3번이 15번보다 먼저이므로, 3번의 답이 A라면
집합에 3이 들어 있다는 것을 이미 안다. 그러면 집합이 $\{9\}$나 $\{13\}$이나
$\{11\}$일 수 없으니 \opt{C}가 맞다는 주장도, \opt{B}나 \opt{D}가 틀렸다는
주장도 그 자리에서 그럴듯해진다.
@<큰 스위치의 갈래들@>=
case pack(0, 15, C), pack(1, 15, B), pack(1, 15, D):
	if eq(3, AA) {
		goto okay
	}
	goto postpone
case pack(1, 15, C):
	goto postpone

@ 미룬 확인 가운데 \opt{B}와 \opt{D}는 짝이다. 지목한 것 하나만 A이고 나머지
홀수가 모두 A가 아니면 주장이 참이 되어 버리므로 물러선다.
@<미룬 스위치의 갈래들@>=
case pack(1, 15, B), pack(1, 15, D):
	i = 9
	if x == D {
		i = 13
	}
	holds := true
	for _, r := range [3]int{9, 11, 13} {
		if r == i {
			holds = eq(r, AA)
		} else {
			holds = ne(r, AA)
		}
		if !holds {
			break
		}
	}
	if holds && ne(1, AA) && ne(5, AA) && ne(7, AA) && ne(17, AA) && ne(19, AA) {
		goto b5
	}

@ 그리고 \opt{C}. 여기가 원문에서 어긋난 첫 자리다.

보기 \opt{C}는 ``$\{11\}$이 아니다''이므로, 이 주장이 {\it 참\/}인 것은 집합이
$\{11\}$이 {\it 아닐\/} 때다. 그러니 답이 맞아야 한다면 집합이 $\{11\}$일 때
물러서야 하고, 답이 틀려야 한다면 집합이 $\{11\}$이 {\it 아닐\/} 때 물러서야
한다. 두 경우의 조건이 서로 정반대다.

그런데 원문은 두 경우를 한 갈래에 묶고 똑같은 검사를 붙여 두었다. 그래서 답이
틀려야 하는 15\opt{C}에 대해 판단이 뒤집힌 채로 나온다. 그 탓에 공개된
프로그램은 15번이 실제로는 맞았는데도 틀렸다고 우기는 답안지를 몇 장 찍어
낸다. 아래에서는 |clash|에 |u|를 넘겨 두 경우를 갈라 준다.
@<미룬 스위치의 갈래들@>=
case pack(0, 15, C), pack(1, 15, C):
	holds := ne(1, AA) && ne(3, AA) && ne(5, AA) && ne(7, AA) && ne(9, AA) &&
		eq(11, AA) && ne(13, AA) && ne(17, AA) && ne(19, AA)
	if clash(u, !holds) { // 주장은 ``집합이 $\{11\}$이 아니다''
		goto b5
	}

@ ``16. 8번의 답은 다음 문제의 답과 같다:
\opt{A}~3 \opt{B}~2 \opt{C}~13 \opt{D}~18 \opt{E}~20''

차례를 보면 2, 3, 20번이 16번보다 앞선다. 그 셋을 지목한 보기는 그 자리에서
8번을 못박거나 지울 수 있다. 13번과 18번은 아직 모르니 미룬다.
@<큰 스위치의 갈래들@>=
case pack(0, 16, A), pack(0, 16, B), pack(0, 16, E):
	mems += 2
	if !force(8, rho[mem[q16same[x]]]) {
		goto bad
	}
	goto okay
case pack(1, 16, A), pack(1, 16, B), pack(1, 16, E):
	mems += 2
	if !deny(8, rho[mem[q16same[x]]]) {
		goto bad
	}
	goto okay
case pack(0, 16, C), pack(0, 16, D), pack(1, 16, C), pack(1, 16, D):
	goto postpone

@ @<미룬 스위치의 갈래들@>=
case pack(0, 16, C), pack(0, 16, D), pack(1, 16, C), pack(1, 16, D):
	mems++
	if clash(u, mem[8] == mem[q16same[x]]) {
		goto b5
	}

@ @<전역 변수@>=
var q16same = [5]int{3, 2, 13, 18, 20}

@ ``17. 10번의 답은:
\opt{A}~C \opt{B}~D \opt{C}~B \opt{D}~A \opt{E}~맞았다''

10번과 17번이 서로를 가리킨다. 10\opt{E}는 ``17번이 틀렸다''이고 17\opt{E}는
``10번이 맞았다''이니, 두 답을 한꺼번에 고르면 어느 쪽이 맞고 틀리든 앞뒤가
맞지 않는다. 그래서 17\opt{E} 갈래는 맞아야 하든 틀려야 하든 10번에서 E를
지운다. 차례상 17번이 10번보다 먼저이므로 여기서 미리 손을 써 두면
10번이 나중에 말썽을 부리지 않는다.
@<큰 스위치의 갈래들@>=
case pack(0, 17, A), pack(0, 17, B), pack(0, 17, C), pack(0, 17, D):
	if !force(10, q17ans[x]) {
		goto bad
	}
	goto okay
case pack(1, 17, A), pack(1, 17, B), pack(1, 17, C), pack(1, 17, D):
	if !deny(10, q17ans[x]) {
		goto bad
	}
	goto okay
case pack(0, 17, E):
	if !deny(10, E) {
		goto bad
	}
	mems++
	if falsity[10] == 0 {
		goto okay
	}
	goto bad
case pack(1, 17, E):
	if !deny(10, E) {
		goto bad
	}
	mems++
	if falsity[10] == 0 {
		goto bad
	}
	goto okay

@ @<전역 변수@>=
var q17ans = [4]int{C, D, B, A}

@ ``18. 답이 모음인 소수 번호 문제의 개수는:
\opt{A}~소수 \opt{B}~제곱수 \opt{C}~홀수 \opt{D}~짝수 \opt{E}~0''

모음은 A와 E다. 소수 번호 문제는 여덟이고, 차례를 보면 그 여덟이 모두 18번보다
앞선다(그림 1의 흐린 활들). 그러니 미룰 것 없이 그 자리에서 세면 된다.
개수는 $0$부터 $8$까지이므로, 보기마다 ``어떤 개수들이 맞는가''를 아홉 비트짜리
집합 |magic|에 담아 두면 판단이 비트 하나를 보는 일로 줄어든다.
@<큰 스위치의 갈래들@>=
case pack(0, 18, A), pack(0, 18, B), pack(0, 18, C), pack(0, 18, D), pack(0, 18, E),
	pack(1, 18, A), pack(1, 18, B), pack(1, 18, C), pack(1, 18, D), pack(1, 18, E):
	j = 0
	for _, r := range primes {
		mems++
		if mem[r]&(AA+EE) != 0 {
			j++
		}
	}
	if clash(u, magic[x]&(1<<j) != 0) {
		goto bad
	}
	goto okay

@ 여기가 원문에서 어긋난 둘째 자리다. 원문은 이 대목을 이렇게 적었다.
$$\vbox{\halign{\.{#}\hfil\cr
if (!u \&\& j) goto okay;\ \ goto bad;\cr
if (u \&\& !j) goto okay;\ \ goto bad;\cr}}$$
첫 줄 끝에 조건 없는 |goto bad|가 있으니 둘째 줄에는 영영 닿지 못한다. 그래서
18번을 틀리라고 시키면 언제나 막힌 것으로 처리되고, 18번이 틀린 답안지는 하나도
나오지 않는다. 위의 |clash|가 그 두 줄이 원래 하려던 일을 한 줄로 한다.

@ @<전역 변수@>=
var (
	primes = [8]int{2, 3, 5, 7, 11, 13, 17, 19}
	magic  = [5]int{
		1<<2 + 1<<3 + 1<<5 + 1<<7, // 소수
		1<<0 + 1<<1 + 1<<4, // 제곱수
		1<<1 + 1<<3 + 1<<5 + 1<<7, // 홀수
		1<<0 + 1<<2 + 1<<4 + 1<<6 + 1<<8, // 짝수
		1 << 0} // 영
)

@ ``19. 답이 B인 마지막 문제는:
\opt{A}~14 \opt{B}~15 \opt{C}~16 \opt{D}~17 \opt{E}~18''

차례상 20번이 19번보다 앞선다. 답이 맞아야 한다면 지목한 자리가 B이고 그 뒤로는
20번까지 B가 없어야 한다. 19번 자신은 답이 B가 아니므로(\opt{B}만 빼고) 셈에
들지 않는다. 그리고 \opt{B}는 어긋난다---19번의 답이 B인데 마지막 B가 15번일
수는 없다.
@<큰 스위치의 갈래들@>=
case pack(0, 19, B):
	goto bad
case pack(0, 19, A), pack(0, 19, C), pack(0, 19, D), pack(0, 19, E):
	k = 14 + x
	if !force(k, B) || !denyRange(B, k+1, 18) || !deny(20, B) {
		goto bad
	}
	goto okay

@ 답이 틀려야 한다면 \opt{B}는 언제나 그럴듯하고, 나머지는 20번이 B인지부터
본다. 20번이 B라면 마지막 B는 20번이니 주장은 이미 거짓이다.
@<큰 스위치의 갈래들@>=
case pack(1, 19, B):
	goto okay
case pack(1, 19, A), pack(1, 19, C), pack(1, 19, D), pack(1, 19, E):
	if eq(20, BB) {
		goto okay
	}
	goto postpone

@ @<미룬 스위치의 갈래들@>=
case pack(1, 19, A), pack(1, 19, C), pack(1, 19, D), pack(1, 19, E):
	k = 14 + x
	holds := eq(k, BB)
	for i = k + 1; holds && i <= 18; i++ {
		holds = ne(i, BB)
	}
	if holds {
		goto b5
	}

@ ``20. 이 시험에서 받을 수 있는 최고 점수는:
\opt{A}~18 \opt{B}~19 \opt{C}~20 \opt{D}~정해지지 않는다
\opt{E}~이 문제를 틀려야만 얻을 수 있다''

Don Woods 자신이 ``말썽을 일으키려고 일부러 만든'' 문제라고 인정한 이 마지막
문제는 따로 손을 봐 주어야 한다. 크누스의 책에 나오는 논의에 따르면 \opt{D}는
언제나 거짓이다. 여기서는 \opt{E}도 거짓이라고 놓는데, 그 가정은 이 프로그램의
출력을 살펴 확인해야 한다. \opt{A}, \opt{B}, \opt{C}에 대해서는 문제를 살짝
고쳐 읽는다---``최고 점수''가 아니라 ``이번 판이 내놓는 모든 답안지의 점수''로.
그러면 |score|와 견주는 일이 된다.
@<큰 스위치의 갈래들@>=
case pack(0, 20, A), pack(0, 20, B), pack(0, 20, C):
	if score == 18+x {
		goto okay
	}
	goto bad
case pack(0, 20, D), pack(0, 20, E):
	goto bad
case pack(1, 20, A), pack(1, 20, B), pack(1, 20, C):
	if score != 18+x {
		goto okay
	}
	goto bad
case pack(1, 20, D), pack(1, 20, E):
	goto okay

@* 돌려 보기.
먼저 스무 문제를 모두 맞히는 답안지를 찾아보자.
$$\.{\$ back-20q 0 0}$$
답이 하나도 없다. 그렇다면 열아홉 개까지는 어떨까? 틀릴 문제를 하나씩 지정해
스무 번 돌려 보면, 답이 나오는 것은 두 경우뿐이다. 19번을 틀렸을 때 한 장,
20번을 틀렸을 때 두 장. 그러니 이 시험의 최고 점수는 {\it 19점\/}이다.

그 세 장 가운데 20번까지 맞힌 것은 딱 한 장이다.
$$\mplibcode sheet := "DCEABEBCEABEAEDBDABB"; wrongq := 19; fig_answer;
  \endmplibcode$$
\figcap{{\it 그림\/} 3: \.{back-20q 19 0}이 찾아낸 단 하나의 답안지.
\.{DCEABEBCEABEAEDBDABB}. 20번의 답 B는 ``최고 점수는 19''라는 뜻이고,
실제로 이 답안지의 점수가 19다---앞뒤가 맞는다.}

나머지 두 장은 20번을 틀린 것이니, 스스로 ``이 답안지는 19점이 아니다''라고
말하면서 19점을 받은 셈이다. 그것도 규칙에는 어긋나지 않는다.

@ 열여덟 개만 맞히는 경우까지 다 훑으면(틀릴 문제를 고르는 방법이 190가지)
답안지가 부쩍 늘어난다. 명령줄이 고를 수 있는 211가지 무늬를 모두 돌리면
답안지가 모두 701장 나온다. 그 가운데 19점짜리가 3장, 나머지 698장은 18점짜리다.

@ 앞에서 짚은 두 자리를 여기서 셈으로 마무리하자. 공개된 \.{CWEB} 판을 그대로
컴파일해 같은 211가지를 돌리면 692장이 나온다. 고친 판과 견주면 이렇다.
\smallskip
\itemitem{$\bullet$} 공개된 판에만 있는 답안지가 5장. 모두 15번의 답이 소문자
\.c인 것들인데, 15번의 주장을 직접 따져 보면 {\it 참\/}이다. 틀렸다고 우기고
있으니 답안지로서 자격이 없다.
\itemitem{$\bullet$} 공개된 판이 놓친 답안지가 14장. 모두 18번의 답이 소문자인
것들이다. 앞서 본 닿지 못하는 줄 때문에 18번이 틀린 길은 아예 막혀 있었다.
\smallskip\noindent
다행히 두 오류 모두 이 퍼즐의 결론은 건드리지 않는다. 20점짜리는 여전히 없고,
19점짜리는 여전히 그 세 장뿐이다. 어긋남은 모두 18점짜리 쪽에서 일어난다.

@ 옮긴 것이 맞는지는 세 갈래로 확인했다.

첫째, 위의 두 자리를 고친 \.{CWEB} 원본과 211가지 무늬를 모두 견주었다.
답안지도, 검색나무의 노드 수도 한 자리 다르지 않았다. mem 수는 두 경우에서
$1$과 $3$만큼 달랐는데, 19번의 미룬 확인에서 원문이 논리곱 대신 비트곱을 써
짧은 회로가 끊기지 않는 자리 때문이다.

둘째, 이 프로그램과 아무것도 나눠 쓰지 않는 채점기를 따로 만들어, 나온 701장을
한 장씩 스무 문제의 우리말 뜻에서 곧바로 다시 채점했다. 대문자로 적힌 답은
주장이 참, 소문자로 적힌 답은 거짓이어야 한다. 701장 모두 맞았다.

셋째, 빠뜨린 답안지가 없는지 보려고 {\it 푸는 차례를 바꿔\/} 돌려 보았다.
3번을 맨 앞에 두고 그림 1의 앞뒤 관계만 지키면 차례는 얼마든지 다르게 잡을 수
있다. 그렇게 만든
차례 열두 개로 열 가지 무늬를 다시 돌렸더니, 나온 답안지의 집합이 언제나
똑같았다.

@ 원문에는 이 프로그램의 변종을 만드는 \.{CWEB} 변경 파일이 둘 딸려 있다.
우리도 그에 맞추어 \.{GWEB} 변경 파일 둘을 나란히 두었다.
\smallskip
\itemitem{$\bullet$} \.{back-20q-backmod9,15.ch}는 문제 둘을 손본다. 9번의
\opt{E}를 $[44\dts53]$에서 $[39\dts43]$으로 바꾸고, 15번의 \opt{C}를
``$\{11\}$이 아니다''에서 그냥 $\{11\}$로 바꾼다.
\itemitem{$\bullet$} \.{back-20q-backmod9,15-indet.ch}는 거기에 하나를 더
얹는다. 20번의 \opt{D}(``정해지지 않는다'')를 거짓이 아니라 {\it 참\/}이라고
놓는다.
\smallskip\noindent
쓰는 법은 \.{CWEB}과 같다. 이를테면
$$\.{gtangle back-20q.w back-20q-backmod9,15.ch}$$
15번의 다섯 보기가 나란해지면 그 대목의 코드가 눈에 띄게 단정해진다. 공개된
원문의 15\opt{C} 오류가 어디서 비롯되었는지도 거기서 짐작할 수 있다.

@* 색인.
