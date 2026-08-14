% dragon-calc.mp -- figures for dragon-calc.w.
%   fig 1: the paperfolding dragon of orders 1..5, and of order 12.
%   fig 2: a generalized dragon -- the unit path times the path 01012,
%          three times over (s=125).
% The D, U and O macros below are exactly the ones that dragon-calc's `m'
% command emits, so these pictures are drawn the way the program draws.
% Build with: mptopdf dragon-calc.mp  (-> dragon-calc-1.pdf, dragon-calc-2.pdf)

verbatimtex
\documentclass{article}
\usepackage{kotex}
\begin{document}
etex

defaultfont := "cmr10";
defaultscale := 0.9;

numeric dd; pair rr, ww, zz;
def D = dd:=dd+90; ww:=zz; zz:=ww+rr rotated dd; draw ww--zz; enddef;
def U = dd:=dd-90; ww:=zz; zz:=ww+rr rotated dd; draw ww--zz; enddef;
def O = zz:=origin; dd:=-90; D; enddef;

% 차수 n의 용은 단위 경로에 *D 를 n 번 곱한 것이다. 그 접기열 F(n) 은
% F(n) = F(n-1) D G(n-1), G(n) = F(n-1) U G(n-1) 로 저절로 난다.
def Dn(expr n) = if n>0: Dn(n-1); D; Un(n-1); fi enddef;
def Un(expr n) = if n>0: Dn(n-1); U; Un(n-1); fi enddef;

beginfig(1);
  picture p[], q;
  numeric wd, x, top;
  rr := (7bp,0);
  for n=1 upto 5:
    p[n] := image(O Dn(n));
  endfor
  x := 0;
  for n=1 upto 5:
    wd := xpart urcorner p[n] - xpart llcorner p[n];
    draw p[n] shifted (x - xpart llcorner p[n], -ypart llcorner p[n]);
    label.bot("n=" & decimal n, (x + .5wd, -4));
    x := x + wd + 18;
  endfor
  top := -36;
  rr := (2.6bp,0);
  drawoptions(withpen pencircle scaled .3bp);
  q := image(O Dn(12));
  draw q shifted (.5x - .5(xpart urcorner q + xpart llcorner q),
                  top - ypart urcorner q);
endfig;

% 일반화된 용. 단위 경로에 경로 01012 를 거듭 곱한 것으로, 접기열은 프로그램의
% m 명령이 뱉은 것을 그대로 옮겼다.
beginfig(2);
  picture g[];
  numeric wd, x;
  rr := (9bp,0);
  g[1] := image(O D U D D;);
  g[2] := image(O D U D D D U U D U U D U D D D U U D U D D U D D;);
  rr := (5bp,0);
  g[3] := image(
  O D U D D D U U D U U D U D D D U U D U D D U D D D U U D U U D
  U D D U U U D U D D U D D U U U D U U D U D D D U U D U U D U D
  D D U U D U D D U D D D U U D U U D U D D U U U D U D D U D D U
  U U D U D D U D D D U U D U U D U D D D U U D U D D U D D;);
  numeric sz, bot;
  bot := 0;
  for n=1 upto 3:
    bot := min(bot, -.5(ypart urcorner g[n] - ypart llcorner g[n]));
  endfor
  x := 0; sz := 1;
  for n=1 upto 3:
    wd := xpart urcorner g[n] - xpart llcorner g[n];
    sz := 5*sz;
    draw g[n] shifted (x - xpart llcorner g[n],
                       -.5(ypart urcorner g[n] + ypart llcorner g[n]));
    label.bot("s=" & decimal sz, (x + .5wd, bot - 3));
    x := x + wd + 22;
  endfor
endfig;

end.
