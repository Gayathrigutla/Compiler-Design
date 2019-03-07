%{
int yylineno;
#include<stdio.h>
%}

%%
\n {yylineno++;}
"/*" {multiline();}
"//" {while(input() != '\n');}

#include[" "]*<[a-zA-Z]+\.h> {}

#include[" "]*\"[a-zA-Z]+\.h\" {}


\"[^\n]*\" { yylval = yytext; return STRING_CONST; }
[0-9]+ { yylval = yytext; return INT_CONST; }
[0-9]+\.[0-9]+ { yylval = yytext; return FLOAT_CONST; }

"{" { yylval = yytext; return ('{'); }
"}" { yylval = yytext; return ('}'); }
"(" { yylval = yytext; return ('('); }
")" { yylval = yytext; return (')'); }
"=" { yylval = yytext; return ('='); }
";" { yylval = yytext; return (';'); }
"+" { yylval = yytext; return ('+'); }
"-" { yylval = yytext; return ('-'); }
"*" { yylval = yytext; return ('*'); }
"/" { yylval = yytext; return ('/'); }
"%" { yylval = yytext; return ('%'); }
"<" { yylval = yytext; return ('<'); }
">" { yylval = yytext; return ('>'); }
"," { yylval = yytext; return (','); }
"+=" { yylval = yytext; return ADD_ASSIGN; }

"int" { yylval = yytext; return INT; }
"for" { yylval = yytext; return FOR; }
"return" { yylval = yytext; return RETURN; }
"printf" { yylval = yytext; return PRINTF; }

[A-Za-z_]([A-Za-z0-9_])* {yylval = yytext; return IDENTIFIER; }

[ \n\t] { }
. { }

%%

int yywrap() {
return 1;
}

void multiline() {
	char c, c1;
	while(((c=input()) != '*') && c != 0);
	c1 = input();
	if(!(c == '*' && c1 == '/'))
		putchar(c1);
}


