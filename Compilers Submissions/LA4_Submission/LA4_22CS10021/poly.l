%{
#include "y.tab.c"

int yylex();
%}

%%

"+"           { return PLUS; }
"-"           { return MINUS; }
"^"           { return EXP; }
"x"           { return PH; }

[2-9]        {yylval.intval = atoi(yytext);return D;}
[0]         {return ZERO;}
[1]         {return ONE;}            
[ \t\n]           { /* Ignore whitespace */ }

%%


int yywrap() {
    return 1;
}