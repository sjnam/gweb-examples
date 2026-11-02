# squint

[squint.w](squint.w) — 게으른 거듭제곱 급수를 요구에 따라 움직이는 채널 그물로
본다(합, 곱, 합성, 역수, 함수의 역, 그리고 `exp` 같은 미분 방정식). 매킬로이의
*Squinting at Power Series*를 따른다.

## 빌드

```sh
make        # squint.w -> squint.go + squint_test.go + squint.pdf
make clean  # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
