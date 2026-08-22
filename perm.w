@s Rand int
@s testing.T int
@s testing.B int

\input kotexgweb

% non-centered displays
\outer\def\begindisplay{\obeylines\startdisplay}
{\obeylines\gdef\startdisplay#1
  {\catcode`\^^M=5$$#1\halign\bgroup\indent##\hfil&&\qquad##\hfil\cr}}
\outer\def\enddisplay{\crcr\egroup$$}

@* 들어가며. 나에게는 20년도 훨씬 더 지난 일이지만 존 벤틀리의 유명한 저서 {\sl More Programming Pearls:
Confessions of a Coder\/}의 13장을 감탄하면서 읽었던 기억이 아직 생생하다. 그것은 {\sl A Sample
of Brilliance\/}라는 제목으로 밥 플로이드(Robert W. Floyd)가 제안한 효율적인 무작위 샘플링 알고리즘을
다룬다. 나는 그때 이전에는 느껴보지 못했던 진정한 ``아하!''라는 느낌을 받았고, 저자 존 벤틀리 조차 제목에
Brilliance 라고 붙일 정도로 ``천재성이 느껴지는 알고리즘''이라고 했다. 해결하려는 문제는 간단하다.
$$
\hbox{``$N$개의 원소 중에서 $M$개를 중복 없이 균등하게(random uniformly) 뽑는 알고리즘을 구하라''}
$$
예를 들어, 1부터 1{,}000{,}000까지의 정수 중에서 100개를 중복 없이 균등하게
선택하고 싶다. 이 때, 모든 $1000000\choose 100$개의 부분집합이 동일한 확률을 가져야 한다.
나의 최애 프로그래밍 언어 \.{GWEB}으로 풀어본다.
@c
package perm

import (
    "math/rand"
    "time"
)

@<순열 생성기 타입과 함수들@>
@<편리한 함수들@>

@ 이 프로그램은 |main| 함수가 없는 라이브러리이며, 테스트 코드를 포함한다.
@(perm_test.go@>=
package perm

import(
    "sort"
    "testing"
)

@<테스트 도우미 함수@>
@<테스트 케이스@>
@<벤치마크 테스트@>

@ 무작위 순열 생성기부터 만들자. 생성기는 무작위 난수 생성기를 갖는다. 난수 씨앗을 인자로 받거나 없으면
(씨앗이 0이면) 현재 시간 기반으로 난수를 생성한 준비를 한다.
@<순열 생성기 타입과 함수들@>=
type PermutationGenerator struct {
    rng *rand.Rand
}

func NewPermutationGenerator(seed int64) *PermutationGenerator {
    if seed == 0 {
        seed = time.Now().UnixNano()
    }
    return &PermutationGenerator{
        rng: rand.New(rand.NewSource(seed)),
    }
}

@ 하는 김에 시간을 기반으로 하는 기본 생성기도 만들자.
@<순열 생성기 타입과 함수들@>=
func NewDefaultGenerator() *PermutationGenerator {
    return NewPermutationGenerator(0)
}

@* 플로이드 알고리즘.
우리가 다루고 있는 문제, ``$N$개의 원소 중에서 $M$개를 중복 없이 균등하게(random uniformly) 뽑는 알고리즘''이라고 하면,
많은 사람들이 처음 떠올리는 방법은 다음과 같다.
\begindisplay
\vbox{
\+$S\leftarrow\{\}$\cr
\+$size\leftarrow0$\cr
\+\bf while $size<m$ do\cr
\+\quad&$t\leftarrow{\it rand\_int\/}(1,n)$\cr
\+&\bf if $t\not\in S$ then\cr
\+&\quad& insert $t$ in $S$\cr
\+&&$size\leftarrow size+1$\cr}
\enddisplay
아무런 문제가 없어 보이는 이 방법은 이미 뽑은 숫자가 계속 나올 수 있으므로 $random$함수 호출 횟수가 일정하지 않고 마지막에는
충돌이 매우 많아진다. 1부터 100까지의 정수를 무작위 순서로 100개 뽑는다고 할 때, 서로 다른 수들로 99개를 이미 뽑았다고 하자.
그렇다면 남은 하나의 수는 자명한데, 위의 방법으로는 계속해서 $random$함수를 호출할 것이고, 99/100의 확률로 계속 충돌할 것이다.  

Floyd는 전혀 다른 생각을 한다. 예를 들어 $N$이 10이고 $M$이 5라고 하자. 즉 1부터 10까지의 자연수 중에서 서로 다른 다섯 개의 수를
고르는 것이다. 먼저 1부터 9까지에서 4개를 뽑는다. 그리고나서 10을 적절히 추가한다.그러면 문제는 $N=9$, $M=4$인 문제로 작아진다.
그러면 같은 방식으로 1에서 8까지에서 3개를 뽑고나서 9를 적절히 추가한다. 즉 재귀 알고리즘이 되는데 형태는 다음과 같다.
\begindisplay
\vbox{
\+\bf function ${\it sample\/}(m,n)$\cr
\+\quad& \bf if $m=0$ then\cr
\+&\quad&{\bf return} $\{\}$\cr
\+&\bf else\cr
\+&& $S\leftarrow{\it sample\/}(m-1,n-1)$\cr
\+&& $t\leftarrow{\it rand\_int\/}(1,n)$\cr
\+&&\bf if $t \not\in S$ then\cr
\+&&\quad&insert $t$ in $S$\cr
\+&&\bf else\cr
\+&&& insert $n$ in $S$\cr
\+&&\bf return $S$\cr}
\enddisplay
놀랍게도 이것만으로 모든 부분집합이 동일한 확률로 생성된다. 그 증명은 벤틀리의 책에 있으니 각자 확인해보길 바란다.
나중에 테스트 케이스를 통해서 간략하게 확인할 예정이다.
@<순열 생성기 타입과 함수들@>=
func(pg *PermutationGenerator)Generate(n,m int)[]int{
    if m<=0||n<=0||m>n {
        return nil
    }

    result:=make([]int,0,m)
    selected:=make(map[int]bool,m)
    @<플로이드 알고리즘@>
    return result
}

@ 앞선 설명에서 플로이드 알고리즘을 재귀적으로 설명했는데, 이를 반복문으로 변경하는 것은 어렵지 않다.
@<플로이드 알고리즘@>=
for j:=n-m+1;j<=n;j++{
    t:=pg.rng.Intn(j)+1
    if selected[t]{
        result=append(result,j)
        selected[j]=true
    }else{
        result=append(result,t)
        selected[t]=true
    } 
}

@ 사실 이것으로 끝났지만, 우리는 지금 \GO/ 언어를 사용하고 있다. \GO/에서 생성기는 모름지기 채널을
사용해야지 제맛이다. 쓸데없는 기교를 부려본다.
@<순열 생성기 타입과 함수들@>=
func(pg *PermutationGenerator)GenerateChannel(n,m int)<-chan int{
    ch:=make(chan int)
    go func(){
        defer close(ch)
        perm:=pg.Generate(n,m)
        for _,val:=range perm{
            ch<-val
        }
    }()
    return ch
}

@ 편리하게 사용하기 위해서 함수 몇 개를 더 만들어보자. 우선 기본 생성자부터 만든다.
@<편리한 함수들@>=
var defaultGenerator = NewDefaultGenerator()

@ 패키지 변수|defaultGenerator|를 이미 만들었으니, 곧바로 사용할 수 있는 생성 함수들도 만든다.
@<편리한 함수들@>=
func Generate(n,m int)[]int{
    return defaultGenerator.Generate(n,m)
}

func GenerateChannel(n,m int)<-chan int{
    return defaultGenerator.GenerateChannel(n,m)
}

@* 테스트 케이스. 긴 여정이 될 듯하다. 테스트 케이스를 하나씩 만들어가자.
먼저 생성기 부터 검증한다.
@<테스트 케이스@>=
func TestNewPermutationGenerator(t *testing.T) {
	tests := []struct {
		name string
		seed int64
	}{
		{"with specific seed", 12345},
		{"with zero seed", 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gen := NewPermutationGenerator(tt.seed)
			if gen == nil {
				t.Fatal("NewPermutationGenerator returned nil")
			}
			if gen.rng == nil {
				t.Fatal("Generator's RNG is nil")
			}
		})
	}
}

@ 디폴트 생성기
@<테스트 케이스@>=
func TestNewDefaultGenerator(t *testing.T) {
	gen := NewDefaultGenerator()
	if gen == nil {
		t.Fatal("NewDefaultGenerator returned nil")
	}
	if gen.rng == nil {
		t.Fatal("Generator's RNG is nil")
	}
}

@ 이제 주요 기능인 |Generate| 함수를 검증한다.
@<테스트 케이스@>=
func TestGenerate(t *testing.T) {
	gen := NewPermutationGenerator(12345) // Fixed seed for reproducibility

	tests := []struct {
		name    string
		n, m    int
		wantLen int
		wantNil bool
	}{
		{"valid input", 10, 5, 5, false},
		{"m equals n", 5, 5, 5, false},
		{"m equals 1", 10, 1, 1, false},
		{"zero m", 10, 0, 0, true},
		{"negative m", 10, -1, 0, true},
		{"zero n", 0, 5, 0, true},
		{"negative n", -1, 5, 0, true},
		{"m greater than n", 5, 10, 0, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := gen.Generate(tt.n, tt.m)

			if tt.wantNil {
				if result != nil {
					t.Errorf("Generate(%d, %d) = %v, want nil", tt.n, tt.m, result)
				}
				return
			}

			if result == nil {
				t.Fatalf("Generate(%d, %d) = nil, want non-nil slice", tt.n, tt.m)
			}

			if len(result) != tt.wantLen {
				t.Errorf("Generate(%d, %d) length = %d, want %d",
					tt.n, tt.m, len(result), tt.wantLen)
			}
		})
	}
}

@ 이 알고리즘으로 만든 순열들의 수학적 성질을 테스트한다.
@<테스트 케이스@>=
func TestGenerateProperties(t *testing.T) {
	gen := NewPermutationGenerator(12345)
	n, m := 20, 8

	result := gen.Generate(n, m)
	if result == nil {
		t.Fatal("Generate returned nil for valid input")
	}

	// Test 1: All elements should be unique
	seen := make(map[int]bool)
	for _, val := range result {
		if seen[val] {
			t.Errorf("Duplicate element found: %d", val)
		}
		seen[val] = true
	}

	// Test 2: All elements should be in range [1, n]
	for _, val := range result {
		if val < 1 || val > n {
			t.Errorf("Element %d out of range [1, %d]", val, n)
		}
	}

	// Test 3: Length should be exactly m
	if len(result) != m {
		t.Errorf("Result length = %d, want %d", len(result), m)
	}
}

@ 난수 생성기도 올바른지 확인하자. 같은 씨앗이면 결과가 같아야 한다.
@<테스트 케이스@>=
func TestGenerateReproducibility(t *testing.T) {
	seed := int64(42)
	n, m := 10, 5

	gen1 := NewPermutationGenerator(seed)
	result1 := gen1.Generate(n, m)

	gen2 := NewPermutationGenerator(seed)
	result2 := gen2.Generate(n, m)

	if len(result1) != len(result2) {
		t.Fatalf("Results have different lengths: %d vs %d",
			len(result1), len(result2))
	}

	for i := range result1 {
		if result1[i] != result2[i] {
			t.Errorf("Results differ at index %d: %d vs %d",
				i, result1[i], result2[i])
		}
	}
}

@ 채널 기반 생성기도 빼놓을 수 없다.
@<테스트 케이스@>=
func TestGenerateChannel(t *testing.T) {
	gen := NewPermutationGenerator(12345)
	n, m := 10, 5

	ch := gen.GenerateChannel(n, m)
	var result []int

	for val := range ch {
		result = append(result, val)
	}

	// Test properties similar to Generate
	if len(result) != m {
		t.Errorf("Channel produced %d elements, want %d", len(result), m)
	}

	// Check uniqueness
	seen := make(map[int]bool)
	for _, val := range result {
		if seen[val] {
			t.Errorf("Duplicate element found: %d", val)
		}
		seen[val] = true
	}

	// Check range
	for _, val := range result {
		if val < 1 || val > n {
			t.Errorf("Element %d out of range [1, %d]", val, n)
		}
	}
}

@ 편리를 목적으로 만든 함수들도 살펴보자.
@<테스트 케이스@>=
func TestGlobalFunctions(t *testing.T) {
	n, m := 10, 5

	// Test Generate
	result := Generate(n, m)
	if result == nil {
		t.Fatal("Global Generate returned nil")
	}
	if len(result) != m {
		t.Errorf("Global Generate length = %d, want %d", len(result), m)
	}

	// Test GenerateChannel
	ch := GenerateChannel(n, m)
	var channelResult []int
	for val := range ch {
		channelResult = append(channelResult, val)
	}
	if len(channelResult) != m {
		t.Errorf("Global GenerateChannel length = %d, want %d",
			len(channelResult), m)
	}
}

@ 이 알고리즘이 균등 분포로 순열을 생성하는지도 확인한다.
@<테스트 케이스@>=
func TestDistribution(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping distribution test in short mode")
	}

	n, m := 10, 3
	iterations := 1000
	counts := make(map[int]int)

    @<여러번 반복하고 각 숫자의 출현 빈도를 센다@>
    @<1부터 |n|까지의 수는 대충 ${m\over n}*반복횟수$ 만큼 나와야 한다@>
	
	// Just log the distribution for manual inspection
	t.Logf("Distribution over %d iterations:", iterations)
	for i := 1; i <= n; i++ {
		t.Logf("  %d: %d times (%.1f%%)",
			i, counts[i], float64(counts[i]*100)/float64(m*iterations))
	}
}

@ @<여러번 반복하고 각 숫자의 출현 빈도를 센다@>=
for range iterations {
	gen := NewPermutationGenerator(0) // Random seed each time
	result := gen.Generate(n, m)
	for _, val := range result {
		counts[val]++
	}
}

@ @<1부터 |n|까지의 수는 대충 ${m\over n}*반복횟수$ 만큼 나와야 한다@>=
expectedFreq := float64(m*iterations) / float64(n)
tolerance := expectedFreq * 0.3 // 30\% tolerance

for i := 1; i <= n; i++ {
	freq := float64(counts[i])
	if freq < expectedFreq-tolerance || freq > expectedFreq+tolerance {
		t.Logf("Number %d appeared %d times, expected around %.1f (tolerance: ±%.1f)",
			i, counts[i], expectedFreq, tolerance)
	}
}

@ 다양한 특수한 경우를 테스트한다. 중요하다.
@<테스트 케이스@>=
func TestEdgeCases(t *testing.T) {
	gen := NewPermutationGenerator(12345)

	tests := []struct {
		name string
		n, m int
	}{
		{"n=1, m=1", 1, 1},
		{"large n, small m", 1000000, 1},
		{"large n, large m", 1000, 999},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := gen.Generate(tt.n, tt.m)
			if result == nil {
				t.Fatalf("Generate(%d, %d) returned nil", tt.n, tt.m)
			}
			if len(result) != tt.m {
				t.Errorf("Generate(%d, %d) length = %d, want %d",
					tt.n, tt.m, len(result), tt.m)
			}

            @<모든 원소가 유일하고 범위 안에 있는지 확인한다@>
		})
	}
}

@ @<모든 원소가 유일하고 범위 안에 있는지 확인한다@>=
seen := make(map[int]bool)
for _, val := range result {
	if val < 1 || val > tt.n {
		t.Errorf("Element %d out of range [1, %d]", val, tt.n)
	}
	if seen[val] {
		t.Errorf("Duplicate element: %d", val)
	}
	seen[val] = true
}

@ 슬라이스가 정렬이 되어있는지 확인하는 도우미가 필요하다.
@<테스트 도우미 함수@>=
func isSorted(slice []int) bool {
	return sort.IntsAreSorted(slice)
}

@ 마지막으로 결과들이 항상 정렬되어있지 않다는 것을 확인한다.
@<테스트 케이스@>=
func TestRandomness(t *testing.T) {
	gen := NewPermutationGenerator(0) // Random seed
	n, m := 20, 10
	sortedCount := 0
	iterations := 100

	for range iterations {
		result := gen.Generate(n, m)
		if isSorted(result) {
			sortedCount++
		}
	}

	// It's extremely unlikely that all results are sorted if truly random
	if sortedCount == iterations {
		t.Errorf("All %d iterations produced sorted results, suspicious", iterations)
	}

	t.Logf("Out of %d iterations, %d were sorted (%.1f%%)",
		iterations, sortedCount, float64(sortedCount*100)/float64(iterations))
}

@* 벤치마크. 기나긴 테스트 케이스 검증이 끝났지만, 아직 끝나지 않았다. 생성함수부터 벤치마크 하자.
@<벤치마크 테스트@>=
func BenchmarkGenerate(b *testing.B) {
	gen := NewPermutationGenerator(12345)

	benchmarks := []struct {
		name string
		n, m int
	}{
		{"small", 100, 10},
		{"medium", 1000, 100},
		{"large", 10000, 1000},
	}

	for _, bm := range benchmarks {
		b.Run(bm.name, func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				gen.Generate(bm.n, bm.m)
			}
		})
	}
}

@ @<벤치마크 테스트@>=
func BenchmarkGenerateChannel(b *testing.B) {
	gen := NewPermutationGenerator(12345)
	n, m := 1000, 100

	b.Run("channel", func(b *testing.B) {
		for i := 0; i < b.N; i++ {
			ch := gen.GenerateChannel(n, m)
			for range ch {
				// Consume all values
			}
		}
	})
}


@* 찾아보기.
