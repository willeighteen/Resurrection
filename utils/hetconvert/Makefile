# Makefile for hetconvert-1.6.1

all: hetcnv

hetcnv:
	g++ -c main.cc HetConvert.cc FileAccess.cc
 
	g++ -o hetcnv main.o HetConvert.o FileAccess.o
	rm *.o

install:

clean:
	rm hetcnv
