BASE=tinyC2_22CS10021_22CS10072

# output.txt: a.out test.c
# 	./a.out < test.c > out.txt

all:
	yacc -d $(BASE).y
	lex $(BASE).l
	gcc $(BASE).c
	./a.out < input_22CS10021_22CS10072.c>output_22CS10021_22CS10072.txt
clean:
	rm -f a.out y.tab.c lex.yy.c y.tab.h output_22CS10021_22CS10072.txt
