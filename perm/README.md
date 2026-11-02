# perm

**플로이드의 무작위 뽑기 알고리즘**(벤틀리의 *More Programming Pearls*에서)으로
1…N에서 서로 다른 정수 M개를 균등하게 O(M)에 뽑는다. 모든 부분집합이 같은
확률이고, 순진한 방법이 겪는 충돌 재시도가 없다.

- 문서: [perm.w](perm.w)
- 꾸러미: 라이브러리 `perm`(`main`이 없다)

## 내용

작은 `perm` 라이브러리(와 채널 기반 생성기)를 짓는 한글 문학적 에세이다.
성질·재현성·분포·벤치마크를 다루는 넉넉한 시험 묶음 `@(perm_test.go@>`이 딸려
있어 `go test`로 돌린다.

## 빌드

```sh
make        # perm.go + perm_test.go + perm.pdf
make clean  # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
