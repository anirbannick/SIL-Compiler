#include<iostream>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
using namespace std;




struct Gsymbol {

char *name; // Name of the Identifier

int type; // TYPE can be INTEGER or BOOLEAN

/***The TYPE field must be a TypeStruct if user defined types are allowed***/

int size; // Size field for arrays

// int BINDING; // Address of the Identifier in Memory

//ArgStruct *ARGLIST; // Argument List for functions

/***Argstruct must store the name and type of each argument ***/

struct Gsymbol *next; // Pointer to next Symbol Table Entry */

} *headg=NULL, *tailg=NULL;



struct Lsymbol {

/* Here only name, type, binding and pointer to next entry needed */
	char *name; // Name of the Identifier

	int type; // TYPE can be INTEGER or BOOLEAN

	/***The TYPE field must be a TypeStruct if user defined types are allowed***/
	
	struct Lsymbol *next; // Pointer to next Symbol Table Entry */

	} *headl[50], *taill[50];




struct Gsymbol *Glookup(char *name) // Look up for a global identifier

{
	
	Gsymbol *temp=NULL;
    
    

  if(headg!=NULL)
    { temp=headg;
   
     while (temp!=NULL)
       
         {	printf("found %s\n",temp->name);
            if( strcmp(temp->name,name)==0)
                  {
					
 						return temp;
                         
                   }

            else
                  temp=temp->next;

          }
       }

    else
		return NULL;
	
	
}



void Ginstall(char *name,int type, int size=1)   // Installation
{
     Gsymbol *temp=new Gsymbol;

     temp->name =  name;
     temp->type=type;
	temp->size=size;
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
	
	Lsymbol *temp=NULL;
    
    

  if(headl[n]!=NULL)
    { temp=headl[n];
   
     while (temp!=NULL)
       
         {
            if( strcmp(temp->name,name)==0)
                  {
                      return temp;
                         
                   }

            else
                  temp=temp->next;

          }
       }

    else
		return NULL;
	
}



void Linstall(char *name, int type, int n)
{
	Lsymbol *temp=new Lsymbol;

     temp->name = name;
     temp->type=type;
	
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


   


   
