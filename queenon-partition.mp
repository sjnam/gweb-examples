% queenon-partition.w의 그림 둘. 원본은 크누스의 queenon-partition.mp이다.
% 문서(luamplib)가 조판 중에 읽어 들이므로 bye. 는 없고, 그림마다 이름을 준다.

numeric N, n, u, h;
N := 4;
n := 17;
u := 1.2cm;
h := N*u/n;
primarydef x!y = (x*u,y*u) enddef;

% 잘라 돌린 눈금의 대각선들. 두 그림이 나눠 쓴다.
def diagonals =
  for i = 0 upto N-1:
    draw 0!i--(N-i)!N;
    draw i!0--N!(N-i);
    draw 0!(N-i)--(N-i)!0;
    draw i!N--N!i;
  endfor
enddef;

% 칸 [IJ]의 이름표와 그 이름표가 놓일 자리(칸의 중심).
string digs;
digs := "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
vardef lab(expr I, J) =
  ((substring (I,I+1) of digs) & (substring (J,J+1) of digs)) infont "cmtt10"
enddef;
vardef labloc(expr I, J) =
  save x, y;
  x = (I-J+N)/2;
  y = (I+J-N-1)/2;
  x!y
enddef;

% 그림 하나: N=4일 때의 칸 [IJ]들.
def fig_cells =
beginfig(0);
draw 0!0--N!0--N!N--0!N--cycle;
diagonals;
for i = 1 upto N:
  for j = N+1-i upto N+i: label(lab(i,j), labloc(i,j)); endfor
endfor
for i = N+1 upto 2N:
  for j = i-N upto 3N+1-i: label(lab(i,j), labloc(i,j)); endfor
endfor
endfig;
enddef;

% 그림 둘에 쓸 색칠. 프로그램이 뱉는 것과 똑같은 얼개다.
string ch;
picture pic[];
pic[ASCII "W"] := nullpicture;
currentpicture := nullpicture;
fill (0,0)--(h,0)--(h,h)--(0,h)--cycle withcolor red;
pic[ASCII "R"] := currentpicture;
fill (0,0)--(h,0)--(h,h)--(0,h)--cycle withcolor blue;
pic[ASCII "B"] := currentpicture;
fill (0,0)--(h,0)--(h,h)--(0,h)--cycle withcolor green;
pic[ASCII "G"] := currentpicture;
currentpicture := nullpicture;

numeric ny;
def row expr s =
  ny := ny+1;
  for j = 0 upto length s - 1:
    ch := substring (j,j+1) of s;
    draw pic[ASCII ch] shifted (j*h, ny*h);
  endfor
enddef;

% 그림 둘: N=4, n=17일 때의 대응 (ij) -> [IJ].
def fig_map =
beginfig(1);
ny := -1;
row "WGGGGBRRRWGGGBRRR"
row "WWGGBBBRWWWGBBBRW"
row "WWWBBBBGWWWRBBBGW"
row "WWRRBBGGGWRRRBGGG"
row "BRRRRGGGGBRRRWGGG"
row "BBRRWWGGBBBRWWWGG"
row "BBBWWWWBBBBGWWWRB"
row "BBGGWWRRBBGGGWWRR"
row "WGGGGRRRRGGGGBRRR"
row "WWGGBBRRWWGGGBBRR"
row "WWWBBBBWWWWGBBBGW"
row "WWRRBBGGWWWRBBBGG"
row "BRRRRGGGGWRRRBGGG"
row "BBRRWWGGGBRRRWGGG"
row "BBBWWWWGBBBRWWWGB"
row "BBGGWWWRBBBGWWWRB"
row "BGGGGWRRRBGGGWRRR"
for i = 0 upto n: draw (0,i*h)--(n*h,i*h); draw (i*h,0)--(i*h,n*h); endfor
diagonals;
endfig;
enddef;
