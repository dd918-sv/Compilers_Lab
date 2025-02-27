%{
    #include<string.h>
    void yyerror(char*s);    
    extern int yylex(); 
    extern int yylineno;
    extern char *yytext;
   // 0->S ,1->P ,2->T ,3->X ,4->N ,5->M ,6->D ,7->0/1
   typedef struct node_
    {
        int type;
        int val;
        int inh;
        struct node_ *left;
        struct node_ *middle;
        struct node_ *right;
    } node;
   node*root=NULL;
   node*newNode(int);
   node*addChild(node*,node*,int);
   
%}
 
%union{
int intval;
float floatval;
char charval;
char* stringval;
node* nd;
}


%type<nd>S P T X N M 
%token<intval> PLUS EXP MINUS PH D ONE ZERO


%start S
 
%%
S   : P {$$=newNode(0);$$=addChild($$,$1,0);root=$$;}
    | PLUS P {$$=newNode(0); $$=addChild($$,newNode(10),0); $$=addChild($$,$2,1);root=$$;}
    | MINUS P {$$=newNode(0); $$=addChild($$,newNode(11),0); $$=addChild($$,$2,1);root=$$;}
    ;
P   : T {$$=newNode(1); $$=addChild($$,$1,0);}
    | T PLUS P {$$=newNode(1); $$=addChild($$,$1,0); $$=addChild($$,newNode(10),1); $$=addChild($$,$3,2);}
    | T MINUS P {$$=newNode(1); $$=addChild($$,$1,0);$$=addChild($$,newNode(11),1); $$=addChild($$,$3,2);}
    ;
T   : ONE {$$=newNode(2);node*tmp=newNode(7); tmp->val=1; $$=addChild($$,tmp,0); }
    | N {$$=newNode(2); $$=addChild($$,$1,0);}
    | X {$$=newNode(2); $$=addChild($$,$1,0);}
    | N X {$$=newNode(2); $$=addChild($$,$1,0);$$=addChild($$,$2,1);}
    ;
X   : PH {$$=newNode(3);$$=addChild($$,newNode(12),0);}
    | PH EXP N {$$=newNode(3); $$=addChild($$,newNode(12),0);$$=addChild($$,newNode(13),1);$$=addChild($$,$3,2);}
    ;
N   : D {$$=newNode(4); node*tmp=newNode(6);tmp->val=$1;$$=addChild($$,tmp,0);}
    | ONE M {$$=newNode(4); node*tmp=newNode(7); $$=addChild($$,tmp,0);$$=addChild($$,$2,1);}
    | D M {$$=newNode(4);node*tmp=newNode(6);tmp->val=$1;$$=addChild($$,tmp,0); $$=addChild($$,$2,1);}
    ;
M   : ZERO {$$=newNode(5);node*tmp=newNode(7);tmp->val=0;$$=addChild($$,tmp,0); }
    | ONE {$$=newNode(5); node*tmp=newNode(7);tmp->val=1; $$=addChild($$,tmp,0);}
    | D {$$=newNode(5);node*tmp=newNode(6); tmp->val=$1; $$=addChild($$,tmp,0);}
    | ZERO M {$$=newNode(5);node*tmp=newNode(7); tmp->val=0; $$=addChild($$,tmp,0);$$=addChild($$,$2,1);}
    | ONE M {$$=newNode(5);node*tmp=newNode(7);tmp->val=1; $$=addChild($$,tmp,0) ;$$=addChild($$,$2,1);}
    | D M {$$=newNode(5);node*tmp=newNode(6); tmp->val=$1; $$=addChild($$,tmp,0);$$=addChild($$,$2,1);}
    ;
%%


void yyerror(char *s) {
    printf("Error occurred: %s\n", s);
    printf("Line no.: %d\n", yylineno);
}