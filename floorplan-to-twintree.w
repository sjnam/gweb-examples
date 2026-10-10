\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\title{플로어플랜에서 쌍둥이 나무로}

@* 들어가며.
이 프로그램은 주어진 플로어플랜에 대응하는 쌍둥이 나무(twintree)를 계산한다.
크누스의 말로는 ``서둘러'' 짠 것이다. 관련된 개념과 용어는 {\sl The Art of
Computer Programming\/} 제4B권의 연습 문제 MPR--135와 7.2.2.1--372에 소개되어
있다.

플로어플랜은 직사각형을 더 작은 직사각형 ``방''들로 나눈 것이다. 방들을 가르는
가로 선분과 세로 선분을 ``경계''라고 한다. 경계는 서로 가로지르지 않는다. 그래서
두 경계가 만나는 곳은 늘 `$\top$', `$\bot$', `$\vdash$', `$\dashv$' 꼴의 교차점이고,
네 방이 한 점에서 만나는 일은 없다.

방마다 표준 입력으로 한 줄씩 준다. 줄에는 방의 이름과 그 방의 위 경계, 아래
경계, 왼쪽 경계, 오른쪽 경계의 이름을 차례로 적는다. 이를테면 다음 열 줄이 그
연습 문제의 예를 나타낸다.
$$\vcenter{\halign{\tt #\cr
A h0 h3 v0 v1\cr
B h0 h1 v1 v5\cr
C h1 h3 v1 v3\cr
D h3 h5 v0 v2\cr
E h5 h6 v0 v2\cr
F h3 h6 v2 v3\cr
G h1 h2 v3 v5\cr
H h2 h4 v3 v4\cr
I h4 h6 v3 v4\cr
J h2 h6 v4 v5\cr
}}$$
이름은 보이는 \.{ASCII} 글자로 많아야 일곱 자다. 방은 어떤 차례로 늘어놓아도 된다.
그림으로 그리면 이렇다.
$$\mplibcode
beginfig(1);
  u := 10mm;
  def hseg(expr y, a, b) = draw (a*u, y*u) -- (b*u, y*u) enddef;
  def vseg(expr x, a, b) = draw (x*u, a*u) -- (x*u, b*u) enddef;
  pickup pencircle scaled .8;
  hseg(6, 0, 5); hseg(5, 1, 5); hseg(4, 3, 5); hseg(3, 0, 3);
  hseg(2, 3, 4); hseg(1, 0, 2); hseg(0, 0, 5);
  vseg(0, 0, 6); vseg(1, 3, 6); vseg(2, 0, 3); vseg(3, 0, 5);
  vseg(4, 0, 4); vseg(5, 0, 6);
  label(btex A etex, (.5u, 4.5u)); label(btex B etex, (3u, 5.5u));
  label(btex C etex, (2u, 4u));    label(btex D etex, (1u, 2u));
  label(btex E etex, (1u, .5u));   label(btex F etex, (2.5u, 1.5u));
  label(btex G etex, (4u, 4.5u));  label(btex H etex, (3.5u, 3u));
  label(btex I etex, (3.5u, 1u));  label(btex J etex, (4.5u, 2u));
  def bname(expr t, z) =
    begingroup save pic; picture pic; pic := thelabel(t, z);
    unfill bbox pic; draw pic; endgroup
  enddef;
  bname(btex \.{h0} etex, (2.5u, 6u)); bname(btex \.{h1} etex, (2u, 5u));
  bname(btex \.{h2} etex, (3.5u, 4u)); bname(btex \.{h3} etex, (1.5u, 3u));
  bname(btex \.{h4} etex, (3.5u, 2u)); bname(btex \.{h5} etex, (1.5u, 1u));
  bname(btex \.{h6} etex, (2.5u, 0));
  bname(btex \.{v0} etex, (0, 3u));     bname(btex \.{v1} etex, (1u, 5.5u));
  bname(btex \.{v2} etex, (2u, 2.5u));  bname(btex \.{v3} etex, (3u, 4.5u));
  bname(btex \.{v4} etex, (4u, 3.5u));  bname(btex \.{v5} etex, (5u, 3u));
endfig;
\endmplibcode$$

@ 쌍둥이 나무는 같은 $n$개의 마디 위에 세운 두 이진 나무 $T_0$과 $T_1$이다. 마디마다
네 링크 $l_0$, $r_0$, $l_1$, $r_1$이 있다. $l_0$과 $r_0$은 $T_0$의 왼쪽·오른쪽
자식이고, $l_1$과 $r_1$은 $T_1$의 왼쪽·오른쪽 자식이다. 두 나무의 대칭 순서(중위
순서)는 같다. 그리고 대칭 순서로 마지막이 아닌 마디 $k$마다 $r_0[k]$와 $r_1[k]$
가운데 꼭 하나만 널이 아니다. 이 두 성질은 뒤에서 결과를 확인할 때 쓴다.

출력은 대응하는 쌍둥이 나무 $T_0$과 $T_1$이다. 나무마다 먼저 뿌리를 밝히고, 이어서
마디 이름과 왼쪽·오른쪽 자식 링크를 대칭 순서로 찍는다. 널 링크는 `\.{/\\}'로
나타낸다.

앞의 예의 쌍둥이 나무는 이렇다. 대칭 순서는 방 이름의 순서 A, B, \dots, J와 같다.
(이것을 플로어플랜의 대각선 순서라고 한다.)
$$\mplibcode
beginfig(2);
  w := 6mm; h := 7mm;
  string nm; nm := "ABCDEFGHIJ";
  numeric d[], e[];
  d1 := 2; d2 := 4; d3 := 3; d4 := 1; d5 := 0;
  d6 := 1; d7 := 4; d8 := 3; d9 := 2; d10 := 3;
  e1 := 1; e2 := 0; e3 := 2; e4 := 4; e5 := 5;
  e6 := 3; e7 := 1; e8 := 3; e9 := 4; e10 := 2;
  def p(expr k) = (k*w, -d[k]*h) enddef;
  def q(expr k) = (k*w + 13w, -e[k]*h) enddef;
  pickup pencircle scaled .5;
  draw p(5)--p(4); draw p(5)--p(6); draw p(4)--p(1); draw p(1)--p(3);
  draw p(3)--p(2); draw p(6)--p(9); draw p(9)--p(8); draw p(9)--p(10);
  draw p(8)--p(7);
  draw q(2)--q(1); draw q(2)--q(7); draw q(7)--q(3); draw q(7)--q(10);
  draw q(3)--q(6); draw q(6)--q(4); draw q(4)--q(5); draw q(10)--q(8);
  draw q(8)--q(9);
  for k = 1 upto 10:
    unfill fullcircle scaled 4.2mm shifted p(k);
    draw fullcircle scaled 4.2mm shifted p(k);
    label(textext(substring (k-1, k) of nm), p(k));
    unfill fullcircle scaled 4.2mm shifted q(k);
    draw fullcircle scaled 4.2mm shifted q(k);
    label(textext(substring (k-1, k) of nm), q(k));
  endfor
  label.top(btex $T_0$ etex, p(5) + (0, 3mm));
  label.top(btex $T_1$ etex, q(2) + (0, 3mm));
endfig;
\endmplibcode$$

@ 이것은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{floorplan-to-twintree.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/floorplan-to-twintree.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Wed, 07 Dec 2022 15:56:48 GMT}다. 프로그램이 찍는 말과 종료 부호는 원본
그대로 두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

크누스는 이 프로그램을 플로어플랜, 쌍둥이 나무, 백스터 순열 사이의 전단사를 다루는
삼부작의 첫 편으로 썼다. 둘째 편 {\mc TWINTREE-TO-BAXTER}는 쌍둥이 나무에서 백스터
순열을, 셋째 편 {\mc BAXTER-TO-FLOORPLAN}은 백스터 순열에서 플로어플랜을 만든다.
변경 파일 \.{floorplan-to-twintree-ttform.ch}를 적용하면 이 프로그램의 출력이 둘째
편이 읽는 형식으로 바뀐다. 그 변경 파일도 함께 옮겼다.

옮기다가 원본의 결함 다섯을 만났다. 가장 큰 것은, 잘못된 플로어플랜을 받고도
모순을 알아채지 못해 엉뚱한 쌍둥이 나무를 내놓거나 스택이 넘쳐 죽는 것이다. 모두
고쳤고, 맨 뒤의 ``옮기며 고친 것''에 모아 적었다.

@ 크누스는 오류를 만나면 사정없이 멈춘다. 받은 자료가 잘못되었으면 |reject|로
종료 부호 $-666$을, 처리하다 모순을 만나면 |pan|으로 $-66$을 내고 멈춘다. 이유가
둘이면 |reject2|를 쓴다. 원본에서는 셋 다 매크로이고 이름이 |panic|, |pan|,
|panicic|이다. \GO/에서는 |panic|이 미리 정의된 이름이라 바꾸었다.

@<함수들@>=
func reject(m, s string) {
	fmt.Fprintf(os.Stderr, "%s! (%s)\n", m, s)
	os.Exit(-666)
}
@#
func pan(m string) {
	fmt.Fprintf(os.Stderr, "%s!\n", m)
	os.Exit(-66)
}
@#
func reject2(m, s1, s2 string) {
	fmt.Fprintf(os.Stderr, "%s! (%s and %s)\n", m, s1, s2)
	os.Exit(-666)
}

@ 뼈대는 이렇다. 입력 단계, 준비 단계, 멋진 단계, 출력 단계가 차례로 온다. 멋진
단계 뒤에는 결과를 확인하는 단계를 하나 더 두었다. 원본에는 없는 것이다.

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
	var i, j, k, l, q, nameloc, nametyp, rooms, hbounds, vbounds, todo int
	@<플로어플랜을 읽는다@>@;
	@<교차점들을 찾는다@>@;
	@<쌍둥이 나무를 만든다@>@;
	@<쌍둥이 나무가 입력과 맞는지 살핀다@>@;
	@<쌍둥이 나무를 찍는다@>@;
	out.Flush()
}

@ 크기의 한도는 원본 그대로다. 방이 $r$개인 플로어플랜에는 경계가 $r+3$개 있으니
이름은 많아야 $2r+3$개다.

@<상수@>=
const (
	bufsize  = 80 // 입력 줄의 최대 길이
	maxrooms = 1024
	maxnames = 2*maxrooms + 3
)

@* 입력 단계.
쉬운 것부터 시작한다. 이름은 배열 |name|에 기억하고, 방인지 경계인지를 가린다.
방 $i$마다 다섯 가지를 기억한다. 가로 경계를 가리키는 번호 |top[i]|와 |bot[i]|,
세로 경계를 가리키는 번호 |lft[i]|와 |rt[i]|, 그리고 방의 이름의 번호 |room[i]|다.

원본은 이름을 찾을 때 지금까지의 이름을 처음부터 하나씩 견준다. 나는 이름에서
번호로 가는 사상 |where|를 두었다. 찾는 것은 같고, 빠를 뿐이다.

@<전역 변수@>=
var (
	buf   [bufsize]byte
	pos   int      // |buf|에서 읽고 있는 자리
	name  []string // 지금까지 본 이름들
	where = map[string]int{}
	typ   []int // $1=$방, $2=$가로 경계, $3=$세로 경계
	inx   []int // |room|이나 |hbound|나 |vbound|로 가는 번호
	room, hbound, vbound [maxrooms + 1]int // 이름으로 돌아가는 번호
	top, bot, lft, rt    [maxrooms]int     // 방의 경계들
	in                   = bufio.NewReader(os.Stdin)
	out                  = bufio.NewWriter(os.Stdout)
)

@ 줄마다 이름 다섯을 읽는다. 원본은 \CEE/의 |fgets|로 한 줄을 읽는다. 많아야
|bufsize-1|바이트를 읽되 줄바꿈을 만나면 그것까지 읽고 멈추며, 끝에 영 바이트를
둔다. 줄이 더 길면 나머지는 다음 줄이 된다. 이 판도 꼭 그렇게 읽는다.

@<플로어플랜을 읽는다@>=
for {
	@<|buf|에 한 줄을 읽는다; 입력이 끝났으면 |break|@>@;
	pos = 0
	@<방 |i|의 이름을 읽는다@>@;
	@<위 경계 |top[i]|의 이름을 읽는다@>@;
	@<아래 경계 |bot[i]|의 이름을 읽는다@>@;
	@<왼쪽 경계 |lft[i]|의 이름을 읽는다@>@;
	@<오른쪽 경계 |rt[i]|의 이름을 읽는다@>@;
}
fmt.Fprintf(os.Stderr, "(OK, I've read the specs for %d rooms, %d horizontal bounds,",
	rooms, hbounds)
fmt.Fprintf(os.Stderr, " %d vertical bounds)\n", vbounds)
if hbounds+vbounds != rooms+3 {
	reject("but those totals can't be right", "not h+v=r+3")
}

@ @<|buf|에 한 줄을 읽는다; 입력이 끝났으면 |break|@>=
k = 0
for k < bufsize-1 {
	c, err := in.ReadByte()
	if err != nil {
		break
	}
	buf[k] = c
	k++
	if c == '\n' {
		break
	}
}
if k == 0 {
	break
}
buf[k] = 0

@ 원본은 잘못된 줄을 \CEE/의 |"%s"|로 찍는다. 영 바이트 앞까지만 찍히고, 줄바꿈도
그대로 찍힌다. 이 판도 그렇게 찍으려고 작은 함수를 둔다.

@<함수들@>=
func cstring(s []byte) string {
	for i, c := range s {
		if c == 0 {
			return string(s[:i])
		}
	}
	return string(s)
}

@ 이름 하나를 읽는다. 빈칸을 건너뛰고, 보이는 \.{ASCII} 글자가 이어지는 동안 모은다.
원본은 이 일을 절 하나에 두고 다섯 곳에 끼워 넣는다. 여기서는 함수로 두었다.
돌려주는 것은 이름의 번호 |nameloc|과, 전에 본 이름이면 그 종류 |nametyp|이다.
처음 보는 이름이면 종류가 0이다.

이름이 일곱 자를 넘으면, 원본은 그때까지 모은 일곱 자를 찍고 멈춘다.

@<함수들@>=
func scanName() (nameloc, nametyp int) {
	for buf[pos] == ' ' {
		pos++
	}
	if buf[pos] < ' ' || buf[pos] > '~' {
		reject("input line must have five names", cstring(buf[:]))
	}
	start := pos
	for ; buf[pos] > ' ' && buf[pos] <= '~'; pos++ {
		if pos-start == 7 {
			reject("name longer than seven characters", string(buf[start:pos]))
		}
	}
	@<이름 |buf[start:pos]|를 찾거나 새로 넣는다@>@;
}

@ @<이름 |buf[start:pos]|를 찾거나 새로 넣는다@>=
s := string(buf[start:pos])
if loc, ok := where[s]; ok {
	return loc, typ[loc]
}
name, typ, inx = append(name, s), append(typ, 0), append(inx, 0)
if len(name) > maxnames {
	reject("too many names", "recompile?")
}
where[s] = len(name) - 1
return len(name) - 1, 0

@ 방의 이름은 처음 보는 것이어야 한다. 원본은 방이 |maxrooms|개를 넘는지 살피지
않는다. 이름이 |maxnames|개를 넘으면 멈추지만, 방들이 경계를 같이 쓰면 이름이 적어도
방은 많아질 수 있다. 그러면 배열 밖에 쓴다. 이 판은 거기서 멈춘다.

@<방 |i|의 이름을 읽는다@>=
nameloc, nametyp = scanName()
if nametyp != 0 {
	reject("duplicate room name", name[nameloc])
}
if rooms == maxrooms {
	reject("too many rooms", "recompile?")
}
i, room[rooms] = rooms, nameloc
rooms++
typ[nameloc], inx[nameloc] = 1, i

@ 가로 경계 $j$의 이름은 |name[hbound[j]]|이다. 그 위로 방 |len(tnbr[j])|개가,
아래로 방 |len(bnbr[j])|개가 붙어 있다. 그 이웃들이 |tnbr[j]|와 |bnbr[j]|에 있다.
원본은 이웃의 수를 따로 세지만 \GO/의 조각은 제 길이를 안다.

가로 경계가 |maxrooms+1|개를 넘는 것도 원본은 살피지 않는다. 올바른 플로어플랜이면
세로 경계가 둘 이상이니 그럴 수 없다.

@<위 경계 |top[i]|의 이름을 읽는다@>=
nameloc, nametyp = scanName()
if nametyp == 0 {
	@<새 가로 경계 |nameloc|을 만든다@>@;
} else if nametyp != 2 {
	reject("not a horizontal bound", name[nameloc])
}
j = inx[nameloc]
top[i] = j
bnbr[j] = append(bnbr[j], i)

@ @<새 가로 경계 |nameloc|을 만든다@>=
if hbounds == maxrooms+1 {
	reject("too many horizontal bounds", "recompile?")
}
typ[nameloc], inx[nameloc], hbound[hbounds] = 2, hbounds, nameloc
hbounds++

@ @<전역 변수@>=
var tnbr, bnbr [maxrooms + 1][]int

@ 원본은 높이가 0인 방을 알릴 때 방의 이름 대신 |name[i]|를 찍는다. 방 번호 |i|를
이름의 번호로 잘못 쓴 것이다. 이를테면 둘째 줄의 방이 높이가 0이면 첫 줄의 위
경계 이름을 찍는다. 이 판은 |name[room[i]]|를 찍는다.

@<아래 경계 |bot[i]|의 이름을 읽는다@>=
nameloc, nametyp = scanName()
if nametyp == 0 {
	@<새 가로 경계 |nameloc|을 만든다@>@;
} else if nametyp != 2 {
	reject("not a horizontal bound", name[nameloc])
}
j = inx[nameloc]
bot[i] = j
tnbr[j] = append(tnbr[j], i)
if bot[i] == top[i] {
	reject("room of zero height", name[room[i]])
}

@ 마찬가지로 세로 경계 $j$의 이름은 |name[vbound[j]]|이다. 그 왼쪽에 방
|len(lnbr[j])|개가, 오른쪽에 방 |len(rnbr[j])|개가 붙어 있다.

@<왼쪽 경계 |lft[i]|의 이름을 읽는다@>=
nameloc, nametyp = scanName()
if nametyp == 0 {
	@<새 세로 경계 |nameloc|을 만든다@>@;
} else if nametyp != 3 {
	reject("not a vertical bound", name[nameloc])
}
j = inx[nameloc]
lft[i] = j
rnbr[j] = append(rnbr[j], i)

@ @<새 세로 경계 |nameloc|을 만든다@>=
if vbounds == maxrooms+1 {
	reject("too many vertical bounds", "recompile?")
}
typ[nameloc], inx[nameloc], vbound[vbounds] = 3, vbounds, nameloc
vbounds++

@ @<전역 변수@>=
var lnbr, rnbr [maxrooms + 1][]int

@ 너비가 0인 방도 높이가 0인 방과 같은 결함이 있었다.

@<오른쪽 경계 |rt[i]|의 이름을 읽는다@>=
nameloc, nametyp = scanName()
if nametyp == 0 {
	@<새 세로 경계 |nameloc|을 만든다@>@;
} else if nametyp != 3 {
	reject("not a vertical bound", name[nameloc])
}
j = inx[nameloc]
rt[i] = j
lnbr[j] = append(lnbr[j], i)
if lft[i] == rt[i] {
	reject("room of zero width", name[room[i]])
}

@* 준비 단계.
이제 가로 경계와 세로 경계가 만나는 교차점들을 찾는다. 가로 경계는 모두 왼쪽 끝의
`$\vdash$' 교차점에서 오른쪽 끝의 `$\dashv$' 교차점까지 뻗는다. (맨 위와 맨 아래의
가로 경계는 꼭 그렇지 않지만, 플로어플랜의 모퉁이를 두 다른 종류의 교차점처럼
다룬다.)

교차점 $j$마다 그 북동, 남동, 남서, 북서에 붙은 방 가운데 둘을 정한다. 그 방들을
|ne[j]|, |se[j]|, |sw[j]|, |nw[j]|라 한다. `$\bot$'이면 |nw[j]|와 |ne[j]|만,
`$\dashv$'이면 |nw[j]|와 |sw[j]|만, `$\top$'이면 |sw[j]|와 |se[j]|만, `$\vdash$'이면
|ne[j]|와 |se[j]|만 정한다. 나머지 둘은 늘 알 수 있는 것도 아니고, 어차피 쓸 일이
없다.

플로어플랜을 둘러싼 빈 곳은 있지도 않은 번호 |rooms|의 방으로 친다. (그 방은 맨
바깥 모퉁이의 네 교차점에서만 나타난다.)

@ 전략은 아주 간단하다. 먼저 오른쪽 아래 모퉁이를 찾는다. 그다음 아는 `$\dashv$'
교차점마다 오른쪽에서 왼쪽으로, 아는 `$\bot$' 교차점마다 아래에서 위로 경계를 따라
가며, 새로 만나는 교차점의 짝을 찾는다.

물론 플로어플랜의 명세 가운데에는 불가능하거나 끊어져 있는 따위가 많다. 그런
이상은 가는 길에 알아채고 싶다.

@<교차점들을 찾는다@>=
@<오른쪽 아래의 방과 경계를 찾는다@>@;
@<아는 교차점에 이어진 경계를 하나씩 처리한다@>@;
@<방마다 제 모퉁이의 교차점을 가리키게 한다@>@;

@ @<오른쪽 아래의 방과 경계를 찾는다@>=
@<|i|를 가장 오른쪽 세로 경계의 번호로 둔다@>@;
@<|j|를 맨 아래 가로 경계의 번호로 둔다@>@;
@<|l|을 오른쪽 아래 방의 번호로 둔다@>@;

@ 오른쪽에 이웃이 없는 세로 경계가 가장 오른쪽 경계다.

@<|i|를 가장 오른쪽 세로 경계의 번호로 둔다@>=
for i, k = -1, 0; k < vbounds; k++ {
	if len(rnbr[k]) == 0 {
		if i >= 0 {
			reject2("both are rightmost", name[vbound[i]], name[vbound[k]])
		}
		i = k
	}
}
if i < 0 {
	pan("there's no rightmost bound")
}

@ 아래에 이웃이 없는 가로 경계가 맨 아래 경계다.

@<|j|를 맨 아래 가로 경계의 번호로 둔다@>=
for j, k = -1, 0; k < hbounds; k++ {
	if len(bnbr[k]) == 0 {
		if j >= 0 {
			reject2("both are at the bottom", name[hbound[j]], name[hbound[k]])
		}
		j = k
	}
}
if j < 0 {
	pan("there's no bottom line")
}

@ 원본은 오른쪽 아래 방이 둘일 때 둘째 방의 이름을
|name[room[rt[tnbr[j][k]]]]|로 찍는다. 그 방의 오른쪽 경계 번호를 방 번호로 잘못 쓴
것이다. 이 판은 |name[room[tnbr[j][k]]]|를 찍는다.

@<|l|을 오른쪽 아래 방의 번호로 둔다@>=
for l, k = -1, 0; k < len(tnbr[j]); k++ {
	if rt[tnbr[j][k]] == i {
		if l >= 0 {
			reject2("both are at bottom-right", name[room[l]], name[room[tnbr[j][k]]])
		}
		l = tnbr[j][k]
	}
}
if l < 0 {
	pan("there's no bottom-right room")
}

@ 교차점 0은 오른쪽 아래 모퉁이다. 맨 아래 가로 경계와 가장 오른쪽 세로 경계가
여기서 출발한다. 경계마다 그것이 출발한 교차점을 |hjunc|와 |vjunc|에 적고, 처리할
경계를 스택 |hstack|과 |vstack|에 쌓는다. 가로 경계를 먼저 처리한다.

교차점 배열의 크기는 입력을 다 읽은 뒤에 정한다. 올바른 플로어플랜의 교차점은
$2(h+v)-4=2r+2$개다. 경계의 양 끝이 교차점이고, 네 모퉁이에서만 두 끝이 겹치기
때문이다. 잘못된 입력이라도 뒤의 고침 덕분에 $2(h+v)$개를 넘지 않는다.

@<아는 교차점에 이어진 경계를 하나씩 처리한다@>=
@<교차점과 경계의 배열을 마련한다@>@;
nw[0], ne[0], sw[0] = l, rooms, rooms // 교차점 0에 닿은 방들
vjunc[i], hjunc[j] = 0, 0
jtyp[0], vstack, hstack = 0x8, []int{i}, []int{j}
jptr = 1
todo = hbounds + vbounds
for len(hstack)+len(vstack) > 0 {
	if len(hstack) > 0 {
		j, hstack = hstack[len(hstack)-1], hstack[:len(hstack)-1]
		@<가로 경계 |j|를 처리한다@>@;
	} else {
		i, vstack = vstack[len(vstack)-1], vstack[:len(vstack)-1]
		@<세로 경계 |i|를 처리한다@>@;
	}
	todo--
}
if todo != 0 {
	pan("disconnected floorplan")
}

@ 아직 출발하지 않은 경계는 |hjunc|와 |vjunc|가 $-1$이다.

@<교차점과 경계의 배열을 마련한다@>=
jmax := 2*(hbounds+vbounds) + 1
nw, ne, se, sw, jtyp = make([]int, jmax), make([]int, jmax), make([]int, jmax),
	make([]int, jmax), make([]int, jmax)
for k = 0; k < hbounds; k++ {
	hjunc[k] = -1
}
for k = 0; k < vbounds; k++ {
	vjunc[k] = -1
}

@ 이 시점에서 가로 경계 |j|의 오른쪽 끝은 `$\dashv$' 교차점 |hjunc[j]|임을 안다.
이제 그 이웃 목록을 다시 늘어놓고, 가는 길에 만나는 새 교차점들을 세운다.

@<가로 경계 |j|를 처리한다@>=
@<경계 |j| 바로 아래의 방들을 다시 늘어놓는다@>@;
@<경계 |j| 바로 위의 방들을 다시 늘어놓는다@>@;
@<경계 |j|의 왼쪽 끝에 `$\vdash$' 교차점을 세운다@>@;
@<경계 |j|에서 새 `$\bot$' 교차점들을 띄운다@>@;

@ 크누스는 이웃 목록을 다시 늘어놓을 때 가장 단순한 ``무식한'' 방법을 썼다. 그래서
이 단계는 이차 시간이 걸릴 수도 있다. 그러나 방을 대각선 순서로 입력하면 다시
늘어놓을 것이 없어서 알고리즘 전체가 선형 시간에 끝난다.

경계 아래의 방들을 오른쪽에서 왼쪽으로 줄 세운다. 가장 오른쪽 방 |l|은 이미 안다.
그다음 방은 오른쪽 경계가 방금 세운 방의 왼쪽 경계와 같은 방이다. 목록이 비어
있으면 $i=-1$에서 시작하니, 반복문이 한 번 돌면서 그 방을 찾지 못했다고 멈춘다.
원본도 그렇다.

@<경계 |j| 바로 아래의 방들을 다시 늘어놓는다@>=
l = sw[hjunc[j]] // |j| 아래의 가장 오른쪽 방
if l < rooms {
	for q, i = rt[l], len(bnbr[j])-1; i != 0; i-- {
		for k = 0; k <= i && rt[bnbr[j][k]] != q; k++ {
		}
		if k > i {
			reject2("can't find NE room", name[hbound[j]], name[vbound[q]])
		}
		bnbr[j][k], bnbr[j][i] = bnbr[j][i], bnbr[j][k]
		q = lft[bnbr[j][i]]
	}
}

@ @<경계 |j| 바로 위의 방들을 다시 늘어놓는다@>=
l = nw[hjunc[j]] // |j| 위의 가장 오른쪽 방
if l < rooms {
	for q, i = rt[l], len(tnbr[j])-1; i != 0; i-- {
		for k = 0; k <= i && rt[tnbr[j][k]] != q; k++ {
		}
		if k > i {
			reject2("can't find NW room", name[hbound[j]], name[vbound[q]])
		}
		tnbr[j][k], tnbr[j][i] = tnbr[j][i], tnbr[j][k]
		q = lft[tnbr[j][i]]
	}
}

@ 여기서 미묘한 일이 생긴다. |j|가 맨 아래 가로 경계이면 맨 왼쪽의 세로 경계를
띄워야 한다. (이것은 |jptr=1|일 때, 그리고 그때에만 일어난다. 처음에 그 가로 경계를
스택에 먼저 쌓았기 때문이다.)

맨 위의 가로 경계는 가장 오른쪽 세로 경계가 띄운다. 맨 왼쪽 세로 경계는 위쪽
끝에서 왼쪽 위 모퉁이 |tlc|를 정한다. 맨 위의 가로 경계를 처리할 때는 왼쪽 위
모퉁이에 교차점을 또 만들면 안 된다.

원본은 위에 방이 없어도 |tnbr[j][0]|을 읽는다. \CEE/의 배열에서는 그 자리의 지난
값을 읽을 뿐이고, 그 값은 쓰이지 않는다. 이 판은 읽지 않는다.

@<경계 |j|의 왼쪽 끝에 `$\vdash$' 교차점을 세운다@>=
if len(tnbr[j]) == 0 {
	if bnbr[j][0] != se[tlc] {
		pan("this can't happen")
	}
} else {
	ne[jptr] = tnbr[j][0]
	if len(bnbr[j]) == 0 {
		se[jptr], nw[jptr], jtyp[jptr] = rooms, rooms, 0x4
		launchV(lft[ne[jptr]])
	} else {
		se[jptr], jtyp[jptr] = bnbr[j][0], 0x6
	}
	jptr++
}

@ 위에 방이 $k$개 있으면 교차점 $k-1$개를 띄우고, 그에 해당하는 세로 경계들을
|vstack|에 쌓는다.

@<경계 |j|에서 새 `$\bot$' 교차점들을 띄운다@>=
for k = 1; k < len(tnbr[j]); k++ {
	launchV(lft[tnbr[j][k]])
	nw[jptr], ne[jptr], jtyp[jptr] = tnbr[j][k-1], tnbr[j][k], 0xc
	jptr++
}

@ 경계는 지금의 교차점 |jptr|에서 출발한다. 올바른 플로어플랜에서는 경계마다 출발점이
하나뿐이다. 가로 경계는 오른쪽 끝에서, 세로 경계는 위쪽 끝에서만 출발하기 때문이다.

원본은 같은 경계가 두 번 출발해도 살피지 않는다. 그러면 그 경계를 두 번 처리하며
교차점을 거듭 만든다. 대개는 나중에 다른 모순으로 멈추지만, 엉뚱한 나무를 내놓거나
죽기도 한다. 이 판은 두 번째로 출발하려는 경계를 만나면 멈춘다. 그래서 경계는
저마다 많아야 한 번 처리되고, 교차점은 $2(h+v)$개를 넘지 않는다. 이 말은 이 판에서
지은 것이다.

@<함수들@>=
func launchV(q int) {
	if vjunc[q] >= 0 {
		pan("a bound was launched twice")
	}
	vjunc[q] = jptr
	vstack = append(vstack, q)
}
@#
func launchH(q int) {
	if hjunc[q] >= 0 {
		pan("a bound was launched twice")
	}
	hjunc[q] = jptr
	hstack = append(hstack, q)
}

@ 세로 경계도 같은 방식으로 다룬다. 가로와 세로만 맞바꾸면 된다.

@<세로 경계 |i|를 처리한다@>=
@<경계 |i| 바로 오른쪽의 방들을 다시 늘어놓는다@>@;
@<경계 |i| 바로 왼쪽의 방들을 다시 늘어놓는다@>@;
@<경계 |i|의 위쪽 끝에 `$\top$' 교차점을 세운다@>@;
@<경계 |i|에서 새 `$\dashv$' 교차점들을 띄운다@>@;

@ @<경계 |i| 바로 오른쪽의 방들을 다시 늘어놓는다@>=
l = ne[vjunc[i]] // |i| 오른쪽의 가장 아래 방
if l < rooms {
	for q, j = bot[l], len(rnbr[i])-1; j != 0; j-- {
		for k = 0; k <= j && bot[rnbr[i][k]] != q; k++ {
		}
		if k > j {
			reject2("can't find SW room", name[hbound[q]], name[vbound[i]])
		}
		rnbr[i][k], rnbr[i][j] = rnbr[i][j], rnbr[i][k]
		q = top[rnbr[i][j]]
	}
}

@ @<경계 |i| 바로 왼쪽의 방들을 다시 늘어놓는다@>=
l = nw[vjunc[i]] // |i| 왼쪽의 가장 아래 방
if l < rooms {
	for q, j = bot[l], len(lnbr[i])-1; j != 0; j-- {
		for k = 0; k <= j && bot[lnbr[i][k]] != q; k++ {
		}
		if k > j {
			reject2("can't find SE room", name[hbound[q]], name[vbound[i]])
		}
		lnbr[i][k], lnbr[i][j] = lnbr[i][j], lnbr[i][k]
		q = top[lnbr[i][j]]
	}
}

@ 맨 왼쪽 세로 경계의 위쪽 끝은 왼쪽 위 모퉁이 |tlc|이고, 가장 오른쪽 세로 경계의
위쪽 끝은 오른쪽 위 모퉁이다. 맨 위의 가로 경계는 오른쪽 위 모퉁이에서 출발한다.

@<경계 |i|의 위쪽 끝에 `$\top$' 교차점을 세운다@>=
if len(lnbr[i]) == 0 {
	se[jptr], sw[jptr], ne[jptr] = rnbr[i][0], rooms, rooms
	tlc, jtyp[jptr] = jptr, 0x2
} else if len(rnbr[i]) == 0 {
	sw[jptr], se[jptr], nw[jptr], jtyp[jptr] = lnbr[i][0], rooms, rooms, 0x1
	launchH(top[sw[jptr]])
} else {
	sw[jptr], se[jptr], jtyp[jptr] = lnbr[i][0], rnbr[i][0], 0x3
}
jptr++

@ 왼쪽에 방이 $k$개 있으면 교차점 $k-1$개를 띄우고, 그에 해당하는 가로 경계들을
|hstack|에 쌓는다.

@<경계 |i|에서 새 `$\dashv$' 교차점들을 띄운다@>=
for k = 1; k < len(lnbr[i]); k++ {
	launchH(top[lnbr[i][k]])
	nw[jptr], sw[jptr], jtyp[jptr] = lnbr[i][k-1], lnbr[i][k], 0x9
	jptr++
}

@ 끝으로 교차점마다 제가 아는 방들에게 자기를 알린다.

@<방마다 제 모퉁이의 교차점을 가리키게 한다@>=
@<방의 모퉁이 배열을 마련한다@>@;
for k = 0; k < jptr; k++ {
	q = jtyp[k]
	if q&0x1 != 0 {
		tr[sw[k]] = k
	}
	if q&0x2 != 0 {
		tl[se[k]] = k
	}
	if q&0x4 != 0 {
		bl[ne[k]] = k
	}
	if q&0x8 != 0 {
		br[nw[k]] = k
	}
}

@ @<방의 모퉁이 배열을 마련한다@>=
tl, tr, bl, br = make([]int, rooms), make([]int, rooms), make([]int, rooms),
	make([]int, rooms)

@ 교차점의 종류 |jtyp|는 비트로 적는다. 비트 |0x1|은 남서에, |0x2|는 남동에,
|0x4|는 북동에, |0x8|은 북서에 방이 있다는 뜻이다. 그래서 $|0x3|=\top$,
$|0xc|=\bot$, $|0x6|=\vdash$, $|0x9|=\dashv$이고, 모퉁이는 비트가 하나뿐이다.

@<전역 변수@>=
var (
	hjunc, vjunc   [maxrooms + 1]int
	hstack, vstack []int // 처리할 경계들
	jptr           int   // 지금까지 본 교차점의 수
	jtyp           []int
	nw, ne, se, sw []int
	tl, tr, bl, br []int // 방의 왼쪽 위, 오른쪽 위, 왼쪽 아래, 오른쪽 아래 교차점
	tlc            int   // 왼쪽 위 모퉁이의 교차점
)

@* 멋진 단계.
이제 쌍둥이 나무를 세울 준비가 되었다. Bo~Yao, Hongyu~Chen, Chung-Kuan Cheng,
Ronald Graham이 {\sl ACM Transactions on Design Automation of Electronic
Systems\/ \bf8} (2003), 55--80에서 찾아낸 놀랍도록 간단한 방법을 다시 꾸민 것이다.

방 $k$의 왼쪽 위 모퉁이가 `$\top$'이면 그 남서의 방이 $l_1[k]$가 되고, 아니면 그
북동의 방이 $l_0[k]$가 된다. 오른쪽 아래 모퉁이가 `$\dashv$'이면 그 남서의 방이
$r_1[k]$가 되고, 아니면 그 북동의 방이 $r_0[k]$가 된다. $T_0$의 뿌리는 왼쪽 아래
방이고, $T_1$의 뿌리는 오른쪽 위 방이다.

크누스의 말로는, 이 구성을 보면 앞의 배열들 가운데 많은 것이 군더더기라서 애써
계산할 필요도 없었다.

@<쌍둥이 나무를 만든다@>=
null = rooms
l0, r0, l1, r1 = make([]int, rooms), make([]int, rooms), make([]int, rooms),
	make([]int, rooms)
for k = 0; k < rooms; k++ {
	if j = tl[k]; jtyp[j] == 0x3 {
		l0[k], l1[k] = null, sw[j]
	} else {
		l0[k], l1[k] = ne[j], null
	}
	if j = br[k]; jtyp[j] == 0x9 {
		r0[k], r1[k] = null, sw[j]
	} else {
		r0[k], r1[k] = ne[j], null
	}
}
root0, root1 = ne[1], sw[tlc+1]

@ @<전역 변수@>=
var (
	root0, root1   int
	l0, r0, l1, r1 []int
	null           int // 널 방
)

@* 확인 단계.
원본은 잘못된 명세를 가는 길에 알아채려 하지만, 다 알아채지는 못한다. 받아들인
명세가 실제로는 플로어플랜이 아니면, 원본은 쌍둥이 나무가 아닌 것을 찍거나,
다른 플로어플랜의 쌍둥이 나무를 찍는다. 링크가 고리를 이루면 대칭 순서로 훑는
재귀가 끝나지 않아 스택이 넘쳐 죽는다. 그래서 나는 찍기 전에 결과를 확인한다.

확인은 두 가지다. (a)~만든 것이 쌍둥이 나무여야 한다. 두 나무를 대칭 순서로 훑으면
모든 방을 꼭 한 번씩, 같은 차례로 지나야 하고, 그 차례로 마지막이 아닌 방 $k$마다
$r_0[k]$와 $r_1[k]$ 가운데 꼭 하나만 널이 아니어야 한다. (b)~링크마다 입력의
경계와 맞아야 한다. $l_0[k]=a$이면 $a$가 $k$의 왼쪽 위 모퉁이에서 $k$의 위에
있으니 $|bot|[a]=|top|[k]$이고 $|lft|[a]=|lft|[k]$다. 마찬가지로 $l_1[k]=b$이면
$|rt|[b]=|lft|[k]$이고 $|top|[b]=|top|[k]$, $r_0[k]=c$이면 $|lft|[c]=|rt|[k]$이고
$|bot|[c]=|bot|[k]$, $r_1[k]=d$이면 $|top|[d]=|bot|[k]$이고 $|rt|[d]=|rt|[k]$다.

@ 이 둘로 충분한 까닭은 이렇다. (a)를 통과한 쌍둥이 나무 $T$에는 그것을 쌍둥이
나무로 갖는 플로어플랜 $F$가 꼭 하나 있다. 삼부작이 보이는 전단사가 그것이다. $F$의
경계마다, 그 경계에 붙은 방들은 (b)의 등식들로 모두 이어진다. 이를테면 가로 경계
아래의 이웃한 두 방은 그 사이의 `$\top$' 교차점이 주는 $l_1$ 링크로 이어지고, 위의
이웃한 두 방은 `$\bot$' 교차점이 주는 $r_0$ 링크로 이어진다. 위와 아래는 왼쪽 끝의
`$\vdash$'가 주는 $l_0$ 링크로 이어진다. 세로 경계도 같다. 그러니 입력이 (b)를
만족하면 입력의 경계 하나하나는 $F$의 경계 여럿을 합친 것이다. 그런데 입력은 이미
$h+v=r+3$을 통과했고 $F$도 그렇다. 경계의 수가 같으니 합친 것이 없다. 곧 입력은
$F$ 바로 그것이고, $T$가 그 쌍둥이 나무다. 거꾸로 올바른 입력은 그 쌍둥이 나무를
낳으니 (a)와 (b)를 모두 통과한다.

@<쌍둥이 나무가 입력과 맞는지 살핀다@>=
order0, order1 := symorder(root0, l0, r0), symorder(root1, l1, r1)
if len(order0) != rooms || len(order1) != rooms {
	pan("inconsistent floorplan")
}
for k = 0; k < rooms; k++ {
	if order0[k] != order1[k] {
		pan("inconsistent floorplan")
	}
	if q = order0[k]; k < rooms-1 && (r0[q] == null) == (r1[q] == null) {
		pan("inconsistent floorplan")
	}
}
@<링크마다 입력의 경계와 맞는지 본다@>@;

@ 대칭 순서로 훑는 함수는 두 나무에 쓴다. 고리가 있어도 끝나도록 재귀 대신
스택으로 훑고, 같은 방을 두 번 만나면 |nil|을 돌려준다.

@<함수들@>=
func symorder(root int, l, r []int) []int {
	var order, stack []int
	seen := make([]bool, null)
	for p := root; p != null || len(stack) > 0; {
		if p != null {
			if seen[p] {
				return nil
			}
			seen[p] = true
			stack, p = append(stack, p), l[p]
		} else {
			p, stack = stack[len(stack)-1], stack[:len(stack)-1]
			order, p = append(order, p), r[p]
		}
	}
	return order
}

@ @<링크마다 입력의 경계와 맞는지 본다@>=
for k = 0; k < rooms; k++ {
	if a := l0[k]; a != null && (bot[a] != top[k] || lft[a] != lft[k]) {
		pan("inconsistent floorplan")
	}
	if b := l1[k]; b != null && (rt[b] != lft[k] || top[b] != top[k]) {
		pan("inconsistent floorplan")
	}
	if c := r0[k]; c != null && (lft[c] != rt[k] || bot[c] != bot[k]) {
		pan("inconsistent floorplan")
	}
	if d := r1[k]; d != null && (top[d] != bot[k] || rt[d] != rt[k]) {
		pan("inconsistent floorplan")
	}
}

@* 출력 단계.
널 방의 이름은 `\.{/\\}'로 둔다. 이름은 여덟 칸에 오른쪽으로 맞춰 찍는다.

@<쌍둥이 나무를 찍는다@>=
room[rooms], name = len(name), append(name, `/\`)
fmt.Fprintf(out, "T0 (rooted at %s)\n", name[room[root0]])
inorder(root0, l0, r0)
fmt.Fprintf(out, "T1 (rooted at %s)\n", name[room[root1]])
inorder(root1, l1, r1)

@ 나무를 대칭 순서로 훑으며 마디마다 한 줄을 찍는다. 원본은 두 나무에 같은 모양의
함수를 하나씩 두지만, 여기서는 링크 배열을 받는 함수 하나로 두 나무를 다 훑는다.
앞에서 확인했으니 고리는 없다.

@<함수들@>=
func inorder(root int, l, r []int) {
	if l[root] != null {
		inorder(l[root], l, r)
	}
	fmt.Fprintf(out, "%8s: %8s, %8s\n",
		name[room[root]], name[room[l[root]]], name[room[r[root]]])
	if r[root] != null {
		inorder(r[root], l, r)
	}
}

@* 옮기며 고친 것.
원본의 결함은 다섯이었다. 저마다 그 자리에서 이야기했으니 여기서는 모아만 둔다.

\smallskip
\item{$\bullet$} 높이나 너비가 0인 방을 알릴 때 방의 이름 대신 엉뚱한 이름을 찍는다.
\item{$\bullet$} 오른쪽 아래 방이 둘일 때 둘째 방의 이름 대신 엉뚱한 이름을 찍는다.
\item{$\bullet$} 방이나 경계가 한도를 넘는지 살피지 않아 배열 밖에 쓴다. 이를테면
방 $1100$개가 모두 같은 네 경계를 쓰면 \.{UndefinedBehaviorSanitizer}가 이웃
목록 밖에 쓰는 것을 잡는다.
\item{$\bullet$} 같은 경계가 두 번 출발해도 살피지 않는다.
\item{$\bullet$} 받아들인 명세가 플로어플랜인지 끝까지 확인하지 않는다. 그래서 쌍둥이
나무가 아닌 것을 찍거나, 다른 플로어플랜의 쌍둥이 나무를 조용히 찍거나, 스택이 넘쳐
죽는다.
\smallskip

\noindent 원본의 |main|은 `\.{void main()}'이라 제대로 끝나도 종료 부호가 정해지지
않는다. 이 판은 0을 돌려준다.

새로 지은 말은 다섯이다. 한도를 넘으면 ``\.{too many rooms}'', ``\.{too many
horizontal bounds}'', ``\.{too many vertical bounds}''를 종료 부호 $-666$과 함께,
경계가 두 번 출발하면 ``\.{a bound was launched twice}''를, 확인 단계에서
걸리면 ``\.{inconsistent floorplan}''을 종료 부호 $-66$과 함께 낸다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀어 컴파일하고 이 판과 견주었다. (요즘의 \.{clang}은 원본을
받아 주지 않아서 \.{-std=gnu89}로 컴파일했다.) 삼부작의 나머지 두 원본도 함께
컴파일했다. 변경 파일을 적용한 것과 적용하지 않은 것을 따로 견주었다.

\smallskip
\item{$\bullet$} 크기 8까지의 백스터 순열 $13373$개를 모두 삼부작에 한 바퀴 돌렸다.
{\mc BAXTER-TO-FLOORPLAN}으로 플로어플랜을 만들고, 변경 파일을 적용한 이 프로그램으로
쌍둥이 나무를 만들고, {\mc TWINTREE-TO-BAXTER}로 다시 백스터 순열을 얻었다. 원본으로
돌려도 이 판으로 돌려도 모두 처음 순열로 돌아왔다. 크기별 개수 1, 2, 6, 22, 92, 422,
2074, 10754는 백스터 수와 같다.
\item{$\bullet$} {\mc BAXTER-TO-FLOORPLAN}은 방을 대각선 순서로 내놓으니, 그대로
넣으면 다시 늘어놓는 코드가 돌지 않는다. 그래서 크기 7까지의 플로어플랜 $2619$개마다
줄의 차례를 두 번씩 뒤섞어 넣었다. 모두 $7857$번이고, 두 형식 모두 출력이 원본과
바이트까지 같았다.
\item{$\bullet$} 큰 플로어플랜은 무작위 순열에서 만들었다. 순열을 이진 탐색 나무에
앞에서부터 넣고 뒤에서부터 넣으면 쌍둥이 나무가 된다. 그것을
{\mc TWINTREE-TO-BAXTER}와 {\mc BAXTER-TO-FLOORPLAN}에 차례로 넣고 줄을 뒤섞었다.
방이 1024개까지인 것 $540$개에서 출력이 원본과 같았고, 한 바퀴 돌리면 같은 백스터
순열로 돌아왔다.
\item{$\bullet$} 잘못된 입력은 $60000$개를 만들었다. 절반은 크기 7까지의 플로어플랜을
망가뜨린 것이다. 경계 이름을 바꾸고, 줄을 빼거나 겹쳐 넣고, 위와 아래를 맞바꾸는
식이다. 나머지 절반은 $h+v=r+3$만 맞춘 무작위 명세다. 받아들인 명세가 정말
플로어플랜인지는 원본과 따로 판정했다. 내놓은 쌍둥이 나무를 한 바퀴 돌려 얻은
플로어플랜이 입력과 이름만 다르고 같은지를 보는 것이다.

이 판은 플로어플랜만 받아들였다. 원본이 플로어플랜이라며 받아들인 것은 모두 이 판도
받아들였고, 출력이 바이트까지 같았다. 둘 다 원본의 말로 거절한 것은 그 말이 같았다.
(원본의 이름 결함 둘을 고친 \CEE/ 판과 견준 것이다.) 이 판만 새 말로 거절한 것은
$1009$개다. 그 가운데 $142$개는 원본이 잘못된 명세를 받아들여 엉뚱한 출력을 낸
것이고, $44$개는 원본이 스택이 넘쳐 죽은 것이며, 나머지 $823$개는 원본도 나중에 다른
말로 거절한 것이다.
\item{$\bullet$} 원본을 \.{AddressSanitizer}와 \.{UndefinedBehaviorSanitizer}를 붙여
돌리면, 고리가 있는 결과에서 스택 넘침을, 방 $1100$개가 같은 경계를 쓰는 입력에서
배열 밖 쓰기를 잡는다. 이 판은 그 두 입력을 ``\.{a bound was launched twice}''와
``\.{too many rooms}''로 거절한다.
\smallskip

@* 색인.
