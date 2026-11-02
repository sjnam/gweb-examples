# GWEB 예제 빌드용 Makefile.
#
# 예제는 저마다 제 이름의 디렉토리에 있다(<이름>/<이름>.w). 이 파일 하나가 모두를
# 빌드하므로 저장소 루트에서 부른다.
#
#   make <이름>      # <이름>/<이름>.w -> <이름>/<이름>.go(들) + <이름>/<이름>.pdf
#                    #   예) make ziptree
#   make <변경>      # <이름>/<변경>.ch 판 -> <이름>/<변경>/ 아래에 같은 것들
#                    #   예) make matula-big
#   make all         # 모든 예제 (변경 파일 판은 빼고)
#   make clean       # 생성물 삭제 (.w/.ch/.mp 원본과 자료는 남김)
#
# 예제와 변경 파일은 */*.w 와 */*.ch 를 훑어 찾으므로, 새 예제를 더할 때 이 파일을
# 고칠 일은 없다.
#
# 조판은 luatex 하나로 한다. 한글 문서(\input kotexgweb.tex)와 그림 있는
# 문서(\input luamplib.sty)가 luatex 를 요구하고---luamplib 은 \directlua 를 쓰므로
# pdftex 로는 돌지 않는다---여기 있는 문서는 모두 그 둘 가운데 하나다.
# 매크로(gwebmac.tex, kotexgweb.tex)는 설치된 texmf 트리에서 자동으로 찾는다.
#
# 그림은 따로 만들 것이 없다. MetaPost 는 luamplib 이 조판 중에 직접 돌린다. 그림은
# .w 안에 그대로 들어 있고, 문서 둘이 나눠 쓰는 도우미와 프로그램이 뱉는 좌표만
# <이름>.mp 에 남아 `input <이름>;` 으로 읽힌다. 그래서 luatex 는 예제 디렉토리
# 안에서 돌린다.

GTANGLE ?= gtangle
GWEAVE  ?= gweave
# 이름을 TEX 로 두면 안 된다. make 의 내장 변수(TEX=tex)라 ?= 가 먹지 않는다.
LUATEX  ?= luatex

NAMES   := $(notdir $(basename $(wildcard */*.w)))
CHFILES := $(wildcard */*.ch)

# 변경 파일 판의 출력 디렉토리 이름에서는 쉼표를 `_`로 바꾼다
# (back-20q-backmod9,15 -> ..._15). Go 의 import 경로에는 쉼표가 들 수 없어, 그런
# 디렉토리가 하나라도 있으면 `go vet ./...` 가 통째로 멈춘다.
comma  := ,
outdir  = $(subst $(comma),_,$1)

.PHONY: help all clean $(NAMES) $(notdir $(CHFILES:.ch=))
.DEFAULT_GOAL := help

help:
	@echo 'usage:'
	@echo '  make <name>     # <name>/<name>.go(들) + <name>/<name>.pdf   (예: make ziptree)'
	@echo '  make <change>   # <change>.ch 판 -> <name>/<change>/   (예: make matula-big)'
	@echo '  make all        # 모든 예제'
	@echo '  make clean      # 생성물 삭제 (.w/.ch 원본은 남김)'

all: $(NAMES)

# 예제 하나($1). gtangle 과 gweave 는 출력을 입력 파일의 디렉토리에 쓰고, @i 도
# 그 디렉토리를 기준으로 찾는다(@i ../types.w).
define example-rules
$1: $1/$1.go $1/$1.pdf

$1/$1.go: $1/$1.w types.w $(wildcard $1/*.mp)
	$(GTANGLE) $$<

$1/$1.pdf: $1/$1.w types.w $(wildcard $1/*.mp)
	$(GWEAVE) $$<
	cd $1 && $(LUATEX) $1.tex </dev/null
endef

# 변경 파일 판: 예제 $1 에 $1/$2.ch 를 적용한다. gtangle 과 gweave 는 출력 이름을
# .ch 가 아니라 .w 에서 따오므로, 같은 자리에 짜면 원본의 <이름>.go 를 덮어쓴다.
# 그래서 하위 디렉토리에 짜되, luatex 는 예제 디렉토리에서 돌려야 .mp 와 자료를
# 찾으므로 -output-directory 로 출력만 그리 보낸다.
define change-rules
$2: $1/$(call outdir,$2)/$1.go $1/$(call outdir,$2)/$1.pdf

$1/$(call outdir,$2)/$1.go: $1/$1.w types.w $1/$2.ch
	@mkdir -p $$(@D)
	$(GTANGLE) -o $$(@D) $$< $1/$2.ch

$1/$(call outdir,$2)/$1.pdf: $1/$1.w types.w $1/$2.ch $(wildcard $1/*.mp)
	@mkdir -p $$(@D)
	$(GWEAVE) -o $$(@D) $$< $1/$2.ch
	cd $1 && $(LUATEX) -output-directory=$(call outdir,$2) $(call outdir,$2)/$1.tex </dev/null
endef

$(foreach n,$(NAMES),$(eval $(call example-rules,$n)))
$(foreach f,$(CHFILES),$(eval $(call change-rules,$(patsubst %/,%,$(dir $f)),$(notdir $(f:.ch=)))))

# 다른 예제 디렉토리에서 읽어 오는 파일.
tarjan-strong-and-weak/tarjan-strong-and-weak.pdf: tarjan-strong/tarjan-strong.mp

# 생성물만 지운다. woven 출력은 <이름>/<이름>.tex 만 골라 지운다: `*.tex`로 싹
# 지우면 손으로 쓴 .tex 가 있을 때 함께 날아간다.
clean:
	rm -f */*.go */*.log */*.toc */*.pdf */*.idx */*.scn */*.dvi */*.out */*.mpx
	rm -f $(foreach n,$(NAMES),$n/$n.tex)
	rm -rf $(foreach f,$(CHFILES),$(dir $f)$(call outdir,$(notdir $(f:.ch=))))
