\input kotexgweb
\input luamplib.sty
@i types.w
\datethis

\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

\def\title{소수 체}

@* 들어가며.
이 프로그램은 ``에라토스테네스의 체''를 한 토막씩 만들어, 찾아낸 가장 큰 소수 간격을
내놓는다. 좀 더 정확히 말하면, $s_i$와 $s_{i+1}=s_i+\delta$ 사이의 소수 집합을 비트
배열로 나타내고, 그런 배열을 $i=0$, 1, \dots,~$t-1$에 대해 연속한 구간 $t$개만큼
살핀다. 그러니 $s_0$과 $s_t$ 사이의 소수를 모두 훑는다.

수열의 $k$번째 소수를 $p_k$라 하자. 에라토스테네스의 체는 집합 $\{2,3,\ldots,N\}$에서
시작해 소수가 아닌 것을 지워 나가 $N$ 이하의 소수를 모두 찾는다. 곧 $p_1$부터
$p_{k-1}$까지를 알고 나면 남은 다음 원소가 $p_k$이고, 수 $p_k^2$, $p_k(p_k+1)$,
$p_k(p_k+2)$, \dots를 지운다. 그러다 $p_k^2>N$인 첫 소수를 찾으면 체는 끝난다.

이 프로그램에서는 소수 대신 소수가 아닌 것을 다루는 편이 편하고, $p_k^2\le s_t$인
``작은'' 소수 $p_k$는 모두 이미 안다고 가정한다. 물론 홀수만 다루어도 된다. 그래서
$s_i$와 $s_{i+1}$ 사이의 정수를 비트 $\delta/2$개로 나타낸다. 이 비트들은 $64$비트
수 $\delta/128$개 |sieve[j]|에 담기고,
$$|sieve[j]|=\sum_{n=s_i+128j}^{s_i+128(j+1)} 2^{(n-s_i-128j-1)/2}
\,\hbox{$\bigl[n$은 $\sqrt{\mathstrut s_{i+1}}$ 이하인 어떤 홀수 소수의 홀수 배$\bigr]$}$$
이다.

@ 구간 크기 $\delta$는 $128$의 배수로 고른다. 또 $s_0$은 짝수이고
$s_0\ge\sqrt\delta$라고 가정한다. 그러면 모든 $s_i$가 짝수이고
$$(s_i+1)^2=s_i^2+s_i+s_{i+1}-\delta+1\ge s_i+s_{i+1}+1>s_{i+1}$$
이다. 따라서
$$|sieve[j]|=\sum_{n=s_i+128j}^{s_i+128(j+1)} 2^{(n-s_i-128j-1)/2}
\,\hbox{$\bigl[n$은 홀수이고 소수가 아니다$\bigr]$}$$
이다. 수 $n$이 들어가는 것은 $p\le\sqrt{\mathstrut s_{i+1}}<s_i+1\le n$인 어떤 소수
$p$로 나누어떨어질 때이고 그때뿐이기 때문이다.

원본의 식에는 가운데의 `$+1$'이 빠져 있다. 제곱 $(s_i+1)^2$은 $s_i^2+2s_i+1$이니 있어야 한다.
빠져도 부등식은 그대로 선다.

@ 이것은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{prime-sieve.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/prime-sieve.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Wed, 24 May 2017 14:29:37 GMT}다. 프로그램이 찍는 말과 종료 부호는 원본 그대로
두었다. 그래야 두 프로그램의 출력을 바이트 단위로 견줄 수 있다.

옮기다 보니 원본의 명령줄 검사에서 결함 둘이 나왔다. 하나는 $2^{32}$의 배수인 출발점을
잘못 거절하는 것이고, 다른 하나는 음수 $t$를 받으면 배열 밖을 읽고 $0$으로 나누는 것이다. 둘 다
고쳤고, 그 자리에서 이야기한다. 크누스가 스스로 미심쩍어한 간격 찾기 논리는 옳았다.
맨 끝의 ``맞춰 보기''에 확인한 방법을 적었다.

@ 구간 크기 $\delta$는 컴파일할 때 정하고, $s_0$과 $t$는 프로그램을 돌릴 때
명령줄에서 준다. 명령줄 인자는 둘 더 있는데, 입력 파일과 출력 파일의 이름이다.

입력 파일에는 소수 $p_1$, $p_2$, \dots가 $p_k^2>s_t$인 첫 소수까지 모두 들어 있어야
한다. 그 뒤의 소수가 더 있어도 되고, 무시된다. 입력 파일은 이진 파일이고 소수마다
\.{unsigned int} 하나로 적힌다. 이 판은 원본처럼 이 기계의 바이트 순서로 읽는다.
($2^{32}$보다 작은 소수는 203,280,221개이고, 그 가운데 가장 큰 것은 $2^{32}-5$다.
그러니 크누스는 은연중에 $s_t<(2^{32}-5)^2\approx1.8\times10^{19}$이라고 가정한다.)

출력 파일은 큰 간격을 알리는 짧은 텍스트 파일이다. 연속한 소수의 간격
$p_{k+1}-p_k$가 앞서 본 모든 간격보다 크거나 같으면 그 간격을 내놓는다(다만 $256$보다
작으면 내놓지 않는다). 또 $s_0$과 $s_t$ 사이의 가장 작은 소수와 가장 큰 소수도 내놓는다.
그러면 이 프로그램을 여러 번 나누어 돌렸을 때 그 사이에 걸친 간격도 챙길 수 있다.

@ 뼈대는 이렇다.

@c
package main

import (
	"bufio"
	"encoding/binary"
	"fmt"
	"io"
	"math/bits"
	"os"
)

@<상수@>@;
@<전역 변수@>@;

func main() {
	var j, k, d, ii, kk int
	var x, y, z, s, ss uint64
	@<명령줄을 처리하고 소수를 읽는다@>@;
	@<첫 구간을 준비한다@>@;
	for ii = 0; ii < tt; ii++ {
		@<구간 |ii|를 처리한다@>@;
	}
	@<마지막 소수를 알린다@>@;
	outfile.Flush()
	out.Flush()
}

@ @<상수@>=
const (
	del  = 100000000   // 구간 크기 $\delta$, $128$의 배수
	kmax = 10000       // $p_{kmax}^2>s_t$인 첨자
	ones = ^uint64(0) // 모두 1인 낱말, 원본의 |-1|
)

@ @<전역 변수@>=
var (
	infile    *os.File
	outfile   *bufio.Writer
	prime     [kmax]uint32            // $|prime|[k]=p_{k+1}$
	start     [kmax]int               // 구간을 초기화할 때 쓰는 첨자
	sieve     [2 + del/128]uint64
	s0        uint64 // 첫 구간의 시작
	tt        int    // 구간의 수
	st        uint64 // 마지막 구간의 끝
	lastprime uint64 // 지금까지 본 가장 큰 소수(있다면)
	bestgap   = 256  // 간격을 알릴 하한
	sv        [11]uint64 // 가장 작은 소수들의 비트 무늬
	rem       [11]int    // 가장 작은 소수들의 자리 옮김 양
	out       = bufio.NewWriter(os.Stdout) // 표준 출력의 버퍼
)

@ 인자는 \CEE/의 |sscanf|처럼 읽는다. 원본은 음수 $t$를 걸러 내지 않는다. 그러면
$s_t=s_0+t\delta$가 $s_0$보다 작아져, 소수를 $\sqrt{s_t}$ 근처까지만 읽고서
$\sqrt{s_0}$까지의 소수를 찾아 읽지 않은 칸으로 넘어간다. 거기 든 $0$으로 나누고
|prime[10000]|까지 짚는 것을 \.{UndefinedBehaviorSanitizer}가 잡는다. 이 판은 음수
$t$를 사용법 오류로 거절한다.

@<명령줄을 처리하고 소수를 읽는다@>=
{
	ok := len(os.Args) == 5
	if ok {
		var t32 int32
		_, err1 := fmt.Sscanf(os.Args[1], "%d", &s0)
		_, err2 := fmt.Sscanf(os.Args[2], "%d", &t32)
		tt = int(t32)
		ok = err1 == nil && err2 == nil && tt >= 0
	}
	if !ok {
		fmt.Fprintf(os.Stderr, "Usage: %s s[0] t inputfile outputfile\n", os.Args[0])
		os.Exit(-1)
	}
}
@<입력 파일과 출력 파일을 연다@>@;
st = s0 + uint64(tt)*del
@<$\delta$와 $s_0$을 살핀다@>@;
@<소수를 읽는다@>@;
fmt.Fprintf(out, "Sieving between s[0]=%d and s[t]=%d:\n", s0, st)

@ @<입력 파일과 출력 파일을 연다@>=
{
	var err error
	if infile, err = os.Open(os.Args[3]); err != nil {
		fmt.Fprintf(os.Stderr, "I can't open %s for binary input!\n", os.Args[3])
		os.Exit(-2)
	}
	f, err := os.Create(os.Args[4])
	if err != nil {
		fmt.Fprintf(os.Stderr, "I can't open %s for text output!\n", os.Args[4])
		os.Exit(-3)
	}
	outfile = bufio.NewWriter(f)
}

@ 원본은 $s_0\ge\sqrt\delta$를 |s0*s0<del|로 살핀다. 그런데 곱이 $64$비트에서
넘치므로, $s_0$이 $2^{32}$의 배수이면 $s_0^2$이 $0$이 되어 멀쩡한 출발점을 거절한다.
이를테면 원본에 $s_0=4294967296$을 주면 ``\.{The starting point 4294967296 is less
than sqrt(100000000)!}''라며 멈춘다. 이 판은 $s_0\ge2^{32}$이면 곱하지 않는다.

@<$\delta$와 $s_0$을 살핀다@>=
if del%128 != 0 {
	fmt.Fprintf(os.Stderr, "Oops: The sieve size %d isn't a multiple of 128!\n", del)
	os.Exit(-4)
}
if s0&1 != 0 {
	fmt.Fprintf(os.Stderr, "The starting point %d isn't even!\n", s0)
	os.Exit(-5)
}
if s0 < 1<<32 && s0*s0 < del {
	fmt.Fprintf(os.Stderr, "The starting point %d is less than sqrt(%d)!\n", s0, del)
	os.Exit(-6)
}

@ 소수를 하나씩 읽으며 $2$로 시작하는지, 늘어나기만 하는지 살핀다. 그러다 $p_k^2>s_t$인
소수에 이르면 멈춘다.

@<소수를 읽는다@>=
for k = 0; ; k++ {
	if k >= kmax {
		fmt.Fprintf(os.Stderr, "Oops: Please recompile me with kmax>%d!\n", kmax)
		os.Exit(-7)
	}
	var buf [4]byte
	if _, err := io.ReadFull(infile, buf[:]); err != nil {
		var p uint32
		if k > 0 {
			p = prime[k-1]
		}
		fmt.Fprintf(os.Stderr, "The input file ended prematurely (%d^2<%d)!\n", p, st)
		os.Exit(-8)
	}
	prime[k] = binary.NativeEndian.Uint32(buf[:])
	if k == 0 && prime[0] != 2 {
		fmt.Fprintf(os.Stderr, "The input file begins with %d, not 2!\n", prime[0])
		os.Exit(-9)
	} else if k > 0 && prime[k] <= prime[k-1] {
		fmt.Fprintf(os.Stderr, "The input file has consecutive entries %d,%d!\n",
			prime[k-1], prime[k])
		os.Exit(-10)
	}
	if uint64(prime[k])*uint64(prime[k]) > st {
		break
	}
}
fmt.Fprintf(out, "%d primes successfully loaded from %s\n", k, os.Args[3])

@* 체질.
소수 $p_k$가 $p_k^2<s_{i+1}$이면 ``활성''이라 하자. 변수 |kk|는 활성이 아닌 첫
소수의 첨자다. 체질의 주된 일은 지금 구간에서 활성 소수의 배수를 모두 표시하는
것이다.

활성 소수 $p_k$마다, $s_i$보다 큰 $p_k$의 홀수 배 가운데 가장 작은 것을 $n_k$라 하자.
그리고 |start[k]|를 $(n_k-s_i-1)/2$, 곧 표시해야 할 첫 배수의 비트 자리로 둔다.

처음에는 |start[k]|를 나눗셈으로 구한다. 그러나 다음 구간부터는 체질의 부산물로
나눗셈 없이 얻는다. 그래서 굳이 |start[k]|를 메모리에 둔다.

출발점 $s_0$을 $p$로 나눈 나머지를 $j$라 하자. 나머지 $j$가 홀수이면 $s_0-j$는 홀수 배이지만 $s_0$
이하이니, 다음 홀수 배 $s_0-j+2p$를 쓴다. 그리고 $j$가 짝수이면 $s_0-j+p$가 홀수 배다.

@<활성 소수를 초기화한다@>=
for k = 1; uint64(prime[k])*uint64(prime[k]) < s0; k++ {
	j = int(s0 % uint64(prime[k]))
	if j&1 != 0 {
		start[k] = int(prime[k]) - ((j + 1) >> 1)
	} else {
		start[k] = (int(prime[k]) - j - 1) >> 1
	}
}
kk = k
@<아주 작은 활성 소수를 초기화한다@>@;

@ 크기가 $32$보다 작은 소수는 체의 여덟 바이트 낱말마다 적어도 두 번 나온다. 그래서 처음부터
활성인 한, 조금 더 빠른 방법으로 다룬다. 낱말 하나에 들어갈 비트 무늬 |sv[k]|를 만들어
두고, 낱말마다 그 무늬를 $64\bmod p$만큼 돌린다.

@<아주 작은 활성 소수를 초기화한다@>=
for k = 1; prime[k] < 32 && k < kk; k++ {
	for x, y = 0, 1<<start[k]; x != y; x, y = y, y|y<<prime[k] {
	}
	sv[k], rem[k] = x, 64%int(prime[k])
}
d = k // |d|는 아주 작지 않은 가장 작은 소수의 첨자

@ @<첫 구간을 준비한다@>=
@<활성 소수를 초기화한다@>@;
ss = s0 // 다음 구간의 바탕 주소
sieve[1+del/128] = ones // 파수꾼을 둔다

@ @<구간 |ii|를 처리한다@>=
s, ss = ss, ss+del // $s=s_i$, $|ss|=s_{i+1}$
fmt.Fprintf(out, "Beginning segment %d\n", s)
@<아주 작은 소수로 체를 초기화한다@>@;
@<이미 활성인 소수로 체질한다@>@;
@<새로 활성이 된 소수로 체질한다@>@;
@<큰 간격을 찾는다@>@;

@ @<아주 작은 소수로 체를 초기화한다@>=
for j = 0; j < del/128; j++ {
	z = 0
	for k = 1; k < d; k++ {
		z |= sv[k]
		sv[k] = sv[k]<<(int(prime[k])-rem[k]) | sv[k]>>rem[k]
	}
	sieve[j] = z
}

@ 이제 지금 구간에서 활성인 |prime[k]|마다 그 홀수 배에 1 비트를 켠다. $0\le
j<\delta/2$일 때 정수 $s_i+2j+1$의 비트는 |sieve[j>>6]|의 |1<<(j&0x3f)|다.

원본은 이것을 |1LL<<(j&0x3f)|로 써서 부호 있는 수를 $63$비트 민다. \CEE/에서 정의되지
않은 동작이라 \.{UndefinedBehaviorSanitizer}가 경고를 낸다. 이 판은 부호 없는
\.{uint64}로 민다.

@<이미 활성인 소수로 체질한다@>=
for k = d; k < kk; k++ {
	for j = start[k]; j < del/2; j += int(prime[k]) {
		sieve[j>>6] |= 1 << (j & 0x3f)
	}
	start[k] = j - del/2
}

@ 새로 활성이 된 소수는 $p_k^2$부터 표시한다. 그보다 작은 배수는 더 작은 소수가 이미
지웠다.

@<새로 활성이 된 소수로 체질한다@>=
for uint64(prime[k])*uint64(prime[k]) < ss {
	for j = int((uint64(prime[k])*uint64(prime[k]) - s - 1) >> 1); j < del/2; j += int(prime[k]) {
		sieve[j>>6] |= 1 << (j & 0x3f)
	}
	start[k] = j - del/2
	k++
}
kk = k

@* 간격 다루기.
두 소수의 간격이 $p_{k+1}-p_k\ge256$이면, $p_k$의 0 비트와 $p_{k+1}$의 0 비트 사이에 모두 1인 여덟
바이트 낱말이 반드시 있다. 두 소수 사이의 홀수 $127$개 이상이 모두 소수가 아니니,
그 가운데 낱말 하나를 통째로 덮기 때문이다. 그런 경우에 이 간격이 지금까지의 기록을
깨는지, 같은지를 살핀다.

$$\mplibcode
beginfig(1);
  u := 13mm; h := 5mm;
  for i = 0 upto 5:
    if (i >= 2) and (i <= 3):
      fill unitsquare xscaled u yscaled h shifted (i*u, 0) withcolor .82white;
    fi
    draw unitsquare xscaled u yscaled h shifted (i*u, 0);
  endfor
  label(btex \sevenrm 11111111 etex, (2.5u, .5h));
  label(btex \sevenrm 11111111 etex, (3.5u, .5h));
  label(btex \sevenrm 10110111 etex, (1.5u, .5h));
  label(btex \sevenrm 11101001 etex, (4.5u, .5h));
  label(btex \sevenrm 10110101 etex, (.5u, .5h));
  label(btex \sevenrm 10010110 etex, (5.5u, .5h));
  label.bot(btex $k$ etex, (1.5u, 0));
  label.bot(btex $j$ etex, (4.5u, 0));
  label.top(btex $p_k$ etex, (1.57u, h));
  label.top(btex $p_{k+1}$ etex, (4.44u, h));
endfig;
\endmplibcode$$
\figcap{체의 낱말들을 그린 것이다. 비트는 일부만, 수가 커지는 차례대로 낮은 자리부터
적었다. 회색 낱말은 모두 1이라
소수가 없다. 그 왼쪽 낱말 $k$의 가장 높은 0 비트가 $p_k$이고, 오른쪽 낱말 $j$의 가장
낮은 0 비트가 $p_{k+1}$이다.}

@ 간격이 구간의 맨 앞이나 맨 끝에 걸치거나, 구간 하나가 통째로 소수 없이 비면 일이
복잡해진다. 크누스는 프로그램을 느리게 하지 않으면서 이 논리를 바로잡으려 애썼다며,
이 코드에 버그가 있다면 이 대목의 추론이 틀린 탓일 것이라고 적었다. 나는 구간 크기를
$128$까지 줄여 구간 하나가 통째로 비는 경우까지 만들어 시험해 보았는데, 틀린 곳을 찾지
못했다.

루프를 빨리 끝내려고 체의 끝에 파수꾼 둘을 둔다. |sieve[del/128]=0|과
|sieve[1+del/128]=-1|이다. 앞의 것은 전역 배열이라 늘 $0$이다.

@<큰 간격을 찾는다@>=
j = 0
@<필요하면 이 구간의 첫 소수를 찾는다@>@;
for { // 여기서 |j<del/128|이고 |sieve[j]!=-1|이다
	for j++; sieve[j] != ones; j++ {
	}
	if j < del/128 {
		k = j - 1
		for j++; sieve[j] == ones; j++ {
		}
		if j == del/128 {
			break
		}
		@<눈여겨볼 만한 간격인지 살핀다@>@;
	} else { // |j=1+del/128|이고 |sieve[del/128-1]!=-1|이다
		k = del/128 - 1
		break
	}
}
@<|lastprime|을 |sieve[k]|의 가장 큰 소수로 둔다@>@;
donewithseg:

@ 값 |s|보다 큰 첫 소수의 정확한 값은 대개 알 필요가 없다. 지금 구간이 모두 1인 낱말로
시작하거나, 앞 구간이 그런 낱말로 끝나거나, 첫 구간일 때만 필요하다.

그러나 어떤 경우든, 지금 구간에 소수가 하나도 없으면 곧장 |donewithseg|로 가고
싶다. 그리고 이 단계는 늘 |j|를 |sieve[j]!=-1|인 가장 작은 첨자로 두고 끝나야 한다.

@<필요하면 이 구간의 첫 소수를 찾는다@>=
if lastprime <= s-128 || sieve[j] == ones {
	for ; sieve[j] == ones; j++ {
	}
	if j == del/128 {
		goto donewithseg
	}
	x = s + uint64(j<<7) + 2*uint64(bits.TrailingZeros64(^sieve[j])) + 1 // 이 구간의 첫 소수
	if lastprime != 0 {
		@<간격이 크면 알린다@>@;
	} else {
		k = int(x - s0)
		fmt.Fprintf(outfile, "The first prime is %d = s[0]+%d\n", x, k)
	}
}

@ 원본은 알릴 때마다 |fflush|로 출력 파일을 비운다. 이 판은 버퍼에 모았다가 끝에 한 번
비운다. 파일에 남는 내용은 같다.

@ 두 낱말이 |sieve[k]!=-1|, |sieve[j]!=-1|이고 그 사이가 모두 |-1|(모두 1)이면, 간격의
크기~$g$는 $128\vert j-k\vert-126\le g\le128\vert j-k\vert+126$이다.

@<눈여겨볼 만한 간격인지 살핀다@>=
if (j-k)<<7+126 >= bestgap {
	x = s + uint64(j<<7) + 2*uint64(bits.TrailingZeros64(^sieve[j])) + 1 // 간격 뒤의 첫 소수
	@<|lastprime|을 |sieve[k]|의 가장 큰 소수로 둔다@>@;
	@<간격이 크면 알린다@>@;
}

@ 낱말의 가장 낮은 0 비트와 가장 높은 0 비트의 자리는 \.{math/bits}로 구한다.

원본은 가장 오른쪽 1 비트 $y$를 뽑고, $y-1$의 1을 열여섯 비트씩 네 번 표 |nu|로 세어
이진 로그를 얻는다. 크누스가 목표로 한 \.{Opteron}에서는 그것이 가장 빠른 방법이었다.
요즘은 |bits.TrailingZeros64|와 |bits.Len64|가 명령어 하나로 번역되니 표가 필요
없다.

@<|lastprime|을 |sieve[k]|의...@>=
lastprime = s + uint64(k<<7) + 2*uint64(bits.Len64(^sieve[k])-1) + 1

@ @<간격이 크면 알린다@>=
if x-lastprime >= uint64(bestgap) {
	bestgap = int(x - lastprime)
	fmt.Fprintf(outfile, "%d is followed by a gap of length %d\n", lastprime, bestgap)
}

@ @<마지막 소수를 알린다@>=
if lastprime != 0 {
	k = int(st - lastprime)
	fmt.Fprintf(outfile, "The final prime is %d = s[t]-%d.\n", lastprime, k)
} else {
	fmt.Fprintf(outfile, "No prime numbers exist between s[0] and s[t].\n")
}

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 컴파일해 이 판과 견주었다. 표준 출력, 출력 파일, 표준
오류, 종료 부호가 바이트까지 같은지를 보았다. 사용법을 알리는 말에 든 프로그램
이름만 뺐다. 간격 찾기의 경계 경우를 드러내려고 원본과 이 판 모두 $\delta$를 $128$,
$256$, $640$, $1280$, $12800$으로 바꾼 판도 만들었다.

\smallskip
\item{$\bullet$} 원본이 옳은지는 파이썬으로 짠 구간 체와 견주어 보았다. 알려진 극대
간격 일곱 곳(436273009 뒤의 282부터 10726904659 뒤의 382까지) 둘레에서 출발점과
구간 수를 무작위로 고른 $750$건과, 작은 소수가 도중에 활성이 되는 작은 출발점
$447$건에서 출력 파일이 모두 같았다. 구간 하나가 통째로 소수 없이 비는 경우도 여기
들어 있다.
\item{$\bullet$} 이 판은 작은 $\delta$로 $600$건, $\delta=10^8$으로 $21$건에서 원본과
견주었다. 다른 것은 일부러 고친 두 경우, 곧 출발점 $2^{32}$과 음수 $t$뿐이다. 출발점
$2^{32}$에서 이 판이 낸 답은 파이썬 구간 체와 같다.
\smallskip

@* 색인.
