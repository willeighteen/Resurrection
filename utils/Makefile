# Makefile for Resurrection/utils

all: makeFtables

makeFtables:
	g++ -c makeFtables.cc hetconvert/HetConvert.cc \
hetconvert/FileAccess.cc

	g++ -s -o makeFtables makeFtables.o HetConvert.o FileAccess.o
	rm *.o

install:

clean:
	rm makeFtables
