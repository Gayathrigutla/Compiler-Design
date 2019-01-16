/*
Namrata Ladda, 16CO121
Mehnaz Yunus, 16CO124
Sharanya Kamath, 16CO140

Lexical Analyser
*/
%x comment
%{
    
    #include<stdio.h>
    #include<string.h>
    char bstack[100];
    int btop = -1;
    int nested_comment_stack = 0;
    int line = 0;

    struct hashtable{
        char name[100];
        char type[100];
        int len;
    }table[1000];

    int Hash(char *s){
        int mod = 1001;
        int l = strlen(s), val = 0, i;
        for(i = 0; i < l; i++){
            val = val * 10 + (s[i]-'A');
            val = val % mod;
            while(val < 0){
                val += mod;
            }
        }
        return val;
    }

    void insert_symbol(char *lexeme, char *token_name){
        
        int l1 = strlen(lexeme);
        int l2 = strlen(token_name);
        int v = Hash(lexeme);
        if(table[v].len == 0){
            strcpy(table[v].name, lexeme);
            strcpy(table[v].type, token_name);
            
            table[v].len = strlen(lexeme);
            return;
        }

        if(strcmp(table[v].name,lexeme) == 0)
        return;

        int i, pos = 0;

        for (i = 0; i < 1001; i++){
            if(table[i].len == 0){
                pos = i;
                break;
            }
        }

        strcpy(table[pos].name, lexeme);
        strcpy(table[pos].type, token_name);
        table[pos].len = strlen(lexeme);

    }

    void print(){
        int i;
        for(i = 0;i < 1001; i++){
            if(table[i].len == 0){
                continue;
            }
            printf("%15s \t %40s\n",table[i].name,table[i].type);
        }
    }

%}

LEQ <=
GEQ >=
EQ =
LES <
GRE >
PLUS \+
INCREMENT \+\+
DECREMENT \-\-
MINUS \-
MULT \*
DIV \/
REM %
AND &
OR \|
XOR \^
NOT \~

PREPROCESSOR #(include<.*>|define.*|ifdef|endif|if|else|ifndef|undef|pragma)
STRING \".*\"|\'.*\'
WRONG_STRING \"[^"\n]*|\'[^'\n]* 
SINGLELINE \/\/.*
MULTILINE "/*"([^*]|\*+[^*/])*\*+"/"
KEYWORD auto|const|default|enum|extern|register|return|sizeof|static|struct|typedef|union|volatile|break|continue|goto|else|switch|if|case|default|for|do|while|char|double|float|int|long|short|signed|unsigned|void
IDENTIFIER [a-z|A-Z]([a-z|A-Z]|[0-9])*
NUMBER_CONSTANT [1-9][0-9]*(\.[0-9]+)?|0(\.[0-9]+)? 
OPERATOR {INCREMENT}|{DECREMENT}|{PLUS}|{MINUS}|{MULT}|{DIV}|{EQ}
COMPARISON {LEQ}|{GEQ}|{LES}|{GRE}
BITWISE {XOR}|{REM}|{AND}|{OR}|{NOT}
INVALID [^\n\t ]
WRONG_ID ([0-9]+[a-zA-Z][a-zA-Z0-9]*)


%%
\n line++;
[\t ] ;
; {printf("%s \t---- SEMICOLON DELIMITER\n", yytext);}
, {printf("%s \t---- COMMA DELIMITER\n", yytext);}
\{ {printf("%s \t---- PARENTHESIS\n", yytext);
	if(btop==-1){
		bstack[0]='{'; btop=1;}
	else {bstack[btop]='{';
	btop++;
    }
	}
\} {printf("%s \t---- PARENTHESIS\n", yytext);
	if(bstack[btop-1]!='{')
		printf("ERROR: UNBALANCED PARENTHESIS AT LINE NUMBER: %d\n",line);
	btop--;
	}
\( {printf("%s \t---- PARENTHESIS\n", yytext);
	if(btop==-1){
		bstack[0]='('; btop=1;}
	else {
        bstack[btop]='(';
    	btop++;
    }
	}
\) {printf("%s \t---- PARENTHESIS\n", yytext);
	if(bstack[btop-1]!='(')
		printf("ERROR: UNBALANCED PARENTHESIS AT LINE NUMBER: %d\n",line);
	btop--;
	}
\[ {printf("%s \t---- PARENTHESIS\n", yytext);
	if(btop==-1){
		bstack[0]='['; btop=1;}
	else {
        bstack[btop]='[';
    	btop++;
    }
	}
\] {printf("%s \t---- PARENTHESIS\n", yytext);
	if(bstack[btop-1]!='[')
		printf("ERROR: UNBALANCED PARENTHESIS AT LINE NUMBER: %d\n",line);
	btop--;
	}
\\ {printf("%s \t- FSLASH\n", yytext);}
\. {printf("%s \t- DOT DELIMITER\n", yytext);}

"/*"                    {BEGIN(comment); nested_comment_stack=1; yymore();}
<comment><<EOF>>        {printf("\nERROR: MULTILINE COMMENT: \""); yyless(yyleng-2); ECHO; printf("\", NOT TERMINATED AT LINE NUMBER: %d",line); yyterminate();}
<comment>"/*"           {nested_comment_stack++; yymore();}
<comment>.              {yymore();}
<comment>\n             {yymore();line++;}
<comment>"*/"           {nested_comment_stack--;
                        if(nested_comment_stack<0)
                        {
                          printf("\n \"%s\"\t---- ERROR: UNBALANCED COMMENT AT LINE NUMBER: %d.", yytext, line);
                          yyterminate();
                        }
                        else if(nested_comment_stack==0)
                        {
                          BEGIN(INITIAL);
                        }
                        else
                          yymore();
                        }

"*/"                    {printf("%s \t---- ERROR: UNINITIALISED COMMENT AT LINE NUMBER: %d\n", yytext,line); yyterminate();}

"//".*                  {printf("%s \t---- SINGLE LINE COMMENT\n", yytext);}

{PREPROCESSOR} printf("%s \t---- PREPROCESSOR\n", yytext);
{STRING} {printf("%s \t---- STRING \n", yytext); insert_symbol(yytext,"STRING CONSTANT");}
{MULTILINE} {printf("%s \t---- MULTI LINE COMMENT\n", yytext);}
{KEYWORD} {printf("%s \t---- KEYWORD\n", yytext); insert_symbol(yytext, "KEYWORD");}
{IDENTIFIER} {printf("%s \t---- IDENTIFIER\n", yytext); insert_symbol(yytext, "IDENTIFIER");}
{WRONG_ID} {printf("%s \t---- ERROR: ILL-FORMED IDENTIFIER\n", yytext);}
{NUMBER_CONSTANT} {printf("%s \t---- NUMBER CONSTANT\n", yytext); insert_symbol(yytext, "NUMBER CONSTANT");}
{OPERATOR} {printf("%s \t---- ARITHMETIC OPERATOR\n", yytext);} 
{BITWISE} {printf("%s \t---- BITWISE OPERATOR\n", yytext);}
{COMPARISON} {printf("%s \t---- COMPARISON OPERATOR\n", yytext);}
{WRONG_STRING} {printf("%s \t---- ERROR: UNTERMINATED STRING AT LINE NUMBER: %d\n", yytext,line);}
{INVALID} {printf("%s \t---- ERROR: ILL-FORMED IDENTIFIER AT LINE NUMBER: %d\n", yytext,line); }

%%

int yywrap(){
    return 1;
}

int main(){

    int i;
    for (i = 0; i < 1001; i++){
        table[i].len=0;
    }
    yyin = fopen("test-1.c","r");
    yylex();
    printf("\n\n----------------------------------------------------------------------------\n\t\t\t\tSYMBOL TABLE\n----------------------------------------------------------------------------\n");   
	printf("\tLexeme \t\t\t\t\t\tToken\n"); 
	printf("----------------------------------------------------------------------------\n");
    print();
}


