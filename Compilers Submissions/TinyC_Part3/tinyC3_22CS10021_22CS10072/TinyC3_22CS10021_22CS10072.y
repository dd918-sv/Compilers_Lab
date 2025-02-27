%{
    /**
    * Devansha Dhanker(22CS10021)
    * Shivam Choudhury(22CS10072)
    */
    #include <iostream>  // Include the standard input-output stream library
    #include "TinyC3_22CS10021_22CS10072_translator.h"  // Include custom header for the translator
    using namespace std;  // Use the standard namespace

    extern int yylex();          // Function prototype for the lexer
    void yyerror(string s);      // Function prototype for error reporting
    extern char* yytext;         // Variable to store the text being scanned
    extern int yylineno;         // Variable to store the current line number being scanned
    extern string v_typ;         // Variable to store the last type scanned
%}

// Define a union to hold various data types used in the parser
%union {
    int intval;                // INTEGER_VAL type
    int ins_no;                // INSTRUCTION_NUMBER type
    char* charval;             // CHAR_VALUE type
    char op_Unary;             // UNARY_OPERATORS type
    int param_no;              // NUMBER_OF_PARAMETERS type
    Express* exp;              // EXPRESSION type
    statement* stmt;           // STATEMENT type
    Symbol_Object* smb;        // SYMBOL type
    Type_of_Symbol_* smb_type; // SYMBOL_TYPE type
    array* arr;                // ARRAYS type
}

%token ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN LS_ASSIGN RS_ASSIGN BAND_ASSIGN BXOR_ASSIGN BOR_ASSIGN COMMA HASH
%token AND OR QUESTION COLON SEMICOLON ELLIPSIS 
%token SQUARE_OPEN SQUARE_CLOSE OPEN_PARENTHESIS CLOSE_PARENTHESIS OPEN_CURLY CLOSE_CURLY 
%token LS RS LT GT LE GE EQ NE BXOR BOR 
%token DOT ARROW INC DEC BAND MUL PLUS MINUS BNOR NOT DIV MOD 
%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT FOR GOTO IF INLINE INT LONG REGISTER RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE BOOL COMPLEX IMAGINARY

%start transUnit

%token <charval> FLOATING_CONSTANT

%token <intval> INTEGER_CONSTANT

%token <charval> CHAR_CONSTANT

%token <charval> STRING_LITERAL

%token <smb> IDENTIFIER

%right THEN ELSE    //For fixing the problem of dangling ELSE

%type <op_Unary> unary_operator

%type <param_no> argument_expression_list argument_expression_list_opt

%type <exp> 
        expression primitive_Expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression
        and_expression exclusive_or_expression inclusive_or_expression logical_and_expression logical_or_expression conditional_expression
        assignment_expression expression_statement

%type <stmt>
        statement compound_statement loop_statement selection_statement iteration_statement labeled_statement jump_statement block_item block_item_list
        block_item_list_opt

%type <smb_type> pointer

%type <smb> constant initializer
%type <smb> direct_declarator init_declarator declarator

%type <arr> postfix_expression unary_expression cast_expression

%type <ins_no> BP_HELP     // Auxiliary non-terminal BP_HELP of type ins_no to help in backpatching
%type <stmt> CF_HELP      // Auxiliary non-terminal CF_HELP of type stmt to help in control flow statements

%%

// Rule for primitive expressions
primitive_Expression: 
        IDENTIFIER
        { 
            $$ = new Express();  // Create a new expression object
            $$->type = "non_bool";  // Set the expression type to non-boolean
            $$->marker = $1;        // Set the marker to the identifier's symbol object
        }
        | constant
        {
            $$ = new Express();  // Create a new expression object for constant
            $$->marker = $1;     // Set the marker to the constant's symbol object
        }
        | STRING_LITERAL
        {
            $$ = new Express();  // Create a new expression for string literal
            $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("ptr"), $1);  // Create temporary symbol for string pointer
            $$->marker->type->arrtyp = new Type_of_Symbol_("char");  // Set the type of the temporary symbol to char
        }
        | OPEN_PARENTHESIS expression CLOSE_PARENTHESIS
        {
            $$ = $2;    // Return the expression within parentheses
        }
        ;

// Rule for postfix expressions
postfix_expression: 
        primitive_Expression
        {
            $$ = new array();           // Create a new array object
            $$->arr = $1->marker;       // Store the marker of the primary expression
            $$->type = $1->marker->type; // Update the type based on the primary expression
            $$->marker = $$->arr;       // Set the marker to the array's marker
        }
        | postfix_expression SQUARE_OPEN expression SQUARE_CLOSE
        {
            $$ = new array();               // Create a new array for the indexed expression
            $$->type = $1->type->arrtyp;   // Set the type to the element type of the array
            $$->arr = $1->arr;             // Copy the base of the array
            $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int"));  // Create a temporary symbol for the index
            $$->artp = "arr";              // Set artp to "arr"

            if($1->artp == "arr") {        // If the base type is an array
                Symbol_Object* sym = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int")); // Temporary symbol for size calculation
                int sz = type_size($$->type); // Get the size of the array type
                emit("*", sym->name, $3->marker->name, intos(sz)); // Emit multiplication for index calculation
                emit("+", $$->marker->name, $1->marker->name, sym->name); // Emit addition to get the final address
            }
            else {                          
                int sz = type_size($$->type); // Get the size of the element type
                emit("*", $$->marker->name, $3->marker->name, intos(sz)); // Emit multiplication for index calculation
            }
        }
        | postfix_expression OPEN_PARENTHESIS argument_expression_list_opt CLOSE_PARENTHESIS
        {   
            // Handle function call with appropriate arguments
            $$ = new array();  
            $$->arr = Table_of_Symbols::tempSymFactory($1->type); // Create a temporary symbol for the function call
            emit("call", $$->arr->name, $1->arr->name, intos($3)); // Emit the function call
        }
        | postfix_expression DOT IDENTIFIER
        { 
            // Ignore dot operator in this context
        }
        | postfix_expression ARROW IDENTIFIER
        { 
            // Ignore arrow operator in this context
        }
        | postfix_expression INC
        {   
            $$ = new array();  // Create a new array for increment
            $$->arr = Table_of_Symbols::tempSymFactory($1->arr->type); // Create a temporary symbol for the incremented value
            emit("=", $$->arr->name, $1->arr->name); // Assign the old value to the temporary
            emit("+", $1->arr->name, $1->arr->name, "1"); // Increment the value
        }
        | postfix_expression DEC
        {
            $$ = new array();  // Create a new array for decrement
            $$->arr = Table_of_Symbols::tempSymFactory($1->arr->type); // Create a temporary symbol for the decremented value
            emit("=", $$->arr->name, $1->arr->name); // Assign the old value to the temporary
            emit("-", $1->arr->name, $1->arr->name, "1"); // Decrement the value
        }
        | OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS OPEN_CURLY initializer_list CLOSE_CURLY
        { 
            // Ignore this syntax in the current context
        }
        | OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS OPEN_CURLY initializer_list COMMA CLOSE_CURLY
        { 
            // Ignore this syntax in the current context
        }
        ;

// Rule for argument expression lists
argument_expression_list: 
        assignment_expression
        {
            $$ = 1;                        // One argument counted
            emit("param", $1->marker->name); // Emit the parameter for the argument
        }
        | argument_expression_list COMMA assignment_expression
        {
            $$ = $1 + 1;                   // Increment argument count
            emit("param", $3->marker->name); // Emit the parameter for the argument
        }
        ;

// Rule for cast expressions
cast_expression: 
        unary_expression
        {
            $$ = $1;    // Direct assignment for unary expressions
        }
        | OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS cast_expression
        { 
            // Handle cast operation
            $$ = new array();
            $$->arr = type_CONVERSION_function($4->arr, v_typ); //  
        }
        ;

constant: 
        INTEGER_CONSTANT
        {
            // Create a new temporary symbol for an integer constant and store its value
            $$ = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int"), intos($1));   
            emit("=", $$->name, $1);  // Emit an assignment operation
        }
        | FLOATING_CONSTANT
        {
            // Create a new temporary symbol for a floating constant and store its value
            $$ = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("float"), string($1));     
            emit("=", $$->name, string($1));  // Emit an assignment operation
        }
        | CHAR_CONSTANT
        {
            // Create a new temporary symbol for a character constant and store its value
            $$ = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("float"), string($1));     
            emit("=", $$->name, string($1));  // Emit an assignment operation
        }
        ;

unary_expression: 
        postfix_expression
        {
            $$ = $1;    // Assign the result of the postfix expression to the unary expression
        }
        | INC unary_expression
        {
            emit("+", $2->arr->name, $2->arr->name, "1");   // Increment the value by 1
            $$ = $2;    // Assign the incremented value back to $$ 
        }
        | DEC unary_expression
        {
            emit("-", $2->arr->name, $2->arr->name, "1");   // Decrement the value by 1
            $$ = $2;    // Assign the decremented value back to $$
        }
        | unary_operator cast_expression
        {
            // Handle the application of a unary operator
            $$ = new array();  // Create a new array to hold the result
            switch($1) {  // Check which unary operator is being applied
                case '&':   // Address-of operator
                    $$->arr = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("ptr"));    // Generate a pointer temporary
                    $$->arr->type->arrtyp = $2->arr->type;  // Assign the corresponding type to the pointer
                    emit("= &", $$->arr->name, $2->arr->name);  // Emit an operation for taking the address
                    break;
                case '*':   // De-reference operator
                    $$->artp = "ptr";  // Set the artp to "ptr"
                    $$->marker = Table_of_Symbols::tempSymFactory($2->arr->type->arrtyp);   // Generate a temporary of the appropriate type
                    $$->arr = $2->arr;  // Assign the array
                    emit("= *", $$->marker->name, $2->arr->name);  // Emit an operation for de-referencing
                    break;
                case '+':   // Unary plus (no effect)
                    $$ = $2;    // Simply assign the cast expression
                    break;
                case '-':   // Unary minus (negation)
                    $$->arr = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_($2->arr->type->type));  // Generate temporary of the same base type
                    emit("= -", $$->arr->name, $2->arr->name);  // Emit an operation for negation
                    break;
                case '~':   // Bitwise NOT operator
                    $$->arr = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_($2->arr->type->type));  // Generate temporary of the same base type
                    emit("= ~", $$->arr->name, $2->arr->name);  // Emit an operation for bitwise NOT
                    break;
                case '!':   // Logical NOT operator
                    $$->arr = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_($2->arr->type->type));  // Generate temporary of the same base type
                    emit("= !", $$->arr->name, $2->arr->name);  // Emit an operation for logical NOT
                    break;
            }
        }
        | SIZEOF unary_expression
        { 
            // The SIZEOF unary operator is ignored in this case
        }
        | SIZEOF OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS
        { 
            // The SIZEOF operator with a type name is also ignored
        }
        ;

unary_operator:
        BAND  // Bitwise AND operator
        {
            $$ = '&';  // Assign the symbol for the operator
        }
        | MUL  // Dereference operator
        {
            $$ = '*';  // Assign the symbol for the operator
        }
        | PLUS  // Unary plus operator
        {
            $$ = '+';  // Assign the symbol for the operator
        }
        | MINUS  // Unary minus operator
        {
            $$ = '-';  // Assign the symbol for the operator
        }
        | BNOR  // Bitwise NOT operator
        {
            $$ = '~';  // Assign the symbol for the operator
        }
        | NOT  // Logical NOT operator
        {
            $$ = '!';  // Assign the symbol for the operator
        }
        ;

argument_expression_list_opt: 
        argument_expression_list
        {
            $$ = $1;    // Assign the argument expression list to $$
        }
        | 
        {
            $$ = 0;     // No arguments present, assign zero
        }
        ;
shift_expression: 
        additive_expression
        {
            $$ = $1;    // Simple assignment of the additive expression
        }
        | shift_expression LS additive_expression
        {
            // Handle left shift operation
            if($3->marker->type->type == "int") {  // Check if type is compatible (must be int)
                $$ = new Express();  // Create a new expression
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int"));  // Generate a new temporary
                emit("<<", $$->marker->name, $1->marker->name, $3->marker->name);  // Emit the left shift operation
            }
            else {
                yyerror("Type Error");  // Raise a type error if types are incompatible
            }
        }
        | shift_expression RS additive_expression
        {
            // Handle right shift operation
            if($3->marker->type->type == "int") {  // Check if type is compatible (must be int)
                $$ = new Express();  // Create a new expression
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int"));  // Generate a new temporary
                emit(">>", $$->marker->name, $1->marker->name, $3->marker->name);  // Emit the right shift operation
            }
            else {
                yyerror("Type Error");  // Raise a type error if types are incompatible
            }
        }
        ;
additive_expression: 
        multiplicative_expression
        {
            $$ = $1;    // Simple assignment of the multiplicative expression
        }
        | additive_expression PLUS multiplicative_expression
        {   
            // Handle addition operation
            if(is_type_correct($1->marker, $3->marker)) {  // Check for type compatibility
                $$ = new Express();  // Create a new expression
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_($1->marker->type->type));  // Generate a new temporary
                emit("+", $$->marker->name, $1->marker->name, $3->marker->name);  // Emit the addition operation
            }
            else {
                yyerror("Type Error");  // Raise a type error if types are incompatible
            }
        }
        | additive_expression MINUS multiplicative_expression
        {
            // Handle subtraction operation
            if(is_type_correct($1->marker, $3->marker)) {  // Check for type compatibility
                $$ = new Express();  // Create a new expression
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_($1->marker->type->type));  // Generate a new temporary
                emit("-", $$->marker->name, $1->marker->name, $3->marker->name);  // Emit the subtraction operation
            }
            else {
                yyerror("Type Error");  // Raise a type error if types are incompatible
            }
        }
        ;

relational_expression: 
        shift_expression
        {
            $$ = $1;    // Simple assignment of the shift expression
        }
        | relational_expression LT shift_expression
        {
            // Handle less-than operation
            if(is_type_correct($1->marker, $3->marker)) {  // Check for type compatibility
                $$ = new Express();  // Create a new expression of type bool
                $$->type = "bool";  // Set type to bool
                $$->true_lst = createNewList(next_instruction());  // Create a true list for the boolean expression
                $$->false_lst = createNewList(next_instruction() + 1);  // Create a false list for the boolean expression
                emit("<", "", $1->marker->name, $3->marker->name);  // Emit the less-than operation
                emit("goto", "");  // Emit the next instruction as a goto
            }
            else {
                yyerror("Type Error");  // Raise a type error if types are incompatible
            }
        }
        | relational_expression GT shift_expression
        {
            // Handle greater-than operation
            if(is_type_correct($1->marker, $3->marker)) {  // Check for type compatibility
                $$ = new Express();  // Create a new expression of type bool
                $$->type = "bool";  // Set type to bool
                $$->true_lst = createNewList(next_instruction());  // Create a true list for the boolean expression
                $$->false_lst = createNewList(next_instruction() + 1);  // Create a false list for the boolean expression
                emit(">", "", $1->marker->name, $3->marker->name);  // Emit the greater-than operation
                emit("goto", "");  // Emit the next instruction as a goto
            }
            else {
                yyerror("Type Error");  // Raise a type error if types are incompatible
            }
        }
        | relational_expression LE shift_expression // Indicates less than or equal to
        {
            if(is_type_correct($1->marker, $3->marker)) {                   // Check for type compatibility
                $$ = new Express();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->true_lst = createNewList(next_instruction());           // Create true_lst for boolean expression
                $$->false_lst = createNewList(next_instruction() + 1);      // Create false_lst for boolean expression
                emit("<=", "", $1->marker->name, $3->marker->name);   // Emit "if x <= y goto ..."
                emit("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        | relational_expression GE shift_expression // Indicates greater than or equal to
        {
            if(is_type_correct($1->marker, $3->marker)) {                   // Check for type compatibility
                $$ = new Express();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->true_lst = createNewList(next_instruction());           // Create true_lst for boolean expression
                $$->false_lst = createNewList(next_instruction() + 1);      // Create false_lst for boolean expression
                emit(">=", "", $1->marker->name, $3->marker->name);   // Emit "if x >= y goto ..."
                emit("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

multiplicative_expression: 
        cast_expression // Indicates cast expression
        {
            $$ = new Express();          // Generate new expression
            if($1->artp == "arr") {        // artp "arr"
                $$->marker = Table_of_Symbols::tempSymFactory($1->marker->type);  // Generate new temporary
                emit("=[]", $$->marker->name, $1->arr->name, $1->marker->name);     // Emit the quad
            }
            else if($1->artp == "ptr") {   // artp "ptr"
                $$->marker = $1->marker;          // Assign the Symbol_Object table entry
            }
            else {
                $$->marker = $1->arr;
            }
        }
        | multiplicative_expression MUL cast_expression // Indicates multiplication
        {   
            if(is_type_correct($1->marker, $3->arr)) {     // Check for type compatibility
                $$ = new Express();                                                  // Generate new expression
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_($1->marker->type->type));    // Generate new temporary
                emit("*", $$->marker->name, $1->marker->name, $3->arr->name);                 // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | multiplicative_expression DIV cast_expression // Indicates division
        {
            if(is_type_correct($1->marker, $3->arr)) {     // Check for type compatibility
                $$ = new Express();                                                  // Generate new expression
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_($1->marker->type->type));    // Generate new temporary
                emit("/", $$->marker->name, $1->marker->name, $3->arr->name);               // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | multiplicative_expression MOD cast_expression // Indicates modulo
        {
            if(is_type_correct($1->marker, $3->arr)) {     // Check for type compatibility
                $$ = new Express();                                                  // Generate new expression
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_($1->marker->type->type));    // Generate new temporary
                emit("%", $$->marker->name, $1->marker->name, $3->arr->name);               // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

equality_expression: 
        relational_expression
        {
            $$ = $1;    // Simple assignment of the relational expression
        }
        | equality_expression EQ relational_expression
        {
            // Handle equality operation
            if(is_type_correct($1->marker, $3->marker)) {  // Check for type compatibility
                converting_Bool_Int($1);                           // Convert bool to int
                converting_Bool_Int($3);
                $$ = new Express();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->true_lst = createNewList(next_instruction());           // Create true_lst for boolean expression
                $$->false_lst = createNewList(next_instruction() + 1);      // Create false_lst for boolean expression
                emit("==", "", $1->marker->name, $3->marker->name);   // Emit "if x == y goto ..."
                emit("goto", "");     
            }
            else {
                yyerror("Type Error");  // Raise a type error if types are incompatible
            }
        }
        | equality_expression NE relational_expression
        {
            // Handle inequality operation
            if(is_type_correct($1->marker, $3->marker)) {  // Check for type compatibility
                converting_Bool_Int($1);                           // Convert bool to int
                converting_Bool_Int($3);
                $$ = new Express();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->true_lst = createNewList(next_instruction());           // Create true_lst for boolean expression
                $$->false_lst = createNewList(next_instruction() + 1);      // Create false_lst for boolean expression
                emit("!=", "", $1->marker->name, $3->marker->name);   // Emit "if x != y goto ..."
                emit("goto", "");
            }
            else {
                yyerror("Type Error");  // Raise a type error if types are incompatible
            }
        }
        ;

and_expression: 
        equality_expression
        {
            $$ = $1;    // Simple assignment
        }
        | and_expression BAND equality_expression
        {
            if(is_type_correct($1->marker, $3->marker)) {
                converting_Bool_Int($1);  // Convert bool to int
                converting_Bool_Int($3);  // Convert bool to int
                $$ = new Express();  // New Expression
                $$->type = "not_bool"; // The new result is not bool
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int"));  // Create a new temporary
                emit("&", $$->marker->name, $1->marker->name, $3->marker->name); // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

logical_and_expression: 
        inclusive_or_expression
        {
            $$ = $1;    // Simple assignment of the equality expression
        }
        | logical_and_expression AND BP_HELP inclusive_or_expression
        {
            // Handle logical AND operation
            Expr_Bool($1);
            Expr_Bool($4);
            $$ = new Express();  // Create a new expression of type bool
            $$->type = "bool";  // Set type to bool
            Back_patching($1->true_lst, $3);
            $$->true_lst = $4->true_lst;                            // Generate true_lst from true_lst of $4
            $$->false_lst = merge($1->false_lst, $4->false_lst);    // Generate false_lst by merging the falselists of $1 and $4
        }
        ;

inclusive_or_expression: 
        exclusive_or_expression
        {
            $$ = $1;    // Simple assignment
        }
        | inclusive_or_expression BOR exclusive_or_expression
        {
            if(is_type_correct($1->marker, $3->marker)) {                            
                converting_Bool_Int($1); // Convert bool to int
                converting_Bool_Int($3);
                $$ = new Express();
                $$->type = "not_bool";                                      // The new result is not bool
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int"));      // Create a new temporary
                emit("|", $$->marker->name, $1->marker->name, $3->marker->name);     // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

exclusive_or_expression: 
        and_expression
        {
            $$ = $1;    // Simple assignment
        }
        | exclusive_or_expression BXOR and_expression
        {
            if(is_type_correct($1->marker, $3->marker)) {                               
                converting_Bool_Int($1); // Convert bool to int
                converting_Bool_Int($3); // Convert bool to int
                $$ = new Express(); // New Expression
                $$->type = "not_bool"; // The new result is not bool
                $$->marker = Table_of_Symbols::tempSymFactory(new Type_of_Symbol_("int")); // Create a new temporary
                emit("^", $$->marker->name, $1->marker->name, $3->marker->name); // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;


logical_or_expression: 
        logical_and_expression
        {
            $$ = $1;    // Simple assignment of the logical AND expression
        }
        | logical_or_expression OR BP_HELP logical_and_expression
        {
            // Handle logical OR operation
            Expr_Bool($1);                                   // Convert the expressions from int to bool
            Expr_Bool($4);
            $$ = new Express();                                  // Create a new bool expression for the result
            $$->type = "bool";
            Back_patching($1->false_lst, $3);                           // Backpatching
            $$->false_lst = $4->false_lst;                          // Generate false_lst from false_lst of $4
            $$->true_lst = merge($1->true_lst, $4->true_lst);       // Generate true_lst by merging the truelists of $1 and $4
        }
        ;
conditional_expression:
        logical_or_expression
        {
            $$ = $1;    // Simple assignment of the logical OR expression
        }
        | logical_or_expression CF_HELP QUESTION BP_HELP expression CF_HELP COLON BP_HELP conditional_expression
        {   
            /*
                Note the augmented grammar with the non-terminals BP_HELP and CF_HELP
                This structure handles the conditional (ternary) operator.
            */
            $$->marker = Table_of_Symbols::tempSymFactory($5->marker->type);      // Generate temporary for the expression
            $$->marker->update($5->marker->type);  // Update the type of the temporary marker
            emit("=", $$->marker->name, $9->marker->name);  // Assign the conditional expression result
            list<int> l1 = createNewList(next_instruction());  // Create a new instruction list for the true branch
            emit("goto", "");  // Emit a goto to prevent fall-through
            Back_patching($6->nxt_lst, next_instruction());  // Backpatch the next instruction list
            emit("=", $$->marker->name, $5->marker->name);  // Assign the false expression to the temporary marker
            list<int> l2 = createNewList(next_instruction());  // Create another new instruction list for the false branch
            l1 = merge(l1, l2);  // Merge the two lists of instructions
            emit("goto", "");  // Emit a goto to prevent fall-through again
            Back_patching($2->nxt_lst, next_instruction());  // Backpatching the next instruction list for control flow
            Expr_Bool($1);  // Convert the logical expression to a boolean expression
            Back_patching($1->true_lst, $4);  // If $1 is true, control goes to the expression $4
            Back_patching($1->false_lst, $8);  // If $1 is false, control goes to the conditional expression $8
            Back_patching(l1, next_instruction());  // Final backpatching of the merged instruction list
        }
        
        ;

CF_HELP: 
        {
            // Helps in control flow by creating a statement with a next instruction list
            $$ = new statement();  
            $$->nxt_lst = createNewList(next_instruction());  // Initialize the next instruction list
            emit("goto", "");  // Emit a goto to prepare for backpatching
        }
        ;

BP_HELP: 
        {   
            // Stores the next instruction value to assist in backpatching
            $$ = next_instruction();  // Capture the current instruction number
        }
        ;

assignment_operator: 
        ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | MUL_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | DIV_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | MOD_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | ADD_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | SUB_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | LS_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | RS_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | BAND_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | BXOR_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        | BOR_ASSIGN
        { /* Ignored - treated as part of assignment expression */ }
        ;

constant_expression: 
        conditional_expression
        { /* Ignored - treated as part of expression evaluation */ }
        ;

declStmt: 
        declaration_specifiers init_declarator_list SEMICOLON
        { /* Ignored - declaration statements handled here */ }
        | declaration_specifiers SEMICOLON
        { /* Ignored - declaration statements without initializers */ }
        ;

declaration_specifiers: 
        storage_class_specifier declaration_specifiers
        { /* Ignored - part of the declaration specification */ }
        | storage_class_specifier
        { /* Ignored - part of the declaration specification */ }
        | type_specifier declaration_specifiers
        { /* Ignored - part of the declaration specification */ }
        | type_specifier
        { /* Ignored - part of the declaration specification */ }
        | type_qualifier declaration_specifiers
        { /* Ignored - part of the declaration specification */ }
        | type_qualifier
        { /* Ignored - part of the declaration specification */ }
        | function_specifier declaration_specifiers
        { /* Ignored - part of the declaration specification */ }
        | function_specifier
        { /* Ignored - part of the declaration specification */ }
        ;

init_declarator_list: 
        init_declarator
        { /* Ignored - part of initialization declaration */ }
        | init_declarator_list COMMA init_declarator
        { /* Ignored - part of initialization declaration */ }
        ;

assignment_expression: 
        conditional_expression
        {
            $$ = $1;    // Simple assignment of the conditional expression
        }
        | unary_expression assignment_operator assignment_expression
        {
            // Handle assignment with potential type conversion
            if($1->artp == "arr") {  // If the first operand is an array
                $3->marker = type_CONVERSION_function($3->marker, $1->type->type);  // Convert type
                emit("[]=", $1->arr->name, $1->marker->name, $3->marker->name);  // Emit array assignment
            }
            else if($1->artp == "ptr") {  // If the first operand is a pointer
                emit("*=", $1->arr->name, $3->marker->name);  // Emit pointer assignment
            }
            else {
                $3->marker = type_CONVERSION_function($3->marker, $1->arr->type->type);  // Convert type
                emit("=", $1->arr->name, $3->marker->name);  // Emit standard assignment
            }
            $$ = $3;  // Return the assignment expression
        }
        ;

init_declarator: 
        declarator
        {
            $$ = $1;  // Simple assignment of the declarator
        }
        | declarator ASSIGN initializer
        {   
            // Find out the initial value and emit assignment
            if($3->val != "") {  // Check if the initializer has a value
                $1->val = $3->val;  // Store the value in the declarator
            }
            emit("=", $1->name, $3->name);  // Emit the assignment operation
        }
        ;

storage_class_specifier: 
        EXTERN
        { /* Ignored - part of storage class specifiers */ }
        | STATIC
        { /* Ignored - part of storage class specifiers */ }
        | AUTO
        { /* Ignored - part of storage class specifiers */ }
        | REGISTER
        { /* Ignored - part of storage class specifiers */ }
        ;

expression: 
        assignment_expression
        {
            $$ = $1;  // Simple assignment of the assignment expression
        }
        | expression COMMA assignment_expression
        { /* Ignored - handle comma-separated expressions */ }
        ;

type_specifier: 
        VOID
        {
            v_typ = "void";   // Store the latest encountered type as "void"
        }
        | CHAR
        {
            v_typ = "char";   // Store the latest encountered type as "char"
        }
        | SHORT
        { /* Ignored - short type is not stored */ }
        | INT
        {
            v_typ = "int";    // Store the latest encountered type as "int"
        }
        | LONG
        { /* Ignored - long type is not stored */ }
        | FLOAT
        {
            v_typ = "float";  // Store the latest encountered type as "float"
        }
        | DOUBLE
        { /* Ignored - double type is not stored */ }
        | SIGNED
        { /* Ignored - signed type is not stored */ }
        | UNSIGNED
        { /* Ignored - unsigned type is not stored */ }
        | BOOL
        { /* Ignored - bool type is not stored */ }
        | COMPLEX
        { /* Ignored - complex type is not stored */ }
        | IMAGINARY
        { /* Ignored - imaginary type is not stored */ }
        | enum_specifier
        { /* Ignored - enumeration type is handled separately */ }
        ;

specifier_qualifier_list: 
        type_specifier specifier_qualifier_list_opt
        { /* Ignored - specifier and qualifier list can have multiple types */ }
        | type_qualifier specifier_qualifier_list_opt
        { /* Ignored - qualifier can also precede specifiers */ }
        ;

specifier_qualifier_list_opt: 
        specifier_qualifier_list
        { /* Ignored - allows for an optional specifier and qualifier list */ }
        | 
        { /* Ignored - empty list is also valid */ }
        ;

enum_specifier: 
        ENUM identifier_opt OPEN_CURLY enumerator_list CLOSE_CURLY
        { /* Ignored - handle enumeration definitions */ }
        | ENUM identifier_opt OPEN_CURLY enumerator_list COMMA CLOSE_CURLY
        { /* Ignored - handles trailing comma in enum */ }
        | ENUM IDENTIFIER
        { /* Ignored - simple enum declaration */ }
        ;

enumerator_list: 
        enumerator
        {/* Ignored - at least one enumerator is required */}
        | enumerator_list COMMA enumerator
        {/* Ignored - allows for multiple enumerators separated by commas */}
        ;

enumerator: 
        IDENTIFIER
        {/* Ignored - define enumerator without assignment */}
        | IDENTIFIER ASSIGN constant_expression
        {/* Ignored - define enumerator with an assigned value */}
        ;

type_qualifier: 
        CONST
        {/* Ignored - const qualifier is not processed further */}
        | RESTRICT
        {/* Ignored - restrict qualifier is not processed further */}
        | VOLATILE
        {/* Ignored - volatile qualifier is not processed further */}
        ;

function_specifier: 
        INLINE
        {/* Ignored - inline specifier is not processed further */}
        ;

declarator: 
        pointer direct_declarator
        {
            Type_of_Symbol_* t = $1;  // Begin with the pointer type
            // Traverse through multi-dimensional arrays to find the base type
            while(t->arrtyp != NULL) {
                t = t->arrtyp;  // Move down the hierarchy to find the base type
            }
            t->arrtyp = $2->type;  // Assign the base type to the array type
            $$ = $2->update($1);   // Update the symbol with the new type
        }
        | direct_declarator
        { /* Ignored - simple declarator without pointer */ }
        ;

direct_declarator: 
        IDENTIFIER
        { 
            $$ = $1->update(new Type_of_Symbol_(v_typ));   // Update identifier type to v_typ
            symInstance = $$;                         // Update pointer to current Symbol_Object
        }
        | OPEN_PARENTHESIS declarator CLOSE_PARENTHESIS // Declarator wrapped in parentheses
        {
            $$ = $2;    // Simple assignment, return the inner declarator
        }
        | direct_declarator SQUARE_OPEN type_qualifier_list assignment_expression SQUARE_CLOSE // Array declaration with type qualifiers
        { // Ignored
        }
        | direct_declarator SQUARE_OPEN type_qualifier_list SQUARE_CLOSE // Array declaration with type qualifiers, no assignment
        { // Ignored 
        }
        | direct_declarator SQUARE_OPEN assignment_expression SQUARE_CLOSE // Array declaration with size determined by assignment expression
        {
            Type_of_Symbol_* t = $1->type;  // Get the current type
            Type_of_Symbol_* prev = NULL;    // Track the previous type for array dimensions
            // Recursively find the base type
            while(t->type == "arr") {
                prev = t;   // Keep track of the previous array type
                t = t->arrtyp;  // Move to the next type
            }
            if(prev == NULL) {
                int temp = atoi($3->marker->val.c_str());  // Convert assignment expression to int
                Type_of_Symbol_* tp = new Type_of_Symbol_("arr", $1->type, temp); // Create new array type
                $$ = $1->update(tp);  // Update the Symbol_Object table for this Symbol_Object
            }
            else {
                int temp = atoi($3->marker->val.c_str());  // Convert assignment expression to int
                prev->arrtyp = new Type_of_Symbol_("arr", t, temp); // Create new array type linked to previous
                $$ = $1->update($1->type);  // Update the Symbol_Object table for this Symbol_Object
            }
        }
        | direct_declarator SQUARE_OPEN SQUARE_CLOSE // Array declaration with unspecified size
        {
            Type_of_Symbol_* t = $1->type;  // Get the current type
            Type_of_Symbol_* prev = NULL;    // Track the previous type for array dimensions
            // Recursively find the base type
            while(t->type == "arr") {
                prev = t;   // Keep track of the previous array type
                t = t->arrtyp;  // Move to the next type
            }
            if(prev == NULL) {
                Type_of_Symbol_* tp = new Type_of_Symbol_("arr", $1->type, 0); // Create new array type with zero size
                $$ = $1->update(tp);  // Update the Symbol_Object table for this Symbol_Object
            }
            else {
                prev->arrtyp = new Type_of_Symbol_("arr", t, 0); // Create new array type linked to previous
                $$ = $1->update($1->type);  // Update the Symbol_Object table for this Symbol_Object
            }
        }
        | direct_declarator SQUARE_OPEN STATIC type_qualifier_list assignment_expression SQUARE_CLOSE
        { /* Ignored - handles static arrays */ }
        | direct_declarator SQUARE_OPEN STATIC assignment_expression SQUARE_CLOSE
        { /* Ignored - handles static arrays */ }
        | direct_declarator SQUARE_OPEN type_qualifier_list STATIC assignment_expression SQUARE_CLOSE
        { /* Ignored - handles static arrays */ }
        | direct_declarator SQUARE_OPEN type_qualifier_list MUL SQUARE_CLOSE
        { /* Ignored - handles pointer to array */ }
        | direct_declarator SQUARE_OPEN MUL SQUARE_CLOSE
        { /* Ignored - handles pointer to array */ }
        | direct_declarator OPEN_PARENTHESIS change_table parameter_type_list CLOSE_PARENTHESIS
        {
            symbol_Registory->name = $1->name;  // Store the function name
            if($1->type->type != "void") {
                Symbol_Object* s = symbol_Registory->lookup("return");  // Lookup for the return type
                s->update($1->type);  // Update return type
            }
            $1->nestedSymTable = symbol_Registory;  // Set the nested symbol table
            symbol_Registory->par = global_symbol_Registory;   // Update parent Symbol_Object table
            alt_table(global_symbol_Registory);  // Switch to the global symbol table
            symInstance = $$;  // Update current Symbol_Object
        }
        | direct_declarator OPEN_PARENTHESIS identifier_list CLOSE_PARENTHESIS
        { /* Ignored - function declaration with identifier list */ }
        | direct_declarator OPEN_PARENTHESIS change_table CLOSE_PARENTHESIS
        {
            symbol_Registory->name = $1->name;  // Store the function name
            if($1->type->type != "void") {
                Symbol_Object* s = symbol_Registory->lookup("return");  // Lookup for the return type
                s->update($1->type);  // Update return type
            }
            $1->nestedSymTable = symbol_Registory;  // Set the nested symbol table
            symbol_Registory->par = global_symbol_Registory;   // Update parent Symbol_Object table
            alt_table(global_symbol_Registory);  // Switch to the global symbol table
            symInstance = $$;  // Update current Symbol_Object
        }
        ;

type_qualifier_list_opt: 
        type_qualifier_list
        { /* Ignored - allows for an optional list of qualifiers */ }
        | 
        { /* Ignored - empty qualifier list is also valid */ }
        ;
pointer: 
        MUL type_qualifier_list_opt
        {
            $$ = new Type_of_Symbol_("ptr");     // Create a new type "ptr" indicating a pointer
        }
        | MUL type_qualifier_list_opt pointer
        {
            $$ = new Type_of_Symbol_("ptr", $3); // Create a new type "ptr" that points to another pointer type
        }
        ;

type_qualifier_list: 
        type_qualifier
        { /* Ignored - allows a single type qualifier */ }
        | type_qualifier_list type_qualifier
        { /* Ignored - allows multiple type qualifiers */ }
        ;

identifier_opt: 
        IDENTIFIER
        {/* Ignored - optional identifier for declarations */ }
        | 
        {/* Ignored - empty option is valid */ }
        ;

parameter_type_list: 
        parameter_list
        { /* Ignored - list of parameters for function definitions */ }
        | parameter_list COMMA ELLIPSIS
        { /* Ignored - allows for variable-length argument lists */ }
        ;

parameter_declaration: 
        declaration_specifiers declarator
        { /* Ignored - handles parameter declarations with type and name */ }
        | declaration_specifiers
        { /* Ignored - handles parameter declarations without specific names */ }
        ;

identifier_list: 
        IDENTIFIER
        { /* Ignored - a single identifier */ }
        | identifier_list COMMA IDENTIFIER
        { /* Ignored - multiple identifiers separated by commas */ }
        ;

parameter_list: 
        parameter_declaration
        { /* Ignored - at least one parameter is required */ }
        | parameter_list COMMA parameter_declaration
        { /* Ignored - allows multiple parameters separated by commas */ }
        ;

type_name: 
        specifier_qualifier_list
        { /* Ignored - represents type names with qualifiers */ }
        ;

initializer: 
        assignment_expression
        {
            $$ = $1->marker;   // Simple assignment expression, returns the assignment marker
        }
        | OPEN_CURLY initializer_list CLOSE_CURLY
        { /* Ignored - handles initializer lists in curly braces */ }
        | OPEN_CURLY initializer_list COMMA CLOSE_CURLY
        { /* Ignored - handles initializer lists with trailing commas */ }
        ;

initializer_list: 
        designation_opt initializer
        { /* Ignored - optional designation followed by an initializer */ }
        | initializer_list COMMA designation_opt initializer
        { /* Ignored - allows multiple initializers separated by commas */ }
        ;

designation: 
        designator_list ASSIGN
        { /* Ignored - defines a designation for an initializer */ }
        ;

designator_list: 
        designator
        { /* Ignored - single designator */ }
        | designator_list designator
        { /* Ignored - allows for multiple designators */ }
        ;

designation_opt: 
        designation
        { /* Ignored - optional designation */ }
        | 
        { /* Ignored - empty designation is valid */ }
        ;

designator: 
        SQUARE_OPEN constant_expression SQUARE_CLOSE
        { /* Ignored - array subscript designator */ }
        | DOT IDENTIFIER
        { /* Ignored - structure member designator */ }
        ;

statement: 
        labeled_statement
        { /* Ignored - handles labeled statements */ }
        | compound_statement
        {
            $$ = $1;    // Assigns the compound statement to the result
        }
        | expression_statement
        {
            $$ = new statement();           // Create a new statement object
            $$->nxt_lst = $1->nxt_lst;    // Link to the next statement in the list
        }
        | selection_statement
        {
            $$ = $1;    // Assigns the selection statement to the result
        }
        | iteration_statement
        {
            $$ = $1;    // Assigns the iteration statement to the result
        }
        | jump_statement
        {
            $$ = $1;    // Assigns the jump statement to the result
        }
        ;

/* New non-terminal added to facilitate the structure of labeled statements */
labeled_statement: 
        IDENTIFIER COLON statement
        { /* Ignored - defines a labeled statement */ }
        | CASE constant_expression COLON statement
        { /* Ignored - defines a case statement */ }
        | DEFAULT COLON statement
        { /* Ignored - defines a default case statement */ }
        ;

loop_statement:
        labeled_statement
        { /* Ignored - allows labeled loop statements */ }
        | expression_statement
        {
            $$ = new statement();           // Create a new statement object for loop body
            $$->nxt_lst = $1->nxt_lst;    // Link to the next statement in the list
        }
        | selection_statement
        {
            $$ = $1;    // Assigns the selection statement to the result
        }
        | iteration_statement
        {
            $$ = $1;    // Assigns the iteration statement to the result
        }
        | jump_statement
        {
            $$ = $1;    // Assigns the jump statement to the result
        }
        ;

block_item_list_opt: 
        block_item_list
        {
            $$ = $1;    // Assigns the block item list to the result
        }
        | 
        {
            $$ = new statement();   // Create a new statement if no items are present
        }
        ;

compound_statement: 
        OPEN_CURLY X change_table block_item_list_opt CLOSE_CURLY
        {
            /*
                The grammar includes non-terminals like X and change_table 
                to facilitate the creation of nested Symbol_Object tables
            */
            $$ = $4;  // Assign the block item list to the result
            alt_table(symbol_Registory->par);     // Update the current Symbol_Object table
        }
        ;

block_item: 
        declStmt
        {
            $$ = new statement();   // Create a new statement object for a declaration
        }
        | statement
        {
            $$ = $1;    // Assigns the statement to the result
        }
        ;

block_item_list: 
        block_item
        {
            $$ = $1;    // Assigns the first block item to the result
        }
        | block_item_list BP_HELP block_item
        {   
            /*
                This production rule uses the non-terminal BP_HELP 
                to manage block items in a list
            */
            $$ = $3;  // Assigns the last block item to the result
            Back_patching($1->nxt_lst, $2);    // Connects the previous items to the new item
        }
        ;

expression_statement: 
        expression SEMICOLON
        {
            $$ = $1;    // Assigns the expression to the result
        }
        | SEMICOLON
        {
            $$ = new Express();  // Creates a new expression object for an empty statement
        }
        ;

selection_statement: 
        IF OPEN_PARENTHESIS expression CF_HELP CLOSE_PARENTHESIS BP_HELP statement CF_HELP %prec THEN
        {
            // Backpatching: nxt_lst of CF_HELP now has next_instruction
            Back_patching($4->nxt_lst, next_instruction());
            Expr_Bool($3); // Convert expression to boolean
            $$ = new statement(); // Create a new statement
            Back_patching($3->true_lst, $6); // Backpatching for true case
            // Merging false_lst of expression, nxt_lst of statement, and nxt_lst of last CF_HELP
            list<int> temp = merge($3->false_lst, $7->nxt_lst);
            $$->nxt_lst = merge($8->nxt_lst, temp);
        }
        | IF OPEN_PARENTHESIS expression CF_HELP CLOSE_PARENTHESIS BP_HELP statement CF_HELP ELSE BP_HELP statement
        {
            // Backpatching: nxt_lst of CF_HELP now has next_instruction
            Back_patching($4->nxt_lst, next_instruction());
            Expr_Bool($3); // Convert expression to boolean
            $$ = new statement(); // Create a new statement
            Back_patching($3->true_lst, $6); // Backpatching for true case
            Back_patching($3->false_lst, $10); // Backpatching for false case
            // Merging nxt_lst of statements and CF_HELP
            list<int> temp = merge($7->nxt_lst, $8->nxt_lst);
            $$->nxt_lst = merge($11->nxt_lst, temp);
        }
        | SWITCH OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement
        { /* Ignored */ }
        ;

iteration_statement: 
        WHILE W OPEN_PARENTHESIS X change_table BP_HELP expression CLOSE_PARENTHESIS BP_HELP loop_statement
        {   
            // Handling control flow and backpatching for WHILE loop
            $$ = new statement(); // Create a new statement
            Expr_Bool($7); // Convert expression to boolean
            Back_patching($10->nxt_lst, $6); // Back to expression after one iteration
            Back_patching($7->true_lst, $9); // Go to loop_statement if true
            $$->nxt_lst = $7->false_lst; // Exit loop if false
            emit("goto", intos($6)); // Prevent fall-through
            block_name = ""; // Reset block name
            alt_table(symbol_Registory->par); // Update symbol table
        }
        | WHILE W OPEN_PARENTHESIS X change_table BP_HELP expression CLOSE_PARENTHESIS OPEN_CURLY BP_HELP block_item_list_opt CLOSE_CURLY
        {
            // Handling control flow and backpatching for WHILE loop with block
            $$ = new statement(); // Create a new statement
            Expr_Bool($7); // Convert expression to boolean
            Back_patching($11->nxt_lst, $6); // Back to expression after one iteration
            Back_patching($7->true_lst, $10); // Go to block if true
            $$->nxt_lst = $7->false_lst; // Exit loop if false
            emit("goto", intos($6)); // Prevent fall-through
            block_name = ""; // Reset block name
            alt_table(symbol_Registory->par); // Update symbol table
        }
        | DO D BP_HELP loop_statement BP_HELP WHILE OPEN_PARENTHESIS expression CLOSE_PARENTHESIS SEMICOLON
        {
            // Handling control flow and backpatching for DO WHILE loop
            $$ = new statement(); // Create a new statement     
            Expr_Bool($8); // Convert expression to boolean
            Back_patching($8->true_lst, $3); // Go back to loop_statement if true
            Back_patching($4->nxt_lst, $5); // Check expression after statement
            $$->nxt_lst = $8->false_lst; // Exit loop if false  
            block_name = ""; // Reset block name
        }
        | DO D OPEN_CURLY BP_HELP block_item_list_opt CLOSE_CURLY BP_HELP WHILE OPEN_PARENTHESIS expression CLOSE_PARENTHESIS SEMICOLON
        {
            // Handling control flow and backpatching for DO WHILE loop with block
            $$ = new statement(); // Create a new statement  
            Expr_Bool($10); // Convert expression to boolean
            Back_patching($10->true_lst, $4); // Go back to block if true
            Back_patching($5->nxt_lst, $7); // Check expression after block completion
            $$->nxt_lst = $10->false_lst; // Exit loop if false  
            block_name = ""; // Reset block name
        }
        | FOR F OPEN_PARENTHESIS X change_table declStmt BP_HELP expression_statement BP_HELP expression CF_HELP CLOSE_PARENTHESIS BP_HELP loop_statement
        {
            // Handling control flow and backpatching for FOR loop
            $$ = new statement(); // Create a new statement
            Expr_Bool($8); // Convert expression to boolean
            Back_patching($8->true_lst, $13); // Go to M3 if true
            Back_patching($11->nxt_lst, $7); // Back to CF_HELP
            Back_patching($14->nxt_lst, $9); // Back to expression after loop_statement
            emit("goto", intos($9)); // Prevent fall-through
            $$->nxt_lst = $8->false_lst; // Exit loop if false
            block_name = ""; // Reset block name
            alt_table(symbol_Registory->par); // Update symbol table
        }
        | FOR F OPEN_PARENTHESIS X change_table expression_statement BP_HELP expression_statement BP_HELP expression CF_HELP CLOSE_PARENTHESIS BP_HELP loop_statement
        {
            // Handling control flow and backpatching for FOR loop with expressions
            $$ = new statement(); // Create a new statement
            Expr_Bool($8); // Convert expression to boolean
            Back_patching($8->true_lst, $13); // Go to M3 if true
            Back_patching($11->nxt_lst, $7); // Back to CF_HELP
            Back_patching($14->nxt_lst, $9); // Back to expression after loop_statement
            emit("goto", intos($9)); // Prevent fall-through
            $$->nxt_lst = $8->false_lst; // Exit loop if false
            block_name = ""; // Reset block name
            alt_table(symbol_Registory->par); // Update symbol table
        }
        | FOR F OPEN_PARENTHESIS X change_table declStmt BP_HELP expression_statement BP_HELP expression CF_HELP CLOSE_PARENTHESIS BP_HELP OPEN_CURLY block_item_list_opt CLOSE_CURLY
        {
            // Handling control flow and backpatching for FOR loop with block
            $$ = new statement(); // Create a new statement
            Expr_Bool($8); // Convert expression to boolean
            Back_patching($8->true_lst, $13); // Go to M3 if true
            Back_patching($11->nxt_lst, $7); // Back to CF_HELP
            Back_patching($15->nxt_lst, $9); // Back to expression after loop_statement
            emit("goto", intos($9)); // Prevent fall-through
            $$->nxt_lst = $8->false_lst; // Exit loop if false
            block_name = ""; // Reset block name
            alt_table(symbol_Registory->par); // Update symbol table
        }
        | FOR F OPEN_PARENTHESIS X change_table expression_statement BP_HELP expression_statement BP_HELP expression CF_HELP CLOSE_PARENTHESIS BP_HELP OPEN_CURLY block_item_list_opt CLOSE_CURLY
        {
            // Handling control flow and backpatching for FOR loop with expressions and block
            $$ = new statement(); // Create a new statement
            Expr_Bool($8); // Convert expression to boolean
            Back_patching($8->true_lst, $13); // Go to M3 if true
            Back_patching($11->nxt_lst, $7); // Back to CF_HELP
            Back_patching($15->nxt_lst, $9); // Back to expression after loop_statement
            emit("goto", intos($9)); // Prevent fall-through
            $$->nxt_lst = $8->false_lst; // Exit loop if false
            block_name = ""; // Reset block name
            alt_table(symbol_Registory->par); // Update symbol table
        }
        ;
W: 
        {
            /*
            This non-terminal indicates the start of a while loop
            */
            block_name = "WHILE";
        }
        ;

F: 
        {   
            /*
            This non-terminal indicates the start of a for loop
            */
            block_name = "FOR";
        }
        ;

D: 
        {
            /*
            This non-terminal indicates the start of a do-while loop
            */
            block_name = "DO_WHILE";
        }
        ;

X: 
        {   
            // Create a new nested Symbol_Object table for nested blocks
            string newST = symbol_Registory->name + "." + block_name + "$" + to_string(symbol_Tally++);  // Generate a unique name for the new Symbol_Object table
            Symbol_Object* sym = symbol_Registory->lookup(newST);  // Lookup the Symbol_Object
            sym->nestedSymTable = new Table_of_Symbols(newST);  // Create a new Symbol_Object table for nested symbols
            sym->name = newST;  // Set the name of the Symbol_Object
            sym->nestedSymTable->par = symbol_Registory;  // Set the parent of the new table to the current symbol registry
            sym->type = new Type_of_Symbol_("block");    // Set the type of the symbol as "block"
            symInstance = sym;    // Update the current Symbol_Object pointer to the new symbol
        }
        ;

jump_statement: 
        GOTO IDENTIFIER SEMICOLON
        { /* Ignored */ }  // No action for GOTO statement
        | CONTINUE SEMICOLON
        {
            $$ = new statement();  // Create a new statement for CONTINUE
        }
        | BREAK SEMICOLON
        {
            $$ = new statement();  // Create a new statement for BREAK
        }
        | RETURN expression SEMICOLON
        {
            $$ = new statement();  // Create a new statement for RETURN with an expression
            emit("return", $2->marker->name);  // Emit a return instruction with the return value
        }
        | RETURN SEMICOLON
        {
            $$ = new statement();  // Create a new statement for RETURN without an expression
            emit("return", "");             // Emit a return instruction without any return value
        }
        ;

external_declaration: 
        function_definition{}  // Handle function definitions
        | declStmt{};  // Handle declaration statements

change_table: 
        {   
            // Change the Symbol_Object table upon encountering functions
            if(symInstance->nestedSymTable != NULL) {  // Check if the nested symbol table exists
                // Switch to the existing nested Symbol_Object table
                alt_table(symInstance->nestedSymTable);
                emit("label", symbol_Registory->name);  // Emit a label for the current symbol registry name
            }
            else {
                // If the nested Symbol_Object table does not exist, create it and switch to it
                alt_table(new Table_of_Symbols(""));  // Create a new table with an empty name
            }
        }
        ;

transUnit: 
        external_declaration{}  // Handle a single external declaration
        | transUnit external_declaration{};  // Handle multiple external declarations

function_definition: 
        declaration_specifiers declarator declaration_list_opt change_table OPEN_CURLY block_item_list_opt CLOSE_CURLY
        {   
            symbol_Registory->par = global_symbol_Registory;  // Set parent to the global symbol registry at the end of a function
            symbol_Tally = 0;  // Reset the symbol tally for local scope
            alt_table(global_symbol_Registory);  // Switch back to the global Symbol_Object table
        };

declaration_list_opt: 
        declaration_list{}  // Handle an optional declaration list
        | {};  // Allow for an empty declaration list

declaration_list: 
        declStmt{}  // Handle a single declaration statement
        | declaration_list declStmt{};  // Handle multiple declaration statements


%%

void yyerror(string s) {
    // Error type
    cout << "ERROR: " << s << endl;
    // Line number
    cout << "At line: " << yylineno << endl;
    // Surroundings
    cout << "Near: " << yytext << endl;
}