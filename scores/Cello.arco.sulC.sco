#include "data/Cello.arco.sulC/Cello.arco.sulC-header.sco"

; virtual instr. i90 is defined as type cello by meta-instr. i1

; play the cello
;i90	4	2	10000	0	1	1	214
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
;; make default portamento shorter (i2)
;i2	8		1		0		0.1		0	0	0	0	0
;
;i3	8	1		0		0	8.00		; portamento base current note pitch
;i3	.	1		0		0	8.00		; no port. on 1st note
;i3	+	.		0		0	9.00		; port. to next note pitch
;i8	5	1		7000 	7 1 0 0 0		; vibrato
;i8	+	0		0 		0 0 0 0 0		; vib env continues unless turned off
;i90	0	1		4600		6.00
;i90	+	.		4700		6.02
;i90	+	-1		4700		6.04		; next note is tied
;i90	+	.		3500		6.05
;i90	+	1		5500		6.07		; end tie on +ve duration
;i90	+	1.25		4400		6.09
;i90   +	.    		4300   		7.11
;i90	+	-1		4300		8.00
;i90   +	1		3300                9.00
;i90   +	1.5		5200                7.00

;i90	0	1		2000		7.00

; cello range test notes
;i90     0               3.31    2000    6.01    ; pp C#2
;i90     4               2.39    2000    8.02    ; pp D4
;i90 	6.5         3.21    12000   6.00    ; ff C2
;i90	 10          3.83    12000   7.11    ; ff D3

;i90	0		1.5		1700	6.00
;i90	+		.		1700	9.07
;i90	+		.		2550	7.10
;i90	+		.		3400	6.00
;i90	+		.		3400	9.07

i90	0		0.25	1550	6.10

e