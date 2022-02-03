#include "data/Cello-arco-reference-1st/Cello-arco-reference-1st-header.sco"

; virtual instr. i90 is defined as type cello by meta-instr. i1

; play the cello
;i90	0	1.5	2000	6.00
;i90	+	.	2000	6.00
;i90	+	.	10000	9.02
;i90	+	.	10000	9.02
;i90	+	.	2000	6.00
;i90	+	.	2000	6.00
;i90	+	.	10000	9.02
;i90	+	.	10000	9.02

; This is meant to be used with a fixed note length: set giduradj to 1
; or the portamento and vibrato get misplaced if the notes produced by default
; are too long for the score-specified duration.
;
; old sequence from clarinet score with tied notes and portamento on
; second tied group (i3)
;
; make default portamento shorter (i2)
;i2	8	1	0	0.1	0	0	0	0	0

;i3	8	2		0		0	8.00		; portamento base current note pitch
;i3	.	1		0		0	8.00		; no port. on 1st note
;i3	+	.		0		0	9.00		; port. to next note pitch
;i8	5	1		1000 	7 1 0 0 0		; vibrato
;i8	+	0		0 		0 0 0 0 0		; vib env continues unless turned off
;i90	0	1		2800		6.00
;i90	+	.		2950		6.02
;i90	+	-1		2700		6.04		; next note is tied
;i90	+	.		1750		6.05
;i90	+	1		2550		6.07		; end tie on +ve duration
;i90	+	1.25		3200		6.09
;i90   +	.    		2750   		7.11
;i90	+	-1		2500		8.00
;i90   +	1		1950                9.00
;i90   +	1.5		3300                7.00

; test for note randomisation
i90 	0	0.5		2550		8.00
;i90 	+	1		2550		8.00
;i90 	+	2		2550		8.00
;i90 0	1		2550		8.00
;i90 +	.		.			.
;i90 +	.		.			.
;i90 +	.		.			.
;i90 +	.		.			.

;i90	0	2		2800		6.00
;i90	+	.		2950		6.02
;i90	+	-2		2700			6.04		; next note is tied
;i90	+	.		1750		6.05
;i90	+	2		2550		6.07		; end tie on +ve duration
;i90	+	2.5		3200		6.09
;i90   +	.    		2750   		7.11
;i90	+	-2		2500			8.00
;i90   +	2		1950                9.00
;i90   +	3		3300                7.00

e