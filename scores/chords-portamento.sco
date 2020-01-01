; portamento in chord demo
; port time is long enough to make a glisaando

#include "data/Cello-arco-reference-1st/Cello-arco-reference-1st-header.sco"

i2	0		4	0	-1	0	0	0	0	; scale portamento by factor note dur.

i3	0		1.	0	0	8.04		; from i3.p6 to i90.p5 (8.04): initialise
i3	+		.	.	.	8.04		; from i3.p6 (8.04) to i90.p5 (8.05)
i3	+		2	.	.	8.05		; from i3.p6 (8.05) to i90.p5 (8.06)

i90		0		4		1000	8.00
i90		0.001	-1.5	700		8.04	; time offset - see docs/README
i90		+		.		.		8.05
i90		+		1	.			8.06
i90		0		4		500		8.07
