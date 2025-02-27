#include "lex.yy.c"
#include <iomanip>
using namespace std;

// Global variables
Symbol_Object *symInstance = NULL;
Table_of_Symbols *symbol_Registory = NULL;
Table_of_Symbols *global_symbol_Registory = NULL;
quad_container quadStream;
int symbol_Tally;
string block_name;
string v_typ;

// Implementation of constructors of different classes defined in the header(.h) file

// Constructor for Type_of_Symbol_ class
Type_of_Symbol_::Type_of_Symbol_(string type_, Type_of_Symbol_ *arrtyp_, int width_) : type(type_), width(width_), arrtyp(arrtyp_) {}

// Constructor for Symbol_Object class
Symbol_Object::Symbol_Object(string name_, string type_, Type_of_Symbol_ *tp_, int width_) : name(name_), val("-"), type(tp_), nestedSymTable(NULL)
{
    type = new Type_of_Symbol_(type_, tp_, width_);
    size = type_size(type);
}

// Update method for Symbol_Object class
Symbol_Object *Symbol_Object::update(Type_of_Symbol_ *tp, int size)
{
    type = tp;
    size = type_size(tp);
    return this;
}

// Constructor for Table_of_Symbols class
Table_of_Symbols::Table_of_Symbols(string name_) : name(name_), tmp_cnt(0), par(NULL), total(0) {}

// Implementation of member function for searching a symbol in the symbol table
Symbol_Object *Table_of_Symbols::lookup(string name)
{
    // Search in the current symbol table
    for (auto &x : table)
    {
        if (x.name == name)
        {
            return &(x);
        }
    }
    // If the symbol is not found in the current symbol table, then search in the parent symbol table
    Symbol_Object *tmp = NULL;
    if (this->par != NULL)
    {
        tmp = this->par->lookup(name);
    }

    // If the symbol is not found, create a new symbol and add it to the symbol table
    if (tmp == NULL)
    {
        if (symbol_Registory == this)
        {
            Symbol_Object *new_ = new Symbol_Object(name);
            table.push_back(*new_);
            return &(table.back());
        }
    }
    else
    {
        return tmp;
    }

    return NULL;
}

// Static method to create temporary symbols
Symbol_Object *Table_of_Symbols::tempSymFactory(Type_of_Symbol_ *stype, string v, int size_)
{
    string name = "tmp" + intos(symbol_Registory->tmp_cnt++);
    Symbol_Object *new_sym = new Symbol_Object(name);
    new_sym->val = v;
    new_sym->type = stype;
    new_sym->size = type_size(stype);
    symbol_Registory->table.push_back(*new_sym);
    return &(symbol_Registory->table.back());
}

// Print method for Table_of_Symbols class
void Table_of_Symbols::print()
{
    // Print table header
    cout << "\nSymbol Table: " << name << "\n";

    for (int i = 0; i < 126; i++)
    {
        cout << "-";
    }
    cout << "\n";

    // Column Headers with borders
    cout << "| " << std::left << setw(40) << "Name"
         << "| " << setw(6) << "Type"
         << "| " << setw(14) << "Initial Value"
         << "| " << setw(5) << "Size"
         << "| " << setw(7) << "Offset"
         << "| " << setw(40) << "Nested Table" << " |\n";

    for (int i = 0; i < 126; i++)
    {
        cout << "-";
    }
    cout << "\n";

    list<Table_of_Symbols *> nested_tables;

    // Print each row of the table
    for (auto x : table)
    {
        cout << "| " << std::left << setw(40) << x.name
             << "| " << setw(6) << x.type->type
             << "| " << setw(14) << x.val
             << "| " << setw(5) << x.size
             << "| " << setw(7) << x.offset
             << "| " << setw(40);

        if (x.nestedSymTable != NULL)
        {
            cout << x.nestedSymTable->name;
            nested_tables.push_back(x.nestedSymTable);
        }
        else
        {
            cout << "NULL";
        }
        cout << " |\n";
    }

    for (int i = 0; i < 126; i++)
    {
        cout << "-";
    }
    cout << "\n";

    // Recursively print nested tables
    for (auto x : nested_tables)
    {
        x->print();
    }
}

// Update method for Table_of_Symbols class
void Table_of_Symbols::update()
{
    list<Table_of_Symbols *> nested_tables;
    int offset = 0;
    for (auto it = table.begin(); it != table.end(); it++)
    {
        if (it == table.begin())
        {
            it->offset = 0;
            offset += it->size;
        }
        else
        {
            it->offset = offset;
            offset += it->size;
        }

        if (it->nestedSymTable != NULL)
        {
            nested_tables.push_back(it->nestedSymTable);
        }
    }

    for (auto &x : nested_tables)
    {
        x->update();
    }
    return;
}

// Implementing classes related to quad

// Constructor for quad class
quad::quad(string result, string argument1, string op_, string argument2) : res(result), arg1(argument1), op(op_), arg2(argument2) {}

// Constructor for quad class with integer argument
quad::quad(string res, int argument1, string op_, string argument2) : res(res), arg2(argument2), op(op_)
{
    arg1 = intos(argument1);
}

// Constructor for quad class with float argument
quad::quad(string res, float argument1, string op_, string argument2) : res(res), arg2(argument2), op(op_)
{
    arg1 = fltos(argument1);
}

// Print method for quad class
void quad::print()
{
    // Assignment Statements
    if (op == "=")
        cout << res << " = " << arg1;
    else if (op == "*=")
        cout << "*" << res << " = " << arg1;
    else if (op == "[]=")
        cout << res << "[" << arg1 << "]" << " = " << arg2;
    else if (op == "=[]")
        cout << res << " = " << arg1 << "[" << arg2 << "]";
    // Jump Statements
    else if (op == "goto" || op == "param" || op == "return")
        cout << op << " " << res;
    else if (op == "call")
        cout << res << " = " << "call " << arg1 << ", " << arg2;
    else if (op == "label")
        cout << res << ": ";
    // Binary Operators
    else if (op == "+" || op == "-" || op == "*" || op == "/" || op == "%" || op == "^" || op == "|" || op == "&" || op == "<<" || op == ">>")
        cout << res << " = " << arg1 << " " << op << " " << arg2;
    // Relational Operators
    else if (op == "==" || op == "!=" || op == "<" || op == ">" || op == "<=" || op == ">=")
        cout << "if " << arg1 << " " << op << " " << arg2 << " goto " << res;
    // Unary operators
    else if (op == "= &" || op == "= *" || op == "= -" || op == "= ~" || op == "= !")
        cout << res << " " << op << arg1;
    else
        cout << "Unknown Operator";
}

// Print method for quad_container class
void quad_container::print()
{
    for (int i = 0; i < 132; i++)
    {
        cout << "-";
    }
    cout << endl;
    cout << "Quad Translation" << endl;
    for (int i = 0; i < 132; i++)
    {
        cout << "-";
    }
    cout << endl;
    for (int i = 0; i < arr.size(); i++)
    {
        if (arr[i].op == "label")
        {
            cout << endl;
            arr[i].print();
        }
        else
        {
            cout << "\t" << i << ":\t";
            arr[i].print();
        }
        cout << endl;
    }
}

// Implementation of emit functions

// Release function with string arguments
void emit(string op_, string res_, string argument1, string argument2)
{
    quad *new_ = new quad(res_, argument1, op_, argument2);
    quadStream.arr.push_back(*new_);
}

// Release function with integer argument
void emit(string op_, string res_, int argument1, string argument2)
{
    quad *new_ = new quad(res_, argument1, op_, argument2);
    quadStream.arr.push_back(*new_);
}

// Release function with float argument
void emit(string op_, string res_, float argument1, string argument2)
{
    quad *new_ = new quad(res_, argument1, op_, argument2);
    quadStream.arr.push_back(*new_);
}

// Implementation of createNewList function
list<int> createNewList(int n)
{
    list<int> new_list(1, n);
    return new_list;
}

// Implementation of merge function
list<int> merge(list<int> &a, list<int> &b)
{
    a.merge(b);
    return a;
}

// Implementation of Back_patching function
void Back_patching(list<int> a, int add)
{
    string tmp = intos(add);
    for (auto it : a)
    {
        quadStream.arr[it].res = tmp;
    }
}

// Implementation of is_type_correct function

// Check if types of two Symbol_Objects are correct
bool is_type_correct(Symbol_Object *&a1, Symbol_Object *&a2)
{
    Type_of_Symbol_ *tp1 = a1->type;
    Type_of_Symbol_ *tp2 = a2->type;
    if (is_type_correct(tp1, tp2))
    {
        return 1;
    }
    else if (a1 = type_CONVERSION_function(a1, tp2->type))
    {
        return 1;
    }
    else if (a2 = type_CONVERSION_function(a2, tp1->type))
    {
        return 1;
    }
    else
        return 0;
}

// Check if types of two Type_of_Symbol_ objects are correct
bool is_type_correct(Type_of_Symbol_ *a1, Type_of_Symbol_ *a2)
{
    if (a1 == NULL && a2 == NULL)
        return 1;
    else if (a1 == NULL || a2 == NULL)
        return 0;
    else if (a1->type != a2->type)
        return 0;
    else
        return is_type_correct(a1->arrtyp, a2->arrtyp);
}

// Get the type as a string
string is_type_correct(Type_of_Symbol_ *tp)
{
    if (tp == NULL)
        return "NULL";
    if (tp->type == "void" || tp->type == "func" || tp->type == "int" || tp->type == "float" || tp->type == "char" || tp->type == "block")
        return tp->type;
    if (tp->type == "ptr")
        return "pointer(" + is_type_correct(tp->arrtyp) + ")";
    if (tp->type == "arr")
        return "array(" + intos(tp->width) + "," + is_type_correct(tp->arrtyp) + ")";
    return "Random";
}

// Implementation of type_CONVERSION_function

// Convert the type of a Symbol_Object
Symbol_Object *type_CONVERSION_function(Symbol_Object *a, string tp, string convert)
{
    Symbol_Object *new_ = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_(tp));

    if (a->type->type == "float")
    {
        if (tp == "int")
        {
            emit("=", new_->name, "floatToInt(" + a->name + ")");
            return new_;
        }
        else if (tp == "char")
        {
            emit("=", new_->name, "floatToChar(" + a->name + ")");
            return new_;
        }
        return a;
    }
    else if (a->type->type == "int")
    {
        if (tp == "float")
        {
            emit("=", new_->name, "intToFloat(" + a->name + ")");
            return new_;
        }
        else if (tp == "char")
        {
            emit("=", new_->name, "intToChar(" + a->name + ")");
            return new_;
        }
        return a;
    }
    else if (a->type->type == "char")
    {
        if (tp == "float")
        {
            emit("=", new_->name, "charToFloat(" + a->name + ")");
            return new_;
        }
        else if (tp == "int")
        {
            emit("=", new_->name, "charToInt(" + a->name + ")");
            return new_;
        }
        return a;
    }

    return a;
}

// Utility functions to convert int and float to string

// Convert int to string
string intos(int n)
{
    string tmp = to_string(n);
    int len = tmp.size();
    return tmp;
}

// Convert float to string
string fltos(float f)
{
    string tmp = to_string(f);
    int len = tmp.size();
    return tmp;
}

// Implementation of functions to handle boolean expressions

// Convert an expression to boolean
Express *Expr_Bool(Express *exp)
{
    if (exp->type != "bool")
    {
        exp->false_lst = createNewList(next_instruction()); // Add false_list
        emit("==", exp->marker->name, "0");
        exp->true_lst = createNewList(next_instruction()); // Add true_list
        emit("goto", "");
    }
    return exp;
}

// Convert a boolean expression to integer
Express *converting_Bool_Int(Express *exp)
{
    if (exp->type == "bool")
    {
        exp->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int"));
        Back_patching(exp->true_lst, next_instruction());
        emit("=", exp->marker->name, "true");
        emit("goto", intos(next_instruction() + 1));
        Back_patching(exp->false_lst, next_instruction());
        emit("=", exp->marker->name, "false");
    }
    return exp;
}

// Function to alter the symbol table
void alt_table(Table_of_Symbols *tmp)
{
    symbol_Registory = tmp;
    return;
}

// Function to get the next instruction
int next_instruction()
{
    int n = 0;
    for (int i = 0; i < quadStream.arr.size(); i++)
    {
        n = quadStream.arr.size();
    }
    return n;
}

// Function to get the size of a type
int type_size(Type_of_Symbol_ *tp)
{
    if (tp == NULL)
        return 0;
    if (tp->type == "func")
        return 0;
    if (tp->type == "void")
        return 0;
    if (tp->type == "char")
        return 1;
    if (tp->type == "ptr")
        return 4;
    if (tp->type == "int")
        return 4;
    if (tp->type == "float")
        return 8;
    if (tp->type == "arr")
        return tp->width * type_size(tp->arrtyp);
    return INT16_MIN;
}

// Main function
int main()
{
    symbol_Tally = 0;
    global_symbol_Registory = new Table_of_Symbols("Global");
    symbol_Registory = global_symbol_Registory;
    block_name = "";

    yyparse();
    global_symbol_Registory->update();
    quadStream.print();
    cout << endl;
    global_symbol_Registory->print();
    return 0;
}