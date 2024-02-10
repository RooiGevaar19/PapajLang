unit PolyUtils;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils,
    ComplexNumbers, ArrayUtils,
    UnitStack, UnitEntity;

function buildLinearPoly(x : ComplexType) : TEntities;

function polynomial_value(poly : TEntities; x : ComplexType) : ComplexType;
function polynomial_degree(poly : TEntities) : LongInt;
procedure polynomial_truncate(var poly : TEntities);
function polynomial_isofIntegerCoefs(poly : TEntities) : Boolean;
function polynomial_isTrivial(poly : TEntities) : Boolean;
function polynomial_isPowerOfPoly(poly : TEntities) : LongInt;

function polynomial_sum(poly1 : TEntities; poly2 : TEntities) : TEntities;
function polynomial_diff(poly1 : TEntities; poly2 : TEntities) : TEntities;
function polynomial_mul(poly1 : TEntities; poly2 : TEntities) : TEntities;
function polynomial_div(poly1 : TEntities; poly2 : TEntities) : TEntities;
function polynomial_mod(poly1 : TEntities; poly2 : TEntities) : TEntities;
function polynomial_mul(poly : TEntities; x : ComplexType) : TEntities;
function polynomial_hornerdiv(poly : TEntities; x : ComplexType) : TEntities;

//function polynomial_roots(poly : TEntities; distinct : Boolean = True; realonly : Boolean = False) : TEntities;
procedure polynomial_roots(var poly : TEntities; var res : TEntities; distinct : Boolean = True; realonly : Boolean = False);
//procedure polynomial_roots(poly : TEntities; var res : TEntities; distinct : Boolean = True; realonly : Boolean = False);

function polynomial_derivative(poly : TEntities; grade : LongInt = 1) : TEntities;

implementation

uses MathUtils, Math;

//function generateIntegerDivisors(x : ComplexType) : TEntities;
//var
//    res  : TEntities;
//    i, j : LongInt;
//    size : LongInt = 0;
//begin
//    if x = 1 then
//    begin
//        SetLength(Result, 2);
//        Result[0] := buildNumber(1);
//        Result[1] := buildNumber(-1);
//        //Result := res;
//    end else begin
//        SetLength(res, size);
//        i := 1;
//        j := Int(x);
//        while (i*i <= j) do
//        begin
//            if (divides(j, i)) then 
//            begin
//                writeln(size);
//                SetLength(res, size+2);
//                writeln(size);
//                res[size]   := buildNumber(i);
//                res[size+1] := buildNumber(-i);
//                size := size+2;
//                writeln(size);
//                if (i*i <> j) then begin 
//                    res[size] := buildNumber(j div i);
//                    res[size+1] := buildNumber(-(j div i));
//                    size := size+2;
//                end;
//            end;
//            i := i + 1;
//        end;
//        Result := res;
//    end;
//end;

procedure genIntegerDivisors(var res : TEntities; x : ComplexType);
var
    i, j : LongInt;
    size : LongInt = 0;
begin
    if x = 1 then
    begin
        SetLength(res, 2);
        res[0] := buildNumber(1);
        res[1] := buildNumber(-1);
        //Result := res;
    end else begin
        SetLength(res, size);
        i := 1;
        j := Int(x);
        while (i*i <= j) do
        begin
            if (divides(j, i)) then 
            begin
                SetLength(res, size+2);
                res[size]   := buildNumber(i);
                res[size+1] := buildNumber(-i);
                size := size+2;
                if (i*i <> j) then begin 
                    SetLength(res, size+2);
                    res[size] := buildNumber(j div i);
                    res[size+1] := buildNumber(-(j div i));
                    size := size+2;
                end;
            end;
            i := i + 1;
        end;
    end;
end;


// polynomials
// move it to separate file

function buildLinearPoly(x : ComplexType) : TEntities;
var
    res  : TEntities;
begin
    SetLength(res, 2);
    res[0] := buildNumber(x);
    res[1] := buildNumber(1);
    Result := res;
end;

function polynomial_value(poly : TEntities; x : ComplexType) : ComplexType;
var
    res : ComplexType;
    i   : LongInt;
begin
    case polynomial_degree(poly) of
        -1 : begin
            Result := 0;
        end;
        0 : begin
            Result := poly[0].Num; 
        end;
        else begin
            res := poly[Length(poly)-1].Num;
            i := Length(poly)-2;
            while (i >= 0) do
            begin
                res := res * x + poly[i].Num;
                i := i-1;
            end;
            Result := res;
        end;
    end;
end;

function polynomial_degree(poly : TEntities) : LongInt;
var
    i : LongInt;
begin
    i := Length(poly)-1;
    while (i >= 0) do
    begin
        if not (poly[i].Num = 0) then break;
        i := i-1;
    end;
    Result := i;
    //if Length(poly) = 0 
    //    then Result := 0
    //    else Result := i;
end;

procedure polynomial_truncate(var poly : TEntities);
var
    n : LongInt;
begin
    n := polynomial_degree(poly);
    SetLength(poly, n+1);
end;

function polynomial_isofIntegerCoefs(poly : TEntities) : Boolean;
var
    i   : LongInt;
begin
    Result := True;
    for i := 0 to polynomial_degree(poly) do
        if not (isInteger(poly[i].Num)) then 
        begin
            Result := False;
            break;
        end;
end;

// is like ax^n + b
function polynomial_isTrivial(poly : TEntities) : Boolean;
var
    i   : LongInt;
begin
    Result := True;
    for i := 1 to polynomial_degree(poly)-1 do
        if not (ComplexNumbers.isZero(poly[i].Num)) then 
        begin
            Result := False;
            break;
        end;
end;

// is like ax^2n + bx^n + c
function polynomial_isPowerOfPoly(poly : TEntities) : LongInt;
var
    i, n : LongInt;
begin
    n := polynomial_degree(poly) div 2;
    if (i = 0) then 
    begin
        Result := -1;
        Exit;
    end;
    Result := n;
    for i := 1 to 2*n do
    begin
        if ((i mod n = 0) and (poly[i].Num = 0)) 
        or ((i mod n <> 0) and (poly[i].Num <> 0))
        then begin
            Result := -1;
            Exit;
        end;
    end;
end;

function polynomial_sum(poly1 : TEntities; poly2 : TEntities) : TEntities;
var
    res    : TEntities;
    flag   : ShortInt;
    mx, mn : LongInt;
    i      : LongInt;
begin
    if Length(poly1) > Length(poly2) then
    begin
        flag := 0;
        mx := Length(poly1);
        mn := Length(poly2);
    end else begin
        flag := 1;
        mx := Length(poly2);
        mn := Length(poly1);
    end; 
    SetLength(res, mx);
    for i := 0 to mn-1 do
        res[i] := buildNumber(poly1[i].Num + poly2[i].Num);
    if flag = 0 then
    begin
        for i := mn to mx-1 do
            res[i] := buildNumber(poly1[i].Num);
    end else begin
        for i := mn to mx-1 do
            res[i] := buildNumber(poly2[i].Num);
    end;
    polynomial_truncate(res);
    Result := res;
end;

function polynomial_diff(poly1 : TEntities; poly2 : TEntities) : TEntities;
var
    res    : TEntities;
    flag   : ShortInt;
    mx, mn : LongInt;
    i      : LongInt;
begin
    if Length(poly1) > Length(poly2) then
    begin
        flag := 0;
        mx := Length(poly1);
        mn := Length(poly2);
    end else begin
        flag := 1;
        mx := Length(poly2);
        mn := Length(poly1);
    end; 
    SetLength(res, mx);
    for i := 0 to mn-1 do
        res[i] := buildNumber(poly1[i].Num - poly2[i].Num);
    if flag = 0 then
    begin
        for i := mn to mx-1 do
            res[i] := buildNumber(poly1[i].Num);
    end else begin
        for i := mn to mx-1 do
            res[i] := buildNumber(-poly2[i].Num);
    end;
    polynomial_truncate(res);
    Result := res;
end;

function polynomial_mul(poly1 : TEntities; poly2 : TEntities) : TEntities;
// todo:
// make mul by constant
var
    res        : TEntities;
    m1, m2, mx : LongInt;
    i, j       : LongInt;
begin
    m1 := Length(poly1);
    m2 := Length(poly2);
    mx := m1 + m2 - 1;
    SetLength(res, mx);
    for i := 0 to mx-1 do
        res[i] := buildNumber(0);
    for i := 0 to m1-1 do
        for j := 0 to m2-1 do
            res[i+j] := buildNumber(res[i+j].Num + poly1[i].Num * poly2[j].Num);
    polynomial_truncate(res);
    Result := res;
end;

function divideLeads(poly1 : TEntities; poly2 : TEntities) : TEntities;
var
    n1, n2, n, i : LongInt; 
    res          : TEntities;
begin
    n1 := polynomial_degree(poly1);
    n2 := polynomial_degree(poly2);
    n := n1 - n2;
    SetLength(res, n + 1);
    for i := 0 to n-1 do
        res[i] := buildNumber(0);
    res[n] := buildNumber(poly1[n1].Num / poly2[n2].Num);
    Result := res;
end;


function polynomial_div(poly1 : TEntities; poly2 : TEntities) : TEntities;
var
    r, q, t : TEntities;
begin
    SetLength(q, 0);
    r := poly1;
    while (polynomial_degree(r) > 0) and (polynomial_degree(r) >= polynomial_degree(poly2)) do
    begin
        t := divideLeads(r, poly2);
        q := polynomial_sum(q, t);
        r := polynomial_diff(r, polynomial_mul(t, poly2));
    end;
    polynomial_truncate(q);
    Result := q;
end;

function polynomial_mod(poly1 : TEntities; poly2 : TEntities) : TEntities;
var
    r, q, t : TEntities;
begin
    SetLength(q, 0);
    r := poly1;
    while (polynomial_degree(r) > 0) and (polynomial_degree(r) >= polynomial_degree(poly2)) do
    begin
        t := divideLeads(r, poly2);
        q := polynomial_sum(q, t);
        r := polynomial_diff(r, polynomial_mul(t, poly2));
    end;
    polynomial_truncate(r);
    Result := r;
end;

function polynomial_mul(poly : TEntities; x : ComplexType) : TEntities;
var
    res  : TEntities;
    i, n : LongInt;
begin
    n := polynomial_degree(poly);
    SetLength(res, n+1);
    for i := 0 to n do
    begin
        res[i] := buildNumber(poly[i].Num * x);
    end;
    Result := res;
end;

function polynomial_hornerdiv(poly : TEntities; x : ComplexType) : TEntities;
var
    res  : TEntities;
    i, n : LongInt;
begin
    n := polynomial_degree(poly);
    SetLength(res, n);
    res[n-1] := buildNumber(poly[n].Num);
    for i := n-2 downto 0 do
        res[i] := buildNumber(res[i+1].Num*x+poly[i+1].Num);
    Result := res;
end;

// assume P(x) is divisible by (x-x0)
procedure polynomial_phornerdiv(var poly : TEntities; x : ComplexType);
var
    i, n : LongInt;
begin
    n := polynomial_degree(poly);
    for i := 0 to n-1 do
        poly[i] := buildNumber(poly[i+1].Num);
    SetLength(poly, n);
    for i := n-2 downto 0 do
        poly[i] := buildNumber(poly[i+1].Num*x+poly[i].Num);
end;


// toadd:
// newton coefficients
// cardano 
// quartic

procedure polynomial_roots(var poly : TEntities; var res : TEntities; distinct : Boolean = True; realonly : Boolean = False);
//procedure polynomial_roots(poly : TEntities; var res : TEntities; distinct : Boolean = True; realonly : Boolean = False);
var
    //x, y, d : TEntities;
    x     : TEntities;
    y, d  : TEntities;
    a, b  : TEntities;
    delta : ComplexType;
    p, q  : ComplexType;
    u, v  : ComplexType;
    e, f  : ComplexType;
    n, i  : LongInt; 
    j, k  : LongInt;
    size  : LongInt;
    flag  : Boolean;
begin
    size := Length(res);
    // todo: consider
    //       scale polynomials
    //       newton-pascal coefs polynomials
    //       approximate root finding when nothing is found
    // todo: improve searching through integer divisors
    case polynomial_degree(poly) of
        -1 : begin
            // all complex numbers
            SetLength(res, size+1);
            //res[size] := buildNumber(NaN);
            if realonly 
                then res[size] := buildString('real_numbers')
                else res[size] := buildString('complex_numbers');
            size := size+1;
        end;
        0 : begin
            // no solutions
            SetLength(res, size);
        end;
        1 : begin
            SetLength(res, size+1);
            res[0] := buildNumber(-poly[0].Num/poly[1].Num);
        end;
        2 : begin
            delta := Sqr(poly[1].Num) - 4 * poly[2].Num * poly[0].Num;
            SetLength(res, size+2);
            res[size] := buildNumber((-poly[1].Num-Sqrt(delta))/(2*poly[2].Num));
            res[size+1] := buildNumber((-poly[1].Num+Sqrt(delta))/(2*poly[2].Num));
        end;
        3 : begin
            if (isReal(poly[0].Num)) and (isReal(poly[1].Num))
            and (isReal(poly[2].Num)) and (isReal(poly[3].Num)) then
            begin
                if (poly[3].Num = 1) and (poly[2].Num = 0) then
                begin
                    p := poly[1].Num;
                    q := poly[0].Num;
                end else begin
                    p := poly[1].Num/poly[3].Num - Sqr(poly[2].Num)/(3*Sqr(poly[3].Num));
                    q := (2*Cub(poly[2].Num))/(27*Cub(poly[3].Num)) + poly[0].Num/poly[3].Num - (poly[2].Num*poly[1].Num)/(3*Sqr(poly[3].Num));
                end;
                delta := Sqr(q)/4 + Cub(p)/27;
                if 
                //(isReal(p)) and (isReal(q)) and 
                (Real(delta) >= 0)
                then begin
                    u := RealRoot(Real(Sqrt(delta)-0.5*q), 3);
                    v := RealRoot(Real(-Sqrt(delta)-0.5*q), 3);
                end else begin
                    u := Root(Sqrt(delta)-0.5*q, 3);
                    v := Root(-Sqrt(delta)-0.5*q, 3);
                end;
                e := ComplexNum(-0.5, -system.sqrt(3)/2);
                f := ComplexNum(-0.5, system.sqrt(3)/2);
                SetLength(res, size+3);
                res[size]   := buildNumber(u+v     -poly[2].Num/(3*poly[3].Num));
                res[size+1] := buildNumber(u*e+v*f -poly[2].Num/(3*poly[3].Num));
                res[size+2] := buildNumber(u*f+v*e -poly[2].Num/(3*poly[3].Num));
            end else begin
                e := Sqr(poly[2].Num) - 3*poly[3].Num*poly[1].Num; // delta_0
                f := 2*Cub(poly[2].Num) - 9*poly[3].Num*poly[2].Num*poly[1].Num + 27*Sqr(poly[3].Num)*poly[0].Num; // delta_1
                if (e = 0) and (f = 0) 
                then begin
                    u := -poly[2].Num/(3*poly[3].Num);
                    SetLength(res, size+3);
                    res[size]   := buildNumber(u);
                    res[size+1] := buildNumber(u);
                    res[size+2] := buildNumber(u);
                end else begin
                    delta := ComplexNumbers.Root((f + ComplexNumbers.Sqrt(Sqr(f) - 4*Cub(e)))/2, 3);
                    if delta = 0 then delta := ComplexNumbers.Root((f - ComplexNumbers.Sqrt(Sqr(f) - 4*Cub(e)))/2, 3);
                    u := -Inv(3*poly[3].Num)*(poly[2].Num + delta + e/delta);
                    SetLength(res, size+3);
                    // todo: try best to find real roots
                    res[size]   := buildNumber(u);
                    v := ComplexNum(-0.5, system.sqrt(3)/2);
                    delta := delta*v;
                    u := -Inv(3*poly[3].Num)*(poly[2].Num + delta + e/delta);
                    res[size+1] := buildNumber(u);
                    delta := delta*v;
                    u := -Inv(3*poly[3].Num)*(poly[2].Num + delta + e/delta);
                    res[size+2] := buildNumber(u);
                end;
            end;
        end;
        //4 : begin
        //end;
        else begin
            // work it out later
            SetLength(res, size);

            if (poly[0].Num = 0) then
            begin
                // todo: make it iterative
                SetLength(res, size+1);
                res[size] := buildNumber(0);
                a := buildLinearPoly(0);
                poly := polynomial_div(poly, a);
                polynomial_roots(poly, res, distinct, realonly); 
                //for i := 0 to Length(res)-1 do writeln(AnsiString(res[i].Num));
            end else if (polynomial_isTrivial(poly)) then
            begin
                n := polynomial_degree(poly);
                SetLength(res, size+n);
                if (isReal(poly[0].Num)) and (isReal(poly[n].Num))
                    then res[size] := buildNumber(RealRoot(-Real(poly[0].Num)/Real(poly[n].Num), n))
                    else res[size] := buildNumber(Root(-poly[0].Num/poly[n].Num, n));
                e := ComplexNumPolar(1, 2*C_PI/n);
                for i := 2 to n do
                begin
                    res[size+i-1] := buildNumber(res[size+i-2].Num * e);
                end;
            end else if (polynomial_degree(poly) mod 2 = 0) and (polynomial_isPowerOfPoly(poly) > -1) then begin
                n := polynomial_isPowerOfPoly(poly);
                poly[0] := buildNumber(poly[0].Num);
                poly[1] := buildNumber(poly[n].Num);
                poly[2] := buildNumber(poly[2*n].Num);
                for i := 3 to 2*n do
                    poly[i] := buildNumber(0);
                polynomial_truncate(poly);
                polynomial_roots(poly, res, False, False);
                size := Length(res);
                SetLength(res, size+2*n-2);
                //res[size-2] := buildNumber(Sqrt(res[size-2].Num));
                //res[size-1] := buildNumber(Sqrt(res[size-1].Num));
                if (isReal(poly[0].Num)) and (isReal(poly[1].Num)) and (isReal(poly[2].Num)) then 
                begin
                    res[size-2] := buildNumber(RealRoot(Real(res[size-2].Num), n));
                    res[size-1] := buildNumber(RealRoot(Real(res[size-1].Num), n));
                end else begin 
                    res[size-2] := buildNumber(Root(res[size-2].Num, n));
                    res[size-1] := buildNumber(Root(res[size-1].Num, n));
                end;
                e := ComplexNumPolar(1, 2*C_PI/n);
                for i := 1 to n-1 do
                begin
                    res[size+2*i-2] := buildNumber(res[size+2*i-4].Num * e);
                    res[size+2*i-1] := buildNumber(res[size+2*i-3].Num * e);
                end;
            end else if (polynomial_isofIntegerCoefs(poly)) then begin
                // todo: fix it
                n := polynomial_degree(poly);
                p := poly[0].Num; 
                q := poly[n].Num;
                SetLength(x, 0);
                genIntegerDivisors(x, Abs(p*q));
                flag := True;
                e := 0;
                f := 1;
                i := 0; 
                k := 0;
                // todo: do something if nothing is found
                while flag and (k < n) do
                begin
                    while flag and (i < Length(x)) do
                    begin
                        j := 0;
                        while flag and (j < Length(x)) do
                        begin
                            if (x[j].Num = 0) then
                            begin
                                j := j+1;
                                continue;
                            end;
                            e := x[i].Num/x[j].Num * f;
                            if (polynomial_value(poly, e) = 0) then
                            begin
                                flag := False;
                                break;
                            end;
                            j := j+1;
                        end;
                        i := i+1;
                    end;
                    f := f * ComplexNumPolar(1, 2*C_PI/n);
                    k := k+1;
                end;
                SetLength(x, 0);
                // -----------------------------------------------------------------
                if not Flag then
                begin
                    repeat
                        polynomial_phornerdiv(poly, e);
                        SetLength(res, size+1);
                        res[size] := buildNumber(e);
                        size := size+1;
                    until (polynomial_value(poly, e) <> 0) or (polynomial_degree(poly) = 2);
                    polynomial_roots(poly, res, false, false);
                    Flag := True;
                end else begin
                    //for i := 0 to Length(poly)-1 do
                    //    write(AnsiString(poly[i].Num)+' ');
                    //writeln('no other root found');
                    SetLength(res, size+1);
                    //res[size] := buildNumber(NaN);
                    res[size] := buildString('unknown_roots');
                    size := size+1;
                end;
            end;
        end;
    end;
    if (Length(res) > 0) and (distinct) then
        res := table_distinct(res); 
end;

function polynomial_derivative(poly : TEntities; grade : LongInt = 1) : TEntities;
var
    res  : TEntities;
    i, n : LongInt;
begin
    if polynomial_degree(poly) <= 0 then
    begin
        SetLength(res, 0);
        Result := res;
        Exit;
    end;
    while (grade >= 1) do
    begin
        n := polynomial_degree(poly);
        SetLength(res, n);
        for i := n-1 downto 0 do
            res[i] := buildNumber(poly[i+1].Num*(i+1));
        poly := res;
        grade := grade - 1;
    end;
    polynomial_truncate(res);
    Result := res;
end;

end.