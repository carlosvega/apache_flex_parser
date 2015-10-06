%{
#include <cstdio>
#include <cstring>
#include <iostream>
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

int n_headers = 1;
long n_lineas = 0;
int first_quote = 1;

void yyerror(const char *s);

%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	int ival;
	float fval;
	char *sval;
}

// define the constant-string tokens:
%token END
%token QUOTE
%token EOF_TOKEN


// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING
%token <sval> STRING_WITH_SPACES
%token <sval> FIRST_PART
%token <sval> LAST_PART
%token <sval> IP
%token <sval> APACHE_DATE

%%

// the first rule defined is the highest-level rule, which in our
// case is just the concept of a whole "snazzle file":
apache_log:
	apache_lines EOF_TOKEN { cout << "done with a apache log file!" << '\n'; YYABORT;}
apache_lines:
	apache_lines apache_line 
	| apache_line
	;
apache_line:
	APACHE_ADDR IDENTD USER_ID DATE REQUEST STATUS_CODE SIZE apache_optional { cout << "}" << '\n'; }
	| error endl {yyerrok;}
	;
apache_optional:
	cabecera apache_optional
	| cabecera
	| endl
	| EOF_TOKEN
cabecera:
	q cadena q {n_headers+=1;}
	;
q:
	QUOTE {if(first_quote==1){first_quote=0; cout << ", \"header_" << n_headers << "\": \"";}else{first_quote=1; cout << "\"";};}
cadena:
	cadena STRING {cout << " " << $2 ;}
	| STRING {cout << $1;}
	;
APACHE_ADDR:
	IP	  { n_lineas++; n_headers=1; cout << "{ \"ip\": \"" << $1 << "\"" ;}
	;
IDENTD:
	STRING {cout << ", \"identd\": \"" << $1 << "\"" ;}
	;
USER_ID:
	STRING {cout << ", \"user_id\": \"" << $1 << "\"" ;}
	;
DATE:
	APACHE_DATE { cout << ", \"date\": \"" << $1 << "\"" ;}
	;
REQUEST:
	QUOTE METHOD URI VERSION QUOTE
	;
METHOD:
	STRING {cout << ", \"method\": \"" << $1 << "\"" ;}
	;
URI:
	STRING {cout << ", \"uri\": \"" << $1 << "\"" ;}
	;
VERSION:
	STRING {cout << ", \"version\": \"" << $1 << "\"" ;}
	;
STATUS_CODE:
	INT       { cout << ", \"status_code\": \"" << $1 << "\"" ;}
	;
SIZE:
	INT       { cout << ", \"size\": \"" << $1 << "\""  ;}
	;
endl:
	END
	;

%%

int main(int argc, char* argv[]) {
	// open a file handle to a particular file:
	FILE *myfile = fopen(argv[1], "r");
	// make sure it's valid:
	if (!myfile) {
		cout << "I can't open in.apache file!" << '\n';
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;

	// parse through the input until there is no more:
	do {
		if(yyparse() == 1){
			break;
		}
	} while (!feof(yyin));
	
}

void yyerror(const char *s) {
	cout << "EEK, parse error!  Message: " << s << " Continue...\n" << '\n';
	// might as well halt now:
}