//#include<iostream>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
//#include<malloc.h>
//using namespace std;
int base=0;

struct ArgStruct
{
	char *name;
	int type;
	int nodetype;
	int size;
	int offset;
	struct ArgStruct *next;
	
	} *headA[10],*tailA[10] ;






struct Gsymbol {

char *name; // Name of the Identifier

int type; // TYPE can be INTEGER or BOOLEAN

int nodetype;

/***The TYPE field must be a TypeStruct if user defined types are allowed***/

int size; // Size field for arrays

int binding; // Address of the Identifier in Memory

ArgStruct *arglist; // Argument List for functions

/***Argstruct must store the name and type of each argument ***/

struct Gsymbol *next; // Pointer to next Symbol Table Entry */

int fc;				//function count

} *headg=NULL, *tailg=NULL;



struct Lsymbol {

/* Here only name, type, binding and pointer to next entry needed */
	char *name; // Name of the Identifier

	int type; // TYPE can be INTEGER or BOOLEAN
	int nodetype;
	int binding;
	/***The TYPE field must be a TypeStruct if user defined types are allowed***/
	
	struct Lsymbol *next; // Pointer to next Symbol Table Entry */

} *headl[10], *taill[10];


void Arginstall(char *name,int type,int nodetype,int size,int offset,int fc)
{
	printf(" \nentered Arginstall block\n");
    struct  ArgStruct *temp=(struct ArgStruct *)malloc(sizeof(struct ArgStruct));

     temp->name =  name;
     temp->type=type;
	temp->nodetype=nodetype;
	temp->size=size;
	temp->offset=offset;	
     temp->next=NULL;

     	if (headA[fc]==NULL)
        {
            headA[fc]=temp;
            tailA[fc]=temp;   
          
         }

     else
        
         {
            tailA[fc]->next=temp;
            tailA[fc]=tailA[fc]->next;
          }
	
}


struct ArgStruct Arglookup(char *name,int fc)
{
	struct	ArgStruct *temp=NULL;
    
   	printf("\nin Arglookup \nlooking for %s , in function no. - %d\n",name,fc); 

  if(headArg[fc]!=NULL)
    { temp=headArg[fc];
   	printf("\n headArg[n]!=NULL\n");
     while (temp!=NULL)
       
         {  	printf("found %s\n",temp->name);
            if( strcmp(temp->name,name)==0)
                  {
                      return temp;
                         
                   }

            else
                 { temp=temp->next;
	              printf("\ntemp->name not equal to name\n");
	             }

          }
       }

    else
	    {   printf("\n headArg[n]==NULL\n returning NULL\n");
			return NULL;
			
		}
		
		return NULL;
}




struct Gsymbol *Glookup(char *name) // Look up for a global identifier

{
	
	struct Gsymbol *temp=NULL;
	
	printf("\nin Glookup \nlooking for %s\n",name);
    
    

  if(headg!=NULL)
    { temp=headg;
		printf("\n headg!=NULL\n");
     while (temp!=NULL)
       
         {	printf("found %s\n",temp->name);
            if( strcmp(temp->name,name)==0)
                  {
					
 						return temp;
                         
                   }

            else
                 { temp=temp->next;
					printf("\ntemp->name not equal to name\n");
			     }

          }
       }

    else
	
		{printf("\n headg==NULL\n returning NULL\n");	return NULL;}
		
 
	return NULL;
	
	
}






void Ginstall(char *name, int type,int nodetype,int size, struct ArgStruct *arglist,int fc)   // Installation
{   
		printf(" \nentered Ginstall block\n");
    struct  Gsymbol *temp=(struct Gsymbol *)malloc(sizeof(struct Gsymbol));

     temp->name =  name;
     temp->type=type;
	temp->nodetype=nodetype;
	temp->size=size;
		printf(" \nCurrent base value = %d\n",base);
	temp->binding = base;
		printf(" \ntemp->binding =  %d\n" ,temp->binding);
	base= base + size;
	//temp->size=size;
	temp->arglist=arglist;
	temp->fc=fc;
     temp->next=NULL;

     	if (headg==NULL)
        {
            headg=temp;
            tailg=temp;   
          
         }

     else
        
         {
            tailg->next=temp;
            tailg=tailg->next;
          }
  
	
} 



struct Lsymbol *Llookup(char *name,int n)

{
	
 struct	Lsymbol *temp=NULL;
    
   	printf("\nin Llookup \nlooking for %s , in function no. - %d\n",name,n); 

  if(headl[n]!=NULL)
    { temp=headl[n];
   	printf("\n headl[n]!=NULL\n");
     while (temp!=NULL)
       
         {  	printf("found %s\n",temp->name);
            if( strcmp(temp->name,name)==0)
                  {
                      return temp;
                         
                   }

            else
                 { temp=temp->next;
	              printf("\ntemp->name not equal to name\n");
	             }

          }
       }

    else
	    {   printf("\n headl[n]==NULL\n returning NULL\n");
			return NULL;
			
		}
		
		return NULL;
	
}



void Linstall(char *name, int type,int nodetype, int n)
{
		printf(" \nentered Linstall block\n");
	
   struct	Lsymbol *temp=(struct Lsymbol *)malloc(sizeof(struct Lsymbol));

     temp->name = name;
     temp->type=type;
	temp->nodetype=nodetype;
    	printf(" \nCurrent base value = %d\n",base);
	temp->binding = base;
		printf(" \ntemp->binding =  %d\n" ,temp->binding);
	
	
	
	base= base + 1;
	
	 
	
     temp->next=NULL;

     	if (headl[n]==NULL)
        {
            headl[n]=temp;
            taill[n]=temp;   
          
         }

     else
        
         {
            taill[n]->next=temp;
            taill[n]=taill[n]->next;
          }
	
	
}


void GsymbolTraversal()
{
	struct	Gsymbol *tempg=NULL;
	tempg=headg;
	if(headg==NULL)
	{
		printf("\nGsymbol table is empty\n");
		exit(1);
	}
	printf("\nname				type			nodetype		size			binding			formalParameter\n");
	while(tempg!=NULL)
	{   
		if((tempg->arglist)==NULL)
			printf("%s			%d			%d			%d			%d			NULL\n",tempg->name,tempg->type,tempg->nodetype,tempg->size,tempg->binding);
	    else	
			{
				printf("%s			%d			%d			%d			%d			Given in next line\n",tempg->name,tempg->type,tempg->nodetype,tempg->size,tempg->binding);
				printf("Formal parameter list : \n");
				struct ArgStruct *temparg=tempg->arglist;
				printf("name			type			nodetype			size\n");
				while(temparg!=NULL)
				{
						printf("%s			%d			%d			%d",temparg->name,temparg->type,temparg->nodetype,temparg->size);
						temparg=temparg->next;
				}
			}
			tempg=tempg->next;
	}
	
	
}



void LsymbolTraversal(int n)
{
	struct	Lsymbol *templ=NULL;
	templ=headl[n];
	if(headl[n]==NULL)
	{
		printf("\nLsymbol table[%d] is empty\n",n);
		exit(1);
	}
	printf("\nname				type			nodetype			binding\n");
	while(templ!=NULL)
	{
		printf("%s			%d			%d\n",templ->name,templ->type,templ->nodetype,templ->binding);
		templ=templ->next;
	}
	
	
}



   


   
