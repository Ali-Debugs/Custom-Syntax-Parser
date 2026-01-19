%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);

extern FILE *yyin;
extern int yylineno;
extern char *yytext;

int error_count = 0; 
%}

%error-verbose

%token NUMSPELL TEXTSPELL FLOATSPELL TRUTHCHARM VOIDCHARM
%token BEGINMAGIC RETURNCHARM HOUSE
%token IFCHARM ELSECHARM LOOPCHARM SPELLCYCLE
%token BREAKCURSE SKIPCURSE REVEAL LISTEN
%token INC_OP DEC_OP
%token LE_OP GE_OP EQ_OP NEQ_OP AND_OP OR_OP
%token PLUS MINUS MULT DIV MOD ASSIGN_OP LT_OP GT_OP NOT_OP
%token DOLLAR LBRACE RBRACE LPAREN RPAREN LBRACKET RBRACKET SEMICOLON COMMA DOT
%token NUMBER_INT NUMBER_FLOAT NUMBER_EXP
%token IDENTIFIER STRING_LITERAL CHAR_LITERAL

/* Precedence Rules */
%right ASSIGN_OP
%left OR_OP
%left AND_OP
%left EQ_OP NEQ_OP LT_OP GT_OP LE_OP GE_OP
%left PLUS MINUS
%left MULT DIV MOD
%right NOT_OP INC_OP DEC_OP
%nonassoc UMINUS

%start Program

%%

/* ========== MAIN PROGRAM ========== */
Program:
    FunctionList
    ;

FunctionList:
    /* empty */
    | FunctionList Function
    | FunctionList HouseDefinition
    | FunctionList GlobalDeclaration
    ;

/* ========== HOUSE STRUCT ========== */
HouseDefinition:
    HOUSE IDENTIFIER LBRACE HouseBody RBRACE
    ;

HouseBody:
    /* empty */
    | HouseBody HouseMember
    ;

HouseMember:
    DataType IDENTIFIER DOLLAR
    ;

/* ========== GLOBAL DECLARATIONS ========== */
GlobalDeclaration:
    DataType IDENTIFIER DOLLAR
    | DataType IDENTIFIER ASSIGN_OP Expression DOLLAR
    ;

/* ========== FUNCTIONS ========== */
Function:
    DataType IDENTIFIER LPAREN ParameterList RPAREN Block
    | VOIDCHARM IDENTIFIER LPAREN ParameterList RPAREN Block
    | VOIDCHARM BEGINMAGIC LPAREN RPAREN Block
    ;

ParameterList:
    /* empty */
    | Parameters
    ;

Parameters:
    Parameter
    | Parameters COMMA Parameter
    ;

Parameter:
    DataType IDENTIFIER
    ;

/* ========== STATEMENTS ========== */
Block:
    LBRACE StatementList RBRACE
    ;

StatementList:
    /* empty */
    | StatementList Statement
    ;

Statement:
    Declaration DOLLAR
    | Expression DOLLAR
    | ConditionalStmt
    | LoopStmt
    | OutputStmt DOLLAR
    | InputStmt DOLLAR
    | ReturnStmt DOLLAR
    | BreakStmt DOLLAR
    | ContinueStmt DOLLAR
    | Block
    ;

/* ========== DECLARATIONS ========== */
Declaration:
    DataType IDENTIFIER OptionalInit
    ;

OptionalInit:
    /* empty */
    | ASSIGN_OP Expression
    ;

/* ========== CONTROL FLOW ========== */
ConditionalStmt:
    IFCHARM LPAREN Expression RPAREN Block
    | IFCHARM LPAREN Expression RPAREN Block ELSECHARM Block
    ;

LoopStmt:
    LOOPCHARM LPAREN Expression RPAREN Block
    | SPELLCYCLE LPAREN ForInit DOLLAR Expression DOLLAR Expression RPAREN Block
    ;

ForInit:
    Declaration
    | Expression
    ;

OutputStmt:
    REVEAL Expression
    ;

InputStmt:
    LISTEN IDENTIFIER
    ;

ReturnStmt:
    RETURNCHARM Expression
    | RETURNCHARM
    ;

BreakStmt:
    BREAKCURSE
    ;

ContinueStmt:
    SKIPCURSE
    ;

/* ========== EXPRESSIONS ========== */
Expression:
    Expression ASSIGN_OP Expression
    | Expression OR_OP Expression
    | Expression AND_OP Expression
    | Expression EQ_OP Expression
    | Expression NEQ_OP Expression
    | Expression LT_OP Expression
    | Expression GT_OP Expression
    | Expression LE_OP Expression
    | Expression GE_OP Expression
    | Expression PLUS Expression
    | Expression MINUS Expression
    | Expression MULT Expression
    | Expression DIV Expression
    | Expression MOD Expression
    | NOT_OP Expression
    | MINUS Expression %prec UMINUS
    | IDENTIFIER INC_OP 
    | IDENTIFIER DEC_OP 
    | NUMBER_INT
    | NUMBER_FLOAT
    | NUMBER_EXP
    | IDENTIFIER 
    | STRING_LITERAL 
    | CHAR_LITERAL 
    | FunctionCall
    | LPAREN Expression RPAREN
    ;

FunctionCall:
    IDENTIFIER LPAREN ArgumentList RPAREN
    ;

ArgumentList:
    /* empty */
    | ExpressionList
    ;

ExpressionList:
    Expression
    | ExpressionList COMMA Expression
    ;

/* ========== TYPES ========== */
DataType:
    NUMSPELL 
    | TEXTSPELL 
    | FLOATSPELL 
    | TRUTHCHARM 
    ;

%%

/* ========================================================== */
/* ERROR HANDLING LOGIC */
/* ========================================================== */

void yyerror(const char *s) {
    error_count++; 
    
    fprintf(stderr, "\n========================================\n");
    fprintf(stderr, "LINE NUMBER: %d\n", yylineno);
    fprintf(stderr, "ERROR: %s\n", s);
    fprintf(stderr, "TOKEN: %s\n", yytext);
    fprintf(stderr, "========================================\n");
}

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Error: Cannot open file %s\n", argv[1]);
            return 1;
        }
    }
    
    int parse_status = yyparse();
    
    fprintf(stderr, "\n========================================\n");
    fprintf(stderr, "SYNTAX ANALYSIS COMPLETE\n");
    fprintf(stderr, "========================================\n");
    
    if (parse_status == 0 && error_count == 0) {
        fprintf(stderr, "Status: Syntax analysis successful\n");
        printf("Syntax analysis successful\n");
        fprintf(stderr, "========================================\n");
        return 0;
    } else {
        fprintf(stderr, "Status: Failed\n");
        fprintf(stderr, "Total Errors Found: %d\n", error_count);
        fprintf(stderr, "========================================\n");
        return 1;
    }
}