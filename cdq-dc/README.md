# CDQ 분할정복

CDQ 분할정복(CDQ divide and conquer)을 정석 문제들로 설명하고 푸는
[GWEB](https://github.com/sjnam/gweb) 문학적 프로그램 모음이다. 각 문제가
`.w` 파일 하나이고, 거기서 Go 프로그램과 한글 문서(PDF)가 함께 나온다.

| 디렉터리 | 문서 | 문제 |
| --- | --- | --- |
| `flower/` | «맥상화개» | [Luogu P3810](https://www.luogu.com.cn/problem/P3810) 3차원 편서 — 기법의 일반론 |
| `inv/` | «쾌도참난마» | [Luogu P3157](https://www.luogu.com.cn/problem/P3157) 동적 역순쌍 — 시간을 축으로 승격 |
| `stars/` | «창백한 푸른 점» | [POJ 2352](http://poj.org/problem?id=2352) 별의 등급 — 2차원, 사다리의 밑단 |
| `robin/` | «셔우드의 장부» | [LightOJ 1112](https://lightoj.com/problem/curious-robin-hood) 자루 합 질의 — 번외편, 펜윅 트리의 단독 무대 |

[«맥상화개»](flower/flower.w)는 기법 자체를 다룬다 — 일반적인 분할정복과 무엇이
다른가(문제가 아니라 *쌍의 집합*을 쪼갠다), 어떤 문제에 잘 듣는가(기여가
합으로 쌓이는 오프라인 문제), 복잡도(시간 O(n log n log k), 공간 O(n + k)),
왜 우아한가(축마다 무기 하나씩: 정렬·분할정복·펜윅 트리), 단점은
무엇인가(오프라인 전용, 로그 두 개).

[«쾌도참난마»](inv/inv.w)는 그 틀의 응용이다 — 원소가 하나씩 뽑히는
수열의 역순쌍 세기를 (시간, 위치, 값)의 3차원 편서로 번역하면, 첫째 축의
정렬이 공짜가 되고 기여의 방향이 뒤집히는 것 말고는 같은 코드가 된다.

[«창백한 푸른 점»](stars/stars.w)은 사다리를 한 칸 내려간다 — 두 축뿐인
별의 등급 세기에서는 정렬을 입력이 대신해 주고 펜윅 트리마저 필요 없어,
병합정렬 하나로 끝나는 기법의 가장 순수한 밑단이 드러난다.

[«셔우드의 장부»](robin/robin.w)는 번외편이다 — 세 문서 내내 셋째 축을
조용히 떠맡던 펜윅 트리를 주연으로 세워, 그 여덟 줄이 왜 도는지를 책임
구간 그림과 함께 설명한다. 축이 하나뿐이라 정렬도 분할정복도 없는 사다리의
맨 아래 칸이자, 온라인 질의 앞에서 CDQ가 자리를 비켜 줄 때 남아서 일하는
도구의 이야기다.

## 파일

저장소에 두는 것은 원본뿐이다 — `.w` (그림은 그 안에 들어 있다). Go 소스(`*.go`)도
조판된 문서(`*.pdf`)도 `.w`에서 `make`가 그때그때 뽑는 생성물이라 저장소에
없다. 위의 문서 링크가 `.pdf`가 아니라 `.w`를 가리키는 것은 그 때문이다.
고칠 것이 있으면 언제나 `.w`를 고친다.

## 빌드

[GWEB](https://github.com/sjnam/gweb)(`gtangle`, `gweave`)과 TeX Live
(luatex, ko.TeX, MetaPost), Go가 필요하다. 프로그램만 돌릴 거라면
`gtangle`과 Go만 있으면 된다(`make tangle` 후 `go run`).

```sh
make            # tangle + 문서 조판
make clean      # 생성물 삭제
go run ./flower < in   # P3810을 풀어 본다
go run ./inv < in      # P3157을 풀어 본다
go run ./stars < in    # POJ 2352를 풀어 본다
go run ./robin < in    # LightOJ 1112를 풀어 본다
```

## 예

```sh
$ printf '5 4
1 5 3 4 2
5 1 4 2
' | go run ./inv
5
2
2
1
```

모든 프로그램이 최대 크기 입력을 1초 안에 너끈히 푼다.
