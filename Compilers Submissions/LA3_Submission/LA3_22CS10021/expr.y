%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef struct Symbol {
    char *id;
    int value;
    int set;
    struct Symbol *next;
} Symbol;
typedef Symbol* symboltable;

typedef struct TreeNode {
        int numValue;
        char *idValue;
        struct {
            char* operation;
            struct TreeNode *left;
            struct TreeNode *right;
        } opNode;
} TreeNode;

symboltable S=NULL;
symboltable addSymbol(char*,symboltable);
symboltable addSymbolNum(int,symboltable);
symboltable findSymbol(symboltable,char*);
symboltable findSymbolnum(symboltable,int);
void setSymbol(symboltable,int);
int readVal(symboltable);
int readTreeVal(TreeNode*);
TreeNode*createInternal(char*,TreeNode*,TreeNode*);
TreeNode*createLeaf(symboltable);
int yylex();
void yyerror(char*);
%}

%union{
    char *id;
    TreeNode*tnd;
    symboltable node;
}

%start PROGRAM
%token <node> NUM ID
%token PLUS MINUS DIVIDE MULTIPLY EXPONENT MODULO SET
%type <tnd>EXPR ARG
%type STMT SETSTMT EXPRSTMT 
%type <id> OP 

%%
PROGRAM :  STMT PROGRAM {}
        | STMT  {}
        ;
STMT    :  SETSTMT  {}
        | EXPRSTMT  {}
        ;
SETSTMT :   '(' SET ID NUM ')' { setSymbol($3,readVal($4));}
        |   '(' SET ID ID ')' { setSymbol($3,readVal($4));}
        |   '(' SET ID EXPR ')' { setSymbol($3,readTreeVal($4));}
EXPRSTMT : EXPR {  printf("Standalone expression evaluates to %d \n", readTreeVal($1));} 
        ;
EXPR    : '(' OP ARG ARG ')' { $$=createInternal($2,$3,$4);}
        ;
OP  :   PLUS {$$=strdup("+");}
    |   MINUS {$$=strdup("-");}
    |   DIVIDE {$$=strdup("/");}
    |   MULTIPLY {$$=strdup("*");}
    |   EXPONENT {$$=strdup("**");}
    |   MODULO {$$=strdup("mod");}
    ;

ARG :   ID {$$= createLeaf($1); }
    |   NUM {$$= createLeaf($1);}
    |   EXPR {$$=$1;}
    ;
%%

void yyerror(char*s){
    printf("Error: %s\n",s);
}


