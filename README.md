# GWEB examples

## Building

A [Makefile](Makefile) builds any example by its name (the `.w` basename):

```sh
make ziptree   # ziptree.w -> ziptree.go (+ any @( ) files) + ziptree.pdf
make           # show usage
make clean     # remove all generated files, keeping the .w/.ch sources
```

Build one example at a time (there is no `make all`): nearly every tangled
`.go` is a `package main` with its own `main()`, so emitting them into one
directory at once would make Go refuse to compile (`main` redeclared).

The TeX engine is chosen automatically — **luatex** for Korean documents (those
with `\input kotexgweb.tex`, see below), **pdftex** otherwise.

* [fast_cancel.w](fast_cancel.w) — It shows a complementary pattern
  useful in any concurrent Go program: how to propagate a first-error signal to all
  sibling goroutines cleanly.
* [floyd.w](floyd.w) — Floyd's partition problem, the classic
  "toy problem" Knuth discusses in *Are Toy Problems Useful?*: partition
  √1…√50 into two nearly-equal halves. A worked literate solution
  (meet-in-the-middle search, Gray-code enumeration, compensated summation, and
  a `math/big` verification).
* [intersect.w](intersect.w) — Codeforces 1093E *Intersection
  of Permutations*: each value becomes a 2-D point, reducing the queries to
  rectangle counting with point updates — a **Fenwick tree of Fenwick trees**
  with offline coordinate compression. Korean (typeset with **luatex**).
* [ntt.w](ntt.w) — a friendly guide to the **fast Fourier
  transform** and its integer cousin, the **number theoretic transform**: the
  evaluate–multiply–interpolate detour, why squaring folds the roots of unity
  so the problem halves, bit reversal and the butterfly network, the inverse
  transform, what NTT actually needs from a ring (and why
  998244353 = 119·2²³+1), and the surprising history from Gauss (1805) to
  Harvey–van der Hoeven (2021). Three MetaPost figures. The working program it
  builds toward solves Library Checker's *Convolution (mod 998244353)* —
  polynomial multiplication in O(n log n). Korean (**luatex**).
* [pairsums.w](pairsums.w) — HackerRank's *Pair Sums*: the
  largest pair-product sum over all subarrays. The identity value = (S²−Q)/2
  and a prefix-sum twist turn it into the upper envelope of a family of lines,
  solved with a **Li Chao tree** in O(n log n).
* [perm.w](perm.w) — **Floyd's random-sampling algorithm**
  (from Bentley's *More Programming Pearls*): draw M distinct integers from
  1…N uniformly in O(M), every subset equally likely, without the collision
  retries of the naive approach. A Korean literate essay building a small
  `perm` library (plus a channel-based generator) with an extensive
  `@(perm_test.go@>` suite — properties, reproducibility, distribution, and
  benchmarks. Typeset with **luatex**.
* [pipeline.w](pipeline.w) — a tutorial that bridges Go's two
  pipeline worlds: lazy `iter.Seq` transforms and a fan-out of channel workers,
  joined by two boundary adapters, with first-error cancellation flowing across
  both. Uses range-over-func and a pocket `errgroup`.
* [pmap.w](pmap.w) — a generic concurrent `map` over a slice,
  exercising generics, goroutines, channels, and `sync.WaitGroup`.
* [poison.w](poison.w) — HackerRank's *Poisonous Plants*:
  how many days until no plant dies, in O(n) with an increasing stack that gives
  each plant its day of death. Korean (typeset with **luatex**).
* [pqundo.w](pqundo.w) — the **priority-queue undo trick**:
  a rollback DSU extended to delete the max-priority element from the middle of
  its update stack in amortized O(log²n), applied to Codeforces 603E. Korean
  (typeset with **luatex**).
* [prjeuler152.w](prjeuler152.w) — Project Euler Problem 152,
  The key challenge—and the appeal—is that you cannot compare the sums using
  floating-point arithmetic. When adding the $1/n^2$ terms, precise rational
  number operations are required, and a brute-force approach that simply cycles
  through all $2^{79}$ subsets is impossible.
* [runningmedian.w](runningmedian.w) — HackerRank's *Find the
  Running Median*: the median of a growing stream, kept in O(log n) per value
  with two heaps (a max-heap and a min-heap). Korean (typeset with **luatex**).
* [seq.w](seq.w) — a tiny lazy-sequence library (`Map`,
  `Filter`, `Take` over infinite Fibonacci numbers), showing off the Go features
  C has no answer to: first-class functions and closures, anonymous functions,
  generics, and Go 1.23 range-over-func iterators.
* [sham.w](sham.w) — a GWEB port of Knuth's Stanford GraphBase
  demo `sham`: count the symmetric Hamiltonian cycles of the knight's graph on an
  8×9 board, by folding the graph in half and backtracking with `goto` labels. It
  builds on [go-sgb](https://github.com/sjnam/go-sgb), a Go port of the SGB, so
  running it needs that module (`go get github.com/sjnam/go-sgb`); the commentary
  is newly written. Shows GWEB handling an external dependency and a real Knuth
  program.
* [slidingmax.w](slidingmax.w) — LeetCode's *Sliding Window
  Maximum*, solved in O(n) with a **monotonic deque**. A Korean literate essay
  (typeset with **luatex**, like `hangul.w`).
* [squint.w](squint.w) — lazy power series as demand-driven
  channel networks (sum, product, composition, reciprocal, functional inverse,
  and differential equations like `exp`), after McIlroy's *Squinting at Power
  Series*.
* [suffixautomaton.w](suffixautomaton.w) — an exposition of the
  **suffix automaton** (after cp-algorithms): the online O(n) construction with
  suffix links and the clone/split step, applied to counting distinct
  substrings. Korean (typeset with **luatex**).
* [topswops.w](topswops.w) — Conway's *topswops* game, solved
  by A. Pepperdine's backward search (run the game in reverse from its ending
  state). A Korean literate essay retelling of Knuth's CWEB `topswops.w`, with
  MetaPost figures (a sample game, and the complete backward search tree for
  n=3) and a proof of Conway's halting argument. Typeset with **luatex**.
* [topswops_fwd.w](topswops_fwd.w) — the same game solved
  *forwards*: a branch-and-bound search with placeholder cards and an `f(m)`
  pruning bound, written as a `goto` state machine. A Korean literate essay
  retelling of Knuth's CWEB `topswops-fwd.w`, with MetaPost figures (the
  five-label state machine, and the pruning bound). Typeset with **luatex**.
* [trucktour.w](trucktour.w) — HackerRank's *Truck Tour* (the
  circular gas-station problem), solved in O(n) by a greedy single pass; the
  essay explains *why* one pass suffices. Korean (typeset with **luatex**).
* [waiter.w](waiter.w) — HackerRank's *Waiter*: a stack
  simulation that splits plates by successive primes. A Korean literate essay
  (typeset with **luatex**).
* [wc.w](wc.w) — a literate word-count program; its tangled
  output matches the system `wc`. It also shows `@f` setting a user type in bold.
* [ziptree.w](ziptree.w) — the **zip tree** of Tarjan, Levy,
  and Timmel: a randomized BST that is max-heap-ordered by a geometric random
  *rank* (ties favoring the smaller key), updated by *unzipping* and *zipping*
  search paths instead of rotations. Implements the paper's recursive insert,
  zip, and delete as a library, then derives two memory-savers: an *arena*
  (index-based, byte rank, free list) that halves node size and cuts a
  million-node build from ~1M allocations to ~40, and a *pseudo-random rank*
  variant that drops the rank field entirely (computing it from the key). The
  `@(zip_test.go@>` test file (run with `go test`) reproduces the paper's
  Figure 1 exactly, cross-checks all three representations, fuzz-checks the
  BST/heap invariants, and benchmarks allocations. Korean (typeset with
  **luatex**).

### Korean (and other non-English) documentation

The woven output can be written in Korean by processing it with **`luatex`**
(not `pdftex`) and putting one line in the `.w` file's limbo:

```tex
\input kotexgweb
```

[tex/kotexgweb.tex](tex/kotexgweb.tex) loads [luatexko](https://ctan.org/pkg/luatexko)
and selects the Noto Serif/Sans CJK KR fonts (edit the `\sethangulfont` lines to
change typefaces), translates gweave's fixed wording into Korean, and supplies a
LuaTeX PDF back end so that blue cross-reference links and the PDF outline
(bookmark) pane work, with Korean bookmark titles. Then:

```sh
gweave foo.w           # -> foo.tex
luatex foo.tex         # -> foo.pdf   (kotexgweb.tex on TEXINPUTS)
```

gweave needs no flag; all the human-readable text it emits goes through macros
(`\GU`, `\GNused`, `\Gsectionword`, …) that `kotexgweb.tex` overrides, so the same
mechanism localizes to any language — write your own `\input` file modelled on it.
