% bridge.mp -- 리차오 트리 노드의 결투.
% 노드 [l,r]의 한가운데 m에서 주인 g와 도전자 ell이 값을 겨룬다.
% m에서 낮은 g(찬 점)가 노드를 지키고, 진 ell(빈 점)은 제가 아직 낮은
% 데가 남은 왼쪽 반으로만 내려간다(화살표).
% bridge.w의 동봉 그림; mpost bridge.mp 로 bridge.1 (EPS)을 만든다.

beginfig(1);
  numeric u; u := 9mm;

  % 구간 [l,r]과 한가운데 m
  draw (0,0)--(10u,0);
  for xx = 0, 5, 10:
    draw (xx*u,0)--(xx*u,7u) dashed evenly scaled 0.7;
  endfor
  label.bot(btex $l$ etex, (0,-1mm));
  label.bot(btex $m$ etex, (5u,-1mm));
  label.bot(btex $r$ etex, (10u,-1mm));

  % 주인 g와 도전자 ell; 교차는 왼반에서 단 한 번
  draw (0,2.5u)--(10u,5.0u) withpen pencircle scaled 1pt;
  draw (0,2.0u)--(10u,6.4u) dashed evenly;
  label.rt(btex $g$ etex, (10u,5.0u));
  label.rt(btex $\ell$ etex, (10u,6.4u));

  % 한가운데의 결투: g가 이긴다
  fill fullcircle scaled 3.5bp shifted (5u,3.75u);
  draw fullcircle scaled 3.5bp shifted (5u,4.2u);

  % 진 직선은 왼쪽 반으로 내려간다
  drawarrow (4.7u,-8mm)--(0.3u,-8mm);
  label.bot(btex $\ell$ etex, (2.5u,-8.5mm));
endfig;

end
