# CDQ 분할정복 예제 모음 빌드용 Makefile.
#
#   make            # tangle + 문서 조판
#   make tangle     # 각 디렉터리의 .w -> .go
#   make doc        # 각 디렉터리의 .pdf 조판 (한글이라 luatex)
#   make clean      # 생성물 삭제 (.w, .mp 원본은 남김)
#
# 문제를 풀어 보려면: go run ./flower < in  (./inv, ./stars, ./robin도 같다)
# 매크로(gwebmac.tex, kotexgweb.tex)는 설치된 texmf 트리에서 자동으로 찾는다.

GTANGLE ?= gtangle
GWEAVE  ?= gweave

.PHONY: all tangle doc clean
.DEFAULT_GOAL := all

all: tangle doc

tangle: flower/flower.go inv/inv.go stars/stars.go robin/robin.go

flower/flower.go: flower/flower.w
	cd flower && $(GTANGLE) flower.w

inv/inv.go: inv/inv.w
	cd inv && $(GTANGLE) inv.w

stars/stars.go: stars/stars.w
	cd stars && $(GTANGLE) stars.w

robin/robin.go: robin/robin.w
	cd robin && $(GTANGLE) robin.w

doc: flower/flower.pdf inv/inv.pdf stars/stars.pdf robin/robin.pdf

flower/flower-1.pdf: flower/flower.mp
	cd flower && mptopdf flower.mp

flower/flower.pdf: flower/flower.w flower/flower-1.pdf
	cd flower && $(GWEAVE) flower.w && luatex flower.tex </dev/null

inv/inv.pdf: inv/inv.w
	cd inv && $(GWEAVE) inv.w && luatex inv.tex </dev/null

stars/stars.pdf: stars/stars.w
	cd stars && $(GWEAVE) stars.w && luatex stars.tex </dev/null

robin/robin-1.pdf: robin/robin.mp
	cd robin && mptopdf robin.mp

robin/robin.pdf: robin/robin.w robin/robin-1.pdf
	cd robin && $(GWEAVE) robin.w && luatex robin.tex </dev/null

clean:
	rm -f */*.tex */*.log */*.toc */*.scn */*.idx */*.go
	rm -f */*.[0-9] */*-[0-9].pdf */*.mpx mpxerr.tex mpxerr.log
