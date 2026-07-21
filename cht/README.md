# 볼록 껍질 트릭

볼록 껍질 트릭(convex hull trick)을 정석 문제로 설명하고 푸는
[GWEB](https://github.com/sjnam/gweb) 문학적 프로그램 모음이다. 각 문제가
`.w` 파일 하나이고, 거기서 Go 프로그램과 한글 문서(PDF)가 함께 나온다.
[CDQ 분할정복](https://github.com/sjnam/cdq-dc) 모음(«맥상화개»·«쾌도참난마»)의 자매편이다.

| 디렉터리 | 문서 | 문제 |
| --- | --- | --- |
| `frog/` | «정저지와» | [AtCoder EDPC Z](https://atcoder.jp/contests/dp/tasks/dp_z) Frog 3 --- 기법의 일반론 |
| `bridge/` | «과하탁교» | [CEOI 2017 Building Bridges](https://www.luogu.com.cn/problem/P4655) --- 비단조 CHT, 리차오 트리 |
| `cash/` | «선견지명» | [NOI 2007 Cash](https://www.luogu.com.cn/problem/P4027) --- 동적 볼록 껍질, CDQ와의 합류 |
| `segment/` | «군웅할거» | [HEOI 2013 Segment](https://www.luogu.com.cn/problem/P4097) --- 선분 삽입, 리차오 트리의 고향 |

[«정저지와»](frog/frog.w)는 우물을 나선 개구리와 함께 기법을 처음부터
끝까지 다룬다 --- 이차식 전이가 어떻게 직선 게시로 바뀌는가, 직선들의
최솟값(아래 포락선)은 왜 볼록한가, 기울기·질의의 단조성 두 겹이 어떻게
전체를 O(n)으로 누르는가, 64비트를 넘는 교차곱은 어떻게 비교하는가
(`math/bits.Mul64`), 그리고 단조성을 하나씩 무르면 무엇이 되는가(이분 탐색,
리차오 트리, CDQ와의 재회).

[«과하탁교»](bridge/bridge.w)는 그 단조성이 둘 다 깨진 문제다 --- 다리를
놓고 안 쓴 기둥은 허문다(철거비가 음수인 기둥도 있다). 높이가 뒤죽박죽이라
덱이 무너지고 정렬도 DP 순서에 막히는 자리에, 노드마다 직선 하나씩만 맡기는
리차오 트리를 세운다. 교점을 셈하지 않고 값만 비교하므로 «정저지와»의
128비트 곡예가 통째로 사라지는 대비도 볼거리다.

[«선견지명»](cash/cash.w)에서 두 모음이 합류한다 --- 미래 시세를 다 아는
투자자의 환전 문제(천단치가 CDQ 분할정복을 알린 논문의 바로 그 문제)를,
시간은 재귀로 가르고 x는 올라오며 병합하고 기울기는 내려가며 배분하는
O(n log n) CDQ+볼록 껍질로 푼다. 튜링이 셴리 숲에 묻고 못 찾은 은괴와
크누스의 2.56달러 수표가 이 문서의 들머리와 끝을 지킨다.

[«군웅할거»](segment/segment.w)는 그 선견지명을 압수당한 문제다 --- 좌표가
직전 답으로 암호화되어 오는 강제 온라인이라 CDQ도 좌표압축도 봉인되고,
리차오 트리가 제 고향(선분 삽입)에서 홀로 선다. 영지의 정준 분해 O(log²X),
동률이면 연장자가 이기는 사전식 결투, 그리고 eps 없이 63비트에 꼭 들어차는
정확한 유리수 비교 --- 같은 기하에 산술 네 벌이 갖춰지는 마지막 조각이다.

## 파일

저장소에 두는 것은 원본뿐이다 --- `.w`와 그림(`*.mp`). `gtangle`이 뽑는
Go 소스(`*.go`)도 `gweave`와 luatex가 조판하는 문서(`*.pdf`)도 `make`가
그때그때 만드는 생성물이라 저장소에 없다. 위의 문서 링크가 `.pdf`가 아니라
`.w`를 가리키는 것은 그 때문이다. 고칠 것이 있으면 언제나 `.w`를 고친다.

## 빌드

[GWEB](https://github.com/sjnam/gweb)(`gtangle`, `gweave`)과 TeX Live
(luatex, ko.TeX, MetaPost), Go가 필요하다. 프로그램만 돌릴 거라면
`gtangle`과 Go만 있으면 된다(`make tangle` 후 `go run`).

```sh
make            # tangle + 문서 조판
make clean      # 생성물 삭제
go run ./frog < in     # EDPC Z를 풀어 본다
go run ./bridge < in   # CEOI 2017을 풀어 본다
go run ./cash < in     # NOI 2007을 풀어 본다
go run ./segment < in  # HEOI 2013을 풀어 본다
```

## 예

```sh
$ printf '5 6
1 2 3 4 5
' | go run ./frog
20
$ printf '6
3 8 7 1 6 6
0 -1 9 1 2 0
' | go run ./bridge
17
$ printf '3 100
1 1 1
1 2 2
2 2 3
' | go run ./cash
225.000
$ printf '6
1 8 5 10 8
1 6 7 2 6
0 2
0 9
1 4 7 6 7
0 5
' | go run ./segment
2
0
3
```

네 프로그램 모두 최대 크기 입력을 눈 깜짝할 새에 푼다(frog: n = 2×10⁵에
0.02초, 나머지: n = 10⁵에 0.05초 안팎) --- 단조성이 살아 있으면 선형, 깨져
있으면 로그 하나둘을 낸 값이다.
