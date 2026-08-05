% wordcube.mp -- figure for wordcube.w.
%   fig 1: the example as a symmetric 5x5 array of words (a word square),
%          with the main diagonal shaded.  Reading a row, a column, or --
%          stacking the square into a cube -- a pillar all give words.
% Build with: mptopdf wordcube.mp  (-> wordcube-1.pdf)

% mptopdf runs mpost with --tex=latex, so a LaTeX preamble here lets
% btex...etex carry Korean (and spaces, which bare cmr10 labels cannot).
verbatimtex
\documentclass{article}
\usepackage{kotex}
\begin{document}
etex

defaultfont := "cmtt10";
defaultscale := 0.95;

beginfig(1);
  numeric w, h;
  w := 54; h := 20;
  string cell[][];
  cell[0][0]:="aster"; cell[0][1]:="scale"; cell[0][2]:="tacos"; cell[0][3]:="elope"; cell[0][4]:="reset";
  cell[1][0]:="scale"; cell[1][1]:="codex"; cell[1][2]:="adopt"; cell[1][3]:="leper"; cell[1][4]:="extra";
  cell[2][0]:="tacos"; cell[2][1]:="adopt"; cell[2][2]:="cover"; cell[2][3]:="opera"; cell[2][4]:="strap";
  cell[3][0]:="elope"; cell[3][1]:="leper"; cell[3][2]:="opera"; cell[3][3]:="perks"; cell[3][4]:="erase";
  cell[4][0]:="reset"; cell[4][1]:="extra"; cell[4][2]:="strap"; cell[4][3]:="erase"; cell[4][4]:="taper";
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
end.
