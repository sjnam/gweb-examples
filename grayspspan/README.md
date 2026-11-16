# grayspspan

그래프의 신장 나무를 모두 만들되, 이웃한 두 나무가 변 하나만 다르게 늘어놓는다.
변이 m개, 꼭짓점이 n개, 나무가 t개일 때 O(m+n+t) 시간이 든다.

- 문서: [grayspspan.w](grayspspan.w)
- 바탕: 맬컴 스미스의 석사 논문(1997)을 바탕으로 커누스가 `grayspan`과 `spspan`을
  합친 CWEB 프로그램(2004)
- 먼저 읽을 것: [grayspan](../grayspan), [spspan](../spspan)
- 필요한 것: [go-sgb](https://github.com/sjnam/go-sgb)

## 방법

- 겹친 변은 병렬로, 차수 2인 꼭짓점의 두 변은 직렬로 묶어 *결합*을 짓고, 차수 1인
  꼭짓점은 그 변을 꼭 넣기로 하고 없앤다. 더 줄일 수 없으면 변 하나를 줄인다.
- 그래프가 점 하나가 되면 결합들의 숲을 `spspan`의 초점 포인터로 훑는다.
- 되돌아 나오며 줄인 변이 다리가 아니면 지우고 다시 줄이기로 간다(`grayspan`).
- 결합을 짓고 허무는 일은 나중에 한 것을 먼저 되돌리는 춤추는 고리로 한다.

## 원본과 다른 점

- `grayspan`처럼 go-sgb 그래프를 작은 꼭짓점·호 구조체로 옮겨 담는다. 다목적
  필드에 겹쳐 두던 `mark`와 `bfs`도 따로 둔다.
- 셈 `mems`는 `main`의 지역 변수로 두고, `buildBond`와 `deleteBonds`는 제 셈을
  돌려준다.
- 한 곳에서만 부르는 `unbuildbond`는 함수 대신 절로 끼워 넣었다.
- 진단 함수 `printbond`가 지움 기록의 `rhist` 대신 `lhist`를 찍던 것을 고쳤다.

## 검증

- 그래프 369개, 실행 879가지에서 원본과 출력·mems·종료 부호가 바이트까지 같다.
- 커누스의 `sanitycheck`를 두 곳에서 부르게 한 시험판끼리도 출력이 같다.
- 신장 나무인지, 모두 다른지, 수가 행렬 나무 정리와 맞는지 따로 검사했다.

## 성능

K₁₀의 나무 10⁸개에서 원본 1.69초, 이 판 1.42초. 5×5 격자의 나무 5억 5천만 개에서
원본 9.0초, 이 판 7.6초.

## 빌드

저장소 루트에서 부른다. 규칙은 [../Makefile](../Makefile)에 있다.

```sh
make grayspspan  # grayspspan/grayspspan.go + grayspspan/grayspspan.pdf
make clean       # 모든 예제의 생성물 삭제
```
