% matula.mp -- matula.w의 S, T, S⊂T 나무 그림.
%
% 나무마다 두 가지를 적는다. 하나는 마디가 격자의 어디에 앉는지를 그림 그대로
% 보이는 행 문자열이고(`.'은 빈 칸이다), 하나는 matula.go가 명령줄에서 받는 것과
% 똑같은 부모 포인터 문자열이다. 마디 이름은 0..9, a..z, A..Z로 0부터 61까지다.

numeric u, dia;
u   := 13.94766;                        % 격자 눈금
dia :=  8.96634;                        % 동그라미 지름
color pale; pale = 0.5white;            % 안 쓰는 부분의 빛깔

% 마디 번호로 찾아 쓰는 이름표. btex를 쓰므로 글꼴은 문서가 정한다.
picture lab[];
lab[ 0]=btex \tt 0 etex; lab[ 1]=btex \tt 1 etex; lab[ 2]=btex \tt 2 etex; lab[ 3]=btex \tt 3 etex;
lab[ 4]=btex \tt 4 etex; lab[ 5]=btex \tt 5 etex; lab[ 6]=btex \tt 6 etex; lab[ 7]=btex \tt 7 etex;
lab[ 8]=btex \tt 8 etex; lab[ 9]=btex \tt 9 etex; lab[10]=btex \tt a etex; lab[11]=btex \tt b etex;
lab[12]=btex \tt c etex; lab[13]=btex \tt d etex; lab[14]=btex \tt e etex; lab[15]=btex \tt f etex;
lab[16]=btex \tt g etex; lab[17]=btex \tt h etex; lab[18]=btex \tt i etex; lab[19]=btex \tt j etex;
lab[20]=btex \tt k etex; lab[21]=btex \tt l etex; lab[22]=btex \tt m etex; lab[23]=btex \tt n etex;
lab[24]=btex \tt o etex; lab[25]=btex \tt p etex; lab[26]=btex \tt q etex; lab[27]=btex \tt r etex;
lab[28]=btex \tt s etex; lab[29]=btex \tt t etex; lab[30]=btex \tt u etex; lab[31]=btex \tt v etex;
lab[32]=btex \tt w etex; lab[33]=btex \tt x etex; lab[34]=btex \tt y etex; lab[35]=btex \tt z etex;
lab[36]=btex \tt A etex; lab[37]=btex \tt B etex; lab[38]=btex \tt C etex; lab[39]=btex \tt D etex;
lab[40]=btex \tt E etex; lab[41]=btex \tt F etex; lab[42]=btex \tt G etex; lab[43]=btex \tt H etex;
lab[44]=btex \tt I etex; lab[45]=btex \tt J etex; lab[46]=btex \tt K etex; lab[47]=btex \tt L etex;
lab[48]=btex \tt M etex; lab[49]=btex \tt N etex; lab[50]=btex \tt O etex; lab[51]=btex \tt P etex;
lab[52]=btex \tt Q etex; lab[53]=btex \tt R etex; lab[54]=btex \tt S etex; lab[55]=btex \tt T etex;
lab[56]=btex \tt U etex; lab[57]=btex \tt V etex; lab[58]=btex \tt W etex; lab[59]=btex \tt X etex;
lab[60]=btex \tt Y etex; lab[61]=btex \tt Z etex;

vardef nodenum(expr c) =                % 이름 한 글자를 마디 번호로
  if ASCII c <= ASCII "9": ASCII c - ASCII "0"
  elseif ASCII c <= ASCII "Z": ASCII c - ASCII "A" + 36
  else: ASCII c - ASCII "a" + 10 fi
enddef;

pair pos[];                             % 나무의 마디마다 그 자리
pair img[];                             % S의 마디가 심긴 자리

% 행 문자열들을 읽어 마디 자리를 정한다. 왼쪽 위가 첫 칸이고 아래로 내려간다.
vardef layout(text rows) =
  save r; numeric r; r := 0;
  for s = rows:
    r := r + 1;
    for c = 1 upto length s:
      if (substring (c-1,c) of s) <> ".":
        pos[nodenum(substring (c-1,c) of s)] := ((c-1)*u, -(r-1)*u);
      fi
    endfor
  endfor
enddef;

% 마디 k를 그 부모와 잇는다. 뿌리의 부모 자리에는 `.'이 있으므로 1부터 센다.
def edges(suffix p)(expr dad, col) =
  for k = 1 upto length(dad) - 1:
    draw p[k] -- p[nodenum(substring (k,k+1) of dad)] withcolor col;
  endfor
enddef;

def disks(suffix p)(expr n, col) =      % 이름 없는 동그라미 n개
  for k = 0 upto n - 1:
    unfill fullcircle scaled dia shifted p[k];
    draw fullcircle scaled dia shifted p[k] withcolor col;
  endfor
enddef;

def marks(suffix p)(expr n) =           % 동그라미마다 그 마디의 이름을 적는다
  for k = 0 upto n - 1:
    unfill fullcircle scaled dia shifted p[k];
    draw fullcircle scaled dia shifted p[k];
    label(lab[k], p[k]);
  endfor
enddef;

% S의 마디 0, 1, ...이 T의 어느 마디로 가는지 적은 문자열대로 자리를 옮긴다.
vardef embed(expr emb) =
  for k = 0 upto length(emb) - 1:
    img[k] := pos[nodenum(substring (k,k+1) of emb)];
  endfor
enddef;

string Sdad, Tdad;                      % matula.go에 주는 것과 같은 문자열
Sdad = ".0111444759a488cfch";
Tdad = ".011345676965cc5ffh5cklfn55qjstuuwxxwwuCCuFCpppqrtGOHJRLMNO";

def S_grid =
  layout("0126",
         "35478",
         "9bcde",
         "afghi")
enddef;

def T_grid =
  layout("028a...y",
         "1379bdzxAB",
         ".g46cemvwD",
         "ihf5jkluCE",
         "onpqrstFGH",
         ".IJKLMNOPQ",
         "..RSTUVW")
enddef;

def fig_S =
beginfig(0);
  S_grid;
  edges(pos)(Sdad, black);
  marks(pos)(length Sdad);
endfig;
enddef;

def fig_T =
beginfig(0);
  T_grid;
  edges(pos)(Tdad, black);
  marks(pos)(length Tdad);
endfig;
enddef;

% 굵게 그린 부분이 심긴 자리다. 심기는 matula.go가 찍는 답 그대로다.
def fig_ST =
beginfig(0);
  T_grid;
  edges(pos)(Tdad, pale);
  disks(pos)(length Tdad, pale);
  embed("DCEHuFvwxGOWtyzNVsj");
  edges(img)(Sdad, black);
  marks(img)(length Sdad);
endfig;
enddef;
