# prjeuler152

Project Euler 152번 문제를 푼다.

- 문서: [prjeuler152.w](prjeuler152.w)

## 어려운 점

핵심이자 재미는 합을 부동소수점으로 견줄 수 없다는 데 있다.

- $1/n^2$ 항을 더할 때는 정확한 유리수 연산이 필요하다.
- $2^{79}$개의 부분집합을 모두 도는 무차별 방법은 불가능하다.

## 빌드

저장소 루트에서 부른다. 규칙은 [../Makefile](../Makefile)에 있다.

```sh
make prjeuler152  # prjeuler152/prjeuler152.go + prjeuler152/prjeuler152.pdf
make clean        # 모든 예제의 생성물 삭제
```
