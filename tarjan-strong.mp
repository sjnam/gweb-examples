% tarjan-strong.mp -- tarjan-strong.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input tarjan-strong;` 으로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_digraph -- 보기 유향그래프와 그 세 강한 성분
%   fig_low     -- 같은 그래프의 깊이 우선 나무, p 와 LOW
%   fig_fallacy -- 안쪽 화살을 지워도 되는가: 틀린 규칙의 반례
%
% 굵은 실선 = 나무 화살, 점선 = 나무 아닌 화살, 두 겹 점 = 성분의 우두머리.

numeric rr;  rr := 2.6bp;      % 꼭짓점 점의 반지름
numeric gg;  gg := 9bp;        % 화살이 양 끝에서 물러나는 거리
picture dashy; dashy := dashpattern(on 3bp off 2.5bp);

def dot(expr z) = fill fullcircle scaled 2rr shifted z; enddef;

% 두 겹 점: 성분의 우두머리.
def bigdot(expr z) =
  fill fullcircle scaled 2rr shifted z;
  draw fullcircle scaled (2rr + 5bp) shifted z;
enddef;

% 곧은 화살길 a->b. 양 끝에서 이름표 자리만큼 물러난다.
vardef spath(expr a, b) =
  (a + gg*unitvector(b-a)) -- (b - gg*unitvector(b-a))
enddef;

% 휜 화살길 a->b. |s|가 양수면 진행 방향의 왼쪽으로 부푼다.
vardef cpath(expr a, b, s) =
  save m; pair m;
  m := 0.5[a,b] + s*unitvector((b-a) rotated 90);
  (a + gg*unitvector(m-a)) .. m .. (b - gg*unitvector(b-m))
enddef;

% 세 꼭짓점을 둘러싸는 둥근 세모 테두리. 무게중심에서 바깥으로 |d|만큼
% 부풀리되, 변의 한가운데는 절반만 밀어 세모꼴이 남게 한다.
vardef out(expr z, ctr, d) = z + d*unitvector(z-ctr) enddef;
def blob(expr p, q, r, d) =
  begingroup save ctr; pair ctr; ctr := (p+q+r)/3;
    draw (out(p,ctr,d) .. out(0.5[p,q],ctr,0.72d) .. out(q,ctr,d)
          .. out(0.5[q,r],ctr,0.72d) .. out(r,ctr,d)
          .. out(0.5[r,p],ctr,0.72d) .. cycle)
         dashed dashy withcolor .55white;
  endgroup
enddef;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def fig_digraph =
beginfig(1);
save u, a, b, c, d, e, f; numeric u; pair a, b, c, d, e, f;
u := 30bp;
f := (0, 3.1u);    d := (2.5u, 3.1u);  e := (4.5u, 3.1u);
b := (2.2u, 1.5u); c := (3.7u, 0);     a := (0.7u, 0);

% 성분의 테두리를 먼저 그려 화살 밑에 깔리게 한다.
blob(a, b, c, 0.5u);
draw fullcircle xscaled (abs(e-d) + 1.35u) yscaled 1.15u
     shifted (0.5[d,e]) dashed dashy withcolor .55white;
draw fullcircle scaled 1.15u shifted f dashed dashy withcolor .55white;

pickup pencircle scaled 1.1bp;                     % 나무 화살
drawarrow spath(f, d); drawarrow spath(d, b);
drawarrow spath(b, c); drawarrow spath(c, a);
drawarrow cpath(d, e, 0.3u);
pickup pencircle scaled 0.6bp;                     % 나무 아닌 화살
drawarrow cpath(e, d, 0.3u) dashed dashy;
drawarrow spath(a, b) dashed dashy;
drawarrow cpath(f, a, 0.5u) dashed dashy;

bigdot(b); bigdot(d); bigdot(f);
dot(a); dot(c); dot(e);
label.llft(btex $a$ etex, a shifted (-2bp,-2bp));
label.lft (btex $b$ etex, b shifted (-6bp,0));
label.lrt (btex $c$ etex, c shifted (2bp,-2bp));
label.ulft(btex $d$ etex, d shifted (-2bp,3bp));
label.rt  (btex $e$ etex, e shifted (6bp,0));
label.lft (btex $f$ etex, f shifted (-6bp,0));
endfig;
enddef;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def fig_low =
beginfig(2);
save u, h, a, b, c, d, e, f; numeric u, h; pair a, b, c, d, e, f;
u := 34bp; h := 34bp;
f := (0, 4h);      d := (0, 3h);      e := (-1.7u, 2h);
b := (1.35u, 2h);  c := (1.35u, h);   a := (1.35u, 0);

pickup pencircle scaled 1.1bp;
drawarrow spath(f, d); drawarrow spath(d, e); drawarrow spath(d, b);
drawarrow spath(b, c); drawarrow spath(c, a);
pickup pencircle scaled 0.6bp;
drawarrow cpath(e, d, 0.55u) dashed dashy;
drawarrow cpath(a, b, 1.1u) dashed dashy;
drawarrow cpath(f, a, -3.4u) dashed dashy;

bigdot(f); bigdot(d); bigdot(b);
dot(e); dot(c); dot(a);
label.rt (btex $f\;(1,1)$ etex, f shifted (7bp,0));
label.rt (btex $d\;(2,2)$ etex, d shifted (7bp,0));
label.bot(btex $e\;(3,2)$ etex, e shifted (0,-8bp));
label.rt (btex $b\;(4,4)$ etex, b shifted (7bp,0));
label.rt (btex $c\;(5,4)$ etex, c shifted (7bp,0));
label.rt (btex $a\;(6,4)$ etex, a shifted (7bp,0));
endfig;
enddef;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def fig_fallacy =
beginfig(3);
save u, h, dx, a, b, c; numeric u, h, dx; pair a[], b[], c[];
u := 30bp; h := 42bp; dx := 4.2u;
for i=0 upto 1:
  c[i] := (i*dx, 2h);  b[i] := (i*dx, h);  a[i] := (i*dx, 0);
endfor

for i=0 upto 1:
  pickup pencircle scaled 1.1bp;
  drawarrow spath(c[i], b[i]); drawarrow spath(b[i], a[i]);
  pickup pencircle scaled 0.6bp;
  drawarrow cpath(a[i], b[i], -0.6u) dashed dashy;
  if i=0:
    drawarrow cpath(b[i], c[i], -0.6u) dashed dashy;
  else:
    draw cpath(b[i], c[i], -0.6u) dashed dashy withcolor .7white;
  fi
  dot(a[i]); dot(b[i]); bigdot(c[i]);
  label.rt(btex $a$ etex, a[i] shifted (6bp,0));
  label.rt(btex $b$ etex, b[i] shifted (6bp,0));
  label.rt(btex $c$ etex, c[i] shifted (6bp,0));
endfor
label(btex $\times$ etex, 0.5[b1,c1] shifted (0.95u,0));
label.bot(btex 안쪽 화살 둘을 다 내면 etex, a0 shifted (0,-18bp));
label.bot(btex $b\to c$를 빠뜨리면 etex, a1 shifted (0,-18bp));
endfig;
enddef;
