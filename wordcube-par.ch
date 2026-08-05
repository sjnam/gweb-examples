이 변경 파일은 wordcube를 병렬로 돌린다. 최상위 시작 낱말(대각 낱말 W00)의
선택은 서로 완전히 독립이므로, 그것을 여러 고루틴에 나눠 맡기면 코어 수만큼
빨라진다. 명령줄에 워커 수(숫자)를 주면 그만큼의 일꾼이 원자적 작업 큐에서
시작 낱말을 하나씩 받아 자기 |worker|로 탐색하고, 끝에 셈을 합친다. 시작 낱말마다
부하가 크게 다르므로(흔한 첫 글자일수록 무거움) 정적 분할보다 동적 큐가 균형이 좋다.
개수(83576 / 75130)와 노드 수는 순차 판과 한 치도 다르지 않다. 적용:

    gtangle wordcube.w wordcube-par.ch     (-> 병렬 wordcube.go)

바꾸는 것은 딱 셋이다: import에 동시성 꾸러미를 더하고, 명령줄에서 워커 수를 읽고,
차례로 훑던 구동부를 고루틴 풀로 갈아 끼운다. 나머지 절---탐색, 세기, 보고---은
일꾼 하나짜리든 여럿이든 그대로다.

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
	var wk worker
	for w := 0; w < len(words); w++ {
		wk.searchFrom(w)
	}
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
