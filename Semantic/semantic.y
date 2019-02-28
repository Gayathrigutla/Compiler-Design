%token INT ID INT_CONST STR_CONST PRINT MAIN CHAR
%start start_state
%{
#include<stdio.h>
#include<string.h>
int stack=-1;
int end[1000];
int i=0;
extern int yylineno;
struct sym{
    char* datatype;
    char* identifier;
    int scope;
}table[1000];

void insert(char* datatype,char* identifier,int scope)
{
    printf("Inderting");
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
          ;
  
declaration : INT ID '=' INT_CONST';'
            {
                //printf("\nInserting %s %s %s", $2, $3, $4);
                printf("%d",i);
                //insert("int","x",1);
            }
            ;
              
compound : '{''}'
        | '{' statement_list '}'
         ;
         

         
print : PRINT '(' STR_CONST ',' ID ')'';'
        {
            int x=returnscope($5);
            if(x==-1 || x!=stack)
                printf("Undeclared use of %s at line %d\n",$5,yylineno);
        }
      ;    
 
main : INT MAIN '('')';        
%%

#include "lex.yy.c"
#include<ctype.h>
int main(int argc, char *argv[])
{
	yyin =fopen(argv[1],"r");
	if(!yyparse())
	{
		printf("Parsing done\n");
		//print();
	}
	else
	{
		printf("Error\n");
	}
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
