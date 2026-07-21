@i types.w

\input kotexgweb
\def\title{기타 튜너 콘솔 프런트}

@* 들어가며.
맥의 마이크로 들어오는 소리에서 음정을 뽑아 콘솔에 바늘 눈금으로 보여 주는 기타
튜너의 {\it 프런트엔드\/}다. 음정 검출은 마이크$\cdot$화면에 의존하지 않는 순수
코어 \.{pitch} 패키지(별도 문서)가 맡는다. 이 \.{main} 패키지는 그 코어를 마이크와
콘솔에 잇기만 한다: malgo로 마이크를 열어 표본을 |pitch.Stream|에 흘리고, 나오는
|pitch.Result|를 콘솔 계기판에 그린다. 프런트가 코어에 대해 아는 것은 이 세 가지뿐이다.
$$
\vbox{\halign{\quad#\hfil&\quad#\hfil\cr
  |pitch.NewStream(cfg)|& 검출 파이프라인 하나를 만든다\cr
  |stream.Push(samples)|& 표본을 흘려 |[]pitch.Result|를 받는다\cr
  |pitch.OpenStrings|, |pitch.NearestString|& 개방현 음악 이론\cr}}
$$
기타 줄 맞추는 일에 유난히 집요했던 이로 에릭 클랩튼을 빼놓을 수 없다. 완벽에
가까운 청음 능력을 가졌다고 알려진 그조차, 무대 위에서 곡과 곡 사이마다 습관처럼
다시 튜닝을 했고 결국은 전자 튜너를 눈으로 한 번 더 확인하곤 했다고 전해진다.
반대로 지미 헨드릭스는 아예 기준 자체를 바꿔 버렸다---여섯 줄을 통째로 반음
내린 Eb 튜닝으로 연주해, 줄 장력을 낮추고 특유의 격렬한 벤딩과 비브라토를 얻었다.
정확함의 기준은 사람마다, 곡마다 다르지만---그 기준이 무엇이든 한결같이 지켜
주는 것이 튜너의 몫이다. 이 프로그램이 하는 일도 다르지 않다.

프로그램의 전체적인 뼈대는 다음과 같다.
@c
package main

import (
	"encoding/binary"
	"flag"
	"fmt"
	"math"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/gen2brain/malgo"
	"github.com/sjnam/guitar-tuner/pitch"
)

const channels = 1 // 모노

@<콘솔에 그리기@>@;

func main() {
	@<명령줄 플래그로 설정을 만든다@>
	@<오디오 컨텍스트를 초기화하라@>
	@<장치를 설정하고 콜백을 걸어라@>
	@<입력 장치를 초기화하고 캡처를 시작하라@>

	fmt.Printf("기타 튜너 (A4=%.1fHz, %dHz) — 멈추려면 Ctrl-C\n", cfg.A4, cfg.SampleRate)
	@<창이 찰 때마다 검출해 표시하라@>
}

@ 몇몇 값은 명령줄 플래그로 바꿀 수 있게 |pitch.Config|에 실어 넘긴다. |main|
안에서 한 번만 쓰므로 따로 함수로 두지 않는다.
@<명령줄 플래그로 설정을 만든다@>=
cfg := pitch.DefaultConfig()
flag.Float64Var(&cfg.A4, "a4", cfg.A4, "기준음 A4 주파수(Hz)")
flag.IntVar(&cfg.SampleRate, "rate", cfg.SampleRate, "표본화율(Hz)")
flag.Float64Var(&cfg.MinRMS, "sensitivity", cfg.MinRMS, "무음 문턱(RMS) — 작을수록 민감")
flag.Parse()

@* 콘솔에 그리기.
표시 계층은 매 결과마다 다섯 줄짜리 계기판을 {\it 제자리에서\/} 다시 그린다.
그린 줄 수만큼 커서를 위로 올리고(\.{\\033[5A}) 각 줄을 지우며(\.{\\033[K}) 덮어써,
화면이 스크롤 없이 조용히 갱신되게 한다. 색은 세 단계다: $\pm5$ 센트 안이면 {\it
초록\/}(정확), $\pm25$ 센트 안이면 {\it 노랑\/}, 그 밖은 {\it 빨강\/}.
@<콘솔에 그리기@>=
const (
	colReset  = "\033[0m"
	colBold   = "\033[1m"
	colDim    = "\033[2m"
	colGreen  = "\033[32m"
	colYellow = "\033[33m"
	colRed    = "\033[31m"
	colLock   = "\033[1;30;42m" // 잠금 강조: 초록 바탕에 굵은 검정 글씨
)

@ 계기판은 늘 다섯 줄이다: 개방현 행, 빈 줄, 음이름·주파수, 바늘 눈금, 상태
안내. 무음일 때도 같은 다섯 줄을 유지해 높이가 흔들리지 않게 한다. |locked|이면
음이름을 초록 바탕 칩으로 감싸고 상태 줄을 축하 문구로 바꿔 뚜렷이 강조한다.
세 갈래(무음$\cdot$일반$\cdot$잠금)를 따로 떼어 하나씩 설명한다.
@<콘솔에 그리기@>=
func panel(r pitch.Reading, locked bool) []string {
	active := -1
	if r.Voiced {
		active = pitch.NearestString(r.Freq)
	}
	row := stringsRow(active, r.Cents)
	@<무음이면 안내 문구를 돌려준다@>
	@<정확도에 따라 기본 문구를 만든다@>
	@<잠금이면 축하 문구로 덮어쓴다@>
	return []string{row, "", note, gauge(r.Cents, color, true), stat}
}

@ 무음이면 나머지 값(음이름·센트 등)이 뜻이 없으므로, 여기서 다섯 줄을 채워
바로 돌려준다.
@<무음이면 안내 문구를 돌려준다@>=
if !r.Voiced {
	return []string{
		row,
		"",
		"      " + colDim + "듣는 중…" + colReset,
		gauge(0, colDim, false),
		"      " + colDim + "기타 줄을 튕겨 보세요" + colReset,
	}
}

@ 색$\cdot$문구는 |statusFor|가 정하고, 음이름 줄에는 측정 주파수와 함께
가장 가까운 음의 {\it 목표 주파수\/}를 나란히 보여 준다.
@<정확도에 따라 기본 문구를 만든다@>=
color, status := statusFor(r.Cents)
target := r.Freq * math.Exp2(-r.Cents/1200) // 가장 가까운 음의 이상적 주파수
note := fmt.Sprintf("      %s%s%d%s   %6.1f Hz   %s목표 %.2f Hz%s",
	colBold, r.Name, r.Octave, colReset, r.Freq, colDim, target, colReset)
stat := fmt.Sprintf("      %s%s%s   %s%+.1f¢%s",
	color, status, colReset, color, r.Cents, colReset)

@ 클랩튼이 곡 사이마다 확인했던 바로 그 순간---줄이 완벽히 맞았다는 확신 ---
을 여기서는 배지 하나로 대신한다. 잠금 상태면 방금 만든 문구를 축하 배지로
덮어써 뚜렷이 강조한다.
@<잠금이면 축하 문구로 덮어쓴다@>=
if locked {
	color = colGreen
	note = fmt.Sprintf("      %s ★ %s%d 정확! ★ %s   %6.1f Hz",
		colLock, r.Name, r.Octave, colReset, r.Freq)
	stat = fmt.Sprintf("      %s%s튜닝 완료 — 잘 맞았습니다! ✓%s   %s%+.1f¢%s",
		colBold, colGreen, colReset, colGreen, r.Cents, colReset)
}

@ 개방현 행은 여섯 이름을 늘어놓고, 지금 겨냥 중인 현만 대괄호로 감싸 강조한다.
강조색은 정확하면 초록, 아니면 노랑이다. 대괄호 \.{[E]}와 여백 \.{\{\GSP E\GSP \}}는
너비가 같아 줄이 흔들리지 않는다. 여기 늘어놓은 |pitch.OpenStrings|는 표준
튜닝(E2 A2 D3 G3 B3 E4)이다---헨드릭스처럼 여섯 줄을 통째로 내려 잡았다면,
이름표는 그대로 두고 마음속으로 반음씩 낮춰 읽으면 된다.
@<콘솔에 그리기@>=
func stringsRow(active int, cents float64) string {
	hi := colYellow
	if math.Abs(cents) < 5 {
		hi = colGreen
	}
	parts := make([]string, len(pitch.OpenStrings))
	for i, s := range pitch.OpenStrings {
		if i == active {
			parts[i] = hi + colBold + "[" + s.Name + "]" + colReset
		} else {
			parts[i] = colDim + " " + s.Name + " " + colReset
		}
	}
	return "   개방현  " + strings.Join(parts, " ")
}

@ 바늘 눈금은 $[-50,+50]$ 센트를 폭 |gaugeWidth| 칸에 대응시킨다. 가운데는
기준선 \\{┼}, 바늘 \\{●}은 센트에 비례한 자리에 색을 입혀 찍는다. |live|가 거짓이면
(무음) 바늘 없이 눈금만 흐리게 보여 준다.
@<콘솔에 그리기@>=
const gaugeWidth = 41

func gauge(cents float64, color string, live bool) string {
	cells := make([]rune, gaugeWidth)
	for i := range cells {
		cells[i] = '─'
	}
	cells[gaugeWidth/2] = '┼'
	if !live {
		return "   ♭ " + colDim + string(cells) + colReset + " ♯"
	}
	pos := int(math.Round((cents + 50) / 100 * float64(gaugeWidth-1)))
	pos = max(0, min(gaugeWidth-1, pos))
	left, right := string(cells[:pos]), string(cells[pos+1:])
	return "   ♭ " + left + color + colBold + "●" + colReset + right + " ♯"
}

@ 상태 안내는 센트 크기로 색과 문구를 정한다. 낮으면($cents<0$) 줄을 {\it 조여\/}
음을 높이고, 높으면 줄을 {\it 풀어\/} 음을 낮춘다.
@<콘솔에 그리기@>=
func statusFor(cents float64) (color, text string) {
	switch ac := math.Abs(cents); {
	case ac < 5:
		return colGreen, "정확함 ✓"
	case ac < 25:
		if cents < 0 {
			return colYellow, "조금 낮음 ▲ 줄을 조여 주세요"
		}
		return colYellow, "조금 높음 ▼ 줄을 풀어 주세요"
	default:
		if cents < 0 {
			return colRed, "너무 낮음 ▲ 줄을 조여 주세요"
		}
		return colRed, "너무 높음 ▼ 줄을 풀어 주세요"
	}
}

@* 오디오 캡처와 주 순환.
malgo로 기본 입력 장치를 열어 모노 |float32| 표본을 받고, 콜백에서 처리 고루틴으로
흘려보낸 뒤, |pitch.Stream|에 밀어 넣어 나오는 결과로 화면을 갱신한다.

@ @<오디오 컨텍스트를 초기화하라@>=
ctx, err := malgo.InitContext(nil, malgo.ContextConfig{}, nil)
if err != nil {
	fmt.Fprintln(os.Stderr, "오디오 컨텍스트 초기화 실패:", err)
	os.Exit(1)
}
defer func() { _ = ctx.Uninit(); ctx.Free() }()

@ @<입력 장치를 초기화하고 캡처를 시작하라@>=
device, err := malgo.InitDevice(ctx.Context, deviceConfig, malgo.DeviceCallbacks{Data: onFrames})
if err != nil {
	fmt.Fprintln(os.Stderr, "입력 장치 초기화 실패:", err)
	os.Exit(1)
}
defer device.Uninit()

if err := device.Start(); err != nil {
	fmt.Fprintln(os.Stderr, "캡처 시작 실패:", err)
	os.Exit(1)
}

@ 오디오 콜백은 실시간 스레드에서 불리므로 절대 막히면 안 된다. 그래서 들어온
바이트를 |float32|로 바꿔 버퍼 채널에 {\it 논블로킹\/}으로 넣고, 채널이 차면 그
조각은 조용히 버린다(튜너에는 최신 소리만 있으면 된다).
@<장치를 설정하고 콜백을 걸어라@>=
deviceConfig := malgo.DefaultDeviceConfig(malgo.Capture)
deviceConfig.Capture.Format = malgo.FormatF32
deviceConfig.Capture.Channels = channels
deviceConfig.SampleRate = uint32(cfg.SampleRate)

samples := make(chan []float32, 16)
onFrames := func(_, in []byte, frameCount uint32) {
	n := int(frameCount)
	frame := make([]float32, n)
	for i := 0; i < n; i++ {
		bits := binary.LittleEndian.Uint32(in[i*4:])
		frame[i] = math.Float32frombits(bits)
	}
	select {
	case samples <- frame:
	default: // 채널이 차면 이 조각은 버린다
	}
}

@ 주 순환은 먼저 상태를 준비한 뒤, \.{Ctrl-C} 신호나 새 표본 조각을 기다리는
무한 반복에 들어간다.
@<창이 찰 때마다 검출해 표시하라@>=
@<상태를 준비한다@>

for {
	select {
	case <-sig:
		@<\.{Ctrl-C} 신호를 받으면 끝낸다@>
	case frame := <-samples:
		@<표본 조각을 처리해 화면을 갱신한다@>
	}
}

@ 검출 파이프라인(|pitch.Stream|), 화면에 몇 줄을 그렸는지 기억할 |drawn|,
표본을 모을 버퍼, 그리고 \.{Ctrl-C}/\.{SIGTERM}을 받을 신호 채널을 준비한다.
@<상태를 준비한다@>=
stream := pitch.NewStream(cfg)
drawn := false
buf := make([]float64, 0, 4096)

sig := make(chan os.Signal, 1)
signal.Notify(sig, os.Interrupt, syscall.SIGTERM)

@ 줄을 바꿔 프롬프트를 깨끗이 남기고 순환을 끝낸다.
@<\.{Ctrl-C} 신호를 받으면 끝낸다@>=
fmt.Println()
return

@ 조각을 |float64|로 바꿔 |Stream|에 밀어 넣고, 나오는 결과들 중 {\it 가장
최근\/} 것으로 화면을 한 번만 갱신해 깜빡임을 줄인다. 잠금이 새로 걸린
프레임(|Chime|)에는 터미널 벨을 한 번 울린다.
@<표본 조각을 처리해 화면을 갱신한다@>=
buf = buf[:0]
for _, s := range frame {
	buf = append(buf, float64(s))
}
var latest pitch.Result
var got, chime bool
for _, res := range stream.Push(buf) {
	latest, got = res, true
	chime = chime || res.Chime
}
if got {
	if chime {
		fmt.Print("\a") // 터미널 벨
	}
	@<계기판을 다시 그린다@>
}

@ 직전에 몇 줄을 그렸으면(|drawn|) 그만큼 커서를 올린 뒤 계기판을 통째로
다시 찍는다. 그래야 화면이 스크롤 없이 조용히 갱신된다.
@<계기판을 다시 그린다@>=
lines := panel(latest.Reading, latest.Locked)
var b strings.Builder
if drawn {
	fmt.Fprintf(&b, "\033[%dA", len(lines))
}
drawn = true
for _, ln := range lines {
	b.WriteString("\r\033[K")
	b.WriteString(ln)
	b.WriteByte('\n')
}
fmt.Print(b.String())

@** 검사.
프런트엔드의 순수한 조각들---계기판을 짜는 |panel|$\cdot$|gauge|$\cdot$|statusFor|
$\cdot$|stringsRow|---을 확인한다. 부수 파일 \.{@(tuner\_test.go@>} 로 뽑아 같은
\.{main} 패키지에서 돌린다. ANSI 색코드는 |stripANSI|로 벗겨 내용만 견준다.
@(tuner_test.go@>=
package main

import (
	"regexp"
	"strings"
	"testing"

	"github.com/sjnam/guitar-tuner/pitch"
)

var ansiRE = regexp.MustCompile("\033\\[[0-9;]*m")

func stripANSI(s string) string { return ansiRE.ReplaceAllString(s, "") }

@<바늘 눈금 테스트@>@;
@<상태 안내 테스트@>@;
@<개방현 행 테스트@>@;
@<계기판 테스트@>@;

@ 바늘 눈금: 센트가 낮을수록 바늘이 왼쪽에, 높을수록 오른쪽에 찍혀야 한다.
@<바늘 눈금 테스트@>=
func needlePos(cents float64) int {
	for i, c := range []rune(stripANSI(gauge(cents, colGreen, true))) {
		if c == '●' {
			return i
		}
	}
	return -1
}

func TestGaugeNeedleMoves(t *testing.T) {
	flat, center, sharp := needlePos(-40), needlePos(0), needlePos(40)
	if !(flat < center && center < sharp) {
		t.Errorf("바늘 위치가 단조롭지 않음: 낮음=%d 가운데=%d 높음=%d", flat, center, sharp)
	}
	// 무음(live=false)은 바늘이 없어야 한다.
	if strings.ContainsRune(gauge(0, colDim, false), '●') {
		t.Errorf("무음 눈금에 바늘이 있음")
	}
}

@ 상태 안내: 센트 크기와 부호에 따라 색과 조임/풂 방향이 맞아야 한다.
@<상태 안내 테스트@>=
func TestStatusFor(t *testing.T) {
	if c, txt := statusFor(0); c != colGreen || !strings.Contains(txt, "정확") {
		t.Errorf("0¢: %q (기대 초록·정확)", txt)
	}
	if c, txt := statusFor(-10); c != colYellow || !strings.Contains(txt, "조여") {
		t.Errorf("-10¢: %q (기대 노랑·조여)", txt)
	}
	if c, txt := statusFor(30); c != colRed || !strings.Contains(txt, "풀어") {
		t.Errorf("+30¢: %q (기대 빨강·풀어)", txt)
	}
}

@ 개방현 행: 겨냥 중인 현만 대괄호로 강조된다.
@<개방현 행 테스트@>=
func TestStringsRowHighlight(t *testing.T) {
	row := stripANSI(stringsRow(pitch.NearestString(110), 2)) // A2 겨냥
	if !strings.Contains(row, "[A]") {
		t.Errorf("A가 강조되지 않음: %q", row)
	}
	if strings.Contains(row, "[E]") {
		t.Errorf("겨냥하지 않은 E가 강조됨: %q", row)
	}
}

@ 계기판: 어느 상태에서나 다섯 줄이고, 무음이면 안내를, 잠금이면 축하 강조를
보여 준다.
@<계기판 테스트@>=
func TestPanelStates(t *testing.T) {
	if ls := panel(pitch.Reading{}, false); len(ls) != 5 ||
		!strings.Contains(stripANSI(strings.Join(ls, "\n")), "듣는 중") {
		t.Errorf("무음 계기판이 어긋남: %q", ls)
	}
	r := pitch.Reading{Voiced: true, Freq: 110, Name: "A", Octave: 2, Cents: 1}
	locked := stripANSI(strings.Join(panel(r, true), "\n"))
	if !strings.Contains(locked, "정확!") || !strings.Contains(locked, "튜닝 완료") {
		t.Errorf("잠금 강조가 없음: %q", locked)
	}
	plain := stripANSI(strings.Join(panel(r, false), "\n"))
	if !strings.Contains(plain, "목표") {
		t.Errorf("일반 계기판에 목표 주파수가 없음: %q", plain)
	}
}

@* 찾아보기.
