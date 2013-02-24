%{

	#include <ctype.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parseTree.h"
	int yylex(void);
	void yyerror(char *s);
	int type;
	char *id_name;
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
                     {struct symbolTable *check=lookup(id_name);
                      if(check==NULL)  install(id_name,type);
                      else yyerror("Redeclaration Error");
                      }
	| item			
                      { struct symbolTable *check=lookup(id_name);
                      if(check==NULL)  install(id_name,type);
                      else yyerror("Redeclaration Error");
                      }		           
	;
		

item:
	ID					      
                  {id_name=yylval.name;}
	| ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET    
                  {id_name=yylval.name;}			
	| ID LEFT_ROUND_BRACKET argument_list RIGHT_ROUND_BRACKET  
                   {id_name=yylval.name;}				
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
                     {id_name=yylval.name;}		       
          | ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET	
                      {id_name=yylval.name;}		
	|  ADDRESS_OF ID
                       {id_name=yylval.name;}				
	
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
	          
	;




main_body:
	  DECL  l_declarations ENDDECL BEGIN statements RETURN expression TERMINATOR END	
	    
	  | BEGIN statements RETURN expression TERMINATOR END 
	       
	
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
	    
	|						   
	   
	;
statement:
           assignment_statement
 
           | conditional_statement
                
           | iterative_statement
          
           | input_output_statement
                 
           ;  

	
assingment_statement:
                  ID ASSIGNMENT_OP expression TERMINATOR				  
                                 
		  |ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET ASSIGNMENT_OP expression TERMINATOR		
				
		;
 
conditional_statement:
                      IF LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET THEN statements ENDIF TERMINATOR		
                             
		|IF LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET THEN statements ELSE statements ENDIF TERMINATOR	
		             
		;
					
iterative_statement:
                    WHILE LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET DO statements ENDWHILE TERMINATOR 
                            
                                
		  ;
					
input_output_statement:					
	                 READ LEFT_ROUND_BRACKET ID RIGHT_ROUND_BRACKET TERMINATOR			    	   
	                           
	                | WRITE LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET TERMINATOR				      
	                         
	                ;
	
//int_var :  ID
  //         | ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET
    //       ;


	
					

expression:
	expression ADDOP expression					
               
	| expression SUBOP expression					
                    
	| expression MULOP expression					
                    
	| expression DIVOP expression					
	| LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET			    	
                                                               
	| expression AND expression					
	| expression OR expression					
	| expression LT expression					
	| expression GT expression					
	| expression LE expression					
	| expression GE expression					
	| expression EQ expression				
	| expression NE expression					
	| NOT expression				    	
	| ID					    	
	| ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET				
	| NUM					    	
	| BOOLEAN_OP					
	| function_call				   
    | SUBOP exp %prec UMINUS        
	; 

function_call:
	ID LEFT_ROUND_BRACKET parameter_list RIGHT_ROUND_BRACKET			
	;

parameter_list:
	parameter_list SEPERATOR expression			
	| expression					    
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
