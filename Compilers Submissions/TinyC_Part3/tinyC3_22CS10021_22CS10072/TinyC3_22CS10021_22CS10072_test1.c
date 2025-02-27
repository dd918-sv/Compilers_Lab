int main(){

    int j,ct=0;
    int ar[10][20][20]; 

    for(int i=0;i<10;i++){
        for(j=2;j<20;j++){
            ct++;
        }
    }

    while(j<20){
        for(int i=0;i<10;i++){
            ct++;
        }
        j++;
    }

    if(j<10){
        ct++;
    }


    return 0;
}