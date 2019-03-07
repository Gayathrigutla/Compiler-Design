%{
#include <string.h>
#define YYSTYPE char*
char type[100];
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

start_state
	: function_definition
	;
	
function_definition
	: type_specifier function_identifier '(' ')' compound_statement 
	;
	
function_identifier
	: IDENTIFIER { symbolInsert($1, type); }
	;
type_specifier
	: INT 	{ $$ = "int"; strcpy(type, $1); }
	;

compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	; 
	
statement_list
	: statement
	| statement_list statement 
	;

statement
	: compound_statement
	| expression_statement
	| iteration_statement
	| jump_statement	
	| print_statement
	;

expression_statement
	: expression ';'
	| ';'
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;
	
assignment_expression
	: relational_expression
	| assignment_expression assignment_operator relational_expression
	;
	
assignment_operator
	: '='
	| ADD_ASSIGN
	;

relational_expression
	: addsub_expression
	| relational_expression '>' addsub_expression
	| relational_expression '<' addsub_expression
	;
	
addsub_expression
	: muldivmod_expression
	| addsub_expression '+' muldivmod_expression
	| addsub_expression '-' muldivmod_expression
	;
	
muldivmod_expression
	: fundamental_expression
	| muldivmod_expression '*' fundamental_expression
	| muldivmod_expression '/' fundamental_expression
	| muldivmod_expression '%' fundamental_expression
	;
	
fundamental_expression
	: IDENTIFIER { symbolInsert($1, type); }
	| STRING_CONST { constantInsert($1, "string"); }
	| INT_CONST { constantInsert($1, "int"); }
	| FLOAT_CONST { constantInsert($1, "float"); }
	| '(' expression ')'
	;
	
iteration_statement
	: FOR '(' expression statement expression statement expression ')'
	| FOR '(' expression statement expression statement ')'
	;
	
jump_statement
	: RETURN expression ';'
	;

print_statement
	: PRINTF '(' STRING_CONST ',' init_declarator_list ')' ';'
	;
	
declaration_list
	: declaration
	| declaration_list declaration
	;
	
declaration
	: type_specifier init_declarator_list ';'
	| error
	;
	
init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	 : variable
	 | variable '=' assignment_expression
	 ;

variable 
	: IDENTIFIER { symbolInsert($1, type); }
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
	
	showSymbolTable();
showConstantTable();	
}

extern char* yytext;
extern int yylineno;
yyerror() {
	err = 1;
	printf("Error at %d", yylineno);
	showSymbolTable();
	showConstantTable();
	exit(0);
}

