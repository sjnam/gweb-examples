% ntt.mp -- figures for ntt.w (FFT/NTT).
%   fig 1: the evaluate-multiply-interpolate detour
%   fig 2: squaring folds the n-th roots of unity two-to-one
%   fig 3: the n=8 butterfly network (three stages: length 2, 4, 8)
% Build with: mptopdf ntt.mp  (-> ntt-1.pdf, -2.pdf, -3.pdf)

input boxes

% mptopdf runs mpost with --tex=latex, so a LaTeX preamble here lets
% btex...etex carry Korean (and spaces, which bare cmr10 labels cannot).
verbatimtex
\documentclass{article}
\usepackage{kotex}
\begin{document}
etex

% ---------------------------------------------------------------- fig 1
beginfig(1);
  boxit.tl(btex $A,\;B$ etex);
  boxit.tr(btex $C=AB$ etex);
  boxit.bl(btex $A(\omega^t),\;B(\omega^t)$ etex);
  boxit.br(btex $C(\omega^t)$ etex);
  tl.c = (0, 78);   tr.c = (215, 78);
  bl.c = (0, 0);    br.c = (215, 0);
  drawunboxed(tl, tr, bl, br);

  % the direct route we avoid
  drawarrow (tl.c -- tr.c cutbefore bpath.tl cutafter bpath.tr) dashed evenly;
  label.top(btex 계수끼리 직접 곱하기: $O(n^2)$ etex, (107, 82));

  % the detour
  drawarrow (tl.c -- bl.c cutbefore bpath.tl cutafter bpath.bl);
  label.lft(btex 평가 (FFT) etex, (-6, 42));
  drawarrow (bl.c -- br.c cutbefore bpath.bl cutafter bpath.br);
  label.bot(btex 점별 곱셈: $O(n)$ etex, (107, -6));
  drawarrow (br.c -- tr.c cutbefore bpath.br cutafter bpath.tr);
  label.rt(btex 보간 (FFT$^{-1}$) etex, (221, 42));
endfig;

% ---------------------------------------------------------------- fig 2
beginfig(2);
  numeric rr, rs, gap;
  rr := 46; rs := 32; gap := 205;
  pair L, R;
  L = (0,0); R = (gap, 0);

  % left: the eight 8th roots of unity, paired by antipodes
  draw fullcircle scaled 2rr shifted L;
  for k=0 upto 3:
    draw (L + rr*dir(45k)) -- (L + rr*dir(45k+180)) dashed evenly
      withcolor .6white;
  endfor
  for k=0 upto 7:
    fill fullcircle scaled 3.4 shifted (L + rr*dir(45k));
  endfor
  label.rt (btex $\omega^0$ etex, L + 1.1rr*dir(0));
  label.urt(btex $\omega^1$ etex, L + 1.1rr*dir(45));
  label.top(btex $\omega^2$ etex, L + 1.1rr*dir(90));
  label.ulft(btex $\omega^3$ etex, L + 1.1rr*dir(135));
  label.lft(btex $\omega^4$ etex, L + 1.1rr*dir(180));
  label.llft(btex $\omega^5$ etex, L + 1.1rr*dir(225));
  label.bot(btex $\omega^6$ etex, L + 1.1rr*dir(270));
  label.lrt(btex $\omega^7$ etex, L + 1.1rr*dir(315));
  label.top(btex 8차 단위근: 여덟 점 etex, L + (0, 1.35rr));

  % the squaring map
  drawarrow (L + 1.55rr*dir(0)) -- (R - 1.75rs*dir(0));
  label.top(btex $z\mapsto z^2$ etex, .5[L + 1.55rr*dir(0), R - 1.75rs*dir(0)]);

  % right: only four survive
  draw fullcircle scaled 2rs shifted R;
  for k=0 upto 3:
    fill fullcircle scaled 3.4 shifted (R + rs*dir(90k));
  endfor
  label.rt (btex $\omega^0$ etex, R + 1.15rs*dir(0));
  label.top(btex $\omega^2$ etex, R + 1.15rs*dir(90));
  label.lft(btex $\omega^4$ etex, R + 1.15rs*dir(180));
  label.bot(btex $\omega^6$ etex, R + 1.15rs*dir(270));
  label.top(btex 접혀서 네 점 etex, R + (0, 1.45rs));
endfig;

% ---------------------------------------------------------------- fig 3
beginfig(3);
  numeric xc[], yr[], dd;
  for c=0 upto 3: xc[c] := 62c; endfor
  for i=0 upto 7: yr[i] := (7-i)*18; endfor

  dd := 1;
  for s=0 upto 2:
    for i=0 upto 7:
      if (i mod (2dd)) < dd:
        draw (xc[s],yr[i])    -- (xc[s+1],yr[i]);
        draw (xc[s],yr[i])    -- (xc[s+1],yr[i+dd]);
        draw (xc[s],yr[i+dd]) -- (xc[s+1],yr[i]);
        draw (xc[s],yr[i+dd]) -- (xc[s+1],yr[i+dd]);
      fi
    endfor
    dd := 2dd;
  endfor
  for c=0 upto 3:
    for i=0 upto 7:
      fill fullcircle scaled 3.4 shifted (xc[c],yr[i]);
    endfor
  endfor

  % inputs, in bit-reversed order
  label.lft(btex $a_0$ etex, (xc[0]-4, yr[0]));
  label.lft(btex $a_4$ etex, (xc[0]-4, yr[1]));
  label.lft(btex $a_2$ etex, (xc[0]-4, yr[2]));
  label.lft(btex $a_6$ etex, (xc[0]-4, yr[3]));
  label.lft(btex $a_1$ etex, (xc[0]-4, yr[4]));
  label.lft(btex $a_5$ etex, (xc[0]-4, yr[5]));
  label.lft(btex $a_3$ etex, (xc[0]-4, yr[6]));
  label.lft(btex $a_7$ etex, (xc[0]-4, yr[7]));

  % outputs, in natural order
  label.rt(btex $A(\omega^0)$ etex, (xc[3]+4, yr[0]));
  label.rt(btex $A(\omega^1)$ etex, (xc[3]+4, yr[1]));
  label.rt(btex $A(\omega^2)$ etex, (xc[3]+4, yr[2]));
  label.rt(btex $A(\omega^3)$ etex, (xc[3]+4, yr[3]));
  label.rt(btex $A(\omega^4)$ etex, (xc[3]+4, yr[4]));
  label.rt(btex $A(\omega^5)$ etex, (xc[3]+4, yr[5]));
  label.rt(btex $A(\omega^6)$ etex, (xc[3]+4, yr[6]));
  label.rt(btex $A(\omega^7)$ etex, (xc[3]+4, yr[7]));

  % column headers and stage captions
  label(btex 입력 etex, (xc[0], yr[0]+16));
  label(btex 출력 etex, (xc[3], yr[0]+16));
  label.bot(btex $\ell=2$ etex, (.5[xc[0],xc[1]], -12));
  label.bot(btex $\ell=4$ etex, (.5[xc[1],xc[2]], -12));
  label.bot(btex $\ell=8$ etex, (.5[xc[2],xc[3]], -12));
endfig;
end.
