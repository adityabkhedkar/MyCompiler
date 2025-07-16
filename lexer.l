%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

int line_number = 1;
int column_number = 1;

void count();
%}

%%

"//"[^\n]*  { count(); } /* Single line comments */
[ \t]       { count(); }
[\n]        { line_number++; column_number = 1; }

"int"       { count(); return INT; }
"float"     { count(); return FLOAT; }
"char"      { count(); return CHAR; }
"void"      { count(); return VOID; }
"if"        { count(); return IF; }
"else"      { count(); return ELSE; }
"while"     { count(); return WHILE; }
"for"       { count(); return FOR; }
"return"    { count(); return RETURN; }
"struct"    { count(); return STRUCT; }
"sizeof"    { count(); return SIZEOF; }
"break"     { count(); return BREAK; }
"continue"  { count(); return CONTINUE; }

[a-zA-Z_][a-zA-Z0-9_]*  { count(); yylval.str = strdup(yytext); return ID; }
[0-9]+      { count(); yylval.num = atoi(yytext); return NUM; }
[0-9]+\.[0-9]+ { count(); yylval.flt = atof(yytext); return FLOATLIT; }
\"[^\"]*\"  { count(); yylval.str = strdup(yytext); return STRING; }

"=="        { count(); return EQ; }
"!="        { count(); return NEQ; }
"<"         { count(); return LT; }
">"         { count(); return GT; }
"<="        { count(); return LEQ; }
">="        { count(); return GEQ; }
"+"         { count(); return ADD; }
"-"         { count(); return SUB; }
"*"         { count(); return MUL; }
"/"         { count(); return DIV; }
"%"         { count(); return MOD; }
"="         { count(); return ASSIGN; }
"&&"        { count(); return AND; }
"||"        { count(); return OR; }
"!"         { count(); return NOT; }
"."         { count(); return DOT; }
"++"        { count(); return INCR; }
"--"        { count(); return DECR; }
";"         { count(); return SEMICOLON; }
","         { count(); return COMMA; }
"("         { count(); return LPAREN; }
")"         { count(); return RPAREN; }
"{"         { count(); return LBRACE; }
"}"         { count(); return RBRACE; }
"["         { count(); return LBRACK; }
"]"         { count(); return RBRACK; }

.           { count(); /* Ignore unrecognized characters */ }

%%

void count() {
    column_number += yyleng;
}