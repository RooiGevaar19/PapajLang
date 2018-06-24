program rpn;
uses Unit2, Unit5, UnitEntity, Sysutils;

procedure show_version();
begin
     writeln('RPN Calculator. Version X.X.X (Leviathan)');
     writeln('Paul Lipkowski. June 13, 2018.');
     writeln('Since 11/24/2017. Proudly written in FPC. :)');
     writeln('');
end;

procedure show_help();
begin
     writeln('SYNTAX: rpn "quoted_rpn_expression" [flags]');
     writeln('');
     writeln('Run ''rpn help'' or ''rpn'' to display this again.');
     writeln('Run ''rpn expression'' to obtain info about making RPN expressions.');
     writeln('Run ''rpn operands [page]'' to obtain info about available operands.');
     writeln('Run ''rpn parse (FILENAME)'' to parse a RPN script file');
     writeln('');
     writeln('More help at github.com/RooiGevaar19/RPNCalculator');
end;

procedure show_expressions;
begin
	writeln('EXPRESSIONS: ');
	writeln('Remember - the expression in console mode must be a "quoted" string');
	writeln('and each operation must be separated by 1 space.');
	writeln('');
	writeln('Type ''rpn operands'' to check out the available operands.');
	writeln('');
	writeln('EXAMPLES');
	writeln(' 6              -> 6');
	writeln(' 2+3            -> 2 3 +');
	writeln(' (12-6)/3.5     -> 12 6 - 3.5 /');
	writeln(' 5*(2-9)        -> 5 2 9 - *');
	writeln(' (12-4)/(4^0.5) -> 12 4 - 4 0.5 ^ /');
	writeln(' (2*PI)^E       -> 2 PI * E ^');
	writeln(' sin(5) + 1     -> 5 sin 1 +');
end;

procedure show_operands;
begin
	writeln('OPERANDS:');
	writeln('Page 1: Binary operands');
	writeln('Page 2: Unary operands');
	writeln('Page 3: Stack operations');
	writeln('Page 4: Constants');
	writeln('Page 5: Parsing directives');
	writeln('Page 6: Other');
	writeln;
	writeln('Type ''rpn operands [page_num]'' to obtain info about specific operands, e.g. ''rpn operands 1''');
	writeln('Type ''rpn operands all'' to print all pages at once.');
end;

// binary
procedure show_operands1();
begin
	writeln('Binary operands model: (expr1) (expr2) (operand), e.g. 2 4 +');
    writeln('Available binary operands:');
    writeln('       +       -       *       /     div');
    writeln('       ^     pow    root     log     mod');
    writeln('    cdiv    cmod  choose     gcd     lcm');
end;

// unary
procedure show_operands2();
begin
    writeln('Unary operands model: (expr0) (operand), e.g. 2 sin');
    writeln('Available unary operands:');
    writeln('     abs    sqrt     exp      ln       !    fact');
    writeln('     sin     cos     tan     csc     sec     cot');
    writeln('   trunc   round     inc     dec      ++      --');
    writeln();
    writeln(' X times - do the next thing X times');
    writeln('  X keep - Keep the top n values on the stack (e.g. "2 3 1 4 5 3 keep" results in a stack of "1 4 5")');
    writeln('  X copy - Copy the top n values on the stack (e.g. "2 3 1 4 5 3 copy" results in a stack of "2 3 1 4 5 1 4 5")');
    writeln(' X mcopy - Copy the top n values on the stack in reversed order (e.g. "2 3 1 4 5 3 mcopy" results in a stack of "2 3 1 4 5 5 4 1")');
end;

// stacks
procedure show_operands3();
begin
	writeln('Stack operations model (set of expressions put on the stack) (operand),'); 
	writeln('e.g. 5 2 3 + 7 sum => 5 5 7 sum => 17');
	writeln('Available stack operations:');
	writeln('       sum   product     count       avg');
	writeln('       min       max');
	writeln('Stack generators:');
	writeln('     seq    gseq    seql   gseql');
	writeln('Stack transformations:');
	writeln('   clone     rev');
end;

// constants
procedure show_operands4();
begin
    writeln('Available constants: ');
    writeln('      PI = ~3.1415926535897');
	writeln('      EU = ~2.7182818284590');
	writeln('      FI = ~1.6180339887498');
end;

procedure show_operands5();
begin
	writeln('Data directives: ');
	writeln('#real        #milli       #float');
	writeln('#double      #int         #decimal');
	writeln('#scientific  #scientific1 #money');
	writeln('#amoney');
	writeln('Parsing directives:');
	writeln('  #autoclear=BOOL  : Stack is wisely cleared after every operation (BOOL=true by default)');
	writeln('            =true  : After "2 3 +" the stack is "5", as 2 and 3 were removed after usage. ');
	writeln('            =false : After "2 3 +" the stack is "2 3 5", as 2 and 3 stay on the stack.');
	writeln('  #silent          : Don''t print the final stack output (it does not affect the outputs invoked by script before)');
	writeln('  #sorttype=VAL    : Choose a sorting algorithm (VAL=[0..3], 1 is default, 3 is risky)');
	writeln('  @source="FNAME"  : Use an another RPN script and execute its code directly on the main stack (FNAME is a quoted path to a filename)');
end;

procedure show_operands6();
begin
    writeln('Other operations: ');
    writeln('      rand : Get a random integer value from 0 to N-1 (execute "N rand")');
    writeln('      scan : Scan any value from input');
    writeln('   scannum : Scan a number from input');
    writeln('   scanstr : Scan a string from input');
    writeln('     print : Print a value being on the top of the stack');
    writeln('   println : Same as above and end the line.');
    writeln('    rprint : Print a value being on the top of the stack and remove it from this stack.');
    writeln('  rprintln : Same as above and end the line.');
    writeln('     clone : Clone the value being on the top of the stack');
    writeln('       rem : Remove a value from the top of the stack');
    writeln('      keep : Keep the top n values on the stack (e.g. "2 3 1 4 5  3 keep" results in a stack of "1 4 5")');
    writeln('        Xn : Do the next thing n times');
    writeln('        X* : Scan all the values from input (pre-made input usage recommended)');
    writeln('        // : One-line comment (when parsing files)');
end;


function read_file(filename : String; var sets : TSettings) : String;
var
  fun, S : String;
  fp     : Text;
begin
  fun := '';
  assignfile(fp, filename);
    reset(fp);
    while not eof(fp) do
    begin
      readln(fp, S);
      if (S <> '') then S := commentcut(S);
      fun := fun + ' ' + S;
    end;
    closefile(fp);
  read_file := calc_parseRPN(fun, sets);
end;

// main

var
   x, maska : String;
   sets     : TSettings;

{$R *.res}

begin
	randomize();
	case ParamCount of
		0 : begin
			show_version();
     		writeln('No arguments provided - run ''rpn help''');
		end;
		1 : begin
			case ParamStr(1) of
     			'help' : begin
     				show_version();
     				show_help();
     			end;
     			'expression' : begin
     				show_version();
     				show_expressions();
     			end;
     			'operands' : begin
     				show_version();
     				show_operands();
     			end
     			else begin
     				try
     					sets := default_settings();
     					x := calc_parseRPN(ParamStr(1), sets);
        				if (sets.Prevent = false) then writeln(x);
              		except
              			On E : Exception do
                 		begin
                      		writeln(StdErr, E.ToString);
                 		end;
              		end;
     			end;
     		end;
		end;
		else begin
			case ParamStr(1) of
				'operands' : begin
     				show_version();
     				case ParamStr(2) of
     					'1'	: show_operands1();
     					'2'	: show_operands2();
     					'3'	: show_operands3();
     					'4'	: show_operands4();
     					'5'	: show_operands5();
     					'6' : show_operands6();
     					'all': begin 
     						show_operands1(); writeln();
     						show_operands2(); writeln();
     						show_operands3(); writeln();
     						show_operands4(); writeln();
     						show_operands5(); writeln();
     						show_operands6();
     					end;
     				end;
     			end;
     			'parse' : begin
     				try
     					sets := default_settings();
     					x := read_file(ParamStr(2), sets);
        				if (sets.Prevent = false) then writeln(x);
              		except
              			On E : Exception do
                 		begin
                      		writeln(StdErr, E.ToString);
                 		end;
              		end;
     			end;
			end;
		end;
	end;
	
end.
