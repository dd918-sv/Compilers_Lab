%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef struct Symbol {
    char *id;
    // int value;
    int mem_idx;
    // int set;
    struct Symbol *next;
} Symbol;
typedef Symbol* symboltable;
typedef struct record_{
    int reg;
    int m_id;
    int type;
    int val;
}record;

// typedef struct TreeNode {
//         int numValue;
//         char *idValue;
//         struct {
//             char* operation;
//             struct TreeNode *left;
//             struct TreeNode *right;
//         } opNode;
// } TreeNode;

symboltable S=NULL;
FILE *fptr;
symboltable addSymbol(char*,symboltable);
// symboltable addSymbolNum(int,symboltable);
symboltable findSymbol(symboltable,char*);
void printTAC(record*,record,record,int);
// symboltable findSymbolnum(symboltable,int);
// void setSymbol(symboltable,int);
// int readVal(symboltable);
// int readTreeVal(TreeNode*);
// TreeNode*createInternal(char*,TreeNode*,TreeNode*);
// TreeNode*createLeaf(symboltable);
int mem_idx=0;
int lst_reg=2;
int yylex();
void yyerror(char*);
%}

%union{
    char *id;
    int num;
    record rec;
}

%start PROGRAM
%token <id> ID
%token<num> NUM
%token PLUS MINUS DIVIDE MULTIPLY EXPONENT MODULO SET
%type <rec>EXPR ARG
%type STMT SETSTMT EXPRSTMT
%type <num> OP 

%%
PROGRAM :  STMT PROGRAM {}
        | STMT  {}
        ;
STMT    :  SETSTMT  {}
        | EXPRSTMT  {}
        ;
SETSTMT :   '(' SET ID NUM ')' {S=addSymbol($3,S); int id_posm=(findSymbol(S,$3)->mem_idx); fprintf(fptr,"\tMEM[%d]=%d;\n\tmprn(MEM,%d);\n",id_posm,$4,id_posm); }
        |   '(' SET ID ID ')' {S=addSymbol($3,S);if(findSymbol(S,$4)==NULL){printf("\tWarning: Unitialised variable used-->%s\n",$4);S=addSymbol($4,S);};
                                int id_posm1=(findSymbol(S,$4)->mem_idx); int id_posm2=(findSymbol(S,$3)->mem_idx);
                                fprintf(fptr,"\tR[%d]=MEM[%d];\n\tMEM[%d]=R[%d];\n\tmprn(MEM,%d);\n",0,id_posm1,id_posm2,0,id_posm2);
                            }
        
        |   '(' SET ID EXPR ')' {S=addSymbol($3,S); int id_posm=(findSymbol(S,$3)->mem_idx);
                                fprintf(fptr,"\tMEM[%d]=R[%d];\n\tmprn(MEM,%d);\n",id_posm,$4.reg,id_posm);
                                if($4.reg!=0)lst_reg--;
                                }
        ;
EXPRSTMT : EXPR {
            if($1.reg!=0){
            fprintf(fptr,"\teprn(R,%d);\n",$1.reg);lst_reg--;
            }
            else fprintf(fptr,"\teprn(MEM,%d);\n",$1.m_id);
            } 
        ;
EXPR    : '(' OP ARG ARG ')' {       
                                   $$.type=3;
                                   printTAC(&($$),$3,$4,$2);
                             }
        ;
OP  :   PLUS {$$=PLUS;}
    |   MINUS {$$=MINUS;}
    |   DIVIDE {$$=DIVIDE;}
    |   MULTIPLY {$$=MULTIPLY;}
    |   EXPONENT {$$=EXPONENT;}
    |   MODULO {$$=MODULO;}
    ;

ARG :   ID {$$.type=1; $$.reg=0; $$.m_id=findSymbol(S,$1)->mem_idx; }
    |   NUM {$$.type=2; $$.reg=0; $$.m_id=0; $$.val=$1;}
    |   EXPR {$$=$1;}
    ;
%%

void yyerror(char*s){
    printf("Error: %s\n",s);
}


