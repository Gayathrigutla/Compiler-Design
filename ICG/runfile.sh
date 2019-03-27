#rm a.out
yacc semantic.y
lex my.l
gcc y.tab.c -ll -ly -w -std=c99
