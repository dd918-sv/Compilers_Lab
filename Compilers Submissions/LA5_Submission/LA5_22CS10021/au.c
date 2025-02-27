#include<stdio.h>

int pwr(int a,int b){
    if(b<0){
        printf("Error: NUM^(-ve) is not an integer\n");
        exit(1);
    }
    if(a==0 && b==0){
        printf("Error: 0^0 is undefined\n");
        exit(1);
    }
    int res=1;
    for(int i=0;i<b;i++){
        res*=a;
    }
    return res;
}

void mprn(int MEM[],int idx){
    printf("MEM[%d] set to %d\n",idx,MEM[idx]);
}

void eprn(int R[],int idx){
    printf("Standalone expression evaluates to %d\n",R[idx]);
}