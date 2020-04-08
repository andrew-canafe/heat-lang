%{
    #include <stdio.h>
    #include "heat.tab.h"
%}

%%

if								{ return IF; }
elif							{ return ELIF; }
else							{ return ELSE; }
while							{ return WHILE; }
match							{ return MATCH; }
for								{ return FOR; }
to								{ return TO; }
class							{ return CLASS; }
func							{ return FUNC; }
var								{ return VAR; }
break							{ return BREAK; }
return							{ return RETURN; }
next							{ return NEXT; }
l1								{ return L1; }
l2								{ return L2; }
l3								{ return L3; }
l4								{ return L4; }
l5								{ return L5; }
l6								{ return L6; }
l7								{ return L7; }
l8								{ return L8; }
\(								{ return '('; }
\)								{ return ')'; }
\{								{ return '{'; }
\}								{ return '}'; }
\:\=							{ return CEQ; }
\<								{ return LT; }
\<=								{ return LTE; }
\>								{ return GT; }
\>=								{ return GTE; }
\=								{ return EQ; }
\!\=							{ return NEQ; }
\=\>							{ return ARROW; }
\&\&							{ return AND; }
\|\|							{ return OR; }
\,								{ return ','; }
\+								{ return '+'; }
\-								{ return '-'; }
\*								{ return '*'; }
\/								{ return '/'; }
i8								{ return I8; }
i16								{ return I16; }
i32								{ return I32; }
i64								{ return I64; }
u8								{ return U8; }
u16								{ return U16; }
u32								{ return U32; }
u64								{ return U64; }
f32								{ return F32; }
f64								{ return F64; }
str								{ return STR; }
ptr								{ return PTR; }
[0-9]+\.[0-9]+					{ yylval.f32 = atof(yytext); return VAL; }
[0-9]+							{ yylval.i32 = atoi(yytext); return VAL; }
"[a-zA-Z0-9]+"					{ yylval.str = strdup(yytext); return VAL; }
[a-zA-Z][a-zA-Z0-9]*			{ return NAME; }
\n								{ return NL; }
.								{ ; }

%%

int yywrap () {
    return 1;
}
