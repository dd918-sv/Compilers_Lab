%{
    #include<iostream>
    #include<vector>
    #include<string>
    using namespace std;
    extern int yylex();
    void yyerror(string s);
    extern char* yytext;
    extern int yylineno;

    typedef struct smb{
        string name;
        string type;
        int value;
        bool mem_latest;
        struct smb* next;
    } symboltable;

    typedef struct node_{
        string type;
        string name;
        int value;
        int truelist,falselist,nextlist;
    }node;

    typedef struct tc_{
            string tac;
            int gt;
    }TC;

    typedef struct quad_{
        string op;
        node*arg1,*arg2,*result;
        int label;
        int line_no;
        int block_no;
    }quad;

    int ct=1;
    symboltable *S=new symboltable();
    vector<string>TAC;
    vector<quad>Q;


    symboltable*lookup(string name,bool flag){
        if(S==NULL){
            S=new symboltable();
            S->next=NULL;
            S->name=name;
            if(name[0]!='$')
            S->mem_latest=1;
            else S->mem_latest=0;
            return S;
        }
        symboltable*temp=S;
        // cout<<name<<endl;
        if(temp->name==name)return temp;
        while(temp->next!=NULL){
            if(temp->next->name==name)return temp->next;
            temp=temp->next;
        }
        // cout<<"Devansha\n";
        if(flag)
        {
            cout<<"Warning: Variable "<<name<<" not declared.Default value set to Zero!"<<endl<<endl;
        }
        symboltable *curr=new symboltable();
        curr->name=name;
        if(name[0]!='$')
        curr->mem_latest=1;
        else curr->mem_latest=0;
        curr->next=NULL;
        temp->next=curr;
        return curr;
    }

    node*create_node(string type,int value){
        node*temp=new node();
        temp->type=type;
        temp->value=value;
        return temp;
    }
    node* create_node(string type,string name){
        node*temp=new node();
        temp->type=type;
        temp->name=name;
        return temp;
    }
    node* create_node(node*nd){
        if(nd==NULL) return NULL;
        node*tmp=new node();
        tmp->type=nd->type;
        tmp->name=nd->name;
        tmp->value=nd->value;
        return tmp;
    }

    quad create_quad(string op_,node*arg1_,node*arg2_,node*res_){
        quad q1;
        q1.op=op_;
        q1.arg1=create_node(arg1_);
        q1.arg2=create_node(arg2_);
        q1.result=create_node(res_);
        return q1;
    }

    
    void tac_op(node*oper,node*arg1,node*arg2,node*res){
        res->type="EXPR";
        // cout<<res->name<<endl;
        if(arg1->type=="IDEN" && arg2->type=="IDEN"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+arg1->name+" "+oper->name+" "+arg2->name;
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        else if(arg1->type=="IDEN" && arg2->type=="NUM"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+arg1->name+" "+oper->name+" "+to_string(arg2->value);
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        else if(arg1->type=="IDEN" && arg2->type=="EXPR"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+arg1->name+" "+oper->name+" "+arg2->name;
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        else if(arg1->type=="NUM" && arg2->type=="IDEN"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+to_string(arg1->value)+" "+oper->name+" "+arg2->name;
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        else if(arg1->type=="NUM" && arg2->type=="NUM"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+to_string(arg1->value)+" "+oper->name+" "+to_string(arg2->value);
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        else if(arg1->type=="NUM" && arg2->type=="EXPR"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+to_string(arg1->value)+" "+oper->name+" "+arg2->name;
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        else if(arg1->type=="EXPR" && arg2->type=="IDEN"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+arg1->name+" "+oper->name+" "+arg2->name;
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        else if(arg1->type=="EXPR" && arg2->type=="NUM"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+arg1->name+" "+oper->name+" "+to_string(arg2->value);
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        else if(arg1->type=="EXPR" && arg2->type=="EXPR"){
            string tmp_tac="";
            tmp_tac="$"+to_string(ct)+" = "+arg1->name+" "+oper->name+" "+arg2->name;
            res->name="$"+to_string(ct);
            ct++;
            TAC.push_back(tmp_tac);
        }
        quad q1=create_quad(oper->name,arg1,arg2,res);
        Q.push_back(q1);
    }


    string make_bool(node* op,node*arg1,node*arg2){
        return ((arg1->type=="NUM")?(to_string(arg1->value)):arg1->name)+" "+op->name+" "+((arg2->type=="NUM")?(to_string(arg2->value)):arg2->name);
    }

   


%}


%union{
    int ival;
    char* sval;
    char cval;
    node*nval;
}

%start LIST
%token EQ NE LT LE GT GE PLUS MINUS MUL DIV MOD LP RP SET WHEN LOOP WHILE
%token<sval>IDEN 
%token<ival>NUMB 
%type<nval> LIST STMT ASGN COND ATOM BOOL EXPR LOOP_NT RELN OPER
%type<ival> M


%%
LIST : STMT  {$$=$1;$$->nextlist=$1->nextlist;}
    |  STMT LIST {$$->nextlist=$2->nextlist;}
    ;

STMT : ASGN {$$=$1;$$->nextlist=$1->nextlist;}
    |  COND {$$=$1;$$->nextlist=$1->nextlist; }
    |  LOOP_NT {$$=$1;$$->nextlist=$1->nextlist; }
    ;

ASGN : LP SET IDEN ATOM RP{
                            // cout<<"hi\n";
                            $$=new node(); /*printf("%s\n",$3);*/ lookup($3,0); 
                            if($4->type=="NUM"){
                                string tmp_tac="";
                                string tmp($3);
                                node*arg1=create_node("NUM",$4->value);
                                node*arg2=NULL;
                                node*res=create_node("IDEN",$3);
                                tmp_tac=tmp+" = "+to_string($4->value);
                                quad q1=create_quad("=",arg1,arg2,res);
                                Q.push_back(q1);
                                TAC.push_back({tmp_tac,0});
                                
                            }
                            else if($4->type=="IDEN"){
                                lookup($4->name,1);
                                string tmp_tac1="";
                                string tmp($3);
                                tmp_tac1=tmp+" = "+$4->name;
                                node*arg1=create_node("IDEN",$4->name);
                                node*arg2=NULL;
                                node*res=create_node("IDEN",$3);
                                quad q1=create_quad("=",arg1,arg2,res);
                                Q.push_back(q1);
                                TAC.push_back({tmp_tac1,0});
                            }
                            else{
                                string tmp_tac="";
                                string tmp($3);
                                tmp_tac=tmp+" = "+$4->name;
                                node*arg1=create_node("EXPR",$4->name);
                                node*arg2=NULL;
                                node*res=create_node("IDEN",$3);
                                quad q1=create_quad("=",arg1,arg2,res);
                                Q.push_back(q1);
                                TAC.push_back({tmp_tac,0});
                            }
                            $$->nextlist=TAC.size();
                        }
    ;

COND : LP WHEN BOOL{$3->truelist=TAC.size();string tmp_tac="iffalse ( "+$3->name+" ) goto ";TAC.push_back(tmp_tac);} M LIST RP {
                                $$=new node();
                                TAC[$3->truelist]+=to_string($6->nextlist);
                                Q[$3->truelist].label=$6->nextlist;
                                // printf("%d\n",$5);
                                $3->falselist=$5;
                                $$->nextlist=$6->nextlist;
                              }
    ;

LOOP_NT : LP LOOP WHILE M BOOL {
                                    $5->truelist=TAC.size();string tmp_tac="";
                                    tmp_tac="iffalse ("+$5->name+") goto ";TAC.push_back(tmp_tac);} 
                    M LIST RP {
                                            $$=new node();
                                            $5->falselist=TAC.size()+1;
                                            TAC[$5->truelist]+=to_string($5->falselist);
                                            Q[$5->truelist].label=$5->falselist;
                                            quad q1=create_quad("goto_u",NULL,NULL,NULL);
                                            q1.label=$4;
                                            Q.push_back(q1);
                                            $8->nextlist=$4;
                                            $$->nextlist=$5->falselist;
                                            string tmp_tac= "goto "+to_string($4);
                                            TAC.push_back(tmp_tac);
                                         }
    ;

EXPR : LP OPER ATOM ATOM RP  {  
                                $$=new node();
                                tac_op($2,$3,$4,$$);
                            }
    ;

BOOL : LP RELN ATOM ATOM RP {
                                $$=new node();
                                $$->type="BOOL";
                                $$->name=make_bool($2,$3,$4);
                                quad q1; 
                                q1=create_quad($2->name,$3,$4,create_node("EXPR","$"+to_string(ct++)));
                                q1.line_no=Q.size();
                                Q.push_back(q1);
                                
                            }
    ;

ATOM : IDEN {string tmp($1);lookup(tmp,1); $$=new node(); $$->name=$1;$$->type="IDEN";}
    |  NUMB {$$=new node(); $$->value=$1;$$->type="NUM";}
    | EXPR {$$=$1;}
    ;

OPER : PLUS { $$=new node(); $$->name="+";}
    |  MINUS {$$=new node(); $$->name="-";}
    |  MUL {$$=new node(); $$->name="*";}
    |  DIV {$$=new node(); $$->name="/";}
    |  MOD {$$=new node(); $$->name="%";}
    ;

RELN : EQ {$$=new node();$$->name="==";}
    |  NE {$$=new node();$$->name="!=";}
    |  LT {$$=new node();$$->name="<";}
    |  LE {$$=new node();$$->name="<=";}
    |  GT {$$=new node();$$->name=">";}
    |  GE {$$=new node();$$->name=">=";}
    ;

M : {$$=TAC.size();}
    ;

%%

void yyerror(string s){
    cout<<s<<endl;
    cout<<"Error at line "<<yylineno<<": "<<s<<endl;
}