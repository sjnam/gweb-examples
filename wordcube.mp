% wordcube.mp -- wordcube.w 의 그림 꾸러미.
% luamplib이 문서 안에서 `input wordcube;` 로 읽어들인 뒤 이름으로 불러 쓴다.
%   fig_square -- 보기를 대칭인 5x5 낱말 배열(낱말 사각형)로 그린 것. 주대각선에
%                 음영을 넣었다. 가로줄, 세로줄, 그리고 사각형을 쌓아 세운
%                 기둥이 모두 낱말이 된다.
%   fig_cube   -- 같은 것을 진짜 5x5x5 글자 정육면체로, 등각 투영으로 그린 것.
%                 보이는 세 면에 글자를 얹고, 오른쪽 면에서 다섯 글자 한 줄을
%                 막대로 뽑아내어 세 번째 읽기 방향(속으로 들어가는 쪽)도
%                 눈에 보이게 했다.

defaultfont := "cmtt10";
defaultscale := 0.95;

% cell[i][j] is the word C_{ij*}; the table is symmetric.
string cell[][];
cell[0][0]:="aster"; cell[0][1]:="scale"; cell[0][2]:="tacos"; cell[0][3]:="elope"; cell[0][4]:="reset";
cell[1][0]:="scale"; cell[1][1]:="codex"; cell[1][2]:="adopt"; cell[1][3]:="leper"; cell[1][4]:="extra";
cell[2][0]:="tacos"; cell[2][1]:="adopt"; cell[2][2]:="cover"; cell[2][3]:="opera"; cell[2][4]:="strap";
cell[3][0]:="elope"; cell[3][1]:="leper"; cell[3][2]:="opera"; cell[3][3]:="perks"; cell[3][4]:="erase";
cell[4][0]:="reset"; cell[4][1]:="extra"; cell[4][2]:="strap"; cell[4][3]:="erase"; cell[4][4]:="taper";

def fig_square =
beginfig(1);
  numeric w, h;
  w := 54; h := 20;
  for i=0 upto 4:
    for j=0 upto 4:
      if i=j:
        fill (j*w,-(i+1)*h)--((j+1)*w,-(i+1)*h)--((j+1)*w,-i*h)--(j*w,-i*h)--cycle
          withcolor (1, 0.92, 0.78);
      fi
      label(cell[i][j], (j*w+.5w, -i*h-.5h));
    endfor
  endfor
  for k=0 upto 5:
    draw (k*w, 0)--(k*w, -5h);
    draw (0, -k*h)--(5w, -k*h);
  endfor
endfig;
enddef;

% ---- Isometric machinery for fig 2 ----------------------------------
% i runs down-left, j runs down-right, k runs up; q(i,j,k) projects a
% lattice point, and face(c,ea,eb) is the unit face centred at c.
pair ex, ey, ez;
vardef q(expr i, j, k) = i*ey + j*ex + k*ez enddef;
vardef face(expr c, ea, eb) =
  (c-.5ea-.5eb)--(c+.5ea-.5eb)--(c+.5ea+.5eb)--(c-.5ea+.5eb)--cycle
enddef;

color topc, rgtc, lftc, khi, ihi, holec, rodt, rodr, rodl;
topc := (1, 0.965, 0.90);      % top face  (k = 4)
rgtc := (0.985, 0.905, 0.775); % right face (j = 4)
lftc := (0.925, 0.815, 0.645); % left face  (i = 4)
khi  := (0.76, 0.885, 0.98);   % the word read upwards:  extra
ihi  := (0.80, 0.925, 0.76);   % the word read across:   strap
holec:= (0.42, 0.40, 0.37);    % the emptied cell
rodt := (1, 0.855, 0.755);     % the extracted rod: adopt
rodr := (0.965, 0.755, 0.635);
rodl := (0.885, 0.645, 0.525);

% one lettered cell of the cube's surface
def lettercell(expr c, ea, eb, col, ch) =
  fill face(c,ea,eb) withcolor col;
  draw face(c,ea,eb) withpen pencircle scaled .25bp withcolor .55white;
  label(ch, c);
enddef;

% one free-standing little cube, its letter written on the top face
def cubelet(expr c, ch) =
  fill face(c+.5ey, ex, ez) withcolor rodl;
  fill face(c+.5ex, ey, ez) withcolor rodr;
  fill face(c+.5ez, ex, ey) withcolor rodt;
  draw face(c+.5ey, ex, ez) withpen pencircle scaled .35bp;
  draw face(c+.5ex, ey, ez) withpen pencircle scaled .35bp;
  draw face(c+.5ez, ex, ey) withpen pencircle scaled .35bp;
  label(ch, c+.5ez);
enddef;

def fig_cube =
beginfig(2);
  numeric u;
  u := 20;                        % edge of one little cube
  ex := u*(cosd 30, -sind 30);
  ey := u*(-cosd 30, -sind 30);
  ez := u*(0, 1);

  % top face, k=4: the (i,j) cell holds letter j of the word cell[i][4]
  for i=0 upto 4:
    for j=0 upto 4:
      lettercell(q(i+.5,j+.5,5), ey, ex, topc, substring (j,j+1) of cell[i][4]);
    endfor
  endfor
  % left face, i=4: the (j,k) cell holds letter k of the word cell[4][j]
  for j=0 upto 4:
    for k=0 upto 4:
      lettercell(q(5,j+.5,k+.5), ex, ez, lftc, substring (k,k+1) of cell[4][j]);
    endfor
  endfor
  % right face, j=4: the (i,k) cell holds letter k of the word cell[i][4].
  % Column i=1 spells extra upwards, row k=2 spells strap down-left, and
  % the cell where they cross has been carried off with the rod.
  for i=0 upto 4:
    for k=0 upto 4:
      if (i=1) and (k=2):
        fill face(q(i+.5,5,k+.5), ey, ez) withcolor holec;
      elseif i=1:
        lettercell(q(i+.5,5,k+.5), ey, ez, khi, substring (k,k+1) of cell[i][4]);
      elseif k=2:
        lettercell(q(i+.5,5,k+.5), ey, ez, ihi, substring (k,k+1) of cell[i][4]);
      else:
        lettercell(q(i+.5,5,k+.5), ey, ez, rgtc, substring (k,k+1) of cell[i][4]);
      fi
    endfor
  endfor

  % silhouette, the three edges meeting at the near corner, and the rim
  % of the hole
  draw q(0,0,5)--q(0,5,5)--q(0,5,0)--q(5,5,0)--q(5,0,0)--q(5,0,5)--cycle
    withpen pencircle scaled .8bp;
  draw q(5,5,5)--q(0,5,5) withpen pencircle scaled .6bp;
  draw q(5,5,5)--q(5,0,5) withpen pencircle scaled .6bp;
  draw q(5,5,5)--q(5,5,0) withpen pencircle scaled .6bp;
  draw face(q(1.5,5,2.5), ey, ez) withpen pencircle scaled .5bp;

  % the rod: the five cells (1,j,2) slid out along +j, one letter each.
  % It clears the cube by two cells, so that it hides no letter; its axis
  % is dashed first, so it shows only in the gaps.
  draw q(1.5,5,2.5)--q(1.5,12.8,2.5) dashed evenly scaled .9
    withpen pencircle scaled .45bp withcolor .3white;
  for m=0 upto 4:
    cubelet(q(1.5, 7.6+m*1.3, 2.5), substring (m,m+1) of cell[1][2]);
  endfor

  % a little axis tripod, parked in the empty corner below left
  pair o;
  o := (-3.9u, -4.4u);
  drawarrow o--(o+.8ex) withpen pencircle scaled .5bp;
  drawarrow o--(o+.8ey) withpen pencircle scaled .5bp;
  drawarrow o--(o+.8ez) withpen pencircle scaled .5bp;
  label.bot(btex $j$ etex, o+.8ex);
  label.bot(btex $i$ etex, o+.8ey);
  label.top(btex $k$ etex, o+.8ez);
endfig;
enddef;

