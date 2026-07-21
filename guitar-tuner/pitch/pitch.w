@i ../types.w

\input kotexgweb
\def\title{Pitch 코어}

@* 들어가며.
\.{pitch} 는 마이크나 화면에 전혀 의존하지 않는 {\it 순수\/} 음정 검출 코어다.
오로지 |float64| 표본과 |Reading| 값만 주고받으므로, 콘솔$\cdot$웹$\cdot$GUI 어느
프런트에서나 그대로 재사용할 수 있다. 프런트가 알아야 할 것은 |Stream| 하나뿐이다:
$$\hbox{|pitch.NewStream(cfg)|}\ \to\ \hbox{|Push(samples)|}\ \to\ \hbox{|[]Result|}.$$

\noindent 이 파일의 얼개는 설정과 결과 자료형, 음악 이론(주파수$\leftrightarrow$음이름,
개방현), YIN 검출기, 그리고 그 앞뒤로 붙는 신호처리 단들(저주파 제거, 어택 억제,
안정화, 정확 잠금)을 하나로 엮는 |Stream|이다.
@c
package pitch

import (
	"math"
	"sort"
)

@<튜닝 상수@>@;
@<설정과 결과 자료형@>@;
@<주파수를 음이름으로@>@;
@<개방현@>@;
@<YIN 검출기@>@;
@<저주파 제거@>@;
@<어택 억제@>@;
@<검출 안정화@>@;
@<정확 잠금@>@;
@<스트림 파이프라인@>@;

@ 사람이 바꾸지 않는 내부 상수들이다. 표본화율 44100\,Hz에서 분석 창 |bufferSize|%
를 4096 표본($\approx93$\,ms)으로 잡으면, YIN이 훑는 지연(lag)의 최대치는 그
절반인 2048 표본이 되어 검출 하한이 $44100/2048\approx21$\,Hz까지 내려간다. 기타
6번 줄 저음~E(E2, $82.4$\,Hz)를 여유 있게 담는다. 나머지 상수의 뜻은 해당 단에서
설명한다.
@<튜닝 상수@>=
const (
	bufferSize = 4096          // YIN 분석 창 크기(표본)
	hopSize    = bufferSize / 2 // 창을 미는 간격
	threshold  = 0.15          // YIN 절대 임계값

	highpassCut    = 70 // 고역통과 차단주파수(Hz) — E2(82Hz) 아래 잡음 제거
	highpassStages = 2  // 고역통과 단수

	onsetRatio      = 1.8  // 직전 프레임의 이 배수를 넘게 커지면 어택
	onsetFloor      = 0.02 // 이보다 커야 어택으로 친다
	clarityGate     = 0.95 // 명료도가 이 이상 회복되면 어택 종료
	maxAttackFrames = 6    // 어택 억제 안전 상한(프레임)

	smoothWindow = 5 // 중앙값 평활 창(프레임)

	inTuneCents   = 5  // 이 안이면 '정확'
	unlockCents   = 12 // 잠금 해제 문턱(히스테리시스)
	lockFrames    = 5  // 정확이 이만큼 이어지면 잠근다
	chimeCooldown = 22 // 신호음 재발 방지(프레임 ≈ 1초)
)

@ |Config|는 실행할 때 정하는 설정이다: 기준음 A4(관현악단은 442\,Hz에 맞추기도
한다), 표본화율(장치 호환), 무음 감도. |Reading|은 검출 한 번의 결과로,
|Voiced|가 거짓이면 나머지 값은 뜻이 없다.
@<설정과 결과 자료형@>=
type Config struct {
	A4         float64 // 기준음 A4 주파수(Hz)
	SampleRate int     // 표본화율(Hz)
	MinRMS     float64 // 무음 문턱(RMS) — 작을수록 민감
}

// |DefaultConfig|는 표준 기본값을 준다.
func DefaultConfig() Config {
	return Config{A4: 440, SampleRate: 44100, MinRMS: 0.01}
}

type Reading struct {
	Voiced  bool
	Freq    float64 // 기본 주파수(Hz)
	Name    string  // 가장 가까운 음이름 (예: ``E")
	Octave  int     // 옥타브 (예: 2)
	Cents   float64 // 그 음에서 벗어난 정도(-50~+50센트)
	RMS     float64 // 창의 실효값(에너지) — 어택 감지에 쓴다
	Clarity float64 // 주기의 뚜렷함 (1 − d'(τ*)) — 적응형 릴리스에 쓴다
}

@* 주파수를 음이름으로.
주파수 $f$를 MIDI 음 번호로 옮기면 반음이 정수 눈금이 된다.
$$m=69+12\log_2(f/A_4),$$
여기서 69는 기준음 A4의 번호다. $m$을 반올림한 정수 $n$이 가장 가까운 음이고,
소수 부분에 100을 곱하면 그 음에서 벗어난 {\it 센트\/}가 된다(한 반음 $=100$
센트). 표준 튜닝의 여섯 줄 E2-A2-D3-G3-B3-E4도 모두 이 눈금 위의 점일 뿐이라,
크로매틱 튜너 하나로 다 맞출 수 있다. |FreqToNote|는 주파수를 (기준음 a4 아래에서)
가장 가까운 음이름·옥타브·센트로 옮긴다.
@<주파수를 음이름으로@>=
var noteNames = [12]string{
	"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B",
}

func FreqToNote(f, a4 float64) (name string, octave int, cents float64) {
	midi := 69 + 12*math.Log2(f/a4)
	nearest := int(math.Round(midi))
	cents = (midi - float64(nearest)) * 100
	name = noteNames[((nearest%12)+12)%12]
	octave = nearest/12 - 1
	return
}

@* 개방현.
표준 튜닝의 여섯 개방현은 어느 프런트에서나 쓰는 음악 이론이라 코어에 둔다.
@<개방현@>=
// |GuitarString|은 개방현 하나(이름과 주파수)다.
type GuitarString struct {
	Name string
	Freq float64
}

// |OpenStrings|는 표준 튜닝의 여섯 개방현 (6번줄 → 1번줄).
var OpenStrings = [6]GuitarString{
	{"E", 82.41}, {"A", 110.00}, {"D", 146.83},
	{"G", 196.00}, {"B", 246.94}, {"E", 329.63},
}

// |NearestString|은 |freq|에 로그 눈금상 가장 가까운 개방현의 번호를 준다
// (옥타브가 달라도 공평하다).
func NearestString(freq float64) int {
	best, bestDiff := 0, math.Inf(1)
	for i, s := range OpenStrings {
		if d := math.Abs(1200 * math.Log2(freq/s.Freq)); d < bestDiff {
			best, bestDiff = i, d
		}
	}
	return best
}

@* YIN 음정 검출.
YIN 알고리즘(de~Cheveign\'e \& Kawahara, 2002)은 자기상관 대신 {\it 차이함수\/}를
쓴다. 창 안의 표본열 $x$ 에 대해, 지연 $\tau$ 만큼 어긋나게 겹쳤을 때의 제곱오차
$$d(\tau)=\sum_{j=0}^{W-1}\bigl(x_j-x_{j+\tau}\bigr)^2$$
를 모든 $\tau$에 대해 구한다. 신호가 주기 $T$로 반복되면 $\tau=T$ 에서 $d$가
바닥으로 떨어진다. 여기서 $W=$ |bufferSize|$/2$ 이고, $j+\tau$가 창을 넘지 않도록
전체 버퍼는 그 두 배 크기를 쓴다.

@ 검출기는 설정 |cfg|와 재사용할 작업 버퍼 |yin|을 들고 다닌다. |yin|의 길이는
$W$, 곧 훑을 수 있는 지연의 개수다.
@<YIN 검출기@>=
type detector struct {
	cfg Config
	yin []float64 // 차이함수 d'(τ)를 담는 길이 W의 작업 버퍼
}

func newDetector(cfg Config) *detector {
	return &detector{cfg: cfg, yin: make([]float64, bufferSize/2)}
}

@ 검출은 논문의 네 단계를 그대로 따른다: 차이함수 → 누적평균정규화 →
절대임계값 → 포물선 보간. 주기를 못 찾으면 |Voiced|가 거짓인 |Reading|을
돌려주되, 어택 판정에 쓰도록 에너지 |RMS|는 실어 보낸다.
@<YIN 검출기@>=
func (d *detector) detect(buf []float64) Reading {
	rms := rmsOf(buf)
	if rms < d.cfg.MinRMS {
		return Reading{RMS: rms} // 잡음뿐인 조용한 구간
	}
	@<차이함수를 구한다@>
	@<누적평균으로 정규화한다@>
	tau := d.absoluteThreshold()
	if tau < 0 {
		return Reading{RMS: rms} // 임계값 아래로 내려가는 골이 없다
	}
	betterTau := d.parabolicInterpolation(tau)
	freq := float64(d.cfg.SampleRate) / betterTau
	name, octave, cents := FreqToNote(freq, d.cfg.A4)
	clarity := 1 - d.yin[tau] // 골이 깊을수록(주기가 뚜렷할수록) 1에 가깝다
	return Reading{
		Voiced: true, Freq: freq, Name: name, Octave: octave,
		Cents: cents, RMS: rms, Clarity: clarity,
	}
}

@ 에너지는 창의 실효값(RMS)으로 잰다. 무음 문지기와 어택 감지가 모두 이 값을 쓴다.
@<YIN 검출기@>=
func rmsOf(buf []float64) float64 {
	var sumSq float64
	for _, s := range buf {
		sumSq += s * s
	}
	return math.Sqrt(sumSq / float64(len(buf)))
}

@ {\bf 1단계---차이함수.} 정의 그대로 이중 합을 돈다. 가장 무거운 부분이라
$O(W^2)$이지만, $W=2048$에 초당 스무 번이면 넉넉히 실시간이다. |detect| 안에서
한 번만 쓰므로 따로 메서드로 두지 않는다.
@<차이함수를 구한다@>=
W := len(d.yin)
for tau := 0; tau < W; tau++ {
	var sum float64
	for j := 0; j < W; j++ {
		delta := buf[j] - buf[j+tau]
		sum += delta * delta
	}
	d.yin[tau] = sum
}

@ {\bf 2단계---누적평균정규화.} 생 차이함수는 $\tau=0$ 에서 항상 0이라
그대로 쓰면 늘 0을 ``고른다''. 그래서 각 $d(\tau)$를 처음부터의 누적 평균으로
나눈 $d'(\tau)$로 바꾼다.
$$d'(\tau)=\cases{1,&$\tau=0$;\cr
  d(\tau)\Big/\Bigl[{1\over\tau}\sum_{k=1}^{\tau}d(k)\Bigr],&그 밖.\cr}$$
이러면 낮은 $\tau$의 얕은 골들이 눌리고 진짜 주기의 골만 도드라진다.
@<누적평균으로 정규화한다@>=
d.yin[0] = 1
var running float64
for tau := 1; tau < len(d.yin); tau++ {
	running += d.yin[tau]
	if running == 0 {
		d.yin[tau] = 1
	} else {
		d.yin[tau] *= float64(tau) / running
	}
}

@ {\bf 3단계---절대임계값.} $d'(\tau)$가 |threshold| 아래로 처음 내려가는
$\tau$를 찾되, 곧바로 멈추지 않고 그 {\it 국소 최솟값}까지 더 내려간다.
그래야 배음이 만드는 이른 골에 속지 않는다. 끝내 임계값을 못 넘으면 $-1$.
@<YIN 검출기@>=
func (d *detector) absoluteThreshold() int {
	for tau := 2; tau < len(d.yin); tau++ {
		if d.yin[tau] < threshold {
			for tau+1 < len(d.yin) && d.yin[tau+1] < d.yin[tau] {
				tau++
			}
			return tau
		}
	}
	return -1
}

@ {\bf 4단계---포물선 보간.} 정수 지연 |tau|는 표본 단위라 눈금이 거칠다.
골 주변 세 점 $(\tau-1,\tau,\tau+1)$에 포물선을 맞춰 꼭짓점의 실수 위치를
구하면, 한 표본 사이를 부드럽게 채워 주파수 분해능이 크게 좋아진다.
@<YIN 검출기@>=
func (d *detector) parabolicInterpolation(tau int) float64 {
	if tau < 1 || tau+1 >= len(d.yin) {
		return float64(tau)
	}
	s0, s1, s2 := d.yin[tau-1], d.yin[tau], d.yin[tau+1]
	denom := 2*s1 - s2 - s0
	if denom == 0 {
		return float64(tau)
	}
	return float64(tau) + (s2-s0)/(2*denom)
}

@* 입력 전처리: 저주파 제거.
실제 마이크는 기타 소리 말고도 낮은 잡음을 함께 담는다: DC 오프셋, 책상 진동 같은
수십~Hz 럼블, 60\,Hz 전원 험. 기타에서 가장 낮은 음이 E2($82.4$\,Hz)이므로 그
아래는 모두 잡음이다. 문제는 이 저주파가 {\it 조용한 고음현}(B3, E4)의 약한
기본음을 가려, YIN이 럼블의 주기를 잡거나 아예 검출을 접게 만든다는 점이다.
그래서 창에 넣기 전에 {\it 고역통과}(high-pass) 필터로 저주파를 걷어낸다.

@ 원폴 고역통과(DC 차단기)의 차분식은
$$y_n = x_n - x_{n-1} + R\,y_{n-1},\qquad R=e^{-2\pi f_c/f_s}$$
로, DC에 영점을 두어 오프셋을 완전히 없애고 차단주파수 $f_c$ 아래를 눌러 준다.
한 단은 6\,dB/oct로 완만하므로 |stages|단을 이어 붙여 험까지 확실히 줄인다.
필터는 표본 스트림에 {\it 연속}으로 걸어야 하므로 직전 입력$\cdot$출력 상태를
단별로 들고 다닌다.
@<저주파 제거@>=
type highpass struct {
	r    float64
	x, y []float64 // 각 단의 직전 입력/출력
}

func newHighpass(cutoff float64, stages, sampleRate int) *highpass {
	return &highpass{
		r: math.Exp(-2 * math.Pi * cutoff / float64(sampleRate)),
		x: make([]float64, stages),
		y: make([]float64, stages),
	}
}

func (h *highpass) step(in float64) float64 {
	v := in
	for k := range h.x {
		out := v - h.x[k] + h.r*h.y[k]
		h.x[k], h.y[k] = v, out
		v = out
	}
	return v
}

@* 어택 트랜지언트 억제.
기타 줄을 튕기는 순간에는 현이 아직 고르게 진동하지 않아, 짧은 {\it 어택
트랜지언트} 구간 동안 소리가 시끄럽고 배음이 뒤섞인다. 이 구간의 검출값은
주파수가 출렁이고 옥타브 오류도 잦다. |onsetGate|는 에너지가 갑자기 솟는 순간을
{\it 어택 시작}(onset)으로 보고, 현이 안정될 때까지 검출값을 버린다.

얼마나 오래 버릴지를 {\it 고정} 프레임 수로 정하면, 빨리 안정되는 고음현은
쓸데없이 오래 죽이고 느리게 안정되는 저음현은 덜 죽인다. 그래서 {\it 적응형}으로
푼다: 명료도(|Clarity|)가 |clarityGate| 이상으로 회복되면---즉 주기가 다시
또렷해지면---그 순간 릴리스한다. 명료도가 끝내 안 돌아오는 병적인 경우를 대비해
|maxAttackFrames|를 안전 상한으로 둔다.
@<어택 억제@>=
type onsetGate struct {
	prevRMS  float64 // 직전 프레임의 실효값
	settling bool    // 어택 뒤 정착을 기다리는 중인가
	waited   int     // 억제한 프레임 수(안전 상한용)
}

func (g *onsetGate) pass(r Reading) Reading {
	if r.RMS > onsetFloor && r.RMS > g.prevRMS*onsetRatio {
		g.settling, g.waited = true, 0 // 어택 시작 → 정착 대기
	}
	g.prevRMS = r.RMS
	if g.settling {
		settled := r.Voiced && r.Clarity >= clarityGate
		if settled || g.waited >= maxAttackFrames {
			g.settling = false // 정착됨(또는 상한 도달) → 릴리스
		} else {
			g.waited++
			return Reading{} // 아직 어택 — 억제
		}
	}
	return r
}

@* 검출 안정화.
한 창씩 따로 검출하면 값이 프레임마다 조금씩 떨린다. 게다가 YIN은 이따금 기본
주파수 대신 그 {\it 옥타브 위}(두 배)나 {\it 아래}(절반)를 골라 순간적으로
튀기도 한다. |smoother|는 최근 검출들의 짧은 이력을 들고 다니며 두 가지를 한다:
(1)~새 값이 이력 중앙값의 두 배나 절반에 가까우면 옥타브 오류로 보고 접어 맞추고,
(2)~이력의 {\it 중앙값}(median)을 내보내 이상치 하나에 흔들리지 않게 한다.
중앙값에서 음이름을 다시 매기려면 기준음이 필요하므로 |a4|를 지닌다.
@<검출 안정화@>=
type smoother struct {
	a4   float64
	hist []float64 // 최근 (옥타브 교정된) 주파수들
}

func newSmoother(a4 float64) *smoother {
	return &smoother{a4: a4, hist: make([]float64, 0, smoothWindow)}
}

@ |push|는 원 검출 하나를 받아 안정화한 |Reading|을 돌려준다. 무음이면 이력을
비우고 그대로 통과시킨다. 유효한 값이면 옥타브를 맞춘 뒤 이력에 넣고, 이력의
중앙값에서 음이름과 센트를 다시 계산해 내보낸다.
@<검출 안정화@>=
func (s *smoother) push(r Reading) Reading {
	if !r.Voiced {
		s.hist = s.hist[:0]
		return r
	}
	f := r.Freq
	if len(s.hist) > 0 {
		f = snapOctave(f, median(s.hist))
	}
	s.hist = append(s.hist, f)
	if len(s.hist) > smoothWindow {
		s.hist = s.hist[1:]
	}
	sf := median(s.hist)
	name, octave, cents := FreqToNote(sf, s.a4)
	return Reading{Voiced: true, Freq: sf, Name: name, Octave: octave, Cents: cents}
}

@ YIN의 옥타브 오류는 참값의 거의 정확히 두 배나 절반으로 나타난다. 그래서
후보 $\{f,\,f/2,\,2f\}$ 중 기준값 |ref|에 (로그 눈금에서) 가장 가까운 것을 고른다.
옥타브 관계가 아닌 {\it 진짜 다른 음}을 연주하면 |f| 자신이 가장 가까워 그대로
남으므로, 이 교정은 옥타브 튐만 골라 잡는다.
@<검출 안정화@>=
func snapOctave(f, ref float64) float64 {
	best, bestCents := f, math.Abs(1200*math.Log2(f/ref))
	for _, c := range [2]float64{f / 2, f * 2} {
		if d := math.Abs(1200 * math.Log2(c/ref)); d < bestCents {
			best, bestCents = c, d
		}
	}
	return best
}

@ 중앙값은 이력을 복사해 정렬한 뒤 가운데 값을 취한다(원본 순서는 건드리지
않는다). 창이 작아 정렬 비용은 무시할 만하다.
@<검출 안정화@>=
func median(xs []float64) float64 {
	tmp := append([]float64(nil), xs...)
	sort.Float64s(tmp)
	return tmp[len(tmp)/2]
}

@* 정확 잠금.
음이 충분히 오래 정확하게 맞으면 {\it 잠금}으로 보고, 프런트가 화면을 강조하거나
신호음을 울릴 수 있게 알린다. |locker|는 |Cents|가 |inTuneCents| 안에
|lockFrames| 프레임 이어지면 잠그고, 신호음을 울릴 {\it 상승 에지}를 |chime|로
알린다. 두 장치로 튼튼하게 만든다: {\it 히스테리시스}(한 번 잠기면 |unlockCents|
밖으로 나가야 풀림)로 살짝 흔들려도 강조가 깜빡이지 않게 하고, {\it 쿨다운}으로
마이크가 제 신호음을 주워 다시 잠그더라도 벨이 연달아 울리지 않게 한다.
@<정확 잠금@>=
type locker struct {
	count    int  // 연속 정확 프레임 수
	locked   bool // 현재 잠금 여부
	cooldown int  // 신호음 쿨다운 카운트다운
}

func (l *locker) update(r Reading) (locked, chime bool) {
	@<쿨다운을 한 프레임 줄인다@>
	@<잠긴 상태면 풀림 여부만 보고 반환한다@>
	@<잠기지 않았으면 연속 정확 프레임을 센다@>
	return l.locked, chime
}

@ 신호음 쿨다운은 매 프레임 하나씩 줄어든다(0 아래로는 안 내려간다).
@<쿨다운을 한 프레임 줄인다@>=
if l.cooldown > 0 {
	l.cooldown--
}

@ 이미 잠긴 상태에서는 새로 셀 것이 없다: |unlockCents| 밖으로 나가거나
무음이 되면 풀고, 그 결과만 신호음 없이 돌려준다.
@<잠긴 상태면 풀림 여부만 보고 반환한다@>=
if l.locked {
	if !r.Voiced || math.Abs(r.Cents) > unlockCents {
		l.locked, l.count = false, 0
	}
	return l.locked, false
}

@ 풀린 상태에서는 정확한 프레임을 세다가 |lockFrames|에 이르면 잠근다.
쿨다운이 0일 때만 신호음을 울린 뒤 쿨다운을 다시 채운다.
@<잠기지 않았으면 연속 정확 프레임을 센다@>=
if r.Voiced && math.Abs(r.Cents) < inTuneCents {
	l.count++
	if l.count >= lockFrames {
		l.locked = true
		if l.cooldown == 0 {
			chime = true
			l.cooldown = chimeCooldown
		}
	}
} else {
	l.count = 0
}

@* 스트림 파이프라인.
|Stream|은 앞의 단들을 하나로 엮어, 표본을 받아 안정된 결과를 내는 검출
파이프라인이다. 프런트엔드는 이 하나만 알면 된다. 내부 순서는
$$\hbox{고역통과}\to\hbox{YIN 검출}\to\hbox{어택 억제}\to\hbox{안정화}\to
  \hbox{정확 잠금}$$
이다.
@<스트림 파이프라인@>=
type Stream struct {
	hp     *highpass
	det    *detector
	gate   *onsetGate
	sm     *smoother
	lk     *locker
	window []float64
}

@ 프런트가 받는 결과다: 검출값(|Reading|)에 잠금$\cdot$신호음 신호를 얹었다.
@<스트림 파이프라인@>=
// |Result|는 한 프레임의 결과 — 검출값에 잠금·신호음 신호를 얹은 것.
type Result struct {
	Reading
	Locked bool // 정확히 맞아 잠긴 상태인가
	Chime  bool // 이 프레임에 잠금이 새로 걸렸는가(신호음)
}

@ 각 단은 |cfg|(기준음$\cdot$표본화율$\cdot$감도)를 나눠 가지며, 창 버퍼는
YIN 이 훑을 때 넘치지 않도록 |bufferSize|의 두 배로 미리 잡아 둔다.
@<스트림 파이프라인@>=
func NewStream(cfg Config) *Stream {
	return &Stream{
		hp:     newHighpass(highpassCut, highpassStages, cfg.SampleRate),
		det:    newDetector(cfg),
		gate:   &onsetGate{},
		sm:     newSmoother(cfg.A4),
		lk:     &locker{},
		window: make([]float64, 0, 2*bufferSize),
	}
}

@ |Push|는 표본을 고역통과에 연속으로 흘려 넣고, |bufferSize| 표본이 찰 때마다 한
창을 검출$\cdot$억제$\cdot$안정화$\cdot$잠금까지 처리해 |Result|로 모은다. 창은
매번 |hopSize| 만큼 밀어 겹침을 남긴다. 프런트는 돌려받은 결과들을 그리기만 하면
된다.
@<스트림 파이프라인@>=
func (s *Stream) Push(samples []float64) []Result {
	for _, x := range samples {
		s.window = append(s.window, s.hp.step(x))
	}
	var out []Result
	for len(s.window) >= bufferSize {
		r := s.sm.push(s.gate.pass(s.det.detect(s.window[:bufferSize])))
		locked, chime := s.lk.update(r)
		out = append(out, Result{Reading: r, Locked: locked, Chime: chime})
		s.window = s.window[hopSize:]
	}
	return out
}

@** 검사.
순수 코어를 확인하는 검사다. 같은 \.{pitch} 패키지에 속하는 부수 파일
\.{@(pitch\_test.go@>}로 뽑아, 소문자로 감춘 |detector|$\cdot$|smoother| 같은
속살에도 곧장 손댈 수 있게 한다. 표본화율 등은 |testCfg|로 고정해 쓴다.
@(pitch_test.go@>=
package pitch

import (
	"math"
	"math/rand"
	"testing"
)

var testCfg = DefaultConfig()

@<사인파 생성 도우미@>@;
@<개방현 검출 테스트@>@;
@<음이름 변환 테스트@>@;
@<기준음 설정 테스트@>@;
@<가까운 개방현 테스트@>@;
@<RMS 테스트@>@;
@<고역통과 테스트@>@;
@<잡음 하 검출 테스트@>@;
@<어택 억제 테스트@>@;
@<정확 잠금 테스트@>@;
@<중앙값 테스트@>@;
@<옥타브 교정 테스트@>@;
@<평활기 테스트@>@;
@<스트림 테스트@>@;

@ |sine|은 주파수 |freq|의 순음을 한 창(|bufferSize| 표본)만큼 만든다. 진폭은
무음 문지기를 넉넉히 넘도록 $0.5$로 둔다.
@<사인파 생성 도우미@>=
func sine(freq float64) []float64 {
	buf := make([]float64, bufferSize)
	for i := range buf {
		buf[i] = 0.5 * math.Sin(2*math.Pi*freq*float64(i)/float64(testCfg.SampleRate))
	}
	return buf
}

@ 표준 튜닝 여섯 줄의 주파수에 순음을 넣어, YIN이 주파수를 $0.5$\,Hz 안으로,
음이름과 옥타브를 정확히, 센트를 $\pm5$ 안으로 찾아내는지 본다.
@<개방현 검출 테스트@>=
func TestDetectStrings(t *testing.T) {
	cases := []struct {
		freq   float64
		name   string
		octave int
	}{
		{82.41, "E", 2}, {110.00, "A", 2}, {146.83, "D", 3},
		{196.00, "G", 3}, {246.94, "B", 3}, {329.63, "E", 4},
	}
	det := newDetector(testCfg)
	for _, c := range cases {
		r := det.detect(sine(c.freq))
		if !r.Voiced {
			t.Errorf("%.2fHz: 검출 실패", c.freq)
			continue
		}
		if math.Abs(r.Freq-c.freq) > 0.5 {
			t.Errorf("%.2fHz: freq=%.2f (오차 %.2f)", c.freq, r.Freq, r.Freq-c.freq)
		}
		if r.Name != c.name || r.Octave != c.octave {
			t.Errorf("%.2fHz: 음이름 %s%d (기대 %s%d)", c.freq, r.Name, r.Octave, c.name, c.octave)
		}
		if math.Abs(r.Cents) > 5 {
			t.Errorf("%.2fHz: cents=%.1f (0에 가까워야)", c.freq, r.Cents)
		}
	}
}

@ 무음(진폭 0)은 |Voiced|가 거짓이어야 한다.
@<개방현 검출 테스트@>=
func TestSilenceUnvoiced(t *testing.T) {
	if r := newDetector(testCfg).detect(make([]float64, bufferSize)); r.Voiced {
		t.Errorf("무음인데 Voiced=true (freq=%.2f)", r.Freq)
	}
}

@ 주파수를 음이름으로 옮기는 변환을 몇 점에서 확인한다: 기준음 A4, 가온다 C4,
그리고 A4에서 정확히 $+30$ 센트 높은 점.
@<음이름 변환 테스트@>=
func TestFreqToNote(t *testing.T) {
	name, octave, cents := FreqToNote(440, 440)
	if name != "A" || octave != 4 || math.Abs(cents) > 0.01 {
		t.Errorf("440Hz: %s%d %+.2f¢ (기대 A4 0¢)", name, octave, cents)
	}
	name, octave, _ = FreqToNote(261.63, 440)
	if name != "C" || octave != 4 {
		t.Errorf("261.63Hz: %s%d (기대 C4)", name, octave)
	}
	sharp := 440 * math.Exp2(30.0/1200)
	if name, octave, cents := FreqToNote(sharp, 440); name != "A" || octave != 4 || math.Abs(cents-30) > 0.1 {
		t.Errorf("A4+30¢ 지점: %s%d %+.2f¢ (기대 A4 +30¢)", name, octave, cents)
	}
}

@ 기준음 |a4|를 바꾸면 눈금이 통째로 옮겨간다: |a4| $=442$ 일 때 442\,Hz가 $0$
센트인 A4가 되고, 예전 기준 440\,Hz는 그만큼 낮은($\approx-7.85$센트) 음이 된다.
@<기준음 설정 테스트@>=
func TestReferenceA4(t *testing.T) {
	if name, octave, cents := FreqToNote(442, 442); name != "A" || octave != 4 || math.Abs(cents) > 0.01 {
		t.Errorf("a4=442, 442Hz: %s%d %+.2f¢ (기대 A4 0¢)", name, octave, cents)
	}
	want := 1200 * math.Log2(440.0/442.0) // ≈ -7.85¢
	if _, _, cents := FreqToNote(440, 442); math.Abs(cents-want) > 0.1 {
		t.Errorf("a4=442, 440Hz: %+.2f¢ (기대 %+.2f¢)", cents, want)
	}
}

@ 가장 가까운 개방현 고르기: 각 현의 정확한 주파수는 자기 자신을, 현 사이의
주파수는 로그 눈금상 더 가까운 쪽을 가리켜야 한다.
@<가까운 개방현 테스트@>=
func TestNearestString(t *testing.T) {
	for i, s := range OpenStrings {
		if got := NearestString(s.Freq); got != i {
			t.Errorf("%.2fHz: NearestString=%d (기대 %d)", s.Freq, got, i)
		}
	}
	if got := NearestString(90); got != 0 { // E2(82.41)에 더 가깝다
		t.Errorf("90Hz: NearestString=%d (기대 0=E2)", got)
	}
	if got := NearestString(300); got != 5 { // E4(329.63)에 더 가깝다
		t.Errorf("300Hz: NearestString=%d (기대 5=E4)", got)
	}
}

@ RMS: 상수 신호의 실효값은 그 크기와 같고, 진폭 $A$ 사인파의 실효값은 $A/\sqrt2$다.
@<RMS 테스트@>=
func TestRMSOf(t *testing.T) {
	buf := make([]float64, 100)
	for i := range buf {
		buf[i] = 0.5
	}
	if got := rmsOf(buf); math.Abs(got-0.5) > 1e-9 {
		t.Errorf("rmsOf(0.5 상수)=%.4f (기대 0.5)", got)
	}
	if got := rmsOf(sine(110)); math.Abs(got-0.5/math.Sqrt2) > 0.01 { // 진폭 0.5
		t.Errorf("rmsOf(사인 진폭0.5)=%.4f (기대 %.4f)", got, 0.5/math.Sqrt2)
	}
}

@ |filterGain|은 필터가 자리 잡도록 앞부분을 버리고, 뒤쪽 구간의 RMS 비로
주어진 주파수의 통과 이득을 잰다.
@<고역통과 테스트@>=
func filterGain(freq float64) float64 {
	hp := newHighpass(highpassCut, highpassStages, testCfg.SampleRate)
	const n = 8192
	var inSq, outSq float64
	for i := 0; i < n; i++ {
		x := math.Sin(2 * math.Pi * freq * float64(i) / float64(testCfg.SampleRate))
		y := hp.step(x)
		if i >= n/2 { // 정착 후 구간만
			inSq += x * x
			outSq += y * y
		}
	}
	return math.Sqrt(outSq / inSq)
}

@ 저주파(DC, 40\,Hz)는 크게 줄고 기타 대역(300\,Hz)은 거의 그대로 통과해야
한다. DC는 특히 완전히 사라져야 하므로 상수 입력을 오래 흘려 확인한다.
@<고역통과 테스트@>=
func TestHighpassShape(t *testing.T) {
	if g := filterGain(40); g > 0.4 {
		t.Errorf("40Hz 이득 %.2f (기대 <0.4)", g)
	}
	if g := filterGain(300); g < 0.9 {
		t.Errorf("300Hz 이득 %.2f (기대 >0.9)", g)
	}
	hp := newHighpass(highpassCut, highpassStages, testCfg.SampleRate) // DC는 사라져야 한다
	var y float64
	for i := 0; i < 4096; i++ {
		y = hp.step(1.0)
	}
	if math.Abs(y) > 1e-3 {
		t.Errorf("DC 출력 %.4f (기대 ~0)", y)
	}
}

@ 회귀 테스트: 저주파 잡음(럼블 40\,Hz + 전원 험 60\,Hz + DC)이 섞여도, 스트림을
거치면 여섯 줄이 모두 제대로 검출돼야 한다---특히 조용한 고음현 B3, E4.
@<잡음 하 검출 테스트@>=
func TestDetectUnderRumble(t *testing.T) {
	strings := []struct {
		f   float64
		amp float64 // 고음현일수록 조용
	}{
		{82.41, 1.0}, {110.00, 0.9}, {146.83, 0.7},
		{196.00, 0.55}, {246.94, 0.4}, {329.63, 0.3},
	}
	harmonics := []float64{1.0, 0.5, 0.3, 0.2, 0.1}
	rng := rand.New(rand.NewSource(1))
	total := bufferSize + 8*hopSize
	for _, s := range strings {
		stream := NewStream(testCfg)
		var last Reading
		for i := 0; i < total; i++ {
			ta := float64(i) / float64(testCfg.SampleRate)
			var v float64
			for k, a := range harmonics {
				n := float64(k + 1)
				v += a * math.Sin(2*math.Pi*n*s.f*math.Sqrt(1+0.0004*n*n)*ta)
			}
			rumble := 0.25*math.Sin(2*math.Pi*40*ta) + 0.2*math.Sin(2*math.Pi*60*ta) + 0.05
			x := s.amp*v + rumble + 0.02*(rng.Float64()*2-1)
			for _, res := range stream.Push([]float64{x}) {
				last = res.Reading
			}
		}
		if !last.Voiced || math.Abs(last.Freq-s.f) > 4 {
			t.Errorf("%.2fHz: 검출 %+v (기대 %.2f 근처)", s.f, last, s.f)
		}
	}
}

@ 적응형 릴리스: 조용하다 갑자기 시끄럽게 커지면(명료도 낮은 어택) 억제하고,
명료도가 |clarityGate| 이상으로 회복되는 순간 릴리스해야 한다.
@<어택 억제 테스트@>=
func TestOnsetGateReleasesWhenClear(t *testing.T) {
	g := &onsetGate{}
	quiet := Reading{Voiced: true, RMS: 0.005, Clarity: 0.99}  // onsetFloor 아래
	attack := Reading{Voiced: true, RMS: 0.3, Clarity: 0.6}    // 시끄러운 어택
	settled := Reading{Voiced: true, RMS: 0.3, Clarity: 0.99}  // 정착

	g.pass(quiet)
	if g.pass(attack).Voiced {
		t.Errorf("어택 프레임인데 통과됨")
	}
	if g.pass(attack).Voiced {
		t.Errorf("아직 어택인데 통과됨")
	}
	if !g.pass(settled).Voiced {
		t.Errorf("정착됐는데도 억제됨")
	}
}

@ 안전 상한: 명료도가 끝내 회복되지 않아도 |maxAttackFrames| 프레임만 억제하고
그 뒤엔 통과시켜야 한다(지속되는 소리를 영영 버리지 않도록).
@<어택 억제 테스트@>=
func TestOnsetGateMaxCap(t *testing.T) {
	g := &onsetGate{}
	g.pass(Reading{Voiced: true, RMS: 0.005, Clarity: 0.99}) // 조용
	noisy := Reading{Voiced: true, RMS: 0.3, Clarity: 0.6}   // 계속 시끄러움
	suppressed := 0
	var out Reading
	for i := 0; i < maxAttackFrames+2; i++ {
		out = g.pass(noisy)
		if !out.Voiced {
			suppressed++
		}
	}
	if suppressed != maxAttackFrames {
		t.Errorf("억제 프레임 %d (기대 %d)", suppressed, maxAttackFrames)
	}
	if !out.Voiced {
		t.Errorf("안전 상한을 지나도 계속 억제됨")
	}
}

@ 맑은 지속음(명료도 높음)은 에너지가 올라도 어택으로 오인해 버리면 안 된다.
@<어택 억제 테스트@>=
func TestOnsetGatePassesSteadyClear(t *testing.T) {
	g := &onsetGate{}
	steady := Reading{Voiced: true, RMS: 0.3, Clarity: 0.99}
	for i := 0; i < 5; i++ {
		if !g.pass(steady).Voiced {
			t.Errorf("맑은 지속음 %d번째가 억제됨", i)
		}
	}
}

@ 정확 잠금: |lockFrames| 만큼 정확이 이어지면 잠기고, 신호음은 상승 에지에서
{\it 한 번만\/} 울려야 한다.
@<정확 잠금 테스트@>=
func TestLockerLocksAndChimesOnce(t *testing.T) {
	l := &locker{}
	inTune := Reading{Voiced: true, Freq: 110, Cents: 2}
	chimes := 0
	var lastLocked bool
	for i := 0; i < lockFrames+3; i++ {
		var chime bool
		lastLocked, chime = l.update(inTune)
		if chime {
			chimes++
		}
	}
	if chimes != 1 {
		t.Errorf("신호음 %d회 (기대 1회)", chimes)
	}
	if !lastLocked {
		t.Errorf("정확이 이어졌는데 잠기지 않음")
	}
}

@ 히스테리시스: 한 번 잠기면 5~12센트 흔들림에는 잠금이 유지되고, |unlockCents|
밖으로 나가야 풀린다.
@<정확 잠금 테스트@>=
func TestLockerHysteresis(t *testing.T) {
	l := &locker{}
	for i := 0; i < lockFrames; i++ {
		l.update(Reading{Voiced: true, Cents: 1})
	}
	if locked, _ := l.update(Reading{Voiced: true, Cents: 8}); !locked {
		t.Errorf("8센트에서 잠금이 풀림 (히스테리시스 실패)")
	}
	if locked, _ := l.update(Reading{Voiced: true, Cents: 20}); locked {
		t.Errorf("20센트에서도 잠금이 유지됨")
	}
}

@ 쿨다운: 크게 벗어나 풀렸다가 곧바로 다시 잠겨도, 쿨다운 동안에는 신호음이
다시 울리면 안 된다(마이크가 제 벨을 주워 재잠그는 피드백 방지).
@<정확 잠금 테스트@>=
func TestLockerChimeCooldown(t *testing.T) {
	l := &locker{}
	lockOnce := func() (chimes int) {
		for i := 0; i < lockFrames; i++ {
			if _, c := l.update(Reading{Voiced: true, Cents: 1}); c {
				chimes++
			}
		}
		return
	}
	if lockOnce() != 1 {
		t.Errorf("첫 잠금에서 신호음이 1회가 아님")
	}
	l.update(Reading{Voiced: true, Cents: 40}) // 크게 벗어나 해제
	if c := lockOnce(); c != 0 {
		t.Errorf("쿨다운 중 재잠금인데 신호음 %d회", c)
	}
}

@ 중앙값은 정렬 순서의 가운데 값을 주고, 원본 슬라이스를 바꾸지 않아야 한다.
@<중앙값 테스트@>=
func TestMedian(t *testing.T) {
	if got := median([]float64{3, 1, 2}); got != 2 {
		t.Errorf("median{3,1,2}=%v (기대 2)", got)
	}
	xs := []float64{3, 1, 2}
	median(xs)
	if xs[0] != 3 || xs[1] != 1 || xs[2] != 2 {
		t.Errorf("median이 원본을 바꿈: %v", xs)
	}
}

@ 옥타브 교정: 두 배/절반으로 튄 값은 기준으로 접히고, 옥타브 관계가 아닌 다른
음은 그대로 남아야 한다.
@<옥타브 교정 테스트@>=
func TestSnapOctave(t *testing.T) {
	cases := []struct{ f, ref, want float64 }{
		{220, 110, 110},   // 두 배로 튐 → 접힘
		{55, 110, 110},    // 절반으로 튐 → 접힘
		{110, 82.41, 110}, // A2 vs E2: 옥타브 아님 → 그대로
	}
	for _, c := range cases {
		if got := snapOctave(c.f, c.ref); math.Abs(got-c.want) > 1e-9 {
			t.Errorf("snapOctave(%.2f,%.2f)=%.3f (기대 %.2f)", c.f, c.ref, got, c.want)
		}
	}
}

@ 평활기: 110\,Hz가 이어지다 한 프레임만 220\,Hz로 튀어도 결과는 110 근처에
머물러야 하고, 무음이 오면 |Voiced|가 꺼지고 이력이 비어야 한다.
@<평활기 테스트@>=
func TestSmootherStabilizes(t *testing.T) {
	s := newSmoother(testCfg.A4)
	var last Reading
	for _, f := range []float64{110, 110, 111, 220, 109} {
		last = s.push(Reading{Voiced: true, Freq: f})
	}
	if !last.Voiced || math.Abs(last.Freq-110) > 2 {
		t.Errorf("옥타브 튐 뒤 freq=%.2f (기대 110 근처)", last.Freq)
	}
	if r := s.push(Reading{}); r.Voiced || len(s.hist) != 0 {
		t.Errorf("무음 뒤 상태가 안 비워짐: Voiced=%v len=%d", r.Voiced, len(s.hist))
	}
}

@ 스트림 통합: 깨끗한 순음을 충분히 흘려 넣으면 결국 그 음으로 검출되고, 정확한
음이 이어지면 잠금(과 신호음)이 걸려야 한다.
@<스트림 테스트@>=
func TestStreamLocks(t *testing.T) {
	stream := NewStream(testCfg)
	sr := float64(testCfg.SampleRate)
	var last Result
	var everChimed bool
	for i := 0; i < bufferSize+40*hopSize; i++ {
		x := 0.5 * math.Sin(2*math.Pi*110.0*float64(i)/sr) // 정확한 A2
		for _, res := range stream.Push([]float64{x}) {
			last = res
			everChimed = everChimed || res.Chime
		}
	}
	if !last.Voiced || last.Name != "A" || last.Octave != 2 {
		t.Errorf("A2 순음인데 %s%d (voiced=%v)", last.Name, last.Octave, last.Voiced)
	}
	if !last.Locked || !everChimed {
		t.Errorf("정확한 음이 이어졌는데 잠금=%v 신호음=%v", last.Locked, everChimed)
	}
}

@* 찾아보기.
