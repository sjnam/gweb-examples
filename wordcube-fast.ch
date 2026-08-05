이 변경 파일은 앞의 두 최적화---preclusion(선행 배제)과 고루틴 병렬---을 한꺼번에
건다. 둘은 서로 다른 절만 건드리므로 충돌 없이 포개진다. preclusion의 |feasible|는
일꾼 저마다의 |cube|를 읽는 메서드고 미리 계산한 표(|pairIdx|,|knownTime|)는 읽기
전용이라, 여러 일꾼이 동시에 돌려도 안전하다. 노드는 46억에서 9800만으로 줄고(배제),
그 9800만을 다시 코어 수만큼 나눠 밟으니(병렬), 벽시계가 가장 짧다. 개수(83576 /
75130)는 그대로. 적용:

    gtangle wordcube.w wordcube-fast.ch     (-> preclusion+병렬 wordcube.go)
    wordcube sgb-words.txt 10               (워커 10으로 실행)

블록은 소스 등장 순서로 놓았다: import(병렬), 표 계산·전역·searchFrom·배치·feasible
(preclusion), 구동부·명령줄(병렬).

@x
	"sort"
)
@y
	"sort"
	"strconv"
	"sync"
	"sync/atomic"
)
@z

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

@x
	var wk worker
	for w := 0; w < len(words); w++ {
		wk.searchFrom(w)
		fmt.Fprintf(os.Stderr, "\r진행: 시작 낱말 %d/%d, 노드 %d ", w+1, len(words), wk.nodes)
	}
	fmt.Fprintln(os.Stderr)
	count, distinct, nodes, profile = wk.count, wk.distinct, wk.nodes, wk.profile
@y
	pool := make([]worker, workers)
	var next int64 = -1
	var wg sync.WaitGroup
	for g := range pool {
		wg.Add(1)
		go func(wk *worker) {
			defer wg.Done()
			for {
				w := int(atomic.AddInt64(&next, 1))
				if w >= len(words) {
					return
				}
				wk.searchFrom(w)
			}
		}(&pool[g])
	}
	wg.Wait()
	for g := range pool {
		count += pool[g].count
		distinct += pool[g].distinct
		nodes += pool[g].nodes
		for t := range profile {
			profile[t] += pool[g].profile[t]
		}
	}
@z

@x
	wordFile = "sgb-words.txt"
	if len(os.Args) >= 2 {
		wordFile = os.Args[1]
	}
@y
	wordFile = "sgb-words.txt"
	workers := 1
	for _, a := range os.Args[1:] {
		if k, err := strconv.Atoi(a); err == nil {
			workers = k
		} else {
			wordFile = a
		}
	}
	if workers < 1 {
		workers = 1
	}
@z
