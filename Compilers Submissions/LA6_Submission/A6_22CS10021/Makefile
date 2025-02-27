all: 	
	yacc -d prog.y
	lex prog.l
	g++ codegen.cpp  -o codegen 

run: all
	./codegen < sample.txt

clean: 
	rm -f lex.yy.c y.tab.c y.tab.h codegen target_code.txt intermediate.txt 