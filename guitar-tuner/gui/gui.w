@i ../types.w

\input kotexgweb
\def\title{기타 튜너: Gio GUI 프런트}

@* 들어가며.
콘솔(\.{tuner.w}) 곁에 두는 두 번째 프런트엔드다. 웹이 아니라 맥에서 곧바로
실행되는 창을 띄우되, 순수 Go로 짜인 \.{Gio}(gioui.org)를 쓴다. cgo 브리지나
별도 언어 없이 지금의 \.{pitch} 코어를 그대로 가져다 쓸 수 있고, {\it
즉시모드\/}(immediate-mode) 렌더링이라 바늘이 매끄럽게 움직이는 계기판을 그리기에
알맞다.

구조는 세 조각이다: 마이크 콜백이 표본을 |pitch.Stream|에 흘리는 백그라운드
고루틴, 그 결과를 잠금으로 지키는 |uiState|, 그리고 새 결과가 올 때마다
|window.Invalidate()|로 깨어나 창을 다시 그리는 이벤트 순환. 콘솔의 다섯 줄
계기판(개방현 행$\cdot$음이름$\cdot$바늘 눈금$\cdot$상태 안내)을 그대로 옮겨,
두 프런트가 같은 사용자 경험을 준다.

한 가지 주의할 점: Gio에 기본 내장된 Go 글꼴(\.{gofont})은 라틴 문자만 담고
있어 한글이 깨진다. 그래서 맥에 이미 있는 한글 글꼴(\.{AppleSDGothicNeo.ttc})을
읽어 쓰고, 못 찾으면 라틴 글꼴로 조용히 물러난다(그러면 한글이 네모로 보이지만
프로그램은 계속 돈다).
@c
package main

import (
	"encoding/binary"
	"flag"
	"fmt"
	"image"
	"image/color"
	"math"
	"os"
	"sync"

	@<gioui.org 패키지@>

	"github.com/gen2brain/malgo"
	"github.com/sjnam/guitar-tuner/pitch"
)

@<프로그램 상수@>@;
@<화면 상태@>@;
@<계기판 도우미@>@;
@<글꼴과 테마 준비@>@;
@<오디오 캡처@>@;
@<메인 루프@>@;

@ @<gioui.org 패키지@>= 
"gioui.org/app"
"gioui.org/font"
"gioui.org/font/gofont"
"gioui.org/font/opentype"
"gioui.org/layout"
"gioui.org/op"
"gioui.org/op/clip"
"gioui.org/op/paint"
"gioui.org/text"
"gioui.org/unit"
"gioui.org/widget/material"

@ 창 크기와 오디오 채널 수는 프로그램 전체에서 쓰는 상수라 한곳에 모은다.
@<프로그램 상수@>=
const (
	winWidth  = 460 // 창 너비(dp)
	winHeight = 260 // 창 높이(dp)
	channels  = 1   // 모노
)

@* 화면 상태.
오디오 콜백 고루틴과 화면을 그리는 이벤트 순환은 서로 다른 고루틴에서 돈다.
|uiState|는 그 사이에서 최신 |pitch.Result| 하나만 뮤텍스로 지켜 건넨다 ---
콘솔이 |latest| 변수 하나로 깜빡임을 줄였던 것과 같은 생각이다.
@<화면 상태@>=
type uiState struct {
	mu     sync.Mutex
	latest pitch.Result
}

@* 계기판 도우미.
그리기 코드에서 뽑아낸 순수 함수들이다. 창(|layout.Context|)이 없어도 결과를
확인할 수 있어, 콘솔의 |gauge|$\cdot$|statusFor|처럼 이 함수들만 따로 검사한다.

@ |needleX|는 $[-50,+50]$ 센트를 폭 |width| 픽셀에 선형으로 대응시키고, 범위
밖 값은 양 끝에 붙인다.
@<계기판 도우미@>=
func needleX(cents float64, width float32) float32 {
	x := width * float32(cents+50) / 100
	if x < 0 {
		x = 0
	}
	if x > width {
		x = width
	}
	return x
}

@ 색은 콘솔과 같은 문턱을 쓴다: $\pm5$ 센트 안이면 정확(초록), $\pm25$ 센트
안이면 조금 벗어남(노랑), 그 밖은 많이 벗어남(빨강).
@<계기판 도우미@>=
func statusColor(cents float64) color.NRGBA {
	switch ac := math.Abs(cents); {
	case ac < 5:
		return colorGreen
	case ac < 25:
		return colorYellow
	default:
		return colorRed
	}
}

@ 안내 문구도 같은 문턱을 쓰되, 낮으면($cents<0$) 줄을 {\it 조여\/} 음을
높이고 높으면 줄을 {\it 풀어\/} 음을 낮추라고 알려 준다.
@<계기판 도우미@>=
func statusText(cents float64) string {
	switch ac := math.Abs(cents); {
	case ac < 5:
		return "정확함 ✓"
	case ac < 25:
		if cents < 0 {
			return "조금 낮음 ▲ 줄을 조여 주세요"
		}
		return "조금 높음 ▼ 줄을 풀어 주세요"
	default:
		if cents < 0 {
			return "너무 낮음 ▲ 줄을 조여 주세요"
		}
		return "너무 높음 ▼ 줄을 풀어 주세요"
	}
}

@ 팔레트는 여기 모아 둔다.
@<계기판 도우미@>=
var (
	colorBg     = color.NRGBA{R: 0xfa, G: 0xfa, B: 0xfa, A: 0xff}
	colorDim    = color.NRGBA{R: 0x90, G: 0x90, B: 0x90, A: 0xff}
	colorTick   = color.NRGBA{R: 0xbb, G: 0xbb, B: 0xbb, A: 0xff}
	colorGreen  = color.NRGBA{R: 0x2e, G: 0xa0, B: 0x4a, A: 0xff}
	colorYellow = color.NRGBA{R: 0xc9, G: 0x8a, B: 0x00, A: 0xff}
	colorRed    = color.NRGBA{R: 0xd0, G: 0x33, B: 0x2f, A: 0xff}
	colorLockBg = color.NRGBA{R: 0xe3, G: 0xf6, B: 0xe6, A: 0xff}
	colorLockFg = color.NRGBA{R: 0x1b, G: 0x5e, B: 0x2f, A: 0xff}
)

@* 글꼴과 테마 준비.
맥의 시스템 한글 글꼴을 읽어 Gio의 글꼴 모음으로 삼는다. 파일을 못 읽거나
파싱에 실패하면(다른 macOS 버전이라 경로가 다르거나 하는 경우) 표준 에러에
경고만 남기고 Gio 기본 글꼴(라틴 전용)로 물러난다---한글은 깨져도 프로그램은
계속 동작해야 하므로.
@<글꼴과 테마 준비@>=
const koreanFontPath = "/System/Library/Fonts/AppleSDGothicNeo.ttc"

func loadFaces() []text.FontFace {
	data, err := os.ReadFile(koreanFontPath)
	if err == nil {
		if faces, err := opentype.ParseCollection(data); err == nil && len(faces) > 0 {
			return faces
		}
	}
	fmt.Fprintln(os.Stderr, "경고: 한글 글꼴을 찾지 못해 한글이 깨질 수 있습니다:", koreanFontPath)
	return gofont.Collection()
}

@ 그 글꼴 모음으로 |material.Theme|을 만든다. |th.Face|를 모음의 첫 글꼴로
지정해, 라벨들이 기본으로 그 글꼴을 골라 쓰게 한다. |run| 안에서 한 번만
쓰므로 따로 함수로 두지 않는다.
@<글꼴로 테마를 만든다@>=
faces := loadFaces()
th := material.NewTheme()
th.Shaper = text.NewShaper(text.WithCollection(faces))
th.Face = faces[0].Font.Typeface

@* 계기판 그리기.
콘솔과 같은 다섯 부분---개방현 행, 음이름$\cdot$주파수, 바늘 눈금, 상태 안내
--- 을 세로로 쌓는다. 잠금 상태면 배경을 연한 초록으로 칠하고 음이름 줄을 축하
문구로 바꿔 뚜렷이 강조한다(콘솔의 |colLock| 강조와 같은 생각). |run| 안에서
한 번만 그리므로 함수로 두지 않고 절로 엮는다---|pitch.Result|는 |Reading|을
얹고 있어(embedding) |r.Voiced|$\cdot$|r.Freq|처럼 그대로 꺼내 쓸 수 있다.
@<계기판을 그린다@>=
locked := r.Locked
bg := colorBg
if locked {
	bg = colorLockBg
}
paint.FillShape(gtx.Ops, bg, clip.Rect{Max: gtx.Constraints.Max}.Op())

layout.UniformInset(unit.Dp(18)).Layout(gtx, func(gtx layout.Context) layout.Dimensions {
	return layout.Flex{Axis: layout.Vertical}.Layout(gtx,
		layout.Rigid(func(gtx layout.Context) layout.Dimensions {
			@<개방현 행을 그린다@>
		}),
		layout.Rigid(layout.Spacer{Height: unit.Dp(16)}.Layout),
		layout.Rigid(func(gtx layout.Context) layout.Dimensions {
			@<음이름 줄을 그린다@>
		}),
		layout.Rigid(layout.Spacer{Height: unit.Dp(12)}.Layout),
		layout.Rigid(func(gtx layout.Context) layout.Dimensions {
			@<바늘 눈금을 그린다@>
		}),
		layout.Rigid(layout.Spacer{Height: unit.Dp(12)}.Layout),
		layout.Rigid(func(gtx layout.Context) layout.Dimensions {
			@<상태 안내 줄을 그린다@>
		}),
	)
})

@ 개방현 행은 여섯 이름을 늘어놓고, 지금 겨냥 중인 현만 굵게 색칠해 강조한다.
콘솔의 |stringsRow|와 같은 규칙: 정확하면 초록, 아니면 노랑.
@<개방현 행을 그린다@>=
active := -1
if r.Voiced {
	active = pitch.NearestString(r.Freq)
}
hi := colorYellow
if math.Abs(r.Cents) < 5 {
	hi = colorGreen
}
children := make([]layout.FlexChild, len(pitch.OpenStrings))
for i, s := range pitch.OpenStrings {
	i, s := i, s
	children[i] = layout.Rigid(func(gtx layout.Context) layout.Dimensions {
		return layout.UniformInset(unit.Dp(6)).Layout(gtx, func(gtx layout.Context) layout.Dimensions {
			lbl := material.Body1(th, s.Name)
			if i == active {
				lbl.Font.Weight = font.Bold
				lbl.Color = hi
			} else {
				lbl.Color = colorDim
			}
			return lbl.Layout(gtx)
		})
	})
}
return layout.Flex{Axis: layout.Horizontal, Alignment: layout.Middle}.Layout(gtx, children...)

@ 음이름$\cdot$주파수 줄. 무음이면 안내 문구, 잠금이면 축하 배지, 그 밖엔
음이름$\cdot$측정 주파수$\cdot$목표 주파수를 보여 준다.
@<음이름 줄을 그린다@>=
if !r.Voiced {
	lbl := material.H5(th, "듣는 중…")
	lbl.Color = colorDim
	return lbl.Layout(gtx)
}
var txt string
if locked {
	txt = fmt.Sprintf("★ %s%d 정확! ★   %.1f Hz", r.Name, r.Octave, r.Freq)
} else {
	target := r.Freq * math.Exp2(-r.Cents/1200) // 가장 가까운 음의 이상적 주파수
	txt = fmt.Sprintf("%s%d   %.1f Hz   목표 %.2f Hz", r.Name, r.Octave, r.Freq, target)
}
lbl := material.H5(th, txt)
if locked {
	lbl.Color = colorLockFg
}
return lbl.Layout(gtx)

@ 바늘 눈금: 가운데 기준선 위에 트랙을 깔고, 유효한 소리면 |needleX|로 구한
자리에 색이 입혀진 바늘(원)을 찍는다. 무음이면 트랙만 흐리게 보여 준다.
@<바늘 눈금을 그린다@>=
cents, voiced := r.Cents, r.Voiced
width := gtx.Constraints.Max.X
height := gtx.Dp(unit.Dp(28))
trackH := gtx.Dp(unit.Dp(6))
midY := height / 2

track := image.Rect(0, midY-trackH/2, width, midY+trackH/2)
paint.FillShape(gtx.Ops, colorTick, clip.UniformRRect(track, trackH/2).Op(gtx.Ops))

tickW := gtx.Dp(unit.Dp(2))
tick := image.Rect(width/2-tickW/2, 0, width/2+tickW/2, height)
paint.FillShape(gtx.Ops, colorDim, clip.Rect(tick).Op())

if voiced {
	radius := gtx.Dp(unit.Dp(9))
	x := int(needleX(cents, float32(width)))
	dot := image.Rect(x-radius, midY-radius, x+radius, midY+radius)
	paint.FillShape(gtx.Ops, statusColor(cents), clip.Ellipse(dot).Op(gtx.Ops))
}

return layout.Dimensions{Size: image.Point{X: width, Y: height}}

@ 상태 안내 줄. 무음 안내, 잠금 축하, 또는 조임/풂 방향과 센트를 보여 준다.
@<상태 안내 줄을 그린다@>=
if !r.Voiced {
	lbl := material.Body1(th, "기타 줄을 튕겨 보세요")
	lbl.Color = colorDim
	return lbl.Layout(gtx)
}
txt, col := statusText(r.Cents), statusColor(r.Cents)
if locked {
	txt, col = "튜닝 완료 — 잘 맞았습니다! ✓", colorGreen
}
lbl := material.Body1(th, fmt.Sprintf("%s   %+.1f¢", txt, r.Cents))
lbl.Color = col
return lbl.Layout(gtx)

@* 오디오 캡처.
malgo로 기본 입력 장치를 열어 모노 |float32| 표본을 받고, 콜백에서 처리
고루틴으로 흘려보낸다. |startCapture| 는 그 준비 과정을 여섯 단계로 나눠
차례로 밟는다---몸통을 짧게 두고, 각 단계는 따로 설명한다.
@<오디오 캡처@>=
func startCapture(cfg pitch.Config, state *uiState, w *app.Window) (stop func(), err error) {
	@<오디오 컨텍스트를 연다@>
	@<장치를 설정한다@>
	@<오디오 콜백을 정의한다@>
	@<장치를 초기화하고 캡처를 시작한다@>
	@<표본을 받아 처리하는 고루틴을 띄운다@>
	@<정리 함수를 만들어 돌려준다@>
}

@ malgo 의 모든 것은 이 컨텍스트에서 시작한다. 실패하면 더 할 일이 없으니
바로 감싸서 돌려준다.
@<오디오 컨텍스트를 연다@>=
ctx, err := malgo.InitContext(nil, malgo.ContextConfig{}, nil)
if err != nil {
	return nil, fmt.Errorf("오디오 컨텍스트 초기화 실패: %w", err)
}

@ 캡처 형식은 |pitch| 코어가 기대하는 그대로---모노 |float32|, 설정된
표본화율---로 맞춘다. 검출 파이프라인(|pitch.Stream|)과 콜백이 표본을
건넬 채널도 여기서 함께 준비한다.
@<장치를 설정한다@>=
deviceConfig := malgo.DefaultDeviceConfig(malgo.Capture)
deviceConfig.Capture.Format = malgo.FormatF32
deviceConfig.Capture.Channels = channels
deviceConfig.SampleRate = uint32(cfg.SampleRate)

stream := pitch.NewStream(cfg)
samples := make(chan []float32, 16)

@ 콜백은 실시간 스레드에서 불리므로 절대 막히면 안 된다. 그래서 바이트를
|float32|로 바꿔 버퍼 채널에 {\it 논블로킹\/}으로 넣고, 채널이 차면 그 조각은
조용히 버린다---콘솔과 같은 규칙이다.
@<오디오 콜백을 정의한다@>=
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

@ 장치를 만들고 켠다. 둘 중 어느 쪽이 실패하든 그때까지 연 자원(컨텍스트,
장치)을 순서대로 되돌려야 새는 게 없다.
@<장치를 초기화하고 캡처를 시작한다@>=
device, err := malgo.InitDevice(ctx.Context, deviceConfig, malgo.DeviceCallbacks{Data: onFrames})
if err != nil {
	ctx.Free()
	return nil, fmt.Errorf("입력 장치 초기화 실패: %w", err)
}
if err := device.Start(); err != nil {
	device.Uninit()
	ctx.Free()
	return nil, fmt.Errorf("캡처 시작 실패: %w", err)
}

@ 백그라운드 고루틴이 채널에서 표본 조각을 받아 |pitch.Stream|에 밀어 넣고,
나오는 결과로 |uiState|를 갱신한 뒤 |window.Invalidate()|로 새 프레임을
요청한다.
@<표본을 받아 처리하는 고루틴을 띄운다@>=
go func() {
	buf := make([]float64, 0, 4096)
	for frame := range samples {
		buf = buf[:0]
		for _, s := range frame {
			buf = append(buf, float64(s))
		}
		for _, res := range stream.Push(buf) {
			state.mu.Lock()
			state.latest = res
			state.mu.Unlock()
		}
		w.Invalidate()
	}
}()

@ 창이 닫힐 때 부를 정리 함수다. 장치와 컨텍스트를 연 순서의 역순으로 놓는다.
@<정리 함수를 만들어 돌려준다@>=
stop = func() {
	device.Uninit()
	_ = ctx.Uninit()
	ctx.Free()
}
return stop, nil

@* 메인 루프.
Gio는 macOS에서 메인 스레드를 넘겨받아야 해서, 실제 창 이벤트 순환은
고루틴에서 돌리고 |app.Main()|을 마지막에 불러 제어를 넘긴다.
@<메인 루프@>=
func main() {
	@<명령줄 플래그로 설정을 만든다@>
	go func() {
		w := new(app.Window)
		w.Option(
			app.Title(fmt.Sprintf("기타 튜너 (A4=%.1fHz)", cfg.A4)),
			app.Size(unit.Dp(winWidth), unit.Dp(winHeight)),
		)
		if err := run(w, cfg); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		os.Exit(0)
	}()
	app.Main()
}

@ 몇몇 값은 콘솔과 똑같이 명령줄 플래그로 바꿀 수 있게 |pitch.Config|에 실어
넘긴다. |main| 안에서 한 번만 쓰므로 따로 함수로 두지 않는다.
@<명령줄 플래그로 설정을 만든다@>=
cfg := pitch.DefaultConfig()
flag.Float64Var(&cfg.A4, "a4", cfg.A4, "기준음 A4 주파수(Hz)")
flag.IntVar(&cfg.SampleRate, "rate", cfg.SampleRate, "표본화율(Hz)")
flag.Float64Var(&cfg.MinRMS, "sensitivity", cfg.MinRMS, "무음 문턱(RMS) — 작을수록 민감")
flag.Parse()

@ |run|은 한 창의 일생을 맡는다: 테마와 오디오 캡처를 준비하고, |FrameEvent|가
올 때마다 최신 결과로 계기판을 다시 그린다. |DestroyEvent|가 오면 창이
닫힌 것이니 순환을 끝낸다.
@<메인 루프@>=
func run(w *app.Window, cfg pitch.Config) error {
	@<글꼴로 테마를 만든다@>
	state := &uiState{}
	stop, err := startCapture(cfg, state, w)
	if err != nil {
		return err
	}
	defer stop()

	var ops op.Ops
	for {
		switch e := w.Event().(type) {
		case app.DestroyEvent:
			return e.Err
		case app.FrameEvent:
			gtx := app.NewContext(&ops, e)
			state.mu.Lock()
			r := state.latest
			state.mu.Unlock()
			@<계기판을 그린다@>
			e.Frame(gtx.Ops)
		}
	}
}

@** 검사.
창이 없어도 검사할 수 있는 순수 도우미들---|needleX|$\cdot$|statusColor|
$\cdot$|statusText|---을 확인한다. 부수 파일 \.{@(gui\_test.go@>} 로 뽑아
같은 \.{main} 패키지에서 돌린다.
@(gui_test.go@>=
package main

import (
	"strings"
	"testing"
)

@<바늘 위치 테스트@>@;
@<상태 색상 테스트@>@;
@<상태 문구 테스트@>@;

@ 바늘은 센트가 커질수록 오른쪽으로 단조 이동하고, 범위 밖 극단값은 양 끝에
붙어야 한다.
@<바늘 위치 테스트@>=
func TestNeedleXMonotonicAndClamped(t *testing.T) {
	const width = 400
	flat, center, sharp := needleX(-40, width), needleX(0, width), needleX(40, width)
	if !(flat < center && center < sharp) {
		t.Errorf("바늘 위치가 단조롭지 않음: 낮음=%.1f 가운데=%.1f 높음=%.1f", flat, center, sharp)
	}
	if x := needleX(-1000, width); x != 0 {
		t.Errorf("극단 낮음 클램프 실패: %.1f (기대 0)", x)
	}
	if x := needleX(1000, width); x != width {
		t.Errorf("극단 높음 클램프 실패: %.1f (기대 %.1f)", x, float32(width))
	}
}

@ 색은 콘솔과 같은 문턱(5, 25 센트)을 따라야 한다.
@<상태 색상 테스트@>=
func TestStatusColorThresholds(t *testing.T) {
	if c := statusColor(0); c != colorGreen {
		t.Errorf("0¢: %v (기대 초록)", c)
	}
	if c := statusColor(-10); c != colorYellow {
		t.Errorf("-10¢: %v (기대 노랑)", c)
	}
	if c := statusColor(30); c != colorRed {
		t.Errorf("+30¢: %v (기대 빨강)", c)
	}
	// 문턱 경계값도 확인한다.
	if c := statusColor(4.9); c != colorGreen {
		t.Errorf("4.9¢: %v (기대 초록)", c)
	}
	if c := statusColor(24.9); c != colorYellow {
		t.Errorf("24.9¢: %v (기대 노랑)", c)
	}
}

@ 문구는 부호에 따라 조임/풂 방향이 맞아야 한다.
@<상태 문구 테스트@>=
func TestStatusTextDirection(t *testing.T) {
	if txt := statusText(0); !strings.Contains(txt, "정확") {
		t.Errorf("0¢: %q (기대 '정확' 포함)", txt)
	}
	if txt := statusText(-10); !strings.Contains(txt, "조여") {
		t.Errorf("-10¢: %q (기대 '조여' 포함)", txt)
	}
	if txt := statusText(30); !strings.Contains(txt, "풀어") {
		t.Errorf("+30¢: %q (기대 '풀어' 포함)", txt)
	}
}

@* 찾아보기.
