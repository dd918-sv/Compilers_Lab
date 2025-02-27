%{
#include <stdio.h>
#include <stdlib.h>
#define ENV 1
#define COMMAND 2
#define INLINE 4
#define DISP 5
%}

%%
%.*\n {
    // Ignore unmatched patterns
}
\$\$ {
    // printf("Displayed Math Formula\n");
    return DISP;
}
\$ {
    // printf("Inline Math Formula\n");
    return INLINE;
}
\\\[ {return DISP;}
~ {return COMMAND;}
\\begin[{a-zA-Z}]+ {
    // printf("Environment: %s\n", yytext + 7);
    return ENV;
}
\\end[{a-zA-Z}]+ {}
\\[a-zA-Z]+ {
    // printf("Alphabetic Command: %s\n", yytext + 1);
    return COMMAND;
}

\\[^a-zA-Z~] {return COMMAND;}
. {}
\n {}
[\t\r]+ {}
%%