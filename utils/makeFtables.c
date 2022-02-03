/* makeFtables.c */
/* read in case extreme files and concatenate ; 'cat'; who?... */
/* Will 18, 2021*/


#include <stdio.h>
#include <string.h>

#define BUFSIZE 1024

// explicitly declare file names */
//int readCaseFiles;


int main (int argc, char *argv[])
{
	if (argc<6)
	{
                printf("Usage: makeFtables instrumentName <case extreme names>\n\n");
		printf("case extreme names for ppLf, ppHF, ffLF, ffHF - in that order\n");
		printf("the case extreme files are those obtained from 'het2ftbl'\n");
		return 1;
	}
	FILE *infile;
	FILE *outfile;
	FILE *hmagfile;	// harmonic peak magnitudes
	
	char outFileName[BUFSIZE];
	strncpy (outFileName, argv[1], BUFSIZE-6);
	strncat (outFileName,".data", 5);
	outfile = fopen(outFileName, "w");

	if ( outfile == NULL )
	{
		printf("Unable to open data output file '%s'\n", outFileName);
		return 1;
	}
	char buf[BUFSIZE];
	char caseFileName[BUFSIZE];
	unsigned int n;
	unsigned int tblBase = 0;

	for (n=2; n<6; n++)
	{
		strncpy (caseFileName, argv[n], BUFSIZE-10);
		infile = fopen(caseFileName, "r");

		if ( infile == NULL )
		{
			printf("Unable to open case extreme file '%s'\n", caseFileName);
			fclose (outfile);
			return 1;
		}
		do
		{
			buf[0] = 0;
			fgets (buf, BUFSIZE-1, infile);
			if (buf[0]=='f')	// 1st. char 'f' is table number identifier
				sscanf (buf, "f%u", &tblBase);
			fputs(buf, outfile);
		}
		while (strlen(buf) !=0);
		fclose (infile);
	}
	fclose (outfile);
	tblBase++;
	unsigned int tblSize, oldFnum;
	int genType;

	strncpy (outFileName, argv[1], BUFSIZE-11);
	strncat (outFileName,"-hmag.data", 10);
	outfile = fopen(outFileName, "w");

	if ( outfile == NULL )
	{
		printf("Unable to open hmag.data output file '%s'\n", outFileName);
		return 1;
	}

	for (n=2; n<6; n++)
	{
		strncpy (caseFileName, argv[n], BUFSIZE-10);
		strncat (caseFileName, ".hmag", 5);
		infile = fopen(caseFileName, "r");

		if ( infile == NULL )
		{
			printf("Unable to open case extreme file '%s'\n", caseFileName);
			fclose (outfile);
			return 1;
		}
	
		do
		{
			buf[0] = 0;
			fgets (buf, BUFSIZE-1, infile);
			if (buf[0]=='f')	// 1st. char 'f' is table number identifier
			{
				sscanf (buf, "f%u	0	%u	%d", &oldFnum, &tblSize, &genType);
				sprintf(buf, "f%u	0	%u	%d\n", tblBase, tblSize, genType);
			}
			fputs(buf, outfile);
		}
		while (strlen(buf) !=0);
		fclose (infile);
		tblBase++;
	}
	fclose(outfile);
	printf("makeFtables: last used ftable number %u\n", tblBase-1);	// for info (including hmag)
	return 0;
}