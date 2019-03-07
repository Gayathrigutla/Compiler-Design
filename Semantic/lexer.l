%%
[\v\f\t ] 		{}
[\n] 			{yylineno++;}
"{" 			{startblock(); return '{';}
"}" 			{endblock(); return '}';}
"(" 			{return '(';}
")" 			{return ')';}
"=" 			{return '=';}
";" 			{return ';';}
"," 			{return ',';}
"int" 			{yylval = strdup(yytext); return INT;}
"char" 			{yylval = strdup(yytext); return CHAR;}
"main" 			{yylval = strdup(yytext); return MAIN;}
"printf" 		{yylval = strdup(yytext); return PRINT;}
[0-9]+ 			{yylval = strdup(yytext); return INT_CONST;}
\"[^\n]*\" 		{yylval = strdup(yytext); return STR_CONST;}
[A-Za-z_]([A-Za-z_]|[0-9])*  	{yylval = strdup(yytext); return ID;}

%%

