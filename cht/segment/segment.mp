% segment.mp -- 군웅할거의 지도: 선분들과 구간별 패자.
% 선분 넷이 등재된 어느 순간. 축 밑의 굵은 토막이 그 구간의 하늘을 지배하는
% 선분의 번호(질의의 답)다. 아무도 없는 하늘은 0이다.
% segment.w의 동봉 그림; mpost segment.mp 로 segment.1 (EPS)을 만든다.

beginfig(1);
  numeric u; u := 9mm;

  drawarrow (0,0)--(10.3u,0);
  label.bot(btex $x$ etex, (10.3u,-1mm));

  % 선분 넷
  draw (0.5u,3u)--(4u,5.5u);          % 1
  draw (2u,6u)--(5u,2.5u);            % 2
  draw (6u,4u)--(9.5u,4u);            % 3
  draw (3u,1.5u)--(8u,1u);            % 4
  label.rt(btex $1$ etex, (4u,5.5u));
  label.ulft(btex $2$ etex, (2u,6u));
  label.top(btex $3$ etex, (7.75u,4u));
  label.bot(btex $4$ etex, (5.5u,1.2u));

  % 구간별 패자: 경계 내림선(점선)과 패자 토막(굵은 선), 번호
  for xx = 0.5, 2, 3.03, 4, 5, 6, 9.5:
    draw (xx*u,0)--(xx*u,-0.8u) dashed withdots scaled 0.5;
  endfor
  def reign(expr xa, xb, no) =
    draw (xa*u,-0.8u)--(xb*u,-0.8u) withpen pencircle scaled 1.2pt;
    label.bot(no, ((xa+xb)/2*u, -0.9u));
  enddef;
  reign(0.5, 2, btex $1$ etex);
  reign(2, 3.03, btex $2$ etex);
  reign(3.03, 4, btex $1$ etex);
  reign(4, 5, btex $2$ etex);
  reign(5, 6, btex $4$ etex);
  reign(6, 9.5, btex $3$ etex);
  label.bot(btex $0$ etex, (0.2u,-0.9u));
  label.bot(btex $0$ etex, (9.85u,-0.9u));
endfig;

end
