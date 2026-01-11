# Harry Potter Themed Compiler

A **lexical and syntax analyzer** for a Harry Potter-inspired language using **Flex** and **Bison**. Recognizes magical keywords, operators, and statements.

---

## Features

- **Lexer**: keywords (`numspell`, `textspell`, `floatspell`, `truthcharm`, etc.), identifiers, numbers, strings/chars, operators. Detects invalid tokens, bad numbers, unclosed strings/chars, and comments.
- **Parser**: functions, houses (struct-like), variables, loops, conditionals, expressions. Syntax-only with detailed error reporting.
- Outputs `tokens.txt` (tokens) and `errors.log` (errors).

---

## Requirements

- C Compiler (GCC)  
- **Flex**  
- **Bison**

---

## Compilation

```bash
bison -d parser.y
flex scanner.l
gcc parser.tab.c lex.yy.c -o parser
