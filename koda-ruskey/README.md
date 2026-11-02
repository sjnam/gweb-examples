# koda-ruskey

*숲 포셋의 이상*을 모두 만들어 낸다. 곧 부모가 1일 때만 자식이 1일 수 있는
비트열 모두를, 한 걸음에 비트 하나만 바뀌는 일반화된 반사 그레이 부호로
늘어놓는다.

- 문서: [koda-ruskey.w](koda-ruskey.w)
- 바탕: 커누스의 CWEB 프로그램
- 그림: MetaPost 그림 셋
- 다음 읽을거리: [li-ruskey](../li-ruskey/), [spiders](../spiders/)

## 두 구현

같은 수열을 두 가지로 구현해 나란히 둔다.

- **코루틴 판**: 마디마다 코루틴 하나를 둔다.
- **무반복 판**: 한 걸음이 언제나 네 고리짜리 *변두리*에 대한 정해진 수의
  연산이다.

## 원본과 다른 점

CWEB 원본은 열 가지 상태의 `switch`로 코루틴을 손수 흉내 낸다. 옮긴 판은 그것을
버퍼 없는 채널에서 만나는 고루틴으로 적는다. 그래서 여섯 줄짜리 코루틴 몸통이
그대로 살아남는다.

## 빌드

저장소 루트에서 부른다. 규칙은 [../Makefile](../Makefile)에 있다.

```sh
make koda-ruskey  # koda-ruskey/koda-ruskey.go + koda-ruskey/koda-ruskey.pdf
make clean        # 모든 예제의 생성물 삭제
```
