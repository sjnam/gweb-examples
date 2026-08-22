\input kotexgweb
\input luamplib.sty

% 그림들은 enigmatic-puzzle.mp 안에 fig_... 라는 이름으로 있다.
\everymplib{input enigmatic-puzzle;}

\def\title{에니그마 풀기}

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}
\def\dts{\mathinner{\ldotp\ldotp}}

@* 들어가며.
1918년, 독일 기술자 Arthur Scherbius가 회전자로 글자를 뒤섞는 암호 기계의 특허를
냈다. 처음에는 은행과 회사에 팔 물건이었는데, 1930년 무렵 독일군이 이것을 골라
쓰면서 {\it 에니그마\/}(Enigma)라는 이름이 역사에 남았다. 군용판에는 민간판에 없던
것이 하나 붙었다---앞판에 늘어선 스물여섯 개의 소켓, {\it 플러그보드\/}
(Steckerbrett)다. 케이블 열두어 개를 꽂아 글자 열두어 쌍을 미리 맞바꿔 두는 장치인데,
이것만으로 열쇠의 가짓수가 천문학적으로 불어난다.

이 프로그램은 크누스의 \.{CWEB} 프로그램 \pdfURL{\.{enigmatic-puzzle.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/enigmatic-puzzle.w}를
\.{GWEB}으로 옮긴 것이다. 하는 일은 이렇다. 125글자짜리 암호문 하나와, 그 안에 반드시
들어 있다고 알려진 낱말 하나(\.{ENIGMATICALLY})가 주어진다. 그것만으로 로터의
종류와 순서, 링 설정, 시작 위치, 플러그보드를 모두 알아내어 평문을 되찾는다.
TAOCP 7.2.2.8절에 실린 퍼즐이다.

@ 크누스는 이 프로그램을 두고 ``내 프로그램 다섯 개의 조각을 얼기설기 이어 붙인
것''이라고 적었다. 그 다섯은 \.{ENIGMA-BOMBE}, \.{ENIGMA-SETUP}, \.{ENIGMA-TAOCP},
\.{SAT0W-ALLSOLS}, \.{QUINGRAM-RATING}이다. 그래서 이 글도 자연히 여러 장으로
나뉜다. 기계를 흉내 내는 장, 로터가 어떻게 돌아갔을지를 나무로 세는 장, 봄베로
플러그보드의 후보를 좁히는 장, 남은 것을 SAT로 푸는 장, 링 설정을 되짚는 장,
그리고 마지막으로 나온 평문들 가운데 어느 것이 영어인지 가리는 장이다.

옮기면서 두 가지를 바꿨다. 하나는 채점표다. 크누스는 \.{QUINGRAM-RATING}이 미리
만들어 둔 $26^5$개짜리 파일을 읽는데, 우리는 그 표를 뜨는 원문을 직접 읽어 그
자리에서 센다---어차피 한 번 훑으면 되는 일이라 중간 파일을 둘 까닭이 없다.
다른 하나는 되돌아가기 스택의 크기인데, 그 이야기는 SAT 장에서 하겠다.

@c
package main

import (
	"fmt"
	"os"
	"strings"
)

@<상수@>@;
@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	@<명령줄을 처리한다@>@;
	@<자료 구조를 채비한다@>@;
	@<백만 가지 바퀴 배치를 훑는다@>@;
	@<셈한 것을 알린다@>@;
}

@* 기계.
에니그마 M3를 그림으로 그리면 이렇다. 자판에서 글자 하나를 누르면 전류가 흘러
플러그보드를 지나고, 회전자 셋을 오른쪽에서 왼쪽으로 통과하고, 왼쪽 끝의
{\it 반사판\/}(Umkehrwalze)에서 되돌아 나와, 회전자 셋을 반대로 거슬러 지나고,
플러그보드를 한 번 더 지나 램프 하나에 불을 켠다. 그 램프의 글자가 암호문 글자다.
$$
\mplibcode
fig_wiring;
\endmplibcode
$$
\figcap{{\bf 그림 1}: 글자 하나가 지나는 길. 회전자 셋(음영)은 글자를 칠 때마다
돌아가므로, 같은 글자를 두 번 쳐도 다른 글자가 나온다. 길이 반사판에서 되꺾여
나오는 탓에 들어간 글자와 나온 글자가 결코 같을 수 없다---이 프로그램은 그
빈틈으로 들어간다.}

@ 회전자는 다섯 개(\.I, \.{II}, \.{III}, \.{IV}, \.V) 가운데 셋을 골라 왼쪽부터
꽂는다. 고르고 늘어놓는 방법이 $5\cdot4\cdot3=60$가지다. 아래 문자열은 각 회전자의
배선이고, 반사판은 독일군이 오래 쓴 \.B판이다.

@<전역 변수@>=
var (
	rotorName = [5]string{"I", "II", "III", "IV", "V"}
	rotorPerm = [5]string{
		"DBYJRKALSNTVOUPMZEIWCXFHQG",
		"DMPSWGCROHXLBUIKTAQJZVEYFN",
		"YWUSFHJLNPGTVXBZDRCIMAKEOQ",
		"KYHXNBDVJWATSCMRUIELFPZQOG",
		"VZBRGITYUPSDNHLXAWMJQOFECK"}
	reflector = "YRUHQSLDPXNGOKMIEBFZCWVJAT" // 반사판 \.B
)

@ 반사판에는 치명적인 성질이 하나 있다. 전류가 되돌아 나오게 만들자면 반사판의
치환이 {\it 대합\/}(involution)이어야 하고, 게다가 고정점이 없어야 한다---어떤
글자를 제 자신으로 보내면 전구와 자판이 같은 글자에서 맞부딪혀 회로가 서지
않는다. 그래서 에니그마는 {\bf 어떤 글자도 자기 자신으로 암호화하지 못한다.}

기계를 쓰기 편하게 만들려던 이 장치가 결국 기계를 무너뜨렸다. 암호문 어딘가에
평문 조각(\.{crib})이 숨어 있으리라 짐작될 때, 그 조각을 암호문에 대고 미끄러뜨리며
같은 자리에 같은 글자가 오는 곳을 모두 지워 버릴 수 있기 때문이다. 우리 퍼즐에서도
크립을 놓을 수 있는 자리 $113$곳 가운데 $50$곳이 이 한 줄로 사라진다.

@ 회전자의 자리는 |pos|에, 링 설정을 뺀 실제 회전량은 |off|에 담는다. 글자는
$\.A\mapsto0$으로 적는다. 나눗셈을 피하려고 $0\dts51$을 $0\dts25$로 접는 표
|mod26|을 미리 만들어 둔다.

@<전역 변수@>=
var (
	perm  [3][26]int // 고른 회전자 셋의 치환
	iperm [3][26]int // 그 역치환
	refl  [26]int    // 반사판 치환
	pos   [3]int     // 느린 것, 가운데 것, 빠른 것의 자리
	off   [3]int     // 링 설정을 뺀 회전량
	mod26 [26 + 26]int
)

@ 이제 기계의 심장이다. 오른쪽(빠른 회전자)부터 왼쪽으로 훑고, 반사한 뒤,
왼쪽에서 오른쪽으로 거슬러 나온다. 회전량 |off[k]|만큼 돌아간 회전자를 지나는
것은 ``들어갈 때 더하고 나올 때 빼는'' 일이다.

@<글자 |c|를 암호화한다@>=
c = mod26[perm[2][mod26[c+off[2]]]+26-off[2]]
c = mod26[perm[1][mod26[c+off[1]]]+26-off[1]]
c = mod26[perm[0][mod26[c+off[0]]]+26-off[0]]
c = refl[c]
c = mod26[iperm[0][mod26[c+off[0]]]+26-off[0]]
c = mod26[iperm[1][mod26[c+off[1]]]+26-off[1]]
c = mod26[iperm[2][mod26[c+off[2]]]+26-off[2]]

@ 글자 하나를 칠 때마다 회전자가 돈다. 빠른 회전자는 늘 한 칸 돌고, 그것이 한 바퀴를
채우면 가운데 것을 밀어 올리며, 가운데 것이 한 바퀴를 채우면 느린 것까지 밀어 올린다.
그런데 실제 기계에는 {\it 이중 걸음\/}(double stepping)이라는 유명한 별난 구석이
있어서, 가운데 회전자가 문턱에 서 있으면 그 자신도 함께 한 칸 더 돈다. 아래 세 갈래가
그 논리를 그대로 옮긴 것이다. 크누스는 회전자 배선을 문턱이 \.Z에 오도록 미리 돌려
두었으므로, 문턱 검사가 ``자리가 $25$인가''로 단순해진다.

@<회전자를 돌린다@>=
switch {
case pos[1] == 25: // 큰 자리올림: 셋이 함께 돈다
	pos[0], off[0] = mod26[pos[0]+1], mod26[off[0]+1]
	fallthrough
case pos[2] == 25: // 가운데와 빠른 것이 돈다
	pos[1], off[1] = mod26[pos[1]+1], mod26[off[1]+1]
	fallthrough
default: // 빠른 것만 돈다
	pos[2], off[2] = mod26[pos[2]+1], mod26[off[2]+1]
}

@* 델타 나무.
공격을 시작하려면 성가신 사실 하나를 넘어야 한다. 우리는 링 설정을 모른다. 링
설정은 회전자의 배선과 눈금 사이의 어긋남이라, 실제 회전량 |off|에 상수를 더하는
효과를 낸다. 그런데 {\it 자리올림이 언제 일어나는가\/}는 링이 아니라 |pos|가
정하므로, 링을 모르는 채로는 회전자가 언제 서로를 밀어 올렸는지도 모른다.

크누스의 해법이 곱다. 링 설정을 아예 잊어버리고, 대신 ``크립 $m$글자를 찍는 동안
세 회전량이 처음보다 얼마나 늘었는가''만 따진다. 그 늘어난 양을 {\it 델타\/}라
부르자. 첫걸음의 델타는 $(0,0,1)$이거나 $(0,1,1)$이거나 $(1,1,1)$, 셋뿐이다.
그리고 $k$걸음까지 갈 수 있는 델타의 열은 정확히 $2k+1$가지다. 이것들을 나무
하나에 담는다. 층 $k$의 노드가 $2k+1$개이니 층 $25$까지 모두 모으면
$1+3+5+\cdots+51=26^2=676$개다.

@ 층 $k$의 노드 가운데 델타가 $(0,0,k)$인 것과 $(1,1,k)$인 것이 하나씩 있고,
$(0,1,k)$인 것이 $k$개, 나머지 $k-1$개는 모두 $(1,2,k)$다.
$$
\mplibcode
fig_delta;
\endmplibcode
$$
\figcap{{\bf 그림 2}: 델타 나무의 위 네 층. 노드에 적힌 세 자리는 느린 회전자,
가운데 회전자, 빠른 회전자의 회전량이 처음보다 얼마나 늘었는지를 나타낸다. 층마다
노드가 $2k+1$개씩 늘어난다.}

노드는 부모와 형제를 색인으로 가리킨다. \CEE/ 원본은 포인터를 썼지만 색인이
\GO/에서 다루기 쉽고 뜻도 또렷하다. 뿌리는 $0$번이고, 없음은 $-1$이다.

@<자료형@>=
type node struct {
	parent, sibling int    // 색인. 없으면 $-1$
	del             [3]int // 세 회전량이 늘어난 양
}

@ @<전역 변수@>=
var (
	delta [676]node // $1+3+5+\cdots+51=676$
	level [26]int   // 각 층의 노드를 잇는 목록의 머리
)

@ 나무를 짓는 규칙은 이렇다. 델타가 $(0,0,\cdot)$이면 다음은 $(0,0,\cdot)$이나
$(0,1,\cdot)$이고, $(0,1,\cdot)$이면 다음은 $(0,1,\cdot)$이거나---{\it 부모도\/}
$(0,\ast,\cdot)$였을 때만---$(1,2,\cdot)$이다. 앞자리가 이미 $1$이면 더 오를 데가
없어 가운데 값을 그대로 물려받는다.

@<델타 나무를 짓는다@>=
for k := range level {
	level[k] = -1
}
delta[0].parent, delta[0].sibling = -1, -1
j, p := 1, 0
@<층 |k|에 노드를 하나 단다@>@;
newnode(0, 0, 1)
newnode(0, 1, 1)
newnode(1, 1, 1)
@<둘째 층부터 스물다섯째 층까지 자란다@>@;

@ 노드를 다는 일은 한곳에 모아 두는 편이 낫다. 클로저 하나로 |j|와 |k|와 |p|를
함께 잡아 둔다.

@<층 |k|에 노드를 하나 단다@>=
k = 1
newnode := func(a, b, c int) {
	delta[j].parent, delta[j].sibling = p, level[k]
	delta[j].del = [3]int{a, b, c}
	level[k] = j
	j++
}

@ @<둘째 층부터 스물다섯째 층까지 자란다@>=
for k = 2; k < 26; k++ {
	for p = level[k-1]; p >= 0; p = delta[p].sibling {
		d := delta[p].del
		switch {
		case d[0] != 0:
			newnode(1, d[1], k)
		case d[1] == 0:
			newnode(0, 0, k)
			newnode(0, 1, k)
		default:
			newnode(0, 1, k)
			if delta[delta[p].parent].del[1] == 0 {
				newnode(1, 2, k)
			}
		}
	}
}

@ 로터 셋을 고르고 나면, 회전량 세 개가 정해질 때마다 기계가 어떤 치환을 내는지
미리 다 계산해 둘 수 있다. 회전량이 $26^3$가지이고 글자가 $26$개이니 표가
$26^4=456{,}976$칸이다. 값이 모두 $0\dts25$이므로 바이트 하나면 넉넉한데, 이
표는 안쪽 고리에서 쉼 없이 읽히므로 작게 만들어 캐시에 앉히는 것이 실제로 값을 한다.

@<전역 변수@>=
var enc [26][26][26][26]uint8 // 지금 로터로 만든 치환들

@ @<지금 로터로 치환표를 만든다@>=
for off[0] = 0; off[0] < 26; off[0]++ {
	for off[1] = 0; off[1] < 26; off[1]++ {
		for off[2] = 0; off[2] < 26; off[2]++ {
			for j := 0; j < 26; j++ {
				c := j
				@<글자 |c|를 암호화한다@>@;
				enc[off[0]][off[1]][off[2]][j] = uint8(c)
			}
		}
	}
}

@* 봄베.
1932년, 폴란드 암호국(Biuro Szyfr\'ow)의 젊은 수학자 Marian Rejewski가 동료
Jerzy R\'o\.zycki, Henryk Zygalski와 함께 에니그마를 깨뜨렸다. 순열의 군론으로
회전자 배선을 알아낸 이 일은 지금도 암호 역사에서 가장 눈부신 대목으로 꼽힌다.
1938년에는 열쇠를 자동으로 찾아 주는 기계 {\it 봄바\/}(bomba kryptologiczna)까지
만들었다. 1939년 7월, 전쟁이 코앞에 닥치자 폴란드는 바르샤바 근교 피리(Pyry)에서
영국과 프랑스에 자신들이 알아낸 모든 것을 넘겼다.

그 자리에 있던 영국 쪽 사람들이 블레츨리 파크로 돌아가, Alan Turing이 새 기계를
설계했다. 폴란드 봄바가 독일군의 특정한 열쇠 관행에 기대고 있었던 것과 달리,
튜링의 {\it 봄베\/}(Bombe)는 {\it 크립\/}에 기댔다---암호문 어딘가에 반드시 들어
있을 법한 평문 조각 말이다. 독일군의 규칙적인 통신이 크립을 후하게 내주었다.
``Wetterbericht''(일기 예보), ``Keine besonderen Ereignisse''(특별한 일 없음)
같은 것들이다. 우리 퍼즐의 크립은 \.{ENIGMATICALLY} 한 낱말이다.

@ 봄베의 착상은 이렇다. 플러그보드는 모르지만, 그것이 {\it 대합\/}이라는 것은
안다---\.A를 \.T에 꽂으면 \.T도 \.A에 꽂힌다. 그래서 우리가 다룰 것은 순서 없는
글자 짝 $\{i,j\}$이고, 그런 짝이 ${26\choose2}+26=351$개다. 짝 $\{i,i\}$는
``$i$는 아무 데도 꽂히지 않았다''는 뜻이다.

이제 크립의 $k$번째 글자가 평문 $P$이고 그 자리의 암호문이 $C$라 하자. 회전자
부분의 치환(플러그보드를 뺀 것)을 $\pi_k$라 하면, 기계가 하는 일은
$$C=\hbox{플러그}\bigl(\pi_k(\hbox{플러그}(P))\bigr)$$
이다. 그러니 ``$P$가 $i$에 꽂혔다''고 가정하면 곧바로 ``$C$가 $\pi_k(i)$에
꽂혔다''가 따라 나온다. 이 두 짝은 함께 참이거나 함께 거짓이다. 스물여섯 개의
$i$마다 이런 연결을 하나씩 긋고, 크립의 $m$글자에 대해 되풀이하면, $351$개의
짝이 여러 {\it 동치류\/}로 뭉친다. 한 류에 든 짝들은 운명을 같이한다.

@ 여기서 짝을 순서 없이 다룬 것이 바로 Gordon Welchman이 튜링의 봄베에 덧붙인
{\it 대각판\/}(diagonal board)의 정신이다. 튜링의 원래 설계는 ``$P$가 $i$에''와
``$i$가 $P$에''를 따로 다루었는데, Welchman이 그 둘이 같은 말임을 배선으로
못 박자 기계의 힘이 몇 곱절로 뛰었다. 우리 표에서는 |loc(i,j)|가 |loc(j,i)|와
같은 칸을 가리키는 것으로 그 일이 끝난다. 배선 한 뭉치가 첨자 하나로 줄어든 셈이다.

@ 짝 $\{i,j\}$는 $i\le j$일 때 |rowadd[i]+j|번 칸이다. 이 함수는 온 프로그램에서
가장 자주 불린다.

@<상수@>=
const (
	nn    = 351 // 글자 짝의 수
	maxm  = 25  // 크립의 최대 길이
	maxmc = 150 // 암호문의 최대 길이
)

@ @<전역 변수@>=
var rowadd = [26]int{0, 25, 49, 72, 94, 115, 135, 154, 172, 189, 205, 220,
	234, 247, 259, 270, 280, 289, 297, 304, 310, 315, 319, 322, 324, 325}

@ 봄베를 한 번 돌릴 때마다 짝 $351$개를 처음 상태로 되돌려야 한다. 그 처음 상태는
늘 같으니 미리 만들어 두고 통째로 복사한다. 되돌리는 일이 온 프로그램에서 십육억
번 넘게 일어나므로 이런 것이 값을 한다.

@<전역 변수@>=
var (
	self  [nn]int // $v\mapsto v$
	ones  [nn]int // 모두 $1$
	bits0 [nn]int // 짝 하나만 든 류의 비트
)

@ @<처음 상태를 미리 만들어 둔다@>=
for i := 0; i < 26; i++ {
	for j := 0; j < 26; j++ {
		if i <= j {
			locTab[i][j] = rowadd[i] + j
		} else {
			locTab[i][j] = rowadd[j] + i
		}
	}
}
for v := 0; v < nn; v++ {
	self[v], ones[v] = v, 1
}
for i := 0; i < 26; i++ {
	for j := i; j < 26; j++ {
		bits0[loc(i, j)] = (1 << i) | (1 << j)
	}
}

@ 셈은 이렇지만 실제로는 표를 하나 떠 두고 짚는다. 이 함수가 봄베의 안쪽 고리에서
한 번 돌 때마다 천 번 넘게 불리므로, 비교 한 번을 아끼는 것이 그냥 아끼는 것이 아니다.
프로파일을 떠 보니 표로 바꾸는 것만으로 온 프로그램이 한 할쯤 빨라졌다.

@<전역 변수@>=
var locTab [26][26]int

@ @<함수들@>=
func loc(i, j int) int { return locTab[i][j] }

@ 동치류는 여느 때처럼 합치기-찾기로 다룬다. 다만 대표를 갈아 끼울 때 원소를 모두
훑어야 하므로, 같은 류의 원소들을 |link|로 둥글게 이어 둔다. 그리고 각 류마다
{\it 그 류에 나오는 글자들\/}을 비트로 모아 |bits|에 담는데, 같은 글자가 두 번
나오면 $-1$로 표시한다. 플러그보드는 대합이라 한 글자가 두 짝에 낄 수 없으니,
$-1$인 류는 이미 모순이다.

@<전역 변수@>=
var (
	rep  [nn]int // 이 원소가 든 류의 대표
	size [nn]int // 대표가 이끄는 류의 크기
	bits [nn]int // 류에 나오는 글자들. 겹치면 $-1$
	link [nn]int // 같은 류의 다음 원소
	name [nn]string
)

@ 합치기는 작은 쪽을 큰 쪽에 붙이는 흔한 방식이다. 크누스는 이 함수에 |yewnion|
이라는 이름을 붙였는데, \CEE/에서 |union|이 예약어라 소리 나는 대로 적은 장난이다.
\GO/에서는 |union|을 그대로 쓸 수 있지만, 이 농담이 아까워 그대로 둔다.

@<함수들@>=
func yewnion(u, v int) int {
	s, t := rep[u], rep[v]
	if s == t {
		return s
	}
	if size[s] < size[t] {
		s, t = t, s
	}
	rep[t] = s
	for p := link[t]; p != t; p = link[p] {
		rep[p] = s
	}
	size[s] += size[t]
	if bits[s]&bits[t] != 0 {
		bits[s] = -1
	} else {
		bits[s] += bits[t]
	}
	link[s], link[t] = link[t], link[s]
	return s
}

@* 문제.
명령줄로 크립과 암호문을 받는다. 크누스의 것에 낱말 빈도를 뜰 원문 파일 이름을
하나 더 얹었다.

@<전역 변수@>=
var (
	plaintext  [maxm]int  // 주어진 크립
	ciphertext [maxmc]int // 주어진 암호문
	plainsize  int
	ciphersize int
	fullswap   [maxm][26]int // 지금 다루는 치환들
	pused      [26]int // 크립에 이 글자가 몇 번 나오는가
	used       [26]int // 지금 다루는 글자들에 몇 번 나오는가
	corpusFile = "VOL1TEXT"
)

@ @<명령줄을 처리한다@>=
args := os.Args[1:]
if len(args) >= 3 {
	corpusFile, args = args[2], args[:2]
}
if len(args) != 2 {
	fmt.Fprintf(os.Stderr, "사용법: %s 크립 암호문 [원문파일]\n", os.Args[0])
	os.Exit(1)
}
crib, cipher := args[0], args[1]
@<크립과 암호문을 숫자로 바꾼다@>@;

@ 두 문자열은 대문자 알파벳만이어야 하고, 크립이 암호문보다 길면 말이 안 된다.

@<크립과 암호문을 숫자로 바꾼다@>=
plainsize, ciphersize = len(crib), len(cipher)
if plainsize > maxm || ciphersize > maxmc || plainsize > ciphersize {
	fmt.Fprintf(os.Stderr, "크립은 %d글자까지, 암호문은 %d글자까지, 그리고 크립이 더 짧아야 한다!\n",
		maxm, maxmc)
	os.Exit(1)
}
for i, ch := range []byte(crib + cipher) {
	if ch < 'A' || ch > 'Z' {
		fmt.Fprintln(os.Stderr, "글자는 모두 대문자여야 한다!")
		os.Exit(1)
	}
	if i < plainsize {
		plaintext[i] = int(ch - 'A')
		pused[plaintext[i]]++
	} else {
		ciphertext[i-plainsize] = int(ch - 'A')
	}
}
fmt.Fprintf(os.Stderr, "크립 %d글자, 암호문 %d글자로 시작한다.\n", plainsize, ciphersize)

@ @<자료 구조를 채비한다@>=
for i := 0; i < 26; i++ {
	mod26[i], mod26[i+26] = i, i
	refl[i] = int(reflector[i] - 'A')
}
@<처음 상태를 미리 만들어 둔다@>@;
@<델타 나무를 짓는다@>@;
for i := 0; i < 26; i++ {
	for j := i; j < 26; j++ {
		name[loc(i, j)] = string([]byte{byte('A' + i), byte('A' + j)})
	}
}
@<원문을 읽어 다섯 글자 빈도를 센다@>@;

@ 회전자 셋을 고르는 $60$가지와 회전량 $26^3$가지를 곱하면 $1{,}054{,}560$가지,
곧 백만 남짓이다. 이 여섯 겹 고리가 프로그램의 바깥 뼈대다.

@<백만 가지 바퀴 배치를 훑는다@>=
for r0 = 0; r0 < 5; r0++ {
	@<로터 $0$을 |r0|형으로 끼운다@>@;
	for r1 = 0; r1 < 5; r1++ {
		if r1 == r0 {
			continue
		}
		@<로터 $1$을 |r1|형으로 끼운다@>@;
		for r2 = 0; r2 < 5; r2++ {
			if r2 == r0 || r2 == r1 {
				continue
			}
			@<로터 $2$를 |r2|형으로 끼운다@>@;
			@<지금 로터로 치환표를 만든다@>@;
			@<회전량 세 개를 모두 훑는다@>@;
		}
	}
}

@ 회전자를 끼우는 일은 배선 문자열을 숫자로 옮기고 그 역치환을 만드는 것이다.
같은 일을 세 번 하므로 이름 있는 절 하나를 세 곳에서 부른다.

@<로터를 끼운다@>=
for i := 0; i < 26; i++ {
	perm[k][i] = int(rotorPerm[jj][i] - 'A')
}
for i := 0; i < 26; i++ {
	iperm[k][perm[k][i]] = i
}

@ @<로터 $0$을 |r0|형으로 끼운다@>=
k, jj = 0, r0
@<로터를 끼운다@>@;

@ @<로터 $1$을 |r1|형으로 끼운다@>=
k, jj = 1, r1
@<로터를 끼운다@>@;

@ @<로터 $2$를 |r2|형으로 끼운다@>=
k, jj = 2, r2
@<로터를 끼운다@>@;

@ @<회전량 세 개를 모두 훑는다@>=
for p0 = 0; p0 < 26; p0++ {
	for p1 = 0; p1 < 26; p1++ {
		for p2 = 0; p2 < 26; p2++ {
			@<변형 하나를 살펴본다@>@;
		}
	}
}

@ 델타 나무의 층 $m-1$에 있는 노드 하나를 고르면 크립 $m$글자 동안의 회전량이
모두 정해지고, 따라서 치환 $\pi_0,\ldots,\pi_{m-1}$이 정해진다. 그 다음은 크립을
암호문의 어느 자리에 대 볼 것인가---그것이 |kk|다.

@<변형 하나를 살펴본다@>=
for pp = level[plainsize-1]; pp >= 0; pp = delta[pp].sibling {
	@<델타 경로를 따라 |fullswap|을 만든다@>@;
nextkk:
	for kk = 0; kk+plainsize <= ciphersize; kk++ {
		@<크립이 암호문과 부딪히면 건너뛴다@>@;
		@<쓰인 글자를 센다@>@;
		@<봄베를 돌린다@>@;
		@<시험 해가 나왔으면 거대 강제류를 찾는다@>@;
	}
}

@ 노드에서 뿌리까지 거슬러 올라가며 뒤에서부터 채운다. 뿌리의 델타는 $(0,0,0)$이라
첫 치환은 회전량 $(p_0,p_1,p_2)$ 그대로다.

@<델타 경로를 따라 |fullswap|을 만든다@>=
for k, q := plainsize-1, pp; k >= 0; k, q = k-1, delta[q].parent {
	d := delta[q].del
	e := &enc[mod26[p0+d[0]]][mod26[p1+d[1]]][mod26[p2+d[2]]]
	for j := 0; j < 26; j++ {
		fullswap[k][j] = int(e[j])
	}
}

@ 반사판이 남긴 흠집을 쓰는 자리가 여기다. 크립의 글자와 암호문의 글자가 한 자리에서
같으면 그 자리는 볼 것도 없다.

@<크립이 암호문과 부딪히면 건너뛴다@>=
clash := false
for i := 0; i < plainsize; i++ {
	if plaintext[i] == ciphertext[kk+i] {
		clash = true
		break
	}
}
if clash {
	continue
}

@ @<쓰인 글자를 센다@>=
used = pused
for i := 0; i < plainsize; i++ {
	used[ciphertext[kk+i]]++
}

@ 봄베 자체는 짧다. 짝 $351$개를 저마다 홀로 두고 시작해서, 크립의 걸음마다
스물여섯 개의 연결을 긋는다.

크누스는 첫 판(그가 \.{ENIGMA-BOMBE-TOY}라 부르는 것)에서 $i$와 $j$가 둘 다 크립에
안 쓰인 글자면 |size[loc(i,j)]|를 $0$으로 두었다고 적었다. 그러고는 ``일반적으로는
그것을 정당화할 수 없다''며 물렀다. 플러그보드는 크립에만 쓰이는 것이 아니라 암호문
전체에 쓰이기 때문이다.

@<봄베를 돌린다@>=
copy(rep[:], self[:])
copy(link[:], self[:])
copy(size[:], ones[:])
copy(bits[:], bits0[:])
for k := 0; k < plainsize; k++ {
	for i := 0; i < 26; i++ {
		yewnion(loc(plaintext[k], i), loc(ciphertext[kk+k], fullswap[k][i]))
	}
}

@* 더 나은 거르개.
봄베가 동치류를 다 만들고 나면, 쓰인 글자 $i$마다 ``$i$가 낀 짝을 담은 {\it 좋은\/}
류''가 적어도 하나는 있어야 한다. 좋은 류란 짝들이 서로 글자를 겹치지 않는 류,
곧 |bits>=0|인 류다. 그런 류는 실제로 드물어서, 쓰인 글자 가운데 하나쯤은 좋은
류에서 통째로 지워지기 마련이다. 그러면 지금의 배치로는 그 암호문이 나올 수 없다.

그런데 더 잘할 수 있다. 아니, 더 잘해야만 한다---그러지 않으면 가짜 ``해''가 너무
많아진다. 크누스는 첫 판에서 봄베가 통과시킨 맨 처음 시험 해를 손으로 들여다보고
이렇게 적었다. 쓰인 글자 \.A가 좋은 류 {\it 하나\/}에만 들어 있었고 그 류에 짝
\.{AU}가 있었다. 그러니 \.A와 \.U는 반드시 함께 꽂혀야 한다. 그런데 쓰인 글자 \.B도
좋은 류 하나에만 들어 있었고, 그 류에는 짝 \.{BU}가 있었다. 모순이다.

@ 그래서 이렇게 한다. 쓰인 글자 $i$를 담은 좋은 류가 딱 하나라면 그 류의 짝들은
{\it 반드시\/} 꽂힌다. 그런 류를 {\it 강제류\/}라 부르자. 강제류는 모두 하나로
합쳐도 되고, 합친 것---{\it 거대류\/}---안의 짝들은 서로 글자가 달라야 한다.

@<시험 해가 나왔으면 거대 강제류를 찾는다@>=
giant, hit := -1, 0
for i := 0; i < 26; i++ {
	if used[i] == 0 {
		continue
	}
	@<글자 |i|를 담은 좋은 류를 센다@>@;
	if c == 0 {
		continue nextkk // 글자 |i|가 지워졌으니 해가 아니다
	}
	if c == 1 { // |hit|이 강제류다
		if giant < 0 {
			giant = hit
		} else if giant != hit {
			giant = yewnion(giant, hit)
			if bits[giant] < 0 {
				continue nextkk
			}
		}
	}
}
if giant >= 0 {
	@<거대류로 더 쳐 낼 수 있으면 쳐 낸다@>@;
}
@<해를 살펴본다@>@;

@ @<글자 |i|를 담은 좋은 류를 센다@>=
c := 0
for j := 0; j < 26; j++ {
	if s := rep[loc(i, j)]; bits[s] >= 0 {
		c, hit = c+1, s
	}
}

@ 거대류가 아닌 류는 강제된 짝들과 글자를 겹치지 않을 때에만 살아남는다. 그러니
거대류와 부딪히는 류는 모두 죽일 수 있고, 그러면 또 다른 류가 강제류가 될 수 있다.
모순이 나오거나 더 변하지 않을 때까지 되풀이한다.

원본에는 안쪽 고리가 끝난 뒤에도 |change|를 한 번 더 보는 줄이 있는데, 그 자리에
이르렀다면 |change|는 이미 참이므로 결코 걸리지 않는다. 죽은 줄이라 여기서는 뺐다.

@<거대류로 더 쳐 낼 수 있으면 쳐 낸다@>=
for {
	change := false
	for k := 0; k < nn; k++ {
		if rep[k] == k && bits[k] >= 0 && k != giant && bits[k]&bits[giant] != 0 {
			change, bits[k] = true, -1
		}
	}
	if !change {
		break
	}
	@<새로 강제류가 된 것이 있으면 거대류에 합친다@>@;
}

@ @<새로 강제류가 된 것이 있으면 거대류에 합친다@>=
for i := 0; i < 26; i++ {
	if used[i] == 0 || (1<<i)&bits[giant] != 0 {
		continue
	}
	@<글자 |i|를 담은 좋은 류를 센다@>@;
	if c == 0 {
		continue nextkk
	}
	if c == 1 {
		giant = yewnion(giant, hit)
		if bits[giant] < 0 {
			continue nextkk
		}
	}
}

@* 플러그보드를 SAT로.
여기까지 통과했다면 플러그보드가 있을 법한 배치를 하나 찾은 것이다. 정말 있는지는
SAT 해결기에게 물어본다.

착상은 간단하다. 살아남은 좋은 류 $C_0,\ldots,C_{n-1}$마다 불 변수 $x_j$를 하나
두어 ``이 류의 짝들을 모두 꽂는다''를 뜻하게 한다. 두 류가 글자를 공유하면 둘 다
고를 수 없으니 {\it 많아야 하나\/} 제약 $(\bar x_j\lor\bar x_k)$가 생긴다. 그리고
글자 $l$마다 그것을 담은 류가 적어도 하나는 뽑혀야 하니 {\it 적어도 하나\/} 제약
$\bigl(\bigvee\{x_j\mid l\in C_j\}\bigr)$가 생긴다. 이것을 다 풀면 쓸 수 있는
플러그보드가 남김없이 나온다.

@ @<전역 변수@>=
var (
	klass      [nn]int
	kbits      [nn]int
	konstraint [26]uint64
	nvars      int
)

@ @<해를 살펴본다@>=
cases++
nvars = 0
for k := 0; k < nn; k++ {
	if rep[k] == k && bits[k] >= 0 {
		klass[nvars], kbits[nvars] = k, bits[k]
		nvars++
	}
}
if nvars > varsmax {
	varsmax = nvars
}
satSolve()
if sols == 0 {
	fails++
	if nvars > 64 {
		hardfails++
	}
} else {
	@<플러그보드와 링 설정마다 평문을 살펴본다@>@;
}

@* SAT 해결기.
아래 코드는 크누스의 오래된 프로그램 \.{SAT0W}를 잘라 붙인 것인데, 우리 쓰임에
맞춰 크게 줄였다. 알고리즘 7.2.2.2B, 곧 {\it 감시 리터럴\/}(watched literals)을
쓰는 단순한 되돌아가기다. 한 절은 리터럴 하나만 감시하며, 그 리터럴이 거짓이 될
때에만 그 절을 들여다본다.

제약을 만드는 일과 푸는 일과 뒷정리를 한 함수에 담았다. 이 함수는 한 곳에서만
부르지만, 조기 반환이 여러 겹으로 얽힌 큰 알고리즘이라 이름 있는 절로 인라인하기에는
모양이 사납다. 뒷정리는 |defer|에 맡겨, 어디서 빠져나가든 반드시 치우도록 했다---
원본에서 크누스가 ``자취를 지워야 한다''고 따로 당부한 대목이 \GO/에서는 한 줄이 된다.

@<함수들@>=
func satSolve() {
	sols, vars = 0, nvars
	clauses, nonspec, cells = nvars+nvars+2, nvars+nvars+2, 0
	defer func() {
		@<|cmem|을 지운다@>@;
	}()
	@<제약을 만든다@>@;
	@<되돌아가며 모든 해를 찾는다@>@;
}

@ 자료 구조의 기본 단위는 {\it 칸\/}(cell)이다. 절에 든 리터럴 하나에 칸 하나가
대응한다. 절은 제 첫 칸의 주소로 나타내는데, 그 칸에 든 것이 곧 감시 리터럴이다.
절 |c|의 칸들은 |cmem[c].start|부터 |cmem[c+1].start-1|까지다. 앞쪽 $2n+2$개의
``절''은 진짜 절이 아니라 리터럴마다 하나씩 두는 감시 목록의 머리다.

리터럴 번호는 변수 $x_k$가 $2k+2$, 그 부정 $\bar x_k$가 $2k+3$이다.

@<상수@>=
const (
	memsize    = 4000
	clausesize = 6000
	maxsols    = 10000
)

@ @<자료형@>=
type clauseRec struct {
	start uint32 // 이 절의 칸이 시작하는 |mem| 안의 주소
	wlink uint32 // 감시 목록의 다음 절
}

@ @<전역 변수@>=
var (
	mem     [memsize]uint32   // 리터럴 번호를 담는 칸들
	cmem    [clausesize]clauseRec
	nonspec int    // 진짜 절이 시작하는 자리
	move    [nn + 2]int // 지금까지의 선택
	vars, clauses, cells, sols int
	plugs   [maxsols][27]int
)

@ 원본은 |move|를 예순네 칸으로 잡아 두었다. 그런데 변수의 수가 예순넷을 넘는
경우가 있다는 것을 크누스 자신이 적어 두었고(``$1500$번에 한 번쯤''), 그때
|move[level]|은 배열 밖을 짚는다. 바로 뒤에 놓인 |vars|를 덮어쓰게 되니 사소한
일이 아니다. 실제로 원본을 이 문제에 끝까지 돌려 보니 마지막에 찍히는 통계가
``\.{max vars 79}''였다---넘침은 이론이 아니라 실제로 일어난다. 여기서는 층이
변수 수를 넘지 않으므로 |nn+2|칸으로 넉넉히 잡았다.

@ 제약을 만드는 순서는 이렇다. 먼저 글자를 공유하는 류 짝마다 이항 제약을 만들고,
그다음 글자마다 적어도-하나 제약을 만든다. 실제로는 적어도-하나 제약들이 서로를
삼키는 일이 잦아서, 류가 예순넷 이하면 제약 하나를 $64$비트 낱말에 담아 포섭 관계를
싸게 걸러 낸다.

@<제약을 만든다@>=
for j := 0; j < nvars; j++ {
	for k := j + 1; k < nvars; k++ {
		if kbits[j]&kbits[k] != 0 {
			@<이항 제약 $(\bar x_j\lor\bar x_k)$을 만든다@>@;
		}
	}
}
if nvars > 64 {
	@<적어도-하나 제약을 우격다짐으로 만든다@>@;
} else {
	@<겹치는 것을 걸러 적어도-하나 제약을 만든다@>@;
}

@ 절 하나를 닫는 일은 세 곳에서 똑같이 되풀이된다. 쌓아 둔 리터럴 가운데 첫 번째를
{\it 감시자\/}로 삼아 그 리터럴의 감시 목록에 이 절을 끼워 넣는다. 절이 비었다면
그 글자를 담은 좋은 류가 하나도 없다는 뜻이니 그 자리에서 못 푼다고 판정한다.
원본은 이 경우를 따로 다루지 않는데, 빈 절이 생기면 감시자를 읽는 자리가 아직
쓰이지 않은 칸을 가리키게 된다.

@<절 하나를 닫는다@>=
if cells == st {
	return // 빈 절이 나왔다---풀 수 없다
}
w := int(mem[st])
cmem[clauses].wlink = cmem[w].wlink
cmem[w].wlink = uint32(clauses)
clauses++
cmem[clauses].start = uint32(cells)

@ @<이항 제약 $(\bar x_j\lor\bar x_k)$을 만든다@>=
st := cells
mem[cells] = uint32(j + j + 3)   // $\bar x_j$
mem[cells+1] = uint32(k + k + 3) // $\bar x_k$
cells += 2
@<절 하나를 닫는다@>@;

@ @<겹치는 것을 걸러 적어도-하나 제약을 만든다@>=
mk := 0
for i := 0; i < 26; i++ {
	var bb uint64
	for k := 0; k < nvars; k++ {
		if (1<<i)&kbits[k] != 0 {
			bb += 1 << k
		}
	}
	@<|bb|를 |konstraint|에 넣되 포섭 관계를 정리한다@>@;
}
for j := 0; j < mk; j++ {
	@<|konstraint[j]|의 적어도-하나 제약을 만든다@>@;
}

@ 이미 있는 제약이 |bb|를 삼키면 |bb|는 버리고, |bb|가 이미 있는 것을 삼키면 그것을
지운다. 지운 자리는 맨 뒤의 것으로 메운다.

@<|bb|를 |konstraint|에 넣되 포섭 관계를 정리한다@>=
k := 0
for k < mk {
	if konstraint[k]&bb == konstraint[k] {
		break // |bb|가 삼켜진다
	}
	if konstraint[k]&bb == bb { // |bb|가 앞의 것을 삼킨다
		mk--
		konstraint[k] = konstraint[mk]
		continue
	}
	k++
}
if k == mk {
	konstraint[mk] = bb
	mk++
}

@ @<|konstraint[j]|의 적어도-하나 제약을 만든다@>=
st := cells
for k, bb := 0, uint64(1); bb != 0 && bb <= konstraint[j]; k, bb = k+1, bb<<1 {
	if bb&konstraint[j] != 0 {
		mem[cells] = uint32(k + k + 2) // $x_k$
		cells++
	}
}
@<절 하나를 닫는다@>@;

@ 류가 예순넷을 넘으면 비트 낱말이 모자라니 걸러 내기를 포기하고 글자마다 절을
하나씩 그냥 만든다. 크누스의 말대로, 그런 때는 좀 게을러도 괜찮다.

@<적어도-하나 제약을 우격다짐으로 만든다@>=
hardcases++
for i := 0; i < 26; i++ {
	st := cells
	for k := 0; k < nvars; k++ {
		if (1<<i)&kbits[k] != 0 {
			mem[cells] = uint32(k + k + 2) // $x_k$
			cells++
		}
	}
	@<절 하나를 닫는다@>@;
}

@* 되돌아가기.
이제 옛날 방식 그대로의 되돌아가기다. 층 |level|에서 변수 하나를 정하고, 그 값이
거짓으로 만드는 리터럴을 감시하던 절들을 모두 다른 리터럴로 옮겨 붙인다. 옮길 데가
없는 절이 나오면 그 절이 비어 버린 것이니 물러선다.

배열 |move[level]|에 어느 값을 먼저 시도했는지 적는다. 값이 $0$이면 참을 먼저, $1$이면 거짓을
먼저 시도한 것이고, 물러섰다가 반대쪽을 시도할 때는 $3-|move|$로 뒤집는다. 그래서
|move|가 짝수면 그 변수는 참이다.

@<되돌아가며 모든 해를 찾는다@>=
	var c, i, j, k, p, q, w uint32
	var level, parity int
	level = 1
newlevel:
	if level > vars {
		@<찾은 해를 갈무리한다@>@;
		goto backtrack
	}
	@<어느 쪽을 먼저 시도할지 고른다@>@;
tryit:
	parity = move[level] & 1
	w = uint32(level + level + 1 - parity)
	@<고르지 않은 쪽 목록의 절들을 옮겨 붙인다@>@;
	level++
	goto newlevel
tryagain:
	if move[level] < 2 {
		move[level] = 3 - move[level]
		goto tryit
	}
backtrack:
	if level > 1 {
		level--
		goto tryagain
	}

@ 거짓 쪽을 감시하는 절이 있거나 참 쪽을 감시하는 절이 없으면 거짓부터 시도한다.

@<어느 쪽을 먼저 시도할지 고른다@>=
if cmem[level+level+1].wlink != 0 || cmem[level+level].wlink == 0 {
	move[level] = 1
} else {
	move[level] = 0
}

@ 절 |c|에서 아직 거짓이 아닌 리터럴을 하나 찾아 감시자를 그리로 옮긴다. 첫 칸에
있던 감시자와 자리를 맞바꾸면 된다. 끝까지 찾지 못하면 절 |c|가 모순이다.

@<고르지 않은 쪽 목록의 절들을 옮겨 붙인다@>=
for c = cmem[w].wlink; c != 0; c = q {
	i, q, j = cmem[c].start, cmem[c].wlink, cmem[c+1].start
	for p = i + 1; p < j; p++ {
		k = mem[p]
		if k >= uint32(level+level) || (int(k)^move[k>>1])&1 == 0 {
			break
		}
	}
	if p == j { // 절 |c|가 비었다
		cmem[w].wlink = c
		goto tryagain
	}
	mem[i], mem[p] = k, w
	cmem[c].wlink, cmem[k].wlink = cmem[k].wlink, c
}
cmem[w].wlink = 0

@ 해를 찾으면 참인 변수들이 가리키는 류의 짝을 모두 적는다. 각 류의 원소는 |link|를
따라 한 바퀴 돌면 다 나온다. 목록의 끝은 $-1$로 막는데, 다음 류를 적기 시작하면
그 $-1$이 덮이고 맨 마지막 것만 남는다.

플러그를 하나도 꽂지 않은 플러그보드라면 짝이 스물여섯 개가 되어 $-1$ 자리가
모자란다. 원본은 스물여섯 칸만 잡아 두었는데, 여기서는 넉넉히 잡았다.

@<찾은 해를 갈무리한다@>=
jj := 0
for k := 1; k < level; k++ {
	if move[k]&1 != 0 {
		continue // $x_{k-1}$이 거짓이다
	}
	s := klass[k-1]
	plugs[sols][jj] = s
	jj++
	for pp := link[s]; pp != s; pp = link[pp] {
		plugs[sols][jj] = pp
		jj++
	}
	plugs[sols][jj] = -1
}
sols++
if sols > solsmax {
	if sols >= maxsols {
		fmt.Fprintln(os.Stderr, "SAT 해가 너무 많다!")
		os.Exit(1)
	}
	solsmax = sols
}
if cells > cellsmax {
	cellsmax = cells
}
if clauses > clausesmax {
	clausesmax = clauses
}

@ 다 풀고 나면 자취를 지워야 다음 일을 맡을 수 있다. 고리 |wlink|는 물론이고 |start|도
지워야 하는데, 프로그램이 |cmem[nonspec].start|가 $0$이라고 믿기 때문이다. 그리고
절이 아닌 |cmem[clauses]|까지 지워야 한다---크누스가 ``이런, 이것도''라고 두 번
덧붙인 자리다.

@<|cmem|을 지운다@>=
for c := 0; c <= clauses; c++ {
	cmem[c] = clauseRec{}
}

@* 시작 위치와 링 설정.
플러그보드를 찾았으니 이제 링 설정 차례다. 우리가 아는 것은 델타 경로와 그 경로가
끝나는 뿌리 위치 $(p_0,p_1,p_2)$, 그리고 크립이 놓인 자리 |prefix|다. 구할 것은
``어떤 시작 위치와 링 설정으로 기계를 맞추면 바로 그 시각에 바로 그 경로를 밟는가''다.

열쇠는 자리올림이 일어나는 시각이다. 빠른 회전자가 $25$번 자리에서 한 칸 더 돌면
가운데 것이 밀리고, 가운데 것이 $25$번 자리에서 돌면 셋이 함께 돈다---{\it 큰
자리올림\/}이다. 델타 경로의 모양이 그 시각을 말해 준다.

@<상수@>=
const maxsetups = 500

@ @<전역 변수@>=
var (
	startpos [maxsetups][3]int
	rings    [maxsetups][3]int
	start    [3]int
	now      [3]int
	root     [3]int
	prefix   int
	setups   int
)

@ 경로의 첫 성분이 $1$이면 크립을 찍는 동안 큰 자리올림이 있었다는 뜻이고, 그 시각이
정확히 언제인지도 알 수 있다. 가운데 성분만 $1$이면 작은 자리올림의 시각만 알고,
둘 다 $0$이면 크립을 찍는 동안 아무 자리올림도 없었다는 뜻이라 경우가 가장 많다.

@<있을 수 있는 설정을 모두 적는다@>=
setups, prefix = 0, kk
root[0], root[1], root[2] = p0, p1, p2
d := delta[pp].del
switch {
case d[0] != 0:
	@<쉬운 경우@>@;
case d[1] != 0:
	@<중간 경우@>@;
default:
	@<어려운 경우@>@;
}
if sols*setups > solsbysetupsmax {
	solsbysetupsmax = sols * setups
}

@ @<쉬운 경우@>=
if d[1] == 1 {
	outbig(prefix + 1)
} else {
	q := delta[pp].parent
	for delta[q].del[0] != 0 {
		q = delta[q].parent
	}
	outbig(prefix + 1 + delta[q].del[2])
}

@ @<중간 경우@>=
q := delta[pp].parent
for delta[q].del[1] != 0 {
	q = delta[q].parent
}
outmedium((prefix + 1 + delta[q].del[2]) % 26)

@ 남은 경우에는 크립을 찍는 동안 어떤 자리올림도 일어나지 않아야 한다. 그런 시각을
모두 훑는다.

@<어려운 경우@>=
for k := (prefix + plainsize) % 26; k != (prefix+1)%26; k = (k + 1) % 26 {
	outmedium(k)
}

@ 큰 자리올림이 |bigcarry|번째 글자에서 일어나도록 기계를 맞춘다. 느린 회전자의
시작 자리는 늘 \.A로 두어도 일반성을 잃지 않는다.

@<함수들@>=
func outbig(bigcarry int) {
	carry := (bigcarry - 1) % 26
	start[2] = 25 - carry
	start[1] = 24 - (bigcarry-1)/26
	if bigcarry <= prefix {
		now[0] = 1
	} else {
		now[0] = 0
	}
	now[2] = (start[2] + prefix + 1) % 26
	now[1] = start[1] + (start[2]+prefix+1)/26 - 25*now[0]
	@<이 설정을 목록에 적는다@>@;
}

@ @<이 설정을 목록에 적는다@>=
for i := 0; i < 3; i++ {
	startpos[setups][i] = start[i]
	rings[setups][i] = (now[i] + 26 - root[i]) % 26
}
setups++
if setups > setupsmax {
	if setups >= maxsetups {
		fmt.Fprintln(os.Stderr, "한 배치에 설정이 너무 많다!")
		os.Exit(1)
	}
	setupsmax = setups
}

@ 작은 자리올림은 |carry|번째 글자에서 일어나되 큰 자리올림은 (암호문이 $600$글자를
넘지 않는 한) 일어나지 않게 맞춘다. 그러고 나서, 크립을 건드리지 않는 시각마다 큰
자리올림을 하나씩 더 넣어 본다.

@<함수들@>=
func outmedium(carry int) {
	@<큰 자리올림 없이 작은 자리올림만 맞춘다@>@;
	for bigcarry := carry + 1; bigcarry < ciphersize; bigcarry += 26 {
		if bigcarry <= prefix || bigcarry > prefix+plainsize {
			outbig(bigcarry)
		}
	}
}

@ @<큰 자리올림 없이 작은 자리올림만 맞춘다@>=
start[2] = 25 - carry
start[1] = 0
now[2] = (start[2] + prefix + 1) % 26
now[1] = (start[2] + prefix + 1) / 26
now[0] = 0
@<이 설정을 목록에 적는다@>@;

@* 영어답기.
마지막 관문이다. 지금까지의 방법이 크립과 기계의 조건을 모두 만족하는 평문을
빠짐없이 길어 올리는데, 그것이 자그마치 $3{,}331{,}188$개다. 사람 눈으로 다 볼 수는
없다. 남은 단서는 하나, ``이 글은 영어다''뿐이다.

낱글자 빈도로는 어림도 없다. 그래서 크누스가 쓴 것이 {\it 다섯 글자 빈도\/}
(quingram)다. 모두 $26^5=11{,}881{,}376$가지인 다섯 글자 토막이 영어에 얼마나 자주 나오는지를
세어 두고, 후보 평문의 $121$개 토막의 빈도를 모두 더해 점수로 삼는다.

그런데 인터넷에 굴러다니는 $n$-gram 통계는 낱말 사이의 빈칸과 문장 부호를 그대로
세어 둔 것이라 우리에게 맞지 않다. 우리 암호문은 빈칸과 부호를 걷어낸 글이기
때문이다. 그래서 크누스는 {\it 자기 책\/}을 썼다. TAOCP 1권의 전자 원고에서 글자를
모두 대문자로 바꾸고 빈칸과 부호와 숫자와 수식과 프로그램을 걷어내어 백만 자에
조금 못 미치는 문자열 하나를 만들었으니, 그것이 그의 사이트에 있는 파일 \.{VOL1TEXT}다.
(보기를 들면 \.{CHAOS}, \.{ORDER}, \.{XYZZY}의 빈도가 각각 $0$, $739$, $0$이다.)

@ 크누스는 그 빈도를 \.{QUINGRAM-RATING}으로 미리 세어 $26^5$줄짜리 파일에 적어
두고 이 프로그램에서 읽어 들인다. 우리는 원문을 직접 읽어 그 자리에서 센다.
원문 $90$만 자를 한 번 훑는 일이라 눈 깜짝할 사이고, 24MB짜리 중간 파일이 사라진다.

표가 $26^5$칸이니 $32$비트 정수로 잡아도 $47.5$MB다. \GO/의 |int|는 $64$비트라
그대로 두면 $95$MB가 되므로 |int32|로 못 박았다.

@<상수@>=
const maxscore = 10000

@ @<전역 변수@>=
var (
	score     [26][26][26][26][26]int32
	bestscore int
	plntxt    [maxmc]int
	plugboard [26]int
	tally     [maxscore]int
)

@ 원문을 한 번 훑으며 창을 다섯 글자씩 미끄러뜨린다. 창의 값은 $26$진수 다섯 자리로
읽으면 되니, 맨 앞자리를 떼고 새 글자를 붙이는 일만 되풀이하면 된다.

@<원문을 읽어 다섯 글자 빈도를 센다@>=
text, err := os.ReadFile(corpusFile)
if err != nil {
	fmt.Fprintf(os.Stderr, "원문 파일을 열 수 없다: %v\n", err)
	os.Exit(1)
}
text = []byte(strings.Map(func(r rune) rune {
	if r >= 'A' && r <= 'Z' {
		return r
	}
	return -1
}, string(text)))
if len(text) < 5 {
	fmt.Fprintf(os.Stderr, "원문 %s에 대문자가 너무 적다!\n", corpusFile)
	os.Exit(1)
}
@<창을 미끄러뜨리며 센다@>@;
fmt.Fprintf(os.Stderr, "원문 %s에서 대문자 %d개를 읽었다.\n", corpusFile, len(text))

@ 창을 미끄러뜨리는 일은 맨 앞 글자를 버리고 새 글자를 뒤에 붙이는 것뿐이다.
첨자 다섯 개를 그대로 쓰므로 표를 하나로 펼 것도 없다.

@<창을 미끄러뜨리며 센다@>=
var w [5]int
for i := 0; i < 4; i++ {
	w[i+1] = int(text[i] - 'A')
}
for i := 4; i < len(text); i++ {
	w[0], w[1], w[2], w[3], w[4] = w[1], w[2], w[3], w[4], int(text[i]-'A')
	score[w[0]][w[1]][w[2]][w[3]][w[4]]++
}

@* 끝까지 밀어붙이기.
파이프라인의 끝이다. 설정 |i|와 플러그보드 |j|를 골라 기계를 맞추고, 저 수수께끼
같은 암호문을 그대로 밀어 넣어 본다. 숨을 죽이고, 손가락을 꼬고서.

@<플러그보드와 링 설정마다 평문을 살펴본다@>=
@<있을 수 있는 설정을 모두 적는다@>@;
for i := 0; i < setups; i++ {
	for j := 0; j < sols; j++ {
		@<설정 |i|와 해 |j|로 암호문을 풀어 본다@>@;
	}
}

@ @<설정 |i|와 해 |j|로 암호문을 풀어 본다@>=
count++
for k := 0; k < 3; k++ {
	pos[k] = startpos[i][k]
	off[k] = mod26[pos[k]+26-rings[i][k]]
}
@<|plugs[j]|로 플러그보드를 맞춘다@>@;
for k := 0; k < ciphersize; k++ {
	c := ciphertext[k]
	@<회전자를 돌린다@>@;
	c = plugboard[c]
	@<글자 |c|를 암호화한다@>@;
	plntxt[k] = plugboard[c]
}
@<크립이 제자리에 나왔는지 다시 확인한다@>@;
@<점수를 매기고 좋으면 찍는다@>@;

@ 고른 류들이 스물여섯 글자를 모두 덮으므로 플러그보드는 매번 통째로 다시 쓰인다.

@<|plugs[j]|로 플러그보드를 맞춘다@>=
for k := 0; plugs[j][k] >= 0; k++ {
	nm := name[plugs[j][k]]
	u, v := int(nm[0]-'A'), int(nm[1]-'A')
	plugboard[u], plugboard[v] = v, u
}

@ 스스로를 못 믿는 것이 아니라, 여태 세운 논리가 정말 맞는지 보는 것이다. 이 줄이
한 번이라도 울린다면 어딘가 크게 틀린 것이다.

@<크립이 제자리에 나왔는지 다시 확인한다@>=
for k := 0; k < plainsize; k++ {
	if plntxt[k+prefix] != plaintext[k] {
		fmt.Fprintln(os.Stderr, "이런, 내가 뭔가 잘못했다.")
	}
}

@ 점수는 $121$개 토막의 빈도를 더한 것이다. 여태까지의 최고와 같거나 그보다 나으면
찍는다. 크누스는 $6000$점이 넘어도 찍게 해 두었는데, 그래야 상위 후보들을 놓치지
않기 때문이다.

@<점수를 매기고 좋으면 찍는다@>=
s := 0
for k := 4; k < ciphersize; k++ {
	s += int(score[plntxt[k-4]][plntxt[k-3]][plntxt[k-2]][plntxt[k-1]][plntxt[k]])
}
if s < maxscore {
	tally[s]++
}
if s >= bestscore || s >= 6000 {
	@<이 후보를 찍는다@>@;
	bestscore = s
}
if count%250000 == 0 {
	fmt.Fprintf(os.Stderr, "... 여기까지 평문 %d개, %s %s %s %c%c%c\n", count,
		rotorName[r0], rotorName[r1], rotorName[r2], p0+'A', p1+'A', p2+'A')
}

@ @<이 후보를 찍는다@>=
var b strings.Builder
for k := 0; k < ciphersize; k++ {
	b.WriteByte(byte('A' + plntxt[k]))
}
fmt.Fprintf(&b, " %s %s %s %c%c%c %c%c%c", rotorName[r0], rotorName[r1], rotorName[r2],
	startpos[i][0]+'A', startpos[i][1]+'A', startpos[i][2]+'A',
	rings[i][0]+'A', rings[i][1]+'A', rings[i][2]+'A')
for k := 0; plugs[j][k] >= 0; k++ {
	if nm := name[plugs[j][k]]; nm[0] != nm[1] {
		b.WriteByte(' ')
		b.WriteString(nm)
	}
}
fmt.Fprintf(&b, " (%c%c%c) %6d %d", p0+'A', p1+'A', p2+'A', s, count)
fmt.Println(b.String())

@* 셈하기.
마지막으로 점수 분포와 이런저런 최고 기록을 알린다. 크누스가 이 프로그램을 어디까지
빠듯하게 몰아붙였는지가 이 숫자들에 남는다.

@<전역 변수@>=
var (
	count                                  int
	cases, fails, hardcases, hardfails     int
	varsmax, clausesmax, cellsmax          int
	solsmax, setupsmax, solsbysetupsmax    int
)

@ @<셈한 것을 알린다@>=
for s := 0; s < maxscore; s++ {
	if tally[s] != 0 {
		fmt.Printf("%10d:%10d\n", s, tally[s])
	}
}
fmt.Fprintf(os.Stderr, "모두 해서 평문 %d개를 들여다보았다.\n", count)
fmt.Fprintf(os.Stderr, " %d/%d 경우에 해가 없었고, 그중 어려운 것은 %d/%d다.\n",
	fails, cases, hardfails, hardcases)
fmt.Fprintf(os.Stderr, "최대 변수 %d개, 절 %d개, 칸 %d개,\n", varsmax, clausesmax, cellsmax)
fmt.Fprintf(os.Stderr, " 최대 해 %d개, 설정 %d개, 해 곱하기 설정 %d개.\n",
	solsmax, setupsmax, solsbysetupsmax)

@ 남은 것은 |main|이 쓰는 지역 변수뿐이다. 여섯 겹 고리의 첨자들과, 이름 있는 절
여기저기서 함께 쓰는 몇 개다.

@<지역 변수@>=
var r0, r1, r2, p0, p1, p2, k, jj, kk, pp int

@* 돌려 보기.
쓰는 법은 이렇다. 크립과 암호문을 명령줄로 주고, 다섯 글자 빈도를 뜰 원문 파일을
셋째 인자로 준다.
$$\vbox{\halign{\.{#}\hfil\cr
enigmatic-puzzle ENIGMATICALLY WMGQR...QAEGI VOL1TEXT\cr}}$$
원문 \.{VOL1TEXT}은 크누스의 사이트에 있다. TAOCP 1권의 본문에서 빈칸과 부호와
숫자와 수식을 걷어내고 대문자로 바꾼 $90$만 자짜리 문자열이다.
$$\vbox{\halign{\.{#}\hfil\cr
curl -O https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/VOL1TEXT\cr}}$$
내 노트북에서 CPU 시간으로 $2$시간 $4$분이 걸렸다. 크누스의 \CEE/ 원본을 같은
기계에서 돌린 것과 견주면 찍히는 줄이 이천사십 개 모두 한 글자도 다르지 않다.

@ 걸러지는 모습이 볼만하다. 시작할 때 따져야 할 시나리오는 크립을 놓을 자리
$113$곳 가운데 반사판 규칙으로 살아남은 $63$곳에, 로터 고르기 $60$가지와 회전량
$26^3$가지와 델타 경로 $25$가지를 곱한 $1{,}660{,}932{,}000$가지다. 봄베와 거대류
거르개가 이것을 $110{,}860$가지로 줄인다---$15000$배다. 그 가운데 $15{,}392$가지는
SAT가 풀지 못해 버려지고, 남은 것들에서 후보 평문 $3{,}331{,}188$개가 나온다.

그 삼백만 개 가운데 $2000$점을 넘는 것이 $867$개, $6000$점을 넘는 것이 아홉 개뿐이다.
그리고 일등과 이등이 $8000$점과 $7062$점으로 시원하게 갈린다. 다섯 글자 빈도라는
잣대가 이 문제에서 놀랍도록 잘 듣는다.

@ 일등이 내놓은 평문이 이것이다.
$$\vbox{\halign{\.{#}\hfil\cr
PHILO SOPHE RSWHE NTHEY WROTE ANYTH INGTO OEXCE LLENT FORTH EVULG ARTOK\cr
NOWEX PRESS EDITE NIGMA TICAL LYTHA TTHES ONSOF ARTON LYMIG HTUND ERSTA NDITX\cr}}$$
빈칸을 도로 넣으면 이렇다.

\smallskip
{\narrower\noindent {\it Philosophers when they wrote any thing too excellent
for the vulgar to know, expressed it enigmatically, that the sons of Art only
might understand it.\/}
\smallskip
\hfill---John French, {\it The Art of Distillation\/} (1653)\par}
\smallskip

\noindent 연금술을 다룬 1653년 책에서 따온 구절이다. 크립 \.{ENIGMATICALLY}는
$74$번째 자리에 앉아 있었고, 마지막 \.X는 마침표를 옮겨 적은 것이다. 1651년 초판에는
``sonnes of Art''라고 적혀 있었다는데, 철자는 곧 요즘 것으로 다듬어졌다고 한다.

@ 튜링과 Welchman의 봄베가 1940년에 하던 일을, 지금은 노트북 한 대가 두 시간이면
해낸다. 그때 블레츨리 파크에는 봄베가 수십 대 늘어서서 밤낮으로 돌았고, 그 소리가
``수천 개의 뜨개바늘 소리 같았다''고 그곳에서 일한 사람들이 적었다. 우리 프로그램이
백만 가지 바퀴 배치를 훑는 동안 팬이 도는 소리가 그 메아리쯤 될지도 모르겠다.

그 시절 그들에게는 우리에게 있는 것이 없었다. 무엇보다도, 답을 이미 아는 채로
프로그램을 짜 보는 호사가 없었다.

@* 색인.
