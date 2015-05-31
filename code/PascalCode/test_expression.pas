program exProcedure;
var
   a, b, c,  min: integer;
procedure findMin(var x, y, z: integer; var m: integer); 

begin
   if x < y then
      m:= x;
end; 
begin
   write(' Enter three numbers: ');
   read( a, b, c);
   findMin(a, b, c, min); 
   write(' Minimum: ', min);
end.
