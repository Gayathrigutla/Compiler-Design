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


\"[^\n]*\" { yylval = strdup(yytext); return STRING_CONST; }
[0-9]+ { yylval = strdup(yytext); return INT_CONST; }
[0-9]+\.[0-9]+ { yylval = strdup(yytext); return FLOAT_CONST;}

"{" { startBlock(); yylval = strdup(yytext); return ('{'); }
"}" { endBlock(); yylval = strdup(yytext); return ('}'); }
"(" { yylval = strdup(yytext); return ('('); }
")" { yylval = strdup(yytext); return (')'); }
"=" { yylval = strdup(yytext); return ('='); }
";" { yylval = strdup(yytext); return (';'); }
"+" { yylval = strdup(yytext); return ('+'); }
"-" { yylval = strdup(yytext); return ('-'); }
"*" { yylval = strdup(yytext); return ('*'); }
"/" { yylval = strdup(yytext); return ('/'); }
"%" { yylval = strdup(yytext); return ('%'); }
"<" { yylval = strdup(yytext); return ('<'); }
">" { yylval = strdup(yytext); return ('>'); }
"," { yylval = strdup(yytext); return (','); }
"+=" { yylval = strdup(yytext); return ADD_ASSIGN; }

"int" { yylval = strdup(yytext); return INT; }
"float" { yylval = strdup(yytext); return FLOAT; }
"void" { yylval = strdup(yytext); return VOID; }
"for" { yylval = strdup(yytext); return FOR; }
"return" { yylval = strdup(yytext); return RETURN; }
"printf" { yylval = strdup(yytext); return PRINTF; }
"while" { yylval = strdup(yytext); return WHILE; }

[A-Za-z_]([A-Za-z0-9_])* {yylval = strdup(yytext); return IDENTIFIER; }

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


