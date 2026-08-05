이 변경 파일은 wordcube에 preclusion(선행 배제, 전방 검사)을 더한다. 낱말을 하나
놓으면 그 글자들이 아직 안 놓은 여러 낱말의 접두사 칸을 미리 정한다. 놓는 즉시 "아직
안 놓은 낱말들이 저마다 사전에서 완성될 수 있는가"를 묻고, 한 곳이라도 완성 불가능하면
그 서브트리를 통째로 배제한다. 막다른 길에 도착해서야 무르는 것이 아니라, 몇 층 위에서
미리 잘라 낸다. 그 덕에 밟는 노드가 46억에서 약 9800만으로 47배 줄고, 순차 실행이
5분 52초에서 약 2분 반으로 준다. 개수(83576 / 75130)는 그대로다. 적용:

    gtangle wordcube.w wordcube-precl.ch     (-> preclusion wordcube.go)

각 미래 낱말의 위치가 어느 층에서 정해지는지를 |knownTime|에 미리 담아 두고(짝
(a,b)의 놓는 차례는 |pairIdx|), 낱말을 놓을 때마다 |feasible|로 남은 낱말들의 알려진
접두사가 사전에 있는지 확인한다. 바꾸는 것은 넷: 표를 미리 계산하고, 전역에 그 표를
더하고, |feasible|를 두고, 놓은 뒤 그것이 참일 때만 내려간다.

@x
			order[t] = [2]int{i, j}
			t++
		}
	}
@y
			order[t] = [2]int{i, j}
			t++
		}
	}
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
@z

@x
탐색을 하도록. 전역에는 낱말 목록과 채우는 순서, 합계만 둔다.
@y
탐색을 하도록. 전역에는 낱말 목록과 채우는 순서, 합계, 그리고
각 미래 낱말의 위치가 어느 층에서 정해지는지를 |knownTime|에 미리 담아 두고, 짝
$(a,b)$의 놓는 차례는 |pairIdx|에 답는다.
@z

@x
	nodes    int64          // 노드 총수(합계)
	profile  [lines + 1]int64
)
@y
	nodes    int64          // 노드 총수(합계)
	profile  [lines + 1]int64
	pairIdx   [n][n]int      // 짝 (a,b) -> 놓는 차례
	knownTime [lines][n]int  // 낱말 u의 위치 c가 정해지는 층
)
@z

@x
|words[w]|로 정해---곧 큐브의 주대각선을 깔고---나머지 열넷을 |solve|로 채운다.
@y
|words[w]|로 정해---곧 큐브의 주대각선을 깔고---나머지 열넷을 |solve|로 채운다.
이때 |feasible|를 두고, 놓은 뒤 그것이 참일 때만 내려간다.
@z

@x
	wk.chosen[0] = w
	wk.solve(1)
@y
	wk.chosen[0] = w
	if wk.feasible(0) {
		wk.solve(1)
	}
@z

@x
	wk.chosen[t] = w
	wk.solve(t + 1)
@y
	wk.chosen[t] = w
	if wk.feasible(t) {
		wk.solve(t + 1)
	}
@z

@x
func (wk *worker) put(a, b, c int, ch byte) {
	wk.cube[a][b][c] = ch
	wk.cube[a][c][b] = ch
	wk.cube[b][a][c] = ch
	wk.cube[b][c][a] = ch
	wk.cube[c][a][b] = ch
	wk.cube[c][b][a] = ch
}
@y
func (wk *worker) put(a, b, c int, ch byte) {
	wk.cube[a][b][c] = ch
	wk.cube[a][c][b] = ch
	wk.cube[b][a][c] = ch
	wk.cube[b][c][a] = ch
	wk.cube[c][a][b] = ch
	wk.cube[c][b][a] = ch
}

@ 낱말을 놓을 때마다 |feasible|로 남은 낱말들의 알려진
접두사가 사전에 있는지 확인한다.
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
@z
