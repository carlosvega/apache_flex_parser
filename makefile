all: apache

apache.tab.c apache.tab.h: apache.y
	bison -d apache.y

lex.yy.c: apache.l apache.tab.h
	flex apache.l

apache: lex.yy.c apache.tab.c apache.tab.h
	g++ -O3 -Ofast -funroll-loops apache.tab.c lex.yy.c -ll -o apache
clean:
	rm -f apache apache.tab.c apache.tab.h lex.yy.c