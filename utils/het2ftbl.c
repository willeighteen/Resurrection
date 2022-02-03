/* het2ftbl .c  - convert csound *.het format to csound ftable (gen 02) */
/* Will 18, 2021*/


#include <stdio.h>
#include <string.h>
#include <math.h>

#define BUFSIZE 1024

unsigned int writeFrqFtable (unsigned int, unsigned int *, unsigned int *, unsigned int, FILE *, unsigned int, unsigned int, unsigned int);
unsigned int writeAmpFtable (unsigned int, unsigned int *, unsigned int *, unsigned int, FILE *);
unsigned int numTrackDataPairs (FILE *);
unsigned int writeFileHeader (FILE *, char *, unsigned int, unsigned int);
unsigned int writeFtableHeader (FILE *, unsigned int, int, unsigned int, unsigned int, unsigned int, unsigned int);
char _formatString[16];


int main ( int argc, char *argv[] )
{
printf("start het2ftbl\n");
	if (argc<5)
	{
                printf("Usage: het2ftbl hetFileName harmonics tblBase ftblSize <UseFrqFactor> <fpDigits>\n");
		return 0;
	}

	if (strlen (argv[1]) >= BUFSIZE-10)	// 'makeFtables' adds suffices...
	{
		printf ("BUFSIZE %d exceeded by hetfileName, redefine\n", BUFSIZE);
		return 1;
	}
	unsigned int useFreqFactor, fpDigits;

	if (argv[5]!=NULL)
	{
		sscanf (argv[5], "%u", &useFreqFactor);
		if (useFreqFactor>1)
			useFreqFactor=1;
	}
	else
		useFreqFactor = 1;

	if ((argv[6]!=NULL) && (argc>5))
		sscanf (argv[6], "%u", &fpDigits);
	else
		fpDigits = 3;

	fpDigits*=useFreqFactor;
	snprintf( _formatString, sizeof ( _formatString ), "%s%u%s", "%.", fpDigits, "f" );

	FILE *infile;
	FILE *outfile;	// ftable data
	FILE *hmagfile;	// harmonic peak magnitudes
	
	infile = fopen(argv[1], "r");

	if ( infile == NULL )
	{
		printf("Unable to open input file '%s'\n", argv[1]);
		return 1;
	}

/*
fseek(infile, 0L, SEEK_END);
long filepos = ftell(infile);
printf("end pos %d\n", filepos);
fseek(infile, 0L, SEEK_SET);
*/		

	char buf[BUFSIZE];
	fgets(buf, 7, infile);

	if (strcmp (buf, "HETRO ") != 0)
	{
		printf("'%s' found, expecting 'HETRO ' in file\n", buf);
		fclose (infile);
		return 1;
	}

	unsigned int numTracks;
	unsigned int ftblSize, tblBase, fileNameSize;

	sscanf(argv[3], "%u", &tblBase);
	sscanf(argv[4], "%u", &ftblSize);

	unsigned int i, j;

	fileNameSize = strlen(argv[1]);
	char inFileName[fileNameSize+1];	// including trailing zero
	char outFileName[fileNameSize-3];	// space for trailing '\0'
	strncpy(inFileName, (char *) argv[1], fileNameSize+1);
	strncpy (outFileName, inFileName, fileNameSize-4);
	outFileName[fileNameSize-4] = '\0';
	outfile = fopen(outFileName, "w");

	if ( outfile == NULL )
	{
		printf("Unable to open output file '%s'\n", outFileName);
		fclose (infile);
		return 1;
	}
	char hmagFileName[fileNameSize+5];	// space for trailing '\0'
	strncpy (hmagFileName, outFileName, fileNameSize-3);
	strncat (hmagFileName, ".hmag", 5);
	hmagfile = fopen(hmagFileName, "w");

	if ( hmagfile == NULL )
	{
		printf("Unable to open output file '%s'\n", outFileName);
		fclose (outfile);
		fclose (infile);
		return 1;
	}
	fscanf(infile, "%u", &numTracks);
	fseek(infile, 1, SEEK_CUR);	/* skip 'OA' separator */

	unsigned int numElements = 0;
	unsigned int trackNum = 0;
	unsigned int maxAmp[numTracks];
	unsigned int nominalFreq = 1;
	int infilepos;
	int trackType;
	unsigned int once = 0;	/* having duration is useful but we don't have it here */

	while (trackNum<numTracks<<1)
	{
		fscanf(infile, "%d", &trackType);
		infilepos = ftell(infile);	/* keep ptr to 1st ',' (start of data) */
//printf ("trackNum %u infilepos start %d\n", trackNum, infilepos);

		if (trackType==-1 && !once)	// we assume the .het file is in amp, frq order per harmonic
		numElements = numTrackDataPairs(infile);
		fseek(infile, infilepos, SEEK_SET);	/* reset ptr to 1st ',' */

		if (ftblSize<numElements)
			printf("Warning: track %u: numItems %u ftable size %u some data will be lost\n", trackNum+1, numElements, ftblSize);

		unsigned int time[numElements];
		unsigned int value[numElements];
	
		for (i=0; i<numElements; i++)
			fscanf(infile, ",%u,%u", &time[i], &value[i]);

		if (!once)	/* kludge since duration unavailable before track loop */
		{
			writeFileHeader (outfile, inFileName, numTracks, time[numElements-1]);
			once=1;
		}
		writeFtableHeader (outfile, tblBase, trackType, trackNum, ftblSize, useFreqFactor, fpDigits);
	
		switch (trackType)
		{
			case -1:
				maxAmp[trackNum>>1] = 0;

				for (i=0; i<numElements; i++)
					if (value[i]>maxAmp[trackNum>>1])
						maxAmp[trackNum>>1] = value[i];

				writeAmpFtable (numElements, time, value, ftblSize, outfile);
				fseek(infile, 6, SEEK_CUR);	/* skip end track '32767' and '0A' */
				break;

			case -2:
				if (useFreqFactor==1)
				{
					unsigned int start=(int) (numElements*0.33+0.5);
					unsigned int end=(int) (numElements*0.67+0.5);
	
					for (i=start; i<end; i++)
						nominalFreq+=value[i];
	
					nominalFreq=(int) (nominalFreq/(end-start)+0.5);
				}
				writeFrqFtable (numElements, time, value, ftblSize, outfile, useFreqFactor, fpDigits, nominalFreq);
				fseek(infile, 7, SEEK_CUR);	/* skip end track '32767', '0A', '0A' */
				break;

			default:
				break;
		}
		trackNum++;
	}
/*
int filepos = ftell(infile);
char hex[10];
sprintf(&hex, "%x", filepos);
printf("end filepos %d is %s hex\n", filepos, hex);
*/
	printf("het2ftbl: last used ftable number %u\n", tblBase+trackNum-1);	// for info (including hmag)
	i = 1;
	j = 0;

	while (j<numTracks)
	{
		j = (1 << ( int) log2(i));	/* we need math.h to use this */
		i++;
	}
	writeFileHeader (hmagfile, inFileName, numTracks, 0);
	// dummy tbl number line - replace 'f0' with 'f<tblNum>' in makeFtables
	writeFtableHeader (hmagfile, 0, 0, 0, i-1, 0, 0);

	for (i=0; i<numTracks; i++)
		fprintf(hmagfile, "%u\n", maxAmp[i]);

	for (i=numTracks; i<j; i++)	// zero-padding to fill hmag ftable
		fprintf(hmagfile, "%u\n", 0);

	fprintf (hmagfile, "\n");
	fclose (hmagfile);
	fclose (outfile);
	fclose (infile);
printf("end het2ftbl\n");

	return 0;
}


unsigned int writeFileHeader (FILE *outfile, char *filename, unsigned int numItems, unsigned int maxTime)
{
	fprintf (outfile, "; source file %s\n;\n", filename);

	if (maxTime!=0)
	{
		char floatString[16];
		float duration = (float) maxTime/1000;	/* time in s */
		snprintf ( floatString, sizeof ( floatString ), _formatString, duration );
		fprintf (outfile, "; duration %s s\n;\n", floatString);
	}
	fprintf (outfile, "; number of harmonics (amp/frq track pairs)\n; %u\n;\n", numItems);
	return 0;
}


unsigned int writeFtableHeader (FILE *outfile, unsigned int tblBase, int trackType, unsigned int trackNum, unsigned int tblSize, unsigned int useFreqFactor, unsigned int fpDigits)
{
	if (trackType==-1)
		fprintf (outfile, "%s", "; amp");
	else
		if (trackType==-2)
			fprintf (outfile, "%s", "; frq");

	if (trackType<0)
		fprintf (outfile, " track %u (harmonic %u)\n;\n", trackNum+1, trackNum>>1);

	if (useFreqFactor&&trackType==-2&&fpDigits>0)
		fprintf (outfile, "; Freq. Factor\n;\n");
	
	fprintf (outfile, "f%u	0	%u	-2\n", tblBase+trackNum, tblSize);	/* non-normalised */
	return 0;
}


unsigned int writeAmpFtable (unsigned int numItems, unsigned int *time, unsigned int *value, unsigned int tblSize, FILE *outfile)
{
	unsigned int tblPos = 0;
	unsigned int i, j;
	float currentTime;

	if (tblSize>numItems)
	{
		unsigned int lastTblPos = 0;
		fprintf (outfile, "%u\n",0);

		for (i=0; i<numItems; i++)
		{
			currentTime = (float) (time[i]) / time[numItems-1];
			tblPos = (unsigned int)(currentTime*(tblSize-1));
			for (j=lastTblPos; j<tblPos; j++)
				fprintf (outfile, "%u\n",value[i]);

			lastTblPos = tblPos;
		}
	}
	else
	{
		currentTime = 0;
		float tblTimeIncrement = (float)1/(tblSize);
		j = 0;

		while (j<tblSize-1)
		{
			tblPos = (unsigned int) (currentTime*numItems+0.5);
			fprintf (outfile, "%u\n",value[tblPos]);
			currentTime+=tblTimeIncrement;
			j++;
		}
		fprintf (outfile, "%u\n;\n", 0);	// ensure last amplitude entry is zero
	}

	fprintf (outfile, "%c\n",';');
	return 0;
}

unsigned int writeFrqFtable (unsigned int numItems, unsigned int *time, unsigned int *value, unsigned int tblSize, FILE *outfile, unsigned int useFreqFactor, unsigned int fpDigits, unsigned int freq)
{
	unsigned int tblPos = 0;
	unsigned int i, j;
	float currentTime, datum;
	char floatString[16];

	if (tblSize>numItems)
	{
		unsigned int lastTblPos = 0;
		snprintf ( floatString, sizeof ( floatString ), _formatString, 1.0 );
		fprintf (outfile, "%s\n", floatString);

		for (i=0; i<numItems; i++)
		{
			currentTime = (float) (time[i]) / time[numItems-1];
			tblPos = (unsigned int)(currentTime*(tblSize-1));

			for (j=lastTblPos; j<tblPos; j++)
			{
				datum=(float) ((float)value[i]/freq);
				snprintf ( floatString, sizeof ( floatString ), _formatString, datum );
				fprintf (outfile, "%s\n", floatString);
			}
			lastTblPos = tblPos;
		}
	}
	else
	{
		currentTime = 0;
		float tblTimeIncrement = (float)1/(tblSize);
		j = 0;

		while (j<tblSize)
		{
			tblPos = (unsigned int) (currentTime*numItems+0.5);
			datum=(float) ((float)value[tblPos]/freq);
			snprintf ( floatString, sizeof ( floatString ), _formatString, datum );
			fprintf (outfile, "%s\n", floatString);
			currentTime+=tblTimeIncrement;
			j++;
		}
	}
	fprintf (outfile, "%c\n", ';');
	return 0;
}


unsigned int numTrackDataPairs (FILE *infile)
{
	unsigned int num = 0;
	unsigned int items = 0;

	while (num !=32767)	/* end track data marker */
	{
		fscanf(infile, ",%u\n", &num);
		items++;
	}
	return (items-1)>>1;
}
