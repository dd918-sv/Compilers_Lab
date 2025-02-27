%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #define LEFT_PAREN 1 
// #define RIGHT_PAREN 2
// #define PLUS 3
// #define MINUS 4
// #define MULTIPLY 5
// #define DIVIDE 6
// #define MODULO 7
// #define EXPONENT 8
// #define ID 9
// #define NUM 10
// #define SET 11
// #define UNKNOWN -1
#include "y.tab.c"
%}

ID      [a-zA-Z_][a-zA-Z0-9_]*
NUM     [+-]?([0-9]+)

%%
\(       { /*printf("LEFT_PAREN\n");*/ return '(';}
\)       { /*printf("RIGHT_PAREN\n");*/ return ')';}
\+       { /*printf("PLUS\n");*/ yylval.id=yytext; return PLUS;}
\-       { /*printf("MINUS\n");*/ yylval.id=yytext; return MINUS;}
\*       { /*printf("MULTIPLY\n");*/yylval.id=yytext; return MULTIPLY;}
\/       { /*printf("DIVIDE\n");*/yylval.id=yytext; return DIVIDE;}
\%       { /*printf("MODULO\n");*/ yylval.id=yytext; return MODULO;}
"**"     { yylval.id=yytext; return EXPONENT;}
"set"    { return SET;}
{ID}     { /*add_to_id_table(yytext);printf("id\n");*/ yylval.id=(char*)malloc(strlen(yytext)+1); strcpy(yylval.id,yytext); return ID;}
{NUM}    { /*add_to_num_table(atoi(yytext)); printf("num\n");*/yylval.num=atoi(yytext) ;return NUM;}
[ \t\n]+ { /* Ignore whitespace */ }

%%

int yywrap(void){
    return 1;
}