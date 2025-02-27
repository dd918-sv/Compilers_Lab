#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lex.yy.c"

typedef struct _node {
   char *name;
   struct _node *next;
   int val;
} node;
typedef node *symboltable;

extern int yylex();
extern int yylineno;
extern char* yytext;
int yywrap(void){return 1;}

symboltable addtbl ( symboltable T, char *id )
{
   node *p;

   p = T;
   while (p) {
      if (!strcmp(p->name,id)) {\
        // printf("Already added!\n");
         p->val++;
         return T;
      }
      p = p -> next;
   }
   p = (node *)malloc(sizeof(node));
   p->val=1;
   p -> name = (char *)malloc((strlen(id)+1) * sizeof(char));
   strcpy(p -> name, id);
   p -> next = T;
//    printf("New string added: %s\n",p->name);
   return p;
}

int main ()
{
   int nextok;
   symboltable T1 = NULL;
   symboltable T2=NULL;
   symboltable T3=NULL;
   symboltable T4=NULL;
    int c1=0,c2=0;
   while ((nextok = yylex())) {
    // printf("%s\n",yytext);
    // printf("%d\n",nextok);
      switch (nextok) {
         case ENV: {
            T1=addtbl(T1,yytext); break;
         }
         case COMMAND:{
            T2=addtbl(T2,yytext);break;
         }
         case INLINE:{
            c1++;
         }
         case DISP: {
            c2++;
         }   
         default: break;
         }    
      
   }

   printf("*****************************Commands used:***************************** \n");
   node*p=T2;
   while(p!=NULL){
    printf("%s-> %d\n",p->name,p->val);
    p=p->next;
   }
   printf("*****************************Environments used: *****************************\n");
   p=T1;
   while(p!=NULL){
    p->name[strlen(p->name)-1]='\0';
    p->name+=7;
    printf("%s-> %d\n",p->name,p->val);
    p=p->next;
   }
   c1/=2;
   c2/=2;
   printf("%d math equations found.\n",c1);
   printf("%d displayed equations found.\n",c2);

   exit(0);
}
