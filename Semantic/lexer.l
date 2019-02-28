%%
[\t ] {}
[\n] {yylineno++;}
"{" {startblock(); return '{';}
"}" {endblock(); return '}';}
"(" {return '(';}
")" {return ')';}
"=" {return '=';}
";" {return ';';}
"," {return ',';}
"int" {return INT;}
"char" {return CHAR;}
"main" {return MAIN;}
"printf" {return PRINT;}
[0-9]+ {return INT_CONST;}
\"[^\n]*\" {return STR_CONST;}
[A-Za-z_][A-Za-z_0-9]* {return ID;}

%%

