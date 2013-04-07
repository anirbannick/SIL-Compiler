
#include <stdio.h>
#include <stdlib.h>

int rnum = 0;


void Gassemble(struct Gsymbol *temp)
{
    if(temp != NULL)
    {
        printf("MOV R%d, [%d]\n", rnum, temp->binding);
        rnum++;
    }
}


void Lassemble(struct Lsymbol *temp)
{
    if(temp != NULL)
    {
        printf("MOV R%d, [%d]\n", rnum, temp->binding);
        rnum++;
    }
}

int assembleconst(char constant[])
{
    if(strcmp(constant,"")==0) return 0;
    char ch = constant[0];
    if((int)ch >= 48 && (int)ch <= 57)
    {
        printf("MOV R%d, %s\n",rnum, constant);
        rnum++;
        return 1;
    }
    return 0;
}

void add(char *s)
{   
    int flag = assembleconst(s);
    if(!flag && (strcmp(s,"")!=0))
    {
        struct Lsymbol *l = Llookup(s,funcCount);
        if(l!= NULL) Lassemble(l);
       
        else {
			struct Gsymbol *l = Glookup(s);
			if(l!=NULL)  Gassemble(l);
             }
    }

}
void machiceCodeGenerator(struct addrcode *root)
{
    struct Lsymbol *ll=NULL, *lr=NULL;
    struct Gsymbol *gl=NULL,  *gr=NULL;
    
    char tl[20],tr[20];
    int flag = 0;
    printf("START\n");
    
   if(root!= NULL)
    { 
	     while(root!=NULL)
         {   

            if( (strcmp(root->left,"")==0) && (strcmp(root->right,"")==0) &&  (strcmp(root->t,"")==0))
            {
                printf("%s\n",root->op);
            }
            else if(strcmp(root->op,">")==0)
            {   add(root->left);
                add(root->right);
                printf("GT R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(strcmp(root->op,"<")==0)
            {
                add(root->left);
                add(root->right);
                printf("LT R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(strcmp(root->op,">=")==0)
            {
                add(root->left);
                add(root->right);
                printf("GE R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(strcmp(root->op,"<=")==0)
            {
                add(root->left);
                add(root->right);
                printf("LE R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(strcmp(root->op,"==")==0)
            {   
                add(root->left);
                add(root->right);
                printf("EQ R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(strcmp(root->op,"!=")==0)
            {
                add(root->left);
                add(root->right);
                printf("NE R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(strcmp(root->op,"not")==0)
            {
                add(root->left);
                printf("JZ R%d, %s\n",rnum-1, root->t);
            }
            else if(strcmp(root->op,"goto")==0)
            {
                printf("JMP %s\n",root->t);
            }
           
            else if(strcmp(root->op,"+")==0)
            {

                add(root->left);
                add(root->right);
                printf("ADD R%d, R%d\n", rnum-2, rnum-1);
                rnum--;            
            }
            else if(strcmp(root->op,"*")==0)
            {
                add(root->left);
                add(root->right);
                printf("MUL R%d, R%d\n", rnum-2, rnum-1);
                rnum--;
            }    
            else if(strcmp(root->op,"/")==0)
            { 
                add(root->left);
                add(root->right);
                printf("DIV R%d, R%d\n", rnum-2, rnum-1);
                rnum--;
            }    
            else if((strcmp(root->op,"-")==0)  && (strcmp(root->right,"")!=0))
            {
                add(root->left);
                add(root->right);
                printf("SUB R%d, R%d\n", rnum-2, rnum-1);
                rnum--;
            }    
            else if(strcmp(root->op,"%%")==0)
            {

                add(root->left);
                add(root->right);
                printf("MOD R%d, R%d\n", rnum-2, rnum-1);
                rnum--;            
            }

            else if(strcmp(root->op,"-")==0)
            {
                add(root->left);
                printf("MOV R%d, 0\n",rnum);
                printf("SUB R%d, R%d\n", rnum, rnum-1);
                printf("MOV R%d, R%d\n",rnum-1,rnum);
            }    
            else if(strcmp(root->op,"=")==0)
            {   add(root->left);
                //add(root->right);
                 rnum--;
                ll = Llookup(root->t);
                if(ll != NULL)
                           printf("MOV [%d], R%d\n", ll->binding, rnum);
                else {
				           gl = Glookup(root->t,funcCount);
				           if(gl !=NULL)
                                 	printf("MOV [%d], R%d\n", gl->binding, rnum);			          
                           else 
                                    printf("MOV [R%d], R%d\n", rnum, rnum-1);
                     }
                    
                rnum = 0;
            }
            else if(strcmp(root->op,"Array_Value"))
            {  
                ll = Llookup(root->left,funcCount);
				if (ll==NULL) { gl = Glookup(root->left); }
				
                strcpy(tr, root->right);
                int ch = (int) tr[0];
                if((strcmp((root->next)->op,"read")==0)  ||   (strcmp((root->next)->op, "write")==0))                
                {
                    if(ch >= 48 && ch<= 57)
                    {   if(lL!=NULL)
	                        printf("MOV R%d, %d\n", rnum, ll->binding + atoi(tr)); 
	                    else if (gl!=NULL)
	                          printf("MOV R%d, %d\n", rnum, gl->binding + atoi(tr)); 
	
	                    rnum++;
	                 }
                    else
                    {
                        lr = Llookup(root->right,funcCount);
						if(lr==NULL) { gr = Glookup(root->right);  }
                        if(lr != NULL)
                        {   if(ll!=NULL)
	                               printf("MOV R%d, %d\n",rnum, ll->binding + lr->binding);
	                        else if(gl!=NULL)
	                                printf("MOV R%d, %d\n",rnum, gl->binding + lr->binding);
	                       
	
	                        rnum++;
	                     }
	
	                   else if(gr!=NULL)
	                    {
		 
		                     if ( ll!=NULL)
		                                 printf("MOV R%d, %d\n",rnum, ll->binding + gr->binding);
		                        else if (gl!=NULL)
		                                 printf("MOV R%d, %d\n",rnum, gl->binding + gr->binding);
		
		                     rnum++
	                     }
	
	                 
                        


                     else
                        {
                            printf("MOV R%d, R%d\n", rnum, rnum-1);
                            if(ll!=NULL)
                                 printf("MOV R%d, %d\n",rnum+1,ll->binding);
                            else if(gl!=NULL)
                                  printf("MOV R%d, %d\n",rnum+1,ll->binding);
                            printf("ADD R%d, R%d\n", rnum, rnum+1);
                            rnum++;
                        }    
                    }
                }
                else
                {
                    if(ch>=48 && ch<=57)
                    {  if(ll!=NULL)
                            printf("MOV R%d, [%d]\n", rnum, ll->binding +  atoi(tr));
                        else if(gl!=NULL)
                             printf("MOV R%d, [%d]\n", rnum, gl->binding +  atoi(tr));
                 
                        
                        rnum++;
                    }
                    else
                    {
                        lr = Llookup(root->right, funcCount);
						if (lr==NULL) gr=Glookup(root->right);
                        
                        if(lr != NULL)
                        {   if(ll!=NULL)
	                          printf("MOV R%d, [%d]\n",rnum, ll->binding + lr->binding); 
	                        
	                        else if(gl!=NULL)
	                             printf("MOV R%d, [%d]\n",rnum, gl->binding + lr->binding); 
	
	                     rnum++;  
                     	}

                       else if (gr!=NULL)
					      {   if(ll!=NULL)
	                          printf("MOV R%d, [%d]\n",rnum, ll->binding + gr->binding); 

	                        else if(gl!=NULL)
	                             printf("MOV R%d, [%d]\n",rnum, gl->binding + gr->binding); 

	                     rnum++;  
                     	}                       


                        else
                        {
                            printf("MOV R%d, R%d\n", rnum, rnum-1);
                            if(ll!=NULL)
                                 printf("MOV R%d, %d\n",rnum+1, ll->binding);
                             else if(gl!=NULL)
                                  printf("MOV R%d, %d\n",rnum+1, gl->binding);
                            printf("ADD R%d, R%d\n", rnum, rnum+1);
                            printf("MOV R%d, [R%d]\n",rnum-1, rnum);
                            
                        }    
                    }
                }
            }
            
            else if(strcmp(root->op,"read")==0)
            {
                ll = Llookup(root->left, funcCount);
                
				if(ll==NULL)  gl = Glookup(root->left);
			
			if(ll!=NULL)	
              { 
	             if(ll->nodetype == VAR)
                {
                    printf("IN R%d\n",rnum);
                    printf("MOV [%d], R%d\n",ll->binding, rnum);
                }
                else
                {
                    printf("IN R%d\n",rnum);
                    printf("MOV [R%d], R%d\n", rnum-1, rnum);
                    
                }   
                rnum = 0;
              
              }

           else if (gl!=NULL)
              {	
	          	if(gl->nodetype == VAR)
                {
                  printf("IN R%d\n",rnum);
                  printf("MOV [%d], R%d\n",gl->binding, rnum);
               }
              else
              {
                  printf("IN R%d\n",rnum);
                  printf("MOV [R%d], R%d\n", rnum-1, rnum);
                  
              }   
              rnum = 0;

             }
	               
          }

             
           
            else if(strcmp(root->op,"write")==0)
            {
                ll = Llookup(root->left, funcCount);
	  
		        if(ll==NULL)  gl = Glookup(root->left);

                
                if(ll !=NULL)
                   {
	                   if(ll->nodetype == VAR)
                    {
                        printf("MOV R%d, [%d]\n",rnum, ll->binding);
                        printf("OUT R%d\n",rnum);
                    }
                    else
                    {
                        printf("MOV R%d, [R%d]\n",rnum, rnum-1);
                        printf("OUT R%d\n",rnum);
                                            
                    }

                   }
                else if (gl!=NULL)
                {
	                   if(gl->nodetype == VAR)
                 {
                     printf("MOV R%d, [%d]\n",rnum, gl->binding);
                     printf("OUT R%d\n",rnum);
                 }
                 else
                 {
                     printf("MOV R%d, [R%d]\n",rnum, rnum-1);
                     printf("OUT R%d\n",rnum);
                                         
                 }

                }

         
               else
                    printf("OUT R%d\n",rnum-1);    
                
                rnum = 0;
                
           }
         
             root = root->next;
           
           }
    
      }

    printf("HALT\n");
}




