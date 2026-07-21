% frog.mp -- 직선들의 아래 포락선(볼록 껍질 트릭).
% 가는 직선들이 돌들이 내건 후보이고, 굵은 꺾은선이 아래 포락선이다.
% 속 빈 점은 담당 직선이 바뀌는 곳, 채운 점은 질의 x=h_i의 답,
% 점선 직선은 이웃들에 가려 어느 구간도 얻지 못한 직선이다.
% frog.w의 동봉 그림; mpost frog.mp 로 frog.1 (EPS)을 만든다.

beginfig(1);
  numeric u; u := 9mm;

  % y = m*x + b 를 x in [0,10] 구간에서 그린 선분
  def ln(expr m, b) = ((0, b*u)--(10u, (10m+b)*u)) enddef;

  draw ln(-0.10, 5.4);
  draw ln(-0.48, 6.16);
  draw ln(-0.72, 7.24);
  draw ln(-1.5, 12.7);
  draw ln(-0.6, 6.9) dashed evenly;

  % 아래 포락선
  draw (0,5.4u)--(2u,5.2u)--(4.5u,4.0u)--(7u,2.2u)--(8.467u,0)
    withpen pencircle scaled 1.2pt;

  clip currentpicture to (0,0)--(10u,0)--(10u,7u)--(0,7u)--cycle;

  % 좌표축
  drawarrow (0,0)--(10.6u,0);
  drawarrow (0,0)--(0,7.5u);
  label.bot(btex $x$ etex, (10.6u, -1mm));
  label.lft(btex $y$ etex, (-1mm, 7.5u));

  % 질의 지점과 그 답
  draw (5.5u,0)--(5.5u,3.28u) dashed withdots scaled 0.5;
  fill fullcircle scaled 3.5bp shifted (5.5u, 3.28u);
  label.bot(btex $h_i$ etex, (5.5u, -1mm));

  % 포락선에서 담당이 바뀌는 곳들
  for p = (2u,5.2u), (4.5u,4.0u), (7u,2.2u):
    fill fullcircle scaled 3bp shifted p withcolor white;
    draw fullcircle scaled 3bp shifted p;
  endfor
endfig;

end
