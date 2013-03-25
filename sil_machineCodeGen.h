








int rnum = 0;
void assemble(struct symbol *temp)
{
    if(temp != NULL)
    {
        printf("MOV R%d, [%d]\n", rnum, temp->binding);
        rnum++;
    }
}

int assembleconst(char constant[])
{
    if(!strcmp(constant,"")) return 0;
    char chk = constant[0];
    if((int)chk >= 48 && (int)chk <= 57)
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
    if(!flag && strcmp(s,""))
    {
        struct symbol *l = lookup(s,0,1);
        if(l!= NULL) assemble(l);
    }

}
void machiceCodeGenerator(struct addrcode *root)
{
    struct symbol *left=NULL;
    struct symbol *right=NULL;
    struct symbol *var = NULL;
    char templeft[20],tempright[20];
    int flag = 0;
    printf("START\n");
    if(root!= NULL)
    {   while(root!=NULL)
        {   

            if(!strcmp(root->left,"")&&!strcmp(root->right,"")&&!strcmp(root->var,""))
            {
                printf("%s\n",root->op);
            }
            else if(!strcmp(root->op,">"))
            {   add(root->left);
                add(root->right);
                printf("GT R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(!strcmp(root->op,"<"))
            {
                add(root->left);
                add(root->right);
                printf("LT R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(!strcmp(root->op,">="))
            {
                add(root->left);
                add(root->right);
                printf("GE R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(!strcmp(root->op,"<="))
            {
                add(root->left);
                add(root->right);
                printf("LE R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(!strcmp(root->op,"=="))
            {   
                add(root->left);
                add(root->right);
                printf("EQ R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(!strcmp(root->op,"!="))
            {
                add(root->left);
                add(root->right);
                printf("NE R%d, R%d\n",rnum-2,rnum-1);
                rnum--;
            }
            else if(!strcmp(root->op,"not"))
            {
                add(root->left);
                printf("JZ R%d, %s\n",rnum-1, root->var);
            }
            else if(!strcmp(root->op,"jmp"))
            {
                printf("JMP %s\n",root->var);
            }
           
            else if(!strcmp(root->op,"+"))
            {

                add(root->left);
                add(root->right);
                printf("ADD R%d, R%d\n", rnum-2, rnum-1);
                rnum--;            
            }
            else if(!strcmp(root->op,"*"))
            {
                add(root->left);
                add(root->right);
                printf("MUL R%d, R%d\n", rnum-2, rnum-1);
                rnum--;
            }    
            else if(!strcmp(root->op,"/"))
            { 
                add(root->left);
                add(root->right);
                printf("DIV R%d, R%d\n", rnum-2, rnum-1);
                rnum--;
            }    
            else if(!strcmp(root->op,"-")&& strcmp(root->right,"")!=0)
            {
                add(root->left);
                add(root->right);
                printf("SUB R%d, R%d\n", rnum-2, rnum-1);
                rnum--;
            }    
            else if(!strcmp(root->op,"%%"))
            {

                add(root->left);
                add(root->right);
                printf("MOD R%d, R%d\n", rnum-2, rnum-1);
                rnum--;            
            }

            else if(!strcmp(root->op,"-"))
            {
                add(root->left);
                printf("MOV R%d, 0\n",rnum);
                printf("SUB R%d, R%d\n", rnum, rnum-1);
                printf("MOV R%d, R%d\n",rnum-1,rnum);
            }    
            else if(!strcmp(root->op,"="))
            {   add(root->left);
                add(root->right);
                rnum--;
                var = lookup(root->var,0,1);
                if(var != NULL) printf("MOV [%d], R%d\n", var->binding, rnum);
                else printf("MOV [R%d], R%d\n", rnum, rnum-1);
                rnum = 0;
            }
            else if(!strcmp(root->op,"Value_at"))
            {   //add(root->left);
                left = lookup(root->left,0,1);
                strcpy(tempright, root->right);
                int chk = (int) tempright[0];
                if(!strcmp((root->next)->op,"read")||!strcmp((root->next)->op, "write"))                
                {
                    if(chk >= 48 && chk<= 57)
                    {    printf("MOV R%d, %d\n", rnum, left->binding + atoi(tempright)); rnum++;}
                    else
                    {
                        right = lookup(root->right, 0 ,1);
                        if(right != NULL)
                        {    printf("MOV R%d, %d\n",rnum, left->binding + right->binding); rnum++;}
                        else
                        {
                            printf("MOV R%d, R%d\n", rnum, rnum-1);
                            printf("MOV R%d, %d\n",rnum+1,left->binding);
                            printf("ADD R%d, R%d\n", rnum, rnum+1);
                            rnum++;
                        }    
                    }
                }
                else
                {
                    if(chk>=48 && chk<=57)
                    {
                        printf("MOV R%d, [%d]\n", rnum, left->binding +  atoi(tempright));
                        rnum++;
                    }
                    else
                    {
                        right = lookup(root->right, 0 ,1);
                        if(right != NULL)
                        {    printf("MOV R%d, [%d]\n",rnum, left->binding + right->binding); rnum++;}
                        else
                        {
                            printf("MOV R%d, R%d\n", rnum, rnum-1);
                            printf("MOV R%d, %d\n",rnum+1, left->binding);
                            printf("ADD R%d, R%d\n", rnum, rnum+1);
                            printf("MOV R%d, [R%d]\n",rnum-1, rnum);
                            
                        }    
                    }
                }
            }
            
            else if(!strcmp(root->op,"read"))
            {
                left = lookup(root->left, 0 , 1);
                if(left->nodetype == VAR)
                {
                    printf("IN R%d\n",rnum);
                    printf("MOV [%d], R%d\n",left->binding, rnum);
                }
                else
                {
                    printf("IN R%d\n",rnum);
                    printf("MOV [R%d], R%d\n", rnum-1, rnum);
                    
                }   
                rnum = 0;
            }
            else if(!strcmp(root->op,"write"))
            {
                left = lookup(root->left, 0, 1);
                if(left!=NULL)
                    if(left->nodetype == VAR)
                    {
                        printf("MOV R%d, [%d]\n",rnum, left->binding);
                        printf("OUT R%d\n",rnum);
                    }
                    else
                    {
                        printf("MOV R%d, [R%d]\n",rnum, rnum-1);
                        printf("OUT R%d\n",rnum);
                                            
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



void assemblycode()
{
    assembly(tuples);
}
