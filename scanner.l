%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"  /* Include parser's token definitions */

// Global line number tracking is handled by %option yylineno
int column_num = 1;
int last_line_length = 0;

/* For standalone lexer mode & Parser error counting */
int token_count = 0;
int error_counter = 0;

FILE* token_file = NULL;
FILE* error_file = NULL;

/* Helper functions using yylineno */
void print_token(const char* type, const char* lexeme) {
    if (token_file) {
        fprintf(token_file, "Line %d: %s -> %s\n", yylineno, type, lexeme);
        token_count++;
    }
    column_num += strlen(lexeme);
}

void print_error(const char* lexeme) {
    if (token_file) {
        fprintf(token_file, "Line %d: ERROR -> %s\n", yylineno, lexeme);
    }
    if (error_file) {
        fprintf(error_file, "Line %d, ERROR -> %s (Invalid token)\n", 
                yylineno, lexeme);
    }
    error_counter++;
    column_num += strlen(lexeme);
}

void print_unterminated_error(const char* type, int start_line) {
    if (error_file) {
        fprintf(error_file, "Line %d: ERROR -> Unterminated %s\n", start_line, type);
    }
    error_counter++;
}
%}

/* Enable automatic line number tracking */
%option yylineno

/* regex patterns for tokens */
DIGIT           [0-9]
LETTER          [a-zA-Z]

/* special characters that aren't allowed in identifiers */
SPECIAL_CHAR    [@%_#&\?\~\`\:!\^\\\$\{\}\[\];,\.\*\/\+\-\=\<\>\|]

/* any identifier-like token that contains special characters anywhere */
INVALID_IDENTIFIER  ([a-zA-Z0-9]*{SPECIAL_CHAR}[a-zA-Z0-9]*)+|{DIGIT}+[a-zA-Z][a-zA-Z0-9]*

/* proper identifier: starts with a letter (lowercase or uppercase), can include digits */
IDENTIFIER      [a-zA-Z][a-zA-Z0-9]*

/* number types */
INTEGER         [+/-]?{DIGIT}+
FLOAT           [+/-]?{DIGIT}+\.{DIGIT}+
EXPONENTIAL     [+/-]?({INTEGER}|{FLOAT})[eE][+-]?{DIGIT}+

/* improper numbers */
INVALID_FLOAT_START    [+/-]?\.{DIGIT}+
INVALID_FLOAT_END      [+/-]?{DIGIT}+\.
INVALID_EXP            [+/-]?({DIGIT}+|{DIGIT}+\.{DIGIT}*)[eE][+-]?

WHITESPACE      [ \t]+
NEWLINE         \n

/* strings and chars with escape sequences */
STRING          \"([^\"\n\\]|\\.)*\"
CHAR            \'([^\'\n\\]|\\.)\'

/* forgot to close the quote */
UNTERM_STRING   \"([^\"\n\\]|\\.)*
UNTERM_CHAR     \'([^\'\n\\]|\\.)*

/* comments */
SINGLE_COMMENT  "//".*
MULTI_COMMENT   "/*"([^*]|\*+[^*/])*\*+"/"
UNTERM_MULTI_COMMENT  "/*"([^*]|\*+[^*/])*

/* incomplete operators */
INVALID_OP      "#"[^=+\-!]|"#"

%%

    /* Harry Potter themed keywords */
"numspell"          { print_token("KEYWORD", yytext); return NUMSPELL; }
"textspell"         { print_token("KEYWORD", yytext); return TEXTSPELL; }
"floatspell"        { print_token("KEYWORD", yytext); return FLOATSPELL; }
"truthcharm"        { print_token("KEYWORD", yytext); return TRUTHCHARM; }
"voidcharm"         { print_token("KEYWORD", yytext); return VOIDCHARM; }
"beginmagic"        { print_token("KEYWORD", yytext); return BEGINMAGIC; }
"returncharm"       { print_token("KEYWORD", yytext); return RETURNCHARM; }
"house"             { print_token("KEYWORD", yytext); return HOUSE; }
"ifcharm"           { print_token("KEYWORD", yytext); return IFCHARM; }
"elsecharm"         { print_token("KEYWORD", yytext); return ELSECHARM; }
"loopcharm"         { print_token("KEYWORD", yytext); return LOOPCHARM; }
"spellcycle"        { print_token("KEYWORD", yytext); return SPELLCYCLE; }
"breakcurse"        { print_token("KEYWORD", yytext); return BREAKCURSE; }
"skipcurse"         { print_token("KEYWORD", yytext); return SKIPCURSE; }
"reveal"            { print_token("KEYWORD", yytext); return REVEAL; }
"listen"            { print_token("KEYWORD", yytext); return LISTEN; }

    /* operators - multi-char first to avoid conflicts */
"#="                { print_token("OPERATOR", yytext); return EQ_OP; }
"#+"                { print_token("OPERATOR", yytext); return INC_OP; }
"#-"                { print_token("OPERATOR", yytext); return DEC_OP; }
"#!"                { print_token("OPERATOR", yytext); return NEQ_OP; }
"<="                { print_token("OPERATOR", yytext); return LE_OP; }
">="                { print_token("OPERATOR", yytext); return GE_OP; }
"&&"                { print_token("OPERATOR", yytext); return AND_OP; }
"||"                { print_token("OPERATOR", yytext); return OR_OP; }

"+"                 { print_token("OPERATOR", yytext); return PLUS; }
"-"                 { print_token("OPERATOR", yytext); return MINUS; }
"*"                 { print_token("OPERATOR", yytext); return MULT; }
"/"                 { print_token("OPERATOR", yytext); return DIV; }
"%"                 { print_token("OPERATOR", yytext); return MOD; }
"="                 { print_token("OPERATOR", yytext); return ASSIGN_OP; }
"<"                 { print_token("OPERATOR", yytext); return LT_OP; }
">"                 { print_token("OPERATOR", yytext); return GT_OP; }
"!"                 { print_token("OPERATOR", yytext); return NOT_OP; }

    /* punctuation marks */
"$"                 { print_token("PUNCTUATOR", yytext); return DOLLAR; }
"{"                 { print_token("PUNCTUATOR", yytext); return LBRACE; }
"}"                 { print_token("PUNCTUATOR", yytext); return RBRACE; }
"("                 { print_token("PUNCTUATOR", yytext); return LPAREN; }
")"                 { print_token("PUNCTUATOR", yytext); return RPAREN; }
"["                 { print_token("PUNCTUATOR", yytext); return LBRACKET; }
"]"                 { print_token("PUNCTUATOR", yytext); return RBRACKET; }
";"                 { print_token("PUNCTUATOR", yytext); return SEMICOLON; }
","                 { print_token("PUNCTUATOR", yytext); return COMMA; }
"."                 { print_token("PUNCTUATOR", yytext); return DOT; }

    /* numbers */
{EXPONENTIAL}       { print_token("NUMBER_EXP", yytext); return NUMBER_EXP; }
{FLOAT}             { print_token("NUMBER_FLOAT", yytext); return NUMBER_FLOAT; }
{INTEGER}           { print_token("NUMBER_INT", yytext); return NUMBER_INT; }

{INVALID_FLOAT_START}   { print_error(yytext); }
{INVALID_FLOAT_END}     { print_error(yytext); }
{INVALID_EXP}           { print_error(yytext); }

{STRING}            { print_token("STRING_LITERAL", yytext); return STRING_LITERAL; }
{CHAR}              { print_token("CHAR_LITERAL", yytext); return CHAR_LITERAL; }

    /* unclosed strings/chars */
{UNTERM_STRING}     { 
                        print_error(yytext); 
                        if (error_file) {
                            fprintf(error_file, "Line %d: WARNING -> Unterminated string literal\n", yylineno);
                        }
                    }
{UNTERM_CHAR}       { 
                        print_error(yytext); 
                        if (error_file) {
                            fprintf(error_file, "Line %d: WARNING -> Unterminated character literal\n", yylineno);
                        }
                    }

    /* skip comments */
{SINGLE_COMMENT}    { column_num += strlen(yytext); }
{MULTI_COMMENT}     { column_num = 1; }

{UNTERM_MULTI_COMMENT}  {
                            int start_line = yylineno;
                            print_unterminated_error("multi-line comment", start_line);
                        }

    /* check for bad identifiers before accepting good ones */
{INVALID_IDENTIFIER}      { print_error(yytext); }

{IDENTIFIER}        { print_token("IDENTIFIER", yytext); return IDENTIFIER; }

{INVALID_OP}        { print_error(yytext); }

{WHITESPACE}        { column_num += strlen(yytext); }

{NEWLINE}           { 
                        last_line_length = column_num;
                        column_num = 1; 
                    }

.                   { print_error(yytext); }

<<EOF>>             { return 0; }

%%

int yywrap() {
    return 1;
}