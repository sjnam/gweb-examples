% cash.mp -- 꾸러미 점들의 위 볼록 껍질과 질의의 접선.
% 점 하나가 어느 날 전 재산으로 산 금권 꾸러미 (x, y)다. 굵은 사슬이 위
% 껍질이고, 질의 (a,b)의 내적 최대는 기울기 -a/b의 접선(점선)이 닿는
% 꼭짓점(동그라미)에서 나온다. 안쪽 점들은 어떤 질의도 이길 수 없다.
% cash.w의 동봉 그림; mpost cash.mp 로 cash.1 (EPS)을 만든다.

beginfig(1);
  numeric u; u := 9mm;

  drawarrow (0,0)--(10.5u,0);
  drawarrow (0,0)--(0,8u);
  label.bot(btex $x$ etex, (10.5u,-1mm));
  label.lft(btex $y$ etex, (-1mm,8u));

  % 위 껍질
  draw (0.6u,2.2u)--(2u,4.6u)--(4u,6.2u)--(6.3u,6.9u)--(8.2u,6.3u)--(9.5u,4.6u)
    withpen pencircle scaled 1.2pt;

  % 꾸러미 점들(껍질 꼭짓점과 안쪽 점)
  for p = (0.6u,2.2u),(2u,4.6u),(4u,6.2u),(6.3u,6.9u),(8.2u,6.3u),(9.5u,4.6u),
      (1.8u,3.2u),(3.2u,4.9u),(5u,5.6u),(6u,5.2u),(7.4u,5.7u),(8.6u,4u),(4.8u,3.8u):
    fill fullcircle scaled 2.5bp shifted p;
  endfor

  % 질의의 접선과 그것이 닿는 꼭짓점
  draw (0,7.53u)--(10u,6.53u) dashed evenly;
  draw fullcircle scaled 6bp shifted (6.3u,6.9u);
  label.top(btex $-a_i/b_i$ etex, (2.2u,7.31u));
endfig;

end
