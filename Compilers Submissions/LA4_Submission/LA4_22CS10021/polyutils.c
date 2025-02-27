#include "lex.yy.c"
#include<stdlib.h>
extern int yyparse();

// typedef struct node_
// {
//     int type;
//     int val;
//     int inh;
//     struct node_ *left;
//     struct node_ *middle;
//     struct node_ *right;
// } node;

int flag=0;
node *newNode(int typ)
{
    node *temp = (node *)malloc(sizeof(node));
    temp->type = typ;
    temp->val = 0;
    temp->inh = 0;
    temp->left = NULL;
    temp->middle = NULL;
    temp->right = NULL;
    return temp;
}
node *addChild(node *root, node *child, int num)
{
    switch (num)
    {
    case 0:
    {
        root->left = (node *)malloc(sizeof(node));
        root->left = child;
        break;
    }
    case 1:
    {
        root->middle = (node *)malloc(sizeof(node));
        root->middle = child;
        break;
    }
    case 2:
    {
        root->right = (node *)malloc(sizeof(node));
        root->right = child;
        break;
    }
    default:
        break;
    }

    return root;
}

int bin_exponent(int a,int b){
    int res=1;
    int x=a;
    while(b>0){
        if(b%2==1){
            res=res*x;
        }
        x=x*x;
        b=b/2;
    }
    return res;
}

void print_tree(node *root, int lvl)
{
    if (root == NULL)
    {
        return;
    }
    for (int i = 0; i < lvl; i++)
    {
        printf(" ");
    }

    for(int i=0;i<lvl;i++) printf("  ");
    switch(root->type){
        case 0:{
            printf("==>S []\n");
            break;
        }
        case 1:{
            printf("==>P [inh = %c]\n",(root->inh==268)?'+':'-');
            break;
        }
        case 2:{
            printf("==>T [inh=%c]\n",(root->inh==268)?'+':'-');
            break;
        }
        case 3:{
            printf("==>X []\n");
            break;
        }
        case 4:{
            printf("==>N [val=%d]\n",root->val);
            break;
        }
        case 5:{
            printf("==>M [inh = %d, val= %d]\n",root->inh,root->val);
            break;
        }
        case 6:{
            printf("==>%d [val=%d]\n",root->val,root->val);
            break;
        }
        case 7:{
            printf("==>%d [val=%d]\n",root->val,root->val);
            break;
        }
        case 10:{
            printf("==>+ []\n");
            break;
        }
        case 11:{
            printf("==> - []\n");
            break;
        }
        case 12:{
            printf("==>x []\n");
            break;
        }
        case 13:{
            printf("==>^ []\n");
            break;
        }
        default:{
            break;
        }
    }
    print_tree(root->left, lvl + 1);
    print_tree(root->middle, lvl + 1);
    print_tree(root->right, lvl + 1);
}

void setatt(node*root){

    if(root==NULL){
        return;
    }
    switch(root->type){
        case 0:
        {
            if(root->left->type==1 || root->left->type==10){
                // printf("hi\n");
                node*lchild=root->left;
                node*mchild=root->middle;
                if(mchild==NULL){
                    lchild->inh=268;
                    setatt(lchild);
                }
                else{
                    mchild->inh=268;
                    setatt(mchild);
                }
                // root->val=lchild->val;
            }
            else if(root->left->type==11){
                node*mchild=root->middle;
                mchild->inh=-268;
                setatt(mchild);
                // root->val=-(mchild->val);
            }
            break;
        }
                 
        case 1:
        {
            if(root->left->type==2 && root->middle==NULL){
                node*lchild=root->left;
                lchild->inh=root->inh;
                setatt(lchild);
                // root->val=lchild->val;
            }
            else if(root->middle->type==10){
                node*lchild=root->left;
                lchild->inh=root->inh;
                setatt(lchild);
                node*rchild=root->right;
                rchild->inh=268;
                setatt(rchild);
                // root->val=lchild->val+rchild->val;
            }
            else if(root->middle->type==11){
                node*lchild=root->left;
                lchild->inh=root->inh;
                setatt(lchild);
                node*rchild=root->right;
                rchild->inh=-268;
                setatt(rchild);
                // root->val=lchild->val-rchild->val;
            }
            break;
        }

        case 2:{
            if(root->left->type==7){
                root->val=1;
            }
            else if(root->left->type==3){
                setatt(root->left);
            }
            else if(root->left->type==4 && root->middle==NULL){
                // printf("hi\n");
                setatt(root->left);
            }
            else if(root->left->type==4){
                setatt(root->left);
                setatt(root->middle);
            }
            break;
        }
        case 3: {
            flag=1;
            if(root->middle!=NULL){
                setatt(root->right);
            }
            break;
        }
        case 4:{
            if(root->middle==NULL){
                root->val=root->left->val;
            }
            else if(root->left->type==7){
                node*mchild=root->middle;
                mchild->inh=1;
                setatt(mchild);
                root->val=mchild->val;
            }
            else if(root->left->type==6){
                node*mchild=root->middle;
                mchild->inh=root->left->val;
                setatt(mchild);
                root->val=mchild->val;
                // printf("root->val==%d\n",root->val);
            }
            break;
        }
          
        case 5:{
            if((root->left->type==7 || root->left->type==6) && root->middle==NULL){
                node*lchild=root->left;
                root->val=(root->inh)*10+(lchild->val);
            }
            else if((root->left->type==7 || root->left->type==6) && root->middle!=NULL){
                node*lchild=root->left;
                node*mchild=root->middle;
                mchild->inh=10*(root->inh)+(lchild->val);
                setatt(mchild);
                root->val=mchild->val;
            }
            break;

        }
    }

}

int evalpoly(node*root,int ph){
    if(root==NULL) return 0;
    switch(root->type){
        case 0:{
            // printf("S\n");
            if(root->middle==NULL) return evalpoly(root->left,ph);
            else if(root->left->type==10){
                // printf("+P\n");
                return evalpoly(root->middle,ph);
            }
            else if(root->left->type==11){
                // printf("-P\n");
                return evalpoly(root->middle,ph);
            }
            break;
        }
        case 1 :{
            // printf("P\n");
            if(root->middle==NULL){
                return evalpoly(root->left,ph);
            }
            else{
                return evalpoly(root->left,ph)+evalpoly(root->right,ph);
            }
            break;
        }
        case 2 : {
            // printf("T\n");
            if(root->left->type==7){
                return ((root->inh)/268)*1;
            }
            else if(root->left->type==4 && root->middle==NULL){
                return ((root->inh)/268)*(root->left->val);
            }
            else if(root->left->type==4){
                // printf("N=%d\n",root->left->val);
                // printf("M=%d\n",evalpoly(root->middle,ph));
                return ((root->inh)/268)*(root->left->val)*evalpoly(root->middle,ph);
            }
            else if(root->left->type==3){
                return ((root->inh)/268)*evalpoly(root->left,ph);
            }
            break;
        }
             
        case 3: {
            // printf("X\n");
            if(root->left->type==12 && root->middle==NULL){
                return ph;
            }
            else if(root->left->type==12){
                return bin_exponent(ph,root->right->val);
            }
            break;
        }
    }
}

void print_derivative(node*root){
    if(root==NULL || root->type==10 || root->type==11) return;
    // printf("hi\n");
    switch(root->type){
         
        case 0:{
            print_derivative(root->left);
            print_derivative(root->middle);
            break;
        }
        case 1:{
            print_derivative(root->left);
            if(root->middle!=NULL){
                print_derivative(root->right);
            }
        }
        case 2: {
            if(root->left->type==7){
                return;
            }
            else if(root->left->type==4 && root->middle==NULL){
                return;
            }
            else if(root->left->type==4){
                int coeff=root->left->val;
                node*mchild=root->middle;
                if(mchild->middle==NULL){
                    printf("%c%d",(root->inh==268)?'+':'-',coeff);
                }
                else{
                    coeff=(coeff*mchild->right->val);
                    if(mchild->right->val>2){
                        printf("%c%dx^%d",(root->inh==268)?'+':'-',coeff,mchild->right->val-1);
                    }
                    else{
                        printf("%c%dx",(root->inh==268)?'+':'-',coeff);
                    }
                }
                return;
            }
            else if(root->left->type==3){
                printf("%c",(root->inh>=0)?'+':'-');
                print_derivative(root->left);
                return;
            }
        }
        case 3: {
            if(root->left->type==12 && root->middle==NULL){
                printf("%d",1);
            }
            else if(root->left->type==12){
                if(root->right->val>2)
                    printf("%dx^%d",root->right->val,root->right->val-1);
                else{
                    printf("%dx",root->right->val);   
                }
            }
            break;
        }
    }
}

int main(){
    yyparse();
    setatt(root);
    print_tree(root,0);
    for(int i=-5;i<=5;i++)
    printf("+++ f(%d) = %d\n",i,evalpoly(root,i));
    printf("\n+++ f'(x) = ");
    if(flag)
    print_derivative(root);
    else printf("0\n");
    return 0;
}
