%left '='
%token ID MAIN
%token INT INT_CONST STR_CONST PRINT CHAR 
%token RETURN VOID
%start start_state
%glr-parser
%{
#include<stdio.h>
#include<string.h>
int stack=-1;
int end[1000];
int i=0;
extern int yylineno;
struct sym{
    char datatype[100];
    char identifier[100];
    int scope;
}table[1000];

void insert(char* datatype,char* identifier,int scope)
{
    strcpy(table[i].datatype,datatype);
    strcpy(table[i].identifier,identifier);
    table[i].scope=scope;
    i++;
}

int returnscope(char* identifier)
{
    int j;
    for(j=0;j<i;j++)
    {
        if(!strcmp(table[j].identifier,identifier))
            return table[j].scope;
     }
     return -1;
}
/*char* returntype(char* identifier)
{
	int j;
    for(j=0;j<i;j++)
    {
        if(!strcmp(table[j].identifier,identifier))
            return table[j].datatype;
     }
}*/
%}

%%

start_state : statement_list;
            
            
statement_list : statement 
        | statement_list statement
        ;
        
statement : compound
          | declaration
          | print
          | main
	  | function {printf("fsy");}
          ;
  
return_statement : RETURN constant ';' {$$=$2;}
		;

function : type ID '(' ')' compound
	{
		printf("%s %s\n",$1,$5);
		if(strcmp($1,$5))
			printf("ERR in type matching");
		else insert($1,$2,stack);
	}
	;
declaration : type ID '=' constant ';'
            {
		if(strcmp($1,$4))
			printf("Not matching type\n");
               else insert($1,$2,stack);
            }
	    | type ID ';' 
	    {
		int x = returnscope($2);
		if(x!=-1)
			printf("Redeclaration\n");
		else insert($1,$2,stack);
	    }
            ;
	
constant : INT_CONST	{$$="int";}
	| STR_CONST	{$$="char";}
	;             
compound : '{''}'
        | '{' statement_list '}' {$$="void";}
	| '{' statement_list return_statement '}' {$$=$3;}
         ;
         

         
print : PRINT '(' STR_CONST ',' ID ')' ';'
        {
            int x=returnscope($5);
            if(x==-1 || x!=stack)
                printf("Undeclared use of %s at line %d\n",$5,yylineno);
        }
      ;    
	
main : type MAIN '(' ')'       {insert($1,$2,stack);}; 

type
	: INT {$$="int";}
	| CHAR {$$="char";}
	| VOID {$$="void";}
	;	
%%

#include "lex.yy.c"
#include<ctype.h>
void showSymbolTable(){
	int j;
	printf("\nDATATYPE\tIDENTIFIER\tSCOPE\n");
	for(j=0;j<i;j++){
		printf("%s\t\t%s\t\t%d\n",table[j].datatype,table[j].identifier,table[j].scope);
	}
}

int main(int argc, char *argv[])
{
	yyin =fopen(argv[1],"r");
	if(!yyparse())
	{
		printf("Parsing done\n");
	}
	else
	{
		printf("Error\n");
	}
	showSymbolTable();
	fclose(yyin);
	return 0;
}
yyerror(char *s)
{
	printf("\nLine %d : %s %s\n",yylineno,s,yytext);
}

void startblock()
{
    stack++;
    //printf("New top at %d at line no. %d\n",stack,yylineno);
}

void endblock()
{
    stack--;
    end[stack+1]=1;
    //printf("New top at %d at line no. %d\n",stack,yylineno);
}
