# Makefile for Resurrection/utils
# Will 18, 2021


all: makeHet makeTbls makeInstrHdr

makeHet:
	gcc -c het2ftbl.c
	gcc -lm -s -o het2ftbl het2ftbl.o

	rm het2ftbl.o

makeTbls:
	gcc -c makeFtables.c
	gcc -s -o  makeFtables makeFtables.o

	rm makeFtables.o

makeInstrHdr:
	gcc -c makeInstrumentHeader.c
	gcc -s -o makeInstrumentHeader makeInstrumentHeader.o
	
	rm makeInstrumentHeader.o

install:

clean:
	rm -f het2ftbl makeFtables makeInstrumentHeader

