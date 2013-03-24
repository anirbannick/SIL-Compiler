#include <stdio.h>
#include <string.h>
#include <stdlib.h>
//using namespace std;

#define INT 0
#define BOOL 1
#define VOID 2

#define PROG 100
#define GLOBAL 101
#define GLOBAL_LIST 102
#define VARLIST 103
#define VAR 104
#define ARRSIZE 105
#define ARRAY 106
#define FUNC 107
#define ARGS 108
#define F_PARAM_LIST 109

#define F_PARAM 110
#define REFERENCE 111
#define FUNCDEF 112

#define FUNCS 113
#define MAIN 114
#define BODY 115

#define FDCL 116
#define FDCLS 117
#define STMT 118
#define DIVEXP 119
#define OREXP  120
#define PARTHSEXP 121
#define LTEXP  122
#define LEEXP  123
#define GEEXP  124
#define GTEXP  125
#define NOTEXP 126
#define NEEXP  127
#define ANDEXP 128
#define EQEXP 129
#define ADDEXP 130
#define SUBEXP 131
#define MULEXP 132
#define CONST 133
#define BOOLCONST 134
#define FNCALLS 135
#define FNCALL 136
#define FCLISTS 137
#define FCLIST 138
#define ARGLIST 139




int shift = 0;
//int lineno = 1;
struct Tnode {

	int type; // Integer, Boolean or Void (for statements)
	/* Must point to the type expression tree for user defined types */
	int nodetype;
	/* this field should carry following information:
	* a) operator : (+,*,/ etc.) for expressions
	* b) statement Type : (WHILE, READ etc.) for statements */
	char *name; // For Identifiers/Functions
	int value; // for constants
	struct Tnode *left, *middle, *right;
	
};


struct Tnode *nodeCreate(int type, int nodetype, char *name , int value, struct Tnode *left, struct Tnode *middle, struct  Tnode *right) {

	struct Tnode *node = (struct Tnode *)malloc(sizeof(struct Tnode));
	node->type = type;
	node->nodetype = nodetype;
	node->name= name;
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
		    printf(" ");
 
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
