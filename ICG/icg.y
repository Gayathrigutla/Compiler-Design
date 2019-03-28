%{
#include <string.h>
#include<stdio.h>
#include<stdlib.h>
#define YYSTYPE char*
extern int yylineno;
char type[200];
int scope = 0;
int n = 1;
char funcReturnType[100][100];
int currType = 0;
int var = 0; //no of variables declared in one statement

char tokenstack[100][10],i_[2]="0",temp[2]="t", null[2]=" ";
int top = 0;
int label[20],label_index=0,ltop=0;

struct declaration_info {
	char id[100];
	char value[100];
}dec_info[100];

struct symbolTable
{
	char token[100];
	char type[100];
	int tn;
	float fvalue;
	int value;
	int scope;
	int isFunction;
	int fType[100]; 
	char paramType[100];
	int numParams; 
}table[100];

void saveReturnType(int currType, char* returnType) {
	strcpy(funcReturnType[currType], returnType);
}

int isPresent(char* token){ //check if token is already present in symbol table
	int i;
	for(i = 1; i < n; ++i)
		if(!strcmp(table[i].token, token))
			return i;
	return 0;
}

int getNumParams(char* token){
	int i;
	for(i = 1; i < n; ++i)
		if(strcmp(table[i].token, token) == 0)
			return table[i].numParams;
}

char* getParamType(char* token){
	int i;
	for(i = 1; i <n; ++i)
		if(strcmp(table[i].token, token) == 0)
			return table[i].paramType;
}

char* getDataType(char* token){
	int i;
	for(i = 1; i < n; ++i)
		if(strcmp(table[i].token, token) == 0)
			return table[i].type;
}

int getMinScope(char* token) {
	int i;
	int min = 999;
	for(i = 1; i < n; ++i){
		if(strcmp(table[i].token, token) == 0)
			if(table[i].scope < min)
				min = table[i].scope;
	}
	return min;
}

void storeValue(char* token, char* value, int scope){
	int i;
	for(i = 1; i < n; ++i){
		if(strcmp(table[i].token, token) == 0 && table[i].scope == scope) {
			if(strcmp(table[i].type, "float") == 0)
				table[i].fvalue = atof(value);
			if(strcmp(table[i].type, "int") == 0)
				table[i].value = atoi(value);
			if(strcmp(table[i].type, "char") == 0)
				table[i].value = value;			
			break;
		}
	}
}

void insert(char* token, char* type, int scope, char* value) {
	if(!isPresent(token) || table[isPresent(token)].scope != scope){
		strcpy(table[n].token, token);
		strcpy(table[n].type, type);
		table[n].numParams = 0;
		table[n].isFunction = 0;
		table[n].scope = scope;
		if(strcmp(type, "float") == 0)
			table[n].fvalue = atof(value);
		if(strcmp(type, "int") == 0)
			table[n].value = atoi(value);
		n++;
	}
	return;
}

void insertFunction(char* token, char* type, char* paramType, int numParams){
	if(!isPresent(token)){
		strcpy(table[n].token, token);
		strcpy(table[n].type, type);
		strcpy(table[n].paramType, paramType);
		table[n].numParams = numParams;
		table[n].isFunction = 1;
		table[n].scope = scope;
		n++;
	}
	return;
}

void showSymbolTable(){ 
	int i;
	printf("\n\n--------------------------------------------------------------------------------------------\n\t\t\t\tSYMBOL TABLE\n--------------------------------------------------------------------------------------------\n");
	printf("\n\nToken\tType\tParameterType\tNo of Parameters\tisFunction\tValue\t\tScope");
	printf("\n-------------------------------------------------------------------------------------------------\n");
	for(i = 1; i < n; ++i){
		printf("\n%s\t%s\t%s\t\t%d\t\t\t%d\t\t",
		table[i].token, 
		table[i].type, 
		(table[i].isFunction ? table[i].paramType : "-"), 
		(table[i].isFunction ? table[i].numParams : 0),
		table[i].isFunction);

		!strcmp(table[i].type, "int") ? table[i].value==9999?printf("-\t\t"):printf("%d\t\t",table[i].value) : table[i].fvalue==9999.000000?printf("-\t\t"):printf("%f\t",table[i].fvalue);
		printf("%d",table[i].scope);
	}
	printf("\n");
}

void end() {
	showSymbolTable();
	printf("\nParsing Failed\n");
	exit(0);
}

void gencode()
{
	// int i;
	// for(i = 0; i <= top; ++i)
    //    printf("%d %s\n", i, tokenstack[i]);
	strcpy(temp,"t");
	strcat(temp,i_);
	printf("%s = %s %s %s\n",temp,tokenstack[top-2],tokenstack[top-1],tokenstack[top]);
	top-=2;
	strcpy(tokenstack[top],temp);
	i_[0]++;
}

void gencodeAssignment()
{
	// int i;
	// for(i = 0; i <= top; ++i)
    //    printf("--%d %s\n", i, tokenstack[i]);
	printf("%s = %s\n",tokenstack[top-2],tokenstack[top]);
	top-=2;
}

void push(char *a)
{
	strcpy(tokenstack[++top],a);
}

void dummy_if1()
{
	label_index++;
	strcpy(temp,"t");
	strcat(temp,i_);
	printf("%s = not %s\n",temp,tokenstack[top]);
 	printf("if %s goto L%d\n",temp,label_index);
	i_[0]++;
	label[++ltop]=label_index;
}

void dummy_if2()
{
	label_index++;
	printf("goto L%d\n",label_index);
	printf("L%d: \n",label[ltop--]);
	label[++ltop]=label_index;
}

void dummy_if3()
{
	printf("L%d:\n",label[ltop--]);
}

void dummy_w1()
{
	label_index++;
	label[++ltop]=label_index;
	printf("L%d:\n",label_index);
}
void dummy_w2()
{
	label_index++;
	strcpy(temp,"t");
	strcat(temp,i_);
	printf("%s = not %s\n",temp,tokenstack[top--]);
 	printf("if %s goto L%d\n",temp,label_index);
	i_[0]++;
	label[++ltop]=label_index;
}
void dummy_w3()
{
	int y=label[ltop--];
	printf("goto L%d\n",label[ltop--]);
	printf("L%d:\n",y);
}

%}

%left '<' '>' '='
%left '+' '-'
%left '*' '/' '%'
%token IDENTIFIER 
%token INT FOR RETURN PRINTF FLOAT VOID WHILE CHAR IF ELSE
%token STRING_CONST INT_CONST FLOAT_CONST
%token ADD_ASSIGN

%start start_state
%glr-parser

%%

start_state: 
	function_definition_list
	;

function_definition_list:
	function_definition_list function_definition
	| function_definition
	;
	
function_definition: 
	type_specifier IDENTIFIER '(' ')' { printf("\nfunction begin %s:\n", $2); } compound_statement 
	 {
		if(strcmp($1, funcReturnType[currType-1]) != 0){
			printf("\nError: Return Type mismatch at line no %d\n", yylineno);
			end();
		}
		else if(isPresent($2)) {
			printf("\nError: Redefinition of function at line no %d\n", yylineno);
			end();
		}
		else
		insertFunction($2, $1, "-", 0);
		printf("function end\n\n");
	}
    | type_specifier IDENTIFIER '(' type_specifier_fn IDENTIFIER ')' { printf("\nfunction begin %s:\n", $2); } compound_statement
	{
		if(strcmp($1, funcReturnType[currType-1]) != 0){
			printf("\nError Return Type mismatch at line no %d\n", yylineno);
			end();
		}
		else if(isPresent($2)) {
			printf("\nError: Redefinition of function at line no %d\n", yylineno);
			end();
		}
		else
			insertFunction($2, $1, $4, 1);
		printf("function end\n\n");
	}
	;	

type_specifier:
	 INT 	{ $$ = "int"; strcpy(type, $1); }
	| FLOAT { $$ = "float"; }
	| VOID { $$ = "void"; }
	| CHAR { $$ = "char"; }
	;

type_specifier_fn:
	 INT 	{ $$ = "int"; }
	| FLOAT { $$ = "float"; }
	;


compound_statement:
	 '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	| '{' declaration_list statement_list declaration_list'}'
	| '{' declaration_list statement_list declaration_list statement_list'}'
	; 

statement_list:
	 statement
	| statement_list statement 
	;

statement:
	 compound_statement
	| expression_statement
	| iteration_statement
	| jump_statement	
	| print_statement
    | function_call_statement
	| if_statement
	;

expression_statement:
	 expression ';'
	| ';'
	;

expression:
	 assignment_expression
	| expression ',' assignment_expression
	;
	
assignment_expression:
	 all_expression
	| assignment_expression {push($1);} assignment_operator all_expression {gencodeAssignment();}
	{
		storeValue($1, $3, scope);		
	}
	;
	
assignment_operator:
	 '=' {strcpy(tokenstack[++top],"=");}
	| ADD_ASSIGN {strcpy(tokenstack[++top],"+=");}
	;

all_expression:
	all_expression '>'{strcpy(tokenstack[++top],">");} rel_expression{gencode();}
   | all_expression '<'{strcpy(tokenstack[++top],"<");} rel_expression{gencode();}
   | rel_expression
   ;

rel_expression:
	rel_expression '+'{strcpy(tokenstack[++top],"+");} additive_exp{gencode();}
   | rel_expression '-'{strcpy(tokenstack[++top],"-");} additive_exp{gencode();}
   | additive_exp
   ;
   
additive_exp: 
	additive_exp '*'{strcpy(tokenstack[++top],"*");} fundamental_expression{gencode();}
   | additive_exp '/'{strcpy(tokenstack[++top],"/");} fundamental_expression{gencode();}
   | fundamental_expression
   ;

fundamental_expression:
	IDENTIFIER 
	{
		if(!isPresent($1)) {
			printf("\nError: Undeclared variable at line %d\n", yylineno);
			end();
		}
		else{
			int minScope = getMinScope($1);
			if(scope < minScope){
				printf("\nError Variable out of scope at line %d\n", yylineno);
				end();
			}
			else	
				push($1);
		}

	}
	| STRING_CONST {push($1);}
	| INT_CONST {push($1);}
	| FLOAT_CONST {push($1);}
	//| '(' expression ')' {$$=$2;}
	;
	
iteration_statement:
	 FOR '(' expression statement expression statement expression ')'
	| FOR '(' expression statement expression statement ')'
	| WHILE {dummy_w1();} '(' expression')' {dummy_w2();} compound_statement {dummy_w3();}
	;

if_statement
 	: 	 IF '(' expression ')' {dummy_if1();} compound_statement {dummy_if2();} else_statement
	;

else_statement
 	: ELSE compound_statement {dummy_if3();}
	;
	
jump_statement:
	 RETURN INT_CONST ';' 
	 {
		strcpy(funcReturnType[currType], "int");
		currType++;
	 }
	| RETURN FLOAT_CONST ';' 
	{ saveReturnType(currType, "float"); currType++; }
	| RETURN ';' 
	{ 
		saveReturnType(currType, "void"); 
		currType++; 
	}
	| RETURN IDENTIFIER ';'
	{ 
		char* types = getDataType($2);
		printf("Type%s", types);
		saveReturnType(currType, types); 
		currType++; 
	}
	;

print_statement:
	 PRINTF '(' STRING_CONST ',' init_declarator_list ')' ';'
	;

function_call_statement:
	 IDENTIFIER '(' ')' ';'
	{
		if(!isPresent($1)){
			printf("\nError Undeclared function at line no %d\n", yylineno);
			end();
		}
		else if(getNumParams($1) != 0) {
			printf("\nError at line no %d\n", yylineno);
			end();
		}
	}
    | IDENTIFIER '(' IDENTIFIER ')' ';'
	{
		if(!isPresent($1)){
			printf("Error Undeclared function at line no %d\n", yylineno);
			end();
		}
		else if(getNumParams($1) != 1){
			printf("Error No of parameters does not match signature at line no %d\n", yylineno);
			end();
		}
		else if(strcmp(getParamType($1), getDataType($3)) != 0){
			printf("Error Parameter type does not match signature at line no %d\n", yylineno);
			end();
		}		

	}
    | IDENTIFIER '(' INT_CONST ')'';'
	{
		if(!isPresent($1)){
			printf("\nError Undeclared function at line no %d\n", yylineno);
			end();
		}
		else if(getNumParams($1) != 1){ 
			printf("\nError No of parameters does not match signature at line no %d\n", yylineno);
			end();
		}
		else if(strcmp(getParamType($1), "int") != 0){
			printf("\nError Parameter type does not match signature at line no %d\n", yylineno);
			end();
		}		

	}
	| IDENTIFIER '(' FLOAT_CONST ')' ';'
	{
		if(!isPresent($1)){
			printf("Error Undeclared function at line no %d\n", yylineno);
			end();
		}
		else if(getNumParams($1) != 1){
			printf("Error No of parameters does not match signature at line no %d\n", yylineno);
			end();
		}
		else if(strcmp(getParamType($1), "float") != 0){
			printf("Error Parameter type does not match signature at line no %d\n", yylineno);
			end();
		}	

	}
	;
	
declaration_list:
	 declaration
	| declaration_list declaration
	;
	
declaration:
	type_specifier init_declarator_list ';' 
	{
		for(int i = 0; i < var; ++i){
			if(!isPresent(dec_info[i].id) || table[isPresent(dec_info[i].id)].scope != scope)
				insert(dec_info[i].id, $1, scope, dec_info[i].value);
			else{
				printf("\nError: Redeclaration of variable at line no %d\n", yylineno);
				end();
			}
		}
		var = 0;
	}
	;
	
init_declarator_list:
	 init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator:
	variable 
	{
	strcpy(dec_info[var].id, $1);
	strcpy(dec_info[var].value, "9999");
	var++;
	}
	| variable {push($1);} '=' {strcpy(tokenstack[++top],"=");} assignment_expression {gencodeAssignment();}
	{
		strcpy(dec_info[var].id, $1);
		strcpy(dec_info[var].value, $3);
		var++;
	}
	;

variable:
	 IDENTIFIER 
	;
%%

#include "lex.yy.c"
#include <stdio.h>
#include <string.h>
#include <ctype.h>


int err = 0;
int main(int argc, char* argv[]) {
	yyin = fopen(argv[1], "r");
	yyparse();
	
	if(err == 0)
		printf("\nParsing Complete\n");
	else
		printf("\nParsing Failed\n");
		
	fclose(yyin);
	
	showSymbolTable();
}

extern char* yytext;
extern int yylineno;
yyerror() {
	err = 1;
	printf("\nYYError at line no %d\n", yylineno);
	exit(0);
}

void startBlock() {
	scope++;
	return;
}

void endBlock() {	
	scope--;
	return;
}