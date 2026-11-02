# wordcube

스탠퍼드 그래프베이스의 다섯 글자 낱말 5757개로 **대칭 5×5×5 낱말 정육면체**를
몇 개나 지을 수 있는가? 완전히 대칭인 정육면체는 세 축 어느 쪽으로 읽어도 같은
낱말이 나온다.

답은 83,576개다(열다섯 낱말이 모두 달라야 하면 75,130개).

- 문서: [wordcube.w](wordcube.w), 한글 문학적 에세이
- 자료: [sgb-words.txt](sgb-words.txt)(명령줄 인자로 다른 낱말 파일을 줄 수
  있다)
- 그림: MetaPost 그림

## 방법

- 말끔한 백트래킹이 열다섯 줄을 행 우선으로 채운다. 새 낱말마다 이미 놓인 글자가
  접두사를 이루니, 나머지는 사전 찾기가 해 준다.
- 기본 프로그램은 *배제*(전방 검사)를 더한다. 낱말을 놓을 때마다 아직 채우지
  않은 줄이 사전으로 채워질 수 있는지 확인해, 탐색 마디를 46억 개에서 9800만
  개로 쳐 낸다(차례로 돌려 1분 30초쯤).

## 변경 파일

[wordcube-par.ch](wordcube-par.ch)는 고루틴으로 병렬 빌드를 갈라 낸다. 첫 낱말의
서로 독립인 선택이 일꾼들로 퍼져 나가, 코어 10개에서 13초쯤에 같은 답을 준다.

## 빌드

저장소 루트에서 부른다. 규칙은 [../Makefile](../Makefile)에 있다.

```sh
make wordcube      # wordcube/wordcube.go + wordcube/wordcube.pdf
make wordcube-par  # wordcube-par.ch 판 -> wordcube/wordcube-par/
make clean         # 모든 예제의 생성물 삭제
```
