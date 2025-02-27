#include "lex.yy.c"
#include<fstream>
int N=5;

struct reg_des{
    node*var;
    int value;
    int changes;
    struct reg_des*next;
};
typedef struct reg_des regDesc;

typedef struct pair_{
    regDesc* reg;
    int score;
}pair_reg;
vector<pair_reg>descriptor(N,{NULL,0});
vector<bool>leaders;

int searchDesc(node*arg){
    for(int i=0;i<N;i++){
        regDesc*curr=descriptor[i].reg;
        while(curr!=NULL){
            // cout<<curr<<endl;
            if((curr->var->type==arg->type) &&(curr->var->name==arg->name)){
                return i;
            }
            // if(curr->var->name==curr->next->var->name){curr->next=NULL; break;}
            curr=curr->next;
        }
    }
    return -1;
}

void remove_var(string nme,int r){
   if(descriptor[r].reg==NULL) return;

   if (descriptor[r].reg->var->name == nme) {
        regDesc*tmp = descriptor[r].reg;
        descriptor[r].reg = descriptor[r].reg->next;
        delete tmp;
        return;
    }
    regDesc*curr=descriptor[r].reg;  
    while (curr->next!= NULL && curr->next->var->name != nme) {
        curr = curr->next;
    }
    if(curr->next==NULL) return;
    regDesc*tmp=curr->next;
    curr->next=tmp->next;
    delete tmp;
    return;
 
}

void insertDesc(node*arg,int i){
    if(descriptor[i].reg==NULL){
        descriptor[i].reg=new regDesc();
        descriptor[i].reg->var=create_node(arg);
        descriptor[i].reg->next=NULL;
        for(int j=0;j<N;j++){
            if(i!=j)
            remove_var(arg->name,j);
        }
        return;
    }
    regDesc*nr=new regDesc();
    nr->var=create_node(arg);
    nr->next=descriptor[i].reg;
    descriptor[i].reg=nr;
    for(int j=0;j<N;j++){
        if(i!=j)
        remove_var(arg->name,j);
    }
    return;
}
vector<quad>T;

void delocate(int i){
    descriptor[i].score=0;
    regDesc*curr=descriptor[i].reg;
    while(curr!=NULL){
        regDesc*tmp=curr;
        curr=curr->next;
        delete tmp;
    }
    descriptor[i].reg = NULL;
    return;
}

quad makeTAC_op(string op_,string arg1_,string arg2_,string res_){
    node*arg1=create_node("REG",arg1_);
    node*arg2=create_node("REG",arg2_);
    node*res=create_node("REG",res_);
    quad q1=create_quad(op_,arg1,arg2,res);
    return q1;
}

bool check_live(node*arg,int line){
    for(int i=line;(i<Q.size() && i<leaders.size() && !leaders[i]);i++){
        // cout<<arg->name<<endl;
        if((Q[i].arg1!=NULL && Q[i].arg1->name==arg->name) || (Q[i].arg2!=NULL && Q[i].arg2->name==arg->name) || (Q[i].result!=NULL && Q[i].result->name==arg->name)){
            return true;
        }
    }
    return false;
}

void deloc_store(int i){
    if(descriptor[i].reg==NULL){
        descriptor[i].score=0;
        return;
    }
    regDesc*curr=descriptor[i].reg;
    while(curr!=NULL){
        symboltable*tmp=lookup(curr->var->name,0);
        if( (tmp!=NULL) && !(tmp->mem_latest) && (curr->var->type!="EXPR")){
            quad q1=makeTAC_op("ST",curr->var->name,"R"+to_string(i),"");
            T.push_back(q1);
            tmp->mem_latest=1;
        }
        regDesc*nd=curr;
        curr=curr->next;
        delete nd;
    }
    descriptor[i].reg=NULL;
    descriptor[i].score=0;
    return;
}

int calc_score(int i){
    regDesc*curr=descriptor[i].reg;
    if(curr==NULL) return 0;
    int score=0;
    while(curr!=NULL){
        symboltable*tmp=lookup(curr->var->name,0);
        // cout<<"DD "<<tmp->name<<endl;
        if((!tmp->mem_latest)){/*cout<<"hello "<<i<<" "<<tmp->name<<endl;*/ score+=1;}
        curr=curr->next;
    }
    return score;
}

int allocate(node*arg,int line_no,bool imm,quad &q1){
    //1.
    string load=(imm)?"LDI":"LD";
    string argval=(imm)?(to_string(arg->value)):(arg->name);
    int r=searchDesc(arg);
    if(r!=-1){
        // descriptor[r].score=1;
        return r;
    }
    //2.
    for(int i=0;i<N;i++){
        if(descriptor[i].reg==NULL){
            insertDesc(arg,i);
            q1=makeTAC_op(load,"R"+to_string(i),argval,"");
            // descriptor[i].score=1;
            return i;
        }
    }
    //3.
    for(int i=0;i<N;i++){
        if(calc_score(i)==0){
            delocate(i);
            insertDesc(arg,i);
            q1=makeTAC_op(load,"R"+to_string(i),argval,"");
            // descriptor[i].score=1;
            return i;
        }
    }
    //5.
    for(int i=0;i<N;i++){
        regDesc*curr=descriptor[i].reg;
        bool live_temp=false;
        while(curr!=NULL){
            if(check_live(curr->var,line_no)){
                live_temp=true;
                break;
            }
            curr=curr->next;
        }
        if(!live_temp){
            deloc_store(i);
            insertDesc(arg,i);
            q1=makeTAC_op(load,"R"+to_string(i),argval,"");
            // descriptor[i].score=1;
            return i;
        }
    }
    //6.
    // cout<<"Devansha Point 6"<<arg->name<<endl;
    int mn=INT32_MAX,i_mn=-1;
    for(int i=0;i<N;i++){
        int score=calc_score(i);
        // cout<<i<<" "<<score<<endl;
        if(score<=mn && descriptor[i].score!=1){
            mn=score;
            i_mn=i;
        }
    }
    // cout<<"i_mn= "<<i_mn<<" "<<arg->name<<endl;
    deloc_store(i_mn);
    insertDesc(arg,i_mn);
    // descriptor[i_mn].score=1;
    q1=makeTAC_op(load,"R"+to_string(i_mn),argval,"");
    return i_mn;
}

void allocate_arith(quad q){
    int r1=-1,r2=-1,r3=-1;
    string t,a,b;
    quad q1;

    // r3=allocate(q.result,q.line_no,0,q1);
    symboltable*symb=lookup(q.result->name,0);
    symb->mem_latest=0;
    // for(int j=0;j<N;j++){
    //     if(r3!=j){
    //         remove_var(symb->name,j);
    //     }
    // }
    // t="R"+to_string(r3);
    if(q.arg1->type!="NUM"){
        if(q.arg1->name==q.result->name){
            // makeTAC_op("LD","R"+to_string(r3),q.arg1->name,"");
            quad q2;
            r1=allocate(q.arg1,q.line_no,0,q2);
            a="R"+to_string(r1);
        }
        else{
            quad q2;
            // /*jaojfjoj*/cout<<q.arg1->name<<" "<<r3<<endl;
            r1=allocate(q.arg1,q.line_no,0,q2);
            if(q2.op!="")
            T.push_back(q2);
            T[T.size()-1].block_no=q.block_no;
            T[T.size()-1].label=q.label;
            a="R"+to_string(r1);
        }
    }
    else{
        a=to_string(q.arg1->value);
    }
    if(q.arg2->type!="NUM"){
        if(q.arg2->name==q.result->name){
            // makeTAC_op("LD","R"+to_string(r3),q.arg2->name,"");
            quad q2;
            r2=allocate(q.arg2,q.line_no,0,q2);
            b="R"+to_string(r2);
        }
        else{
            quad q2;
            r2=allocate(q.arg2,q.line_no,0,q2);
            if(q2.op!="")
            T.push_back(q2);
            T[T.size()-1].block_no=q.block_no;
            T[T.size()-1].label=q.label;
            b="R"+to_string(r2);
        }
    }
    else{
        b=to_string(q.arg2->value);
    }
    if(r1==-1 && r2==-1){
        r3=allocate(q.result,q.line_no,0,q1);
        // if(q1.op!="") T.push_back(q1);
        t="R"+to_string(r3);
    }
    else if(r1==-1){
        r3=allocate(q.result,q.line_no,0,q1);
        // if(q1.op!="") T.push_back(q1);
        t="R"+to_string(r3);
    }
    else if(r2==-1){
        r3=allocate(q.result,q.line_no,0,q1);
        // if(q1.op!="") T.push_back(q1);
        t="R"+to_string(r3);
    }
    else{
        r3=r2;
        t="R"+to_string(r3);
    }
    q1=makeTAC_op(q.op,t,a,b);
    T.push_back(q1);
    T[T.size()-1].block_no=q.block_no;
    T[T.size()-1].label=q.label;
    symb->mem_latest=0;
    // makeTAC_op("LD","R"+to_string(r3),q.result->name,"");

}

void allocate_set(quad q){
    int ra=-1,rt;
    symboltable*tmp=lookup(q.result->name,0);
    tmp->mem_latest=0;
    if(q.arg1->type=="NUM"){
        quad q1;
        rt=allocate(q.result,q.line_no,1,q1);
        quad q2=makeTAC_op("LDI","R"+to_string(rt),to_string(q.arg1->value),"");
        T.push_back(q2);
        T[T.size()-1].label=q.label;
        T[T.size()-1].block_no=q.block_no;
    }
    else{
        quad q1;
        ra=allocate(q.arg1,q.line_no,0,q1);
        insertDesc(q.result,ra);
    }
        // cout<<tmp->name<<" "<<tmp->mem_latest<<endl;
    return;

}

void allocate_cond(quad q){
    string arg1="";string arg2="";
    if(q.arg1->type!="NUM"){
        // cout<<q.arg1->name<<" "<<q.arg1->type<<endl;
        quad q1;
        arg1="R"+to_string(allocate(q.arg1,q.line_no,0,q1));
        if(q1.op!=""){
            T.push_back(q1);
            T[T.size()-1].label=q.label;
            T[T.size()-1].block_no=q.block_no;
        }
    }
    else {
        // cout<<"hi\n";
        // cout<<q.arg1->value<<" "<<q.arg1->type<<endl;
       arg1=to_string(q.arg1->value); 
    }

    if(q.arg2->type!="NUM"){
        // cout<<q.arg2->name<<" "<<q.arg2->type<<endl;
        quad q1;
        arg2="R"+to_string(allocate(q.arg2,q.line_no,0,q1));
        if(q1.op!=""){
            T.push_back(q1);
            T[T.size()-1].label=q.label;
            T[T.size()-1].block_no=q.block_no;
        }
    }
    else{
        // cout<<q.arg2->value<<" "<<q.arg2->type<<endl;
        arg2=to_string(q.arg2->value);
    }
    if(q.op=="=="){T.push_back(makeTAC_op("JNE",arg1,arg2,""));T[T.size()-1].label=q.label;T[T.size()-1].block_no=q.block_no;}
    else if(q.op==">=") {T.push_back(makeTAC_op("JLT",arg1,arg2,"__"));T[T.size()-1].label=q.label;T[T.size()-1].block_no=q.block_no;}
    else if(q.op=="<=") {T.push_back(makeTAC_op("JGT",arg1,arg2,"__"));T[T.size()-1].label=q.label;T[T.size()-1].block_no=q.block_no;}
    else if(q.op==">") {T.push_back(makeTAC_op("JLE",arg1,arg2,"__"));T[T.size()-1].label=q.label;T[T.size()-1].block_no=q.block_no;}
    else if(q.op=="<") {T.push_back(makeTAC_op("JGE",arg1,arg2,"__"));T[T.size()-1].label=q.label;T[T.size()-1].block_no=q.block_no;}
    else if(q.op=="!=") {T.push_back(makeTAC_op("JEQ",arg1,arg2,"__"));T[T.size()-1].label=q.label;T[T.size()-1].block_no=q.block_no;}
    for(int p=0;p<N;p++){ deloc_store(p);}
    return;
}

void allocate_uncond(quad q){
    T.push_back(makeTAC_op("JMP","","",""));
    T[T.size()-1].block_no=q.block_no;
    T[T.size()-1].label=q.label;
}

int main(int argc,char*argv[]){
    if(argc>1 && stoi(argv[1])>=2){
        cout<<"Number of registers provided is "<<argv[1]<<endl<<endl;
        N=stoi(argv[1]);
    }
    else if(argc<=1){
        cout<<"Number of registers not provided. Default value is 5!"<<endl<<endl;
        N=5;
    }
    else if(stoi(argv[1])<2){
        cout<<"Number of registers should be atleast 2.Default value is taken as 5!"<<endl<<endl;
        N=5;
    }
    S=new symboltable();
    yyparse();
    ofstream file1("intermediate.txt");
    if(!file1){
        cerr<<"File1 not created"<<endl;
        return 1;
    }
    ofstream file2("target_code.txt");
    if(!file2){
        cerr<<"File2 not created"<<endl;
        return 1;
    }
    //Printing Intermediate Code and Defining blocks using leaders array approach
    TAC.push_back("");
    leaders.assign(TAC.size(),false);
    leaders[0]=true;
    for(int i=0;i<Q.size();i++){
        if(Q[i].op=="goto_u" || Q[i].op=="goto_c" || Q[i].op=="==" || Q[i].op=="!=" || Q[i].op==">=" || Q[i].op=="<=" || Q[i].op==">" || Q[i].op=="<"){
            leaders[i+1]=1;
            leaders[Q[i].label]=1;
        }
        Q[i].line_no=i;
    }
    
    int label=0;
    int block=1;
    vector<int>block_line(leaders.size()+1,INT32_MAX);

    for(auto q:TAC){
        if(leaders[label] && label<TAC.size()-1){
            file1<<endl;
            file1<<"Block "<<block++<<endl;
        }
        Q[label].block_no=block-1;
        file1<<"\t"<<label++<<"\t:"<<q<<endl;
    }   

    int i=0;
    for(auto q:Q){
        if(leaders[i]){
            for(int j=0;j<N;j++){
                deloc_store(j);
            }
        }
        if(q.op=="+" || q.op=="-"|| q.op=="*"||q.op=="/"||q.op=="%"){
            allocate_arith(q);
        }
        else if(q.op=="="){
            allocate_set(q);
            symboltable*tmp=lookup(q.result->name,0);
            tmp->mem_latest=0;
        }
        else if(q.op=="goto_u"){
            for(int j=0;j<N;j++){
                deloc_store(j);
            }
            allocate_uncond(q);
        }
        else {
            // cout<<q.op<<" "<<q.arg1->name<<" "<<q.arg2->value<<" "<<q.result->name<<endl;
            allocate_cond(q);
            quad q1=T[T.size()-1];
        }
        i++;
    }
    // symboltable*tmp=lookup("n",0);
    // cout<<tmp->name<<" af "<<tmp->mem_latest<<endl;
    for(int j=0;j<N;j++){
        // cout<<i<<" ";
        deloc_store(j);
    }
    
    vector<bool>leader_T(T.size(),false);
    leader_T[0]=1;
    // cout<<endl<<endl;
    for(int j=0;j<T.size();j++){
        T[j].line_no=j;
    }
    for(int j=0;j<T.size();j++){
        if(T[j].block_no>0 && T[j].block_no<block_line.size())
            block_line[T[j].block_no]=min(block_line[T[j].block_no],j);
    }
    // cout<<endl;
    for(int j=0;j<T.size();j++){
        if(T[j].block_no>0 && T[j].block_no<block_line.size() && block_line[T[j].block_no]==j){
            leader_T[j]=true;
        }
    }

    block=1;
    for(auto t:T){
        if(leader_T[t.line_no]){
            file2<<"\nBlock "<<block++<<endl;
        }
        if(t.op[0]=='J') {
            if(t.label==TAC.size()-1) block_line[Q[t.label].block_no]=T.size();
            t.result->name=to_string(block_line[Q[t.label].block_no]);
            }
        string oper="";
        if(t.op=="+") oper="ADD";
        else if(t.op=="-") oper="SUB";
        else if(t.op=="*") oper="MUL";
        else if(t.op=="/") oper="DIV";
        else if(t.op=="%") oper="REM";
        file2<<"\t"<<t.line_no<<"\t"<<((oper=="")?t.op:oper)<<" "<<t.arg1->name<<" "<<t.arg2->name<<" "<<t.result->name<<endl;
        // i++;
    }
    file2<<"\t"<<T.size()<<endl;
    file1.close();
    file2.close();
    cout<<"Completed Succesfully!"<<endl;
    return 0;
}




// void allocate_arith(quad q){
//     int r1=-1,r2=-1,r3;
//     string t,a,b;
//     quad q1;
//     r3=allocate(q.result,q.line_no,0,q1);
//     symboltable*symb=lookup(q.result->name,0);
//     symb->mem_latest=0;
//     for(int j=0;j<N;j++){
//         if(r3!=j){
//             remove_var(symb->name,j);
//         }
//     }
//     t="R"+to_string(r3);
//     if(q.arg1->type!="NUM"){
//         if(q.arg1->name==q.result->name){
//             // makeTAC_op("LD","R"+to_string(r3),q.arg1->name,"");
//             r1=r3;
//             a="R"+to_string(r1);
//         }
//         else{
//             quad q2;
//             // /*jaojfjoj*/cout<<q.arg1->name<<" "<<r3<<endl;
//             r1=allocate(q.arg1,q.line_no,0,q2);
//             if(q2.op!="")
//             T.push_back(q2);
//             T[T.size()-1].block_no=q.block_no;
//             T[T.size()-1].label=q.label;
//             a="R"+to_string(r1);
//         }
//     }
//     else{
//         a=to_string(q.arg1->value);
//     }
//     if(q.arg2->type!="NUM"){
//         if(q.arg2->name==q.result->name){
//             // makeTAC_op("LD","R"+to_string(r3),q.arg2->name,"");
//             r2=r3;
//             b="R"+to_string(r2);
//         }
//         else{
//             quad q2;
//             r2=allocate(q.arg2,q.line_no,0,q2);
//             if(q2.op!="")
//             T.push_back(q2);
//             T[T.size()-1].block_no=q.block_no;
//             T[T.size()-1].label=q.label;
//             b="R"+to_string(r2);
//         }
//     }
//     else{
//         b=to_string(q.arg2->value);
//     }
//     q1=makeTAC_op(q.op,t,a,b);
//     T.push_back(q1);
//     T[T.size()-1].block_no=q.block_no;
//     T[T.size()-1].label=q.label;
//     symb->mem_latest=0;
//     // makeTAC_op("LD","R"+to_string(r3),q.result->name,"");

// }