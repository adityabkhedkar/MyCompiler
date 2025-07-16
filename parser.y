%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "include/ast.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern char* yytext;
extern int line_number;
extern int column_number;

void yyerror(const char* s);
ASTNode* parse_result = NULL;
%}

%union {
    int num;
    float flt;
    char* str;
    struct ASTNode* node;
}

%token INT FLOAT CHAR VOID IF ELSE WHILE FOR RETURN STRUCT SIZEOF BREAK CONTINUE
%token EQ NEQ LT GT LEQ GEQ
%token ADD SUB MUL DIV MOD
%token ASSIGN AND OR NOT
%token INCR DECR DOT
%token SEMICOLON COMMA
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK

%token <num> NUM
%token <flt> FLOATLIT
%token <str> ID STRING

%type <node> program decl_list decl var_decl fun_decl struct_decl
%type <node> type_spec params param_list param
%type <node> compound_stmt decl_stmt_list stmt
%type <node> expr_stmt if_stmt while_stmt return_stmt
%type <node> expr assign_expr logic_or_expr logic_and_expr
%type <node> equality_expr rel_expr add_expr mul_expr
%type <node> unary_expr postfix_expr primary_expr
%type <node> args

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program
    : decl_list                    { 
        parse_result = create_node(NODE_PROGRAM);
        parse_result->left = $1;
        $$ = parse_result;
    }
    ;

decl_list
    : decl { $$ = $1; }
    | decl decl_list { $$ = $1; $$->next = $2; }
    ;

decl
    : var_decl { $$ = $1; }
    | fun_decl { $$ = $1; }
    | struct_decl { $$ = $1; }
    ;

var_decl
    : type_spec ID SEMICOLON {
        $$ = create_node(NODE_VAR_DECL);
        $$->left = $1;
        $$->value.str_val = strdup($2);
    }
    | type_spec ID ASSIGN expr SEMICOLON {
        $$ = create_node(NODE_VAR_DECL);
        $$->left = $1;
        $$->value.str_val = strdup($2);
        $$->right = $4;
    }
    ;

type_spec
    : INT { $$ = create_node(NODE_DECL); $$->value.str_val = strdup("int"); }
    | FLOAT { $$ = create_node(NODE_DECL); $$->value.str_val = strdup("float"); }
    | CHAR { $$ = create_node(NODE_DECL); $$->value.str_val = strdup("char"); }
    | VOID { $$ = create_node(NODE_DECL); $$->value.str_val = strdup("void"); }
    | STRUCT ID {
        $$ = create_node(NODE_DECL);
        $$->value.str_val = strdup("struct");
        $$->left = create_node(NODE_LITERAL);
        $$->left->value.str_val = strdup($2);
    }
    ;

fun_decl
    : type_spec ID LPAREN params RPAREN compound_stmt {
        $$ = create_node(NODE_FUN_DECL);
        $$->left = $1;
        $$->value.str_val = strdup($2);
        $$->right = $6;
        if ($4) {
            ASTNode* param_node = create_node(NODE_PARAM);
            param_node->left = $4;
            $$->next = param_node;
        }
    }
    ;

struct_decl
    : STRUCT ID LBRACE decl_stmt_list RBRACE SEMICOLON {
        $$ = create_node(NODE_STRUCT_DECL);
        $$->value.str_val = strdup($2);
        $$->left = $4;
    }
    ;

params
    : param_list { $$ = $1; }
    | VOID { $$ = create_node(NODE_PARAM); $$->value.str_val = strdup("void"); }
    | /* empty */ { $$ = NULL; }
    ;

param_list
    : param { $$ = $1; }
    | param COMMA param_list { $$ = $1; $$->next = $3; }
    ;

param
    : type_spec ID {
        $$ = create_node(NODE_PARAM);
        $$->left = $1;
        $$->value.str_val = strdup($2);
    }
    ;

compound_stmt
    : LBRACE decl_stmt_list RBRACE {
        $$ = create_node(NODE_BLOCK);
        $$->left = $2;
    }
    ;

decl_stmt_list
    : /* empty */ { 
        $$ = NULL;
    }
    | decl_stmt_list var_decl { 
        if (!$1) {
            $$ = $2;
        } else {
            ASTNode* last = $1;
            while (last->next) last = last->next;
            last->next = $2;
            $$ = $1;
        }
    }
    | decl_stmt_list stmt {
        if (!$1) {
            $$ = $2;
        } else {
            ASTNode* last = $1;
            while (last->next) last = last->next;
            last->next = $2;
            $$ = $1;
        }
    }
    ;

stmt
    : expr_stmt { $$ = $1; }
    | compound_stmt { $$ = $1; }
    | if_stmt { $$ = $1; }
    | while_stmt { $$ = $1; }
    | return_stmt { $$ = $1; }
    ;

expr_stmt
    : expr SEMICOLON { $$ = $1; }
    | SEMICOLON { $$ = NULL; }
    ;

if_stmt
    : IF LPAREN expr RPAREN stmt %prec LOWER_THAN_ELSE {
        $$ = create_node(NODE_IF_STMT);
        $$->left = $3;
        $$->right = $5;
    }
    | IF LPAREN expr RPAREN stmt ELSE stmt {
        $$ = create_node(NODE_IF_STMT);
        $$->left = $3;
        $$->right = $5;
        $$->next = $7;
    }
    ;

while_stmt
    : WHILE LPAREN expr RPAREN stmt {
        $$ = create_node(NODE_WHILE_STMT);
        $$->left = $3;
        $$->right = $5;
    }
    ;

return_stmt
    : RETURN SEMICOLON {
        $$ = create_node(NODE_RETURN_STMT);
    }
    | RETURN expr SEMICOLON {
        $$ = create_node(NODE_RETURN_STMT);
        $$->left = $2;
    }
    ;

expr
    : assign_expr { $$ = $1; }
    ;

assign_expr
    : postfix_expr ASSIGN assign_expr {
        $$ = create_node(NODE_ASSIGN_EXPR);
        $$->left = $1;
        $$->right = $3;
    }
    | logic_or_expr { $$ = $1; }
    ;

logic_or_expr
    : logic_and_expr { $$ = $1; }
    | logic_or_expr OR logic_and_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("||");
        $$->left = $1;
        $$->right = $3;
    }
    ;

logic_and_expr
    : equality_expr { $$ = $1; }
    | logic_and_expr AND equality_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("&&");
        $$->left = $1;
        $$->right = $3;
    }
    ;

equality_expr
    : rel_expr { $$ = $1; }
    | equality_expr EQ rel_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("==");
        $$->left = $1;
        $$->right = $3;
    }
    | equality_expr NEQ rel_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("!=");
        $$->left = $1;
        $$->right = $3;
    }
    ;

rel_expr
    : add_expr { $$ = $1; }
    | rel_expr LT add_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("<");
        $$->left = $1;
        $$->right = $3;
    }
    | rel_expr GT add_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup(">");
        $$->left = $1;
        $$->right = $3;
    }
    | rel_expr LEQ add_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("<=");
        $$->left = $1;
        $$->right = $3;
    }
    | rel_expr GEQ add_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup(">=");
        $$->left = $1;
        $$->right = $3;
    }
    ;

add_expr
    : mul_expr { $$ = $1; }
    | add_expr ADD mul_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("+");
        $$->left = $1;
        $$->right = $3;
    }
    | add_expr SUB mul_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("-");
        $$->left = $1;
        $$->right = $3;
    }
    ;

mul_expr
    : unary_expr { $$ = $1; }
    | mul_expr MUL unary_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("*");
        $$->left = $1;
        $$->right = $3;
    }
    | mul_expr DIV unary_expr {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup("/");
        $$->left = $1;
        $$->right = $3;
    }
    ;

unary_expr
    : postfix_expr { $$ = $1; }
    | SUB unary_expr {
        $$ = create_node(NODE_UNARY_EXPR);
        $$->value.str_val = strdup("-");
        $$->left = $2;
    }
    ;

postfix_expr
    : primary_expr { $$ = $1; }
    | postfix_expr LPAREN args RPAREN {
        $$ = create_node(NODE_CALL_EXPR);
        $$->left = $1;
        $$->right = $3;
    }
    | postfix_expr DOT ID {
        $$ = create_node(NODE_BINARY_EXPR);
        $$->value.str_val = strdup(".");
        $$->left = $1;
        $$->right = create_node(NODE_EXPR);
        $$->right->value.str_val = strdup($3);
    }
    ;

primary_expr
    : ID {
        $$ = create_node(NODE_EXPR);
        $$->value.str_val = strdup($1);
    }
    | NUM {
        $$ = create_node(NODE_LITERAL);
        $$->value.int_val = $1;
    }
    | FLOATLIT {
        $$ = create_node(NODE_LITERAL);
        $$->value.float_val = $1;
    }
    | STRING {
        $$ = create_node(NODE_LITERAL);
        $$->value.str_val = strdup($1);
    }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

args
    : /* empty */ { $$ = NULL; }
    | expr { $$ = $1; }
    | expr COMMA args {
        $$ = $1;
        $$->next = $3;
    }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error at line %d: %s\n", line_number, s);
}

ASTNode* create_node(NodeType type) {
    ASTNode* node = (ASTNode*)calloc(1, sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        exit(1);
    }
    node->type = type;
    return node;
}

void free_ast(ASTNode* node) {
    if (!node) return;
    
    free_ast(node->left);
    free_ast(node->right);
    free_ast(node->next);
    
    if (node->value.str_val) {
        free(node->value.str_val);
    }
    free(node);
}