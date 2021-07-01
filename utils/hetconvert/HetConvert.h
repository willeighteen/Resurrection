/*
	HetConvert.h
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
*/


#ifndef _HETCONVERT_H
#define _HETCONVERT_H

#include <stdio.h>
#include "FileAccess.h"

#define BUFSIZE 1024


class HetConvert
{
	public:
		HetConvert ( const char * const );
		HetConvert ( const char * const, unsigned int );
		~HetConvert();
		
		char *shortIntName() { return ( _shortIntName ); }
		const char * className() { return ( _className ); }
		int ascToHet ( char * );
		int ascToHet ( char *, char * );
		int ascToFnc ( char * );
		int ascToFnc ( char *, char * );
		int ascToFnc ( char *, char *, unsigned int );
		int ascToFnc ( char *, char *, unsigned int, char * );
		int ascToPeak ( char * );
		int ascToPeak ( char *, char * );
		int ascToPeak ( char *, char *, unsigned int );
		int ascToPeak ( char *, char *, unsigned int, char * );
		int ascToShort ( char * );
		int ascToShort ( char *, char * );
		int fncToRaw ( char * );
		int fncToRaw ( char *, char * );
		int hetToAsc ( char * );
		int hetToAsc ( char *, char * );
		int intToHet ( char * );
		int intToHet ( char *, char * );
		int intToHet ( char *, char *, unsigned int  );
		void baseFtblNum ( unsigned int num ) { _baseFtblNum = num; }
		void endFrqScan ( float num ) { _endFrqScan = num ; }
		void fpDigits ( int num ) { _fpDigits = num; }
		void frqDiffFpDigits ( int num ) { _frqDiffFpDigits = num; }
		void hetDataTracks ( unsigned int num ) { _hetDataTracks = num; }
		void releaseMag ( float num ) { _releaseMag = num; }
		void startFrqScan ( float num ) { _startFrqScan = num ; }
		void writeFrqDiff ( unsigned int num ) { _writeFrqDiff = num; }
		void outMode ( char * );

	protected:
		int ascToHet ( FileAccess *, FileAccess * );
		int fncToRaw ( FileAccess *, char *, char * );
		int hetToAsc ( FileAccess *, FileAccess *, char * );
		int intToHet ( char *, FileAccess *, unsigned int );
		int writeFtblFile ( FileAccess *, FileAccess *, char *, unsigned int );
		int writeFtblFile ( FileAccess *, FileAccess *, char *, unsigned int, unsigned int );
		int writeIntFile ( FileAccess *, char *, char * );
		int writePeakMagFtbl ( FileAccess *, FileAccess *, char *, unsigned int );
		void displayProgress ( unsigned int );
		void errorMessage ( char * );

	private:
		const char * _className;
		char _shortIntName[128];
		char _formatString[16];
		char _frqDiffFormatString[16];
		char _outMode[3];
		float _endFrqScan, _releaseMag, _startFrqScan;
		int _num0, _num1;
		unsigned int _baseFtblNum, _error, _fpDigits, _frqDiffFpDigits;
		unsigned int _hetDataTracks, _showProgress, _writeFrqDiff, _data;
};

#endif
