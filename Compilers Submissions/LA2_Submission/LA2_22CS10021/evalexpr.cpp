#include <iostream>
#include <stdio.h>
#include "lex.yy.c"
#include <stack>
#include<string>
#define END 0
#define EXPR 10
#define OP 11
#define ARG 12
// #include <stdlib.h>
// #include <string.h>

using namespace std;

typedef struct _pair{
    int first;
    string second;
}pr;

typedef struct _node
{
    char *name;
    struct _node *next;
    int val;
} node;
typedef node *symboltable;

symboltable addtbl(symboltable T, char *id)
{
    node *p;

    p = T;
    while (p)
    {
        if (!strcmp(p->name, id))
        {
            // printf("Identifier %s already exists\n", id);
            return T;
        }
        p = p->next;
    }
    // printf("Adding new identifier: %s\n", id);
    p = (node *)malloc(sizeof(node));
    p->name = (char *)malloc((strlen(id) + 1) * sizeof(char));
    strcpy(p->name, id);
    p->val=0;
    p->next = T;
    return p;
}

typedef struct _treenode{
    string name;
    _treenode*left;
    _treenode*right;
    node* id_val;
}treenode;

void print_tree(treenode*root,string tt){
    if(root==NULL) return;
    // cout<<root->name<<endl;
    if(root->name!="NUM" && root->name!="ID") cout<<tt<<"--->OP("<<root->name<<")"<<endl;
    else cout<<tt<<"--->"<<root->name<<"("<<root->id_val->val<<")"<<endl;
    string tt1=tt+"    ";
    print_tree(root->left,tt1);
    print_tree(root->right,tt1);
    return;
}


extern int yylex();
extern int yylineno;
extern char *yytext;
int yywrap(void) { return 1; }

int i=0;
pr ar[100005]={0};
int ct=0;

symboltable C = NULL;
symboltable T = NULL;
symboltable input_arg=NULL;
treenode* dfs(treenode*nd){
    if(i>=ct) return NULL;
    while(ar[i].first==LEFT_PAREN || ar[i].first==RIGHT_PAREN) i++;

    if(ar[i].first==ID){
        nd->name="ID";
        string tmp=ar[i].second;
        node*curr=T;
        while(tmp!=curr->name){
            curr=curr->next;
        }
        nd->id_val=curr;
        nd->left=NULL;
        nd->right=NULL;
        i++;
        return nd;
    }
    else if(ar[i].first==NUM){
        nd->name="NUM";
        nd->id_val=new node;
        nd->id_val->val=stoi(ar[i].second);
        i++;

        return nd;
    }
    else{
        if(ar[i].first==PLUS) nd->name="+";
        else if(ar[i].first==MINUS) nd->name="-";
        else if(ar[i].first==MULTIPLY) nd->name="*";
        else if(ar[i].first==DIVIDE) nd->name="/";
        else if(ar[i].first==MODULO) nd->name="%";
        i++;
        nd->left=new treenode;
        nd->right=new treenode;
        nd->left=dfs(nd->left);
        nd->right=dfs(nd->right);
        return nd;
    }

}


int evaluate(treenode*nd){
    if(nd->name=="ID"){
        // cout<<nd->name<<" "<<nd->id_val->val<<endl;
        return nd->id_val->val;
    }
    else if(nd->name=="NUM"){
        // cout<<"NUM "<<nd->id_val->val<<endl;
        return nd->id_val->val;
    }
    else if(nd->name=="+"){
        int ans=evaluate(nd->left);
        ans+=evaluate(nd->right);
        return ans;
    }
    else if(nd->name=="-"){
        int ans=evaluate(nd->left);
        ans-=evaluate(nd->right);
        return ans;
    }
    else if(nd->name=="*"){
        int ans=evaluate(nd->left);
        ans*=evaluate(nd->right);
        return ans;
    }
    else if(nd->name=="/"){
        int ans=evaluate(nd->left);
        ans/=evaluate(nd->right);
        return ans;
    }
    else if(nd->name=="%"){
        int ans=evaluate(nd->left);
        ans%=evaluate(nd->right);
        return ans;
    }
    return 1;
}


int main()
{
    int nextok;
    stack<int> tokens;
    int par=0;
    bool flag=0;
    while ((nextok = yylex()))
    {
        if(!flag){
            switch (nextok)
            {
                case UNKNOWN:{
                    cout<<"***Error: Unknown operator "<<yytext<<" found"<<endl;
                    exit(0);
                }
                case LEFT_PAREN:
                {
                    ar[ct].first=LEFT_PAREN;
                    ar[ct++].second="(";
                    // tokens.push(LEFT_PAREN);
                    par++;
                    break;
                }
                case RIGHT_PAREN:
                {
                    ar[ct].first=RIGHT_PAREN;
                    ar[ct++].second=")";
                    par--;
                    if(par==0) flag=1;
                    // tokens.push(RIGHT_PAREN);
                    break;
                }
                case PLUS:
                {
                    ar[ct].first=PLUS;
                    ar[ct++].second="+";
                    tokens.push(PLUS);
                    break;
                }
                case MINUS:
                {
                    ar[ct].first=MINUS;
                    ar[ct++].second="-";
                    tokens.push(MINUS);
                    break;
                }
                case MULTIPLY:
                {
                    ar[ct].first=MULTIPLY;
                    ar[ct++].second="*";
                    tokens.push(MULTIPLY);
                    break;
                }
                case DIVIDE:
                {
                    ar[ct].first=DIVIDE;
                    ar[ct++].second="/";
                    tokens.push(DIVIDE);
                    break;
                }
                case MODULO:
                {
                    ar[ct].first=MODULO;
                    ar[ct++].second="%";
                    tokens.push(MODULO);
                    break;
                }
                case ID:
                {
                    T=addtbl(T, yytext);
                    ar[ct].first=ID;
                    ar[ct++].second=yytext;
                    tokens.push(ID);
                    break;
                }
                case NUM:
                {   
                    C=addtbl(C, yytext);
                    ar[ct].first=NUM;
                    ar[ct++].second=yytext;
                    tokens.push(NUM);
                    break;
                }
                default:
                    break;
            }
        }
        else{
            if(nextok==NUM){
                C=addtbl(C,yytext);
                input_arg=addtbl(input_arg,yytext);
            }
        }
    }

    int parse_tbl[13][13]={0};
    parse_tbl[OP][PLUS]=2;
    parse_tbl[OP][MINUS]=3;
    parse_tbl[OP][MULTIPLY]=4;
    parse_tbl[OP][DIVIDE]=5;
    parse_tbl[OP][MODULO]=6;
    parse_tbl[ARG][ID]=7;
    parse_tbl[ARG][NUM]=8;
    parse_tbl[ARG][LEFT_PAREN]=9;
    parse_tbl[EXPR][LEFT_PAREN]=1;

    stack<int>s;
    s.push(END);
    s.push(EXPR);
    int err=0;
    int ip=0;
    while(!s.empty() && !err){
        // cout<<s.top()<<" "<<ar[ip]<<endl;
        if(s.top()!=EXPR && s.top()!=ARG && s.top()!=OP){
            if(s.top()==ar[ip].first) {
                // cout<<"popped= "<<s.top()<<endl;
                s.pop();
                ip++;
                continue;
            }
            else{
                err=1;
                if(s.top()==RIGHT_PAREN) cout<<"***Error: RP expected in place of "<<ar[ip].second<<endl;
                else cout<<"***Error: ID/NUM/LP expected in place of "<<ar[ip].second<<endl;
                exit(0);
                s.pop();
                continue;
            }
        }
        else{
            int grm=parse_tbl[s.top()][ar[ip].first];
            // cout<<"grm rule used= "<<grm<<endl;
            if(grm==0) {
                err=1;
                if(s.top()==EXPR){
                    cout<<"***Error: Expected ( in place of "<<ar[ip].second<<endl;
                    exit(1);
                }
                if(s.top()==OP){
                    cout<<"***Error: Expected operator in place of "<<ar[ip].second<<endl;
                    exit(1);
                }
                else if(s.top()==ARG){
                    cout<<"***Error: Expected ID/NUM or '(' in place of "<<ar[ip].second<<endl;
                    exit(1);
                }
                else{
                    cout<<"***Error Syntax:"<<endl;
                }
                break;
            }
            else if(grm==1){
                s.pop();
                // if(grm==1) 
                // {
                //     cout<<"hi "<<s.top()<<endl;
                // }
                s.push(RIGHT_PAREN);
                s.push(ARG);
                s.push(ARG);
                s.push(OP);
                s.push(LEFT_PAREN);
            }
            else if(grm==2){
                s.pop();
                s.push(PLUS);
            }
            else if(grm==3){
                s.pop();
                s.push(MINUS);
            }
            else if(grm==4){
                s.pop();
                s.push(MULTIPLY);
            }
            else if(grm==5){
                s.pop();
                s.push(DIVIDE);
            }
            else if(grm==6){
                s.pop();
                s.push(MODULO);
            }
            else if(grm==7){
                s.pop();
                s.push(ID);
            }
            else if(grm==8){
                s.pop();
                s.push(NUM);
            }
            else if(grm==9){
                s.pop();
                s.push(EXPR);
            }
        }
    }
    cout<<"Parsing is Successful"<<endl;

    node*curr1=T,*curr2=input_arg;
    while(curr1!=NULL && curr2!=NULL){
        curr1->val=stoi(curr2->name);
        cout<<curr1->name<<" = "<<curr1->val<<endl;
        curr1=curr1->next;
        curr2=curr2->next;
    }
    if(curr1!=NULL || curr2!=NULL){
        cout<<"***Error: Number of variables and the number of arguments are not equal!"<<endl;
        exit(0);
    }

    treenode*root=new treenode;
    root=dfs(root);
    treenode*curr=root;
    string tt="";
    print_tree(curr,tt);

    curr1=T;curr2=input_arg;
    if(curr1!=NULL){
        cout<<"Reading variable values from the input"<<endl;
        while(curr1!=NULL && curr2!=NULL){
            cout<<curr1->name<<" = "<<curr1->val<<endl;
            curr1=curr1->next;
            curr2=curr2->next;
        }
    }
    int ans=evaluate(root);
    cout<<"The value of the evaluated expression is "<<ans<<endl;

    return 0;

}