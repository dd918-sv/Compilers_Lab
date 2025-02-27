#ifndef __TRANSLATOR_H
#define __TRANSLATOR_H

#include <iostream>
#include <vector>
#include <list>
using namespace std;

// Defining the sizes of the basic data types
#define _VOID_SIZE 0
#define _FUNCTION_SIZE 0
#define _CHARACTER_SIZE 1
#define _INTEGER_SIZE 4
#define _POINTER_SIZE 4
#define _FLOAT_SIZE 8

// Forward declarations of classes used in the translator
class Symbol_Object;
class Type_of_Symbol_;
class Table_of_Symbols;
class quad;
class quad_container;

// Global variables used in the translator
extern Symbol_Object *symInstance;
extern Table_of_Symbols *symbol_Registory;
extern Table_of_Symbols *global_symbol_Registory;
extern quad_container quadStream;
extern int symbol_Tally;
extern string block_name;

extern char *yytext;
extern int yyparse();

// Symbol_Object class stores information about a symbol
class Symbol_Object
{
public:
    string name; // Name of the symbol
    Type_of_Symbol_ *type; // Type of the symbol
    string val; // Value of the symbol
    int size; // Size of the symbol
    int offset; // Offset of the symbol
    Table_of_Symbols *nestedSymTable; // Nested symbol table

    // Constructor
    Symbol_Object(string, string = "int", Type_of_Symbol_ * = NULL, int = 0);
    // Update method
    Symbol_Object *update(Type_of_Symbol_ *, int = 0);
};

// Type_of_Symbol_ class stores information about the type of a symbol
class Type_of_Symbol_
{
public:
    string type; // Type name
    int width; // Width of the type
    Type_of_Symbol_ *arrtyp; // Array type

    // Constructor
    Type_of_Symbol_(string, Type_of_Symbol_ * = NULL, int = 1);
};

// Table_of_Symbols class stores information about the symbol table
class Table_of_Symbols
{
public:
    string name; // Name of the table
    int tmp_cnt; // Temporary count
    int total; // Total symbols
    list<Symbol_Object> table; // List of symbols
    Table_of_Symbols *par; // Parent table

    // Constructor
    Table_of_Symbols(string = "NULL");
    // Lookup method
    Symbol_Object *lookup(string);
    // Static method to create temporary symbols
    static Symbol_Object *tempSymFactory(Type_of_Symbol_ *, string = "", int = 0);

    // Print method
    void print();
    // Update method
    void update();
};

// quad class stores information about a quadruple
class quad
{
public:
    string op; // Operation
    string arg1; // Argument 1
    string arg2; // Argument 2
    string res; // Result

    // Constructors
    quad(string result, string argument1, string op_ = "=", string argument2 = "");
    quad(string res, int argument1, string op_ = "=", string argument2 = "");
    quad(string res, float argument1, string op_ = "=", string argument2 = "");

    // Print method
    void print();
};

// quad_container class stores information about a quadruple container
class quad_container
{
public:
    vector<quad> arr; // Vector of quadruples

    // Print method
    void print();
};

// array class stores information about an array
class array
{
public:
    string artp; // Array type
    Symbol_Object *marker; // Marker symbol
    Symbol_Object *arr; // Array symbol
    Type_of_Symbol_ *type; // Type of the array
};

// statement class stores next list
class statement
{
public:
    list<int> nxt_lst; // Next list
};

// Express class stores information about an expression
class Express
{
public:
    string type; // Type of the expression
    Symbol_Object *marker; // Marker symbol
    list<int> true_lst; // True list
    list<int> false_lst; // False list
    list<int> nxt_lst; // Next list
};

// emit function releases a quadruple
void emit(string op, string res, string arg1 = "", string arg2 = "");
void emit(string op, string res, int arg1, string arg2 = "");
void emit(string op, string res, float arg1, string arg2 = "");

// Functions to create and merge lists
list<int> createNewList(int);
list<int> merge(list<int> &, list<int> &);

// Back_patching function back patches the quadruple
void Back_patching(list<int> l, int addr);

// Functions to check type correctness
bool is_type_correct(Symbol_Object *&a1, Symbol_Object *&a2);
bool is_type_correct(Type_of_Symbol_ *a1, Type_of_Symbol_ *a2);
string is_type_correct(Type_of_Symbol_ *);

// Function to convert types
Symbol_Object *type_CONVERSION_function(Symbol_Object *s, string t, string convert = "");

// Utility functions to convert int and float to string
string intos(int);
string fltos(float);

// Functions to handle boolean expressions
Express *Expr_Bool(Express *);
Express *converting_Bool_Int(Express *);

// Function to alter the symbol table
void alt_table(Table_of_Symbols *);

// Function to get the next instruction
int next_instruction();

// Function to get the size of a type
int type_size(Type_of_Symbol_ *);

#endif