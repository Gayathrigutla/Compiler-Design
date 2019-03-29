#rm a.out
yacc icg.y
lex lexer.l
gcc y.tab.c -ll -ly -w -std=c99
