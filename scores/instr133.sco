#include "data/instr133/instr133-header.sco"

; virtual instr. i90 is defined as type instr133 by meta-instr. i1

; play the instrument

; octave pitch-class frequency specification (gisntype = 0, default)
; variation at range extremes
;i90	0	1	1000	6.02
;i90	+	.	0		0
;i90	+	.	1000	8.01
;i90	+	.	0		0
;i90	+	.	10000	6.02
;i90	+	.	0		0
;i90	+	.	10000	8.02

;i99 0 28 0.1 0.5	; reverb

; a simple scale
;i90     0           0.85     8000	5.04
;i90     3           .        .	  	5.05
;i90     6           .        .	 	5.07
;i90     9           .        .	 	5.09
;i90     12           .        .		5.11
;i90     15         .        .		6.00
;i90     18         .        .		6.02
;i90     21         .        .		6.04
;i90     24	       .        .	 	5.04

; if gisntype = 1 (p5 = frq, Hz.)
; the 'same' note
i90	0		1		5000	73.416
;i90	+		.		0		0
;i90	+		.		5000	73.416
;i90	+		.		0		0
;i90	+		.		5000	73.416
;i90	+		.		0		0
;i90	+		.		5000	73.416
;i90	+		.		0		0
;i90	+		.		5000	73.416
;i90	+		.		0		0
;i90	+		.		5000	73.416

e