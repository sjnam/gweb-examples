# pairsums

[pairsums.w](pairsums.w) — 모든 부분 배열에 대한 쌍
곱의 합 가운데 가장 큰 것을 찾는다. 항등식 value = (S²−Q)/2와 누적합 비틀기가
이것을 직선 가족의 위 포락선 문제로 바꾸고, **리차오 트리**로 O(n log n)에
푼다.

## 빌드

```sh
make        # pairsums.w -> pairsums.go + pairsums.pdf
make clean  # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
