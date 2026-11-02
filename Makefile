# GWEB 예제 빌드용 Makefile.
#
# 예제는 저마다 제 디렉토리에 있고, 그 디렉토리의 Makefile 이 빌드한다(규칙은
# gweb.mk). 이 파일은 그쪽으로 넘겨 줄 뿐이다.
#
#   make <이름>    # <이름>/ 에서 make: <이름>.go(들)과 <이름>.pdf 생성
#                  #   예) make ziptree   (cd ziptree && make 와 같다)
#   make all       # 모든 예제 빌드
#   make clean     # 모든 예제의 생성물 삭제
#
# 변경 파일 판은 그 디렉토리에서 부른다(예: cd matula && make matula-big).

DIRS := $(patsubst %/Makefile,%,$(wildcard */Makefile))

.PHONY: help all clean $(DIRS)
.DEFAULT_GOAL := help

help:
	@echo 'usage:'
	@echo '  make <name>   # <name>/ 에서 <name>.go(들) + <name>.pdf   (예: make ziptree)'
	@echo '  make all      # 모든 예제 빌드'
	@echo '  make clean    # 생성물 삭제 (.w/.ch 원본은 남김)'

$(DIRS):
	$(MAKE) -C $@

all: $(DIRS)

clean:
	@for d in $(DIRS); do $(MAKE) -C $$d clean || exit 1; done
