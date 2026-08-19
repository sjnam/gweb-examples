% enigmatic-puzzle.mp -- enigmatic-puzzle.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input enigmatic-puzzle;` 으로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_wiring -- 자판에서 램프까지 전류가 지나는 길. 플러그보드와 회전자 셋을
%                 지나 반사판에서 되돌아 나온다.
%   fig_delta  -- 델타 나무의 위 네 층. 노드에 적힌 세 자리는 세 회전량이
%                 처음보다 얼마나 늘었는가이다.

defaultfont := "cmtt10";
defaultscale := 0.9;

def fig_wiring =
beginfig(1);
  numeric u, w, h; u := 74; w := 44; h := 104;
  numeric fy[], by[];
  fy0=36; fy1=10; fy2=40; fy3=-6; fy4=28;
  by0=-30; by1=-16; by2=-42; by3=6;  by4=-34;
  path bx[];
  for i=0 upto 4:
    bx[i] = (i*u,-.5h)--(i*u+w,-.5h)--(i*u+w,.5h)--(i*u,.5h)--cycle;
  endfor
  for i=1 upto 3: fill bx[i] withcolor (1,.94,.84); endfor
  for i=0 upto 4: draw bx[i]; endfor
  % 앞으로 가는 길: 상자 안에서 비스듬히 건너뛰고, 상자 사이는 곧게 간다
  draw (-30,fy0)--(0,fy0) withcolor .3white;
  for i=0 upto 3:
    draw (i*u,fy[i])--(i*u+w,fy[i+1]) withcolor .3white;
    draw (i*u+w,fy[i+1])--((i+1)*u,fy[i+1]) withcolor .3white;
  endfor
  % 반사판 안에서 되꺾인다
  draw (4u,fy4)--(4u+.6w,fy4)--(4u+.6w,by4)--(4u,by4) withcolor .3white;
  % 되돌아 나오는 길
  for i=3 downto 0:
    draw ((i+1)*u,by[i+1])--(i*u+w,by[i+1]) withcolor .3white;
    draw (i*u+w,by[i+1])--(i*u,by[i]) withcolor .3white;
  endfor
  drawarrow (0,by0)--(-30,by0) withcolor .3white;
  label.lft(btex 자판 etex, (-32,fy0));
  label.lft(btex 램프 etex, (-32,by0));
  label.bot(btex 플러그보드 etex, (.5w,-.5h-7));
  label.bot(btex 빠른 etex, (u+.5w,-.5h-7));
  label.bot(btex 가운데 etex, (2u+.5w,-.5h-7));
  label.bot(btex 느린 etex, (3u+.5w,-.5h-7));
  label.bot(btex 반사판 etex, (4u+.5w,-.5h-7));
  draw (u,-.5h-26)--(3u+w,-.5h-26) withcolor .6white;
  label.bot(btex 회전자 셋 etex, (2u+.5w,-.5h-28));
endfig;
enddef;

def fig_delta =
beginfig(2);
  numeric u, v; u := 46; v := 40;
  % 노드: (층, x자리, 라벨, 부모의 x자리)
  pair pos[][];
  string lab[][];
  numeric nx[];
  pos[0][0] := (5.0u, 0);      lab[0][0] := "000";
  pos[1][0] := (2.5u,-v);      lab[1][0] := "001";
  pos[1][1] := (5.5u,-v);      lab[1][1] := "011";
  pos[1][2] := (7.0u,-v);      lab[1][2] := "111";
  pos[2][0] := (1.5u,-2v);     lab[2][0] := "002";
  pos[2][1] := (3.5u,-2v);     lab[2][1] := "012";
  pos[2][2] := (5.0u,-2v);     lab[2][2] := "012";
  pos[2][3] := (6.0u,-2v);     lab[2][3] := "122";
  pos[2][4] := (7.0u,-2v);     lab[2][4] := "112";
  pos[3][0] := (1.0u,-3v);     lab[3][0] := "003";
  pos[3][1] := (2.0u,-3v);     lab[3][1] := "013";
  pos[3][2] := (3.0u,-3v);     lab[3][2] := "013";
  pos[3][3] := (4.0u,-3v);     lab[3][3] := "123";
  pos[3][4] := (5.0u,-3v);     lab[3][4] := "013";
  pos[3][5] := (6.0u,-3v);     lab[3][5] := "123";
  pos[3][6] := (7.0u,-3v);     lab[3][6] := "113";
  def edge(expr a, b) = draw a--b cutbefore fullcircle scaled 26 shifted a
                              cutafter fullcircle scaled 26 shifted b
                        withcolor .6white; enddef;
  for i=0 upto 2: edge(pos[0][0], pos[1][i]); endfor
  edge(pos[1][0], pos[2][0]); edge(pos[1][0], pos[2][1]);
  edge(pos[1][1], pos[2][2]); edge(pos[1][1], pos[2][3]);
  edge(pos[1][2], pos[2][4]);
  edge(pos[2][0], pos[3][0]); edge(pos[2][0], pos[3][1]);
  edge(pos[2][1], pos[3][2]); edge(pos[2][1], pos[3][3]);
  edge(pos[2][2], pos[3][4]);
  edge(pos[2][3], pos[3][5]);
  edge(pos[2][4], pos[3][6]);
  for k=0 upto 3:
    for i=0 upto 2k:
      fill fullcircle scaled 26 shifted pos[k][i] withcolor white;
      draw fullcircle scaled 26 shifted pos[k][i] withcolor .6white;
      label(lab[k][i], pos[k][i]);
    endfor
  endfor
  label.lft(btex 1개 etex, (0.2u, 0));
  label.lft(btex 3개 etex, (0.2u, -v));
  label.lft(btex 5개 etex, (0.2u, -2v));
  label.lft(btex 7개 etex, (0.2u, -3v));
endfig;
enddef;
