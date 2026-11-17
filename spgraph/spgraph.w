\input kotexgweb
\input luamplib.sty
% spspan/spspan.mp 의 첫 그림을 그대로 나눠 쓴다.
\everymplib{input ../spspan/spspan;}
@i ../types.w
\datethis

\def\title{직병렬 식을 그래프 파일로}

@* 들어가며.
이 프로그램은 직병렬 그래프의 대수적 명세를 받아 Stanford GraphBase(\.{SGB})의
그래프 파일로 바꾼다.

그래프는 간단한 역폴란드 표기로 적는다.
$$
G\,\to\,\.-\,\mid\,G\,G\,\,\.s\,\mid\,G\,G\,\,\.p
$$
변 하나가 \.-이고, 그래프 둘을 이어 붙이는 것이 \.s(직렬), 나란히 놓는 것이
\.p(병렬)다. 이를테면 식 \.{----ps-sp--sp}와 \.{----p-ss--spp}는 둘 다 다음
그래프를 나타낸다.
$$\mplibcode fig_graph; \endmplibcode$$
표기법은 \.{spspan}과 똑같다. 커누스는 \.{spspan}을 \.{grayspan}과 견주려고 이
프로그램을 짰다. 같은 식을 \.{spspan}에 주고, 이 프로그램이 저장한 그래프를
\.{grayspan}이나 \.{grayspspan}에 주면 된다. 이 저장소에는 그 셋을 옮긴 문서가
다 있다.

@ 이것은 커누스의 \.{CWEB} 프로그램 \pdfURL{\.{spgraph.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/spgraph.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Thu, 01 Jun 2017 23:32:05 GMT}다. 위의 그림은 원본이 \.{spspan}의 그림 파일에서
가져다 쓰는 것이라, 이 판도 \.{spspan}을 옮긴 문서와 함께 쓰는 \.{spspan.mp}에서
가져온다.

그래프는 \pdfURL{go-sgb}{https://github.com/sjnam/go-sgb}로 짓고 저장한다.
프로그램이 찍는 말과 종료 부호, 그리고 저장한 파일은 원본 그대로다. 그래야 두
프로그램의 결과를 바이트 단위로 견줄 수 있다. 원본의 결함 하나는 \.{spspan}과
같은 것이라 같은 방법으로 고쳤고, 이야기는 맨 뒤에 적었다.

@ 명령줄의 인자는 꼭 둘이다. 첫째는 그래프를 나타내는 식이고, 둘째는 그래프를
저장할 파일의 이름이다. 인자 수가 맞지 않으면 쓰는 법을 알리고 멈춘다. 원본은
그때 종료 부호 $0$을 돌려준다.

프로그램의 뼈대는 이렇다. 식을 이진 나무로 읽고, 나무를 그래프로 바꾸고, 그래프를
파일에 저장한다.

@c
package main

import (
	"fmt"
	"os"
	@#
	"github.com/sjnam/go-sgb/gbgraph"
	"github.com/sjnam/go-sgb/gbsave"
)

@<전역 변수@>@;
@<함수들@>@;

func main() {
	var j, k int
	if len(os.Args) != 3 {
		fmt.Fprintf(os.Stderr, "Usage: %s SPformula foo.gb\n", os.Args[0])
		os.Exit(0)
	}
	@<식 |os.Args[1]|을 이진 나무로 읽는다@>@;
	@<이진 나무를 그래프로 바꾼다@>@;
	@<그래프를 파일 |os.Args[2]|에 저장하고 알린다@>@;
}

@* 식 읽기.
다음 코드에서 우리는 이항 연산자를 $j$개 훑었고, 그 가운데 \.s가 |jj|개다.
스택에는 항목이 $k$개 있다. 스택 항목은 잎이면 $0$이다. 연산자 $j$번이 만든
가지면 $2j+t$인데, 직렬 연산자 \.s면 $t=1$, 병렬 연산자 \.p면 $t=0$이다. 원본은
이것을 $256t+j$로 적는다. 그 차이는 맨 뒤에서 이야기한다.

이항 연산자는 식의 글자 수보다 적고 스택 깊이도 글자 수를 넘지 않으니, 배열은
식의 길이만큼 잡으면 넉넉하다. 원본은 크기를 상수 |maxn|$=1000$으로 박아 두고
넘치는지 살피지 않는다.

이 부분은 \.{spspan}의 것과 거의 같다. 다른 것은 \.s의 수 |jj|를 세는 것뿐이다.

@<식 |os.Args[1]|을 이진 나무로 읽는다@>=
f := os.Args[1]
stack := make([]int, len(f)) // 파싱에 쓰는 스택
llink = make([]int, len(f)+1)
rlink = make([]int, len(f)+1)
for i := 0; i < len(f); i++ {
	switch f[i] {
	case '-':
		@<새 잎을 만든다@>@;
	case 's', 'p':
		@<새 가지를 만든다@>@;
	default:
		abort(f, i, "bad symbol")
	}
}
if k != 1 {
	abort(f, len(f), "disconnected graph")
}

@ 이항 연산자의 두 피연산자는 전역 배열 |llink|와 |rlink|에 적는다. 재귀 함수
|build|가 나중에 그것을 읽는다. 지을 그래프 |g|와 \.s의 수 |jj|도 그 함수가
쓰니 전역에 둔다.

@<전역 변수@>=
var (
	llink, rlink []int          // 이진 부분 나무들
	jj           int            // 아직 번호를 매기지 않은 가운데 꼭짓점의 수
	g            *gbgraph.Graph // 지을 그래프
)

@ 식이 잘못되면 어디까지 읽었는지를 세로 막대로 표시해 알리고 멈춘다. 그런
자리가 세 곳이라 함수로 둔다.

@<함수들@>=
func abort(f string, i int, mess string) {
	fmt.Fprintf(os.Stderr, "Parsing error: %s|%s, %s!\n", f[:i], f[i:], mess)
	os.Exit(-1)
}

@ @<새 잎을 만든다@>=
stack[k] = 0
k++

@ @<새 가지를 만든다@>=
if k < 2 {
	abort(f, i, "missing operand")
}
t := 0
if f[i] == 's' {
	t = 1
	jj++
}
j++
k--
rlink[j] = stack[k]
llink[j] = stack[k-1]
stack[k-1] = 2*j + t

@* 그래프 짓기.
이제 이진 나무를 위에서 아래로 내려가며 그래프로 바꾼다.

직렬 연산자 하나는 두 피연산자 사이에 가운데 꼭짓점을 하나 새로 들이고, 병렬
연산자는 꼭짓점을 들이지 않는다. 그러니 꼭짓점은 양 끝 둘에 \.s의 수 |jj|를 더한
만큼이다. 꼭짓점의 이름은 \.{v0}, \.{v1}, \dots{}이고, 바깥의 양 끝이 \.{v0}과
\.{v1}이다.

그래프의 이름은 식 앞에 \.{SP}를 붙인 것이다. 원본은 \.{SGB}의 이름 필드에
들어가도록 식을 $152$글자에서 자른다.

원본은 |gb_new_graph|가 메모리를 얻지 못하면 ``\.{Can't create the graph!}''라고
알리고 멈춘다. go-sgb의 |gbgraph.NewGraph|는 실패를 돌려주지 않으니(메모리가
모자라면 \GO/ 런타임이 프로그램을 멈춘다) 이 판에는 그 검사가 없다.

@<이진 나무를 그래프로 바꾼다@>=
g = gbgraph.NewGraph(int64(jj + 2))
if len(f) > 152 {
	f = f[:152]
}
g.ID = "SP" + f
for k = 0; k < int(g.N); k++ {
	g.Vertices[k].Name = fmt.Sprintf("v%d", k)
}
build(stack[0], 0, 1)

@ 재귀 함수 |build|가 짓는 일을 맡는다. 스택 항목 하나를 받아, 그것이 나타내는
부분 그래프를 꼭짓점 |lft|와 |rt| 사이에 짓는다. 잎이면 변 하나를 놓는다. 직렬
가지면 가운데 꼭짓점 하나를 새로 정해 왼쪽 부분을 |lft|와 그 사이에, 오른쪽
부분을 그것과 |rt| 사이에 짓는다. 병렬 가지면 두 부분을 다 |lft|와 |rt| 사이에
짓는다.

가운데 꼭짓점의 번호는 |jj+1|부터 거꾸로 매긴다. 원본은 직렬 가지의 종류를 담던
변수 |t|에 그 번호를 도로 담는데, 나는 |mid|라는 이름을 따로 썼다.

@<함수들@>=
func build(item, lft, rt int) {
	if item == 0 {
		g.NewEdge(&g.Vertices[lft], &g.Vertices[rt], 0)
		return
	}
	t, j := item%2, item/2 // 이항 연산의 종류와 자리
	if t != 0 {
		jj--
		mid := jj + 2
		build(llink[j], lft, mid)
		build(rlink[j], mid, rt)
	} else {
		build(llink[j], lft, rt)
		build(rlink[j], lft, rt)
	}
}

@ 원본의 |save_graph|는 고쳐야 했던 이상의 비트 모음을 돌려주고, 파일을 만들지
못하면 $-2$를 돌려준다. 원본은 그 값이 $0$이 아니면 \.{\%x}로 찍는다. 이 판의
그래프에는 이상이 생길 수 없다. 이름은 짧고, 글자는 \.{-}, \.{s}, \.{p}, 숫자와
영문자뿐이며, 다목적 필드는 쓰지 않는다. 그러니 원본이 $0$ 아닌 값을 찍는 것은
파일을 만들지 못할 때뿐이다.

go-sgb의 |gbsave.SaveGraph|는 이상의 비트 모음 대신 오류를 돌려준다. 그래서 이 판은
오류가 나면 원본처럼 $-2$로 치고, 그것을 \CEE/의 부호 없는 \.{\%x}처럼 32비트로
찍는다. 곧 \.{fffffffe}다. 알리는 말은 표준 출력으로 나가고, 종료 부호는 원본처럼
$0$이다.

@<그래프를 파일 |os.Args[2]|에 저장하고 알린다@>=
k = 0
if gbsave.SaveGraph(g, os.Args[2]) != nil {
	k = -2 // 원본의 |save_graph|가 파일을 열지 못할 때 돌려주는 값
}
if k != 0 {
	fmt.Printf("I had trouble saving in %s (anomalies %x)!\n",
		os.Args[2], uint32(k))
} else {
	fmt.Printf("Graph %s saved successfully in %s.\n", g.ID, os.Args[2])
}

@* 옮기며 고친 것.
원본은 \.{spspan}과 같은 방식으로 스택 항목에 이항 연산의 종류와 자리를 함께
담는다. 직렬이면 $256$을 더한 $256t+j$로 적고, 거꾸로 |t=item>>8|,
|j=item&0xff|로 푼다. 그러니 이항 연산자가 $255$개를 넘으면 셈이 틀어진다.

실제로 원본에 잎 $257$개를 나란히 놓은 식 \.{-}$\,(\.{-p})^{256}$을 주면, 꼭짓점
둘 사이에 변 $257$개가 놓인 그래프가 아니라 변 하나와 고리 하나뿐인 그래프를
저장한다. 연산자 $256$번이 남긴 병렬 항목 $256$이 직렬인 $0$번 연산으로 읽히기
때문이다. 잎 $257$개를 한 줄로 이은 식 \.{-}$\,(\.{-s})^{256}$에서는 마지막 항목
$512$가 $0$번 연산으로 읽혀, 꼭짓점 $258$개 가운데 셋만 이어진 끊어진 그래프를
저장한다.

이 판은 $2j+t$로 적으니 이런 한계가 없다. 연산자가 $255$개 이하인 식에서는
원본과 똑같은 파일을 저장한다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀고 \.{libgb}와 함께 컴파일해 이 판과 견주었다. (요즘의
\CEE/ 컴파일러는 반환형이 없는 원본의 |main|을 받지 않으니 \.{-std=gnu89}를
주었다.)

\smallskip
\item{$\bullet$} \.{spspan}을 맞춰 볼 때 쓴 식 $514$개를 그대로 썼다. 잘못된 식,
잎이 $2$개에서 $254$개인 무작위 식, 연산자가 $254$개인 긴 사슬이 섞여 있다.
두 프로그램이 저장한 그래프 파일, 표준 출력, 표준 오류(말에 든 프로그램 이름은
빼고), 종료 부호가 모두 바이트까지 같았다.
\item{$\bullet$} 인자 수가 틀릴 때와 저장할 파일을 만들 수 없을 때의 말과 종료
부호도 같다.
\item{$\bullet$} 저장한 그래프가 옳은지는 원본과 따로 보았다. 같은 식을
\.{spspan}에 주어 센 신장 나무의 수와, 저장한 그래프를 \.{grayspspan}에 주어 센
수가 올바른 식 $504$개 모두에서 같았다. 연산자가 $256$개, $400$개, $998$개인
사슬도 이 판이 저장한 그래프는 \.{grayspspan}이 센 나무의 수가 맞다. 병렬
사슬은 잎의 수만큼, 직렬 사슬은 하나다.
\smallskip

@* 색인.
