%{
    #include <string>
    #include <iostream>
    #include <vector>
    #include <map>

    using namespace std;

    map<string, string> types;
    string program;

    int yyerror(const char *s);
    int yyerror(char *s);
    int yylex(void);

    #define s(s) new string(s)

    string header =
        "#include <iostream>\n"
        "#include <string>\n"
        "#include <vector>\n"
        "#include <map>\n"
        "using namespace std;\n"
        "#define print(a) cout << a << endl;\n\n"
    ;
%}

%define parse.lac full
%define parse.error verbose
%define api.value.type {std::string*}

%token IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN
%token TYPE OTYPE
%token BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token IF ELSE WHILE DO FOR CONTINUE BREAK RETURN

%start program
%%

program
    : declarations { cout << header << *$1 << endl; }
    ;

statements
    : statement
    | statements statement { $$ = s(*$1 + "\n" + *$2); }
    ;

statement
    : declaration
    | block
    | expression_statement
    | conditional
    | iteration
    | jump
    ;

expression_statement
    : expression ';' { $$ = s(*$1 + ";"); }
    | ';'
    ;

conditional
    : IF '(' expression ')' statement ELSE statement { $$ = s("if (" + *$3 + ") " + *$5 + " else " + *$7); }
    | IF '(' expression ')' statement  { $$ = s("if (" + *$3 + ") " + *$5); }
    ;

iteration
    : WHILE '(' expression ')' statement { $$ = s("while (" + *$3 + ") " + *$5); }
    | DO statement WHILE '(' expression ')' ';' { $$ = s("do " + *$2 + " while (" + *$5 + ");"); }
    | FOR '(' expression_statement expression_statement ')' statement {
        $$ = s("for (" + *$3 + " " + *$4 + ") " + *$6);
    }
    | FOR '(' expression_statement expression_statement expression ')' statement {
        $$ = s("for (" + *$3 + " " + *$4 + " " + *$5 + ") " + *$7);
    }
    | FOR '(' declaration expression_statement ')' statement {
        $$ = s("for (" + *$3 + " " + *$4 + ") " + *$6);
    }
    | FOR '(' declaration expression_statement expression ')' statement {
        $$ = s("for (" + *$3 + " " + *$4 + " " + *$5 + ") " + *$7);
    }
    ;

jump
    : CONTINUE ';' { $$ = s(*$1 + ";"); }
    | BREAK ';' { $$ = s(*$1 + ";"); }
    | RETURN ';' { $$ = s(*$1 + ";"); }
    | RETURN expression ';' { $$ = s(*$1 + " " + *$2 + ";"); }
    ;

declarations
    : declaration
    | declarations declaration { $$ = s(*$1 + "\n" + *$2); }
    ;

declaration
    : var_decl
    | func_decl
    ;

declarator
    : type ident { $$ = s(*$1 + " " + *$2); }
    ;

var_decl
    : type ident ';' {
        $$ = s(*$1 + " " + *$2 + ";");
        types[*$2] = *$1;
    }
    | type ident '=' expression ';' {
        $$ = s(*$1 + " " + *$2 + " = " + *$4 + ";");
        types[*$2] = *$1;
    }
    | TYPE OTYPE '=' obj_qual ';' {
        $$ = s("typedef struct " + *$2 + " " + *$4 + " " + *$2 + ";");
    }
    ;

func_decl
    : type ident '(' param_list ')' block {
        $$ = s(*$1 + " " + *$2 + "(" + *$4 + ")" + *$6);
        types[*$2] = "function";
    }
    | type ident '(' ')' block {
        $$ = s(*$1 + " " + *$2 + "()" + *$5);
        types[*$2] = "function";
    }
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
    | OTYPE { $$ = s("shared_ptr<" + *$1 + ">"); }
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

conditional_expression
    : logical_or_expression
    | logical_or_expression '?' expression ':' conditional_expression {
        $$ = s(*$1 + " ? " + *$3 + " : " + *$5);
    }
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR_OP logical_and_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression AND_OP inclusive_or_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression '|' exclusive_or_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression '^' and_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

and_expression
    : equality_expression
    | and_expression '&' equality_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

equality_expression
    : relational_expression
    | equality_expression EQ_OP relational_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    | equality_expression NE_OP relational_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

relational_expression
    : shift_expression
    | relational_expression '<' shift_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    | relational_expression '>' shift_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    | relational_expression LE_OP shift_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    | relational_expression GE_OP shift_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

shift_expression
    : additive_expression
    | shift_expression LEFT_OP additive_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    | shift_expression RIGHT_OP additive_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

additive_expression
    : multiplicative_expression
    | additive_expression '+' multiplicative_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    | additive_expression '-' multiplicative_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression '*' cast_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    | multiplicative_expression '/' cast_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    | multiplicative_expression '%' cast_expression { $$ = s(*$1 + " " + *$2 + " " + *$3); }
    ;

cast_expression
    : unary_expression
    | '(' type ')' cast_expression { $$ = s("(" + *$2 + ") " + *$4); }
    ;

unary_expression
    : postfix_expression
    | INC_OP unary_expression { $$ = s(*$1 + *$2); }
    | DEC_OP unary_expression { $$ = s(*$1 + *$2); }
    | unary_operator cast_expression { $$ = s(*$1 + *$2); }
    ;

unary_operator
    : '+'
    | '-'
    | '~'
    | '!'
    ;

postfix_expression
    : primary_expression
    | postfix_expression '[' expression ']'  { $$ = s(*$1 + "[" + *$3 + "]"); }
    | postfix_expression '(' ')' { $$ = s(*$1 + "()"); }
    | postfix_expression '(' argument_expression_list ')'  { $$ = s(*$1 + "(" + *$3 + ")"); }
    | postfix_expression '.' IDENTIFIER  {
        if (types.count(*$1) && types[*$1].size() >= 6 && types[*$1].substr(0, 6) == "vector") {
            $$ = s(*$1 + *$2 + *$3);
        } else {
            $$ = s(*$1 + "->" + *$3);
        }
    }
    | postfix_expression INC_OP { $$ = s(*$1 + "++"); }
    | postfix_expression DEC_OP { $$ = s(*$1 + "--"); }
    | obj_decl
    | list_decl
    ;

argument_expression_list
    : expression
    | argument_expression_list ',' expression { $$ = s(*$1 + *$2 + " " + *$3); }
    ;

primary_expression
    : IDENTIFIER
    | constant
    | string
    | '(' expression ')' { $$ = s("(" + *$2 + ")"); }
    ;

constant
    : I_CONSTANT
    | F_CONSTANT
    ;

string
    : STRING_LITERAL
    ;

obj_decl
    : OTYPE '{' obj_decl_list '}' {
        $$ = s("shared_ptr<" + *$1 + ">(new " + *$1 + "{\n" + *$3 + "\n})");
    }
    | OTYPE '{' obj_decl_list ',' '}' {
        $$ = s("shared_ptr<" + *$1 + ">(new " + *$1 + "{\n" + *$3 + "\n})");
    }
    ;

list_decl
    : '[' obj_decl_list ']' { $$ = s("{" + *$2 + "}"); }
    | '[' obj_decl_list ',' ']' { $$ = s("{" + *$2 + "}"); }
    ;

obj_decl_list
    : expression
    | obj_decl_list ',' expression { $$ = s(*$1 + ", " + *$3); }
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
