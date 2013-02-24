#include<iostream>
using namespace std;



struct symbolTable
{
    char *name;
    int type;
    struct sybolTable *next;
} *headg,*tailg,*headl[50],*taill[50];



    

void install( char *name, int type,char t,int n)
{
   
     symbolTable *temp=new symbolTable;

     strcpy(temp->name, name);
     temp->type=type;
     temp->next=NULL;
     if(t=='G')
       {   
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

      else if (t=='L')
           {
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

struct symbolTable *lookup( char *name,char t,int n)
{
   
     symbolTable *temp=NULL;
    
     if(t=='G')


    { temp=headg;
   
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

      else if(t=='L')


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

      return NULL;
 }




   


   
