\input kotexgweb
\input luamplib.sty
@i ../types.w
\datethis

\def\title{직병렬 그래프의 신장 나무}
\def\adj{\mathrel{\!\mathrel-\mkern-8mu\mathrel-\mkern-8mu\mathrel-\!}}
   % 이웃한 꼭짓점
\def\spbox#1{\hbox to1em{\hfil$#1\mathstrut$\hfil}} % 그림의 노드 이름표

@* 들어가며.
이 프로그램은 주어진 직병렬 그래프(series-parallel graph)의 신장 나무를 모두
만들어 낸다. 한 나무에서 다음 나무로 넘어갈 때마다 변을 꼭 하나씩만 바꾸는데,
그렇게 하는 알고리즘이 꽤 재미있다.

그래프는 간단한 역폴란드 표기로 적는다.
$$
G\,\to\,\.-\,\mid\,G\,G\,\,\.s\,\mid\,G\,G\,\,\.p
$$
변 하나가 \.-이고, 그래프 둘을 이어 붙이는 것이 \.s(직렬), 나란히 놓는 것이
\.p(병렬)다. 이를테면 식 \.{----ps-sp--sp}와 \.{----p-ss--spp}는 둘 다 다음
그래프를 나타낸다.
$$
\mplibcode
beginfig(1)
numeric h,w; h=.4in; w=.5in;
z1-z0=z2-z1=z3-z2=(w,0);
z1=-z2; z4=-z5;
z4-z5=z6=-z7=(0,h);
path p; p= z0{up}...z6{right}...z3{down}...z7{left}...cycle;
draw p;
draw z1{up}...z4{right}...z2{down}...z5{left}...cycle;
draw z0--z1; draw z2--z3;
pickup pencircle scaled 3pt;
for j=0,1,2,3,7: drawdot z[j]; endfor
label.top(btex$a$etex,z6);
label.top(btex$b$etex,.5[z0,z1]);
label.top(btex$c$etex,z4);
label.top(btex$d$etex,z5);
label.top(btex$e$etex,.5[z2,z3]);
label.top(btex$f$etex,point 3.3 of p);
label.top(btex$g$etex,point 2.7 of p);
endfig;
\endmplibcode
$$
이 그래프는 나무로도 나타낼 수 있다.
$$
\mplibcode
% 커누스의 상자 정의 가운데 이 그림이 쓰는 것
def box(expr wd,ht)(suffix $) =
  z$ne-z$nw=z$se-z$sw=(wd,0);
  z$ne-z$se=z$nw-z$sw=(0,ht);
  z$n=.5[z$nw,z$ne];
  z$e=.5[z$se,z$ne];
  z$s=.5[z$se,z$sw];
  z$w=.5[z$nw,z$sw];
  z$=.5[z$nw,z$se];
enddef;
picture pic[];
vardef picbox@@# =
  box(xpart(urcorner pic@@#-llcorner pic@@#)+3pt,
      ypart(urcorner pic@@#-llcorner pic@@#)+3pt)(@@#)
enddef;
vardef oval@@# = z@@#se-(.5ypart(z@@#n-z@@#s),0){right}..
  z@@#e{up}..{left}z@@#ne-(.5ypart(z@@#n-z@@#s),0)--
  z@@#nw+(.5ypart(z@@#n-z@@#s),0){left}..
  z@@#w{down}..{right}z@@#sw+(.5ypart(z@@#n-z@@#s),0)--cycle enddef;
def drawobox (expr lbl)(suffix $) =
  erase fill oval$;
  draw oval$;
  label(lbl,z$);
enddef;
beginfig(2)
w:=20pt; h:=18pt;
z0=origin;
z2=z0-(5pt,h);
y1=y2=y3; x3=.5[x7,x8]; x2-x1=4/5(x3-x2);
z5=z2-(0,h);
z6-z5=z5-z4=z7-z6=z8-z7=z10-z9=(w,0);
.5[z9,z10]=z5-(0,h);
draw z0--z1; draw z0--z2; draw z0--z3;
draw z2--z4; draw z2--z5; draw z2--z6; draw z3--z7; draw z3--z8;
draw z5--z9; draw z5--z10;
pic0=btex\spbox A etex;
pic1=btex\spbox a etex;
pic2=btex\spbox B etex;
pic3=btex\spbox D etex;
pic4=btex\spbox b etex;
pic5=btex\spbox C etex;
pic6=btex\spbox e etex;
pic7=btex\spbox f etex;
pic8=btex\spbox g etex;
pic9=btex\spbox c etex;
pic10=btex\spbox d etex;
for j=0 upto 10:
  picbox[j];
  drawobox(pic[j],[j]);
endfor
endfig;
\endmplibcode
$$
나무의 가지 노드는 $S$ 노드 아니면 $P$ 노드이고, 층마다 번갈아 나온다.

계산하면서 만들어 낸 신장 나무의 수와 그러는 데 든 메모리 참조의 수를 센다.

@ 이것은 커누스의 \.{CWEB} 프로그램 \pdfURL{\.{spspan.w}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/spspan.w}를
\.{GWEB}으로 옮긴 것이다. 원본의 머리글 \.{Last-Modified}는
\.{Tue, 08 Aug 2017 23:41:46 GMT}다. 위의 두 그림은 커누스가 함께 내놓은
MetaPost 파일 \pdfURL{\.{spspan.mp}}%
{https://www-cs-faculty.stanford.edu/\TILDE/knuth/programs/spspan.mp}(2003년
8월 28일)를 이 문서 안에 옮겨 조판하면서 그린다. 원본은 그림 2의 이름표
매크로를 \.{verbatimtex}로 정의하지만 여기서는 문서의 림보에 \.{\\spbox}로 두었고,
상자 정의 가운데 그림이 쓰지 않는 것(네모, 마름모, \.{cutat})은 뺐다.

프로그램이 찍는 말과 종료 부호는 원본 그대로 두었다. 두 프로그램의 출력을 바이트
단위로 견주려는 것이다. 옮기다가 원본의 결함 하나를 만났다. 고쳤고, 이야기는 맨
뒤에 적었다.

@ 명령줄의 첫 인자가 그래프를 나타내는 식이다. 인자를 하나 더 주면 나무마다
들어오는 변과 나가는 변을 찍고, 둘을 더 주면 프로그램의 속사정까지 찍는다.
무엇을 주든 상관없고 개수만 본다. 아무것도 더 주지 않으면 찾은 신장 나무의 수와
쓴 메모리 참조의 수만 알린다.

@ 프로그램의 뼈대는 이렇다. 식을 읽어 나무를 세우고, 첫 신장 나무를 마련한 다음,
나머지 신장 나무를 모두 만든다. 채비에 든 메모리 참조와 알고리즘에 든 메모리
참조는 따로 센다.

@c
package main

import (
	"bufio"
	"fmt"
	"os"
)

@<자료형@>@;
@<전역 변수@>@;
@<함수들@>@;

func main() {
	@<지역 변수@>@;
	if len(os.Args) == 1 {
		fmt.Fprintf(os.Stderr, "Usage: %s SPformula [[gory] details]\n",
			os.Args[0])
		os.Exit(0)
	}
	verbose, extraverbose = len(os.Args) > 2, len(os.Args) > 3
	@<식 |os.Args[1]|을 읽어 나무 구조를 세운다@>@;
	@<첫 신장 나무를 마련한다@>@;
	fmt.Fprintf(out, " (%d mems to get started)\n", mems)
	mems = 0
	@<알고리즘을 돌린다@>@;
	fmt.Fprintf(out, "Altogether %d spanning trees, %d additional mems.\n",
		trees, mems)
	out.Flush()
}

@ 커누스는 늘 그렇듯 메모리 참조의 수 |mems|를 센다. 원본은 매크로 |o|, |oo|,
|ooo|, |oooo|로 한 자리에 하나부터 넷까지 얹고, 서브루틴을 한 번 부르는 값은
메모리 참조 두 번으로 친다(매크로 |call|). \.{GWEB}에는 매크로가 없으니 나는
|mems++|와 |mems += 2| 따위를 그대로 쓰고, 호출 값을 얹는 자리에는 주석을 단다.

원본에서 셈 |trees|와 |mems|는 부호 없는 32비트 정수다. 셈이 $2^{32}$을 넘으면
원본은 소리 없이 한 바퀴 돌아 작은 수부터 다시 센다. 나도 둘을 |uint32|로 두어
그때도 원본과 같은 수가 찍히게 했다.

원본은 둘을 전역 변수로 두지만 나는 |main|의 지역 변수로 둔다. 이 저장소의
\.{grayspan}을 옮길 때 겪은 일인데, \GO/ 컴파일러는 전역 변수를 레지스터에
붙들어 두지 않으므로 문장마다 고치는 셈을 전역에 두면 프로그램이 눈에 띄게
느려진다. 그 대가로 다른 함수는 |mems|를 볼 수 없다. 메모리 참조를 세는
함수는 초기화 함수 |initTree| 하나뿐이라, 그 함수가 제 셈을 돌려주면 부르는 쪽이
더한다.

@<지역 변수@>=
var (
	trees        uint32 // 만들어 낸 신장 나무의 수
	mems         uint32 // 메모리 참조의 수
	verbose      bool   // 나무마다 들고 나는 변을 찍는가?
	extraverbose bool   // 속사정까지 찍는가?
	j, k         int    // 지금 관심 있는 정수들
	n            int    // 잎의 수
)

@ 자세히 찍으라고 하면 나무 하나마다 한 줄을 찍는다. \GO/의 |os.Stdout|에는
버퍼가 없어서 그대로 두면 한 줄이 시스템 호출 한 번이니, 버퍼 |out|을 거친다.
\CEE/의 |exit|와 달리 |os.Exit|는 버퍼를 비워 주지 않지만, 이 프로그램이 도중에
멈추는 것은 표준 출력에 아무것도 찍기 전, 식을 읽는 동안뿐이다. 그러니 버퍼는
|main|의 맨 끝에서 한 번만 비우면 된다.

@<전역 변수@>=
var out = bufio.NewWriter(os.Stdout) // 표준 출력의 버퍼

@* 식 읽기와 채비.
먼저 역폴란드 식을 이진 나무로 바꾼다.

다음 코드에서 우리는 이항 연산자를 $j$개 훑었고, 스택에는 항목이 $k$개 있다.
스택 항목은 잎이면 $0$이다. 연산자 $j$번이 만든 가지면 $2j+t$인데, 직렬
연산자 \.s면 $t=1$, 병렬 연산자 \.p면 $t=0$이다. 원본은 이것을 $256t+j$로 적는다.
그 차이는 맨 뒤에서 이야기한다.

이항 연산자는 식의 글자 수보다 적고 스택 깊이도 글자 수를 넘지 않으니, 배열은
식의 길이만큼 잡으면 넉넉하다. 원본은 크기를 상수 |maxn|$=1000$으로 박아 두고
넘치는지 살피지 않는다.

@<식 |os.Args[1]|을 읽어 나무 구조를 세운다@>=
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
@<큰 나무를 짓는다@>@;

@ 이항 연산자의 두 피연산자는 전역 배열 |llink|와 |rlink|에 적는다. 재귀 함수
|build|가 나중에 그것을 읽는다.

@<전역 변수@>=
var llink, rlink []int // 이진 부분 나무들

@ 식이 잘못되면 어디까지 읽었는지를 세로 막대로 표시해 알리고 멈춘다. 그런
자리가 세 곳이라 함수로 둔다.

@<함수들@>=
func abort(f string, i int, mess string) {
	fmt.Fprintf(os.Stderr, "Parsing error: %s|%s, %s!\n", f[:i], f[i:], mess)
	os.Exit(-1)
}

@ 이 단계에서는 메모리 참조를 세지 않는다. 프로그램이 처음부터 나무로 나타낸
그래프를 받는다고 보는 것이다.

@<새 잎을 만든다@>=
stack[k] = 0
k++
n++

@ @<새 가지를 만든다@>=
if k < 2 {
	abort(f, i, "missing operand")
}
t := 0
if f[i] == 's' {
	t = 1
}
j++
k--
rlink[j] = stack[k]
llink[j] = stack[k-1]
stack[k-1] = 2*j + t

@ 이제 이진 나무를 실제로 일할 나무로 바꾼다. 일할 나무의 가지 노드는 전위
순서로 놓인다.

@<자료형@>=
type node struct {
	typ    int   // 직렬 노드면 1, 아니면 0
	lchild *node // 맨 왼쪽 자식. 잎이면 |nil|
	rchild *node // 맨 오른쪽 자식. 잎이면 |nil|
	rsib   *node // 오른쪽 형제. 빙 돌아 맨 왼쪽으로 이어진다
	num    int   // 잎이면 잎의 번호, 가지면 전위 순서의 번호
	@<노드에 더할 필드@>@;
}

@ 원본의 배열 |nodelist|는 앞 절반에 잎을 |maxn|개까지, 뒤 절반에 가지를
|maxn|개까지 담는다. 나는 잎과 가지를 두 슬라이스 |leaves|와 |branches|에 따로
담는다. 크기는 식을 다 읽은 뒤에 정하니 한도가 없다. 잎은 |n|개, 가지는 많아야
연산자 수 |j|에 맨 바깥의 |topnode|를 더한 만큼이다.

원본은 노드가 잎인지를 주소로 가리고, 노드 이름도 주소에서 셈하고, 전위 순서로
왼쪽 이웃인 가지로 옮겨 갈 때도 포인터에서 하나를 뺀다. \GO/에는 포인터 산술이
없으니, 노드마다 제 슬라이스에서의 번호를 필드 |num|에 적어 둔다.

@<전역 변수@>=
var (
	leaves        []node // 잎 노드들
	branches      []node // 가지 노드들. |branches[0]|은 |topnode|다
	curleaf       int    // 아직 내주지 않은 잎 가운데 맨 왼쪽의 번호
	curnode       int    // 내준 가지 가운데 맨 오른쪽의 번호
	root, topnode *node  // 나무의 뿌리와 그 부모
)

@ 원본의 매크로 |isleaf|는 주소를 견준다. 나는 원본의 주석이 말하는 대로
맨 왼쪽 자식이 없는 것을 잎으로 본다. 필드 |lchild|는 나무를 다 지은 뒤로 바뀌지
않는다.

@<함수들@>=
func (p *node) isLeaf() bool { return p.lchild == nil }

@ 재귀 함수 |build|가 짓는 일을 맡는다.

@<큰 나무를 짓는다@>=
leaves = make([]node, n)
branches = make([]node, j+1)
topnode = &branches[0]
topnode.typ = 2 // 맨 바깥 층을 뜻하는 특별한 |typ| 부호
root = build(stack[0], topnode)
root.rsib = root // 없어도 되지만 깔끔하다

@ 함수 |build|는 잎을 지을 때는 그냥 하나 내준다. 가지를 지을 때는 그 자식들을
형제 고리로 잇는다.

꼬이는 데가 하나 있다. 직렬 노드가 직렬 자식을, 병렬 노드가 병렬 자식을 가져서는
안 된다. 그럴 때는 자식의 식구를 부모의 식구에 합치고 자식은 없앤다.

@<함수들@>=
func build(item int, par *node) *node {
	var p, l, r, lc, rc *node
	if item == 0 {
		p = &leaves[curleaf]
		p.num = curleaf
		curleaf++
		return p
	}
	t, j := item%2, item/2 // 이항 연산의 종류와 자리
	if t != par.typ {
		curnode++
		p = &branches[curnode]
		p.typ, p.num = t, curnode
	} else {
		p = par
	}
	l = build(llink[j], p)
	lc, rc = l.lchild, l.rchild
	r = build(rlink[j], p)
	@<자식 |l|과 |r|을 노드 |p| 아래에 잇는다@>@;
	return p
}

@ 자식이 노드 |p|에 합쳐졌으면 |build|는 |p| 자신을 돌려준다. 그러니 |l==p|나
|r==p|를 보고 합쳐졌는지 안다. 왼쪽 자식이 합쳐졌을 때 그 식구의 양 끝을
알아야 하므로, 오른쪽 자식을 짓기 전에 |lc|와 |rc|에 적어 두었다.

@<자식 |l|과 |r|을 노드 |p| 아래에 잇는다@>=
if l == p {
	@<왼쪽 자식을 노드 |p|에 합친다@>@;
} else if r == p {
	@<오른쪽 자식을 노드 |p|에 합친다@>@;
} else {
	p.lchild, p.rchild, l.rsib, r.rsib = l, r, r, l
}

@ @<오른쪽 자식을 노드 |p|에 합친다@>=
r = p.lchild
p.lchild = l
l.rsib = r
p.rchild.rsib = l

@ @<왼쪽 자식을 노드 |p|에 합친다@>=
if r == p {
	@<두 자식을 다 노드 |p|에 합친다@>@;
} else {
	p.rchild = r
	rc.rsib = r
	r.rsib = lc
}

@ @<두 자식을 다 노드 |p|에 합친다@>=
rc.rsib = p.lchild
p.lchild = lc
p.rchild.rsib = lc

@ 좋다, 나무를 세웠다. 다음 목표는 나무를 꾸미는 것이다. 그 전에 풀려는 문제를
좀 더 찬찬히 들여다보자.

나무의 노드는 저마다 두 꼭짓점 $u$와~$v$ 사이의 직병렬 그래프에 자연스럽게
대응한다. 잎은 변 하나 $u\adj v$다. 잎이 아닌 노드~|p|는 자식 $k\ge2$개의 변
또는 초변 $u_1\adj v_1$, \dots, $u_k\adj v_k$로 이루어진 ``초변''(superedge)에
대응한다. 노드 |p|가 직렬 노드면 자식들을 $1\le j<k$에서 $v_j=u_{j+1}$이 되게
잇고, 병렬 노드면 $u_1=\cdots=u_k$와 $v_1=\cdots=v_k$가 되게 잇는다. 어느 쪽이든
노드 |p|는 $u_1$과 $v_k$ 사이의 초변으로 여긴다.

두 꼭짓점 $u$와~$v$ 사이의 직병렬 그래프에서 {\it 거의 신장 나무\/}(near-spanning tree)란
성분이 꼭 둘인 신장 숲으로, $u$와 $v$가 서로 다른 성분에 놓인 것을 말한다.

초변 |p|가 직렬이면, 그 신장 나무는 자식마다 신장 나무를 하나씩 모은 것이다.
거의 신장 나무는 자식 하나를 지정해 그 자식에서는 거의 신장 나무를, 다른
자식들에서는 신장 나무를 지어 얻는다.

초변 |p|가 병렬이면 구실이 뒤바뀐다. 거의 신장 나무는 자식마다 거의 신장 나무를
하나씩 모은 것이고, 신장 나무는 자식 하나를 지정해 그 자식에서는 신장 나무를,
다른 자식들에서는 거의 신장 나무를 지어 얻는다.

잎 노드~|p|마다 불 값 |p.val|을 두어, 그 변이 지금 보고 있는 신장 나무에
들었는지 빠졌는지를 적는다. 가지 노드의 필드 |p.val|도 마찬가지로, 그 초변이
지금 신장 나무를 가졌는지 거의 신장 나무를 가졌는지를 적는다.

아래의 알고리즘에서 가지 노드 |p|는 저마다 지정 자식 |p.des|를 하나 가지며,
언제나 |p.val==p.des.val|이다.

값의 조합이 아무것이나 되는 것은 아니다. 위의 이야기에 따르면 올바른 조합은 두
규칙으로 정해진다.

\indent\indent 직렬 노드의 지정되지 않은 자식은 모두 값이 1이다.

\indent\indent 병렬 노드의 지정되지 않은 자식은 모두 값이 0이다.

\noindent 달리 말해 노드 |p|의 부모가 |q|이면
$$\hbox{|p.val|}=\cases{\hbox{|q.val|},&|p==q.des|일 때;\cr
\noalign{\smallskip}
\hbox{|q.typ|},&|p!=q.des|일 때.\cr}
$$
지정 자식을 어떻게 고르든, |p.val|을 1이나~0으로 두고 이 식으로 값을 잎까지
내려보내면 노드~|p|의 신장 나무나 거의 신장 나무가 하나로 정해진다.

그러므로 |root.val=1|로 두고 나무 곳곳의 지정 자식 |p.des|를 가능한 모든 방법으로
고르면, 그래프의 신장 나무를, 곧 노드 |root|의 신장 나무를 모두 만들 수 있다.

그런데 |p.des|를 달리 골라도 같은 결과가 나오는 일이 많다. 값이~1인 직렬
노드와 값이~0인 병렬 노드에서는 |p.des|가 무엇이든 상관없다. 이 문제는 나중에 다시
다루기로 하고, 우선 필요한 정보를 자료 구조에 넣어 두자.

@<노드에 더할 필드@>=
@!val int   // 0이면 꺼짐, 열림, 거의 신장; 1이면 켜짐, 닫힘, 신장
@!des *node // 지정 자식

@ 시작은 노드마다 맨 왼쪽 자식을 지정하는 것으로 하자.

노드의 |typ|과 |val|은 한 번의 메모리 참조로 읽고 쓸 수 있다고 치고
메모리 참조를 센다.

@<첫 신장 나무를 마련한다@>=
mems++
topnode.typ = 1
mems += 2 // 호출
mems += initTree(root, topnode)
trees = 1
if verbose {
	@<첫 나무를 찍는다@>@;
}

@ 나중에 자료 구조를 조금 손볼 것이지만, 나무를 초기화하는 함수는 대부분 지금
쓸 수 있다. 앞에서 말했듯 이 함수는 제가 쓴 메모리 참조의 수를 돌려준다.
되부른 자신이 쓴 것까지 모아서다.

@<함수들@>=
func initTree(p, par *node) (mems uint32) { // |par|은 |p|의 부모다
	mems += 3
	if par.des == p {
		p.val = par.val
	} else {
		p.val = par.typ
	}
	if p.isLeaf() {
		@<잎 노드의 나머지 초기화@>@;
	} else {
		mems += 2
		p.des = p.lchild
		for q := p.lchild; ; q = q.rsib {
			mems += 2 // 호출
			mems += initTree(q, p)
			mems++
			if q.rsib == p.lchild {
				break
			}
		}
		@<가지 노드의 나머지 초기화@>@;
	}
	return
}

@* 진단 루틴.
자료 구조의 전부나 일부를 찍는 간단한 함수 몇 개를 둔다. 디버깅을 돕고, 사용자가
신장 나무를 모두 보고 싶어 할 때도 쓴다.

잎에는 \.a, \.b, \.c 따위로, 가지에는 \.A, \.B, \.C 따위로 이름을 붙인다.
들어가며에서 본 예와 같다.

원본에는 함수 |xx|도 있다. 커누스는 디버깅할 때 이를테면 |xx('A')|라고 쳐서 노드
\.A의 포인터를 얻으려고 이것을 두었다. 키 누르는 수고와 머리 쓰는 수고를 덜려는
것이다. 나는 이 함수를 옮기지 않았다. 아무도 부르지 않는 함수는 \GO/의 링커가
떨어내므로 디버거 \.{dlv}에서 부를 수가 없다. 대신 \.{dlv}에서는 슬라이스를 바로
들여다보면 된다. 노드 \.A는 |branches[1]|, 잎 \.a는 |leaves[0]|이다.

@ 원본은 이름을 \.{\%c}로 찍는다. \CEE/의 \.{\%c}는 정수를 바이트 하나로 잘라
찍으니, 잎이 $31$개를 넘으면 \.{ASCII}를 벗어난 이름이 바이트 그대로
나간다. \GO/의 \.{\%c}는 같은 수를 유니코드 문자로 보고 UTF-8로 찍으므로,
나는 이름을 바이트 하나짜리 문자열로 만들어 \.{\%s}로 찍는다. 바이트 덧셈은
$256$을 법으로 돌므로 잎이 $256$개를 넘을 때도 원본과 같은 바이트가 나온다.
가지 \.A는 |branches[1]|이고 |branches[0]|은 |topnode|다.

@<함수들@>=
func (p *node) name() string {
	var c byte
	if p.isLeaf() {
		c = 'a' + byte(p.num)
	} else {
		c = 'A' + byte(p.num-1)
	}
	return string([]byte{c})
}

@ 나무 전체를 찍는 함수는 들여쓰기로 깊이를 보인다. 노드마다 한 줄이다.

@<함수들@>=
func printTree(p *node, indent int) {
	for k := 0; k < indent; k++ {
		out.WriteByte(' ')
	}
	if p.isLeaf() {
		@<잎 노드 |p|를 찍는다@>@;
	} else {
		@<가지 노드 |p|를 찍는다@>@;
		for q := p.lchild; ; q = q.rsib {
			printTree(q, indent+1)
			if q.rsib == p.lchild {
				break
			}
		}
	}
}

@ @<잎 노드 |p|를 찍는다@>=
fmt.Fprintf(out, "%s:%d rsib=%s\n", p.name(), p.val, p.rsib.name())

@ @<가지 노드 |p|를 찍는다@>=
fmt.Fprintf(out, "%s:%d rsib=%s lchild=%s des=%s rchild=%s",
	p.name(), p.val, p.rsib.name(),
	p.lchild.name(), p.des.name(), p.rchild.name())
@<가지 노드에 더한 필드를 찍는다@>@;
out.WriteByte('\n')

@ 다음 함수는 값이 1인 잎, 곧 지금 신장 나무에 든 변을 찍는다.

@<함수들@>=
func printEdges(p *node) {
	if p.isLeaf() {
		if p.val != 0 {
			out.WriteString(p.name())
		}
	} else {
		for q := p.lchild; ; q = q.rsib {
			printEdges(q)
			if q.rsib == p.lchild {
				break
			}
		}
	}
}

@ @<첫 나무를 찍는다@>=
if extraverbose {
	printTree(root, 0)
}
fmt.Fprint(out, "The first spanning tree is ")
printEdges(root)
fmt.Fprint(out, ".\n")

@* 알고리즘의 개요.
가지 노드 |p|가 |p.val==p.typ|이면 {\it 쉽다\/}고 하자. 그때는 자식이 모두 같은
값을 가지므로 지정 자식 |p.des|가 신장 나무나 거의 신장 나무에 아무 영향을 주지
않는다.

편의상 노드 |p|의 {\it 구성\/}(config)이란, |p.val==1|이면 그 신장 나무를,
|p.val==0|이면 그 거의 신장 나무를 말한다고 하자. 우리 문제는 뿌리의 구성을 모두
만들어 내는 것이다.

노드 |p|가 쉬우면 그 구성은 자식들의 구성의 데카르트 곱이다. 쉽지 않으면 그런
데카르트 곱들의 합집합인데, 합집합은 |p.des|를 고르는 모든 방법에 걸쳐 취한다.

쉬운 노드는 비교적 드물다. 쉽지 않은 노드의 자식 가운데 쉬울 수 있는 것은 많아야
하나, 곧 지정 자식뿐이다. 그리고 쉬운 노드의 자식은 잎이 아닌 한 모두 쉽지 않다.

원본의 매크로 |easy|는 메모리 참조 하나를 함께 센다. 메서드는 |mems|를 볼 수
없으니 부르는 쪽이 센다.

@<함수들@>=
func (p *node) easy() bool { return p.typ == p.val }

@ 구성의 데카르트 곱은 그레이 부호 순서로 쉽게 만들 수 있다. 본질적으로 $n$짝을
위한 혼합 기수 그레이 부호를 쓰면 된다({\sl The Art of Computer Programming\/}의
7.2.1.1절을 보라). 이 프로그램은 ``반사'' 부호 대신 ``모듈러'' 부호를 쓴다.
모듈러 부호에서는 |p.des|의 후보를 돌아가며 고르는 데 |rsib| 고리만 있으면 되기
때문이다.

노드마다 새 필드 |p.leaf|를 두자. 노드 |p|에서 지정 자손 |p.des|, |p.des.des|,
\dots{}를 따라 내려간 경로의 끝에 있는 잎을 가리킨다. 이 경로에 놓인 노드의
|val| 필드는 모두 |p.val|과 같다.

지정 자식 |p.des|가 한 자식에서 다른 자식으로, 이를테면 |q|에서 |r|로 바뀌면 신장
나무 전체에서 변 값이 둘만 바뀐다. 곧 |q.typ!=p.typ|이고 |r.typ==p.typ|이므로,
|q.leaf.val|은 |r.typ|이 되고 |r.leaf.val|은 |q.typ|이 된다. 그러니 이런 바꿈은
흐뭇하게도 ``그레이''하다.

@<노드에 더할 필드@>=
@!leaf   *node // 지정 경로의 끝
@!parent *node // 이 노드의 부모

@ 이런 생각을 따라가면 신장 나무를 모두 만드는 다음 알고리즘에 이른다. 처음에는
쉽지 않은 가지 노드를 모두 활성으로 둔다. 그리고 다음을 되풀이한다.
\smallskip\itemitem{1)} 전위 순서로 맨 오른쪽의 활성 노드 |p|를 고른다.
\smallskip\itemitem{2)} 지정 자식 |p.des|를 |p.des.rsib|로 바꾸고, 나무의 값을
모두 고치고, 새 신장 나무를 방문한다.
\smallskip\itemitem{3)} 노드 |p|의 오른쪽에 있는 쉽지 않은 노드를 모두 활성으로
만든다.
\smallskip\itemitem{4)} 노드 |p|가 마지막으로 활성이 된 뒤로 |p.des|가 |p|의
자식을 한 바퀴 다 돌았으면 노드~|p|를 비활성으로 만든다.
\smallskip\noindent
단계 (4)를 구현하려고 필드 |p.done|을 들인다. 노드~|p|는 |p.des==p.done|일 때
비활성이 되고, 그때 |p.done|을 |p.des|의 바로 앞 값으로 되돌려 놓는다.

사실 |p.done|의 처음 값은 |p.rchild|와 같고, 주 알고리즘에는 |rchild| 포인터가
필요 없다. 그러니 |p.done|을 |p.rchild|와 같은 것으로 삼을 수 있다. 원본은 매크로로
필드 |rchild|에 새 이름 |done|을 붙이지만, \.{GWEB}에는 매크로가 없으니 이 판은
알고리즘에서도 |p.rchild|라고 쓰고 그 자리에 주석을 단다.

@ 예를 들어 들어가며에서 본 직병렬 그래프에 이 알고리즘을 써 보자. 노드 |A|는
병렬 노드이고 처음에는 맨 왼쪽 자식을 지정하므로, |initTree|는 |A.val=1|,
|B.val=0|, |C.val=1|, |D.val=0|으로 두고 첫 신장 나무는 변 $\it aceg$로 이루어진다.
가지 노드 넷이 처음에는 모두 쉽지 않다. (이것은 우연일 뿐 일반적인 규칙이 아니다.)

알고리즘이 어디까지 왔는지는 지정 자식을 아래 첨자로 적고, 쉬운 노드를 괄호로
감싸고, 비활성 노드 위에 모자를 씌워 나타낼 수 있다. 이렇게 적으면 알고리즘은
다음과 같이 나아간다.
$$\vcenter{\halign{\hbox to2.1em{\hfil$#$\hfil}&
                   \hbox to2.1em{\hfil$#$\hfil}&
                   \hbox to2.1em{\hfil$#$\hfil}&
                   \hbox to2.1em{\hfil$#$\hfil}&
\hskip5em          \hbox to.6em{\hfil$#$\hfil}&
                   \hbox to.6em{\hfil$#$\hfil}&
                   \hbox to.6em{\hfil$#$\hfil}&
                   \hbox to.6em{\hfil$#$\hfil}\cr
\multispan4\hidewidth 가지 노드의 상태\hidewidth&
\multispan4\qquad\qquad 신장 나무\cr
\noalign{\smallskip}
A_a&B_b&C_c&D_f&a&c&e&g\cr
A_a&B_b&C_c&\widehat D_g&a&c&e&f\cr
A_a&B_b&\widehat C_d&D_g&a&d&e&f\cr
A_a&B_b&\widehat C_d&\widehat D_f&a&d&e&g\cr
A_a&B_C&(C_d)&D_f&a&b&e&g\cr
A_a&B_C&(C_d)&\widehat D_g&a&b&e&f\cr
A_a&\widehat B_e&C_d&D_g&a&b&d&f\cr
A_a&\widehat B_e&C_d&\widehat D_f&a&b&d&g\cr
A_a&\widehat B_e&\widehat C_c&D_f&a&b&c&g\cr
A_a&\widehat B_e&\widehat C_c&\widehat D_g&a&b&c&f\cr
A_B&(B_e)&C_c&D_g&b&c&e&f\cr
A_B&(B_e)&C_c&\widehat D_f&b&c&e&g\cr
A_B&(B_e)&\widehat C_d&D_f&b&d&e&g\cr
A_B&(B_e)&\widehat C_d&\widehat D_g&b&d&e&f\cr
\widehat A_D&B_e&C_d&(D_g)&b&d&f&g\cr
\widehat A_D&B_e&\widehat C_c&(D_g)&b&c&f&g\cr
\widehat A_D&B_b&C_c&(D_g)&c&e&f&g\cr
\widehat A_D&B_b&\widehat C_d&(D_g)&d&e&f&g\cr
\widehat A_D&\widehat B_C&(C_d)&(D_g)&b&e&f&g\cr
}}$$
그러니까 먼저 |D.des|를 |f|에서 |g|로 바꾸고 노드~|D|를 비활성으로 만든다. 다음에는
|C.des|를 |c|에서 |d|로 바꾸고 노드~|C|를 비활성으로 만든다. 네 걸음 뒤에는
|B.des|를 |b|에서 |C|로 바꾸어 노드 |C|를 쉬운 노드로 만들고, 그렇게 이어진다.

@ 이른바 ``초점 포인터''를 쓰면 단계 (1)과 (3)을 아주 효율적으로 구현할 수 있다.
알고리즘 7.2.1.1L에서 이야기한 그대로다. 노드 |p|가 쉽지 않고 오른쪽으로 가장
가까운 쉽지 않은 노드가 활성일 때를 빼면 늘 |p.focus=p|로 둔다. 그리고 가지
|branches[curnode]|, 곧 나무 전체에서 전위 순서로 맨 오른쪽의 가지 노드 오른쪽에
쉽지 않은 활성 노드가 하나 더 있다고 상상한다. 그러면 |r|이 맨 오른쪽의 쉽지 않은
노드일 때, 간단한 연산
$$\hbox{|p=r.focus|, \ |r.focus=r|}$$
이 단계 (1)과 (3)을 구현한다. 단계 (2)가 몇몇 노드를 쉬운 것에서 쉽지 않은 것으로,
또 그 거꾸로 바꾸는데도 그렇다(!).

게다가 |l|이 노드 |p|의 왼쪽에 있는 쉽지 않은 노드 가운데 맨 오른쪽 것이면,
간단한 연산
$$\hbox{|p.focus=l.focus|, \ |l.focus=l|}$$
로 단계 (4)에서 노드 |p|를 비활성으로 만들 수 있다. 전위 순서로 무엇보다 왼쪽에
있는 |topnode|는 언제나 쉽지 않고 활성이라고 상상한다. 그러면 |l|은 언제나 있다.
단계~(1)에서 |p==topnode|가 되면 멈춘다. 그때는 신장 나무를 모두 만든 것이다.

@<노드에 더할 필드@>=
@!focus *node // 그레이 부호를 위한 마법의 초점 포인터

@ 새 필드들은 초기화 함수에 쉽게 끼워 넣을 수 있다. 알고리즘이 |leaf|나 |parent|
포인터를 실제로 들여다볼 필요는 없다는 것이 드러날 것이므로, 그것들을 셈하는
값은 메모리 참조로 치지 않는다.

@<잎 노드의 나머지 초기화@>=
p.leaf, p.parent = p, par

@ @<가지 노드의 나머지 초기화@>=
p.leaf, p.parent = p.des.leaf, par
mems++
p.focus = p

@ @<가지 노드에 더한 필드를 찍는다@>=
fmt.Fprintf(out, " leaf=%s", p.leaf.name())
if p.focus != p {
	fmt.Fprintf(out, " focus=%s", p.focus.name())
}

@* 해 보기.
이제 앞에서 밑그림을 그린 알고리즘을 구현하자.

원본은 포인터에서 하나를 빼서 전위 순서로 왼쪽 이웃인 가지로 옮겨 간다. 이
판에서는 번호 |i|를 하나씩 줄이며 |branches[i]|를 본다. 맨 오른쪽의 쉽지 않은
노드를 찾는 이 반복문은 |topnode|에서 반드시 멈춘다. 노드 |topnode|는 |typ|이
1이고 |val|이 0이어서 언제나 쉽지 않기 때문이다.

@<알고리즘을 돌린다@>=
topnode.focus = topnode
for {
	var p, q, l, r *node
	for i := curnode; ; i-- { // 맨 오른쪽의 쉽지 않은 노드를 찾는다
		r = &branches[i]
		mems++
		if !r.easy() {
			break
		}
	}
	mems += 2
	p, r.focus = r.focus, r // 단계 (1)과 (3)
	if p == topnode {
		break
	}
	@<지정 자식 |p.des|를 바꾸고 새 신장 나무를 방문한다@>@;
	mems++
	if p.des == p.rchild { // 필드 |rchild|는 이제 |done|이다
		@<노드 |p|를 비활성으로 만든다@>@;
	}
}

@ 노드 |p|의 오른쪽에 있는 쉽지 않은 노드는 이제 모두 활성이다. 그리고 |l|은
|p.des|의 바로 앞 값이다.

@<노드 |p|를 비활성으로 만든다@>=
mems++
p.rchild = l // 곧 |p.done=l|
for i := p.num - 1; ; i-- { // 왼쪽으로 처음 만나는 쉽지 않은 노드를 찾는다
	l = &branches[i]
	mems++
	if !l.easy() {
		break
	}
}
mems += 3
p.focus, l.focus = l.focus, l

@ 사용자가 |verbose|를 바랐으면 신장 나무에 들어온 변과 나간 변만 찍는다.
옛 지정 자식 |l|에서 내려가는 경로는 값이 |k|에서 |k^1|로, 새 지정 자식 |r|에서
내려가는 경로는 |k^1|에서 |k|로 바뀐다. 그러니 |k==1|이면 앞 경로 끝의 변이
나가고 뒤 경로 끝의 변이 들어온다. 부호 \.+와 \.-는 문자열 |"+-"|와 |"-+"|를
|k|로 짚어 고른다.

@<지정 자식 |p.des|를 바꾸고 새 신장 나무를 방문한다@>=
mems += 2
l, r = p.des, p.des.rsib
mems++
k = p.val // |k==l.val!=r.val|
@<옛 지정 경로의 값을 |k^1|로 바꾼다@>@;
if verbose {
	fmt.Fprintf(out, " %c%s", "+-"[k], q.name())
}
@<새 지정 경로의 값을 |k|로 바꾼다@>@;
if verbose {
	fmt.Fprintf(out, "%c%s\n", "-+"[k], q.name())
}
mems++
p.des = r
trees++ // ``방문''
@<|leaf| 포인터를 고친다@>@;

@ 원본의 반복문 |for (q=l;;o,q=q->des)|는 다음 노드로 내려갈 때 메모리 참조
하나를 센다. 이 판은 그것을 몸통 끝에서 센다. 잎에서 빠져나갈 때는 내려가지
않으니 세지 않는다.

@<옛 지정 경로의 값을 |k^1|로 바꾼다@>=
for q = l; ; q = q.des {
	mems++
	q.val = k ^ 1
	if q.isLeaf() {
		break
	}
	mems++ // |q=q.des|
}

@ @<새 지정 경로의 값을 |k|로 바꾼다@>=
for q = r; ; q = q.des {
	mems++
	q.val = k
	if q.isLeaf() {
		break
	}
	mems++ // |q=q.des|
}

@ 지정 자식이 |r|로 바뀌었으니, |p|와 그 위로 지정 경로가 이어진 조상들의
|leaf|를 고친다. 이 반복문은 없어도 되는 것이라 메모리 참조를 세지 않는다.

@<|leaf| 포인터를 고친다@>=
for q = p; q.des == r; r, q = q, q.parent {
	q.leaf = r.leaf
}
if extraverbose {
	printEdges(root)
	fmt.Fprintf(out, "; now %s->leaf=%s\n", r.name(), r.leaf.name())
}

@* 루프 없는 판.
여기서 구현한 알고리즘에는 반복문이 넷 있다. 둘은 가지 목록에서 |r|과 |l|을
찾으며 쉬운 노드를 건너뛰고, 둘은 |val| 필드를 바꾸며 가지에서 잎까지 내려간다.

이 반복문들의 분할 상환 비용은 새 신장 나무 하나에 상수다. 그래도 완전히 루프
없는 알고리즘, 곧 (처음에 선형 시간으로 채비를 마친 뒤로는) 새 나무 하나에 드는
연산의 수가 유계인 알고리즘을 찾아보는 일에는 배울 것이 있다.

루프 없는 알고리즘은 루프 있는 짝보다 느린 경향이 있다. 지금처럼 루프를 피하는
데 드는 덧비용이 꽤 커 보이는 경우에는 더 그렇다. 그러니 루프 없는 구현을 찾는
것은 순전히 학문적인 일이다. 그런데도 충분히 매혹적이어서, 커누스는 휴가 때 사흘을
여기에 매달렸다고 한다.

커누스는 방법을 알 것 같다고 했다. 다만 세부를 다 해낼 시간이 없어 밑그림만
그려 둔다고, 누군가 영감을 얻어 이를 마무리하고 루프 없는 판의 메모리 참조 수를
지금 구현과 견주어 주면 좋겠다고 했다. 아래가 그 밑그림이다.

처음 두 반복문은 나무를 동적으로 바꾸어 지정 자식이 늘 맨 왼쪽 자식이 되게 하면
피할 수 있다. 그러면 쉬운 노드 둘이 전위 순서로 잇달아 놓이는 일이 없음을 쉽게 알
수 있다. 커누스가 계획한 구현은 |p.des|를 바꾸어야 할 때 맨 오른쪽 자식을 맨 왼쪽
자리로 옮긴다. 이렇게 옮기면 전위 순서로 늘어선 노드 목록에서 이웃한 두 부분
문자열이 자리를 맞바꾼다. 노드 목록은 이중으로 이어야 하고, 맞바꾸려면 새 필드
|p.scope|가 있어야 한다. 지금의 목록에서 |p|의 자손인 가지 가운데 맨 오른쪽 것을
가리키는 필드다.

나머지 두 반복문은 |val| 필드를 아래에서부터 게으르게 고치면 피할 수 있다.
그러면 포인터 |p.leaf|가 있으면 좋은 것이 아니라 꼭 있어야 하는 것이 된다. 잎
노드를 먼저 만나게 되고, 신장 나무에 들고 나는 변을 알리려면 |p.leaf|와
|p.rchild.leaf|를 둘 다 알아야 하기 때문이다.

물론 꼭 있어야 하는 필드 |p.scope|와 |p.leaf|를 들이면 그것들을 관리해야 하고,
그러자면 지금 구현에서는 필요 없던 반복문이 더 있어야 할 것처럼 보인다. 다행히
그것들을 그때그때 고칠 필요는 없다. 노드 |p|가 알고리즘의 단계~(2)에서 결정적
노드일 때만 맞으면 된다.

커누스의 해법은 ``등록''을 위한 필드 둘을 더 들이는 것이다. 노드의 열 $p_1$,
$p_2$, \dots, $p_k$가 있어 $1\le j<k$에서 $p_{j+1}$이 $p_j$의 맨 오른쪽 자식이고,
$p_1$과 $p_k$는 활성이며 나머지는 쉽거나 비활성이라 하자. 그러면 $p_2$, \dots,
$p_{k-1}$ 가운데 쉬운 것들은 잇달아 놓이지 않고, 쉽지 않은 것들은 가장 최근에
왼쪽에서 오른쪽 차례로 비활성이 되었다. 결정적 노드가 $p=p_k$이면 우리는 $p$
아래의 나무를 다시 늘어놓을 참이다. 그리고 그다음에 노드 |p|가 비활성이 될
참이면, 지금이 $p_1$의 범위 고리를 고칠 마지막 기회다.

노드 $p$는 초점 포인터로 $p_1$을 찾을 수 있다. 활성 노드 가운데 $p$의 왼쪽에서
가장 가까운 것이 바로 $p_1$이기 때문이다. 그러나 $p_1$에서 $p_k$까지 앞에서 말한
경로가 정말 있는지 확인해야 한다. 아무 노드의 |scope| 고리나 망쳐서는 안 되기
때문이다. 결정적 노드를 |p|, 그 왼쪽의 첫 활성 노드를 |q|라 하자. 노드 |p|에서
|parent| 포인터를 따라 한두 층 올라가 쉽지 않은 노드, 이를테면 |u|에 닿는다. 다만
올라가는 걸음이 맨 오른쪽 가지 자식에서 부모로 가는 것이 아니면 멈춘다. 그렇지
않을 때 |q==u|이면 잘됐다. |q.scope|를 고치고 끝이다. 또 |q==u.registry|이면(필드
|registry|는 새것인데, 곧 더 이야기한다) 역시 |q.scope|를 고친다. 둘 다 아니면
노드 |q|는 |p|에 이르는 먹이 사슬의 꼭대기가 아니라고 결론짓는다.

결정적 노드 |p|가 비활성이 될 때, 그 전에 |q.scope|를 고친 경우였으면
|p.registry=q|로 두고, |q==u.registry|였던 경우에는 |u.registry=nil|로도 둔다.
이렇게 손을 맞잡아 필요한 정보를 나무 아래로 넘기고, 그릇된 진단을 부를 수 있는
엉뚱한 |registry| 값을 남기지 않는다.

포인터 |leaf|도 비슷한 방법으로 관리할 수 있다. 맨 오른쪽 자식 대신 맨 왼쪽
자식을 따른다는 것만 다르다. 그러니 |p.registry| 하나가 아니라
|p.scopeRegistry|와 |p.leafRegistry|라고 했어야 했다.

(휴.)

@* 옮기며 고친 것.
원본은 스택 항목에 이항 연산의 종류와 자리를 함께 담는다. 직렬이면 $256$을 더한
$256t+j$로 적고, 거꾸로 |t=item>>8|, |j=item&0xff|로 푼다. 연산자 번호 $j$가 아래
여덟 비트에 들어가야 하니 이항 연산자가 $255$개를 넘으면 셈이 틀어진다. 잎을
$1000$개까지 받으려고 잡은 |maxn|에 견주면 훨씬 이른 한계다.

실제로 원본에 잎 $257$개를 나란히 놓은 식 \.{-}$\,(\.{-p})^{256}$을 주면 신장
나무가 $257$개여야 하는데 $1$개라고 답한다. 연산자 $256$번이 남긴 병렬 항목
$256$이 직렬인 $0$번 연산으로 읽혀서, 잎 둘을 이은 나무만 남기 때문이다.

잎 $257$개를 한 줄로 이은 식 \.{-}$\,(\.{-s})^{256}$에서는 마지막 항목
$256+256=512$가 |typ|이 $2$인 $0$번 연산으로 읽힌다. 노드 |topnode|의 |typ|도
$2$이니 이 가지는 |topnode|에 합쳐지고, 뿌리가 |topnode| 자신이 된다. 그러면
|topnode|의 값과 |typ|이 둘 다 $1$이 되어 쉬운 노드가 되니, 맨 오른쪽의 쉽지 않은
노드를 찾는 반복문이 |topnode|에서 멈추지 않고 그 아래 잎 구역으로 내려간다.
반복문은 잎 \.b에서 멈추는데 잎의 |focus|는 널 포인터라서, 바로 다음에 지정
자식 |p.des|를 읽다가 세그먼테이션 오류로 죽는다(종료 부호 $139$).

이 판은 $2j+t$로 적으니 이런 한계가 없다. 연산자가 $255$개 이하인 식에서는
원본과 똑같이 짓는다. 잎이 $256$개를 넘으면 이름이 한 바퀴 돌아 겹치지만, 그것은
원본도 마찬가지이고 찍는 말에만 영향이 있다.

@* 맞춰 보기.
원본을 \.{ctangle}로 풀어 컴파일하고 이 판과 견주었다. (요즘의 \CEE/ 컴파일러는
반환형이 없는 원본의 |main|을 받지 않으니 \.{-std=gnu89}를 주었다.)

\smallskip
\item{$\bullet$} 식은 모두 $514$개다. 손으로 쓴 것 $15$개에는 잘못된 식(빈 식,
피연산자가 모자란 식, 끊어진 식, 엉뚱한 글자가 든 식)이 섞였다. 잎이 $2$개에서
$8$개인 무작위 식을 잎 수마다 $40$개, $9$개에서 $29$개인 것을 잎 수마다 $8$개까지,
$30$개에서 $254$개인 것을 몇 개씩 만들었다. 잎이 많은 식은 직렬을 많이 섞어
신장 나무가 $30$만 개를 넘지 않게 했다. 끝으로 연산자가 $254$개인 긴 사슬 둘과
$40$개인 사슬 둘을 더했다.
\item{$\bullet$} 식마다 인자를 더 주지 않고, 하나 더 주고, 둘 더 주어 세 번
돌렸다. 다만 나무가 $3$만 개를 넘는 식은 아주 자세히 찍는 것을 뺐다. 그렇게
$1504$가지 모두에서 표준 출력, 표준 오류(말에 든 프로그램 이름은 빼고), 종료
부호가 바이트까지 같았다. 잎이 $31$개를 넘어 \.{ASCII} 밖의 이름이 나오는 출력도
같다. 인자가 없을 때의 말과 종료 부호 $0$도 같다.
\item{$\bullet$} 답이 옳은지는 원본과 따로 파이썬으로 따져 보았다. 직렬이면
$(T,N)=(T_1T_2,\;N_1T_2+T_1N_2)$, 병렬이면 $(T_1N_2+N_1T_2,\;N_1N_2)$로 신장
나무의 수 $T$와 거의 신장 나무의 수 $N$을 셈하면, 모든 식에서 이 판이 센 나무의
수와 같다. 잎이 $26$개 이하인 식 $429$개에서는 자세히 찍은 출력을 따라가며, 걸음마다
나무에 든 변이 빠지고 들지 않은 변이 드는지, 나무가 모두 서로 다른지도 보았다.
\smallskip

\noindent 빠르기도 견주었다. 식 $f_0=\.{--p}$에서 $f_{i+1}=\.-f_i\.{s-s-p}$로 사다리를
늘여 간 $f_{15}$는 신장 나무가 $708158977$개다. 메모리 참조는 $2^{32}$을 넘어 한
바퀴 돌고, 두 프로그램이 똑같이 $2314246072$를 찍는다. 원본은 $3.3$초, 이 판은
$5.3$초 걸렸다.

이 판이 $1.6$배 느린 까닭은 셈이 아니다. 시험 삼아 반복문 안의 출력과 |mems|를
모두 지워도 $5.1$초이고, 노드를 원본처럼 $64$바이트로 줄여도 그대로다. 짜 낸
기계어를 보면 \GO/는 힙에 포인터를 쓸 때마다 쓰레기 수집기의 쓰기 장벽이 켜졌는지
살피고, |branches[i]|를 짚을 때마다 경계를 검사한다. 이 알고리즘은 나무 하나에
포인터 서넛을 쓰고 몇 걸음 안 가서 다음 나무로 넘어가니, 그런 작은 검사들이
고스란히 드러나는 것이라고 나는 짐작한다. 포인터 대신 번호로 노드를 가리키면
쓰기 장벽은 없앨 수 있겠지만, |p.des.rsib|가 |nodes[nodes[p].des].rsib|처럼 되어
읽기가 훨씬 나빠진다. 나는 읽기 쉬운 쪽을 골랐다.

@* 색인.
