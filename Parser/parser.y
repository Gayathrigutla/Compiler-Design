%nonassoc NO_ELSE
%nonassoc ELSE
%left '<' '>' '=' GE_OP LE_OP EQ_OP NE_OP
%left  '+'  '-'
%left  '*'  '/' '%'
%left  '|'
%left  '&'
%token IDENTIFIER STRING_CONSTANT CHAR_CONSTANT INT_CONSTANT FLOAT_CONSTANT SIZEOF
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN
%token CHAR SHORT SHORT_INT INT LONG LONG_INT SIGNED_INT UNSIGNED_INT FLOAT DOUBLE CONST VOID
%token IF ELSE WHILE FOR CONTINUE BREAK RETURN
%start start_state
%nonassoc UNARY
%glr-parser

%{
#include<string.h>
char type[100];
char temp[100];
%}

%%

start_state
	: global_declaration
	| start_state global_declaration
	;

global_declaration
	: function_definition
	| variable_declaration
	;

function_definition
	: type_specifier direct_declarator compound_statement
	;
	
type_specifier
	: VOID			{ $$ = "void"; } 	{ strcpy(type, $1); }
	| CHAR			{ $$ = "char"; } 	{ strcpy(type, $1); }
	| SHORT			{ $$ = "short"; } 	{ strcpy(type, $1); }
	| SHORT_INT		{ $$ = "short int"; } 	{ strcpy(type, $1); }
	| INT			{ $$ = "int"; } 	{ strcpy(type, $1); }
	| FLOAT			{ $$ = "float";} 	{ strcpy(type, $1); }
	| LONG			{ $$ = "long"; } 	{ strcpy(type, $1); }
	| LONG_INT		{ $$ = "long int"; } 	{ strcpy(type, $1); }
	| SIGNED_INT		{ $$ = "signed int"; } 	{ strcpy(type, $1); }
	| UNSIGNED_INT		{ $$ = "unsigned int"; }{ strcpy(type, $1); }
	;
	
direct_declarator
	: IDENTIFIER					{ symbolInsert($1, type); }
	| '(' direct_declarator ')'
	| direct_declarator '[' conditional_expression ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')'
	;

parameter_type_list
	: parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: type_specifier direct_declarator  
	| type_specifier 
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;
	
compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	| '{' declaration_list statement_list declaration_list statement_list '}'
	| '{' declaration_list statement_list declaration_list '}'
	| '{' statement_list declaration_list statement_list '}'
	;
	
declaration_list
	: variable_declaration
	| declaration_list variable_declaration
	;
	
statement_list
	: statement
	| statement_list statement
	;
	
statement
	: compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;
	
selection_statement
	: IF '(' expression ')' statement %prec NO_ELSE
	| IF '(' expression ')' statement ELSE statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| FOR '(' expression_statement expression_statement expression ')'
	| FOR '(' expression_statement expression_statement ')'
	;

jump_statement
	: CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;	

expression_statement
	: ';'
	| expression ';'
	;
	
expression
	: assignment_expression
	| expression ',' assignment_expression
	;
	
assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;
	
assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;
	
conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;
	
logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;
	
logical_and_expression
	: unary_or_expression
	| logical_and_expression AND_OP unary_or_expression
	;
	
unary_or_expression
	: exor_expression
	| unary_or_expression '|' exor_expression
	;	
	
exor_expression
	: and_expression
	| exor_expression '^' and_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

relational_expression
	: shift_exp
	| relational_expression '<' shift_exp
	| relational_expression '>' shift_exp
	| relational_expression LE_OP shift_exp
	| relational_expression GE_OP shift_exp
	;

shift_exp
	: addsub_exp
	| shift_exp LEFT_OP addsub_exp
	| shift_exp RIGHT_OP addsub_exp
	;

addsub_exp
	: multdivmod_exp
	| addsub_exp '+' multdivmod_exp
	| addsub_exp '-' multdivmod_exp
	;

multdivmod_exp
	: typecast_exp
	| multdivmod_exp '*' typecast_exp
	| multdivmod_exp '/' typecast_exp
	| multdivmod_exp '%' typecast_exp
	;

typecast_exp
	: unary_expression
	| '(' type_specifier ')' typecast_exp
	;

unary_expression
	: secondary_exp
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator typecast_exp
	;
	
unary_operator
	: '&'
	| '+'
	| '-'
	| '~'
	| '!'
	;

	
secondary_exp
	: fundamental_exp
	| secondary_exp '[' expression ']'
	| secondary_exp '(' ')'
	| secondary_exp '(' arg_list ')'
	| secondary_exp '.' IDENTIFIER
	| secondary_exp INC_OP
	| secondary_exp DEC_OP
	;
	
fundamental_exp
	: IDENTIFIER
	| STRING_CONSTANT	{ constantInsert($1, "string"); }
	| CHAR_CONSTANT     	{ constantInsert($1, "char"); }
	| FLOAT_CONSTANT	{ constantInsert($1, "float"); }
	| INT_CONSTANT		{ constantInsert($1, "int"); }
	| '(' expression ')'
	;

arg_list
	: assignment_expression
	| arg_list ',' assignment_expression
	;

variable_declaration
	: type_specifier init_declarator_list ';'
	| error
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: direct_declarator
	| direct_declarator '=' init
	;

init
	: assignment_expression
	| '{' init_list '}'
	| '{' init_list ',' '}'
	;

init_list
	: init
	| init_list ',' init
	;



%%
#include"lex.yy.c"
#include <ctype.h>
#include <stdio.h>
#include <string.h>

struct symbol
{
	char token[100];	// Name of the token
	char dataType[100];		// Date type: int, short int, long int, char etc
}symbolTable[100000], constantTable[100000];

int i=0; // Number of symbols in the symbol table
int c=0;

//Insert function for symbol table
void symbolInsert(char* tokenName, char* DataType)
{
  strcpy(symbolTable[i].token, tokenName);
  strcpy(symbolTable[i].dataType, DataType);
  i++;
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

void showSymbolTable()
{
 
	printf("\n\n----------------------------------------------------------------------------\n\t\t\t\tSYMBOL TABLE\n----------------------------------------------------------------------------\n");   
	printf("\tSNo\t\t\tLexeme\t\t\tToken\n"); 
	printf("----------------------------------------------------------------------------\n");
  for(int j=0;j<i;j++)
    printf("%10d\t%20s\t\t\t<%s>\t\t\n",j+1,symbolTable[j].token,symbolTable[j].dataType);
}

void showConstantTable()
{
	printf("\n\n----------------------------------------------------------------------------\n\t\t\t\tCONSTANT TABLE\n----------------------------------------------------------------------------\n");   
	printf("\tSNo\t\t\tConstant\t\tDatatype\n"); 
	printf("----------------------------------------------------------------------------\n");
  for(int j=0;j<c;j++)
    printf("%10d\t%20s\t\t\t<%s>\t\t\n",j+1,constantTable[j].token,constantTable[j].dataType);
}

int err=0;
int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	yyparse();
	if(err==0)
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	fclose(yyin);

	showSymbolTable();
	showConstantTable();
	return 0;
}
extern char *yytext;
extern int yylineno;
yyerror(char *s)
{
	err=1;
	printf("\nLine %d : %s\n", (yylineno), s);
	showSymbolTable();
	showConstantTable();
	exit(0);
}
