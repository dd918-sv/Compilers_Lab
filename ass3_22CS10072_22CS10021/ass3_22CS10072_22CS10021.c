#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lex.yy.c"

typedef struct _node {
   char *name;
   struct _node *next;
} node;
typedef node *symboltable;

symboltable addtbl ( symboltable T, char *id )
{
   node *p;

   p = T;
   while (p) {
      if (!strcmp(p->name,id)) {
         // printf("Identifier %s already exists\n", id);
         return T;
      }
      p = p -> next;
   }
   // printf("Adding new identifier: %s\n", id);
   p = (node *)malloc(sizeof(node));
   p -> name = (char *)malloc((strlen(id)+1) * sizeof(char));
   strcpy(p -> name, id);
   p -> next = T;
   return p;
}

extern char* yytext;


int main ()
{
   int nextok;
   symboltable keywords = NULL,identifiers=NULL;

   while ((nextok = yylex())) {
      switch (nextok) {
         case ID: {
            printf("< identifier,%s >\n",yytext); 
            identifiers=addtbl(identifiers,yytext);
            break;
         }
         case CONST: {
            printf("< constant,%s >\n",yytext); 
            break;
         }
         case PUNCTUATOR:{
            printf("< puntuator,%s >\n",yytext);
            break;
         }
         case STRING_LITERAL: {
            printf("< String_Literal,%s >\n",yytext); 
            break;
         }
         case KEYWORD:{
            printf("< Keyword,%s >\n",yytext);
            keywords=addtbl(keywords,yytext);
            break;
         }
         case SINGLE_LINE:{
            printf("< single-line comment,%s >\n",yytext);
            break;
         }
         case MULTI_LINE:{
            printf("< multi-line comment,%s >\n",yytext);
            break;
         }
         case UNKNOWN:{
            printf(" Unknown->%s\n",yytext);
            break;
         }
         default: printf(" Unknown token\n"); break;
      }
   }
   symboltable curr=keywords;
   printf("\n**********************************************************\n");
   if(curr!=NULL)
   {
      printf("The Keywords present are:\n");
      while(curr!=NULL){
         printf("%s, ",curr->name);
		 curr=curr->next;
      }
   }
   else{
      printf("No keywords are present!\n");
   }
   printf("\n**********************************************************\n");
   curr=identifiers;
   if(curr!=NULL)
   {
      printf("The Identifiers present are:\n");
      while(curr!=NULL){
         printf("%s, ",curr->name);
		 curr=curr->next;
      }
   }
   else{
      printf("No Identifiers are present!\n");
   }
   printf("\n");

   exit(0);
}