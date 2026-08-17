% back-20q.mp -- back-20q.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input back-20q;` 로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_order  -- 문제를 푸는 차례와, 그 차례가 지켜야 하는 앞뒤 관계
%   fig_prop   -- 이웃으로 번져 가는 강제
%   fig_answer -- 19점짜리 답안지
%
% btex 안에서는 |...| 를 쓸 수 없다(문서의 TeX이 그대로 조판해 버린다). 식별자는
% gwebmac의 \\{...} 로 적는다.

% s 안에 t번째 글자(A..E)가 들어 있는가? 있으면 그 자리, 없으면 -1.
vardef index_of(expr s, t) =
  save r, ch; numeric r; string ch;
  ch := substring (t,t+1) of "ABCDE";
  r := -1;
  for i=0 upto length(s)-1:
    if (substring (i,i+1) of s) = ch: r := i; fi
  endfor
  r
enddef;

picture dg[];
dg1 := btex $1$ etex;   dg2 := btex $2$ etex;   dg3 := btex $3$ etex;
dg4 := btex $4$ etex;   dg5 := btex $5$ etex;   dg6 := btex $6$ etex;
dg7 := btex $7$ etex;   dg8 := btex $8$ etex;   dg9 := btex $9$ etex;
dg10 := btex $10$ etex; dg11 := btex $11$ etex; dg12 := btex $12$ etex;
dg13 := btex $13$ etex; dg14 := btex $14$ etex; dg15 := btex $15$ etex;
dg16 := btex $16$ etex; dg17 := btex $17$ etex; dg18 := btex $18$ etex;
dg19 := btex $19$ etex; dg20 := btex $20$ etex;

picture al[];
al0 := btex A etex;  al1 := btex B etex;  al2 := btex C etex;
al3 := btex D etex;  al4 := btex E etex;

% ---------------------------------------------------------------- fig_order

% 푸는 차례. 왼쪽에서 오른쪽으로 order[1..20]이고, 위에 걸린 활은 "이 문제를
% 다루려면 저 문제가 이미 정해져 있어야 한다"는 뜻이다.
numeric ordr[], slot[];
def setuporder =
  ordr1:=3;   ordr2:=15;  ordr3:=20;  ordr4:=19;  ordr5:=2;
  ordr6:=1;   ordr7:=17;  ordr8:=10;  ordr9:=5;   ordr10:=4;
  ordr11:=16; ordr12:=11; ordr13:=13; ordr14:=14; ordr15:=7;
  ordr16:=18; ordr17:=6;  ordr18:=8;  ordr19:=12; ordr20:=9;
  for t=1 upto 20: slot[ordr[t]] := t; endfor
enddef;

numeric OW, OH; OW := 20bp; OH := 15bp;

% "a가 b보다 먼저"를 나타내는 활. gy가 참이면 흐리게 그린다.
def arc(expr a, b, hh, gy) =
  pair pa, pb;
  pa := ((slot[a]-1)*OW, .5OH+1bp);
  pb := ((slot[b]-1)*OW, .5OH+1bp);
  if gy: drawoptions(withcolor .68white); else: drawoptions(); fi
  drawarrow pa{up} .. (.5[pa,pb]+(0,hh)) .. {down}pb;
  drawoptions();
enddef;

def fig_order =
beginfig(1);
  setuporder;
  for t=1 upto 20:
    draw unitsquare xscaled (OW-4bp) yscaled OH shifted -(.5(OW-4bp),.5OH)
      shifted ((t-1)*OW, 0);
    draw thelabel(dg[ordr[t]], ((t-1)*OW, 0));
  endfor
  for t=2,3,5,7,11,13,17,19: arc(t,18,36bp,true); endfor
  arc(3,1,17bp,false);   arc(2,1,10bp,false);  arc(3,2,10bp,false);
  arc(3,15,10bp,false);  arc(20,19,10bp,false);
  arc(20,16,23bp,false); arc(2,16,17bp,false);
  arc(17,10,10bp,false);
  arc(1,4,10bp,false);   arc(15,4,29bp,false); arc(20,4,23bp,false);
  arc(10,4,10bp,false);
  label.top(btex 흐린 활 여덟은 소수 번호 문제들이 $18$번보다 먼저라는 뜻 etex,
    (9.5OW, .5OH+42bp));
endfig;
enddef;

% ---------------------------------------------------------------- fig_prop

% 5..9번에 남은 답이 CD, AC, BD, ABE, BCD 일 때 8번을 B로 못박으면 어떻게
% 번져 가는가. 위가 번지기 전, 아래가 번진 뒤.
string bef[], aft[];
def setupprop =
  bef5 := "CD"; bef6 := "AC"; bef7 := "BD"; bef8 := "ABE"; bef9 := "BCD";
  aft5 := "CD"; aft6 := "A";  aft7 := "D";  aft8 := "B";   aft9 := "CD";
enddef;

% 한 칸. s에 든 글자만 남긴다.
def cell(expr xx, yy, s) =
  draw unitsquare xscaled 34bp yscaled 17bp shifted -(17bp,8.5bp)
    shifted (xx,yy);
  numeric k; k := 0;
  for t=0 upto 4:
    if index_of(s, t) >= 0:
      draw thelabel(al[t], (xx - 17bp + 7bp + k*8bp, yy));
      k := k + 1;
    fi
  endfor
enddef;

def fig_prop =
beginfig(2);
  numeric W, V; W := 56bp; V := 54bp;
  setupprop;
  for t=5 upto 9:
    draw thelabel(dg[t], ((t-5)*W, .5V+17bp));
    cell((t-5)*W, .5V, bef[t]);
    cell((t-5)*W, -.5V, aft[t]);
  endfor
  label.lft(btex 번지기 전 etex, (-23bp, .5V));
  label.lft(btex 번진 뒤 etex, (-23bp, -.5V));
  drawarrow (3W, .5V-10bp) -- (3W, -.5V+10bp);
  label.rt(btex \ $8$번을 B로 못박으면 etex, (3W+3bp, 6bp));
  drawarrow (3W-19bp, -.5V+11bp){left} .. {left}(2W+19bp, -.5V+11bp);
  drawarrow (2W-19bp, -.5V+11bp){left} .. {left}(W+19bp, -.5V+11bp);
  drawarrow (3W+19bp, -.5V-12bp){right} .. {right}(4W-19bp, -.5V-12bp);
  label.top(btex $7$은 D뿐, 그러니 $6$은 A뿐 etex, (1.6W, -.5V+13bp));
  label.bot(btex $9$는 B를 잃는다 etex, (3.5W, -.5V-14bp));
endfig;
enddef;

% ---------------------------------------------------------------- fig_answer

% 19점짜리 답안지. 부르기 전에 sheet 에 답안지를, wrongq 에 틀린 문제 번호를
% 넣어 둔다(변경 파일이 다른 답안지로 바꿔 부를 수 있도록).
string sheet; numeric wrongq;
sheet := "DCEABEBCEABEAEDBDABB"; wrongq := 19;

def fig_answer =
beginfig(3);
  numeric R, W, V, X; R := 4.6bp; W := 15bp; V := 17bp; X := 128bp;
  for t=1 upto 20:
    numeric col, row, bx, by;
    col := if t <= 10: 0 else: 1 fi;
    row := if t <= 10: t-1 else: t-11 fi;
    bx := col*X;  by := -row*V;
    draw thelabel.lft(dg[t], (bx-7bp, by));
    for c=0 upto 4:
      draw fullcircle scaled 2R shifted (bx + c*W, by);
      if (substring (t-1,t) of sheet) = (substring (c,c+1) of "ABCDE"):
        fill fullcircle scaled (2R-1.6bp) shifted (bx + c*W, by);
      fi
    endfor
    if t = wrongq:
      draw (bx-36bp, by+4bp) -- (bx-28bp, by-4bp);
      draw (bx-36bp, by-4bp) -- (bx-28bp, by+4bp);
    fi
  endfor
  for c=0 upto 4:
    draw thelabel(al[c], (c*W, V-5bp));
    draw thelabel(al[c], (X + c*W, V-5bp));
  endfor
  label.bot(btex $\times$ 가 붙은 하나만 틀렸다---$19$점 etex,
    (.5X+2W, -9*V - 14bp));
endfig;
enddef;
