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
# 그림은 따로 만들 것이 없다. 그림이 있는 문서는 모두 한글 문서(곧 luatex)이고,
# MetaPost 는 luamplib 이 조판 중에 직접 돌린다. 그림이 여러 장인 문서는 그림들을
# <name>.mp 에 이름 붙은 매크로로 두고 문서가 `input <name>;` 으로 읽어들인다.
%.pdf: %.w
	$(GWEAVE) $<
	@if grep -q kotexgweb $<; then eng=luatex; else eng=pdftex; fi; \
	echo ">> $$eng $*.tex"; $$eng $*.tex </dev/null

# 생성물만 삭제한다. 소스(.w, .ch, .mp)는 남긴다. 특히 woven 출력만 골라 지운다:
# `*.tex`로 싹 지우면 손으로 쓴 .tex 가 있을 때 함께 날아가므로, .w 에 대응하는
# <name>.tex 만 지운다.
#
# `*.[0-9]*` 는 mpost 가 그림마다 뱉는 <name>.1, <name>.2, ... 를 쓸어 담는다.
# `*.[0-9]` 로는 한 자리밖에 못 잡아 <name>.12 같은 것이 남는다. 소스 이름에는
# 점 뒤에 숫자가 오는 것이 없으니 이 글로브에 걸릴 것도 없다.
clean:
	rm -f *.go $(WFILES:.w=.tex) *.log *.toc *.pdf *.idx *.scn *.dvi *.out
	rm -f *.[0-9]* *.mpx
	rm -f $(NAMES)
