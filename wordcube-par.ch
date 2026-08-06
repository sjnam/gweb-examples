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
	"runtime"
	"sort"
	"strconv"
	"sync"
	"sync/atomic"
)
@z

@x
탐색을 하도록. 지금 본론은 일꾼 하나로 차례차례 세지만, 이 묶음 덕에 딸린 변경 파일
\.{wordcube-par.ch}가 여럿을 병렬로 돌릴 수 있다. 전역에는 낱말 목록과 채우는 순서, 그리고
@y
탐색을 하도록. 일꾼마다 이 상태를 따로 들기에, 여러 일꾼이 락 없이 나란히 탐색할 수
있다. 전역에는 낱말 목록과 채우는 순서, 그리고
@z

@x
본론은 일꾼 하나로 모든 시작 낱말을 차례로 훑는다. 다 훑으면 그 일꾼의 셈이 곧
합계다. 탐색이 몇 분씩 걸리는데 답은 끝에만 나오므로, 시작 낱말이 몇 개나
처리됐는지를 표준 오류로 흘려 살아 있음을 알린다---\.{\\r}로 같은 줄을 계속 덮어쓴다.
(병렬 판은 이 한 절을 여러 일꾼으로 바꿔치기하는데, 그 이야기는 딸린 변경 파일에서
한다.)
@y
탐색은 최상위 시작 낱말(대각 낱말 |W00|)마다 완전히 독립이라, 그대로 여러 일꾼에게
나눠 준다. |workers|개의 일꾼을 고루틴으로 띄우면 저마다 원자적 작업 큐에서 시작
낱말을 하나씩 받아 자기 |worker|로 탐색한다. 시작 낱말마다 부하가 크게 다르므로(흔한
첫 글자일수록 무겁다) 미리 똑같이 나누기보다 먼저 끝낸 일꾼이 다음 것을 받아 가는
편이 균형이 좋다. 모두 끝나면 일꾼들의 셈을 합친다.
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
@ 명령줄 인자로 낱말 파일을 받되, 없으면 \.{sgb-words.txt}를 쓴다.

@<명령줄을 처리한다@>=
	wordFile = "sgb-words.txt"
	if len(os.Args) >= 2 {
		wordFile = os.Args[1]
	}
@y
@ 명령줄 인자로 낱말 파일을 받되, 없으면 \.{sgb-words.txt}를 쓰고,
워커의 수(숫자)도 읽는다. 파일과 워커 수는 순서에 상관없이 준다. 워커 수를
안 주면 CPU 코어 갯수로 한다---곧 순차 실행이다.

@<명령줄을 처리한다@>=
	wordFile = "sgb-words.txt"
	workers := runtime.NumCPU()
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
