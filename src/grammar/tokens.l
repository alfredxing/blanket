O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]
WSN [ \t\v\f]

%{
    #include <string>
    #include <iostream>
    #include <set>
    #include "parser.hh"

    using namespace std;

    void comment(void);
    int check_type(void);
    int error(void);
    extern void yyerror(char *s);

    set<string> otypes;
    string last;
    #define SAVE { yylval = new string(yytext, yyleng); last = string(yytext, yyleng); }
%}

%%

"/*"                                { comment(); }
"//".*                              { /* ignore comment */ }

"break"                             { SAVE; return(BREAK); }
"char"                              { SAVE; return(CHAR); }
"continue"                          { SAVE; return(CONTINUE); }
"do"                                { SAVE; return(DO); }
"double"                            { SAVE; return(DOUBLE); }
"else"                              { SAVE; return(ELSE); }
"float"                             { SAVE; return(FLOAT); }
"for"                               { SAVE; return(FOR); }
"if"                                { SAVE; return(IF); }
"int"                               { SAVE; return(INT); }
"long"                              { SAVE; return(LONG); }
"string"                            { SAVE; return(STRING); }
"return"                            { SAVE; return(RETURN); }
"type"                              { SAVE; return(TYPE); }
"void"                              { SAVE; return(VOID); }
"while"                             { SAVE; return(WHILE); }

{L}{A}*                             { return check_type(); }

{HP}{H}+{IS}?                       { SAVE; return I_CONSTANT; }
{NZ}{D}*{IS}?                       { SAVE; return I_CONSTANT; }
"0"{O}*{IS}?                        { SAVE; return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"         { SAVE; return I_CONSTANT; }

{D}+{E}{FS}?                        { SAVE; return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?                { SAVE; return F_CONSTANT; }
{D}+"."{E}?{FS}?                    { SAVE; return F_CONSTANT; }
{HP}{H}+{P}{FS}?                    { SAVE; return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?             { SAVE; return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?                 { SAVE; return F_CONSTANT; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+   { SAVE; return STRING_LITERAL; }

"+="                                { SAVE; return ADD_ASSIGN; }
"-="                                { SAVE; return SUB_ASSIGN; }
"*="                                { SAVE; return MUL_ASSIGN; }
"/="                                { SAVE; return DIV_ASSIGN; }
"%="                                { SAVE; return MOD_ASSIGN; }
"&="                                { SAVE; return AND_ASSIGN; }
"^="                                { SAVE; return XOR_ASSIGN; }
"|="                                { SAVE; return OR_ASSIGN; }
">>"                                { SAVE; return RIGHT_OP; }
"<<"                                { SAVE; return LEFT_OP; }
"++"                                { SAVE; return INC_OP; }
"--"                                { SAVE; return DEC_OP; }
"&&"                                { SAVE; return AND_OP; }
"||"                                { SAVE; return OR_OP; }
"<="                                { SAVE; return LE_OP; }
">="                                { SAVE; return GE_OP; }
"=="                                { SAVE; return EQ_OP; }
"!="                                { SAVE; return NE_OP; }
";"                                 { SAVE; return ';'; }
"{"                                 { SAVE; return '{'; }
"}"                                 { SAVE; return '}'; }
","                                 { SAVE; return ','; }
":"                                 { SAVE; return ':'; }
"="                                 { SAVE; return '='; }
"("                                 { SAVE; return '('; }
")"                                 { SAVE; return ')'; }
"["                                 { SAVE; return '['; }
"]"                                 { SAVE; return ']'; }
"."                                 { SAVE; return '.'; }
"&"                                 { SAVE; return '&'; }
"!"                                 { SAVE; return '!'; }
"~"                                 { SAVE; return '~'; }
"-"                                 { SAVE; return '-'; }
"+"                                 { SAVE; return '+'; }
"*"                                 { SAVE; return '*'; }
"/"                                 { SAVE; return '/'; }
"%"                                 { SAVE; return '%'; }
"<"                                 { SAVE; return '<'; }
">"                                 { SAVE; return '>'; }
"^"                                 { SAVE; return '^'; }
"|"                                 { SAVE; return '|'; }
"?"                                 { SAVE; return '?'; }

"\n"                                { yylineno++; }
{WSN}+                              { /* ignore whitespace */ }
.                                   { error(); }

%%

int yywrap(void) {
    return 1;
}

void comment(void) {
    int c;

    while ((c = yyinput()) != 0) {
        if (c == '*') {
            while ((c = yyinput()) == '*');

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    }
    yyerror("Unterminated comment");
}

int check_type(void) {
    int res;
    if (otypes.count(string(yytext))) {
        res = OTYPE;
    } else if (last == "type") {
        res = OTYPE;
        otypes.insert(string(yytext));
    } else {
        res = IDENTIFIER;
    }

    SAVE;
    return res;
}

int error() {
    yyerror("Unknown token");
    yyterminate();
}
