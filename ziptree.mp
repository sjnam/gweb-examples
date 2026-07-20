% ziptree.mp -- Figure 1 of Tarjan, Levy & Timmel, "Zip Trees":
% insertion and deletion of key K (assigned rank 3).
% Companion figure for ziptree.w; build with: mptopdf ziptree.mp  (-> ziptree-1.pdf)

% mptopdf runs mpost with --tex=latex, so a LaTeX preamble here lets
% btex...etex carry Korean (and spaces, which bare cmr10 labels cannot).
verbatimtex
\documentclass{article}
\usepackage{kotex}
\begin{document}
etex

beginfig(1);
  numeric dx, dy, rr, xs;
  dx := 15; dy := 26; rr := 7.5; xs := 12*dx;

  % node-drawing macro: white disc, outline, key inside, rank outside the rim.
  % rankright=true puts the rank at the upper-right (for right children, whose
  % parent edge arrives from the upper-left); otherwise at the upper-left.
  def node(expr c, key, rk, rankright) =
    unfill fullcircle scaled (2rr) shifted c;
    draw fullcircle scaled (2rr) shifted c;
    label(key, c);
    if rankright: label.urt(rk, c + (0.6rr, 0.6rr));
    else: label.ulft(rk, c + (-0.6rr, 0.6rr)); fi
  enddef;

  % ---- left tree: before Insert K (= after Delete K) ----
  % inorder index -> x, depth -> y
  pair F,D,S,H,X,G,M,L,J;
  F = (1*dx, 0);
  D = (0*dx, -1*dy);  S = (7*dx, -1*dy);
  H = (3*dx, -2*dy);  X = (8*dx, -2*dy);
  G = (2*dx, -3*dy);  M = (6*dx, -3*dy);
  L = (5*dx, -4*dy);
  J = (4*dx, -5*dy);

  draw F--D;  draw F--S;  draw S--H;  draw S--X;
  draw H--G;  draw H--M;  draw M--L;  draw L--J;

  node(F,"F","4",false);                     % root
  node(D,"D","2",false); node(S,"S","4",true);  % children of F
  node(H,"H","2",false); node(X,"X","2",true);  % children of S
  node(G,"G","0",false); node(M,"M","2",true);  % children of H
  node(L,"L","1",false);                     % left child of M
  node(J,"J","0",false);                     % left child of L

  % ---- right tree: after Insert K (rank 3) ----
  pair Fr,Dr,Sr,Kr,Xr,Hr,Mr,Gr,Jr,Lr, o;
  o = (xs, 0);
  Fr = (1*dx,0)+o;
  Dr = (0*dx,-1*dy)+o;  Sr = (8*dx,-1*dy)+o;
  Kr = (5*dx,-2*dy)+o;  Xr = (9*dx,-2*dy)+o;
  Hr = (3*dx,-3*dy)+o;  Mr = (7*dx,-3*dy)+o;
  Gr = (2*dx,-4*dy)+o;  Jr = (4*dx,-4*dy)+o;  Lr = (6*dx,-4*dy)+o;

  draw Fr--Dr;  draw Fr--Sr;  draw Sr--Kr;  draw Sr--Xr;
  draw Kr--Hr;  draw Kr--Mr;  draw Hr--Gr;  draw Hr--Jr;  draw Mr--Lr;

  node(Fr,"F","4",false);                      % root
  node(Dr,"D","2",false); node(Sr,"S","4",true);  % children of F
  node(Xr,"X","2",true);                       % right child of S
  node(Hr,"H","2",false); node(Mr,"M","2",true);  % children of K
  node(Gr,"G","0",false); node(Jr,"J","0",true);  % children of H
  node(Lr,"L","1",false);                      % left child of M

  % the freshly inserted K, drawn in red
  unfill fullcircle scaled (2rr) shifted Kr;
  draw fullcircle scaled (2rr) shifted Kr withcolor (0.75,0,0);
  label("K", Kr) withcolor (0.75,0,0);
  label.ulft("3", Kr + (-0.7rr,0.7rr)) withcolor (0.75,0,0);

  % ---- arrows between the two trees ----
  numeric ya, yb;
  ya := -1.3*dy;  yb := -2.3*dy;
  drawarrow (8.7*dx, ya) -- (11.3*dx, ya);
  label.top(btex $K$ 삽입 etex, (10*dx, ya));
  drawarrow (11.3*dx, yb) -- (8.7*dx, yb);
  label.bot(btex $K$ 삭제 etex, (10*dx, yb));
endfig;
end.
