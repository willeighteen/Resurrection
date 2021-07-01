/*
	FileAccess.h

	Will 18, 2000-2013: wj18@talktalk.net

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

	See COPYING for full details.
*/

#ifndef _FILEACCESS_H
#define _FILEACCESS_H


#include <stdio.h>


class FileAccess
{
	public:
		FileAccess ( char *, char * );
		~FileAccess();

 		char * readF ( char * );										// string
		char * readF ( char *, unsigned int );						// string
		int readF ( void * );								// bin
		int readF ( void *, unsigned int, unsigned int );	// bin
		int writeF ( char * );								// string
		int writeF ( void * );								// bin
		int writeF ( void *, unsigned int, unsigned int );	// bin
		
		unsigned int filePos() { return _filePos; }
		int filePos ( unsigned int );
		unsigned int fileSize() { return _fileSize; }
		void elementSize ( unsigned int num ) { _elementSize = num; }
		void numElements ( unsigned int num ) { _numElements = num; }
		
		char * error() { return _error; }
		int errNum() { return _errNum; }

	private:
		FILE * _file;
		char * _path;
		char * _error;	// error status on last op.
		unsigned int _fileSize;
		unsigned int _filePos;
		unsigned int _elementSize;
		unsigned int _numElements;
		int _errNum;
};
		
#endif


/*
  Notes:

  Intended to unify the handling of binary and text mode files.
  The protected data members store information about the currently opened
  file.
  
  The class supports the convenience functions char * readF(char *) and int writeF(void *)
  for reading text and binary files respectively, and also writeF(char *) and
  writeF(void *), their 'write' counterparts.
  
  The text read method readF(char *) supports an indeterminate line length; this defaults
  to the value of _fileSize.
  
  The private data members _elementSize and numElements provide for binary read
  and write operations where data of fixed size is to be read or written ( e.g.
  structs). These two values, once initialised, allow for the use of
  readF(&storage), writeF(&storage);
  
  Note that the text method writeF(char *) simply writes the text as given; there
  is no automatic trailing '\n', neither is the trailing '\0' written at the end
  of the file. These are the province of the user.
  
  Files are automatically opened on instantiation of an instance of the class,
  and closed on its destruction.
  
  readF(char *)		access text file - read unknown number of chars, perhaps till
				EOF.
  readF(int)	text access but read at most maxchars-1 chars.

  Typical usage:
  
  	// text
  	FileAccess *myFile = new FileAccess ( "textFile", "r" );
	FileAccess *myOutFile = new FileAccess ( "out", "w" );
	char buf[myFile->fileSize()];

	while ( myFile->filePos() < myFile->fileSize() )	
	{
		char buf[ 1024 ];
		myFile->readF((char *) &buf) );
		myOutFile->writeF ( buf );
		printf ( "%s", buf );	
	}

	delete myOutFile;
	delete myFile;

	// binary
	FileAccess *myFile = new FileAccess ( "binaryFile", "r" );
	char c;
	
	while ( myFile->filePos() < myFile->fileSize() )	
	{
		myFile->readF ( &c, 1, 1 );
		printf ( "%c", (char *) c );
	}

	delete myFile;

	// binary file copy
	FileAccess *inFile = new FileAccess ( "test", "r" );
	FileAccess *outFile = new FileAccess ( "out", "w" );
	int bufSize = 1000;
	int bytesRead;
	char buf[bufSize];

	inFile->numElements ( 1 );
	inFile->elementSize ( bufSize );
	outFile->numElements ( 1 );
	outFile->elementSize ( bufSize );
	
	while ( inFile->filePos() < inFile->fileSize() )	
	{
		bytesRead = inFile->readF ( &buf );

		if (  bytesRead < bufSize )
			outFile->elementSize ( bytesRead );
		
		outFile->writeF ( &buf );	// call the right 'write'!
	}

	// alternatively, in one go
	char buf [ inFile->fileSize() ];
	inFile->readF ( &buf, inFile->fileSize(), 1 );
	outFile->writeF ( &buf, inFile->fileSize(), 1 );	// call the right 'write'!
	// end alternative
	
	delete outFile;
	delete inFile;
	
*/
