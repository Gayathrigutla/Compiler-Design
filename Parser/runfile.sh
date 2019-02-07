#!/bin/bash
rm ./a.out
yacc parser.y
lex lexer.l
gcc y.tab.c -ll -ly -w -std=c99

