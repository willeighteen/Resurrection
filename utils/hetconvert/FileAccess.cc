/*
	FileAccess.cc - read/write binary and text files

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

#include "FileAccess.h"
#include <errno.h>
#include <string.h>


FileAccess::FileAccess ( char *path, char *mode )
{
	_fileSize = 0;
	_filePos = 0;
	_elementSize = 0;
	_numElements = 0;
	_errNum = 0;		// set on error, plus appropriate string
	errno = 0;		// null global error variable before use


	if ( ( _file = fopen ( path, mode ) ) != NULL )
	{
		fseek ( _file, 0L, SEEK_END );
		_fileSize = ftell ( _file );
		fseek ( _file, 0L, SEEK_SET );
	}

	_errNum = errno;

	if ( _errNum != 0 )
		_error = strerror ( errno );
	else
		_error = (char *) "\0";
}
 

FileAccess::~FileAccess()
{
    if ( _file )
		fclose ( _file );
}


// read text file
char * FileAccess::readF ( char *textbuf )
{
	return ( ( char * ) readF ( textbuf, _fileSize ) );	// don't need to check for an '\n'
}


char * FileAccess::readF ( char *textbuf, unsigned int maxchars )
{
	_errNum = 0;

	if ( fgets ( textbuf, maxchars, _file ) != NULL )
	{
		fseek ( _file, 0L, SEEK_CUR );
		_filePos = ftell ( _file );
	}
	else
	{
		_errNum = -1;
		
		if ( _filePos == 0 )
			_error = (char *) "File is empty";
		else
			_error = (char *) "File read error (EOF)";
	}

	return textbuf;
}


// read binary file
int FileAccess::readF ( void *storage )
{
	if ( ( _elementSize > 0 ) && ( _numElements > 0 ) )
		return readF ( storage, _elementSize, _numElements );
	else
		return -1;	// error, set parameter methods not called
}


int FileAccess::readF ( void *storage, unsigned int elementSize, unsigned int numElements )
{
	int itemsRead;
	unsigned int remainder = _fileSize - _filePos;

	_errNum = 0;
	
	if ( remainder < elementSize * numElements )
		itemsRead = fread ( storage, elementSize, remainder / elementSize, _file );
	else
		itemsRead = fread ( storage, elementSize, numElements, _file  );

	fseek ( _file, 0L, SEEK_CUR );
	_filePos = ftell ( _file );

	return itemsRead;
}


// write text file
int FileAccess::writeF ( char *text )
{
	int bytesWritten;

	bytesWritten =  fputs ( text, _file );	// leave user to write '\0' at end of file
	_filePos = ftell ( _file );
	fseek ( _file, 0L, SEEK_CUR );
	return bytesWritten;
}


// write binary file
int FileAccess::writeF ( void *storage )
{
	if ( ( _elementSize > 0 ) && ( _numElements > 0 ) )
		return writeF ( storage, _elementSize, _numElements );
	else
		return -1;
}


int FileAccess::writeF ( void *storage, unsigned int elementSize, unsigned int numElements )
{
	unsigned int itemsWritten;

	_errNum = 0;
	itemsWritten = fwrite ( storage, elementSize, numElements, _file );

	if ( feof ( _file ) )
	{
		_errNum = -1;
		_error = (char *) "End of file";
		return -1;
	}
	else
	{
		if ( ferror ( _file ) )
		{
			_errNum = ferror ( _file );
			_error = (char *) "Unspecified binary write error";
			return -1;
		}
	}
	
	fseek(_file, 0L, SEEK_CUR);
	_filePos = ftell( _file );

	return itemsWritten;
}


// set file pointer
int FileAccess::filePos ( unsigned int filePos )
{
	int error;
	
	_filePos = filePos;

	fseek ( _file, 0L, SEEK_END );
	_fileSize = ftell ( _file );

	error = fseek ( _file, _filePos, SEEK_SET );

	if ( error )
	{
		_errNum = error;
		_error = strerror ( _errNum );
	}
	
	return error;
}
