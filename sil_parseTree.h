#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>

#define INT 0
#define BOOL 1
#define VOID 2
#define MAIN 100
#define MAIN_BODY_DECL 101
#define MAIN_BODY_ONLY 102
#define STATEMENT 103
#define ASSGNMT_STMT 104
#define COND_STMT 105
#define ITER_STMT 106
#define IN_OUT_STMT 107
#define VAR 108
#define VARLIST 109

#define CONST 110
#define ARRAY 111
#define ARRSIZE 112

#define FUN_CALL 113
#define PARAM_LIST 114


#define ADDEXP 116
#define SUBEXP 117
#define MULEXP 118
#define DIVEXP 119
#define OREXP  120
#define PARANTHESIZEDEXP 121
#define LTEXP  122
#define LEEXP  123
#define GEEXP  124
#define GTEXP  125
#define NOTEXP 126
#define NEEXP  127
#define ANDEXP 128
#define EQEXP 129
#define SWITCH_STMT 130
#define SWITCH_BODY 131
#define INDIVIDUAL_STMT 132

int shift = 0;
//int lineno = 1;
struct Tnode {

	int type; // Integer, Boolean or Void (for statements)
	/* Must point to the type expression tree for user defined types */
	int nodetype;
	/* this field should carry following information:
	* a) operator : (+,*,/ etc.) for expressions
	* b) statement Type : (WHILE, READ etc.) for statements */
	char name[100]; // For Identifiers/Functions
	int value; // for constants
	struct Tnode *left, *middle, *right;
	
};


struct Tnode *nodeCreate(int type, int nodetype, char *name , int value, struct Tnode *left, struct Tnode *middle, struct  Tnode *right) {

	struct Tnode *node = (struct Tnode *)malloc(sizeof(struct Tnode));
	node->type = type;
	node->nodetype = nodetype;
	strcpy(node->name, name);
	node->value = value;
	node->left = left;
	node->middle = middle;
	node->right = right;
	return node;
}

void treeTraversal(struct Tnode *root, int tabs)
{
	int i;
	

	if(root != NULL)
	{   printf("         ");   
        if(shift){tabs = tabs - 4; shift = 0;}
        if (root->left != NULL && (root->left)->nodetype == MAIN) {shift = 1;}

		for(i = 0; i<tabs ; i++) printf(" ");
	    printf("(");	
	    if (root->nodetype == VAR)
			printf("Variable(%s)",root->name);
		else if (root->nodetype == ARRAY)
			printf("Array(%s)",root->name); 
		else if (root->nodetype == MAIN)
			printf("Mian_Func(%s)",root->name);		
		else 
			printf("%s", root->name);
		if(root->left != NULL)
		{   printf("\n");
		    treeTraversal(root->left,tabs+4);
		    printf("");
 
		}
		if(root->middle != NULL)
		{   printf("\n");
		    treeTraversal(root->middle,tabs+4);
		    printf("");

		}
		if(root->right != NULL)
		{   printf("\n");
		    treeTraversal(root->right,tabs+4);
		    printf("");

		}
 
printf(")");
        tabs= tabs-4; 
    }
    
}

void treeCreate(struct Tnode *root)
{
    
	if(root != NULL)
	{	printf("\n");
    		treeTraversal(root,0);
		printf("\n");
        }
    	else printf("NULL\n");
}
