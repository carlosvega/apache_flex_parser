all: apache

apache.tab.c apache.tab.h: apache.y
	bison -d apache.y

lex.yy.c: apache.l apache.tab.h
	flex -CFr apache.l

apache: lex.yy.c apache.tab.c apache.tab.h
	OS := $(shell uname)
	ifeq $(OS) Darwin
	g++ apache.tab.c lex.yy.c -ll -o apache
	else
	g++ apache.tab.c lex.yy.c -lfl -o apache
	endif
clean:
	rm -f apache apache.tab.c apache.tab.h lex.yy.c
