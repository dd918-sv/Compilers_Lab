all:
	yacc -d expr.y
	lex expr.l
	gcc intgencode.c -o icgen

run: 
	./icgen<sample.txt
	gcc intcode.c -o ic
	./ic>output.txt

clean:
	rm -f icgen ic intcode.c output.txt lex.yy.c y.tab.c y.tab.h
