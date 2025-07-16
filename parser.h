#ifndef PARSER_H
#define PARSER_H

// Token type definitions (must match lexer.l)
enum {
    INT = 1,
    FLOAT,
    CHAR,
    VOID,
    IF,
    ELSE,
    WHILE,
    FOR,
    RETURN,
    STRUCT,
    SIZEOF,
    BREAK,
    CONTINUE,
    NUM,
    FLOATLIT,
    ID,
    EQ,
    NEQ,
    LT,
    GT,
    LEQ,
    GEQ,
    ADD,
    SUB,
    MUL,
    DIV,
    MOD,
    ASSIGN,
    AND,
    OR,
    NOT,
    INCR,
    DECR,
    SEMICOLON,
    COMMA,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    LBRACK,
    RBRACK,
    STRING
};

// YYSTYPE definition
typedef union {
    int num;
    float flt;
    char* str;
    struct ASTNode* node;
} YYSTYPE;

extern YYSTYPE yylval;

// Function declarations
int yylex(void);
void yyerror(const char *s);

#endif /* PARSER_H */