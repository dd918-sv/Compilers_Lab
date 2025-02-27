int try(){
    return 268;
}

int main(){
    int i=0,j=10,ct=0;
    for(i=0;i<100;i++){
        if(i>j){
            while(j<=2*i){j++;}
            try(1);
        }
    }
    return 0;
}