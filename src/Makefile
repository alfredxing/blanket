OBJS = parser.o lex.o main.o

CC = g++
CFLAGS = -g -Wall -ll

main: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o main

lex.o: grammar/tokens.l
	flex -o lex.cc grammar/tokens.l
	$(CC) $(CFLAGS) -c lex.cc -o lex.o

parser.o: grammar/parser.y
	bison -d -v -o parser.cc grammar/parser.y
	$(CC) $(CFLAGS) -c parser.cc -o parser.o

main.o: main.cc
	$(CC) $(CFLAGS) -c main.cc -o main.o

clean:
	rm -f parser.cc parser.hh parser.output lex.cc main *.o
