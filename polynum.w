\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\caret/{\smash{\lower4pt\hbox to0pt{\hss$\scriptscriptstyle\land$\hss}}}
\def\qcaret/{`\thinspace\caret/\thinspace'} % 따옴표 친 캐럿
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

\def\title{다항체 세기}

@* 들어가며.
이 프로그램의 목적은 칸이 55개까지인 고정 다항체(폴리오미노)를 세는 것이다. (무어의
법칙이 몇 해 더 이어져야 정말 그만큼 갈 수 있겠지만.) 방법은 본질적으로 Iwan Jensen의
것이다[{\tt arXiv:cond-mat/0007239}, {\sl Journal of Statistical Physics\/} 2001년 봄호에
실릴 예정]. Jensen은 Andrew Conway의 중요한 기법[{\sl Journal of Physics\/ \bf A28}
(1995), 335--349]을 다항체 세기라는 특수한 경우에 크게 개선할 수 있음을 발견했다.
@^Jensen, Iwan@>
@^Conway, Andrew Richard@>

기본 착상은 아주 단순하다. 높이 $h$칸, 너비 $w$칸인 직사각형을 꽉 채워 걸치는(span)
고정 다항체의 수를 센다. 여기서 $h$와 $w$는 될 수 있는 대로 작은 것이다. 그런 다음
관련된 모든 $h$와 $w$에 걸쳐 합계를 더한다. 또 $h\ge w$라고 가정해도 된다. 필요한 $h$와
$w$마다, $h\times w$ 배열의 칸을 왼쪽에서 오른쪽으로, 위에서 아래로 한 번에 하나씩
살피며 그 칸을 차지할지 말지 정하고, 앞으로의 결정에 관한 한 동등한 경계 짜임들의
결과를 합쳐 가며 걸치는 다항체를 센다. 이를테면 다항체가 이렇게 시작할 수 있다.

$$\mplibcode
beginfig(2);
  numeric u; u = .2in;
  picture pix;
  fill unitsquare scaled u withcolor .9white;
  draw unitsquare scaled u;
  pix = currentpicture; currentpicture := nullpicture;
  def row(expr s, y) =
    for i = 1 upto length s:
      if substring (i-1, i) of s <> "0": draw pix shifted ((i-1, y)*u); fi;
    endfor
  enddef;
  for y = 10 downto 0:
    draw ((0, y)*u) -- ((if y > 0: 26 else: 15 fi, y)*u) dashed withdots;
  endfor
  for x = 0 upto 26:
    draw ((x, if x > 15: 1 else: 0 fi)*u) -- ((x, 10)*u) dashed withdots;
  endfor
  row("00000001011111000000000000", 9);
  row("00000011110001000000000000", 8);
  row("00011111000011111100000000", 7);
  row("00010000000000000111000000", 6);
  row("00010000111111110001000000", 5);
  row("01110000100000010001000111", 4);
  row("01100111100001110001110010", 3);
  row("01000100111000100000010010", 2);
  row("01011101001000110011010110", 1);
  row("010010010010101", 0);
endfig;
\endmplibcode$$
\figcap{너비 26칸인 배열에 채워 가는 다항체. 맨 아래 줄은 열다섯 칸까지만 정했다. 그림은
크누스가 공개한 \.{polyomino.mp}의 둘째 그림을 그대로 옮긴 것이다.}

(이 부분 다항체는 이미 칸이 54개를 넘으니 분명히 너무 크다. 그러나 큰 예가 아래
프로그램에 필요한 개념을 밝히는 데 도움이 된다.)

@ 이 무늬의 위쪽 세부는 대부분, 아직 정하지 않은 칸들이 알맞은 다항체를 이룰지 아닐지에
아무 영향도 주지 않는다. 그 물음에 답하려면 지금까지의 각 열의 맨 아래 칸이 찼는지
비었는지, 그리고 찬 칸들 가운데 어느 것들이 이미 서로 이어졌는지만 알면 된다. 또 맨
왼쪽 열과 맨 오른쪽 열이 아직 비어 있는지도 알아야 한다.

이 경우 열 26개의 맨 아래 점유 무늬는 \.{01001001001010110011010110}이고, 찬 칸들은
연결 성분 여섯 개에 속한다. 곧
$$\vbox{\halign{\.{#}\cr
01000000000000000000010000\cr
00001000001000110000000000\cr
00000001000000000000000000\cr
00000000000010000000000000\cr
00000000000000000011000000\cr
00000000000000000000000110\cr}}$$
이다. 다행히 다항체는 평면에 놓이므로 성분들은 서로 안에 포개질 수밖에 없다.
\.{1000100}과 \.{0010001} 같은 ``엇갈림''은 있을 수 없다. 그래서 성분과 점유 정보를
$$\.{0(00(00100-010-)00()0)0()0}$$
처럼 다섯 글자 알파벳으로 편하게 적을 수 있다.
$$\vbox{\halign{\.#\enspace&#\hfil\cr
0&칸이 비어 있다.\cr
1&칸이 홀로 한 성분을 이룬다.\cr
(&칸이 여러 칸짜리 성분의 맨 왼쪽이다.\cr
)&칸이 여러 칸짜리 성분의 맨 오른쪽이다.\cr
-&칸이 여러 칸짜리 성분의 가운데에 있다.\cr}}$$
게다가 맨 왼쪽 열 전체가 비어 있지 않은 경우는, 배열의 왼쪽 가장자리가 맨 왼쪽 칸
성분에 속한다고 보아 다룰 수 있다. 맨 오른쪽 열도 마찬가지다. 이런 약속 아래, 위의
부분적으로 채운 배열의 아래 경계 조건을 26글자 문자열
$$\.{0(00(00100-010-\caret/)00()0)0(-0}\,,\eqno(*)$$
로 적는다. 여기서 \qcaret/는 마지막 부분 줄이 끝나는 곳을 보인다.

\vskip1pt
$(*)$ 같은 문자열을 {\it 짜임\/}(configuration)이라 한다. \qcaret/가 없으면 부분 줄이
완전한 줄이라고 본다. 주어진 점유 무늬 위에 있는 줄의 수는 짜임에 암묵적으로 들어
있지만 표기에 드러나지는 않는다. 이 프로그램은 지금 부분 줄 위의 줄 수가 서로 다른
짜임들을 한꺼번에 다룰 일이 없기 때문이다.

@ 약간의 이론이 이 규칙을 몸에 익히는 데 도움이 될지 모른다. 알고 보니 한 줄의 끝에서
가능한 연결성/점유 짜임 부호 전체는 다음의 흥미로운 모호하지 않은 문맥 자유 문법을
갖는다.
$$\eqalign{
S&\to L\,\.0J_0R \mid Z\.-I\.-Z\mid Z\.-Z\cr
Z&\to\epsilon\mid\.0Z\cr
L&\to\epsilon\mid Z\,\.)\mid Z\.-I\.)\cr
R&\to\epsilon\mid \.(Z\mid \.(I\.-Z\cr
I_0&\to\epsilon\mid\.0J_0\cr
J_0&\to I_0\mid A\,\.0J_0\cr
I&\to\epsilon\mid\.-I\mid\.0J\cr
J&\to I\mid A\,\.0J\cr
A&\to 1\mid \.(I\.)\cr
}$$
[풀이: $I$는 \.0과 \.-와 $A$로 된 아무 열이되, 각 $A$의 앞뒤에는 \.0이 온다. 기호 $I_0$도
비슷하지만 맨 위 수준에 \.-가 없다.] 이 문법에서 길이가 $n$인 문자열의 수 $s_n$은 생성
함수
$$\sum s_nz^n={1-4z^2-4z^3+z^4-(1+z)(1-z^2)\sqrt{\mkern1mu1+z}
    \sqrt{\mkern1mu1-3z}\over2z^3(1-z)}=2z+6z^2+16z^3+\cdots{}$$
를 갖는다. 그러므로 $s_n$은 점근적으로 $3^n\!/n^{3/2}$에 비례한다.

@ 10번째 줄의 가운데에서 짜임 $(*)$를 갖는 다항체는 지금까지 적어도
$28+18+1+1+2+4=54$칸을 차지했을 것이고, 성분들을 잇고 배열의 왼쪽 가장자리에 닿게 하려면
16칸이 더 필요하다. 게다가 배열은 지금까지 10줄뿐인데 열은 26개이고, 우리는 $h\ge w$인
배열에만 관심이 있다. 그러므로 $h\times26$ 배열에서 다항체를 완성하려면 적어도 15칸을 더
차지해야 한다.

다시 말해 경계 짜임 $(*)$는 칸이 적어도 $54+16+15=85$개인 다항체를 셀 때에만 다루면
된다. 이런 고려 덕에 생겨날 수 있는 짜임의 수가 크게 줄어든다. Jensen의 실험에 따르면
다루어야 할 경우의 총수는 대략 $c^n$으로 자라는데, $c$는 1.4보다 조금 크다. 지수적으로
크지만 Conway의 원래 방법에서 생기는 짜임 $3^{n/2}$개보다는 꽤 작고, 대략 $4.06^n$에
$0.3/n$을 곱한 것으로 밝혀진 다항체 총수보다는 엄청나게 작다.

@ 이 프로그램이 세기를 다 하지는 않는다. 어떻게 세는지를 알려 주는 명령어들만 내놓는다.
다른 프로그램 {\mc POLYSLAVE}가 그 명령어들을 읽어 계산을 마친다.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{polynum.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/polynum.w}를 \.{GWEB}으로 옮긴
것이다. 원본의 머리글 \.{Last-Modified}는 \.{Tue, 08 Aug 2017 23:42:50 GMT}다.
프로그램이 찍는 말과 종료 부호, 그리고 내놓는 명령어 파일은 원본 그대로 두었다. 그래야
두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

옮기다 보니 원본에서 결함 셋이 나왔다. 곧 $n\ge127$이면 \.{char}인 지수 필드가 넘쳐
죽는 것, |confsize|가 $0$이면 배열 밖을 읽는 것, |slavesize|가 $2^{30}$을 넘으면
명령어의 주소가 깨지는 것이다. 모두 고쳤고, 저마다 그 자리에서 이야기한다. 맨 끝의
``맞춰 보기''에 확인한 방법을 적었다.

@ 뼈대는 이렇다.

@c
package main

import (
	"bufio"
	"encoding/binary"
	"fmt"
	"os"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 읽는다@>@;
	@<초기화한다@>@;
	@<후처리기에 줄 명령어를 내놓는다@>@;
	@<이번 실행의 통계를 찍는다@>@;
	@<버퍼를 비우고 출력 파일을 닫는다@>@;
	out.Flush()
	os.Exit(0)
}

@ 원본의 |panic|은 \.{Go}의 내장 함수와 이름이 겹치므로 |fatal|로 부른다. 표준 출력은
버퍼에 모으므로 끝내기 전에 비운다.

@<함수들@>=
func fatal(mess string) {
	out.Flush()
	fmt.Fprintf(os.Stderr, "%s!\n", mess)
	os.Exit(-1)
}

@ @<전역 변수@>=
var out = bufio.NewWriter(os.Stdout) // 표준 출력의 버퍼

@ 사용자는 명령줄에서 셀 다항체의 최대 크기 $n$과 원하는 너비 $w$를 준다. 칸이 $n$개
이하인 다항체가 걸치는 $h\times w$ 직사각형을 $w\le h\le n+1-w$에 대해 모두 센다.
($h>n+1-w$이면 해가 없다.)

이 판은 원본처럼 |w|를 많아야 23으로 제한한다. 원본은 \.{CWEB} 변경 파일로 묶고 푸는
루틴을 고치면 $w$를 27까지 다룰 수 있다고 했다.

명령줄에는 이 프로그램이 짜임에 쓸 메모리와 출력의 개별 카운터에 쓸 메모리의 크기도
준다. 이 매개변수들을 고르는 데 참고하도록 통계를 찍는다.

출력 파일의 기본 이름이 명령줄의 마지막 인자다. 출력이 엄청나게 많을 수 있으므로,
뒤에서 설명하듯이 이 이름은 실제로 \.{.0}, \.{.1}, \dots로 늘어난다.

@<상수@>=
const (
	wmax = 23              // 사오 진법과 팔진법으로 네 바이트 둘에 묶기 위해
	nmax = wmax + wmax + 126
)

@ 인자는 \CEE/의 |sscanf|처럼 읽는다.

원본은 |confsize|와 |slavesize|를 살피지 않는다. 매개변수 |confsize|가 $0$이면 짜임 배열이 비어
있는데도 첫 짜임을 그 첫 칸에 두어 배열 밖을 읽고 쓴다. 또 슬레이브의 주소는 아래에서
보듯이 명령어 안에 $30$비트로 들어가고 그 위의 비트는 대상 주소 표시로 쓰이므로,
|slavesize|가 $2^{30}$을 넘으면 주소가 그 비트를 침범해 명령어 흐름이 조용히 깨진다.
이를테면 원본에 |slavesize|$=2\times10^9$을 주면 명령어를 해석한 셈이 모두 $0$이 된다.
이 판은 두 값을 살펴 거절한다. 두 말은 이 판에서 지은 것이다.

@<명령줄을 읽는다@>=
{
	ok := len(os.Args) == 6
	if ok {
		_, e1 := fmt.Sscanf(os.Args[1], "%d", &n)
		_, e2 := fmt.Sscanf(os.Args[2], "%d", &w)
		_, e3 := fmt.Sscanf(os.Args[3], "%d", &confSize)
		_, e4 := fmt.Sscanf(os.Args[4], "%d", &slaveSize)
		ok = e1 == nil && e2 == nil && e3 == nil && e4 == nil
	}
	if !ok {
		fmt.Fprintf(os.Stderr, "Usage: %s n w confsize slavesize outfilename\n", os.Args[0])
		os.Exit(-2)
	}
}
if w > wmax {
	fatal("Sorry, that w is too big for this implementation")
}
if w < 2 {
	fatal("No, w must be at least 2")
}
if n < w+w-1 {
	fatal("There are no solutions for such a small n")
}
if n > w+w+126 {
	fatal("Eh? That n is incredible")
}
if confSize < 1 {
	fatal("Sorry, confsize must be positive")
}
if slaveSize > 1<<30 {
	fatal("Sorry, slavesize must not exceed 2^30")
}
baseName = os.Args[5]

@ 명령줄 인자는 \CEE/의 \.{int}처럼 $32$비트로 읽는다.

@<전역 변수@>=
var (
	n         int32 // 칸이 $n$개 이하인 다항체를 센다
	w         int32 // 다만 너비 $w$, 높이 $w$ 이상인 직사각형에 걸치는 것만
	confSize  int32 // 메모리에 둘 짜임 구조의 수
	slaveSize int32 // 슬레이브 프로그램 메모리의 카운터 자리 수
)

@* 출력.
어디로 가는지 알 수 있도록 출력의 기본부터 처리하자. 후처리 프로그램 {\mc POLYSLAVE}는
명령어 하나가 한 바이트나 네 바이트인 간결한 이진 형식에 따라 명령어를 해석한다.

출력은 몇 기가바이트에 이를 수 있는데, 크누스의 리눅스는 길이가
$2^{31}-1=2147483647$을 넘는 파일을 그리 반기지 않았다. 그래서 출력을 \.{foo.0},
\.{foo.1}, \dots라는 파일들로 나누어, 파일마다 많아야 큰 기가바이트 하나(곧
$2^{30}$바이트)가 되게 한다.

몇 번 겪은 하드웨어 고장 때문에 크누스는 검사합(|checksum|) 기능을 덧붙였다.

@<상수@>=
const (
	filelengthThreshold = 1 << 30 // 파일 크기의 최댓값(바이트)
	bufSize             = 1 << 16 // 버퍼 크기, |filelengthThreshold|의 약수여야 한다
)

@ @<전역 변수@>=
var (
	outFile       *os.File
	outBuf        [bufSize + 4]byte // 이진 출력을 담을 곳
	bufPtr        int               // 버퍼 안의 지금 자리
	bytesOut      int               // 지금 출력 파일에 쓴 바이트 수
	checksum      uint32            // 잘못된 입출력을 가려내는 데 쓰는 값
	ckFile        *os.File          // 검사합 파일
	fileExtension int               // 내놓은 큰 기가바이트의 수
	baseName      string
	filename      string
)

@ 원본은 이름을 |"%.90s.%d"|로 만들어 기본 이름을 90글자에서 자른다. 이 판도 그렇게
한다.

@<함수들@>=
func openIt() {
	filename = fmt.Sprintf("%.90s.%d", baseName, fileExtension)
	var err error
	if outFile, err = os.Create(filename); err != nil {
		out.Flush()
		fmt.Fprintf(os.Stderr, "I can't open file %s", filename)
		fatal(" for output")
	}
	bytesOut, checksum = 0, 0
}

@ 검사합은 이 기계의 바이트 순서로 네 바이트씩 검사합 파일에 쓴다.

@<함수들@>=
func closeIt() {
	var b [4]byte
	binary.NativeEndian.PutUint32(b[:], checksum)
	if _, err := ckFile.Write(b[:]); err != nil {
		fatal("I couldn't write the check sum")
	}
	if outFile.Close() != nil {
		fatal("I couldn't close the output file")
	}
	fmt.Fprintf(out, "[%d bytes written on file %s, checksum %d.]\n",
		bytesOut, filename, checksum)
}

@ @<함수들@>=
func writeIt(bytes int) {
	if bytesOut >= filelengthThreshold {
		if bytesOut != filelengthThreshold {
			fatal("Improper buffer size")
		}
		closeIt()
		fileExtension++
		openIt()
	}
	if k, err := outFile.Write(outBuf[:bytes]); err != nil || k != bytes {
		fatal("Bad write")
	}
	bytesOut += bytes
	var s uint32
	for k := 0; k < bytes; k++ {
		s = s<<1 + uint32(outBuf[k])
	}
	checksum += s
}

@ 네 바이트 명령어는 이진수 $(0xaaaaaa)_2$, $(bbbbbbbb)_2$, $(cccccccc)_2$,
$(dddddddd)_2$의 꼴이다. 여기서 $(aaaaaabbbbbbbbccccccccdddddddd)_2$는 큰 쪽이 앞에 오는
$30$비트 주소다. 비트 $x=0$이면 ``이것이 새 원천 주소 $s$다''라는 뜻이고, $x=1$이면 ``이것이
새 대상 주소 $t$다''라는 뜻이다.

한 바이트 명령어는 이진수 $(1ooopppp)_2$의 꼴이다. 여기서 $(ooo)_2$는 $3$비트 연산
부호이고 $(pppp)_2$는 $4$비트 매개변수다. 매개변수가 $0$이면 다음 바이트를 $8$비트
매개변수 $(pppppppp)_2$로 보며, 그것은 $0$이 아니어야 한다. (그때 ``한 바이트
명령어''는 실제로 두 바이트다.)

아래 명령어 정의에서 $p$는 매개변수, $s$는 지금의 원천 주소, $t$는 지금의 대상 주소다.
슬레이브 처리기는 |count|라는 커다란 배열을 다룬다.

연산 부호 0(|opSync|)은 ``방금 $p$번째 줄을 마쳤다''는 뜻이다. 사용자에게 보고한다.

연산 부호 1(|opClear|)은 ``$0\le j<p$에 대해 |count[t+j]=0|으로 둔다''는 뜻이다.

연산 부호 2(|opCopy|)는 ``$0\le j<p$에 대해 |count[t+j]=count[s+j]|로 둔다''는 뜻이다.

연산 부호 3(|opAdd|)은 ``$0\le j<p$에 대해 |count[t+j]+=count[s+j]|로 둔다''는 뜻이다.

연산 부호 4(|opIncSrc|)는 ``|s+=p|''이고, 5(|opDecSrc|)는 ``|s-=p|''이다.

연산 부호 6(|opIncTrg|)은 ``|t+=p|''이고, 7(|opDecTrg|)은 ``|t-=p|''이다.

원본의 이름 |sync|, |clear|, |copy|, \dots{} 가운데 |clear|와 |copy|가 \.{Go}의 내장
함수와 겹치므로, 이 판은 모두 |op|를 앞에 붙였다.

@<상수@>=
const targBit = 0x40000000 // 네 바이트 명령어에서 |t|를 가리킨다

const (
	opSync = iota
	opClear
	opCopy
	opAdd
	opIncSrc
	opDecSrc
	opIncTrg
	opDecTrg
)

@ 버퍼가 차면 |bufSize|바이트를 쓰고, 넘친 바이트를 앞으로 옮긴다.

@<함수들@>=
func putInst(o, p byte) {
	b := bufPtr
	if p < 16 {
		outBuf[b] = 0x80 + o<<4 + p
	} else {
		outBuf[b] = 0x80 + o<<4
	}
	b++
	if p >= 16 {
		outBuf[b] = p
		b++
	}
	if b >= bufSize {
		writeIt(bufSize)
		outBuf[0] = outBuf[bufSize]
		b -= bufSize
	}
	bufPtr = b
}

@ @<함수들@>=
func putFour(x uint32) {
	b := bufPtr
	outBuf[b] = byte(x >> 24)
	outBuf[b+1] = byte(x >> 16)
	outBuf[b+2] = byte(x >> 8)
	outBuf[b+3] = byte(x)
	b += 4
	if b >= bufSize {
		writeIt(bufSize)
		copy(outBuf[:3], outBuf[bufSize:bufSize+3])
		b -= bufSize
	}
	bufPtr = b
}

@ 그러나 명령어 파일의 첫 여섯 바이트는 특별하다. 바이트~0은 세는 다항체 가운데 가장
큰 것의 칸 수 $n$이다. {\mc POLYSLAVE}는 |opSync|를 해석할 때 $1\le j\le n$에 대해
|count[j]|의 지금 값을 내놓는다.

바이트~1은 마지막 줄의 번호다. 이 번호가 $r$이면 {\mc POLYSLAVE}는 명령어 |opSync|~$r$을
해석한 뒤 끝낸다.

바이트 2--5는 |count| 배열의 원소 수를 (큰 쪽이 앞에 오게) 적는다.

처음에는 |s=t=0|이고 |count[0]=1|이며, $1\le j\le n$에 대해 |count[j]|는 $0$이라고 본다.

@<초기화한다@>=
filename = fmt.Sprintf("%.90s.ck", baseName)
{
	var err error
	if ckFile, err = os.Create(filename); err != nil {
		fatal("I can't open the checksum file")
	}
}
openIt()
outBuf[0] = byte(n)
outBuf[1] = byte(n + 2 - w)
bufPtr = 2
putFour(uint32(slaveSize))

@ 모두 끝나면 이렇게 한다.

@<버퍼를 비우고...@>=
if bufPtr != 0 {
	writeIt(bufPtr)
}
closeIt()

@ 출력의 대부분은 |basicInst| 루틴이 만든다. 원천 주소와 대상 주소가 바뀌었으면 그
차이를 한 바이트 명령어로, 너무 멀면 네 바이트 명령어로 알린다.

@<함수들@>=
func basicInst(op int, srcAddr, trgAddr int, count byte) {
	if verbose > 1 {
		if op == opClear {
			fmt.Fprintf(out, "{clear %d ->%d}\n", count, trgAddr)
		} else {
			fmt.Fprintf(out, "{%s %d %d->%d}\n", sym[op], count, srcAddr, trgAddr)
		}
	}
	del := srcAddr - curSrc
	if del > 0 && del < 256 {
		putInst(opIncSrc, byte(del))
	} else if del < 0 && del > -256 {
		putInst(opDecSrc, byte(-del))
	} else if del != 0 {
		putFour(uint32(srcAddr))
	}
	curSrc = srcAddr
	del = trgAddr - curTrg
	if del > 0 && del < 256 {
		putInst(opIncTrg, byte(del))
	} else if del < 0 && del > -256 {
		putInst(opDecTrg, byte(-del))
	} else if del != 0 {
		putFour(uint32(trgAddr + targBit))
	}
	curTrg = trgAddr
	putInst(byte(op), count)
}

@ @<전역 변수@>=
var (
	sym            = [4]string{"sync", "clear", "copy", "add"}
	curSrc, curTrg int // 슬레이브의 지금 원천 주소와 대상 주소
	verbose        = 0 // 디버깅할 때 $0$이 아니게 둔다
)

@* 연결성.
우리 앞의 가장 어려운 일은 잘라 낼 문턱을 정하는 방법을 알아내는 것이다. 곧
\.{0(00(00100-010-\caret/)00()0)0(-0} 같은 짜임이 주어졌을 때, 그것을 모두 잇고 적어도
주어진 수만큼의 줄로 더 뻗게 하려면 칸이 적어도 몇 개 더 필요할까? 앞에서 이 짜임은
이어지고 왼쪽 경계에 닿기 전에 적어도 16칸이 더 필요하다고 증명 없이 주장했다. 이제 그
주장을 증명하고, 일반적인 문제도 풀자.

어떤 경우는 쉽다. 이를테면 먼저 완전한 줄의 처음이나 끝에 있는 경우를 보자. 그러면
\.{00-)0(0--)00(--0} 같은 짜임에는 적어도 $3+4$칸이 더 차야 한다는 것이 분명하다. [혹시
분명하지 {\it 않다면}, 여기서 멈추고 분명해질 때까지 생각해 보라. 이것은 찬 칸들의 연결
성분 셋을 나타냄을 기억하라. 왼쪽 성분은 왼쪽 가장자리에 이어져 있고, 오른쪽 성분은
오른쪽 가장자리에 이어져 있으며, 가운데 성분은 홀로 서 있다.]

무늬가 $\.0^{g_0}\alpha_1\.0^{g_1}\alpha_2\ldots\.0^{g_{k-1}}\alpha_k\.0^{g_k}$와 같다고
하자. 여기서 각 $\alpha_j$는 \.(로 시작해 \.)로 끝나는 별개의 성분이다. 이를테면 흔한
$\alpha$는 \.{()}나 \.{(-)}나 \.{(-00--00-0-0)} 따위다. 이번에도 문제는 쉽게 풀린다.
성분 $\alpha_1$을 왼쪽 가장자리에 이으려면 $g_0+1$칸, $1\le j<k$에 대해 $\alpha_j$를
$\alpha_{j+1}$에 이으려면 $g_j+2$칸, $\alpha_k$를 오른쪽 가장자리에 이으려면 $g_k+1$칸을
차지해야 한다. 어떤 $\alpha_j$가 그저 홀로 선 성분 \.1이어도 같은 공식이 성립하되, 그런
$\alpha_j$마다 1을 뺄 수 있다. 이를테면 \.{0100(0-)00010(0)0}을 잇는 비용은
$2+4+5+3+2-2$다.

성분 $\alpha_1$이 이미 왼쪽 가장자리에 이어져 있으면 $g_0+1$을 아끼지만, $\alpha_1$이 \.1이면
그 덤은 받을 수 없다. 오른쪽에서도 비슷하다.

@ 성분들이 포개지면 상황이 더 흥미로워진다. 이를테면 $\alpha_1$, $\alpha_2$, \dots,
$\alpha_{k-1}$은 서로 다르지만 $\alpha_k$는 $\alpha_1$과 같은 성분이라 하자. 그러면 여전히
$\alpha_1$을 왼쪽에 잇는 데 $g_0+1$, $\alpha_k\equiv\alpha_1$을 오른쪽에 잇는 데 $g_k+1$을
치러야 한다. 그러나 이 새 경우에는 $1\le j<k$ 범위의 $j$ 하나를 마음대로 골라
$\alpha_j$와 $\alpha_{j+1}$을 이어지지 않은 채로 둘 수 있다. 그러면 위 공식에서
$g_j+2$를 아끼지만, $\alpha_j$나 $\alpha_{j+1}$의 길이가 1이었다면 덤을 한두 점 잃는다.
이를테면 짜임 \.{0(00010(0)00-0)00}은
$\.0^1\alpha_1\.0^3\alpha_2\.0^1\alpha_3\.0^2\alpha_4\.0^2$의 꼴로
$\alpha_1\equiv\alpha_4$이고 $\alpha_1$과 $\alpha_2$에서 덤을 받을 수 있는데, 잇는 방법이
셋이다. 성분 $\alpha_1$과 $\alpha_2$를 떼어 두면 $2+0+3+4+3-0$, $\alpha_2$와 $\alpha_3$을
떼어 두면 $2+5+0+4+3-1$, $\alpha_3$과 $\alpha_4$를 떼어 두면 $2+5+3+0+3-2$가 든다. 셋째가
가장 좋다. 가장 큰 틈 $\.0^3$을 떼어 두지 않는데도, 덤 2점을 지키기 때문이다.

@ 이제 짜임 \.{-00(010-010)00()00()00-}를 보자. 이것은 왼쪽과 오른쪽 가장자리에 이어져
있고, 부분 성분 \.{(010-010)}도 품고 있다. 그 부분 성분을 다루는 가장 좋은 방법은
그 아래 다섯 칸을 차지해 가운데 영역 \.{10-01}에 걸치는 것이다. 그러나 그러면 그림
전체를 잇는 데 $4+4+4$칸이 더 든다. 대신 부분 성분 안에서 여섯 칸을 써서 왼쪽의
\.{(01}과 오른쪽의 \.{10)}에 걸치면, 마무리에 $3+3+4$칸만 든다. 이처럼 둘레가 부분 성분
안의 가장 좋은 행동에 영향을 줄 수 있다.

이 예들은 일반적인 무늬
$\.0^{g_0}\alpha_1\.0^{g_1}\alpha_2\ldots\.0^{g_{k-1}}\alpha_k\.0^{g_k}$의 최소 연결 비용을
생각하는 한 가지 방법을 준다. 어떤 쌍 $(i,j)$에 대해 $\alpha_i$가 이미 $\alpha_j$에
이어져 있을 때, 먼저 $(g_0+1)+(g_1+2)+\cdots+(g_{k-1}+2)+(g_k+1)$을 매기고, 이어지지 않은
채로 남겨도 되는 틈 $g_j$의 항 몇을 빼는 것이다. 성분 $\alpha_1$이 왼쪽 가장자리에 이어져
있으면 $(g_0+1)$을 뺄 수 있고, $\alpha_k$가 오른쪽 가장자리에 이어져 있으면 $(g_k+1)$을
뺄 수 있다. 어떤 $j>i$에 대해 $\alpha_i\equiv\alpha_j$이고 성분 $\alpha_{i+1}$, \dots,
$\alpha_j$가 서로 이어져 있지 않으면, 항 $(g_i+2)$, \dots, $(g_{j-1}+2)$ 가운데 아무거나
하나를 뺄 수 있고, 그 뒤로는 $\alpha_i\ldots\alpha_j$를 더 빼는 데 {\it 한\/} 성분으로
다룬다. 끝으로 뺄 항들을 고른 뒤, 길이가 1인 $\alpha_j$ 가운데 $g_{j-1}$도 $g_j$도
떼어 두지 않은 것마다 덤을 받는다. (길이가 1이라는 것은 $\alpha_j$의 부호가 \.1이나
\.(나 \.)나 \.- 한 글자라는 뜻이다.)

@ 최소 연결 문제는 되부르는 전략으로 선형 시간에 풀 수 있다. 그러나 앞의 예들 때문에
조심해서 설계해야 한다. 열쇠가 되는 착상은 부분 성분마다 비용 넷 $c_{ij}$($0\le
i,j\le1$)를 매기는 것이다. 비용 $c_{ij}$는 성분 안의 모든 것을 잇는 데 필요한 앞으로의
찬 칸 수의 최솟값이다. 다만 $i=1$이면 맨 왼쪽 칸 아래에, $j=1$이면 맨 오른쪽 칸 아래에
칸이 있어야 한다는 조건이 붙는다. 그러면 $2\times2$ 행렬 $(c_{ij})$가 이 성분을 더 높은
수준에서 잇는 데 알아야 할 모든 것을 나타낸다.

\vskip1pt
\def\mx#1#2#3#4{{#1\,#2\choose#3\,#4}}
이를테면 한 글자짜리 성분의 비용 행렬은 $\mx0111$이고, 안에 부분 성분이 없는 여러
글자짜리 성분의 비용 행렬은 $\mx0112$다. (왼쪽 위의 0은 이미 이어져 있으니 잇는 데 칸이
필요 없다는 뜻이다. 그러나 둘레가 원하면 왼쪽이나 오른쪽에 ``갈고리''로 한두 칸을
차지해야 할 수 있다.)

\vskip1pt
\def\gmp#1#2{\mathbin{^#1_#2}}
아래 알고리즘의 바탕 이론은 {\it 최소-합 행렬 곱셈\/} $C=AB$로 이해하는 것이 가장
좋다. 여기서 $c_{ij}=\min_k(a_{ik}+b_{kj})$다. (크누스는 이 곱셈에 $AB$ 대신
$A\gmp\land+B$ 같은 특별한 기호를 써야 했을지도 모른다고 한다. 이를테면 {\sl The Art of
Computer Programming\/} 묶음 1의 연습 문제 1.3.1$'$--32를 보라. 그러나 그러면 아래의
수많은 식이 어지러워지고, 이 프로그램에서는 보통의 행렬 곱셈을 쓸 일이 없다. 그래서
아래 논의에서는 최소-합 곱셈에 따로 표시를 하지 않는다.)

\vskip1pt
\def\mtx#1#2#3#4{\hbox{$\bigl({#1\atop#2}\ {#3\atop#4}\bigr)$}}
행렬 \mtx\infty\infty\infty g를 $X_g$라 하자. 그러면 $\alpha_1$, \dots, $\alpha_k$가
비용 행렬이 저마다 $A_1$, \dots,~$A_k$인 서로 다른 부분 성분일 때,
$\.0^{g_0}\alpha_1\.0^{g_1}\alpha_2\ldots\.0^{g_{k-1}}\alpha_k\.0^{g_k}$를 잇고 왼쪽과
오른쪽 가장자리에 닿게 하는 비용은
$$OX_{g_0}A_1X_{g_1}\ldots X_{g_{k-1}}A_kX_{g_k}O,\qquad \qquad
\hbox{여기서 $O=\mtx0000$}$$
의 왼쪽 위 원소다. 행렬 $X_g$는 본질적으로 ``아래의 $g$칸을 차지하고, 그 칸들의 왼쪽과
오른쪽 칸도 차 있기를 요구하라''는 뜻이기 때문이다. 이 규칙은 각 행렬 $A_j$가
$\mx0112$인 특수한 경우에 $(g_0+1)+(g_1+2)+\cdots+(g_{k-1}+2)+(g_k+1)$을 주고, $A_j$를
$\mx0111$로 바꿀 때마다 덤 1을 준다. 또 $X_gX_h=X_{g+h}$임에도 주목하라. 그러니 짜임의
\.0 하나하나를 $X_1$을 곱하는 것으로 볼 수 있다.

@ 이미 서로 이어진 부분 성분 $\alpha$와 $\beta$의 비용 행렬이 저마다 $A$와~$B$이면,
한 성분으로서의 $\alpha\,\.0^g\beta$의 비용 행렬은 $ANB$다. 여기서
$N=\mtx0\infty\infty\infty$는 ``$\.0^g$ 아래에는 아무것도 차지하지 말고, 그 틈의 왼쪽과
오른쪽 칸이 차 있기를 고집하지도 말라''는 뜻의 행렬이다. 이를테면 이 규칙은 마땅히
$\mx0111N\mx0111=\mx0112$를 준다.

일반적으로, 부분 성분 $\alpha_0$, $\alpha_1$, \dots, $\alpha_k$가 서로 다르되
$\alpha_0$만 이미 $\alpha_k$에 이어져 있다고 하자. 그러면 한 부분 성분으로서의
$\alpha_0\.0^{g_1}\alpha_1\ldots\alpha_{k-1}\.0^{g_k}\alpha_k$의 비용 행렬은 개별 비용
행렬 $A_0$, $A_1$, \dots, $A_k$로
$$\min_{1\le j\le k}\bigl(A_0X_{g_1}\ldots X_{g_{j-1}}A_{j-1}NA_j
   X_{g_{j+1}}\ldots X_{g_k}A_k\bigr)   \eqno(**)$$
와 같이 나타낼 수 있다. 틈 $\.0^{g_j}$ 가운데 아무거나 하나를 이어지지 않은 채로 둘 수
있기 때문이다. 규칙 $(**)$가 되부르는 알고리즘을 돌게 하는 기본 원리다.

@ 지금까지는 간단히 하려고 줄의 끝에 있다고 가정했다. 그러나 부분 줄을 채우는 곳
근처에서는 틈 $\.0^g$가 $\.0^a\caret/\.0^b$일 수도 있다. 다행히 같은 이론이 조금만
바꾸어 들어맞는다. 행렬 $X_g=X_{a+b}$ 대신, $a>0$이면 $X_{a+b+1}$을, $a=0$이면
$Y_b=\mtx\infty\infty b\infty$를 쓴다. 그리고 $a$나 $b$나 둘 다 $0$일 수 있다. 행렬 $Y_b$는
``$\.0^b$ 아래 칸들을 차지하고, 오른쪽 다음 칸(왼쪽은 아니어도 된다)도 차 있기를
요구하라''는 뜻이다. 그리고 $a>0$일 때 $X_{a+b+1}$의 덤 1은, 새로 찬 칸 하나가 $r+1$번째 줄에
닿으려면 지금 줄 $r$을 지나야 하기 때문에 필요하다.

@ 최소 연결 비용을 셈한 뒤에는 $w\times w$ 정사각형에 걸치도록 늘이는 비용도 더해야 할
수 있다. 곧 $r$번째 줄이 부분적으로 차 있고 $r-1$번째 줄은 다 찼으며 $r<w$이면, 최소
연결을 $r+1$번째 줄의 칸 하나 이상으로 이룰 수 있을 때는 $w-r-1$칸을, 그렇지 않으면
$w-r$칸을 더해야 한다.

이를테면 짜임 \.{-0\caret/010)00}을 보자. 이것을 잇는 가장 좋은 방법은 \.{10)00} 아래에
오는 $r$번째 줄의 다섯 칸을 차지하는 것이다. 그러나 그러면 늘이는 데 $w-r$칸이 더
필요하다. 한편 \.{-0\caret/010000)00} 같은 짜임에는 여덟 칸으로 잇는 본질적으로 다른
방법이 둘 있고, $r+1$번째 줄의 칸을 쓰는 쪽을 골라야 한다. (\.{-0\caret/01000)00} 같은
짜임은 $r+1$번째 줄을 쓰지 않고 일곱 칸으로, 그 줄을 써서 여덟 칸으로 이을 수 있으니
어느 쪽이든 같다.)

짜임 \.{-01\caret/00-}와 \.{-01\caret/00)0(}도 우리 알고리즘이 제대로 다루어야 할
흥미로운 득실 관계를 보인다.

여기서 택한 해법은 \qcaret/ 뒤의 칸 비용에 $\epsilon$을 더해, $r$번째 줄에 새로 차는
칸이 $r+1$번째 줄의 칸보다 조금 더 비싸게 하는 것이다. 그러면 필요할 때 뒤의 칸들이 더
매력적이 된다.

@ 꽤 깔끔한 이론을 얻었으니 이제 실천에 옮길 때다. 첫걸음은 알파벳 \.0, \.1, \.(,
\.), \.-의 부호를 정하는 것이고, 여기에 ``줄의 가장자리'' 글자를 더한다. 다음 부호는
글자가 \.-나 \.)인지 쉽게 알아보도록 설계했다.

@<상수@>=
const (
	zero = iota // \.0
	one         // \.1
	rt          // \.)
	mid         // \.-
	lft         // \.(
	eol         // 짜임 문자열의 가장자리 구분자
)

@ 두 번째 비트가 켜져 있으면 \.-나 \.)다. 여러 곳에서 쓰므로 함수로 둔다.

@<함수들@>=
func midOrRt(x int) bool {
	return x&2 == 2
}

@ @<전역 변수@>=
var (
	decode  = [5]byte{'0', '1', ')', '-', '('}
	reflect = [5]int{zero, one, lft, mid, rt}
)

@ 비용 행렬과 짜임의 최소 연결 비용을 나타내는 답에서는 $a+b\epsilon$을 짧은 정수로
나타낸다. 크누스는 $a$와 $b$가 27을 넘지 않으리라는 것을 안다고 했다.

@<상수@>=
const (
	unity   = 1 << 8
	epsilon = 1
	uunity  = unity + epsilon
)

@ @<함수들@>=
func intPart(x int) int { return x >> 8 }
func epsPart(x int) int { return x & 0xff }

@ @<자료형@>=
type cost = uint16 // $a+b\epsilon$을 |(a<<8)+b|로 나타낸다

type costMatrix struct {
	c [2][2]cost
}

@ 비용 행렬 $X_g=\mtx\infty\infty\infty {g_{\mathstrut}}$와 $Y_g=\mtx\infty\infty
g\infty$를 가려야 하고, 짜임이 이미 왼쪽 가장자리에 이어져 있을 때 생기는 셋째 경우도
있다.

@<상수@>=
const (
	ytyp = iota
	xtyp
	otyp
)

@ 비용 행렬의 기본 연산 몇 가지를 쉬운 함수로 둔다.

@<함수들@>=
func aNB(a, b costMatrix) costMatrix { // $A N B$를 셈한다
	var c costMatrix
	c.c[0][0] = a.c[0][0] + b.c[0][0]
	c.c[0][1] = a.c[0][0] + b.c[0][1]
	c.c[1][0] = a.c[1][0] + b.c[0][0]
	c.c[1][1] = a.c[1][0] + b.c[0][1]
	return c
}

@ 틈의 종류 |typ|에 따라 $A X_{g\,}B$나 $A Y_{g\,} B$를 셈하거나 $B$를 그대로 돌려준다.

@<함수들@>=
func aXB(a, b costMatrix, typ int, g cost) costMatrix {
	var c costMatrix
	if typ == otyp {
		return b
	}
	c.c[0][0] = a.c[0][typ] + g + b.c[1][0]
	c.c[0][1] = a.c[0][typ] + g + b.c[1][1]
	c.c[1][0] = a.c[1][typ] + g + b.c[1][0]
	c.c[1][1] = a.c[1][typ] + g + b.c[1][1]
	return c
}

@ @<함수들@>=
func minMat(a *costMatrix, b costMatrix) { // $A=\min(A,B)$로 둔다
	for i := 0; i < 2; i++ {
		for j := 0; j < 2; j++ {
			if a.c[i][j] > b.c[i][j] {
				a.c[i][j] = b.c[i][j]
			}
		}
	}
}

@ 알고리즘은 본래 되부르는 것이지만, 간단한 대수 연산만 하므로 스택을 써서 반복으로
구현한다. 스택 항목 하나는 대개 \.0의 열 하나와 아직 다 훑지 않은 부분 성분 하나를
나타낸다. \.0의 열은 비용 행렬 $X_g$나 $Y_g$로, 다 훑지 않은 부분 성분은 식 $(**)$를
부분적으로 계산한 것으로 나타낸다.

그러나 스택 수준~0에는 다 훑지 않은 부분 성분이 없고 |closedCost| 필드만 쓴다. 이
필드는 지금까지 훑은 모든 성분의 비용 행렬에 해당한다.

@<자료형@>=
type stackEntry struct {
	gap        cost       // 앞 틈에서 덮을 \.0들
	gapTyp     int        // 앞 틈의 종류(|xtyp|나 |ytyp|나 |otyp|)
	closedCost costMatrix // 틈 없는 비용 행렬
	openCost   costMatrix // 틈 하나를 떼어 둘 수 있는 비용 행렬
}

@ 주어진 짜임 문자열은 |c[1]|부터 |c[w]|까지에 들어 있고, |c[0]|과 |c[w+1]|은 |eol|로
둔다.

@<전역 변수@>=
var (
	c   [64]int        // 지금 짜임 문자열의 부호들
	stk [64]stackEntry // 부분적으로 계산한 비용들
)

@ 이 프로그램은 거의 똑같은 두 단계로 돈다. 문자열에서 |rowEnd|를 만나기 전에는 연결 칸의 비용이
|unity|이지만, 그 뒤로는 |unity+epsilon|이다. 크누스는 코드를 매끄럽게 하려고 자기 논문
``Structured programming with |goto| statements''의 예~7에서 설명한 요령을 쓴다. 곧 거의
똑같은 코드를 두 벌 만들어, 한 벌은 |k==rowEnd| 전에, 다른 한 벌은 그 뒤에 하는 일을
맡긴다. 첫 벌은 |k==rowEnd|를 알아차리자마자 둘째 벌로 뛴다. 그러면 온갖 조건부 코드를
피하고 ``변수''를 ``상수''로 만들 수 있다. 다만 한 반복문에서 다른 반복문의 몸통 안으로
뛰어드는, 조금 당황스러운 면이 있다.

크누스는 \.{(0--00-)} 같은 부분 성분을 특별히 빨리 다루면 이 프로그램이 더 빨라질 수
있다고 했다. 그 부분 성분은 우리가 셈하는 연결성 척도에 관한 한 \.{()}와 같기
때문이다. 그러나 이 프로그램을 더 단순하고 검증하기 쉽게 하려고 일부러 까다로운
최적화는 피했다. 한편 \.{(---)} 같은 \.0 없는 꼴은 \.{()}로, \.{(-\caret/--)}는
\.{(\caret/)}로 줄인다. 이런 최적화가 꼭 필요하지는 않지만 워낙 자주 나와서 참을 수
없었다고 한다.

다음 루틴의 |rowEnd|는 \qcaret/ 바로 다음 글자를 가리킨다.

@ \.{Go}의 |goto|는 블록 안으로 뛰어들 수 없다. 그런데 원본은 첫 단계의 묶기 반복문에서
둘째 단계 |switch|의 |case| 몸통 안으로 뛴다. 그래서 이 판은 두 단계의 |switch|에서
|case|마다 몸통을 함수 맨 바깥 수준의 이름표로 펴 놓았다. 문장 |switch|는 어느 이름표로
갈지만 고르고, 몸통 사이의 원래 흐름(\CEE/에서 한 |case|가 다음 |case|로 흘러드는 것)은
이름표의 차례로 지킨다. 모든 지역 변수는 함수 첫머리에 선언해 |goto|가 선언을 건너뛰지
않게 했다.

함수 |connectivity|는 두 곳에서 부르므로 함수로 둔다.

@<함수들@>=
func connectivity(rowEnd int) cost {
	var k int    // 문자열 안의 우리 자리
	var s int    // 스택에서 열린 항목의 수
	var g int    // 지금 틈의 크기
	var typ int  // 그 종류
	var open int // 앞 토큰이 \.(나 \.-였으면 $0$이 아니다
	var cm, acm costMatrix
	@<연결성을 셈할 준비를 한다@>@;
scanZeros0:
	@<첫 단계에서 \.0들을 훑는다@>@;
scanTokens0:
	@<첫 단계에서 $0$ 아닌 토큰 묶음을 훑는다@>@;
scanZeros1:
	@<둘째 단계에서 \.0들을 훑는다@>@;
scanTokens1:
	@<둘째 단계에서 $0$ 아닌 토큰 묶음을 훑는다@>@;
	@<연결성 한계 계산을 마치고 답을 돌려준다@>@;
}

@ 실제로는 |rowEnd|가 $0$일 일이 없다. 그러나 크누스는 코드가 한 줄만 더 들기에 그
경우에도 바르게 돌도록 알고리즘을 일반적으로 만들었다.

@<연결성을 셈할 준비를 한다@>=
s, open = 0, 0
stk[0].closedCost = zeroCost
k = 1
if midOrRt(c[1]) {
	g, typ = 0, xtyp // 왼쪽 가장자리에서는 |xtyp|와 |ytyp|가 같다
	if rowEnd == 1 {
		goto scanTokens1
	}
	goto scanTokens0
}

@ @<첫 단계에서 \.0들을 훑는다@>=
if k == rowEnd {
	g, typ = 0, ytyp
	goto scanZeros1x
}
if c[k] != zero {
	fatal("Syntax error, 0 expected")
}
typ, g = xtyp, unity
k++
for c[k] == zero {
	if k == rowEnd {
		g += unity + uunity // 두 줄에 걸친 것을 바로잡는다
		k++
		goto scanZeros1x
	}
	g += unity
	k++
}
if k == rowEnd {
	g += unity
	goto scanTokens1
}

@ 토큰 하나를 읽고 그 종류에 따라 이름표를 고른다. \.(나 \.- 뒤에 \.-$^*$\.)가 오면
한 토큰으로 묶는다.

@<첫 단계에서 $0$ 아닌...@>=
cm = baseCost0
k++
switch c[k-1] {
case lft:
	if !midOrRt(c[k]) {
		goto scanOpen0
	}
	goto lft0
case one:
	goto one0
case mid:
	if !midOrRt(c[k]) {
		goto scanMid0
	}
	goto mid0
case rt:
	goto rt0
case eol:
	goto scanEol0
default:
fatal("Illegal code")
}
@<첫 단계에서 토큰의 몸통을 처리한다@>@;
@<첫 단계에서 열린 토큰을 마무리한다@>@;

@ 토큰마다 묶고 덧붙이고 닫는다. 이름표 사이의 흐름은 원본의 |case|가 다음 |case|로
흘러드는 것과 같다.

@<첫 단계에서 토큰의 몸통을 처리한다@>=
lft0:
@<첫 단계에서 \.( 뒤의 $\.-^*\.)$를 한 토큰으로 묶는다@>@;
if c[k-1] != rt {
	goto scanOpen0
}
one0:
@<|cm|을 지금의 부분 성분에 덧붙인다@>@;
open = 0
goto scanZeros0
mid0:
@<첫 단계에서 \.- 뒤의 $\.-^*\.)$를 한 토큰으로 묶는다@>@;
if c[k-1] != rt {
	goto scanMid0
}
rt0:
@<\.)를 처리한다@>@;
open = 0
goto scanZeros0

@ 열린 토큰은 스택에 올리고, 줄 끝인지 살핀다.

@<첫 단계에서 열린 토큰을 마무리한다@>=
scanOpen0:
@<|lft| 처리를 마친다@>@;
goto checkEol0
scanMid0:
@<|mid| 처리를 마친다@>@;
checkEol0:
open = 1
if c[k] != eol {
	goto scanZeros0
}
if k == rowEnd {
	goto scanEol1
}
scanEol0:
fatal("Row end missed")

@ 스택이 비어 있으면 \.)는 왼쪽 가장자리에 이어진 성분을 닫는다.

@<\.)를 처리한다@>=
if s == 0 {
	if stk[0].closedCost.c[1][1] != 0 {
		fatal("Unmatched )")
	}
	stk[0].closedCost = cm // 이미 왼쪽 가장자리에 이어져 있다
} else {
	@<|cm|을 |stk[s].openCost|에 덧붙인다@>@;
	@<스택의 맨 위 두 항목을 합친다@>@;
}

@ @<전역 변수@>=
var (
	zeroCost  = costMatrix{}                                             // $0\,0\choose0\,0$
	baseCost0 = costMatrix{[2][2]cost{{0, unity}, {unity, unity}}}       // $0\,1\choose1\,1$
	baseCost1 = costMatrix{[2][2]cost{{0, uunity}, {uunity, uunity}}}    // $\bigl({0\atop1+\epsilon}\ {1+\epsilon\atop1+\epsilon}\bigr)$
)

@ 묶는 도중에 \qcaret/를 만나면 둘째 단계의 묶기로 넘어간다.

@<첫 단계에서 \.( 뒤의...@>=
for {
	if k == rowEnd {
		goto scanTokens1a
	}
	k++
	if c[k-1] == rt || !midOrRt(c[k]) {
		break
	}
}
cm.c[1][1] = unity + unity // 이제 |cm|은 $0\,1\choose1\,2$다

@ @<첫 단계에서 \.- 뒤의...@>=
for {
	if k == rowEnd {
		goto scanTokens1b
	}
	k++
	if c[k-1] == rt || !midOrRt(c[k]) {
		break
	}
}
cm.c[1][1] = unity + unity // 이제 |cm|은 $0\,1\choose1\,2$다

@ @<|cm|을 지금의 부분 성분에 덧붙인다@>=
if s != 0 {
	@<|cm|을 |stk[s].openCost|에...@>@;
}
stk[s].closedCost = aXB(stk[s].closedCost, cm, typ, cost(g))

@ @<|cm|을 |stk[s].openCost|에...@>=
acm = aNB(stk[s].closedCost, cm)
stk[s].openCost = aXB(stk[s].openCost, cm, typ, cost(g))
minMat(&stk[s].openCost, acm)

@ @<스택의 맨 위 두 항목을 합친다@>=
s--
if s != 0 {
	acm = aNB(stk[s].closedCost, stk[s+1].openCost)
	stk[s].openCost = aXB(stk[s].openCost, stk[s+1].openCost, stk[s+1].gapTyp, stk[s+1].gap)
	minMat(&stk[s].openCost, acm)
}
stk[s].closedCost = aXB(stk[s].closedCost, stk[s+1].openCost, stk[s+1].gapTyp, stk[s+1].gap)

@ @<|lft| 처리를 마친다@>=
s++
stk[s].gapTyp = typ
stk[s].gap = cost(g)
stk[s].closedCost, stk[s].openCost = cm, cm

@ @<|mid| 처리를 마친다@>=
if s == 0 {
	if stk[0].closedCost.c[1][1] != 0 {
		fatal("Unmatched -")
	}
	s = 1
	stk[1].gapTyp = otyp
	stk[1].closedCost, stk[1].openCost = cm, cm
} else {
	@<|cm|을 |stk[s].openCost|에...@>@;
	stk[s].closedCost = stk[s].openCost
}

@ @<둘째 단계에서 \.0들을...@>=
if c[k] != zero {
	fatal("Syntax error, 0 expected")
}
typ, g = xtyp, uunity
k++
scanZeros1x:
for c[k] == zero {
	g += uunity
	k++
}

@ 둘째 단계는 첫 단계와 같되 비용이 |uunity|이고, \qcaret/를 살피지 않는다.

@<둘째 단계에서 $0$ 아닌...@>=
cm = baseCost1
k++
switch c[k-1] {
case lft:
	if !midOrRt(c[k]) {
		goto scanOpen1
	}
	goto scanTokens1a
case one:
	goto one1
case mid:
	if !midOrRt(c[k]) {
		goto scanMid1
	}
	goto scanTokens1b
case rt:
	goto rt1
case eol:
	goto scanEol1
default:
fatal("Illegal code")
}
@<둘째 단계에서 토큰의 몸통을 처리한다@>@;
@<둘째 단계에서 열린 토큰을 마무리한다@>@;

@ 토큰마다 묶고 덧붙이고 닫는다. 이름표 사이의 흐름은 원본의 |case|가 다음 |case|로
흘러드는 것과 같다.

@<둘째 단계에서 토큰의 몸통을 처리한다@>=
scanTokens1a:
@<둘째 단계에서 $\.-^*\.)$를 한 토큰으로 묶는다@>@;
if c[k-1] != rt {
	goto scanOpen1
}
one1:
@<|cm|을 지금의 부분 성분에 덧붙인다@>@;
open = 0
goto scanZeros1
scanTokens1b:
@<둘째 단계에서 $\.-^*\.)$를 한 토큰으로 묶는다@>@;
if c[k-1] != rt {
	goto scanMid1
}
rt1:
@<\.)를 처리한다@>@;
open = 0
goto scanZeros1

@ 열린 토큰은 스택에 올리고, 줄 끝인지 살핀다.

@<둘째 단계에서 열린 토큰을 마무리한다@>=
scanOpen1:
@<|lft| 처리를 마친다@>@;
goto checkEol1
scanMid1:
@<|mid| 처리를 마친다@>@;
checkEol1:
open = 1
if c[k] != eol {
	goto scanZeros1
}

@ 원본은 \.(와 \.- 뒤의 묶기를 둘째 단계에서도 따로 적었지만 두 절의 내용이 같으므로,
이 판은 한 절로 두고 두 곳에 끼운다.

@<둘째 단계에서 $\.-^*\.)$를...@>=
for {
	k++
	if c[k-1] == rt || !midOrRt(c[k]) {
		break
	}
}
cm.c[0][1] = uunity
cm.c[1][1] += uunity
	// 이제 |cm|은 $\bigl({0\atop1}\ {1+\epsilon\atop2+\epsilon}\bigr)$이거나
	// $\bigl({0\atop1+\epsilon}\ {1+\epsilon\atop2+2\epsilon}\bigr)$다

@ 오른쪽 가장자리에 닿는 비용은 |g|가 $b+b\epsilon$의 꼴이면 |g|이지만, 채우지 않은 줄을
채울 때 생기는 예외적인 꼴 $a+1+b+b\epsilon$이면 $a+b$다.

@<연결성 한계 계산을 마치고...@>=
scanEol1:
if open != 0 {
	@<스택의 맨 위 두 항목을 합친다@>@;
	if s != 0 {
		fatal("Missing )")
	}
	return stk[0].closedCost.c[0][0]
}
if s != 0 { // 오른쪽 가장자리에 닿아야 한다
	fatal("Missing )")
}
if intPart(g) == epsPart(g) {
	return stk[0].closedCost.c[0][typ] + cost(g)
}
return stk[0].closedCost.c[0][1] + cost((intPart(g)-1)<<8)

@* 자료 구조.
크기 $n$이 클 때 $n$-오미노를 효율적으로 세려면, 가장 귀한 자원은 쓸 수 있는 임의 접근
메모리임이 드러난다. 크누스는 살아 있는 짜임 하나에 메모리가 적어도 20바이트 필요하다고
보았고, 그러면 기가바이트당 살아 있는 짜임은 약 5천만 개로 묶인다. 그런 사정이라
공간을 아끼려고 결과를 몇 번 다시 셈해도 괜찮다. 이를테면 많은 짜임이 여러 줄에서
나타나는데, 이 프로그램은 나타날 때마다 그 연결 비용을 다시 셈한다.

주 계산 반복문은 살 수 있는 짜임 $\alpha$를 하나 꺼내 그 뒤 둘 $\alpha_0$과 $\alpha_1$을
보는 것이다. 뒤 짜임 $\alpha_0$과 $\alpha_1$의 |rowEnd|(\qcaret/의 자리)는 $\alpha$의 것보다 하나
크다. 그리고 $\alpha_0$은 새 칸을 비워 두고 $\alpha_1$은 그 칸을 차지한다.

뒤 짜임 $\alpha_0$이나 $\alpha_1$을 전에 본 적이 있으면 시간을 번다. 해시 표로 그것들이 이미 본
것인지 알아낸다. 처음 보는 짜임은 |connectivity| 한계를 거쳐, 살 수 있을 때에만
계산에 받아들인다.

짜임 $\alpha$마다 {\it 생성 함수\/} $g(\alpha)$가 딸린다. 이를테면 생성 함수
$5z^8+2z^9$는 칸 8개를 차지하고 $\alpha$에 이르는 방법이 5가지, 칸 9개를 차지하고
이르는 방법이 2가지라는 뜻이다. 뒤 짜임 $\alpha_0$이 살 수 있으면 $g(\alpha)$를 $g(\alpha_0)$에
더하고, $\alpha_1$이 살 수 있으면 $zg(\alpha)$를 $g(\alpha_1)$에 더한다. 그 뒤로는
$\alpha$와 $g(\alpha)$를 잊고 귀한 메모리를 되찾는다.

사실 생성 함수 $g(\alpha)$를 다룰 공간조차 넉넉하지 않다. 그래서 이 프로그램은 다른
프로그램 {\mc POLYSLAVE}가 해석할 명령어 열을 엮어 내놓는다. 그 프로그램은 해시 표나
다른 공간을 많이 먹는 자료 없이 실제 덧셈을 나중에 한다.

@ 알고리즘은 $r=1$번째 줄부터 줄마다 나아가며, 살 수 있는 짜임이 남지 않을 때까지
계속한다. 줄마다 기존 짜임들을 $w$번 완전히 훑으며, |rowEnd|가 $0$부터 $w-1$까지
움직인다. 훑기마다 앞 훑기에서 만든 짜임을 모두 처리하고 버리며, 어떤 차례로 처리해도
된다. 그래서 메모리를 거의 최대로 효율적으로 쓰는 ``굴리기'' 전략을 쓴다. 한 훑기가
$N=|confSize|$개 칸으로 된 메모리 풀의 첫 $M$칸 $\alpha^{(1)}$, \dots, $\alpha^{(M)}$에
짜임 $M$개를 만들었다고 하자. 먼저 $\alpha^{(M)}$의 뒤 $\alpha^{(M)}_0$과
$\alpha^{(M)}_1$을 찾아 칸 $N$과 $N-1$에 둔다. 그러면 칸~$M$이 비고, $\alpha^{(M-1)}$로
넘어간다. 그렇게 하면 $N$칸이 모두 쓰일 때에만 메모리가 모자란다. 다음 훑기에서는
방향을 뒤집어 칸을 $N$에서 아래로가 아니라 1에서 위로 채운다.

같은 전략으로 {\mc POLYSLAVE} 프로그램에서 생성 함수에 필요한 메모리도 쉽게 잡을 수
있다. 사실 생성 함수마다 차지하는 바이트 수가 다른데도 이 굴리기 할당은 메모리를 거의
완벽하게 채운다. (생성 함수가 생각보다 많은 바이트를 요구하면 가끔 구멍이 생기지만,
대체로 꽤 만족스럽다.)

@ 다섯 글자 알파벳으로 된 짜임 $c_0\ldots c_{w-1}$은 여덟 바이트면 담을 수 있다.
부등식 $5^{27}<2^{64}<5^{28}$이 성립하고 $w$가 많아야 27이라고 가정하기 때문이다.

원본은 \KW{cstring}을 공용체로 정의해, 해시 함수가 낱낱의 바이트를 읽으면서도 묶고 풀기는
5진법이나 8진법으로 할 수 있게 했다. 그래서 해시 함수의 값은 큰 쪽 우선 기계와 작은 쪽
우선 기계에서 다르다(크누스는 상관없다고 했다). 해시 값은 명령어 파일에는 영향을 주지
않지만, 해시 사슬 길이의 도수 분포로 표준 출력에 드러난다. 이 판은 원본이 작은 쪽 우선
기계에서 보는 바이트 차례를 따른다.

@<자료형@>=
type cstring struct {
	h, l uint32 // 위쪽 절반과 아래쪽 절반
}

@ 함수 |packit|은 배열 |c|의 부호들로 \KW{cstring}을 만든다. 지금은 |w|가 많아야 23이라고
가정하므로, 한 네 바이트에는 8진법으로 부호 10개를, 다른 네 바이트에는 5진법으로 부호
13개를 넣을 수 있다. 더 큰 |w|를 위한 판에서는 두 네 바이트에 모두 5진법을 쓰거나,
여덟 바이트에 순수한 5진법을 쓸 수 있을 것이다.

@<함수들@>=
func packit() cstring {
	var packed cstring
	k, j := int(w)-1, uint32(c[w])
	if w > 10 {
		for ; k > 10; k-- {
			j = j<<2 + j + uint32(c[k])
		}
		packed.h = j
		k, j = 9, uint32(c[10])
	}
	for ; k > 0; k-- {
		j = j<<3 + uint32(c[k])
	}
	packed.l = j
	return packed
}

@ 묶은 것은 풀 수 있다. 이 루틴은 새 원천 짜임 $\alpha$를 풀 때만 쓰므로, 결과를 두
배열 |sc|와 |c|에 넣는다.

크누스는 5로 나누는 순수한 이진 방법({\sl TAOCP\/} 연습 문제 4.4--9)이 어떤 기계에서는
나눗셈보다 빠르지만 자기 컴퓨터에서는 그냥 `/5'가 가장 좋았다고 적었다. 또 `|x*5|'가
`$(x<<2)+x$'보다 느리고 `|y-5*x|'는 `|y-((x<<2)+x)|'보다 빠른 까닭은 파이프라인의 어떤
변덕일 것이라며, 지금 속도면 됐으니 그런 수수께끼는 풀지 않고 두겠다고 했다.

@<함수들@>=
func unpackit(s cstring) {
	var k int
	var j uint32
	if w > 10 {
		for k, j = 1, s.l; k < 10; k++ {
			sc[k] = int(j & 7)
			c[k] = sc[k]
			j >>= 3
		}
		sc[10], c[10] = int(j), int(j)
		for k, j = 11, s.h; k < int(w); k++ {
			q := j / 5
			sc[k] = int(j - 5*q)
			c[k] = sc[k]
			j = q
		}
	} else {
		for k, j = 1, s.l; k < int(w); k++ {
			sc[k] = int(j & 7)
			c[k] = sc[k]
			j >>= 3
		}
	}
	sc[k], c[k] = int(j), int(j)
}

@ @<전역 변수@>=
var sc [64]int // 지금 원천 짜임의 부호들

@ @<초기화한다@>=
c[0], sc[0], c[w+1], sc[w+1] = eol, eol, eol, eol

@ 짜임을 찍는다. 자리 |rowEnd| 앞에 \qcaret/ 대신 `\.\^'를 찍는다.

@<함수들@>=
func printConfig(rowEnd int) {
	for k := 1; k <= int(w); k++ {
		if rowEnd == k {
			fmt.Fprintf(out, "^")
		}
		if c[k] < eol {
			fmt.Fprintf(out, "%c", decode[c[k]])
		} else {
			fmt.Fprintf(out, "?")
		}
	}
}

@ 짜임은 세 상태 가운데 하나다. 보통은 생성 함수를 카운터 열로 나타내는 |active|다.
그러나 처음에는 카운터 공간만 잡고 아직 $0$으로 지우지 않은 |raw|다. 대상 짜임이 더는
쓰이지 않아 메모리 공간을 되돌려 다시 쓸 수 있게 되면 |deleted|로 표시한다.

@<상수@>=
const (
	active = iota
	raw
	deleted
)

@ 짜임 하나를 나타내는 귀한 20바이트다. 굴리기 전략 덕에 연결 필드 하나로 버틴다.

원본은 생성 함수의 지수 |lo|, |hi|, |lim|을 \.{char}에 담는다. 이 기계에서 \.{char}는
부호가 있으니 127을 넘으면 음수가 된다. 그런데 명령줄 검사는 $n\le2w+126$까지 받아 준다.
원본에 $w=2$, $n=127$을 주면 $\alpha_1$을 만들며 |hi|를 늘리다가 128이 $-128$이 되고,
통계를 낼 때 |chist[hi-lo]|가 |chist[-128]|을 짚어 버스 오류로 죽는다.
\.{AddressSanitizer}는 이것을 배열 밖 접근으로 잡는다. 지수는 $0$부터 $n+1\le173$까지이므로
이 판은 부호 없는 바이트 \.{uint8}에 담는다. 크기는 그대로 20바이트다.

원본의 연결 필드는 포인터다. 이 판은 짜임 배열 |conf|의 첨자를 \.{int32}로 담고, 없음은
$-1$로 나타낸다. 원천과 대상을 가리키는 |src|와 |trg|도 첨자다. 그러면 원본의 포인터
뺄셈 |src-trg|는 첨자 뺄셈이 되고, |trg==conf|는 |trg==0|이 된다.

@<자료형@>=
type config struct {
	s     cstring // 짜임의 이름
	addr  uint32  // 슬레이브가 생성 함수를 두는 곳
	link  int32   // 해시 사슬이나 구멍 목록의 다음 항목
	lo    uint8   // 지금 생성 함수에서 $z$의 가장 작은 지수
	hi    uint8   // 지금 생성 함수에서 $z$의 가장 큰 지수
	lim   uint8   // 대상이라면, 살 수 있는 $z$의 가장 큰 지수
	state uint8   // |active|, |raw|, |deleted|
}

@ @<초기화한다@>=
conf = make([]config, confSize)
confEnd = int(confSize)

@ 높은 수준의 주 루틴 |update|는 짜임~|p|의 생성 함수에서 |p.lo|부터 |hi|까지의 항을
짜임~|q|의 생성 함수에 더한다. 특수한 경우 |q==nil|은 완성된 다항체의 카운터를 고치는 데
쓴다.

@<함수들@>=
func update(p, q *config, hi int) {
	cnt := byte(hi + 1 - int(p.lo))
	if q == nil {
		basicInst(opAdd, int(p.addr), int(p.lo), cnt)
	} else if q.state == raw {
		q.state = active
		if q.lo != p.lo || int(q.hi) != hi {
			basicInst(opClear, curSrc, int(q.addr), byte(int(q.hi)+1-int(q.lo)))
		}
		basicInst(opCopy, int(p.addr), int(q.addr)+int(p.lo)-int(q.lo), cnt)
	} else {
		basicInst(opAdd, int(p.addr), int(q.addr)+int(p.lo)-int(q.lo), cnt)
	}
}

@ 열쇠 비트가 대개 $0$이므로, 좋은 해시 함수를 얻으려고 ``보편 해싱''({\sl TAOCP\/} 연습
문제 6.4--72)을 쓴다. 바이트 차례는 앞에서 말했듯이 원본이 작은 쪽 우선 기계에서 보는
것, 곧 |h|의 네 바이트를 낮은 것부터, 이어서 |l|의 네 바이트를 낮은 것부터다.

@<상수@>=
const (
	hashWidth = 20 // 해시 표 크기의 이진 로그
	hashMask  = 1<<hashWidth - 1
)

@ @<함수들@>=
func mangle(s cstring) int {
	var h uint32
	for l := 0; l < 4; l++ {
		h += hashBits[l][byte(s.h>>(8*l))]
		h += hashBits[l+4][byte(s.l>>(8*l))]
	}
	return int(h & hashMask)
}

@ @<전역 변수@>=
var (
	hashBits  [8][256]uint32 // 보편 해싱에 쓰는 무작위 비트
	hashTable []int32        // 해시 사슬의 머리
)

@ 여기 쓰는 난수 생성기가 대단한 품질일 필요는 없다. 첫 칸 |hashBits[j][0]|을 $0$으로 두어도
보편성을 잃지 않는다.

원본은 이때 레지스터 |row_end|를 잠깐 빌려 쓴다(``나쁜 버릇이다, 미안''). 또 \.{int}에서
|69069*row_end|가 넘쳐 \CEE/에서 정의되지 않은 동작이 되고, 음수를 오른쪽으로 민다.
실제로는 $32$비트로 돌고 부호를 채워 미는데, \.{Go}의 \.{int32}가 바로 그렇게 정의되어
있으므로 같은 비트를 얻는다.

@<초기화한다@>=
{
	var rr int32 = 314159265
	for j := 0; j < 8; j++ {
		for k := 1; k < 256; k++ {
			rr = 69069*rr + 1
			hashBits[j][k] = uint32(rr >> (32 - hashWidth))
		}
	}
	hashTable = make([]int32, hashMask+1)
	for k := range hashTable {
		hashTable[k] = -1
	}
	for k := range slot {
		slot[k] = -1
	}
}

@ @<지역 변수@>=
var j, k int    // 두루 쓰는 첨자
var rowEnd int  // 지금 부분 줄 |r|의 크기
var p int       // 지금 관심 있는 대상의 첨자

@ 홀수 번째 훑기에서는 |src|가 |conf|의 처음 쪽으로 내려가고, |trg|는 |confEnd-1|에서
시작해 내려간다. 짝수 번째 훑기에서는 |src|가 |confEnd-1| 쪽으로 올라가고, |trg|는
처음부터 올라간다. 변수 |ssrc|와 |strg|도 비슷하지만 슬레이브 메모리의 주소를 가리킨다.

원본은 |src|를 처음에 널 포인터로 두는데, 첫 진행 보고는 |src|가 ``|conf-1|''인지로
훑기의 방향을 가른다. 이 판의 |src| 처음 값 $0$은 $-1$이 아니므로 같은 쪽을 고른다.

@<전역 변수@>=
var (
	conf       []config // 짜임 노드 풀
	confEnd    int      // 풀의 마지막 항목 다음
	src        int      // 곧 되쓸 지금 짜임 $\alpha$
	trg        int      // 쓰지 않은 첫 짜임 칸
	ssrc, strg int      // 슬레이브 카운터의 할당 포인터
)

@ 새 짜임을 만들면 그 생성 함수의 공간을 슬레이브 모듈에 잡는다. 나중에 항이 더 많은
다른 생성 함수와 합쳐야 해서 공간이 더 필요해질 수 있다. 그때는 자료를 다른 칸으로
옮기고, 짜임 배열과 슬레이브의 카운터 배열에 구멍을 남긴다. 같은 크기의 구멍은 모두
이어 두어, 곧 다시 메울 수 있기를 바란다.

다음은 생성 함수에 항 |s+1|개가 있는 짜임의 공간을 잡는 기본 함수다. 할당이 위로 가는
훑기와 아래로 가는 훑기를 위해 두 벌이 있다. 메모리가 가장 빠듯할 때 얼마나 조각났는지
가늠할 수 있게 통계도 모은다.

@<함수들@>=
func getSlotUp(s int) int {
	p := int(slot[s])
	if p >= 0 {
		slot[s] = conf[p].link
		holes--
		sholes -= s + 1
	} else {
		p = trg
		trg++
		@<위로 |conf[p].addr|를 잡고 메모리가 넘치지 않았는지 살핀다@>@;
	}
	conf[p].state = raw
	return p
}

@ @<위로 |conf[p].addr|를...@>=
if src-trg < minSpace {
	minSpace = src - trg
	if minSpace < 0 {
		fatal("Memory overflow")
	}
	minHoles, spaceRow, spaceCol = holes, r, re
}
conf[p].addr = uint32(strg)
strg += s + 1
if ssrc-strg < minSspace {
	minSspace = ssrc - strg
	if minSspace < 0 {
		fatal("Slave memory overflow")
	}
	minSholes, slaveRow, slaveCol = sholes, r, re
}

@ @<전역 변수@>=
var (
	holes                int             // 대상 영역의 지금 구멍 수
	sholes               int             // 슬레이브 대상 영역에서 비운 카운터 수
	minSpace             = 1000000000    // |src|와 |trg|가 얼마나 가까워졌나
	minHoles             int             // 그때 구멍은 몇 개였나
	spaceRow, spaceCol   int             // 그때 우리는 어디 있었나
	minSspace            = 1000000000    // |ssrc|와 |strg|가 얼마나 가까워졌나
	minSholes            int             // 그때 버린 카운터는 몇 개였나
	slaveRow, slaveCol   int             // 그때 우리는 어디 있었나
	moves                int             // 구멍이 생긴 횟수
	configs              int             // 지금까지 기록한 짜임의 총수, mod $10^9$
	hconfigs             int             // 짜임의 십억 단위 수
	r                    int             // 부분적으로 채운 줄의 번호
	re                   int             // |rowEnd|의 전역 사본
	slot                 [nmax + 1]int32 // 빈 칸 사슬의 머리
)

@ @<이번 실행의 통계를...@>=
fmt.Fprintf(out, "Altogether ")
if hconfigs != 0 {
	fmt.Fprintf(out, "%d%09d", hconfigs, configs)
} else {
	fmt.Fprintf(out, "%d", configs)
}
fmt.Fprintf(out, " viable configurations examined;\n")
fmt.Fprintf(out, " %d slots needed (with %d holes) in position (%d,%d);\n",
	int(confSize)-minSpace, minHoles, spaceRow, spaceCol)
fmt.Fprintf(out, " %d counters needed (with %d wasted) in position (%d,%d);\n",
	int(slaveSize)-minSspace, minSholes, slaveRow, slaveCol)
fmt.Fprintf(out, " %d moves.\n", moves)

@ @<함수들@>=
func getSlotDown(s int) int {
	p := int(slot[s])
	if p >= 0 {
		slot[s] = conf[p].link
		holes--
		sholes -= s + 1
	} else {
		p = trg
		trg--
		@<아래로 |conf[p].addr|를 잡고 메모리가 넘치지 않았는지 살핀다@>@;
	}
	conf[p].state = raw
	return p
}

@ @<아래로 |conf[p].addr|를...@>=
if trg-src < minSpace {
	minSpace = trg - src
	if minSpace < 0 {
		fatal("Memory overflow")
	}
	minHoles, spaceRow, spaceCol = holes, r, re
}
strg -= s + 1
if strg-ssrc < minSspace {
	minSspace = strg - ssrc
	if minSspace < 0 {
		fatal("Slave memory overflow")
	}
	minSholes, slaveRow, slaveCol = sholes, r, re
}
conf[p].addr = uint32(strg + 1)

@ 원본의 |move_down|과 |move_up|은 살아 있는 대상 짜임 |p|의 생성 함수에 공간이 더 필요할
때 부른다. 전역 변수 |hash|는 |hashTable[hash]=p|가 되도록 정해져 있다. 그 짜임을 대상들의
차례 목록에서 다른 곳으로 사실상 옮기고, 새 자리를 |p|에 둔다. 옛 노드는 이제 |deleted|로
표시되지만, |getSlot|이 다시 쓸 수 있도록 |addr| 필드는 그대로 둔다.

두 함수는 저마다 한 곳에서만 불리므로, 이 판은 이름 있는 절로 옮겨 그 자리에 끼운다.
할당 방향만 다르므로 한 절의 두 벌로 적었다. 원본의 지역 변수 |r|은 전역 변수 |r|을
가리므로 |rr|로 바꾸었다.

@<|p|를 아래로 옮긴다@>=
{
	lo, hi := int(conf[p].lo), int(conf[p].hi)
	rr := conf[p].link
	conf[p].link, slot[hi-lo] = slot[hi-lo], int32(p)
	conf[p].state = deleted
	holes++
	sholes += hi - lo + 1
	lo, hi = min(lo, int(conf[src].lo)), max(hi, j)
	q := getSlotDown(hi - lo)
	@<옮긴 노드 |q|를 채우고 |p|를 |q|로 바꾼다@>@;
}

@ @<|p|를 위로 옮긴다@>=
{
	lo, hi := int(conf[p].lo), int(conf[p].hi)
	rr := conf[p].link
	conf[p].link, slot[hi-lo] = slot[hi-lo], int32(p)
	conf[p].state = deleted
	holes++
	sholes += hi - lo + 1
	lo, hi = min(lo, int(conf[src].lo)), max(hi, j)
	q := getSlotUp(hi - lo)
	@<옮긴 노드 |q|를 채우고...@>@;
}

@ @<옮긴 노드 |q|를 채우고...@>=
conf[q].lo, conf[q].hi = uint8(lo), uint8(hi)
conf[q].s, conf[q].lim = conf[p].s, conf[p].lim
hashTable[hash], conf[q].link = int32(q), rr
update(&conf[p], &conf[q], int(conf[p].hi))
moves++
p = q

@* 주 반복문.
기반이 얼마쯤 갖추어졌으니, 이 프로그램의 주 처리 순환의 윗 수준을 그려 보자.

너비 $w$인 칸 배열의 맨 위에서, 모두 |zero|인 짜임으로 시작한다. 이 짜임은 뒤에 생기는
모든 짜임의 고조할머니 노릇을 한다. 슬레이브 모듈은 이 짜임에 카운터 칸 0번에서 자명한
생성 함수 `1'(곧 $z^0$)을 주며 시작한다. 처음 짜임에 이르는 방법은 하나뿐이고 아직 찬
칸이 없다는 뜻이다.

필드 |conf[0].lim|과 |conf[0].link|는 짜임이 대상일 때만 쓰이므로 초기화할 필요가 없다. 다른
필드, 곧 |conf[0].s|, |conf[0].addr|, |conf[0].lo|, |conf[0].hi|, |conf[0].state|는
처음에 $0$이고, 다행히 그 $0$이 바로 원하는 값이다. \.{Go}의 |make|도 $0$으로 채운다.

@<초기화한다@>=
r, rowEnd = 0, int(w)
trg = 1 // 앞 훑기가 결과 하나를 냈다고 친다
strg = 1

@ 크누스는 여기서도 할당이 실제로 위로 가느냐 아래로 가느냐에 따라 거의 똑같은 코드를
두 벌 쓰는 편이 가장 낫다고 보았다. (메모리를 아껴야 하지만, 이 프로그램 자체에 드는
공간은 하찮다.)

@<후처리기에 줄 명령어를...@>=
for {
	@<아래로 훑을 준비를 하거나, 끝났으면 |break|@>@;
	@<앞 훑기가 만든 짜임을 모두 아래로 훑는다@>@;
	@<위로 훑을 준비를 하거나, 끝났으면 |break|@>@;
	@<앞 훑기가 만든 짜임을 모두 위로 훑는다@>@;
}

@ @<아래로 훑을 준비를...@>=
if rowEnd < int(w) {
	rowEnd++
	fmt.Fprintf(out, "Beginning column %d", rowEnd)
	@<지금 통계를 찍고 해시와 슬롯 표를 지운다@>@;
} else {
	if r != 0 {
		fmt.Fprintf(out, "Finished row %d", r)
		@<지금 통계를 찍고...@>@;
		if r > int(w) {
			putInst(opSync, byte(r))
		}
	}
	@<이번 실행이 너무 오래 갔는지 살핀다@>@;
	r++
	rowEnd = 1
}
if trg == 0 {
	break // 앞 훑기에서 아무것도 나오지 않았다
}
src = trg - 1          // 원천 포인터를 차지한 가장 높은 노드에서 시작한다
ssrc = strg - 1        // 그리고 차지한 가장 높은 카운터 자리
trg = confEnd - 1      // 대상 포인터를 비어 있는 가장 높은 노드에서 시작한다
strg = int(slaveSize) - 1 // 그리고 비어 있는 가장 높은 카운터 자리
re = rowEnd

@ @<앞 훑기가 만든 짜임을 모두 아래로...@>=
for src >= 0 {
	if conf[src].state == active {
		unpackit(conf[src].s) // 원천 짜임 $\alpha$를 |sc|와 |c|에 넣는다
		if verbose != 0 {
			printConfig(rowEnd)
			fmt.Fprintf(out, "\n")
		}
		@<대상 $\alpha_0$을 위해 배열 |c|를 바꾼다@>@;
		if viable != 0 {
			@<대상 짜임 |c|를 처리한다(아래로)@>@;
		}
		for k = 1; k <= int(w); k++ {
			c[k] = sc[k]
		}
		@<대상 $\alpha_1$을 위해 배열 |c|를 바꾼다@>@;
		if viable != 0 {
			@<대상 짜임 |c|를 처리한다(아래로)@>@;
		}
	}
	ssrc = int(conf[src].addr) - 1
	src-- // 옛 |src| 노드는 이제 쓸모없다
}

@ 제때 진행을 알려 사용자가 아직 잘 돌고 있음을 알게 한다. 위로 훑기를 막 시작하려
할 때, 그리고 그때만 |src==-1|이다.

@<지금 통계를 찍고...@>=
if src == -1 {
	fmt.Fprintf(out, " (%d,%d,", confEnd-1-trg, int(slaveSize)-1-strg)
} else {
	fmt.Fprintf(out, " (%d,%d,", trg, strg-int(n)-1)
}
fmt.Fprintf(out, "%d,%d,%d,%d,%d)\n",
	int(confSize)-minSpace, minHoles, int(slaveSize)-minSspace, minSholes, bytesOut)
@<해시와 슬롯 표를 찍고 지운다@>@;
out.Flush()

@ 슬레이브 메모리의 카운터 자리 1번부터 $n$번까지는 최종 다항체 수를 위해 남겨 둔다.

@<위로 훑을 준비를...@>=
if rowEnd < int(w) {
	rowEnd++
	fmt.Fprintf(out, "Beginning column %d", rowEnd)
	@<지금 통계를 찍고...@>@;
} else {
	if r != 0 {
		fmt.Fprintf(out, "Finished row %d", r)
		@<지금 통계를 찍고...@>@;
		if r > int(w) {
			putInst(opSync, byte(r))
		}
	}
	r++
	rowEnd = 1
}
if trg == confEnd-1 {
	break // 앞 훑기에서 아무것도 나오지 않았다
}
src = trg + 1 // 원천 포인터를 차지한 가장 낮은 노드에서 시작한다
	// 곧 |ssrc|를 |conf[src].addr|로 둘 텐데, 그것은 차지한 가장 낮은 카운터 |strg+1|이다
trg = 0           // 대상 포인터를 비어 있는 가장 낮은 노드에서 시작한다
strg = int(n) + 1 // 그리고 비어 있는 가장 낮은 카운터 자리
re = rowEnd

@ @<앞 훑기가 만든 짜임을 모두 위로...@>=
for src < confEnd {
	if conf[src].state == active {
		ssrc = int(conf[src].addr)
		unpackit(conf[src].s) // 원천 짜임 $\alpha$를 |sc|와 |c|에 넣는다
		if verbose != 0 {
			printConfig(rowEnd)
			fmt.Fprintf(out, "\n")
		}
		@<대상 $\alpha_0$을 위해...@>@;
		if viable != 0 {
			@<대상 짜임 |c|를 처리한다(위로)@>@;
		}
		for k = 1; k <= int(w); k++ {
			c[k] = sc[k]
		}
		@<대상 $\alpha_1$을 위해...@>@;
		if viable != 0 {
			@<대상 짜임 |c|를 처리한다(위로)@>@;
		}
	}
	src++ // 옛 |src| 노드는 이제 쓸모없다
}

@* 자잘한 세부.
이른바 ``전이 행렬'' 방법의 기본 논리는 다음 단계들에 들어 있다. 이 단계들은 $r$번째
줄의 새 칸을 차지하느냐 마느냐에 따라 짜임 문자열을 바꾼다. 이를테면 앞 짜임의 부분 줄
끝이 `\.{1\caret/(}'이고 새 칸을 차지하면, 새 짜임에는 그 대신 `\.{(-}\caret/\thinspace'가
온다. 그러나 그 칸을 차지하지 않으면 새 짜임에는 `\.{10}\caret/\thinspace'가 오고, 사라진
\.( 때문에 다른 곳도 고쳐야 한다.

\def\sp(#1){\rlap{$^{\rm\,#1}$}}
\def\key(#1) {&\omit&\multispan5\quad\sp(#1)\quad}
생기는 경우는 대부분 아주 단순하다. 그러나 이웃한 두 부호의 조합 서른 가지를 물론 모두
빈틈없이 다루어야 한다. 다음 표는 새 칸을 비워 둘 때 프로그램이 할 일을 간추린 것이다.
$$\vbox{\offinterlineskip
\halign{\strut\hfil\tt#\quad&\vrule#&
 \hbox to4em{\hfil\tt#\hfil}&
 \hbox to4em{\hfil\tt#\hfil}&
 \hbox to4em{\hfil\tt#\hfil}&
 \hbox to4em{\hfil\tt#\hfil}&
 \hbox to4em{\hfil\tt#\hfil}&
 \vrule#\cr
&\omit&0&1&(&-&)\cr
\noalign{\vskip2pt}
\omit&&\multispan5\hrulefill&\cr
\omit&height3pt&&&&&&\cr
0&&00&\sp(a)&00\sp(b)&00\sp(c)&00\sp(d)&\cr
1&&10&\sp(a)&10\sp(b)&10\relax&10\sp(d)&\cr
(&&(0&\sp(e)&  \sp(e)&(0\relax&(0\sp(d)&\cr
-&&-0&\sp(a)&-0\sp(b)&-0\relax&-0\sp(d)&\cr
)&&)0&\sp(a)&-0\sp(b)&)0\relax&-0\sp(d)&\cr
\rm 왼쪽 끝&&0&\sp(e)&\sp(e)&0\sp(c)&\sp(a)&\cr
\omit&height1pt&&&&&&\cr
\omit&&\multispan5\hrulefill&\cr
\noalign{\smallskip}
\key(a) 살 수 없다\hfil\cr
\key(b) \.(의 다음 것을 낮춘다\hfil\cr
\key(c) 다항체가 완성되었을 수 있다\hfil\cr
\key(d) \.)의 앞 것을 낮춘다\hfil\cr
\key(e) 있을 수 없는 경우\hfil\cr}}$$

\.-를 없앨 때, 그 앞이나 뒤에 \.0만 있으면 특별히 다루어야 한다. 이를테면 \.{0(010-}은
\.{010(00}이 되어야 하고, \.{-010()0-0}은 \.{00)0()0(0}이나 \.{)010(-000}이 되어야 한다.
아래 프로그램은 이런 드문 경우에 조심스럽게 다가간다.

원본은 두 부호의 쌍을 매크로 |f(x,y)=(x<<3)+y|로 만든다. 이 판은 그 식을 그대로
|x<<3+y|로 적는다. \.{Go}에서 |<<|는 |+|보다 먼저 묶인다.

@<대상 $\alpha_0$을 위해...@>=
pair = sc[rowEnd-1]<<3 + sc[rowEnd]
c[rowEnd] = zero
viable = 1
switch pair {
case zero<<3 + one, one<<3 + one, mid<<3 + one, rt<<3 + one, eol<<3 + rt:
	viable = 0 // 성분이 외톨이가 된다
case zero<<3 + zero, one<<3 + zero, lft<<3 + zero, mid<<3 + zero,
	rt<<3 + zero, eol<<3 + zero, lft<<3 + mid, mid<<3 + mid:
case zero<<3 + lft, one<<3 + lft, mid<<3 + lft, rt<<3 + lft:
	@<|lft|의 다음 것을 낮춘다@>@;
case zero<<3 + rt, one<<3 + rt, lft<<3 + rt, mid<<3 + rt, rt<<3 + rt:
	@<|rt|의 앞 것을 낮춘다@>@;
case zero<<3 + mid, eol<<3 + mid:
	@<맨 왼쪽일 수 있는 |mid|를 조심스럽게 지운다@>@;
	fallthrough
case one<<3 + mid, rt<<3 + mid:
	@<맨 오른쪽일 수 있는 |mid|를 조심스럽게 지운다@>@;
case lft<<3 + one, lft<<3 + lft, eol<<3 + one, eol<<3 + lft:
	fatal("Impossible configuration")
default:
	fatal("Impossible pair")
}

@ @<전역 변수@>=
var (
	pair   int // |sc|에서 \qcaret/를 둘러싼 두 부호
	viable int // 대상 짜임이 쓸모 있는 다항체로 이어질 수 있나?
)

@ 이 단계에서는 방금 왼쪽 괄호를 $0$으로 만들었다. 그 \.( 다음에 \.-가 오면 그 \.-를
\.(로 바꾸고, \.)가 오면 그 \.)를 \.1로 바꾼다.

여기서 ``다음에 온다''는 사실 ``같은 수준에서 다음에 온다''는 뜻이다. 포개진 부분 성분이
끼어들 수 있기 때문이다. 그래서 오른쪽으로 훑으며 수준 계수기 |j|를 둔다.

그 \.(가 그저 오른쪽 가장자리와의 연결을 표시했을 뿐이라 다음 것이 없다면, 지우지
말았어야 했다. 그 성분은 이제 끊어졌으므로 |viable|을 $0$으로 둔다.

원본의 |switch|에서 |case lft|는 |j|를 늘리고 |case zero|로 흘러들어 |continue|한다. 이
판은 그 흐름을 |case lft|에 바로 적었다. 아래 비슷한 반복문들도 그렇다.

@<|lft|의 다음 것을 낮춘다@>=
for k, j = rowEnd+1, 0; ; k++ {
	switch c[k] {
	case lft:
		j++
		continue
	case zero, one:
		continue
	case mid:
		if j != 0 {
			continue
		}
		c[k] = lft
	case rt:
		if j != 0 {
			j--
			continue
		}
		c[k] = one
	case eol:
		if j != 0 {
			fatal("Unexpected eol")
		}
		viable = 0
	}
	break
}

@ 거꾸로, 지운 \.)는 지운 \.(와 같되 방향이 반대다.

@<|rt|의 앞 것을 낮춘다@>=
for k, j = rowEnd-1, 0; ; k-- {
	switch c[k] {
	case rt:
		j++
		continue
	case zero, one:
		continue
	case mid:
		if j != 0 {
			continue
		}
		c[k] = rt
	case lft:
		if j != 0 {
			j--
			continue
		}
		c[k] = one
	case eol:
		if j != 0 {
			fatal("Unexpected eol")
		}
		viable = 0
	}
	break
}

@ @<맨 왼쪽일 수 있는 |mid|를...@>=
for k = rowEnd - 1; c[k] == zero; k-- {
}
if c[k] == eol { // 그렇다, 그 |mid|는 맨 왼쪽이었다
	for k = rowEnd + 1; c[k] == zero; k++ {
	}
	switch c[k] {
	case mid, rt, eol: // 문제없다
	default:
		if c[k] == one {
			c[k], j = rt, 0
		} else {
			c[k], j = mid, 1 // |c[k]|는 |lft|였다
		}
		@<그 |mid|의 다음 것을 낮춘다@>@;
	}
}

@ @<그 |mid|의 다음 것을...@>=
for k++; ; k++ {
	switch c[k] {
	case lft:
		j++
		continue
	case zero, one:
		continue
	case mid:
		if j != 0 {
			continue
		}
		c[k] = lft
	case rt:
		if j != 0 {
			j--
			continue
		}
		c[k] = one
	case eol:
		fatal("This can't happen")
	}
	break
}

@ @<맨 오른쪽일 수 있는 |mid|를...@>=
for k = rowEnd + 1; c[k] == zero; k++ {
}
if c[k] == eol { // 그렇다, 그 |mid|는 맨 오른쪽이었다
	for k = rowEnd - 1; c[k] == zero; k-- {
	}
	switch c[k] {
	case mid, lft, eol: // 문제없다
	default:
		if c[k] == one {
			c[k], j = lft, 0
		} else {
			c[k], j = mid, 1 // |c[k]|는 |rt|였다
		}
		@<그 |mid|의 앞 것을 낮춘다@>@;
	}
}

@ @<그 |mid|의 앞 것을...@>=
for k--; ; k-- {
	switch c[k] {
	case rt:
		j++
		continue
	case zero, one:
		continue
	case mid:
		if j != 0 {
			continue
		}
		c[k] = rt
	case lft:
		if j != 0 {
			j--
			continue
		}
		c[k] = one
	case eol:
		fatal("This can't happen")
	}
	break
}

@ 새 칸을 차지하는 것을 생각하면 다른 종류의 흥분이 기다린다.

경우 |lft<<3+mid|, |lft<<3+rt|, |mid<<3+mid|, |mid<<3+rt|를 고쳐 |viable=0|으로 두면, 이
프로그램은 보통 다항체 대신 {\it 다항체 나무\/}를 센다. (다항체 나무에서는 한 칸에서 다른
칸으로 룩 움직임으로 가는 길이 꼭 하나다.) 이 넷은 이미 이어진 칸들을 다시 잇는
경우다.
$$\vbox{\offinterlineskip
\halign{\strut\hfil\tt#\quad&\vrule#&
 \hbox to4em{\hfil\tt#\hfil}&
 \hbox to4em{\hfil\tt#\hfil}&
 \hbox to4em{\hfil\tt#\hfil}&
 \hbox to4em{\hfil\tt#\hfil}&
 \hbox to4em{\hfil\tt#\hfil}&
 \vrule#\cr
&\omit&0&1&(&-&)\cr
\noalign{\vskip2pt}
\omit&&\multispan5\hrulefill&\cr
\omit&height3pt&&&&&&\cr
0&&01\sp(k)&01&    0(&0-\relax&0)\relax&\cr
1&&()&    ()&(-\relax&--\relax&-)\relax&\cr
(&&(-&\sp(e)&  \sp(e)&(-\sp(f)&()\sp(f)&\cr
-&&--&    --&--\sp(g)&--\sp(f)&-)\sp(f)&\cr
)&&-)&    -)&--\relax&--\sp(h)&-)\sp(h)&\cr
\rm 왼쪽 끝&&)\sp(i)&\sp(e)&\sp(e)&-&)&\cr
\omit&height1pt&&&&&&\cr
\omit&&\multispan5\hrulefill&\cr
\noalign{\smallskip}
\key(e) 있을 수 없는 경우\hfil\cr
\key(f) 다항체 나무에서는 살 수 없다\hfil\cr
\key(g) \.(의 짝과 합친다\hfil\cr
\key(h) \.)의 짝과 합친다\hfil\cr
\key(i) 다음 성분이 열려 있으면 낮춘다\hfil\cr
\key(j) 앞 성분이 열려 있으면 낮춘다\hfil\cr
\key(k) 또는 \.{0)\sp(i)}나 \.{0(\sp(j)}\hfil\cr
}}$$
드문 경우 \.{01\sp(k)}\ \ 는 왼쪽에 $0$ 아닌 칸이 없지만 왼쪽 가장자리가 위쪽 줄 어딘가에서
이미 차 있으면 \.{0)\sp(i)}가 된다. 오른쪽에 $0$ 아닌 칸이 없지만 오른쪽 가장자리가 위쪽
줄 어딘가에서 이미 차 있으면 \.{0(\sp(j)}가 된다.

@<대상 $\alpha_1$을 위해...@>=
viable = 1
conf[src].lo++
conf[src].hi++ // 생성 함수 $g(\alpha)$에 $z$를 암묵적으로 곱한다
switch pair {
case one<<3 + zero, one<<3 + one:
	c[rowEnd-1], c[rowEnd] = lft, rt
case zero<<3 + one, zero<<3 + lft, zero<<3 + mid, zero<<3 + rt, lft<<3 + mid,
	lft<<3 + rt, mid<<3 + mid, mid<<3 + rt, eol<<3 + mid, eol<<3 + rt:
case one<<3 + lft:
	c[rowEnd-1], c[rowEnd] = lft, mid
case one<<3 + mid, one<<3 + rt:
	c[rowEnd-1] = mid
case lft<<3 + zero, mid<<3 + zero, mid<<3 + one:
	c[rowEnd] = mid
case mid<<3 + lft:
	c[rowEnd] = mid
	@<예전 |lft|의 짝과 합친다@>@;
case rt<<3 + zero, rt<<3 + one:
	c[rowEnd-1], c[rowEnd] = mid, rt
case rt<<3 + lft:
	c[rowEnd-1], c[rowEnd] = mid, mid
case rt<<3 + mid, rt<<3 + rt:
	c[rowEnd-1] = mid
	@<예전 |rt|의 짝과 합친다@>@;
case eol<<3 + zero:
	c[rowEnd] = rt
	@<다음 성분이 열려 있으면 낮춘다@>@;
case zero<<3 + zero:
	@<새 |one|을 조심스럽게 들인다@>@;
case lft<<3 + one, lft<<3 + lft, eol<<3 + one, eol<<3 + lft:
	fatal("Impossible configuration")
default:
	fatal("Impossible pair")
}
if rowEnd == int(w) {
	@<오른쪽 가장자리에서 특별히 바로잡는다@>@;
}

@ @<예전 |lft|의 짝과...@>=
for k, j = rowEnd+1, 0; ; k++ {
	switch c[k] {
	case lft:
		j++
		continue
	case zero, one, mid:
		continue
	case rt:
		if j != 0 {
			j--
			continue
		}
	case eol:
		fatal("Unexpected eol")
	}
	c[k] = mid
	break
}

@ @<예전 |rt|의 짝과...@>=
for k, j = rowEnd-2, 0; ; k-- {
	switch c[k] {
	case rt:
		j++
		continue
	case zero, one, mid:
		continue
	case lft:
		if j != 0 {
			j--
			continue
		}
	case eol:
		fatal("Unexpected eol")
	}
	c[k] = mid
	break
}

@ @<다음 성분이 열려 있으면...@>=
for k = 2; ; k++ {
	switch c[k] {
	case zero:
		continue
	case mid:
		c[k] = lft
	case rt:
		c[k] = one
	}
	break
}

@ @<새 |one|을...@>=
c[rowEnd] = one
for k = rowEnd - 2; c[k] == zero; k-- {
}
if k == 0 { // 맨 왼쪽에 새 \.1을 들인다
	for k = rowEnd + 1; ; k++ {
		switch c[k] {
		case zero:
			continue
		case mid:
			c[k], c[rowEnd] = lft, rt
		case rt:
			c[k], c[rowEnd] = one, rt
		}
		break
	}
} else {
	for j = rowEnd + 1; c[j] == zero; j++ {
	}
	if c[j] == eol { // 맨 오른쪽에 새 \.1을 들인다
		if c[k] == mid {
			c[k], c[rowEnd] = rt, lft
		} else if c[k] == lft {
			c[k], c[rowEnd] = one, lft
		}
	}
}

@ @<오른쪽 가장자리에서...@>=
switch c[rowEnd] {
case rt:
	c[rowEnd] = mid
case one:
	c[rowEnd] = lft
	@<앞 성분이 열려 있으면 낮춘다@>@;
}

@ @<앞 성분이 열려 있으면...@>=
for k = rowEnd - 1; ; k-- {
	switch c[k] {
	case zero:
		continue
	case mid:
		c[k] = rt
	case lft:
		c[k] = one
	}
	break
}

@* 더 자잘한 세부.
마지막으로 넘을 만만찮은 고비는 대상 짜임을 |c[1]|부터 |c[w]|까지에 지은 다음에 할
일이다. 큰 문제는 아니지만, 특히 생성 함수 산술에 관해서는 조심해야 한다.

모두 |zero|인 대상 짜임은 첫 줄 끝에 이르기 전의 처음 몇 훑기에서만 남긴다.

@<대상 짜임 |c|를 처리한다(아래로)@>=
if rowEnd == int(w) {
	@<짜임을 정규형으로 바꾼다@>@;
}
target = packit()
if target.l != 0 || target.h != 0 || (r == 1 && rowEnd < int(w)) {
	@<|target|이 이미 있으면 |p|가 그것을 가리키게 한다@>@;
	if p < 0 {
		@<|target|이 정말 살 수 있으면 아래쪽 칸을 잡는다@>@;
	}
	if p >= 0 && conf[src].lo <= conf[p].lim {
		j = int(min(conf[src].hi, conf[p].lim))
		if j > int(conf[p].hi) || conf[src].lo < conf[p].lo {
			@<|p|를 아래로 옮긴다@>@;
		}
		@<자세히 보일 때는 대상을 찍는다@>@;
		update(&conf[src], &conf[p], j)
	}
} else if r > int(w) {
	if verbose != 0 {
		fmt.Fprintf(out, " -> 0\n")
	}
	update(&conf[src], nil, int(conf[src].hi)) // 다항체를 완성했다
}

@ @<자세히 보일 때는...@>=
if verbose != 0 {
	fmt.Fprintf(out, " -> ")
	printConfig(rowEnd + 1)
	fmt.Fprintf(out, "\n")
}

@ @<전역 변수@>=
var (
	target cstring // 지금 대상 짜임의 묶은 이름
	hash   int     // 그 해시 주소
)

@ 줄 끝에서는 짜임을 좌우로 뒤집은 것이 사전순으로 더 작으면 그것으로 바꾼다. 이렇게
정규형으로 줄이면, 적어도 다음 몇 훑기 동안 살아 있는 짜임의 수가 거의 절반이 된다. (왼쪽이
무거운 줄 다음의 줄마다 왼쪽에서 오른쪽 대신 오른쪽에서 왼쪽으로 처리할 수도 있었다는
것으로 이 줄임을 정당화할 수 있다.)

\.{0(0} 같은 부호는 \.{0)0}으로 뒤집힌다.

@<짜임을 정규형으로...@>=
for j, k = 1, int(w); j <= k; j, k = j+1, k-1 {
	if c[j] != reflect[c[k]] {
		break
	}
}
if c[j] > reflect[c[k]] {
	for ; j <= k; j, k = j+1, k-1 {
		i := c[k]
		c[k] = reflect[c[j]]
		c[j] = reflect[i]
	}
}

@ 대상 |p|를 찾으면 해시 사슬의 맨 앞으로 옮기고, |p|를 옮기는 절에 필요한 전역 변수 |hash|를
정한다.

@<|target|이 이미 있으면...@>=
hash = mangle(target)
p = int(hashTable[hash])
if p >= 0 && conf[p].s != target {
	q := p
	for p = int(conf[p].link); p >= 0; q, p = p, int(conf[p].link) {
		if conf[p].s == target {
			break
		}
	}
	if p >= 0 {
		conf[q].link = conf[p].link       // |p|를 예전 자리에서 빼고
		conf[p].link = hashTable[hash]    // 맨 앞에 넣는다
		hashTable[hash] = int32(p)
	}
}

@ 대상이 살 수 있으면 |p|는 |state==raw|인 새 노드가 된다. 그러면 |p|를 옮길 일이 없음을
독자는 확인할 수 있다. 필요한 칸 수 |j|는 연결 비용에, 아직 정사각형에 이르지 않았으면
늘이는 비용을 더한 것이다.

@<|target|이 정말 살 수 있으면 아래쪽...@>=
@<더 필요한 칸 수 |j|를 셈한다@>@;
if int(conf[src].lo)+j <= int(n) {
	@<짜임 수를 센다@>@;
	p = getSlotDown(min(int(conf[src].hi), int(n)-j) - int(conf[src].lo))
	@<새 노드 |p|를 해시 사슬에 넣고 채운다@>@;
}

@ @<더 필요한 칸 수...@>=
j = int(connectivity(rowEnd + 1))
if r >= int(w) {
	j = intPart(j)
} else if intPart(j) == epsPart(j) {
	j = intPart(j) + (int(w) - r)
} else {
	j = intPart(j) + (int(w) - 1 - r)
} // 쓸 만한 다항체에는 칸이 |j|개 더 필요하다

@ @<짜임 수를 센다@>=
configs++
if configs == 1000000000 {
	configs = 0
	hconfigs++
}

@ @<새 노드 |p|를 해시 사슬에...@>=
conf[p].link, hashTable[hash] = hashTable[hash], int32(p)
conf[p].s = target
conf[p].lo, conf[p].hi, conf[p].lim = conf[src].lo, conf[src].hi, uint8(int(n)-j)
if conf[p].hi > conf[p].lim {
	conf[p].hi = conf[p].lim
}

@ @<대상 짜임 |c|를 처리한다(위로)@>=
if rowEnd == int(w) {
	@<짜임을 정규형으로...@>@;
}
target = packit()
if target.l != 0 || target.h != 0 || (r == 1 && rowEnd < int(w)) {
	@<|target|이 이미 있으면...@>@;
	if p < 0 {
		@<|target|이 정말 살 수 있으면 위쪽 칸을 잡는다@>@;
	}
	if p >= 0 && conf[src].lo <= conf[p].lim {
		j = int(min(conf[src].hi, conf[p].lim))
		if j > int(conf[p].hi) || conf[src].lo < conf[p].lo {
			@<|p|를 위로 옮긴다@>@;
		}
		@<자세히 보일 때는...@>@;
		update(&conf[src], &conf[p], j)
	}
} else if r > int(w) {
	if verbose != 0 {
		fmt.Fprintf(out, " -> 0\n")
	}
	update(&conf[src], nil, int(conf[src].hi)) // 다항체를 완성했다
}

@ @<|target|이 정말 살 수 있으면 위쪽...@>=
@<더 필요한 칸 수...@>@;
if int(conf[src].lo)+j <= int(n) {
	@<짜임 수를 센다@>@;
	p = getSlotUp(min(int(conf[src].hi), int(n)-j) - int(conf[src].lo))
	@<새 노드 |p|를 해시 사슬에...@>@;
}

@* 체크포인트.
이 프로그램의 목표 하나는 새 세계 기록을 세우는 것이다. 그러니 손에 있는 자원을 아마
지금 한계까지 쓰고 있을 것이고, 며칠씩 돌 수도 있다.

그래서 알맞은 ``체크포인트''에서 멈추어 지금까지 이룬 것을 다져 두는 것이 신중하다. 그러면
재난에서 되살아날 때 맨 처음으로 돌아가지 않아도 된다. 그때 {\mc POLYSLAVE}로 중간
자료를 줄여, 디스크를 더 채우기 전에 그동안 채운 공간을 거의 다 비워야 한다.

이 절의 코드는 특히 편한 때에 돈다. 새 줄과 새 아래쪽 훑기가 막 시작하려는 때다. 지금까지의
짜임 표를, 이 프로그램의 특별판이 다시 이어 갈 때 쉽게 쓸 수 있는 꼴로 쏟아 놓기에 딱 좋은
때다. (자세한 것은 변경 파일 \.{polynum-restart.ch}를 보라.)

@<상수@>=
const gigThreshold = 5 // 디스크를 대략 이것의 두 배 기가바이트보다 많이 채우지 않으려 한다

@ @<이번 실행이 너무 오래...@>=
if fileExtension >= gigThreshold && trg != 0 {
	@<{\mc POLYSLAVE} 처리를 끝낸다@>@;
	filename = fmt.Sprintf("%.90s.dump", baseName)
	f, err := os.Create(filename)
	if err != nil {
		fatal("I can't open the dump file")
	}
	@<다시 시작하는 데 필요한 정보를 모두 쏟아 놓는다@>@;
	@<이번 실행의 통계를...@>@;
	fmt.Fprintf(out, "[%d bytes written on file %s.]\n", dumpBytes, filename)
	out.Flush()
	os.Exit(1)
}

@ 매개변수가 255인 특별한 |opSync| 명령어는 {\mc POLYSLAVE}에게 스스로 체크포인트 일을
하라고 알린다.

@<{\mc POLYSLAVE} 처리를...@>=
putInst(opSync, 255)
@<버퍼를 비우고...@>@;
fmt.Fprintf(out, "Checkpoint stop: Please process that data with polyslave,\n")
fmt.Fprintf(out, "then resume the computation with polynum-restart.\n")

@ 아래쪽 훑기의 처음이므로, 사용자는 원하면 |confSize|와 |slaveSize|를 바꾸어 이
프로그램을 다시 시작할 수 있다.

원본은 매개변수 다섯 개를 \.{int}로, 이어서 짜임 구조들을 메모리 모양 그대로 쓴다. 그
구조에는 포인터와 채움 바이트가 들어 있어 기계와 컴파일러마다 모양이 다르다. 이 판은 같은
매개변수를 네 바이트씩, 이어서 짜임마다 |s.h|, |s.l|, |addr|, |lo|, |hi|, |lim|, |state|를
차례로 이 기계의 바이트 순서로 쓴다. 연결 필드는 쓰지 않는다. 다시 시작할 때는 해시 표와
구멍 목록이 비어 있으므로 필요 없다. 그러니 이 덤프는 원본의 \.{polynum-restart.ch}와
맞지 않는다.

@<다시 시작하는 데...@>=
{
	bw := bufio.NewWriter(f)
	for _, v := range []int32{n, w, int32(r), int32(trg), int32(strg)} {
		binary.Write(bw, binary.NativeEndian, v)
	}
	for _, q := range conf[:trg] {
		binary.Write(bw, binary.NativeEndian, []uint32{q.s.h, q.s.l, q.addr})
		bw.Write([]byte{q.lo, q.hi, q.lim, q.state})
	}
	if bw.Flush() != nil {
		fatal("Couldn't dump the configuration table")
	}
	dumpBytes = 20 + 16*trg
	f.Close()
}

@ @<전역 변수@>=
var dumpBytes int // 덤프 파일에 쓴 바이트 수

@* 계산 경험.
알맞은 변경 파일이 있으면, $n$과 $w$가 꽤 작을 때 이 프로그램을 계산까지 바로 하는 한 번
훑기 루틴으로 바꾸기는 어렵지 않다. 이를테면 $n=30$이고 $2\le w\le15$일 때 모든 계산이
192초 만에 끝났다(2000년 12월 12일). 가장 어려운 경우는 $w=13$으로 68초 걸렸고, 칸
100,488개(구멍 0개)와 카운터 218980개(4114개 버림)가 필요했다.

그렇게 얻은 $n\le30$인 $n$-오미노의 수는 크누스의 이제는 낡은 프로그램 {\mc POLYENUM}으로
전혀 다른 알고리즘을 써서 얻은 답과 완벽하게 맞았다. 그 프로그램은 30-오미노를 세는 데
15시간 넘게 걸렸으니, Jensen의 방법은 거의 300배 빨랐다.
@^Jensen, Iwan@>

크기를 $n=47$로 두자 물론 훨씬 더 큰 모험이 되었다. 공간과 시간이 모두 지수적으로 자라기
때문이다. 며칠씩 돈 실행도 있었고, 여러 사고와 하드웨어 고장이 흥분을 더했다. 여기서 셈하는
도수 분포를 비롯한 자세한 성능 통계가 계획과 여러 문제의 진단에 도움이 되었다.

@<상수@>=
const histSize = 100

@ 해시 사슬 길이와 생성 함수 길이의 도수 분포를 찍고, 해시 표와 구멍 목록을 비운다.

@<해시와 슬롯 표를 찍고 지운다@>=
for k = 0; k < histSize; k++ {
	hhist[k] = 0
}
for k = 0; k <= nmax; k++ {
	chist[k] = 0
}
jj = 0
for k = 0; k <= hashMask; k++ {
	j = 0
	for p = int(hashTable[k]); p >= 0; p = int(conf[p].link) {
		chist[conf[p].hi-conf[p].lo]++
		j++
	}
	if j > jj {
		if j >= histSize {
			j = histSize - 1
		}
		jj = j
	}
	hhist[j]++
	hashTable[k] = -1
}
fmt.Fprintf(out, "Hash histogram:")
for j = 1; j <= jj; j++ {
	fmt.Fprintf(out, " %d", hhist[j])
}
fmt.Fprintf(out, "\nCounters:")
for k = nmax; k >= 0 && chist[k] == 0; k-- {
}
for j = 0; j <= k; j++ {
	fmt.Fprintf(out, " %d", chist[j])
}
@<구멍 목록을 찍고 지운다@>@;
fmt.Fprintf(out, "\n")
holes, sholes = 0, 0

@ @<구멍 목록을...@>=
for k = nmax; k >= 0 && slot[k] < 0; k-- {
}
if k >= 0 {
	fmt.Fprintf(out, "\nHoles:")
	for j = 0; j <= k; j++ {
		for p, jj = int(slot[j]), 0; p >= 0; p, jj = int(conf[p].link), jj+1 {
		}
		fmt.Fprintf(out, " %d", jj)
		slot[j] = -1
	}
}

@ @<전역 변수@>=
var (
	hhist [histSize]int // 해시 사슬 길이의 도수 분포
	chist [nmax + 1]int // 카운터 표 길이의 도수 분포
	jj    int           // 통계 계산의 보조 변수
)

@ 크기가 $n=47$일 때 가장 어려운 경우는 $w=20$이었다. 그 경우 {\mc POLYSLAVE}에 넘긴 자료가 100
기가바이트를 넘었고 계산이 며칠 걸렸으니, 체크포인트 알고리즘이 특히 쓸모 있었다.

그 실행들의 주요 통계를 간추린다. ``configs''는 모든 훑기에 걸쳐 더한 서로 다른 짜임의
총수다. ``moves''는 생성 함수에 공간을 더 주려고 |p|를 옮긴 횟수다.
$$\vbox{\halign{&\quad\hfil#\cr
$w\ $&slots&counters&configs&moves&bytes&\mc POLYNUM&\mc POLYSLAVE\cr
\noalign{\vskip2pt}
23&    0.3M&    0.3M&   109M&   3M&  0.4G&     14 min&        5 min\cr
22&    6.2M&    8.0M&  2150M& 129M& 10.2G&    267 min\rlap*& 35 min\rlap*\cr
21&   28.6M&   46.5M&  9481M&1053M& 58.8G&   1911 min\rlap*&314 min\rlap*\cr
20&   40.2M&   94.0M& 12852M&2267M&103.6G&   2960 min\rlap*&574 min\rlap*\cr
19&   31.5M&  105.6M&  9183M&2099M& 86.8G&   1803 min\rlap*&497 min\rlap*\cr
18&   19.4M&   85.5M&  5220M&1318M& 52.9G&    749 min\rlap*&324 min\rlap*\cr
17&   10.1M&   58.3M&  2514M& 678M& 26.7G&    280 min\rlap*&172 min\rlap*\cr
16&    4.5M&   34.2M&  1091M& 308M& 11.9G&    137 min\rlap*&104 min\rlap*\cr
15&    1.9M&   18.2M&   437M& 127M&  4.9G&     51 min\rlap*& 44 min\rlap*\cr
14&    0.7M&    8.8M&   167M&  49M&  2.0G&     22 min&       31 min\cr
13&    0.3M&    4.1M&    62M&  19M&  0.8G&      8 min&       12 min\cr
12&     98K&    1.8M&    23M&   7M&  0.3G&      3 min&        5 min\cr
11&     37K&    789K&   8.5M& 2.6M&  0.1G&     84 sec&        2 min\cr
10&     14K&    334K&   3.1M& 0.9M&   40M&     45 sec&       21 sec\cr
 9&      5K&    148K&  1124K& 340K&   15M&     30 sec&        7 sec\cr
 8&      2K&     59K&   402K& 119K&    5M&     23 sec&        2 sec\cr
 7&     875&     24K&   144K&  43K&  1.9M&     20 sec&        1 sec\cr
 6&     350&     10K&    50K&  14K&  618K&     17 sec&        0 sec\cr
 5&     146&      4K&    17K&   5K&  206K&     14 sec&        0 sec\cr
 4&      57&    1484&   5410& 1460&   59K&     11 sec&        0 sec\cr
 3&      22&     553&   1658&  430&   17K&      8 sec&        0 sec\cr
 2&       7&     180&    318&   76&    3K&      6 sec&        0 sec\cr
}}$$
* 스탠퍼드 데이터베이스 그룹의 Andy Kacsmar 덕에 메모리 1기가바이트인 컴퓨터에서 했다.
@^Kacsmar, Andrew Charles@>

\smallskip\noindent (너비 $w=24$는 빠졌다. 칸 수가 $n=h+w-1$이고 $h>1$, $w>1$일 때 $h\times w$ 직사각형에
걸치는 $n$-오미노의 총수는 공식
$$
8{h+w-2\choose w-1}-3hw+2h+2w-8
$$
로 주어지기 때문이다.)

@ 구멍을 허락하는 가변 길이 노드의 할당 체계가 꽤 잘 돌아서 크누스는 기뻤다고 한다. 필요할
때 메모리 공간의 98퍼센트 넘게가 대개 제대로 쓰이고 있었다. 사실 $n=47$을 돌릴 때 칸이
가장 많이 필요했던 순간($w=20$일 때 10번째 줄 11번째 열)에 칸 40,219,325개가 쓰였는데
구멍은 8개뿐이었고, 카운터가 가장 많이 필요했던 순간($w=19$일 때 12번째 줄 10번째 열)에
카운터 105,578,552개 가운데 버린 것은 105개뿐이었다.

@ 농담 하나. George P\'olya는 다항체(polyomino)를 연구한 박식가(polymath)였다.
@^joke@>

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 컴파일해 이 판과 견주었다. 표준 출력, 표준 오류, 종료 부호,
그리고 명령어 파일 \.{.0}, \.{.1}, \dots{}와 검사합 파일 \.{.ck}가 바이트까지 같은지를
보았다. 명령어를 해석하려고 {\mc POLYSLAVE}의 일을 하는 짧은 파이썬 프로그램을 따로 짰다.
원본의 {\mc POLYSLAVE}는 법 $m$으로 세지만, 이것은 정확한 정수로 센다.

\smallskip
\item{$\bullet$} 원본이 옳은지는 OEIS A001168과 견주어 보았다. 너비 $w$마다 마지막
|opSync|에서 읽은 셈은 높이가 $w$ 이상인 것이고, 첫 |opSync|에서 읽은 셈은 정사각형인
것이다. 그러니 앞의 것의 두 배에서 뒤의 것을 빼 $w\ge2$에 걸쳐 더하고, $w=1$인 막대를
더하면 $k$-오미노의 수가 된다. 원본은 $k\le14$에서, 이 판은 $k\le20$에서 모두
22964779660까지 맞았다.
\item{$\bullet$} 이 판은 원본과 스무 가지 실행에서 모두 바이트까지 같았다. 곧 $n=14$와
$n=23$에서 여러 $w$, 짜임 칸을 빠듯하게 주어 구멍과 옮기기가 수만 번 생기는 경우, 짜임
메모리와 슬레이브 메모리가 넘치는 경우, 그리고 $n=126$, $w=2$다.
\item{$\bullet$} 파일 크기 문턱을 $2^{16}$바이트로, 체크포인트 문턱을 파일 두 개로 줄인
판을 양쪽에 만들어 파일 나누기와 체크포인트 멈춤도 견주었다. 다른 것은 일부러 형식을
바꾼 덤프 파일과 그 크기를 알리는 줄뿐이다.
\item{$\bullet$} 원본이 버스 오류로 죽는 $w=2$, $n=130$에서 이 판이 낸 셈은 $n=126$일 때의
셈과 126칸까지 같다. 최대 크기 $n$이 커져도 작은 다항체의 수는 달라지지 않아야 한다.
\smallskip

@* 색인.
