# GWEB examples

[GWEB](https://github.com/sjnam/gweb) is a literate programming system for Go,
modeled closely on Knuth and Levy's **CWEB**. You write one `.w` file that
interleaves TeX prose with Go code, and two tools read it in opposite
directions: `gtangle` extracts the compilable `.go` for the machine, `gweave`
typesets a cross-referenced document for people. The program and the essay
explaining it are not two artifacts kept in sync — they are one file.

This repository collects programs written that way. The range is deliberate:
tutorials on what Go itself can do (range-over-func iterators, channel
pipelines, generics), expositions of algorithms worth understanding (zip trees,
suffix automata, the FFT), contest problems from HackerRank, Codeforces,
LeetCode, Library Checker and Project Euler, and ports of Knuth's own CWEB
programs. Most of the recent ones are written as Korean essays.

They are here to show what GWEB looks like when actually used — and, one hopes,
to be worth reading on their own. Start with the PDF a `.w` weaves into; that is
the side meant for human eyes.

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

Figures need no build step of their own. Every illustrated document here is a
Korean one, hence typeset with luatex, so **luamplib** runs MetaPost inline
while the document is being typeset — no `mpost` pass, no intermediate PDFs,
and figure labels are set in the document's own fonts. A document with a single
figure carries the MetaPost right inside its `.w`; one with several keeps them
in `<name>.mp` as named macros (`fig_...`) and pulls them in with
`\everymplib{input <name>;}`, calling each by name where it belongs.

Only sources are tracked: the `.w`/`.ch` programs and the MetaPost figure
libraries (`*.mp`). Every `.go` and every PDF here is generated, so you will
not find one until you build it.

The entries below that name a directory rather than a `.w` are separate
projects, each with its own `README.md`, `Makefile` and `go.mod`. This Makefile
does not reach into them — build those from inside (`cd life-game && make`).

* [back-20q.w](back-20q.w) — Knuth's **back-20q**, which solves Don Woods's
  *Twenty Questions*: a twenty-item multiple-choice quiz whose every question
  talks about the answer sheet it is printed on ("the first question whose
  answer is A is…", "the maximum score that can be achieved on this test is…").
  A backtrack over five-bit candidate sets, splitting each question into the
  part that can be decided on the spot and the part that must wait until all
  twenty letters are known, with one forced letter cascading down the row of
  neighbours. The document quotes all twenty questions (try it yourself before
  reading on) and then turns each into code, one section apiece. Two errors in
  the published CWEB are found and fixed along the way — an unreachable line
  that made question 18 impossible to get wrong, and an inverted test that let
  question 15 be marked wrong while it was in fact right — costing the original
  14 valid answer sheets and gaining it 5 invalid ones, though the puzzle's own
  answer survives untouched: the best possible score is 19, and exactly one
  sheet reaches it with question 20 answered correctly. Verified against the
  corrected original on all 211 falsity patterns, against an independent
  re-grader written from the English text, and against a dozen different search
  orderings. Knuth's two change files come along as GWEB change files
  ([back-20q-backmod9,15.ch](back-20q-backmod9,15.ch),
  [back-20q-backmod9,15-indet.ch](back-20q-backmod9,15-indet.ch)), each
  reworking a couple of the questions and reporting its own answer — and the
  first of them shows where the question-15 bug most likely came from, since
  under its wording the five options line up and the offending case disappears.
  Apply them the CWEB way: `gtangle back-20q.w back-20q-backmod9,15.ch`.
  Korean (typeset with **luatex**), three MetaPost figures.
* [back-pdi.w](back-pdi.w) — Knuth's **back-pdi**: find every
  *perfect digital invariant* of order m — an integer equal to the sum of the
  m-th powers of its own digits, like 153 = 1³ + 5³ + 3³. A backtrack that picks
  the digits in nonincreasing order and prunes hard with sharp lower/upper
  bounds, over a binary-coded-decimal bignum that needs only addition (the
  +6 / −6 carry trick, with a worked figure). A Go/GWEB port of Knuth's CWEB
  program; its node counts match the original exactly. Korean (typeset with
  **luatex**), one MetaPost figure.
* [dragon-calc.w](dragon-calc.w) — Knuth's **dragon-calc**: an interactive
  calculator for Dekking's generalized dragon curves and the calculus of tiles
  from his *diamonds and dragons* notes. Fold sequences of `D`s and `U`s, the
  folding product that doubles (or quintuples) a curve, tiles as Gaussian
  integers with odd coordinate sum, congruence classes mod (2+2i)z via a
  Hermite-normal-form basis found by Euclid on imaginary parts, factoring tiles
  over plane-filling paths, and MetaPost output. A Go/GWEB port of Knuth's 2010
  CWEB program whose answers match the original line for line; the `goto` web
  became a labeled loop, the 134 MB static table became an exact allocation, and
  a divide-by-zero on closed paths is now caught. Korean (typeset with
  **luatex**), two MetaPost figures.
* [enigmatic-puzzle.w](enigmatic-puzzle.w) — Knuth's **enigmatic-puzzle**,
  which breaks the 125-character Enigma message posed in TAOCP 7.2.2.8. Given
  nothing but the ciphertext and one crib word (`ENIGMATICALLY`), it recovers the
  rotor choice and order, the ring settings, the start position, the plugboard,
  and the plaintext. Five of Knuth's programs are fused into one pipeline here, so
  the document runs through all of them: the **machine** itself (three rotors from
  five, reflector B, the double-stepping quirk, and the fatal flaw that no letter
  ever enciphers to itself — which kills 50 of the 113 crib positions in a single
  line); the **delta tree**, which sidesteps the unknown ring settings by tracking
  only how far each rotor has turned, and has exactly 2k+1 nodes on level k; the
  **bombe**, a union-find over the 351 unordered letter pairs, where taking the
  pairs unordered *is* Welchman's diagonal board; the improved filter that merges
  all forced classes into one giant class; a stripped-down watched-literal SAT
  solver that enumerates every plugboard consistent with the surviving classes;
  the arithmetic that turns a delta path back into start positions and ring
  settings; and finally five-gram statistics to pick the one candidate out of
  3,331,188 that is actually English. It is, and it comes from a 1653 book on
  alchemy. Verified line-for-line against Knuth's C original over the full
  million-configuration sweep. Three latent buffer problems in the original are
  fixed and explained: `move[64]` is indexed up to the variable count, which Knuth
  himself notes can exceed 64 — and the full run proves it does, reporting
  `max vars 79`; `plugs[…][26]` has no room for the sentinel when a
  plugboard has no plugs at all; and an at-least-one clause with no literals reads
  an unwritten cell. Woven with the history — Scherbius, Rejewski and the Polish
  bomba, Pyry, Turing, Welchman. Korean (typeset with **luatex**), two MetaPost
  figures. Needs Knuth's `VOL1TEXT` (a 900 KB file on his site) for the five-gram
  counts, and about two hours to run.
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
* [koda-ruskey.w](koda-ruskey.w) — Knuth's **koda-ruskey**: generate every
  *ideal of a forest poset* — all bitstrings in which a bit may be 1 only if
  its parent's is — as a generalized reflected Gray code, one bit changing per
  step. Two implementations of the same sequence, side by side: one coroutine
  per node, and a loopless one whose every step is a bounded number of
  operations on a four-link *fringe*. Where the CWEB original hand-simulates
  coroutines with a ten-state `switch`, this port writes them out as goroutines
  rendezvousing on unbuffered channels, so the six-line coroutine body survives
  intact. Korean (typeset with **luatex**), three MetaPost figures.
* [li-ruskey.w](li-ruskey.w) — Knuth's **li-ruskey**, the sequel to
  `koda-ruskey`: the constraints now carry *directions*, so instead of a forest
  poset the input is any totally acyclic digraph, and the job is to list every
  0/1 labeling respecting `x → y ⟹ bit x ≤ bit y` as a Gray path whose root bit
  flips exactly once. Near-positive and near-negative vertex sets, the
  mixed-radix reflected code that splices two half-paths into one, entourages
  and transition strings, and a fringe that stays loopless by leaving *stale*
  links behind a travelling flag. Knuth left the coroutine version as an
  exercise, noting that its parent pointers would have to be dynamic; this port
  does that exercise with goroutines, where the difficulty evaporates (the call
  stack *is* the parent pointer) and each coroutine picks its entry point by
  reading its own bit as it first wakes. Both implementations run in one
  program and agree line for line with the CWEB original, `-v` output included.
  Korean (typeset with **luatex**), four MetaPost figures.
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
* [spiders.w](spiders.w) — Knuth's **spiders**, which closes the trilogy and
  makes `koda-ruskey` and `li-ruskey` obsolete: the same problem — list every
  0/1 labeling of a totally acyclic digraph respecting `x → y ⟹ bit x ≤ bit y`
  as a Gray path whose root bit flips once — solved from a different direction.
  The near-sets `U_k`/`V_k` carried implicitly on *progenitor* chains so the
  whole O(n²) worth of sets fits in linear time and space; the parity of the
  reflected code read off a single `ueven`/`veven` table instead of n-bit
  arithmetic; and an *active list* of alternately awake and asleep nodes whose
  blocks enter and leave behind delayed flags, giving a genuinely loopless
  generator. Knuth's original recurrence for the insertion point was wrong for
  twenty-five years — a five-vertex spider breaks it — and this document walks
  through the failure and the fix (which Knuth adopted in June 2026 and
  credited to this repository's author) with a figure. Verified against the
  CWEB original on all 10,067 connected spiders of ≤ 7 vertices, `-v` output
  included. Korean (typeset with **luatex**), four MetaPost figures.
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
* [word-cube-dlx.w](word-cube-dlx.w) — the same symmetric word cubes as
  `wordcube.w`, but handed to somebody else: this one **translates the whole
  problem into a single exact-cover (XCC) instance** and writes it out as a DLX
  file, in the manner of Knuth's
  [word-rect-dlx.w](https://www-cs-faculty.stanford.edu/~knuth/programs/word-rect-dlx.w)
  ("supposed to compete with BACK-MXN-WORDS-NEW"). The translation is startlingly
  small — 15 primary items (the lines `i <= j`), 35 secondary items (the cells,
  named by their sorted index triple), and one option per line-and-word, its five
  colored items saying which letter goes where. Sorting the name is the whole
  symmetry mechanism; not one line of code checks it. A bonus falls out for free:
  an uncolored secondary item per word turns "all fifteen words distinct" into an
  extra flag (`-d`) rather than extra code. Verified against `wordcube` on
  truncated dictionaries (3 = 3 at 3000 words, 83 = 83 at 3500, 60 = 60 with `-d`),
  each emitted solution rebuilt into a 5×5×5 array and re-checked along all three
  axes, and the full list run to the end for the same 83,576. The closing chapter
  runs the match: dancing cells prunes the *better* tree — 57.1M nodes against
  98.0M — yet loses on the clock, because a cell item sits in 3·|W| options, so one
  coloring walks thousands of them where the backtrack does one binary search. The
  gap does narrow with scale, as covered items shorten the lists (92× at 2000 words,
  39× at 3500, 16× on the full list: 26m36s against 1m41s). Korean (typeset with
  **luatex**), with one inline MetaPost figure and one borrowed from `wordcube.mp`.
* [wordcube.w](wordcube.w) — how many **symmetric 5×5×5 word
  cubes** can be built from the Stanford GraphBase's 5757 five-letter words? A
  fully symmetric cube reads the same word along any of its three axes; a clean
  backtrack fills the fifteen lines in row-major order, where each new word's
  already-placed letters form a prefix and dictionary lookup does the rest. The
  answer is 83,576 (75,130 if all fifteen words must differ). The base program adds
  *preclusion* (forward-checking): after each word is placed it verifies every
  not-yet-filled line can still be completed from the dictionary, pruning the tree
  from 4.6B search nodes to 98M (~1½ min sequentially). A Korean literate essay
  (typeset with **luatex**), with a MetaPost figure. A companion change file
  `wordcube-par.ch` (`gtangle wordcube.w wordcube-par.ch`) forks a goroutine-parallel
  build — the independent first-word choices fan out across workers, giving the same
  counts in ~13 s on 10 cores.
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
* [cdq-dc/](cdq-dc/) — **CDQ divide and conquer**, the offline technique that
  splits not the problem but the *set of pairs*, letting an earlier half pay its
  contribution forward to a later one. One axis per weapon: sorting, divide and
  conquer, Fenwick tree.
  * `flower/` — Luogu P3810, 3-D partial order. The technique in general: what
    it is, when it applies, O(n log n log k), and what it costs you.
  * `inv/` — Luogu P3157, dynamic inversions. Promoting *time* to an axis.
  * `stars/` — POJ 2352, star levels. Two axes only, so the input does the
    sorting and even the Fenwick tree disappears — the technique at its barest.
  * `robin/` — LightOJ 1112. An aside giving the Fenwick tree, silent third
    axis of the other three, the stage to itself.
* [cht/](cht/) — the **convex hull trick**: quadratic DP transitions reread as
  lines, and the lower envelope of those lines. A companion to `cdq-dc/`, walking
  down the same ladder as monotonicity is taken away one rung at a time.
  * `frog/` — AtCoder EDPC Z, *Frog 3*. The technique in general; both slopes
    and queries monotone, so a deque holds the hull and the whole thing is O(n).
  * `bridge/` — CEOI 2017 *Building Bridges*. Both monotonicities broken, so a
    **Li Chao tree** replaces the deque — and comparing values instead of
    intersections retires the 128-bit arithmetic.
  * `cash/` — NOI 2007 *Cash*, the problem CDQ divide and conquer was
    introduced with. The two collections meet here: recursion over time, merging
    upward in x, slopes distributed downward.
  * `segment/` — HEOI 2013 *Segment*. Forced online (coordinates arrive
    encrypted by the previous answer), which seals off CDQ and coordinate
    compression and leaves the Li Chao tree standing alone, in its home problem
    of segment insertion.
* [guitar-tuner/](guitar-tuner/) — a guitar tuner that reads the Mac's
  microphone and shows the pitch on a needle gauge in real time. Pitch detection
  is a **from-scratch implementation of the YIN algorithm** with no DSP library:
  difference function, cumulative mean normalization, absolute threshold, and
  parabolic interpolation, wrapped in high-pass pre-filtering, attack-transient
  suppression, median smoothing and octave-error correction. Audio capture uses
  [malgo](https://github.com/gen2brain/malgo) (miniaudio). Its own
  [README](guitar-tuner/README.md) has the details; unlike the two collections
  above, this one is a single program cut into three documents.
  * `pitch/` — the pure core, knowing nothing of microphones or screens: the
    detection pipeline behind `pitch.Stream`, plus open-string music theory.
  * `tuner.w` — the console frontend, a chromatic gauge drawn in the terminal.
  * `gui/` — a second frontend in a [Gio](https://gioui.org) native window,
    sharing that same core.
* [life-game/](life-game/) — Conway's **Game of Life** in the terminal, with no
  graphics library whatsoever: if a Go board was enough for Conway, ANSI escape
  codes are enough for us. The universe is a torus, so a glider walking off one
  edge returns from the other — and Gosper's gun is eventually shot down by its
  own stream. A single `.w` that is equally a program and an essay, titled after
  Laozi's *heaven and earth are not benevolent*: Conway tuning the rules with
  stones on a tea table, the $50 bet the glider gun settled, and Conway's
  late-life "I hate the Game of Life". `demos/` holds recordings made with
  [vhs](https://github.com/charmbracelet/vhs).

### Korean (and other non-English) documentation

The woven output can be written in Korean by processing it with **`luatex`**
(not `pdftex`) and putting one line in the `.w` file's limbo:

```tex
\input kotexgweb
```

`kotexgweb.tex` ships with [GWEB](https://github.com/sjnam/gweb) itself, not with
these examples; installing GWEB puts it on your `TEXINPUTS`. It loads
[luatexko](https://ctan.org/pkg/luatexko) and selects the Noto Serif/Sans CJK KR
fonts (edit the `\sethangulfont` lines to change typefaces), translates gweave's
fixed wording into Korean, and supplies a LuaTeX PDF back end so that blue
cross-reference links and the PDF outline (bookmark) pane work, with Korean
bookmark titles. Then:

```sh
gweave foo.w           # -> foo.tex
luatex foo.tex         # -> foo.pdf   (kotexgweb.tex on TEXINPUTS)
```

gweave needs no flag; all the human-readable text it emits goes through macros
(`\GU`, `\GNused`, `\Gsectionword`, …) that `kotexgweb.tex` overrides, so the same
mechanism localizes to any language — write your own `\input` file modelled on it.
