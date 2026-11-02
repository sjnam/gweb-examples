# 예제 디렉토리의 Makefile 들이 함께 읽는 빌드 규칙.
#
# 각 디렉토리의 Makefile 은 이름만 정하고 이 파일을 읽어들인다:
#
#   NAME    := matula                          # <NAME>.w 가 이 디렉토리의 문서
#   CHANGES := matula-big matula-exhaustive    # 변경 파일 <CHANGE>.ch (없으면 비움)
#   DEPS    := ../tarjan-strong/tarjan-strong.mp   # 다른 디렉토리에서 읽는 파일 (선택)
#   include ../gweb.mk
#
# 그러면 그 디렉토리에서
#
#   make            # <NAME>.w -> <NAME>.go(들) + <NAME>.pdf
#   make <CHANGE>   # <NAME>.w + <CHANGE>.ch -> <CHANGE>/<NAME>.go(들) + <CHANGE>/<NAME>.pdf
#   make clean      # 생성물 삭제 (.w/.ch/.mp 원본과 자료는 남김)
#
# 변경 파일을 적용한 결과는 하위 디렉토리 <CHANGE>/ 에 짠다. gtangle 과 gweave 는
# 출력 이름을 .ch 가 아니라 .w 에서 따오므로, 같은 자리에 짜면 원본의 <NAME>.go 를
# 덮어쓴다.
#
# 조판은 luatex 하나로 한다. 한글 문서(\input kotexgweb.tex)와 그림 있는
# 문서(\input luamplib.sty)가 luatex 를 요구하고---luamplib 은 \directlua 를 쓰므로
# pdftex 로는 돌지 않는다---여기 있는 문서는 모두 그 둘 가운데 하나다.
# 매크로(gwebmac.tex, kotexgweb.tex)는 설치된 texmf 트리에서 자동으로 찾는다.
#
# 그림은 따로 만들 것이 없다. MetaPost 는 luamplib 이 조판 중에 직접 돌린다. 그림은
# .w 안에 그대로 들어 있고, 문서 둘이 나눠 쓰는 도우미와 프로그램이 뱉는 좌표만
# <이름>.mp 에 남아 `input <이름>;` 으로 읽힌다.

GTANGLE ?= gtangle
GWEAVE  ?= gweave
# 이름을 TEX 로 두면 안 된다. make 의 내장 변수(TEX=tex)라 ?= 가 먹지 않는다.
LUATEX  ?= luatex

# 원본 말고도 다시 짜야 할 까닭이 되는 파일들: 공용 포함 파일과 이 디렉토리의 .mp.
SRCS := $(NAME).w ../types.w $(wildcard *.mp) $(DEPS)

.PHONY: all clean $(CHANGES)
.DEFAULT_GOAL := all

all: $(NAME).go $(NAME).pdf

# Tangle: <NAME>.w -> <NAME>.go  (@( ) 로 뽑는 부수 파일도 함께 생성)
$(NAME).go: $(SRCS)
	$(GTANGLE) $<

# Weave + 조판: <NAME>.w -> <NAME>.tex -> <NAME>.pdf
$(NAME).pdf: $(SRCS)
	$(GWEAVE) $<
	$(LUATEX) $(NAME).tex </dev/null

# 변경 파일 판. luatex 는 이 디렉토리에서 돌려야 .mp 와 자료를 찾으므로, 디렉토리를
# 옮겨 가지 않고 -output-directory 로 출력만 <CHANGE>/ 에 보낸다.
#
# 출력 디렉토리 이름에서는 쉼표를 `_`로 바꾼다(back-20q-backmod9,15 -> ..._15).
# Go 의 import 경로에는 쉼표가 들 수 없어, 그런 디렉토리가 하나라도 있으면 루트에서
# `go vet ./...` 가 통째로 멈춘다. 그래서 규칙을 변경 파일마다 따로 짠다.
comma  := ,
outdir  = $(subst $(comma),_,$1)

define change-rules
$1: $(call outdir,$1)/$(NAME).go $(call outdir,$1)/$(NAME).pdf

$(call outdir,$1)/$(NAME).go: $(SRCS) $1.ch
	@mkdir -p $$(@D)
	$(GTANGLE) -o $$(@D) $$< $1.ch

$(call outdir,$1)/$(NAME).pdf: $(SRCS) $1.ch
	@mkdir -p $$(@D)
	$(GWEAVE) -o $$(@D) $$< $1.ch
	$(LUATEX) -output-directory=$$(@D) $$(@D)/$(NAME).tex </dev/null
endef
$(foreach c,$(CHANGES),$(eval $(call change-rules,$c)))

# 생성물만 지운다. woven 출력은 <NAME>.tex 만 골라 지운다: `*.tex`로 싹 지우면 손으로
# 쓴 .tex 가 있을 때 함께 날아간다.
clean:
	rm -f *.go $(NAME).tex *.log *.toc *.pdf *.idx *.scn *.dvi *.out *.mpx
	rm -rf $(foreach c,$(CHANGES),$(call outdir,$c))
