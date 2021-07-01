#include "header.sco"

i1	0		0		43 

; reduce harmonic gain (for a very 'warm' note', increasingly sharp)
; reduce rolloff rate (lengthen higher harmonics' duration)
i5	0	42		0.25	0.35		0.75	0.6		-1	0
i5	42	0.001	1		1			1		1		-1	0	; reset params
; top four notes have harmonic decline index rate reduced (rolloff level
; increased), harmonics decline less steeply
i5	48	12		30		10			-1		0		0.5	0.8
i5	60	0.001		1		1			-1		0		1	1

; performer competence: amp, frq, dur, ampdevrate, frqdevrate, no seeds
;i19	0	0	0.7	0.9	0.85	3	2	0	0

i90		0		3	2000 6.00
i90		+		.	3000 6.02
i90		+		.	4000 6.04
i90		+		.	5000 6.05
i90		+		.	6000 6.07
i90		+		.	7000 6.09
i90		+		.	8000 6.11
i90		+		.	9000 7.00
i90		+		.	10000 7.01
i90		+		.	9000 7.02
i90		+		.	8000 7.04
i90		+		.	7000 7.05
i90		+		.	5000 7.07
i90		+		.	4000 7.09
i90		+		.	3000 7.11
i90		+		.	2000 8.00
i90		+		.	3000 9.00
i90		+		.	4000 8.11
i90		+		.	5000 8.09
i90		+		.	6000 8.07
i90		+		.	7000 8.05
i90		+		.	8250 8.04
i90		+		.	10050 8.02
i90		+		.	12000 8.00
e
