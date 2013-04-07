#include<stdio.h>

int regcount=0,ifcount=0,whilecount=0;
	int funcCount=0,arraysize=0;
	struct Lsymbol *tl;
	struct Gsymbol *tg;

void codeGenerator(struct Tnode *root, int check,int fc)   // if check =0 then value of the variable required and if check=1 the address of the varialbe required
{
  
  switch(root->nodetype)
  {
	case(STMT): 
				//printf("\nCASE STMT \n");
	 			if((root->left)!=NULL) codeGenerator(root->left,0);
	            if((root->middle)!=NULL) codeGenerator(root->middle,0);
	            if((root->right)!=NULL) codeGenerator(root->right,0);
				break;

	case(ASSGNSTMT):
				//printf("\nCASE ASSGNSTMT \n");
				codeGenerator(root->left,1);
	            codeGenerator(root->middle,0);
	            printf("MOV [R%d], R%d\n",regcount-2,regcount-1);
	            regcount--;
	 			break;

	case(IFSTMT):	
			//	printf("\nCASE IFSTMT \n");
				printf("if_%d : \n",ifcount);			
				codeGenerator(root->left,0);
				printf("JZ R%d, endif_%d",regcount-1,ifcount);
				codeGenerator(root->right,0);
				printf("endif_%d : \n",ifcount);
				ifcount++;
				break;

	case(IFELSESTMT):
			//	printf("\nCASE IFELSESTMT \n");
				printf("if_%d : \n",ifcount);
				codeGenerator(root->left,0);
				printf("JZ R%d, else_%d\n",regcount-1,ifcount);
				codeGenerator(root->middle,0);
				printf("JMP endif_%d\n",ifcount);
				codeGenerator(root->right,0);
				printf("endif_%d\n",ifcount);
				ifcount++;
				break;

	case(WHILESTMT):
			//	printf("\nCASE WHILESTMT \n");
				printf("while_%d\n",whilecount);
				codeGenerator(root->left,0);
				printf("JZ R%d, endwhile_%d\n",regcount-1,whilecount);
				codeGenerator(root->middle,0);
				printf("JMP while_%d\n",whilecount);
				whilecount++;
				break;

	case(READSTMT):
			//	printf("\nCASE READSTMT \n");
				codeGenerator(root->left,1);
				printf("IN R%d\n",regcount);
				printf("MOV [R%d], R%d\n",regcount-1,regcount);
				break;
	
	
	case(WRITESTMT):
			//	printf("\nCASE WRITESTMT \n");
				codeGenerator(root->left,0);
				printf("OUT R%d\n",regcount-1);
				break;


	case(ADDEXP):
			//	printf("\nCASE ADDEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("ADD R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(SUBEXP):
			//	printf("\nCASE SUBEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("SUB R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(MULEXP):
			//	printf("\nCASE MULEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("MUL R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(DIVEXP):
			//	printf("\nCASE DIVEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("DIV R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(MODEXP):
			//	printf("\nCASE MODEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("MOD R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(ANDEXP):
			//	printf("\nCASE ANDEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("AND R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(OREXP):
			//	printf("\nCASE OREXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("OR R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(LTEXP):
			//	printf("\nCASE LTEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("LT R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(GTEXP):
			//	printf("\nCASE GTEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("GT R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(LEEXP):
			//	printf("\nCASE LEEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("LE R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(GEEXP):
			//	printf("\nCASE GEEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("GE R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(EQEXP):
			//	printf("\nCASE EQEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("EQ R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(NEEXP):
			//	printf("\nCASE NEEXP \n");
				codeGenerator(root->left,0);
				codeGenerator(root->middle,0);
				printf("NE R%d, R%d\n",regcount-2,regcount-1);
				regcount--;
				break;

	case(NOTEXP):
			//	printf("\nCASE NOTEXP \n");
				codeGenerator(root->left,0);
				printf("MOV R%d, 0\n",regcount);
				printf("MOV R%d, R%d\n",regcount-1,regcount);
				regcount--;
				break;

	case(PARTHSEXP) :
			//	printf("\nCASE PARTHSEXP \n");
				codeGenerator(root->left,0);
				break;

	case(VAR):
			//	printf("\nCASE VAR \n");
			//	printf("\nGoing to Llookup with value %s \n",root->name);
				tl=Llookup(root->name,fc-1);
			//	printf("\nDone Llookup\n");
				if(tl!=NULL)
			    {   if(check==0)
						printf("MOV R%d, [%d]\n",regcount,tl->binding);
					else if (check==1)
						printf("MOV R%d, %d\n",regcount,tl->binding);
					regcount++;
				}
				else 
				{  
				   //printf("\nGoing to Glookup with value %s \n",root->name);
				   tg=Glookup(root->name);
				//	printf("\nDone Glookup\n");
					if(check==0)
						printf("MOV R%d, [%d]\n",regcount,tg->binding);
					else if (check==1)
						printf("MOV R%d %d\n",regcount,tg->binding);
					regcount++;
				}
				break;
				
	case(ARRAY) :
				//printf("\nCASE ARRAY \n");
				
				codeGenerator(root->left,0);
			//	printf("\nGoing to Glookup with value %s \n",root->name);
				tg=Glookup(root->name);
			//	printf("\nDone Glookup\n");
				if(check==0)
				{   
					printf("MOV R%d, %d\n",regcount, tg->binding);
					printf("ADD R%d, R%d\n",regcount,regcount-1);
					printf("MOV R%d, [R%d]\n",regcount-1,regcount);
				}	
				else if (check==1)
				{	
					printf("MOV R%d, %d\n",regcount, tg->binding);
					printf("ADD R%d, R%d\n",regcount,regcount-1);
					printf("MOV R%d, R%d\n",regcount-1,regcount);
				}
				break;
				
	
	case(CONST) :
			//	printf("\nCASE CONST \n");
				printf("MOV R%d, %d\n",regcount,root->value);
				regcount++;
				break;
				
	
	case(BOOLCONST) :
			//	printf("\nCASE BOOLCONST \n");
				printf("MOV R%d, %d\n",regcount,root->value);
				regcount++;
				break;
			
		
	case(UMINUSEXP) :
			//	printf("\nCASE UMINUSEXP \n");
				codeGenerator(root->left,0);	
				printf("MOV R%d, 0\n",regcount);
				printf("SUB R%d, R%d\n",regcount,regcount-1);
				printf("MOV R%d, R%d\n",regcount-1,regcount);
				break;
				
				
	default : 
			//	printf("\nCASE default \n");
				if((root->left)!=NULL) codeGenerator(root->left,0);
	            if((root->middle)!=NULL) codeGenerator(root->middle,0);
	            if((root->right)!=NULL) codeGenerator(root->right,0);
				break;
				
	}
	
}
				
				
	
				



















							
			
