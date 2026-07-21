% robin.mp -- 펜윅 트리의 책임 구간 (n=16).
% 상자 t[i]는 구간 (i-lowbit(i), i]의 합을 책임지고, 상자 안의 수가 색인 i다.
% 회색 상자 셋은 접두사 합 sum(13) = t[13]+t[12]+t[8]의 분해.
% robin.w의 동봉 그림; mptopdf robin.mp 로 robin-1.pdf를 만든다.

beginfig(1);
  numeric u, h, dy;
  u := 7mm; h := 3.6mm; dy := 6mm;

  % 구간 (a, b]를 책임지는 상자를 높이 lev에 그린다
  def bar(expr a, b, lev, shaded) =
    begingroup
      save p; path p;
      p := (a*u, lev*dy)--(b*u, lev*dy)--(b*u, lev*dy+h)--(a*u, lev*dy+h)--cycle;
      if shaded: fill p withcolor .85white; fi
      draw p;
      label(decimal b, ((b-.5)*u, lev*dy+.5h));
    endgroup
  enddef;

  for i = 1 step 2 until 15: bar(i-1, i, 0, (i=13)); endfor  % lowbit 1
  for i = 2 step 4 until 14: bar(i-2, i, 1, false); endfor   % lowbit 2
  for i = 4 step 8 until 12: bar(i-4, i, 2, (i=12)); endfor  % lowbit 4
  bar(0, 8, 3, true);                                        % lowbit 8
  bar(0, 16, 4, false);                                      % lowbit 16
endfig;

end
