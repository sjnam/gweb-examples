\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\title{울람 수와 기브스의 방법}
\font\logo=logo10
\def\MP{{\logo METAPOST}}
\def\bslash{/\mkern-4.5mu/} % 연분수에 쓴다
\let\mod=\bmod

@* 들어가며.
크누스는 울람 수를 몇십억 개 셈해 보려 했다. {\it 울람 수열\/}이란 다음 수열이다.
$$(U_1,U_2,\ldots{})=(1,2,3,4,6,8,11,13,16,18,
                       26,28,36,38,47,48,53,57,62,69,\ldots{})$$
처음 두 항은 $U_1=1$, $U_2=2$이고, 그 뒤로 $U_{n+1}$은 $U_n$보다 큰 수 가운데
$1\le j<k\le n$인 짝 $(j,k)$ 꼭 하나로 $U_j+U_k$라 쓸 수 있는 가장 작은 수다.
(그런 수는 반드시 있다. 없다면 짝 $(j,k)=(n-1,n)$이 조건을 채워 모순이 생긴다.)

{\it 울람 헛수\/}(Ulam miss)란 서로 다른 두 울람 수의 합으로 나타낼 수 없는 수다.
그런 수를 늘어놓으면 이렇다.
$$(1, 2, 23, 25, 33, 35, 43, 45, 67, 92, 94, 96, 111, 121, 136,\ldots{})$$

이 프로그램은 Philip~E. Gibbs의 아름다운 생각들에 바탕을 둔다. 2015년에 처음으로
십억 개의 벽을 넘은 것이 그의 Java 코드였다. 크누스가 십 년 전에 비트 단위로 짠
프로그램 {\mc ULAM}보다 훨씬, 훨씬 빠르다. 게다가 크누스에게 몇 가지를 가르쳐 준
재미난 솜씨가 들어 있어서, 그는 그것을 남들에게도 꼭 전하고 싶었다고 적었다.

울람은 이 수열을 {\sl SIAM Review\/ \bf6} (1964), 348에서 더 넓은 논의의 한
자락으로 꺼냈다. 수열의 성질은 여러 해 동안 정수론 학자들을 어리둥절하게 했지만,
새로운 통찰들이 그림을 바꾸기 시작했다. Stefan Steinerberger는 $\lambda\approx
2.443443$일 때 $U_n/\lambda\mod1$이 거의 언제나 구간
$\bigl[{1\over3}\,.\,.{2\over3}]$에 든다는 것을 실험으로 찾아냈다[``A hidden
signal in the Ulam sequence,'' Report DCS/TR-1508 (Yale University, 2015)].
이어서 Gibbs가 그 성질을 교묘하게 써먹어[``An efficient method for computing Ulam
numbers,'' viXra:1508.0085 (2015)], 처음 $N$항을 셈하는 데 대략 $O(N)$ 시간과
$O(N)$ 공간이면 넉넉함을 보였다. 그 뒤 그는 시간과 공간에 붙는 $N$의 계수를 크게
줄이는 방법도 찾아냈다. 크누스가 어떻게 했느냐고 묻자 그는 선선히 제 프로그램을
보내 주었다.
@^Ulam, Stanis{\l}aw Marcin@>
@^Steinerberger, Stefan@>
@^Gibbs, Philip Edward@>

크누스는 물론 그것을 Java에서 \.{CWEB}으로 옮기지 않고는 못 배겼다. ``그게 내
밥벌이니까.'' 그렇게 나온 것이 원본이고, 이 문서는 그것을 다시 \.{GWEB}으로
옮긴 것이다.

@ 원본은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{ulam-gibbs.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/ulam-gibbs.w}이고, 머리글
\.{Last-Modified}는 \.{Tue, 08 Aug 2017 23:37:54 GMT}다. 옮기며 달라진 곳과 원문에서
찾은 흠은 맨 뒤 「맞춰 보기」장에 모아 두었다.

@ 이 프로그램에는 손볼 수 있는 매개변수가 많아서, 그것들이 성능에 어떤 영향을
주는지 살펴보는 재미가 있다. 가장 중요한 매개변수는 물론 원하는 출력의 개수 $N$이다.
나머지 옵션은 명령줄에서 글자 하나를 앞세워 준다. 이를테면 `\.{v5}'는 수다스러움
매개변수를 $5$로 둔다.

매개변수마다 뒤에서 설명하겠지만, 옵션 글자를 여기 한데 모아 두면 편하다.
\smallskip
\item{$\bullet$}
옵션 `\.v$\langle\,$정수$\,\rangle$'는 |stderr|에 내놓는 여러 가지 수다를 비트
부호로 켠다(기본값 $1$).
\item{$\bullet$}
옵션 `\.p$\langle\,$양의 정수$\,\rangle$'는 $\lambda$의 유리수 근삿값의 분자다(기본값
$120500181$).
\item{$\bullet$}
옵션 `\.q$\langle\,$양의 정수$\,\rangle$'는 그 분모다(기본값 $49315733$). 프로그램은
$p$와 $q$가 $2^{32}$보다 작고 $2<p/q\le3$이라고 가정한다.
\item{$\bullet$}
옵션 `\.m$\langle\,$양의 정수$\,\rangle$'는 출력 간격이다. 울람 수를 $m$번째마다
하나씩 표준 출력에 적는다. \.{m0}이면 $U_N$만 알린다.
\item{$\bullet$}
옵션 `\.g$\langle\,$양의 정수$\,\rangle$'는 통계를 모으는 가장 큰 간격이다(기본값
$2000$).
\item{$\bullet$}
옵션 `\.o$\langle\,$양의 정수$\,\rangle$'는 ``바깥값''과 ``준바깥값''을 담을 자리의
크기다(기본값 $1000000$).
\item{$\bullet$}
옵션 `\.i$\langle\,$양의 정수$\,\rangle$'는 그 목록들에 붙이는 색인의 크기다(기본값
$100000$).
\item{$\bullet$}
옵션 `\.T$\langle\,$양의 실수$\,\rangle$'는 `준바깥값'을 정의하는 문턱이다(기본값
$100$).
\item{$\bullet$}
옵션 `\.b$\langle\,$양의 정수$\,\rangle$'는 |isUm| 표의 비트를 몇 개씩 한 바이트에
담을지 정한다(기본값 $18$). 이 기본값이 가장 좋다. 옵션 \.{b19}는 $N>2198412$이면 너무
크다고 판명되었다.
\item{$\bullet$}
옵션 `\.B$\langle\,$양의 정수$\,\rangle$'는 한 바이트에 한 비트씩 적는 |isUlam|
앞자리의 수다(기본값 $18000$). \.b 옵션의 배수여야 하고 적어도 $3$이어야 한다.
\item{$\bullet$}
옵션 `\.w$\langle\,$양의 정수$\,\rangle$'는 최근에 셈한 울람 수를 기억해 둘 창의
크기다(기본값 $1000000$). 창의 크기는 적어도 $3$이어야 한다.
\item{$\bullet$}
옵션 `\.M$\langle\,$파일 이름$\,\rangle$'을 주면, 울람 수와 울람 헛수를 $\lambda$로
나눈 나머지가 어떻게 흩어지는지 보여 주는 \MP\ 그림을 만든다.

@ 크누스의 원문에는 \.m의 기본값이 $1000000$이라고 적혀 있다. 그런데 코드에서 그
값을 담는 변수 |spacing|에는 초깃값이 없어 $0$이고, 그래서 \.m을 주지 않으면
$U_N$ 하나만 찍힌다. 원본 C를 지어 돌려 보아도 그렇다. 나는 코드를 따랐고, 위
목록에서 기본값 이야기를 뺐다.

@ 수다 매개변수 |vbose|는 다음 이진 부호들의 합이다. 모두 켜려면 `\.{v-1}'이라
하면 된다.

@<상수@>=
const (
	showUsageStats       = 1    // 시간과 공간 쓰임을 알린다
	showCompressionStats = 2    // |isUlam| 부호화를 자세히 알린다
	showHistograms       = 4    // $\lambda$에 대한 울람 수와 헛수의 나머지를 알린다
	showGapStats         = 8    // 간격마다 히스토그램과 보기를 준다
	showRecordGaps       = 16   // 앞선 것을 모두 넘어선 간격을 알린다
	showRecordOutliers   = 32   // 앞선 것을 넘어선 바깥값을 알린다
	showOutlierDetails   = 64   // 바깥값을 넣고 뺄 때마다 알린다
	showRecordCutoffs    = 128  // 준바깥값의 잉여 한계를 알린다
	showOmittedInliers   = 256  // 준바깥값이 아닌 안값을 알린다
	showBruteWinners     = 512  // 무차별 탐색 뒤에 드문 경우를 알린다
	showInlierAnchors    = 1024 // 두 안값이 울람 수를 이룰 때 알린다
)

@ 프로그램 전체의 얼개는 이렇다.

크누스는 mem을 세려고 매크로 |o|, |oo|, |ooo|를 두었다. mem 하나는 64비트 메모리를
한 번 읽거나 쓰는 것이다. \GO/에는 매크로가 없으므로, 그 자리마다 |mems++|나
|mems+=2|를 문장 앞에 적는다. 크누스는 C의 나머지 연산자를 적으려고 |mod|라는
매크로도 두었는데, \GO/에서는 그냥 |%|를 쓴다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
	"time"
	"unsafe"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	var i, j, k, r, rp, t, x, count int
	var n, u, up uint64
	var hits bool
	var g float64
	@<명령줄을 처리한다@>@;
	@<배열을 마련한다@>@;
	@<자료 구조를 초기화한다@>@;
	for u = 3; n < maxn; u++ {
		@<|u|가 울람 수인지 울람 헛수인지 둘 다 아닌지 가리고 자료 구조를 고친다@>@;
	}
	if mpFile != nil {
		@<\MP\ 파일을 내놓는다@>@;
	}
finishUp:
	@<작별 인사를 찍는다@>@;
}

@ 같은 매개변수를 두 번 주면 앞의 것이 이긴다. 뒤에서부터 읽기 때문이다.

@<명령줄을 처리한다@>=
if len(os.Args) == 1 {
	k = 1
} else {
	k = sscan(os.Args[len(os.Args)-1], &maxn) // $N$을 읽는다
	for j = len(os.Args) - 2; j > 0; j-- {
		a := os.Args[j]
		var c byte
		if a != "" {
			c = a[0]
		}
		switch c {
		@<옵션 하나에 답한다. 틀리면 |k|를 $0$ 아닌 값으로 둔다@>@;
		default:
			k = 1 // 알 수 없는 옵션
		}
	}
}
@<문제가 있으면 쓰는 법을 알리고 끝낸다@>@;

@ 명령줄의 수는 크누스의 |sscanf| 대신 |fmt.Sscan|이 읽는다. 둘 다 앞쪽 공백을
건너뛰고 숫자를 읽다가, 뒤에 붙은 것은 모른 척한다. 그러니 `\.{v5x}'는 둘 모두에게
$5$다. 크누스를 따라 성공하면 $0$을, 실패하면 $-1$을 돌려준다.

@<함수들@>=
func sscan(s string, p any) int {
	n, _ := fmt.Sscan(s, p)
	return n - 1
}

@ @<전역 변수@>=
var (
	maxn       uint64           // 셈하려는 울람 수의 개수
	vbose      = showUsageStats // 수다스러움의 정도
	lamp       = 120500181      // $\lambda$의 분자
	lamq       = 49315733       // $\lambda$의 분모
	spacing    uint64           // 찍는 간격. $0$이면 마지막 것만 찍는다
	misses     uint64           // 여태 본 울람 헛수의 수
	biggestgap = 1              // 여태 본 가장 큰 간격
	maxgap     = 2000           // 히스토그램을 모으는 가장 큰 간격
	outliers   = 1000000        // 기억할 바깥값과 준바깥값의 최대 수
	isize      = 100000         // 두 색인을 합친 크기(언제나 짝수)
	thresh     = 100.0          // 준바깥값을 기억하는 문턱
	mems       uint64           // mem 수
	bytes      uint64           // 주요 자료 구조가 쓰는 메모리
	started    = time.Now()     // 프로그램이 뜬 때
	bitsPerCompressedByte = 18      // 채워 넣기 매개변수
	uncompressedBytes     = 18000   // 앞쪽의 |isUlam| 비트 이만큼은 채워 넣지 않는다
	windowSize            = 1000000 // 최근 울람 수를 이만큼 기억한다
	mpFile     *os.File                   // 원하면 \MP\ 코드를 내놓을 파일
	mpName     string                     // 그 이름
	out        = bufio.NewWriter(os.Stdout) // 표준 출력
)

@ @<옵션 하나에 답한다. 틀리면 |k|를 $0$ 아닌 값으로 둔다@>=
case 'v':
	k |= sscan(a[1:], &vbose)
case 'p':
	k |= sscan(a[1:], &lamp)
case 'q':
	k |= sscan(a[1:], &lamq)
case 'm':
	k |= sscan(a[1:], &spacing)
case 'g':
	k |= sscan(a[1:], &maxgap)
case 'o':
	k |= sscan(a[1:], &outliers)
case 'i':
	k |= sscan(a[1:], &isize)
	isize = (isize + 1) &^ 1 // |isize|를 가장 가까운 짝수로 올린다
case 'T':
	k |= sscan(a[1:], &thresh)
case 'b':
	k |= sscan(a[1:], &bitsPerCompressedByte)
case 'B':
	k |= sscan(a[1:], &uncompressedBytes)
case 'w':
	k |= sscan(a[1:], &windowSize)
case 'M':
	mpName = a[1:]
	f, err := os.Create(mpName)
	if mpFile = f; err != nil {
		mpFile = nil
		fmt.Fprintf(os.Stderr, "미안하지만 파일 %s에 쓸 수 없다!\n", mpName)
	}

@ 크누스의 확인에 몇 가지를 더했다. 원본이 $0$으로 나누다 죽거나(\.{q0}, \.{b0})
엉뚱한 크기의 메모리를 잡으려 들던(\.{N}이 $0$이거나 크기가 음수) 인자를 여기서
미리 거른다.

@<문제가 있으면 쓰는 법을 알리고 끝낸다@>=
if k != 0 || maxn == 0 || uncompressedBytes < 3 ||
	bitsPerCompressedByte <= 0 || bitsPerCompressedByte > 32 ||
	uncompressedBytes%bitsPerCompressedByte != 0 ||
	lamq <= 0 || lamp >= 1<<32 || (lamp-1)/lamq != 2 || windowSize < 3 ||
	maxgap < 0 || outliers < 0 || isize < 0 {
	fmt.Fprintf(os.Stderr, "쓰는 법: %s [v<n>] [p<n>] [q<n>] [m<n>] [g<n>] [o<n>] [i<n>]"+
		" [T<f>] [b<n>] [B<n>] [w<n>] [Mfoo.mp] N\n", os.Args[0])
	os.Exit(1)
}

@ 중요한 고리가 몇 번 도는지에 대한 통계는 \&{stat} 구조에 모은다.

@<자료형@>=
type stat struct {
	n    uint64  // 표본의 수
	mean float32 // 경험적 평균
	max  int     // 경험적 최댓값
	ex   uint64  // |max|를 낳은 극단적인 보기
}

@ @<함수들@>=
func recordStat(s *stat, datum int, u uint64) {
	if s.n == 0 {
		s.n, s.mean, s.max, s.ex = 1, float32(datum), datum, u
	} else {
		s.n++
		s.mean += (float32(datum) - s.mean) / float32(s.n)
		if datum > s.max {
			s.max, s.ex = datum, u
		}
	}
}

@* 알고리즘 뒤의 생각.
Gibbs의 방법은 값 $(U_n/\lambda)\mod 1$이 거의 모두 1/3과 2/3 사이에 놓인다는
놀라운 사실에 바탕을 둔다. 이 프로그램의 \MP\ 옵션으로 그린 그림 하나를 보자.
$1\le n\le N=1000000$에서 그 잉여들이 어떻게 흩어져 있는지 보여 준다.
$$\mplibcode
newinternal n; numeric a[];
def init =
  draw (1,0)--(128,0);
  for j=1 upto 128: a[j]:=0; endfor
  pickup pencircle;
enddef;
def doit(text j) text l =
  drawoptions(withcolor j/16[green,red]);
  n:=1;
  for t=l:
   if t>0: draw (n,a[n])--(n,a[n]+t); a[n]:=a[n]+t; fi
   n:=n+1;
  endfor
enddef;
beginfig(1) init;
doit(15)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,4,
  4,4,5,5,5,5,5,5,4,4,3,2,2,1,0,0,
  0,0,0,0,0,0,0,0,1,3,4,5,5,5,5,5,
  4,3,2,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(14)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,
  5,5,4,5,5,5,5,5,5,3,3,3,2,1,0,0,
  0,0,0,0,0,0,0,0,1,2,4,4,5,5,5,4,
  4,3,3,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(13)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,2,3,3,4,4,
  4,4,5,5,5,5,5,4,4,4,3,2,1,1,0,0,
  0,0,0,0,0,0,0,0,1,3,4,5,5,5,5,4,
  3,3,2,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(12)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,
  5,5,5,5,5,5,6,5,4,3,3,2,2,0,0,0,
  0,0,0,0,0,0,0,0,1,3,4,5,5,6,5,5,
  4,3,3,2,2,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(11)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,4,
  4,4,4,5,5,6,5,5,5,4,3,2,2,1,0,0,
  0,0,0,0,0,0,0,0,1,3,4,5,5,5,4,4,
  4,3,2,2,1,1,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(10)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,1,1,2,4,5,5,
  5,5,5,5,5,5,5,5,4,4,2,3,2,1,0,0,
  0,0,0,0,0,0,0,0,1,3,4,4,5,5,5,5,
  3,3,2,1,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(9)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,4,
  4,4,5,4,4,5,5,4,4,3,3,2,1,1,0,0,
  0,0,0,0,0,0,0,0,1,2,4,5,5,5,5,4,
  4,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(8)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,2,3,3,4,4,
  5,5,4,5,5,5,5,5,4,4,3,2,2,1,0,0,
  0,0,0,0,0,0,0,0,1,3,4,5,5,5,5,5,
  4,3,2,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(7)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,
  4,4,5,5,5,5,5,5,5,3,3,3,2,1,0,0,
  0,0,0,0,0,0,0,0,1,3,4,4,6,5,5,4,
  4,3,3,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(6)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,4,
  5,4,5,5,5,5,5,5,4,4,3,2,2,1,0,0,
  0,0,0,0,0,0,0,0,2,3,4,5,5,6,5,5,
  4,3,2,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(5)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,
  4,5,5,4,5,5,5,5,5,3,3,2,1,0,0,0,
  0,0,0,0,0,0,0,0,1,2,4,5,5,5,5,4,
  3,3,2,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(4)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,4,
  5,5,4,5,5,6,6,5,4,4,3,2,2,1,0,0,
  0,0,0,0,0,0,0,0,0,3,4,4,5,5,5,5,
  4,3,3,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(3)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,3,3,4,5,
  4,4,5,5,5,5,5,4,4,4,3,3,2,1,0,0,
  0,0,0,0,0,0,0,0,1,3,4,5,5,5,5,4,
  4,3,2,2,2,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(2)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,2,2,3,4,4,
  5,4,5,5,5,5,5,5,5,4,3,2,2,1,0,0,
  0,0,0,0,0,0,0,1,1,2,4,5,5,5,4,5,
  4,3,3,1,1,1,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(1)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,1,1,2,3,4,5,
  4,5,4,5,5,5,5,5,4,3,2,2,1,1,0,0,
  0,0,0,0,0,0,0,0,2,3,4,4,5,6,5,4,
  4,3,2,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
doit(0)
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,2,4,4,4,
  5,4,5,4,5,5,5,5,4,4,3,3,2,1,0,0,
  0,0,0,0,0,0,0,0,1,3,4,5,5,5,5,4,
  4,3,3,2,1,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
endfig;
\endmplibcode$$
색은 작은 $n$의 초록에서 $N$에 가까운 $n$의 빨강으로 옮아간다. 그래서 $n$이
커지면서 분포가 꽤 안정된 모양으로 ``자리 잡는'' 모습이 보인다.

정수 $U$가 있고 그 잉여를 $\rho=(U/\lambda)\mod1$이라 하자. 준주기의 길이
$\lambda$가 무리수라고 가정해도 괜찮다. ``이런 문제에 나오는 유리수가 정말 큰
분모를 가지기를 신이 바라지는 않았을 테니까.'' 그 가정 아래서 $\rho$는 결코
유리수가 아니고, $U\ne U'$이면 $\rho\ne\rho'$이다. (물론 실제 셈은 $\lambda$의
유리수 근삿값으로 하므로 $\rho=\rho'$인 경우를 수없이 만나게 된다.)

Steinerberger는 2015년에, 알려진 모든 $U_n$에 대해 $\rho_n$이 1/4과 3/4 사이에
있다는 것을 실험으로 찾았다. 예외는 $U_2=2$ ($\rho_2\approx.82$), $U_3=3$
($\rho_3\approx.23$), $U_{15}=47$ ($\rho_{15}\approx.23$), $U_{20}=69$
($\rho_{20}\approx.24$)의 넷뿐이다. 그 까닭은 아직 모르지만 사실은 사실이다.

Gibbs는 한 걸음 더 나아가 $\rho<1/3$이거나 $\rho>2/3$인 $U$를 {\it 바깥값\/}(outlier)이라
정의했다. 두 {\it 안값\/}(inlier)의 합은 안값일 수 없으므로 바깥값이 무한히 많아야
한다는 것도 알아차렸다. 그러면서 어떤 $\epsilon>0$에 대해서도 $\rho_n<1/3-\epsilon$이거나
$\rho_n>2/3+\epsilon$인 $n$은 유한히 많을 뿐이라고 추측했다. 또 알려진 경우의
대부분에서, 하나뿐인 표현 $U_n=U_i+U_j$의 $U_i$나 $U_j$ 가운데 하나가 바깥값이라는
것도 관찰했다.

이것을 더 파고들자. 세 수가 $U=U'+U''$를 채우면 $\rho=\rho'+\rho''$이거나
$\rho=\rho'+\rho''-1$이다. 둘째 경우는 $\bar\rho=1-\rho$로 두면
$\bar\rho=\bar\rho'+\bar\rho''$로 쓸 수 있다.

잉여가 $\rho<1/4$이거나 $\rho>3/4$이면, 짧은 무차별 탐색으로 $U$를 두 울람 수의
합으로 나타내는 전혀 다른 표현 둘을 거의 언제나 찾을 수 있다.

반면에 $1/4<\rho<3/4$이면, $\rho=\rho'+\rho''$이고 $\rho'<\rho''$인 경우나
$\bar\rho=\bar\rho'+\bar\rho''$이고 $\bar\rho'<\bar\rho''$인 경우를 비교적 조금만
살펴도 $U$가 울람 수의 합 $U'+U''$인지 대개 가릴 수 있다. Gibbs는 $U'$가
바깥값이거나 {\it 준바깥값\/}(near outlier)인 경우만 살펴도 넉넉하다는 것을 실험으로
찾아냈다. 준바깥값은 다음 조건으로 정의한다.
$$
\hbox{$\rho'<1/2$이고 $(\rho'-1/3)\sqrt{U'}\le\theta$}\qquad\hbox{또는}\qquad
\hbox{$\bar\rho'<1/2$이고 $(\bar\rho'-1/3)\sqrt{U'}\le\theta$}$$
여기서 $\theta$는 우리 프로그램의 문턱 매개변수 |thresh|다. 수 $U'$가 크고
$\rho'>1/3$이면, $\rho'$가 1/3에 {\it 아주\/} 가깝지 않은 한 $U'$는 살펴볼
필요가 없다.

그러니 이미 셈한 울람 수에 대해 자세한 정보를 너무 많이 기억할 필요가 없다. 무차별
탐색에는 적당히 작은 창 하나면 되고, 다른 탐색에는 $\rho'$ 순서로 늘어놓은 바깥값과
준바깥값 $U'$의 사전 하나면 된다.

@ 그 비교적 짧은 표들 말고도, 주어진 수 $u\le U_N$이 울람 수인지 아닌지 가릴 방법이
필요하다. 흔들림이 크지 않은 $U_N\approx 13.5178N$이라는 것이 실험으로 알려져
있다. 그러니 $U_N<14N$이라고 마음 놓고 가정할 수 있고, $14N$ 비트짜리 표면
충분하다.

그래도 $14N$ 비트는 $1.75N$ 바이트라, $N$이 수십억이면 적지 않다. Gibbs는
메모리가 16기가바이트뿐인 컴퓨터로 일했고, 궁하면 통한다고 했다. 그는 18비트를
한 바이트에 채워 넣어 필요한 메모리를 $.778N$ 바이트로 줄이는 방법을 고안했다.
비트 무늬의 엔트로피가 꽤 낮아서 이 줄이기가 가능했고, 편하기까지 했다. 실제로
준주기계가 꽤 안정될 만큼 $n$이 크기만 하면, 잇닿은 $n$값 18개에 대한 |isUlam| 표의
비트 무늬는 많아야 256가지만 나온다.

@ Gibbs의 초기 프로그램은 잉여 $\rho$를 부동소수점으로 셈했다. 그러다 보니 까다로운
경우와 미묘한 문제가 생겼다. 그러다 $\lambda$의 유리수 근삿값을 쓰면 반올림 오차를
피할 수 있다는 것을 깨달았고, 덕분에 프로그램이 더 간단해지기까지 했다.

그는 $\rho<1/3$인 ``낮은'' 바깥값의 수와 $\rho>2/3$인 ``높은'' 바깥값의 수가 거의
같아질 때까지 조정해서 $\lambda$의 좋은 근삿값을 실험으로 찾았다. 그 값은
$$\lambda\;\approx\;2.443442967784743$$
이고, 그다음 자리는 아직 정해지지 않았다. 따라서 정규 연분수는
$$\lambda\;=\;
  2+\bslash 2,3,1,11,1,1,4,1,1,7,1,2,1,1,2,2,1,3,1,2,\ldots{}\bslash$$
이다. 표기법은 {\sl Seminumerical Algorithms\/}의 \S4.5.3을 따랐다. 이 연분수를
자르면 $\lambda$의 좋은 유리수 근삿값이 나온다. 연습문제 4.5.3--42에 나오는
라그랑주의 정리에 따르면 사실 이것들이 ``가장 좋은'' 근삿값이다.
$$2;\quad
{5\over2};\quad
{17\over7};\quad
{22\over9};\quad
{259\over106};\quad
{281\over115};\quad
{540\over221};\quad
{2441\over999};\quad
\ldots;\quad
{35876494\over14682763};\quad
{84623687\over34632970}\hbox{ 또는 }
{120500181\over49315733}.$$
마지막 둘은 참값을 양쪽에서 감싸는 것으로 보인다. 맨 마지막 것이 지금의
기본값이지만, 다른 것도 아마 똑같이 좋은 결과를 줄 것이다.

근삿값 $\lambda=p/q$를 쓰면 공식 $\rho=U/\lambda\mod1$은 다음처럼 바뀐다.
$$r\;=\;qU\mod p.$$
이제 잉여는 {\it 정수\/} $r$이고, 0과 1 사이의 분수 $\rho$ 대신 $0$과 $p-1$ 사이에
놓인다. (프로그램 변수 |lamp|와 |lamq|가 $p$와 $q$에 해당한다.)

@ 이 생각들은 작은 수로 먼저 해 보면 가장 쉽게 몸에 붙는다. 보기로 $p=22$,
$q=9$라 하자. 그러면 $\lambda$의 꽤 괜찮은 근삿값 $2.4444\ldots\,$가 된다.
처음 100개의 $r_n=9U_n\mod22$ 값은 보기 좋게 모여 있다.
$$\displaylines{\quad
\{5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7,
  7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9,
\hfill\cr\hfill
 10, 10, 10, 10, 10, 10,
 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
  11, 12, 12,
 12, 12, 12, 12, 12, 12,
\hfill\cr\hfill
12, 12, 12, 12, 12, 12, 12, 13, 13,
  13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16,
  18\}.\quad\cr}$$
더 나은 근삿값 $\lambda\approx540/221=2.44344\ldots\,$을 쓰면
$r_n=221U_n\mod540$이 더 자세한 모습을 보여 준다.
$$\displaylines{\quad
\{123, 127, 129, 148, 166, 173, 176, 177, 182, 185,
  185, 189, 198, 202, 202, 204, 206, 206, 208, 209,
\hfill\cr\hfill
  210, 211, 217, 218, 220, 221, 222, 225, 227, 230,
  233, 234, 235, 237, 241, 242, 243, 244, 246, 246,
\hfill\cr\hfill
  248, 248, 249, 252, 252, 258, 261, 262, 265, 271,
  277, 278, 279, 282, 289, 293, 296, 298, 299, 301,
\hfill\cr\hfill
  302, 303, 306, 308, 308, 309, 311, 316, 318, 324,
  325, 327, 327, 330, 331, 332, 334, 335, 336, 337,
\hfill\cr\hfill
  339, 341, 342, 344, 344, 346, 346, 348, 354, 360,
  363, 373, 376, 377, 380, 393, 396, 399, 402, 442\}.\quad\cr}$$
근삿값 $\lambda=540/221$에서 바깥값은 $r<180$이거나 $r\ge360$인 것이다.
덧붙이면 $U_{100}=690$이다.

@* 압축 방식.
낮은 수준의 |isUlam| 표 루틴부터 짜면서 자신감을 쌓아 가자. 그 표는 두 부분으로
되어 있다. 앞부분 $0\le n<|uncompressedBytes|$에서는 간단히, |n|이 울람 수이면
|isUlam[n]=1|, 아니면 |isUlam[n]=0|이다. 그러나 |n>=uncompressedBytes|에서는
|isUm|이라는 압축된 표가 필요한 정보를 가볍게 부호화해 담는다.

곧, 명령줄의 \.b 옵션(보통 18)을 |b=bitsPerCompressedByte|라 하자. 그러면
|isUm[n/b]|는 바이트 |t|이고, |isUlam[n]|은 |code[t]|의 비트 $n\mod b$로
나타난다. 이 약속은 $|uncompressedBytes|\le n<|curSlot|$에 적용된다. 여기서
|curSlot|은 $b\times\lfloor u/b\rfloor$이고 |u|는 지금 살피는 수다. 끝으로
|curSlot|에서 시작하는 수 |b|개의 |isUlam| 비트는 |b|비트짜리 수 |curCode|로 따로
둔다.

부호어가 256개보다 많이 필요하면 물론 손을 들어야 한다. 보조 표들이 정보를 더
준다. 표 |codeUse[t]|는 |code[t]|를 몇 번 썼는지 적고, 표 |codeExample[t]|는
|code[t]|가 필요했던 가장 작은 |curSlot|을 적는다. 속도에 모든 것을 걸었다면
|codeUse|와 |codeExample|은 뺐을 것이라고 크누스는 적었다. 그 값은 언제나 셈하지만
|showCompressionStats|를 켰을 때만 알린다.

프로그램이 쓰는 메모리의 대부분은 |isUm| 표다. 살펴야 할 수 |u|의 윗한계가
$14|maxn|$이므로 이 표는 $\lceil 14|maxn|/b\rceil$ 바이트를 차지한다. (표 |isUm|의
앞쪽 |uncompressedBytes/b| 바이트는 결코 쓰이지 않는다. 프로그램을 짜기 쉽게 한
대가치고는 작다.)

@<전역 변수@>=
var (
	isUlam, isUm []byte      // 울람 수인지 가리는 주 배열
	curSl        uint64      // |isUm|의 앞쪽 이만큼 바이트는 제대로 채워졌다
	curSlot      uint64      // |bitsPerCompressedByte*curSl|
	curCode      uint32      // 다음에 압축할 |bitsPerCompressedByte|개의 비트
	code         [256]uint32 // 압축한 바이트마다 펼친 ``뜻''
	invCode      []byte      // |code| 표의 역
	codePtr      = 1         // 여태 정한 부호의 수
	codeUse, codeExample [256]uint64 // |code|의 통계
)

@ 털어놓자면, 쓴 메모리 바이트 수 |bytes|는 |isUlam|, |isUm|, |code| 같은 꼭
필요한 표만 센다. 진단용 배열 |codeUse|나 |codeExample|에 드는 메모리는 치지
않는다. 프로그램 자체와 그 원자적인 전역 변수에 할당된 메모리도 태연히 무시한다.

메모리를 할당하는 비용도 무시한다. 프로그램이 스스로를 띄우는 동안 할당이 하는
메모리 접근은 |mems|에 들어가지 않는다.

크누스는 할당이 실패하면 알리고 끝내는 매크로 |alloc_quit|을 두었다. \GO/의
|make|는 메모리를 얻지 못하면 런타임이 스스로 멈추므로 여기서는 그런 확인을 두지
않았다. 메모리 수 |bytes|에 더하는 크기는 C의 |sizeof|에 해당하는
|unsafe.Sizeof|로 센다.

@<배열을 마련한다@>=
isUlam = make([]byte, uncompressedBytes)
bytes += uint64(uncompressedBytes) * uint64(unsafe.Sizeof(isUlam[0]))
u = (14*maxn-1)/uint64(bitsPerCompressedByte) + 1
isUm = make([]byte, u)
bytes += u * uint64(unsafe.Sizeof(isUm[0]))
invCode = make([]byte, 1<<bitsPerCompressedByte)
bytes += (1 << bitsPerCompressedByte) * uint64(unsafe.Sizeof(invCode[0]))
bytes += uint64(unsafe.Sizeof(code)) // 미리 잡아 둔 |code| 표

@ 정의에 따라 $U_1=1$이고 $U_2=2$다. 이것으로 시작한다.

@<자료 구조를 초기화한다@>=
mems += 3; isUlam[0] = 0; isUlam[1], isUlam[2] = 1, 1
curSlot = uint64(uncompressedBytes); curSl = curSlot / uint64(bitsPerCompressedByte)

@ 주어진 |x|가 울람 수인지 가리는 방법을 자세히 보자. (수 |x|는 지금 수 |u|보다
작고, |u|는 많아야 |curSlot+bitsPerCompressedByte|라고 은연중에 가정한다.)

@<함수들@>=
func ulamq(x uint64) bool { // |x|가 울람 수인가
	if x >= curSlot {
		return curCode&(1<<(x-curSlot)) != 0
	}
	if x < uint64(uncompressedBytes) {
		return isUlam[x] != 0
	}
	q, r := x/uint64(bitsPerCompressedByte), x%uint64(bitsPerCompressedByte)
	mems++; c := isUm[q]
	mems++; t := code[c]
	return t&(1<<r) != 0
}

@ 수 |u|가 울람 수인지 판가름하고 나면 그 결과를 다음처럼 표에 적는다.

@<|ulamness|를 |isUlam|이나 |isUm| 표에 적는다@>=
if u < curSlot {
	mems++; isUlam[u] = byte(ulamness)
} else if u == curSlot+uint64(bitsPerCompressedByte) {
	@<|curCode|를 갈무리하고 다음 것을 채비한다@>@;
} else if ulamness != 0 {
	curCode += 1 << (u - curSlot)
}

@ 언제나 |code[0]=0|이다.

@<|curCode|를 갈무리하고 다음 것을 채비한다@>=
mems++; t = int(invCode[curCode])
if t == 0 {
	if curCode != 0 {
		@<새 부호 |t|를 정한다@>@;
	} else if codeExample[0] == 0 {
		codeExample[0] = curSlot
	}
}
mems++; isUm[curSl] = byte(t)
codeUse[t]++ // 진단용 통계라 mem을 치지 않는다
curSl++; curSlot += uint64(bitsPerCompressedByte)
curCode = uint32(ulamness)

@ @<새 부호 |t|를 정한다@>=
if codePtr == 256 {
	fmt.Fprintf(os.Stderr, "이런, 부호가 256개로는 모자란다! b를 줄여야 한다.\n")
	goto finishUp
}
mems++; t = codePtr; invCode[curCode] = byte(codePtr)
codeExample[codePtr] = curSlot // mem을 치지 않는다
mems++; code[codePtr] = curCode; codePtr++

@* 요긴한 울람 수 기억하기.
계속 낮은 수준에서, 이미 본 울람 수에 대한 중요한 사실을 기억하는 다른 자료
구조들을 짜 보자.

먼저 |window| 표가 있는데, 이것은 쉽다. 가장 최근에 찾은 울람 수
|windowSize|개를 담는 고리 버퍼일 뿐이다.

@<배열을 마련한다@>=
window = make([]uint64, windowSize)
bytes += uint64(windowSize) * uint64(unsafe.Sizeof(window[0]))

@ 값 $|nw|=n\mod|windowSize|$를 늘 유지한다.

@<|u|를 |window|에 넣는다@>=
mems++; window[nw] = u

@ 지금까지 찾은 바깥값과 준바깥값을 기억하는 다른 구조들이 더 흥미롭다. 그 수들은
잉여의 차례로 처리해야 한다.

Gibbs는 이를 위해 이중 연결 리스트에 색인을 붙인 특별한 자료 구조를 도입했다.
여기서는 비슷하지만 더 간단한 구조를 쓴다. 단일 연결 리스트 {\it 둘\/}에 색인
{\it 둘\/}을 붙인 것이다.

다행히 바깥값과 준바깥값의 수가 넉넉히 적어서, 저장할 때 메모리를 너무 아낄 필요는
없다. 탐색 목록의 노드마다 밭이 셋 있다. 둘은 수와 그 잉여를 담고, 하나는 다음
노드를 가리킨다. 크누스의 노드는 16바이트다. 그 크기를 지키려고 잉여와 링크를
|int32|로 두었다.

@<자료형@>=
type node struct {
	u    uint64 // 울람 수
	r    int32  // 그 잉여
	next int32  // |r|의 차례로 다음 노드를 가리킨다
}

@ 탐색 목록은 둘이다. 하나는 잉여가 작은 바깥값과 준바깥값을 담고, 하나는 잉여가
큰 것을 담는다. 뒤의 것에는 |r| 자체 대신 여잉여 $\bar r=p-r$을 탐색 키로 넣는다.
두 목록 모두 키가 커지는 차례로 훑기 때문이다.

키 |r|이 같은 노드끼리는 |u| 값의 차례를 따른다.

두 목록의 노드는 모두 |nmem| 배열에 있고, 목록 머리 |loOut|과 |hiOut|이 자리
$0$과 $1$에 있다. 크누스의 매크로 |bar(r)|은 함수가 되었다.

@<상수@>=
const (
	loOut = 0 // 잉여가 작은 목록의 머리
	hiOut = 1 // 잉여가 큰 목록의 머리
)

@ @<함수들@>=
func bar(r int) int {
	return lamp - r
}

@ @<전역 변수@>=
var (
	window   []uint64    // 최근 울람 수를 기억하는 고리 버퍼
	nw       int         // $n\mod|windowSize|$
	nmem     []node      // 탐색 목록의 노드들
	nodePtr  = 2         // 쓰고 있는 노드의 수
	inx      [2][]uint32 // 목록마다의 색인
	avail    int         // 쓸 수 있는 노드 더미의 머리
	insStats [2]stat     // 두 목록에 넣을 때의 통계
)

@ @<배열을 마련한다@>=
nmem = make([]node, 2+outliers)
bytes += uint64(2+outliers) * uint64(unsafe.Sizeof(node{}))
inx[0] = make([]uint32, isize/2+1)
inx[1] = make([]uint32, isize/2+1)
bytes += uint64(isize+2) * uint64(unsafe.Sizeof(inx[0][0]))

@ 목록은 |null| 링크 $0$이나 |danger| 링크 $1$로 끝난다. 뒤의 것은 뒤에서
이야기한다. 처음에는 목록이 비어 있고, 색인 항목은 모두 |r| 밭이 $0$인 목록
머리를 가리킨다.

@<상수@>=
const (
	null   = 0 // 목록의 끝
	danger = 1 // 잘라 낸 목록의 끝
)

@ @<자료 구조를 초기화한다@>=
mems += 2; nmem[loOut].next = null; nmem[loOut].r = 0
mems += 2; nmem[hiOut].next = null; nmem[hiOut].r = 0
for i = 0; i <= isize/2; i++ {
	mems += 2; inx[0][i] = loOut; inx[1][i] = hiOut
}
avail = 0

@ 이제 이런 목록에 새 노드를 넣는 방법이다. 핵심 불변식은 이렇다. 키 |r|이 색인
항목 |j|에서 출발하게 한다면, $j'>j$인 모든 색인은 |r|보다 {\it 엄격히\/} 큰 키에
대해서만 살펴진다. 그러므로 그 색인들이 새로 넣은 노드를 가리켜도 괜찮다.

이 서브루틴은 |u|가 목록에 이미 있는 어떤 |u| 밭보다도 클 때만 불린다.

크누스의 매크로 |insert|는 |ins|가 실패하면 넘침을 알리고 |finish_up|으로
건너뛰었다. 매크로도, 함수 밖으로 나가는 |goto|도 \GO/에는 없으므로 여기서는
|ins|가 스스로 넘침을 알리고 |false|를 돌려준다. 부르는 쪽은 그것을 보고
|finishUp|으로 간다.

@<함수들@>=
func ins(head int, u uint64, r int) bool {
	var j, x, y, z, count int
	if avail != 0 {
		mems++; z = avail; avail = int(nmem[avail].next) // 되살린 노드를 다시 쓴다
	} else if nodePtr < 2+outliers {
		z = nodePtr; nodePtr++
	} else {
		fmt.Fprintf(os.Stderr, "어이쿠, 바깥값 자리가 넘친다(크기=%d)!\n", outliers)
		return false // 더 둘 자리가 없다
	}
	mems += 2; nmem[z].u = u; nmem[z].r = int32(r)
	if vbose&showOutlierDetails != 0 {
		fmt.Fprintf(os.Stderr, " (%s %d 기억, %s=%d)\n",
			nearName(r), u, keyName(head), r)
	}
	@<|r| 앞에서 멈출 노드 |x|와 그 뒤의 |y|를 찾는다@>@;
	mems += 2; nmem[x].next = int32(z); nmem[z].next = int32(y)
	for j++; j <= isize/2; j, count = j+1, count+1 {
		mems += 2
		if int(nmem[inx[head][j]].r) > r {
			break
		}
		mems++; inx[head][j] = uint32(z)
	}
	recordStat(&insStats[head], count, u)
	return true
}

@ 색인에서 출발해 목록을 따라가다가, 키가 |r|을 넘는 노드 앞에서 멈춘다. 이 대목은
뒤의 |forget|에서 한 번 더 쓴다.

@<|r| 앞에서 멈출 노드 |x|와 그 뒤의 |y|를 찾는다@>=
j = int(uint64(r) * uint64(isize) / uint64(lamp))
mems++; x = int(inx[head][j])
mems++; y = int(nmem[x].next)
for count = 1; y > danger; count++ {
	mems++
	if int(nmem[y].r) > r {
		break
	}
	mems++; x = y; y = int(nmem[x].next)
}

@ 알림말에 넣을 이름 둘이다. 크누스는 조건 연산자로 그 자리에서 골랐다.

@<함수들@>=
func nearName(r int) string {
	if r > lamp/3 {
		return "준바깥값"
	}
	return "바깥값"
}

func keyName(head int) string {
	if head == hiOut {
		return "rbar"
	}
	return "r"
}

@ 준바깥값이 버린 안값보다 더 ``안쪽''이 되면 가끔 그것을 버리기도 한다. 링크 |danger|가
자료에 끼어드는 곳이 여기다.

이 서브루틴도 |u|가 목록에 이미 있는 어떤 |u| 밭보다도 클 때만 불린다.

잉여가 |r| 이상인 항목은 다시 넣지 않을 것이므로 색인을 고칠 필요는 없다.

크누스는 이 함수를 |delete|라 불렀다. \GO/에서는 그것이 내장 함수의 이름이라,
진단 알림말(``forgetting'')에서 따 |forget|으로 바꾸었다. 눈여겨볼 것이 하나 있다.
잘라 낸 사슬의 노드를 알리는 고리는 다음 링크가 |danger|보다 큰 동안만 돌기
때문에, 사슬의 마지막 노드는 알리지 않는다. 원본이 그러므로 그대로 두었다.

@<함수들@>=
func forget(head int, u uint64, r int) {
	var j, x, y, count int
	@<|r| 앞에서 멈출 노드 |x|와 그 뒤의 |y|를 찾는다@>@;
	mems++; nmem[x].next = danger // 뒤따르는 것을 모두 잘라 낸다
	if y > danger {
		for x = y; ; count++ {
			mems++
			if nmem[y].next <= danger {
				break
			}
			if vbose&showOutlierDetails != 0 { // 진단이라 mem을 치지 않는다
				fmt.Fprintf(os.Stderr, " (%s %d 잊음, %s=%d)\n",
					nearName(int(nmem[y].r)), nmem[y].u, keyName(head), nmem[y].r)
			}
			y = int(nmem[y].next)
		}
		mems++; nmem[y].next = int32(avail); avail = x
	}
	recordStat(&insStats[head], count, u)
}

@ 색인과 링크의 짜임새가 좀 까다로우니, 망가지지 않았는지 살피는 서브루틴을 두는
게 좋겠다. 링크 밭에 잠시 |flag| 비트를 얹어 지나간 노드를 표시하고, 색인이
가리키는 노드가 모두 표시되었는지 본다.

크누스는 이 서브루틴을 어디서도 부르지 않는다. 의심이 들 때 부르라고 둔 것이다.
나는 원본 C와 이 \GO/ 판 양쪽에 울람 수를 256개 찾을 때마다 부르는 줄을 넣어
$N=300000$까지 돌려 보았는데, 둘 다 한 번도 불평하지 않았다.

@<상수@>=
const flag = 0x80000000 // |next| 밭에 잠시 얹는 표시

@ @<함수들@>=
func sanity() {
	var h, j, nextj, x, y, r, lastr int
	var u, lastu uint64
	for h = loOut; h <= hiOut; h++ {
		lastr, lastu, j = 0, 0, 1
		for x = h; ; x = y {
			r, u, y = int(nmem[x].r), nmem[x].u, int(nmem[x].next)
			if r < lastr || (r == lastr && u < lastu) {
				fmt.Fprintf(os.Stderr, "이런, 순서가 어긋났다! (h=%d, r=%d, j=%d, x=%d)\n", h, r, j, x)
				return
			}
			nextj = int(uint64(r) * uint64(isize) / uint64(lamp))
			for ; j <= nextj; j++ {
				if uint32(nmem[inx[h][j]].next)&flag == 0 {
					fmt.Fprintf(os.Stderr, "이런, 색인이 잘못됐다! (h=%d, r=%d, j=%d, x=%d)\n", h, r, j, x)
					return
				}
			}
			nmem[x].next = int32(uint32(y) + flag)
			if y <= danger {
				break
			}
			lastr, lastu = r, u
		}
		for x = h; ; x = y {
			y = int(int32(uint32(nmem[x].next) - flag))
			nmem[x].next = int32(y)
			if y <= danger {
				break
			}
		}
	}
}

@ 몫 $\lfloor(p-1)/q\rfloor=2$라는 가정 덕에, $U_1=1$은 낮은 준바깥값이고
$U_2=2$는 높은 바깥값이다.

세세한 점 하나. 두 수 1과 2는 서로 다른 울람 수의 합으로 나타낼 수 없으므로 울람
수이면서 울람 헛수이기도 하다.

@<자료 구조를 초기화한다@>=
mems += 2; window[1] = 1; window[2] = 2
n, nw, misses = 2, 2, 2
if !ins(loOut, 1, lamq) || !ins(hiOut, 2, bar(2*lamq)) {
	goto finishUp
}
if spacing == 1 {
	fmt.Fprintf(out, "U1=1\n")
}
if spacing == 1 || spacing == 2 {
	fmt.Fprintf(out, "U2=2\n")
}

@* 무차별 탐색.
이제 본론을 칠 채비가 되었다. 지금 수 |u|가 울람 수인지, 울람 헛수인지, 둘 다
아닌지 가려야 한다. 앞에서 말했듯 Gibbs의 전략은 |u|의 잉여 |r|에 따라 두 가지로
하는 것이다. 절반쯤은, 곧 |r<=lamp/4|이거나 |lamp-r<=lamp/4|일 때는, 창에 담아
둔 결과로 무차별 탐색을 하면 된다.

크누스의 코드에는 판가름 뒤로 |ulam_miss|, |not_ulam|, |ulam_yes|, |finish| 네
표지가 늘어서 있다. 첫째 것은 흘러 들어오기만 하고 |goto|로 가는 일이 없다. \GO/는
쓰지 않는 표지를 허락하지 않으므로 그것만 뺐다.

크누스의 원본에는 바로 이 자리에 버그가 하나 숨어 있다. 원문은 무차별 탐색 절을
중괄호로 감싸 두고, 그 뒤에 |else|와 바깥값 시험 절의 이름을 이어 적었다. 그런데
\.{CTANGLE}은 이름 있는 절을 펼칠 때 중괄호를 두르지 않는다. 그래서 |else|가
거느리는 것은 바깥값 시험의 첫 문장, 곧 |rbound|와 |ubound|를 정하는 한 줄뿐이다.
두 닻 고리와 그 뒤의 판가름은 무차별 탐색이 풀이를 하나도 못 찾고 흘러내려 온
수에서도 돌고, 그때 쓰는 |rbound|와 |ubound|는 앞서 바깥값 시험을 한 수가 남긴
묵은 값이다.

기본값 $\lambda=120500181/49315733$에서는 무차별 탐색이 풀이를 하나도 못 찾는 수가
$u=25$ 하나뿐이라서 결과에 드러나지 않는다. 닻 고리 통계가 한 번씩 더 적히고 mem을
12개 더 셀 뿐이다. 그러나 근삿값이 거칠면 이야기가 다르다. 원본 C를 \.{p22}
\.{q9}로 돌리면 $U_{700}$부터 틀린다. 참값이 $8255$인데 $8275$를 내놓고,
$U_{2000}$은 $25511$ 대신 $25166$이 된다. 근삿값 \.{p17} \.{q7}에서는 $U_{500}$이
$5685$ 대신 $5544$이고, \.{p300} \.{q100}에서는 $U_{100}$이 $690$ 대신 $624$다.
묵은 한계로 돈 닻 고리가 가짜 풀이를 딱 하나 찾아내, 헛수여야 할 수를 울람 수로
선언하는 것이다.

\GO/에는 이런 함정이 없다. 문법이 |if|와 |else|의 몸통을 언제나 중괄호로 감싸게
하기 때문이다. 이 판은 문서가 말하는 대로 돌고, 위의 수들은 모두 곧이곧대로 셈한
참값과 맞는다.

@<|u|가 울람 수인지 울람 헛수인지 둘 다 아닌지 가리고 자료 구조를 고친다@>=
@<|u|의 잉여 |r|을 셈한다@>@;
hits = false // $u=u'+u''$의 풀이를 찾았는가
if r <= lamp>>2 || bar(r) <= lamp>>2 {
	@<무차별 탐색으로 판가름한다@>@;
} else {
	@<바깥값 시험으로 판가름한다@>@;
}
misses++
missBin[n/alpha][r/beta]++
notUlam:
ulamness = 0
goto finish
ulamYes:
yesBin[n/alpha][r/beta]++
@<|u|를 다음 울람 수로 적어 둔다@>@;
ulamness = 1
finish:
@<|ulamness|를 |isUlam|이나 |isUm| 표에 적는다@>@;

@ 곱 |lamq*u|는 |u|가 넉넉히 크면 64비트를 넘으므로, 잉여는 두 단계로 셈한다.

@<|u|의 잉여 |r|을 셈한다@>=
r = int(u % uint64(lamp))
r = int(uint64(lamq) * uint64(r) % uint64(lamp))

@ 무차별 탐색은 간단한 생각을 쓴다. 두 수가 $u'>u''$이면서 $u=u'+u''$를 채우려면
$u'>u/2$여야 한다. 그러니 이미 셈한 수 $u'=U_n$, $U_{n-1}$, \dots을 차례로 보면서,
$u-u'$이 울람 수인 경우를 둘 찾거나, $u'$이 너무 작아지거나, 창 안의 수를 다 쓸
때까지 간다.

@<무차별 탐색으로 판가름한다@>=
x = nw
mems++; up = window[x]
for count = 1; up > u>>1; {
	if ulamq(u - up) { // $u=u'+u''$의 새 풀이를 찾았다
		if hits { // |u|를 나타내는 길이 하나가 아니다
			recordStat(&windowStats, count, u)
			goto notUlam
		}
		hits = true
	}
	if count++; count > windowSize {
		fmt.Fprintf(os.Stderr, "어이쿠, 창이 넘친다(크기=%d)!\n", windowSize)
		goto finishUp
	}
	if x != 0 {
		x--
	} else {
		x = windowSize - 1
	}
	mems++; up = window[x]
}
recordStat(&windowStats, count, u)
if vbose&showBruteWinners != 0 {
	fmt.Fprintf(os.Stderr, " (무차별 탐색 단계에서 %d → %s)\n", u, ulamName(hits))
}
if hits {
	goto ulamYes
}

@ @<함수들@>=
func ulamName(hit bool) string {
	if hit {
		return "울람 수"
	}
	return "울람 헛수"
}

@ 울람 수와 울람 헛수의 히스토그램은 $16\times128$ 크기의 배열 |yesBin|과 |missBin|에
모은다. (첫째 첨자는 \MP\ 그림의 색을 정하고, 둘째 첨자는 |r|의 범위에서 몇 번째
칸인지를 정한다.)

@<상수@>=
const (
	bincolors = 16  // 그림에 쓰는 색의 수
	binsize   = 128 // 잉여의 범위를 나눈 칸의 수
)

@ @<전역 변수@>=
var (
	windowStats     stat                         // 창 고리를 돈 횟수
	yesBin, missBin [bincolors][binsize]uint64 // 히스토그램
	alpha           uint64                       // 첫째 첨자의 축척
	beta            int                          // 둘째 첨자의 축척
)

@ @<자료 구조를 초기화한다@>=
alpha, beta = (maxn-1)/bincolors+1, (lamp-1)/binsize+1
yesBin[0/alpha][lamq/beta], missBin[0/alpha][lamq/beta] = 1, 1
yesBin[1/alpha][(2*lamq)/beta], missBin[1/alpha][(2*lamq)/beta] = 1, 1

@* 새 울람 수 받아들이기.
새 울람 수 $U_{n+1}=u$를 알아내면 여러 가지로 축하한다.

먼저 |n|을 늘리고 |u|를 창에 넣는다.

@<|u|를 다음 울람 수로 적어 둔다@>=
n++; nw++
if nw == windowSize {
	nw = 0
}
@<|u|를 |window|에 넣는다@>@;

@ 다음으로 |u|가 바깥값인지, 거의 그런지 가려야 한다.

@<|u|를 다음 울람 수로 적어 둔다@>=
if r <= lamp/3 {
	@<|u|를 낮은 바깥값으로 적는다@>@;
} else if r <= lamp/2 {
	@<|u|가 낮은 준바깥값이면 적는다@>@;
} else if bar(r) <= lamp/3 {
	@<|u|를 높은 바깥값으로 적는다@>@;
} else {
	@<|u|가 높은 준바깥값이면 적는다@>@;
}

@ @<|u|를 낮은 바깥값으로 적는다@>=
if r <= lowestOutlier {
	lowestOutlier = r
	if vbose&showRecordOutliers != 0 {
		fmt.Fprintf(os.Stderr, " (가장 낮은 바깥값 r=%d, u=%d)\n", r, u)
	}
}
if !ins(loOut, u, r) {
	goto finishUp
}

@ @<|u|를 높은 바깥값으로 적는다@>=
if r >= highestOutlier {
	highestOutlier = r
	if vbose&showRecordOutliers != 0 {
		fmt.Fprintf(os.Stderr, " (가장 높은 바깥값 r=%d, u=%d)\n", r, u)
	}
}
if !ins(hiOut, u, bar(r)) {
	goto finishUp
}

@ Gibbs의 발견적 ``안쪽 점수''는 $\rho\le{1\over2}$일 때 $(\rho-{1\over3})\sqrt{u}$인데,
|u|를 낮은 준바깥값으로 기억하려면 이것이 $T$ 이하여야 한다. 여기까지 왔으면
$r\ge(p+1)/3$임을 안다. 따라서 $T/(\rho-1/3)=3Tp/(3r-p)\le 3Tp$다.

수 |u|를 저장하지 {\it 않을\/} 때는 실수가 없었음을 보장해야 한다. 그래서 앞으로
준바깥값 ``닻''을 찾는 어떤 탐색이든, 잉여가 |r|보다 크거나 |r|과 같으면서 딸린
값이 |u|보다 큰 수를 만날 수 있었다면 오류로 친다. (그런 경우라면 알고리즘이 지금
버리는 수를 정말로 만났어야 하기 때문이다.)

이 대목은 찬찬히 생각해 보라. 프로그램에서 가장 미묘한 곳이라고 크누스는 적었다.
@^미묘한 곳@>

탐색 목록을 잘라 내고, 거기서 |danger|를 만나면 알아차리는 식으로 그런 오류를
막는다. 앞서 잘라 낸 자리는 |loRBound|에 기억해 둔다.

@<|u|가 낮은 준바깥값이면 적는다@>=
g = lampthresh / float64(3*r-lamp)
if float64(u) >= g*g { // 가깝지 {\it 않으니\/} 버린다
	if vbose&showOmittedInliers != 0 {
		fmt.Fprintf(os.Stderr, " (빠뜨림 r=%d, u=%d, g=%.6g)\n", r, u, g*g/float64(u))
	}
	if r < loRBound {
		loRBound = r
		if vbose&showRecordCutoffs != 0 {
			fmt.Fprintf(os.Stderr, " (가장 낮게 잘라 냄 r=%d, u=%d, g=%.6g)\n",
				r, u, g*g/float64(u))
		}
		forget(loOut, u, r)
	}
} else if r < loRBound && !ins(loOut, u, r) {
	goto finishUp
}

@ @<|u|가 높은 준바깥값이면 적는다@>=
g = lampthresh / float64(3*bar(r)-lamp)
if float64(u) >= g*g { // 가깝지 {\it 않으니\/} 버린다
	if vbose&showOmittedInliers != 0 {
		fmt.Fprintf(os.Stderr, " (빠뜨림 rbar=%d, u=%d, g=%.6g)\n",
			bar(r), u, g*g/float64(u))
	}
	if bar(r) < hiRBound {
		hiRBound = bar(r)
		if vbose&showRecordCutoffs != 0 {
			fmt.Fprintf(os.Stderr, " (가장 높게 잘라 냄 rbar=%d, u=%d, g=%.6g)\n",
				bar(r), u, g*g/float64(u))
		}
		forget(hiOut, u, bar(r))
	}
} else if bar(r) < hiRBound && !ins(hiOut, u, bar(r)) {
	goto finishUp
}

@ 다음으로 |u|와 앞 울람 수 |prevu| 사이의 간격을 본다.

@<|u|를 다음 울람 수로 적어 둔다@>=
j = int(u - prevu)
if j > maxgap {
	gapcount[maxgap+1]++
} else {
	gapcount[j]++
}
if j >= biggestgap {
	biggestgap = j
	if vbose&showRecordGaps != 0 {
		fmt.Fprintf(os.Stderr, " (간격 %d = U%d-U%d, U%d=%d)\n", j, n, n-1, n-1, prevu)
	}
}
prevu = u

@ 끝으로 |n|이 |spacing|의 배수이면 |u| 자체를 알린다. 요청하면 다른 통계도
|stderr|에 찍는다.

크누스는 C의 |clock|으로 프로세스가 쓴 CPU 시간을 쟀다. 여기서는 벽시계로 잰다.
\GO/ 런타임은 쓰레기 수거 같은 일을 다른 스레드에서도 하므로, 걸린 시간을 보는
데는 벽시계가 더 곧다.

@<|u|를 다음 울람 수로 적어 둔다@>=
if spacing != 0 && n%spacing == 0 {
	now := time.Now()
	fmt.Fprintf(out, "U%d=%d\n", n, u)
	if vbose&showUsageStats != 0 {
		fmt.Fprintf(os.Stderr, " (헛수 %d개, mem %d개, %.2f초)\n",
			misses-prevmisses, mems-prevmems, now.Sub(prevclock).Seconds())
	}
	prevmisses, prevmems, prevclock = misses, mems, now
}

@ 지금까지 써 온 변수들을 선언해 두는 게 좋겠다.

@<전역 변수@>=
var (
	lampthresh                    float64   // |lamp*thresh|
	lowestOutlier, highestOutlier int       // 가장 멀리 나간 바깥값
	prevu                         uint64    // 가장 최근에 찾은 울람 수
	gapcount                      []uint64  // 간격마다 몇 번 나왔는지
	rbound, rbarbound             int       // 잉여에 대한 탐색 한계
	ubound                        uint64    // 잉여가 한계와 같을 때 값에 대한 탐색 한계
	anchorx                       int       // $u=u'+u''$인 하나뿐인 $u'$의 노드
	loRBound, hiRBound            int       // 자료를 잘라 낸 잉여
	prevmisses                    uint64    // 가장 최근에 알린 헛수의 수
	prevmems                      uint64    // 가장 최근에 알린 mem 수
	prevclock                     = started // 가장 최근에 알린 시각
	loOutStats, hiOutStats        stat      // 두 닻 고리의 통계
	ulamness                      int       // |u|가 울람 수인가
)

@ 크누스는 |gapcount|를 |malloc|으로 잡고 |gapcount[1]| 말고는 초기화하지 않았다.
그러니 원칙대로라면 |gapcount[j]++|가 쓰레기 값에 더해질 수 있다. 크누스의 기계에서도
내 기계에서도 새로 받은 메모리가 0으로 채워져 나와 탈이 드러나지 않았을 뿐이다.
\GO/의 |make|는 언제나 0으로 채우니 걱정할 것이 없다.

@<배열을 마련한다@>=
gapcount = make([]uint64, maxgap+2)
bytes += uint64(maxgap+2) * uint64(unsafe.Sizeof(gapcount[0]))

@ 그리고 초기화도 해 두자.

@<자료 구조를 초기화한다@>=
lampthresh = float64(lamp) * thresh
lowestOutlier, loRBound, hiRBound = lamp, lamp, lamp
highestOutlier = 2 * lamq
gapcount[1] = 1
prevu = 2

@* 잉여로 판가름하기.
좋다, 이제 계산의 주 고리를 다룰 차례다. 주 {\it 고리들\/}이라고 해야 옳겠다. 이
과정에서 탐색 목록 둘을 쓰기 때문이다.

풀이 $u=u'+u''$가 하나뿐임을 찾으면, |anchorx|가 $u'$에 해당하는 노드다.

@<바깥값 시험으로 판가름한다@>=
@<|loOut|에 닻을 내려 판가름해 본다@>@;
@<|hiOut|에 닻을 내려 판가름해 본다@>@;
if hits {
	if int(nmem[anchorx].r) > lamp/3 && vbose&showInlierAnchors != 0 {
		fmt.Fprintf(os.Stderr, " (안값 닻 U%d=%d+%d)\n",
			n, nmem[anchorx].u, u-nmem[anchorx].u)
	}
	goto ulamYes
}

@ 두 등식 $u=u'+u''$와 $r=r'+r''$가 성립하면 $r'\le r''$라고, 따라서 $r'\le r/2$라고
가정할 수 있다. 게다가 $r'=r''$이면 $u'<u''$라고, 따라서 $u'<u/2$라고 가정할 수
있다. 이런 사실이 탐색을 좁혀 주고, 같은 풀이를 두 번 찾지 않게 해 준다.

크누스의 코드는 이 고리에서 |up|을 한 번 더 읽고 mem도 하나 더 센다. 바로 앞에서
이미 읽었으니 결과에는 아무 상관이 없고, 짝이 되는 |hiOut| 쪽 고리에는 그 줄이 없다.
mem 수를 원본과 똑같이 맞추려고 그대로 두었다.

@<|loOut|에 닻을 내려 판가름해 본다@>=
rbound, ubound = r>>1, (u-1)>>1
mems++; x = int(nmem[loOut].next)
for count = 1; ; count++ {
	if x <= danger {
		break
	}
	mems += 2; rp = int(nmem[x].r); up = nmem[x].u
	if rp >= rbound && (rp > rbound || (rp+rp == r && up > ubound)) {
		break
	}
	mems++; up = nmem[x].u
	if ulamq(u - up) { // $u=u'+u''$의 새 풀이를 찾았다
		if hits {
			recordStat(&loOutStats, count, u)
			goto notUlam
		}
		hits, anchorx = true, x
	}
	mems++; x = int(nmem[x].next)
}
recordStat(&loOutStats, count, u)
if x == danger {
	fmt.Fprintf(os.Stderr, "미안하지만 T 문턱이 너무 낮다!\n")
	fmt.Fprintf(os.Stderr, " (r=%d,u=%d,loRBound=%d)\n", r, u, loRBound)
	goto finishUp
}

@ 등식 $u=u'+u''$와 $\bar r=\bar r'+\bar r''$를 풀 때도 비슷한 관찰이 통한다.

@<|hiOut|에 닻을 내려 판가름해 본다@>=
rbarbound = bar(r) >> 1
mems++; x = int(nmem[hiOut].next)
for count = 1; ; count++ {
	if x <= danger {
		break
	}
	mems += 2; rp = int(nmem[x].r); up = nmem[x].u
	if rp >= rbarbound && (rp > rbarbound || (rp+rp == bar(r) && up > ubound)) {
		break
	}
	if ulamq(u - up) { // $u=u'+u''$의 새 풀이를 찾았다
		if hits {
			recordStat(&hiOutStats, count, u)
			goto notUlam
		}
		hits, anchorx = true, x
	}
	mems++; x = int(nmem[x].next)
}
recordStat(&hiOutStats, count, u)
if x == danger {
	fmt.Fprintf(os.Stderr, "미안하지만 T 문턱이 너무 낮다!\n")
	fmt.Fprintf(os.Stderr, " (rbar=%d,u=%d,hiRBound=%d)\n", bar(r), u, hiRBound)
	goto finishUp
}

@* 마무리.
다 끝나면 알아낸 것 가운데 요청받은 부분을 내놓는다. 표준 출력은 버퍼에 모아
두었으니 맨 끝에 흘려보낸다.

@<작별 인사를 찍는다@>=
if n == maxn && !(spacing != 0 && n%spacing == 0) {
	fmt.Fprintf(out, "U%d=%d\n", n, u-1) // 마지막 답을 아직 찍지 않았으면 찍는다
}
if n < maxn {
	fmt.Fprintf(os.Stderr, "울람 수 %d개와 ", n)
}
fmt.Fprintf(os.Stderr, "%d 미만인 울람 헛수 %d개를 찾았다.\n", u, misses)
if vbose&showGapStats != 0 {
	@<간격 통계를 찍는다@>@;
}
if vbose&showHistograms != 0 {
	@<히스토그램을 찍는다@>@;
}
if vbose&showCompressionStats != 0 {
	@<압축 통계를 찍는다@>@;
}
if vbose&showUsageStats != 0 {
	@<시간과 공간 통계를 찍는다@>@;
}
out.Flush()

@ @<간격 통계를 찍는다@>=
fmt.Fprintf(os.Stderr, "****** U%d까지의 간격 통계 ******\n", n)
for j = 1; j <= maxgap; j++ {
	if gapcount[j] != 0 {
		fmt.Fprintf(os.Stderr, "%5d:%14d\n", j, gapcount[j])
	}
}
if gapcount[maxgap+1] != 0 {
	fmt.Fprintf(os.Stderr, ">%4d:%14d\n", maxgap, gapcount[maxgap+1])
}

@ 크누스는 울람 수의 히스토그램과 헛수의 히스토그램을 똑같은 코드 두 벌로 찍었다.
여기서는 두 표를 고리 하나로 돈다.

@<히스토그램을 찍는다@>=
fmt.Fprintf(os.Stderr, "****** U%d까지의 히스토그램 ******\n", n)
for f, bins := range [2]*[bincolors][binsize]uint64{&yesBin, &missBin} {
	fmt.Fprintf(os.Stderr, " %s:\n", ulamName(f == 0))
	for j = 0; j < binsize; j++ {
		var tot uint64
		for i = 0; i < bincolors; i++ {
			tot += bins[i][j]
		}
		if tot != 0 {
			fmt.Fprintf(os.Stderr, "%4d/%d:%14d\n", j, binsize, tot)
		}
	}
}

@ @<압축 통계를 찍는다@>=
fmt.Fprintf(os.Stderr, "****** 압축 요약: ******\n")
j = 1
if codeUse[0] != 0 {
	j = 0
}
for ; j < codePtr; j++ {
	fmt.Fprintf(os.Stderr, " %02x ", j)
	for k = bitsPerCompressedByte - 1; k >= 0; k-- {
		fmt.Fprintf(os.Stderr, "%d", code[j]>>k&1)
	}
	fmt.Fprintf(os.Stderr, "%14d%14d\n", codeUse[j], codeExample[j])
}

@ 크누스의 매크로 |dump_stats|는 함수가 되었다.

@<함수들@>=
func dumpStats(s stat) {
	fmt.Fprintf(os.Stderr, "n %d, 평균 %.6g, 최대 %d (%d)\n",
		s.n, float64(s.mean), s.max, s.ex)
}

@ @<시간과 공간 통계를 찍는다@>=
fmt.Fprintf(os.Stderr, "\n무차별 탐색 고리 통계: ")
dumpStats(windowStats)
fmt.Fprintf(os.Stderr, "낮은 바깥값 넣기 통계: ")
dumpStats(insStats[loOut])
fmt.Fprintf(os.Stderr, "낮은 바깥값 고리 통계: ")
dumpStats(loOutStats)
fmt.Fprintf(os.Stderr, "높은 바깥값 넣기 통계: ")
dumpStats(insStats[hiOut])
fmt.Fprintf(os.Stderr, "높은 바깥값 고리 통계: ")
dumpStats(hiOutStats)
fmt.Fprintf(os.Stderr, "바깥값 목록이 칸 %d개를 썼다.\n", nodePtr-2)
fmt.Fprintf(os.Stderr, "모두 %d바이트, mem %d개, %.2f초.\n",
	bytes, mems, time.Since(started).Seconds())

@* \MP\ 출력.
예쁜 그림, 곧 나갑니다.

울람 수의 그림과 헛수의 그림도 크누스는 두 벌로 적었는데, 여기서는 고리 하나로
돈다. 곱에 $0.5$를 더하는 자리에서 \GO/ 컴파일러는 곱셈과 덧셈을 융합 연산 하나로
묶을 수 있고, 그러면 반올림이 달라질 수 있다. 곱을 |float64|로 한 번 더 감싸면 그
묶기가 막힌다.

@<\MP\ 파일을 내놓는다@>=
fmt.Fprintf(mpFile, "%% ulam-gibbs가 N=%d로 만들었다\n", maxn)
@<틀에 박힌 머리말을 내놓는다@>@;
factor = float64(binsize*binsize) / (9 * float64(maxn))
for f, bins := range [2]*[bincolors][binsize]uint64{&yesBin, &missBin} {
	fmt.Fprintf(mpFile, "\nbeginfig(%d) init; %% %s의 분포\n", 1-f, ulamName(f == 0))
	for j = 0; j < binsize; j++ {
		acc[j], prev[j] = 0, 0
	}
	for i = bincolors - 1; i >= 0; i-- {
		@<색 |i|의 막대들을 내놓는다@>@;
	}
	fmt.Fprintf(mpFile, "endfig;\n")
}
fmt.Fprintf(mpFile, "\nbye.\n")
mpFile.Close()
fmt.Fprintf(os.Stderr, "METAPOST 코드를 파일 %s에 썼다.\n", mpName)

@ 막대의 높이는 색마다 쌓아 올린다. 반올림한 누적 높이의 차이를 내놓으므로,
반올림 오차가 쌓이지 않는다.

@<색 |i|의 막대들을 내놓는다@>=
fmt.Fprintf(mpFile, "doit(%d)\n  ", i)
for j = 0; j < binsize; j++ {
	acc[j] += bins[i][j]
	t = int(float64(factor*float64(acc[j])) + 0.5)
	sep := ","
	if j+1 == binsize {
		sep = ";\n"
	} else if j&0xf == 0xf {
		sep = ",\n  "
	}
	fmt.Fprintf(mpFile, "%d%s", t-prev[j], sep)
	prev[j] = t
}

@ @<전역 변수@>=
var (
	acc    [binsize]uint64 // 누적한 히스토그램 자료
	prev   [binsize]int    // 앞서 내놓은, 반올림한 히스토그램 자료
	factor float64         // \MP\ 출력에서 히스토그램 자료의 축척
)

@ @<틀에 박힌 머리말을 내놓는다@>=
fmt.Fprintf(mpFile, "newinternal n; numeric a[];\n\n")
fmt.Fprintf(mpFile, "def init =\n  draw (1,0)--(%d,0);\n", binsize)
fmt.Fprintf(mpFile, "  for j=1 upto %d: a[j]:=0; endfor\n", binsize)
fmt.Fprintf(mpFile, "  pickup pencircle;\nenddef;\n\n")
fmt.Fprintf(mpFile, "def doit(text j) text l =\n")
fmt.Fprintf(mpFile, "  drawoptions(withcolor j/%d[green,red]);\n", bincolors)
fmt.Fprintf(mpFile, "  n:=1;\n")
fmt.Fprintf(mpFile, "  for t=l:\n")
fmt.Fprintf(mpFile, "   if t>0: draw (n,a[n])--(n,a[n]+t); a[n]:=a[n]+t; fi\n")
fmt.Fprintf(mpFile, "   n:=n+1;\n")
fmt.Fprintf(mpFile, "  endfor\nenddef;\n")

@* 맞춰 보기.
원본 C를 \.{CTANGLE}로 지어 두고, 옵션을 47가지로 바꿔 가며 이 \GO/ 판과 나란히
돌렸다. 한글로 옮긴 알림말을 영어로 되돌리고 초 단위 시간만 지운 뒤 견주었다.
옵션이 없거나 틀린 경우, $N$이 1, 2, 3인 가장자리, \.{v-1}로 모든 수다를 켠 것,
여섯 가지 근삿값(\.{p84623687} \.{q34632970}, 540/221, 22/9, 17/7, 5/2, 300/100),
문턱이 너무 낮거나(\.{T0}, \.{T5}) 바깥값 자리나 창이 넘치는 경우, \.b와 \.B와
\.i와 \.g와 \.w를 여러 값으로 바꾼 것, 그리고 \.M으로 그림 파일을 쓰는 것까지다.

비교 상대는 원본에 앞에서 말한 중괄호 한 쌍만 더한 C다. 표준 출력, 표준 오류,
mem 수, \MP\ 그림 파일이 47가지 모두에서 한 글자도 다르지 않았다. (두 프로그램에
그림 파일 이름을 다르게 주었으므로, 그 이름을 알리는 줄은 셈에서 뺐다.) 중괄호가
없는 원본 그대로와 견주면, 기본 근삿값에서는 닻 고리 통계가 한 번씩 적고 mem이
12개 적은 것 말고는 같다. 그 차이는 $N=10^8$까지 돌려도 그대로였다. 곧 무차별
탐색이 풀이를 못 찾고 흘러내려 오는 수는 1억 번째 울람 수
$U_{100000000}=1351856726$에 이르기까지 $u=25$ 하나뿐이다. 거친 근삿값에서 원본이
틀린 답을 내는 경우는 무차별 탐색장의 첫머리에 적었고, 그 답들이 틀렸다는 것은
울람 수의 정의대로 곧이곧대로 센 값과 견주어 확인했다.

옵션 \.{b19}가 $N>2198412$에서 너무 크다는 크누스의 말도 확인했다. \.{B18012}와
함께 주면 $N=2198412$에서는 끝까지 가고, $N=2198413$에서는 부호가 256개로 모자란다.

시간은 이렇다. $N=10^8$에서 원본 C는 39.3초, 이 판은 55.9초 걸렸다. 쓴 메모리는
둘 다 86메가바이트 남짓이다. 그림은 이 판이 \.M 옵션으로 $N=10^6$에서 뽑은 것을
그대로 옮겼는데, 원본 C가 뽑는 것과 주석을 빼면 바이트 단위로 같다.

@ 원문에서 찾은 흠 가운데 버그는 무차별 탐색장에, \.m의 기본값 이야기는 들어가며에
적었다. 나머지는 사소하다.
\smallskip
\item{$\bullet$} 잉여 이야기에서 $U_3=3$의 잉여를 $\rho_2$로 적은 첨자를 $\rho_3$로
고쳤다.
\item{$\bullet$} 근삿값 540/221의 잉여 목록에서 두 번째 $248$ 앞에 빠진 쉼표를
넣었다.
\item{$\bullet$} 가장 높은 바깥값을 알리는 줄에 빠진 닫는 괄호를 달았다.
\item{$\bullet$} \MP\ 파일의 머리 주석이 프로그램 이름을 `gibbs-ulam'이라 적던 것을
바로잡았다.
\item{$\bullet$} 배열 |gapcount|를 초기화하지 않던 일, 낮은 닻 고리에서 |up|을 한 번
더 읽던 일, |forget|이 사슬의 마지막 노드를 알리지 않던 일은 그 절들에 적었다.

@ 옮기며 달라진 곳은 이렇다. 버그를 고친 것 말고는 모두 언어에서 왔다.
\smallskip
\item{$\bullet$} 매크로 |o|, |oo|, |ooo|는 |mems++| 따위의 문장이 되었고, 매크로
|bar|, |dump_stats|는 함수가 되었다. 매크로 |insert|는 |ins|가 넘침을 스스로 알리는
꼴로, 할당 실패를 알리던 |alloc_quit|은 \GO/의 |make|에 맡기는 꼴로 바뀌었다.
\item{$\bullet$} 함수 |ins|와 |delete|가 똑같이 적던 목록 따라가기는 이름 있는 절
하나로 나눠 쓴다. 함수 이름 |delete|는 \GO/ 내장 함수와 겹쳐 |forget|이 되었다.
\item{$\bullet$} 밑줄로 잇던 C식 이름은 \GO/식으로 바꾸었다(|is_ulam|이 |isUlam|).
함수 |ulamq|의 반환값과 변수 |hits|는 참거짓 값이다.
\item{$\bullet$} 쓰이지 않던 변수 셋, 곧 |main|의 |y|와 전역 |last_mems|,
|last_clock|을 뺐다. 넣기 통계 |ins_stats|는 목록 수에 맞게 넷에서 둘로 줄였다.
\item{$\bullet$} 시간은 CPU 시간 대신 벽시계로 잰다. 표준 출력은 버퍼에 모았다가
끝에 흘려보낸다.
\item{$\bullet$} 명령줄의 수는 |fmt.Sscan|이 읽으므로 음수를 부호 없는 자리에 받지
않는다. 원본이 죽거나 엉뚱한 메모리를 잡으려던 인자는 쓰는 법 오류로 거르고,
끝내기 부호는 $-1$ 대신 $1$이다.
\item{$\bullet$} 히스토그램과 \MP\ 출력에서 두 벌로 적던 코드는 고리 하나로 묶었다.

@* 색인.
