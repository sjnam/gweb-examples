# GWEB examples

* [examples/wc.w](wc.w) — a literate word-count program; its tangled
  output matches the system `wc`. It also shows `@f` setting a user type in bold.
* [examples/pmap.w](pmap.w) — a generic concurrent `map` over a slice,
  exercising generics, goroutines, channels, and `sync.WaitGroup`.
* [examples/seq.w](seq.w) — a tiny lazy-sequence library (`Map`,
  `Filter`, `Take` over infinite Fibonacci numbers), showing off the Go features
  C has no answer to: first-class functions and closures, anonymous functions,
  generics, and Go 1.23 range-over-func iterators.
* [examples/pipeline.w](pipeline.w) — a tutorial that bridges Go's two
  pipeline worlds: lazy `iter.Seq` transforms and a fan-out of channel workers,
  joined by two boundary adapters, with first-error cancellation flowing across
  both. Uses range-over-func and a pocket `errgroup`.
* [examples/hangul.w](hangul.w) — a short Fibonacci program written in
  Korean, demonstrating `\input kotexgweb.tex`. Typeset it with **luatex**:
  `make -C examples NAME=hangul TEXENGINE=luatex` (or `make example`).
* [examples/slidingmax.w](slidingmax.w) — LeetCode's *Sliding Window
  Maximum*, solved in O(n) with a **monotonic deque**. A Korean literate essay
  (typeset with **luatex**, like `hangul.w`).
* [examples/waiter.w](waiter.w) — HackerRank's *Waiter*: a stack
  simulation that splits plates by successive primes. A Korean literate essay
  (typeset with **luatex**).
* [examples/trucktour.w](trucktour.w) — HackerRank's *Truck Tour* (the
  circular gas-station problem), solved in O(n) by a greedy single pass; the
  essay explains *why* one pass suffices. Korean (typeset with **luatex**).
* [examples/poison.w](poison.w) — HackerRank's *Poisonous Plants*:
  how many days until no plant dies, in O(n) with an increasing stack that gives
  each plant its day of death. Korean (typeset with **luatex**).
* [examples/runningmedian.w](runningmedian.w) — HackerRank's *Find the
  Running Median*: the median of a growing stream, kept in O(log n) per value
  with two heaps (a max-heap and a min-heap). Korean (typeset with **luatex**).
* [examples/convmod.w](convmod.w) — Library Checker's *Convolution
  (mod 998244353)*: polynomial multiplication in O(n log n) via the **number
  theoretic transform** (NTT). Korean (typeset with **luatex**).
* [examples/intersect.w](intersect.w) — Codeforces 1093E *Intersection
  of Permutations*: each value becomes a 2-D point, reducing the queries to
  rectangle counting with point updates — a **Fenwick tree of Fenwick trees**
  with offline coordinate compression. Korean (typeset with **luatex**).
* [examples/suffixautomaton.w](suffixautomaton.w) — an exposition of the
  **suffix automaton** (after cp-algorithms): the online O(n) construction with
  suffix links and the clone/split step, applied to counting distinct
  substrings. Korean (typeset with **luatex**).
* [examples/pqundo.w](pqundo.w) — the **priority-queue undo trick**:
  a rollback DSU extended to delete the max-priority element from the middle of
  its update stack in amortized O(log²n), applied to Codeforces 603E. Korean
  (typeset with **luatex**).
* [examples/squint.w](squint.w) — lazy power series as demand-driven
  channel networks (sum, product, composition, reciprocal, functional inverse,
  and differential equations like `exp`), after McIlroy's *Squinting at Power
  Series*.
* [examples/fast_cancel.w](fast_cancel.w) — It shows a complementary pattern
  useful in any concurrent Go program: how to propagate a first-error signal to all
  sibling goroutines cleanly.
* [examples/sham.w](sham.w) — a GWEB port of Knuth's Stanford GraphBase
  demo `sham`: count the symmetric Hamiltonian cycles of the knight's graph on an
  8×9 board, by folding the graph in half and backtracking with `goto` labels. It
  builds on [go-sgb](https://github.com/sjnam/go-sgb), a Go port of the SGB, so
  running it needs that module (`go get github.com/sjnam/go-sgb`); the commentary
  is newly written. Shows GWEB handling an external dependency and a real Knuth
  program.
* [examples/topswops.w](topswops.w) — Conway's *topswops* game, solved
  by A. Pepperdine's backward search (run the game in reverse from its ending
  state). An essay-style port of Knuth's CWEB `topswops.w`.
* [examples/topswops_fwd.w](topswops_fwd.w) — the same game solved
  *forwards*: a branch-and-bound search with placeholder cards and an `f(m)`
  pruning bound, written as a `goto` state machine. A port of Knuth's CWEB
  `topswops-fwd.w`.
* [examples/floyd.w](floyd.w) — Floyd's partition problem, the classic
  "toy problem" Knuth discusses in *Are Toy Problems Useful?*: partition
  √1…√50 into two nearly-equal halves. A worked literate solution
  (meet-in-the-middle search, Gray-code enumeration, compensated summation, and
  a `math/big` verification).
* [examples/pairsums.w](pairsums.w) — HackerRank's *Pair Sums*: the
  largest pair-product sum over all subarrays. The identity value = (S²−Q)/2
  and a prefix-sum twist turn it into the upper envelope of a family of lines,
  solved with a **Li Chao tree** in O(n log n).
* [examples/prjeuler152.w](prjeuler152.w) — Project Euler Problem 152,
  The key challenge—and the appeal—is that you cannot compare the sums using
  floating-point arithmetic. When adding the $1/n^2$ terms, precise rational
  number operations are required, and a brute-force approach that simply cycles
  through all $2^{79}$ subsets is impossible.
