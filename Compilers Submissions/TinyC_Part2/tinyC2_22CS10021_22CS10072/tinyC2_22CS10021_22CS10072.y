%{
    #include<stdio.h> 
    #include<stdlib.h>
    #include<string.h>
    void yyerror(char*s);    
    extern int yylex(); 
    extern int yylineno;
    extern char *yytext;
    
    typedef struct node_{
        char*type;
        // char*name;
        struct node_*children;
        struct node_*next;
    }node;

    node*root;
    node*newNode(char*typ){
        node*temp=(node*)malloc(sizeof(node));
        temp->type=(char*)malloc((strlen(typ)+1)*sizeof(char));
        strcpy(temp->type,typ);
        // temp->name=(char*)malloc((strlen(name)+1)*sizeof(char));
        // strcpy(temp->name,name);
        temp->children=NULL;
        return temp;
    }
    node*addChild(node*root,node*child){
        if(root->children==NULL){
            root->children=(node*)malloc(sizeof(node));
            root->children=child;
        }
        else{
            node*curr= (node*)malloc(sizeof(node));
            node*tmp=(node*)malloc(sizeof(node));
            curr=root->children;
            tmp=child;
            tmp->next=curr;
            root->children=tmp;
        }
        return root;
    }
    void print_tree(node*root,int lvl){
        if(root==NULL){
            return;
        }
        for(int i=0;i<lvl;i++){
            printf("-");
        }
        printf(">%s\n",root->type);
        print_tree(root->children, lvl + 1);
        print_tree(root->next, lvl);
    } 

    
%}

%union{
    int intval;
    float floatval;
    char charval;
    char* stringval;
    node* nd;
}

%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT FOR GOTO IF INLINE INT LONG REGISTER RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE BOOL COMPLEX IMAGINARY

%token SQUARE_OPEN SQUARE_CLOSE OPEN_PARENTHESIS CLOSE_PARENTHESIS OPEN_CURLY CLOSE_CURLY
%token DOT ARROW NOT BNOR INC DEC
%token ASSIGN ADD_ASSIGN DIV_ASSIGN MOD_ASSIGN MUL_ASSIGN SUB_ASSIGN LS_ASSIGN RS_ASSIGN BAND_ASSIGN BOR_ASSIGN BXOR_ASSIGN
%token IDENTIFIER
%token QUESTION COLON PTR_OP ELLIPSIS SEMICOLON COMMA
%token OR AND BOR BXOR BAND EQ NE LT GT LE GE LS RS PLUS MINUS MUL DIV MOD
%token<stringval> STRING_LITERAL
%token <intval>INT_CONST
%token <charval> CHAR_CONST
%token <floatval> FLOAT_CONST
%type <nd> primary_expression constant expression assignment_expression conditional_expression unary_expression assignment_operator logical_or_expression postfix_expression unary_operator cast_expression type_name logical_and_expression argument_expression_list initializer_list specifier_qualifier_list inclusive_or_expression initializer designation type_specifier type_qualifier exclusive_or_expression and_expression designator_list designator equality_expression constant_expression relational_expression shift_expression additive_expression multiplicative_expression declaration declaration_specifiers init_declarator_list storage_class_specifier function_specifier init_declarator declarator pointer direct_declarator type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list statement labeled_statement compound_statement expression_statement selection_statement iteration_statement jump_statement block_item_list expression_opt block_item translation_unit external_declaration function_definition declaration_list
%start program


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%
program :translation_unit {
        root=(node*)malloc(sizeof(node));
        root=$1;
        }
primary_expression: IDENTIFIER {/*printf("primary_expression-->IDENTIFIER\n");*/ $$=newNode("primary_expression"); $$=addChild($$,newNode("IDENTIFIER"));}
                 | constant {/*printf("primary_expression-->constant\n");*/node*tmp=newNode("primary_expression"); tmp=addChild(tmp,$1); $$=tmp;}
                 | STRING_LITERAL {/*printf("primary_expression-->STRING_LITERAL\n");*/ $$=newNode("primary_expression"); $$=addChild($$,newNode("STRING_LITERAL"));} 
                 | OPEN_PARENTHESIS expression CLOSE_PARENTHESIS {/*printf("primary_expression-->(expression)\n");*/
                    $$=newNode("primary_expression"); $$=addChild($$,newNode("(")); $$=addChild($$,$2); $$=addChild($$,newNode(")"));
                    } 
                 ;
postfix_expression : primary_expression {/*printf("postfix_expression-->primary_expression\n");*/ $$=newNode("postfix_expression"); $$=addChild($$,$1);}
                    | postfix_expression SQUARE_OPEN expression SQUARE_CLOSE {/*printf("postfix_expression-->postfix_expression [expression]\n");*/$$=newNode("postfix_expression"); $$=addChild($$,$1);$$=addChild($$,newNode("[")); $$=addChild($$,$3); $$=addChild($$,newNode("]"));}
                    | postfix_expression OPEN_PARENTHESIS CLOSE_PARENTHESIS {/*printf("postfix_expression-->postfix_expression()\n");*/ $$=newNode("postfix_expression"); $$=addChild($$,$1);$$=addChild($$,newNode("(")); $$=addChild($$,newNode(")"));}
                    | postfix_expression OPEN_PARENTHESIS argument_expression_list CLOSE_PARENTHESIS {/*printf("postfix_expression-->postfix_expression(argument_expression_list)\n");*/ $$=newNode("postfix_expression"); $$=addChild($$,$1);$$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(")"));}
                    | postfix_expression DOT IDENTIFIER {/*printf("postfix_expression-->postfix_expression.IDENTIFIER\n");*/ $$=newNode("postfix_expression"); $$=addChild($$,$1);$$=addChild($$,newNode(".")); $$=addChild($$,newNode("IDENTIFIER"));}
                    | postfix_expression PTR_OP IDENTIFIER {/*printf("postfix_expression-->postfix_expression->IDENTIFIER\n");*/ $$=newNode("postfix_expression"); $$=addChild($$,$1);$$=addChild($$,newNode("->")); $$=addChild($$,newNode("IDENTIFIER"));}
                    | postfix_expression INC {/*printf("postfix_expression-->postfix_expression++\n");*/ $$=newNode("postfix_expression"); $$=addChild($$,$1);$$=addChild($$,newNode("++"));}
                    | postfix_expression DEC {/*printf("postfix_expression-->postfix_expression--\n");*/ $$=newNode("postfix_expression"); $$=addChild($$,$1);$$=addChild($$,newNode("--"));}
                    | OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS OPEN_CURLY initializer_list CLOSE_CURLY {/*printf("postfix_expression-->(type_name){initializer_list}\n");*/ $$=newNode("postfix_expression"); $$=addChild($$,newNode("("));$$=addChild($$,$2); $$=addChild($$,newNode(")")); $$=addChild($$,newNode("{")); $$=addChild($$,$5); $$=addChild($$,newNode("}"));}
                    | OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS OPEN_CURLY initializer_list COMMA CLOSE_CURLY {/*printf("postfix_expression-->(type_name){initializer_list}\n"); */$$=newNode("postfix_expression"); $$=addChild($$,newNode("("));$$=addChild($$,$2); $$=addChild($$,newNode(")")); $$=addChild($$,newNode("{")); $$=addChild($$,$5); $$=addChild($$,newNode(",")); $$=addChild($$,newNode("}"));}
                    ;
argument_expression_list : assignment_expression {/*printf("argument_expression_list-->assignment_expression\n");*/
                        $$=newNode("argument_expression_list"); $$=addChild($$,$1);
                        }
                        | argument_expression_list COMMA assignment_expression {/*printf("argument_expression_list-->argument_expression_list,assignment_expression\n");*/
                        $$=newNode("argument_expression_list"); $$=addChild($$,$1); $$=addChild($$,newNode(",")); $$=addChild($$,$3);
                        }
                        ;

unary_expression : postfix_expression {/*printf("unary_expression-->postfix_expression\n");*/ $$=newNode("unary_expression"); $$=addChild($$,$1);}
                | INC unary_expression {/*printf("unary_expression-->INC unary_expression\n");*/ $$=newNode("unary_expression"); $$=addChild($$,newNode("++"));$$=addChild($$,$2);}
               | DEC unary_expression {/*printf("unary_expression-->DEC unary_expression\n");*/ $$=newNode("unary_expression"); $$=addChild($$,newNode("--"));$$=addChild($$,$2);}
                | unary_operator cast_expression {/*printf("unary_expression-->unary_operator cast_expression\n");*/ $$=newNode("unary_expression"); $$=addChild($$,$1);$$=addChild($$,$2);}
                | SIZEOF unary_expression {/*printf("unary_expression-->SIZEOF unary_expression\n"); */$$=newNode("unary_expression"); $$=addChild($$,newNode("SIZEOF"));$$=addChild($$,$2);}
                | SIZEOF OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS {/*printf("unary_expression-->SIZEOF (type_name)\n");*/ $$=newNode("unary_expression"); $$=addChild($$,newNode("SIZEOF"));$$=addChild($$,newNode("("));$$=addChild($$,$3);$$=addChild($$,newNode(")"));}
                ;
 
unary_operator: BAND {/*printf("unary_operator-->&\n");*/
                    $$=newNode("&");
                    }
                | MUL {/*printf("unary_operator-->*\n");*/
                    $$=newNode("*");
                    }
                | PLUS {/*printf("unary_operator-->+\n");*/
                    $$=newNode("+");
                    }
                | MINUS {/*printf("unary_operator-->-\n");*/
                    $$=newNode("-");
                    }
                | BNOR {/*printf("unary_operator-->~\n");*/
                    $$=newNode("~");
                    }
                | NOT {/*printf("unary_operator-->!\n");*/
                    $$=newNode("!");
                    }
                ;

cast_expression : unary_expression {/*printf("cast_expression-->unary_expression\n");*/
                        $$=newNode("cast_expression"); $$=addChild($$,$1);
                        }
                | OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS cast_expression {/*printf("cast_expression-->(type_name) cast_expression\n");*/
                        $$=newNode("cast_expression"); $$=addChild($$,newNode("(")); $$=addChild($$,$2); $$=addChild($$,newNode(")")); $$=addChild($$,$4);
                        }
                ;

multiplicative_expression : cast_expression {/*printf("multiplicative_expression-->cast_expression\n");*/ $$=newNode("multiplicative_expression"); $$=addChild($$,$1);}
                        | multiplicative_expression MUL cast_expression {/*printf("multiplicative_expression-->multiplicative_expression * cast_expression\n");*/
                        $$=newNode("multiplicative_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("*")); $$=addChild($$,$3);
                        }
                        | multiplicative_expression DIV cast_expression {/*printf("multiplicative_expression-->multiplicative_expression / cast_expression\n");*/
                        $$=newNode("multiplicative_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("/")); $$=addChild($$,$3);
                        }
                        | multiplicative_expression MOD cast_expression {/*printf("multiplicative_expression-->multiplicative_expression %% cast_expression\n");*/
                        $$=newNode("multiplicative_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("%%")); $$=addChild($$,$3);
                        }
                        ;

additive_expression : multiplicative_expression {/*printf("additive_expression-->multiplicative_expression\n");*/
                    $$=newNode("additive_expression"); $$=addChild($$,$1);
                    }
                    | additive_expression PLUS multiplicative_expression {/*printf("additive_expression-->additive_expression + multiplicative_expression\n");*/
                    $$=newNode("additive_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("+")); $$=addChild($$,$3);
                    }
                    | additive_expression MINUS multiplicative_expression {/*printf("additive_expression-->additive_expression - multiplicative_expression\n");*/
                    $$=newNode("additive_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("-")); $$=addChild($$,$3);
                    }
                    ;

shift_expression : additive_expression {/*printf("shift_expression-->additive_expression\n");*/ $$=newNode("shift_expression"); $$=addChild($$,$1);}
                | shift_expression LS additive_expression {/*printf("shift_expression-->shift_expression << additive_expression\n");*/
                $$=newNode("shift_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("<<")); $$=addChild($$,$3);
                }
                | shift_expression RS additive_expression {/*printf("shift_expression-->shift_expression >> additive_expression\n");*/
                $$=newNode("shift_expression"); $$=addChild($$,$1); $$=addChild($$,newNode(">>")); $$=addChild($$,$3);
                }
                ;


relational_expression : shift_expression {/*printf("relational_expression-->shift_expression\n");*/
                        $$=newNode("relational_expression"); $$=addChild($$,$1);
                        }
                    | relational_expression LT shift_expression {/*printf("relational_expression-->relational_expression < shift_expression\n");*/
                    $$=newNode("relational_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("<")); $$=addChild($$,$3);
                    }
                    | relational_expression GT shift_expression {/*printf("relational_expression-->relational_expression > shift_expression\n");*/
                    $$=newNode("relational_expression"); $$=addChild($$,$1); $$=addChild($$,newNode(">")); $$=addChild($$,$3);
                    }
                    | relational_expression LE shift_expression {/*printf("relational_expression-->relational_expression <= shift_expression\n");*/
                    $$=newNode("relational_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("<=")); $$=addChild($$,$3);
                    }
                    | relational_expression GE shift_expression {/*printf("relational_expression-->relational_expression >= shift_expression\n");*/
                    $$=newNode("relational_expression"); $$=addChild($$,$1); $$=addChild($$,newNode(">=")); $$=addChild($$,$3);
                    }
                    ;

equality_expression : relational_expression {/*printf("equality_expression-->relational_expression\n");*/ $$=newNode("equality_expression"); $$=addChild($$,$1);}
                    | equality_expression EQ relational_expression {/*printf("equality_expression-->equality_expression == relational_expression\n");*/
                    $$=newNode("equality_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("==")); $$=addChild($$,$3);
                    }
                    | equality_expression NE relational_expression {/*printf("equality_expression-->equality_expression != relational_expression\n");*/
                    $$=newNode("equality_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("!=")); $$=addChild($$,$3);
                    }
                    ;
    

and_expression : equality_expression {/*printf("and_expression-->equality_expression\n");*/ $$=newNode("and_expression"); $$=addChild($$,$1);}
                | and_expression BAND equality_expression {/*printf("and_expression-->and_expression & equality_expression\n"); */
                $$=newNode("and_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("&")); $$=addChild($$,$3);
                }
                ;

exclusive_or_expression : and_expression {/*printf("exclusive_or_expression-->and_expression\n");*/ $$=newNode("exclusive_or_expression"); $$=addChild($$,$1);}
                        | exclusive_or_expression BXOR and_expression {/*printf("exclusive_or_expression-->exclusive_or_expression ^ and_expression\n");*/
                        $$=newNode("exclusive_or_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("^")); $$=addChild($$,$3);
                        }
                        ;

inclusive_or_expression: exclusive_or_expression {/*printf("inclusive_or_expression-->exclusive_or_expression\n");*/
                        $$=newNode("inclusive_or_expression"); $$=addChild($$,$1);
                        }
                        | inclusive_or_expression BOR exclusive_or_expression {/*printf("inclusive_or_expression-->inclusive_or_expression | exclusive_or_expression\n");*/
                        $$=newNode("inclusive_or_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("|")); $$=addChild($$,$3);
                        }
                        ;

logical_and_expression : inclusive_or_expression {/*printf("logical_and_expression-->inclusive_or_expression\n");*/
                        $$=newNode("logical_and_expression"); $$=addChild($$,$1);
                        }
                        | logical_and_expression AND inclusive_or_expression {/*printf("logical_and_expression-->logical_and_expression && inclusive_or_expression\n");*/
                        $$=newNode("logical_and_expression"); $$=addChild($$,$1); $$=addChild($$,newNode("&&")); $$=addChild($$,$3);
                        }   
                        ;
logical_or_expression : logical_and_expression {/*printf("logical_or_expression-->logical_and_expression\n");*/ $$=newNode("logical_or_expression"); $$=addChild($$,$1);}
                    | logical_or_expression OR logical_and_expression {/*printf("logical_or_expression-->logical_or_expression || logical_and_expression\n");*/ $$=newNode("logical_or_expression"); $$=addChild($$,$1);$$=addChild($$,newNode("||")); $$=addChild($$,$3);}
                    ;

conditional_expression : logical_or_expression {/*printf("conditional_expression-->logical_or_expression\n"); */
                        $$=newNode("conditional_expression"); $$=addChild($$,$1);}
                    | logical_or_expression QUESTION expression COLON conditional_expression {/*printf("conditional_expression-->logical_or_expression ? expression : conditional_expression\n");*/
                        $$=newNode("conditional_expression"); $$=addChild($$,$1);$$=addChild($$,newNode("?")); $$=addChild($$,$3); $$=addChild($$,newNode(":")); $$=addChild($$,$5); }
                    ;
assignment_expression: conditional_expression {/*printf("assignment_expression-->conditional_expression\n"); */
                    $$=newNode("assignment_expression"); $$=addChild($$,$1);}
                    | unary_expression assignment_operator assignment_expression {/*printf("assignment_expression-->unary_expression assignment_operator assignment_expression\n"); */
                    $$=newNode("assignment_expression"); $$=addChild($$,$1);$$=addChild($$,$2); $$=addChild($$,$3);}
                    ;
assignment_operator : ASSIGN {/*printf("assignment_operator-->=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("="));}
                    | MUL_ASSIGN {/*printf("assignment_operator-->*=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("*="));}
                    | DIV_ASSIGN {/*printf("assignment_operator-->/=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("/="));}
                    | MOD_ASSIGN {/*printf("assignment_operator-->%%= \n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("%%="));}
                    | ADD_ASSIGN {/*printf("assignment_operator-->+=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("+="));}
                    | SUB_ASSIGN {/*printf("assignment_operator-->=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("-="));}
                    | LS_ASSIGN {/*printf("assignment_operator-->=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("<<="));}
                    | RS_ASSIGN {/*printf("assignment_operator-->=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode(">>="));}
                    | BAND_ASSIGN {/*printf("assignment_operator-->=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("&="));}
                    | BXOR_ASSIGN {/*printf("assignment_operator-->=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("^="));}
                    | BOR_ASSIGN {/*printf("assignment_operator-->=\n");*/ $$=newNode("assignment_operator"); $$=addChild($$,newNode("|="));}

expression : assignment_expression {/*printf("expression-->assignment_expression\n");*/  $$=newNode("expression"); $$=addChild($$,$1);}
            | expression COMMA assignment_expression {/*printf("expression-->expression,assignment_expression\n"); */$$=newNode("expression"); $$=addChild($$,$1);$$=addChild($$,newNode(",")); $$=addChild($$,$3);}
            ;
    
constant_expression : conditional_expression {/*printf("constant_expression-->conditional_expression\n");*/ $$=newNode("constant_expression"); $$=addChild($$,$1);}
                    ;

constant : INT_CONST {/*printf("constant-->INT_CONST\n");*/ $$=newNode("constant"); $$=addChild($$,newNode("INT_CONST"));}
        | FLOAT_CONST {/*printf("constant-->FLOAT_CONST\n");*/ $$=newNode("constant"); $$=addChild($$,newNode("FLOAT_CONST"));}
        | CHAR_CONST {/*printf("constant-->CHAR_CONST\n");*/  $$=newNode("constant"); $$=addChild($$,newNode("CHAR_CONST"));}
        ;


declaration : declaration_specifiers SEMICOLON {/*printf("declaration-->declaration_specifiers;\n");*/ $$=newNode("declaration"); $$=addChild($$,$1); $$=addChild($$,newNode(";"));}
            | declaration_specifiers init_declarator_list SEMICOLON {/*printf("declaration-->declaration_specifiers init_declarator_list;\n");*/ $$=newNode("declaration"); $$=addChild($$,$1); $$=addChild($$,$2); $$=addChild($$,newNode(";"));}
            ;

declaration_specifiers : storage_class_specifier {/*printf("declaration_specifiers-->storage_class_specifier\n"); */
                        $$=newNode("declaration_specifiers"); $$=addChild($$,$1);
                        }
                        | storage_class_specifier declaration_specifiers {/*printf("declaration_specifiers-->storage_class_specifier declaration_specifiers\n");*/
                        $$=newNode("declaration_specifiers"); $$=addChild($$,$1); $$=addChild($$,$2);
                        }
                        | type_specifier {/*printf("declaration_specifiers-->type_specifier\n"); */
                        $$=newNode("declaration_specifiers"); $$=addChild($$,$1);
                        }
                        | type_specifier declaration_specifiers {/*printf("declaration_specifiers-->type_specifier declaration_specifiers\n");*/
                        $$=newNode("declaration_specifiers"); $$=addChild($$,$1); $$=addChild($$,$2);
                        }
                        | type_qualifier {/*printf("declaration_specifiers-->type_qualifier\n");*/
                        $$=newNode("declaration_specifiers"); $$=addChild($$,$1);
                        }
                        | type_qualifier declaration_specifiers {/*printf("declaration_specifiers-->type_qualifier declaration_specifiers\n");*/
                        $$=newNode("declaration_specifiers"); $$=addChild($$,$1); $$=addChild($$,$2);
                        }
                        | function_specifier {/*printf("declaration_specifiers-->function_specifier\n");*/
                        $$=newNode("declaration_specifiers"); $$=addChild($$,$1);
                        }
                        | function_specifier declaration_specifiers {/*printf("declaration_specifiers-->function_specifier declaration_specifiers\n");*/
                        $$=newNode("declaration_specifiers"); $$=addChild($$,$1); $$=addChild($$,$2);
                        }
                        ;

init_declarator_list : init_declarator {/*printf("init_declarator_list-->init_declarator\n");*/
                        $$=newNode("init_declarator_list"); $$=addChild($$,$1);
                        }
                    | init_declarator_list COMMA init_declarator {/*printf("init_declarator_list-->init_declarator_list,init_declarator\n");*/
                        $$=newNode("init_declarator_list"); $$=addChild($$,$1); $$=addChild($$,newNode(",")); $$=addChild($$,$3);
                        }
                        ;
                    ;

init_declarator: declarator {/*printf("init_declarator-->declarator\n");*/
                $$=newNode("init_declarator"); $$=addChild($$,$1);
                }
                | declarator ASSIGN initializer {/*printf("init_declarator-->declarator=initializer\n");*/
                $$=newNode("init_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("=")); $$=addChild($$,$3);
                }
                ;

storage_class_specifier : AUTO {/*printf("storage_class_specifier-->AUTO\n");*/
                        $$=newNode("storage_class_specifier"); $$=addChild($$,newNode("AUTO"));
                        }
                        | REGISTER {/*printf("storage_class_specifier-->REGISTER\n");*/
                        $$=newNode("storage_class_specifier"); $$=addChild($$,newNode("REGISTER"));
                        }
                        | STATIC {/*printf("storage_class_specifier-->STATIC\n");*/
                        $$=newNode("storage_class_specifier"); $$=addChild($$,newNode("STATIC"));
                        }
                        | EXTERN {/*printf("storage_class_specifier-->EXTERN\n");*/
                        $$=newNode("storage_class_specifier"); $$=addChild($$,newNode("EXTERN"));
                        }
                        ;

type_specifier : VOID {/*printf("type_specifier-->VOID\n"); */$$=newNode("type_specifier"); $$=addChild($$,newNode("VOID"));}
                | CHAR {/*printf("type_specifier-->CHAR\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("CHAR"));}
                | SHORT {/*printf("type_specifier-->SHORT\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("SHORT"));}
                | INT {/*printf("type_specifier-->INT\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("INT"));}
                | LONG {/*printf("type_specifier-->LONG\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("LONG"));}
                | FLOAT {/*printf("type_specifier-->FLOAT\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("FLOAT"));}
                | DOUBLE {/*printf("type_specifier-->DOUBLE\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("DOUBLE"));}
                | SIGNED {/*printf("type_specifier-->SIGNED\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("SIGNED"));}
                | UNSIGNED {/*printf("type_specifier-->UNSIGNED\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("UNSIGNED"));}
                | BOOL {/*printf("type_specifier-->BOOL\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("BOOL"));}
                | COMPLEX {/*printf("type_specifier-->COMPLEX\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("COMPLEX"));}
                | IMAGINARY {/*printf("type_specifier-->IMAGINARY\n");*/ $$=newNode("type_specifier"); $$=addChild($$,newNode("IMAGINARY"));}
                ;


specifier_qualifier_list : type_specifier {/*printf("specifier_qualifier_list-->type_specifier\n");*/
                        $$=newNode("specifier_qualifier_list"); $$=addChild($$,$1);
                        }
                        | type_specifier specifier_qualifier_list {/*printf("specifier_qualifier_list-->type_specifier specifier_qualifier_list\n");*/
                        $$=newNode("specifier_qualifier_list"); $$=addChild($$,$1); $$=addChild($$,$2);
                        }
                        | type_qualifier {/*printf("specifier_qualifier_list-->type_qualifier\n");*/
                        $$=newNode("specifier_qualifier_list"); $$=addChild($$,$1);
                        }
                        | type_qualifier specifier_qualifier_list {/*printf("specifier_qualifier_list-->type_qualifier specifier_qualifier_list\n");*/
                        $$=newNode("specifier_qualifier_list"); $$=addChild($$,$1); $$=addChild($$,$2);
                        }
                        ;

type_qualifier : CONST {/*printf("type_qualifier-->CONST\n");*/ $$=newNode("type_qualifier"); $$=addChild($$,newNode("CONST"));}
                | VOLATILE {/*printf("type_qualifier-->VOLATILE\n");*/ $$=newNode("type_qualifier"); $$=addChild($$,newNode("VOLATILE"));}
                | RESTRICT {/*printf("type_qualifier-->RESTRICT\n");*/ $$=newNode("type_qualifier"); $$=addChild($$,newNode("RESTRICT"));}
                ;

function_specifier : INLINE {/*printf("function_specifier-->INLINE\n");*/
                    $$=newNode("function_specifier"); $$=addChild($$,newNode("INLINE"));
                    }
                    ;

declarator : pointer direct_declarator {/*printf("declarator-->pointer direct_declarator\n");*/
            $$=newNode("declarator"); $$=addChild($$,$1); $$=addChild($$,$2);
            }
            | direct_declarator {/*printf("declarator-->direct_declarator\n");*/
            $$=newNode("declarator"); $$=addChild($$,$1);
            }
            ;

direct_declarator : IDENTIFIER {/*printf("direct_declarator-->IDENTIFIER\n");*/ $$=newNode("direct_declarator"); $$=addChild($$,newNode("IDENTIFIER"));}
                    | OPEN_PARENTHESIS declarator CLOSE_PARENTHESIS {printf("direct_declarator-->(declarator)\n");
                    $$=newNode("direct_declarator"); $$=addChild($$,newNode("(")); $$=addChild($$,$2); $$=addChild($$,newNode(")"));
                    }
                    | direct_declarator SQUARE_OPEN SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[]\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("[]"));
                    }
                    | direct_declarator SQUARE_OPEN type_qualifier_list SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[type_qualifier_list]\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("[")); $$=addChild($$,$3); $$=addChild($$,newNode("]"));
                    }
                    | direct_declarator SQUARE_OPEN assignment_expression SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[assignment_expression]\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("[")); $$=addChild($$,$3); $$=addChild($$,newNode("]"));
                    }
                    | direct_declarator SQUARE_OPEN type_qualifier_list assignment_expression SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[type_qualifier_list assignment_expression]\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("[")); $$=addChild($$,$3);$$=addChild($$,$4) ;$$=addChild($$,newNode("]"));
                    }
                    | direct_declarator SQUARE_OPEN STATIC assignment_expression SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[STATIC assignment_expression]\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("["));$$=addChild($$,newNode("STATIC")); $$=addChild($$,$4); $$=addChild($$,newNode("]"));
                    }
                    | direct_declarator SQUARE_OPEN STATIC type_qualifier_list assignment_expression SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[STATIC type_qualifier_list assignment_expression]\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("["));$$=addChild($$,newNode("STATIC")); $$=addChild($$,$4);$$=addChild($$,$5); $$=addChild($$,newNode("]"));
                    }
                    | direct_declarator SQUARE_OPEN type_qualifier_list STATIC assignment_expression SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[type_qualifier_list STATIC assignment_expression]\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("[")); $$=addChild($$,$3);$$=addChild($$,newNode("STATIC")); $$=addChild($$,$5); $$=addChild($$,newNode("]"));
                    }
                    | direct_declarator SQUARE_OPEN MUL SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[]*\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("[")); $$=addChild($$,newNode("*")); $$=addChild($$,newNode("]"));
                    }
                    | direct_declarator SQUARE_OPEN type_qualifier_list MUL SQUARE_CLOSE {/*printf("direct_declarator-->direct_declarator[type_qualifier_list]*\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("[")); $$=addChild($$,$3); $$=addChild($$,newNode("*")); $$=addChild($$,newNode("]"));
                    }
                    | direct_declarator OPEN_PARENTHESIS parameter_type_list CLOSE_PARENTHESIS {/*printf("direct_declarator-->direct_declarator(parameter_type_list)\n");*/
                     $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(")"));
                    } 
                    | direct_declarator OPEN_PARENTHESIS identifier_list CLOSE_PARENTHESIS {/*printf("direct_declarator-->direct_declarator(identifier_list)\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(")"));
                    }
                    | direct_declarator OPEN_PARENTHESIS CLOSE_PARENTHESIS {/*printf("direct_declarator-->direct_declarator()\n");*/
                    $$=newNode("direct_declarator"); $$=addChild($$,$1); $$=addChild($$,newNode("(")); $$=addChild($$,newNode(")"));
                    }
                    ;

pointer : MUL {/*printf("pointer-->*\n");*/
        $$=newNode("pointer"); $$=addChild($$,newNode("*"));
        }
        | MUL type_qualifier_list {/*printf("pointer-->* type_qualifier_list\n");*/ $$=newNode("pointer"); $$=addChild($$,newNode("*")); $$=addChild($$,$2);}
        | MUL pointer {/*printf("pointer-->* pointer\n");*/ $$=newNode("pointer"); $$=addChild($$,newNode("*")); $$=addChild($$,$2);}
        | MUL type_qualifier_list pointer {/*printf("pointer-->* type_qualifier_list pointer\n");*/ 
        $$=newNode("pointer"); $$=addChild($$,newNode("*")); $$=addChild($$,$2); $$=addChild($$,$3);
        }
        ;

type_qualifier_list : type_qualifier {/*printf("type_qualifier_list-->type_qualifier\n");*/
                    $$=newNode("type_qualifier_list"); $$=addChild($$,$1);
                    }
                    | type_qualifier_list type_qualifier {/*printf("type_qualifier_list-->type_qualifier_list type_qualifier\n");*/
                    $$=newNode("type_qualifier_list"); $$=addChild($$,$1); $$=addChild($$,$2);
                    }
                    ;

parameter_type_list : parameter_list {/*printf("parameter_type_list-->parameter_list\n");*/
                    $$=newNode("parameter_type_list"); $$=addChild($$,$1);
                    }
                    | parameter_list COMMA ELLIPSIS {/*printf("parameter_type_list-->parameter_list,...\n");*/
                    $$=newNode("parameter_type_list"); $$=addChild($$,$1); $$=addChild($$,newNode(",")); $$=addChild($$,newNode("..."));
                    }
                    ;

parameter_list : parameter_declaration {/*printf("parameter_list-->parameter_declaration\n");*/
                $$=newNode("parameter_list"); $$=addChild($$,$1);
                }
                | parameter_list COMMA parameter_declaration {/*printf("parameter_list-->parameter_list,parameter_declaration\n");*/
                $$=newNode("parameter_list"); $$=addChild($$,$1); $$=addChild($$,newNode(",")); $$=addChild($$,$3);
                }
                ;
parameter_declaration : declaration_specifiers declarator {/*printf("parameter_declaration-->declaration_specifiers declarator\n");*/
                    $$=newNode("parameter_declaration"); $$=addChild($$,$1); $$=addChild($$,$2);
                    }
                    | declaration_specifiers {/*printf("parameter_declaration-->declaration_specifiers\n");*/
                    $$=newNode("parameter_declaration"); $$=addChild($$,$1);
                    }
                    ;

identifier_list : IDENTIFIER {/*printf("identifier_list-->IDENTIFIER\n");*/
                    $$=newNode("identifier_list"); $$=addChild($$,newNode("IDENTIFIER"));
                    }
                | identifier_list COMMA IDENTIFIER {/*printf("identifier_list-->identifier_list,IDENTIFIER\n");*/
                    $$=newNode("identifier_list"); $$=addChild($$,$1); $$=addChild($$,newNode(",")); $$=addChild($$,newNode("IDENTIFIER"));
                    }
                ;

type_name : specifier_qualifier_list {/*printf("type_name-->specifier_qualifier_list\n");*/
            $$=newNode("type_name"); $$=addChild($$,$1);
            }
            ;
initializer: assignment_expression {/*printf("initializer-->assignment_expression\n");*/
            $$=newNode("initializer"); $$=addChild($$,$1);
            }
            | OPEN_CURLY initializer_list CLOSE_CURLY {/*printf("initializer-->{initializer_list}\n");*/
            $$=newNode("initializer");$$=addChild($$,newNode("{")) ;$$=addChild($$,$2); $$=addChild($$,newNode("}"));
            }
            | OPEN_CURLY initializer_list COMMA CLOSE_CURLY {/*printf("initializer-->{initializer_list,}\n");*/
            $$=newNode("initializer");$$=addChild($$,newNode("{")) ;$$=addChild($$,$2); $$=addChild($$,newNode(",")); $$=addChild($$,newNode("}"));
            }
            ;

initializer_list : initializer {/*printf("initializer_list-->initializer\n");*/
                $$=newNode("initializer_list"); $$=addChild($$,$1);
                }
                | designation initializer {/*printf("initializer_list-->designation initializer\n");*/
                $$=newNode("initializer_list"); $$=addChild($$,$1); $$=addChild($$,$2);
                }
                | initializer_list COMMA initializer {/*printf("initializer_list-->initializer_list,initializer\n");*/
                $$=newNode("initializer_list"); $$=addChild($$,$1); $$=addChild($$,newNode(",")); $$=addChild($$,$3);
                }
                | initializer_list COMMA designation initializer {/*printf("initializer_list-->initializer_list,designation initializer\n");*/
                $$=newNode("initializer_list"); $$=addChild($$,$1); $$=addChild($$,newNode(",")); $$=addChild($$,$3); $$=addChild($$,$4);
                }
                ;


designation : designator_list '=' {/*printf("designation-->designator_list=\n");*/
            $$=newNode("designation"); $$=addChild($$,$1); $$=addChild($$,newNode("="));
            }
            ;




designator_list: designator {/*printf("designator_list-->designator\n"); */$$=newNode("designator_list"); $$=addChild($$,$1);}
                | designator_list designator {printf("designator_list-->designator_list designator\n"); 
                $$=newNode("designator_list"); $$=addChild($$,$1); $$=addChild($$,$2);
                }
                ;

designator : SQUARE_OPEN constant_expression SQUARE_CLOSE {/*printf("designator-->[constant_expression]\n");*/ $$=newNode("designator"); $$=addChild($$,newNode("[")); $$=addChild($$,$2); $$=addChild($$,newNode("]"));}
            | DOT IDENTIFIER {/*printf("designator-->IDENTIFIER\n");*/ $$=newNode("designator"); $$=addChild($$,newNode(".")); $$=addChild($$,newNode("IDENTIFIER"));}
            ;



statement : labeled_statement {/*printf("statement-->labeled_statement\n");*/ $$=newNode("statement"); $$=addChild($$,$1);}
            | compound_statement {/*printf("statement-->compound_statement\n"); */$$=newNode("statement"); $$=addChild($$,$1);}
            | expression_statement {/*printf("statement-->expression_statement\n");*/ $$=newNode("statement"); $$=addChild($$,$1);}
            | selection_statement {/*printf("statement-->selection_statement\n");*/ $$=newNode("statement"); $$=addChild($$,$1);}
            | iteration_statement {/*printf("statement-->iteration_statement\n");*/ $$=newNode("statement"); $$=addChild($$,$1);}
            | jump_statement {/*printf("statement-->jump_statement\n"); */$$=newNode("statement"); $$=addChild($$,$1);}
            ;

labeled_statement : IDENTIFIER COLON statement {/*printf("labeled_statement-->IDENTIFIER:statement\n"); */
                $$=newNode("labeled_statement"); $$=addChild($$,newNode("IDENTIFIER")); $$=addChild($$,newNode(":")); $$=addChild($$,$3);
                }
                | CASE constant_expression COLON statement {/*printf("labeled_statement-->CASE constant_expression:statement\n");*/
                 $$=newNode("labeled_statement"); $$=addChild($$,newNode("CASE")); $$=addChild($$,$2); $$=addChild($$,newNode(":")); $$=addChild($$,$4);
                }
                | DEFAULT COLON statement {/*printf("labeled_statement-->DEFAULT:statement\n");*/
                 $$=newNode("labeled_statement"); $$=addChild($$,newNode("DEFAULT")); $$=addChild($$,newNode(":")); $$=addChild($$,$3);
                }
                ;

compound_statement : OPEN_CURLY CLOSE_CURLY {/*printf("compound_statement-->{ }\n");*/
                    $$=newNode("compound_statement"); $$=addChild($$,newNode("{")); $$=addChild($$,newNode("}"));
                    }
                    | OPEN_CURLY block_item_list CLOSE_CURLY {/*printf("compound_statement-->{ block_item_list }\n");*/
                    $$=newNode("compound_statement"); $$=addChild($$,newNode("{")); $$=addChild($$,$2); $$=addChild($$,newNode("}"));
                    }
                    ;
block_item_list : block_item {/*printf("block_item_list-->block_item\n");*/
                $$=newNode("block_item_list"); $$=addChild($$,$1);}
                | block_item_list block_item {/*printf("block_item_list-->block_item_list block_item\n");*/
                $$=newNode("block_item_list"); $$=addChild($$,$1); $$=addChild($$,$2);
                }
                ;


block_item : declaration {/*printf("block_item-->declaration\n");*/
            $$=newNode("block_item"); $$=addChild($$,$1);}
            | statement {/*printf("block_item-->statement\n");*/
            $$=newNode("block_item"); $$=addChild($$,$1);}
            ;

expression_statement : SEMICOLON {/*printf("expression_statement-->;\n");*/
                    $$=newNode("expression_statement"); $$=addChild($$,newNode(";"));
                    }
                    | expression SEMICOLON {/*printf("expression_statement-->expression;\n");*/
                    $$=newNode("expression_statement"); $$=addChild($$,$1); $$=addChild($$,newNode(";"));
                    }
                    ;

selection_statement : IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement %prec LOWER_THAN_ELSE {/*printf("selection_statement-->IF(expression) statement\n");*/
                    $$=newNode("selection_statement"); $$=addChild($$,newNode("IF")); $$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(")")); $$=addChild($$,$5);
}  
                    | IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement ELSE statement {/*printf("selection_statement-->IF(expression) statement ELSE statement\n");*/
                     $$=newNode("selection_statement"); $$=addChild($$,newNode("IF")); $$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(")")); $$=addChild($$,$5); $$=addChild($$,newNode("ELSE")); $$=addChild($$,$7);
                    }
                    | SWITCH OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement {/*printf("selection_statement-->SWITCH(expression) statement\n");*/
                    $$=newNode("selection_statement"); $$=addChild($$,newNode("SWITCH")); $$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(")")); $$=addChild($$,$5);
                    }
                    ;

iteration_statement : WHILE OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement {/*printf("iteration_statement-->WHILE(expression) statement\n");*/
                    $$=newNode("iteration_statement"); $$=addChild($$,newNode("WHILE")); $$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(")")); $$=addChild($$,$5);
                    }
                    | DO statement WHILE OPEN_PARENTHESIS expression CLOSE_PARENTHESIS SEMICOLON {/*printf("iteration_statement-->DO statement WHILE(expression);\n");*/
                    $$=newNode("iteration_statement"); $$=addChild($$,newNode("DO")); $$=addChild($$,$2); $$=addChild($$,newNode("WHILE")); $$=addChild($$,newNode("(")); $$=addChild($$,$5); $$=addChild($$,newNode(")")); $$=addChild($$,newNode(";"));
                    }
                    | FOR OPEN_PARENTHESIS expression_opt SEMICOLON expression_opt SEMICOLON expression_opt CLOSE_PARENTHESIS statement {/*printf("iteration_statement-->FOR(expression_opt;expression_opt;expression_opt) statement\n");*/
                    $$=newNode("iteration_statement"); $$=addChild($$,newNode("FOR")); $$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(";")); $$=addChild($$,$5); $$=addChild($$,newNode(";")); $$=addChild($$,$7); $$=addChild($$,newNode(")")); $$=addChild($$,$9);
                    }
                    | FOR OPEN_PARENTHESIS declaration expression_opt SEMICOLON expression_opt CLOSE_PARENTHESIS statement {/*printf("iteration_statement-->FOR(declaration;expression_opt;expression_opt) statement\n");*/
                    $$=newNode("iteration_statement"); $$=addChild($$,newNode("FOR")); $$=addChild($$,newNode("(")); $$=addChild($$,$3); $$=addChild($$,newNode(";")); $$=addChild($$,$4); $$=addChild($$,newNode(";")); $$=addChild($$,$6); $$=addChild($$,newNode(")")); $$=addChild($$,$8);
                    }
                    ;



jump_statement : GOTO IDENTIFIER SEMICOLON {/*printf("jump_statement-->GOTO IDENTIFIER;\n");*/ 
                $$=newNode("jump_statement"); $$=addChild($$,newNode("GOTO")); $$=addChild($$,newNode("IDENTIFIER")); $$=addChild($$,newNode(";"));
                }
                | CONTINUE SEMICOLON {/*printf("jump_statement-->CONTINUE;\n");*/
                $$=newNode("jump_statement"); $$=addChild($$,newNode("CONTINUE")); $$=addChild($$,newNode(";"));
                }
                | BREAK SEMICOLON {/*printf("jump_statement-->BREAK;\n");*/
                $$=newNode("jump_statement"); $$=addChild($$,newNode("BREAK")); $$=addChild($$,newNode(";"));
                }
                | RETURN expression_opt SEMICOLON {/*printf("jump_statement-->RETURN expression_opt;\n");*/
                $$=newNode("jump_statement"); $$=addChild($$,newNode("RETURN")); $$=addChild($$,$2); $$=addChild($$,newNode(";"));
                }
                ;

expression_opt : {/*printf("expression_opt-->epsilon\n");*/ $$=newNode("expression_opt"); }
                | expression {/*printf("expression_opt-->expression\n");*/ 
                $$=newNode("expression_opt"); $$=addChild($$,$1);
                }
                ;

translation_unit : external_declaration {/*printf("translation_unit-->external_declaration\n");*/
                $$=newNode("translation_unit"); $$=addChild($$,$1);}
                | translation_unit external_declaration {/*printf("translation_unit-->translation_unit external_declaration\n");*/
                $$=newNode("translation_unit"); $$=addChild($$,$1); $$=addChild($$,$2);
                }
                ;

external_declaration : function_definition {/*printf("external_declaration-->function_definition\n");*/
                    $$=newNode("external_declaration"); $$=addChild($$,$1);}
                    | declaration {/*printf("external_declaration-->declaration\n"); */
                    $$=newNode("external_declaration"); $$=addChild($$,$1);
                    }
                    ;
function_definition : declaration_specifiers declarator declaration_list compound_statement {/*printf("function_definition-->declaration_specifiers declarator declaration_list compound_statement\n");*/
                    $$=newNode("function_definition"); $$=addChild($$,$1); $$=addChild($$,$2); $$=addChild($$,$3); $$=addChild($$,$4);
                    }
                    | declaration_specifiers declarator compound_statement {/*printf("function_definition-->declaration_specifiers declarator compound_statement\n");*/
                    $$=newNode("function_definition"); $$=addChild($$,$1); $$=addChild($$,$2); $$=addChild($$,$3);
                    }
                    ;
declaration_list : declaration {/*printf("declaration_list-->declaration\n");*/
                $$=newNode("declaration_list"); $$=addChild($$,$1);}
                | declaration_list declaration {/*printf("declaration_list-->declaration_list declaration\n");*/
                $$=newNode("declaration_list"); $$=addChild($$,$1); $$=addChild($$,$2);
                }
                ;

%%

void yyerror(char *s) {
    printf("Error occurred: %s\n", s);
    printf("Line no.: %d\n", yylineno);
    printf("Unable to parse: %s\n", yytext);
    fflush(stdout);
}