/*
	HetConvert.cc
	Version 1.6.1

	Will 18, 2007-2013, 2019
	will18@virginmedia.com
	eighteenwill@gmail.com

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
	
	credits: twobob (bugs; trust the time wasn't wasted)
*/


#include "HetConvert.h"

#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>


HetConvert::HetConvert ( const char * const name )
{
	_className = name;
	_showProgress = 0;
	_baseFtblNum = 1;
	_hetDataTracks = 1;
	_fpDigits = 0;
	_startFrqScan = 0.33;
	_endFrqScan = 0.66;
	_writeFrqDiff = 0;
	strncpy ( _outMode, "w", 1 );
	_releaseMag = 0.9;
}


HetConvert::HetConvert ( const char * const name, unsigned int showProgress )
{
	_className = name;
	_showProgress = showProgress;
	_baseFtblNum = 1;
	_hetDataTracks = 1;
	_fpDigits = 0;
	_startFrqScan = 0.33;
	_endFrqScan = 0.66;
	_writeFrqDiff = 0;
	strncpy ( _outMode, "w", 1 );
	_releaseMag = 0.9;
}


HetConvert::~HetConvert()
{
	// empty
}


int HetConvert::ascToHet ( char *infile )
{
	int nameLen, error;
	
	nameLen = strlen ( _className ) + strlen ( infile ) + 6;

	char outfile [ nameLen + 1 ];

	snprintf ( outfile, nameLen, "%s-%s.het", _className, infile );
	outfile [ nameLen ] = 0;

	if ( ascToHet ( infile, ( char * ) &outfile ) != 0 )
		return ( 1 );

	return ( 0 );
}


int HetConvert::ascToHet ( char *infile, char *outfile )
{
	unsigned int srcNameLen, dstNameLen, error;

	srcNameLen = strlen ( ( char * ) infile );
	dstNameLen = strlen ( ( char * ) outfile );

	char srcFile [srcNameLen + 1 ];
	char dstFile [dstNameLen + 1 ];

	strncpy ( srcFile, infile, srcNameLen );
	srcFile [ srcNameLen ] = 0;

	strncpy ( dstFile, outfile, dstNameLen );
	dstFile [ dstNameLen ] = 0;

	// can we open source for read?
	FileAccess *in = new FileAccess ( infile, (char *) "r" );

	if ( in->errNum() != 0 )
	{
		errorMessage ( in->error() );
		error = in->errNum();
		delete in;
		return ( error );
	}

	// can we open dst for write?
	FileAccess *out = new FileAccess ( outfile, (char *) "w" );

	if ( out->errNum() != 0 )
	{
		errorMessage ( out->error() );
		error = out->errNum();
		delete out;
		return ( error );
	}


	if ( ascToHet ( in, out ) == -1 )
		return ( -1 );

	if ( _showProgress )
		printf ( (char *) "\n" );

	delete in;
	delete out;
	return ( 0 );
}


int HetConvert::ascToHet ( FileAccess *in, FileAccess *out )
{
	unsigned int percentDone = 0;
	unsigned int percent = 0;
	int intSize = sizeof ( int );

	/* exec goes on in here */
	/* runs as independent process */
	char buf[BUFSIZE];
	unsigned int backtrack, bufSize, numInts;

	bufSize = sizeof ( buf ) - 1;
	numInts = 0;

	if ( _showProgress )
		printf ( (char *) "percent done: \n" );

	while ( in->filePos() < in->fileSize() )
	{
		in->readF ( buf, BUFSIZE );

		if ( buf[0] == ';' )
		{
			if ( strstr ( buf, (char *) "amplitude breakpoint set" ) != NULL )
			{
				_num0 = -1;
        			out->writeF ( &_num0, intSize, 1 );
			}

			if ( strstr ( buf, (char *) "frequency breakpoint set" ) != NULL )
			{
        			_num0 = -2;
        			out->writeF ( &_num0, intSize, 1 );
			}

			if ( strstr ( buf, (char *) "end track" ) != NULL )
			{
				_num0 = 32767;
				out->writeF ( &_num0, intSize, 1 );
			}
		}
		else
		{
			if ( numInts == 0 )
			{
				sscanf ( buf, "%d", &_num0 );
				out->writeF ( &_num0, intSize, 1 );
				numInts++;
			}
			else
			{
				sscanf ( buf, "%d %d", &_num0, &_num1 );
				out->writeF ( &_num0, intSize, 1 );
				out->writeF ( &_num1, intSize, 1 );
				numInts++;
			}
		}

		percent = ( int ) ( ( float ) in->filePos() / ( float ) in->fileSize() * 100 );

		if ( ( percentDone != percent ) && _showProgress )
		{
			percentDone = percent;
			displayProgress ( percentDone );
		}
	}

	return ( 0 );
}


int HetConvert::hetToAsc ( char *infile )
{
	int nameLen, error;
	
	nameLen = strlen ( _className ) + strlen ( infile ) + 7;

	char outfile [ nameLen + 1 ];

	snprintf ( outfile, nameLen, "%s-%s.asc", _className, infile );
	outfile [ nameLen ] = 0;

	if ( hetToAsc ( infile, ( char * ) &outfile ) != 0 )
		return ( 1 );

	return ( 0 );
}


int HetConvert::hetToAsc ( char *infile, char *outfile )
{
	unsigned int srcNameLen, dstNameLen, error;
	
	srcNameLen = strlen ( ( char * ) infile );
	dstNameLen = strlen ( ( char * ) outfile );
	
	char srcFile [ srcNameLen + 1 ];
	char dstFile [ dstNameLen + 1 ];

	strncpy ( srcFile, infile, srcNameLen );
	srcFile [ srcNameLen ] = 0;

	strncpy ( dstFile, outfile, dstNameLen );
	dstFile [ dstNameLen ] = 0;
	FileAccess *in = new FileAccess ( srcFile, (char *) "r" );

	if ( in->errNum() != 0 )
	{
		errorMessage ( in->error() );
		error = in->errNum();
		delete in;
		return ( error );
	}

	FileAccess *out = new FileAccess ( dstFile, (char *) "w" );

	if ( out->errNum() != 0 )
	{
		errorMessage ( out->error() );
		error = out->errNum();
		delete out;
		return ( error );
	}

	if ( hetToAsc ( in, out, srcFile ) == -1 )
		return ( -1 );

	if ( _showProgress )
		printf ( "\n" );

	delete in;
	delete out;
	return ( 0 );
}


int HetConvert::hetToAsc ( FileAccess *in, FileAccess *out, char *srcFile )
{
	unsigned int backtrack, bufSize, trackNum;
	unsigned int percentDone = 0;
	unsigned int percent = 0;
	int count = 0;
	int length, n, numElements;
	char buf[BUFSIZE];
	char stringNum[BUFSIZE];

	bufSize = sizeof ( buf ) - 1;
	numElements = 1;
	trackNum = 1;

	if ( _showProgress )
		printf ( (char *) "percent done: \n" );

	in->readF(buf, 1, 6);

	if (strncmp ( buf, "HETRO ", 6 ) != 0 )
	{
		printf("unrecognised file format '%s'\n", buf);
		return ( 1 );
	}

	in->readF(buf);
	sscanf ( buf, "%d", &_num0 );
	snprintf ( buf, bufSize, "; source file %s\n", srcFile );
	out->writeF ( buf );
	snprintf ( buf, bufSize, "; number of harmonics (amp/frq track pairs):\n" );
	out->writeF (buf );
	snprintf ( buf, bufSize, "%d", _num0 );	// number of tracks
	out->writeF ( buf );
	snprintf ( buf, bufSize, "\n;\n" );
	out->writeF ( buf );
	numElements = 2;
	in->readF ( buf, 1 , numElements );	// -1 = amp trk, -2 = frq trk
	sscanf ( buf, "%d", &_num0 );
	buf[0] = 0;
	buf[1] = 0;
	in->readF ( buf, 1, 1 ); // read comma

	while ( in->filePos() <= in->fileSize() )
	{
		switch ( _num0 )
		{
			case -1:	/* begin amplitude breakpoint set */
				snprintf ( buf, bufSize, "; track %d\n", trackNum );
				out->writeF ( buf );
				out->writeF ( (char *) "; amplitude breakpoint set\n" );
				out->writeF ((char *)  "; time (ms), amplitude\n" );
				numElements = 2;
				break;

			case -2:	/* begin frequency breakpoint set */
				snprintf ( buf, bufSize, "; track %d\n", trackNum );
				out->writeF ( buf );
				out->writeF ( (char *) "; frequency breakpoint set\n" );
				out->writeF ( (char *) "; time (ms), frequency (Hz.)\n" );
				numElements = 2;
				break;

			case 32767:	/* track end */
				out->writeF ( (char *) "; end track\n" );
				numElements = 1;
				trackNum++;

				if ( in->filePos() == in->fileSize() )
					return ( 0 );
				else
				{
					out->writeF ( (char *) ";\n" );
					backtrack = 6;
				}

				in->filePos ( in->filePos() - backtrack );
				break;
		}
		length = strlen ( buf );

		for ( n = 0; n < length; n++ )
			buf[n] = 0;

		length = strlen ( stringNum) ;

		for ( n = 0; n < length; n++ )
			stringNum[n] = 0;

		count = 0;	// reset
				
		while ( count < numElements )
		{
			in->readF ( buf, 1, 1 );

			if ( in->filePos() == in->fileSize() )
				count = numElements;
			else
				if ( strncmp ( buf, ",", 1 ) == 0 )	// count commas
					count++;
			strncat ( stringNum, buf, 1 );
		}

		sscanf ( stringNum, "%d,%d", &_num0, &_num1 );

		if ( numElements == 2 && _num0 != 32767 )
		{
			snprintf ( buf, 12, "%d %d\n", _num0, _num1 );
			out->writeF ( buf );
		}

		percent = ( int ) ( ( float ) in->filePos() / ( float ) in->fileSize() * 100 );

		if ( ( percentDone != percent ) && _showProgress )
		{
			percentDone = percent;
			displayProgress ( percentDone );
		}
		length = strlen ( buf );

		for ( int n = 0; n < length; n++ )
			buf[n] = 0;
	}
}

int HetConvert::ascToFnc ( char *infile )
{
	int nameLen, error;
	
	nameLen = strlen ( _className ) + strlen ( infile ) + 7;

	char outfile [ nameLen + 1 ];

	snprintf ( outfile, nameLen, "%s-%s-ftbl", _className, infile );
	outfile [ nameLen ] = 0;

	if ( ascToFnc ( infile, ( char * ) &outfile ) != 0 )
		return ( 1 );
	
	return ( 0 );
}


int HetConvert::ascToFnc ( char *infile, char *outfile )
{
	if ( ascToFnc ( infile, outfile, _baseFtblNum, _outMode ) != 0 )
		return 1;

	return ( 0 );
}


int HetConvert::ascToFnc ( char *infile, char *outfile, unsigned int baseFtblNum )
{
	if ( ascToFnc ( infile, outfile, _baseFtblNum, (char *) "w" ) != 0 )
		return 1;

	return ( 0 );
}


int HetConvert::ascToFnc ( char *infile, char *outfile, unsigned int  baseFtblNum, char *outMode )
{
	int error;

	FileAccess *in = new FileAccess ( infile, (char *) "r" );

	if ( in->errNum() != 0 )
	{
		errorMessage ( in->error() );
		error = in->errNum();
		delete in;
		return ( error );
	}

	FileAccess *out = new FileAccess ( outfile, outMode );

	if ( out->errNum() != 0 )
	{
		errorMessage ( out->error() );
		error = out->errNum();
		delete out;
		return ( error );
	}

	if ( writeFtblFile ( in, out, infile, baseFtblNum   ) == -1 )
	{
		delete in;
		return ( -1 );
	}

	if ( _showProgress )
		printf ( "\n" );

	delete in;
	return ( 0 );
}


int HetConvert::ascToPeak ( char *infile )
{
	int nameLen, error;
	
	nameLen = strlen ( _className ) + strlen ( infile ) + 7;

	char outfile [ nameLen + 1 ];

	snprintf ( outfile, nameLen, "%s-%s-ftbl", _className, infile );
	outfile [ nameLen ] = 0;

	if ( ascToPeak ( infile, ( char * ) &outfile ) != 0 )
		return ( 1 );
	
	return ( 0 );
}


int HetConvert::ascToPeak ( char *infile, char *outfile )
{
	if ( ascToPeak ( infile, outfile, _baseFtblNum, _outMode ) != 0 )
		return 1;

	return ( 0 );
}


int HetConvert::ascToPeak ( char *infile, char *outfile, unsigned int baseFtblNum )
{
	if ( ascToPeak ( infile, outfile, _baseFtblNum, (char *) "w" ) != 0 )
		return 1;

	return ( 0 );
}


int HetConvert::ascToPeak ( char *infile, char *outfile, unsigned int  baseFtblNum, char *outMode )
{
	int error;

	FileAccess *in = new FileAccess ( infile, (char *) "r" );

	if ( in->errNum() != 0 )
	{
		errorMessage ( in->error() );
		error = in->errNum();
		delete in;
		return ( error );
	}

	FileAccess *out = new FileAccess ( outfile, outMode );

	if ( out->errNum() != 0 )
	{
		errorMessage ( out->error() );
		error = out->errNum();
		delete out;
		return ( error );
	}

	if ( writePeakMagFtbl ( in, out, infile, baseFtblNum  ) == -1 )
	{
		delete in;
		return ( -1 );
	}

	if ( _showProgress )
		printf ( "\n" );

	return ( 0 );
}



int HetConvert::ascToShort ( char *infile )
{
	int nameLen;
	
	nameLen = strlen ( _className ) + strlen ( infile ) + 6;

	char outfile [ nameLen ];

	snprintf ( outfile, nameLen, "%s-%s-int", _className, infile );
	outfile [ nameLen ] = 0;

	if ( ascToShort ( infile, ( char * ) &outfile ) != 0 )
		return ( 1 );
	
	return ( 0 );
}


int HetConvert::ascToShort ( char *infile, char *outfile )
{
	unsigned int srcNameLen, dstNameLen, error;

	srcNameLen = strlen ( ( char * ) infile );
	dstNameLen = strlen ( ( char * ) outfile );

	char srcFile [ srcNameLen + 1 ];
	char dstFile [ dstNameLen + 2 ];

	strncpy ( srcFile, infile, srcNameLen );
	srcFile [ srcNameLen ] = 0;

	strncpy ( dstFile, outfile, dstNameLen );
	dstFile [ dstNameLen ] = '-';
	dstFile [ dstNameLen + 1 ] = 0;

	FileAccess *in = new FileAccess ( srcFile, (char *) "r" );

	if ( in->errNum() != 0 )
	{
		errorMessage ( in->error() );
		error = in->errNum();
		delete in;
		return ( error );
	}

	if ( writeIntFile ( in, srcFile, dstFile ) == -1 )
	{

		delete in;
		return ( -1 );
	}

	if ( _showProgress )
		printf ( (char *) "\n" );

	delete in;
	return 0;
}


int HetConvert::fncToRaw ( char *infile )
{
	int nameLen;
	
	nameLen = strlen ( _className ) + strlen ( infile ) + 6;

	char outfile [ nameLen ];

	snprintf ( outfile, nameLen, "%s-%s-asc", _className, infile );
	outfile [ nameLen ] = 0;

	if ( fncToRaw ( infile, ( char * ) &outfile ) != 0 )
		return ( 1 );
	
	return ( 0 );
}


int HetConvert::fncToRaw ( char *infile, char *outfile )
{
	unsigned int srcNameLen, dstNameLen, error;

	srcNameLen = strlen ( ( char * ) infile );
	dstNameLen = strlen ( ( char * ) outfile );

	char srcFile [ srcNameLen + 1 ];
	char dstFile [ dstNameLen + 2 ];

	strncpy ( srcFile, infile, srcNameLen );
	srcFile [ srcNameLen ] = 0;

	strncpy ( dstFile, outfile, dstNameLen );
	dstFile [ dstNameLen ] = '-';
	dstFile [ dstNameLen + 1 ] = 0;

	FileAccess *in = new FileAccess ( srcFile, (char *) "r" );

	if ( in->errNum() != 0 )
	{
		errorMessage ( in->error() );
		error = in->errNum();
		delete in;
		return ( error );
	}

	if ( fncToRaw ( in, srcFile, dstFile ) == -1 )
	{
		delete in;
		return ( -1 );
	}

	if ( _showProgress )
		printf ( (char *) "\n" );

	delete in;
	return 0;
}


int HetConvert::intToHet ( char *infile )
{
	int nameLen;
	
	nameLen = strlen ( infile ) + 6;

	char outfile [ nameLen ];

	snprintf ( outfile, sizeof ( outfile ), "%s.het", infile );
	outfile [ nameLen ] = 0;

	if ( intToHet ( infile, ( char * ) &outfile ) != 0 )
		return ( 1 );
	
	return ( 0 );
}


int HetConvert::intToHet ( char *infile, char *outfile )
{
	unsigned int nameLen;

	nameLen = strlen ( ( char * ) infile );

	char srcFile [ nameLen + 2 ];

	snprintf( srcFile, sizeof ( srcFile ), "%s-", infile );
	srcFile [ nameLen + 1 ] = 0;

	if ( intToHet ( ( char * ) srcFile, outfile, _hetDataTracks ) != 0 )
		return ( 1 );

	if ( _showProgress )
		printf ( (char *) "\n" );

	return ( 0 );
}


int HetConvert::intToHet ( char *infile, char *outfile, unsigned int hetDataTracks )
{
	if ( hetDataTracks == 0 )
	{

		if ( _hetDataTracks == 0 )
		{
			char msg[BUFSIZE];

			strncpy ( msg, "Default number of data tracks zero. Specify tracks or use\n\
ascToFnc and read the track count from the output file.", sizeof ( msg ) );
			msg [ sizeof ( msg ) -1 ] = 0;
			errorMessage ( msg );
			return ( 1 );
		}
		
		hetDataTracks = _hetDataTracks;
	}

	FileAccess *out = new FileAccess ( outfile, (char *) "w" );

	if ( intToHet ( infile, out, hetDataTracks ) != 0 )
	{
		delete out;
		return ( 1 );
	}

	delete out;
	return ( 0 );
}


int HetConvert::intToHet ( char *infile, FileAccess *out, unsigned int hetDataTracks )
{
	int error, intSize, percent, percentDone;
	short int num[2];
	float time;

	num[0] = ( short int ) hetDataTracks;

	intSize = sizeof ( short int );
	out->elementSize ( intSize );
	out->numElements ( 1 );
	out->writeF ( &num[0] );	// write number of data tracks

	char intFile[BUFSIZE];
	char timeFile[BUFSIZE];
	char dataType;
	int count = 0;

	while ( count < 2*hetDataTracks )
	{
		if ( ( ( float ) count / 2 ) - int ( count / 2 ) == 0 )
			dataType = 'a';
		else
			dataType = 'f';

		snprintf ( intFile, sizeof (intFile ), "%s%c%d", infile, dataType,
					( int ( ( count / 2 ) + 1 ) - 1 ) );
		intFile [ sizeof ( intFile ) - 1 ] = 0;

		FileAccess *in = new FileAccess ( intFile, (char *) "r" );

		if ( in->errNum() != 0 )
		{
			errorMessage ( in->error() );
			error = in->errNum();
			delete in;
			return ( error );
		}

		snprintf ( timeFile, sizeof (timeFile ), "%stime-%c%d", infile, dataType,
					( int ( ( count / 2 ) + 1 ) - 1 ) );
		timeFile [ sizeof ( timeFile ) - 1 ] = 0;

		FileAccess *time = new FileAccess ( timeFile, (char *) "r" );

		if ( time->errNum() != 0 )
		{
			errorMessage ( time->error() );
			error = time->errNum();
			delete time;
			return ( error );
		}

		if ( dataType == 'a' )
			num[0] = ( short int ) -1;
		else
			num[0] = ( short int ) -2;

		out->writeF ( &num[0] );	// amp/frq track start flag

		in->elementSize ( intSize );
		in->numElements ( 1 );
		time->elementSize ( intSize );
		time->numElements ( 1 );
		out->numElements ( 2 );	// duration (ms), value

		while ( in->filePos() < in->fileSize() )
		{
			time->readF ( &num[0] );
			in->readF ( &num[1] );
			out->writeF ( &num );
		}

		out->numElements ( 1 );
		num[0] = ( short int ) 32767;
		out->writeF ( &num[0] );	// track end flag

		delete time;
		delete in;

		percent = ( int ) ( ( float ) count / ( float ) hetDataTracks ) * 100;

		if ( ( percentDone != percent ) && _showProgress )
		{
			percentDone = percent;
			displayProgress ( percentDone );
		}
		count++;
	}

	return ( 0 );
}


int HetConvert::writePeakMagFtbl ( FileAccess *in, FileAccess *out, char *srcFile, unsigned int baseFtblNum )
{
	char buf[BUFSIZE];
	char floatString[16];
	float datumF;
	unsigned int percent = 0;
	unsigned int percentDone = 0;
	unsigned int bufSize, datum, exponent, ftblSize, maxAmp;
	unsigned int srcTracks, trackMax, trackNum;

	snprintf( _formatString, sizeof ( _formatString ), "%s%u%s", "%.", _fpDigits, "f" );
	bufSize = sizeof ( buf ) - 1;
	ftblSize = 0;
	maxAmp = 0;
	trackNum = 0;

	if ( _showProgress )
		printf ( (char *) "percent done: \n" );

	in->readF ( buf, bufSize );	// original het file
	out->writeF ( buf );
	out->writeF ( (char *) "; via " );
	out->writeF ( srcFile );	// the ascii equivalent
	out->writeF ( (char *) "\n;\n" );
	in->readF ( buf, bufSize );
	out->writeF ( buf );
	in->readF ( buf, bufSize );
	sscanf ( buf, "%u", &srcTracks );
	out->writeF ( (char *) "; " );
	out->writeF ( buf );
	out->writeF ( (char *) ";\n" );

	unsigned int startPos, endPos, dur;

	while ( in->filePos() < in->fileSize() )
	{
		in->readF ( buf, bufSize );	// num src tracks

		if ( buf[0] == ';' ) // found at data block end
		{
			if ( strstr ( buf, "amplitude breakpoint set" ) != NULL )
			{
				startPos = in->filePos();

				while ( buf[0] == ';' )	// last  buf item is valid data
					in->readF ( buf, bufSize );

				in->filePos ( in->filePos() - strlen ( buf ) );	// reset to first data

				while ( strstr ( buf, "end track" ) == NULL )	// found it, somewhere
				{
					in->readF ( buf, bufSize );
					sscanf ( buf, "%u %u", &dur, &datum);

					if ( datum > maxAmp )
						maxAmp = datum;
				}

				trackNum++;
			}
		}
	}

	in->filePos(0);
	trackMax = 0;

	for ( exponent = 0; exponent < 8; exponent++ )	// support 128-entry ftables
	{
		if ( ( unsigned int ) pow ( 2, exponent ) >= trackNum )
		{
			ftblSize = ( unsigned int ) pow ( 2, exponent );
			exponent = 8;
		}
	}

	snprintf ( buf, bufSize, "f%u	0	%u	-2\n", baseFtblNum, ftblSize );
	out->writeF ( buf );

	while ( in->filePos() < in->fileSize() )
	{
		in->readF ( buf, bufSize );	// num src tracks

		if ( buf[0] == ';' ) // found at data block end
		{
			if ( strstr ( buf, "amplitude breakpoint set" ) != NULL )
			{
				trackMax = 0;

				while ( buf[0] == ';' )	// last  buf item is valid data
					in->readF ( buf, bufSize );

				in->filePos ( in->filePos() - strlen ( buf ) );	// reset to first data

				while ( strstr ( buf, "end track" ) == NULL )	// found it, somewhere
				{
					in->readF ( buf, bufSize );

					sscanf ( buf, "%u %u", &dur, &datum);

					if ( datum > trackMax )
						trackMax = datum;
				}

				datumF = (float) trackMax;
				
				if ( _fpDigits>0 )
					datumF = (float) trackMax / (float) maxAmp;

				snprintf ( floatString, sizeof ( floatString ), _formatString, datumF );
				snprintf ( buf, bufSize, "%s\n", floatString );
				out->writeF ( buf );

			}
		}
	}

	datumF = 0.0;
	snprintf ( floatString, sizeof ( floatString ), _formatString, datumF );
	snprintf ( buf, bufSize, "%s\n", floatString );

	while ( trackNum < ftblSize )
	{
		out->writeF ( buf );
		trackNum++;
	}

	out->writeF( (char *) "\n");

	percent = ( int ) ( ( float ) in->filePos() / ( float ) in->fileSize() * 50 );

	if ( ( percentDone != percent ) && _showProgress )
	{
		percentDone = percent;
		displayProgress ( percentDone );
	}
}


int HetConvert::writeFtblFile ( FileAccess *in, FileAccess *out, char *srcFile, unsigned int baseFtblNum )
{
		writeFtblFile ( in, out, srcFile, baseFtblNum, _writeFrqDiff );
}


int HetConvert::writeFtblFile ( FileAccess *in, FileAccess *out, char *srcFile, unsigned int baseFtblNum, unsigned int frqType )
{
	char buf[BUFSIZE];
	unsigned int percent = 0;
	unsigned int percentDone = 0;
	unsigned int bufSize, datum, dur, exponent, ftblSize;
	unsigned int maxAmp, maxDatumValues, maxDur, numDatumValues;
	unsigned int peakTrack, srcTracks, trackMax;

	snprintf( _formatString, sizeof ( _formatString ), "%s%u%s", "%.", _fpDigits, "f" );
	snprintf( _frqDiffFormatString, sizeof ( _frqDiffFormatString ), "%s%u%s", "%.", _frqDiffFpDigits, "f" );
	bufSize = sizeof ( buf ) - 1;
	ftblSize = 0;
	maxAmp = 0;
	maxDatumValues = 0;
	maxDur = 0;

	if ( _showProgress )
		printf ( (char *) "percent done: \n" );

	in->readF ( buf, bufSize );	// original het file
	out->writeF ( buf );
	out->writeF ( (char *) "; via " );
	out->writeF ( srcFile );	// the ascii equivalent
	out->writeF ( (char *) "\n;\n" );
	in->readF ( buf, bufSize );
	out->writeF ( buf );
	in->readF ( buf, bufSize );
	sscanf ( buf, "%u", &srcTracks );
	out->writeF ( (char *) "; " );
	out->writeF ( buf );
	out->writeF ( (char *) ";\n" );

	float avgFreq[srcTracks];
	float avgFrq;
	unsigned int peakTime[srcTracks];
	unsigned int ampTrkNum, avgReleaseTime,endPos, frqTrkNum;
	unsigned int releaseTime, rlsFlag, rlsLevel, startPos, totalValues;
	unsigned int diffValues = 0;

	ampTrkNum = 0;
	frqTrkNum = 0;
	avgReleaseTime = 0;

	while ( in->filePos() < in->fileSize() )
	{
		in->readF ( buf, bufSize );	// num src tracks

		if ( buf[0] == ';' ) // found at data block end
		{
			if ( strstr ( buf, "amplitude breakpoint set" ) != NULL )
			{
				numDatumValues = 0;
				peakTime[ampTrkNum] = 0;
				trackMax = 0;
				startPos = in->filePos();

				while ( buf[0] == ';' )	// last  buf item is valid data
					in->readF ( buf, bufSize );

				in->filePos ( in->filePos() - strlen ( buf ) );	// reset to first data

				do
				{
					in->readF ( buf, bufSize );
					sscanf ( buf, "%u %u", &dur, &datum);
					numDatumValues++;

					if (datum != 32767)
					{
						if ( datum > maxAmp )
						{
							maxAmp = datum;
							peakTrack = ( ampTrkNum<<1 ) + 1;
						}
						if ( dur > maxDur )
							maxDur = dur;
	
						if ( datum > trackMax )
						{
							trackMax = datum;
							peakTime[ampTrkNum] = dur;
						}
					}
				}
				while ( strstr ( buf, "end track" ) == NULL );	// found it, somewhere

				numDatumValues--;

				if ( maxDatumValues < numDatumValues )
					maxDatumValues = numDatumValues;					

				in->filePos ( startPos );	// re-scan for release
				rlsLevel = ( unsigned int ) ( ( ( float ) trackMax * _releaseMag ) + 0.5 );
				rlsFlag = 0;

				while ( buf[0] == ';' )	// last  buf item is valid data
					in->readF ( buf, bufSize );

				in->filePos ( in->filePos() - strlen ( buf ) );	// reset to first data

				while ( strstr ( buf, "end track" ) == NULL )	// found it, somewhere
				{
					in->readF ( buf, bufSize );

					sscanf ( buf, "%u %u", &dur, &datum);

					if ( ( datum < rlsLevel ) && ( dur > peakTime[ampTrkNum] ) )
					{
						if ( !rlsFlag )
						{
							releaseTime = dur;
							rlsFlag = 1;
						}
					}
				}

				avgReleaseTime += releaseTime;
				ampTrkNum++;	// only used here for peakTime calculation
			}

			if ( strstr ( buf, "frequency breakpoint set" ) != NULL )
			{
				numDatumValues = 0;

				while ( buf[0] == ';' )
					in->readF ( buf, bufSize );

				in->filePos ( in->filePos() - strlen ( buf ) );
				startPos = in->filePos();

				while ( strstr ( buf, "end track" ) == NULL )
				{
					in->readF ( buf, bufSize );
					sscanf ( buf, "%u %u", &dur, &datum);
					numDatumValues++;

					if ( dur > maxDur )
						maxDur = dur;
				}

				endPos = in->filePos();
				totalValues = ( unsigned int ) ( numDatumValues * _endFrqScan );

				if ( frqType )
				{
					avgFrq = 0;
					diffValues = 0;
					in->filePos ( startPos );

					while ( diffValues < ( unsigned int ) ( numDatumValues * _startFrqScan ) )
					{
						in->readF ( buf, bufSize );
						diffValues++;
					}

					while ( diffValues < totalValues )
					{
						in->readF ( buf, bufSize );
						sscanf ( buf, "%u %u", &dur, &datum);
						avgFrq += ( float ) datum; 
						diffValues++;
					}

					avgFrq = avgFrq / ( unsigned int ) ( ( ( _endFrqScan - _startFrqScan) * numDatumValues ) + 0.5 );
					in->filePos ( endPos );
				}

				avgFreq[frqTrkNum] = avgFrq;
				numDatumValues--;

				if ( maxDatumValues < numDatumValues )
					maxDatumValues = numDatumValues;

				frqTrkNum++;
			}
		}

		percent = ( int ) ( ( float ) in->filePos() / ( float ) in->fileSize() * 50 );

		if ( ( percentDone != percent ) && _showProgress )
		{
			percentDone = percent;
			displayProgress ( percentDone );
		}
	}

	for ( exponent = 0; exponent < 16; exponent++ )	// support ftables up to 64 kB
	{
		if ( ( unsigned int ) pow ( 2, exponent ) >= maxDatumValues )
		{
			ftblSize = ( unsigned int ) pow ( 2, exponent );	// repeating this is slooow
			exponent = 16;
		}
	}

	avgReleaseTime = ( unsigned int ) ( ( (float ) avgReleaseTime / ( float ) srcTracks) + 0.5 );

	char floatString[16];
	char writeBuf[ bufSize];
	float datumF, datumIncr, durF, interpDatum, intervalTimeF;
	float lastDatumF, lastDurF, remainDurF, tblInterval;
	int numTblItems;
	unsigned int avgPeakTime, i, trackNum;

	avgPeakTime = 0;

	for ( i = 0; i < ampTrkNum; i++ )
		avgPeakTime += peakTime[i];

	avgPeakTime = avgPeakTime / ampTrkNum;

	trackNum = 0;
	tblInterval = maxDur / ftblSize;
	snprintf( writeBuf, bufSize, "; duration %f s\n", ( float ) maxDur / 1000  );	// convert from ms
	out->writeF ( writeBuf );
	snprintf ( writeBuf, bufSize, "; avg. peak time %u ms\n", avgPeakTime );
	out->writeF ( writeBuf );
	snprintf ( writeBuf, bufSize, "; avg. release time %u ms\n", avgReleaseTime );
	out->writeF ( writeBuf );
	snprintf ( writeBuf, bufSize, "; peak amp %u (track %u)\n;\n", maxAmp, peakTrack );
	out->writeF ( writeBuf );
	in->filePos ( 0 );
	trackNum = 0;
	frqTrkNum = 0;

	while ( in->filePos() < in->fileSize() )
	{	// second pass for output write
		in->readF ( buf, bufSize );	// num src tracks

		if ( buf[0] == ';' ) // found at data block end
		{
			if ( strstr ( buf, "amplitude breakpoint set" ) != NULL )
			{
				numDatumValues = 0;	// counts ftable values written

				snprintf( writeBuf, bufSize, ";\n; amp track %u (harmonic %u)\n",
							trackNum + 1, ( int ) trackNum / 2 );
				out->writeF ( writeBuf );
				snprintf ( writeBuf, bufSize, "; peak time %u ms\n", peakTime[trackNum>>1] );
				out->writeF ( writeBuf );
				out->writeF ( (char *) ";\n");

				snprintf ( writeBuf, bufSize, "f%u	0	%u	-2\n",
							baseFtblNum + trackNum, ftblSize );
				out->writeF ( writeBuf );

				while ( buf[0] == ';' )
					in->readF ( buf, bufSize );

				sscanf ( buf, "%u %u", &dur, &datum);
				numDatumValues++;
				datumF = ( float ) datum;
				
				if ( _fpDigits>0 )
					datumF = (float) datum / (float) maxAmp;	// normalised

				snprintf ( floatString, sizeof ( floatString ), _formatString, datumF );
				snprintf ( writeBuf, bufSize, "%s\n", floatString );
				out->writeF ( writeBuf );

				lastDatumF = datumF;
				lastDurF = ( float ) dur;
				in->readF ( buf, bufSize );
				remainDurF = 0;

				while ( ( strstr ( buf, "end track" ) == NULL ) && ( numDatumValues < ( ftblSize - 1 ) ) )
				{
					sscanf ( buf, "%u %u", &dur, &datum );
					datumF = ( float ) datum;
					durF = ( float ) dur;

					intervalTimeF = durF - lastDurF + remainDurF;
					remainDurF = intervalTimeF - tblInterval;
					numTblItems = ( int )  ( intervalTimeF / tblInterval );
					interpDatum = 0;

					datumIncr = ( tblInterval / intervalTimeF ) * ( datumF - lastDatumF );
					datumIncr = datumIncr / numTblItems;

					for ( i = 0; i < numTblItems; i++ )
					{
						interpDatum = ( i + 1 ) * datumIncr + lastDatumF;

						if ( _fpDigits>0 )
							interpDatum = interpDatum / (float) maxAmp;

						snprintf ( floatString, sizeof ( floatString ), _formatString, interpDatum );
						snprintf ( writeBuf, bufSize, "%s\n", floatString );
						out->writeF ( writeBuf );
						numDatumValues++;
					}

					remainDurF -= ( i - 1 ) * tblInterval;
					lastDatumF = interpDatum;
					lastDurF = durF + remainDurF;	// since this is where we actually interpolate to
					in->readF ( buf, bufSize );
				}

				datumF = 0;

				if ( numDatumValues == ftblSize-1 )
				{
					out->filePos ( out->filePos() - strlen ( writeBuf ) );
					snprintf ( floatString, sizeof ( floatString ), _formatString, datumF );
					snprintf ( writeBuf, bufSize, "%s\n", floatString );
					out->writeF ( writeBuf );
				}

				// pad ftable
				snprintf ( floatString, sizeof ( floatString ), _formatString, datumF );
				snprintf ( writeBuf, bufSize, "%s\n", floatString );

				while ( numDatumValues < ftblSize - 1 )
				{
					out->writeF ( writeBuf );
					numDatumValues++;
				}

				trackNum++;
			}

			if ( strstr ( buf, "frequency breakpoint set" ) != NULL )
			{
				numDatumValues = 0;

				snprintf( writeBuf, bufSize, ";\n; frq track %u (harmonic %u)\n",
							trackNum + 1, ( int ) trackNum / 2 );
				out->writeF ( writeBuf );

				if ( frqType )
					strncpy ( writeBuf, "; Freq. diffs.\n", sizeof ( writeBuf ) );
				else
					strncpy ( writeBuf, "; Freq. data (Hz.)\n", sizeof ( writeBuf ) );

				out->writeF ( writeBuf );
				out->writeF ( (char *) "; \n" );

				snprintf ( writeBuf, bufSize, "f%u	0	%u	-2\n",
							baseFtblNum + trackNum, ftblSize );
				out->writeF ( writeBuf );

				while ( buf[0] == ';' )
					in->readF ( buf, bufSize );

				sscanf ( buf, "%u %u", &dur, &datum);
				numDatumValues++;
				datumF = ( float ) datum;

				avgFrq = avgFreq[frqTrkNum];

				if  ( frqType )
					snprintf ( floatString, sizeof ( floatString ), _frqDiffFormatString,
//								( ( datumF - avgFrq ) / avgFrq ) * ( pow ( 10, _frqDiffFpDigits ) ) );
								datumF - avgFrq );
				else
					snprintf ( floatString, sizeof ( floatString ), _frqDiffFormatString, datumF );

				snprintf ( writeBuf, bufSize, "%s\n", floatString );
				out->writeF ( writeBuf );

				lastDatumF = datumF;
				lastDurF = ( float ) dur;
				in->readF ( buf, bufSize );
				remainDurF = 0;

				while ( ( strstr ( buf, "end track" ) == NULL ) && ( numDatumValues < ( ftblSize - 1 ) ) )
				{
					sscanf ( buf, "%u %u", &dur, &datum );
					datumF = ( float ) datum;
					durF = ( float ) dur;

					intervalTimeF = durF - lastDurF + remainDurF;
					remainDurF = intervalTimeF - tblInterval;
					numTblItems = ( int )  ( intervalTimeF / tblInterval );
					interpDatum = 0;

					datumIncr = ( tblInterval / intervalTimeF ) * ( datumF - lastDatumF );
					datumIncr = datumIncr / numTblItems;

					for ( i = 0; i < numTblItems; i++ )
					{
						interpDatum = ( i + 1 ) * datumIncr + lastDatumF;

						if  ( frqType )
							snprintf ( floatString, sizeof ( floatString ), _frqDiffFormatString,
//										( ( interpDatum - avgFrq ) / avgFrq ) * ( pow ( 10, _frqDiffFpDigits ) ) );
										interpDatum - avgFrq );
						else
							snprintf ( floatString, sizeof ( floatString ), _frqDiffFormatString, interpDatum );

						snprintf ( writeBuf, bufSize, "%s\n", floatString );
						out->writeF ( writeBuf );
						numDatumValues++;
					}

					remainDurF -= ( i - 1 ) * tblInterval;
					lastDatumF = interpDatum;
					lastDurF = durF + remainDurF;	// since this is where we actually interpolate to
					in->readF ( buf, bufSize );
				}

				if ( numDatumValues == ftblSize - 1 )
				{
					out->filePos( out->filePos() - strlen ( writeBuf ) );

					if  ( frqType )
						snprintf ( floatString, sizeof ( floatString ), _frqDiffFormatString,
//									( ( interpDatum - avgFrq ) / avgFrq ) * ( pow ( 10, _frqDiffFpDigits ) ) );
										interpDatum - avgFrq );
					else
						snprintf ( floatString, sizeof ( floatString ), _frqDiffFormatString, interpDatum );

					snprintf ( writeBuf, bufSize, "%s\n", floatString );
					out->writeF ( writeBuf );
				}

				// pad ftable
				// preserve last frq
				if  ( frqType )
					snprintf ( floatString, sizeof ( floatString ), _frqDiffFormatString,
//								( ( interpDatum - avgFrq ) / avgFrq ) * ( pow ( 10, _frqDiffFpDigits ) ) );
								interpDatum - avgFrq );
				else
					snprintf ( floatString, sizeof ( floatString ), _frqDiffFormatString, interpDatum );

				snprintf ( writeBuf, bufSize, "%s\n", floatString );

				while ( numDatumValues < ftblSize - 1 )
				{
					out->writeF ( writeBuf );
					numDatumValues++;
				}

				trackNum++;
				frqTrkNum++;
			}
		}

		percent = ( int ) ( ( ( float ) in->filePos() / ( float ) in->fileSize() * 50 ) + 50 );

		if ( ( percentDone != percent ) && _showProgress )
		{
			percentDone = percent;
			displayProgress ( percentDone );
		}
	}

	out->writeF( (char *) ";\n");	// add final semicolon as loop terminator
	return ( 0 );
}


int HetConvert::writeIntFile ( FileAccess *in, char *srcFile, char *dstFile )
{
	char buf[BUFSIZE];
	int intSize;
	short int num;
	unsigned int percent = 0;
	unsigned int percentDone = 0;
	unsigned int bufSize, dur, trackNum;
	unsigned int srcTracks;
	int datum;

	bufSize = sizeof ( buf ) - 1;
	intSize = sizeof ( short int );

	if ( _showProgress )
		printf ( "percent done: \n" );

	buf[0] = ';';
	trackNum = 0;

	while ( buf[0] == ';' )	// last  buf item is valid data
		in->readF ( buf, bufSize );

	sscanf ( buf, "%u", &srcTracks );

	char outFile[bufSize];
	char timeFile[bufSize];
	char trkNumSize[ strlen ( buf ) ];
	char writeBuf[bufSize];

	while ( in->filePos() < in->fileSize() )
	{
		in->readF ( buf, bufSize );

		if ( buf[0] == ';' ) // found at data block end
		{
			if ( strstr ( buf, "amplitude breakpoint set" ) != NULL )
			{
				snprintf ( trkNumSize, sizeof ( trkNumSize ), "%u",
							( unsigned int ) trackNum / 2 );
				snprintf (outFile, sizeof ( outFile ), "%sa%s", dstFile, trkNumSize);

				FileAccess *out = new FileAccess ( outFile, (char *) "w" );

				out->elementSize ( intSize );
				out->numElements ( 1 );

				snprintf (timeFile, sizeof ( timeFile ), "%stime-a%s", dstFile, trkNumSize);
				FileAccess *time = new FileAccess ( timeFile, (char *) "w" );

				time->elementSize ( intSize );
				time->numElements ( 1 );

				while ( buf[0] == ';' )
					in->readF ( buf, bufSize );

				while ( strstr ( buf, "end track" ) == NULL )
				{
					sscanf ( buf, "%u %d", &dur, &datum );
					num = ( short int ) datum;
					out->writeF ( &num );
					num = ( short int ) dur;
					time->writeF ( &num );
					in->readF ( buf, bufSize );
				}

				trackNum++;
				delete out;
				delete time;
			}

			if ( strstr ( buf, "frequency breakpoint set" ) != NULL )
			{
				snprintf ( trkNumSize, sizeof ( trkNumSize ), "%u",
							( unsigned int ) trackNum / 2 );
				snprintf (outFile, sizeof ( outFile ), "%sf%s", dstFile, trkNumSize);

				FileAccess *out = new FileAccess ( outFile, (char *) "w" );

				out->elementSize ( intSize );
				out->numElements ( 1 );

				snprintf (timeFile, sizeof ( timeFile ), "%stime-f%s", dstFile, trkNumSize);

				FileAccess *time = new FileAccess ( timeFile, (char *) "w" );

				time->elementSize ( intSize );
				time->numElements ( 1 );

				while ( buf[0] == ';' )
					in->readF ( buf, bufSize );

				while ( strstr ( buf, "end track" ) == NULL )
				{
					sscanf ( buf, "%u %d", &dur, &datum );
					num = ( short int ) datum;
					out->writeF ( &num );
					num = ( short int ) dur;
					time->writeF ( &num );
					in->readF ( buf, bufSize );
				}

				trackNum++;
				delete out;
				delete time;
			}
		}

		percent = ( int ) ( ( ( float ) in->filePos() / ( float ) in->fileSize() * 50 ) + 50 );

		if ( ( percentDone != percent ) && _showProgress )
		{
			percentDone = percent;
			displayProgress ( percentDone );
		}
	}

	if ( _showProgress )
		printf ( "\n" );

	return ( 0 );
}


int HetConvert::fncToRaw ( FileAccess *in, char *srcFile, char *dstFile )
{
	char buf[BUFSIZE];
	char dur[BUFSIZE];
	unsigned int percent = 0;
	unsigned int percentDone = 0;
	unsigned int bufSize, trackNum;
	unsigned int numTracks;
	char srcTracks[16];

	bufSize = sizeof ( buf ) - 1;

	if ( _showProgress )
		printf ( "percent done: \n" );

	trackNum = 0;

	while ( strstr ( buf, "; number of amp/frq track pairs:" ) == NULL )
		in->readF ( buf, bufSize );

	in->readF ( buf, bufSize );
	sscanf ( buf, "; %s\n", &srcTracks );
	sscanf( srcTracks, "%u", &numTracks );

	char trkNumSize[ strlen ( buf ) ];
	char plotFile [ bufSize ];
	char outFile [ bufSize ];
	char trkNum [ strlen ( buf ) ];

	while ( in->filePos() < in->fileSize() )
	{
		while ( buf[0] == ';' )
			in->readF ( buf, bufSize );

		if ( buf[0] != ';' )
		{
			if ( buf[0] == 'f' )
			{
				snprintf ( trkNumSize, sizeof ( trkNumSize ), "%u",
							( unsigned int ) trackNum / 2 );
				snprintf ( outFile, sizeof ( outFile ), "%sa%s", dstFile, trkNumSize );

				FileAccess *out = new FileAccess ( outFile, (char *) "w" );

				snprintf ( plotFile, sizeof ( plotFile ), "%sa%s.gnuplot", dstFile, trkNumSize );
				FileAccess *plot = new FileAccess ( plotFile, (char *) "w" );
				plot->writeF ( (char *) "set key outside below\nplot " );

				in->readF ( buf, bufSize );

				while ( strstr ( buf, ";" ) == NULL )
				{
					out->writeF ( buf );
					in->readF ( buf, bufSize );
				}

				snprintf ( dur, sizeof ( dur ), "'%s' with lines\n", outFile );
				plot->writeF ( dur );
				plot->writeF ( (char *) "pause -1 \"Hit return to continue\"\n" );
				plot->writeF ( (char *) "reset\n" );
				delete plot;

				trackNum++;
				delete out;
			}

			while ( buf[0] == ';' )
				in->readF ( buf );

			if ( buf[0] == 'f' )
			{
				snprintf ( trkNumSize, sizeof ( trkNumSize ), "%u",
							( unsigned int ) trackNum / 2 );
				snprintf ( outFile, sizeof ( outFile ), "%sf%s", dstFile, trkNumSize );

				FileAccess *out = new FileAccess ( outFile, (char *) "w" );

				snprintf ( plotFile, sizeof (plotFile ), "%sf%s.gnuplot", dstFile, trkNumSize );
				FileAccess *plot = new FileAccess ( plotFile, (char *) "w" );
				plot->writeF ( (char *) "set key outside below\nplot " );

				in->readF ( buf, bufSize );

				while ( strstr ( buf, ";" ) == NULL )
				{
					out->writeF ( buf );
					in->readF ( buf, bufSize );
				}

				snprintf ( dur, sizeof ( dur ), "'%s' with lines\n", outFile );
				plot->writeF ( dur );
				plot->writeF ( (char *) "pause -1 \"Hit return to continue\"\n" );
				plot->writeF ( (char *) "reset\n" );
				delete plot;

				trackNum++;
				delete out;
			}
		}

		percent = ( int ) ( ( ( float ) in->filePos() / ( float ) in->fileSize() * 50 ) + 50 );

		if ( ( percentDone != percent ) && _showProgress )
		{
			percentDone = percent;
			displayProgress ( percentDone );
		}
	}

	if ( _showProgress )
		printf ( "\n" );

	return ( 0 );
}


void HetConvert::displayProgress ( unsigned int percentDone )
{                                                                               
	static int plusSigns;

	printf ( "\r%u |", percentDone );                                

	for( plusSigns = 0; plusSigns < ( int ) ( percentDone / 10 ); plusSigns++ )
		printf ( "+" );

	for ( ; plusSigns < 10; plusSigns++ )
		printf ( "-" );

	printf ( "|" );

	if ( percentDone == 100 )
		printf ( "\n" );

	fflush ( stdout );
}


void HetConvert::errorMessage ( char *error )
{
	printf ( "%s\n", error );
}


void HetConvert::outMode ( char *string )
{
	strncpy ( _outMode, string, 2 );
	_outMode[2] = 0;
}
