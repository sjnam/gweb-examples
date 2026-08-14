% back-pdi.mp -- figure for back-pdi.w.
%   fig 1: a worked BCD addition, 344159959 + 271828043 = 615988002,
%          with the carry columns shaded.
% Build with: mpost --tex=etex back-pdi.mp && mptopdf back-pdi.[0-9]*
%   (-> back-pdi-1.pdf)

% 라벨의 한글은 plain TeX 쪽 kotex(kotex-plain)이 맡는다. e-TeX 원시명령을
% 쓰므로 tex 이 아니라 etex 으로 돌려야 한다.
verbatimtex \input kotex.sty etex

beginfig(1);
  numeric w, h, y[];
  w := 20; h := 24;
  y0 := 56; y1 := 28; y2 := 0; % 윗 덧수, 아랫 덧수, 합
  string topd, botd, sumd;
  topd := "344159959";
  botd := "271828043";
  sumd := "615988002";

  % 자리올림이 난 칸(왼쪽에서 0-기준): 1,5,6,7,8
  boolean carry[];
  for c=0 upto 8: carry[c] := false; endfor
  carry[1] := true; carry[5] := true;
  carry[6] := true; carry[7] := true; carry[8] := true;
  for c=0 upto 8:
    if carry[c]:
      fill (c*w, y2-4)--((c+1)*w, y2-4)
        --((c+1)*w, y0+h+2)--(c*w, y0+h+2)--cycle withcolor (1, 0.92, 0.78);
    fi
  endfor

  % 세 줄의 자릿수
  for c=0 upto 8:
    label(substring(c,c+1) of topd, (c*w+.5w, y0+.5h));
    label(substring(c,c+1) of botd, (c*w+.5w, y1+.5h));
    label(substring(c,c+1) of sumd, (c*w+.5w, y2+.5h));
  endfor

  % 합 위의 가로줄과 더하기표
  draw (-.7w, y1-4)--(9w, y1-4);
  label.lft(btex $+$ etex, (-.35w, y1+.5h));

  % 오른쪽 끝에 자리 이름
  label.rt(btex 십진수 그대로 etex, (9w+.3w, y0+.5h));
  label.rt(btex 음영은 자리올림이 난 칸 etex, (9w+.3w, y2+.5h));
endfig;
end.
