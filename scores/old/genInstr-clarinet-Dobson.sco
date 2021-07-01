; ADJUST NOTE VOL FOR CORRECT TIMBRE!!! (ref. 705.wav)
; genInstr-clarinet-Dobson.sco
; after Dobson, 'Designing Legato Instruments', the Csound Book

#include "header.sco"

t0 40 3 40 3 30 ;SLOW DOWN IN BAR 2

; define instrument as MIDI #72 'clarinet'
i1	0		0		72

; make linear reduced portamento
i2	0		0	0		0.03		0	0	0	0

; expression (amplitude envelope, offset from base gain unity)
;i3	1.95	0.08	0.1		203	0
;i3	2.05	0.1		0		213	0
;i3	2.9		1		-1.5	211	0
;i3	4.45	0.3		0.75	201 0
;i3	4.8		0.5		0		211	0

; expression (portamento)
i3	0		0.65	0	0	8.10	; to i90->p5 (8.10)
i3	+		0.125	.	.	8.10	; to i90->np5 (8.09)
i3	+		.		.	.	8.09	; to i90->np5 (8.11)
i3	+		0.75	.	.	8.11
i3	+		0.125	0	0	8.08
i3	+		.		.	.	8.07
i3	+		0.25	.	.	8.09
i3	+		.		.	.	8.06
i3	+		.		.	.	8.05
i3	+		.		.	.	8.04	; to i90->np5 (8.01)
i3	+		0.75	.	.	8.10
i3	+		0.125	.	.	8.10
i3	+		.		.	.	9.00
i3	+		0.5		.	.	8.11

; attack and release replace clarinet defaults in i1
i4	0		0	0.4		1	0	0
; increase attack and release duration on last tied note and force 
; s-harmonic amp envelope on p-harmonics
; the p-harmonic timing is AR not ADSR by default. Causes slight timbral
; change.
i4	3.9		1	0.9		8	1

; reduce contribution from frq data tables
;i5	0	0	-1	0	-1	0	0.7	-1	0

; tremolo
i9	0		0.35	4500	4.5		0		2		201
i9	0.45	0.45	.		.		2		0		211
i9	0.9		0.6		2250	.		0		5		201
i9	1.5		0.15	.		.		5		0		211
i9	1.92	0.98	.		7		1		0		211
i9	2.9		0.3		5000	5		0		2		201
i9	3.3		0.5		2500		5		2		0		211
i9	4.3		0.4		2750	4.5		0		2		201
i9	4.7		1.2		.		.		2		1		211

; set eq to give something near Dobson's clarinet
;i11	0	0		1	2	; 1 harmonic per band, 18 dB/oct slope
; preserve system gain on f0, f1, attenuate f2,...
;i12	0	5.15	0 0 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 

; now play the instrument...
; note vol. levels are 10% of Dobson's to achieve matching timbre
; INSTR 90 'CLARINET'
;
i90   0   -0.65   1000   8.10
i90   +   -0.125  750    8.09
i90   +   0.125   500    8.11
i90   +   -0.75   1000   8.08
i90   +   -0.125  800    8.07
i90   +   0.125   500    8.09
i90   +   -0.25   900    8.06
i90   +   -0.25   670    8.05
i90   +   -0.25   600    8.04
i90   +   0.25    400    8.01
;BAR 2	
i90   +   -0.75   1000   8.10
i90   +   -0.125  820 	 9.00
i90   +   0.125   800    8.11
; DELAYED VIBRATO ON LAST NOTE, AND A LONG FINAL DECAY
i90	  +	  2		  700	 8.10


e
