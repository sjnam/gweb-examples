# 기타 튜너 (guitar-tuner)

맥의 마이크로 들어오는 소리에서 음정을 실시간으로 검출해 콘솔에 바늘 눈금으로
보여 주는 기타 튜너. 음정 검출은 **외부 라이브러리 없이 YIN 알고리즘을 직접
구현**했고, 오디오 캡처는 [malgo](https://github.com/gen2brain/malgo)(miniaudio)를
쓴다. 전체 코드는 Go 전용 literate programming 도구
**[GWEB](https://github.com/sjnam/gweb)**로 한글 문서와 함께 작성했다.

```text
   개방현  [A]  D   G   B   E   E
      A2    110.2 Hz   목표 110.00 Hz
   ♭ ────────────────────●┼─────────────────── ♯
      조금 낮음 ▲ 줄을 조여 주세요   -3.1¢
```

## 특징

- **YIN 음정 검출** — 차이함수 → 누적평균정규화 → 절대임계값 → 포물선 보간을
  직접 구현.
- **입력 전처리** — 원폴 고역통과(DC 차단) 2단으로 DC·럼블·60 Hz 험을 제거해
  조용한 고음현(B3·E4)도 안정적으로 검출.
- **어택 트랜지언트 억제** — 튕긴 직후 불안정 구간을, 명료도가 회복되는 순간
  푸는 *적응형 릴리스*로 걸러냄.
- **검출 안정화** — 중앙값 평활 + 옥타브 오류(2×/½×) 교정.
- **정확 잠금** — 정확히 맞으면 화면을 강조하고 신호음(터미널 벨)을 울림
  (히스테리시스 + 쿨다운으로 깜빡임·연타 방지).
- **크로매틱 계기판(콘솔 + 네이티브 GUI)** — 개방현 표시, 색상 바늘 눈금, 조임/풂
  안내, 정확 잠금 강조. 콘솔(터미널)과 [Gio](https://gioui.org) 네이티브 창, 두
  프런트가 같은 순수 코어(`pitch.Stream`)를 공유한다.

## 요구 사항

- **Go 1.26+**
- **macOS** (CoreAudio) + Xcode Command Line Tools (malgo는 cgo 사용)
- 마이크 접근 권한 (첫 실행 시 macOS가 물어봄)
- 유니코드 폰트를 쓰는 UTF-8 터미널 (`♭ ┼ ● ♯ ✓` 표시용, 콘솔 프런트)
- *(GUI 프런트)* 한글 표시를 위해 `/System/Library/Fonts/AppleSDGothicNeo.ttc`
  (macOS 기본 한글 글꼴)를 읽는다. 못 찾으면 라틴 글꼴로 물러나 한글이 깨질 수
  있으나 프로그램은 계속 동작한다.
- *(문서 생성 시)* GWEB 도구 `gtangle`/`gweave`, LuaTeX + `kotexgweb.tex` 매크로

## 빌드와 실행

코드는 `.w`(literate 원본)에서 `.go`로 뽑아(tangle) 쓴다.

```sh
make run          # 콘솔 프런트: tangle 후 go run .
make run-gui      # Gio GUI 프런트: tangle 후 go run ./gui
# 또는 수동으로:
gtangle pitch/pitch.w     # -> pitch/pitch.go, pitch/pitch_test.go
gtangle tuner.w           # -> tuner.go, tuner_test.go       (콘솔)
gtangle gui/gui.w         # -> gui/gui.go, gui/gui_test.go   (GUI)
go run .        # 콘솔
go run ./gui    # GUI 창
```

콘솔은 `Ctrl-C`로, GUI는 창을 닫으면 멈춘다.

### 명령줄 플래그

| 플래그 | 기본값 | 설명 |
| --- | --- | --- |
| `-a4` | `440` | 기준음 A4 주파수(Hz) — 관현악단은 442 등 |
| `-rate` | `44100` | 표본화율(Hz) — 장치가 44100을 거부하면 48000 등 |
| `-sensitivity` | `0.01` | 무음 문턱(RMS) — 작을수록 민감 |

```sh
go run . -a4 442 -sensitivity 0.02       # 콘솔
go run ./gui -a4 442 -sensitivity 0.02   # GUI (같은 플래그)
```

## 구조

패키지마다 literate 문서(`.w`) 하나. 각 `.w`는 자기 `.go`와 `_test.go`를 낸다.

```text
guitar-tuner/
├── pitch/pitch.w   → pitch/pitch.go (+_test.go)   순수 코어 (package pitch)
├── tuner.w         → tuner.go (+_test.go)          콘솔 프런트 (package main)
├── gui/gui.w       → gui/gui.go (+_test.go)        Gio GUI 프런트 (package main)
├── types.w                                          GWEB 조판용 공유 힌트
└── Makefile
```

- **`pitch`** — 마이크·화면에 의존하지 않는 순수 음정 검출 코어. 프런트가 아는
  것은 다음뿐이라, 어느 프런트에서나 그대로 재사용할 수 있다.

  ```go
  cfg := pitch.DefaultConfig()      // {A4:440, SampleRate:44100, MinRMS:0.01}
  stream := pitch.NewStream(cfg)
  for _, r := range stream.Push(samples) { // samples []float64
      // r.Reading: Voiced, Freq, Name, Octave, Cents, ...
      // r.Locked, r.Chime
  }
  ```

  내부 파이프라인:
  `고역통과 → YIN 검출 → 어택 억제 → 안정화 → 정확 잠금`.

- **`tuner.w`(콘솔)** — malgo로 마이크를 열어 표본을 `pitch.Stream`에 흘리고,
  나오는 `pitch.Result`를 터미널 계기판(ANSI 색상 바늘 눈금)에 그린다.

- **`gui/gui.w`(Gio GUI)** — 같은 마이크 캡처·`pitch.Stream` 파이프라인을 쓰지만,
  결과를 웹이 아니라 순수 Go GUI 툴킷 [Gio](https://gioui.org)로 그린 네이티브
  맥 창에 그린다(즉시모드 렌더링이라 바늘이 매끄럽게 움직인다). 오디오 콜백
  고루틴이 결과를 뮤텍스로 지켜지는 상태에 넣고 `window.Invalidate()`로 새
  프레임을 요청하는 구조다. 콘솔과 같은 다섯 부분 계기판(개방현 행·음이름·바늘
  눈금·상태 안내)을 그대로 옮겼고, 정확히 맞으면 배경이 연한 초록으로 강조된다.
  한글 표시를 위해 macOS 시스템 한글 글꼴을 읽어 쓴다(오디오 신호음은 아직
  없음 — 시각 강조만 v1 범위).

## 테스트

```sh
make test        # go test ./...
```

순수 검출 로직은 `pitch`에서, 콘솔 렌더링은 루트 `main`(`tuner_test.go`)에서,
GUI의 순수 렌더 도우미(바늘 위치·색상·안내 문구)는 `gui`(`gui_test.go`)에서
검증한다. 합성 신호(순음·배음·럼블)로 여섯 줄 검출, 옥타브 교정, 어택 릴리스,
정확 잠금 등을 다룬다.

## 문서 (literate)

각 `.w`를 weave 하면 한글 조판 PDF가 나온다.

```sh
make all         # 세 패키지 tangle + weave (PDF)
make pitch       # pitch/pitch.pdf
make tuner       # tuner.pdf
make gui         # gui/gui.pdf
```

## 정리

```sh
make clean       # 생성물(.go/.tex/.pdf 등) 삭제, .w 원본은 남김
```
