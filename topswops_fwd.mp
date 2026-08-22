% topswops_fwd.mp -- topswops_fwd.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input topswops_fwd;` 로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_states -- main 안에 든 라벨 다섯 개짜리 상태 기계
%   fig_bound  -- 분기한정 판정 c + f(m) >= r
% 라벨에 빈칸을 쓰지 않는다: mpost 기본 라벨 글꼴 cmr10 에 빈칸 글립이 없다.

input boxes

def fig_states =
beginfig(1);
  boxit.adv("advance"); boxit.tri("tryit"); boxit.don("done");
  boxit.inf("infeas");  boxit.bak("backup"); boxit.nxt("nextv");
  adv.c = (40, 85);  tri.c = (175, 85);  don.c = (310, 85);
  inf.c = (40, 15);  bak.c = (175, 15);  nxt.c = (310, 15);
  drawboxed(adv, tri, don, inf, bak, nxt);
  % advance -> tryit: fall through
  drawarrow adv.c -- tri.c cutbefore bpath.adv cutafter bpath.tri;
  % tryit -> advance: descend one level, arcing over the top
  drawarrow tri.c{dir 140} .. {dir 220}adv.c
    cutbefore bpath.tri cutafter bpath.adv;
  label.top("descend", (107, 114));
  % tryit -> infeas: candidate rejected
  drawarrow tri.c -- inf.c cutbefore bpath.tri cutafter bpath.inf;
  label.ulft("reject", (98, 52));
  % tryit -> nextv: a full deck, i.e. a leaf
  drawarrow tri.c{dir -28} .. {dir 232}nxt.c
    cutbefore bpath.tri cutafter bpath.nxt;
  label.urt("leaf", (252, 58));
  % infeas -> advance: try another slot
  drawarrow inf.c -- adv.c cutbefore bpath.inf cutafter bpath.adv;
  % infeas -> backup: fall through
  drawarrow inf.c -- bak.c cutbefore bpath.inf cutafter bpath.bak;
  % backup -> nextv: fall through
  drawarrow bak.c -- nxt.c cutbefore bpath.bak cutafter bpath.nxt;
  % nextv -> backup: candidates exhausted, arcing below
  drawarrow nxt.c{dir 235} .. (242, -14) .. {dir 125}bak.c
    cutbefore bpath.nxt cutafter bpath.bak;
  % nextv -> tryit: restore the deck, try the next candidate
  drawarrow nxt.c{dir 175} .. {dir 95}tri.c
    cutbefore bpath.nxt cutafter bpath.tri;
  label.llft("next", (212, 34));
  % nextv -> done: backed up to the root
  drawarrow nxt.c -- don.c cutbefore bpath.nxt cutafter bpath.don;
endfig;
enddef;

def fig_bound =
beginfig(2);
  numeric y; y := 20;
  % steps taken so far
  draw (0, y) -- (120, y);
  draw (0, y-3) -- (0, y+3);
  draw (120, y-3) -- (120, y+3);
  label.bot(btex$c$etex, (60, y-4));
  % the best the unknown remainder could still add
  drawarrow (120, y) -- (200, y) dashed evenly;
  label.bot(btex$f(m)$etex, (160, y-4));
  % the record to beat sits out of reach
  draw (235, y-15) -- (235, y+22) dashed evenly;
  label.top(btex$r$etex, (235, y+22));
endfig;
enddef;
