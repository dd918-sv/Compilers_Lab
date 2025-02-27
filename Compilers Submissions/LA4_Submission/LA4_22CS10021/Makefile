all: 
	yacc -d poly.y
	lex poly.l
	gcc  polyutils.c
run:	
	./a.out<sample.txt>output.txt
clean:
	rm -f lex.yy.c y.tab.c y.tab.h  output.txt a.out