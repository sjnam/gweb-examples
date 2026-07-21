# 볼록 껍질 트릭 예제 모음 빌드용 Makefile.
#
#   make            # tangle + 문서 조판
#   make tangle     # frog/frog.w -> frog.go, 다른 디렉터리도 같게
#   make doc        # frog/frog.pdf 등 문서 조판 (한글이라 luatex)
#   make clean      # 생성물 삭제 (.w, .mp 원본은 남김)
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

frog/frog-1.pdf: frog/frog.mp
	cd frog && mptopdf frog.mp

frog/frog.pdf: frog/frog.w frog/frog-1.pdf
	cd frog && $(GWEAVE) frog.w && luatex frog.tex </dev/null

bridge/bridge-1.pdf: bridge/bridge.mp
	cd bridge && mptopdf bridge.mp

bridge/bridge.pdf: bridge/bridge.w bridge/bridge-1.pdf
	cd bridge && $(GWEAVE) bridge.w && luatex bridge.tex </dev/null

cash/cash-1.pdf: cash/cash.mp
	cd cash && mptopdf cash.mp

cash/cash.pdf: cash/cash.w cash/cash-1.pdf
	cd cash && $(GWEAVE) cash.w && luatex cash.tex </dev/null

segment/segment-1.pdf: segment/segment.mp
	cd segment && mptopdf segment.mp

segment/segment.pdf: segment/segment.w segment/segment-1.pdf
	cd segment && $(GWEAVE) segment.w && luatex segment.tex </dev/null


clean:
	rm -f */*.tex */*.log */*.toc */*.scn */*.idx */*.go
	rm -f */*.[0-9] */*-[0-9].pdf */*.mpx mpxerr.tex mpxerr.log
