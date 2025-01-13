%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void yyerror(const char *s);
int yylex(void);
%}

%union {
    double num;
}

%token <num> NUM
%token PLUS MINUS MUL DIV LPAREN RPAREN
%type <num> expression term factor

%%

input:
    /* empty */
    | input expression '\n' { printf("Result: %f\n", $2); }
    ;

expression:
    term                     { $$ = $1; }
    | expression PLUS term    { $$ = $1 + $3; }
    | expression MINUS term   { $$ = $1 - $3; }
    ;

term:
    factor                   { $$ = $1; }
    | term MUL factor         { $$ = $1 * $3; }
    | term DIV factor         { if ($3 == 0) { yyerror("Division by zero!"); } else { $$ = $1 / $3; } }
    ;

factor:
    NUM                      { $$ = $1; }
    | LPAREN expression RPAREN { $$ = $2; }
    | MINUS factor           { $$ = -$2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    printf("Enter an expression: ");
    yyparse();
    return 0;
}

