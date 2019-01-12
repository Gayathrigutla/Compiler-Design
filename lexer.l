%x comment
%{
    
    #include<stdio.h>
    #include<string.h>
    int pstack[100];
   int ptop=-1;
   int cstack[100];
   int ctop=-1;
   
   int nested_comment_stack=0;
    int line=0;
    struct hashtable{
        char name[105];
        char type[105];
        int len;
    }table[1005];

    struct consttable{
        char name[105];
        char type[105];
        int len;
    }ctable[1005];
    

    int Hash(char *s){
        int mod=1001;
        int l=strlen(s),val=0,i;
        for (i=0;i<l;i++){
            val=val*10+(s[i]-'A');
            val=val%mod;
            while(val<0){
                val+=mod;
            }
        }
        return val;
    }

    void insert(char *arg1,char *arg2){
        
        int l1=strlen(arg1);
        int l2=strlen(arg2);
        int v=Hash(arg1);
        if(table[v].len==0){
            strcpy(table[v].name,arg1);
            strcpy(table[v].type,arg2);
            
            table[v].len=strlen(arg1);
            return ;
        }

        if(strcmp(table[v].name,arg1)==0)
        return ;

        int i,pos=0;

        for (i=0;i<1001;i++){
            if(table[i].len==0){
                pos=i;
                break;
            }
        }

        strcpy(table[pos].name,arg1);
        strcpy(table[pos].type,arg2);
        table[pos].len=strlen(arg1);


    }

    void insert2(char *arg1,char *arg2){
        
        int l1=strlen(arg1);
        int l2=strlen(arg2);
        int v=Hash(arg1);
        if(ctable[v].len==0){
            strcpy(ctable[v].name,arg1);
            strcpy(ctable[v].type,arg2);
            
            ctable[v].len=strlen(arg1);
            return ;
        }

        if(strcmp(ctable[v].name,arg1)==0)
        return ;

        int i,pos=0;

        for (i=0;i<1001;i++){
            if(ctable[i].len==0){
                pos=i;
                break;
            }
        }

        strcpy(ctable[pos].name,arg1);
        strcpy(ctable[pos].type,arg2);
        ctable[pos].len=strlen(arg1);
    }

    void print(){
        int i;

        for ( i=0;i<1001;i++){
            if(table[i].len==0){
                continue;
            }

            printf("%s \t %s\n",table[i].name,table[i].type);
        }
    }

    void print2(){
        int i;

        for ( i=0;i<1001;i++){
            if(ctable[i].len==0){
                continue;
            }

            printf("%s \t %s\n",ctable[i].name,ctable[i].type);
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

PREPROCESSOR #include<.*>|#define.*
STRING \".*\"|\'.*\'
WRONG_STRING \"[^"\n]*|\'[^'\n]* 
SINGLELINE \/\/.*
ARRAY .*\[[0-9]+\]
MULTILINE "/*"([^*]|\*+[^*/])*\*+"/"
KEYWORD auto|const|default|enum|extern|register|return|sizeof|static|struct|typedef|union|volatile|main 
DATATYPE char|double|float|int|long|short|signed|unsigned|void
IDENTIFIER [a-z|A-Z]([a-z|A-Z]|[0-9])*
NUMBER_CONSTANT [1-9][0-9]*|0 
OPERATOR {INCREMENT}|{DECREMENT}|{PLUS}|{MINUS}|{MULT}|{DIV}|{EQ}
COMPARISON {LEQ}|{GEQ}|{LES}|{GRE}
BITWISE {XOR}|{REM}|{AND}|{OR}|{NOT}
INVALID (.?)
JUMP break|continue|goto
CONDITIONAL else|switch|if|case|default
LOOP for|do|while

%%
\n line++;
[\t] ;
; {printf("%s \t- SEMICOLON DELIMITER\n", yytext);}
, {printf("%s \t- COMMA DELIMITER\n", yytext);}
\{ {printf("%s \t- OPENING BRACES\n", yytext);}
\} {printf("%s \t- CLOSING BRACES\n", yytext);}
\( {printf("%s \t- OPENING BRACKETS\n", yytext);}
\) {printf("%s \t- CLOSING BRACKETS\n", yytext);}
\\ {printf("%s \t- FSLASH\n", yytext);}
\. {printf("%s \t- DOT DELIMITER\n", yytext);}
"/*"                    {BEGIN(comment); nested_comment_stack=1; yymore();}
<comment><<EOF>>        {printf("\nMULTILINE COMMENT: \""); yyless(yyleng-2); ECHO; printf("\", NOT TERMINATED AT LINE NUMBER: %d",line); yyterminate();}
<comment>"/*"           {nested_comment_stack++; yymore();}
<comment>.              {yymore();}
<comment>\n             {yymore();line++;}
<comment>"*/"           {nested_comment_stack--;
                        if(nested_comment_stack<0)
                        {
                          printf("\n \"%s\"\t- COMMENT NOT BALANCED AT LINE NUMBER: %d.", yytext, line);
                          yyterminate();
                        }
                        else if(nested_comment_stack==0)
                        {
                          BEGIN(INITIAL);
                        }
                        else
                          yymore();
                        }

"*/"                    {printf("%s \t- UNINITIALISED COMMENT AT LINE NUMBER: %d\n", yytext,line); yyterminate();}

"//".*                  {printf("%s \t- SINGLE LINE COMMENT\n", yytext);}

{PREPROCESSOR} {printf("%s \t- PREPROCESSOR\n", yytext); insert(yytext, "PREPROCESSOR");}
{STRING} {printf("%s \t- STRING CONSTANT\n", yytext); insert2(yytext,"STRING CONSTANT");}
{ARRAY} {printf("%s \t- ARRAY DECLARATION\n", yytext);}

{MULTILINE} {printf("%s \t- MULTI LINE COMMENT\n", yytext);}
{DATATYPE}[ ]+{IDENTIFIER}[ ]+\({KEYWORD}[ ]+{IDENTIFIER}\) {printf("%s \t- FUNCTION\n", yytext);}
{KEYWORD} {printf("%s \t- KEYWORD\n", yytext); insert(yytext, "KEYWORD");}
{DATATYPE} {printf("%s \t- DATATYPE\n", yytext); insert(yytext, "DATATYPE");}
{JUMP} {printf("%s \t- JUMP KEYWORD\n", yytext); insert(yytext, "JUMP");}
{CONDITIONAL} {printf("%s \t- CONDITIONAL KEYWORD\n", yytext); insert(yytext, "CONDITIONAL");}
{LOOP} {printf("%s \t- LOOP KEYWORD\n", yytext); insert(yytext, "LOOP");}
{IDENTIFIER} {printf("%s \t- IDENTIFIER\n", yytext); insert(yytext, "IDENTIFIER");}

{NUMBER_CONSTANT} {printf("%s \t- NUMBER CONSTANT\n", yytext); insert2(yytext, "NUMBER CONSTANT");}

{OPERATOR} {printf("%s \t- ARITHMETIC OPERATOR\n", yytext);} 
{BITWISE} {printf("%s \t- BITWISE OPERATOR\n", yytext);}
{COMPARISON} {printf("%s \t- COMPARISON OPERATOR\n", yytext);}
{WRONG_STRING} {printf("%s \t\t- WRONG STRING CONSTANT AT LINE NUMBER: %d\n", yytext,line);}

%%

int main(){

    int i;
    for (i=0;i<1001;i++){
        table[i].len=0;
    }
    yyin=fopen("test-1.c","r");
    yylex();
    printf("\n\nSYMBOL TABLE\n\n");
    
    print();

    printf("\n\nCONSTANT TABLE\n\n");
    print2();
}

int yywrap(){
    return 1;
}
