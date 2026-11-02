# back-20q

[back-20q.w](back-20q.w) — 돈 우즈의 *스무 문제*를
푼다. 스무 개의 객관식 문항이 모두 자기가 인쇄된 답안지를 두고 하는
말이다("답이 A인 첫 문항은…", "이 시험에서 얻을 수 있는 최고 점수는…"). 다섯
비트 후보 집합 위의 백트래킹인데, 문항마다 그 자리에서 판정할 수 있는 부분과
스무 글자가 다 정해져야 알 수 있는 부분으로 갈라 두고, 강제된 글자 하나가
이웃한 문항들로 줄줄이 번져 간다. 문서는 스무 문항을 모두 인용하고(더 읽기
전에 직접 풀어 보시라) 절 하나에 문항 하나씩 코드로 옮긴다. 그 과정에서 발표된
CWEB의 잘못 둘을 찾아 고쳤다. 닿을 수 없는 줄 때문에 18번을 틀릴 수가 없었던
것과, 뒤집힌 검사 때문에 15번이 사실은 맞는데도 틀린 것으로 매겨질 수 있었던
것이다. 그 탓에 원본은 옳은 답안지 14장을 잃고 그른 답안지 5장을 얻었다. 퍼즐
자체의 답은 그대로다. 최고 점수는 19점이고, 20번을 맞히면서 그 점수에 닿는
답안지는 정확히 하나다. 고친 원본과 거짓 패턴 211가지 모두에서 맞춰 보았고,
영문 문제에서 새로 쓴 독립 채점기와도, 탐색 순서를 열두 가지로 바꾼 것과도
맞춰 보았다. 커누스의 변경 파일 둘도 GWEB 변경 파일로 함께
옮겼다([back-20q-backmod9,15.ch](back-20q-backmod9,15.ch),
[back-20q-backmod9,15-indet.ch](back-20q-backmod9,15-indet.ch)). 저마다 문항
두엇을 고쳐 쓰고 제 답을 보고하는데, 그 가운데 첫째는 15번 결함이 어디서
왔는지 짐작하게 한다. 그 문구대로라면 다섯 선택지가 가지런히 늘어서서 문제의
경우가 사라지기 때문이다. 적용은 CWEB에서 하던 대로 `gtangle back-20q.w
back-20q-backmod9,15.ch`. MetaPost 그림 셋.

## 빌드

```sh
make                             # back-20q.w -> back-20q.go + back-20q.pdf
make back-20q-backmod9,15        # back-20q.w + back-20q-backmod9,15.ch -> back-20q-backmod9_15/back-20q.go + back-20q-backmod9_15/back-20q.pdf
make back-20q-backmod9,15-indet  # back-20q.w + back-20q-backmod9,15-indet.ch -> back-20q-backmod9_15-indet/back-20q.go + back-20q-backmod9_15-indet/back-20q.pdf
make clean                       # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
