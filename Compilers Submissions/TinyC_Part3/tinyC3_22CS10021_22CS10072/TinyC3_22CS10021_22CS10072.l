%{
    // typedef struct node_{ 
    //     char*type;
    //     char*name;
    //     struct node_*children; 
    //     struct node_*next;
    // }node;
    #include "y.tab.c"
%}

%option yylineno

%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT


IDENTIFIER                      [_a-zA-Z][_a-zA-Z0-9]*

INTEGER_CONSTANT                [1-9][0-9]*|[0]

DIGIT_SEQUENCE                  [0-9]+
EXPONENT_PART                   [eE]([+-]?){DIGIT_SEQUENCE}
FRACTIONAL_CONSTANT             ({DIGIT_SEQUENCE}?\.{DIGIT_SEQUENCE})|({DIGIT_SEQUENCE}\.)
FLOATING_CONSTANT               ({FRACTIONAL_CONSTANT}{EXPONENT_PART}?)|({DIGIT_SEQUENCE}{EXPONENT_PART})

ENUM_CONSTANT                   {IDENTIFIER}

ESCAPE_SEQUENCE                 \\['"?\\abfnrtv]
C_CHAR                          [^\'\\\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE                 {C_CHAR}+
CHAR_CONSTANT                   \'({C_CHAR_SEQUENCE})\'

CONSTANT                        {INTEGER_CONSTANT}|{FLOATING_CONSTANT}|{ENUM_CONSTANT}|{CHAR_CONSTANT}

S_CHAR                          [^\"\\\n]|{ESCAPE_SEQUENCE}
S_CHAR_SEQUENCE                 {S_CHAR}+
STRING_LITERAL                  \"({S_CHAR_SEQUENCE}?)\"
WS                              [ \t\n]

%%

"auto"                          { return AUTO; }
"break"                         { return BREAK; }
"case"                          { return CASE; }
"char"                          { return CHAR; }
"const"                         { return CONST; }
"continue"                      { return CONTINUE; }
"default"                       { return DEFAULT; }
"do"                            { return DO; }
"double"                        { return DOUBLE; }
"else"                          { return ELSE; }
"enum"                          { return ENUM; }             
"extern"                        { return EXTERN; }
"float"                         { return FLOAT; }
"for"                           { return FOR; }
"goto"                          { return GOTO; }
"if"                            { return IF; }
"inline"                        { return INLINE; }
"int"                           { return INT; }
"long"                          { return LONG; }
"register"                      { return REGISTER; }
"restrict"                      { return RESTRICT; }
"return"                        { return RETURN; }
"short"                         { return SHORT; }
"signed"                        { return SIGNED; }
"sizeof"                        { return SIZEOF; }
"static"                        { return STATIC; }
"struct"                        { return STRUCT; }
"switch"                        { return SWITCH; }
"typedef"                       { return TYPEDEF; }
"union"                         { return UNION; }
"unsigned"                      { return UNSIGNED; }
"void"                          { return VOID; }
"volatile"                      { return VOLATILE; }
"while"                         { return WHILE; }
"_Bool"                         { return BOOL; }
"_Complex"                      { return COMPLEX; }
"_Imaginary"                    { return IMAGINARY; }

{IDENTIFIER}                    { yylval.smb=symbol_Registory->lookup(yytext); return IDENTIFIER; }
{INTEGER_CONSTANT}              { yylval.intval=atoi(yytext); return INTEGER_CONSTANT; }
{FLOATING_CONSTANT}             { yylval.charval=yytext; return FLOATING_CONSTANT; }
{CHAR_CONSTANT}                 { yylval.charval=yytext;return CHAR_CONSTANT; }
{STRING_LITERAL}                { yylval.charval=yytext;return STRING_LITERAL; }
{WS}                            { /* ignore whitespaces */ }

"//"                            { BEGIN(SINGLE_LINE_COMMENT); }
<SINGLE_LINE_COMMENT>.          { /* ignore comment */ }
<SINGLE_LINE_COMMENT>\n         { BEGIN(INITIAL); }
<SINGLE_LINE_COMMENT><<EOF>>    { BEGIN(INITIAL); }

"/*"                            { BEGIN(MULTI_LINE_COMMENT); }
<MULTI_LINE_COMMENT>"*/"        { BEGIN(INITIAL); }
<MULTI_LINE_COMMENT>.           { /* ignore comment */ }
<MULTI_LINE_COMMENT>\n          { /* ignore comment */ }

"["                             { return SQUARE_OPEN; }
"]"                             { return SQUARE_CLOSE; }
"("                             { return OPEN_PARENTHESIS; }
")"                             { return CLOSE_PARENTHESIS; }
"{"                             { return OPEN_CURLY; }
"}"                             { return CLOSE_CURLY; }
"."                             { return DOT; }
"->"                            { return ARROW; }
"++"                            { return INC; }
"--"                            { return DEC; }
"&"                             { return BAND; }
"*"                             { return MUL; }
"+"                             { return PLUS; }
"-"                             { return MINUS; }
"~"                             { return BNOR; }
"!"                             { return NOT; }
"/"                             { return DIV; }
"%"                             { return MOD; }
"<<"                            { return LS; }
">>"                            { return RS; }
"<"                             { return LT; }
">"                             { return GT; }
"<="                            { return LE; }
">="                            { return GE; }
"=="                            { return EQ; }
"!="                            { return NE; }
"^"                             { return BXOR; }
"|"                             { return BOR; }
"&&"                            { return AND; }
"||"                            { return OR; }
"?"                             { return QUESTION; }
":"                             { return COLON; }
";"                             { return SEMICOLON; }
"..."                           { return ELLIPSIS; }
"="                             { return ASSIGN; }
"*="                            { return MUL_ASSIGN; }
"/="                            { return DIV_ASSIGN; }
"%="                            { return MOD_ASSIGN; }
"+="                            { return ADD_ASSIGN; }
"-="                            { return SUB_ASSIGN; }
"<<="                           { return LS_ASSIGN; }
">>="                           { return RS_ASSIGN; }
"&="                            { return BAND_ASSIGN; }
"^="                            { return BXOR_ASSIGN; }
"|="                            { return BOR_ASSIGN; }
","                             { return COMMA; }
%%

int yywrap() {
    return 1;
}