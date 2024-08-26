%{
#include <stdio.h> 
#define KEYWORD 1
#define ID 2
#define CONST 3 
#define STRING_LITERAL 4
#define PUNCTUATOR 5
#define MULTI_LINE 6
#define SINGLE_LINE 7
#define UNKNOWN -1
%}

spaces         [ \t\r\n]+
digit          [0-9]
nonzero_digit  [1-9]
letter         [a-zA-Z]
identifier_nondigit [_a-zA-z]
identifier     {identifier_nondigit}({identifier_nondigit}|{digit})*
constant    {int_const}|{float_const}|{char_const}
int_const   {digit}+
float_const    {frac_const}{exp}?|{int_const}{exp}
exp         [eE]{sign}?{int_const}
sign        [\+\-]
frac_const  {int_const}?\.{int_const}|{int_const}\.
char_const  \'{c_char_seq}\'
c_char_seq  {c_char}+
c_char      [^\"\n\\]|{escape_seq}
escape_seq  \\[abfnrtv\'\"\?\\]
string_literal \"{s_char_seq}?\"
s_char_seq     {s_char}+
s_char         [^\"\n\\]|{escape_seq}



%%
"auto"|"enum"|"restrict"|"unsigned"|"break"|"extern"|"return"|"void"|"case"|"float"|"short"|"volatile"|"char"|"for"|"signed"|"while"|"const"|"goto"|"sizeof"|"Bool"|"continue"|"if"|"static"|"Complex"|"default"|"inline"|"struct"|"Imaginary"|"do"|"int"|"switch"|"double"|"long"|"typedef"|"else"|"register"|"union"         { return KEYWORD; }  /* Token code for keyword */

{identifier}             {return ID;}  /* Token code for identifier */
{constant}               {return CONST;}
{string_literal}         {return STRING_LITERAL;}
"["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"    { return PUNCTUATOR; }  /* Token code for punctuator */
"/*"([^*]|\*[^/])*"*/"  {return MULTI_LINE;}
"//".*                  {return SINGLE_LINE;}
{spaces}             { /* skip whitespace */ }
.                       {return UNKNOWN;}  /* Token code for unknown character */
%%

int yywrap() {
    return 1;
}
