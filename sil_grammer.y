%{

	#include <ctype.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parseTree.h"
	int yylex(void);
	void yyerror(char *s);
	int type;
	char nOFid[100];
	struct Tnode *t;
	char buffer[100];
	int z;

%}

%token DECL ENDDECL BEGIN END RETURN MAIN_FUNC 
%token INTEGER BOOLEAN NUM ID
%token IF THEN ELSE ENDIF WHILE DO ENDWHILE READ WRITE SWITCH CASE
%token ASSIGNMENT_OP ADDOP SUBOP MULOP DIVOP BOOLEAN_OP MODOP 
%token LE GE LT GT NE EQ AND NOT OR
%token LEFT_SQR_BRACKET RIGHT_SQR_BRACKET LEFT_ROUND_BRACKET RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET 
%token SEPERATOR TERMINATOR ADDRESS_OF COLON

%union {int value; char *name;  struct Tnode *n;}

%type <value>  BOOLEAN_OP NUM
%type <name> ID
%type <n> start global_declaration declarations typ item_list item argument_list parameters argument functions normal_function main_function  local_declaration l_declarations l_decl_list function_body expression statements statement assignment_statement conditional_statement iterative_statement input_output_statement int_var function_call parameter_list


%nonassoc NE LT LE EQ GT GE
%left OR AND 
%right NOT
%left ADDOP SUBOP
%left DIVOP MULOP
%right UMINUS

%%
start:
	global_declaration functions	 		
    | main_function				   
    ;

global_declaration:
    DECL declarations ENDDECL		
    ;

declarations:
	declarations typ item_list TERMINATOR	
	| 						
	;

typ:
	INTEGER					    {type = INT;}
	|BOOLEAN				    {type = BOOL;}
	;
	
item_list:
    item_list SEPERATOR item 	
	| item					           
	;
		

item:
	ID					       
	| ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET			
	| ID LEFT_ROUND_BRACKET argument_list RIGHT_ROUND_BRACKET				
	;


argument_list:
	argument_list typ  parameters				
	|argument_list typ  parameters TERMINATOR					  
	|
	;
	

	
parameters:
	parameters SEPERATOR argument  		      
	| argument
	;
	
argument :
          ID					       
		| ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET			
		|  ADDRESS_OF ID				
		;
           	



functions:
	normal_function main_function			
	; 

normal_function:
	 normal_function typ ID LEFT_ROUND_BRACKET argument_list RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET local_declaration function_body RIGHT_CURLY_BRACKET 	
	|						  
	;

main_function:
	INTEGER MAIN_FUNC LEFT_ROUND_BRACKET RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET main_body RIGHT_CURLY_BRACKET		
	              {$$=nodeCreate(INT,MAIN,"Main",0,$6,NULL,NULL);}
	;




main_body:
	  DECL  l_declarations ENDDECL BEGIN statements RETURN expression TERMINATOR END	
	         {$$=nodeCreate(VOID,MAIN_BODY_DECL,"Main_Body_with_Decl",0,$5, $7,NULL);}
	  | BEGIN statements RETURN expression TERMINATOR END 
	          {$$=nodeCreate(VOID,MAIN_BODY_ONLY,"Main_Body",0,$2, $4,NULL);}
	
	  ;


l_declarations :  
                 l_declarations typ l_decl_list TERMINATOR
                 |
                 ;
                 
                 
l_decl_list :  
               l_decl_list SEPARATOR ID
               |  ID
               ;                 

statements:
	statements statement 					
	       {$$=nodeCreate(VOID,STATEMENT,"Statements",0,$1,$2,NULL);}
	|						   
	    {$$=NULL;}
	;
statement:
           assignment_statement
                 {$$=nodeCreate(VOID,ASSGNMT_STMT,"Assignment_Stmt",0,$1,NULL,NULL);}
           | conditional_statement
                 {$$=nodeCreate(VOID,COND_STMT,"Conditional_Stmt",0,$1,NULL,NULL);}
           | iterative_statement
                  {$$=nodeCreate(VOID,ITER_STMT,"Iterative_Stmt",0,$1,NULL,NULL);}
           | input_output_statement
                 {$$=nodeCreate(VOID,IN_OUT_STMT,"Input_Output_Stmt",0,$1,NULL,NULL);}
           ;  

	
assingment_statement:
                  ID ASSIGNMENT_OP expression TERMINATOR				  
                                 {$$=nodeCreate(type,VAR,yyval.name,0,NULL,NULL,NULL);$$=nodeCreate(VOID,ASSGNMT_STMT,"ASGNStmt",0,t,$3,NULL)}
		  |ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET ASSIGNMENT_OP expression TERMINATOR		
				{t=nodeCreate(type,ARRAY,yyval.name,0,NULL,NULL,NULL);$$=nodeCreate(VOID,ASSGNMT_STMT,"ASGNStmt",0,t,$6,NULL);}
		;
 
conditional_statement:
                      IF LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET THEN statements ENDIF TERMINATOR		
                                 {$$=nodeCreate(VOID,COND_STMT,"IFStmt",0,$3,$6,NULL);}
		|IF LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET THEN statements ELSE statements ENDIF TERMINATOR	
		                {$$=nodeCreate(VOID,COND_STMT,"IFStmt",0,$3,$6,$8);}
		;
					
iterative_statement:
                    WHILE LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET DO statements ENDWHILE TERMINATOR 
                                {$$=nodeCreate(VOID,ITER_STMT,"WhileStmt",0,$3,$6,NULL);}
                                
		  ;
					
input_output_statement:					
	                 READ LEFT_ROUND_BRACKET ID RIGHT_ROUND_BRACKET TERMINATOR			    	   
	                            {$$=nodeCreate(VOID,IN_OUT_STMT,"ReadStmt",0,NULL,NULL,NULL);}
	                | WRITE LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET TERMINATOR				      
	                            {$$=nodeCreate(VOID,IN_OUT_STMT,"WriteStmt",0,NULL,NULL,NULL);}
	                ;
	
//int_var :  ID
  //         | ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET
    //       ;


	
					

expression:
	expression ADDOP expression					{$$=nodeCreate(INT,ADDEXP,"Add_Exp",0,$1,$3,NULL);}
	| expression SUBOP expression					{$$=nodeCreate(INT,SUBEXP,"Sub_Exp",0,$1,$3,NULL);}
	| expression MULOP expression					{$$=nodeCreate(INT,MULEXP,"Mul_Exp",0,$1,$3,NULL);}
	| expression DIVOP expression					{$$=nodeCreate(INT,DIVEXP,"Div_Exp",0,$1,$3,NULL);}
	| LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET			    	
                                                               {$$=nodeCreate(VOID,PARANTHESIZEDEXP,"Paranthesized_Exp",0,$2,NULL,NULL);}
	| expression AND expression					{$$=nodeCreate(BOOL,ANDEXP,"AND_Exp",0,$1,$3,NULL);}
	| expression OR expression					{$$=nodeCreate(BOOL,OREXP,"OR_Exp",0,$1,$3,NULL);}
	| expression LT expression					{$$=nodeCreate(BOOL,LTEXP,"LT_Exp",0,$1,$3,NULL);}
	| expression GT expression					{$$=nodeCreate(BOOL,GTEXP,"GT_Exp",0,$1,$3,NULL);}
	| expression LE expression					{$$=nodeCreate(BOOL,LEEXP,"LE_Exp",0,$1,$3,NULL);}
	| expression GE expression					{$$=nodeCreate(BOOL,GEEXP,"GE_Exp",0,$1,$3,NULL);}
	| expression EQ expression					{$$=nodeCreate(BOOL,EQEXP,"EQ_Exp",0,$1,$3,NULL);}
	| expression NE expression					{$$=nodeCreate(BOOL,NEEXP,"NE_Exp",0,$1,$3,NULL);}
	| NOT expression				    	{$$=nodeCreate(BOOL,NOTEXP,"NOT_Exp",0,$2,NULL,NULL);}
	| ID					    	{$$=nodeCreate(VOID,VAR,yyval.name,0,NULL,NULL,NULL);}
	| ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET				{$$=nodeCreate(VOID,ARRAY,yyval.name,0,NULL,NULL,NULL);}
	| NUM					    	{sprintf(buffer,"Integer_Const(%d)",yylval.value); $$=nodeCreate(VOID,CONST,buffer,0,NULL,NULL,NULL);}
	| BOOLEAN_OP					{sprintf(buffer,"Boolean_Const(%s)",yyval.name);$$=nodeCreate(VOID,BOOL,buffer,0,NULL,NULL,NULL);}
	| function_call				    	{$$=nodeCreate(VOID,FUN_CALL,"Function_Call",0,$1,NULL,NULL);}
    | SUBOP exp %prec UMINUS        {$$=nodeCreate(INT,UMINUS,"Minus_Exp",0,$2,NULL,NULL);}
	; 

function_call:
	ID LEFT_ROUND_BRACKET parameter_list RIGHT_ROUND_BRACKET			{$$=nodeCreate(VOID,FUN_CALL,nOFid,0,$3,NULL,NULL);}
	;

parameter_list:
	parameter_list SEPERATOR expression			{$$=nodeCreate(VOID,PARAM_LIST,"Func_Parameters",0,$1,$3,NULL);}
	| expression					       	    {$$=nodeCreate(VOID,PARAM_LIST,"Func_Parameters",0,$1,NULL,NULL);}
	;


%%
#include "lex.yy.c"

void yyerror(char *s) {
    fprintf(stderr, "\n\n%s at line number = %d due to %s\n\n",s,linenumber,yytext);
	e = 1;
}

int main(void) {
    yyparse();
    if(e==0) printf("\n\nParsed Successfully\nLines = %d\n\n",line);
    else printf("\n\nERROR while parsing\n\n")
    return 0;
}
