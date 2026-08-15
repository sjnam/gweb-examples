% spiders.mp -- spiders.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input spiders;` 로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_spider -- 보기로 삼는 거미 ....+-.--..+-..-+
%   fig_uv     -- 1에 가까운 양 정점 U_1과 음 정점 V_1을 얻는 법
%   fig_prev   -- U와 V를 적지 않고 prev 사슬 하나로 가지고 다니기
%   fig_bug    -- umaxscope가 한 칸 얕으면 활동 목록이 흐트러진다
%
% 정점 자리는 Knuth의 deco.5 그대로다. 거기서는 화살촉 없이 선만 긋고 "모든 변은
% 위로 향한다"고 적어 두었는데, 여기서는 화살촉을 붙였다. 그래도 화살표는 언제나
% 아래에서 위로 간다.
%
% btex 안에서는 |...| 를 쓸 수 없다(문서의 TeX이 그대로 조판해 버린다). 식별자는
% gwebmac의 \\{...} 로 적는다.

numeric u; u := 26bp;
numeric r; r := 8bp;            % 정점 동그라미의 반지름

picture nm[];
nm1 := btex $1$ etex;  nm2 := btex $2$ etex;  nm3 := btex $3$ etex;
nm4 := btex $4$ etex;  nm5 := btex $5$ etex;  nm6 := btex $6$ etex;
nm7 := btex $7$ etex;  nm8 := btex $8$ etex;  nm9 := btex $9$ etex;

pair vz[];
numeric ea[], eb[];
boolean gry[], rng[];

def clearflags(expr nv) =
  for t=1 upto nv: gry[t] := false; rng[t] := false; endfor
enddef;

def pale(expr b) =
  if b: drawoptions(withcolor .72white); else: drawoptions(); fi
enddef;

% 정점 자리 vz[] 와 변 ea[]->eb[] 가 놓여 있다고 보고 한 벌을 (dx,0)만큼 옮겨
% 그린다. gry[t]가 참이면 정점 t와 거기 닿는 변을 흐리게, rng[t]가 참이면 정점 t를
% 동그라미로 둘러싼다.
def drawG(expr nv, ne, dx) =
  for i=1 upto ne:
    pair pa, pb;
    pa := vz[ea[i]] + (dx,0);
    pb := vz[eb[i]] + (dx,0);
    pale(gry[ea[i]] or gry[eb[i]]);
    drawarrow (pa -- pb)
      cutbefore fullcircle scaled 2r shifted pa
      cutafter  fullcircle scaled 2r shifted pb;
  endfor
  drawoptions();
  for t=1 upto nv:
    pair pc; pc := vz[t] + (dx,0);
    if rng[t]: draw fullcircle scaled (2r+8bp) shifted pc; fi
    unfill fullcircle scaled 2r shifted pc;
    pale(gry[t]);
    draw fullcircle scaled 2r shifted pc;
    drawoptions();
    if gry[t]: draw thelabel(nm[t], pc) withcolor .72white;
    else: draw thelabel(nm[t], pc); fi
  endfor
enddef;

% 보기로 삼는 거미. 정점 아홉, 변 여덟.
def setupspider =
  vz1 := (3u,-u);  vz2 := (2u,0);  vz3 := (u,u);   vz4 := (0,0);
  vz5 := (3u,u);   vz6 := (4u,0);  vz7 := (5u,-u); vz8 := (2u,-2u);
  vz9 := (u,-u);
  ea1:=1; eb1:=2;  ea2:=2; eb2:=3;  ea3:=4; eb3:=3;  ea4:=2; eb4:=5;
  ea5:=1; eb5:=6;  ea6:=7; eb6:=6;  ea7:=8; eb7:=1;  ea8:=8; eb8:=9;
enddef;

def fig_spider =
beginfig(1);
  setupspider;
  clearflags(9);
  drawG(9, 8, 0);
endfig;
enddef;

def fig_uv =
beginfig(2);
  numeric dx; dx := 7.4u;
  setupspider;
  clearflags(9);
  gry[1] := true; gry[8] := true;                  % 1로 가는 것들
  rng[2] := true; rng[6] := true; rng[9] := true;
  drawG(9, 8, 0);
  label.bot(btex $1$로 가는 것을 지우면 $U_1=\{2,6,9\}$ etex,
    (2.5u, -2u-r-12bp));
  clearflags(9);
  for t=1,2,3,5,6: gry[t] := true; endfor          % 1에서 가는 것들
  rng[4] := true; rng[7] := true; rng[8] := true;
  drawG(9, 8, dx);
  label.bot(btex $1$에서 가는 것을 지우면 $V_1=\{4,7,8\}$ etex,
    (dx+2.5u, -2u-r-12bp));
endfig;
enddef;

% prev 사슬. 같은 시조를 갖는 것들이 한 줄로 꿰어 있고, U_k와 V_k는 저마다 그 줄의
% 한 토막이다. 위는 시조가 1인 양의 사슬, 아래는 시조가 0인 음의 사슬.
numeric bx[], by[];

def chainbox(expr t, xx, yy) =
  bx[t] := xx; by[t] := yy;
  draw unitsquare xscaled 24bp yscaled 18bp shifted -(12bp,9bp) shifted (xx,yy);
  draw thelabel(nm[t], (xx,yy));
enddef;

path lastarc;
def chainarrow(expr s, t) =
  lastarc := (bx[s],by[s]+11bp){up} .. {down}(bx[t],by[t]+11bp);
  drawarrow lastarc;
enddef;

% s칸부터 t칸까지 아래를 감싸는 꺾쇠. dep 만큼 아래로 내린다.
def brace(expr s, t, dep, cap) =
  draw (bx[s]-12bp, by[s]-9bp-dep+4bp) -- (bx[s]-12bp, by[s]-9bp-dep)
    -- (bx[t]+12bp, by[t]-9bp-dep) -- (bx[t]+12bp, by[t]-9bp-dep+4bp);
  label.bot(cap, (.5[bx[s],bx[t]], by[s]-9bp-dep));
enddef;

def fig_prev =
beginfig(3);
  numeric U, V; U := 52bp; V := 106bp;
  chainbox(2, 0, 0); chainbox(6, U, 0); chainbox(9, 2U, 0);
  chainarrow(9, 6);
  label.top(btex $\\{prev}$ etex, point .5 of lastarc);
  chainarrow(6, 2);
  label.lft(btex 시조 $1$: etex, (-22bp, 0));
  label.rt(btex $\leftarrow\\{umax}[1]=\\{umax}[8]=9$ etex, (2U+16bp, 0));
  brace(2, 9, 6bp, btex $U_1=\{2,6,9\}$ etex);
  brace(9, 9, 32bp, btex $U_8=\{9\}$ etex);
  chainbox(4, 0, -V); chainbox(7, U, -V); chainbox(8, 2U, -V);
  chainarrow(8, 7); chainarrow(7, 4);
  label.lft(btex 시조 $0$: etex, (-22bp, -V));
  label.rt(btex $\leftarrow\\{vmax}[1]=8$ etex, (2U+16bp, -V));
  brace(4, 8, 6bp, btex $V_1=\{4,7,8\}$ etex);
  brace(7, 7, 32bp, btex $V_6=\{7\}$ etex);
  brace(4, 4, 58bp, btex $V_2=V_3=\{4\}$ etex);
endfig;
enddef;

% 고치기 전의 버그. 다섯 정점짜리 거미 ....++-.+ 에서 bit[1]이 뒤집히는 순간.
def fig_bug =
beginfig(4);
  numeric dx, W, y; dx := 5.6u; W := 40bp; y := -u;
  vz2 := (0,0);   vz3 := (-u,-u);  vz4 := (-2u,-2u);
  vz1 := (u,-u);  vz5 := (2u,-2u);
  ea1:=1; eb1:=2;  ea2:=3; eb2:=2;  ea3:=4; eb3:=3;  ea4:=5; eb4:=1;
  clearflags(5);
  drawG(5, 4, 0);
  label.bot(btex \.{....++-.+} etex, (0, -2u-r-12bp));
  picture lb[];
  lb1 := btex $1_0$ etex;  lb2 := btex $2_1$ etex;
  lb3 := btex $3_1$ etex;  lb4 := btex $4_1$ etex;
  for t=1 upto 4:
    draw unitsquare xscaled 24bp yscaled 18bp shifted -(12bp,9bp)
      shifted (dx+(t-1)*W, y);
    draw thelabel(lb[t], (dx+(t-1)*W, y));
  endfor
  for t=1 upto 3:
    drawdblarrow (dx+(t-1)*W+13.5bp, y) -- (dx+t*W-13.5bp, y);
  endfor
  drawarrow (dx+3W+10bp, y+38bp){right} .. {down}(dx+3W+16bp, y+11bp);
  label.top(btex 여기가 옳다 etex, (dx+3W+4bp, y+38bp));
  drawarrow (dx+2.5W, y-38bp){left} .. {up}(dx+2.5W-1bp, y-11bp);
  label.bot(btex 고치기 전에는 여기에 넣었다 etex, (dx+2.5W, y-39bp));
endfig;
enddef;
