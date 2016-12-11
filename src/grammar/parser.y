%{
    #include <string>
    #include <iostream>
    #include <vector>

    using namespace std;

    string program;

    int yyerror(const char *s);
    int yyerror(char *s);
    int yylex(void);

    #define s(s) new string(s)
%}

%define parse.lac full
%define parse.error verbose
%define api.value.type {std::string*}

%token IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN
%token TYPEDEF_NAME ENUMERATION_CONSTANT
%token TYPE
%token BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token IF ELSE WHILE FOR CONTINUE BREAK RETURN

%start  program
%%

program
    : statements { cout << *$1 << endl; }
    ;

statements
    : statement
    | statements statement { $$ = s(*$1 + *$2); }
    ;

statement
    : declaration
    | expression { $$ = s(*$1 + ";"); }
    ;

declaration
    : var_decl
    | func_decl
    ;

declarator
    : type ident { $$ = s(*$1 + " " + *$2); }
    ;

var_decl
    : declarator ';' { $$ = s(*$1 + ";"); }
    | declarator '=' expression ';' { $$ = s(*$1 + " = " + *$3 + ";"); }
    | TYPE ident '=' obj_qual ';' {
        $$ = s("typedef struct " + *$2 + " " + *$4 + " " + *$2 + ";");
    }
    ;

func_decl
    : declarator '(' param_list ')' block { $$ = s(*$1 + "(" + *$3 + ")" + *$5); }
    | declarator '(' ')' block { $$ = s(*$1 + "()" + *$4); }
    ;

param_list
    : declarator
    | param_list ',' declarator { $$ = s(*$1 + ", " + *$3); }
    ;

obj_qual
    : '{' obj_qual_list '}' { $$ = s("{\n" + *$2 + "\n}"); }
    ;

obj_qual_list
    : obj_qual_single
    | obj_qual_list obj_qual_single { $$ = s(*$1 + "\n" + *$2); }
    ;

obj_qual_single
    : declarator ';' { $$ = s(*$1 + ";"); }
    ;

type
    : primitive
    | ident { $$ = s("shared_ptr<" + *$1 + ">"); }
    | type '[' ']' { $$ = s("vector<" + *$1 + ">"); }
    ;

primitive
    : INT
    | FLOAT
    | DOUBLE
    | LONG
    | VOID
    ;

ident
    : IDENTIFIER
    ;

expression
    : assignment_expression
    ;

block
    : '{' statements '}' { $$ = s("{\n" + *$2 + "\n}"); }
    | '{' '}'
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression {
        $$ = s(*$1 + " " + *$2 + " " + *$3);
    }
    ;

assignment_operator
    : '='
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | LEFT_ASSIGN
    | RIGHT_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    | OR_ASSIGN
    ;

unary_expression
    : postfix_expression
    | INC_OP unary_expression { $$ = s(*$1 + *$2); }
    | DEC_OP unary_expression { $$ = s(*$1 + *$2); }
    | unary_operator cast_expression { $$ = s(*$1 + *$2); }
    ;

unary_operator
    : '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'
    ;

cast_expression
    : unary_expression
    | '(' type ')' cast_expression
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression '?' expression ':' conditional_expression
    ;

postfix_expression
    : primary_expression
    | postfix_expression '[' expression ']'
    | postfix_expression '(' ')'
    | postfix_expression '(' argument_expression_list ')'
    | postfix_expression '.' IDENTIFIER
    | postfix_expression INC_OP
    | postfix_expression DEC_OP
    | '{' initializer_list '}'
    | '{' initializer_list ',' '}'
    ;

argument_expression_list
    : expression
    | argument_expression_list ',' expression
    ;

obj_decl
    : '{' obj_decl_list '}' { $$ = s("{\n" + *$2 + "\n}"); }
    ;

obj_decl_list
    : expression
    | obj_decl_list ',' expression { $$ = s(*$1 + " , " + *$3); }
    ;

%%

int yyerror(string s) {
    extern int yylineno;
    extern char *yytext;

    cerr << "Error: " << s << " at symbol \"" << yytext;
    cerr << "\" on line " << yylineno << endl;
    exit(1);
}

int yyerror(const char *s) {
    return yyerror(string(s));
}

int yyerror(char *s) {
    return yyerror(string(s));
}
