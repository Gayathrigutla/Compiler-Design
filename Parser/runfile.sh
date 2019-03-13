#!/bin/bash
#rm ./a.out
>>>>>>> 88e79a6a1627804d5fa1cfd74f101a3013a87b4f
yacc parser.y
lex lexer.l
gcc y.tab.c -ll -ly -w -std=c99

