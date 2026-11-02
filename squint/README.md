# squint

게으른 거듭제곱 급수를 요구에 따라 움직이는 채널 그물로 본다. 매킬로이의
*Squinting at Power Series*를 따른다.

- 문서: [squint.w](squint.w)
- 꾸러미: 라이브러리 `squint`(`main`이 없다). 시험 파일 `squint_test.go`를 함께
  짜 `go test`로 돌린다.

## 다루는 연산

- 합, 곱, 합성
- 역수, 함수의 역
- 미분 방정식(`exp` 같은 것)

## 빌드

저장소 루트에서 부른다. 규칙은 [../Makefile](../Makefile)에 있다.

```sh
make squint  # squint/squint.go + squint/squint_test.go + squint/squint.pdf
make clean   # 모든 예제의 생성물 삭제
```
