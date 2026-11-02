# nqueens-somers

[nqueens-somers.w](nqueens-somers.w) — N 여왕 문제의 해를 세는 **제프 소머즈의
기법**(2002)을 옮기면서 하나하나 풀어 설명한다. 판의 한 줄을 N비트 정수로
나타내고, 대각선의 위협을 줄마다 한 칸씩 밀어 비트 자리가 곧 막힌 칸이 되게
하고, 놓아 볼 칸을 `-x & x`로 뽑고, 거울 대칭으로 일을 절반으로 줄이되 홀수
판의 가운데 칸은 따로 다루고, 재귀 대신 명시적 스택을 쓴다. MetaPost 그림 셋.
원본 `nq.c`와 N=18까지 해의 수가 같고, `-p`로 찍는 판은 원본과 바이트까지
같다. 원본을 그대로 옮기면 Go에서 30% 느린데, 방금 배열에 적은 값을 도로
읽는 한 곳이 원인이라 고쳤다. 그러고 나면 명시적 스택과 재귀가 거의 비긴다.
짝이 되는 변경 파일 [nqueens-somers-par.ch](nqueens-somers-par.ch)(`gtangle
nqueens-somers.w nqueens-somers-par.ch`)는 첫 두 줄의 여왕 짝을 작업으로 삼아
고루틴들에 나눠 준다. 결정적인 반복문은 한 글자도 바꾸지 않고, 코어 10개에서
N=18이 186초에서 27초로 준다.

## 빌드

```sh
make                     # nqueens-somers.w -> nqueens-somers.go + nqueens-somers.pdf
make nqueens-somers-par  # nqueens-somers.w + nqueens-somers-par.ch -> nqueens-somers-par/nqueens-somers.go + nqueens-somers-par/nqueens-somers.pdf
make clean               # 생성물 삭제
```

규칙은 [../gweb.mk](../gweb.mk)에 있다.
