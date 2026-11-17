# spgraph

`----ps-sp--sp` 같은 직병렬 식을 Stanford GraphBase 그래프 파일로 바꾼다. 커누스가
`spspan`을 `grayspan`과 견주려고 짠 짧은 프로그램이다.

- 문서: [spgraph.w](spgraph.w)
- 바탕: 커누스의 CWEB 프로그램 `spgraph.w`(2017)
- 함께 볼 것: [spspan](../spspan), [grayspan](../grayspan), [grayspspan](../grayspspan)
- 그림: [../spspan/spspan.mp](../spspan/spspan.mp)의 첫 그림을 `spspan`과 나눠 쓴다.
- 필요한 것: [go-sgb](https://github.com/sjnam/go-sgb)

## 방법

- 식을 스택으로 읽어 이진 나무로 바꾼다(`spspan`과 같다).
- 나무를 위에서 내려가며, 직렬 연산마다 가운데 꼭짓점을 하나 들이고 잎마다 변을
  놓는다.

## 원본과 다른 점

- `spspan`과 같은 결함, 이항 연산자가 255개를 넘으면 엉뚱한 그래프를 저장하는
  것을 고쳤다.
- go-sgb의 `SaveGraph`는 이상 비트 대신 오류를 돌려주므로, 오류가 나면 원본처럼
  `-2`로 치고 `fffffffe`로 찍는다.

## 검증

- 식 514개에서 원본과 저장 파일·출력·종료 부호가 바이트까지 같다.
- 올바른 식 504개에서 `spspan`과 `grayspspan`이 센 나무 수가 같다.

## 빌드

저장소 루트에서 부른다. 규칙은 [../Makefile](../Makefile)에 있다.

```sh
make spgraph   # spgraph/spgraph.go + spgraph/spgraph.pdf
make clean     # 모든 예제의 생성물 삭제
```
