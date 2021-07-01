/*
	hetconvert - csound heterodyne analysis file format converter
	Will 18, 2007-2013; wj18@talktalk.net

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

#include <string.h>
#include "HetConvert.h"


int main ( int argc, char *argv[] )
{
	char c = 0;
	char srcFile[256];
	char dstFile[256];
	char num[256];
	int keeplooping = 1;
	unsigned int baseFtblNum = 1;
	unsigned int hetDataTracks = 10;
	unsigned int useDiff = 0;

	HetConvert *hetcnv = new HetConvert ( "Hetcnv" );

	hetcnv->writeFrqDiff ( useDiff );
	hetcnv->hetDataTracks ( hetDataTracks );

	srcFile[0] = 0;
	dstFile[0] = 0;

	while (keeplooping)
	{
		printf ( "Enter an option:\n" );

		printf ( "1 <input file name> %s\n", srcFile );
		printf ( "2 <output file name> %s\n", dstFile );
		printf ( "3 (clear filenames)\n");
		printf ( "4 (convert hetro -> ascii)\n" );
		printf ( "5 (convert ascii -> hetro)\n" );
		printf ( "6 (convert ascii -> CSound ftables <base=%u>)\n", baseFtblNum );
		printf ( "7 (convert ascii -> short int (2 bytes)\n" );
		printf ( "8 (convert short int -> hetro <harmonics=%u>)\n", hetDataTracks );
		printf ( "9 (convert ftables to split datum files)\n" );
		printf ( "p (extract ascii -> harmonic peak amp. Csound ftables" );
		printf ( "b <n> (set base ftable number n)\n" );
		printf ( "f <flag> (output ftable frq <0> or diff <1>) <flag=%u>\n", useDiff );
		printf ( "h <n> (set number of het file harmonics n <harmonics=%u>\n", hetDataTracks );
		printf ( "q (quit)\n" );

		scanf("%c", &c);

		switch ( c )
		{
			case '1':
				scanf ( "%s", &srcFile );
				break;

			case '2':
				scanf ( "%s", &dstFile );
				break;

			case '3':
				srcFile[0] = 0;
				dstFile[0] = 0;
				break;

			case '4':
				if ( strlen(dstFile ) == 0 )
					hetcnv->hetToAsc ( srcFile );
				else
					hetcnv->hetToAsc ( srcFile, dstFile );
				break;

			case '5':
				if ( strlen(dstFile ) == 0 )
					hetcnv->ascToHet ( srcFile );
				else
					hetcnv->ascToHet ( srcFile, dstFile );
				break;

			case '6':
				if ( useDiff )
					hetcnv->frqDiffFpDigits ( 3 );	// or we don't get meaningful o/p

				if ( strlen(dstFile ) == 0 )
					hetcnv->ascToFnc ( srcFile );
				else
					hetcnv->ascToFnc ( srcFile, dstFile );
				break;

			case '7':
				if ( strlen(dstFile ) == 0 )
					hetcnv->ascToShort ( srcFile );
				else
					hetcnv->ascToShort ( srcFile, dstFile );
				break;

			case '8':
				if ( strlen(dstFile ) == 0 )
					hetcnv->intToHet ( srcFile );
				else
					hetcnv->intToHet ( srcFile, dstFile );
				break;

			case '9':
				if ( strlen(dstFile ) == 0 )
					hetcnv->fncToRaw ( srcFile );
				else
					hetcnv->fncToRaw ( srcFile, dstFile );
				break;

			case 'p':
				if ( strlen(dstFile ) == 0 )
					hetcnv->ascToPeak ( srcFile );
				else
					hetcnv->ascToPeak ( srcFile, dstFile );
				break;

			case 'b':
				scanf("%s", &num);
				sscanf ( num, "%u", &baseFtblNum );
				hetcnv->baseFtblNum ( baseFtblNum );
				break;

			case 'f':
				scanf("%s", &num);
				sscanf ( num, "%u", &useDiff );
				hetcnv->writeFrqDiff ( useDiff );
				break;

			case 'h':
				scanf("%s", &num);
				sscanf ( num, "%u", &hetDataTracks );
				hetcnv->hetDataTracks ( hetDataTracks );
				break;
			
			case 'q':
				keeplooping = 0;
				break;

			default:
				break;
		}
	}

	delete hetcnv; 
}
