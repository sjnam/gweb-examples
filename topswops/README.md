# topswops

[topswops.w](topswops.w) — 콘웨이의 *톱스왑스* 놀이에서 가장 오래 버티는 패를
두 길로 찾는다. 기본은 페퍼다인의 거꾸로 탐색(끝난 자리에서 놀이를 거꾸로
돌린다)이고, `-fwd`를 주면 자리 표시 카드와 `f(m)` 가지치기 한계를 쓰는 앞으로
가는 분기 한정 탐색(`goto` 상태 기계)을 한다. 덱 크기는 `-n`으로 바꾼다.
커누스의 CWEB `topswops.w`와 `topswops-fwd.w`를 하나로 합쳐 다시 풀어 쓴 한글
문학적 에세이이고, MetaPost 그림 넷(놀이 한 판, n=3의 거꾸로 탐색 나무 전체,
이름표 다섯 개짜리 상태 기계, 가지치기 한계)과 콘웨이의 멈춤 논증에 대한 증명이
딸려 있다.

## 빌드

```sh
make        # topswops.w -> topswops.go + topswops.pdf
make clean  # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
