# tarjan-strong

**타잔의 강한 성분**. 깊이 우선 한 번으로 강한 성분을 모두 찾고, 증서도 함께
내놓는다.

- 문서: [tarjan-strong.w](tarjan-strong.w)
- 바탕: 커누스의 CWEB `tarjan-strong.w`(곧 나올 프리패시클 12a의 알고리즘
  7.4.1.2T)
- 필요한 것: [go-sgb](https://github.com/sjnam/go-sgb)
- 그림: MetaPost 그림 셋. 도우미 [tarjan-strong.mp](tarjan-strong.mp)는
  [tarjan-strong-and-weak](../tarjan-strong-and-weak/)와 함께 쓴다.
- 다음 읽을거리: [tarjan-strong-and-weak](../tarjan-strong-and-weak/)

## 증서

- 성분마다 강한 연결을 지켜 주는 `tree`와 `inner` 호
- 응축 그래프의 호마다 `link` 하나

## 커누스의 틀린 규칙

커누스 자신의 노트에는 그가 처음에 잘못 잡았던 규칙, 곧 나무 자식이 LOW를 비길
때 부모의 안쪽 호를 버리는 규칙이 적혀 있다. 이 문서는 그 틀린 판을 지어 그의
다섯 호짜리 반례에 돌려 실패를 되살린다.

## 커누스의 LOW는 lowlink가 아니다

여기서 LOW는 패시클이 *내리막 경로*와 호의 *성숙*으로 정의하는
이브–쿠르키수오니오 판이지, 타잔의 1972년 lowlink가 아니다.

- 나무가 아닌 호 `v→u`는 PRE(u)가 아니라 LOW(u)를 돌려준다.
- 그래서 "LOW가 같으면 성분도 같다"는 거짓이다(무작위 방향 그래프 500개 가운데
  168개에서 깨졌다).
- 그 때문에 꺼내기 검사가 `≥`다.

## 원본과 다른 점

옮긴 판은 C의 `low`/`rep` 합집합을 *책*이 정한 부호화(한 필드 안의 `SENT +
v′`)로 바꾼다. 그래야 mem 수가 맞고, 원본의 포인터 주소 검사 `exit(-666)`도 지울
수 있다.

## 검증

C 원본과 출력과 mems가 바이트까지 같다.

- SGB의 로제 그래프(꼭짓점 1022개, 성분 77개)와 무작위 방향 그래프 1615개에서
  맞춰 보았다.
- 증서는 다시 1500개에서 뜻이 맞는지 따로 검사했다.

## 빌드

저장소 루트에서 부른다. 규칙은 [../Makefile](../Makefile)에 있다.

```sh
make tarjan-strong  # tarjan-strong/tarjan-strong.go + tarjan-strong/tarjan-strong.pdf
make clean          # 모든 예제의 생성물 삭제
```
