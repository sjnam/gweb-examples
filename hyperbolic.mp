% hyperbolic.mp -- hyperbolic.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input hyperbolic;` 으로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_triangle -- 삼각형 ABC와 되비추어 얻은 세 이웃
%   fig_annulus  -- 고리 하나에 놓인 무늬          (hyperbolic-arcs.mp)
%   fig_dual     -- 그것을 |z|=1/r 에 되비춘 것    (hyperbolic-arcs.mp)
%   fig_tiling   -- 오른쪽 반평면 전체의 무늬      (hyperbolic-arcs.mp)
%
% 뒤의 세 그림은 손으로 적은 것이 아니라 hyperbolic.go 가 뱉은 것이다:
%     go run hyperbolic.go hyperbolic-arcs.mp
% 원본에서 Knuth는 이 좌표들을 프로그램 출력에서 따로 뽑아 .mp 에 붙여 두었는데,
% 여기서는 프로그램이 직접 적는다.

numeric u; u := 4.3in;          % 사분원의 반지름

% x축 위 (c,0)에 중심을 둔 반지름 r 의 반원 --- 곧 쌍곡 평면의 '직선' 하나.
def arc(expr c,r) =
 draw (((r,0){up}..(r*cosd30,r*sind30)..(r*cosd60,r*sind60)..(0,r)..
              (-r*cosd60,r*sind60)..(-r*cosd30,r*sind30)..(-r,0){down})
   shifted (c,0)) scaled u;
enddef;

% 그린 것을 오른쪽 위 사분원으로 잘라 내고, 테두리를 두른다.
def quarter =
 clip currentpicture to ((0,0)--(1,0){up}..(cosd30,sind30)..
         (cosd60,sind60)..(0,1){left}--cycle) scaled u;
 draw((1,0){up}..(cosd30,sind30)..(cosd60,sind60)..(0,1){left}) scaled u;
 draw (0,0)--(0,u);
 setbounds currentpicture to ((0,0)--(u,0)--(u,u)--(0,u)--cycle);
enddef;

def fig_triangle =
beginfig(1);                    % 삼각형과 그 세 이웃
numeric s; (1685-72)*s=2.6in;

z1=(0,1000) scaled s;
z2=(-500,500) scaled s;
z3=(500,500) scaled s;
z12=(-222,797) scaled s;
z23=(85,519) scaled s;
z31=(245,735) scaled s;
z123=(0,72) scaled s;
z231=(491,1364) scaled s;
z312=(-483,1685) scaled s;
z1231=(220,1176) scaled s;
z2312=(-518,1144) scaled s;
z3123=(229,302) scaled s;
z1223=(-204,246) scaled s;
z2331=(448,888) scaled s;
z3112=(-242,1309) scaled s;

draw (z1..z12..z2);
draw (z2..z23..z3);
draw (z3..z31..z1);
draw (z1..z1231..z231) dashed evenly scaled 1/2;
draw (z231..z2331..z3) dashed evenly scaled 1/2;
draw (z2..z2312..z312) dashed evenly scaled 1/2;
draw (z312..z3112..z1) dashed evenly scaled 1/2;
draw (z3..z3123..z123) dashed evenly scaled 1/2;
draw (z123..z1223..z2) dashed evenly scaled 1/2;

labeloffset:=5pt;
pickup pencircle scaled 2pt;
drawdot z1;
label.top(btex $A$ etex,z1+(0,3pt));
drawdot z2;
label.lft(btex $B$ etex,z2);
drawdot z3;
label.rt(btex $C$ etex, z3);
drawdot z123;
label.bot(btex $A'$ etex,z123);
drawdot z231;
label.rt(btex $B'$ etex, z231);
drawdot z312;
label.lft(btex $C'$ etex, z312);
label.lft(btex $\scriptstyle90$ etex,z1);
label.bot(btex $\scriptstyle90$ etex,z1);
label.rt (btex $\scriptstyle90$ etex,z1);
label.urt(btex $\scriptstyle45$ etex,z2+(-2pt,8pt));
label.urt(btex $\scriptstyle45$ etex,z2+(6pt,0));
label.lrt(btex $\scriptstyle45$ etex,z2+(6pt,2pt));
label.llft(btex $\scriptstyle36$ etex,z3-(6pt,-2pt));
label.ulft(btex $\scriptstyle36$ etex,z3-(6pt,0));
label.ulft(btex $\scriptstyle36$ etex,z3+(0,8pt));
label.lrt(btex $\scriptstyle36$ etex,z312-(4pt,10pt));
label.llft(btex $\scriptstyle45$ etex,z231-(1pt,6pt));
label.top(btex $\scriptstyle90$ etex,z123+(0,1pt));
endfig;
enddef;

input hyperbolic-arcs;
