% koda-ruskey.mp -- koda-ruskey.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input koda-ruskey;` 로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_forest -- 괄호열 ((())(()())) 과 거기서 나오는 숲
%   fig_gray   -- 코루틴 하나가 만드는 l(r+1)가지의 뱀 모양 차례
%   fig_fringe -- 프린지의 이중 연결 목록과 focus 지름길

% 괄호열과 거기서 나오는 숲. 노드는 제 오른쪽 괄호 바로 아래에 놓았고, 높이는
% 그 괄호쌍의 중첩 깊이다. 화살표는 자식에서 부모로 간다.
def fig_forest =
beginfig(1);
  numeric u, v, rad; u := 13bp; v := 27bp; rad := 7bp;
  string s; s := "((())(()()))";
  numeric px[], dep[], par[];
  pair np[];
  px0 := 3;  px1 := 4;  px2 := 7;  px3 := 9;  px4 := 10; px5 := 11;
  dep0 := 2; dep1 := 1; dep2 := 2; dep3 := 2; dep4 := 1; dep5 := 0;
  par0 := 1; par1 := 5; par2 := 4; par3 := 4; par4 := 5; par5 := -1;
  for k=0 upto 11:
    label(substring (k,k+1) of s, (k*u, 0));
  endfor
  for k=0 upto 5:
    np[k] := (px[k]*u, -dep[k]*v - 30bp);
    draw (px[k]*u, -9bp) -- (np[k] + (0,rad)) dashed withdots
      withpen pencircle scaled .7bp;
  endfor
  for k=0 upto 5:
    if par[k] >= 0:
      drawarrow np[k] -- np[par[k]]
        cutbefore fullcircle scaled 2.4rad shifted np[k]
        cutafter fullcircle scaled 2.4rad shifted np[par[k]];
    fi
  endfor
  for k=0 upto 5:
    unfill fullcircle scaled 2rad shifted np[k];
    draw fullcircle scaled 2rad shifted np[k];
    label(decimal k, np[k]);
  endfor
  label.rt(btex \ \ 뿌리 etex, np[5] + (rad,0));
endfig;
enddef;

% 코루틴 p 가 두 번의 false 사이에 만드는 l(r+1)가지. 세로 한 칸은 p 의
% 부분나무가 한 걸음 나아간 것이고, 가로 한 칸은 왼쪽 형제들이 한 걸음
% 나아간 것이다. 차례는 뱀처럼 접힌다 --- 그래서 반사 그레이 코드다.
def fig_gray =
beginfig(2);
  numeric U, V, ll, rr; U := 40bp; V := 26bp; ll := 4; rr := 3;
  pair pt[][];
  path snake;
  for i=0 upto ll-1: for j=0 upto rr-1:
    pt[i][j] := (i*U, j*V);
  endfor endfor
  snake := pt[0][0] -- pt[0][rr-1];
  for i=1 upto ll-1:
    if odd i:
      snake := snake -- pt[i][rr-1] -- pt[i][0];
    else:
      snake := snake -- pt[i][0] -- pt[i][rr-1];
    fi
  endfor
  draw snake withpen pencircle scaled 1.1bp;
  for i=0 upto ll-1: for j=0 upto rr-1:
    unfill fullcircle scaled 5bp shifted pt[i][j];
    draw fullcircle scaled 5bp shifted pt[i][j];
  endfor endfor
  fill fullcircle scaled 5bp shifted point 0 of snake;
  fill fullcircle scaled 9bp shifted point (length snake) of snake;
  label.llft(btex 처음: 모두 $0$ etex, pt[0][0] + (-2bp,-2bp));
  label.lrt(btex 끝 etex, pt[ll-1][0] + (3bp,-3bp));
  label.bot(btex 왼쪽 형제들의 $l$가지 $\longrightarrow$ etex,
    (.5(ll-1)*U, -22bp));
  label.lft(btex \vbox{\halign{\hfil#\hfil\cr $p$의\cr 부분나무가\cr
    내는\cr $r+1$가지\cr}} etex, (-16bp, .5(rr-1)*V));
endfig;
enddef;

% 프린지의 한 순간. 능동 노드는 색을 채웠고 수동 노드는 비었다. 위쪽 점선
% 화살표가 focus 지름길이다. head 에서 왼쪽으로 한 칸 간 뒤 focus 를 한 번
% 따라가면 수동 노드들을 통째로 건너뛰어 D 에 닿는다.
def fig_fringe =
beginfig(3);
  numeric U, wd, ht; U := 40bp; wd := 24bp; ht := 18bp;
  numeric xx[];
  picture nm[];
  path bx[];
  nm0 := btex $A$ etex; nm1 := btex $B$ etex; nm2 := btex $C$ etex;
  nm3 := btex $D$ etex; nm4 := btex $E$ etex; nm5 := btex $F$ etex;
  nm6 := btex \it head etex;
  boolean act[];
  act0 := true;  act1 := false; act2 := false;
  act3 := true;  act4 := false; act5 := false; act6 := true;
  for k=0 upto 5: xx[k] := k*U; endfor
  xx6 := -U;  % head 는 맨 왼쪽에 둔다
  for k=0 upto 6:
    bx[k] := unitsquare xscaled wd yscaled ht
      shifted -(.5wd,.5ht) shifted (xx[k],0);
  endfor
  for k=0 upto 6:
    if act[k]: fill bx[k] withcolor .85white; fi
    draw bx[k];
    label(nm[k], (xx[k],0));
  endfor
  for k=0 upto 4:
    drawdblarrow (xx[k]+.5wd+2bp, 0) -- (xx[k+1]-.5wd-2bp, 0);
  endfor
  drawdblarrow (xx6+.5wd+2bp, 0) -- (xx0-.5wd-2bp, 0);
  % focus 지름길: C 는 A 로, F 는 D 로.
  drawarrow (xx2,.5ht+3bp) .. (.5[xx0,xx2], .5ht+22bp) .. (xx0,.5ht+3bp)
    dashed evenly;
  drawarrow (xx5,.5ht+3bp) .. (.5[xx3,xx5], .5ht+22bp) .. (xx3,.5ht+3bp)
    dashed evenly;
  label.top(btex \it focus etex, (.5[xx0,xx2], .5ht+24bp));
  label.top(btex \it focus etex, (.5[xx3,xx5], .5ht+24bp));
  % 순환 목록임을 알리는 되돌이 선.
  draw (xx5,-.5ht-3bp) .. (.5[xx6,xx5], -.5ht-26bp) .. (xx6,-.5ht-3bp)
    dashed withdots withpen pencircle scaled .5bp;
  label.bot(btex 목록은 {\it head\/}를 거쳐 돈다 etex,
    (.5[xx6,xx5], -.5ht-27bp));
endfig;
enddef;
