#include<stdio.h>
#include "lex.yy.c"

symboltable addSymbol(char* name,symboltable S){
    symboltable curr= S;
    while(curr!=NULL){
        if(curr -> id && !strcmp(curr->id,name)){
            return S;
        }
        curr=curr->next;
    }
    symboltable newnode=(symboltable)malloc(sizeof(symboltable));
    newnode->id=(char*)malloc((strlen(name)+1)*(sizeof(char)));
    newnode->set=0;
    strcpy(newnode->id,name);
    newnode->next=S;
    // newnode->value= 0;
    S=newnode;
    // printf("%s added to symboltable\n",S->id);
    return S;
}

symboltable addSymbolNum(int num,symboltable S){
    symboltable curr= S;
    while(curr!=NULL){
        if(curr -> id == NULL && num==curr->value){
            return S;
        }
        curr=curr->next;
    }
    symboltable newnode=(symboltable)malloc(sizeof(symboltable));
    newnode -> id = NULL;
    newnode->set=1;
    newnode->value=num;
    newnode->next=S;
    S=newnode;
    // printf("%d added to symboltable\n",S->value);
    return S;
}

// void addSymbol(int val,)

symboltable findSymbol(symboltable S,char*name){
    symboltable curr=S;
    while(curr!=NULL){
        if(curr -> id && !strcmp(curr->id,name)){
            // printf("Found curr->id=%s\n",curr->id);
            return curr;
        }
        curr=curr->next;
    }
    return NULL;
}

symboltable findSymbolnum(symboltable S,int num){
    symboltable curr=S;
    while(curr!=NULL){
        if(curr -> id == NULL && num==curr->value){
            return curr;
        }
        curr=curr->next;
    }
    return NULL;
}

void setSymbol(symboltable node,int num){
    if(node==NULL)
    {
        // printf("ok\n");
        fflush(stdout);
        return;
    }
    node->value=num;
    node->set=1;
    printf("Variable %s is set to %d\n",node->id,num);
    return;
}

int readVal(symboltable node){
    if(node==NULL)
    {
        // printf("ok1\n");
        fflush(stdout);
        return 1;
    }
    if(node->set==0){
        printf("Error: Uninitialised variable %s is used!\n",node->id);
        exit(0);
    }
    return node->value;
}

int bin_exp(int a,int b){
    if(b==0) return 1;
    int curr=a,ans=1;
    while(b>0){
        if(b&1){
            ans=ans*curr;
        }
        b=b/2;
        curr=curr*curr;
    }
    return ans;
}

void freeTreeNode(TreeNode* node) {
    if (node == NULL) {
        return;
    }

    freeTreeNode(node->opNode.left);
    freeTreeNode(node->opNode.right);
    if (node->opNode.operation != NULL) {
        free(node->opNode.operation);
    }
    if (node->idValue != NULL) {
        free(node->idValue);
    }
    free(node);
}


int evalTree(TreeNode*node){
    int ans=0;
    if(!strcmp(node->idValue,"num")){
        ans=node->numValue;
    }
    else if(!strcmp(node->opNode.operation,"+")){
        ans=evalTree(node->opNode.left)+evalTree(node->opNode.right);
    }
    else if(!strcmp(node->opNode.operation,"-")){
        ans=evalTree(node->opNode.left)-evalTree(node->opNode.right);
    }
    else if(!strcmp(node->opNode.operation,"*")){
        ans=evalTree(node->opNode.left)*evalTree(node->opNode.right);
    }
    else if(!strcmp(node->opNode.operation,"/")){
        int tmp=evalTree(node->opNode.right);
        if(tmp==0){
            printf("Error: Division by Zero not allowed!\n");
            exit(0);
        }
        ans=evalTree(node->opNode.left)/tmp;
    }
    else if(!strcmp(node->opNode.operation,"**")){
        int a=evalTree(node->opNode.left);
        int b=evalTree(node->opNode.right);
        if(a==1) return 1;
        else{
            if(a==0){
                if(b<=0){
                    printf("Error: Zero is exponientiated to a non-positive power!\n");
                    exit(0);
                }
                else{
                    ans=0;
                }
            }
            else if(b<0){
                return 0;
            }
            else if(b>=0){
                ans=bin_exp(a,b);
            }
        }
    }
    else if(!strcmp(node->opNode.operation,"mod")){
        int a=evalTree(node->opNode.left);
        int b=evalTree(node->opNode.right);
        if(b==0){
            printf("Error: Mod(0) is invalid!\n");
            exit(0);
        }
        else{
            ans= (a%b);
        }
    }
    return ans;
}


int readTreeVal(TreeNode* node){
    node->numValue=evalTree(node);
    int ans=node->numValue;
    freeTreeNode(node);
    return ans;
}

TreeNode*createInternal(char*op,TreeNode*lft,TreeNode*rgt){
    TreeNode*curr=(TreeNode*)malloc(sizeof(TreeNode));
    curr->opNode.operation=(char*)malloc(strlen(op)*sizeof(char));
    curr->idValue=(char*)malloc((strlen("internal")+1)*sizeof(char));
    strcpy(curr->idValue,"internal");
    strcpy(curr->opNode.operation,op);
    curr->opNode.left=lft;
    curr->opNode.right=rgt;
    return curr;
}

TreeNode*createLeaf(symboltable node){
    if(node->set==0){
        printf("Error: Uninitialised variable %s is used!\n",node->id);
        exit(0);
    }
    TreeNode*curr=(TreeNode*)malloc(sizeof(TreeNode));
    curr->idValue=(char*)malloc((1+strlen("num"))*sizeof(char));
    strcpy(curr->idValue,"num");
    curr->numValue=node->value;
    curr->opNode.left=NULL;
    curr->opNode.right=NULL;
    curr->opNode.operation=NULL;
    return curr;
}

int main(){
    yyparse();
    return 0;
}

