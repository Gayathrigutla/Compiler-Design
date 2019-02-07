%{
int yylineno;
#include <stdio.h>
%}

%%
\n  	{ yylineno++; }
"/*"	{ multicomment(); }
"//"	{ singlecomment(); }
"#include<"([A-Za-z_])*".h>" {}
"#define"([ ])""([A-Za-z_])""([A-Za-z_]|[0-9])*""([ ])""([0-9])+"" 					{ }
"#define"([ ])""([A-Za-z_]([A-Za-z_]|[0-9])*)""([ ])""(([0-9]+)\.([0-9]+))"" 		{ }
"#define"([ ])""([A-Za-z_]([A-Za-z_]|[0-9])*)""([ ])""([A-Za-z_]([A-Za-z_]|[0-9])*)"" 	{ }

\"[^\n]*\" 				{ yylval = yytext; return STRING_CONSTANT; }
\'[A-Za-z_]\' 				{ yylval = yytext; return CHAR_CONSTANT; }
[0-9]+ 					{ yylval = yytext; return INT_CONSTANT; }
([0-9]+)\.([0-9]+) 			{ yylval = yytext; return FLOAT_CONSTANT; }
([0-9]+)\.([0-9]+)([eE][-+]?[0-9]+)? 	{ yylval = yytext; return FLOAT_CONSTANT; }

"sizeof"				{  return SIZEOF; }
"++"			{  return INC_OP; }
"--"			{  return DEC_OP; }
"<<"			{  return LEFT_OP; }
">>"			{  return RIGHT_OP; }
"<="			{  return LE_OP; }
">="			{  return GE_OP; }
"=="			{  return EQ_OP; }
"!="			{  return NE_OP; }
"&&"			{  return AND_OP; }
"||"			{  return OR_OP; }
"*="			{  return MUL_ASSIGN; }
"/="			{  return DIV_ASSIGN; }
"%="			{  return MOD_ASSIGN; }
"+="			{  return ADD_ASSIGN; }
"-="			{  return SUB_ASSIGN; }
"<<="			{  return LEFT_ASSIGN; }
">>="			{  return RIGHT_ASSIGN; }
"&="			{  return AND_ASSIGN; }
"^="			{  return XOR_ASSIGN; }
"|="			{  return OR_ASSIGN; }
"char"			{  yylval = yytext; return CHAR; }
"short"			{  yylval = yytext; return SHORT; }
"int"			{  yylval = yytext; return INT; }
"float"			{  yylval = yytext; return FLOAT; }
"long"			{  yylval = yytext; return LONG; }
"signed"		{  yylval = yytext; return SIGNED; }
"unsigned"		{  yylval = yytext; return UNSIGNED; }
"void"			{  yylval = yytext; return VOID; }
"if"			{  return IF; }
"else"			{  return ELSE; }
"while"			{  return WHILE; }
"break"			{  return BREAK; }
"return"		{  return RETURN; }
";"				{  return(';'); }
("{")			{  return('{'); }
("}")			{  return('}'); }
","				{  return(','); }
":"				{  return(':'); }
"="				{  return('='); }
"("				{  return('('); }
")"				{  return(')'); }
("["|"<:")		{  return('['); }
("]"|":>")		{  return(']'); }
"."				{  return('.'); }
"&"				{  return('&'); }
"!"				{  return('!'); }
"~"				{  return('~'); }
"-"				{  return('-'); }
"+"				{  return('+'); }
"*"				{  return('*'); }
"/"				{  return('/'); }
"%"				{  return('%'); }
"<"				{  return('<'); }
">"				{  return('>'); }
"^"				{  return('^'); }
"|"				{  return('|'); }
"?"				{  return('?'); }
[A-Za-z_]([A-Za-z_]|[0-9])*    		{  yylval = yytext; return IDENTIFIER;  }
[ \t\v\n\f]		{  }
.			{ }
%%
yywrap()
{
	return(1);
}

multicomment()
{
	char c, c1;
	while ((c = input()) != '*' && c != 0);
	c1=input();
	if(c=='*' && c1=='/')
	{
		c=0;
	}
	if (c != 0)
		putchar(c1);
}

singlecomment()
{
	char c;
	while(c=input()!='\n');
	if(c=='\n')
		c=0;
	if(c!=0)
		putchar(c);
}
