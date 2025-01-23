%{
#include "parser.tab.h" // Include the bison header file
#include <stdlib.h>

void yyerror(const char*); // Forward declare the error function
%}

%option yylineno
%option noyywrap
DIGIT        [0-9]
INT          {DIGIT}+
EXP          [Ee][+-]?{DIGIT}+
FLOAT        {INT}\.{INT}?{EXP}?
%%
[ \t]+       ; /* Ignore whitespace */
{INT}        { yylval.ival = atoi(yytext); return NUMBER_INT; }
{FLOAT}       { yylval.dval = atof(yytext); return NUMBER_DOUBLE; }
"+"          { return PLUS; }
"-"          { return MINUS; }
"*"          { return MUL; }
"/"          { return DIV; }
"^"          { return POW; }
"("          { return LPAREN; }
")"          { return RPAREN; }
"sin"|"cos"|"tan"|"sqrt"|"log"|"exp" { yylval.sval = strdup(yytext); return FUNC; }
\n           { return EOL; }
.            { yyerror("Invalid character"); }
%%
