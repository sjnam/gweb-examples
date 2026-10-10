\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\title{오델로}

@* 들어가며.
크누스는 리버시를 일반화한 게임을 조금 겪어 보려고 이 프로그램을 ``서둘러''
짰다. 리버시는 그 주된 변형인 ``오델로''라는 이름으로 더 널리 알려져 있다.

판은 $m\times n$이다. 행에는 \.1, \.2, \.3, \dots\ 하고 번호를 매기고, 열에는
\.a, \.b, \.c, \dots\ 하고 이름을 붙인다. 칸은 글자와 숫자로 가리킨다. 이를테면
\.{d3}은 넷째 열의 셋째 행이다. 크누스는 $m>9$나 $n>26$을 막지 않았지만, 그렇게
크게 잡으면 버그가 드러날 거라고 했다. 행 번호를 숫자 한 글자로만 읽기 때문이다.

차례가 오면 사용자는 표준 입력으로 다음 수를 둘 칸의 이름을 넣고 줄을 바꾼다.
줄바꿈 바로 앞에 `\.!'를 붙이면, 수를 둔 뒤의 판을 표준 출력으로 찍는다.

@ 처음 네 수는 판에 돌을 놓기만 하고 아무것도 뒤집지 않는다. 이 네 수는 $-3$,
$-2$, $-1$, $0$번째 수로 치므로, 보통의 첫 수가 1번째 수가 된다. 표준 오델로에서는
$m=n=8$이고 처음 네 수가 \.{d5}, \.{e5}, \.{e4}, \.{d4}다. 이때 첫 수로
\.{d3}을 두면 \.{d4}의 색이 뒤집힌다. 아래 그림에서 검은 돌이
경기자 0, 흰 돌이 경기자 1이고, 점선 원이 \.{d3}이다.
$$\mplibcode
beginfig(1);
  u := 13pt;
  def cell(expr j, i) = ((j - .5) * u, -(i - .5) * u) enddef;
  def stone(expr j, i, c) =
    fill fullcircle scaled .72u shifted cell(j, i) withcolor
      if c = 0: black else: white fi;
    draw fullcircle scaled .72u shifted cell(j, i) withpen pencircle scaled .5;
  enddef;
  fill unitsquare xscaled 8u yscaled 8u shifted (0, -8u) withcolor .9white;
  for k = 0 upto 8:
    draw (0, -k * u) -- (8u, -k * u) withpen pencircle scaled .4;
    draw (k * u, 0) -- (k * u, -8u) withpen pencircle scaled .4;
  endfor
  for k = 1 upto 8:
    label.top(textext(substring (k - 1, k) of "abcdefgh"), ((k - .5) * u, 0));
    label.lft(textext(decimal k), (0, -(k - .5) * u));
  endfor
  stone(4, 5, 0); stone(5, 5, 1); stone(5, 4, 0); stone(4, 4, 1);
  draw fullcircle scaled .72u shifted cell(4, 3) dashed evenly scaled .6;
endfig;
\endmplibcode$$
\.{d3}에서 아래로 내려가면 경기자 1의 \.{d4}를 지나 경기자 0의 \.{d5}에 닿는다.
그래서 \.{d4}가 경기자 0의 색으로 뒤집힌다.

@ 이 프로그램은 경기자가 둘보다 많아도 된다. 경기자가 $p$명이면 $1-p^2$번째
수부터 시작해, 처음 $p^2$수로 첫 배치를 만든다. 경기자들이 차례로 한 수씩 두므로
저마다 돌 $p$개를 놓게 된다.

@ 크누스는 까다로운 일은 아무것도 하지 않았다. 판의 칸에는 비어 있으면 $-1$이,
돌이 있으면 그 맨 위 색 $c$가 들어 있다. 색은 0, 1, \dots,~$p-1$이다. 판
|board[i][j]|는 $0\le i\le m+1$과 $0\le j\le n+1$에 걸쳐 두지만, 테두리의 칸은
늘 비어 있다. 그래서 여덟 방향으로 훑다가 판 밖으로 나가는지를 따로 살필 필요가
없다. 빈칸에서 멈추듯 테두리에서도 멈추기 때문이다.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{othello.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/othello.w}를 \.{GWEB}으로
옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Sun, 09 Jun 2024 09:12:47 GMT}다. 프로그램이 찍는 말과 종료 부호는 원본
그대로 두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

원본은 표준 오델로가 ``$m=n=9$''라고 적었다. 오델로의 판은 $8\times8$이고, 원본이
정의한 상수도 8이니 오타다. 고쳐 적었다.

게임의 규칙을 다루는 부분에서는 결함을 찾지 못했다. 다만 원본의 |main|은
`\.{void main(void)}'라서, 게임이 제대로 끝나도 종료 부호가 정해지지 않는다. 마지막에
부른 함수가 남긴 값이 그대로 종료 부호가 되기 때문이다. 내 컴퓨터의 \.{clang}으로
컴파일하면 \.{-O0}에서는 1, \.{-O1}과 \.{-O2}에서는 10이었다. 마지막 판의 끝
줄바꿈을 찍는 |printf("\n")|를 컴파일러가 |putchar('\n')|으로 바꾸고, 그 반환값인
줄바꿈의 부호 10이 남은 것이다. 셸은 이것을 실패로 본다. 이 판은 게임이 끝나면 0을
돌려준다.

@ 단말기에서 돌리면 이렇다. 처음 네 수로 첫 배치를 만들고, 셋째 수 \.{f6} 뒤에
`\.!'를 붙여 판을 찍게 했다. 판의 마지막 행 끝에는 색마다 돌의 수가 붙는다.
$$\vbox{\tt\frenchspacing\obeyspaces\halign{#\hfil\cr
Move -3, player 0: d5\cr
Move -2, player 1: e5\cr
Move -1, player 0: e4\cr
Move 0, player 1: d4\cr
Move 1, player 0: d3\cr
Move 2, player 1: c5\cr
Move 3, player 0: f6!\cr
........\cr
........\cr
...0....\cr
...00...\cr
..110...\cr
.....0..\cr
........\cr
........ 5 2\cr
Move 4, player 1:\cr}}$$

@ 뼈대는 이렇다. 판을 비우고, 게임이 끝날 때까지 수를 받아 두고, 마지막 판을
찍는다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
)

@<상수@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	var i, j, k, ii, jj, pass, player int
	@<판을 비운다@>@;
	@<게임이 끝날 때까지 수를 받아 둔다@>@;
	printBoard()
	out.Flush()
}

@ 판의 크기와 경기자의 수는 원본처럼 상수로 둔다. 바꾸려면 여기를 고쳐 다시
컴파일한다.

@<상수@>=
const (
	m = 8 // 행의 수
	n = 8 // 열의 수
	p = 2 // 경기자의 수
)

@ 배열 |deli|와 |delj|는 여덟 방향이다. 방향 |k|로 한 칸 가면 행이 |deli[k]|,
열이 |delj[k]|만큼 바뀐다.

@<전역 변수@>=
var (
	board  [m + 2][n + 2]int // 지금 판의 칸들
	move   int               // 지금 몇 번째 수인가
	deli   = [8]int{-1, -1, -1, 0, 0, 1, 1, 1}
	delj   = [8]int{-1, 0, 1, -1, 1, -1, 0, 1}
	buffer [8]byte    // 입력을 받는 곳
	total  [p]int     // 색마다 판에 보이는 돌의 수
	in     = bufio.NewReader(os.Stdin)
	out    = bufio.NewWriter(os.Stdout)
)

@ 테두리까지 모든 칸을 비운다.

@<판을 비운다@>=
for i = 0; i <= m+1; i++ {
	for j = 0; j <= n+1; j++ {
		board[i][j] = -1
	}
}

@* 게임 진행.
수마다 먼저 지금 경기자가 둘 곳이 있는지 본다. 없으면 넘기고 다음 경기자를 본다.
$p$명이 잇달아 넘기면 아무도 둘 곳이 없으니 게임이 끝난다. 넘겨도 수의 번호는 늘지
않는다.

원본은 둘 곳을 찾으면 이름표 |nextmove|로 뛰어 그 수를 받는다. 받은 칸이 없는
칸이거나 둘 수 없는 칸이어도 그리로 다시 뛰어, 같은 경기자에게 다시 묻는다.
\GO/의 |goto|도 바깥 블록의 이름표로는 뛸 수 있으니 그대로 두었다. 둘 곳이 있는지
찾는 반복문 안에서 앞으로 뛰는 것과, 수를 받는 절에서 뒤로 뛰는 것 둘이다.

@<게임이 끝날 때까지 수를 받아 둔다@>=
for move, player = 1-p*p, 0; ; move, player = move+1, (player+1)%p {
	for pass = 0; pass < p; pass++ {
		@<|player|가 둘 곳이 있으면 |goto nextmove|@>@;
		fmt.Fprintf(out, "(player %c cannot move)\n", '0'+player)
		player = (player + 1) % p
	}
	break // 게임이 끝났다: $p$명이 잇달아 넘겼다
nextmove:
	fmt.Fprintf(out, "Move %d, player %c: ", move, '0'+player)
	out.Flush() // 사용자가 물음을 꼭 보게 한다
	@<다음 수의 좌표를 |i|와 |j|에 받는다@>@;
	@<|player|의 돌을 칸 $(i,j)$에 둔다@>@;
	if buffer[2] == '!' {
		printBoard()
	}
}

@ @<|player|가 둘 곳이 있으면 |goto nextmove|@>=
for i = 1; i <= m; i++ {
	for j = 1; j <= n; j++ {
		if islegal(i, j, player) {
			goto nextmove
		}
	}
}

@ 원본은 \CEE/의 |fgets(buffer,8,stdin)|으로 한 줄을 읽는다. 많아야 일곱 바이트를
읽되 줄바꿈을 만나면 그것까지 읽고 멈추며, 끝에 영 바이트를 둔다. 줄이 그보다
길면 나머지는 다음 수의 입력이 된다. 이 판도 꼭 그렇게 읽는다. 아무것도 읽지
못하면 입력이 끝난 것이다.

칸 이름의 첫 글자가 열이고 둘째 글자가 행이다. 행을 숫자 한 글자로만 읽으니
$m>9$이면 열째 행부터는 가리킬 수가 없다. (사실은 `\.:'가 10이 되기는 한다.)

@<다음 수의 좌표를 |i|와 |j|에 받는다@>=
@<|buffer|에 한 줄을 읽는다; 입력이 끝났으면 멈춘다@>@;
j, i = int(buffer[0])-'a'+1, int(buffer[1])-'0'
if i < 1 || i > m || j < 1 || j > n {
	fmt.Fprintf(os.Stderr, "Cell `%c%c' doesn't exist!\n", buffer[0], buffer[1])
	printBoard()
	goto nextmove
}
if !islegal(i, j, player) {
	fmt.Fprintf(os.Stderr, "No! `%c%c' isn't a legal move for %c.\n",
		buffer[0], buffer[1], '0'+player)
	printBoard()
	goto nextmove
}

@ 입력이 끝나 멈출 때는 표준 출력의 버퍼를 먼저 비운다. \CEE/의 |exit|는 그렇게
해 주지만 \GO/의 |os.Exit|는 해 주지 않는다.

@<|buffer|에 한 줄을 읽는다; 입력이 끝났으면 멈춘다@>=
k = 0
for k < len(buffer)-1 {
	c, err := in.ReadByte()
	if err != nil {
		break
	}
	buffer[k] = c
	k++
	if c == '\n' {
		break
	}
}
if k == 0 {
	out.Flush()
	fmt.Fprintf(os.Stderr, "Unexpected end of input!\n")
	os.Exit(-1)
}
buffer[k] = 0

@* 수 두기.
다음 함수는 색 |c|의 돌을 판의 칸 $(i,j)$에 놓아도 되는지를 판정한다.
$1\le i\le m$, $1\le j\le n$, $0\le c<p$라고 가정하고 따로 살피지 않는다.
이미 찬 칸에는 둘 수 없다. 첫 배치를 만드는 동안에는 빈칸이면 어디든 된다. 그
뒤로는 여덟 방향 가운데 적어도 한 방향에서 남의 돌을 하나 이상 지나 제 돌에 닿아야
한다. 경기자가 셋 이상이면 그 사이의 남의 돌은 색이 섞여 있어도 된다.

@<함수들@>=
func islegal(i, j, c int) bool {
	if board[i][j] >= 0 {
		return false // 이미 찼다
	}
	if move <= 0 {
		return true // 이제 막 시작했다
	}
	for k := 0; k < 8; k++ {
		@<방향 |k|로 둘 수 있으면 |true|를 돌려준다@>@;
	}
	return false
}

@ 방향 |k|로 빈칸이나 테두리를 만날 때까지 훑으며, 처음 만나는 제 돌을 찾는다.
그 앞까지 지난 칸의 수가 |l|이다. 원본은 제 돌을 만나면 이름표 |maybe|로 뛰고,
못 만나면 |continue|로 다음 방향을 본다. 여기서는 제 돌을 만난 자리에서 바로
판정한다. |l|이 0이면 제 돌 둘이 붙어 있는 것이니 이 방향으로는 뒤집을 것이 없다.

@<방향 |k|로 둘 수 있으면 |true|를 돌려준다@>=
for ii, jj, l := i+deli[k], j+delj[k], 0; board[ii][jj] >= 0; ii, jj, l = ii+deli[k], jj+delj[k], l+1 {
	if board[ii][jj] == c {
		if l > 0 {
			return true // 적어도 |l|칸을 뒤집는다
		}
		break
	}
}

@ 수를 두면 그 칸에 돌을 놓고, 첫 배치가 끝난 뒤라면 여덟 방향으로 뒤집을 것을
모두 뒤집는다. 원본은 이 일을 함수 |makemove|로 따로 두었지만 부르는 곳이 한
곳뿐이라 이름 있는 절로 바꾸었다. 원본의 조기 반환 `|if (move<=0) return;|'은 조건을
뒤집어 감쌌다.

@<|player|의 돌을 칸 $(i,j)$에 둔다@>=
board[i][j] = player
if move > 0 {
	for k = 0; k < 8; k++ {
		@<방향 |k|로 뒤집을 것을 모두 뒤집는다@>@;
	}
}

@ 판정할 때처럼 방향 |k|로 훑어 처음 만나는 제 돌을 찾는다. 찾으면 거기서 칸
$(i,j)$ 쪽으로 되돌아오며 그 사이의 돌을 모두 제 색으로 바꾼다. 못 찾으면 이
방향으로는 뒤집을 것이 없다. 원본은 찾았을 때 이름표 |reverse|로 뛴다.

@<방향 |k|로 뒤집을 것을 모두 뒤집는다@>=
for ii, jj = i+deli[k], j+delj[k]; board[ii][jj] >= 0; ii, jj = ii+deli[k], jj+delj[k] {
	if board[ii][jj] == player {
		@<칸 $(ii,jj)$에서 칸 $(i,j)$ 쪽으로 되돌아오며 뒤집는다@>@;
		break
	}
}

@ @<칸 $(ii,jj)$에서 칸 $(i,j)$ 쪽으로 되돌아오며 뒤집는다@>=
for ii, jj = ii-deli[k], jj-delj[k]; ii != i || jj != j; ii, jj = ii-deli[k], jj-delj[k] {
	board[ii][jj] = player
}

@* 판 찍기.
판을 찍는 함수는 세 곳에서 부른다. 사용자가 `\.!'를 붙였을 때, 받은 수가 잘못되었을
때, 그리고 게임이 끝났을 때다. 빈칸은 `\..'로, 돌은 그 색의 숫자로 찍는다. 찍는
김에 색마다 돌을 세어 마지막 행 끝에 붙인다.

@<함수들@>=
func printBoard() {
	for k := 0; k < p; k++ {
		total[k] = 0
	}
	for i := 1; i <= m; i++ {
		for j := 1; j <= n; j++ {
			if k := board[i][j]; k >= 0 {
				total[k]++
				out.WriteByte('0' + byte(k))
			} else {
				out.WriteByte('.')
			}
		}
		if i == m {
			for k := 0; k < p; k++ {
				fmt.Fprintf(out, " %d", total[k])
			}
		}
		out.WriteByte('\n')
	}
}

@* 맞춰 보기.
원본을 \.{ctangle}로 풀어 컴파일하고 이 판과 견주었다. (요즘의 \.{clang}은
원본 |print_board|의 `\.{register i,j,k;}'처럼 형을 빠뜨린 선언을 받아 주지 않아서
\.{-std=gnu89}로 컴파일했다.) 판의 크기와 경기자의 수는 상수이므로, 두 프로그램의
상수를 함께 바꾸어 열두 가지로 컴파일했다. $8\times8$의 경기자 2명, 1명, 그리고
$1\times1$, $2\times2$, $4\times4$, $5\times7$, $6\times8$, $10\times10$의 2명,
$3\times3$과 $6\times6$의 3명, $9\times9$의 4명, $4\times9$의 5명이다.

\smallskip
\item{$\bullet$} 가지마다 무작위 입력 $600$개, 모두 $7200$개를 넣었다. 입력은 줄을
많게는 $4000$개까지 늘어놓은 것이다. 줄은 대개 판 위의 칸 이름이고, 가끔 `\.!'를
붙였다. 사이사이에 없는 칸, 빈 줄, 일곱 바이트보다 긴 줄, 대문자, 제어 문자 따위를
섞었고, 마지막 줄바꿈을 뺀 것도 있다. 표준 출력과 표준 오류가 모두 바이트까지
같았다. 게임이 끝까지 간 것이 $4103$개였는데, 원본의 종료 부호만 앞에서 말한 대로
0이 아니었다. 나머지 $3097$개는 입력이 도중에 끝나, 두 프로그램 모두 종료 부호
$-1$로 멈추었다.
\item{$\bullet$} 그 가운데 $720$개는 \.{AddressSanitizer}와
\.{UndefinedBehaviorSanitizer}를 붙인 원본으로도 돌렸다. 아무것도 잡히지 않았다.
\item{$\bullet$} 한 경기자가 넘긴 뒤에 게임이 이어지는 경우도 시험에 들었는지
따로 세어 보았다. 무작위 게임 $300$개 가운데 $129$개에 있었다.
\item{$\bullet$} 규칙이 옳은지는 원본과 따로, 오델로의 잘 알려진 수 세기와
견주었다. 표준 첫 배치에서 둘 수 있는 수의 열은 길이 1부터 5까지 4, 12, 56, 244,
1396가지다. 이 판에 칸 이름을 하나씩 넣어 보아 `\.{No!}'가 나오지 않는 수만
따라가며 세었더니 이 수들이 그대로 나왔다.
\smallskip

@* 색인.
