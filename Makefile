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
%.pdf: %.w
	$(GWEAVE) $<
	@if [ -f $*.mp ]; then echo ">> mptopdf $*.mp"; mptopdf $*.mp; fi
	@if grep -q kotexgweb $<; then eng=luatex; else eng=pdftex; fi; \
	echo ">> $$eng $*.tex"; $$eng $*.tex </dev/null

# 원본(.w, .ch)만 남기고 모든 생성물(go/tex/pdf/로그·인덱스, 빌드된 실행파일) 삭제.
clean:
	rm -f *.go *.tex *.log *.toc *.pdf *.idx *.scn *.dvi *.out
	rm -f *.1 *-1.pdf *.mpx *.t1 *.mps   # MetaPost 산출물 (.mp 원본은 남김)
	rm -f $(NAMES)
