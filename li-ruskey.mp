% li-ruskey.mp -- li-ruskey.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input li-ruskey;` 로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_graph -- 보기로 삼는 다이그래프 +0+1-2+1+0-5-0+7
%   fig_ab    -- 0에 가까운 양수 정점 A와 음수 정점 B를 얻는 법
%   fig_tau   -- bit 0이 뒤집힐 때 전이 문자열이 바뀌는 모습
%   fig_stale -- 낡은 링크를 깃발로 미뤄 두었다가 하나씩 고치는 얼개
%
% 정점 자리는 Knuth의 원본 li-ruskey.mp 그대로다. 원본의 above/below 매크로가
% 하던 일을 좌표로 풀어 적었을 뿐이다. 화살표는 언제나 아래에서 위로 간다.

numeric u; u := 24bp;
numeric dotsize; dotsize := 3.5bp;

pair vz[];
vz[0] := origin;
vz[1] := vz[0] + (-u, u);
vz[2] := vz[1] + (-u, u);
vz[3] := vz[2] + (-u,-u);
vz[4] := vz[1] + ( u, u);
vz[5] := vz[0] + ( u, u);
vz[6] := vz[5] + ( u,-u);
vz[7] := vz[0] + (-u,-u);
vz[8] := vz[7] + (-u, u);

% 변 여덟 개. 화살표는 ea[i]에서 eb[i]로, 곧 아래쪽 정점에서 위쪽 정점으로.
numeric ea[], eb[];
ea1:=0; eb1:=1;  ea2:=1; eb2:=2;  ea3:=3; eb3:=2;  ea4:=1; eb4:=4;
ea5:=0; eb5:=5;  ea6:=6; eb6:=5;  ea7:=7; eb7:=0;  ea8:=7; eb8:=8;

boolean gry[], rng[];
def clearflags =
  for t=0 upto 8: gry[t] := false; rng[t] := false; endfor
enddef;

% 그래프 한 벌을 (dx,0)만큼 옮겨 그린다. gry[t]가 참이면 정점 t와 거기 닿는 변을
% 흐리게, rng[t]가 참이면 정점 t를 동그라미로 둘러싼다.
def pale(expr b) =
  if b: drawoptions(withcolor .72white); else: drawoptions(); fi
enddef;

def drawG(expr dx) =
  for i=1 upto 8:
    pair pa, pb;
    pa := vz[ea[i]] + (dx,0);
    pb := vz[eb[i]] + (dx,0);
    pale(gry[ea[i]] or gry[eb[i]]);
    drawarrow (pa -- pb)
      cutbefore fullcircle scaled 9bp shifted pa
      cutafter  fullcircle scaled 9bp shifted pb;
  endfor
  drawoptions();
  for t=0 upto 8:
    if rng[t]: draw fullcircle scaled 15bp shifted (vz[t]+(dx,0)); fi
  endfor
  for t=0 upto 8:
    pale(gry[t]);
    drawdot (vz[t]+(dx,0)) withpen pencircle scaled dotsize;
  endfor
  % 동그라미를 두른 정점은 이름표를 더 바깥으로 밀어낸다.
  numeric ex;
  for t=3,8:
    pale(gry[t]); ex := if rng[t]: 6bp else: 0 fi;
    label.lft(decimal t, vz[t]+(dx-ex,0));
  endfor
  for t=4,6:
    pale(gry[t]); ex := if rng[t]: 6bp else: 0 fi;
    label.rt(decimal t, vz[t]+(dx+ex,0));
  endfor
  pale(gry[1]); ex := if rng[1]: 8bp else: 2bp fi;
  label.lft(decimal 1, vz[1]+(dx-ex,0));
  for t=0,2,5,7:
    pale(gry[t]); ex := if rng[t]: 8bp else: 2bp fi;
    label.rt(decimal t, vz[t]+(dx+ex,0));
  endfor
  drawoptions();
enddef;

def fig_graph =
beginfig(1);
  clearflags;
  drawG(0);
endfig;
enddef;

def fig_ab =
beginfig(2);
  numeric dx; dx := 8u;
  clearflags;
  gry[0] := true; gry[7] := true;              % $x\preceq0$ 인 것들
  rng[1] := true; rng[5] := true; rng[8] := true;
  drawG(0);
  label.bot(btex $0$으로 가는 것들을 지우면 $A=\{1,5,8\}$ etex, (-.5u, -1.6u));
  clearflags;
  for t=0,1,2,4,5: gry[t] := true; endfor      % $0\preceq y$ 인 것들
  rng[3] := true; rng[6] := true; rng[7] := true;
  drawG(dx);
  label.bot(btex $0$에서 가는 것들을 지우면 $B=\{3,6,7\}$ etex, (dx-.5u, -1.6u));
endfig;
enddef;

% bit 0이 0에서 1로 뒤집힐 때 프린지가 어떻게 바뀌는가.
% 위줄이 $0_0\tau_{00}$, 아래줄이 $0_1\tau_{01}$.
def fig_tau =
beginfig(3);
  numeric U, V, wd, ht; U := 40bp; V := 46bp; wd := 26bp; ht := 17bp;
  numeric col[];
  col0 := 0; col1 := 1; col3 := 2; col5 := 3; col6 := 4; col7 := 5; col8 := 6;
  picture nm[][];
  nm[0][0] := btex $0_0$ etex;  nm[0][1] := btex $0_1$ etex;
  nm[1][0] := btex $1_1$ etex;  nm[3][0] := btex $3_0$ etex;
  nm[5][0] := btex $5_1$ etex;  nm[6][0] := btex $6_1$ etex;
  nm[7][0] := btex $7_0$ etex;  nm[8][0] := btex $8_0$ etex;
  nm[1][1] := nm[1][0]; nm[3][1] := nm[3][0]; nm[5][1] := nm[5][0];
  nm[6][1] := nm[6][0]; nm[7][1] := nm[7][0]; nm[8][1] := nm[8][0];
  boolean has[][];
  for t=0 upto 8: has[t][0] := false; has[t][1] := false; endfor
  for t=0,1,3,5,6,8: has[t][0] := true; endfor
  for t=0,3,6,7,8: has[t][1] := true; endfor
  pair c[][];
  for r=0 upto 1: for t=0,1,3,5,6,7,8:
    c[t][r] := (col[t]*U, -r*V);
  endfor endfor
  for r=0 upto 1:
    numeric prev; prev := -1;
    for t=0,1,3,5,6,7,8:
      if has[t][r]:
        draw unitsquare xscaled wd yscaled ht shifted -(.5wd,.5ht)
          shifted c[t][r];
        label(nm[t][r], c[t][r]);
        if prev >= 0:
          drawdblarrow (c[prev][r]+(.5wd+1.5bp,0)) -- (c[t][r]-(.5wd+1.5bp,0));
        fi
        prev := t;
      fi
    endfor
  endfor
  % 그대로 남는 것들은 세로 점선으로 잇는다.
  for t=0,3,6,8:
    draw (c[t][0]-(0,.5ht+2bp)) -- (c[t][1]+(0,.5ht+2bp))
      dashed withdots withpen pencircle scaled .7bp;
  endfor
  for t=1,5:
    label.bot(btex 빠짐 etex, c[t][0]-(0,.5ht+3bp));
  endfor
  label.top(btex 들어옴 etex, c[7][1]+(0,.5ht+3bp));
  label.lft(btex $\tau_{00}$: etex, c[0][0]-(.5wd+22bp,0));
  label.lft(btex $\tau_{01}$: etex, c[0][1]-(.5wd+22bp,0));
endfig;
enddef;

% 낡은 링크. 전이가 일어날 때 오른쪽 끝 이음매 하나만 곧바로 잇고, 나머지
% 이음매에는 깃발을 꽂아 두었다가 알고리즘의 눈길이 거기 닿을 때 하나씩 고친다.
def fig_stale =
beginfig(4);
  numeric U, wd, ht, gap; U := 26bp; wd := 20bp; ht := 16bp; gap := 20bp;
  picture cap[];
  cap1 := btex $\sigma_1$ etex; cap2 := btex $\sigma_2$ etex;
  cap3 := btex $\sigma_3$ etex;
  numeric lft_[], rgt_[], x;
  x := 0;
  draw unitsquare xscaled wd yscaled ht shifted -(.5wd,.5ht) shifted (x,0);
  label(btex $k_1$ etex, (x,0));
  numeric prevr; prevr := x;
  for g=1 upto 3:
    x := x + gap + U;
    lft_[g] := x;
    for m=0 upto 1:
      draw unitsquare xscaled wd yscaled ht shifted -(.5wd,.5ht)
        shifted (x + m*U, 0);
    endfor
    drawdblarrow (x+.5wd+1.5bp,0) -- (x+U-.5wd-1.5bp,0);
    rgt_[g] := x + U;
    label.bot(cap[g], (x+.5U, -.5ht-4bp));
    % 끊긴 이음매: 가운데를 비워 둔 점선.
    draw (prevr+.5wd+1.5bp,0) -- (.5[prevr,x]-4bp,0) dashed evenly;
    draw (.5[prevr,x]+4bp,0) -- (x-.5wd-1.5bp,0) dashed evenly;
    prevr := rgt_[g];
    x := rgt_[g];
  endfor
  % 오른쪽 끝은 프린지의 나머지. 이 이음매만 전이 때 곧바로 잇는다.
  x := x + gap + 16bp;
  label(btex $\cdots$ etex, (x,0));
  drawdblarrow (rgt_[3]+.5wd+1.5bp,0) -- (x-8bp,0);
  label.bot(btex 이 이음매 하나만 전이가 일어날 때 곧바로 잇는다 etex,
    (.5[rgt_[3],x], -.5ht-20bp));
  % 깃발은 한 번에 하나뿐이다. $\sigma_3$ 의 첫 칸에서 시작해 왼쪽으로 옮겨 간다.
  draw (lft_[3], .5ht+2bp) -- (lft_[3], .5ht+11bp);
  fill ((0,0)--(8bp,3.5bp)--(0,7bp)--cycle) shifted (lft_[3], .5ht+4bp);
  label.rt(btex \ 깃발 etex, (lft_[3]+4bp, .5ht+7.5bp));
  drawarrow (lft_[3]-4bp, .5ht+17bp) -- (lft_[2]+4bp, .5ht+17bp) dashed evenly;
  label.top(btex 고치고 나면 깃발은 왼쪽으로 옮겨 간다 etex,
    (.5[lft_[2],lft_[3]], .5ht+18bp));
  drawarrow (x+4bp, -.5ht-38bp) -- (-12bp, -.5ht-38bp);
  label.bot(btex 알고리즘의 눈길은 오른쪽에서 왼쪽으로 옮겨 간다 etex,
    (.5x, -.5ht-39bp));
endfig;
enddef;
