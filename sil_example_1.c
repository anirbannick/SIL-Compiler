decl

integer factorial(integer n);

enddecl

integer factorial (integer n) {

decl

integer rvalue;

enddecl

begin

if (n==1) then

rvalue = 1;

else

rvalue = n * factorial (n-1);

endif;

return rvalue;	

end

}

integer main( ){ 

decl

integer n,i ;

enddecl

begin

read (n);

i = 1;

while ( i <= n) do

write ( factorial(i));

i = i + 1;

endwhile;

return ;

end

}
