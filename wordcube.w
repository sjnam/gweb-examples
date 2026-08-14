\input kotexgweb
\input luamplib.sty

% 그림은 wordcube.mp 안에 fig_... 라는 이름의 매크로로 있다. 여기서 한 번 읽어
% 두고 그림 자리마다 이름만 부른다.
\everymplib{input wordcube;}

\def\title{대칭 단어 정육면체}

% 그림 설명. \centerline과 달리 길면 여러 줄로 접힌다.
\def\figcap#1{\smallskip{\narrower\noindent #1\par}\medskip}

@* 들어가며.
가로줄도 낱말, 세로줄도 낱말인 글자 격자를 {\it 단어 정사각형\/}(word square)이라
부른다. 여기에 차원을 하나 더 얹은 것이 이 글의 주인공, {\it 단어 정육면체\/}다.
$5\times5\times5$ 격자의 $125$칸을 글자로 채우되, 세 축 가운데 어느 방향으로 다섯
칸을 읽어도 사전에 있는 다섯 글자 낱말이 나오게 만든다. 재료는 Knuth의 스탠퍼드
그래프베이스(Stanford GraphBase)에 실린 다섯 글자 낱말 $5757$개(\.{sgb-words.txt})다.

게다가 {\it 대칭\/}이라는 조건을 건다. 칸 $(i,j,k)$의 글자가 세 첨자를 어떻게
뒤섞어도 같다는 뜻이다.
$$ a_{ijk}=a_{ikj}=a_{jik}=a_{jki}=a_{kij}=a_{kji}.$$
그러면 축을 맞바꿔도
정육면체가 그대로이므로, 세 방향의 낱말들이 실은 한 벌이다. 말보다 그림이다. 아래는
그런 정육면체 하나를, 셋째 축을 읽기 방향으로 삼아 $(i,j)$칸마다 낱말 $a_{ij\ast}$를
적어 펼친 것이다.
$$
\mplibcode
fig_square;
\endmplibcode
$$
\figcap{{\bf 그림 1}: 대칭 단어 정육면체 하나를 $5\times5$ 낱말 표로 편 모습. $(i,j)$칸은
낱말 $a_{ij\ast}$이다. 대칭이라 표는 대칭 행렬이고(음영은 대각 낱말), 어느 행을
읽든 그 전치인 열을 읽든---나아가 이 정사각형을 밑면으로 쌓아 올린 기둥을 읽든---같은
낱말들이 나온다.}

\noindent
대칭 덕분에 이 표는 대칭 행렬이다: $(i,j)$칸과 $(j,i)$칸이 같은 낱말이다. 그뿐
아니라 한 겹 더 깊은 대칭이 숨어 있다. $(i,j)$낱말의 $k$번째 글자는 $(i,k)$낱말의
$j$번째 글자와 같다. 그림에서 \.{adopt}$(a_{12\ast})$의 넷째 글자 \.{p}는
\.{leper}$(a_{13\ast})$의 셋째 글자와 같고, \.{opera}$(a_{23\ast})$의 끝 글자 \.{a}는
\.{strap}$(a_{24\ast})$의 넷째, \.{erase}$(a_{34\ast})$의 셋째 글자와 같다. 이 겹겹의
맞물림이 정육면체를 몹시 빠듯하게 죈다.

@ 표는 표일 뿐이니 실물도 한번 보자. {\bf 그림 1}의 낱말들을 글자로 풀어 $125$칸에 채워
넣으면 아래와 같다. 겉으로 드러나는 세 면에만 글자를 적었는데, 세 면이 저마다 낱말
다섯 개로 짜인 단어 정사각형이고, 게다가 셋 다 같은 것이다---\.{reset}, \.{extra},
\.{strap}, \.{erase}, \.{taper}, 곧 그림 1의 마지막 줄에 있는 낱말들이다. 보이는 면이
$i=4$, $j=4$, $k=4$ 세 장이니 그럴 수밖에 없다. 축을 맞바꿔도 정육면체가 그대로라는
말이 이렇게 눈에 보인다. 속으로 뻗은 낱말은 겉에서 보이지 않으므로, 하나를 글자
다섯 개로 떼어 통째로 뽑아냈다.
$$
\mplibcode
fig_cube;
\endmplibcode
$$
\figcap{{\bf 그림 2}: 같은 정육면체를 등각 투영으로 본 모습. 오른쪽 면에서 파란 줄은
아래에서 위로 읽어 \.{extra}이고, 초록 줄은 오른쪽 위에서 왼쪽 아래로 읽어
\.{strap}이다. 둘이 만나는 칸을 비우고, 그 자리에서 속으로 뻗은 셋째 방향의 낱말
\.{adopt}$(a_{12\ast})$를 글자 하나씩 떼어 오른쪽으로 뽑아냈다. 빈칸에 있던 글자
\.{t}는 \.{adopt}의 마지막 글자이면서 \.{extra}의 셋째 글자이고 \.{strap}의 둘째 글자다.
칸 하나가 낱말 셋에 한꺼번에 매여 있는 것이다.}

@ 이 프로그램이 답하는 질문은 하나다: {\it 이런 정육면체를 몇 개나 만들 수 있는가?\/}
미리 답을 말하면 $83{,}576$개다. 그 가운데, {\bf 그림 1}처럼 열다섯 줄이 {\it 모두 서로
다른\/} 낱말인 것만 세면 $75{,}130$개로 줄어든다. 답에 이르는 백트래킹은 놀랄 만큼
단순한데, 거기에 {\it 선행 배제\/}(preclusion)라는 전방 검사를 곁들여 탐색 나무를
크게 줄인다(「선행 배제」 장).

한 가지 짚고 넘어가자. 정사각형이나 정육면체를 세다 보면 으레 ``회전$\cdot$반사로
겹치는 것은 하나로''라며 대칭군으로 나누고 싶어진다. 여기서는 그럴 것이 없다. 다섯
좌표의 라벨을 순열 $p$로 바꾸면 읽는 방향인 셋째 축까지 함께 섞여 낱말의 {\it 글자
순서\/}가 헝클어진다---위치 $0$과 $1$을 맞바꾸면 대각 낱말 \.{codex}가 \.{ocdex}로 읽혀
사전에서 사라진다. 그러니 라벨 재배열은 이 문제의 대칭이 {\it 아니고,\/} 유효한
정육면체는 저마다 딱 한 번씩 세어진다. $83{,}576$은 있는 그대로의 개수다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
)

const (
	n     = 5           // 정육면체 한 변, 곧 낱말 길이
	lines = n * (n + 1) / 2 // 채울 낱말의 수, 15
)

@<전역 변수@>
@<함수들@>

func main() {
	@<명령줄을 처리한다@>
	@<단어를 읽어 정렬한다@>
	@<채우는 순서를 만든다@>
	@<배제 표를 미리 계산한다@>
	@<탐색하여 센다@>
	@<결과를 보고한다@>
}

@* 대칭과 채우는 순서.
대칭 정육면체는 첨자를 정렬한 $i\le j\le k$짜리 칸, 곧 크기 $3$짜리 다중집합
${5+2\choose3}=35$개만 독립이다. 하지만 프로그램은 굳이 그 압축된 표현을 쓰지 않고
$5\times5\times5$ 배열 |cube| 하나에 대칭인 자리를 모두 함께 적어 둔다. 그러면 낱말
$a_{ij\ast}$를 |cube[i][j][0..4]|로 곧장 읽을 수 있다. 다중집합 하나에 글자를 놓을
때마다 대칭인 여섯 자리에 똑같이 적어 두기만 하면 이 성질이 유지된다(놓는 코드는
백트래킹에서 나온다).

낱말은 $i\le j$인 짝 $(i,j)$마다 하나씩 모두 $15$개다. 이들을 {\it 행 우선\/}으로,
곧
$$(0,0),(0,1),(0,2),(0,3),(0,4),(1,1),(1,2),\ldots,(4,4)$$
순서로 하나씩 놓는다. 이 순서의 열쇠는 다음 사실이다.

\smallskip
{\narrower\noindent{\bf 채우기 불변식.} $(i,j)$낱말을 놓을 차례가 되면, 그 낱말의
앞 $j$글자(위치 $0,\ldots,j-1$)는 이미 정해져 있고, 뒤 $n-j$글자(위치 $j,\ldots,n-1$)는
아직 어느 칸에도 놓인 적 없는 새 글자다.\par}
\smallskip\noindent
왜 그런가. $(i,j)$낱말의 위치 $c$는 다중집합 $\{i,j,c\}$다. 이 칸은 자신을 이루는
어떤 짝이 앞서 놓였다면 그때 이미 정해진다.
\smallskip
\item{$\bullet$} $c<j$이면 짝 $\{i,c\}$가 앞선 행이나 같은 행의 왼쪽에서 이미 놓였으므로 정해져 있다.
\item{$\bullet$} $c=j$이면 이 칸을 처음 건드리는 낱말이 바로 지금 $(i,j)$다.
\item{$\bullet$} $c>j$이면 짝 $\{i,c\}$도 $\{j,c\}$도 아직 나중 차례라, 이 칸 역시 지금 처음 놓인다.
\smallskip
따라서 놓기는 이렇게 된다. 이미 정해진 앞 $j$글자를 {\it 접두사\/}로 삼아 사전에서
그 접두사로 시작하는 낱말을 모두 찾고, 그 각각에 대해 나머지 $n-j$글자를 새로 적은
뒤 다음 낱말로 내려간다. 접두사가 맞으면 앞 글자들은 저절로 아귀가 맞으니, 백트래킹
도중에 글자끼리 어긋나는지 따로 검사할 일이 아예 없다---{\it 접두사 일치가 모든
제약을 대신한다.\/}

@<채우는 순서를 만든다@>=
	t := 0
	for i := 0; i < n; i++ {
		for j := i; j < n; j++ {
			order[t] = [2]int{i, j}
			t++
		}
	}

@ 탐색이 쓰는 상태는 정육면체 |cube|와 지금까지 고른 낱말 번호 |chosen|, 그리고 세어
본 것들이다. 이들을 |worker| 하나에 묶는다---한 일꾼이 저마다 이것을 들고 서로 독립인
탐색을 하도록. 지금 본론은 일꾼 하나로 차례차례 세지만, 이 묶음 덕에 딸린 변경 파일
\.{wordcube-par.ch}가 여럿을 병렬로 돌릴 수 있다. 전역에는 낱말 목록과 채우는 순서, 그리고
합계만 둔다.

@<전역 변수@>=
type worker struct {
	cube     [n][n][n]byte // 대칭으로 유지되는 글자 정육면체
	chosen   [lines]int    // 각 층에서 고른 낱말의 번호
	count    int64         // 이 일꾼이 찾은 정육면체의 수
	distinct int64         // 그중 열다섯 낱말이 모두 다른 것
	nodes    int64         // 밟은 탐색 나무의 노드 수
	profile  [lines + 1]int64
}

var (
	words    []string      // 정렬된 다섯 글자 낱말
	order    [lines][2]int // 낱말을 놓는 순서
	wordFile string
	count    int64          // 정육면체 총수(합계)
	distinct int64          // 서로 다른 것의 총수(합계)
	nodes    int64          // 노드 총수(합계)
	profile  [lines + 1]int64
)

@* 사전 다루기.
낱말 파일은 한 줄에 한 낱말씩이다. 다섯 글자짜리만 골라 |words|에 담고 정렬한다---접두사로
낱말을 찾으려면 정렬이 있어야 이진 탐색이 먹힌다. 파일을 열지 못하면 곧바로 접는다.

@<단어를 읽어 정렬한다@>=
	f, err := os.Open(wordFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		if s := sc.Text(); len(s) == n {
			words = append(words, s)
		}
	}
	f.Close()
	sort.Strings(words)
	if err := sc.Err(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

@ 접두사로 낱말을 찾는 일이 탐색의 안쪽 고리다. 그 뼈대는 낱말의 앞 몇 글자만
접두사와 견주는 이 함수 하나뿐이다. 접두사에 맞는 구간이나 존재 여부는 쓰이는
곳(탐색과 배제)에서 이 함수를 발판 삼아 이진 탐색으로 바로 잡는다.

@<함수들@>=
func cmpPrefix(w string, pre []byte) int {
	for k := 0; k < len(pre); k++ {
		if w[k] != pre[k] {
			if w[k] < pre[k] {
				return -1
			}
			return 1
		}
	}
	return 0
}

@* 백트래킹.
탐색의 독립 단위는 대각 낱말 $a_{00\ast}$ 하나를 고르는 일이다. |searchFrom(w)|은 그것을
|words[w]|로 정해---곧 정육면체의 주대각선을 깔고---나머지 열넷을 |solve|로 채운다.
다만 주대각선을 깐 직후에도 |feasible|로 한 번 거른다: 그 다섯 글자만으로 벌써 어떤
줄이 완성 불가능이면 열넷을 헤집을 것 없이 바로 접는다(선행 배제, 뒤에서). 서로 다른
|w|의 탐색은 완전히 독립이라, 이 함수가 병렬화의 이음매도 된다.

@<함수들@>=
func (wk *worker) searchFrom(w int) {
	s := words[w]
	for c := 0; c < n; c++ {
		wk.put(0, 0, c, s[c])
	}
	wk.chosen[0] = w
	if wk.feasible(0) {
		wk.solve(1)
	}
}

@ 이제 심장이다. |solve(t)|는 |order|의 $t$번째 낱말을 놓는다. $t$가 $15$에 이르면
정육면체 하나가 온전히 채워진 것이니 한 개를 세고 돌아온다. 그렇지 않으면 채우기
불변식대로, 접두사를 읽어 후보 낱말을 훑는다.

@<함수들@>=
func (wk *worker) solve(t int) {
	wk.nodes++
	wk.profile[t]++
	if t == lines {
		wk.count++
		@<열다섯 낱말이 모두 다르면 |distinct|를 늘린다@>@;
		return
	}
	i, j := order[t][0], order[t][1]
	@<접두사를 읽어 후보 낱말을 훑는다@>@;
}

@ 접두사는 |cube[i][j]|의 앞 $j$글자다(불변식이 이미 채워져 있음을 보장한다).
그 접두사로 시작하는 낱말마다 한 번씩 내려간다. 같은 낱말이 다른 줄에 다시 쓰이는
것도 일단 허용한다---나중에 잎에서 가려낸다.

@<접두사를 읽어 후보 낱말을 훑는다@>=
	var pre [n]byte
	for c := 0; c < j; c++ {
		pre[c] = wk.cube[i][j][c]
	}
	@<접두사에 맞는 낱말 구간 |lo..hi|를 잡는다@>@;
	for w := lo; w < hi; w++ {
		@<이 낱말을 놓고 한 겹 내려갔다 되돌린다@>@;
	}

@ 정렬된 목록에서 접두사 |pre[:j]|로 시작하는 낱말들이 놓인 구간 |[lo,hi)|를 두 번의
이진 탐색으로 잡는다. 앞 탐색은 접두사에 든 첫 낱말을, 뒤 탐색은 접두사를 벗어나는 첫
낱말을 가리킨다.

@<접두사에 맞는 낱말 구간 |lo..hi|를 잡는다@>=
	p := pre[:j]
	lo := sort.Search(len(words), func(k int) bool { return cmpPrefix(words[k], p) >= 0 })
	hi := lo + sort.Search(len(words)-lo, func(k int) bool { return cmpPrefix(words[lo+k], p) > 0 })

@ 놓는 것은 뒤 $n-j$글자를 새로 적는 일뿐이다. 앞 $j$글자는 접두사로 맞춰 두었으니
건드리지 않는다. 고른 낱말의 번호는 |chosen[t]|에 적어 둔다. 내려가기 전에 |feasible|로
남은 낱말들의 가망을 미리 확인해서(선행 배제), 통과할 때만 한 겹 판다. 되돌릴 때 대칭
자리들은 다음 후보가 어차피 덮어쓰므로 따로 지울 필요가 없다.

@<이 낱말을 놓고 한 겹 내려갔다 되돌린다@>=
	s := words[w]
	for c := j; c < n; c++ {
		wk.put(i, j, c, s[c])
	}
	wk.chosen[t] = w
	if wk.feasible(t) {
		wk.solve(t + 1)
	}

@ 다중집합 $\{i,j,c\}$에 글자를 놓는다는 것은, 세 첨자를 뒤섞은 여섯 자리에 같은
글자를 적는 일이다. 이렇게 해 두면 |cube|는 늘 완전 대칭을 유지한다.

@<함수들@>=
func (wk *worker) put(a, b, c int, ch byte) {
	wk.cube[a][b][c] = ch
	wk.cube[a][c][b] = ch
	wk.cube[b][a][c] = ch
	wk.cube[b][c][a] = ch
	wk.cube[c][a][b] = ch
	wk.cube[c][b][a] = ch
}

@ 열다섯 층에서 고른 낱말 번호가 모두 다른지 |chosen|에서 확인한다. 잎에서만, 그것도
$83{,}576$번만 도므로 이 겹루프는 공짜나 다름없다.

@<열다섯 낱말이 모두 다르면 |distinct|를 늘린다@>=
	dup := false
	for a := 0; a < lines && !dup; a++ {
		for b := a + 1; b < lines; b++ {
			if wk.chosen[a] == wk.chosen[b] {
				dup = true
				break
			}
		}
	}
	if !dup {
		wk.distinct++
	}

@* 선행 배제.
지금까지의 백트래킹은 {\it 시간순\/}(chronological)이다: 낱말을 놓다가 어떤 낱말의
접두사에 맞는 사전 항목이 하나도 없으면 그제야 되돌아간다. 막다른 길에 {\it
도착해서야\/} 무르는 셈이다. 그런데 낱말 하나를 놓으면 그 글자들이 아직 안 놓은 여러
낱말의 접두사 칸을 미리 못 박는다. 그러니 놓는 {\it 즉시\/} ``아직 안 놓은 낱말들이
저마다 사전에서 완성될 수 있는가''를 물어, 한 곳이라도 완성 불가능하면 그 서브트리를
통째로 잘라 낼 수 있다. 이 전방 검사를 {\it 선행 배제\/}(preclusion)라 부른다. 막다른
길을 몇 층 위에서 미리 쳐 내니, 밟는 노드가 $46$억에서 $9800$만으로 $47$배 줄고 순차
실행이 $6$분에서 $1$분 반으로 준다---개수는 물론 그대로다.

@ 검사를 빠르게 하려면 준비가 필요하다. 미래 낱말 $(i_u,j_u)$의 위치 $c$는 다중집합
$\{i_u,j_u,c\}$인데, 이 칸은 짝 $\{i_u,c\}$와 $\{j_u,c\}$ 가운데 {\it 먼저\/} 놓이는
낱말이 정한다. 그 ``먼저''가 몇 번째 층인지를 |knownTime[u][c]|에 미리 담아 둔다(짝의
놓는 차례는 |pairIdx|). 그러면 층 $t$에서 낱말 $u$의 {\it 이미 정해진 앞 글자 수\/}는
|knownTime[u][c]<=t|가 이어지는 앞자리의 개수일 뿐이다.

@<배제 표를 미리 계산한다@>=
	for u := 0; u < lines; u++ {
		pairIdx[order[u][0]][order[u][1]] = u
		pairIdx[order[u][1]][order[u][0]] = u
	}
	for u := 0; u < lines; u++ {
		iu, ju := order[u][0], order[u][1]
		for c := 0; c < n; c++ {
			knownTime[u][c] = pairIdx[iu][c]
			if pairIdx[ju][c] < knownTime[u][c] {
				knownTime[u][c] = pairIdx[ju][c]
			}
		}
	}

@ 이 표들은 탐색 내내 읽기만 하므로 전역에 둔다. 여러 일꾼이 병렬로 돌 때도 함께
읽기만 하니 안전하다.

@<전역 변수@>=
var (
	pairIdx   [n][n]int      // 짝 $(a,b)$가 놓이는 차례
	knownTime [lines][n]int  // 낱말 |u|의 위치 |c|가 정해지는 층
)

@ 이제 배제 검사 자체다. 층 $t$에서 낱말 하나를 놓은 직후, 아직 안 놓은 낱말
$u=t+1,\ldots,14$마다 이미 정해진 앞 글자(길이 $L$)를 접두사로 삼아, 사전에 그것으로
시작하는 낱말이 하나라도 있는지 본다. 없으면 이 배치는 가망이 없으니 |false|를 돌려
가지를 접게 한다. 완성 {\it 가능성\/}만 보면 되므로 중복이든 아니든 상관없고, 존재
여부는 이진 탐색 한 번---하계 |k|가 접두사와 맞는지---으로 족하다.

@<함수들@>=
func (wk *worker) feasible(t int) bool {
	for u := t + 1; u < lines; u++ {
		iu, ju := order[u][0], order[u][1]
		L := 0
		for L < n && knownTime[u][L] <= t {
			L++
		}
		pre := wk.cube[iu][ju][:L]
		k := sort.Search(len(words), func(m int) bool { return cmpPrefix(words[m], pre) >= 0 })
		if k == len(words) || cmpPrefix(words[k], pre) != 0 {
			return false
		}
	}
	return true
}

@* 세어 보고하기.
본론은 일꾼 하나로 모든 시작 낱말을 차례로 훑는다. 다 훑으면 그 일꾼의 셈이 곧
합계다. 탐색이 몇 분씩 걸리는데 답은 끝에만 나오므로, 시작 낱말이 몇 개나
처리됐는지를 표준 오류로 흘려 살아 있음을 알린다---\.{\\r}로 같은 줄을 계속 덮어쓴다.
(병렬 판은 이 한 절을 여러 일꾼으로 바꿔치기하는데, 그 이야기는 딸린 변경 파일에서
한다.)

@<탐색하여 센다@>=
	var wk worker
	for w := 0; w < len(words); w++ {
		wk.searchFrom(w)
		fmt.Fprintf(os.Stderr, "\r진행: 시작 낱말 %d/%d, 노드 %d ", w+1, len(words), wk.nodes)
	}
	fmt.Fprintln(os.Stderr)
	count, distinct, nodes, profile = wk.count, wk.distinct, wk.nodes, wk.profile

@ 명령줄 인자로 낱말 파일을 받되, 없으면 \.{sgb-words.txt}를 쓴다.

@<명령줄을 처리한다@>=
	wordFile = "sgb-words.txt"
	if len(os.Args) >= 2 {
		wordFile = os.Args[1]
	}

@ 다 세었으면 두 가지 개수와 밟은 노드 수를, 이어서 층별 두께를 알린다. 층별 두께는
탐색이 어디서 굵어지는지 보여 준다: 행 $0$을 다 채운 상태(|profile[5]|)가 곧 SGB
다섯 글자 낱말로 만드는 대칭 $5\times5$ 단어 정사각형의 수인데, 선행 배제가 없다면
$541{,}968$개나 된다. 그중 극히 일부만 정육면체로 자라 오른다.

@<결과를 보고한다@>=
	fmt.Printf("대칭 단어 정육면체는 모두 %d개다", count)
	fmt.Printf(" (그중 열다섯 낱말이 모두 다른 것은 %d개, 노드 %d개).\n", distinct, nodes)
	fmt.Fprint(os.Stderr, "층별 노드:")
	for t := 1; t <= lines; t++ {
		fmt.Fprintf(os.Stderr, " %d", profile[t])
	}
	fmt.Fprintln(os.Stderr)

@* 색인.
