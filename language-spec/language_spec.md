Section 1: Language Overview

    CStar is a C-like programming language designed for educational compiler development. It includes variable declarations, expressions, control flow, structs, functions, arrays, and supports type-safe operations and intermediate code generation in the form of three-address code.

Section 2: Feature Checklist

    | Feature             | Status | Example                           |
    |---------------------|--------|-----------------------------------|
    | Variable Declaration| ✅     | `int x = 5;`                      |
    | Arithmetic Ops      | ✅     | `x = a + b * c;`                  |
    | If/Else             | ✅     | `if (x > 0) { ... } else { ... }` |
    | While/For           | ✅     | `for (i = 0; i < 10; i++)`        |
    | Structs             | ✅     | `struct Point { int x, y; };`    |
    | Arrays              | ✅     | `int a[5];`                       |
    | Functions           | ✅     | `int max(int a, int b) { ... }`  |

Section 3: Keywords, Operators, and Symbols

keywords:
    
    int, float, char, void, if, else, for, while, return, struct, sizeof, break, continue

operators:

    + - * / % = == != < > <= >= && || ! ++ -- += -= *= /= 


Section 4: Grammar in BNF

    program         → decl_list

    decl_list       → decl | decl decl_list
    decl            → var_decl | fun_decl | struct_decl

    var_decl        → type_spec ID [ '[' NUM ']' ] ';'
    fun_decl        → type_spec ID '(' params ')' block
    struct_decl     → 'struct' ID '{' var_decl_list '}' ';'

    type_spec       → 'int' | 'float' | 'char' | 'void' | 'struct' ID

    params          → param_list | 'void'
    param_list      → param | param ',' param_list
    param           → type_spec ID

    block           → '{' local_decls stmt_list '}'
    local_decls     → ε | local_decls var_decl
    stmt_list       → ε | stmt stmt_list

    stmt            → expr_stmt | compound_stmt | if_stmt | while_stmt
                    | for_stmt | return_stmt | break_stmt | continue_stmt

    expr_stmt       → expr ';' | ';'
    compound_stmt   → block
    if_stmt         → 'if' '(' expr ')' stmt ['else' stmt]
    while_stmt      → 'while' '(' expr ')' stmt
    for_stmt        → 'for' '(' expr_stmt expr_stmt expr ')' stmt
    return_stmt     → 'return' [expr] ';'
    break_stmt      → 'break' ';'
    continue_stmt   → 'continue' ';'

    expr            → assign_expr
    assign_expr     → ID '=' assign_expr | logic_or_expr
    logic_or_expr   → logic_and_expr ('||' logic_and_expr)*
    logic_and_expr  → equality_expr ('&&' equality_expr)*
    equality_expr   → rel_expr (('==' | '!=') rel_expr)*
    rel_expr        → add_expr (('>' | '>=' | '<' | '<=') add_expr)*
    add_expr        → mul_expr (('+' | '-') mul_expr)*
    mul_expr        → unary_expr (('*' | '/' | '%') unary_expr)*
    unary_expr      → ('!' | '-' | '++' | '--') unary_expr | postfix_expr
    postfix_expr    → primary_expr ('[' expr ']' | '(' args ')' | '.' ID)*
    primary_expr    → ID | NUM | CHAR | '(' expr ')' | 'sizeof' '(' type_spec ')'

    args            → ε | expr (',' expr)*



Section 5: Sample Programs

    struct Point {
        int x;
        int y;
    };

    int max(int a, int b) {
        if (a > b) return a;
        else return b;
    }

    int main() {
        int a = 5, b = 10, arr[5];
        struct Point p;
        p.x = 3;
        p.y = 4;

        arr[0] = a + b * 2;

        for (int i = 0; i < 5; i++) {
            arr[i] = i * i;
        }

        return max(p.x, p.y);
    }
