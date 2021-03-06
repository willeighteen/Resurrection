#include "data/Cello-arco-reference-1st/Cello-arco-reference-1st-header.sco"

; make default portamento shorter
;i2	0		7.5		0		0.4		0	0	0	0	0
;
;; expression envelope example with portamento on first group of tied notes
;; the portamento is from note i3->p6 to i90->np5 where i90->np5 is the next
;; i90->p5 value; the first note has no portamento!
;i3  4		1		0		0		7.04
;i3  +		.		0		0		7.04
;i3  +		.		0		0		7.05

i90	0		2		2550	7.00
i90	+		.		.		7.02
i90	+		-1		.		7.04	; next note is tied
i90	+		.		.		7.05
i90	+		1.5		.		7.07

; i.e. portamento is from i3 6.04 to i90 6.04 (first, tied note, no portamento
; required), then from i3 6.04 to i90 6.05 (portamento between 1st. and 2nd.
; notes), and finally from 13 6.05 to i90 6.07.
e
