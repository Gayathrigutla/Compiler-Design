#rm a.out
yacc semantic.y
lex lexer.l
gcc y.tab.c -ll -ly -w -std=c99
