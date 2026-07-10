@i types.w
@s testing.T int
@s testing.B int

\input kotexgweb
\input pdfpic

\def\title{Zip Trees}
\datethis

@** 들어가며.
{\it 짚트리\/}(zip tree)는 Tarjan, Levy, Timmel이 소개한 {\it 무작위 이진
검색 트리\/}다. 여느 이진 검색 트리처럼 각 노드는 키를 가지고 왼쪽 부분트리의
키는 모두 자기보다 작고 오른쪽 부분트리의 키는 모두 자기보다 크다.
여기에 더해 노드마다 정수 {\it 랭크\/}를 하나씩 두고, 트리가 랭크에 대해
{\it 최대 힙\/} 꼴이 되도록 유지한다. 곧 어떤 노드의 랭크는 그 자식들의 랭크보다
크거나 같다. 키는 검색을, 랭크는 균형을 맡는 셈이다.

랭크를 {\it 무작위로\/} 고르되 그 분포를 잘 잡으면, 트리의 모양은 거의 늘
납작해진다. 짚트리의 기대 깊이는 $1.5\lg n$ 남짓으로, $n$이 아무리 커도
검색과 갱신이 $O(\log n)$에 끝난다. 같은 성질을 가진 자료구조로 {\it 트립\/}
(treap)과 {\it 스킵 리스트\/}(skip list)가 있는데, 짚트리는 트립과 본질적으로
같으면서 랭크를 {\it 기하분포\/}에서 뽑아 노드마다 필요한 비트 수를 $O(\log n)$
에서 $O(\log\log n)$으로 줄였고, 스킵 리스트와는 자연스러운 동형 관계를 이룬다.

이 글의 백미는 갱신 방법이다. 보통의 균형 트리가 {\it 회전\/}으로
모양을 고치는 것과 달리, 짚트리는 검색 경로를 키 기준으로 두 갈래로 {\it 가르고\/}
(unzip), 거꾸로 두 경로를 {\it 엮어\/}(zip) 합친다. 지퍼를 올리고 내리듯 경로를
풀고 잠그는 이 연산이 이름의 유래이며, 노드마다 자식 포인터를 많아야 한 번만
바꾸므로 회전보다 빠르다. 이 글에서는 노드 구조와 무작위 랭크부터 삽입(언지핑),
삭제(지핑), 검색까지 차례로 구현한다.

@ 이 코드는 실행 파일이 아니라 {\it 라이브러리\/}다. 상위 프로그램에 끼워 쓰는
자료구조 묶음이므로 |main| 함수가 없다. 대신 구현이 제대로 도는지 확인하는 검사
프로그램 \.{ziptree\_test.go}를 따로 둔다. \.{ziptree.go}의 뼈대는 이렇다.
@c
package ziptree

import (
	"math/bits"
	"math/rand"
)

@<노드와 트리@>
@<무작위 랭크@>
@<검색@>
@<삽입@>
@<지핑@>
@<삭제@>
@<인덱스 기반 아레나@>
@<의사난수 랭크 트리@>

@* 노드와 랭크.
노드는 키 |key|, 랭크 |rank|, 그리고 두 자식 포인터 |left|, |right|를 가진다.
트리 전체는 뿌리 |root|와 난수원 |rng|를 묶은 |zipTree|로 들고 다닌다. 난수원을
트리에 품어 두면 씨앗을 고정해 결과를 재현하기 좋다. 트리를 만들 때는
|&zipTree{rng: rand.New(rand.NewSource(seed))}|처럼 난수원을 하나 쥐여 준다.
@<노드와 트리@>=
type node struct {
	key         int
	rank        int
	left, right *node
}

type zipTree struct {
	root *node
	rng  *rand.Rand
}

@ 랭크는 {\it 평균 1인 기하분포\/}에서 뽑는다. 곧 랭크가 음이 아닌 정수 |k|일
확률이 $1/2^{k+1}$이다($k=0$이 절반, $k=1$이 사분의 일, $\ldots$). 왜 하필 이
분포일까? 노드의 개수 |n|이 $2^{h+1}-1$개인 {\it 완전\/} 이진 트리에서 높이가 |k|인 노드의
비율이 꼭 $1/2^{k+1}$이기 때문이다. 새 노드에 이 분포대로 ``높이''에 해당하는
랭크를 매기고 랭크로 힙 순서를 지키면, 완전 트리의 층 구조를 기댓값으로 흉내 내게
된다. 게다가 가장 큰 랭크조차 거의 확실히 $\lg n + O(1)$을 넘지 않아, 랭크를
저장하는 데 $\lg\lg n + O(1)$비트면 족하다.

뽑는 법은 동전 던지기 그대로다. 앞면이 나오는 동안 세다가 뒷면이 나오면 멈추고,
그때까지 나온 앞면의 수를 랭크로 삼는다. 첫 던지기에서 바로 뒷면(확률 $1/2$)이면
랭크는 $0$이다.
@<무작위 랭크@>=
func (t *zipTree) randomRank() int {
	k := 0
	for t.rng.Intn(2) == 1 { // 앞면이면 계속
		k++
	}
	return k
}

@ 힙 순서에는 미묘한 단서가 하나 붙는다. 같은 랭크가 둘 이상 나올 수 있으므로,
{\it 동점은 키가 작은 쪽을 위로\/} 올린다고 약속한다. 정확히 말하면 어떤 노드의
랭크는 {\it 왼쪽\/} 자식의 랭크보다 {\it 크고\/}, {\it 오른쪽\/} 자식의 랭크보다
{\it 크거나 같다\/}. 이 비대칭이 ``작은 키 우선''이라는 동점 규칙을 포인터 모양으로
새긴 것이다. 이 규칙 덕분에 키와 랭크만 주어지면 트리 모양이 유일하게 정해진다.
그래서 짚트리는 {\it 역사 독립적\/}이다. 어떤 순서로 넣고 뺐든 지금 든 노드들의
키와 랭크만으로 모양이 결정된다. 검색은 보통의 이진 검색 그대로다.
@<검색@>=
func (t *zipTree) Contains(key int) bool {
	for x := t.root; x != nil; {
		switch {
		case key == x.key:
			return true
		case key < x.key:
			x = x.left
		default:
			x = x.right
		}
	}
	return false
}

@* 삽입과 언지핑.
새 키 |key|를 넣으려면, 먼저 랭크를 뽑아 노드 |x|를 만든다. 그리고 키 순서로
검색 경로를 내려가다가, |x|가 들어설 자리, 곧 |x|보다 랭크가 낮은(랭크가 같으면
키가 더 큰) 첫 노드를 만나는 지점에서 그 아래 경로를 {\it 언지핑\/}한다. 경로를
|x|보다 키가 작은 노드들의 사슬 $P$와 키가 큰 노드들의 사슬 $Q$로 가르고, $P$의
꼭대기를 |x|의 왼쪽 자식, $Q$의 꼭대기를 |x|의 오른쪽 자식으로 삼는다. 언지핑은
$P$ 노드들의 왼쪽 부분트리와 $Q$ 노드들의 오른쪽 부분트리를 고스란히 보존한다.

아래 |insert|는 이 과정을 재귀로 우아하게 풀어낸다. 키로 내려가다 빈 자리에
다다르면 |x|를 돌려주고, 되돌아 올라오며 매 노드에서 ``|x|가 나보다 위로 와야
하는가''를 랭크로 판정한다. 위로 와야 하면 그 노드를 |x|의 자식 사슬($P$ 또는
$Q$)에 이어 붙이고 |x|를 위로 올린다(이것이 언지핑의 한 걸음이다). 아니면 |x|는
이미 제자리에 박혔으므로 현재 노드를 그대로 돌려준다. 동점 규칙대로 왼쪽은
{\it 진짜 작을 때\/}(|<|), 오른쪽은 {\it 작거나 같을 때\/}(|<=|) |x|를 올린다.
@<삽입@>=
func insert(x, root *node) *node {
	if root == nil {
		return x
	}
	if x.key < root.key {
		if insert(x, root.left) == x {
			if x.rank < root.rank {
				root.left = x
			} else {
				root.left = x.right
				x.right = root
				return x
			}
		}
	} else {
		if insert(x, root.right) == x {
			if x.rank <= root.rank {
				root.right = x
			} else {
				root.right = x.left
				x.left = root
				return x
			}
		}
	}
	return root
}

@ 바깥에서 부르는 |Insert|는 랭크를 뽑아 새 노드를 만들고 재귀를 시작한다. 랭크는
방향을 정하는 데는 쓰이지 않고 오직 언지핑 판정에만 쓰이므로, 내려가기 전에 미리
정해 두어도 결과가 같다. 같은 키를 다시 넣으면 재귀가 깨질 수 있으니, 이미 있는
키면 조용히 넘어간다.
@<삽입@>=
func (t *zipTree) Insert(key int) {
	if t.Contains(key) {
		return
	}
	x := &node{key: key, rank: t.randomRank()}
	t.root = insert(x, t.root)
}

@* 지핑.
{\it 지핑\/}은 언지핑의 역연산이다. 모든 키가 |y|쪽보다 작은 사슬 |x|와 큰 사슬
|y|를, 랭크가 위에서 아래로 줄지 않도록 하나의 경로로 엮는다. 두 꼭대기를 견주어
랭크가 큰 쪽을 위에 놓고, 그 자리를 채운 뒤 나머지를 재귀로 마저 엮는다. |x|가
이기면(랭크가 크거나 같으면) |x|를 위에 두고 |x|의 오른쪽 자리를 잇고, |y|가
이기면 |y|를 위에 두고 |y|의 왼쪽 자리를 잇는다. 동점이면 |else|로 가 |x|가
위로 오는데, |x|는 키가 더 작으므로 ``작은 키 우선'' 규칙과 정확히 맞아떨어진다.
@<지핑@>=
func zip(x, y *node) *node {
	if x == nil {
		return y
	}
	if y == nil {
		return x
	}
	if x.rank < y.rank {
		y.left = zip(x, y.left)
		return y
	}
	x.right = zip(x.right, y)
	return x
}

@* 삭제.
삭제는 삽입을 뒤집은 것이다. 지울 키를 검색으로 찾으면, 그 노드의 두 부분트리에서
{\it 맞닿은 두 사슬\/}, 곧 왼쪽 부분트리의 오른쪽 등마루와 오른쪽 부분트리의 왼쪽
등마루를 |zip|으로 엮어 하나의 경로로 만들고, 그 꼭대기를 지워진 노드 자리에
끼운다. 나머지 부분트리들은 손대지 않는다.

재귀 |deleteNode|는 경로를 따라 내려가되, {\it 지울 노드의 부모\/}에 이르렀을 때
딱 한 번 자식 포인터를 고친다. 곧 자식이 바로 지울 노드이면 그 자식을 자기 두
부분트리의 지핑 결과로 바꾼다. 경로 위 다른 노드들의 포인터는 건드리지 않으니,
한 번의 삭제가 바꾸는 포인터는 경로 길이와 무관하게 적다. 이 함수는 키가 트리에
{\it 있다고\/} 가정하므로, |Delete|에서 먼저 확인하고 부른다.
@<삭제@>=
func deleteNode(key int, root *node) *node {
	if key == root.key {
		return zip(root.left, root.right)
	}
	if key < root.key {
		if key == root.left.key {
			root.left = zip(root.left.left, root.left.right)
		} else {
			deleteNode(key, root.left)
		}
	} else {
		if key == root.right.key {
			root.right = zip(root.right.left, root.right.right)
		} else {
			deleteNode(key, root.right)
		}
	}
	return root
}

@ @<삭제@>=
func (t *zipTree) Delete(key int) {
	if !t.Contains(key) {
		return
	}
	t.root = deleteNode(key, t.root)
}

@** 메모리를 아끼는 인덱스 구현.
앞의 구현은 읽기 좋지만 노드 하나가 64비트 환경에서 |key|(8바이트)${}+{}$|rank|
(8바이트)${}+{}$두 포인터(16바이트)${}={}$32바이트를 차지하고, 게다가 노드마다 따로
힙에 할당된다. 그러면 할당자 오버헤드가 붙고, GC가 노드마다 포인터 16바이트를
훑으며, 노드들이 메모리 여기저기 흩어져 캐시 적중률도 낮다.

Theorem 1을 떠올리면 더 줄일 여지가 보인다. 짚트리의 최대 랭크는 거의 확실히
$\lg n + O(1)$이라, $n$이 천문학적으로 커도 한 {\it 바이트\/}(0..255)에 너끈히
든다(랭크가 256이 되려면 동전 앞면이 256번 연속이라야 한다). 그러니 |rank|는
|uint8|로 충분하다. 또 포인터 대신 노드들을 {\it 한 슬라이스\/}에 모아 담고
자식을 {\it 첨자\/}로 가리키면, 포인터는 |int32|로 줄고, 더 중요하게는 슬라이스
백킹 배열에 포인터가 없어 {\it GC가 아예 훑지 않으며\/}, 노드들이 연속 메모리에
놓여 캐시에도 친화적이다. 알고리즘은 그대로이고 표현만 첨자로 바꾼다. 빈 자식은
첨자 $-1$을 파수꾼으로 삼는다.
@<인덱스 기반 아레나@>=
const nilIdx = -1 // 빈 자식을 가리키는 파수꾼

type anode struct {
	key         int32
	left, right int32 // 자식의 첨자 (|nilIdx|면 없음)
	rank        uint8
}

type arenaTree struct {
	nodes []anode // 모든 노드를 담는 아레나
	free  []int32 // 삭제로 비워져 재활용할 슬롯
	root  int32
	rng   *rand.Rand
}

func newArenaTree(rng *rand.Rand) *arenaTree {
	return &arenaTree{root: nilIdx, rng: rng}
}

@ 노드를 만들 때는 비워 둔 슬롯이 있으면 거기에 덮어쓰고, 없으면 슬라이스를 한 칸
늘린다. 삭제된 슬롯은 |free|에 쌓아 두었다가 재활용하므로, 쓰는 메모리는 {\it
동시에 살아 있는\/} 노드 수에 비례하지 지금껏 넣은 총수에 비례하지 않는다.
@<인덱스 기반 아레나@>=
func (t *arenaTree) alloc(key int32, rank uint8) int32 {
	x := anode{key: key, left: nilIdx, right: nilIdx, rank: rank}
	if n := len(t.free); n > 0 {
		i := t.free[n-1]
		t.free = t.free[:n-1]
		t.nodes[i] = x
		return i
	}
	t.nodes = append(t.nodes, x)
	return int32(len(t.nodes) - 1)
}

func (t *arenaTree) freeNode(i int32) { t.free = append(t.free, i) }

@ 랭크는 바이트로 뽑는다. 뽑는 법 자체는 포인터판과 같다.
@<인덱스 기반 아레나@>=
func (t *arenaTree) randomRank() uint8 {
	k := uint8(0)
	for t.rng.Intn(2) == 1 {
		k++
	}
	return k
}

@ 검색은 첨자를 따라가는 것 말고는 포인터판과 같다.
@<인덱스 기반 아레나@>=
func (t *arenaTree) Contains(key int32) bool {
	for x := t.root; x != nilIdx; {
		switch n := t.nodes[x]; {
		case key == n.key:
			return true
		case key < n.key:
			x = n.left
		default:
			x = n.right
		}
	}
	return false
}

@ 삽입과 언지핑은 포인터판과 글자 그대로 같은 알고리즘이다. 다만 |root.left|가
|t.nodes[root].left|로, |nil|이 |nilIdx|로, 새 노드 |x|가 첨자로 바뀌었을 뿐이다.
삽입은 내려가기 {\it 전에\/} |alloc|으로 노드를 마련하므로 재귀 도중에는 슬라이스가
자라지 않아, 들고 있는 첨자가 가리키는 곳이 흔들리지 않는다.
@<인덱스 기반 아레나@>=
func (t *arenaTree) insert(x, root int32) int32 {
	if root == nilIdx {
		return x
	}
	if t.nodes[x].key < t.nodes[root].key {
		if t.insert(x, t.nodes[root].left) == x {
			if t.nodes[x].rank < t.nodes[root].rank {
				t.nodes[root].left = x
			} else {
				t.nodes[root].left = t.nodes[x].right
				t.nodes[x].right = root
				return x
			}
		}
	} else {
		if t.insert(x, t.nodes[root].right) == x {
			if t.nodes[x].rank <= t.nodes[root].rank {
				t.nodes[root].right = x
			} else {
				t.nodes[root].right = t.nodes[x].left
				t.nodes[x].left = root
				return x
			}
		}
	}
	return root
}

@ 바깥에서 부르는 |Insert|도 마찬가지다.
@<인덱스 기반 아레나@>=
func (t *arenaTree) Insert(key int32) {
	if t.Contains(key) {
		return
	}
	t.root = t.insert(t.alloc(key, t.randomRank()), t.root)
}

@ 지핑도 똑같다.
@<인덱스 기반 아레나@>=
func (t *arenaTree) zip(x, y int32) int32 {
	if x == nilIdx {
		return y
	}
	if y == nilIdx {
		return x
	}
	if t.nodes[x].rank < t.nodes[y].rank {
		t.nodes[y].left = t.zip(x, t.nodes[y].left)
		return y
	}
	t.nodes[x].right = t.zip(t.nodes[x].right, y)
	return x
}

@ 삭제는 포인터판이 GC에 맡기던 일, 곧 지워진 노드를 거두는 일을 |freeNode|로
손수 한다. 지울 노드를 찾으면 두 부분트리를 |zip|으로 엮어 그 자리에 끼우고,
비워진 슬롯을 |free|에 돌려준다.
@<인덱스 기반 아레나@>=
func (t *arenaTree) deleteNode(key, root int32) int32 {
	if key == t.nodes[root].key {
		r := t.zip(t.nodes[root].left, t.nodes[root].right)
		t.freeNode(root)
		return r
	}
	if key < t.nodes[root].key {
		if l := t.nodes[root].left; key == t.nodes[l].key {
			t.nodes[root].left = t.zip(t.nodes[l].left, t.nodes[l].right)
			t.freeNode(l)
		} else {
			t.deleteNode(key, l)
		}
	} else {
		if r := t.nodes[root].right; key == t.nodes[r].key {
			t.nodes[root].right = t.zip(t.nodes[r].left, t.nodes[r].right)
			t.freeNode(r)
		} else {
			t.deleteNode(key, r)
		}
	}
	return root
}

@ @<인덱스 기반 아레나@>=
func (t *arenaTree) Delete(key int32) {
	if !t.Contains(key) {
		return
	}
	t.root = t.deleteNode(key, t.root)
}

@ 표현만 바꿨을 뿐, 키와 랭크가 같으면 트리 모양은 포인터판과 똑같아야 한다(역사
독립성). 검사 절의 |TestArenaMatchesPointer|가 같은 (키, 랭크) 흐름을 두 구현에
나란히 흘려 매 단계 모양이 글자까지 같은지 대조하고, |TestNodeSize|가 노드 크기가
실제로 줄었음을 보인다. 줄이는 대신 잃는 것도 있다. |t.nodes[root].left| 같은
표기로 본문이 덜 읽히고, |int32| 첨자는 노드 수를 약 21억으로 제한하며, 프리
리스트라는 관리 거리가 하나 는다. 한 걸음 더 나아가 랭크 필드마저 없애려면, 랭크를
키의 의사난수 함수로 매번 {\it 계산\/}하는 길(논문 4절)도 있는데, 이는 더 강한
독립성 가정을 요구한다.

@** 랭크를 저장하지 않기.
방금 말한 ``한 걸음 더''를 실제로 디뎌 보자. 랭크는 무작위이기만 하면 되고 키마다
{\it 고정\/}이면 되므로, 굳이 노드에 담지 않고 {\it 키의 의사난수 함수\/}로 그때그때
계산해도 된다(Aragon과 Seidel의 착상, 논문 4절). 그러면 노드에서 랭크 필드가
통째로 사라진다.

키를 잘 섞으려면 splitmix64의 마무리 함수를 쓴다. 섞은 64비트 값의 {\it 뒤쪽 0
비트 수\/}를 세면, 그 값이 |k|일 확률이 꼭 $1/2^{k+1}$이라 우리가 바라던 기하분포가
공짜로 나온다($63$에서 막아 둔다). 씨앗을 섞어 두면 트리마다 다른 랭크열을 얻는다.
@<의사난수 랭크 트리@>=
type pnode struct {
	key         int
	left, right *pnode
}

type prfTree struct {
	root *pnode
	seed uint64
}

func mix(z uint64) uint64 {
	z += 0x9e3779b97f4a7c15
	z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9
	z = (z ^ (z >> 27)) * 0x94d049bb133111eb
	return z ^ (z >> 31)
}

func (t *prfTree) rank(key int) int {
	h := mix(uint64(key) ^ t.seed)
	return bits.TrailingZeros64(h | 1<<63) // 0..63
}

@ 나머지는 앞서와 글자 그대로 같은 알고리즘인데, |x.rank|를 읽던 자리에서 대신
|t.rank(x.key)|를 부른다. 랭크를 저장하지 않아 메모리를 아끼는 대신, 비교할 때마다
다시 계산하므로 CPU를 조금 더 쓴다. 검색은 여느 이진 검색이다.
@<의사난수 랭크 트리@>=
func (t *prfTree) Contains(key int) bool {
	for x := t.root; x != nil; {
		switch {
		case key == x.key:
			return true
		case key < x.key:
			x = x.left
		default:
			x = x.right
		}
	}
	return false
}

@ 삽입과 언지핑이다. 랭크 비교만 |t.rank|로 바뀌었을 뿐 구조는 저장-랭크판과 같다.
@<의사난수 랭크 트리@>=
func (t *prfTree) insert(x, root *pnode) *pnode {
	if root == nil {
		return x
	}
	if x.key < root.key {
		if t.insert(x, root.left) == x {
			if t.rank(x.key) < t.rank(root.key) {
				root.left = x
			} else {
				root.left = x.right
				x.right = root
				return x
			}
		}
	} else {
		if t.insert(x, root.right) == x {
			if t.rank(x.key) <= t.rank(root.key) {
				root.right = x
			} else {
				root.right = x.left
				x.left = root
				return x
			}
		}
	}
	return root
}

@ 바깥에서 부르는 |Insert|는 랭크 없는 노드를 만들어 재귀를 시작한다.
@<의사난수 랭크 트리@>=
func (t *prfTree) Insert(key int) {
	if t.Contains(key) {
		return
	}
	t.root = t.insert(&pnode{key: key}, t.root)
}

@ 지핑은 |t.rank|를 부르는 것 말고는 저장-랭크판과 같다.
@<의사난수 랭크 트리@>=
func (t *prfTree) zip(x, y *pnode) *pnode {
	if x == nil {
		return y
	}
	if y == nil {
		return x
	}
	if t.rank(x.key) < t.rank(y.key) {
		y.left = t.zip(x, y.left)
		return y
	}
	x.right = t.zip(x.right, y)
	return x
}

@ 삭제도 마찬가지다.
@<의사난수 랭크 트리@>=
func (t *prfTree) deleteNode(key int, root *pnode) *pnode {
	if key == root.key {
		return t.zip(root.left, root.right)
	}
	if key < root.key {
		if key == root.left.key {
			root.left = t.zip(root.left.left, root.left.right)
		} else {
			t.deleteNode(key, root.left)
		}
	} else {
		if key == root.right.key {
			root.right = t.zip(root.right.left, root.right.right)
		} else {
			t.deleteNode(key, root.right)
		}
	}
	return root
}

@ @<의사난수 랭크 트리@>=
func (t *prfTree) Delete(key int) {
	if !t.Contains(key) {
		return
	}
	t.root = t.deleteNode(key, t.root)
}

@ 이 방식에는 대가가 있다. 랭크가 키만으로 정해지므로, 공격자가 키를 고를 수 있고
씨앗을 알(거나 추측할) 수 있다면 일부러 한쪽으로 치우친 트리를 만들 수 있다. 실제로
씨앗 재사용이 여러 라이브러리의 ``서비스 거부'' 공격으로 이어진 적이 있다(논문 각주
3). 그래서 효율 분석이 성립하려면 삽입$\cdot$삭제열이 랭크 함수와 {\it 독립\/}
이라는, 더 강한 가정이 필요하다. 같은 트릭은 아레나 표현에도 그대로 얹을 수 있어,
거기서는 |int32| 둘만 남은 더 작은 노드가 된다.

@** 검사와 실험.
짚트리가 제대로 도는지 확인하고 이런저런 활용을 실험하려면, 굳이 표준 입력을
받는 |main|을 둘 필요가 없다. \.{GWEB}의 \.{@(ziptree\_test.go@>} 표기를 쓰면 이 묶음을 별도
파일 \.{ziptree\_test.go}로 뽑아낼 수 있고, 거기에 검사와 실험을 담아 \.{go test}로
돌리면 된다. 검사 파일도 같은 |ziptree| 패키지에 속하므로, 소문자로 감춘 |node|나
|insert| 같은 속살에 곧장 손댈 수 있다.
@(ziptree_test.go@>=
package ziptree

import (
	"fmt"
	"math"
	"math/rand"
	"runtime"
	"slices"
	"sort"
	"strings"
	"testing"
	"unsafe"
)

@<테스트 도우미@>
@<그림 1 재현 테스트@>
@<불변식 검사 테스트@>
@<인덱스 대조 테스트@>
@<의사난수 랭크 대조 테스트@>
@<노드 크기 테스트@>
@<할당 벤치마크@>

@ 검사에 쓸 도우미들이다. |insertRanked|는 랭크를 무작위로 뽑는 대신 밖에서 받아
넣는다. 그림을 재현하려면 적힌 랭크를 그대로 박아야 한다.
@<테스트 도우미@>=
func insertRanked(t *zipTree, key, rank int) {
	if t.Contains(key) {
		return
	}
	t.root = insert(&node{key: key, rank: rank}, t.root)
}

@ |shape|는 트리를 한 줄
문자열 \.{key:rank(L)(R)} 꼴로 직렬화해 모양을 정확히 견주게 한다(빈 자리는 마침표).
키는 글자 코드값을 담을 수 있으므로 \.{\%c}로 찍는다.
@<테스트 도우미@>=
func shape(x *node) string {
	if x == nil {
		return "."
	}
	return fmt.Sprintf("%c%d(%s)(%s)", rune(x.key), x.rank, shape(x.left), shape(x.right))
}

@ |draw|는 트리를 시계 반대로 $90^\circ$ 뉘어 사람 눈에 보기 좋게 그린다.
@<테스트 도우미@>=
func draw(x *node, depth int, sb *strings.Builder) {
	if x == nil {
		return
	}
	draw(x.right, depth+1, sb)
	fmt.Fprintf(sb, "%s%c:%d\n", strings.Repeat("    ", depth), rune(x.key), x.rank)
	draw(x.left, depth+1, sb)
}

@ |checkInvariants|는 대칭 순서와 랭크 힙 순서(동점은 작은 키 우선)가 지켜지는지
훑어, 어긋나면 까닭을 돌려준다.
@<테스트 도우미@>=
func checkInvariants(x *node, lo, hi, prank int, isLeft bool) string {
	if x == nil {
		return ""
	}
	if x.key <= lo || x.key >= hi {
		return fmt.Sprintf("대칭 순서 위반: 키 %d", x.key)
	}
	if isLeft && x.rank >= prank || !isLeft && x.rank > prank {
		return fmt.Sprintf("힙 순서 위반: 키 %d", x.key)
	}
	if m := checkInvariants(x.left, lo, x.key, x.rank, true); m != "" {
		return m
	}
	return checkInvariants(x.right, x.key, hi, x.rank, false)
}

@ 첫 실험은 논문의 {\it 그림 1\/} 재현이다. 그림은 키 \.{K}(랭크 3)를 넣고 빼는
한 장면으로 언지핑과 지핑을 함께 보여 준다. 트리는 키와 랭크만으로 모양이 유일하게
정해지므로(역사 독립성), 넣는 {\it 순서\/}와 무관하게 그림에 적힌 랭크만 맞추면
같은 트리가 선다. 그렇게 그림 1의 왼쪽 트리를 세우고(\.{F}부터 \.{X}까지, 글자
코드값을 키로), \.{K}를 랭크 3으로 넣어 오른쪽 트리(언지핑
결과)가 됨을 확인한 뒤, 다시 \.{K}를 빼서(지핑) 처음 트리로 돌아옴을 확인한다. 세
모양을 모두 그림과 글자 그대로 견준다. |t.Log|로 그림도 함께 찍으므로
\.{go test -v}로 돌리면 트리가 눈에 보인다.

\medskip
\centerline{\pdfpic{ziptree-1.pdf}}
\centerline{그림 1: 랭크 3을 받은 키 \.{K}의 삽입(언지핑)과 삭제(지핑).}
\medskip
@<그림 1 재현 테스트@>=
func TestFigure1(t *testing.T) {
	const wantBefore = "F4(D2(.)(.))(S4(H2(G0(.)(.))" +
		"(M2(L1(J0(.)(.))(.))(.)))(X2(.)(.)))"
	const wantAfter = "F4(D2(.)(.))(S4(K3(H2(G0(.)(.))(J0(.)(.)))" +
		"(M2(L1(.)(.))(.)))(X2(.)(.)))"

	zt := &zipTree{}
	for _, kr := range []struct {
		key  rune
		rank int
	}{
		{'F', 4}, {'D', 2}, {'S', 4}, {'H', 2}, {'X', 2},
		{'G', 0}, {'M', 2}, {'L', 1}, {'J', 0},
	} {
		insertRanked(zt, int(kr.key), kr.rank)
	}
	@<세운 트리를 그림 1 왼쪽과 견준다@>
	@<\.{K}를 넣어 오른쪽 트리가 됨을 본다@>
	@<\.{K}를 빼서 처음 트리로 돌아옴을 본다@>
}

@ @<세운 트리를 그림 1 왼쪽과 견준다@>=
var sb strings.Builder
draw(zt.root, 0, &sb)
t.Logf("K를 넣기 전:\n%s", sb.String())
if got := shape(zt.root); got != wantBefore {
	t.Fatalf("그림 1 왼쪽 트리가 다름\n  got:  %s\n  want: %s", got, wantBefore)
}

@ \.{K}는 코드값으로 \.{J}와 \.{L} 사이에 든다. 랭크 3은 만나는 \.{H}, \.{M}(랭크 2)보다
높아, \.{K}가 \.{S}의 왼쪽 자식으로 올라서며 그 아래 경로가 언지핑된다.
@<\.{K}를 넣어 오른쪽 트리가 됨을 본다@>=
insertRanked(zt, 'K', 3)
sb.Reset()
draw(zt.root, 0, &sb)
t.Logf("K(랭크 3)를 넣은 뒤 — 언지핑:\n%s", sb.String())
if got := shape(zt.root); got != wantAfter {
	t.Fatalf("그림 1 오른쪽 트리가 다름\n  got:  %s\n  want: %s", got, wantAfter)
}

@ 삭제는 \.{K}의 두 부분트리(\.{H} 쪽과 \.{M} 쪽)를 지핑해 도로 잇는다. 결과가 넣기
전과 글자 하나 틀리지 않고 같으면, 언지핑과 지핑이 서로의 역연산임이 확인된다.
@<\.{K}를 빼서 처음 트리로 돌아옴을 본다@>=
zt.Delete('K')
if got := shape(zt.root); got != wantBefore {
	t.Fatalf("지핑 뒤 처음 트리로 안 돌아옴\n  got:  %s\n  want: %s", got, wantBefore)
}

@ 둘째 실험은 무작위 담금질이다. 무작위 랭크로 수만 번 넣고 빼고 찾으면서, 매
연산 뒤 대칭 순서와 힙 순서가 깨지지 않는지, 그리고 멤버십이 참조용 집합과
어긋나지 않는지 살핀다. 씨앗을 고정해 실패를 재현할 수 있게 한다. 마지막에는
중위 순회로 읽은 키 목록이 참조 집합과 완전히 같은지 견준다.
@<불변식 검사 테스트@>=
func TestInvariants(t *testing.T) {
	zt := &zipTree{rng: rand.New(rand.NewSource(1))}
	ref := map[int]bool{}
	rng := rand.New(rand.NewSource(2))
	for i := 0; i < 100000; i++ {
		k := rng.Intn(500)
		switch rng.Intn(3) {
		case 0:
			zt.Insert(k)
			ref[k] = true
		case 1:
			zt.Delete(k)
			delete(ref, k)
		case 2:
			if zt.Contains(k) != ref[k] {
				t.Fatalf("멤버십 불일치: 키 %d", k)
			}
		}
		if msg := checkInvariants(zt.root, math.MinInt, math.MaxInt, math.MaxInt, false); msg != "" {
			t.Fatalf("연산 %d 뒤 %s", i, msg)
		}
	}
	@<중위 순회 키가 참조 집합과 같은지 본다@>
}

@ @<중위 순회 키가 참조 집합과 같은지 본다@>=
var got []int
var walk func(*node)
walk = func(x *node) {
	if x == nil {
		return
	}
	walk(x.left)
	got = append(got, x.key)
	walk(x.right)
}
walk(zt.root)

want := make([]int, 0, len(ref))
for k := range ref {
	want = append(want, k)
}
sort.Ints(want)
if !slices.Equal(got, want) {
	t.Fatalf("내용 불일치: %d개 대 %d개", len(got), len(want))
}

@ 인덱스 구현을 검사하려면 도우미 둘이 더 필요하다. |insertRankedA|는 아레나에
랭크를 지정해 넣고, 아레나용 |shape|는 첨자를 따라가며 포인터판 |shape|와 똑같은
형식의 문자열을 만든다. 형식이 같아야 두 구현의 모양을 곧장 견줄 수 있다.
@<테스트 도우미@>=
func insertRankedA(t *arenaTree, key int32, rank uint8) {
	if t.Contains(key) {
		return
	}
	t.root = t.insert(t.alloc(key, rank), t.root)
}

func (t *arenaTree) shape(i int32) string {
	if i == nilIdx {
		return "."
	}
	n := t.nodes[i]
	return fmt.Sprintf("%c%d(%s)(%s)", rune(n.key), n.rank, t.shape(n.left), t.shape(n.right))
}

func (t *prfTree) shape(x *pnode) string {
	if x == nil {
		return "."
	}
	return fmt.Sprintf("%c%d(%s)(%s)", rune(x.key), t.rank(x.key), t.shape(x.left), t.shape(x.right))
}

@ 포인터 트리와 아레나 트리에 {\it 똑같은\/} (키, 랭크) 흐름을 흘린다. 매 단계
두 모양이 글자까지 같으면, 인덱스 구현이 이미 검증된 포인터 구현과 한 치도 다르지
않게 도는 것이다(역사 독립성이 보장하듯, 같은 키와 랭크는 같은 모양을 낳는다).
이 대조는 그림 1 재현까지 포함하는 더 센 검사다. 끝에 아레나 길이와 재활용 슬롯
수를 찍어, 쓰는 메모리가 {\it 동시에 살아 있는\/} 노드 수에 묶임을 보인다.
@<인덱스 대조 테스트@>=
func TestArenaMatchesPointer(t *testing.T) {
	pt := &zipTree{}
	at := newArenaTree(nil)
	rng := rand.New(rand.NewSource(3))
	live := map[int]bool{}
	for i := 0; i < 20000; i++ {
		key := rng.Intn(500)
		if rng.Intn(3) == 0 {
			if live[key] {
				pt.Delete(key)
				at.Delete(int32(key))
				delete(live, key)
			}
		} else if !live[key] {
			rank := 0
			for rng.Intn(2) == 1 {
				rank++
			}
			insertRanked(pt, key, rank)
			insertRankedA(at, int32(key), uint8(rank))
			live[key] = true
		}
		if got, want := at.shape(at.root), shape(pt.root); got != want {
			t.Fatalf("연산 %d: 모양 불일치\n  아레나: %s\n  포인터: %s", i, got, want)
		}
	}
	t.Logf("최종 노드 %d개, 아레나 길이 %d, 재활용 슬롯 %d",
		len(live), len(at.nodes), len(at.free))
}

@ 의사난수 랭크 트리도 같은 방식으로 대조한다. 포인터 트리에 |rt.rank(key)|로 계산한
바로 그 랭크를 넣어 주면, 랭크를 저장한 트리와 계산하는 트리가 같은 모양이어야 한다.
이로써 ``랭크를 매번 계산한다''는 발상이 알고리즘을 망가뜨리지 않음을 확인한다.
@<의사난수 랭크 대조 테스트@>=
func TestPRFMatchesStored(t *testing.T) {
	pt := &zipTree{}
	rt := &prfTree{seed: 0x1234}
	rng := rand.New(rand.NewSource(11))
	live := map[int]bool{}
	for i := 0; i < 20000; i++ {
		key := rng.Intn(500)
		if rng.Intn(3) == 0 {
			if live[key] {
				pt.Delete(key)
				rt.Delete(key)
				delete(live, key)
			}
		} else if !live[key] {
			insertRanked(pt, key, rt.rank(key))
			rt.Insert(key)
			live[key] = true
		}
		if got, want := rt.shape(rt.root), shape(pt.root); got != want {
			t.Fatalf("연산 %d: 모양 불일치\n  의사난수: %s\n  저장: %s", i, got, want)
		}
	}
}

@ 세 노드의 크기를 직접 잰다. 랭크를 바이트로 줄이고 포인터를 첨자로 바꾼 아레나
노드, 랭크 필드를 아예 없앤 의사난수 노드 모두 원래 노드보다 작아야 한다.
@<노드 크기 테스트@>=
func TestNodeSize(t *testing.T) {
	sn := unsafe.Sizeof(node{})  // 포인터 + 저장 랭크
	sa := unsafe.Sizeof(anode{}) // 아레나(첨자 + 바이트 랭크)
	sp := unsafe.Sizeof(pnode{}) // 의사난수(랭크 없음)
	t.Logf("기본 %dB → 아레나 %dB, 의사난수 %dB", sn, sa, sp)
	if sa >= sn || sp >= sn {
		t.Fatalf("줄어든 노드가 더 커서는 안 된다: 기본=%d 아레나=%d 의사난수=%d", sn, sa, sp)
	}
}

@ 끝으로 할당과 GC 부담을 수치로 본다. 같은 |n|개 노드짜리 트리를 포인터판과
아레나판으로 각각 세우는 작은 함수부터 둔다.
@<할당 벤치마크@>=
func buildPointer(n int) *zipTree {
	t := &zipTree{rng: rand.New(rand.NewSource(1))}
	for k := 0; k < n; k++ {
		t.Insert(k)
	}
	return t
}

func buildArena(n int) *arenaTree {
	t := newArenaTree(rand.New(rand.NewSource(1)))
	for k := 0; k < n; k++ {
		t.Insert(int32(k))
	}
	return t
}

@ |profile|은 트리를 한 번 세우는 동안 |runtime.ReadMemStats|로 ① 객체 할당 횟수,
② GC 횟수, ③ 다 짓고 GC한 뒤 유지하는 힙을 잰다. |KeepAlive|로 측정이 끝나기 전에
트리가 수거되지 않게 막는다.
@<할당 벤치마크@>=
func profile(build func() any) (mallocs uint64, gc uint32, heap uint64) {
	runtime.GC()
	var m0, m1, m2 runtime.MemStats
	runtime.ReadMemStats(&m0)
	tree := build()
	runtime.ReadMemStats(&m1)
	runtime.GC()
	runtime.ReadMemStats(&m2)
	runtime.KeepAlive(tree)
	return m1.Mallocs - m0.Mallocs, m1.NumGC - m0.NumGC, m2.HeapAlloc - m0.HeapAlloc
}

@ 포인터판은 노드마다 따로 할당하니 객체 수가 |n|에 비례하고, 아레나판은 슬라이스를
몇 번 늘릴 뿐이라 할당 횟수가 수십에 그친다. 유지 메모리도 노드 크기 차이만큼
벌어진다.
@<할당 벤치마크@>=
func TestMemFootprint(t *testing.T) {
	const n = 1 << 20 // 약 100만 노드

	mP, gcP, hP := profile(func() any { return buildPointer(n) })
	mA, gcA, hA := profile(func() any { return buildArena(n) })

	t.Logf("포인터: 객체할당 %d회, GC %d회, 유지 %dMiB", mP, gcP, hP>>20)
	t.Logf("아레나: 객체할당 %d회, GC %d회, 유지 %dMiB", mA, gcA, hA>>20)
	if mA >= mP {
		t.Fatalf("아레나가 객체를 덜 할당해야 한다: %d >= %d", mA, mP)
	}
	if hA >= hP {
		t.Fatalf("아레나가 힙을 덜 유지해야 한다: %d >= %d", hA, hP)
	}
}

@ \.{go test -bench=.} 로 돌리면 한 삽입에 드는 시간과 할당이 나란히 찍힌다. 아레나판의
|allocs/op|이 0에 수렴하는 것이 눈에 띈다.
@<할당 벤치마크@>=
func BenchmarkInsertPointer(b *testing.B) {
	b.ReportAllocs()
	t := &zipTree{rng: rand.New(rand.NewSource(1))}
	for i := 0; i < b.N; i++ {
		t.Insert(i)
	}
}

func BenchmarkInsertArena(b *testing.B) {
	b.ReportAllocs()
	t := newArenaTree(rand.New(rand.NewSource(1)))
	for i := 0; i < b.N; i++ {
		t.Insert(int32(i))
	}
}

@* 찾아보기.
