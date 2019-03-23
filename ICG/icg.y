%{
#include <string.h>
#define YYSTYPE char*
char type[100];
char tokenstack[100][10],i_[2]="0",temp[2]="t", null[2]=" ";
int top = 0;

void gencode()
{
    int i;
    //for(i = 0; i <= top; ++i)
       // printf("%d %s\n", i, tokenstack[i]);
	strcpy(temp,"t");
	strcat(temp,i_);
	printf("---------------%s = %s %s %s\n",temp,tokenstack[top-2],tokenstack[top-1],tokenstack[top]);
	top-=2;
	strcpy(tokenstack[top],temp);
	i_[0]++;
}

void unarygencode() {
    strcpy(temp,"t");
	strcat(temp,i_);
	printf("---------------%s = %s %s\n",temp,tokenstack[top-1],tokenstack[top]);
	top-=1;
	strcpy(tokenstack[top],temp);
	i_[0]++;
}
void gencodeAssignment()
{
	printf("---------------%s = %s\n",tokenstack[top-2],tokenstack[top]);
	top-=2;
}

void push(char *a)
{
	strcpy(tokenstack[++top],a);
}

%}

%left '<' '>' '='
%left '+' '-'
%left '*' '/' '%'
%token IDENTIFIER
%token INT FOR RETURN PRINTF
%token STRING_CONST INT_CONST FLOAT_CONST
%token ADD_ASSIGN

%start start_state
%glr-parser

%%

start_state:
    assignment_expression
    | expression;

assignment_expression:
    id '=' {strcpy(tokenstack[++top],"=");} expression {gencodeAssignment();}
    ;
    
expression:
    mul_expression
    | expression '+'{strcpy(tokenstack[++top],"+"); } mul_expression {gencode();}
    ;
    
mul_expression
    : unary
    | mul_expression '*'{strcpy(tokenstack[++top],"*"); }  unary {gencode();} 
    ;

unary: 
    id 
    | '-' { strcpy(tokenstack[++top],"-");} id {unarygencode();}
    ;
    
id: IDENTIFIER {push($1);}
    ;



    
%%

#include "lex.yy.c"
#include <stdio.h>
#include <string.h>
#include <ctype.h>

struct symbol {
	char token[100];
	char dataType[100];
	int len;
}symbolTable[1000], constantTable[1000];


int s = 0, c= 0 ; //no of records in symbol table

int hash(char* s) {
	int l = strlen(s);
	int i, val = 0, mod = 1001;
	for(i = 0; i < l; ++i){
		val = val*10 + (s[i] - 'a');
		val = val % mod;
		while(val < 0)
			val += mod;
	}
	return val;	
}

void symbolInsert(char* token, char* type) {
	int h = hash(token);
	if(symbolTable[h].len == 0){
		strcpy(symbolTable[h].token, token);
		strcpy(symbolTable[h].dataType, type);
		symbolTable[h].len = strlen(token);
		s++;
		return;
	}
	if(strcmp(symbolTable[h].token, token) == 0)
		return;
	
	int i;
	for(i = 0; i < 1000; ++i) {
		if(symbolTable[i].len == 0) {
			strcpy(symbolTable[i].token, token);
			strcpy(symbolTable[i].dataType, type);
			symbolTable[i].len = strlen(token);
			break;
		}
	}
	s++;
	return;
}

void showSymbolTable()
{
 	int j;
	printf("\n\n----------------------------------------------------------------------------\n\t\t\t\tSYMBOL TABLE\n----------------------------------------------------------------------------\n");   
	printf("\tSNo\t\t\tLexeme\t\t\tToken\n"); 
	printf("----------------------------------------------------------------------------\n");
  for(j=0;j<1000;j++)
	if(symbolTable[j].len != 0)
    		printf("%d\t%s\t\t\t<%s>\t\t\n",j+1,symbolTable[j].token,symbolTable[j].dataType);
}

void constantInsert(char* tokenName, char* DataType)
{
	for(int j=0; j<c; j++)
	{
		if(strcmp(constantTable[j].token, tokenName)==0)
			return;
	}
  strcpy(constantTable[c].token, tokenName);
  strcpy(constantTable[c].dataType, DataType);
  c++;
}

void showConstantTable()
{
  printf("\n------------Constant Table---------------------\n\nSNo\tConstant\t\tDatatype\n\n");

  for(int j=0;j<c;j++)
    printf("%d\t%s\t\t< %s >\t\t\n",j+1,constantTable[j].token,constantTable[j].dataType);
}


int err = 0;
int main(int argc, char* argv[]) {
	yyin = fopen(argv[1], "r");
	yyparse();
	
	if(err == 0)
		printf("Complete");
	else
		printf("Failed");
		
	fclose(yyin);
	
	
}

extern char* yytext;
extern int yylineno;
yyerror() {
	err = 1;
	printf("Error at %d", yylineno);
	//showSymbolTable();
	//showConstantTable();
	exit(0);
}
 
