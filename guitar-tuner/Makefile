# 기타 튜너 빌드용 Makefile (gweb-examples 패턴을 따름).
#
#   make tuner    # tuner.w        -> tuner.go + tuner_test.go + tuner.pdf   (콘솔)
#   make pitch    # pitch/pitch.w  -> pitch/pitch.go(+_test.go) + pitch/pitch.pdf
#   make gui      # gui/gui.w      -> gui/gui.go(+_test.go) + gui/gui.pdf    (Gio GUI)
#   make all      # 셋 다 tangle+weave
#   make run      # 콘솔 튜너 실행 (go run .)
#   make run-gui  # Gio GUI 튜너 실행 (go run ./gui)
#   make test     # go test ./...
#   make clean    # 원본(.w)만 남기고 생성물 삭제
#
# 패키지마다 .w 하나: pitch/pitch.w는 순수 코어, tuner.w는 콘솔 프런트,
# gui/gui.w는 Gio(순수 Go) 네이티브 GUI 프런트. 둘 다 같은 pitch.Stream을 쓴다.
# 한글 문서(\input kotexgweb.tex)는 luatex로, 그 밖은 pdftex로 조판한다.

GTANGLE ?= gtangle
GWEAVE  ?= gweave

.PHONY: help all run run-gui test clean tuner pitch gui
.DEFAULT_GOAL := help

help:
	@echo 'usage:'
	@echo '  make tuner   # tuner.w -> tuner.go(+_test) + tuner.pdf'
	@echo '  make pitch   # pitch/pitch.w -> pitch/pitch.go(+_test) + pitch/pitch.pdf'
	@echo '  make gui     # gui/gui.w -> gui/gui.go(+_test) + gui/gui.pdf'
	@echo '  make all     # 셋 다'
	@echo '  make run     # 콘솔 튜너 실행 (go run .)'
	@echo '  make run-gui # Gio GUI 튜너 실행 (go run ./gui)'
	@echo '  make test    # go test ./...'
	@echo '  make clean   # 생성물 삭제 (.w 원본은 남김)'

all: tuner pitch gui

tuner: tuner.go tuner.pdf
pitch: pitch/pitch.go pitch/pitch.pdf
gui: gui/gui.go gui/gui.pdf

# Tangle: <name>.w -> <name>.go (+ 부수 파일 _test.go)
tuner.go: tuner.w
	$(GTANGLE) tuner.w
pitch/pitch.go: pitch/pitch.w
	$(GTANGLE) pitch/pitch.w
gui/gui.go: gui/gui.w
	$(GTANGLE) gui/gui.w

# Weave + 조판.
tuner.pdf: tuner.w
	$(GWEAVE) tuner.w
	luatex tuner.tex </dev/null
pitch/pitch.pdf: pitch/pitch.w
	$(GWEAVE) pitch/pitch.w
	cd pitch && luatex pitch.tex </dev/null
gui/gui.pdf: gui/gui.w
	$(GWEAVE) gui/gui.w
	cd gui && luatex gui.tex </dev/null

run: tuner.go pitch/pitch.go
	go run .

run-gui: gui/gui.go pitch/pitch.go
	go run ./gui

test: tuner.go pitch/pitch.go gui/gui.go
	go test ./...

clean:
	rm -f *.go *.tex *.log *.toc *.pdf *.idx *.scn *.out tuner
	rm -f pitch/*.go pitch/*.tex pitch/*.log pitch/*.toc pitch/*.pdf pitch/*.idx pitch/*.scn pitch/*.out
	rm -f gui/*.go gui/*.tex gui/*.log gui/*.toc gui/*.pdf gui/*.idx gui/*.scn gui/*.out
