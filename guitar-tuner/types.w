% 이 파일은 여러 .w에서 @i로 공유하는 형식 힌트 모음이다.
% gweave가 외부 패키지 식별자를 '자료형'으로 예쁘게 조판하도록 알려 줄 뿐,
% gtangle(코드 추출)에는 아무 영향이 없다.

% 외부 상수
@d SIGTERM

% malgo 관련 형식
@s Context int
@s AllocatedContext int
@s ContextConfig int
@s Device int
@s DeviceConfig int
@s DeviceCallbacks int
@s DataProc int
@s Backend int

% 표준 라이브러리 형식
@s Builder int

% pitch 패키지가 정의하는 형식
@s Config int
@s pitch.Reading int
@s Result int
@s Stream int
@s GuitarString int
@s detector int
@s highpass int
@s onsetGate int
@s smoother int
@s locker int

% main 패키지 형식
@s screen int

% testing.T
@s testing.T int
