{Program 11.6
find zero of a function by bisection}

{ * Since Pascal/  Z does not allow the use of procedural/          * }
{ * functional parameters, this program will not run under Pascal/Z * }

Program bisect;

const	eps = 1E-14;
var	x, y : real;

function zero( function f : real; a, b : real ) : real;
	var	x, z : real;
		s : boolean;
begin
	s := f( a ) < 0;
	repeat x := ( a + b )/2.0;
		z := f( x );
		if ( z < 0 ) = s then a := x else b := x
	until abs( a - b ) < eps;
	zero := x
end;		{zero}

begin		{main}
	read( x, y ); writeln( x, y, zero( sin, x, y ) );
	read( x, y ); writeln( x, y, zero( cos, x, y ) );
end.
                                                                                                                    