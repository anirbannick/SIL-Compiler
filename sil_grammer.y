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
	#include "sil_intermCodeGenerator_v2.h"
	//#include "sil_machineCodeGen.h"
	int yylex(void);
	void yyerror(char *s);
	int type;
	int linenumber=1;
	int fc=0;
	char *id_name;
	int offset=1;
        
	struct Tnode *t;
	struct ArgStruct *fplist;

	

	
	 struct Tnode *rootprogram , *rootmain, *rootstmt;
     struct Lsymbol *tempL;
     struct Gsymbol *tempG;
     struct ArgStruct *tempArg;
     
%}

%token DECL ENDDECL BEGIN1 END RETURN MAIN_FUNC 
%token INTEGER BOOLEAN NUM ID
%token IF THEN ELSE ENDIF WHILE DO ENDWHILE READ WRITE SWITCH CASE
%token ASSIGNMENT_OP ADDOP SUBOP MULOP DIVOP BOOLEAN_OP MODOP UMINUS
%token LE GE LT GT NE EQ AND NOT OR
%token LEFT_SQR_BRACKET RIGHT_SQR_BRACKET LEFT_ROUND_BRACKET RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET 
%token SEPARATOR TERMINATOR ADDRESS_OF COLON 

%union {int value; char *name;  struct Tnode *n;}

%type <value>  BOOLEAN_OP NUM
%type <name> ID
%type <n> start global_declaration declarations typ item_list item argument_list parameters argument functions normal_function main_function  l_declarations l_decl_list function_body expression statements statement function_call parameter_list identifier litem


%nonassoc NE LT LE EQ GT GE
%left OR AND 
%right NOT
%left ADDOP SUBOP
%left DIVOP MULOP MODOP
%right UMINUS

%%
start:
	global_declaration functions	 		
	              {$$=nodeCreate(VOID,PROG,"Program",0,$1,$2,NULL,0); rootprogram=$$;}
    | main_function				   
                  {$$=nodeCreate(VOID,PROG,"Program",0,$1,NULL,NULL,0);  rootprogram = $$;}
    ;

global_declaration:
    DECL declarations ENDDECL		
                  {printf("\n reading global declaration \n");$$=nodeCreate(VOID,GLOBAL,"GDeclBlock",0,$2,NULL,NULL,0);funcCount=0; }
    ;

declarations:
	declarations typ item_list TERMINATOR	
	              {
                         printf("\n reading declarations from lexical analyzer with declaration typ itemlist terminator\n");
                         $$=nodeCreate(VOID,GLOBAL_LIST,"GDecl",0,$1,$3,NULL,0);} 
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
										printf("\n Ginstalling with arraySize = %d\n",arraysize);
                                         Ginstall(id_name,type,$3->nodetype,arraysize,fplist,fc);
                                          printf("\n Ginstalled %s\n",id_name);
										
                                         $$=nodeCreate(type,GLOBAL,"GDeclList",0,$1,$3,NULL,0);
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
                                  printf("\n start Glookup of %s\n",id_name);
						tempG=Glookup(id_name);
                         if(tempG==NULL) {
                                           
                                            printf("\n in silgrammr.y tempg==NULL entered if block \n");
											printf("\n Ginstalling with arraySize = %d\n",arraysize);
                                           Ginstall(id_name,type,$1->nodetype,arraysize,fplist,fc);
                                             printf("\n Ginstalled %s\n",id_name);
                                           $$=nodeCreate(type,VARLIST,"Item",0,$1,NULL,NULL,0);
											
                                          }
                      else 
                                  {

                                        printf("\n in silgrammr.y tempg!=NULL entered else block for redeclaration error \n");
                                        yyerror("Redeclaration Error");
                                  }
                      
						}		           
	;
		

item:
	identifier					      
                     {printf("\n reading item=ID\n"); 
				
					$$=nodeCreate(type,VAR,id_name,0,NULL,NULL,NULL,0);
					arraysize=1;
					fc=0;
					fplist=NULL;
				//	isfun=0; }

	| identifier LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET    
                     { printf("\n reading item=ID[num]\n");
                       t=nodeCreate(INT,ARRSIZE,"ArrSize",yylval.value,NULL,NULL,NULL);
						arraysize=yylval.value;
                       $$=nodeCreate(type,ARRAY,id_name,0,t,NULL,NULL,0);
						fc=0;
					//	isfun=0;
					   fplist=NULL;
                     }
			
	| identifier  LEFT_ROUND_BRACKET argument_list RIGHT_ROUND_BRACKET  
                      {printf("\n reading item=ID(args)\n"); 
						arraysize=0;
                      // t=nodeCreate(VOID,ARGLIST,"ArgList",0,NULL,NULL,NULL);
                       $$=nodeCreate(type,FUNC,id_name,0,$3,NULL,NULL,funcCount++);
						fc=funcCount-1;
						fplist=headArg[fc];
						offset=1;
						
                       }				
	;



identifier :
             ID   { id_name=yylval.name; printf("\n Reading ID with value %s\n", id_name);}


argument_list:
	argument_list typ  parameters				
	                    {printf("\n reading arglist = arglist typ param\n");$$=nodeCreate(VOID,ARGS,"Args",0,$1,$3,NULL,0);}
	|argument_list typ  parameters TERMINATOR		
	                    {printf("\n reading arglist = arglist typ param terminator\n");$$=nodeCreate(VOID,ARGS,"Args",0,$1,$3,NULL,0);}
				  
	|                    
	                    {printf("\n reading arglist = null\n");
						fplist=NULL; $$=NULL;}
	;
	

	
parameters:
	parameters SEPARATOR argument  
	                     {printf("\n reading param = param separator argmnt\n");
	                       $$=nodeCreate(type,F_PARAM_LIST,"FormalParameterList",0,$1,$3,NULL,0); }	
		      
	| argument
	                     { printf("\n reading param = argmnt\n");$$=nodeCreate(type,F_PARAM,"FormalParameter",0,$1,NULL,NULL,0);}
	;
	
argument :
          identifier			
                         {printf("\n reading argmnt = ID\n"); 
                          $$=nodeCreate(type,VAR,id_name,0,NULL,NULL,NULL,0); 
						printf("\n node Creted Argument VAR with value = %s\n",id_name);
						printf("\n starting ArgLookup for value = %s  and  funcCout =  %d\n",id_name,funcCount);
						  tempArg=Arglookup(id_name,funcCount);
						printf("\nArgLookup done\n");
						
						 if(tempArg==NULL)
						   {
								printf("\n tempArg==NULL\n");
								Arginstall(id_name,type,VAR,1,offset++,funcCount);
						    }
						
						else 
						  {
								printf("tempArg!=NULL");
								yyerrot("Redeclaration Formal Parameter Error");
					    	}
                      }
		       
          | identifier LEFT_SQR_BRACKET NUM RIGHT_SQR_BRACKET	
                          { 
							printf("\nReading argument = ID[NUM] : %s[]\n",id_name);
                            t=nodeCreate(INT,ARRSIZE,"ArrSize",0,NULL,NULL,NULL,0);
                            $$=nodeCreate(type,ARRAY,yyval.name,0,t,NULL,NULL,0);
							printf("\n node Creted Argument ARRAY with value = %s\n",id_name);
						printf("\n starting ArgLookup for value = %s  and  funcCout =  %d\n",id_name,funcCount);
						  tempArg=Arglookup(id_name,funcCount);
						printf("\nArgLookup done\n");
						
						 if(tempArg==NULL)
						   {
								printf("\n tempArg==NULL\n");
								Arginstall(id_name,type,ARRAY,$3,offset++,funcCount);
						    }
						
						else 
						  {
								printf("tempArg!=NULL");
								yyerrot("Redeclaration Formal Parameter Error");
					    	}
                          }		
	|  ADDRESS_OF identifier
                           {printf("\n reading argmnt =  & ID with ID = %s\n",id_name);
                             $$=nodeCreate(type,REFERENCE,id_name,0,NULL,NULL,NULL,0);}	
							printf("\n node Creted Argument ADDRESS_OF with value = %s\n",id_name);
						printf("\n starting ArgLookup for value = %s  and  funcCout =  %d\n",id_name,funcCount);
						  tempArg=Arglookup(id_name,funcCount);
						printf("\nArgLookup done\n");
						
						 if(tempArg==NULL)
						   {
								printf("\n tempArg==NULL\n");
								Arginstall(id_name,type,REFERENCE,1,offset++,funcCount);
						    }
						
						else 
						  {
								printf("tempArg!=NULL");
								yyerrot("Redeclaration Formal Parameter Error");
					    	}
	
        ;
           	



functions:
	normal_function main_function		
	                        { $$=nodeCreate(type,FUNCDEF,"Funcs",0,$1,$2,NULL,0);}	
	; 

normal_function:
	 normal_function typ identifier LEFT_ROUND_BRACKET argument_list RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET function_body RIGHT_CURLY_BRACKET 	
	                        {   printf("\n Reading normal_funtion with NO NULL\n");
	 						    tempG=Glookup($3);
						     	if(tempG!=NULL)
							    {
									
									$$=nodeCreate(type,FUNCS,$3,0,$1,$5,$8,funcCount-1);
								}
								else
								{
								  yyerror("Undeclared Function %s ",$3)
								}
	|						 
	                         {printf("\nReading normal_funtion with NULL\n");  $$=NULL;} 
	;

main_function:
	INTEGER MAIN_FUNC LEFT_ROUND_BRACKET RIGHT_ROUND_BRACKET LEFT_CURLY_BRACKET  function_body RIGHT_CURLY_BRACKET		
	                         {printf("\n Reading main_function\n");  $$=nodeCreate(INT,MAIN,"Main",0,$6,NULL,NULL,funcCount-1); rootmain=$$;}
	          
	;




function_body:
	  DECL  l_declarations ENDDECL BEGIN1 statements RETURN expression TERMINATOR END	
	                         { printf("\nReading function_body with Local Decl\n");
	                          funcCount++ ; $$=nodeCreate(VOID,BODY,"FnBody",0,$2,$5,$7,0); }
	    
	  | BEGIN1 statements RETURN expression TERMINATOR END 
	                         { printf("\nReading function_body with NO Local Decl\n");
	                           $$=nodeCreate(VOID,BODY,"FnBody",0,$2,$4,NULL,0);}
	       
	
	  ;


l_declarations :  
                 l_declarations typ l_decl_list TERMINATOR
                              {printf("\nReading local declarations with NOT ldecl= ldecl typ ldecl_list terminator\n");
                                $$=nodeCreate(VOID,FDCL,"FuncDcl",0,$1,$3,NULL,0);} 
                 |
                              {printf("\nReading local declration with ldecl=NULL\n"); $$=NULL;}
                 ;
                 
                 
l_decl_list :  
               l_decl_list SEPARATOR litem
                             {
                                 printf("\n in Local_decl_list with ldecllist = ldecllist separator ID\n");
                                tempL=Llookup(id_name,funcCount);
                               if(tempL==NULL)   {  printf("\n in local_decl_list with tempL == NULL\n");
 												    printf("\n Linstalling with funcCount = %d\n",funcCount);
                                                 Linstall(id_name,type,funcCount);
                                                  printf("\n Linstalled %s\n",id_name);
                                                 t=nodeCreate(type,VAR,yyval.name,0,NULL,NULL,NULL,0);
                                                 $$=nodeCreate(type,FDCLS,"FDcls",0,$1,t,NULL,0);
                                                 }
                                else  {   printf("in Loacl_decl_list with tempL !=NULL\n");
                                          yyerror("Redeclaration Error");
                                     }
                             }
               |  litem
                              {    printf("\n in Local_decl_list with ldecllist = ID\n");
                                 tempL=Llookup(id_name,funcCount);
                               if(tempL==NULL)   { printf("\n in local_decl_list with tempL == NULL\n");
                                                  printf("\n Linstalling with funcCount = %d\n",funcCount);
                                                 Linstall(id_name,type,funcCount);
                                                  printf("\n Linstalled %s\n",id_name);
                                                 $$=nodeCreate(type,VAR,yyval.name,0,NULL,NULL,NULL,0);
                                                 }

                                else  
				                         {   printf("in Loacl_decl_list with tempL !=NULL\n");
				                            yyerror("Redeclaration Error");
				                         }
				                }
               ;    



litem :
         ID   { id_name=yylval.name; printf("\n Reading ID with value %s\n", id_name);}             



statements:
	         statements statement 				
	                          { printf("\n Reading statements with statetements= statements statement\n");
	                             $$=nodeCreate(VOID,STMT,"Stmts",0,$1,$2,NULL,0); rootstmt = $$;}	
	    
	|						  
	                          {printf("\n Reading statements with statetements= NULL\n"); $$=NULL;} 
	   
	;


statement:
          
          identifier ASSIGNMENT_OP expression TERMINATOR	
                                          { printf("\n Reading ASSGNStmt and looking for ID = %s\n",id_name);
										printf("\n Llookup with funcCount = %d\n",funcCount);
                                              tempL=Llookup(id_name,funcCount);
                                            if(tempL!=NULL)
                                                    { printf("\n In ASSGNStmnt and tempL !=NULL\n");
                                                         if(tempL->type == $3->type)
                                                                {  t=nodeCreate(VOID,VAR,id_name,0,NULL,NULL,NULL,0);
                                                                   $$=nodeCreate(VOID,ASSGNSTMT,"ASGNStmt",0,t,$3,NULL,0);
                                                                 }
                                                       
                                                      else 
                                                            yyerror("Type Does not Match");
                                                    }
                                          
                     
                                            else 
                                                { tempG= Glookup(id_name);
                                                 if (tempG!=NULL)
                              						{ printf("\n In ASSGNStmnt and tempG !=NULL\n");
                                                      if(tempG->type == $3->type)
                                                             {  t=nodeCreate(VOID,VAR,id_name,0,NULL,NULL,NULL,0);
                                                                $$=nodeCreate(VOID,ASSGNSTMT,"ASGNStmt",0,t,$3,NULL,0);
                                                              }
                                                    
                                                   else 
                                                         yyerror("Type Does not Match");
                                                 }
                                      
                                                  else
							
                                                      yyerror("Undeclared Variable"); 
                                                  }
                                          }			  
                                 
		  
		 
		|  identifier LEFT_SQR_BRACKET expression RIGHT_SQR_BRACKET ASSIGNMENT_OP expression TERMINATOR
		                                   { printf("\n Reading ASSGNStmt and looking for ID[NUM] = %s\n",id_name);
											printf("\n Llookup with funcCount = %d\n",funcCount);
		                                     tempL=Llookup(id_name,funcCount); 
		                                    if((tempL!=NULL)  && ($3->type== INT) )
	                                            	{   printf("\n In ASSGNStmnt and tempL !=NULL\n");
	                                                        if(tempL->type==$6->type)
		                                                        {   t=nodeCreate(VOID,ARRAY,id_name,0,NULL,NULL,NULL,0);
		                                                            $$=nodeCreate(VOID,ASSGNSTMT,"ASGNStmt",0,t,$6,NULL,0);
		                                                         }
		
		                                                else 
		                                                      yyerror("Type Does Not Match");
		                                             }
		
		                                     else 
		                                           { tempG= Glookup(id_name);
                                                      if ((tempG!=NULL)  && ($3->type== INT))
                              						    { printf("\n In ASSGNStmnt and tempG !=NULL\n");
                                                             if(tempG->type == $6->type)
                                                                  {  t=nodeCreate(VOID,VAR,id_name,0,NULL,NULL,NULL,0);
                                                                      $$=nodeCreate(VOID,ASSGNSTMT,"ASGNStmt",0,t,$6,NULL,0);
                                                                   }

                                                             else 
                                                                    yyerror("Type Does not Match");
                                                          }

                                                        else

                                                             yyerror("Undeclared Variable"); 
                                                    }
		                                    }		
				
		
       
         | IF LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET THEN statements ENDIF TERMINATOR	
                                            {  printf("\n Reading IFStmt with if then endif \n");
                                                     if($3->type == BOOL)
                                                         $$=nodeCreate(VOID,IFSTMT,"IfStmt",0,$3,$6,NULL,0);
            
                                                else 
                                                       yyerror("Expression Does not Have Proper type (Boolean) ");
                                             }	
                             
	
		|  IF LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET THEN statements ELSE statements ENDIF TERMINATOR	
		                                    {  printf("\n Reading IFStmt with if then else endif \n");
		                                                  if($3->type==BOOL)
		                                                   $$=nodeCreate(VOID,IFELSESTMT,"IfElseStmt",0,$3,$6,$8,0);
		
		                                        else 
		                                               yyerror("Expression Does not Have Proper type (Boolean) ");
		                                   
		                                    }
		             
		
				
        | WHILE LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET DO statements ENDWHILE TERMINATOR 
                                              {   printf("\n Reading WHILEStmt \n");
                                                   if($3->type==BOOL)
                                                            $$=nodeCreate(VOID,WHILESTMT,"WhileStmt",0,$3,$6,NULL,0) ;

                                                   else 
					                                        yyerror("Expression Does not Have Proper type (Boolean) ");

					                           }
                            
                                
	
		| READ LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET TERMINATOR			   
	                                           {  printf("\n Reading READStmt with nodetype= %s \n", $3->name);
	                                             /*   tempL=Llookup(id_name,funcCount);
	                                              if(tempL!=NULL)
	                                                     $$=nodeCreate(VOID,READSTMT,"ReadStmt",0,$3,NULL,NULL,0);
	
	                                             else 
	                                                   { tempG= Glookup(id_name);
	                                                      if (tempG!=NULL)
	                              						    { printf("\n In READStmnt and tempG !=NULL\n");
	                                                          $$=nodeCreate(VOID,READSTMT,"ReadStmt",0,$3,NULL,NULL,0);
	                                                              
	                                                          
	                                                          }

	                                                      else

	                                                         yyerror("Undeclared Variable"); 
	                                                    }
                                                      */
												if(($3->nodetype==VAR) || ($3->nodetype==ARRAY))
                                                     $$=nodeCreate(VOID,READSTMT,"ReadStmt",0,$3,NULL,NULL,0);
											   else 
													yyerror("Read Stattent can take either variable or array types as input\n Thus Invali read type");
	
	                                           }
	
		   
	                           
	    | WRITE LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET TERMINATOR	
	                                          { printf("\n Reading WRITEStmt \n"); 
	                                            $$=nodeCreate(VOID,WRITESTMT,"WriteStmt",0,$3,NULL,NULL,0); }			      
	                         
	                
	    ;
	


	
					

expression:
	
	expression ADDOP expression				
	                                          { printf("\n Reading ADDOPEXP \n");
	                                                if($1->type== INT && $3->type == INT)
	                                                      $$=nodeCreate(INT,ADDEXP,"Add",0,$1,$3,NULL,0);
	
	                                              else 
	                                                     yyerror("Expression Types Do not Match"); 
	     
	                                           }	
               
	| expression SUBOP expression				
	                                           { printf("\n Reading SUBOPEXP \n");
	                                              if($1->type== INT && $3->type == INT) 
	                                                       $$=nodeCreate(INT,SUBEXP,"Sub",0,$1,$3,NULL,0);
	                                               
	                                               else 
			                                               yyerror("Expression Types Do not Match"); 

			                                    }
			
                    
	| expression MULOP expression				
	                                           {   printf("\n Reading MULOPEXP \n");
	                                                if($1->type== INT && $3->type == INT) 
	                                                       $$=nodeCreate(INT,MULEXP,"Mul",0,$1,$3,NULL,0); 
	
	                                		        else 
			                                                yyerror("Expression Types Do not Match"); 

			                                    }
                    
	| expression DIVOP expression				
	                                           {   printf("\n Reading DIVOPEXP \n");
	                                                if($1->type== INT && $3->type == INT)
	                                                              $$=nodeCreate(INT,DIVEXP,"Div",0,$1,$3,NULL,0); 
	
	                             					 else 
					                                               yyerror("Expression Types Do not Match"); 

					                             }
					
					
					
   | expression MODOP expression				
											 {   printf("\n Reading MODOPEXP \n");
												 if($1->type== INT && $3->type == INT) 
												                                                               
												          $$=nodeCreate(INT,MODEXP,"Mod",0,$1,$3,NULL,0); 

												  else 
														  yyerror("Expression Types Do not Match"); 

				                             }	
				
				
		
	| LEFT_ROUND_BRACKET expression RIGHT_ROUND_BRACKET			    
	                                          {   printf("\n Reading PARTHEXP \n");
	                                             $$=nodeCreate($2->type,PARTHSEXP,"Parthsexp",0,$2,NULL,NULL,0); }
		
                                                               
	| expression AND expression				
	                                         {  printf("\n Reading ANDEXP \n");
	                                             if($1->type== BOOL && $3->type == BOOL) 
	                                                             $$=nodeCreate(BOOL,ANDEXP,"AND",0,$1,$3,NULL,0); 
	
	     										 else 
					                                             yyerror("Expression Types Do not Match"); 

					                          }
					
	
	| expression OR expression				
	                                          { printf("\n Reading OREXP \n"); 
	                                              if($1->type== BOOL && $3->type == BOOL)
	                                                           $$=nodeCreate(BOOL,OREXP,"OR",0,$1,$3,NULL,0); 
	   
	 											   else 
				                                               yyerror("Expression Types Do not Match"); 

				                              }
				
		
	| expression LT expression					
	                                          { printf("\n Reading LTEXP \n"); 
	                                             if($1->type== INT && $3->type == INT) 
	                                                         $$=nodeCreate(BOOL,LTEXP,"LT",0,$1,$3,NULL,0); 
	
												  else 
				                                             yyerror("Expression Types Do not Match"); 

				                              }
	
	
	| expression GT expression				
	                                          {   printf("\n Reading GTEXP \n");       
	                                              if($1->type== INT && $3->type == INT) 
	                                                         $$=nodeCreate(BOOL,GTEXP,"GT",0,$1,$3,NULL,0);
	 
												   else 
				                                              yyerror("Expression Types Do not Match"); 

				                              }
				
				
		
	| expression LE expression				
	                                           {  printf("\n Reading LEEXP \n");
	                                               if($1->type== INT && $3->type == INT) 
	                                                          $$=nodeCreate(BOOL,LEEXP,"LE",0,$1,$3,NULL,0); 
	
												    else 
				                                              yyerror("Expression Types Do not Match"); 

				                                }
		
		
	| expression GE expression					
	                                          {   printf("\n Reading GEEXP \n"); 
	                                               if($1->type== INT && $3->type == INT) 
	                                                           $$=nodeCreate(BOOL,GEEXP,"GE",0,$1,$3,NULL,0);
	
	 											     else 
				                                               yyerror("Expression Types Do not Match"); 

				                               }
				
	
	| expression EQ expression				
	                                           {  printf("\n Reading EQEXP \n");
	                                                if ($1->type== INT && $3->type == INT)
	                                                            $$=nodeCreate(BOOL,EQEXP,"EQ",0,$1,$3,NULL,0); 
	
													else 
					                                             yyerror("Expression Types Do not Match"); 

					                           }
					
	
	| expression NE expression				
	                                          {   printf("\n Reading NEEXP \n");
	                                               if($1->type== INT && $3->type == INT)
	                                                            $$=nodeCreate(BOOL,NEEXP,"NE",0,$1,$3,NULL,0); 
	
													 else 
					                                             yyerror("Expression Types Do not Match"); 

					                           }
					
		
	| NOT expression				    	
	                                          {   printf("\n Reading NOTEXP \n");
	                                                 if($2->type== BOOL)
	                                                              $$=nodeCreate(BOOL,NOTEXP,"NOT",0,$2,NULL,NULL,0); 
	
													 else 
					                                              yyerror("Expression Types Do not Match"); 

					                           }
					
	
	| ID					    	
	                                          { printf("\n Reading ID = %s\n",yylval.name);
												printf("\n Llookup with funcCount = %d\n",funcCount);
	                                             tempL = Llookup(yylval.name,funcCount);  
	                                             if(tempL!=NULL)
	                                                       {printf("\n Found with tempL !=NULL %s\n",yylval.name);
	                                                         $$=nodeCreate(tempL->type,VAR,yylval.name,0,NULL,NULL,NULL,0);
	                                                     printf("\n nodeCreated with type= %d and name = %s\n",tempL->type,yylval.name);
	                                                    }
	
	                                            
	                                            else 
			                                              { tempG= Glookup(yylval.name);
		                                                      if (tempG!=NULL)
		                              						    { printf("\n Found with tempG!NULL = %s\n", yylval.name);
		                                                          $$=nodeCreate(tempG->type,VAR,yylval.name,0,NULL,NULL,NULL,0);
		                                              printf("\n nodeCreated with type= %d and name = %s\n",tempG->type,yylval.name);   


		                                                          }

		                                                      else

		                                                         yyerror("Undeclared Variable"); 
		                                                    }

			                                   }
			
	
	| ID LEFT_SQR_BRACKET expression RIGHT_SQR_BRACKET			
	                                             { printf("\n Reading ID[num] = %s[] \n",yyval.name);
													printf("\n Llookup with funcCount = %d\n",funcCount);
	                                                tempL=Llookup(yyval.name,funcCount); 
	                                                if((tempL!=NULL) && ($3->type== INT))
	                                                       $$=nodeCreate(tempL->type,ARRAY,yyval.name,0,$3,NULL,NULL,0); 
	                                             
	
													else 
					                                      
					                                              { 	printf(" \nWill now look in Glookup with value = %s\n",yyval.name);
																	tempG= Glookup(yyval.name);
																     printf(" \nDone Glookup now in grammer.y file\n");
				                                                      if ((tempG!=NULL)  && ($3->type== INT))
				                              						    { //printf("\n Reading ID[num] = %s[]\n", %1);
																			printf(" \nentered tempG !=NUll block\n");
				                                                           $$=nodeCreate(tempG->type,ARRAY,yyval.name,0,$3,NULL,NULL,0);
				 																printf(" \nnode Created in ID[NUM] expression\n");


				                                                          }

				                                                      else

				                                                         yyerror("Undeclared Variable"); 
				                                                    }

					                               }
	      	
	
	| NUM					    	
	                                              {  printf("\n Reading NUM =%d \n",yylval.value);
	                                                 $$=nodeCreate(INT,CONST,"IntConst",yylval.value,NULL,NULL,NULL,0); }
	
	
	| BOOLEAN_OP				
	                                               { printf("\n Reading BOOLEAN_OP with value = %d \n",yylval.value);
	                                                 $$=nodeCreate(BOOL,BOOLCONST,"BoolConst",yylval.value,NULL,NULL,NULL,0);}
	
	  	
	| function_call				   
	                                              {printf("\n Reading Function CAll \n");
	                                                 $$=nodeCreate($1->type,FNCALLS,"FuncCall",0,$1,NULL,NULL,0); }
	
	
    | SUBOP expression %prec UMINUS       
                                                   {printf("\n Reading UNIARY SUBOPEXP \n");
                                                      if($2->type==INT)
                                                              $$=nodeCreate(INT,UMINUSEXP,"Negation",0,$2,NULL,NULL,0);

												 	else 
						                                      yyerror("Expression Type Does not Match (INTEGER) "); 

						                              }
						
	; 
	
	
	

function_call:
	  ID LEFT_ROUND_BRACKET parameter_list RIGHT_ROUND_BRACKET			
	                                            { tempG = Glookup(yyval.name); 
	                                              if((tempG!=NULL))
	                                                      $$=nodeCreate(tempG->type,FNCALL,id_name,0,$3,NULL,NULL,0);
	
											 	 else 
					                                     yyerror("Undeclared Variable"); 

					                            }
					
	;
	
	
	

parameter_list:
	parameter_list SEPARATOR expression			
	                                                 { if($3->nodetype)!=FNCALLS)
															$$=nodeCreate(VOID,FCLISTS,"FuncArgsList",0,$1,NULL,NULL,0); 
														else
																yyerror("Invalid Actuall Parameter, parameter cannot be a functioncall");	
													}
	
	| expression					   
	                                                 {  if($1->nodetype)!=FNACALLS)
																$$=nodeCreate(VOID,FCLIST,"FuncArg",0,$1,NULL,NULL,0);
														else
																yyerror("Invalid Actuall Parameter, parameter cannot be a functioncall");
														}  
	
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

   treeCreate(rootmain);

   printf("\nGsymbol Table Traversal\n");
   GsymbolTraversal();
   printf("\n\nLsymbol Table Traversal\n");
   for(int i=0;i<funcCount;i++)
	{	printf("\nLsymbol Table[%d] Traversal  : \n",i);
		LsymbolTraversal(i);
	}
    
   // intermCodeGenerator(rootstmt);

   //  intermCodeTraversal();

   // machineCodeGenerator(ahead);

   

    if(e==0) printf("\n\nParsed Successfully\nLines = %d\n\n",linenumber);
    else printf("\n\nERROR while parsing\n\n");

 printf("START\n") ;
    codeGenerator(rootstmt,0);
   printf("HALT\n");

    return 0;
}
