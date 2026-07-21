# 생명 게임 빌드용 Makefile.
#
#   make            # tangle + 실행 파일 + 문서 조판
#   make tangle     # life.w -> life.go
#   make life       # 실행 파일 빌드
#   make doc        # life.pdf 문서 조판 (한글이라 luatex)
#   make run        # 터미널에서 우주를 돌린다 (Ctrl-C로 종말)
#   make demo       # README용 GIF 녹화: demo/glider/pulsar (vhs 필요; 추적함)
#   make clean      # 생성물 삭제 (.w 원본과 GIF들은 남김)
#
# 매크로(gwebmac.tex, kotexgweb.tex)는 설치된 texmf 트리에서 자동으로 찾는다.

GTANGLE ?= gtangle
GWEAVE  ?= gweave

.PHONY: all tangle doc run demo clean
.DEFAULT_GOAL := all

all: life doc

tangle: life.go

life.go: life.w
	$(GTANGLE) life.w

life: life.go
	go build -o life

doc: life.pdf

life.pdf: life.w
	$(GWEAVE) life.w && luatex life.tex </dev/null

run: life
	./life

demo: demos/demo.gif demos/glider.gif demos/pulsar.gif

demos/demo.gif: demos/demo.tape life
	vhs demos/demo.tape

demos/glider.gif: demos/glider.tape life
	vhs demos/glider.tape

demos/pulsar.gif: demos/pulsar.tape life
	vhs demos/pulsar.tape

clean:
	rm -f life life.go
	rm -f life.tex life.log life.toc life.scn life.idx
