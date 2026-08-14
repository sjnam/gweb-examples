# CDQ 분할정복 예제 모음 빌드용 Makefile.
#
#   make            # tangle + 문서 조판
#   make tangle     # 각 디렉터리의 .w -> .go
#   make doc        # 각 디렉터리의 .pdf 조판 (한글이라 luatex)
#   make clean      # 생성물 삭제 (.w 원본은 남김)
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

flower/flower.pdf: flower/flower.w
	cd flower && $(GWEAVE) flower.w && luatex flower.tex </dev/null

inv/inv.pdf: inv/inv.w
	cd inv && $(GWEAVE) inv.w && luatex inv.tex </dev/null

stars/stars.pdf: stars/stars.w
	cd stars && $(GWEAVE) stars.w && luatex stars.tex </dev/null

robin/robin.pdf: robin/robin.w
	cd robin && $(GWEAVE) robin.w && luatex robin.tex </dev/null

# 그림을 미리 굽지 않으므로, 문서 PDF 를 지워야 다시 짜인다.
clean:
	rm -f */*.tex */*.log */*.toc */*.scn */*.idx */*.go */*.pdf
