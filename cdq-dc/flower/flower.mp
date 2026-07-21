% flower.mp -- CDQ 분할정복의 재귀 구조.
% 원소 16개짜리 배열의 처음 세 층: 층마다 점선이 구간을 반으로 가르고,
% 화살표는 "왼쪽 반이 오른쪽 반에 주는 기여"의 방향이다.
% flower.w의 동봉 그림; mpost flower.mp 로 flower.1 (EPS)을 만든다.

beginfig(1);
  numeric u, h, vgap;
  u := 7mm; h := 3.5mm; vgap := 12mm;

  % 구간 [xa,xb)를 깊이 d에 그린다: 상자, 가운데(xm) 점선, 왼반->오른반 화살표
  def cell(expr xa, xm, xb, d) =
    begingroup
      save yy; numeric yy; yy := -d*vgap;
      draw (xa*u,yy)--(xb*u,yy)--(xb*u,yy+h)--(xa*u,yy+h)--cycle;
      draw (xm*u,yy)--(xm*u,yy+h) dashed evenly;
      drawarrow ((xa+xm)/2*u, yy+h){dir 60} .. {dir -60}((xm+xb)/2*u, yy+h);
    endgroup
  enddef;

  cell(0, 8, 16, 0);
  cell(0, 4, 8, 1);   cell(8, 12, 16, 1);
  cell(0, 2, 4, 2);   cell(4, 6, 8, 2);
  cell(8, 10, 12, 2); cell(12, 14, 16, 2);

  % 맨 위 구간의 경계 표시
  label.bot(btex $l$ etex, (0, -1mm));
  label.bot(btex $m$ etex, (8u, -1mm));
  label.bot(btex $r$ etex, (16u, -1mm));

  % 재귀가 계속됨을 알리는 줄임표
  label(btex $\vdots$ etex, (8u, -2*vgap - 7mm));
endfig;

end
