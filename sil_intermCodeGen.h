#include <stdio.h>
//#include <malloc.h>
#include <stdlib.h>


int tempcount = 0;
int lcount = 0;


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
   
    if(ahead == NULL)
    {
       intermCode = (struct addrcode *)malloc(sizeof(struct addrcode)); 
        ahead = intermCode;
		atail = intermCode;
    }
    else
    {
       
        atail->next = (struct tuple *)malloc(sizeof(struct addrcode));
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
	char left[20],right[20],t[20],arraysize[20],op[20];
    int expression = 0;
    
    if (root != NULL)
    {       
        switch (root->nodetype)
        {
            case(STMT):
                        
                            if(root->l != NULL) intermCodeGenerator(root->l);
                            if(root->m != NULL) intermCodeGenerator(root->m);
                            if(root->r != NULL) intermCodeGenerator(root->r);    
                        
                        break;

		    case(ASSGNSTMT): 
                        
	                       if ((root->m)->nodetype != VAR && (root->m)->nodetype != CONST  && (root-m)->nodetype != BOOLCONST)
			                      {   intermCodeGenerator(root->m);
			                          sprintf(right,"t%d",tempcount-1);                   

			                       }
			                else
			                            {  if((root->m)->nodetype == VAR )
			                                       sprintf(right,"%s",(root->m)->name);
			                               else
				                                  sprintf(right,"%s(%d)",(root->m)->name,(root->m)->value);
				                            
	
			                            }   
			               
			                if((root->l)->nodetype != VAR && (root->l)->nodetype != CONST && (root-l)->nodetype != BOOLCONST)
			                        {
			                              intermCodeGenerator(root->l);
			                              sprintf(left,"t%d",tempcount-1);

			                        }
			                           
		                      else
			                        {
			                             if((root->l)->nodetype == VAR )
			                                       sprintf(left,"%s",(root->l)->name);
			                               else
				                                  sprintf(left,"%s(%d)",(root->l)->name,(root->l)->value);                   
			                        
			                        }
			                            
			                 
			                 addrCodeInsert( "=", right, "", left);                                    
			                 tempcount = 0;
			               
			                 break;
			
			
			
		     case(ARRAY):
					                       
					       if((root->l)->nodetype != VAR && (root->l)->nodetype != CONST )
					                            
					                  {
					                        intermCodeGenerator(root->l);
					                        sprintf(arraysize,"t%d",tempcount-1);
					                  }
					           
					          else
					                  {   
						                     if((root->l)->nodetype == VAR )
			                                       sprintf(arraysize,"%s",(root->l)->name);
			                               else
				                                  sprintf(arraysize,"%s(%d)",(root->l)->name,(root->l)->value);
					                   }
					                            
					          sprintf(left,"%s",root->name);
					          sprintf(t,"t%d",tempcount);
					          addrCodeInsert("Array_Value", left, arraysize, t);
					                       
					 
					          break;
			
			case(IFSTMT):

		                 int lnum = lcount++;
				         
				        intermCodeGenerator(root->l);                          
				         sprintf(left,"t%d",tempcount-1);            
				                          
			            sprintf(t,"endif%d",lnum);       
				                                             
				         addrCodeInsert("not",left,"",t);
				                            
				        tempcount--;
				                           
				        intermCodeGenerator(root->m);
				       
				        sprintf(op,"endif%d:",lnum);
				        addrCodeInsert(op, "", "", "");
				        tempcount--;
				                        
				         break;
				
				
				
		    case(IFELSESTMT):

				           int lnum = lcount++;

				           intermCodeGenerator(root->l);                          
						   sprintf(left,"t%d",tempcount-1);            

						   sprintf(t,"l%d",lnum);   

						   addrCodeInsert("not",left,"",t);

						   tempcount--;

						   intermCodeGenerator(root->m);
					 
						   strcpy(op,"goto");
						   sprintf(t,"endif%d",lnum);
					       addrCodeInsert(op, "", "", t);
						   tempcount--;                   
						    sprintf(op,"l%d:",lnum);
				            addrCodeInsert(op, "", "", "");
						    tempcount--;
					        intermCodeGenerator(root->r);

						    sprintf(op,"endif%d:",lnum);
						    addrCodeInsert(op, "", "", "");
							tempcount--;
									                     

						   break;
						
						


		   case(WHILESTMT):
				                        
				           int lnum = lcount++;
				           sprintf(left,"l%d:",lnum);
				           addrCodeInsert(left,"","","");         
				           tempcount--;
				          intermCodeGenerator(root->l);                         
				           sprintf(left, "t%d", tempcount-1);
				            sprintf(t, "endwhile%d", lnum);
				           addrCodeInsert("not", left, "", t);   
				           tempcount--;
				           intermCodeGenerator(root->m);                       
				           strcpy(op,"goto");
				           sprintf(t, "l%d", lnum);              
				           addrCodeInsert(op, "", "", t);
				           sprintf(op, "endwhile%d:", lnum);
				           addrCodeInsert(op, "", "", "");        
				                       
				             break;




           case(READSTMT):
                          if((root->l)->nodetype == VAR)
                                addrCodeInsert("read",(root->l)->name,"","");
                            else
                            {
                                intermCodeGenerator(root->l);
                                sprintf(arraysize,"t%d",tempcount-1);
                                addrCodeInsert("read",(root->l)->name,arraysize,"");
                                
                            }
                            tempcount = 0;
                        
                        break;
            

       
            case(WRITESTMT):
                       
                          if((root->l)->nodetype == VAR || (root->l)->nodetype == CONST || (root->l)->nodetype == BOOLCONST)
                                { 
	                              if((root->l)->nodetype == VAR)
	                                     addrCodeInsert("write",(root->l)->name, "", "");
	        
	                              else
									{ 
										 sprintf(left,"%s(%d)",(root->l)->name,(root->l)->value);
									  
									     addrCodeInsert("write",left, "", "");
									}
	
	
                           else if ((root->l)->nodetype == ARRAY)
                          
                                {
                                     intermCodeGenerator(root->l);
                                     sprintf(arraysize,"t%d",tempcount-1);
                                     addrCodeInsert("write",(root->l)->name,arraysize,"");
                                }
                                     

                           else
                               {
                                     intermCodeGenerator(root->l);
                                     sprintf(left,"t%d",tempcount-1);
                                     addrCodeInsert("write",left,"","");
                               } 
                            

                           tempcount  = 0;
                        
                            break;
           
                        
            

            

            
          
          case(ADDEXP):
                        
                            expression = 1; 
                            strcpy(op , "+");
                        
                            break;
   
            case(SUBEXP):
                        
                            expression = 1;
                            strcpy(op , "-");
                        
                            break;
   
            case(MULEXP):
                        
                            expression = 1;
                            strcpy(op , "*");
                         
                            break;

            case(DIVEXP):
                        
                            expression = 1;
                            strcpy(op , "/");
                        
                            break;

            case(MODEXP):
                        
                            expression = 1;
                             strcpy(op , "%%");
                        
                            break;
                        
            case(ANDEXP):
                        
                           expression = 1;
                           strcpy(op, "AND");                        
                        
                             break;
                        
           case(OREXP):
                        
                            expression = 1;
                            strcpy(op, "OR");
                        
                            break;
                    
            case(NOTEXP):
                        
                           expression = 1;
                           strcpy(op, "NOT");                        
                         
                            break;
                                 
           
                        
           
           case(GTEXP):
                     
                           expression = 1;
                           strcpy(op, ">");
                    
                             break;
        
            case(GEEXP):
                    
                            expression = 1;
                            strcpy(op, ">=");
                    
                             break;

            case(LTEXP):
                     
                           expression = 1;
                            strcpy(op, "<");
                    
                             break;

            case(LEEXP):
                      
                           expression = 1;
                           strcpy(op, "<=");
                    
                             break;

            case(NEEXP):
                    
                            expression = 1;
                            strcpy(op, "!=");
                    
                             break;
           
            case(EQEXP):
                    
                            expression = 1;
                            strcpy(op, "==");
                    
                            break;


		     case(UMINUS):
			                 
			              
			                 if((root->l)->nodetype != VAR && (root->l)->nodetype != CONST ) 
			                        {
			                            intermCodeGenerator(root->l);
			                            sprintf(left,"t%d",tempcount-1);
			                        }
			                        
			                 else
			                       {	
				                         if((root->l)->nodetype == VAR)
			                                     sprintf(left,"%s",(root->l)->name);

			                              else
											
												 sprintf(left,"%s(%d)",(root->l)->name,(root->l)->value);

								    }    
			                        
			
			                 sprintf(t,"t%d",tempcount);
			                 addrCodeInsert("-", left, "", t);
			                    
			                    
			                break;

            
  
             default:   
                    
                          if(root->l != NULL)  intermCodeGenerator(root->l);
                          if(root->m != NULL)   intermCodeGenerator(root->m);
                          if(root->r != NULL)   intermCodeGenerator(root->r);
                    
                          break;                
       

         }

       


      if(expression == 1)
         {   
            if((root->l)->nodetype != VAR && (root->l)->nodetype != CONST &&  (root->l)->nodetype != BOOLCONST)
            {
                intermCodeGenerator(root->l);
                sprintf(left,"t%d",tempcount-1);
            }
            
            
            else
            {
                if((root->l)->nodetype == VAR)
                         sprintf(left,"%s",(root->l)->name);

                  else
					
						 sprintf(left,"%s(%d)",(root->l)->name,(root->l)->value);
            }
            
           
           if((root->m)->nodetype != VAR && (root->m)->nodetype != CONST &&  (root->m)->nodetype != BOOLCONST)
            {
                intermCodeGenerator(root->m);
                sprintf(right,"t%d",tempcount-1);
            }
            
           
          else
            {
                if((root->m)->nodetype == VAR)
                         sprintf(right,"%s",(root->m)->name);

                  else
					
						 sprintf(right,"%s(%d)",(root->m)->name,(root->m)->value);
            }

            
            sprintf(t,"t%d",tempcount);

            addrCodeInsert(op, left, right, t);
                          
            flag = 0;
        }
    }
}



void intermCodeTraversal()
{   
	struct addrcode *temp=NULL;
	 
	temp=ahead;
    
    printf("\n\n3 - Address - Code: \n")
    while(temp!=NULL)
        {  
	        if(!strcmp(temp->op,"goto"))
             {
                printf("%s %s\n",temp->op,temp>t);
             }
            else if(!strcmp(temp->left,""))
            {
                printf("%s\n",temp->op);
            
            }
            else if(!strcmp(temp->right,""))
            {
                printf("%s %s %s\n",temp->op,temp->left,temp->var);
            
            }
            else
            {
                printf("%s %s %s %s\n",temp->op , temp->left,temp->right,tmep->var);
            
            }
            temp = temp->next;
     
         }


}







