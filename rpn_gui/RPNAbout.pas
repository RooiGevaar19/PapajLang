unit RPNAbout;

interface

const RPN_version = 'X.X.X';
const RPN_update = 0;
const RPN_codename = 'Leviathan';
const RPN_generation = 3;
const RPN_isStable = False;
const RPN_date = {$I %DATE%};
const RPN_updated = '';
const RPN_targetCPU = {$I %FPCTARGETCPU%};
const RPN_targetOS = {$I %FPCTARGETOS%};
const RPN_apptype = 'Console';
const RPN_isGUI = false;

{$IFDEF cpu64}
type LongInt = Int64;
{$ENDIF}

implementation

end.
