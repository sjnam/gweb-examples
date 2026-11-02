# commafree-eastman

이스트먼의 1965년 알고리즘을 반복문으로 쓴 것이다. 길이가 홀수이고 제 순환 이동
가운데 어느 것과도 같지 않은 수열이 주어지면, 고른 이동들이 쉼표 없는 부호를
이루도록 이동 하나를 고른다. 골롬과 고든과 웰치의 추측을 매듭지은 구성이다.

- 문서: [commafree-eastman.w](commafree-eastman.w)
- 바탕: 커누스의 CWEB 프로그램
- 그림: MetaPost 그림 하나

## 방법

낱말은 경계 표시로 부분 낱말로 잘린다. 단계마다 이웃한 *분지*(네바다에서 온
용어는 커누스의 것이다) 사이의 길이가 홀수인 *구간*마다 표시를 딱 하나만 남긴다.
그래서 ⌊log₃ n⌋ 단계면 넉넉하다.

## 검증

CWEB 원본과 26830번의 실행에서 맞춰 보았다.

- 두세 글자 알파벳 위의 길이 3, 5, 7, 9인 수열 모두
- 길이 105까지의 무작위 수열 4000개

일부러 다르게 한 것이 하나 있다. 함수 `strconv.Atoi`는 `sscanf("%d")`가 조용히
받아들이던 뒤쪽 쓰레기를 거절한다.

## 빌드

저장소 루트에서 부른다. 규칙은 [../Makefile](../Makefile)에 있다.

```sh
make commafree-eastman  # commafree-eastman/commafree-eastman.go + commafree-eastman/commafree-eastman.pdf
make clean              # 모든 예제의 생성물 삭제
```
