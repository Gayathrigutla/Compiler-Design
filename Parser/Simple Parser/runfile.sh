#rm a.out
yacc my.y
lex my.l
gcc y.tab.c -ll -ly -w -std=c99
