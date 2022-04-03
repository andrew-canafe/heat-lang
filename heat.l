%{
    #include <stdio.h>
    #include "heat.tab.h"
%}

%%

import			{ return IMPORT; }
class			{ return CLASS; }
func			{ return FUNC; }
var			{ return VAR; }
:=			{ return ASSIGN; }
if			{ return IF; }
elif			{ return ELIF; }
else			{ return ELSE; }
while			{ return WHILE; }
for			{ return FOR; }
match			{ return MATCH; }
=>			{ return ARROW; }
return			{ return RETURN; }
break			{ return BREAK; }
next			{ return NEXT; }
i8			{ return I8; }
i16			{ return I16; }
i32			{ return I32; }
i64			{ return I64; }
u8			{ return U8; }
u16			{ return U16; }
u32			{ return U32; }
u64			{ return U64; }
f32			{ return F32; }
f64			{ return F64; }
str			{ return STR; }
ptr			{ return PTR; }
,			{ return ','; }
\{			{ return '{'; }
\}			{ return '}'; }
\<			{ return LT; }
\<=			{ return LTE; }
\>			{ return GT; }
\>=			{ return GTE; }
=			{ return EQ; }
!=			{ return NEQ; }
\|			{ return '|'; }
\^			{ return '^'; }
&			{ return '&'; }
\+			{ return '+'; }
-			{ return '-'; }
\*			{ return '*'; }
\/			{ return '/'; }
%			{ return '%'; }
~			{ return '~'; }
\(			{ return '('; }
\)			{ return ')'; }
\;			{ return ';'; }
[a-zA-Z][a-zA-Z0-9]*	{ yylval.tv.type = name; yylval.tv.sval = strdup(yytext); return NAME; }
[0-9]+			{ yylval.tv.type = ival; yylval.tv.ival = atol(yytext); return VAL; }
[0-9]+\.[0-9]+		{ yylval.tv.type = fval; yylval.tv.fval = atof(yytext); return VAL; }
\".*\"			{ yylval.tv.type = sval; yylval.tv.sval = strndup(yytext+1, strlen(yytext)-2); return VAL; }
\#.*|[ \t\n\r]		{ ; }
.			{ return yytext[0]; }

%%

int yywrap () {
    return 1;
}
