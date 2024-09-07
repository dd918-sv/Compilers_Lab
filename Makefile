all: smpl.txt lex.yy.c y.tab.h
	yacc -d expr.y
	lex expr.l
	gcc expr.c

run:
	./a.out<smpl.txt>out.txt
	./a.out<smpl.txt

lex.yy.c: expr.l expr.y
	lex expr.l

y.tab.h: expr.y
	yacc -d expr.y

clean:
	rm -f  *.yy.c *.tab.* *.out out.txt