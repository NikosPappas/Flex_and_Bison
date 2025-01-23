%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
typedef enum {
    NODE_NUMBER_INT,
    NODE_NUMBER_DOUBLE,
    NODE_ADD,
    NODE_SUB,
    NODE_MUL,
    NODE_DIV,
    NODE_POW,
    NODE_FUNC,
} NodeType;


typedef union {
    int ival;
    double dval;
    char *sval;
} Value;


typedef struct Node {
  NodeType type;
  Value value;
  struct Node *left;
  struct Node *right;
} Node;

Node* createNode(NodeType type, Value value, Node* left, Node* right);
double evaluate(Node* node);
void freeAST(Node* node);
void yyerror(const char*);

extern int yylineno;
extern char* yytext;
int yylex();
%}

%union {
  int ival;
  double dval;
  char* sval;
  struct Node* node;
}

%token <ival> NUMBER_INT
%token <dval> NUMBER_DOUBLE
%token PLUS MINUS MUL DIV POW LPAREN RPAREN
%token <sval> FUNC
%token EOL

%type <node> expression term factor
%%

start:
  expression EOL { printf("Result: %f\n", evaluate($1)); freeAST($1); return 0; }
  | EOL { return 0;}
  ;

expression:
  term { $$ = $1; }
  | expression PLUS term { $$ = createNode(NODE_ADD, (Value){.dval = 0}, $1, $3); }
  | expression MINUS term { $$ = createNode(NODE_SUB, (Value){.dval = 0}, $1, $3); }
  ;

term:
  factor { $$ = $1; }
  | term MUL factor { $$ = createNode(NODE_MUL, (Value){.dval = 0}, $1, $3); }
  | term DIV factor { $$ = createNode(NODE_DIV, (Value){.dval = 0}, $1, $3); }
  | term POW factor { $$ = createNode(NODE_POW, (Value){.dval = 0}, $1, $3); }
  ;

factor:
  NUMBER_INT { $$ = createNode(NODE_NUMBER_INT, (Value){.ival = $1}, NULL, NULL); }
  | NUMBER_DOUBLE { $$ = createNode(NODE_NUMBER_DOUBLE, (Value){.dval = $1}, NULL, NULL); }
  | LPAREN expression RPAREN { $$ = $2; }
  | FUNC LPAREN expression RPAREN { $$ = createNode(NODE_FUNC, (Value){.sval = $1}, $3, NULL); }

%%
// Helper functions
Node* createNode(NodeType type, Value value, Node* left, Node* right) {
    Node* node = (Node*)malloc(sizeof(Node));
    if (!node) {
        yyerror("Memory allocation failed");
        exit(1);
    }
    node->type = type;
    node->value = value;
    node->left = left;
    node->right = right;
    return node;
}

double evaluate(Node* node) {
  if (!node) return 0.0;
    switch (node->type) {
        case NODE_NUMBER_INT:
            return (double)node->value.ival;
        case NODE_NUMBER_DOUBLE:
            return node->value.dval;
        case NODE_ADD:
            return evaluate(node->left) + evaluate(node->right);
        case NODE_SUB:
            return evaluate(node->left) - evaluate(node->right);
        case NODE_MUL:
            return evaluate(node->left) * evaluate(node->right);
        case NODE_DIV:
            {
                double divisor = evaluate(node->right);
                if (divisor == 0) {
                    yyerror("Division by zero");
                    exit(1);
                }
              return evaluate(node->left) / divisor;
            }
        case NODE_POW:
            return pow(evaluate(node->left), evaluate(node->right));
        case NODE_FUNC:
             {
                double arg = evaluate(node->left);
                if(strcmp(node->value.sval, "sin") == 0){
                    return sin(arg);
                }else if (strcmp(node->value.sval, "cos") == 0){
                    return cos(arg);
                }else if (strcmp(node->value.sval, "tan") == 0){
                    return tan(arg);
                }else if (strcmp(node->value.sval, "sqrt") == 0){
                    if (arg < 0) {
                        yyerror("Square root of a negative number");
                        exit(1);
                    }
                    return sqrt(arg);
                }else if (strcmp(node->value.sval, "log") == 0){
                      if (arg <= 0) {
                        yyerror("Logarithm of a non-positive number");
                        exit(1);
                    }
                   return log(arg);
                }else if(strcmp(node->value.sval, "exp") == 0){
                    return exp(arg);
                }
                else{
                    yyerror("Unknown function");
                    exit(1);
                }
             }
    }
  return 0.0;
}


void freeAST(Node* node){
    if(!node) return;
    freeAST(node->left);
    freeAST(node->right);
    if(node->type == NODE_FUNC){
        free(node->value.sval);
    }
    free(node);
}

void yyerror(const char *s) {
  fprintf(stderr, "Error: %s at line %d\n", s, yylineno);
  fprintf(stderr, "Near: %s\n", yytext);
}

int main()
{
   printf("> ");
   yyparse();
   return 0;
}
