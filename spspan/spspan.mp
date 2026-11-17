% spspan.mp -- 커누스의 spspan.mp(2003년 8월 28일)를 고쳐 쓴 그림 꾸러미.
% spspan.w 와 spgraph.w 가 `\everymplib{input ...spspan;}' 으로 읽어들인 뒤
% 이름으로 불러 쓴다.
%   fig_graph -- 식 ----ps-sp--sp 가 나타내는 직병렬 그래프 (원본의 그림 1)
%   fig_tree  -- 같은 그래프를 나타내는 나무 (원본의 그림 2)
%
% 원본과 다른 점:
% * 그림을 beginfig 그대로 두지 않고 매크로 fig_graph 와 fig_tree 로 감쌌다.
% * 그림 2의 이름표 매크로 \mbox 를 verbatimtex 로 정의하지 않고, 이름표마다
%   그 정의를 풀어 썼다. luamplib 은 이 파일을 읽을 때 btex 를 모두 미리
%   조판하므로, 첫 그림만 쓰는 문서에도 그 매크로가 있어야 하게 되기 때문이다.
% * 상자 정의 가운데 그림이 쓰지 않는 것(rect, diamond, drawbox, drawdbox,
%   cutat)은 뺐고, 끝의 bye. 도 뺐다.

% definitions for boxes
def box(expr wd,ht)(suffix $) =
  z$ne-z$nw=z$se-z$sw=(wd,0);
  z$ne-z$se=z$nw-z$sw=(0,ht);
  z$n=.5[z$nw,z$ne];
  z$e=.5[z$se,z$ne];
  z$s=.5[z$se,z$sw];
  z$w=.5[z$nw,z$sw];
  z$=.5[z$nw,z$se];
enddef;

picture pic[];
vardef picbox@# =
  box(xpart(urcorner pic@#-llcorner pic@#)+3pt,
      ypart(urcorner pic@#-llcorner pic@#)+3pt)(@#)
enddef;

vardef oval@# = z@#se-(.5ypart(z@#n-z@#s),0){right}..
  z@#e{up}..{left}z@#ne-(.5ypart(z@#n-z@#s),0)--
  z@#nw+(.5ypart(z@#n-z@#s),0){left}..
  z@#w{down}..{right}z@#sw+(.5ypart(z@#n-z@#s),0)--cycle enddef;

def drawobox (expr lbl)(suffix $) =
  erase fill oval$;
  draw oval$;
  label(lbl,z$);
enddef;

def fig_graph =
beginfig(1)
numeric h,w; h=.4in; w=.5in;
z1-z0=z2-z1=z3-z2=(w,0);
z1=-z2; z4=-z5;
z4-z5=z6=-z7=(0,h);
path p; p= z0{up}...z6{right}...z3{down}...z7{left}...cycle;
draw p;
draw z1{up}...z4{right}...z2{down}...z5{left}...cycle;
draw z0--z1; draw z2--z3;
pickup pencircle scaled 3pt;
for j=0,1,2,3,7: drawdot z[j]; endfor
label.top(btex$a$etex,z6);
label.top(btex$b$etex,.5[z0,z1]);
label.top(btex$c$etex,z4);
label.top(btex$d$etex,z5);
label.top(btex$e$etex,.5[z2,z3]);
label.top(btex$f$etex,point 3.3 of p);
label.top(btex$g$etex,point 2.7 of p);
endfig;
enddef;

def fig_tree =
beginfig(2)
w:=20pt; h:=18pt;
z0=origin;
z2=z0-(5pt,h);
y1=y2=y3; x3=.5[x7,x8]; x2-x1=4/5(x3-x2);
z5=z2-(0,h);
z6-z5=z5-z4=z7-z6=z8-z7=z10-z9=(w,0);
.5[z9,z10]=z5-(0,h);
draw z0--z1; draw z0--z2; draw z0--z3;
draw z2--z4; draw z2--z5; draw z2--z6; draw z3--z7; draw z3--z8;
draw z5--z9; draw z5--z10;
pic0=btex\hbox to1em{\hfil$A\mathstrut$\hfil}etex;
pic1=btex\hbox to1em{\hfil$a\mathstrut$\hfil}etex;
pic2=btex\hbox to1em{\hfil$B\mathstrut$\hfil}etex;
pic3=btex\hbox to1em{\hfil$D\mathstrut$\hfil}etex;
pic4=btex\hbox to1em{\hfil$b\mathstrut$\hfil}etex;
pic5=btex\hbox to1em{\hfil$C\mathstrut$\hfil}etex;
pic6=btex\hbox to1em{\hfil$e\mathstrut$\hfil}etex;
pic7=btex\hbox to1em{\hfil$f\mathstrut$\hfil}etex;
pic8=btex\hbox to1em{\hfil$g\mathstrut$\hfil}etex;
pic9=btex\hbox to1em{\hfil$c\mathstrut$\hfil}etex;
pic10=btex\hbox to1em{\hfil$d\mathstrut$\hfil}etex;
for j=0 upto 10:
  picbox[j];
  drawobox(pic[j],[j]);
endfor
endfig;
enddef;
