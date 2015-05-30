program exProcedure;
var
   a, b, c,  min: integer;
procedure findMin(var x, y, z: integer; var m: integer); 

begin
   if x < y then
      m:= x
   else
      m:= y;
   if z < m then
      m:= z;
end; 
begin
   write(' Enter three numbers: ');
   read( a, b, c);
   findMin(a, b, c, min); 
   write(' Minimum: ', min);
end.
