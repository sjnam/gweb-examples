% topswops.mp -- topswops.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input topswops;` 로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_forward  -- 앞으로 가는 판 3 1 2 -> 2 1 3 -> 1 2 3 (음영 = 곧 뒤집힐 뭉치)
%   fig_backtree -- $n=3$ 의 거꾸로 탐색 나무 전부
% 라벨에 빈칸을 쓰지 않는다: mpost 기본 라벨 글꼴 cmr10 에 빈칸 글립이 없다.

def fig_forward =
beginfig(1);
  numeric w, h, gap, g; w := 16; h := 20; gap := 44;
  def card(expr x, v, hot) =
    if hot:
      fill unitsquare xscaled w yscaled h shifted (x, 0)
        withcolor (1, 0.92, 0.78);
    fi
    draw unitsquare xscaled w yscaled h shifted (x, 0);
    label(v, (x + 0.5w, 0.5h));
  enddef;
  % a deck of three cards, left = top of the pile; nhot leftmost are shaded
  def deck(expr gx, a, b, c, nhot) =
    card(gx, a, nhot >= 1);
    card(gx + w, b, nhot >= 2);
    card(gx + 2w, c, nhot >= 3);
  enddef;
  g := 3w + gap;
  deck(0,  "3", "1", "2", 3);
  deck(g,  "2", "1", "3", 2);
  deck(2g, "1", "2", "3", 0);
  drawarrow (3w + 7, 0.5h) -- (3w + gap - 7, 0.5h);
  label.top("3", (3w + 0.5gap, 0.5h + 2));
  drawarrow (g + 3w + 7, 0.5h) -- (g + 3w + gap - 7, 0.5h);
  label.top("2", (g + 3w + 0.5gap, 0.5h + 2));
endfig;
enddef;

def fig_backtree =
beginfig(2);
  numeric dy, bw, bh; dy := 40; bw := 36; bh := 15;
  % a tree node: fixed-size box around three characters placed by hand,
  % so that no label string ever contains a space
  def node(expr c, a, b, d) =
    unfill unitsquare xscaled bw yscaled bh shifted (c - (0.5bw, 0.5bh));
    draw unitsquare xscaled bw yscaled bh shifted (c - (0.5bw, 0.5bh));
    label(a, c + (-11, 0));
    label(b, c);
    label(d, c + (11, 0));
  enddef;
  pair R, A, B, AA, BB;
  R  = (110, 2dy);
  A  = (45, dy);   B  = (175, dy);
  AA = (45, 0);    BB = (175, 0);
  draw R -- A;  draw R -- B;
  draw A -- AA; draw B -- BB;
  label.ulft("2", 0.5[R,A]);
  label.urt("3", 0.5[R,B]);
  label.lft("3", 0.5[A,AA]);
  label.rt("2", 0.5[B,BB]);
  node(R,  "1", ".", ".");
  node(A,  "2", "1", ".");  node(B,  "3", ".", "1");
  node(AA, "3", "1", "2");  node(BB, "2", "3", "1");
endfig;
enddef;
