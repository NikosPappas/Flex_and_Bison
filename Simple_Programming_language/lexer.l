%{
#include "parser.tab.h"
#include <stdio.h>

%}

%option noyywrap

%%

[ \t\n]+         ; /* Ignore whitespace */
"int"           { return INT_TYPE; }
"double"        { return DOUBLE_TYPE; }
"boolean"       { return BOOLEAN_TYPE; }
"array"         { return ARRAY_TYPE; }
"function"       { return FUNCTION_TYPE;}
"true"          { yylval.bval = 1; return BOOLEAN_LITERAL; }
"false"         { yylval.bval = 0; return BOOLEAN_LITERAL; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
[0-9]+          { yylval.ival = atoi(yytext); return INTEGER_LITERAL; }
[0-9]+\.[0-9]+ { yylval.dval = atof(yytext); return DOUBLE_LITERAL; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return IDENTIFIER; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"["             { return LBRACKET; }
"]"             { return RBRACKET; }
","             { return COMMA; }
";"             { return SEMICOLON; }
"="             { return ASSIGN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }
"=="            { return EQ; }
"!="            { return NEQ; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LTE; }
">="            { return GTE; }
"&&"            { return AND; }
"||"            { return OR; }
"!"            { return NOT; }
"{"            { return LBRACE; }
"}"            { return RBRACE; }
"return"       { return RETURN;}


.               { printf("Unknown character: %s\n", yytext); /* Handle errors */ }

%%
