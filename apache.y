%{
#include <cstdio>
#include <iostream>
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

int n_headers = 0;
long n_lineas = 0;
 
void yyerror(const char *s);
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
	long ival;
	double fval;
	char *sval;
}

// define the constant-string tokens:
%token END
%token COMILLA

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING
%token <sval> IP
%token <sval> APACHE_DATE
%token <sval> HEADER

%%

// the first rule defined is the highest-level rule, which in our
// case is just the concept of a whole "snazzle file":
apache_log:
	apache_lines { cout << "done with a apache log file!" << endl; }
apache_lines:
	apache_lines apache_line 
	| apache_line
	;
apache_line:
	APACHE_ADDR IDENTD USER_ID DATE REQUEST STATUS_CODE SIZE endl { cout << "done with a apache log line!\n" << endl; }
	| APACHE_ADDR IDENTD USER_ID DATE REQUEST STATUS_CODE SIZE headers endl { cout << "done with a apache log line!\n" << endl; }
	;
headers:
	headers header //{ cout << "reading a field" << $2 << endl; }
	| header //{ cout << "reading a field" << $2 << endl; }
	;
header:
	HEADER { n_headers++; cout << "reading a header " << n_headers << " field! " << $1 << endl; }
	;
APACHE_ADDR:
	IP	  { n_lineas++; n_headers=0; cout << "New line, number: " << n_lineas << endl; cout << "reading an IP field! " << $1 << endl; }
	;
IDENTD:
	STRING {cout << "reading an IDENTD field! " << $1 << endl; }
	;
USER_ID:
	STRING {cout << "reading an USER_ID field! " << $1 << endl; }
	;
DATE:
	APACHE_DATE { cout << "reading an APACHE_DATE field! " << $1 << endl; }
	;
REQUEST:
	METHOD URI VERSION
	;
METHOD:
	STRING { cout << "reading a METHOD field! " << $1 << endl; }
	;
URI:
	STRING { cout << "reading a URI field! " << $1 << endl; }
	;
VERSION:
	STRING { cout << "reading a VERSION field! " << $1 << endl; }
	;
STATUS_CODE:
	INT       { cout << "reading a STATUS_CODE field! " << $1 << endl; }
	;
SIZE:
	INT       { cout << "reading a SIZE field! " << $1 << endl; }
	;
endl:
	END
	;

%%

int main(int, char**) {
	// open a file handle to a particular file:
	FILE *myfile = fopen("in.apache", "r");
	// make sure it's valid:
	if (!myfile) {
		cout << "I can't open in.apache file!" << endl;
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;

	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
	
}

void yyerror(const char *s) {
	cout << "EEK, parse error!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}