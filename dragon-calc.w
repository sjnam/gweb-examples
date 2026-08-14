@i types.w
@s pair int
@s scanner int

\input kotexgweb
\input pic

\def\title{용 곡선 계산기}
\font\logo=logo10
\datethis

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}
% 명령 목록의 한 항목. 첫 인자는 명령의 꼴, 나머지는 설명.
\def\thing#1#2\par{\smallskip\item{$\bullet$}#1\hfil\break#2\par}
\def\<#1>{\hbox{$\langle\,$#1$\,\rangle$}}

@* 들어가며.
종이띠를 반으로 접고, 접힌 것을 또 반으로 접고, 그렇게 $n$번 접은 다음 모든 접힌
자리를 직각으로 펴 보라. 자를 대고 그린 적도 없는데 {\it 용 곡선\/}(dragon curve)이
나온다. 접힌 자리를 왼쪽 순서대로 적으면 \.D와 \.U로 된 열이 되는데, 그 열이 곧
곡선이다. 이 프로그램은 그런 {\it 접기열\/}과 그것이 그리는 경로를 가지고 노는
대화식 계산기다.
$$
\pic{dragon-calc-1.pdf}
$$
\figcap{그림 1: 접을수록 자라는 용. 위는 차수 $1$부터 $5$까지고, 아래는 차수
$12$다. 차수 $n$의 용은 선분 $2^n$개로 되어 있다. 한 번 더 접으면 앞 차수의
접기열이 바로 놓인 사본과 뒤집힌 사본으로 되풀이되는데, 그 되풀이가 이 프로그램의
{\it 접기 곱\/}이다. 프로그램으로는 \.{p0} 다음에 \.{*D}를 $n$번 하면 나온다.}

바탕이 되는 이론은 Dekking이 일반화한 용 곡선과 거기 딸린 {\it 타일 계산\/}이고,
Knuth의 노트 ``다이아몬드와 용''(diamonds and dragons)에 나온다. 프로그램 자체는
Knuth가 2010년 9월에 \.{CWEB}으로 쓴 \.{dragon-calc.w}인데, 나는 그것을 \GO/로
옮기면서 한글로 다시 썼다. 원본 끝에 그는 이렇게 적어 두었다: ``맡은 일이 많아
이 프로그램을 몹시 서둘러 써야 했음을 헤아려 주시기 바랍니다.'' 서두른 자리가
군데군데 보이길래 몇 곳은 손을 보았고, 그럴 때마다 어디를 왜 고쳤는지 밝혀 두었다.

@ 프로그램은 물음표 대신 \.{>}를 내밀고 명령을 기다린다. 할 수 있는 일은 다음과 같다.

\thing{\.p\<경로>}
  현재 지그재그 경로를 \<경로>가 말하는 방향열로 정한다. 방향은 숫자 \.0, \.1,
  \.2, \.3이고 차례대로 ``오른쪽,'' ``위,'' ``왼쪽,'' ``아래''를 뜻한다. 방향열은
  반드시 \.0으로 시작하고 짝홀이 번갈아야 한다. 그러면 컴퓨터가 $z$를 알려 주는데,
  이는 복소평면의 $0$에서 떠나 방향~$k$마다 $i^k$만큼 움직였을 때 다다르는 끝점이다.
  이를테면 \.{p01012}는 $z=1+2i$를 준다. 처음 경로는 그냥 \.0이고, $z=1$이다.

\thing{\<접기열>}
  현재 경로를 \<접기열>이 말하는 것으로 정한다. \.D와 \.U로 된 열이다. 길이가
  $s-1$인 접기열은 길이가 $s$인 경로에 대응한다. 방향~$0$에서 떠나 \.D마다 방향을
  $+1$, \.U마다 $-1$(mod~$4$)만큼 튼다. 이를테면 \.{DUDD}는 \.{p01012}와 같다.
  (역사가 남긴 짐을 사과드린다. 이 표기에서는 {\it 아래로\/} 접는 \.D가 실제
  방향은 {\it 위로\/} 틀게 한다.)

\thing{\.*\<경로> 또는 \.*\<접기열>}
  현재 경로에 주어진 경로나 접기열을 Dekking의 {\it 접기 곱\/}으로 곱한다. 현재
  경로가 \.{01012}일 때 \.{*03}이나 \.{*U}는 그것을 \.{0101210303}으로 바꾸고
  $z\gets3+i$로 만든다.

\thing{\<타일>\.*\<타일>}
  타일 둘의 접기 곱을 지금의 $z$에 대하여 셈한다. \<타일>은 쉼표로 나눈 정수 둘이다.
  이를테면 $z=1+2i$일 때 \.{3,2*-2,3}은 \.{-8,1}을 준다. $(3+2i)*(-2+3i)=
  i(3+2i)+z(-2+2i)=-8+i$이기 때문이다.

\thing{\.{a*}\<타일>}
  현재 경로의 폴리오미노에 든 모든 타일 $v$와 주어진 타일 $w$의 곱 $v*w$를 셈한다.
  특히 \.{1,0}을 주면 폴리오미노의 타일을 모두 늘어놓는 셈이 된다.

\thing{\.c\<타일> 또는 \.c}
  주어진 타일의 합동류와 형을 보인다. 타일을 주지 않으면 현재 폴리오미노에 든
  타일 모두의 합동류와 형을 보인다.

\thing{\.f\<타일> 또는 \.F\<타일>}
  주어진 타일 $u$를 ``인수분해''하여 $u=v*w$가 되는 $v$와 $w$를 찾는다. 여기서 $v$는
  현재 폴리오미노의 타일이다. \.f 대신 \.F를 쓰면 되돌이에 들어설 때까지 $w$를
  같은 방식으로 계속 쪼갠다. 현재 경로가 판을 채울 때만 쓸 수 있는 명령이다.

\thing{\.m}
  현재 경로를 그리는 {\logo METAPOST} 명령을 뱉는다.

\thing{\.v\<정수>}
  말수를 정한다. \.{v0}이 가장 조용하고 \.{v-1}이 가장 수다스럽다.

\thing{\.q}
  프로그램을 그만둔다.

\thing{\.{\char`\%}\<주석>}
  아무 일도 하지 않되, 주어진 주석을 공손히 헤아려 본다.

\thing{\.i\<파일이름>}
  주어진 파일에서 명령을 읽어 실행하고 돌아온다(그 파일에 ``그만'' 명령이 없다면).
  파일 안에는 \.i를 뺀 아무 명령이나 올 수 있다. 포함한 파일을 쌓아 두는 수고는
  하고 싶지 않았다.

@ 뼈대는 이렇다. 명령을 한 줄씩 받아 알아듣고 시키기를 되풀이할 뿐이다. 되풀이에
|commands|라는 이름표를 달아 두는 것이 요긴하다. 명령 하나를 처리하다 그만두려면
안쪽 어디에서든 |break commands|, 다음 명령으로 넘어가려면 |continue commands|라고
쓰면 되기 때문이다. 원본은 이 노릇을 |goto|와 이름표 예닐곱 개로 했는데, 그중에는
반복문 {\it 안으로\/} 뛰어드는 것도 있다.
@c
package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
)

@<상수@>
@<자료 구조@>
@<전역 변수@>
@<함수들@>

func main() {
	reset()
	stdin := bufio.NewScanner(os.Stdin)
	var incl *bufio.Scanner
commands:
	for {
		var line string
		@<명령 한 줄을 받는다@>@;
		sc := &scanner{buf: line}
		@<명령을 알아보고 시킨다@>@;
		@<줄 끝에 남은 것을 나무란다@>@;
	}
	@<{\logo METAPOST} 파일을 닫는다@>@;
}

@* 명령 알아듣기.
명령은 표준 입력에서 오거나, \.i로 포함한 파일에서 온다. 포함한 파일이 동나면
|incl|을 비워 다시 사람에게 묻는다. 표준 입력이 동나는 것(\.{Ctrl-D})은 \.q와 같이
친다---원본은 이 경우를 살피지 않아 빈 명령을 끝없이 되풀이한다.

@<명령 한 줄을 받는다@>=
	if incl != nil {
		if !incl.Scan() {
			incl = nil
			continue
		}
		line = incl.Text()
		if vbose&echoIncl != 0 {
			fmt.Println(line)
		}
	} else {
		fmt.Print("> ")
		if !stdin.Scan() {
			break commands
		}
		line = stdin.Text()
	}

@ 명령을 읽는 일은 모두 |scanner| 하나가 맡는다. 줄 하나와 다음에 읽을 자리만
들고 있으면 되니 단출하다.

@<자료 구조@>=
type scanner struct {
	buf string // 명령 한 줄
	p   int    // 다음에 읽을 자리
}

@ 글자 하나를 다루는 잔손질들. 줄 끝을 넘어가면 |peek|은 $0$을 돌려주므로, 어느
검사도 줄 밖으로 나갈 걱정이 없다. C판이 |'\n'|을 파수꾼으로 삼은 자리를 여기서는
이 $0$이 대신한다.

@<함수들@>=
func (sc *scanner) eof() bool { return sc.p >= len(sc.buf) }

func (sc *scanner) peek() byte {
	if sc.eof() {
		return 0
	}
	return sc.buf[sc.p]
}

func (sc *scanner) get() byte {
	c := sc.peek()
	if c != 0 {
		sc.p++
	}
	return c
}

func (sc *scanner) skip() {
	for sc.peek() == ' ' {
		sc.p++
	}
}

func (sc *scanner) rest() string { return sc.buf[sc.p:] }

@ 정수 하나를 읽는다. 부호는 앞에 붙은 빼기표 하나로 족하다.

@<함수들@>=
func (sc *scanner) num() int64 {
	sc.skip()
	neg := sc.peek() == '-'
	if neg {
		sc.p++
	}
	var k int64
	for c := sc.peek(); c >= '0' && c <= '9'; c = sc.peek() {
		k = 10*k + int64(c-'0')
		sc.p++
	}
	if neg {
		return -k
	}
	return k
}

@ 반드시 있어야 할 글자를 확인하고, 없으면 알아듣지 못했다고 말한다. 어디서 걸렸는지는
따로 밝히지 않아도 된다. 읽던 자리가 그대로 남으므로 줄 끝 검사가 남은 것을 고스란히
보여 주기 때문이다.

@<함수들@>=
func (sc *scanner) must(c byte) bool {
	sc.skip()
	if sc.peek() != c {
		fmt.Println("무슨 말씀인지 모르겠다!")
		return false
	}
	sc.p++
	return true
}

@ 타일 하나는 쉼표로 나눈 정수 둘이다. 타일이 되려면 두 좌표의 합이 홀수여야 하는데,
왜 그런지는 타일을 이야기할 때 밝힌다.

@<함수들@>=
func (sc *scanner) tile() (pair, bool) {
	var v pair
	v.x = sc.num()
	if !sc.must(',') {
		return v, false
	}
	v.y = sc.num()
	if (v.x+v.y)&1 == 0 {
		fmt.Printf("타일이 아니다: %d,%d\n", v.x, v.y)
		return v, false
	}
	return v, true
}

@ 이제 첫 글자를 보고 갈 길을 정한다. 이 |switch| 하나가 프로그램의 지도인 셈이다.
명령을 알아듣지 못했거나 도중에 걸렸으면 |break|로 |switch|를 빠져나가는데, 그러면
줄 끝 검사까지는 그대로 거친다. C의 |switch| 안 |break|가 하던 일과 똑같다.

@<명령을 알아보고 시킨다@>=
	sc.skip()
	if sc.eof() {
		if incl == nil {
			fmt.Println("명령을 입력하시라. 그만두려면 q.")
		}
		continue
	}
	switch sc.peek() {
	case 'q':
		break commands
	case '%':
		continue
	case 'i':
		@<파일에서 명령을 읽어 온다@>@;
	case 'v':
		sc.get()
		vbose = int(sc.num())
	@<나머지 명령들@>@;
	}

@ 말수는 비트 세 개로 정한다. \.{v-1}이면 모든 비트가 서므로 가장 수다스럽다.

@<상수@>=
const (
	echoIncl  = 1 << 0 // 포함한 파일의 명령을 되울릴까?
	tellFolds = 1 << 1 // 방향을 받으면 접기열도 보일까?
	tellDirs  = 1 << 2 // 접기열을 받으면 방향도 보일까?
)

@ @<전역 변수@>=
var vbose int // 말수

@ 파일 하나를 통째로 읽어 |incl|에 걸어 둔다. 원본은 파일 손잡이를 들고 다니며
닫을 때를 살펴야 했지만, 통째로 읽어 두면 그럴 일이 없다.

@<파일에서 명령을 읽어 온다@>=
	if incl != nil {
		fmt.Println("파일 안에서 또 파일을 부를 수는 없다.")
		continue
	}
	sc.get()
	sc.skip()
	name := sc.rest()
	data, err := os.ReadFile(name)
	if err != nil {
		fmt.Printf("파일 `%s'를 읽을 수 없다!\n", name)
		continue
	}
	incl = bufio.NewScanner(bytes.NewReader(data))
	continue

@ 명령 하나를 다 처리하고도 줄에 무엇이 남아 있으면 알려 준다. 잘못 친 명령이
어디서 걸렸는지 이 줄이 일러 준다.

@<줄 끝에 남은 것을 나무란다@>=
	sc.skip()
	if !sc.eof() {
		fmt.Printf("명령 뒤에 남은 것은 무시했다: %s\n", sc.rest())
	}

@* 지그재그 경로.
경로는 길이가 $s$인 방향열 $d_0d_1\ldots d_{s-1}$이다. 방향 $k$는 복소평면에서
$i^k$만큼 움직이는 것을 뜻하니, 끝점은
$$z=\sum_{k=0}^{s-1}i^{d_k}$$
이다. 방향은 $d_0=0$에서 시작해 짝홀이 번갈아야 한다. 즉 가로, 세로, 가로,
세로\dots 로 지그재그다.

같은 것을 {\it 접기열\/}로도 적을 수 있다. $f_k$는 $d_k$에서 $d_{k+1}$로 트는
방향이라, \.D면 $+1$, \.U면 $-1$이다(mod~$4$). 방향이 $s$개면 트는 자리는 $s-1$개이므로
접기열의 길이는 $s-1$이다. 두 표현은 서로 오갈 수 있고, 프로그램은 늘 둘 다 들고
있는다.

@<전역 변수@>=
var (
	dir []byte // 현재 경로의 방향들 (0..3)
	fold []byte // 현재 경로의 접기열 (D/U), 길이는 s-1
	s    int    // 현재 경로의 길이
	z    pair   // 경로의 끝점
)

@ 경로가 길어질수록 접기 곱은 길이를 곱절로 불리므로, 끝없이 자라지 않게 고삐를
매어 둔다. 원본에서 이 값은 배열의 크기였지만(그래서 넘으면 ``나를 다시
컴파일하라''고 했다), 여기서는 그저 고삐다. 슬라이스는 필요한 만큼 자란다.

@<상수@>=
const maxm = 1 << 15 // 다룰 수 있는 가장 긴 경로

@ 처음 경로는 방향 하나짜리 \.0이다. 잘못된 경로를 받았을 때도 이리로 되돌아온다.

@<함수들@>=
func reset() {
	s, dir, fold, z = 1, []byte{0}, nil, pair{1, 0}
	@<곁들인 표를 지운다@>@;
}

@ \.p 명령. 숫자를 받아 임시 슬라이스 |nd|에 모은다. 잘못된 방향을 만나면 |nd|를
단위 경로로 바꾸고 빠져나가므로, 뒤따르는 코드가 그대로 되돌리기 노릇까지 한다.

@<나머지 명령들@>=
	case 'p':
		sc.get()
		var nd []byte
		for c := sc.peek(); c >= '0' && c <= '3'; c = sc.peek() {
			@<이 방향이 옳은지 살핀다@>@;
			nd = append(nd, c-'0')
			sc.get()
		}
		@<모은 방향을 현재 경로로 삼는다@>@;

@ 첫 방향은 \.0이어야 하고, 그다음부터는 짝홀이 번갈아야 한다. 방향 $k$가 자리
$j$에 오려면 $k\equiv j\pmod2$라는 말이다.

@<이 방향이 옳은지 살핀다@>=
			if len(nd) == 0 && c != '0' {
				fmt.Println("경로는 방향 0에서 시작해야 한다!")
				nd = []byte{0}
				break
			}
			if (int(c-'0')^len(nd))&1 != 0 {
				fmt.Printf("짝홀이 어긋난 방향이다: %c\n", c)
				nd = []byte{0}
				break
			}

@ @<모은 방향을 현재 경로로 삼는다@>=
		if len(nd) > maxm {
			@<너무 길다고 알린다@>@;
			nd = nd[:1]
		}
		dir, s = nd, len(nd)
		@<방향에서 |z|를 셈한다@>@;
		@<방향을 접기열로 바꾼다@>@;
		@<접기열을 보인다@>@;
		@<경로의 값을 알린다@>@;

@ @<너무 길다고 알린다@>=
			fmt.Printf("경로가 %d보다 길어지면 감당할 수 없다!\n", maxm)

@ @<방향에서 |z|를 셈한다@>=
		z = pair{}
		for _, d := range dir {
			z = z.add(ipower[d])
		}

@ 트는 쪽은 방향의 차이가 알려 준다. 차이가 $\pm1$인데 $-1$은 $3$과 같으므로,
비트 $2$가 서 있는지만 보면 \.U인지 \.D인지 갈린다.

@<방향을 접기열로 바꾼다@>=
		fold = make([]byte, 0, s)
		for j := 0; j+1 < s; j++ {
			if (int(dir[j+1])-int(dir[j]))&2 != 0 {
				fold = append(fold, 'U')
			} else {
				fold = append(fold, 'D')
			}
		}

@ \.D나 \.U로 시작하는 명령은 접기열을 통째로 준 것이다.

@<나머지 명령들@>=
	case 'D', 'U':
		var nf []byte
		for c := sc.peek(); c == 'D' || c == 'U'; c = sc.peek() {
			nf = append(nf, c)
			sc.get()
		}
		if len(nf)+1 > maxm {
			@<너무 길다고 알린다@>@;
			nf = nil
		}
		fold, s = nf, len(nf)+1
		@<접기열을 방향으로 바꾼다@>@;
		@<방향들을 보인다@>@;
		@<경로의 값을 알린다@>@;

@ 거꾸로 가는 길. 방향 $0$에서 떠나 접기열대로 틀면서 $z$도 함께 모은다. C판은
접기열 뒤에 붙은 널 문자를 파수꾼 삼아 마지막 한 번을 거저 돌지만, \GO/의 슬라이스에는
그런 것이 없으므로 마지막 자리를 따로 살핀다.

@<접기열을 방향으로 바꾼다@>=
		dir = make([]byte, s)
		z = pair{}
		cur := 0
		for k := 0; k < s; k++ {
			dir[k] = byte(cur)
			z = z.add(ipower[cur])
			if k+1 < s {
				if fold[k] == 'D' {
					cur = (cur + 1) & 3
				} else {
					cur = (cur + 3) & 3
				}
			}
		}

@ 말수에 따라 방향열이나 접기열을 되비쳐 준다. 방향을 준 사람에게는 접기열을,
접기열을 준 사람에게는 방향을 보이는 셈이다.

@<접기열을 보인다@>=
		if vbose&tellFolds != 0 {
			fmt.Printf(" %s,", fold)
		}

@ @<방향들을 보인다@>=
		if vbose&tellDirs != 0 {
			fmt.Print(" ")
			for _, d := range dir {
				fmt.Print(d)
			}
		}

@ 경로가 바뀔 때마다 길이와 끝점을 알리고, 곁들여 두었던 표들을 지운다.

@<경로의 값을 알린다@>=
		fmt.Printf(" s=%d, z=", s)
		@<복소수 |z|를 찍는다@>@;
		fmt.Println()
		@<곁들인 표를 지운다@>@;

@ 가우스 정수를 사람이 읽는 꼴로 적는다. $1$과 $-1$은 계수를 적지 않고, 실수부가
$0$이면 아예 빼먹되 허수부까지 $0$이면 그냥 \.0이라고 쓴다.

@<복소수 |z|를 찍는다@>=
		if z.x != 0 {
			fmt.Print(z.x)
		} else if z.y == 0 {
			fmt.Print(0)
		}
		switch {
		case z.y == 1:
			fmt.Print("+i")
		case z.y == -1:
			fmt.Print("-i")
		case z.y > 0:
			fmt.Printf("+%di", z.y)
		case z.y < 0:
			fmt.Printf("-%di", -z.y)
		}

@* 접기 곱.
Dekking의 접기 곱은 접기열 둘을 엮어 더 긴 접기열을 만든다. 현재 접기열이 $F$이고
곱할 접기열이 $g_0g_1\ldots g_{n-1}$이면, 곱은
$$F\,g_0\,\tilde F\,g_1\,F\,g_2\,\tilde F\,\cdots$$
이다. 여기서 $\tilde F$는 $F$를 거꾸로 읽으면서 \.D와 \.U를 맞바꾼 것이다. 곧
곱할 글자 하나마다 $F$의 사본이 하나씩 끼어드는데, 그 사본이 바로 놓였다 뒤집혔다를
번갈아 한다. 길이를 세어 보면 $(s-1)+ns=s(n+1)-1$이니, 경로의 길이는 $s$와 $n+1$의
곱이 된다.

종이접기로 생각하면 뻔한 이야기다. 접은 종이띠를 다시 접으면, 원래의 접힌 자리들이
한 번은 그대로, 한 번은 거꾸로 뒤집혀 되풀이되기 때문이다.

곱하는 것이 \.D 하나여야 할 까닭은 없다. 무엇을 곱하느냐에 따라 딴판인 곡선이
쏟아지는데, Dekking이 일반화한 용이 바로 이것들이다.
$$
\pic{dragon-calc-2.pdf}
$$
\figcap{그림 2: 단위 경로에 경로 \.{01012}(접기열 \.{DUDD})를 거듭 곱한 것. 곱할
때마다 길이가 다섯 곱절이 된다. 그림 1의 용은 이 자리에 \.D 하나를 곱한 것일
뿐이다.}

@ 곱할 것은 접기열로 줄 수도 있고 방향열로 줄 수도 있다. 원본은 두 경우를 아예
따로 적어 같은 고리를 두 벌 두었는데, 나는 방향열을 먼저 접기열로 바꾸어 곱셈
자체는 한 벌만 두었다. 덤으로 되비치는 차례도 하나로 맞췄다---원본은 접기열을 받으면
접기열을 먼저, 방향열을 받으면 방향열을 먼저 보인다.

@<나머지 명령들@>=
	case '*':
		sc.get()
		var nf []byte
		switch c := sc.peek(); {
		case c == 'D' || c == 'U':
			for c := sc.peek(); c == 'D' || c == 'U'; c = sc.peek() {
				nf = append(nf, c)
				sc.get()
			}
		case c == '0':
			@<방향열을 읽어 접기열 |nf|로 바꾼다@>@;
		default:
			fmt.Println("무엇을 곱하라는 것인지 모르겠다!")
			break
		}
		@<접기 곱을 셈한다@>@;

@ 곱할 방향열도 \.0으로 시작하고 짝홀이 번갈아야 한다. 어긋나는 글자를 만나면
거기서 멈추므로, 남은 것은 줄 끝 검사가 알려 준다.

@<방향열을 읽어 접기열 |nf|로 바꾼다@>=
			prev := sc.get()
			for c := sc.peek(); c >= '0' && c <= '3' && (c^prev)&1 != 0; c = sc.peek() {
				if (int(c)-int(prev))&2 != 0 {
					nf = append(nf, 'U')
				} else {
					nf = append(nf, 'D')
				}
				prev = c
				sc.get()
			}

@ 곱셈 자체. |j|가 사본의 방향을 기억한다. |j|가 양수면 뒤집힌 사본을 거꾸로 훑으며
붙이고 그러면서 $0$이 되고, $0$이면 바른 사본을 앞에서부터 붙이고 다시 $s-1$이 된다.
그래서 사본이 저절로 번갈아 놓인다. 붙이면서 읽는 자리는 언제나 $s-1$보다 앞이라,
새로 붙인 글자가 아직 읽어야 할 글자를 덮을 걱정은 없다.

@<접기 곱을 셈한다@>=
		j := s - 1
		for _, c := range nf {
			if len(fold)+s >= maxm {
				@<너무 길다고 알린다@>@;
				reset()
				break
			}
			fold = append(fold, c)
			if j > 0 {
				for ; j > 0; j-- {
					fold = append(fold, 'U'+'D'-fold[j-1])
				}
			} else {
				for ; j < s-1; j++ {
					fold = append(fold, fold[j])
				}
			}
		}
		s = len(fold) + 1
		@<접기열을 방향으로 바꾼다@>@;
		@<접기열을 보인다@>@;
		@<방향들을 보인다@>@;
		@<경로의 값을 알린다@>@;

@* 가우스 정수와 타일.
좌표 둘을 묶은 |pair|는 이 프로그램에서 두 가지 노릇을 한다. 하나는 복소평면의
점, 곧 가우스 정수 $x+yi$이고, 다른 하나는 {\it 타일\/}이다.

타일이란 경로가 지나간 변 하나를 가리키는 이름이다. 변의 두 끝점을 더한 값으로
그 변을 부르기로 하면, 두 끝점은 한 좌표만 $1$ 차이가 나므로 합의 두 좌표를 더한
것은 언제나 홀수다. 그래서 $x+y$가 홀수인 가우스 정수와 변이 하나씩 짝을 이룬다.
프로그램이 타일을 받을 때마다 $x+y$의 홀짝을 따지는 까닭이 이것이다.

@<자료 구조@>=
type pair struct{ x, y int64 }

@ $i$의 거듭제곱 넷은 방향 넷이기도 하다. 자주 쓰이니 표로 만들어 둔다.

@<전역 변수@>=
var ipower = [4]pair{{1, 0}, {0, 1}, {-1, 0}, {0, -1}}

@ 복소수의 덧셈, 뺄셈, 곱셈은 쉽다. 나눗셈은 나누어떨어질 때만 쓰므로 켤레를
곱해 노름으로 나누면 그만이다.

@<함수들@>=
func (a pair) add(b pair) pair { return pair{a.x + b.x, a.y + b.y} }

func (a pair) sub(b pair) pair { return pair{a.x - b.x, a.y - b.y} }

func (a pair) mul(b pair) pair {
	return pair{a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x}
}

func (a pair) div(b pair) pair {
	n := b.norm()
	return pair{(a.x*b.x + a.y*b.y) / n, (a.y*b.x - a.x*b.y) / n}
}

func (a pair) norm() int64 { return a.x*a.x + a.y*a.y }

@ 타일에는 {\it 형\/}(type)이 있다. $0$부터 $3$까지 넷인데, 타일에 $i$를 곱하면
형이 하나씩 줄어든다(mod~$4$). 단위 타일 \.{1,0}이 형~$0$이다. 아래 식이 그것을
좌표의 낮은 두 비트만으로 집어낸다. Knuth는 이 줄에 ``그렇다, 이게 된다!''는 주석을
달아 두었다.

@<함수들@>=
func (w pair) typ() int { return int((w.x&1 + (w.x+w.y)&2 + 3) & 3) }

@ 타일의 접기 곱은 지금 경로의 $z$에 매여 있다. $d$를 $w$의 형이라 할 때
$$v*w=i^{-d}v+z\,(w+i^{2-d})$$
이다. 곧 $v$를 $w$의 형만큼 되돌려 놓고, $w$를 원점 쪽으로 한 칸 당긴 것에 $z$를
곱해 더한다. 경로가 바뀌면 $z$가 바뀌므로 같은 두 타일의 곱도 달라진다.

@<함수들@>=
func fprod(v, w pair) pair {
	d := w.typ()
	e := w.add(ipower[(2-d)&3])
	return ipower[(-d)&3].mul(v).add(z.mul(e))
}

@ 타일 둘을 곱하라는 명령은 첫 글자가 숫자나 빼기표라, 나머지를 모두 걸러 낸
자리에서 받는다.

@<나머지 명령들@>=
	default:
		v, ok := sc.tile()
		if !ok {
			break
		}
		if !sc.must('*') {
			break
		}
		w, ok := sc.tile()
		if !ok {
			break
		}
		u := fprod(v, w)
		fmt.Printf(" %d,%d\n", u.x, u.y)

@* 폴리오미노.
경로가 지나간 변들을 모두 모은 것이 그 경로의 {\it 폴리오미노\/}다. 타일 하나가
변 하나이므로, 길이 $s$인 경로의 폴리오미노에는 타일이 $s$개 있다. 앞에서 정한
대로 변마다 두 끝점의 합을 적어 두면 된다. 첫 타일은 늘 \.{1,0}이다.

이 표는 쓸 일이 생길 때만 만든다. 경로가 바뀌면 지워 두었다가, 필요해지면 그때
다시 만든다.

@<함수들@>=
func makePoly() {
	if poly != nil {
		return
	}
	poly = make([]pair, s)
	var u pair
	for k := 0; k < s; k++ {
		v := u
		u = u.add(ipower[dir[k]])
		poly[k] = u.add(v)
	}
}

@ @<전역 변수@>=
var poly []pair // 현재 경로의 폴리오미노

@ @<곁들인 표를 지운다@>=
	poly, cclass, fill = nil, nil, nil

@ \.{a*} 명령은 폴리오미노의 타일 모두에 주어진 타일을 곱한다. \.{a*1,0}은 단위
타일을 곱하는 것이니 폴리오미노를 그냥 늘어놓는 셈이다.

@<나머지 명령들@>=
	case 'a':
		sc.get()
		makePoly()
		if !sc.must('*') {
			break
		}
		w, ok := sc.tile()
		if !ok {
			break
		}
		for _, v := range poly {
			u := fprod(v, w)
			fmt.Printf(" %d,%d", u.x, u.y)
		}
		fmt.Println()

@* 합동류.
이제 가장 재미있는 대목, 두 타일이 합동인지 가리는 일이다.

$Z=(2+2i)z$라 하자. 두 타일이 {\it 합동\/}이라 함은 하나에 $i$의 거듭제곱을 곱하고
$Z$의 배수를 더해 다른 하나로 갈 수 있다는 뜻이다. 그러니 합동류를 셈하려면 타일을
$Z$로 나눈 나머지로 줄인 다음, $i$를 곱해 만나는 넷을 한 무리로 묶으면 된다.

$Z$의 배수들이 이루는 격자를 다루기 좋은 기저로 바꾸는 것이 첫 일이다. $Z$와 $iZ$가
그 격자를 낳는데, 이 둘에 정수 조합을 거듭 먹여 $(U,0)$과 $(V_x,D)$ 꼴로 만든다.
하나는 실수축에 눕고 다른 하나의 허수부는 $D$가 되게 하는 것이다---행렬로 치면
에르미트 정규형이다. 그러면 나머지 줄이기가 간단해진다. 먼저 $(V_x,D)$의 배수를
빼서 허수부를 $[0,D)$에 넣고, 그다음 $(U,0)$의 배수를 빼서 실수부를 $[0,U)$에 넣는다.

@ 기저를 얻는 방법은 허수부에 유클리드 호제법을 돌리는 것이다. 큰 쪽에서 작은 쪽을
빼기를 되풀이하다 한쪽 허수부가 $0$이 되면 끝난다. 격자를 낳는 성질은 그동안
그대로다.

@<함수들@>=
func makeClasses() {
	if cclass != nil {
		return
	}
	@<격자의 기저 |uu|와 |vv|를 얻는다@>@;
	@<합동류 표를 채운다@>@;
}

@ @<격자의 기저 |uu|와 |vv|를 얻는다@>=
	uu = z.mul(pair{2, 2})
	vv = pair{-uu.y, uu.x}
	if uu.y < 0 {
		uu = pair{-uu.x, -uu.y}
	}
	if vv.y < 0 {
		vv = pair{-vv.x, -vv.y}
	}
	for uu.y != 0 {
		for vv.y >= uu.y {
			vv = vv.sub(uu)
		}
		uu, vv = vv, uu
	}
	if uu.x < 0 {
		uu.x = -uu.x
	}

@ @<전역 변수@>=
var (
	cclass [][]int // 합동류 표
	uu, vv pair    // 격자의 기저: |uu| 는 실수축에, |vv| 의 허수부는 $D$
)

@ 표는 나머지로 줄인 점마다 한 칸씩이다. 줄인 결과의 실수부는 $[0,U)$, 허수부는
$[0,D)$에 있고 두 좌표의 합은 홀수이므로, 허수부를 반으로 접어 |cclass[y>>1][x]|에
넣으면 자리를 절반만 쓰고도 넉넉하다.

원본은 이 표를 크기 $256\times131072$짜리 정적 배열로 잡아 두었다. 정수 하나를
$4$바이트로 쳐도 $134$메가바이트다. 여기서는 경로마다 꼭 필요한 만큼만 잡는다.

@<합동류 표를 채운다@>=
	rows, cols := int(vv.y>>1), int(uu.x)
	cclass = make([][]int, rows)
	for j := range cclass {
		cclass[j] = make([]int, cols)
		for k := range cclass[j] {
			cclass[j][k] = -1
		}
	}
	@<아직 번호가 없는 칸마다 새 합동류를 준다@>@;

@ 표를 훑다가 아직 번호가 없는 칸을 만나면 새 번호를 주고, 거기에 $i$, $i^2$, $i^3$을
곱해 나오는 세 칸에도 같은 번호를 준다. 그 넷이 한 합동류다.

@<아직 번호가 없는 칸마다 새 합동류를 준다@>=
	c := 0
	for j := 0; j < rows; j++ {
		for k := 0; k < cols; k++ {
			if cclass[j][k] >= 0 {
				continue
			}
			cclass[j][k] = c
			v := pair{int64(k), int64(2*j + 1 - (k & 1))}
			for d := 1; d < 4; d++ {
				r := reduce(v.mul(ipower[d]))
				cclass[r.y>>1][r.x] = c
			}
			c++
		}
	}

@ 나머지 줄이기. 값을 받아 값을 돌려주므로 부른 쪽의 타일은 그대로 남는다.

@<함수들@>=
func reduce(w pair) pair {
	if w.y < 0 {
		q := (vv.y - 1 - w.y) / vv.y
		w.x, w.y = w.x+q*vv.x, w.y+q*vv.y
	} else {
		q := w.y / vv.y
		w.x, w.y = w.x-q*vv.x, w.y-q*vv.y
	}
	if w.x < 0 {
		w.x += ((uu.x - 1 - w.x) / uu.x) * uu.x
	} else {
		w.x -= (w.x / uu.x) * uu.x
	}
	return w
}

@ @<함수들@>=
func classOf(w pair) int { return cclass[w.y>>1][w.x] }

@ \.c 명령. 타일을 주면 그것 하나를, 주지 않으면 폴리오미노 전체를 보인다.

$z=0$이면 $Z=0$이라 나눌 것이 없다. 원본은 이 경우를 살피지 않아 $0$으로 나누는데,
기계에 따라 죽거나(x86) 엉뚱한 값을 뱉는다(ARM에서 실제로 그랬다). \GO/는 $0$으로
나누면 반드시 패닉이므로 미리 막는다. \.{p0123}처럼 제자리로 돌아오는 경로가
그런 경우다.

@<나머지 명령들@>=
	case 'c':
		sc.get()
		if z.norm() == 0 {
			fmt.Println("z가 0이라 합동류를 따질 수 없다!")
			break
		}
		makeClasses()
		sc.skip()
		if sc.eof() {
			@<폴리오미노 전체의 합동류를 보인다@>@;
			break
		}
		w, ok := sc.tile()
		if !ok {
			break
		}
		@<타일 하나의 합동류와 형을 보인다@>@;

@ 보이는 꼴은 `타일: 류\_형'이다. 원본은 이 자리에서 타일인지 아닌지를 살피지 않아,
홀짝이 어긋난 값을 주면 엉뚱한 칸을 읽고 엉뚱한 번호를 답한다. |tile|이 이미 살피므로
여기서는 그럴 일이 없다.

@<타일 하나의 합동류와 형을 보인다@>=
		fmt.Printf(" %d,%d: %d_%d\n", w.x, w.y, classOf(reduce(w)), w.typ())

@ @<폴리오미노 전체의 합동류를 보인다@>=
			makePoly()
			for _, w := range poly {
				@<타일 하나의 합동류와 형을 보인다@>@;
			}

@* 인수분해.
경로가 {\it 판을 채운다\/}(plane-filling)는 것은 $s=\vert z\vert^2$이고 폴리오미노의
타일들이 서로 합동이 아니라는 뜻이다. 그런 경로에서는 합동류마다 폴리오미노의 타일이
꼭 하나씩 있으므로, 타일 $u$를 받으면 그것과 합동인 폴리오미노의 타일 $v$가 하나로
정해진다. 그러면 $u=v*w$가 되는 $w$도 곱셈 식을 뒤집어 얻을 수 있다. 이것이
\.f 명령이다.

@<전역 변수@>=
var fill []int // 합동류마다 폴리오미노의 타일 번호

@ 표를 만들다가 같은 합동류에 타일이 둘 들어오면 판을 채우지 않는 경로다. 그때는
표를 버린다---|fill|이 비어 있다는 것이 곧 ``판을 채우지 않는다''는 표시다.

@<판을 채우는 경로인지 살펴본다@>=
		if fill == nil && z.norm() == int64(s) {
			makePoly()
			makeClasses()
			fill = make([]int, s)
			for j := range fill {
				fill[j] = -1
			}
			for k, t := range poly {
				c := classOf(reduce(t))
				if fill[c] >= 0 {
					fill = nil
					break
				}
				fill[c] = k
			}
		}

@ \.f는 한 번만 쪼개고 \.F는 되돌이에 들어설 때까지 쪼갠다.

@<나머지 명령들@>=
	case 'f', 'F':
		all := sc.get() == 'F'
		@<판을 채우는 경로인지 살펴본다@>@;
		if fill == nil {
			fmt.Println("지금 경로는 판을 채우지 않는다!")
			break
		}
		u, ok := sc.tile()
		if !ok {
			break
		}
		cyc := []pair{u}
		for {
			@<|u|를 |v*w|로 쪼갠다@>@;
			if !all {
				break
			}
			@<되돌이에 들어섰으면 그만둔다@>@;
			u = w
		}

@ 쪼개는 식은 곱셈 식을 뒤집은 것이다. $u$와 합동인 폴리오미노의 타일 $v$를 찾고,
두 형의 차이 $k$만큼 되돌린 다음 $z$로 나눈다. 이론은 ``다이아몬드와 용'' 노트에 있다.

@<|u|를 |v*w|로 쪼갠다@>=
			v := poly[fill[classOf(reduce(u))]]
			k := (u.typ() - v.typ()) & 3
			e := u.sub(v.mul(ipower[(-k)&3])).div(z)
			w := e.add(ipower[(-k)&3])
			fmt.Printf(" %d,%d = %d,%d * %d,%d\n", u.x, u.y, v.x, v.y, w.x, w.y)

@ |cyc[0]|에는 지금까지 본 것 가운데 가장 작은 것을 둔다. $\vert w\vert=1$이면
$1*w=w$이므로 더 쪼갤 것이 없다.

@<되돌이에 들어섰으면 그만둔다@>=
			if w.norm() == 1 {
				break
			}
			if w.norm() < cyc[0].norm() {
				cyc = append(cyc[:0], w)
			} else {
				seen := false
				for _, y := range cyc {
					if y == w {
						seen = true
						break
					}
				}
				if seen {
					break
				}
				cyc = append(cyc, w)
			}

@* 그림 그리기.
마지막으로, 일반화된 용 곡선을 눈으로 볼 수 있게 {\logo METAPOST} 명령을 뱉는다.
접기열의 \.D와 \.U를 그대로 {\logo METAPOST}의 매크로 이름으로 쓰는 것이 재치 있다.
매크로 하나가 붓을 $90^\circ$ 틀고 한 칸 긋는다.

@<상수@>=
const mpFile = "/tmp/dragon-calc.mp" // 그림을 적을 곳

@ @<전역 변수@>=
var (
	out   *os.File // {\logo METAPOST} 출력
	count int      // 지금까지 뱉은 그림의 수
)

@ 첫 그림을 뱉을 때 파일을 열면서 머리말을 적는다. 눈금 |rr|를 고치면 그림 크기가
달라진다.

@<함수들@>=
func openOut() {
	if out != nil {
		return
	}
	f, err := os.Create(mpFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s에 그림을 적을 수 없다!\n", mpFile)
		os.Exit(1)
	}
	out = f
	fmt.Fprint(out, preamble)
}

@ @<상수@>=
const preamble = `% 용 곡선 계산기가 뱉은 그림
numeric dd; pair rr,ww,zz; rr=(10bp,0); % 원하면 rr를 고치라
def D = dd:=dd+90; ww:=zz; zz:=ww+rr rotated dd; draw ww--zz; enddef;
def U = dd:=dd-90; ww:=zz; zz:=ww+rr rotated dd; draw ww--zz; enddef;
def O = zz:=origin; dd:=-90; D; enddef;
`

@ \.m 명령. 접기열을 한 줄에 서른두 개씩 끊어 적는다.

@<나머지 명령들@>=
	case 'm':
		sc.get()
		openOut()
		count++
		fmt.Fprintf(out, "\nbeginfig(%d)\n O", count)
		for k, c := range fold {
			if k%32 == 31 {
				fmt.Fprintln(out)
			}
			fmt.Fprintf(out, " %c", c)
		}
		fmt.Fprint(out, ";\nendfig;\n")

@ 그만둘 때 파일을 닫는다. 그림을 하나도 뱉지 않았으면 파일을 열지도 않았을 테니
할 일이 없다.

@<{\logo METAPOST} 파일을 닫는다@>=
	if out != nil {
		fmt.Fprint(out, "\nbye.\n")
		out.Close()
		fmt.Fprintf(os.Stderr, "경로 %d개의 그림을 %s에 적었다.\n", count, mpFile)
	}

@* 색인.
