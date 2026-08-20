% hopcroft-karp.mp -- hopcroft-karp.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input hopcroft-karp;` 으로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_augment -- 증대 경로 하나를 뒤집으면 쌍이 하나 는다
%   fig_symdiff -- A (+) B 의 성분 네 가지
%   fig_dag     -- 6x6 보기의 두 번째 판에서 지어지는 dag
%
% 온 그림에서 짝인 변은 겹선, 짝 아닌 변은 홑선이다.

numeric dd; dd := 1.4bp;        % 겹선 두 줄 사이의 반 너비
numeric rr; rr := 2.2bp;        % 꼭짓점 점의 반지름

def dot(expr z) = fill fullcircle scaled 2rr shifted z; enddef;

% 겹선: 짝인 변.
def dbl(expr a, b) =
  begingroup save d; pair d;
    d := dd * unitvector((b-a) rotated 90);
    draw (a+d)--(b+d); draw (a-d)--(b-d);
  endgroup
enddef;

% 겹화살: dag 안의 짝인 변.
def dblarrow(expr a, b) =
  begingroup save d, e; pair d, e;
    d := dd * unitvector((b-a) rotated 90);
    e := 7bp * unitvector(b-a);
    draw (a+d)--(b+d-e); draw (a-d)--(b-d-e);
    drawarrow (b-1.6e)--b;
  endgroup
enddef;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def fig_augment =
beginfig(1);
numeric u, h, dx;
u := 24bp;  h := 42bp;  dx := 5u + 34bp;

pair G[], B[], GG[], BB[];
for i=0 upto 2:
  G[i] := (2i*u, h);        B[i] := ((2i+1)*u, 0);
  GG[i] := G[i] shifted (dx,0);  BB[i] := B[i] shifted (dx,0);
endfor

% 왼쪽: 짝이 둘. 지그재그가 증대 경로다.
draw G0--B0;  dbl(B0,G1);  draw G1--B1;  dbl(B1,G2);  draw G2--B2;
% 오른쪽: 뒤집어서 짝이 셋.
dbl(GG0,BB0); draw BB0--GG1; dbl(GG1,BB1); draw BB1--GG2; dbl(GG2,BB2);

for i=0 upto 2:
  dot(G[i]); dot(B[i]); dot(GG[i]); dot(BB[i]);
endfor
label.top(btex $g_0$ etex, G0); label.top(btex $g_1$ etex, G1);
label.top(btex $g_2$ etex, G2);
label.bot(btex $b_0$ etex, B0); label.bot(btex $b_1$ etex, B1);
label.bot(btex $b_2$ etex, B2);
label.top(btex $g_0$ etex, GG0); label.top(btex $g_1$ etex, GG1);
label.top(btex $g_2$ etex, GG2);
label.bot(btex $b_0$ etex, BB0); label.bot(btex $b_1$ etex, BB1);
label.bot(btex $b_2$ etex, BB2);
label(btex $\Longrightarrow$ etex, (5u + 17bp, h/2));
endfig;
enddef;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def fig_symdiff =
beginfig(2);
numeric u, s, y;
u := 30bp;                       % 변 하나의 길이
s := 108bp;                      % 그림 넷 사이의 간격
y := -17bp;                      % 이름표 자리

% (1) 순환: 가로가 A, 세로가 B.
pair c[];
c1 := (0,u); c2 := (u,u); c3 := (u,0); c4 := (0,0);
draw c1--c2;  dbl(c2,c3);  draw c3--c4;  dbl(c4,c1);
for i=1 upto 4: dot(c[i]); endfor
label(btex 순환 etex, (u/2, y));

% (2) 균형 경로: A B A B --- 양쪽이 둘씩.
pair p[];
for i=0 upto 4: p[i] := (s + i*u/1.6, u/2); endfor
draw p0--p1; dbl(p1,p2); draw p2--p3; dbl(p3,p4);
for i=0 upto 4: dot(p[i]); endfor
label(btex 균형 경로 etex, (s + 2u/1.6, y));

% (3) A-경로: A 가 하나 많다.
pair q[];
for i=0 upto 3: q[i] := (2s + i*u/1.6, u/2); endfor
draw q0--q1; dbl(q1,q2); draw q2--q3;
for i=0 upto 3: dot(q[i]); endfor
label(btex $A$-경로 etex, (2s + 1.5u/1.6, y));

% (4) B-경로: B 가 하나 많다.
pair w[];
for i=0 upto 3: w[i] := (3s + i*u/1.6, u/2); endfor
dbl(w0,w1); draw w1--w2; dbl(w2,w3);
for i=0 upto 3: dot(w[i]); endfor
label(btex $B$-경로 etex, (3s + 1.5u/1.6, y));
endfig;
enddef;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numeric R; R := 9.5bp;           % 동그라미 반지름

def circ(expr z, s) =
  unfill fullcircle scaled 2R shifted z;
  draw fullcircle scaled 2R shifted z;
  label(s, z);
enddef;

def toward(expr a, b) = (a + R*unitvector(b-a)) enddef;

def fig_dag =
beginfig(3);
numeric u, v;
u := 34bp;                       % 가로 한 칸
v := 40bp;                       % 층 사이 간격

pair tnode, bnode, bb[], gg[];
tnode := (0, 5v);
bb5 := (-u, 4v);  bb6 := (u, 4v);
gg6 := (0, 3v);
bb3 := (0, 2v);   bb1 := (2.1u, 2v);
gg4 := (0, v);
bnode := (0, 0);

% 굵게 그릴 길: top -> b5 -> g6 => b3 -> g4 => bot.
pickup pencircle scaled 1.4bp;
drawarrow toward(tnode,bb5)--toward(bb5,tnode);
drawarrow toward(bb5,gg6)--toward(gg6,bb5);
drawarrow toward(bb3,gg4)--toward(gg4,bb3);
dblarrow(toward(gg6,bb3), toward(bb3,gg6));
dblarrow(toward(gg4,bnode), toward(bnode,gg4));
pickup pencircle scaled .5bp;

% 나머지.
drawarrow toward(tnode,bb6)--toward(bb6,tnode);
drawarrow toward(bb6,gg6)--toward(gg6,bb6);
drawarrow toward(bb1,gg4)--toward(gg4,bb1);

circ(tnode, btex $\top$ etex);
circ(bb5, btex $b_5$ etex);   circ(bb6, btex $b_6$ etex);
circ(gg6, btex $g_6$ etex);
circ(bb3, btex $b_3$ etex);   circ(bb1, btex $b_1$ etex);
circ(gg4, btex $g_4$ etex);
circ(bnode, btex $\bot$ etex);
label.rt(btex 짝 없는 소년 etex, bb6 shifted (R+4bp, 0));
label.rt(btex 짝 없는 소녀 etex, gg4 shifted (R+4bp, 0));
endfig;
enddef;
