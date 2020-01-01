;#include "header.sco"
#include "data/Cello-arco-reference-1st/Cello-arco-reference-1st-header.sco"

; clarinet test (not really sutiable for a portamento demo!)
;i1	0		0		72
; make linear decline extended portamento
i2	0		0		0		15		0	0	0	0	0

; expression envelope example with portamento on first group of tied notes
; the portamento is from note i3->p6 to i90->np5 where i90->np5 is the next
; i90->p5 value; the first note has no portamento!
i3  3		1		0		0		8.04
i3  +		.		0		0		8.04
i3  +		.		0		0		8.05

; swell towards end of above group of tied notes
i3	3.5		2		1		202		0	; exp rise
i3	5.5		0.5		1		211		0	; lin fall
; Note: this leaves the sigmoid rise turned on as the default expr. shape.
i3	12.75	0.001	0		0		0	; reset to linear expr. mode
												; after last note on instr.
; comment the above line to see the effect of failing to reset expr. mode
; on the examples following. Note that this requires the expr. mode to have
; a duration, or the reset will not occur.

; alternative linear swell
;i3	3.5		2		1		201		0
;i3	5.5		0.5		1		211		0

; expressions may be combined: swell with portamento
;i3  3		2		1		202		0	; swell starts with first note
;i3  3		1		0		0		8.04
;i3  +		1		0		0		8.04
;i3  +		1		1		211		8.05	; and ends with last note

; in the above, note that it is necessary to specify the same factor for both
; rise and fall amplitudes in the case of tables, but true amplitude factors
; for the linear and exponential. This is because in the first case the p5
; entries are scalars of tables with range 0 to 1, indirectly specifying the
; resultant expression envelope amplitude scalar, whereas the non-table
; function p5 entries are the actual expression envelope amplitude scalars
; themselves.
;
i90	0		1		5000	8.00
i90	1.5		.		.		8.02
i90	3		-1		.		8.04	; next note is tied
i90	+		.		.		8.05
i90	+		1		.		8.07
i90	6.75	.		4970	8.09	; ampl. compensation for env. glitch
i90	8.5		.		5000	8.11
i90	10		-1		.		9.00
i90	+		.		.		10.00
i90	+		1		.		7.00
s

; default AD envelope test
;i1	0 		0		129	; default instrument
;
; change portamento type from default linear to exponential and reduce portdur
i2	0		0		202		0.2	0	0	0	0

; alternatives to setting note amp in score (which affects timbre)
;i3	0		6.5		0.5		247	0	; decreeasing gain over note range
;									; note final value persists
;i5	0		6.5		0	0	5	2	; constant gain over note range
;i5	6.5		1		0	0	5	5

; portamento on 2nd, 3rd tied notes - note portamento dur must coincide
; with note start time
i3  0		0.75	0		0		8.00
i3  +		.		0		0		8.00
i3  +		.		0		0		8.02

i90	0		-0.75	5000	8.00
i90	+		.		.		8.02
i90	+		0.75	.		8.04
i90	+		.		.		8.05
i90	+		.		.		8.07
i90	+		.		.		8.09
i90	+		.		.		8.11
i90	+		.		.		9.00
i90	+		.		.		10.00
i90	+		.		5000	7.00
s

; slide clarinet!
i1	0		0		72
; port dur override
i2	0		0		201		100		0	0	0	0	0	; make lin. decline portamento
												; over approx. tied note duration
i2	2.5		0		0		0		0	0	0	0	0; return port dur to default

; portamento
i3 0		0.5		0		0		8.00	; 8.00->8.00 on 1st note
i3 +		1		0		0		8.00	; 8.00->7.00 on 2nd note

; notes
i90	0		-0.5	5000	8.00	; next two notes tied to first
i90	+		-1		.		7.00
i90	+		1		.		7.00	; next note after this is not tied
										; using '+' truncates previous release
;s										; extension by instrument types
;
; portamento change with added swell
;i1	0 		0		41		0		0	0		0		0		0 0 0 0 0

;i2	0		0		0		10		0	0	0	0	0; force portamento dur increase
;i2	5.5		0		0		0		0	0	0	0	0; reset portamento dur to default
; portamento dur override persists until turned off
;i3 1		0		0		0		0
; tremolo applied on last note of tied group, then cut off by swell decline
; below (tremolo is reinstated)
;i3 2		0.5		0		0		7.04	; portamento on 2nd, 3rd
;i3 +		.		0		0		7.04	; tied notes
;i3 +		.		0		0		7.05	; portamento off after this

;i9	start	dur		ampl	freq	amps	ampe	trmafn	trmdly
; apply increasing/decreasing tremolo
;i9	2.5		1.5		5000	0	0		1		0		0
;i9	4		1		5000	0	1		0		0		0

;i3 8.5		0.5		0		0		8.07
;i3 +		.		0		0		8.07
;i3 +		.		0		0		8.09

;i3 2.5		1		0.4		204		0	; start swell
;i3 4.0		1		0		214		0	; reduce to score value ampl
; note: tremolo ampl must be set on swell decline as this overrides the
; setting given by i3 at t=3 above (which would otherwise persist)

;i3 9		3		2		203		0	; swell on 2nd note of tied grp
; reduces as note amplitudes decrease...

;i9	start	dur		ampl	freq	amps	ampe	vibffn	vibdly
;i8	8		1		1000	4	1		1		0		0
;i8	10.5		0.5		0		0	1		1		0		0

; consecutive notes
;i90	0	0.5		5000	7.00
;i90	1		.		>		7.02
;i90	2		-0.5	>		7.04	; tied
;i90	+		.		>		7.05
;i90	+		.		>		7.07
;i90	+		.		>		7.09	; tied, no portamento
;i90	+		.		>		7.11
;i90	+		0.5		>		8.00	; last tied note
;i90	5.5		.		>		8.02
;i90	6.5		.		>		8.04
;i90	7.5		.		>		8.05
;i90	8.5		-0.5	>		8.07
;i90	+		.		>		8.09
;i90	+		0.5		>		8.11
;i90	10.5	.		2000	9.00

e
