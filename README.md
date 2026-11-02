# GWEB 예제

[GWEB](https://github.com/sjnam/gweb)은 Go를 위한 문학적 프로그래밍 시스템이다.
커누스와 레비의 **CWEB**을 가까이 본떴다. 확장자 `.w` 파일 하나에 TeX 산문과 Go
코드를 엮어 두면, 도구 `gtangle`은 기계가 읽을 `.go`를 뽑아내고, `gweave`는
사람이 읽을 상호 참조 문서를 조판한다.

이 저장소는 그렇게 쓴 프로그램을 모은 것이다. 커누스의 CWEB 프로그램을 옮긴 것이
가장 많고, 알아 둘 만한 알고리즘의 해설(짚트리, FFT와 수론 변환, 리차오 트리,
플로이드의 무작위 뽑기)이 있다. 문서는 모두 한글로 썼다. 파일 `.w`가 짜 내는
PDF부터 보기를 권한다. 그쪽이 사람의 눈을 위한 면이다.

## 구성

예제는 저마다 제 이름의 디렉터리에 있다. 디렉터리에는 `.w` 원본과 그 README,
Makefile이 있고, 딸린 변경 파일(`.ch`), MetaPost 파일(`.mp`), 자료 파일도 함께
둔다. 루트의 `types.w`는 예제가 아니라 여러 문서가 `@i ../types.w`로 읽어들이는
공용 포함 파일이고, [gweb.mk](gweb.mk)는 디렉터리의 Makefile들이 함께 쓰는 빌드
규칙이다.

## 빌드

`gtangle`, `gweave`, 그리고 luatex(luamplib 포함)이 있어야 한다.

```sh
make ziptree          # ziptree/ 에서 ziptree.go + ziptree.pdf (cd ziptree && make 와 같다)
make all              # 모든 예제
make clean            # 생성물 삭제
cd matula && make matula-big   # 변경 파일 판: matula-big/matula.go + matula-big/matula.pdf
```

저장소 전체가 Go 모듈 하나(`go.mod`)이고, 디렉터리마다 패키지 하나가 된다.
대부분 `package main`이고, 라이브러리인 `perm`, `squint`, `ziptree`는 시험 파일을
함께 짠다. 몇몇 예제가 쓰는 [go-sgb](https://github.com/sjnam/go-sgb)도 여기서 받아
온다. 그래서 짜 낸 뒤에는 `go run ./floyd`, `go test ./ziptree`, `go vet ./...`이
그대로 된다.
변경 파일 판을 짜는 하위 디렉터리는 이름의 쉼표를 `_`로 바꾼다
(`back-20q-backmod9,15.ch` → `back-20q-backmod9_15/`). Go의 import 경로에는 쉼표가
들 수 없기 때문이다. 짜 낸 `.go`는 추적하지 않으므로, 빌드하기 전에 `go mod tidy`를
부르면 go-sgb가 `go.mod`에서 지워진다.

## 예제

* [15puzzle-korf1](15puzzle-korf1) — 15 퍼즐의 최소 수 풀이를 코르프의 반복 깊이 증가로 찾는다.
* [back-20q](back-20q) — 돈 우즈의 자기 지시 퍼즐 *스무 문제*를 푼다.
* [back-dissect](back-dissect) — 정사각형을 조각으로 잘라 다른 모양을 채우는 방법을 모두 찾는다.
* [back-graceful](back-graceful) — 그래프의 *우아한 이름표*를 모두 찾는다.
* [back-pdi](back-pdi) — 차수 m의 *완전 자릿수 불변수*를 모두 찾는다.
* [back-pi-day](back-pi-day) — 요한 더라위터르의 2018년 파이 데이 퍼즐을 푼다.
* [back-skeleton](back-skeleton) — 타케 준야의 곱셈 뼈대 퍼즐을 짓는다.
* [back-warnsdorf](back-warnsdorf) — 바른스도르프 규칙을 따르는 나이트 투어를 동률의 갈림까지 모두 훑는다.
* [canonize-bidigraph](canonize-bidigraph) — 양방향 그래프의 정규형을 구한다.
* [celtic-paths](celtic-paths) — 켈트 매듭을 커누스의 CELTICA/CELTICB 글꼴로 찍는다.
* [commafree-eastman](commafree-eastman) — 쉼표 없는 부호를 짓는 이스트먼의 1965년 알고리즘.
* [dragon-calc](dragon-calc) — 데킹의 일반화된 용 곡선과 타일 계산을 위한 대화형 계산기.
* [enigmatic-puzzle](enigmatic-puzzle) — TAOCP 7.2.2.8의 125글자짜리 에니그마 암호문을 깬다.
* [floyd](floyd) — √1…√50을 거의 같은 두 몫으로 가르는 플로이드의 분할 문제.
* [grayspan](grayspan) — 그래프의 신장 나무를 이웃끼리 변 하나만 다르게 모두 늘어놓는다.
* [hopcroft-karp](hopcroft-karp) — 이분 그래프의 최대 매칭을 홉크로프트와 카프의 알고리즘으로 찾는다.
* [hyperbolic](hyperbolic) — 36°-45°-90° 삼각형으로 쌍곡 평면을 덮는 타일링을 셈한다.
* [infty-queens](infty-queens) — 끝없는 체스판에 여왕을 탐욕스럽게 놓아 가는 수열(OEIS A065188)을 계산한다.
* [koda-ruskey](koda-ruskey) — *숲 포셋의 이상*을 그레이 부호로 모두 만들어 낸다.
* [li-ruskey](li-ruskey) — 방향 그래프의 제약을 지키는 0/1 라벨링을 그레이 경로로 늘어놓는다.
* [matula](matula) — 자유 나무가 다른 자유 나무의 부분 나무와 동형인지 마툴라의 알고리즘으로 판정한다.
* [nqueens-somers](nqueens-somers) — N 여왕 문제의 해를 세는 제프 소머즈의 기법을 풀어 설명한다.
* [ntt](ntt) — 고속 푸리에 변환과 수론 변환으로 가는 길잡이.
* [othello](othello) — m×n 판에서 p명이 두는 일반화한 오델로를 대화형으로 진행한다.
* [pairsums](pairsums) — 모든 부분 배열의 쌍 곱의 합 가운데 가장 큰 것을 리차오 트리로 찾는다.
* [perec](perec) — 조르주 페렉의 *인생 사용법*을 그 두 제약에서 다시 짓는다.
* [perfect-partition-square](perfect-partition-square) — 7의 분할 14가지를 7×7 정사각형에 담는 마이클 켈러의 퍼즐.
* [perm](perm) — 플로이드의 무작위 뽑기 알고리즘.
* [polynum](polynum) — 고정 다항체를 세는 Jensen의 전이 행렬 방법.
* [prime-sieve](prime-sieve) — 구간마다 돌리는 에라토스테네스의 체로 소수 간격의 기록을 찾는다.
* [prjeuler152](prjeuler152) — Project Euler 152번 문제를 정확한 유리수 연산으로 푼다.
* [queenon-partition](queenon-partition) — 심킨이 n-퀸 개수의 점근에 쓴 칸 나누기를 그린다.
* [sliding](sliding) — 미닫이 블록 퍼즐을 두루 푸는 엔진.
* [spiders](spiders) — `koda-ruskey`와 `li-ruskey`의 문제를 다른 쪽에서 풀어 삼부작을 닫는다.
* [squint](squint) — 게으른 거듭제곱 급수를 채널 그물로 다룬다.
* [tarjan-strong](tarjan-strong) — 타잔의 강한 성분(알고리즘 7.4.1.2T).
* [tarjan-strong-and-weak](tarjan-strong-and-weak) — 강한 성분과 커누스의 *약한 성분*(알고리즘 7.4.1.2W).
* [topswops](topswops) — 콘웨이의 *톱스왑스*에서 가장 오래 버티는 패를 찾는다.
* [ulam-gibbs](ulam-gibbs) — 울람 수를 필립 깁스의 방법으로 수십억 개 셈한다.
* [wordcube](wordcube) — 다섯 글자 낱말로 대칭 5×5×5 낱말 정육면체를 짓는다.
* [ziptree](ziptree) — 타잔과 레비와 팀멜의 짚트리.
