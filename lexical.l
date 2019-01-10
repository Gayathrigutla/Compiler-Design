%{
  #include<stdio.h>

  int line=0;
%}


keywords auto|double|int|struct|long|enum|register|typedef|char|extern|return|union|signed|void|static|sizeof|volatile|const|float|shortauto|double|int|struct|long|enum|register|typedef|char|extern|return|union|signed|void|static|sizeof|volatile|const|float|short|unsigned
jump break|continue|goto
conditional else|switch|if|case|default
loop for|do|while
id [a-zA-Z][a-zA-Z0-9_]*
var [ \t]*(unsigned|signed)?(void|int|char|short|long|float|double){white_space}+{identifier}[ \t]*
wrong_id ([0-9]|!|@|#|$|%)+([a-zA-Z0-9])+
operator [\+\-\*\/\%]
bitwise [\|\&\^\~]

%%
end {return 0;}
\n line++;
#include[ ]*<[^>]+> {}

{keywords} {ECHO; printf(" is a keyword\n");}
{jump} {printf(" is a jump keyword\n");}
{conditional} {ECHO; printf(" is a conditional keyword\n");}
{loop} {ECHO; printf(" is a loop keyword\n");}
{id} {ECHO; printf(" is an identifier\n");}
{operator} {ECHO; printf(" is an arithmetic operator\n");}
{bitwise} {ECHO; printf(" is a bitwise operator\n");}
{wrong_id} {printf("Invalid identifier on line no. %d\n",line);}

%%

int yywrap(){return 1;}
int main()
{
  yylex();
  return 0;
}
