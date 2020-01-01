/*
	makeFtables.cc
	uses supplied .het csound heterodyne analysis files to make ascii data
	files used to create ftables required by Resurrection.
	Will 18, 2007-2013, 2019
	wj18@talktalk.net
	eighteenwill@gmail.com
	
	Version 2

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

#include <stdio.h>
#include <string.h>
#include "hetconvert/HetConvert.h"

int main ( int argc, char *argv[] )
{
	int args;
	
	if (argc<9)
	{
		printf("Usage: makeFtables instrName instrNum harmonics tblBase <.het file case names>\n");
		printf("het file case names are the four additional names for the instr. case extremes\n");
		printf("e.g. pp<LF pitch> pp<HF pitch> ff<LF pitch> ff<HF pitch>\n");
		printf("where LF and FF reference the extracted .het file names, e.g. ppC2\n");
		printf("optional arguments: <writeFrqDiffs (0/1)> <fpDigits> <frqDiffFpDigits>\n");
		printf("which will be defaulted to '1 0 3' unless specified\n\n");
		printf("Note the number of harmonics extracted must be the same in all four\n");
		printf("case extreme .het files, even if Resurrection does not use them all.\n");
		return (1);
	}
	else
	if (argc>12)
	{
		printf("too many arguments: do './makeFtables' in the utils subdir for help'\n");
		printf("expected 12 maximum, found %d\n", argc);
		return (1);
	}

	HetConvert *hetcnv = new HetConvert ( "Hetcnv" );

	unsigned int instrNum, harmonics, tblBase, writefrqdiff, fpdigits, frqdifffpdigits, error;
	char instrName[512];
	char ppLF[64];
	char ppHF[64];
	char ffLF[64];
	char ffHF[64];
	char dstDir[1024];
	char srcFile[1024];
	char ascFile[1024];
	char dataFile[1024];

	// the dstDir is the target csound ftable data file for the instrument
	// instrName is prepended and '.data' appended
	// since makeFtables runs in the utils dir we need the path to the .het
	// files in the data/<instrName> directory (which dir and files must exist)
	// don't run this program from anywhere else.
	sscanf(argv[1], "%s", &instrName);
	sscanf(argv[2], "%u", &instrNum);
	sscanf(argv[3], "%u", &harmonics);
	sscanf(argv[4], "%u", &tblBase);
	sscanf(argv[5], "%s", &ppLF);
	sscanf(argv[6], "%s", &ppHF);
	sscanf(argv[7], "%s", &ffLF);
	sscanf(argv[8], "%s", &ffHF);
	printf("%s %u %u %u %s %s %s %s\n", instrName, instrNum, harmonics, tblBase, ppLF, ppHF, ffLF, ffHF);

	hetcnv->writeFrqDiff ( 1 );	// default use frq diffs not actual frequencies
	if (argc>9)
	{
		sscanf(argv[9], "%u", &writefrqdiff);
		hetcnv->writeFrqDiff ( writefrqdiff );	
	}
	
	hetcnv->fpDigits ( 0 );	// default use integers
	if (argc>10)
	{
		sscanf(argv[10], "%u", &fpdigits);
		hetcnv->fpDigits ( fpdigits );
	}
	
	hetcnv->frqDiffFpDigits ( 3 );	// default freq/diff tables are float, 3 d.p.

	if (argc>11)
	{
		sscanf(argv[11], "%u", &frqdifffpdigits);
		hetcnv->frqDiffFpDigits ( frqdifffpdigits );
	}

	strcpy(dstDir, "../data/");
	strcat(dstDir, (char *) &instrName);
	strcat(dstDir, "/");	// 
	
	strcpy(dataFile, dstDir);
	strncat(dataFile, instrName, strlen(instrName));
	strncat(dataFile, ".data", 5);

	hetcnv->hetDataTracks ( harmonics );
	hetcnv->outMode ( (char *) "w" );
	hetcnv->baseFtblNum ( tblBase );
	
	// we need to do this sequentially for the 4 case extremes
	// ppLF
	strcpy(srcFile, dstDir);
	strncat(srcFile, ppLF, strlen(ppLF));
	strncat(srcFile, ".het", 4);
	
	strcpy(ascFile, dstDir);
	strncat(ascFile, ppLF, strlen(ppLF));
	strncat(ascFile, ".asc", 4);
	
	hetcnv->hetToAsc ( (char *) srcFile, (char *) ascFile );
	hetcnv->ascToFnc ( (char *) ascFile, (char *) dataFile );
	
	// ppHF
	strcpy(srcFile, dstDir);
	strncat(srcFile, ppHF, strlen(ppHF));
	strncat(srcFile, ".het", 4);
	
	strcpy(ascFile, dstDir);
	strncat(ascFile, ppHF, strlen(ppHF));
	strncat(ascFile, ".asc", 4);

	hetcnv->hetToAsc ( (char *) srcFile, (char *) ascFile );
	hetcnv->outMode ( (char *) "a+" );
	tblBase += harmonics*2;
	hetcnv->baseFtblNum ( tblBase );
	hetcnv->ascToFnc ( (char *) ascFile, (char *) dataFile );

	// ffLF
	strcpy(srcFile, dstDir);
	strncat(srcFile, ffLF, strlen(ffLF));
	strncat(srcFile, ".het", 4);
	
	strcpy(ascFile, dstDir);
	strncat(ascFile, ffLF, strlen(ffLF));
	strncat(ascFile, ".asc", 4);
	
	hetcnv->hetToAsc ( (char *) srcFile, (char *) ascFile );
	tblBase += harmonics*2;
	hetcnv->baseFtblNum ( tblBase );
	hetcnv->ascToFnc ( (char *) ascFile, (char *) dataFile );
	
	// ffHF
	strcpy(srcFile, dstDir);
	strncat(srcFile, ffHF, strlen(ffHF));
	strncat(srcFile, ".het", 4);
	
	strcpy(ascFile, dstDir);
	strncat(ascFile, ffHF, strlen(ffHF));
	strncat(ascFile, ".asc", 4);

	hetcnv->hetToAsc ( (char *) srcFile, (char *) ascFile );
	tblBase += harmonics*2;
	hetcnv->baseFtblNum ( tblBase );
	hetcnv->ascToFnc ( (char *) ascFile, (char *) dataFile );

	tblBase += harmonics*2;	// next free ftable number
	hetcnv->outMode ( (char *) "w" );	// reset to write new file
printf("next free %d\n", tblBase);
	strcpy(dataFile, dstDir);
	strncat(dataFile, instrName, strlen(instrName));
	strncat(dataFile, "-hmag.data", 10);

	hetcnv->baseFtblNum ( tblBase );
	strcpy(ascFile, dstDir);
	strncat(ascFile, ppLF, strlen(ppLF));
	strncat(ascFile, ".asc", 4);
	hetcnv->ascToPeak ( (char *) ascFile, (char *) dataFile );

	tblBase++;
	hetcnv->outMode ( (char *) "a+" );
	hetcnv->baseFtblNum ( tblBase );
	strcpy(ascFile, dstDir);
	strncat(ascFile, ppHF, strlen(ppHF));
	strncat(ascFile, ".asc", 4);
	hetcnv->ascToPeak ( (char *) ascFile, (char *) dataFile );

	tblBase++;
	hetcnv->baseFtblNum ( tblBase );
	strcpy(ascFile, dstDir);
	strncat(ascFile, ffLF, strlen(ffLF));
	strncat(ascFile, ".asc", 4);
	hetcnv->ascToPeak ( (char *) ascFile, (char *) dataFile );

	tblBase++;
	hetcnv->baseFtblNum ( tblBase );
	strcpy(ascFile, dstDir);
	strncat(ascFile, ffHF, strlen(ffHF));
	strncat(ascFile, ".asc", 4);
	hetcnv->ascToPeak ( (char *) ascFile, (char *) dataFile );

	hetcnv->outMode ( (char *) "w" );

	strcpy(dataFile, dstDir);
	strncat(dataFile, instrName, strlen(instrName));
	strncat(dataFile, (char *) "-header.sco", 11);

	FileAccess *out = new FileAccess ( (char *) dataFile, (char *) "w" );

	if ( out->errNum() != 0 )
	{
		printf("%s\n", (char *) out->error() );
		error = out->errNum();
		delete out;
		return ( error );
	}

	// write a basic header file to specify the instrument used in score files
	strcpy(dstDir, "data/");	// this instrument header file is expected by resurrection in its data dir.
	strcat(dstDir, (char *) &instrName);
	strcat(dstDir, "/");	// 
	out->writeF((char *) "; ");
	out->writeF((char *) instrName);
	out->writeF((char *) "-header.sco\n\n");
	out->writeF((char *) "; This file should be included in the instrument score files as the first line:\n");
	out->writeF((char *) "; #include \"");
	out->writeF(dstDir);
	out->writeF((char *) instrName);
	out->writeF((char *) "-header.sco\"\n\n");
	out->writeF((char *) "#include \"header.sco\"\n");
	out->writeF((char *) "#include \"");
	out->writeF(dstDir);
	out->writeF((char *) instrName);
	out->writeF((char *) ".data\"\n#include \"");
	out->writeF(dstDir);
	out->writeF((char *) instrName);
	out->writeF((char *) "-hmag.data\"\n\n");
	out->writeF((char *) "; Additional header files may be specified, e.g.\n");
	out->writeF((char *) "; #include \"");
	out->writeF(dstDir);
	out->writeF((char *) instrName);
	out->writeF((char *) ".terrain\"\n\n");
	out->writeF((char *) "i1	0	0	");
	snprintf(ascFile, sizeof(instrNum), "%u", instrNum);	// use asc as buffer...
	out->writeF((char *) ascFile);
	out->writeF((char *) "	; i1 defines virtual instr i90 as ");
	out->writeF((char *) instrName);
	out->writeF((char *) "\n");

	delete out;
	delete hetcnv;
	printf("Last used ftable number %d\n", tblBase);
	return 0;
}
