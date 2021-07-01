#include "data/instr131/instr131-header.sco"

; virtual instr. i90 is defined as type instr131 by meta-instr. i1

; play the instrument

; octave pitch-class frequency specification (gisntype = 0, default)
;i90	0	1	1000	6.02
;i90	+	.	0		0
;i90	+	.	1000	8.01
;i90	+	.	0		0
;i90	+	.	10000	6.02
;i90	+	.	0		0
;i90	+	.	10000	8.02

i90	0	1	1000	6.02
i90	2	.	1000	8.01
i90	4	.	10000	6.02
i90	6	.	10000	8.02

; if gisntype = 1 (p5 = frq, Hz.)
; the 'same' note
	;i99 0 25 0.1 0.5	; reverb

;i90	0		2.5		5000	73.416
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

;i90	0		2.5		1000	73.416
;i90	+		2.5		5000	73.416
;i90	+		2.5		10000	73.416



;i99 0 3 0.1 0.5
;i90	0	3	10000	73.416
;i90	0	1	5000	256


;i90	0	0.35		5000	6:00
;i90	+	.		.		5.11
;i90	+	.		.		5.10
;i90	+	.		.		5.09
;i90	+	0.5		.		5.06
;i90	+	1		.		4.046


e