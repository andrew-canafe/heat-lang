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
		name, ival, fval, sval
	};

	struct type_val {
		int8_t type;
		union {
			char * name;
			int64_t ival;
			double fval;
			char * sval;
		};
	};
}

%union {
	struct type_val tv;
}

%start heat
%token IMPORT CLASS FUNC VAR ASSIGN IF ELIF ELSE FOR WHILE MATCH ARROW RETURN BREAK NEXT NL
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
%token <tv> LV NAME VAL
%nterm <tv> expression

%%

heat:
	top_level_statements

top_level_statements:
	top_level_statements top_level_statement |
	top_level_statement

top_level_statement:
	import_statement |
	func_statement |
	class_statement |
	initialization

import_statement:
	IMPORT VAL { if ($2.type == sval) { printf("import: %s\n", $2.sval); free($2.sval); } else { printf("type error\n"); } } ';'

func_statement:
	FUNC NAME '(' { printf("func\n"); } declarations ')' '{' statements '}'

class_statement:
	CLASS NAME '{' { printf("class\n"); } class_members '}'

class_members:
	class_members class_member |
	class_member

class_member:
	initialization |
	func_statement

declarations:
	declarations ',' declaration |
	declaration |
	
declaration:
	var_type NAME { printf("decl\n"); }

assignment:
	NAME ASSIGN expression ';' { printf("asmt\n"); }

initialization:
	inline_initialization ';' { printf("init\n"); }

inline_initialization:
	var_type NAME ASSIGN expression { printf("inline init\n"); }

statements:
	statements statement |
	statement |

statement:
	assignment |
	initialization |
	if_statement |
	match_statement |
	for_statement |
	while_statement |
	break_statement |
	next_statement |
	return_statement |
	func_call

if_statement:
	if elifs else |
	if elifs |
	if else |
	if

if:
	IF expression '{' { if ($2.type == ival) { printf("if: %ld\n", $2.ival ); } else { printf("type error\n"); } } statements '}'

else:
	ELSE '{' { printf("else\n"); } statements '}'

elifs:
	elifs elif |
	elif

elif:
	ELIF expression '{' { if ($2.type == ival) { printf("elif: %ld\n", $2.ival); } } statements '}'

match_statement:
	MATCH expression '{' { printf("match\n"); } match_cases '}'

for_statement:
	FOR { printf("for\n"); } inline_initialization ',' expression ',' expression '{' statements '}'

while_statement:
	WHILE expression '{' { if ($2.type == ival) { printf("while: %ld\n", $2.ival); } else { printf("type error\n"); } } statements '}'

break_statement:
	BREAK VAL { /*if ($2.type == ival) {*/ printf("break: %ld\n", $2.ival); /*} else { printf("type error\n"); }*/ } ';' |
	BREAK ';' { printf("break\n"); }

next_statement:
	NEXT VAL { /*if ($2.type == ival) {*/ printf("next: %ld\n", $2.ival); /*} else { printf("type error\n"); }*/ } ';' |
	NEXT ';' { printf("next\n"); }

return_statement:
	RETURN expression { printf("return\n"); } ';' |
	RETURN ';' { printf("return\n"); }

func_call:
	NAME '(' expressions ')' ';' { printf("func call\n"); }

match_cases:
	match_cases match_case |
	match_case

match_case:
	expressions ARROW '{' statements '}'

expressions:
	expressions ',' expression |
	expression |

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
