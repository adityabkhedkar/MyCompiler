#ifndef AST_H
#define AST_H

// Node types for AST
typedef enum {
    NODE_PROGRAM,
    NODE_DECL,
    NODE_VAR_DECL,
    NODE_FUN_DECL,
    NODE_STRUCT_DECL,
    NODE_PARAM,
    NODE_BLOCK,
    NODE_EXPR,
    NODE_IF_STMT,
    NODE_WHILE_STMT,
    NODE_FOR_STMT,
    NODE_RETURN_STMT,
    NODE_ASSIGN_EXPR,
    NODE_BINARY_EXPR,
    NODE_UNARY_EXPR,
    NODE_CALL_EXPR,
    NODE_LITERAL
} NodeType;

// AST node structure
typedef struct ASTNode {
    NodeType type;
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *next;
    union {
        int int_val;
        float float_val;
        char *str_val;
    } value;
} ASTNode;

// Function declarations
ASTNode* create_node(NodeType type);
void free_ast(ASTNode* node);

#endif /* AST_H */