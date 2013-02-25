

%{
    #include "sil_grammer.tab.h"
    #include <stdlib.h>
    int e=0;
    
    void yyerror(char *);

%}



letter	[a-zA-Z]
digit	[0-9]
num	{digit}+
id	(_|{letter})({letter}|{digit}|_)*
space	[ ]


%%



decl	         {return DECL;}
enddecl	         {return ENDDECL;}
begin	         {return BEGIN1;}
end	             {return END;}
integer	         {return INTEGER ;}
boolean	         {return BOOLEAN ;}
while	         {return WHILE ;}
do               {return DO ;}
endwhile	     {return ENDWHILE ;}
if	             {return IF ;}
then	         {return THEN ;}
else	         {return ELSE ;}
switch           {return SWITCH;}
case             {return CASE;}
endif	         {return ENDIF ;}
return	         {return RETURN ;}
read	         {return READ ;}
write	         {return WRITE ;}
main		     {return MAIN_FUNC ;}
"+"	             {return ADDOP ;}
"-"	             {return SUBOP ;}
"*"	             {return MULOP ;}
"/"	             {return DIVOP ;}
"%"	             {return MODOP ;}

TRUE             {/*yylval.name = malloc(100); strcpy(yylval.name,yytext);*/ yylval.value=1; return BOOLEAN_OP;}
FALSE	         {/*yylval.name = malloc(100); strcpy(yylval.name,yytext);*/ yylval.value=0; return BOOLEAN_OP;}

AND	             {return  AND ;}
NOT	             {return NOT ;}
OR	             {return OR ;}
"<"	             {return LT ;}
">"	             {return GT ;}
"=="	         {return EQ ;}
"<="	         {return LE ;}
">="	         {return GE ;}
"!="	         {return NE ;}
"="	             {return ASSIGNMENT_OP ;}
"["	             {return LEFT_SQR_BRACKET ;}
"]"	             {return RIGHT_SQR_BRACKET ;}
"("	             {return LEFT_ROUND_BRACKET ;}
")"	             {return RIGHT_ROUND_BRACKET ;}
"{"	             {return LEFT_CURLY_BRACKET ;}
"}"	             {return RIGHT_CURLY_BRACKET ;}
","	             {return SEPARATOR ;}
"&"              {return ADDRESS_OF ;}
":"              {return COLON ;}
";"	             {return TERMINATOR ;}

{id}             {yylval.name = yytext;  return ID;}
{num}            {yylval.value = atoi(yytext);  return NUM;}

[ \t]	         ;

((\/\*([^*]|(\n)|(\*+([^*/])))*\*+\/))|(\/\/(.)*)          ;

[\n]	         {linenumber++;}

.                yyerror("Unrecognized Character");


%%


int yywrap(void) 
{
    return 1;
}

