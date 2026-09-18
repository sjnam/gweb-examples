\input kotexgweb
@i types.w
\datethis

\def\title{우아한 이름표}

@* 들어가며.
이 프로그램은 주어진 그래프의 {\it 우아한 이름표\/}(graceful labeling)를 모두
찾는 실험적인 프로그램이다. 변이 $m$개인 그래프의 꼭짓점들에 $\{0,1,\ldots,m\}$에서
서로 다른 수를 붙이되, 변마다 두 끝 이름표의 차를 그 변의 이름표로 삼았을 때 변
이름표가 꼭 $1$부터 $m$까지 하나씩 나오게 하는 것이다. 이를테면 길이 3인 경로
$a-b-c-d$에 $0,3,1,2$를 붙이면 변 이름표가 $3,2,1$이 되어 우아하다. 모든 나무가
우아하다는 ``우아한 나무 추측''은 오래된 미해결 문제다.

원한다면 명령줄에 \.{VERTEX=label} 꼴로 꼭짓점 이름표 일부를 미리 줄 수 있다.

미리 준 것이 없으면 해가 ``표준형''이어야 한다. 곧 이름표 |m-1|인 변의 두 꼭짓점이
0과~|m-1|이 아니라 1과~|m|이어야 한다. (이렇게 하면 일이 절반으로 준다. 미리 준
것이 없는 우아한 이름표는 이름표 |l|을 모두 |m-l|로 바꾸어 ``뒤집을'' 수 있기
때문이다.)

크누스는 안쪽 반복문을 빠르게 하려고 Tom Rokicki의 생각 몇 가지와 자신의 별난
생각인 `|labunlab|'과 `|vertunlab|'을 함께 썼다고 했다.
@^Rokicki, Tomas Gerhard@>

이 프로그램은 {\mc BACK-GRACEFUL-ROOTED}를 바탕으로 한다. 그 프로그램은 우아한
이름표의 일부만 찾지만 훨씬 빠르다.

@ 이것은 크누스의 \.{CWEB} 프로그램
\pdfURL{\.{back-graceful.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/back-graceful.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Sun, 09 Nov 2025 13:09:34 GMT}다.

그래프는 Stanford GraphBase(\.{SGB}) 형식의 파일로 읽어 들인다. 그 일은
\pdfURL{go-sgb}{https://github.com/sjnam/go-sgb}의 |gbsave.RestoreGraph|가 해 준다.

원본은 \.{gcc}가 주는 |__builtin_popcountll|을 쓰고, 컴파일할 때 \.{-march=native}를
주라고 당부한다. \GO/에서는 |bits.OnesCount64|가 같은 일을 하고, 컴파일러가
알아서 기계의 비트 세기 명령으로 바꾼다.

옮기다가 결함 셋을 만났다. 모두 고쳤고, 이야기는 맨 뒤에 적었다.

@ 프로그램의 얼개는 이렇다. 꼭짓점은 64개까지, 변은 63개까지 받는다. 변 이름표를
64비트 낱말 하나의 비트로 나타내기 때문이다. (크누스는 비트맵을 두 배로 늘리면
127까지 갈 수 있다고 적었다.)

@c
package main

import (
	"fmt"
	"math/bits"
	"os"
	"strings"

	"github.com/sjnam/go-sgb/gbgraph"
	"github.com/sjnam/go-sgb/gbsave"
)

const (
	maxn = 64 // 꼭짓점은 많아야 이만큼
	maxm = 63 // 변은 많아야 이만큼
)

@<전역 변수@>
@<함수들@>

func main() {
	var i, j, k, l, m, n, p, q, r, t, vv, ll, carry int
	var forced bool
	var ebits, rebits, vbits, del, bad uint64
	var g *gbgraph.Graph
	@<명령줄을 처리하고, 미리 준 이름표를 |prespec|에 둔다@>
	@<문제를 푼다@>
	@<작별 인사를 한다@>
}

@ @<명령줄을 처리하고, 미리 준 이름표를 |prespec|에 둔다@>=
if len(os.Args) < 2 {
	fmt.Fprintf(os.Stderr, "사용법: %s foo.gb [VERTEX=label...]\n", os.Args[0])
	os.Exit(-1)
}
var err error
if g, err = gbsave.RestoreGraph(os.Args[1]); err != nil {
	fmt.Fprintf(os.Stderr, "그래프 %s를 되살릴 수 없다: %v!\n", os.Args[1], err)
	os.Exit(-2)
}
m, n = int(g.M)/2, int(g.N)
if m > maxm {
	fmt.Fprintf(os.Stderr, "미안하지만 지금은 m<=%d여야 한다!\n", maxm)
	os.Exit(-3)
}
if n > maxn {
	fmt.Fprintf(os.Stderr, "미안하지만 지금은 n<=%d여야 한다!\n", maxn)
	os.Exit(-4)
}
for k = 2; k < len(os.Args); k++ {
	@<인자 |os.Args[k]|를 미리 준 이름표로 읽는다@>
}
fmt.Fprintf(os.Stderr,
	"좋다, 꼭짓점 %d개, 변 %d개, 미리 준 이름표 %d개인 그래프를 받았다.\n",
	n, m, prespecptr)

@ 인자는 첫 글자 뒤에 나오는 첫 `\.='에서 나눈다. 앞쪽은 꼭짓점 이름이고 뒤쪽은
이름표다.

원본은 같은 이름표가 두 번 미리 주어지는지 보지 않았다. 그러면 두 꼭짓점이 같은
이름표를 갖는 가짜 해를 찍는다. 이 판은 그런 인자를 거절한다.

@<인자 |os.Args[k]|를 미리 준 이름표로 읽는다@>=
arg := os.Args[k]
i = -1
if len(arg) > 1 {
	if p := strings.IndexByte(arg[1:], '='); p >= 0 {
		i = p + 1
	}
}
if i < 0 || !readLabel(arg[i+1:]) || label < 0 || label > m {
	fmt.Fprintf(os.Stderr, "`%s'는 `VERTEX=label' 꼴이 아니다!\n", arg)
	os.Exit(-3)
}
for j = 0; j < n; j++ {
	if g.Vertices[j].Name == arg[:i] {
		break
	}
}
if j == n {
	fmt.Fprintf(os.Stderr, "`%s'라는 꼭짓점은 없다!\n", arg[:i])
	os.Exit(-5)
}
if verttoprespec[j] {
	fmt.Fprintf(os.Stderr, "꼭짓점 %s는 이미 정해졌다!\n", g.Vertices[j].Name)
	os.Exit(-6)
}
@<이름표 |label|을 이미 미리 주었으면 멈춘다@>
verttoprespec[j] = true
prespec[prespecptr] = j<<8 + label; prespecptr++

@ @<이름표 |label|을 이미 미리 주었으면 멈춘다@>=
for p = 0; p < prespecptr; p++ {
	if prespec[p]&0xff == label {
		fmt.Fprintf(os.Stderr, "이름표 %d는 이미 정해졌다!\n", label)
		os.Exit(-7)
	}
}

@ 크누스는 |sscanf|로 이름표를 읽었다. 함수 |readLabel|은 같은 일을 하고, 수를
읽었는지 알려 준다. 읽는 방식을 한 곳에 모으려고 함수로 두었다.

@<함수들@>=
func readLabel(s string) bool {
	_, err := fmt.Sscanf(s, "%d", &label)
	return err == nil
}

@ @<전역 변수@>=
const vbose = false // 일하는 모습을 보려면 참으로 둔다

var (
	label         int          // 인자에서 읽은 이름표
	prespec       [maxn]int    // 미리 준 이름표
	verttoprespec [maxn]bool   // 이 꼭짓점은 미리 정해졌나?
	prespecptr    int          // 몇 개를 미리 주었나?
)

@ @<작별 인사를 한다@>=
if prespecptr == 0 {
	fmt.Fprintf(os.Stderr, "표준형 우아한 이름표가 모두 %d개다. 노드 %d개.\n",
		count, nodes)
} else {
	fmt.Fprintf(os.Stderr, "우아한 이름표가 모두 %d개다(미리 준 것:", count)
	for k = 0; k < prespecptr; k++ {
		fmt.Fprintf(os.Stderr, " %s=%d",
			g.Vertices[prespec[k]>>8].Name, prespec[k]&0xff)
	}
	fmt.Fprintf(os.Stderr, "). 노드 %d개.\n", nodes)
}

@* 자료 구조.
꼭짓점은 안에서 0부터 |n-1|까지 번호를 매긴다. 꼭짓점 |v|의 이웃은 |deg[v]|개이고,
|edges[v]|의 처음 |deg[v]|칸에 들어 있다.

이름표는 0부터~|m|까지다. 이름표 |l|을 아직 쓰지 않았으면 |labunlab[l]|은 음수이고
|labtovert[l]|은 정해져 있지 않다. 썼으면 |labtovert[l]|은 이름표가~|l|인
꼭짓점이고, |labunlab[l]|은 그 꼭짓점의 이웃 가운데 아직 이름표가 없는 것의 수다.

값 |verttolab[v]|는 |v|의 이름표이고, 없으면 |-1|이다. 꼭짓점 |v|에 이름표가
없으면 |vertunlab[v]|는 |v|의 이웃 가운데 역시 이름표가 없는 것의 수다. 이름표가
있으면 |vertunlab[v]|는 |v|가 이름표를 받던 때 이름표가 없던 이웃의 수다.

되짚어 찾기의 수준 |l|에서는 |vlist|의 처음 |l|개 꼭짓점에 이름표가 붙어 있고,
나머지에는 없다. (사실 |vlist|는 순열이고 $0\le k<n$에서
|ilist[vlist[k]]=vlist[ilist[k]]=k|다. 그리고 $0\le k<l$이면 |vlist[k]|는
수준~$k$에서 이름표를 받은 꼭짓점이다.)

비트맵 셋을 유지한다. 비트맵 |ebits|는 이미 나온 변 이름표를 적는데, |1<<q|가
이름표~|q|를 나타낸다. 비트맵 |vbits|는 아직 나오지 {\it 않은\/} 꼭짓점 이름표를
같은 방식으로 적는다. 비트맵 |rebits|는 |ebits|를 ``거꾸로'' 적은 것이라서,
|1<<(m-q)|가 이름표~|q|를 나타낸다.

@<전역 변수@>=
var (
	deg       [maxn]int       // |v|의 이웃은 몇인가?
	edges     [maxn][maxm]int // 그 이웃들
	verttolab [maxn]int       // |v|의 이름표는 무엇인가?
	vertunlab [maxn]int       // 이름표 없는 이웃이 몇인가?
	labtovert [maxm + 1]int   // 이름표가 |l|인 꼭짓점은?
	labunlab  [maxm + 1]int   // 그 꼭짓점의 이름표 없는 이웃은 몇인가?
	vlist     [maxn]int       // 모든 꼭짓점의 순열
	ilist     [maxn]int       // 그 순열의 역
)

@ 먼저 Stanford GraphBase 형식을 여기서 쓰는 자료 구조로 바꾼다.

@<자료 구조를 초기화한다@>=
for k = 0; k < n; k++ {
	verttolab[k] = -1; vlist[k] = k; ilist[k] = k
	for a := g.Vertices[k].Arcs; a != nil; a = a.Next {
		edges[k][deg[k]] = int(g.Index(a.Tip)); deg[k]++
	}
}
for q = 0; q <= m; q++ {
	labunlab[q] = -1
}
for k = 0; k < n; k++ {
	vertunlab[k] = deg[k]
}
ebits, rebits, vbits = 0, 0, ^uint64(0)>>(63-m)

@* 되짚어 찾기.
주된 계산은 Walker의 되짚어 찾기 방법, 곧 알고리즘 7.2.2W에 바탕을 둔다. 재귀를
드러내 놓고 풀어 쓴 것이라, 갱신과 되돌리기의 비용이 눈에 보인다.

수준마다 아직 나오지 않은 가장 큰 변 이름표 |q|를 목표로 삼고, 그 변을 만드는
방법을 모두 늘어놓는다. 한 이동은 |move| 배열의 정수 하나에 담긴다. 비트
0--7은 이름표 |ll|, 비트 8--15는 꼭짓점 |vv|, 비트 16은 ``자리올림'' 표시
|carry|다. 자리올림이 선 이동은 변의 한쪽 끝에만 이름표를 붙이고, 다른 끝은 다음
수준에 맡긴다.

크누스의 단계 이름표 |w1|은 아무도 그리로 뛰지 않는다. \GO/는 쓰지 않는 이름표를
허락하지 않으므로 뺐다.

@<문제를 푼다@>=
@<자료 구조를 초기화한다@>
l, carry, forced = 0, 0, false
w2:
	nodes++
	if l > prespecptr {
		@<선택지가 하나 이하인 이름표 없는 꼭짓점이 있으면 |w3|이나 |w4|로 간다@>
	}
	if carry != 0 {
		@<변 |q|를 |vv|에서 시작하게 할 이동 |r|개를 정한다@>
	} else if l < prespecptr {
		r = 1; move[l][0] = prespec[l]
	} else {
		@<목표 변 |q|를 찾고, 없으면 해를 찍고 |w4|로 간다@>
		@<변 |q|를 만들 수 있는 이동 |r|개를 정한다@>
	}
	moves[l] = r

@ 단계 |w3|은 남은 이동 하나를 해 보고, 통하면 한 수준 내려간다. 단계 |w4|는 한
수준 위로 올라가 그 수준의 이동을 거둔다.

크누스는 이동이 실패하면 |w4| 안쪽, 곧 이름표를 거두는 절의 한가운데로
|goto abort|했다. \GO/는 블록 안으로 뛰어드는 |goto|를 허락하지 않는다. 그래서
|w4|의 조건문을 뒤집어, |l<0|이면 |done|으로 빠져나가게 했다. 그러면 |abort|가
바깥 블록에 놓인다.

@<문제를 푼다@>=
w3:
	if r > 0 {
		r--; t = move[l][r]
		carry, vv, ll = t>>16, (t>>8)&0xff, t&0xff
		if vbose {
			@<이 이동을 보여 준다@>
		}
		forced = false
		@<꼭짓점 |vv|에 이름표 |ll|을 주되, 실패하면 |abort|로 간다@>
		x[l] = r; l++
		goto w2
	}
w4:
	l--
	if l < 0 {
		goto done
	}
	r = x[l]; t = move[l][r]
	vv, ll = (t>>8)&0xff, t&0xff
	@<꼭짓점 |vv|에서 이름표 |ll|을 거두되, |abort|에서 시작할 수도 있다@>
	goto w3
done:

@ @<이 이동을 보여 준다@>=
if forced {
	fmt.Fprintf(os.Stderr, "L%d: %s=%d (강제)\n", l, g.Vertices[vv].Name, ll)
} else if l < prespecptr {
	fmt.Fprintf(os.Stderr, "L%d: %s=%d (미리 줌)\n", l, g.Vertices[vv].Name, ll)
} else if carry != 0 {
	fmt.Fprintf(os.Stderr, "L%d: %s=%d (%d/%d, 변 %d 시작)\n",
		l, g.Vertices[vv].Name, ll, moves[l]-r, moves[l], target[l])
} else if l > 0 && move[l-1][x[l-1]] >= 1<<16 {
	fmt.Fprintf(os.Stderr, "L%d: %s=%d (%d/%d, 변 %d 완성)\n",
		l, g.Vertices[vv].Name, ll, moves[l]-r, moves[l], target[l])
} else {
	fmt.Fprintf(os.Stderr, "L%d: %s=%d (%d/%d, 변 %d)\n",
		l, g.Vertices[vv].Name, ll, moves[l]-r, moves[l], target[l])
}

@ 목표 변은 바로 앞 수준의 목표보다 작은 것 가운데 아직 없는 가장 큰 것이다.
그런 것이 없으면, 곧 1부터 |m|까지 모든 변 이름표가 나왔으면 해를 얻은 것이다.

@<목표 변 |q|를 찾고, 없으면 해를 찍고 |w4|로 간다@>=
if l == prespecptr {
	q = m
} else {
	q = target[l-1] - 1
}
for del = 1 << q; ebits&del != 0; q, del = q-1, del>>1 {
}
if q == 0 {
	@<해를 찍고 |w4|로 간다@>
}
target[l] = q

@ @<해를 찍고 |w4|로 간다@>=
count++
for k = 0; k <= m; k++ {
	if labunlab[k] >= 0 {
		if labunlab[k] > 0 {
			fmt.Fprintf(os.Stderr, "이런 일은 있을 수 없다!\n")
		}
		vv = labtovert[k]
		fmt.Printf("%s=%d ", g.Vertices[vv].Name, k)
	}
}
fmt.Printf("#%d\n", count)
goto w4

@ 여기에 오면 |vv|와 |ll|은 앞 수준에서 정해진 값이다. 그 수준에서 꼭짓점~|vv|가
이름표 |ll|을 받았고, 이제 |vv|의 이웃 하나에 이름표 |ll+target[l-1]|을 주려 한다.

@<변 |q|를 |vv|에서 시작하게 할 이동 |r|개를 정한다@>=
q = target[l-1]; target[l] = q
for r, i = 0, deg[vv]-1; i >= 0; i-- {
	t = verttolab[edges[vv][i]]
	if t < 0 {
		move[l][r] = edges[vv][i]<<8 + ll + q; r++
	}
}

@ 이름표가 |q|인 변을 만드는 길은, $k=j+q$인 꼭짓점 이름표 쌍 $(j,k)$마다 본질적으로
둘이다. 값 |labunlab[j]|와 |labunlab[k]| 가운데 꼭 하나만 양수이거나, 둘 다
음수이거나. 둘 다 음수인 경우는 ``뿌리 있는'' 해에서는 생기지 않는데, 하위 경우가
엄청나게 많아질 수 있다. 서로 이웃한 이름표 없는 꼭짓점 쌍이라면 {\it 어느\/}
것이든 자격이 되기 때문이다.

크누스는 이것이 안쪽 반복문이라고 했다.

표준형을 지키는 곳도 여기다. 미리 준 것이 없으면 수준 0과 1이 변~|m|을 0과~|m|으로
만들고, 수준 2가 변 |m-1|을 목표로 삼는다. 그때 |j|를 1부터 시작하면 쌍
$(0,m-1)$이 빠지고 $(1,m)$만 남는다.

@<변 |q|를 만들 수 있는 이동 |r|개를 정한다@>=
j = 0
if l == 2 && prespecptr == 0 {
	j = 1
}
for r, k = 0, j+q; k <= m; j, k = j+1, k+1 {
	if labunlab[j] > 0 && labunlab[k] < 0 {
		@<이름표가 |j|인 꼭짓점의 이름표 없는 이웃에 |k|를 주는 이동들@>
	} else if labunlab[j] < 0 {
		if labunlab[k] > 0 {
			@<이름표가 |k|인 꼭짓점의 이름표 없는 이웃에 |j|를 주는 이동들@>
		} else if labunlab[k] < 0 {
			@<이름표 없는 이웃이 있는 꼭짓점에 |j|를 주고 자리올림하는 이동들@>
		}
	}
}

@ @<이름표가 |j|인 꼭짓점의 이름표 없는 이웃에 |k|를 주는 이동들@>=
vv = labtovert[j]
for i = deg[vv] - 1; i >= 0; i-- {
	t = verttolab[edges[vv][i]]
	if t < 0 {
		move[l][r] = edges[vv][i]<<8 + k; r++
	}
}

@ @<이름표가 |k|인 꼭짓점의 이름표 없는 이웃에 |j|를 주는 이동들@>=
vv = labtovert[k]
for i = deg[vv] - 1; i >= 0; i-- {
	t = verttolab[edges[vv][i]]
	if t < 0 {
		move[l][r] = edges[vv][i]<<8 + j; r++
	}
}

@ 이름표 없는 꼭짓점은 |vlist|의 |l|번째 칸부터 있다.

@<이름표 없는 이웃이 있는 꼭짓점에 |j|를 주고 자리올림하는 이동들@>=
for i = n - 1; i >= l; i-- {
	vv = vlist[i]
	if vertunlab[vv] != 0 {
		move[l][r] = 1<<16 + vv<<8 + j; r++
	}
}

@ 이 반복문도 거의 ``안쪽''이다.

크누스는 되짚어야 할 것이 보일 때 이 절에서 다음 절로 뛰어드는 유혹을 참지
못했다며 사과했다.

원본은 |bad|를 |int|로 선언했다. 그러면 |bad|는 |ebits&del|의 아래 32비트만 받으므로,
32 이상의 변 이름표가 겹쳐도 알아채지 못한다. 이 판에서는 64비트다. 맨 뒤의 버그
이야기를 보라.

@<꼭짓점 |vv|에 이름표 |ll|을 주되, 실패하면 |abort|로 간다@>=
for p, i, bad = deg[vv], deg[vv]-1, 0; i >= 0; i-- {
	j = edges[vv][i]; t = verttolab[j]
	if t >= 0 {
		p--; labunlab[t]--; q = abs(t - ll)
		del = 1 << q; bad |= ebits & del
		ebits += del; rebits += 1 << (m - q)
	} else {
		vertunlab[j]--
	}
}
labunlab[ll] += p + 1
if bad != 0 {
	if vbose {
		fmt.Fprintf(os.Stderr, "L%d, %s=%d에서 충돌\n", l, g.Vertices[vv].Name, ll)
	}
	goto abort
}
verttolab[vv], labtovert[ll] = ll, vv
t, p = ilist[vv], vlist[l]
vlist[l], vlist[t], ilist[vv], ilist[p] = vv, p, l, t
vbits -= 1 << ll

@ 여기서는 |vlist|와 |ilist|를 되돌리지 않으려고 ``성긴 집합'' 기교를 쓴다.
(7.2.2--(23)을 보라.)

@<꼭짓점 |vv|에서 이름표 |ll|을 거두되, |abort|에서 시작할 수도 있다@>=
vbits += 1 << ll
verttolab[vv] = -1
abort:
	for i = deg[vv] - 1; i >= 0; i-- {
		j = edges[vv][i]; t = verttolab[j]
		if t >= 0 {
			labunlab[t]++; q = abs(t - ll)
			ebits -= 1 << q; rebits -= 1 << (m - q)
		} else {
			vertunlab[j]++
		}
	}
	labunlab[ll] = -1

@ 두 곳에서 쓰는 절댓값 함수다.

@<함수들@>=
func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

@ 크누스가 해 본 실험에서는, 이름표 없는 꼭짓점이 가질 수 있는 값의 범위가 점점
줄어 하나만 남거나 아예 남지 않는 일이, 바로 탐색에서 시간을 가장 많이 먹는
수준들에서 일어났다.

이 절의 검사는 순전히 선택이다. 반복문이 꽤 길고, 이름표를 붙일 꼭짓점이 아직 많은
뿌리 근처 수준에서는 성공할 것 같지도 않다. 그래서 크누스는 처음에 깊은 수준에서만
검사하려 했다. 그런데 적어도 그의 실험에서는 얕은 수준의 (보람 없는) 검사에 드는
시간이 모두 합쳐도 꽤 적었다. 그래서 어디서부터 검사할지 사용자에게 묻지 않기로
했다. 더 다스리고 싶은 사용자는 아래 코드를 골라서 건너뛰는 변경 파일을 만들면 된다.

이 검사는 완전하지 않다. 이를테면 이름표 없는 꼭짓점 $v$의 이웃이 이름표 10과 20을
가졌고, 이름표가 15인 꼭짓점도 이름표가 5인 변도 없다고 하자. 이 검사는 $v$가 가질
수 있는 값에서 15를 지우지 않는다. 15를 주면 5가 두 번 생겨 실패하는데도 그렇다.

미묘한 곳이 있다. 이름표 없는 꼭짓점 |vv|에 가능한 이름표가 |ll| 하나만 남은 것을
찾았다고 하자. 자리올림 |carry|가 서 있으면 |vv|에 |ll|을 강제할 수 없다. 앞 수준에서
이름표를 받은 꼭짓점의 이웃을 써서 이름표가 |target[l-1]|인 변을 만들어야 하기
때문이다. 그런데 |vv|를 강제하면 같은 해가 두 번 나올 수 있다. 자리올림이 서 있지
않으면 |vv|를 강제할 {\it 수 있다}. 다만 |target[l]=target[l-1]|로 두어야 한다.
그것이 있다고 알려진 가장 큰 변이다. (|l>prespecptr|이므로 |target[l-1]|은 뜻이
있다.)

@<선택지가 하나 이하인 이름표 없는 꼭짓점이 있으면 |w3|이나 |w4|로 간다@>=
{
	var i, j, k, vv, ll int
	var vvbits uint64
	for forced, k = false, l; k < n; k++ {
		vv, vvbits = vlist[k], vbits
		@<꼭짓점 |vv|의 이름표 있는 이웃과 겹칠 이름표를 |vvbits|에서 지운다@>
		@<꼭짓점 |vv|가 막혔으면 |w4|로 가고, 선택지가 하나면 강제할 이동으로 적어 둔다@>
	}
	if forced {
		r, moves[l] = 1, 1 // 강제된 이동
		target[l] = target[l-1] // 앞의 설명을 보라
		goto w3
	}
}

@ 남은 선택지가 없으면 이 가지는 끝이다. 하나뿐이면 그 이름표를 강제할 이동으로
적어 둔다. 여럿이 그렇다면 마지막 것이 남는다.

이 판은 미리 준 것이 없을 때의 수준 2에서도 강제하지 않는다. 그 수준이 표준형을
지키는 곳이기 때문이다. 맨 뒤를 보라.

@<꼭짓점 |vv|가 막혔으면 |w4|로 가고, 선택지가 하나면 강제할 이동으로 적어 둔다@>=
i = bits.OnesCount64(vvbits)
if i > 1 {
	continue
}
if i == 0 {
	if vbose {
		fmt.Fprintf(os.Stderr, "L%d, %s가 막혔다\n", l, g.Vertices[vv].Name)
	}
	goto w4
}
if carry != 0 || (l == 2 && prespecptr == 0) {
	continue
}
ll = bits.OnesCount64(vvbits - 1)
move[l][0], forced = vv<<8+ll, true

@ 이름표가 |ll|인 이웃이 있으면, |vv|에 이름표 $ll\pm q$를 줄 때 변 이름표 |q|가
생긴다. 그러니 |q|가 이미 나왔으면 $ll+q$와 $ll-q$를 지운다. 앞의 것은 |ebits|를
|ll|만큼 왼쪽으로, 뒤의 것은 |rebits|를 |m-ll|만큼 오른쪽으로 밀어 얻는다.

@<꼭짓점 |vv|의 이름표 있는 이웃과 겹칠 이름표를 |vvbits|에서 지운다@>=
for i = deg[vv] - 1; i >= 0; i-- {
	j = edges[vv][i]; ll = verttolab[j]
	if ll >= 0 { // |j|는 이름표 없는 |vv|의 이름표 있는 이웃이다
		vvbits &^= ebits<<ll + rebits>>(m-ll)
	}
}

@ @<전역 변수@>=
var (
	count  int64                   // 지금까지 찾은 해의 수
	nodes  int64                   // 지금까지 탐색 나무의 노드 수
	target [maxn]int               // 수준마다 만들려는 변
	move   [maxn][maxn * maxm]int  // 수준마다 해 볼 것들
	x      [maxn]int               // 수준마다 지금 해 보는 이동
	moves  [maxn]int               // 디버깅과 자세한 추적에만 쓴다
)

@* 옮기며 고친 것.
원본에서 결함 셋을 찾았다. 고친 C 프로그램과 무차별 계수기를 곁에 두고 확인했다.

첫째, |bad|의 폭이다. 원본은 |bad|를 |int|로 선언하고, 거기에 64비트 값 |ebits&del|을
비트별 {\mc OR}로 모은다. 그러면 |bad|에는 아래 32비트만 남는다. 그래서 변 이름표 |q|가 32 이상이면
중복이 생겨도 |bad|가 0으로 남는다. 이를테면 $K_{5,7}$(변 35개)에서 한쪽 두
꼭짓점에 0과 1을, 다른 쪽 두 꼭짓점에 33과 34를 미리 주면 변 이름표 33이 두 번
생긴다. 그런데도 원본은 ``충돌''을 알리지 않고, |ebits+=del|의 자리올림이 비트
34를 켠 채로 탐색을 이어 간다.

다행히 답은 틀리지 않는다. 비트맵 |ebits|에는 덧셈과 뺄셈만 하므로, 그 값은 언제나
지금 생긴 변 이름표 |q|들의 $2^q$를 모두 더한 것이다. 해를 찍는 순간 그 값은
$2^1+\cdots+2^m$이고, 1비트가 $m$개다. 그런데 2의 거듭제곱 $m$개 이하를 더해 1비트가
$m$개인 수를 얻으려면 항이 모두 달라야 한다. 그러니 찍힌 해는 언제나 참이다. 또
되짚을 때는 더한 양을 그대로 빼므로 상태도 온전히 돌아온다. 결국 이 결함은 이미
틀린 가지를 늦게 버릴 뿐이다. (다만 $m=63$이면 $2^{64}$이 넘쳐 이 논증이 깨진다.)
꼭짓점 9--10개, 변 33--42개인 무작위 그래프 200개에서 원본과 고친 판을 견주니, 찾은
해는 모두 같았고 122개에서 원본이 노드를 더 썼다. 많게는 아홉 배 가까이 된다.

둘째, 표준형이다. 미리 준 것이 없으면 수준 2에서 |j=1|로 시작해 쌍 $(0,m-1)$을
뺀다. 그런데 수준 2에서 강제 이동이 일어나면 그 코드를 거치지 않고, 목표도
|target[1]=m|으로 남는다. 그러면 다음 수준이 변 |m-1|을 제한 없이 만들고, 해와 그
뒤집은 해가 둘 다 나온다. 수준 2에서 꼭짓점 둘에 0과~|m|이 붙어 있을 때 이름표
없는 꼭짓점이 막는 이름표는 이미 쓴 것뿐이다. 그러니 강제는 남은 이름표가 하나인
$m=2$일 때만 일어난다. 실제로 경로 $P_3$에서 원본은 표준형 해가 4개라고 하지만
2개가 맞다. 이 판은 그 수준에서는 강제하지 않는다. 막힘 검사는 그대로 한다.

셋째, 같은 이름표를 두 꼭짓점에 미리 주는 것을 막지 않는다. 이를테면 $P_4$에
\.{0=1 3=1}을 주면 원본은 ``This can't happen!''을 찍고 꼭짓점이 빠진 가짜 해 둘을
낸다. 이 판은 그런 인자를 거절한다.

덧붙여 둘. 변이 하나뿐이면($m=1$) 이름표 |m-1|, 곧 0인 변이 없으므로 표준형이 뜻을
잃는다. 그래서 $K_2$에서는 두 이름표가 모두 나온다. 이 판도 원본대로 두었다. 그리고
원본 첫 절의 ``This saves of factor of~2''에서 {\it of\/}는 {\it a\/}여야 한다.

@* 맞춰 보기.
원본에 위의 세 가지만 고친 C 프로그램을 만들어 이 판과 견주었다.

\smallskip
\item{$\bullet$} 경로, 순환, 완전 그래프, 바퀴, 완전 이분 그래프, 격자, 사다리,
3차원 입방체, 피터슨 그래프, 무작위 나무 등 50개에서, 찍은 해와 해의 수, 노드
수가 모두 같다.
\item{$\bullet$} 이름표 한두 개를 무작위로 미리 준 132가지에서도 모두 같다.
\item{$\bullet$} 위의 무작위 조밀 그래프 200개에서도 모두 같다.
\smallskip

\noindent 답 자체는 따로 짠 무차별 계수기로 확인했다. 꼭짓점을 차례로 훑으며
이름표를 붙이는 단순한 되짚어 찾기다. 미리 준 것이 없는 50개 그래프에서 표준형 해의
수의 두 배가 전체 우아한 이름표의 수와 같다. 예외는 앞에서 말한 $K_2$(곧 $P_2$)
하나다.
미리 준 132가지에서는 해의 수가 무차별 계수와 같다. 그리고 찍힌 해는 모두 따로
검사해 우아함을 확인했다. 이를테면 피터슨 그래프의 표준형 해는 5040개다.

@* 색인.
