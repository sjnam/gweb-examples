# floyd

[floyd.w](floyd.w) — 플로이드의 분할 문제. 커누스가 *장난감 문제는 쓸모
있는가?*에서 다룬 고전적인 "장난감 문제"다. √1…√50을 거의 같은 두 몫으로
가른다. 문학적으로 푼 풀이(중간에서 만나기 탐색, 그레이 부호 열거, 보정 덧셈,
그리고 `math/big` 검증)다.

## 빌드

```sh
make        # floyd.w -> floyd.go + floyd.pdf
make clean  # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
