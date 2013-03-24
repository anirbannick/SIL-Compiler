#include <stdio.h>
//#include <malloc.h>
#include <stdlib.h>
#define ARITHMATIC 1
#define RELATIONAL 2

int tempcount = 0;
int labelcount = 0;
struct symbol *lregvar, *rregvar;
struct addrcode
{
    char t[20];
    char left[20];
    char right[20];
    char op[20];
    struct addrcode *next;
}*ahead=NULL,*atail=NULL, *intermCode;

void addrCodeInsert(char *op, char *left, char *right, char *t)
{
    //head = root;
    if(ahead == NULL)
    {
       intermCode = (struct addrcode *)malloc(sizeof(struct addrcode)); 
        ahead = intermCode;
		atail = intermCode;
    }
    else
    {
       
        atail->next = (struct tuple *)malloc(sizeof(struct tuple));
        atail = atail->next;
    }
    strcpy(atail->op,op);
    strcpy(atail->left,left);
    strcpy(atail->right,right);
    strcpy(atail->t,t);
    atail->next = NULL;
    tempcount++;
}



// ###################################### 3 - ADDRESS - CODE - GENARATION ############################################################


void intermCodeGenerator(struct Tnode *root)
{
    char left[20],right[20],t[10],offset[10];
    int flag = 0;
    char op[20];
    if (root != NULL)
    {       
        switch (root->nodetype)
        {
            case(READSTMT):
                        {   if((root->l)->nodetype == VAR )
                                tupleinsert(tuples,"read",(root->l)->name,"","");
                            else
                            {
                                codegen(root->l);
                                sprintf(offset,"t%d",tempcount-1);
                                tupleinsert(tuples,"read",(root->l)->name,offset,"");
                                
                            }
                            tempcount = 0;
                        }
                        break;
            case(WRITESTMT):
                        {   if((root->l)->nodetype == VAR || (root->l)->nodetype == CONST || (root->l)->nodetype == BOOLCONST)
                                tupleinsert(tuples, "write",(root->l)->name, "", "");
                            else if((root->l)->nodetype == ARRAY)
                            {
                                codegen(root->l);
                                sprintf(offset,"t%d",tempcount-1);
                                tupleinsert(tuples,"write",(root->l)->name,offset,"");
                            }
                            else
                            {
                                codegen(root->l);
                                sprintf(left,"t%d",tempcount-1);
                                tupleinsert(tuples,"write",left,"","");
                            } 
                            tempcount  = 0;
                        }
                        break;
            case(WHILESTMT):
                        {
                            int label = labelcount++;
                            sprintf(left,"l%d:",label);
                            tupleinsert(tuples,left,"","","");          //  Starting label of while
                            tempcount--;
                            codegen(root->l);                           //  Conditions
                            sprintf(left, "t%d", tempcount-1);
                            sprintf(var, "endwhile%d", label);
                            tupleinsert(tuples,"not", left, "", var);   //  Check and goto 
                            tempcount--;
                            codegen(root->m);                           //  Statemens
                            strcpy(op,"jmp");
                            sprintf(var, "l%d", label);              //  Jump to the starting label of while
                            tupleinsert(tuples,op, "", "", var);
                            sprintf(op, "endwhile%d:", label);
                            tupleinsert(tuples, op, "", "", "");        //  Ending label of while
                        }
                        break;
                        
            case(IFSTMT):
                        {
                            int label = labelcount++;
                            codegen(root->l);                           //  Condition
                            sprintf(left,"t%d",tempcount-1);            
                            if(root->r == NULL) 
                                sprintf(var,"endif%d",label);      //  IF-ENDIF    
                            else
                                sprintf(var,"l%d",label);          //  IF-ELSE-ENDIF                    
                            tupleinsert(tuples,"not",left,"",var);
                            tempcount--;
                            codegen(root->m);
                            if(root->r != NULL)                         //  ELSE part
                            {
                                strcpy(op,"jmp");
                                sprintf(var,"endif%d",label);
                                tupleinsert(tuples, op, "", "", var);
                                tempcount--;                   
                                sprintf(op,"l%d:",label);
                                tupleinsert(tuples, op, "", "", "");
                                tempcount--;
                                codegen(root->r);
                                
                                sprintf(op,"endif%d:",label);
                                tupleinsert(tuples, op, "", "", "");
                                tempcount--;
                            }
                            else                                        //  ENDIF
                            {
                                sprintf(op,"endif%d:",label);
                                tupleinsert(tuples, op, "", "", "");
                                tempcount--;
                            }
                        }
                        break;


            case(STMTS):
                        {
                            if(root->l != NULL) codegen(root->l);
                            if(root->m != NULL) codegen(root->m);
                            if(root->r != NULL) codegen(root->r);    
                        }
                        break;

            case(ASGNSTMT): 
                        {
                            if ((root->m)->nodetype != VAR && (root->m)->nodetype != CONST )
                            {   codegen(root->m);
                                sprintf(right,"t%d",tempcount-1);                   
//                                    printf("%s = %s\n\n",(root->l)->name,right);
                            }
                            else
                            {
                                sprintf(right,"%s",(root->m)->name);
//                                    printf("%s = %s\n\n",(root->l)->name,(root->m)->name);
                            }   
                            if((root->l)->nodetype != VAR && (root->l)->nodetype != CONST )
                            {
                                codegen(root->l);
                                sprintf(left,"t%d",tempcount-1);
                                //printf("%d\n",(root->l)->nodetype);
                            }
                            else
                            {
                                sprintf(left,"%s",(root->l)->name);                             
                            }
                            tupleinsert(tuples, "=", right, "", left);                                    
                            tempcount = 0;
                        }
                        break;
          
            case(ADDEXP):
                        {
                            flag = ARITHMATIC; strcpy(op , "+");
                        }
                        break;
   
            case(SUBEXP):
                        {
                            flag = ARITHMATIC; strcpy(op , "-");
                        }
                        break;
   
            case(MULEXP):
                        {
                            flag = ARITHMATIC; strcpy(op , "*");
                        }
                        break;

            case(DIVEXP):
                        {
                            flag = ARITHMATIC; strcpy(op , "/");
                        }
                        break;

            case(MODEXP):
                        {
                            flag = ARITHMATIC; strcpy(op , "%%");
                        }
                        break;
                        
            case(ANDEXP):
                        {
                            flag = RELATIONAL; strcpy(op, "AND");                        
                        }
                        break;
                        
           case(OREXP):
                        {
                            flag = RELATIONAL; strcpy(op, "OR");
                        }
                        break;
                    
            case(NOTEXP):
                        {
                            flag = RELATIONAL; strcpy(op, "NOT");                        
                        }
                        break;
                                 
            case(ARRAY):
                        {   if((root->l)->nodetype != VAR && (root->l)->nodetype != CONST )
                            {
                                codegen(root->l);
                                sprintf(offset,"t%d",tempcount-1);
                            }
                            else
                            {
                                strcpy(offset,(root->l)->name);
                            }
                            sprintf(left,"%s",root->name);
                            sprintf(var,"t%d",tempcount);
                            tupleinsert(tuples, "Value_at", left, offset, var);
                        }
                        break;
                        
            case(UNARYM):
                    {   
                        if((root->l)->nodetype != VAR && (root->l)->nodetype != CONST ) 
                        {
                            codegen(root->l);
                            sprintf(left,"t%d",tempcount-1);
                        }
                        else
                        {
                            sprintf(left,"%s",(root->l)->name);
                        
                        }    
                        sprintf(var,"t%d",tempcount);
                        tupleinsert(tuples, "-", left, "", var);
                    }
                    break;
        
            case(GTEXP):
                    {
                        flag = RELATIONAL; strcpy(op, ">");
                    }
                    break;
        
            case(GEEXP):
                    {
                        flag = RELATIONAL; strcpy(op, ">=");
                    }
                    break;

            case(LTEXP):
                    {
                        flag = RELATIONAL; strcpy(op, "<");
                    }
                    break;

            case(LEEXP):
                    {
                        flag = RELATIONAL; strcpy(op, "<=");
                    }
                    break;

            case(NEEXP):
                    {
                        flag = RELATIONAL; strcpy(op, "!=");
                    }
                    break;
            
            case(EQEXP):
                    {
                        flag = RELATIONAL; strcpy(op, "==");
                    }
                    break;

            default:   
                    {
                        if(root->l != NULL)codegen(root->l);
                        if(root->m != NULL)codegen(root->m);
                        if(root->r != NULL)codegen(root->r);
                    }
                    break;                
        }

        if(flag==ARITHMATIC || flag==RELATIONAL)
        {   
            if((root->l)->nodetype != VAR && (root->l)->nodetype != CONST)
            {
                codegen(root->l);
                sprintf(left,"t%d",tempcount-1);
            }
            else
            {
                sprintf(left,"%s",(root->l)->name); 
            }
            if((root->m)->nodetype !=VAR && (root->m)->nodetype != CONST)
            {
                codegen(root->m);
                sprintf(right,"t%d",tempcount-1);
            }
            else
            {
                sprintf(right,"%s",(root->m)->name);
            }

            sprintf(var,"t%d",tempcount);
//                printf("left::%s\n",left);
            tupleinsert(tuples, op, left, right, var);
//                printf("t%d = %s %c %s\n",tempcount,left,op,right);                            
            flag = 0;
        }
    }
}