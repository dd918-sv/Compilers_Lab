output.txt: a.out ass3_22CS10072_22CS10021_test.c
	./a.out < ass3_22CS10072_22CS10021_test.c > out.txt

a.out: lex.yy.c ass3_22CS10072_22CS10021.c
	gcc ass3_22CS10072_22CS10021.c 

lex.yy.c: ass3_22CS10072_22CS10021.l 
	lex ass3_22CS10072_22CS10021.l

ass3_22CS10072_22CS10021.c:
	touch ass3_22CS10072_22CS10021.c

clean:
	rm a.out lex.yy.c out.txt
