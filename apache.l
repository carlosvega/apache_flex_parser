%{
#include <iostream>
#include "apache.tab.h"
using namespace std;
#define YY_DECL extern "C" int yylex()
%}
%%
[ \t] ;
\n           { return END; }
([0-9]{1,3}\.){3}[0-9]{1,3} { yylval.sval = strdup(yytext); return IP; }
[0-9]+\.[0-9]+ { yylval.fval = atof(yytext); return FLOAT; }
[0-9]+         { yylval.ival = atoi(yytext); return INT; }
\[([^\]]+)\]   { yylval.sval = strdup(yytext); return APACHE_DATE;}
[a-zA-Z0-9\./\<\>\?\;\:\'\`\!\@\#\$\%\^\&\*\(\)\[\]\{\}\_\+\=\|\\\-]+   {
	yylval.sval = strdup(yytext);
	return STRING;
}
\"[a-zA-Z0-9\./\<\>\?\;\:\'\`\!\@\#\$\%\^\&\*\(\)\[\]\{\}\_\+\=\|\\\-]+\" {yylval.sval = strdup(yytext); return HEADER;}
\"[a-zA-Z0-9\ \./\<\>\?\;\:\'\`\!\@\#\$\%\^\&\*\(\)\[\]\{\}\_\+\=\|\\\-]+\"$ {yylval.sval = strdup(yytext); return HEADER;}
.              ;
%%