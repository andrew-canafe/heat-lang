%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdint.h>
	extern int yylex();
	extern int yyparse();
	extern FILE * yyin;
	void yyerror(const char * s);
%}

%union {
	int8_t i8;
	int16_t i16;
	int32_t i32;
	int64_t i64;
	uint8_t u8;
	uint16_t u16;
	uint32_t u32;
	uint64_t u64;
	float f32;
	double f64;
	char * str;
	void * ptr;
}

%start heat
%token <i8> I8
%token <i16> I16
%token <i32> I32
%token <i64> I64
%token <u8> U8
%token <u16> U16
%token <u32> U32
%token <u64> U64
%token <f32> F32
%token <f64> F64
%token <str> STR
%token <ptr> PTR
%token <i32> VAL
%token <i32> NAME
%token FUNC VAR NL FOR IF ELIF ELSE WHILE ARROW MATCH CLASS IMPORT BREAK NEXT RETURN TO
%token <i32> L1 L2 L3 L4 L5 L6 L7 L8
%token '(' ')' '{' '}' '<' '>' CEQ ','
%left '|'
%left '^'
%left '&'
%left LT GT EQ LTE GTE NEQ
%left '+' '-'
%left '*' '/' '%'
%left '~'
%precedence PARS
%nterm <i32> expression
%nterm <i32> level

%%

heat:
	newlines toplevelstatements newlines |
	newlines toplevelstatements |
	toplevelstatements newlines |
	toplevelstatements

toplevelstatements:
	toplevelstatements newlines toplevelstatement |
	toplevelstatement

toplevelstatement:
	import |
	function |
	class

import:
	IMPORT { printf("import\n"); }

function:
	FUNC NAME '(' declarations ')' '{' newlines { printf("func\n"); } statements newlines '}'

class:
	CLASS NAME '{' newlines { printf("class\n"); } members newlines '}'

members:
	members member |
	member

member:
	declaration |
	initialization |
	function

declarations:
	declarations ',' declaration |
	declaration |

declaration:
	VAR NAME type { printf("decl\n"); }

assignment:
	NAME CEQ expression { printf("asmt\n"); }
	
initialization:
	VAR NAME type CEQ expression { printf("init\n"); }

statements:
	statements newlines statement |
	statement

statement:
	varstatement |
	ifstatement |
	matchstatement |
	forstatement |
	whilestatement |
	breakstatement |
	nextstatement |
	returnstatement

varstatement:
	declaration |
	assignment |
	initialization

ifstatement:
	if elifs else |
	if elifs |
	if else |
	if

if:
    IF expression '{' newlines { printf("if\n"); } statements newlines '}'

else:
    ELSE '{' newlines { printf("else\n"); } statements newlines '}'

elifs:
	elifs elif |
	elif

elif:
	ELIF expression '{' newlines { printf("elif\n"); } statements newlines '}'

matchstatement:
	MATCH expression '{' newlines { printf("match\n"); } cases newlines '}'

forstatement:
	FOR { printf("for\n"); } initialization ',' expression ',' expression '{' newlines statements newlines '}'
/*
	FOR { printf("for\n"); } initialization ',' expression '{' newlines statements newlines '}' |
	FOR { printf("for\n"); } initialization TO expression '{' newlines statements newlines '}'
*/

whilestatement:
	WHILE expression '{' newlines { printf("while\n"); } statements newlines '}'

breakstatement:
	BREAK level { printf("break l%d\n", $2); } |
	BREAK { printf("break\n"); }

nextstatement:
	NEXT level { printf("next l%d\n", $2); } |
	NEXT { printf("next\n"); }

returnstatement:
	RETURN expression { printf("return\n"); } |
	RETURN { printf("return\n"); }

level:
	L1 { $$ = 1; } |
	L2 { $$ = 2; } |
	L3 { $$ = 3; } |
	L4 { $$ = 4; } |
	L5 { $$ = 5; } |
	L6 { $$ = 6; } |
	L7 { $$ = 7; } |
	L8 { $$ = 8; }

cases:
	cases newlines case |
	case

case:
	expressions ARROW '{' newlines statements newlines '}'

expressions:
	expressions ',' expression |
	expression

expression:
	expression '|' expression { $$ = $1 || $3; } |
	expression '&' expression { $$ = $1 && $3; } |
	expression '^' expression { $$ = $1 && !$3 || !$1 && $3; } |
	expression LT expression { if ($1 < $3) { $$ = 1; } else { $$ = 0; } } |
	expression LTE expression { if ($1 <= $3) { $$ = 1; } else { $$ = 0; } } |
	expression GT expression { if ($1 > $3) { $$ = 1; } else { $$ = 0; } } |
	expression GTE expression { if ($1 >= $3) { $$ = 1; } else { $$ = 0; } } |
	expression EQ expression { if ($1 == $3) { $$ = 1; } else { $$ = 0; } } |
	expression NEQ expression { if ($1 != $3) { $$ = 1; } else { $$ = 0; } } |
	expression '+' expression { $$ = $1 + $3; } |
	expression '-' expression { $$ = $1 - $3; } |
	expression '*' expression { $$ = $1 * $3; } |
	expression '/' expression { $$ = $1 / $3; } |
	expression '%' expression { $$ = $1 % $3; } |
	'~' expression { $$ = !$2; } |
	'(' expression ')' %prec PARS { $$ = $2; } |
	VAL { $$ = $1; } |
	NAME { $$ = $1; }

type:
	I8 | I16 | I32 | I64 | U8 | U16 | U32 | U64 | F32 | F64 | STR | PTR

newlines:
	newlines NL |
	NL

%%

int main(int argc, char * * argv) {
	FILE * file = fopen("test.ht", "r");
	if (!file) {
		printf("file error\n");
		return -1;
	}
	yyin = file;
	yyparse();
}

void yyerror(const char * s) {
	printf("%s\n", s);
	exit(-1);
}
