#include "data/Cello-arco-reference-1st/Cello-arco-reference-1st-header.sco"

; use the default portamento on the tied note in chord 2
i3  1		0.25		0		0		8.11
i3  1.25	0.75		0		0		8.11

; disable temporal incompetence on chords
;i19	0	1	0	0	1	0	0	0	0


i9	0	5		10000 	3 1 1  0	3		; tremolo

i90		0		0.5		200 8.00	
i90		0		.		200 8.04	
i90		0		.		200 9.07	

i90		1		1		600 8.05	
i90		.		.		500 8.09	
i90		1.001	-0.25	400 8.11
i90		1.251	0.75	350 9.00

e
