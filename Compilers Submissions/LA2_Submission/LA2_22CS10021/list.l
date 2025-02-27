%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define LEFT_PAREN 1 
#define RIGHT_PAREN 2
#define PLUS 3
#define MINUS 4
#define MULTIPLY 5
#define DIVIDE 6
#define MODULO 7
#define ID 8
#define NUM 9
#define UNKNOWN -1
%}

ID      [a-zA-Z_][a-zA-Z0-9_]*
NUM     [+-]?([0-9]+)

%%
\(       { /*printf("LEFT_PAREN\n");*/ return LEFT_PAREN;}
\)       { /*printf("RIGHT_PAREN\n");*/ return RIGHT_PAREN;}
\+       { /*printf("PLUS\n");*/ return PLUS;}
\-       { /*printf("MINUS\n");*/ return MINUS;}
\*       { /*printf("MULTIPLY\n");*/ return MULTIPLY;}
\/       { /*printf("DIVIDE\n");*/ return DIVIDE;}
\%        { /*printf("MODULO\n");*/ return MODULO;}
{ID}     { /*add_to_id_table(yytext);printf("id\n");*/ return ID; }
{NUM}    { /*add_to_num_table(atoi(yytext)); printf("num\n");*/ return NUM;}
[ \t\n]+ { /* Ignore whitespace */ }
.        { return UNKNOWN;}

%%