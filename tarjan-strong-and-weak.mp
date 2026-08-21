% tarjan-strong-and-weak.mp -- tarjan-strong-and-weak.w 의 그림 꾸러미.
% 도우미 매크로(dot, bigdot, spath, cpath, dashy)는 앞 글의 것을 그대로 쓴다.
input tarjan-strong;
%   fig_wdigraph -- 보기 유향그래프와 그 여섯 강한 성분
%   fig_weak     -- 오므린 그래프의 순서열 분해와 비교 불가능 그래프

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def fig_wdigraph =
beginfig(11);
save u, h, a, b, c, d, e, f, gv; numeric u, h; pair a, b, c, d, e, f, gv;
u := 30bp; h := 34bp;
a  := (1.4u, 3.5h);
b  := (0.0u, 2.1h);  c := (2.8u, 2.1h);  d := (4.1u, 2.1h);
e  := (-1.1u, 0.1h); f := (0.6u, 0.95h); gv := (2.5u, 0);

draw fullcircle xscaled (abs(d-c) + 1.3u) yscaled 1.4u
     shifted (0.5[c,d]) dashed dashy withcolor .55white;

pickup pencircle scaled 0.8bp;
drawarrow spath(b, a);  drawarrow spath(c, a);
drawarrow spath(f, b);  drawarrow spath(f, c);
drawarrow spath(e, f);  drawarrow spath(gv, b);  drawarrow spath(gv, c);
drawarrow cpath(c, d, 0.28u);  drawarrow cpath(d, c, 0.28u);

bigdot(a); bigdot(b); bigdot(c); bigdot(e); bigdot(f); bigdot(gv);
dot(d);
label.top (btex $a$ etex, a shifted (0,6bp));
label.lft (btex $b$ etex, b shifted (-6bp,0));
label.top (btex $c$ etex, c shifted (0,5bp));
label.urt (btex $d$ etex, d shifted (2bp,2bp));
label.lft (btex $e$ etex, e shifted (-6bp,0));
label.lrt (btex $f$ etex, f shifted (3bp,-3bp));
label.rt  (btex $g$ etex, gv shifted (6bp,-2bp));
endfig;
enddef;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def fig_weak =
beginfig(12);
save u, h, dx, A, B, C, E, F, G; numeric u, h, dx;
pair A[], B[], C[], E[], F[], G[];
u := 28bp; h := 40bp; dx := 5.4u;
for i=0 upto 1:
  A[i] := (i*dx + 1.3u, 3h);
  B[i] := (i*dx + 0.0u, 1.8h);  C[i] := (i*dx + 2.6u, 1.8h);
  E[i] := (i*dx - 1.0u, 0.1h);  F[i] := (i*dx + 0.5u, 0.85h);
  G[i] := (i*dx + 2.4u, 0);
endfor

% 왼쪽: 오므린 그래프와 두 개의 자름선.
pickup pencircle scaled 0.8bp;
drawarrow spath(B0, A0);  drawarrow spath(C0, A0);
drawarrow spath(F0, B0);  drawarrow spath(F0, C0);
drawarrow spath(E0, F0);  drawarrow spath(G0, B0);  drawarrow spath(G0, C0);
pickup pencircle scaled 0.5bp;
draw (-1.7u, 2.45h)--(3.4u, 2.45h) dashed dashy withcolor .55white;
draw (-1.7u, 1.35h)--(3.4u, 1.35h) dashed dashy withcolor .55white;

% 오른쪽: 비교 불가능 그래프. 이어진 것끼리가 한 약한 성분이다.
pickup pencircle scaled 0.8bp;
draw B1--C1;  draw E1--G1;  draw F1--G1;
blob(E1, F1, G1, 0.74u);
draw fullcircle xscaled (abs(C1-B1) + 2.4u) yscaled 1.3u
     shifted (0.5[B1,C1]) dashed dashy withcolor .55white;
draw fullcircle scaled 1.5u shifted A1 dashed dashy withcolor .55white;

for i=0 upto 1:
  dot(A[i]); dot(B[i]); dot(C[i]); dot(E[i]); dot(F[i]); dot(G[i]);
  label.top (btex $a$ etex, A[i] shifted (0,5bp));
  label.lft (btex $b$ etex, B[i] shifted (-5bp,0));
  label.rt  (btex $cd$ etex, C[i] shifted (5bp,0));
  label.lft (btex $e$ etex, E[i] shifted (-8bp,0));
  if i=0:                       % 왼쪽 판에서는 화살을 피해 아래로
    label.lrt(btex $f$ etex, F[i] shifted (3bp,-3bp));
  else:
    label.top(btex $f$ etex, F[i] shifted (0,7bp));
  fi
  label.rt  (btex $g$ etex, G[i] shifted (5bp,0));
endfor
label.bot(btex 오므린 그래프 etex, (0.8u, -0.5h));
label.bot(btex 비교 불가능 그래프 etex, (dx + 0.8u, -0.5h));
endfig;
enddef;
