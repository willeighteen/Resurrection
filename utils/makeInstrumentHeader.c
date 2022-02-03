/* makeInstrumentHeader.c */
/* write a basic header file to specify the instrument used in score files */

#include <stdio.h>
#include <string.h>

#define BUFSIZE 1024


int main ( int argc, char *argv[] )
{
	unsigned int instrNum;
	char instrName[512];
	char dataFile[1024];
	char dstDir[1024];
	FILE *outfile;
	
	if (argc<3)
	{
                printf("Usage: makeInstrumentHeader instrName instrNum\n");
		return 1;
	}
	sscanf(argv[1], "%s", &instrName);
	sscanf(argv[2], "%u", &instrNum);

	strcpy(dstDir, "data/");
	strcat(dstDir, instrName);
	strcat(dstDir, "/");

	strcpy(dataFile, instrName);
	strncat(dataFile, "-header.sco", 12);
	outfile = fopen(dataFile, "w");

	if ( outfile == NULL )
	{
		printf("Unable to open output file '%s'\n", outfile);
		fclose (outfile);
		return 1;
	}
	
	fputs ("; ", outfile);
	fputs(instrName, outfile);
	fputs("-header.sco\n\n; This file should be included in the instrument score files as the first line:\n", outfile);
	fputs ( "; #include \"", outfile);
	fputs (dstDir, outfile);
	fputs(instrName, outfile);
	fputs ("-header.sco\"\n\n", outfile);
	fputs ("#include \"header.sco\"\n#include \"", outfile);
	fputs(instrName, outfile);
	fputs (".data\"\n#include \"", outfile);
	fputs(instrName, outfile);
	fputs ( "-hmag.data\"\n\n", outfile);
	fputs ("; Additional header files may be specified, e.g.\n", outfile);
	fputs ( "; #include \"", outfile);
	fputs(instrName, outfile);
	fputs (".terrain\"\n\n", outfile);
	fputs ("i1	0	0	", outfile);
	fprintf (outfile, "%u", instrNum);
	fputs ( "	; i1 defines virtual instr i90 as ", outfile);
	fputs(instrName, outfile);
	fputs ("\n", outfile);
	
	fclose (outfile);
	return 0;
}
