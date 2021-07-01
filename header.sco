; header.sco
; Version 5: Resurrection-4.0
;
; <<< instrument wavetables >>>
;
; acoustic bass
f33 0 1024 19  1 3.2 0 0  2 0.37 75 0  3 0.01 90 0  4 0.003 0 0  5 0.001 0 0
;f33 0 128 -2  3.2 0.37 0.01 0.0035 0.001

; violin
;f141 0 1024 19  1 1.68 0 0  2 1.525 -20 0  3 .45 165 0  4 .195 150 0  5 .09 0 0  6 .07 0 0  7 .02 180 0  8 .06 0 0  9 .0175 0 0
;f41 0 1024 19  1 1.68 0 0  2 1.15 -160 0  3 0.4 -90 0  4 0.2 180 0  5 .05 0 0  6 .07 0 0  7 .1 180 0  8 .11 0 0

; alto sax
;f66 0 1024 19   1 1.48 45 1  2 1.5 30 -1  3 1.05 50 0  4 0.85 15 0  5 0.5 -30 0
;  6 0.1 0 0  7 0.15 0 0  8 0.08 0 0  9 0.013 0 0  10 0.005 0 0  11 0.004 0 0

; recorder
;f75 0 1024 19  0.5 0.5 75 0  1 6.75 0 0  2 .05 180 0  3 .15 -30 0  4 0.008 0 0

; table nos 129-200 are user-specifiable instruments

; probably need more than these - reallocate in controlFnDefs as well

; <<< attack phase tables >>>
f201	0	257	7	0 256 1			; linear 0->1
f202	0	257	5	0.001 256 1		; exp 0.001->1
f203	0	257	9	0.25 1 0			; sine 0->1
f204 0 	257	19	0.5 1 270 1 		; sigmoid 0->1

; f205-210 unassigned, reserved

; <<< decline/release and decay phase tables >>>
f211	0	257	7	1 256 0			; linear 1->0
f212	0	257	5	1 256 0.001		; exp 1->0.001
f213	0	257	9	0.25 1 90			; cos 1->0
f214 0 	257	19	0.5 1 90 1  		; sigmoid 1->0

; f215-219 unassigned, reserved

f220	0	257	9	1 2 90	; cosine
; Table #1, a simple cosine waveform.(from the gbuzz opcode manual page)
f221 0 2048 11 1	; hires cosine
f230	0	4	7	0 1 1 1 0	; triangle: extended contour
f231	0	3	7	0 1 1 1 0	; triangle: interpolated wraparound
f232	0	4	7	1 1 0 1 1	; inv. triangle extended contour
f233	0	3	7	1 1 0 1 1	; inv. triangle: interpolated wraparound
f234	0	257	3	0 1 0 1 1	; parabola

; <<< misc functions >>>
;f235	0	256	7	0	128	0	; sero-filled table: space for gioscs max. start/end h scl data
; f235reserved: internal i1 idefault terrain parameters
; 236 approx. increasing inv. exp 0 ->1
f236	0	257	7	0 1 0.015 1 0.031 2 0.061 4 0.118 8 0.222 16 0.394 32 0.633 64 0.865 64 0.993 64 1 0.865 64 0.951
; 239: sine
f239  0 257 10   1
; 240: sawtooth - harmonics have strength 1/harmonic number
f240	0	257	10	1 0.5 0.333 0.25 0.2 0.166 0.143 0.125 0.111 0.1 0.0909 0.0833 0.077
; 241: square
f241	0	257	7	1 128 1 0 -1 128 -1
; 242: pulse
f242	0	257	10	0.8 0.9 0.95 0.96 1 0.91 0.8 0.75 0.6 0.42 0.33 0.28 0.2 0.15
; 243: phasor from -1 to 1
f243    0   257    7   -1 256 1
f244	0	33	8	0.5 15 1 18 0.5	; spline curve with hump
; don't move these!
f245	0	2049	10	1	; hires sine
f246	0	2	7	0 2 0	; zero
f247	0	2	7	1 2 1	; unity

f248	0	257	-7	2 143 0.05 113 0.05; portamento/frequency factor table

; likely to be replaced by new table lookup scheme - these are clarinet range
; defaults from Csound Book; they are the default tables in controlFnDefs
; but can be overriden in the instrument
; warning - these are accessed by raw index and cannot be directly used
; <<< attack/decline duration tables >>>
f251	0	129	-5	1 48 0.88 14 0.71 10 0.5 16 0.14 40 0.015; amp attack factor
; higher amplitude returns smaller attack scalar (shorter attack)
f252	0	129	-5	0.035 58 0.14 16 0.35 10 0.64 6 0.85 54 1; amp decay factor
; higher amplitude returns higher release scalar (longer release)
f253	0	129	-7	1 40 0.95 16 0.9 14 0.79 20 0.55 10 0.44 12 0.2 16 0.02; octave attack factor
; higher freq returns shorter attack scalar
f254	0	129	-7	1 60 0.95 15 0.7 15 0.6 17 0.47 21 0.05; octave decay factor
; higher freq returns shorter decay

; see the Csound manual warning about using ftgen in .orc instr. blocks for
; mostly redundant - perhaps preserve 256, 261, maybe 262 (unimplemented here)
; f255-260
; f255 reserved: internal i90 default harmonic/partial magnitude scaling table
; f256 reserved: internal i90 random number table
; f257 reserved: internal i90 terrain amplitude modulation / harmonic level
; f258 reserved: internal i90 terrain frequency modulation / harmonic level
; f259 reserved: internal i90 exp table for attack time sync between p- and s- harmonics	; UNUSED, redundant
; f260 reserved: internal i90 exp table for release time sync between p- and s- harmonics	; UNUSED, redundant
; f261 reserved: internal i1 instrument noise definition table
; f262 reserved: internal i1 instrument constants table	; REDUNDANT

; dummy terrain data tables used for layer defaults
f280    0       128      -23     "data/default/defaultTerrainAmpOrbitFormParams"
f281    0       128      -23     "data/default/defaultTerrainAmpOrbitPathParams"
; f269-300 unassigned, reserved

; utility fns
f301	0	2	-7	0 1 1 1 0
f302	0	2	-7	1 1 0 1 1

; DO NOT DELETE f305
; contiguous-group synthesis envelope power factor - 1 (indexed by harmonic)
f305	0	128	-17	0 0 1 1 3 2 7 3 15 4 31 5 63 6


; f500 upwards - reserved for instrument data tables derived from het analysis