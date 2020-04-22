%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdint.h>
	extern int yylex();
	extern int yyparse();
	extern FILE * yyin;
	void yyerror(const char * s);
%}

%code requires {
	enum {
		bool_t, lv_t, name_t, i8_t, i16_t, i32_t, i64_t, u8_t, u16_t, u32_t, u64_t, f32_t, f64_t, str_t, ptr_t
	};

	struct flex_struct {
		int8_t type;
		union {
			int8_t bool; // Used for debugging only
			int8_t lv;
			char * name;
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
		};
	};
}

%union {
	struct flex_struct flex;
}

%start heat
%token IMPORT CLASS FUNC VAR ASSIGN IF ELIF ELSE FOR WHILE MATCH ARROW RETURN BREAK NEXT LF
%token I8 I16 I32 I64 U8 U16 U32 U64 F32 F64 STR PTR
%token ',' '{' '}'
%left '|'
%left '^'
%left '&'
%left LT LTE GT GTE EQ NEQ
%left '+' '-'
%left '*' '/' '%'
%right '~' '$'
%token '(' ')'
%precedence ADDR
%precedence PARS
%token <flex> LV NAME VAL
%nterm <flex> expression

%%

heat:
	newlines top_level_statements newlines |
	newlines top_level_statements |
	top_level_statements newlines |
	top_level_statements

top_level_statements:
	top_level_statements newlines top_level_statement |
	top_level_statement

top_level_statement:
	import_statement |
	func_statement |
	class_statement |
	var_statement

import_statement:
	IMPORT VAL { if ($2.type == str_t) { printf("import: %s\n", $2.str); free($2.str); } else { printf("type error\n"); } }

func_statement:
	FUNC NAME '(' { printf("func\n"); } declarations ')' '{' newlines statements newlines '}'

class_statement:
	CLASS NAME '{' newlines { printf("class\n"); } class_members newlines '}'

class_members:
	class_members class_member |
	class_member

class_member:
	declaration |
	initialization |
	func_statement

declarations:
	declarations ',' declaration |
	declaration |

assignment:
	NAME ASSIGN expression { printf("asmt\n"); }
	
declaration:
	var_type NAME { printf("decl\n"); }

initialization:
	var_type NAME ASSIGN expression { printf("init\n"); }

statements:
	statements newlines statement |
	statement

statement:
	assignment |
	var_statement |
	if_statement |
	match_statement |
	for_statement |
	while_statement |
	break_statement |
	next_statement |
	return_statement

var_statement:
	VAR '{' newlines vars newlines '}'

vars:
	vars newlines var |
	var

var:
/*
	initialization |
*/
	declaration


if_statement:
	if elifs else |
	if elifs |
	if else |
	if

if:
    IF expression '{' newlines { if ($2.type == bool_t) { printf("if: %d\n", $2.bool ); } else { printf("type error\n"); } } statements newlines '}'

else:
    ELSE '{' newlines { printf("else\n"); } statements newlines '}'

elifs:
	elifs elif |
	elif

elif:
	ELIF expression '{' newlines { if ($2.type == bool_t) { printf("elif: %d\n", $2.bool); } } statements newlines '}'

match_statement:
	MATCH expression '{' newlines { printf("match\n"); } match_cases newlines '}'

for_statement:
	FOR { printf("for\n"); } assignment ',' expression ',' expression '{' newlines statements newlines '}'
/*
	FOR { printf("for\n"); } assignment ',' expression '{' newlines statements newlines '}'
*/

while_statement:
	WHILE expression '{' newlines { if ($2.type == bool_t) { printf("while: %d\n", $2.bool); } else { printf("type error\n"); } } statements newlines '}'

break_statement:
	BREAK LV { printf("break: %d\n", $2.lv); } |
	BREAK { printf("break\n"); }

next_statement:
	NEXT LV { printf("next: %d\n", $2.lv); } |
	NEXT { printf("next\n"); }

return_statement:
	RETURN expression { printf("return\n"); } |
	RETURN { printf("return\n"); }

match_cases:
	match_cases newlines match_case |
	match_case

match_case:
	expressions ARROW '{' newlines statements newlines '}'

expressions:
	expressions ',' expression |
	expression

expression:
	expression '|' expression { /*$$ = $1 | $3;*/ } |
	expression '&' expression { /*$$ = $1 & $3;*/ } |
	expression '^' expression { /*$$ = $1 ^ $3;*/ } |
	expression LT expression { /*if ($1 < $3) { $$ = 1; } else { $$ = 0; }*/ } |
	expression LTE expression { /*if ($1 <= $3) { $$ = 1; } else { $$ = 0; }*/ } |
	expression GT expression { /*if ($1 > $3) { $$ = 1; } else { $$ = 0; }*/ } |
	expression GTE expression { /*if ($1 >= $3) { $$ = 1; } else { $$ = 0; }*/ } |
	expression EQ expression { /*if ($1 == $3) { $$ = 1; } else { $$ = 0; }*/ } |
	expression NEQ expression { /*if ($1 != $3) { $$ = 1; } else { $$ = 0; }*/ } |
	expression '+' expression { /*$$ = $1 + $3;*/ } |
	expression '-' expression { /*$$ = $1 - $3;*/ } |
	expression '*' expression { /*$$ = $1 * $3;*/ } |
	expression '/' expression { /*$$ = $1 / $3;*/ } |
	expression '%' expression { /*$$ = $1 % $3;*/ } |
	'~' expression { /*$$ = !$2;*/ } |
	'$' NAME { /*$$ = *(long *)$2;*/ } |
	'&' NAME %prec ADDR { /*$$ = (long)&$2;*/ } |
	'(' expression ')' %prec PARS { /*$$ = $2;*/ } |
	NAME { /*$$ = $1;*/ } |
	VAL { /*$$ = $1;*/ }

var_type:
	I8 | I16 | I32 | I64 | U8 | U16 | U32 | U64 | F32 | F64 | STR | PTR

newlines:
	newlines LF |
	LF

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
