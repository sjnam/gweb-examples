\input kotexgweb
@i types.w
\datethis

\def\title{미닫이 블록 퍼즐}

@* 들어가며.
이 프로그램은 꽤 일반적인 미닫이 블록 퍼즐을 푼다. 사실 속도보다 일반성을 앞세웠지만,
큰 그래프에서 너비 우선 탐색을 제법 효율적으로 하려고 애쓰기는 한다. (크누스는
나중에 더 발전된 기법으로 프로그램을 따로 쓰고, 이것은 그 결과를 다시 확인하는 데
쓸 생각이었다.) 멋진 사용자 인터페이스를 마련하지 못한 것을 크누스는 사과했다. 여기
있는 것은 미닫이 블록 퍼즐의 최단 풀이를 찾는 엔진뿐이다.

@ 이것은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{sliding.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/sliding.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Fri, 25 Sep 2020 06:31:23 GMT}다.

옮기다가 결함 셋을 만났다. 가장 큰 것은 방식 5의 탐색이 같은 모양의 조각이 있을 때
어떤 배치를 한 수 늦게 찾는 것이다. 모두 고쳤고, 이야기는 맨 뒤에 적었다.

@ 퍼즐에는 조각이 15종류까지 있을 수 있고, 이름은 16진수로 \.1부터~\.f까지다.
조각은 표준 입력에서 한 줄에 하나씩, 0과~1로 된 직사각형 무늬로 정의한다. 0은
`빈칸', 1은 `차지한 칸'이다. 무늬의 행은 아래 예처럼 빗금으로 가른다.

표준 입력의 첫 줄은 특별하다. 판의 크기를 `\\{rows} \.x \\{columns}' 꼴로 적고,
그 뒤에 아무 설명이나 (보통 퍼즐 이름을) 붙인다. 이어서
`\\{piecename} \.= \\{pattern}' 꼴의 조각 정의가 온다.

조각 정의 뒤에는 두 줄이 더 온다. 하나는 처음 배치, 하나는 마지막 배치다. 배치는
판을 채우는 방법을 줄여 적는다. 아직 정하지 않은 칸 가운데 가장 위, 가장 왼쪽의
칸을 차지하는 조각 이름을 차례로 적는데, 그 칸이 비었으면 \.0을, 영영 막힌
칸이면 \.x를 적는다. 끝의 0들은 빼도 된다.

이를테면 네 조각 세 종류로 된 이상한 (그러나 풀기 쉬운) $5\times5$ 퍼즐은 이렇게
적는다.
$$\vbox{\halign{\tt#\hfill\cr
5 x 5 (a silly example)\cr
1 = 111/01\cr
2 = 101/111\cr
3 = 1\cr
1xx200000000033\cr
000xx00033001002\cr
}}$$
같은 퍼즐을 흔히 쓰는 방식으로 그리면 이렇다.
$$\setbox0=\hbox to 0pt{\hss\vrule height8.5pt depth3.5pt\hss}
\setbox1=\hbox{\smash{\lower3.7pt\vbox{\hrule width 12pt}}}
\catcode`\!=\active \def!{\copy0}
\def\\#1{\hbox to 12pt{\hss#1\hss}}
\def\_#1{\hbox to 12pt{\copy1\kern-12pt\hss#1\hss}}
\vbox{\offinterlineskip\halign{\strut\tt#\hfil\cr
\hidewidth\hfil\rm 처음 배치\hidewidth\cr
\noalign{\vskip-6pt}
\_{}\_{}\_{}\cr
!\_1\\1\_1!\_{}\_{}\cr
!\\2!\_1!\\2!\_0!\_0!\cr
!\_2\_2\_2!\_0!\_0!\cr
!\_0!\_0!\_0!\_0!\_0!\cr
!\_3!\_3!\_0!\_0!\_0!\cr}}
\hskip10em
\vbox{\offinterlineskip\halign{\strut\tt#\hfil\cr
\hidewidth\hfil\rm 마지막 배치\hidewidth\cr
\noalign{\vskip-6pt}
\_{}\_{}\_{}\cr
!\_0!\_0!\_0!\_{}\_{}\cr
!\_0!\_0!\_0!\_3!\_3!\cr
!\_0!\_0!\_1\\1\_1!\cr
!\_0!\_0!\\2!\_1!\\2!\cr
!\_0!\_0!\_2\_2\_2!\cr}}
$$
두 `\.3' 조각은 서로 구별되지 않는다. 구별하고 싶었다면 이를테면 `\.{4 = 1}'이라
하여 조각 이름을 하나 더 들였을 것이다.

@ 이 프로그램은 미닫이 이동을 여섯 방식으로 지원하고, 사용자는 원하는 방식을
명령줄에서 정한다.
\smallskip
\def\sty#1. {\par\noindent\hangindent 30pt\hbox{\bf 방식 #1.\enspace}}
\sty0. 조각 하나를 왼쪽, 오른쪽, 위, 아래로 한 칸 옮긴다. 새로 차지하는 칸은 미리
비어 있어야 한다.
\sty1. 조각 하나를 왼쪽, 오른쪽, 위, 아래로 한 칸 이상 옮긴다. (같은 조각을 같은
방향으로 옮기는 방식 0의 이동 여럿을 한 수로 친다.)
\sty2. 조각 하나를 한 칸 이상 옮긴다. (같은 조각을 옮기는 방식 0의 이동 여럿이되,
방향은 같지 않아도 된다.)
\sty3. 조각 몇 개를 한꺼번에 왼쪽, 오른쪽, 위, 아래로 한 칸 옮긴다. (방식 0과
같되, 여러 조각이 하나의 ``초조각''처럼 움직일 수 있다.)
\sty4. 조각 몇 개를 한꺼번에 왼쪽, 오른쪽, 위, 아래로 한 칸 이상 옮긴다. (방식 1의
초조각 판이다.)
\sty5. 조각 몇 개를 한꺼번에 한 칸 이상 옮긴다. (방식 2의 초조각 판이다.)
\smallskip\noindent
방식 3, 4, 5에서 함께 옮기는 조각들은 서로 붙어 있지 않아도 된다. 눈 밝은 독자는
알아챘겠지만, 입력 규칙상 조각 하나가 떨어진 여러 부분으로 되어 있어도 된다.

위의 이상한 퍼즐은 이를테면 방식 (0, 1, 2, 3, 4, 5)로 저마다 (20, 10, 4, 10, 4, 2)수
만에 풀린다. 그 퍼즐을 조금만 바꾸면 초조각 이동 없이는 닿을 수 없는 배치가
생긴다. 그러니 초조각 이동은 그저 사치가 아니라, 어떤 퍼즐을 푸는 데는 꼭 있어야 할
수도 있다.

@ 이제 프로그램의 얼개다. 아직 놀랄 것은 없다.

원본은 답을 찾자마자 깊은 재귀 한가운데서 |longjmp|로 이름표 |hurray|까지 뛰었다.
\GO/에는 그런 것이 없다. 그래서 답을 찾으면 전역 플래그 |found|를 세우고, 재귀하는
함수들이 그것을 보는 대로 곧장 돌아오게 한다. 탐색 반복문도 |found|를 보고 |hurray|로
간다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"

	"github.com/sjnam/go-sgb/gbflip"
)

@<상수@>
@<전역 변수@>
@<함수들@>

func main() {
	var j, k, t, d int
	@<명령줄을 처리한다@>
	@<퍼즐 명세를 읽되, 옳지 않으면 멈춘다@>
	@<초기화한다@>
	@<퍼즐을 푼다@>
hurray:
	@<답을 찍는다@>
}

@ @<전역 변수@>=
var (
	style   int  // 이동 방식
	verbose int  // 양수면 자세히 찍고, 음수면 풀이를 빼고 찍는다
	found   bool // 마지막 배치를 찾았나?
	stdout  = bufio.NewWriter(os.Stdout)
)

@ 표준 출력을 모았다가 내보내므로, 멈출 때는 언제나 이 함수로 멈춘다.

@<함수들@>=
func exit(code int) {
	stdout.Flush()
	os.Exit(code)
}

@ 방식 매개변수 뒤에 매개변수가 하나 더 있으면, 양수일 때는 자세히 찍고 음수일
때는 풀이의 세부를 빼고 찍는다.

@<명령줄을 처리한다@>=
var err error
okay := len(os.Args) >= 2
if okay {
	style, err = strconv.Atoi(os.Args[1])
	okay = err == nil
}
if okay && len(os.Args) >= 3 {
	verbose, err = strconv.Atoi(os.Args[2])
	okay = err == nil
}
if !okay {
	fmt.Fprintf(os.Stderr, "사용법: %s style [verbose]\n", os.Args[0])
	exit(-1)
}
if style < 0 || style > 5 {
	fmt.Fprintf(os.Stderr, "미안하지만 방식은 0과 5 사이여야 한다. %d는 안 된다!\n",
		style)
	exit(-2)
}

@* 판 나타내기.
크기가 $r\times c$인 판은 $rc+2c+r+1$칸짜리 배열로 나타낸다. 왼쪽 위 구석은 배열의 $c+1$번
칸에 해당하고, 위, 아래, 왼쪽, 오른쪽으로 옮기는 것은 지금 자리에 $-(c+1)$, $(c+1)$,
$-1$, $1$을 더하는 것에 해당한다. 경계 표시는 처음 $c+1$칸과 마지막 $c+1$칸, 그리고
$1\le k<r$인 $c+k(c+1)$번 칸에 둔다. 그것들이 조각이 판 가장자리 밖으로 미끄러져
나가지 못하게 막는다.

아래 코드는 $rc\le m$이면 $rc+2c+r+1$이 많아야 $3m+2$라는 사실을 쓴다. 최댓값은
$r=1$, $c=m$일 때 나온다.

@<상수@>=
const (
	bdry      = 999999 // 경계 표시
	obst      = 999998 // 영영 막힌 칸
	maxsize   = 256    // $r\times c$의 최댓값. 8의 배수여야 한다
	boardsize = maxsize*3 + 2
)

@ @<전역 변수@>=
var (
	board  [boardsize]int // 배치를 따지는 주 판
	aboard [boardsize]int // 보조 판
	rows   int            // 판의 행 수
	cols   int            // 판의 열 수
	colsp  int            // |cols+1|
	ul, lr int            // 판에서 왼쪽 위와 오른쪽 아래 구석의 자리
	delta  = [4]int{1, -1} // 오른쪽, 왼쪽, 아래, 위로 옮길 때 |board|의 변위
)

@ 조각의 종류마다, 그 조각의 맨 위 맨 왼쪽 칸에서 잰 판 변위의 목록을 0으로 끝맺어
둔다. 이를테면 이상한 예에서 \.1이라는 조각의 변위는 열이 다섯이므로
$(1, 2, 7, 0)$이다. 열이 여섯이었다면 같은 조각의 변위는 $(1,2,8,0)$이었을 것이다.

다음 코드는 새 조각을 정의할 때 돈다. 무늬의 첫 1이 기준 칸이 되고, 뒤따르는
1마다 기준 칸에서 잰 변위를 적는다. 문자 \.1은 칸을 적은 뒤 \.0처럼 한 칸
나아간다. 원본은 |switch|의 떨어지기(fall-through)로 그렇게 했다.

@<조각의 변위를 셈한다@>=
t, j, k = -1, 0, 0
scan:
for p := 4; ; p++ {
	switch buf[p] {
	case '1':
		if t < 0 {
			t = k
		} else {
			off[curo] = k - t; curo++
		}
		if curo >= maxsize {
			boardover()
		}
		j++; k++
	case '0':
		j++; k++
	case '/':
		k += colsp - j; j = 0
	case '\n':
		break scan
	default:
		fmt.Fprintf(os.Stderr, "조각 %c의 정의에 잘못된 글자 `%c'가 있다!\n",
			buf[0], buf[p])
		exit(-4)
	}
}
if t < 0 {
	fmt.Fprintf(os.Stderr, "조각 %c가 비었다!\n", buf[0]); exit(-5)
}
off[curo] = 0; curo++
if curo >= maxsize {
	boardover()
}

@ 판이 너무 크면 세 곳에서 멈추므로 함수로 둔다.

@<함수들@>=
func boardover() {
	fmt.Fprintf(os.Stderr, "미안하지만 그렇게 큰 판은 다룰 수 없다.\n")
	fmt.Fprintf(os.Stderr, " maxsize를 늘려 다시 컴파일해 달라.\n")
	exit(-3)
}

@ @<전역 변수@>=
var (
	off      [maxsize]int // 조각들의 변위 목록
	offstart [16]int      // |off| 표에서 각 목록이 시작하는 곳
	curo     int          // 지금까지 적은 변위의 수
	buf      string       // 입력 버퍼
)

@ 판의 배치는 차지한 칸마다 블록 번호를 넣어 나타낸다. 같은 종류의 블록이 여럿일 수
있으므로 판 위의 블록 수는 조각 종류의 수보다 많을 수 있다. 블록에는 번호를 아무렇게나
붙인다.

이를테면 이상한 예의 처음 배치에서 배열 |board|는 이렇게 생겼을 수 있다.
$$\vbox{\halign{\hfil#\hfil&&\quad\hfil#\hfil\cr
|bdry|&|bdry|&|bdry|&|bdry|&|bdry|&|bdry|\cr
4&4&4&|obst|&|obst|&|bdry|\cr
3&4&3&0&0&|bdry|\cr
3&3&3&0&0&|bdry|\cr
0&0&0&0&0&|bdry|\cr
2&1&0&0&0&|bdry|\cr
|bdry|&|bdry|&|bdry|&|bdry|&|bdry|\cr}}$$
수 $\{1,2,3,4\}$를 어떻게 바꾸어 붙여도 똑같이 옳다.

@ 다음 함수는 입력 버퍼의 명세로 판을 채운다. 칸을 너무 많이 적었으면 |-1|을,
잘못된 글자가 있으면 |-2|를 돌려준다. 그렇지 않으면 충돌의 수, 곧 두 번 이상 잘못
채운 칸의 수를 돌려준다.

원본은 정의하지 않은 조각 이름이 배치에 나와도 막지 않았다. 그러면 |offstart[t]|가
|-1|이라 |off[-1]|을 읽는다. 이 판은 그때 |-3|을 돌려준다.

@<함수들@>=
func fillBoard(board *[boardsize]int, piece, place *[maxsize + 1]int) int {
	var j, c, k, t int
	@<판의 경계를 두르고 안쪽을 |-1|로 채운다@>
	bcount, j = 0, ul
	for p := 0; buf[p] != '\n'; p++ {
		for board[j] >= 0 {
			if j++; j > lr {
				return -1
			}
		}
		@<글자 |buf[p]|를 읽어 조각 종류 |t|를 정하되, 잘못되었으면 돌아간다@>
		if t != 0 {
			bcount++; piece[bcount] = t; place[bcount] = j; board[j] = bcount
			for k = offstart[t]; off[k] != 0; k++ {
				if j+off[k] < ul || j+off[k] > lr || board[j+off[k]] >= 0 {
					c++
				} else {
					board[j+off[k]] = bcount
				}
			}
		}
		j++
	}
	for ; j <= lr; j++ {
		if board[j] < 0 {
			board[j] = 0
		}
	}
	return c
}

@ @<판의 경계를 두르고 안쪽을 |-1|로 채운다@>=
for j = 0; j < ul; j++ {
	board[j] = bdry
}
for j = ul; j <= lr; j++ {
	board[j] = -1
}
for j = ul + cols; j <= lr; j += colsp {
	board[j] = bdry
}
for ; j <= lr+colsp; j++ {
	board[j] = bdry
}

@ @<글자 |buf[p]|를 읽어 조각 종류 |t|를 정하되, 잘못되었으면 돌아간다@>=
switch ch := buf[p]; {
case ch == '0':
	t = 0; board[j] = 0
case ch >= '1' && ch <= '9':
	t = int(ch - '0')
case ch >= 'a' && ch <= 'f':
	t = int(ch-'a') + 10
case ch == 'x':
	t = 0; board[j] = obst
default:
	return -2
}
if t != 0 && offstart[t] < 0 {
	return -3
}

@ @<전역 변수@>=
var (
	bcount        int              // 판 위의 블록 수
	piece, apiece [maxsize + 1]int // 블록마다 조각 이름
	place, aplace [maxsize + 1]int // 블록마다 맨 위 맨 왼쪽 자리
)

@ 다음 함수는 주어진 판을 표준 출력에 조금 읽기 좋게 찍는다. 같은 블록의 이웃한
칸들을 이어 보여 준다. 이상한 입력의 처음 배치는 이를테면 이렇게 찍힌다.
$$\catcode`\!=\active \chardef!="7C % vertical bar
\obeyspaces
\vbox{\baselineskip=9pt\halign{\tt#\hfill\cr
1-1-1\cr
{}  !\cr
2 1 2 0 0\cr
!   !\cr
2-2-2 0 0\cr
\cr
0 0 0 0 0\cr
\cr
3 3 0 0 0\cr}}$$

@<함수들@>=
func printBoard(board *[boardsize]int, piece *[maxsize + 1]int) {
	cell := func(j, k int) int { return board[ul+j*colsp+k] }
	for j := 0; j < rows; j++ {
		for k := 0; k < cols; k++ {
			if c := cell(j, k); c == cell(j-1, k) && c != 0 && c < obst {
				fmt.Fprintf(stdout, " |")
			} else {
				fmt.Fprintf(stdout, "  ")
			}
		}
		fmt.Fprintf(stdout, "\n")
		for k := 0; k < cols; k++ {
			@<칸 $(j,k)$를 찍는다@>
		}
		fmt.Fprintf(stdout, "\n")
	}
}

@ @<칸 $(j,k)$를 찍는다@>=
c := cell(j, k)
switch {
case c < 0:
	fmt.Fprintf(stdout, " ?")
case c < obst:
	sep := ' '
	if c == cell(j, k-1) && c != 0 {
		sep = '-'
	}
	fmt.Fprintf(stdout, "%c%x", sep, piece[c])
default:
	fmt.Fprintf(stdout, "  ")
}

@ 이런 함수들을 갖추었으니 입력 파일 전체를 읽을 수 있다. 줄을 읽는 일은 여러
곳에서 하므로 함수로 둔다. 원본의 |fgets|처럼 줄 끝의 줄바꿈을 남겨 둔다. 마지막
줄에 줄바꿈이 없으면 하나 붙인다. 파일이 끝났으면 |buf|를 건드리지 않고 거짓을
돌려준다.

@<함수들@>=
func readLine() bool {
	s, err := stdin.ReadString('\n')
	if s == "" && err != nil {
		return false
	}
	if s[len(s)-1] != '\n' {
		s += "\n"
	}
	buf = s
	return true
}

@ @<전역 변수@>=
var stdin = bufio.NewReader(os.Stdin)

@ @<퍼즐 명세를 읽되, 옳지 않으면 멈춘다@>=
@<판의 크기를 읽는다@>
@<조각 명세를 읽는다@>
@<처음 배치를 |board|에 읽는다@>
@<마지막 배치를 |aboard|에 읽는다@>

@ @<판의 크기를 읽는다@>=
readLine()
if n, _ := fmt.Sscanf(buf, "%d x %d", &rows, &cols); n != 2 || rows <= 0 ||
	cols <= 0 {
	fmt.Fprintf(os.Stderr, "rows x cols를 잘못 적었다!\n")
	exit(-6)
}
if rows*cols > maxsize {
	boardover()
}
colsp = cols + 1
delta[2], delta[3] = colsp, -colsp
ul = colsp
lr = (rows+1)*colsp - 2

@ 조각 정의가 아닌 첫 줄이 처음 배치다. 그 줄은 |buf|에 남는다.

@<조각 명세를 읽는다@>=
for j = 1; j < 16; j++ {
	offstart[j] = -1
}
for {
	if !readLine() {
		buf = "\n"; break
	}
	if buf[0] == '\n' {
		continue
	}
	if len(buf) < 4 || buf[1] != ' ' || buf[2] != '=' || buf[3] != ' ' {
		break
	}
	@<조각 이름 |buf[0]|을 |t|로 읽는다@>
	if offstart[t] >= 0 {
		fmt.Fprintf(stdout, "경고: 조각 %c를 다시 정의한 것은 무시한다.\n", buf[0])
	} else {
		offstart[t] = curo
		@<조각의 변위를 셈한다@>
	}
}

@ @<조각 이름 |buf[0]|을 |t|로 읽는다@>=
switch ch := buf[0]; {
case ch >= '1' && ch <= '9':
	t = int(ch - '0')
case ch >= 'a' && ch <= 'f':
	t = int(ch-'a') + 10
default:
	fmt.Fprintf(stdout, "조각 이름이 잘못되었다(%c)!\n", buf[0])
	exit(-7)
}

@ 처음 배치와 마지막 배치를 읽은 뒤의 잘못 알리기는 같으므로 함수로 둔다.

@<함수들@>=
func complain(t, code int) {
	switch {
	case t == 1:
		fmt.Fprintf(os.Stderr, "이런, 칸 하나를 두 번 채웠다!\n")
	case t > 0:
		fmt.Fprintf(os.Stderr, "이런, 칸 %d개를 넘치게 채웠다!\n", t)
	case t == -1:
		fmt.Fprintf(os.Stderr, "이런, 판이 모자란다!\n")
	case t == -2:
		fmt.Fprintf(os.Stderr, "이런, 배치에 잘못된 글자가 있다!\n")
	default:
		fmt.Fprintf(os.Stderr, "이런, 배치에 정의하지 않은 조각이 있다!\n")
	}
	exit(code)
}

@ @<처음 배치를 |board|에 읽는다@>=
t = fillBoard(&board, &piece, &place)
fmt.Fprintf(stdout, "처음 배치:\n")
printBoard(&board, &piece)
if t != 0 {
	complain(t, -8)
}
if bcount == 0 {
	fmt.Fprintf(os.Stderr, "퍼즐에 조각이 하나도 없다!\n")
	exit(-9)
}

@ 원본처럼, 파일이 끝나 마지막 배치를 읽지 못하면 |buf|에 남은 처음 배치를 그대로
쓴다.

@<마지막 배치를 |aboard|에 읽는다@>=
readLine()
t = fillBoard(&aboard, &apiece, &aplace)
fmt.Fprintf(stdout, "\n마지막 배치:\n")
printBoard(&aboard, &apiece)
if t != 0 {
	complain(t, -10)
}
@<두 배치의 막힌 칸과 조각 수가 같은지 본다@>

@ @<두 배치의 막힌 칸과 조각 수가 같은지 본다@>=
for j = ul; j <= lr; j++ {
	if (board[j] < obst) != (aboard[j] < obst) {
		fmt.Fprintf(os.Stderr, "막힌 칸(x)들의 자리가 다르다!\n")
		exit(-11)
	}
	if board[j] < obst {
		balance[piece[board[j]]]++; balance[apiece[aboard[j]]]--
	}
}
for j = 0; j < 16; j++ {
	if balance[j] != 0 {
		fmt.Fprintf(os.Stderr, "마지막 배치의 조각 수가 틀렸다!\n")
		exit(-12)
	}
}

@ @<전역 변수@>=
var balance [16]int // 조각을 잃지 않았는지 보는 계수기

@* 너비 우선 탐색.
이제 계산의 심장에 왔다. 개념은 아주 단순하다. 거리 $d$ 미만에서 닿는 배치를 모두
찾았다면, 거리 $d$에서 닿는 배치는 거리 $d-1$의 배치마다 한 수를 더 두어 얻는다. 곧
대략 이렇게 하고 싶다.
$$\vbox{\halign{#\hfil\cr
$c_1={}$처음 배치;\cr
$m_0=1$; \ $k=2$;\cr
{\bf for} $(d=1;$\ ;\ |d++|)\ $\{$\cr
\quad$m_d=k$;\cr
\quad{\bf for} $(j=m_{d-1};\ j<m_d;\ $|j++|)\cr
\qquad{\bf for} ($c_j$에서 한 수로 닿는 모든 배치 $p$)\cr
\quad\qquad{\bf if} ($p$가 새것) $c_k=p$, \ |k++|;\cr
\quad{\bf if} ($m_d\equiv k$) {\bf break};\cr
$\}$\cr}}$$

주된 문제는 배치 $p$가 새것인지 효율적으로 알아내는 것이다. 이를 위해, 거리 $d-1$의
배치에서 두는 수는 언제나 거리 $d-2$, $d-1$, $d$의 배치로 간다는 사실을 쓸 수 있다.
그러니 새것인지 볼 때 $j<m_{d-2}$인 배치 $c_j$는 모두 {\it 잊어도\/} 된다. 이
원리가 필요한 메모리를 크게 줄인다.

새것인지 보고 낡은 자료를 빨리 버리는 편한 방법 하나는 해시 사슬이다. 사슬 끝의 항목은
번호 $j$가 주어진 경계보다 작아지면 무시한다. 곧 배치마다 해시 주소를 셈하고, 배치를
해시 부호가 같은 바로 앞 배치를 가리키는 포인터와 함께 저장한다. 포인터가
$m_{d-2}$보다 작아지면 사슬을 더 볼 필요가 없다.

@ 배치는 안에서 연이은 조각 이름들의 니블(4비트) 열로 나타낸다. 입력에서 처음과
마지막 배치를 줄여 적는 방식과 같되 \.x는 뺀다. 이를테면 이상한 예의 처음 배치는
16진수 \.{1200000000033}이고, 실제로는 32비트 둘 |0x12000000|과 |0x00033000|으로
저장한다.

다음 함수는 주어진 판을 부호로 묶는다. 32비트 부호들을 |config| 배열에 넣고, 넣은
부호의 수를 돌려준다.

@<함수들@>=
func pack(board *[boardsize]int, piece *[maxsize + 1]int) int {
	var i, j, k, p, t int
	var s uint32
	for j = ul; j <= lr; j++ {
		xboard[j] = false
	}
	for p, j, t = 28, ul, bcount; t != 0; j++ {
		if board[j] < obst && !xboard[j] {
			if k = piece[board[j]]; k != 0 {
				t--; s += uint32(k) << p
				for k = offstart[k]; off[k] != 0; k++ {
					xboard[j+off[k]] = true
				}
			}
			if p == 0 {
				config[i] = s; i++; s, p = 0, 28
			} else {
				p -= 4
			}
		}
	}
	if p != 28 {
		config[i] = s; i++
	}
	return i
}

@ @<전역 변수@>=
var (
	xboard [boardsize]bool     // 미리 채운 자리
	config [maxsize / 8]uint32 // 묶은 배치
)

@ 거꾸로, 묶은 표현에서 판을 되살릴 수도 있다.

@<함수들@>=
func unpack(board *[boardsize]int, piece, place *[maxsize + 1]int,
	config []uint32) int {
	var i, j, k, p, t int
	var s uint32
	for j = ul; j <= lr; j++ {
		xboard[j] = false
	}
	for p, i, j, t = 0, 0, ul, bcount; t != 0; j++ {
		if board[j] < obst && !xboard[j] {
			if p == 0 {
				s = config[i]; i++; p = 28
			} else {
				p -= 4
			}
			@<니블 |(s>>p)&0xf|의 조각을 자리 |j|에 놓는다@>
		}
	}
	for ; j <= lr; j++ {
		if board[j] < obst && !xboard[j] {
			board[j] = 0
		}
	}
	return i
}

@ @<니블 |(s>>p)&0xf|의 조각을 자리 |j|에 놓는다@>=
if k = int(s>>p) & 0xf; k != 0 {
	board[j], piece[t], place[t] = t, k, j
	for k = offstart[k]; off[k] != 0; k++ {
		xboard[j+off[k]] = true; board[j+off[k]] = t
	}
	t--
} else {
	board[j] = 0
}

@ 해시 부호는 ``보편 해싱''으로 셈한다. 바이트마다 정해진 무작위 비트를 {\mc XOR}한다.
그 무작위 비트는 |uni|라는 표에 있다. 원본은 \.{SGB}의 |gb_flip|을 썼다. go-sgb의
|gbflip|은 같은 수열을 내 주므로 해시 부호도 원본과 같다.

@<초기화한다@>=
rng := gbflip.New(0)
for j = 0; j < 4; j++ {
	for k = 1; k < 256; k++ {
		uni[j][k] = int16(rng.Next())
	}
}

@ 해시 사슬의 수 |hashsize|는 2의 거듭제곱이어야 하고, 조금 신경 써서 골라야 한다.
너무 크면 기계의 캐시 메모리를 방해하고, 너무 작으면 해시 사슬을 훑는 데 시간을 너무
쓴다. 크누스는 |hashsize|가 많아야 $2^{16}$이라고 가정해, |uni| 표의 항목을 |short|
(16비트)로 두었다.

@<상수@>=
const hashsize = 1 << 13 // 2의 거듭제곱이고 |1<<16| 이하여야 한다

@ 바이트 넷의 무작위 비트를 더해 해시 부호를 얻는다. 원본의 매크로 |hashcode|는
여러 곳에서 쓰이므로 함수로 둔다.

@<함수들@>=
func hashcode(x uint32) int {
	return int(uni[0][x&0xff]) + int(uni[1][(x>>8)&0xff]) +
		int(uni[2][(x>>16)&0xff]) + int(uni[3][x>>24])
}

@ 배치의 총수는 어마어마할 수 있으므로, 주 해시 표의 포인터에 64비트를 준다.
크누스는 이렇게 적었다. ``(훗날의 프로그래머들은 이 코드를 읽으며 킥킥 웃을 것이다.
나 같은 사람들이 32비트 수를 두고 법석을 떨어야 했던 옛날을 행복하게 잊었을 테니.)''
원본은 64비트 포인터를 32비트 둘(아래쪽과 위쪽)로 나누어 들고 다녔다. 나는 웃으며
|uint64| 하나로 합쳤다. 셈은 똑같다.

@<전역 변수@>=
var (
	uni  [4][256]int16      // 보편 해싱의 비트
	hash [hashsize]uint64   // 해시 표 포인터
)

@ 물론 쉬운 문제가 아니면 모든 배치를 한꺼번에 메모리에 두지 않는다. 대신
|memsize|개 낱말짜리 표 하나에, 배치 하나하나를 나타내는 크기가 제각각인 꾸러미들을
넣는다. 이 표의 주소는 개념상 64비트 수지만, 낡은 자료는 버리므로 실제로는
|memsize|로 나눈 나머지를 쓴다. 그 나머지를 빨리 셈하려고 |memsize|를 2의 거듭제곱으로
둔다.

꾸러미의 첫 낱말은 해시 부호가 같은 바로 앞 꾸러미를 가리키는 포인터다. 이 포인터는
지금 꾸러미에서 잰 {\it 상대\/} 포인터라서 많아야 32비트면 된다.

꾸러미의 둘째 낱말은 이 배치를 낳은 배치를 가리키는 (상대) 포인터다. 공간을 아끼려면
뺄 수도 있지만, 최적의 수만이 아니라 실제 풀이를 보고 싶을 때 요긴하다.

나머지 낱말은 배치를 묶은 부호다. 꾸러미가 |pos| 배열 끝 가까이에서 시작하면 실제로는
|pos[memsize]|를 넘어 뻗는다. 거기에 넉넉한 여분을 두었으므로 꾸러미를 |memsize|
경계에서 감아 돌릴 필요가 없다.

@<상수@>=
const (
	memsize  = 1 << 25 // 알아야 할 배치들을 둘 공간
	maxmoves = 1000    // 경로 길이의 상한
)

@ @<전역 변수@>=
var (
	pos        [memsize + maxsize/8 + 1]uint32 // 지금 아는 배치들
	cutoff     uint64          // 이 포인터 아래는 찾지 않아도 된다
	curpos     uint64          // 쓰지 않은 첫 배치 칸의 포인터
	source     uint64          // 지금 옮겨 가는 배치의 포인터
	nextsource uint64          // |source|의 다음 값
	maxpos     uint64          // 쓸 수 없는 첫 배치 칸의 포인터
	configs    uint64          // 지금까지의 배치 총수
	oldconfigs uint64          // 거리 |d|의 일을 시작할 때의 |configs|
	milestone  [maxmoves]uint64 // 거리마다 |curpos|의 값
	shortcut   int64           // |milestone[d]-cutoff|
	goalhash   int             // 마지막 배치의 해시 부호
	goal       [maxsize / 8]uint32 // 마지막 배치를 묶은 것
	start      [maxsize / 8]uint32 // 처음 배치를 묶은 것
)

@ 함수 |hashin|은 주어진 |board| 배치를 주 표에서 찾고, 새것이면 넣는다. 돌려주는
값은 매개변수 |trick|이 거짓이면 0이다. 참일 때, 곧 방식 2나 5의 이동일 때는 특별한
처리가 필요한데, 뒤에서 설명한다.

마지막 배치를 넣게 되면 |found|를 세우고 0을 돌려준다. 원본은 여기서 |longjmp|했다.

@<함수들@>=
func hashin(trick bool) int {
	var h, j, k, n int
	var bound int64
	n = pack(&board, &piece)
	for h, j = hashcode(config[0]), 1; j < n; j++ {
		h ^= hashcode(config[j])
	}
	h &= hashsize - 1
	if hash[h] < cutoff {
		goto newguy
	}
	bound = int64(hash[h] - cutoff)
	for j = int(hash[h] & (memsize - 1)); ; j = int((uint64(j) - uint64(pos[j])) & (memsize - 1)) {
		@<자리 |j|의 배치가 |config|와 같으면 돌아간다@>
		if bound -= int64(pos[j]); bound < 0 {
			break
		}
	}
newguy:
	@<|config|를 |pos| 표에 넣는다@>
	if h == goalhash {
		@<|config|가 마지막 배치이면 |found|를 세운다@>
	}
	if trick {
		return 1
	}
	return 0
}

@ @<자리 |j|의 배치가 |config|와 같으면 돌아간다@>=
for k = 0; k < n; k++ {
	if config[k] != pos[j+2+k] {
		break
	}
}
if k == n {
	if trick {
		@<까다로운 경우를 처리하고 돌아간다@>
	}
	return 0
}

@ @<|config|가 마지막 배치이면 |found|를 세운다@>=
for k = 0; k < n; k++ {
	if config[k] != goal[k] {
		break
	}
}
if k == n {
	found = true
	return 0
}

@ 앞 꾸러미로 가는 상대 포인터가 모든 경계보다 멀면 |memsize|를 적는다.

@<|config|를 |pos| 표에 넣는다@>=
j = int(curpos & (memsize - 1))
if diff := curpos - hash[h]; diff > memsize {
	pos[j] = memsize // 모든 경계를 넘는 상대 포인터
} else {
	pos[j] = uint32(diff)
}
pos[j+1] = uint32(curpos - source) // 앞 배치로 가는 상대 포인터
for k = 0; k < n; k++ {
	pos[j+2+k] = config[k]
}
hash[h] = curpos
@<|configs|를 고친다@>
@<|curpos|를 고친다@>

@ 새 배치를 만나면, 그것이 지금 거리에서 처음 찾은 것이거나 |verbose|가 섰을 때
찍는다.

@<|configs|를 고친다@>=
if configs == oldconfigs || verbose > 0 {
	@<|config|를 찍는다@>
	if verbose > 0 {
		fmt.Fprintf(stdout, " (%.15g=#%x, #%x에서)\n", float64(configs), curpos, source)
	}
}
configs++

@ 끝의 0들은 뺀다. 원본은 이 일을 |int| 변수로 했다. 그러면 마지막 낱말의 맨 위
니블이 8 이상일 때 오른쪽 밀기가 부호를 퍼뜨려, 이를테면 \.{000000008}을
\.{00000000fffffff8}로 찍는다. 여기서는 부호 없는 수를 쓴다. 크누스의 함수
|print_config|는 여기서만 쓰이므로 절로 풀었다.

@<|config|를 찍는다@>=
for k = 0; k < n-1; k++ {
	fmt.Fprintf(stdout, "%08x", config[k])
}
t, w := config[n-1], 8
for ; t&0xf == 0; w-- {
	t >>= 4
}
fmt.Fprintf(stdout, "%0*x", w, t) // 끝의 0들을 뺀다

@ 꾸러미가 |memsize| 경계를 넘었으면 다음 꾸러미는 경계에서 시작한다. 쓸 수 있는
자리를 넘으면 멈춘다.

@<|curpos|를 고친다@>=
curpos += uint64(n + 2)
if curpos&(memsize-1) < uint64(n+2) {
	curpos &^= memsize - 1
}
if curpos > maxpos {
	fmt.Fprintf(os.Stderr, "미안하지만 이 퍼즐에는 memsize가 모자란다.\n")
	exit(-13)
}

@ 이제 배치를 다루는 법을 알았으니 전체 탐색 계획을 실행할 수 있다.

@<퍼즐을 푼다@>=
fmt.Fprintf(stdout, "\n(방식 %d의 이동을 쓴다)\n", style)
@<처음 배치를 기억한다@>
restart:
@<마지막 배치를 기억한다@>
@<처음 배치를 |pos|에 넣는다@>
for d = 1; d < maxmoves; d++ {
	fmt.Fprintf(stdout, "*** 거리 %d:\n", d)
	milestone[d] = curpos
	oldconfigs = configs
	@<거리 |d|의 배치를 모두 만든다@>
	if configs == oldconfigs {
		exit(0) // 답이 없다
	}
	if verbose <= 0 {
		fmt.Fprintf(stdout, " 외 %d개.\n", configs-oldconfigs-1)
	}
}
fmt.Fprintf(stdout, "아직 답을 못 찾았다(maxmoves=%d)!\n", maxmoves)
exit(0)

@ @<마지막 배치를 기억한다@>=
t = pack(&aboard, &apiece)
for k, goalhash = 0, 0; k < t; k++ {
	goal[k] = config[k]; goalhash ^= hashcode(config[k])
}
goalhash &= hashsize - 1

@ 풀이를 되짚어 짤 때 처음 배치로 돌아가야 할 수도 있다.

@<처음 배치를 기억한다@>=
t = pack(&board, &piece)
for k = 0; k < t; k++ {
	start[k] = config[k]
}

@ @<처음 배치를 |pos|에 넣는다@>=
curpos, cutoff, milestone[0] = 1, 1, 1
source, configs, oldconfigs, d = 0, 0, 0, 0
maxpos = 1 << 32
fmt.Fprintf(stdout, "*** 거리 0:\n")
hashin(false)
if found {
	goto hurray
}
if verbose <= 0 {
	fmt.Fprintf(stdout, ".\n")
}

@ 원본은 처음에 |maxposh=1|, 곧 |maxpos|를 $2^{32}$으로 두었다. 거리 1을 시작할
때 제대로 셈하므로 처음 배치 하나를 넣는 동안만 쓰인다.

거리 $d-1$의 꾸러미들은 차례로 놓여 있으므로, |source|를 꾸러미 크기만큼씩 옮기며
훑는다.

@<거리 |d|의 배치를 모두 만든다@>=
if d > 1 {
	cutoff = milestone[d-2]
}
shortcut = int64(curpos - cutoff)
maxpos = cutoff + memsize
for source = milestone[d-1]; source != milestone[d]; source = nextsource {
	j = unpack(&board, &piece, &place, pos[(source&(memsize-1))+2:]) + 2
	nextsource = source + uint64(j)
	if nextsource&(memsize-1) < uint64(j) {
		nextsource &^= memsize - 1
	}
	@<|board|에서 둘 수 있는 수를 모두 해시에 넣는다@>
}

@* 답.
답을 |d|수 만에 찾았다.

@<답을 찍는다@>=
if d == 0 {
	fmt.Fprintf(stdout, "\n농담이겠지. 그 퍼즐은 한 수도 두지 않고 이미 풀려 있다!\n")
	exit(0)
}
fmt.Fprintf(stdout, "... 풀었다!\n")
if verbose < 0 {
	exit(0)
}
@<|pos|에 남은 핵심 수를 모두 찍고, 다 찍었으면 멈춘다@>
@<메모리가 모자랐음을 사과하고, 줄인 문제로 처음부터 다시 한다@>

@ 배치 목록의 위쪽 |memsize|칸에 자료가 남아 있는 한, 거꾸로 거슬러 가며 이긴 수순을
되살릴 수 있다.

@<|pos|에 남은 핵심 수를 모두 찍고...@>=
if curpos > memsize {
	maxpos = curpos - memsize
} else {
	maxpos = 0
}
for j = 0; j <= lr+colsp; j++ {
	aboard[j] = board[j]
}
for source >= maxpos {
	d--
	if d == 0 {
		exit(0)
	}
	fmt.Fprintf(stdout, "\n%d:\n", d)
	k = int(source & (memsize - 1))
	unpack(&aboard, &apiece, &aplace, pos[k+2:])
	printBoard(&aboard, &apiece)
	source -= uint64(pos[k+1])
}

@ 기억이 모자라 앞쪽 수순을 잊었으면, 잊기 직전의 배치를 새 목표로 삼아 처음부터 다시
찾는다. 그 배치는 지금 |aboard|에 있다.

@<메모리가 모자랐음을 사과하고...@>=
fmt.Fprintf(stdout, "(안타깝게도 수준 %d에 이르는 길을 잊어버렸다.\n", d)
fmt.Fprintf(stdout, " 그 부분을 다시 짜 맞춰야 하니 조금만 기다려 달라.)\n")
for j = 0; j < hashsize; j++ {
	hash[j] = 0
}
unpack(&board, &piece, &place, start[:])
found = false
goto restart

@* 옮기기.
마지막으로 할 일은 블록을 실제로 미는 것이다. 간단해 보이지만, 높은 방식의 이동에서는
까다로울 수 있다.

@<|board|에서 둘 수 있는 수를 모두 해시에 넣는다@>=
if style < 3 {
	for j = 0; j < 4; j++ {
		for k = 1; k <= bcount; k++ {
			move(k, delta[j], delta[j])
			if found {
				goto hurray
			}
		}
	}
} else {
	@<모든 초이동을 해 본다@>
}

@ 함수 |move|의 매개변수 |k|는 블록 번호, |del|은 변위, |delo|는 최근에 변위
|del-delo|인 판을 생각했음을 알려 주는 값이다.

원본은 들어갈 수 없으면 |else| 블록 안의 이름표 |illegal|로 뛰었다. \GO/는 블록
안으로 뛰어드는 |goto|를 허락하지 않으므로, 들어가는지를 |fits|에 담아 모양을 바꾸었다.

@<함수들@>=
func move(k, del, delo int) {
	s, t := place[k], piece[k]
	for j := offstart[t]; ; j++ { // 조각을 들어낸다
		board[s+off[j]] = 0
		if off[j] == 0 {
			break
		}
	}
	fits := true
	for j := offstart[t]; ; j++ { // 새 자리에 들어가는지 본다
		if board[s+del+off[j]] != 0 {
			fits = false; break
		}
		if off[j] == 0 {
			break
		}
	}
	if fits {
		@<조각을 옮겨 해시에 넣고, 더 나아갈 것이면 되돌린 뒤 재귀하고 돌아간다@>
	}
	for j := offstart[t]; ; j++ { // 옮기지 않은 조각을 되놓는다
		board[s+off[j]] = k
		if off[j] == 0 {
			break
		}
	}
}

@ @<조각을 옮겨 해시에 넣고, 더 나아갈 것이면 되돌린 뒤 재귀하고 돌아간다@>=
for j := offstart[t]; ; j++ { // 옮긴다
	board[s+del+off[j]] = k
	if off[j] == 0 {
		break
	}
}
r := hashin(style == 2)
if found {
	return
}
if r != 0 || style == 1 {
	@<조각을 되돌리고 재귀한다@>
	return
}
for j := offstart[t]; ; j++ { // 옮긴 조각을 들어낸다
	board[s+del+off[j]] = 0
	if off[j] == 0 {
		break
	}
}

@ 방식 1은 곧이곧대로다. 장애물에 부딪힐 때까지 방향 |delo|로 계속 민다. 그러나 방식
2는 더 미묘하다. 닿을 수 있는 가능성을 모두 살펴야 하기 때문이다. 크누스는 방식 2의
이동을 모두 찾으려던 첫 시도의 큰 실수를 짚어 준 Gary McDonald에게 고마워했다.
@^McDonald, Gary@>

조각 하나를 몇 번이든 옮겨 닿는 배치를 모두 찾는 기본 생각은 잘 알려진 깊이 우선
탐색이다. 그런데 비틀림이 있다. 그런 이동의 연속이 해시 표에 이미 있는 배치를 지날 수
있으므로, 낡은 배치를 만났다고 그냥 탐색을 멈출 수는 없다. 이를테면 판 \.{0102}에서
한 수로 \.{0120}, \.{0012}, \.{1002}에 닿는다. \.{0120}에서 두 번째 수를 두면
\.{1020}에 간다. 그러면 \.{1002}에서 둘 두 번째 수를 생각할 때 ``이미 본'' \.{1020}에서
멈추면 안 된다. 그러면 \.{1200}으로 가는 수를 찾지 못한다.

그래도 이렇게 말할 수 있다. 거리~$d$의 올바른 방식 2 이동은 모두, 거리 $d-1$에서
시작해 첫걸음 뒤로는 줄곧 거리~$d$에 머무는 경로로 닿는다. (그 이동에 이르는 최단
경로가 분명히 그렇다.)

@ 거리 $d-1$의 배치 $\alpha$에서 나가는 거리 $d$의 방식 2 이동을 살핀다고 하자. 이미
본 배치~$\beta$를 만나면 두 경우가 있다. 배치 $\beta$의 앞 배치가~$\alpha$이거나, 다른
배치 $\alpha'$이다. 앞의 경우에는 $\beta$ 너머를 더 볼 필요가 없다. 깊이 우선 탐색이
이미 거기를 다녀갔기 때문이다. ($\alpha$에서~$\beta$로 바뀔 때 움직인 조각은 하나뿐이니,
그것은 지금 옮기려는 조각이어야 한다.) 반면 $\alpha\ne\alpha'$이면, 위의 예가 보여
주듯 $\beta$ 너머의 모르는 땅을 살펴야 한다. 그러지 않으면 $\alpha$에서 나가는 올바른
수를 놓칠 수 있다. 이 둘째 경우에는 $\beta$를 끝없이 거듭 만나지 않을 방도가 필요하다.

자료 구조에 ``표시 비트''를 더하지 않고 이 궁지를 푸는 방법은, $\beta$의 앞 배치를
$\alpha'$에서 $\alpha$로 {\it 바꾸어 적는\/} 것이다. 이렇게 바꾸어도 된다. 배치 $\beta$는
둘 다 거리~$d-1$인 $\alpha'$과 $\alpha$ 어느 쪽에서도 한 수로 닿기 때문이다. 그러면
$\beta$를 다시 만나도 다시 따질 필요가 없고, 끝없이 도는 일은 생길 수 없다.

이것이 |hashin|의 끝내지 않은 ``까다로운'' 부분을 짜는 법을 알려 준다. 다음 코드에
오면 |pos| 배열의 $j$에서 시작하는 아는 배치~$\beta$를 막 찾은 것이다.

방식 5에서는 앞 배치가 $\alpha$여도 1을 돌려준다. 그때 끝없이 돌지 않게 하는 일은
|supermove|가 맡는다. 까닭은 맨 뒤에 적었다.

@<까다로운 경우를 처리하고 돌아간다@>=
if bound < shortcut {
	return 0 // $\beta$가 거리 $d$에 있지 않으면 돌아간다
}
nn := uint32((uint64(j) - source) & (memsize - 1)) // $\beta$에서 $\alpha$까지의 거리
if pos[j+1] == nn { // $\alpha$가 $\beta$의 앞이면
	if style == 5 {
		return 1
	}
	return 0
}
pos[j+1] = nn // 아니면 $\alpha$를 $\beta$의 앞으로 삼고
return 1 // 깊이 우선 탐색을 이어 간다

@ 이 부분의 지역 변수 |s|와 |t|는 재귀 호출을 건너 보존하지 않아도 된다. (크누스는
여느 컴파일러가 그 사실을 알아채리라 기대하지 않는다면서도, 요즘 컴파일러 기술을
얕보는 것일지도 모른다고 덧붙였다.)

@<조각을 되돌리고 재귀한다@>=
for j := offstart[t]; ; j++ { // 옮긴 조각을 들어낸다
	board[s+del+off[j]] = 0
	if off[j] == 0 {
		break
	}
}
for j := offstart[t]; ; j++ { // 옮기지 않은 조각을 되놓는다
	board[s+off[j]] = k
	if off[j] == 0 {
		break
	}
}
if style == 1 {
	move(k, del+delo, delo)
} else {
	for j := 0; j < 4 && !found; j++ {
		if delta[j] != -delo {
			move(k, del+delta[j], delta[j])
		}
	}
}

@* 초조각 옮기기.
남은 일이 가장 재미있다. 블록 여럿을 한꺼번에 미는 가능성은 어떻게 다룰까?

블록이 $m$개인 퍼즐에는 초조각이 $2^m-1$개 있을 수 있고, 그 상한에 이르는 예를 쉽게
만들 수 있다. 다행히 사리에 맞는 퍼즐에는 사리에 맞는 수의 초조각 이동만 있다. 할
일은 쓸데없는 경우를 따지지 않는 것이다. 다음 알고리즘은 그 일을 하는 귀여운 방법이다.

먼저 |aboard|를 |board|의 손본 사본으로 만들어 앞으로의 셈을 준비한다. 그러면서
|bdry|와 |obst| 항목을 0으로 바꾸어, 이제 0을 ``붙박인'' 특별한 블록으로 여긴다.
그리고 블록마다 그 블록의 칸들을 모두 잇는다. 이 연결이 앞서 쓴 변위 방식보다
효율적이다.

@<|board|를 베끼고 잇는다@>=
for j = 0; j <= bcount; j++ {
	head[j] = -1
}
for j = 0; j <= lr+colsp; j++ {
	if k = board[j]; k != 0 {
		if k >= obst {
			k = 0
		}
		aboard[j] = k; link[j] = head[k]; head[k] = j
	} else {
		aboard[j] = -1
	}
}

@ 이제 초등 그래프 이론이 도와준다.

블록을 꼭짓점으로 하고, 블록 $u$를 주어진 만큼 옮기면 $v$에 부딪힐 때 호 $u\to v$를
두는 방향 그래프를 생각하자. 초조각은 이 그래프의 {\it 이상(ideal)\/}이다. 곧
$u$가 초조각에 들고 $u\to v$이면 $v$도 초조각에 든다. 실제로 비어 있지 않고 붙박인
블록을 담지 않은 이상은 모두 초조각이고, 거꾸로도 그렇다. 그러니 우리 앞의 문제는
주어진 방향 그래프의 그런 이상을 모두 만드는 것과 같다.

이상의 여집합은 쌍대 방향 그래프(호를 모두 뒤집은 그래프)의 이상이다. 그리고 왼쪽으로
미는 방향 그래프는 오른쪽으로 미는 방향 그래프의 쌍대다. 그러니 왼쪽·오른쪽 밀기의
초조각을 모두 만드는 문제는 $k-1$에서 $k$로 옮기는 방향 그래프의 이상을 모두 만드는
것과 같다. 그런 이상이 붙박인 블록을 담지 않으면 오른쪽으로 미는 초조각이 되고, 담으면
그 여집합이 왼쪽으로 미는 초조각이 된다.

그 방향 그래프는 방금 만든 연결을 훑어 지을 수 있다. 다음 코드를 돌리고 나면
$u$에서 나가는 호는 |aboard|$[l]$, |aboard|$[l']$, |aboard|$[l'']$, \dots로 가고,
여기서 $l=|out[u]|$, $l'=|olink|[l]$, $l''=|olink|[l']$ 따위다. 꼭짓점 $u$로 들어오는 호도
|out|과 |olink| 대신 |in|과 |ilink|를 써서 마찬가지다.

@<|del=1|의 방향 그래프를 짓는다@>=
for j = 0; j <= bcount; j++ {
	out[j], in[j] = -1, -1
}
for j = 0; j <= bcount; j++ {
	for k = head[j]; k >= ul; k = link[k] { // |aboard[k]=j|
		t = aboard[k-1]
		if t != j && t >= 0 && (out[t] < 0 || aboard[out[t]] != j) {
			olink[k], out[t] = out[t], k
			ilink[k-1], in[j] = in[j], k-1
		}
	}
}

@ 위아래 밀기의 초조각을 모두 만드는 문제도 아주 비슷한 방향 그래프의 이상을 모두
만드는 문제와 같다.

@<|del=colsp|의 방향 그래프를 짓는다@>=
for j = 0; j <= bcount; j++ {
	out[j], in[j] = -1, -1
}
for j = 0; j <= bcount; j++ {
	for k = head[j]; k >= ul; k = link[k] { // |aboard[k]=j|
		t = aboard[k-colsp]
		if t != j && t >= 0 && (out[t] < 0 || aboard[out[t]] != j) {
			olink[k], out[t] = out[t], k
			ilink[k-colsp], in[j] = in[j], k-colsp
		}
	}
}

@ @<전역 변수@>=
var (
	head, out, in      [maxsize + 1]int // 목록 머리
	link, olink, ilink [boardsize]int  // 연결
)

@ 방향 그래프의 이상을 만드는 다음 함수는 꼭짓점들의 순열을 배열 |perm|에, 그 역순열을
|iperm|에 둔다. 배열의 |inx[l]|번부터 |inx[l+1]-1|번까지의 원소는, 되짚어 찾기 나무의
수준~|l|에서 내린 결정에 따라 |decision[l]=1|이면 모두 이상에 들고 |decision[l]=0|이면
모두 들지 않는다고 알려져 있다.

기본 불변식은, |perm|에서 첨자가 $\ge|inx[l]|$인 원소를 모두 빼든 모두 넣든 이상을
얻을 수 있다는 것이다. 처음에는 |inx[0]=0|이므로 $l=0$일 때 성립한다. 수준을 올리려면 먼저
꼭짓점 |perm[inx[l]]|을 빼기로 한다. 그러면 그리로 이끄는 꼭짓점도 모두 빠지니,
그것들이 제자리에 오도록 |perm|을 재배열한다. 그다음 꼭짓점 |perm[inx[l]]|을 넣기로
한다. 그러면 거기서 이끌려 나가는 꼭짓점도 모두 들어가니, 비슷하게 한다.

꼭짓점 0은 앞서 말한 ``붙박인'' 가짜 조각이다. 이 꼭짓점을 이상에서 빼면, 들어간
꼭짓점들의 판 자리를 모두 늘어놓는다. 그것이 |del|만큼 미는 초조각이다. 붙박인 꼭짓점을
넣으면, 빠진 꼭짓점들의 판 자리를 모두 늘어놓는다. 그것이 |-del|만큼 미는 초조각이다.
수준~|l|을 시작할 때 목록에는 |lstart[l]|개가 있다.

@<함수들@>=
func ideals(del int) {
	var j, k, l, p, u, v, t int
	for j = 0; j <= bcount; j++ {
		perm[j], iperm[j] = j, j
	}
	l, p = 0, 0
excl:
	@<꼭짓점 |perm[inx[l]]|과 그리로 이끄는 것들을 모두 뺀다@>
incl:
	@<꼭짓점 |perm[inx[l]]|과 거기서 이끌려 나가는 것들을 모두 넣는다@>
backup:
	if l != 0 {
		l--
		if decision[l] != 0 {
			goto backup
		}
		goto incl
	}
}

@ 빼는 결정을 내리고 나서 아직 정하지 않은 꼭짓점이 남았으면 한 수준 올라가 다음
꼭짓점을 뺀다. 모두 정해졌으면 이상 하나를 얻은 것이니, 처리하고 넣는 쪽으로 간다.

@<꼭짓점 |perm[inx[l]]|과 그리로 이끄는 것들을 모두 뺀다@>=
decision[l], lstart[l] = 0, p
for j, t = inx[l], inx[l]+1; j < t; j++ {
	@<|perm[j]|로 이끄는 꼭짓점들을 모두 $j$ 가까이 놓는다@>
}
if t > bcount {
	@<이상 하나를 처리한다@>
	goto incl
}
l++; inx[l] = t
goto excl

@ 넣는 쪽도 같다. 다만 모두 정해졌으면 이 가지를 다 본 것이니 되돌아간다.

@<꼭짓점 |perm[inx[l]]|과 거기서 이끌려 나가는 것들을 모두 넣는다@>=
decision[l], p = 1, lstart[l]
for j, t = inx[l], inx[l]+1; j < t; j++ {
	@<|perm[j]|에서 이끌려 나가는 꼭짓점들을 모두 $j$ 가까이 놓는다@>
}
if t > bcount {
	@<이상 하나를 처리한다@>
	goto backup
}
l++; inx[l] = t
goto excl

@ @<|perm[j]|로 이끄는 꼭짓점들을 모두 $j$ 가까이 놓는다@>=
v = perm[j]
for k = in[v]; k >= 0; k = ilink[k] {
	u = aboard[k]
	if iperm[u] >= t {
		uu, tt := perm[t], iperm[u]
		perm[t], perm[tt], iperm[u], iperm[uu] = u, uu, t, tt
		t++
	}
}
if decision[0] == 1 {
	for v = head[v]; v >= 0; v = link[v] {
		super[p] = v; p++
	}
}

@ @<|perm[j]|에서 이끌려 나가는 꼭짓점들을 모두 $j$ 가까이 놓는다@>=
u = perm[j]
for k = out[u]; k >= 0; k = olink[k] {
	v = aboard[k]
	if iperm[v] >= t {
		vv, tt := perm[t], iperm[v]
		perm[t], perm[tt], iperm[v], iperm[vv] = v, vv, t, tt
		t++
	}
}
if decision[0] == 0 {
	for u = head[u]; u >= 0; u = link[u] {
		super[p] = u; p++
	}
}

@ 수준은 꼭짓점 수만큼, 곧 |bcount+1|까지 깊어질 수 있다. 원본은 이 배열들을
|maxsize|칸으로 잡았는데, 블록이 |maxsize|개인 판에서는 한 칸 모자란다. 여기서는
하나씩 늘렸다.

@<전역 변수@>=
var (
	perm, iperm   [maxsize + 1]int // 기본 순열과 그 역
	decision      [maxsize + 1]int // 결정
	inx, lstart   [maxsize + 1]int // 결정 지점에서 되돌릴 값
	super         [maxsize + 1]int // 지금 초조각의 칸들
)

@ 초조각 하나마다 도장 |vstamp|를 새로 찍는다. 그 뜻은 뒤에서 말한다.

@<이상 하나를 처리한다@>=
if p != 0 {
	super[p] = 0 // 초조각 끝의 파수꾼
	vstamp++
	if decision[0] == 0 {
		supermove(del, del)
	} else {
		supermove(-del, -del)
	}
	if found {
		return
	}
}

@ 함수 |supermove|는 |move|와 같되, 블록~|k| 대신 |super|로 정한 초조각을 쓴다.

@<함수들@>=
func supermove(del, delo int) {
	for j := 0; super[j] != 0; j++ { // 초조각을 들어낸다
		board[super[j]] = 0
	}
	fits := true
	for j := 0; super[j] != 0; j++ { // 새 자리에 들어가는지 본다
		if board[del+super[j]] != 0 {
			fits = false; break
		}
	}
	if fits {
		@<초조각을 옮겨 해시에 넣고, 더 나아갈 것이면 되돌린 뒤 재귀하고 돌아간다@>
	}
	for j := 0; super[j] != 0; j++ { // 옮기지 않은 초조각을 되놓는다
		board[super[j]] = aboard[super[j]]
	}
}

@ 방식 5에서는 이번 초조각이 이미 가 본 변위에 다시 오면 더 나아가지 않는다.

@<초조각을 옮겨 해시에 넣고, 더 나아갈 것이면...@>=
for j := 0; super[j] != 0; j++ { // 옮긴다
	board[del+super[j]] = aboard[super[j]]
}
if style != 5 || visited[del+boardsize] != vstamp {
	if style == 5 {
		visited[del+boardsize] = vstamp
	}
	r := hashin(style == 5)
	if found {
		return
	}
	if r != 0 || style == 4 {
		@<초조각을 되돌리고 재귀한다@>
		return
	}
}
for j := 0; super[j] != 0; j++ { // 옮긴 초조각을 들어낸다
	board[del+super[j]] = 0
}

@ 초조각을 한 번 옮기고 나면 방향 그래프도 이상도 바뀐다. 그래도 괜찮다. 함수
|supermove|가 매 걸음마다 막히지 않았는지 보기 때문이다.

@<초조각을 되돌리고 재귀한다@>=
for j := 0; super[j] != 0; j++ { // 옮긴 초조각을 들어낸다
	board[del+super[j]] = 0
}
for j := 0; super[j] != 0; j++ { // 옮기지 않은 초조각을 되놓는다
	board[super[j]] = aboard[super[j]]
}
if style == 4 {
	supermove(del+delo, delo)
} else {
	for j := 0; j < 4 && !found; j++ {
		if delta[j] != -delo {
			supermove(del+delta[j], delta[j])
		}
	}
}

@ 방식 5의 깊이 우선 탐색에서 쓰는 도장이다. 변위는 판 크기보다 작으므로
|del+boardsize|를 첨자로 쓴다.

@<전역 변수@>=
var (
	vstamp  int                    // 지금 초조각의 도장
	visited [2*boardsize + 1]int // 변위마다 마지막으로 가 본 도장
)

@ 이제 남은 코드 조각들을 한데 모으며 프로그램이 영광스럽게 끝난다.

붙박인 블록의 칸 목록을 |lr+1|에서 시작하게 바꾸는 것을 크누스는 ``까다로운
최적화''라며 사과했다. 판 맨 아래 경계 줄의 칸들은 오른쪽 밀기의 방향 그래프에 아무
호도 보태지 않으므로 건너뛴다.

@<모든 초이동을 해 본다@>=
@<|board|를 베끼고 잇는다@>
@<|del=colsp|의 방향 그래프를 짓는다@>
ideals(colsp)
if found {
	goto hurray
}
head[0] = lr + 1
@<|del=1|의 방향 그래프를 짓는다@>
ideals(1)
if found {
	goto hurray
}

@* 옮기며 고친 것.
원본에서 결함 셋을 찾았다. 파이썬으로 따로 짠 단순한 너비 우선 탐색기와 견주며
확인했다.

첫째, 방식 5다. 까다로운 경우에서 원본은 $\beta$의 앞 배치가 $\alpha$이면 더 나아가지
않는다. 근거는 ``$\alpha$에서 $\beta$로 바뀔 때 움직인 조각은 하나뿐이니 지금 옮기려는
조각이어야 한다''였다. 방식 2에서는 옳다. 조각 하나만 옮겨서 같은 배치에 이르는 길은,
모양이 같은 조각이 있어도 하나뿐이다. 그러나 방식 5에서는 모양이 같은 조각이 있으면
{\it 서로 다른\/} 초조각이 $\alpha$에서 같은 $\beta$에 이를 수 있다. 이를테면 한 칸짜리
조각 둘이 \.{110}으로 놓이고 그 아래 줄이 비어 있으면, 두 조각을 함께 오른쪽으로 한 칸
밀어도, 왼쪽 조각 하나만 아래 줄로 돌려 오른쪽 끝에 올려도 \.{011}이 된다. 그러면 둘째 초조각의 깊이 우선 탐색이 $\beta$에서
멈추어, 그 초조각을 더 옮겨야 닿는 배치를 거리 $d$에서 놓친다. 그 배치는 한 수 늦게
나온다.

실제로 무작위 퍼즐 300개를 여섯 방식으로 풀어 본 1800가지에서, 원본은 방식 5의
여덟 가지에서 거리별 배치 수가 틀렸다. 이를테면 $4\times4$ 판에 조각 이름
\.1(한 칸), \.2($2\times2$), \.3, \.4를 두고 처음 배치를 \.{04012111}로 한 퍼즐에서,
원본은 실제 거리가 4인 배치 \.{41000101201}을 거리 5에 둔다. 그래서 이 배치를 마지막
배치로 주면, 원본은 5수가 걸린다고 답한다. 최단 풀이는 4수다.

이 판은 초조각마다 도장을 찍고, 가 본 변위를 적어 둔다. 그리고 방식 5에서는 앞
배치가 $\alpha$인 $\beta$를 만나도, 이번 초조각이 처음 가는 변위면 계속 나아간다.
끝없이 도는 일은 도장이 막는다. 거리 $d-1$ 이하의 배치에서 멈추는 크누스의 규칙과
앞 배치를 바꾸어 적는 요령은 그대로다.

둘째, 원본의 |print_config|는 |int|로 오른쪽 밀기를 해서, 마지막 낱말의 맨 위
니블이 8 이상이면 부호를 퍼뜨린다. 그래서 이를테면 거리 0의 배치 \.{000000008}을
\.{00000000fffffff8}로 찍는다. 찍는 것만 틀리고 탐색은 옳다.

셋째, 배치 줄에 정의하지 않은 조각 이름이 나와도 원본은 막지 않고, |off[-1]|을 읽은
채로 탐색을 이어 간다. 이 판은 그런 입력을 거절한다.

덧붙여, 블록이 |maxsize|개인 판에서는 |piece| 같은 배열이 한 칸 모자란다. 여기서는
하나씩 늘렸다.

@* 맞춰 보기.
원본에 위의 세 가지를 고친 C 프로그램을 만들어 이 판과 견주었다. 무작위 퍼즐 300개와
본문의 이상한 퍼즐을 여섯 방식으로 풀어, 한글로 옮긴 문구를 원본의 것으로 바꾸면
표준 출력이 바이트 하나까지 같다. 거리마다 처음 찾은 배치, 배치 수, 그리고 찍힌 풀이
수순까지 같다.

답 자체는 파이썬으로 짠 너비 우선 탐색기로 확인했다. 배치를 블록 집합으로 들고
다니며, 방식마다 이동의 정의를 곧이곧대로 따르고, 초조각은 부분집합을 모두 늘어놓는다.
고친 판은 1800가지 모두에서 거리별 배치 수가 이 탐색기와 같다. 찍힌 풀이 수순도
따로 검사해, 이웃한 두 판이 그 방식의 한 수로 이어짐을 확인했다.

낡은 자료를 버리는 부분과, 앞쪽 수순을 잊어 처음부터 다시 찾는 부분은 |memsize|를
$2^{13}$으로 줄인 판으로 시험했다. 결과는 같았고, 다시 찾은 수순도 옳았다.

@* 색인.
