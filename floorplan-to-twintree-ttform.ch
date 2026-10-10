이 변경 파일은 크누스의 floorplan-to-twintree-ttform.ch를 옮긴 것이다.
출력을 짝 프로그램 TWINTREE-TO-BAXTER가 읽는 형식으로 바꾼다.

@x
출력은 대응하는 쌍둥이 나무 $T_0$과 $T_1$이다. 나무마다 먼저 뿌리를 밝히고, 이어서
마디 이름과 왼쪽·오른쪽 자식 링크를 대칭 순서로 찍는다. 널 링크는 `\.{/\\}'로
나타낸다.
@y
표준 출력으로 내는 것은 짝 프로그램 {\mc TWINTREE-TO-BAXTER}가 읽는 형식이다. 마디는
대칭 순서의 차례대로 $1$부터 $n$까지 번호를 붙이고, 널 링크는 0으로 적는다. 첫
줄에는 두 뿌리 $t_0$과 $t_1$을 적는다. 이어지는 $n$줄에는 저마다 $k$, $l_0[k]$,
$r_0[k]$, $l_1[k]$, $r_1[k]$를 적는다.
@z

@x
@* 출력 단계.
널 방의 이름은 `\.{/\\}'로 둔다. 이름은 여덟 칸에 오른쪽으로 맞춰 찍는다.

@<쌍둥이 나무를 찍는다@>=
room[rooms], name = len(name), append(name, `/\`)
fmt.Fprintf(out, "T0 (rooted at %s)\n", name[room[root0]])
inorder(root0, l0, r0)
fmt.Fprintf(out, "T1 (rooted at %s)\n", name[room[root1]])
inorder(root1, l1, r1)
@y
@* 출력 단계.
먼저 $T_0$을 대칭 순서로 훑어 방마다 차례 번호 |serial|을 매긴다. 널 방의 번호는
0이다. 그다음 두 뿌리를 찍고, 방마다 제 번호와 네 링크의 번호를 찍는다.

@<쌍둥이 나무를 찍는다@>=
serial = make([]int, rooms+1) // |serial[null]=0|
inorder(root0, l0, r0)
fmt.Fprintf(out, "%d %d\n", serial[root0], serial[root1])
for k = 0; k < rooms; k++ {
	fmt.Fprintf(out, "%d %d %d %d %d\n",
		serial[k], serial[l0[k]], serial[r0[k]], serial[l1[k]], serial[r1[k]])
}

@ @<전역 변수@>=
var (
	rank   int   // 지금까지 번호를 매긴 방의 수
	serial []int // 방마다 대칭 순서의 차례
)
@z

@x
@ 나무를 대칭 순서로 훑으며 마디마다 한 줄을 찍는다. 원본은 두 나무에 같은 모양의
함수를 하나씩 두지만, 여기서는 링크 배열을 받는 함수 하나로 두 나무를 다 훑는다.
앞에서 확인했으니 고리는 없다.
@y
@ 나무를 대칭 순서로 훑으며 마디마다 다음 차례 번호를 매긴다. 앞에서 확인했으니
고리는 없다.
@z

@x
	fmt.Fprintf(out, "%8s: %8s, %8s\n",
		name[room[root]], name[room[l[root]]], name[room[r[root]]])
@y
	rank++
	serial[root] = rank
@z
