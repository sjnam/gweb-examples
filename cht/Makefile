# 볼록 껍질 트릭 예제 모음 빌드용 Makefile.
#
#   make            # tangle + 문서 조판
#   make tangle     # frog/frog.w -> frog.go, 다른 디렉터리도 같게
#   make doc        # frog/frog.pdf 등 문서 조판 (한글이라 luatex)
#   make clean      # 생성물 삭제 (.w 원본은 남김)
#
# 문제를 풀어 보려면: go run ./frog < in  (bridge, cash, segment도 같게)
# 매크로(gwebmac.tex, kotexgweb.tex)는 설치된 texmf 트리에서 자동으로 찾는다.

GTANGLE ?= gtangle
GWEAVE  ?= gweave

.PHONY: all tangle doc clean
.DEFAULT_GOAL := all

all: tangle doc

tangle: frog/frog.go bridge/bridge.go cash/cash.go segment/segment.go

frog/frog.go: frog/frog.w
	cd frog && $(GTANGLE) frog.w

bridge/bridge.go: bridge/bridge.w
	cd bridge && $(GTANGLE) bridge.w

cash/cash.go: cash/cash.w
	cd cash && $(GTANGLE) cash.w

segment/segment.go: segment/segment.w
	cd segment && $(GTANGLE) segment.w

doc: frog/frog.pdf bridge/bridge.pdf cash/cash.pdf segment/segment.pdf

frog/frog.pdf: frog/frog.w
	cd frog && $(GWEAVE) frog.w && luatex frog.tex </dev/null

bridge/bridge.pdf: bridge/bridge.w
	cd bridge && $(GWEAVE) bridge.w && luatex bridge.tex </dev/null

cash/cash.pdf: cash/cash.w
	cd cash && $(GWEAVE) cash.w && luatex cash.tex </dev/null

segment/segment.pdf: segment/segment.w
	cd segment && $(GWEAVE) segment.w && luatex segment.tex </dev/null


# 그림을 미리 굽지 않으므로, 문서 PDF 를 지워야 다시 짜인다.
clean:
	rm -f */*.tex */*.log */*.toc */*.scn */*.idx */*.go */*.pdf
