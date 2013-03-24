/**
  *		bison -d -v grammer.y
  *		flex silgmr.l
  *		gcc grammer.tab.c -ll -ly -o sil
  *		./sil < test
  *
  *   Created By Anirban Das
  
*/






%{

	#include <ctype.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "sil_parseTree.h"
	#include "sil_symbolTable.h"
	int yylex(void);
	void yyerror(char *s);
	int type;
	int linenumber=1;
	char *id_name;
        
	struct Tnode *t;

	
	int funcCount;
	

//	struct Tnode *rootpgm , *rootmain , *rootbody;
     struct Lsymbol *tempL;
     struct Gsymbol *tempG;
     
%}

%token DECL ENDDECL BEGIN1 END RETURN MAIN_FUNC 
%token INTEGER BOOLEAN NUM ID
%token IF THEN ELSE ENDIF WHILE DO ENDWHILE READ WRITE SWITCH CASE
%token ASSIGNMENT_OP ADDOP SUBOP MULOP DIVOP BOOLEAN_OP MODOP 
%token LE GE LT GT NE EQ AND NOT OR
%token LEFT_SQR_BRACKET RIGHT_SQR_BRACKET LEFT_ROUND_BRACKET RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET 
%token SEPARATOR TERMINATOR ADDRESS_OF COLON 

%union {int value; char *name;  struct Tnode *n;}

%type <value>  BOOLEAN_OP NUM
%type <name> ID
%type <n> start global_declaration declarations typ item_list item argument_list parameters argument functions normal_function main_function  l_declarations l_decl_list function_body expression statements statement function_call parameter_list


%nonassoc NE LT LE EQ GT GE
%left OR AND 
%right NOT
%left ADDOP SUBOP
%left DIVOP MULOP
%right UMINUS

%%
start:
	global_declaration functions	 		
	              {$$=nodeCreate(VOID,PROG,"Program",0,$1,$2,NULL);}
    | main_function				   
                  {$$=nodeCreate(VOID,PROG,"Program",0,$1,NULL,NULL);}
    ;

global_declaration:
    DECL declarations ENDDECL		
                  {printf("\n reading global declaration \n");$$=nodeCreate(VOID,GLOBAL,"GDeclBlock",0,$2,NULL,NULL); }
    ;

declarations:
	declarations typ item_list TERMINATOR	
	              {
                         printf("\n reading declarations from lexical analyzer with declaration typ itemlist terminator\n");
                         $$=nodeCreate(VOID,GLOBAL_LIST,"GDecl",0,$1,$3,NULL);} 
	| 					
	              {printf("\n reading declaration from lexical analyzer with null\n");$$=NULL;}	
	;

typ:
	INTEGER					    {printf("\n reading typ from lexical analyzer\n");type = INT;}
	|BOOLEAN				    {printf("\n reading typ from lexical analyzer\n");type = BOOL;}
	;
	
item_list:
    item_list SEPARATOR item 	 
                     { 
                              printf ("\n in silgrmmr.y decl checking item_list = item_list Separator item\n");
						
						tempG=Glookup(id_name);
                      if(tempG==NULL)  {
                                          printf("\n in silgrammr.y tempg==NULL entered if block \n");
                                         Ginstall(id_name,type);
                                          printf("\n Ginstalled %s\n",id_name);
                                         $$=nodeCreate(type,GLOBAL,"GDeclList",0,$1,$3,NULL);
                                        }
                                         
                      else 
                                 {
                                     printf("\n in silgrammr.y tempg!=NULL entered else block for redeclaration error \n");
                                      yyerror("Redeclaration Error");
                                  }
                     
 							}
	| item			
                      { 	
                                  printf ("\n in silgrmmr.y decl checking item_list = item\n");

						tempG=Glookup(id_name);
                         if(tempG==NULL) {
                                           
                                            printf("\n in silgrammr.y tempg==NULL entered if block \n");
                                           Ginstall(id_name,type);
                                             printf("\n Ginstalled %s\n",id_name);
                                           $$=nodeCreate(type,VARLIST,"Item",0,$1,NULL,NULL);
                                          }
                      else 
                                  {

                                        printf("\n in silgrammr.y tempg!=NULL entered else block for redeclaration error \n");
                                        yyerror("Redeclaration Error");
                                  }
                      
						}		           
	;
		

item:
	ID					      
                     {printf("\n reading item=ID\n");id_name=yylval.name;  $$=nodeCreate(type,VAR,id_name,0,NULL,NULL,NULL); }

	| ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET    
                     { printf("\n reading item=ID[num]\n");id_name=yylval.name; 
                       t=nodeCreate(INT,ARRSIZE,"ArrSize",0,NULL,NULL,NULL);
                       $$=nodeCreate(type,ARRAY,id_name,0,t,NULL,NULL);
                     }
			
	| ID LEFT_ROUND_BRACKET argument_list RIGHT_ROUND_BRACKET  
                      {printf("\n reading item=ID(args)\n");id_name=yylval.name;  $$=nodeCreate(type,FUNC,id_name,0,$3,NULL,NULL);}				
	;


argument_list:
	argument_list typ  parameters				
	                    {printf("\n reading arglist = arglist typ param\n");$$=nodeCreate(VOID,ARGS,"Args",0,$1,$3,NULL);}
	|argument_list typ  parameters TERMINATOR		
	                    {printf("\n reading arglist = arglist typ param terminator\n");$$=nodeCreate(VOID,ARGS,"Args",0,$1,NULL,NULL);}
				  
	|                    
	                    {printf("\n reading arglist = null\n");$$=NULL;}
	;
	

	
parameters:
	parameters SEPARATOR argument  
	                     {printf("\n reading param = param separator argmnt\n");$$=nodeCreate(type,F_PARAM_LIST,"FormalParameterList",0,$1,$3,NULL); }	
		      
	| argument
	                     { printf("\n reading param = argmnt\n");$$=nodeCreate(type,F_PARAM,"FormalParameter",0,$1,NULL,NULL);}
	;
	
argument :
          ID			
                         {printf("\n reading argmnt = ID\n");id_name=yylval.name;  
                          $$=nodeCreate(type,VAR,id_name,0,NULL,NULL,NULL); 
                         }
		       
          | ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET	
                          {id_name=yylval.name; 
                            t=nodeCreate(INT,ARRSIZE,"ArrSize",0,NULL,NULL,NULL);
                            $$=nodeCreate(type,ARRAY,yyval.name,0,t,NULL,NULL);
                          }		
	|  ADDRESS_OF ID
                           {printf("\n reading argmnt = & ID\n");id_name=yylval.name; $$=nodeCreate(type,REFERENCE,id_name,0,NULL,NULL,NULL);}				
	
        ;
           	



functions:
	normal_function main_function		
	                        {$$=nodeCreate(type,FUNCDEF,"Funcs",0,$1,$2,NULL);}	
	; 

normal_function:
	 normal_function typ ID LEFT_ROUND_BRACKET argument_list RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET function_body RIGHT_CURLY_BRACKET 	
	                        {$$=nodeCreate(type,FUNCS,id_name,0,$1,$5,$8);}
	|						 
	                         {$$=NULL;} 
	;

main_function:
	INTEGER MAIN_FUNC LEFT_ROUND_BRACKET RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET  function_body RIGHT_CURLY_BRACKET		
	                         {$$=nodeCreate(INT,MAIN,"Main",0,$6,NULL,NULL);}
	          
	;




function_body:
	  DECL  l_declarations ENDDECL BEGIN1 statements RETURN expression TERMINATOR END	
	                         { funcCount++ ; $$=nodeCreate(VOID,BODY,"FnBody",0,$2,$5,$7); }
	    
	  | BEGIN1 statements RETURN expression TERMINATOR END 
	                         { $$=nodeCreate(VOID,BODY,"FnBody",0,$2,$4,NULL);}
	       
	
	  ;


l_declarations :  
                 l_declarations typ l_decl_list TERMINATOR
                              {$$=nodeCreate(VOID,FDCL,"FuncDcl",0,$1,$3,NULL);} 
                 |
                              {$$=NULL;}
                 ;
                 
                 
l_decl_list :  
               l_decl_list SEPARATOR ID
                             {tempL=Llookup(id_name,funcCount);
                               if(tempL==NULL)   {
                                                 Linstall($3,type,funcCount);
                                                 t=nodeCreate(type,VAR,yyval.name,0,NULL,NULL,NULL);
                                                 $$=nodeCreate(type,FDCLS,"FDcls",0,$1,t,NULL);
                                                 }
                                else  
                                          yyerror("Redeclaration Error");
                             }
               |  ID
                              {tempL=Llookup(id_name,funcCount);
                               if(tempL==NULL)   {
                                                 Linstall($1,type,funcCount);
                                                 $$=nodeCreate(type,VAR,yyval.name,0,NULL,NULL,NULL);
                                                 }

                                else  
				                          yyerror("Redeclaration Error");
				                }
               ;                 



statements:
	         statements statement 				
	                          {  $$=nodeCreate(VOID,STMT,"Stmts",0,$1,$2,NULL);}	
	    
	|						  
	                          {$$=NULL;} 
	   
	;


statement:
          
          ID ASSIGNMENT_OP expression TERMINATOR	
                                          {tempL=Llookup(id_name,funcCount);
                                            if(tempL!=NULL)
                                                    { if(tempL->type == $3->type)
                                                                {  t=nodeCreate(VOID,VAR,yyval.name,0,NULL,NULL,NULL);
                                                                   $$=nodeCreate(VOID,STMT,"ASGNStmt",0,t,$3,NULL);
                                                                 }
                                                       
                                                      else 
                                                            yyerror("Type Does not Match");
                                                    }
                     
                                            else 
                                                 yyerror("Undeclared Variable"); 
                                          }			  
                                 
		  
		 
		|  ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET ASSIGNMENT_OP expression TERMINATOR
		                                   {tempL=Llookup(id_name,funcCount); 
		                                    if(tempL!=NULL)
	                                            	{  if(tempL->type==$6->type)
		                                                        {   t=nodeCreate(VOID,ARRAY,yyval.name,0,NULL,NULL,NULL);
		                                                            $$=nodeCreate(VOID,STMT,"ASGNStmt",0,t,$6,NULL);
		                                                         }
		
		                                                else 
		                                                      yyerror("Type Does Not Match");
		                                             }
		
		                                     else 
		                                            yyerror("Undeclared Variable"); 
		                                    }		
				
		
       
         | IF LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET THEN statements ENDIF TERMINATOR	
                                            {  if($3->type == BOOL)
                                                         $$=nodeCreate(VOID,STMT,"IFStmt",0,$3,$6,NULL);
            
                                                else 
                                                       yyerror("Expression Does not Have Proper type (Boolean) ");
                                             }	
                             
	
		|  IF LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET THEN statements ELSE statements ENDIF TERMINATOR	
		                                    {  if($3->type==BOOL)
		                                                   $$=nodeCreate(VOID,STMT,"IFStmt",0,$3,$6,$8);
		
		                                        else 
		                                               yyerror("Expression Does not Have Proper type (Boolean) ");
		                                   
		                                    }
		             
		
				
        | WHILE LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET DO statements ENDWHILE TERMINATOR 
                                              {  if($3->type==BOOL)
                                                            $$=nodeCreate(VOID,STMT,"WhileStmt",0,$3,$6,NULL) ;

                                                   else 
					                                        yyerror("Expression Does not Have Proper type (Boolean) ");

					                           }
                            
                                
	
		| READ LEFT_ROUND_BRACKET ID RIGHT_ROUND_BRACKET TERMINATOR			   
	                                           {  tempL=Llookup(id_name,funcCount);
	                                              if(tempL!=NULL)
	                                                     $$=nodeCreate(VOID,STMT,"ReadStmt",0,NULL,NULL,NULL);
	
	                                             else 
	                                                   yyerror("Undeclared Variable"); 
	
	                                           }
	
		   
	                           
	    | WRITE LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET TERMINATOR	
	                                          {  $$=nodeCreate(VOID,STMT,"WriteStmt",0,NULL,NULL,NULL); }			      
	                         
	                
	    ;
	


	
					

expression:
	
	expression ADDOP expression				
	                                          { if($1->type== INT && $3->type == INT)
	                                                      $$=nodeCreate(INT,ADDEXP,"Add",0,$1,$3,NULL);
	
	                                              else 
	                                                     yyerror("Expression Types Do not Match"); 
	     
	                                           }	
               
	| expression SUBOP expression				
	                                           {  if($1->type== INT && $3->type == INT) 
	                                                       $$=nodeCreate(INT,SUBEXP,"Sub",0,$1,$3,NULL);
	                                               
	                                               else 
			                                               yyerror("Expression Types Do not Match"); 

			                                    }
			
                    
	| expression MULOP expression				
	                                           {   if($1->type== INT && $3->type == INT) 
	                                                       $$=nodeCreate(INT,MULEXP,"Mul",0,$1,$3,NULL); 
	
	                                		        else 
			                                                yyerror("Expression Types Do not Match"); 

			                                    }
                    
	| expression DIVOP expression				
	                                           {    if($1->type== INT && $3->type == INT)
	                                                              $$=nodeCreate(INT,DIVEXP,"Div",0,$1,$3,NULL); 
	
	                             					 else 
					                                               yyerror("Expression Types Do not Match"); 

					                             }
		
	| LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET			    
	                                          {   $$=nodeCreate($2->type,PARTHSEXP,"Parthsexp",0,$2,NULL,NULL); }
		
                                                               
	| expression AND expression				
	                                         {   if($1->type== BOOL && $3->type == BOOL) 
	                                                             $$=nodeCreate(BOOL,ANDEXP,"AND",0,$1,$3,NULL); 
	
	     										 else 
					                                             yyerror("Expression Types Do not Match"); 

					                          }
					
	
	| expression OR expression				
	                                          {    if($1->type== BOOL && $3->type == BOOL)
	                                                           $$=nodeCreate(BOOL,OREXP,"OR",0,$1,$3,NULL); 
	   
	 											   else 
				                                               yyerror("Expression Types Do not Match"); 

				                              }
				
		
	| expression LT expression					
	                                          {   if($1->type== INT && $3->type == INT) 
	                                                         $$=nodeCreate(BOOL,LTEXP,"LT",0,$1,$3,NULL); 
	
												  else 
				                                             yyerror("Expression Types Do not Match"); 

				                              }
	
	
	| expression GT expression				
	                                          {   if($1->type== INT && $3->type == INT) 
	                                                         $$=nodeCreate(BOOL,GTEXP,"GT",0,$1,$3,NULL);
	 
												   else 
				                                              yyerror("Expression Types Do not Match"); 

				                              }
				
				
		
	| expression LE expression				
	                                           {   if($1->type== INT && $3->type == INT) 
	                                                          $$=nodeCreate(BOOL,LEEXP,"LE",0,$1,$3,NULL); 
	
												    else 
				                                              yyerror("Expression Types Do not Match"); 

				                                }
		
		
	| expression GE expression					
	                                          {     if($1->type== INT && $3->type == INT) 
	                                                           $$=nodeCreate(BOOL,GEEXP,"GE",0,$1,$3,NULL);
	
	 											     else 
				                                               yyerror("Expression Types Do not Match"); 

				                               }
				
	
	| expression EQ expression				
	                                           {   if ($1->type== INT && $3->type == INT)
	                                                            $$=nodeCreate(BOOL,EQEXP,"EQ",0,$1,$3,NULL); 
	
													else 
					                                             yyerror("Expression Types Do not Match"); 

					                           }
					
	
	| expression NE expression				
	                                          {    if($1->type== INT && $3->type == INT)
	                                                            $$=nodeCreate(BOOL,NEEXP,"NE",0,$1,$3,NULL); 
	
													 else 
					                                             yyerror("Expression Types Do not Match"); 

					                           }
					
		
	| NOT expression				    	
	                                          {    if($2->type== BOOL)
	                                                              $$=nodeCreate(BOOL,NOTEXP,"NOT",0,$2,NULL,NULL); 
	
													 else 
					                                              yyerror("Expression Types Do not Match"); 

					                           }
					
	
	| ID					    	
	                                          {  tempL = Llookup(yyval.name,funcCount);  
	                                             if(tempL!=NULL)
	                                                       $$=nodeCreate(tempL->type,VAR,yyval.name,0,NULL,NULL,NULL);
	                                            
	                                            else 
			                                               yyerror("Undeclared Variable"); 

			                                   }
			
	
	| ID LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET			
	                                             {  tempL=Llookup(yyval.name,funcCount); 
	                                                if(tempL!=NULL)
	                                                       $$=nodeCreate(tempL->type,ARRAY,yyval.name,0,NULL,NULL,NULL); 
	                                             
	
													else 
					                                        yyerror("Undeclared Variable"); 

					                               }
	      	
	
	| NUM					    	
	                                              {   $$=nodeCreate(INT,CONST,"IntConst",yylval.value,NULL,NULL,NULL); }
	
	
	| BOOLEAN_OP				
	                                               { $$=nodeCreate(BOOL,BOOLCONST,"BoolConst",yylval.value,NULL,NULL,NULL);}
	
	  	
	| function_call				   
	                                              { $$=nodeCreate($1->type,FNCALLS,"FuncCall",0,$1,NULL,NULL); }
	
	
    | SUBOP expression %prec UMINUS       
                                                   { if($2->type==INT)
                                                              $$=nodeCreate(INT,UMINUS,"Negative",0,$2,NULL,NULL);

												 	else 
						                                      yyerror("Expression Type Does not Match (INTEGER) "); 

						                              }
						
	; 
	
	
	

function_call:
	  ID LEFT_ROUND_BRACKET parameter_list RIGHT_ROUND_BRACKET			
	                                            { tempL = Llookup(yyval.name,funcCount); 
	                                              if(tempL!=NULL)
	                                                      $$=nodeCreate(tempL->type,FNCALL,id_name,0,$3,NULL,NULL);
	
											 	 else 
					                                     yyerror("Undeclared Variable"); 

					                            }
					
	;
	
	
	

parameter_list:
	parameter_list SEPARATOR expression			
	                                                 { $$=nodeCreate(VOID,FCLISTS,"FuncArgsList",0,$1,NULL,NULL); }
	
	| expression					   
	                                                 {  $$=nodeCreate(VOID,FCLIST,"FuncArg",0,$1,NULL,NULL);}  
	 
	|
	                                                 {$$=NULL;} 
	
	;






%%
#include "lex.yy.c"

void yyerror(char *s) {
    fprintf(stderr, "\n\n%s at line number = %d ",s,linenumber);
	e = 1;
}

int main(void) {
    yyparse();
    if(e==0) printf("\n\nParsed Successfully\nLines = %d\n\n",linenumber);
    else printf("\n\nERROR while parsing\n\n");
    return 0;
}
