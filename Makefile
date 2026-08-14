# GWEB 예제 빌드용 Makefile.
#
#   make <이름>    # <이름>.w 를 tangle+weave 하여 <이름>.go(들)과 <이름>.pdf 생성
#                  #   예) make ziptree
#   make clean     # 원본(.w/.ch)만 남기고 생성물 모두 삭제
#
# 예제마다 한 번에 하나씩 빌드한다(`make all`은 없다). 거의 모든 .go 가 package main
# 의 main() 을 가져, 한 디렉토리에 동시에 풀면 Go 가 main 중복으로 컴파일을 거부한다.
#
# 한글 문서(\input kotexgweb.tex)는 luatex로, 그 밖은 pdftex로 조판한다. 매크로
# (gwebmac.tex, kotexgweb.tex)는 설치된 texmf 트리에서 자동으로 찾는다. 변경 파일
# .ch 를 적용하려면 수작업으로 부른다(예: gtangle wc.w wc.ch).

GTANGLE ?= gtangle
GWEAVE  ?= gweave
MPOST   ?= mpost

WFILES := $(wildcard *.w)
NAMES  := $(WFILES:.w=)

.PHONY: help clean $(NAMES)
.DEFAULT_GOAL := help

help:
	@echo 'usage:'
	@echo '  make <name>   # <name>.w -> <name>.go(들) + <name>.pdf   (예: make ziptree)'
	@echo '  make clean    # 생성물 삭제 (.w/.ch 원본은 남김)'

# `make ziptree` 처럼 확장자 없는 이름으로 .go 와 .pdf 를 함께 만든다.
$(NAMES): %: %.go %.pdf

# Tangle: <name>.w -> <name>.go  (@( ) 로 뽑는 부수 파일도 함께 생성)
%.go: %.w
	$(GTANGLE) $<

# Weave + 조판: <name>.w -> <name>.tex -> <name>.pdf
#
# 그림(.mp)의 btex 라벨은 plain TeX으로 조판한다. mptopdf 는 늘 --tex=latex 로
# 돌기 때문에 mpost 를 직접 부르고, 나온 그림 파일(<name>.1 ...)만 mptopdf 로
# PDF 로 바꾼다. plain TeX 이되 e-TeX 원시명령이 있어야 하므로 etex 를 쓴다
# (한글 라벨을 넣는 kotex-plain 이 \unless 따위를 쓴다).
%.pdf: %.w
	$(GWEAVE) $<
	@if [ -f $*.mp ]; then echo ">> mpost --tex=etex $*.mp"; \
	rm -f $*.[0-9]*; $(MPOST) --tex=etex $*.mp && mptopdf $*.[0-9]*; fi
	@if grep -q kotexgweb $<; then eng=luatex; else eng=pdftex; fi; \
	echo ">> $$eng $*.tex"; $$eng $*.tex </dev/null

# 생성물만 삭제한다. 소스(.w, .ch, .mp, 그리고 손으로 쓴 pic.tex 같은 .tex)는
# 남긴다. 특히 woven 출력만 골라 지운다: `*.tex`로 싹 지우면 pic.tex 같은 소스
# .tex 까지 날아가므로, .w 에 대응하는 <name>.tex 만 지운다.
clean:
	rm -f *.go $(WFILES:.w=.tex) *.log *.toc *.pdf *.idx *.scn *.dvi *.out
	rm -f *.[0-9]* *.mpx *.mps
	rm -f $(NAMES)
