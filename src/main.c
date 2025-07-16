#include <stdio.h>
#include <stdlib.h>
#include "../include/ast.h"

extern FILE* yyin;
extern int yyparse(void);
extern ASTNode* parse_result;

const char* get_node_type_str(NodeType type);
void print_ast(ASTNode* node, int depth);
void print_indent(int depth);
void generate_three_address_code(ASTNode* node);

void print_indent(int depth) {
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }
}

void print_ast(ASTNode* node, int depth) {
    if (!node) return;

    // Print current node
    print_indent(depth);
    printf("%s", get_node_type_str(node->type));
    
    // Print node value based on type
    switch (node->type) {
        case NODE_PROGRAM:
        case NODE_BLOCK:
        case NODE_IF_STMT:
        case NODE_WHILE_STMT:
        case NODE_FOR_STMT:
        case NODE_RETURN_STMT:
            // These nodes may not have values
            break;
            
        case NODE_LITERAL:
            if (node->value.str_val) {
                printf(": \"%s\"", node->value.str_val);
            } else {
                printf(": %d", node->value.int_val);
            }
            break;
            
        case NODE_VAR_DECL:
        case NODE_FUN_DECL:
        case NODE_STRUCT_DECL:
        case NODE_PARAM:
        case NODE_EXPR:
        case NODE_DECL:
            if (node->value.str_val) {
                printf(": %s", node->value.str_val);
            }
            break;
            
        case NODE_BINARY_EXPR:
        case NODE_UNARY_EXPR:
            if (node->value.str_val) {
                printf(" (%s)", node->value.str_val);
            }
            break;
            
        case NODE_ASSIGN_EXPR:
            if (node->left && node->left->value.str_val) {
                printf(": %s", node->left->value.str_val);
            }
            break;
            
        case NODE_CALL_EXPR:
            if (node->left && node->left->value.str_val) {
                printf(": %s", node->left->value.str_val);
            }
            break;
    }
    printf("\n");
    fflush(stdout);  // Ensure output is flushed

    // Handle different node types
    switch (node->type) {
        case NODE_IF_STMT:
            if (node->left) {
                print_indent(depth + 1);
                printf("Condition:\n");
                print_ast(node->left, depth + 2);
            }
            if (node->right) {
                print_indent(depth + 1);
                printf("Then:\n");
                print_ast(node->right, depth + 2);
            }
            if (node->next) {
                print_indent(depth + 1);
                printf("Else:\n");
                print_ast(node->next, depth + 2);
            }
            break;
            
        case NODE_BLOCK:
            // Print all statements in block
            if (node->left) {
                int stmt_count = 0;
                ASTNode* stmt = node->left;
                printf("DEBUG: Starting block statement traversal\n");
                while (stmt) {
                    printf("DEBUG: Statement %d type: %s\n", 
                           ++stmt_count, get_node_type_str(stmt->type));
                    print_ast(stmt, depth + 1);
                    stmt = stmt->next;
                }
                printf("DEBUG: Block had %d statements\n", stmt_count);
            }
            break;
            
        default:
            // Standard tree traversal
            if (node->left) {
                print_ast(node->left, depth + 1);
            }
            if (node->right) {
                print_ast(node->right, depth + 1);
            }
            // Only traverse next if not in a block's statement list
            if (node->next && node->type != NODE_BLOCK) {
                print_ast(node->next, depth);
            }
            break;
    }
    fflush(stdout);  // Ensure all output is flushed
}

void generate_three_address_code(ASTNode* node) {
    if (!node) return;

    switch (node->type) {
        case NODE_PROGRAM:
        case NODE_BLOCK:
            generate_three_address_code(node->left);
            break;

        case NODE_VAR_DECL:
            if (node->right) {
                printf("%s = ", node->value.str_val);
                generate_three_address_code(node->right);
                printf("\n");
            } else {
                printf("%s\n", node->value.str_val);
            }
            break;

        case NODE_ASSIGN_EXPR:
            generate_three_address_code(node->left);
            printf(" = ");
            generate_three_address_code(node->right);
            printf("\n");
            break;

        case NODE_BINARY_EXPR:
            printf("(");
            generate_three_address_code(node->left);
            printf(" %s ", node->value.str_val);
            generate_three_address_code(node->right);
            printf(")");
            break;

        case NODE_LITERAL:
            if (node->value.str_val) {
                printf("%s", node->value.str_val);
            } else {
                printf("%d", node->value.int_val);
            }
            break;

        case NODE_EXPR:
            if (node->value.str_val) {
                printf("%s", node->value.str_val);
            }
            break;

        case NODE_FUN_DECL:
            printf("function %s:\n", node->value.str_val);
            generate_three_address_code(node->right);
            break;

        case NODE_RETURN_STMT:
            printf("return ");
            generate_three_address_code(node->left);
            printf("\n");
            break;

        case NODE_IF_STMT:
            printf("if ");
            generate_three_address_code(node->left);
            printf(" goto L1\n");
            printf("goto L2\n");
            printf("L1:\n");
            generate_three_address_code(node->right);
            printf("goto L3\n");
            printf("L2:\n");
            break;

        case NODE_WHILE_STMT:
            printf("L1:\n");
            printf("if not ");
            generate_three_address_code(node->left);
            printf(" goto L3\n");
            printf("L2:\n");
            generate_three_address_code(node->right);
            printf("goto L1\n");
            printf("L3:\n");
            break;

        case NODE_STRUCT_DECL:
            printf("struct %s:\n", node->value.str_val);
            generate_three_address_code(node->left);
            break;

        default:
            printf("Unhandled node type: %d\n", node->type);
            break;
    }

    generate_three_address_code(node->next);
}

const char* get_node_type_str(NodeType type) {
    switch (type) {
        case NODE_PROGRAM: return "Program";
        case NODE_DECL: return "Declaration";
        case NODE_VAR_DECL: return "VarDecl";
        case NODE_FUN_DECL: return "FunDecl";
        case NODE_STRUCT_DECL: return "StructDecl";
        case NODE_PARAM: return "Parameter";
        case NODE_BLOCK: return "Block";
        case NODE_EXPR: return "Expression";
        case NODE_IF_STMT: return "If";
        case NODE_WHILE_STMT: return "While";
        case NODE_FOR_STMT: return "For"; 
        case NODE_RETURN_STMT: return "Return";
        case NODE_ASSIGN_EXPR: return "Assignment";
        case NODE_BINARY_EXPR: return "BinaryExpr";
        case NODE_UNARY_EXPR: return "UnaryExpr";
        case NODE_CALL_EXPR: return "FunctionCall";
        case NODE_LITERAL: return "Literal";
        default: return "Unknown";
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        return 1;
    }

    printf("Parsing file: %s\n", argv[1]);
    
    parse_result = NULL;
    int result = yyparse();
    fclose(yyin);
    
    if (result == 0 && parse_result) {
        printf("\nParsing successful! Abstract Syntax Tree:\n");
        print_ast(parse_result, 0);

        printf("\nGenerating Three-Address Code:\n");
        generate_three_address_code(parse_result);

        // Clean up AST
        free_ast(parse_result);
        parse_result = NULL;
        return 0;  // Success
    }
    
    fprintf(stderr, "\nParsing failed!\n");
    return 1;  // Error
}