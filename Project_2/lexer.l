%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"
%}

digit [0-9]
number {digit}+(\.{digit}+)?

%%

" " {/*ignore whitespace*/}
"+" { return PLUS;   }
"-" { return MINUS;  }
"*" { return MUL;    }
"/" { return DIV;    }
"(" { return LPAREN; }
")" { return RPAREN; }

{number}  { yylval.num=atof(yytext); return NUM;}

%%
int yywrap(){
    return 1;
}
