# queenon-partition

마이클 심킨이 n×n 격자를 다이아몬드로 자르고 45° 돌린 2N×2N 격자로 보내는 묘한
사상을 다룬다. 2021년에 그가 n-퀸 개수의 점근을 얻을 때 쓴 칸 나누기다.

- 문서: [queenon-partition.w](queenon-partition.w)
- 바탕: 커누스의 CWEB 프로그램
- 그림: 글 안에 담긴 luamplib 그림 둘

## 방법

- 배정 규칙은 *(ij)*와 넓이가 양수인 부분을 나누는 칸 가운데 가장 작은 *I*를
  잡고, 비기면 *더 큰* *J*를 잡는다는 것이다. 이 규칙은 쌍을 `I<<16 - J`로 담아
  최소를 지키면 저절로 나온다.
- 넓이 자체는 nN×nN 픽셀 격자 위의 무차별 셈으로 정한다.
- 프로그램은 그 배정을 그리는 MetaPost 파일을 뽑아낸다. Go의 날문자열이
  `fprintf` 스물 몇 개를 대신하니, MetaPost를 MetaPost로 읽을 수 있다.

## 검증

CWEB 원본과 (N, n) 쌍 649가지에서 표준 출력과 뽑아낸 `.mp`와 종료 코드가
바이트까지 같다.

## 빌드

```sh
make        # queenon-partition.go + queenon-partition.pdf
make clean  # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
