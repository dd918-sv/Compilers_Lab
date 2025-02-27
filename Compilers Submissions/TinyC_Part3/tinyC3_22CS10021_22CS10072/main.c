#include "lex.yy.c"
extern int yyparse();

int main() 
{
    yyparse(); 
    print_tree(root,0);
    return 0;
}