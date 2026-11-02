# perm

[perm.w](perm.w) — **플로이드의 무작위 뽑기 알고리즘**(벤틀리의 *More
Programming Pearls*에서). 1…N에서 서로 다른 정수 M개를 균등하게 O(M)에 뽑는다.
모든 부분집합이 같은 확률이고, 순진한 방법이 겪는 충돌 재시도가 없다. 작은
`perm` 라이브러리(와 채널 기반 생성기)를 짓는 한글 문학적 에세이이고,
성질·재현성·분포·벤치마크를 다루는 넉넉한 `@(perm_test.go@>` 묶음이 딸려 있다.

## 빌드

```sh
make        # perm.w -> perm.go + perm_test.go + perm.pdf
make clean  # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
