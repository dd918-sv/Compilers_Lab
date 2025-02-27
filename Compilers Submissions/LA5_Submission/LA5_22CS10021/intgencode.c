#include<stdio.h>
#include "lex.yy.c"

symboltable addSymbol(char*name,symboltable S){
    if(S==NULL){
        S=(symboltable)malloc(sizeof(symboltable));
        S->id=(char*)malloc(strlen(name)+1);
        strcpy(S->id,name);
        S->mem_idx=0;
        S->next=NULL;
        return S;
    }
    symboltable curr=S;
    symboltable tmp=findSymbol(S,name);
    // printf("hi\n");
    if(tmp!=NULL)return S;
    mem_idx++;
    while(curr->next!=NULL){
        curr=curr->next;
    }
    curr->next=(symboltable)malloc(sizeof(symboltable));
    curr->next->id=(char*)malloc(strlen(name)+1);
    strcpy(curr->next->id,name);
    curr->next->mem_idx=mem_idx;
    curr->next->next=NULL;
    return S;
}

symboltable findSymbol(symboltable S,char*name){
    symboltable curr=S;
    while(curr!=NULL){
        if(strcmp(curr->id,name)==0){
            return curr;
        }
        curr=curr->next;
    }
    return NULL; 
}

void print(int reg,record a, record b, int op){
    switch(op){
        case 1:{
            if(a.type==1){

                if(b.type==1){
                    
                }
            }
        }
    }
}

void printRegReg(int rd,int rs,int rt,int op){
    switch(op){
        case PLUS:{
            fprintf(fptr,"\tR[%d]=R[%d]+R[%d];\n",rd,rs,rt);
            break;
        }
        case MINUS:{
            fprintf(fptr,"\tR[%d]=R[%d]-R[%d];\n",rd,rs,rt);
            break;
        }
        case MULTIPLY:{
            fprintf(fptr,"\tR[%d]=R[%d]*R[%d];\n",rd,rs,rt);
            break;
        }
        case DIVIDE:{
            fprintf(fptr,"\tR[%d]=R[%d]/R[%d];\n",rd,rs,rt);
            break;
        }
        case MODULO:{
            fprintf(fptr,"\tR[%d]=R[%d]%%R[%d];\n",rd,rs,rt);
            break;
        }
        case EXPONENT:{
            fprintf(fptr,"\tR[%d]=pwr(R[%d],R[%d]);\n",rd,rs,rt);
            break;
        }
    }
}

void printRegNum(int rd,int rs,int num,int op){
    switch(op){
        case PLUS:{
            fprintf(fptr,"\tR[%d]=R[%d]+%d;\n",rd,rs,num);
            break;
        }
        case MINUS:{
            fprintf(fptr,"\tR[%d]=R[%d]-%d;\n",rd,rs,num);
            break;
        }
        case MULTIPLY:{
            fprintf(fptr,"\tR[%d]=R[%d]*%d;\n",rd,rs,num);
            break;
        }
        case DIVIDE:{
            fprintf(fptr,"\tR[%d]=R[%d]/%d;\n",rd,rs,num);
            break;
        }
        case MODULO:{
            fprintf(fptr,"\tR[%d]=R[%d]%%%d;\n",rd,rs,num);
            break;
        }
        case EXPONENT:{
            fprintf(fptr,"\tR[%d]=pwr(R[%d],%d);\n",rd,rs,num);
            break;
        }
    }
}

void printNumReg(int rd,int num,int rs,int op){
    switch(op){
        case PLUS:{
            fprintf(fptr,"\tR[%d]=%d+R[%d];\n",rd,num,rs);
            break;
        }
        case MINUS:{
            fprintf(fptr,"\tR[%d]=%d-R[%d];\n",rd,num,rs);
            break;
        }
        case MULTIPLY:{
            fprintf(fptr,"\tR[%d]=%d*R[%d];\n",rd,num,rs);
            break;
        }
        case DIVIDE:{
            fprintf(fptr,"\tR[%d]=%d/R[%d];\n",rd,num,rs);
            break;
        }
        case MODULO:{
            fprintf(fptr,"\tR[%d]=%d%%R[%d];\n",rd,num,rs);
            break;
        }
        case EXPONENT:{
            fprintf(fptr,"\tR[%d]=pwr(%d,R[%d]);\n",rd,num,rs);
            break;
        }
    }
}

void printNumNum(int rd,int num1,int num2,int op){
    switch(op){
        case PLUS:{
            fprintf(fptr,"\tR[%d]=%d+%d;\n",rd,num1,num2);
            break;
        }
        case MINUS:{
            fprintf(fptr,"\tR[%d]=%d-%d;\n",rd,num1,num2);
            break;
        }
        case MULTIPLY:{
            fprintf(fptr,"\tR[%d]=%d*%d;\n",rd,num1,num2);
            break;
        }
        case DIVIDE:{
            fprintf(fptr,"\tR[%d]=%d/%d;\n",rd,num1,num2);
            break;
        }
        case MODULO:{
            fprintf(fptr,"\tR[%d]=%d%%%d;\n",rd,num1,num2);
            break;
        }
        case EXPONENT:{
            fprintf(fptr,"\tR[%d]=pwr(%d,%d);\n",rd,num1,num2);
            break;
        }
    }
}

void printTAC(record* expr,record arg1,record arg2,int op){
    if(arg1.type==1 && arg2.type==1){
        fprintf(fptr,"\tR[%d]=MEM[%d];\n\tR[%d]=MEM[%d];\n",0,arg1.m_id,1,arg2.m_id);
        if(lst_reg<12){
            printRegReg(lst_reg,0,1,op);
            expr->reg=lst_reg++;
        }
        else{
            printRegReg(0,0,1,op);
            fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
            expr->m_id=mem_idx++;
            expr->reg=0;
        }
    }
    else if(arg1.type==1 && arg2.type==2){
        fprintf(fptr,"\tR[%d]=MEM[%d];\n",0,arg1.m_id);
        if(lst_reg<12){
            printRegNum(lst_reg,0,arg2.val,op);
            expr->reg=lst_reg++;
        }
        else{
            printRegNum(0,0,arg2.val,op);
            fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
            expr->m_id=mem_idx++;
            expr->reg=0;
        }
    }
    else if(arg1.type==1 && arg2.type==3){
        fprintf(fptr,"\tR[%d]=MEM[%d];\n",0,arg1.m_id);
        if(arg2.reg!=0){
            printRegReg(arg2.reg,0,arg2.reg,op);
            expr->reg=arg2.reg;;
        }
        else{
            fprintf(fptr,"\tR[%d]=MEM[%d];\n",1,arg2.m_id);
            if(lst_reg<12){
                printRegReg(lst_reg,0,1,op);
                expr->reg=lst_reg++;
            }
            else{
                printRegReg(0,0,1,op);
                fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
                expr->m_id=mem_idx++;
                expr->reg=0;
            }
        }
    }
    else if(arg1.type==2 && arg2.type==1){
        fprintf(fptr,"\tR[%d]=MEM[%d];\n",0,arg2.m_id);
        if(lst_reg<12){
            printNumReg(lst_reg,arg1.val,0,op);
            expr->reg=lst_reg++;
        }
        else{
            printNumReg(0,arg1.val,0,op);
            fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
            expr->m_id=mem_idx++;
            expr->reg=0;
        }
    }
    else if(arg1.type==2 && arg2.type==2){
        if(lst_reg<12){
            printNumNum(lst_reg,arg1.val,arg2.val,op);
            expr->reg=lst_reg++;
        }
        else{
            printNumNum(0,arg1.val,arg2.val,op);
            fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
            expr->m_id=mem_idx++;
            expr->reg=0;
        }
    }
    else if(arg1.type==2 && arg2.type==3){
        if(arg2.reg!=0){
            printNumReg(arg2.reg,arg1.val,arg2.reg,op);
            expr->reg=arg2.reg;
        }
        else{
            fprintf(fptr,"\tR[%d]=MEM[%d];\n",1,arg2.m_id);
            if(lst_reg<12){
                printNumReg(lst_reg,arg1.val,1,op);
                expr->reg=lst_reg++;
            }
            else{
                printNumReg(0,arg1.val,1,op);
                fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
                expr->m_id=mem_idx++;
                expr->reg=0;
            }
        }
    }
    else if(arg1.type==3 && arg2.type==1){
        if(arg1.reg!=0){
            // printf("hi\n");
            fprintf(fptr,"\tR[%d]=MEM[%d];\n",0,arg2.m_id);
            printRegReg(arg1.reg,arg1.reg,0,op);
            expr->reg=arg1.reg;
        }
        else{
            fprintf(fptr,"\tR[%d]=MEM[%d];\n",0,arg1.m_id);
            if(lst_reg<12){
                printRegNum(lst_reg,0,arg2.val,op);
                expr->reg=lst_reg++;
            }
            else{
                printRegNum(0,0,arg2.val,op);
                fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
                expr->m_id=mem_idx++;
                expr->reg=0;
            }
        
        }
    }
    else if(arg1.type==3 && arg2.type==2){
        if(arg1.reg!=0){
            printRegNum(arg1.reg,arg1.reg,arg2.val,op);
            expr->reg=arg1.reg;
        }
        else{
            fprintf(fptr,"\tR[%d]=MEM[%d];\n",0,arg1.m_id);
            if(lst_reg<12){
                printRegNum(lst_reg,0,arg2.val,op);
                expr->reg=lst_reg++;
            }
            else{
                printRegNum(0,0,arg2.val,op);
                fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
                expr->m_id=mem_idx++;
                expr->reg=0;
            }
        }
    }
    else if(arg1.type==3 && arg2.type==3){
        // printf("hi\n");
        if(arg1.reg!=0 && arg2.reg!=0){
            // fprintf(fptr,"hi1 %d %d\n",arg1.reg,arg2.reg);
            printRegReg(arg1.reg,arg1.reg,arg2.reg,op);
            lst_reg--;
            expr->reg=arg1.reg;
        }
        else if(arg1.reg!=0 && arg2.reg==0){
            // printf("hi2\n");
            fprintf(fptr,"\tR[%d]=MEM[%d];\n",0,arg2.m_id);
            printRegReg(arg1.reg,arg1.reg,0,op);
            expr->reg=arg1.reg;
        }
        else if(arg1.reg==0 && arg2.reg!=0){
            // printf("hi3\n");
            fprintf(fptr,"\tR[%d]=MEM[%d];\n",0,arg1.m_id);
            printRegReg(arg2.reg,0,arg2.reg,op);
            expr->reg=arg2.reg;
        }
        else{
            // printf("hi4\n");
            fprintf(fptr,"\tR[%d]=MEM[%d];\n\tR[%d]=MEM[%d];\n",0,arg1.m_id,1,arg2.m_id);
            if(lst_reg<12){
                printRegReg(lst_reg,0,1,op);
                expr->reg=lst_reg++;
            }
            else{
                printRegReg(0,0,1,op);
                fprintf(fptr,"\tMEM[%d]=R[0];\n",mem_idx);
                expr->m_id=mem_idx++;
                expr->reg=0;
            }
        }

    }
}

int main(){
    fptr=fopen("intcode.c","w");
    fprintf(fptr,"#include <stdio.h>\n#include<stdlib.h>\n\n#include \"au.c\"\n\nint main ( ){\n\tint R[12];\n\tint MEM[65536];\n");
    if(fptr==NULL){
        printf("Error!\n");
        exit(1);
    }
    yyparse();
    fprintf(fptr,"\treturn 0;\n}\n");
    fclose(fptr);

    symboltable curr=S;
    while(curr!=NULL){
        symboltable tmp=curr;
        free(tmp);
        curr=curr->next;
    }
    
    return 0;
}