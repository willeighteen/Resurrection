 
<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
;-odac     ;;;RT audio out
;-iadc    ;;;uncomment -iadc if RT audio input is needed too
; For Non-realtime ouput leave only the line below:
; -o comb.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

;gamix init 0 

instr 1 
krvt =  0.1
ilpt =  5
iosamps = 100
ibwmin = 20	; Hz, allowed min bw of butterworths (s/b 1)
; governs fuzziness of comb filter output
inf0 = 10000
kcf = inf0
kq	expon	1,p3, 250	; this is the nth harmonic: n*f0 <= sr/2: statevar
klpfc	expon	inf0, p3, inf0
khpfc	expon	sr/2-inf0, p3, inf0
;ibwmin/2				; butterworth bp
; comb filter fills in below this

;asig	oscili	0.1, 1000, 1
;asig buzz 0.5, 250, 5, 1

ain	diskin2	"in.wav", 1, 0
; vary kcf and kq
; tighten up cf and raise q through attack phase?
ahp,alp,abp,abr statevar ain, kcf, kq, iosamps
; pass this through a butterworth with exponential sides!
; frq pass band narrows towards cf
; so bp width is exp
;asig	butterbp	abp, 
; can't use a butterworth bp here, need separate hp, lp sections
; band is uneven width centred on n*f0
; low-pass 0 to n*f0, high-pass n*f0 to sr/2 (n*f0<=sr/2)
; bottom end doesn't have to be 0 but we cn cut off later
; top end: what if n*f0=sr/2? LP to sr/2 - but this is the 3dB point. Above this
; there's nothing so no filter input at greater freqs. If hp fc=sr/2 then we are
; 3 dB down on the harmonic to start with. Ideally it shouldn't be filtered, i.e
; anything from sr/2-allowedbandwidth/2 (whar=t gets passed) shouldn't be
; filtered. So, if n*f0>sr/2-abw/2 LP fc = sr/2 (can't put it anywhere elase,
; meaningfully. Then the upper sideband is reduced but the harmonic less so
; depending on its distance from the usb
;aout = abp
abutlp	butterlp	abp, klpfc
abuthp	butterhp	abp, khpfc
aout = abutlp+abuthp
aout	balance	aout, ain
;aout = abp*0.5

;aout   comb abp, krvt, ilpt
 ;       outs  asig, asig 
out aout
;gamix = gamix + asig 

endin

instr 99 

;krvt =  3.5
;ilpt =  0.01
;aout   comb gamix, krvt, ilpt
;aleft   comb gamix, krvt, ilpt
;aright  comb gamix, krvt, ilpt*.2
;        outs   aleft, aright
;out aout
;clear gamix     ; clear mixer
 
endin

</CsInstruments>
<CsScore>
f 1 0 32 10 0 1

;i1 0 	3 	20 	2000
;i1 5 	.01 	440 	440
i1 0	10


;i99 0 1
e

</CsScore>
</CsoundSynthesizer>