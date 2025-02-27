%{
    #include "y.tab.c"
%}



%%
"set"  {return SET;}
"while" {return WHILE;}
"loop" {return LOOP;}
"when" {return WHEN;}
"="     {return EQ;}
"/="    {return NE;}
"<"     {return LT;}  
"<="    {return LE;}
">"     {return GT;}
">="    {return GE;}
"+"     {return PLUS;}
"-"     {return MINUS;}
"*"     {return MUL;}
"/"     {return DIV;}
"%"     {return MOD;}
"("     {return LP;}
")"     {return RP;}
[_a-zA-Z][_a-zA-Z0-9]* {yylval.sval = strdup(yytext); return IDEN;}
[-]?[0-9]+ {yylval.ival = atoi(yytext); return NUMB;}
[ \t\n] {/*ignore*/}

%%

int yywrap(void) {
    return 1;
}
