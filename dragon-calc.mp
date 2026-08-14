% dragon-calc.mp -- dragon-calc.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input dragon-calc;` 로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_dragons -- 차수 1..5 의 종이접기 용, 그리고 차수 12 의 용
%   fig_general -- 일반화된 용. 단위 경로에 경로 01012 를 세 번 곱한 것(s=125)
% 아래의 D, U, O 매크로는 dragon-calc 의 `m' 명령이 뱉는 것과 똑같다. 그러니
% 이 그림들은 프로그램이 그리는 그대로 그려진다.

% btex 는 변수를 받지 못하므로, 라벨을 미리 그림으로 만들어 두고 골라 쓴다.
picture nlbl[], slbl[];
nlbl[1] := btex $n=1$ etex;  nlbl[2] := btex $n=2$ etex;
nlbl[3] := btex $n=3$ etex;  nlbl[4] := btex $n=4$ etex;
nlbl[5] := btex $n=5$ etex;
slbl[1] := btex $s=5$ etex;  slbl[2] := btex $s=25$ etex;
slbl[3] := btex $s=125$ etex;

numeric dd; pair rr, ww, zz;
def D = dd:=dd+90; ww:=zz; zz:=ww+rr rotated dd; draw ww--zz; enddef;
def U = dd:=dd-90; ww:=zz; zz:=ww+rr rotated dd; draw ww--zz; enddef;
def O = zz:=origin; dd:=-90; D; enddef;

% 차수 n의 용은 단위 경로에 *D 를 n 번 곱한 것이다. 그 접기열 F(n) 은
% F(n) = F(n-1) D G(n-1), G(n) = F(n-1) U G(n-1) 로 저절로 난다.
def Dn(expr n) = if n>0: Dn(n-1); D; Un(n-1); fi enddef;
def Un(expr n) = if n>0: Dn(n-1); U; Un(n-1); fi enddef;

def fig_dragons =
beginfig(1);
  picture p[], q;
  numeric wd, cw, x, top;
  rr := (7bp,0);
  for n=1 upto 5:
    p[n] := image(O Dn(n));
  endfor
  x := 0;
  for n=1 upto 5:
    % 칸 너비는 그림과 라벨 가운데 넓은 쪽. 둘 다 칸 한가운데 놓는다.
    wd := xpart urcorner p[n] - xpart llcorner p[n];
    cw := max(wd, xpart urcorner nlbl[n] - xpart llcorner nlbl[n]);
    draw p[n] shifted (x + .5(cw-wd) - xpart llcorner p[n],
                       -ypart llcorner p[n]);
    label.bot(nlbl[n], (x + .5cw, -4));
    x := x + cw + 14;
  endfor
  top := -36;
  rr := (2.6bp,0);
  drawoptions(withpen pencircle scaled .3bp);
  q := image(O Dn(12));
  draw q shifted (.5x - .5(xpart urcorner q + xpart llcorner q),
                  top - ypart urcorner q);
endfig;
enddef;

% 일반화된 용. 단위 경로에 경로 01012 를 거듭 곱한 것으로, 접기열은 프로그램의
% m 명령이 뱉은 것을 그대로 옮겼다.
def fig_general =
beginfig(2);
  picture g[];
  numeric wd, cw, x;
  rr := (9bp,0);
  g[1] := image(O D U D D;);
  g[2] := image(O D U D D D U U D U U D U D D D U U D U D D U D D;);
  rr := (5bp,0);
  g[3] := image(
  O D U D D D U U D U U D U D D D U U D U D D U D D D U U D U U D
  U D D U U U D U D D U D D U U U D U U D U D D D U U D U U D U D
  D D U U D U D D U D D D U U D U U D U D D U U U D U D D U D D U
  U U D U D D U D D D U U D U U D U D D D U U D U D D U D D;);
  numeric bot;
  bot := 0;
  for n=1 upto 3:
    bot := min(bot, -.5(ypart urcorner g[n] - ypart llcorner g[n]));
  endfor
  x := 0;
  for n=1 upto 3:
    wd := xpart urcorner g[n] - xpart llcorner g[n];
    cw := max(wd, xpart urcorner slbl[n] - xpart llcorner slbl[n]);
    draw g[n] shifted (x + .5(cw-wd) - xpart llcorner g[n],
                       -.5(ypart urcorner g[n] + ypart llcorner g[n]));
    label.bot(slbl[n], (x + .5cw, bot - 3));
    x := x + cw + 22;
  endfor
endfig;
enddef;

