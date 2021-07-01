<CsoundSynthesizer>
<CsOptions>
-d -b256 -B2048 -+rtaudio=jack -iadc -odac \
-+jack_client=Resurrection \
-+jack_inportname=in_ -+jack_outportname=out_
</CsOptions>
<CsInstruments>
#include "Resurrection.init"
; at sr 48000 values _must be_  ksmps 128, hopsize 256 and ipeaks 1
sr = 48000
;ksmps = 128
ksmps = 1
; we have problems with amp index with this
;0dbfs  = 1 
nchnls = 1

; code macros

#define posccode
#
	khn = int((ktrk/2)+0.5)
;printks"khn %d\n", 0.2, khn
	if khn >= inposcs goto phdone

	khnix = khn
; terrain currently unimplemented
;	$terrain
; @@@@@@@@@@@@@@@ needs checking

	ktbl1 = (ktrk<2*giphpplf ? khtbl1+ktrk : khtbl1+2*giphpplf-2)
	ktbl2 = (ktrk<2*giphpphf ? khtbl2+ktrk : khtbl2+2*giphpphf-2)
	ktbl3 = (ktrk<2*giphfflf ? khtbl3+ktrk : khtbl3+2*giphfflf-2)
	ktbl4 = (ktrk<2*giphffhf ? khtbl4+ktrk : khtbl4+2*giphffhf-2)
;printks "\\nkt1 %.0f  kt2 %.0f kt3 %.0f kt4 %.0f\\n", 0.2, ktbl1, ktbl2, ktbl3, \
;ktbl4
;printks "khn %.0f kix1 %.3f  kix2 %.3f kix3 %.3f kix4 %.3f\\n", 0.2, \
;khn, k1ix, k2ix, k3ix, k4ix
	k1amp	tableikt	k1ix, ktbl1, 1
	k2amp	tableikt	k2ix, ktbl2, 1
	k3amp	tableikt	k3ix, ktbl3, 1
	k4amp	tableikt	k4ix, ktbl4, 1
;printks "khn %.0f k1 %.3f  k2 %.3f k3 %.3f k4 %.3f\\n", 0.2, \
;khn, k1amp, k2amp, k3amp,k4amp

	ktrk = ktrk+1
	ktbl1 = ktbl1+1
	ktbl2 = ktbl2+1
	ktbl3 = ktbl3+1
	ktbl4 = ktbl4+1

	k1frq	tableikt	k1ix, ktbl1, 1
	k2frq	tableikt	k2ix, ktbl2, 1
	k3frq	tableikt	k3ix, ktbl3, 1
	k4frq	tableikt	k4ix, ktbl4, 1

	klfamp = (k3amp-k1amp)*iampix+k1amp
	khfamp = (k4amp-k2amp)*iampix+k2amp
	kamp = (khfamp-klfamp)*ifrqix+klfamp

	kppfrq = (k2frq-k1frq)*ifrqix+k1frq
	kfffrq = (k4frq-k3frq)*ifrqix+k3frq
	khfrq = (kfffrq-kppfrq)*iampix+kppfrq
;printks "p: khn %.0f kamp %.3f kfrq %.3f\\n", 0.2, khn, kamp, khfrq
	kpartpch = 0
	$comosccode

	aosc	oscili	kamp, kfrq, gisgenfn, inotephase
	aoscp = aoscp+aosc
	ktrk = ktrk+1
#

#define sosccode
#
	khn = int((ktrk/2)+0.5)
	if khn >= inoscs goto shdone

	khnix = khn
;	$terrain

	k1amp	table	khn, ihgtbl1, 0, 0, gihmagtblwrap
	k2amp	table	khn, ihgtbl2, 0, 0, gihmagtblwrap
	k3amp	table	khn, ihgtbl3, 0, 0, gihmagtblwrap
	k4amp	table	khn, ihgtbl4, 0, 0, gihmagtblwrap
	klfamp = (k3amp-k1amp)*iampix+k1amp
	khfamp = (k4amp-k2amp)*iampix+k2amp
	kamp = (khfamp-klfamp)*ifrqix+klfamp

	kamp = (gihmagtblbase==0 ? inotevol : kamp)
	kamp = (gihmagtblnorm==0 ? kamp : kamp*inotevol)

	khfrq = 0	; no frequency deviation data exists for synthetic harmonics
	kpartpch = 0

;printks "1khnix %d kpramp %f\n", 0.2, khnix, kpramp
	$comosccode
;printks "s-h: khnix %.0f kfrq %.3f\\n", 0.1, khnix, kfrq
;	$hrolloff

;	kamp = kamp*khampscl
	aosc	oscili	kamp, kfrq, gisgenfn, inotephase
	aoscs = aoscs+aosc
	ktrk = ktrk+2
#

#define hpcode
#
	if khn > inoscs goto hpdone
;	khfrq = 0

;	khnix = khn-ihp1off
;	$terrain
;	kamp = inotevol
;	kpartpch = -kp1fincr

;	$comosccode
;	$hrolloff

;	kamp = kamp*khampscl
;	ap1	oscili	kamp, kfrq, gisgenfn, inotephase

;	khnix = khn-ihp2off
;	$terrain
;	kamp = inotevol
;	kpartpch = -kp2fincr

;	$comosccode
;	$hrolloff

;	kamp = kamp*khampscl
;	ap2	oscili	kamp, kfrq, gisgenfn, inotephase

;	ap1t = ap1t+ap1
;	ap2t = ap2t+ap2
	khn = khn+1
#

#define comosccode
#
krand	tablei	khnix*iRelIxInc, $random
    krand = krand-0.5
 ; changed random table to triangular [-1,1]
	krand = krand*(1-ifrqix)	; s/b ifrqfactor?
	krand = krand*gihrand
;printks "khnix %.3f krand %.3f\\n", 0.1, khnix, krand
	kfrq = (khn+1)*kpramp+(khfrq*gihflvl)	; khfrq is frq _diff_
;	kfrq = (kfrq+kpartpch+(kfdev*kfrq))*(1+krand)
	; f terrain modulation limited to inter-harmonic distance
; lost track of what's going on here
;	kfrq = kfrq+(kmodfrq*kpramp)
	kfrq = (kfrq>$nyquistfrq ? 0 : kfrq)
		kfrq = (kfrq<0 ? 0 : kfrq)
;	kpkr1 = sqrt(ik1*(itf11/((itwopi*kfrq-ires1)^2+itf21)))
;	kpkr2 = sqrt(ik2*(itf12/((itwopi*kfrq-ires2)^2+itf22)))
;	kpkr3 = sqrt(ik3*(itf13/((itwopi*kfrq-ires3)^2+itf23)))
;printks "khn %.0f kfrq %.3f kpkr1 %.3f\\n", 0.5, khn, kfrq, kpkr1
;printks "khn %.0f kfrq %.3f kpkr2 %.3f\\n", 0.5, khn, kfrq, kpkr2
;printks "khn %.0f kfrq %.3f kpkr3 %.3f\\n", 0.5, khn, kfrq, kpkr3
;printks "1: khn %.0f kamp %.3f\\n", 0.01, khn, kamp
;kmodamp = 0
;	kamp = kamp*(1+kmodamp)*(1+kpkr1+kpkr2+kpkr3)
;kamp = kamp*(1+kmodamp)
;printks "khn %.0f kamp %.3f kfrq %.3f\\n", 0.2, khn, kamp, kfrq
#

#define pblockcode
#
	$posccode
	$posccode
	$posccode
	$posccode
	$posccode
	$posccode
	$posccode
	$posccode
	$posccode
	$posccode
#
#define sblockcode
#
	$sosccode
	$sosccode
	$sosccode
	$sosccode
	$sosccode
	$sosccode
	$sosccode
	$sosccode
	$sosccode
	$sosccode
#

#define allpcode
#
	$pblockcode
	$pblockcode
;	$pblockcode
;	$pblockcode
;	$pblockcode
;	$pblockcode
;	$pblockcode
;	$pblockcode
;	$pblockcode
;	$pblockcode
#
; maximum 100 oscs (including ftable oscs)
; n.b. Resurrection-Rebirth runs out of space on this, limit oscs
#define allscode
#
	$sblockcode
	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
#

; what do we do with the instr defs? They need to defined
; in instr 1 but these have to be included in the header.
; use globals? Does import work?
; If we do this then we can't characterise per-instr so
; they _have_ to go in the instr def'n in the main .csd.
; this means loss of user control

instr 1	; <<< meta-instrument >>>
   	iport = 0	; portamento duration - calculated  at note time 
;but may be
				; forced by value in wavetable instrument 
;sections below with
				; giport = duration
; now giinum must be selectable from score or user entry/seln!
	giinum = p4

	; instrument type defs
;	if giinum == 0 igoto inum129	; default instrument
if giinum == 0 igoto instrdone

	; instrument 33 defaults (acoustic bass)
	inum33:
	if giinum > 33 igoto inum34
	gisgenfn = 33	; single complex wavetable
	gioscs = 1
; these need to be user controls _and_ intr defaults
gimass = 25
gires = 2.5
; allow for shifting and scaling the indices
; ideally both amp and oct s/b scaled by the same values									; pitch-class)
; but might not be desirable, dual control?
;offset range is amp: (128-90.309)/2 (+/- 18.845)
; tehse aren't global in init! Not userland
giampscl = 1.4174
giampoff = 1
gifrqscl = 1.4174
gifrqoff = 0
gidcltbl = $expd
gitdeviance = 0.25
giusrdclphs = 1
	igoto instrdone

	inum34:

	; first user-definable instr (unimplemented)
	inum130:

	instrdone:

	; portamento duration (unused if i2->p6 == 0)	; CHECK THIS 
;#########
	; warning - could go out of control at extremes; tables need 
;tuning
;	giport = (iport>0 ? iport : gires/gimass)	; inverted, but 
;res might be 0
;print giport, gires, gimass
;
; <<< end instr 1, 'meta-instrument' >>>
endin

instr 90	; <<< instrument >>>
	; ##### NOTE INITIALISATION #####
; idur must be at least $mindur - this isn't trapped
;
	itie tival						; true if tied to a previously held note 
									; (p3<0)
	iheld = (p3<0 ? 1 : 0)			; true if note is held

	iseed	random	0, 1
	inotephase = (itie==1 ? -1 : iseed)	; preserve phase between tied notes
	inotedur = abs(p3)
	inotevol = p4
	inotefrq = (gisntype==0? cpspch(p5) : p5)
	ip5 = p5

; the input amp and frq might be external not score-supplied
	if $oldRS == 0 igoto noexchange
	inotefrq = cpspch(p4)
	inotevol = p5
	ip5 = p4

	noexchange:

; if 0dbfs==1 then inotevol will be <= 1 and db values will be sub-zero
; e.g. note vol 0.5 is -6dB approx, so timing gets confused
; if we then force note vol with 2^(giBitsPerSample-1) we restore actual note
; levels
inotevol = (0dbfs==1 ? inotevol*2^(giBitsPerSample-1) : inotevol)
; n.b. this is no use for floats!
	inotefrq = (inotefrq>$maxfrq ? $maxfrq : inotefrq)
	iampi = dbamp(inotevol)			; amplitude index (1-$maxai approx.)
	iocti = octpch(ip5)*10			; frequency index (0-$maxfi approx. for octave
	iampa	tablei	iampi*giampscl+giampoff, 251		; ampl attack (half vol at tbl centre)
	iampd	tablei	iampi*giampscl+giampoff, 252		; ampl decay
	iocta	tablei	iocti*gifrqscl+gifrqoff, 253		; freq attack
	ioctd	tablei	iocti*gifrqscl+gifrqoff, 254		; freq decay

print iampi, iocti, inotevol
; problems with 0dbfs = 1
; imass is technically redundant - its only effect would be to scale up the attck
; as mass increases - but the atk tables cover all eventualities
; imass currently scales correctly but mae it a direct link
; res should scale both atk (inv. prop.) and rls (prop.).
;
; f = ma so if m increases a decreases for given excitation
; then attack lengthens. Mass just scales attack
; 
; density of material, its 'type' and 'resonance'
; desnity relates to sound 'quality'
; resonance probably just scales release.
; tehn we might as well just have 'scale' for these
; next are redundant
	iampratio = iampi/$maxai
	ifrqratio = iocti/$maxfi
; companders probably redundant
	; amp/frq companders
	iampfactor	tablei	iampratio, $amptf, 1	; maximise index ranges for most-used
	ifrqfactor	tablei	ifrqratio, $frqtf, 1	; input amplitude and frequency ranges

; non-atk/rls tbl indexing via iampa/iocta (vector?) and iampd/ioctd 9ditto)
	imass = log(gimass+1)
;	ires1 = (gireshn1*imass^gires*10000*log10(iocti))/log10(iampi)
;	ires2 = (gireshn2*imass^gires*10000*log10(iocti))/log10(iampi)
;	ires3 = (gireshn3*imass^gires*10000*log10(iocti))/log10(iampi)
;	itf11 = gidamp1*0.5
;	itf21 = itf11*itf11
;	itf12 = gidamp2*0.5
;	itf22 = itf12*itf12
;	itf13 = gidamp3*0.5
;	itf23 = itf13*itf13
;	itwopi = 2*$pi
;	ik1 = gipkfactor1*ires1*sqrt((1-iampfactor)^2+ifrqfactor^2)
;	ik2 = gipkfactor2*ires2*sqrt((1-iampfactor)^2+ifrqfactor^2)
;	ik3 = gipkfactor3*ires3*sqrt((1-iampfactor)^2+ifrqfactor^2)
;print inotefrq
;print ik1, ires1
;print ik2, ires2
;print ik3, ires3
; this is a mess: s/b 1 link 'spectral width' governing all
; imatvector is a kludge
;	isw = sqrt(ifrqfactor^2+((1-iampfactor)^2))/sqrt(2)	; 'spectral width', max unity
isw = sqrt(ifrqfactor^2+((1-iampfactor)^2))/sqrt(2)	; 'spectral width', max unity
;	ies = 1-(sqrt(ifrqfactor^2+iampfactor^2)/sqrt(2))	; attack/decay modification
ies = 1-(sqrt(ifrqfactor^2+iampfactor^2)/sqrt(2))	; attack/decay modification
	iharmonics = int($nyquistfrq/inotefrq)-1	; max. harmonics above f0 in audio range at this freq.
	imatvector = sqrt(gimass^2+gires^2)/sqrt(2)	; quality of material
	; note gires here s/b related to ires<n>
	; so lower gires reduces res pk and frq
	itrmfrq = (gitrmfrq==0 ? sqrt((1/ifrqfactor)^2+(1/iampfactor)^2)*imass : gitrmfrq)	; auto-calculated tremolo rate, Hz
; randomise duration in the init section?
ihrno	ftgen	$random, 0, $tblsize, 21, 3	; rand table - unique for each call
;ihrno	ftgen	256, 0, 256, 21, 3	; rand table - unique for each call
	girandctl = (girandctl>ftlen($random) ? 0 : girandctl)
; this next lot is suspect as well
;iafno	ftgen	259, 0, 257, -5, giexpsa, 256, giexpea	; incr.
;	iafno	ftgen	202, 0, 257, -24, 259, 0, 1	; redefine header exp. incr. fn
;iafno	ftgen	260, 0, 257, -5, giexped, 256, giexpsd	; incr.
;iafno	ftgen	212, 0, 257, -24, 260, 0, 1	; redefine header exp. deccr. fn
;	insuslvl = (gihasnoise==0 ? 0 : ginsuslvl)
	; ##### END NOTE INITIALISATION #####

	; ##### NOTE AMPLITUDE ENVELOPE TIMING #####
;print iampa, iocta, imass
;print iampd, ioctd, gires
	iaeattack = iampa*iocta*imass
	iaedecline = iampd*ioctd*gires
print iaeattack, iaedecline
	iatkscl = ies*giatkscl+giatkoff
	iaeattack = iaeattack*iatkscl
	iaeattack = (iaeattack<3*$mindur? 3*$mindur : iaeattack)
	idclscl = ies*gidclscl+gidcloff
	iaedecline = iaedecline*idclscl
	iaedecline = (iaedecline<3*$mindur? 3*$mindur : iaedecline)

	itdev	random	-gitdeviance*inotedur, gitdeviance*inotedur
girandtoverlap = 1
print itdev
	itdev = (girandtoverlap==0 && itdev>0 ? 0 : itdev)
print itdev
	itdev = (ginotestart==p2 ? gitdev : itdev)	; keep chords on this
print itdev
	gitdev = (ginotestart!=p2 ? itdev : gitdev)	; instr in sync.
	ginotestart = p2
	idur = iaeattack+iaedecline
	idur = (giduradj==1 ? inotedur+itdev : idur+inotedur+itdev)
	idur = (idur<10*$mindur ? 10*$mindur : idur)

	if giusrdclphs==1 igoto usrdcl
	idur = (giduradj==0 ? idur-inotedur+itdev : idur)
	idur = (idur<10*$mindur ? 10*$mindur : idur)
	iadj = idur/(iaeattack+iaedecline)
	iaeattack = iaeattack*iadj
	iaedecline = iaedecline*iadj
	igoto endusrphs

	usrdcl:
	idur = ((itie==1 || iheld==1) && giduradj==1 ? inotedur : idur)
	idur = (giduradj==0 && girandtoverlap==0 && idur>inotedur ? inotedur : idur)
	if iaeattack+iaedecline <= idur igoto endadj
	iadj = idur/(iaeattack+iaedecline)
	iaeattack = iaeattack*iadj
	iaedecline = iaedecline*iadj

	endadj:
	iusrphsdur = idur-iaeattack-iaedecline

	; not tied, held - no release
	iusrphsdur = (itie==0 && iheld==1 ? iusrphsdur+iaedecline : iusrphsdur)
	iaedecline = (itie==0 && iheld==1 ? $mindur : iaedecline)

	; tied, not held - no attack
	iusrphsdur = (itie==1 && iheld==0 ? iusrphsdur+iaeattack : iusrphsdur)
	iaeattack = (itie==1 && iheld==0 ? $mindur : iaeattack)

	; tied and held
	iusrphsdur = (itie==1 && iheld==1 ? idur : iusrphsdur)
	iaeattack = (itie==1 && iheld==1 ? $mindur : iaeattack)
	iaedecline = (itie==1 && iheld==1 ? $mindur : iaedecline)

	iusrphsdur = (iaedecline==$mindur ? iusrphsdur-$mindur : iusrphsdur)
	iusrphsdur = (iaeattack==$mindur ? iusrphsdur-$mindur : iusrphsdur)
	iusrphsdur = (iusrphsdur<$mindur ? $mindur : iusrphsdur)

	iaedecay = 0	; default
	iaesustain = iusrphsdur	; default
	iaedecline = iaedecline-$mindur

	if gidcylenctl==0 igoto endusrphs
	if itie==1 igoto endusrphs

	iaedecay = sqrt(((2^log10(gimass))/4)^2+(((2^log10(gires))/4))^2)
	iaedecay = (iaedecay*gidcylenctl>iusrphsdur ? iusrphsdur : iaedecay*gidcylenctl)
	iaedecay = (iaedecay<2*$mindur ? 2*$mindur : iaedecay)
	iaesustain = iusrphsdur-iaedecay
	iaesustain = (iaesustain<$mindur ? $mindur : iaesustain)

	endusrphs:
	iaerelease = (iaedecline<$mindur ? $mindur : iaedecline)
	p3 = idur	; reallocate so csound knows what's going on
print iaeattack, iaedecay, iaesustain, iaerelease
	; ##### END NOTE AMPLITUDE ENVELOPE TIMING #####

	; ##### NOTE AMPLITUDE ENVELOPE CONFIG #####
	irelp = girelpscl*isw+girelpoff	; pointer
	irelp = (irelp<0 ? 0 : irelp)	; must be in [0, 1]
	irelp = (irelp>1 ? 1 : irelp)

	irlsdly = (giusrdclphs==1 ? idur-iaerelease : iaeattack+iaedecay+iaesustain)
	irlslvl = 1
	ivolratio = 1
	ilastvolratio = 1

	if giusrdclphs == 0 igoto endconfig
	idecayampl = (gidcylenctl==0 ? 1 : gidcylvlctl*((2^(log10(gires)))/4))
	idecayampl = (idecayampl>1 || giusrdclphs==0 ? 1 : idecayampl)
	giinitvol = (itie==0 ? inotevol : giinitvol)
	isustainto = ($maxfi-iocti == 0 ? 1 : \
				(($maxai-iampi)/($maxfi-iocti))*gisuslvl)
	ivolratio = (itie==0 ? 1 : inotevol/giinitvol)
	isusinitlvl = gisustainto/ivolratio
	irlslvl = (itie==0 ? isustainto : isustainto/ivolratio)
	ienvamplvls = (itie==0 && iheld==0 ? 1 : gisustainto)
	ienvamplvle = (itie==0 && iheld==0 ? 1 : isustainto)
	ilastvolratio = (itie==0 ? 1 :gilastvolratio*ienvamplvls)
	gilastvolratio = ivolratio*ienvamplvle
	gilastvol = inotevol
	gisustainto = isustainto

	if itie==0 && iheld==0 igoto endconfig
	gisustainto = 1
	isustainto = 1
	isusinitlvl = 1
	irlslvl = 1
	endconfig:	
	; ##### END NOTE AMPLITUDE ENVELOPE CONFIG #####

	; ##### AMPLITUDE ENVELOPE SHAPING #####
	kamplvl	line	ilastvolratio, idur, ivolratio

	if (itie==1 && giusrdclphs==1) igoto atkenvdone ; unless this is a default AR env

	; <<< attack phase >>>
	katkix	line	0, iaeattack, 1
	katkfix	tablei	katkix, giatkixtbl, 1	;attack indexing if non-linear
	katkaenv1	tablei	katkfix, giatktbl, 1
	katkaenv2	linseg 1, iaeattack, 1, $mindur, 0, idur-iaeattack, 0; blank everything after iaeattack
	katkaenv = katkaenv1*katkaenv2; multiply env values to achieve attack phase envelope
; timing's a bloody mess - should use single idex
	; use a separate attack timing for s-armonics to keep them in sync with
; the p-harmonics
;	; same attack period, modified phase read
;	ksatkfix	tablei	katkix, gisatkftbl, 1	;attack indexing if non-linear
; just keep standard atk env
; just scale the rise time to get it in accordance with tables?
;katkaenv1	tablei	ksatkfix, giatktbl, 1
;	ksatkaenv = katkaenv1*katkaenv2

	atkenvdone:
	if giusrdclphs==0 goto endtie
	tigoto dcydone; tied note, no decay

	if gidcylenctl==0 kgoto dcydone
	kdcy1	linseg	0, iaeattack, 0, $mindur, 1, iaedecay-$mindur, 1, $mindur, 0
	kdcyfn	oscil1i	iaeattack, 1-idecayampl, iaedecay, gidcytbl
	kdcyfn = kdcyfn+idecayampl
	kdcy = kdcyfn*kdcy1

	dcydone:
	if itie==1 goto tie
	ksust	linseg	0, iaeattack+iaedecay, 0, $mindur, idecayampl, \
					iaesustain, isustainto, $mindur, 0
	goto endtie

	tie:
	ksust	linseg	isusinitlvl, iaesustain+2*$mindur, irlslvl, $mindur, 0

	endtie:
	krel	linseg	0, irlsdly, 0, $mindur, 1, iaerelease, 1
	krel1	oscil1i	irlsdly, irlslvl, iaerelease, gidcltbl
	krel2	oscil1i	irlsdly, irlslvl, iaerelease, gidcltbl2
	krel3 = (krel2-krel1)*irelp+krel1
	krel = krel*krel3

	kdcyaenv = kdcy+ksust+krel

	dclenvdone:
	kenv = katkaenv+kdcyaenv	; final amplitude envelope
;	ksenv = ksatkaenv+kdcyaenv	; final amplitude envelope for s-harmonics
	kenv = kenv*kamplvl
;	ksenv = ksenv*kamplvl
;display kenv, idur
;display ksenv, idur
	; ##### END AMPLITUDE ENVELOPE SHAPING #####

	; ##### AMPLITUDE ENVELOPE MODULATION #####
	; expect:	i2	gitrmffn - tremolo type (sine default, square for gating)
	;			i3	gkexprenv - note or phrase expression (level, portamento)
	;			i9	gktrmaenv - tremolo amplitude envelope
	;			giadevrate
	;			giadeviance
	;			giaseed
	;			i90 inotephase
	;			i90 itrmfrq - tremolo frequency
	;			i90 kenv - amplitude envelope
	;			i90 iaeattack
	;			i90 iampfactor
	;			i90 ifrqfactor
	;			i90 kenv
	; supply:	kenv (note amplitude envelope with tremolo)
	ktenv	oscili	gktrmaenv*kenv, itrmfrq, gitrmffn, inotephase	; tremolo
	; tremolo magnitude independent of expression amplitude

	; deviance decreases as amplitude and frequency increase
	; (loud and higher pitched notes are rendered with less uncertainty)
	iadevrate = giadevrate*(((1-ifrqfactor)+(1-iampfactor))/2)
	iaseed	table	girandctl, $random
	iaseed = 1-frac(abs(iaseed)*giaseed)
	iaseed = (itie==1 ? giaseedhold : iaseed)
	giaseedhold = (itie==1? giaseedhold : iaseed)
	kadev	randi	giadeviance, iadevrate, iaseed
	; ##### END AMPLITUDE ENVELOPE MODULATION #####

	; ##### FREQUENCY MODULATION #####
	; expect:  i1	giport - base portamento duration (auto-calculated)
	;			i2	giportscl - portamento duration scale factor
	;			i2	giportramp - portamento pitch ramp type
	;			i3  giportpch - pitch to change to from current inotefrq
	;			i2  ivibdel
	;			i8  givibffn
	;			i8  givibfrq
	;			i2  givibphs - vibrato phase (0=sin, 0.25=cos)
	;			i8  gkvibaenv - vibrato amplitude envelope
	;			idur - note duration
	;			inotefrq - current note pitch value (Hz)
	;			inotephase
	;			iocti - octave index for portamento factor table
	;			iprevfreq - pitch prior to the current pitch value (Hz)
	;			itie - tied note flag
	; supply:	kpramp (note with portamento, vibrato)

	; fdevrate falls with rising amp and frq
	ifdevrate = gifdevrate*(((1-ifrqfactor)+(1-iampfactor))/2)
	ifseed	table	girandctl, $random
	ifseed = frac(abs(ifseed)*gifseed)
	kfdev	randi	gifdeviance, ifdevrate, ifseed

	; portamento
	; infer port table base from relation between pitch and prev pitch
	if itie == 0 || giportpch == 0 kgoto noport
	; note: i90.p5 == i3.p6 stops first-note portamento, as does i3.p6 == 0
	iprevfreq = giportpch
	iport	tablei	iocti, $porttbl	;	index by freq into port. factor table
	; giport is base portamento dur defaulted in i1
	iport = giport*iport	; giport only used when portamento is on (i3.p6 > 0)
 	; frequency-compensated port. dur.
	iport = (giportscl==0 ? iport : giportscl*iport)	; scale base port. duration
	iport = (iport>idur ? idur : iport)	; limit port dur to max. available
iport = (iport<$mindur ? $mindur : iport)
print iport, idur
; print out port dur and dur, etc!"! FOR DEBUG
	kpramp	oscili	1, 1/iport, giportramp
	kpramp2	linseg	1, iport, 1, $mindur, 0, idur-iport, 0
	kpramp = kpramp*kpramp2
	iadj = (iport<idur/2 ? 0 : -$mindur)
	kpramp3	linseg	0, iport+iadj, 0, $mindur, 1, idur-iport, 1, $mindur, 0
	kpramp = kpramp+kpramp3
	ifreqrange = inotefrq-iprevfreq

	kpramp = kpramp*ifreqrange	; ramp from to freq diff.and add to
	kpramp = kpramp+iprevfreq	; base note freq to get to current freq
	kgoto endport
		
	noport:
	giportpch = 0		; turn off portamento at end of tied notes
	kpramp	linseg	inotefrq, idur, inotefrq	; constant pitch

	endport:
;display kpramp, idur
	; vibrato
	ivibphs = (inotephase==0 ? givibphs : givibphs*inotephase)
	; produce a vibrato freq scaled from 0 to 1
	kvibfrq1	oscili	1, givibfrq, givibffn, ivibphs
	kvibfrq1 = (kvibfrq1+1)/2			; make +ve, range [0,1]
	kvibfrq1 = kvibfrq1*gkvibaenv		; apply amp env
	kvibenv2 = 1		; apply vibrato from attack phase unless reset below

	if givibdly == 0 || itie == 1 kgoto endvibdly
	kvibenv2	linseg	0, iaeattack, 0, $mindur, 1	; delay onset of vibrato	
	
	endvibdly:
	iviboscamp = (givibfrq==0 ? 0 : 1)	; reject dc as unwanted const. freq offset
	kvibenv = kvibfrq1*kvibenv2*iviboscamp

	kpramp = kpramp*(1+kvibenv)	; adjust pitch for vibrato (multiplicative)
	; ##### END FREQUENCY MODULATION #####

	; ##### SOUND SYNTHESIS #####
	; instrument index returns a gain factor for instr, note freq and note ampl
	igain = isw*gigainscl+gigainoff
;	ioscgain = isw*gioscgscl+gioscgoff

; if we have 0dbfs = 1 and vol levels irrelevant this needs changing
; the amplitude index reduces to note vol (range 0-1 anyway)
	; position index into limiting case harmonic data
;	iampix = (inotevol-giminvol)/(gimaxvol-giminvol)
;	iampix = (iampix<0 ? 0 : iampix)
;	iampix = (iampix>1 ? 1 : iampix)
iampix = inotevol
; frq index is still relevant
	ifrqix = (inotefrq-giminfrq)/(gimaxfrq-giminfrq)
	ifrqix = (ifrqix<0 ? 0 : ifrqix)
	ifrqix = (ifrqix>1 ? 1 : ifrqix)
; another bloody mess
	inoscs = (iharmonics+1>gioscs ? gioscs : iharmonics+1)

	ilfoscs = (giphfflf-giphpplf)*iampix+giphpplf
	ihfoscs = (giphffhf-giphpphf)*iampix+giphpphf
	iamposcs = (ihfoscs-ilfoscs)*iampix+ilfoscs

	ipposcs = (giphpphf-giphpplf)*ifrqix+giphpplf
	iffoscs = (giphffhf-giphfflf)*ifrqix+giphfflf
	ifrqoscs = (iffoscs-ipposcs)*ifrqix+ipposcs

	; inposcs is an estimate of the ftable hamonics to be accessed for a note
	inposcs = sqrt(iamposcs^2+ifrqoscs^2)/sqrt(2)
	inposcs = int(inposcs+0.5)
	inposcs = (inposcs>inoscs ? inoscs : inposcs)

	ilfoscs = (giphfflf-giphpplf)*iampix+giphpplf
	ihfoscs = (giphffhf-giphpphf)*iampix+giphpphf
	iamposcs = (ihfoscs-ilfoscs)*iampix+ilfoscs

	ipposcs = (giphpphf-giphpplf)*ifrqix+giphpplf
	iffoscs = (giphffhf-giphfflf)*ifrqix+giphfflf
	ifrqoscs = (iffoscs-ipposcs)*ifrqix+ipposcs

	; inposcs is an estimate of the ftable hamonics to be accessed for a note
	inposcs = sqrt(iamposcs^2+ifrqoscs^2)/sqrt(2)
	inposcs = int(inposcs+0.5)
	inposcs = (inposcs>inoscs ? inoscs : inposcs)
; more rubbish
iAbsIxInc = 1/$tblsize
	iRelIxInc = 1/inoscs


; another kludge - shouldn't need this
	iattack = (iaeattack==0? $mindur : iaeattack)
	idecay = (iaedecay==0 ? $mindur : iaedecay)

	if (giusrdclphs==1 || giforceampenv==1) kgoto usrdclix
	; p-harmonics have decline-sub-phases table-encoded,
	; use default AD env timing unless overridden
	ipplfstart = 0
	ipphfstart = 0
	ifflfstart = 0
	iffhfstart = 0

	idcypplft = (idecay/idur)*(1-gipplft)+gipplft
	idcypphft = (idecay/idur)*(1-gipphft)+gipphft
	idcyfflft = (idecay/idur)*(1-gifflft)+gifflft
	idcyffhft = (idecay/idur)*(1-giffhft)+giffhft

	ipplfend = 1
	ipphfend = 1
	ifflfend = 1
	iffhfend = 1

	if itie == 0 && iheld == 0 igoto endADtie
	if itie == 0 && iheld == 1 igoto phase1
	if itie == 1 && iheld == 1 igoto phase2
	if itie == 1 && iheld == 0 igoto phase3

	phase1:		; atk,rls
	ipplfend = girlspplft
	ipphfend = girlspphft
	ifflfend = girlsfflft
	iffhfend = girlsffhft
	igoto endADtie

	phase2:		; sus
	ipplfstart = idcypplft
	ipphfstart = idcypphft
	ifflfstart = idcyfflft
	iffhfstart = idcyffhft

	ipplfend = girlspplft
	ipphfend = girlspphft
	ifflfend = girlsfflft
	iffhfend = girlsffhft
	igoto endADtie

	phase3:		; sus, rls
	ipplfstart = idcypplft
	ipphfstart = idcypphft
	ifflfstart = idcyfflft
	iffhfstart = idcyffhft

	endADtie:
	k1ix	linseg	ipplfstart, iattack, gipplft, idur-iattack, ipplfend
	k2ix	linseg	ipphfstart, iattack, gipphft, idur-iattack, ipphfend
	k3ix	linseg	ifflfstart, iattack, gifflft, idur-iattack, ifflfend
	k4ix	linseg	iffhfstart, iattack, giffhft, idur-iattack, iffhfend
	kgoto endnoteix

	usrdclix:
	k1ix	linseg	0, iattack, gipplft, idecay, idcypplft, iaesustain, girlspplft, iaerelease, 1
	k2ix	linseg	0, iattack, gipphft, idecay, idcypphft, iaesustain, girlspphft, iaerelease, 1
	k3ix	linseg	0, iattack, gifflft, idecay, idcyfflft, iaesustain, girlsfflft, iaerelease, 1
	k4ix	linseg	0, iattack, giffhft, idecay, idcyffhft, iaesustain, girlsffhft, iaerelease, 1

	endnoteix:
	khtbl1 = gitblbase				;	pp lf tables
	khtbl2 = gitblbase+2*giphpplf		;	pp hf tables
	khtbl3 = khtbl2+2*giphpphf		;	ff lf tables
	khtbl4 = khtbl3+2*giphfflf		;	ff hf tables

	ihgtbl1 = (gihmagtblbase>0 ? gihmagtblbase : $unity)	; pp lf peak magnitude table
	ihgtbl2 = (gihmagtblbase>0 ? gihmagtblbase+1 : $unity)
	ihgtbl3 = (gihmagtblbase>0 ? gihmagtblbase+2 : $unity)
	ihgtbl4 = (gihmagtblbase>0 ? gihmagtblbase+3 : $unity)

; ideally we want 1 thru-note index...
	; through-note indexing, constant or phase-dependent
	kndpixc	line	0, idur, 1	; terrain translation fn position index
	klfix = (k3ix-k1ix)*iampix+k1ix
	khfix = (k4ix-k2ix)*iampix+k2ix
	kndpixp = (khfix-klfix)*ifrqix+klfix

	kndpix = (gindpix==0 ? kndpixc : kndpixp)
	kndpix = (giusrdclphs==0 ? kndpixc : kndpix)

	; synthesis
	ktrk = 0	; fundamental
	aoscp = 0
	aoscs = 0
	aoscpt = 0	 	 	 	 
	$allpcode

	phdone:	; return from oscs prescribed by ftables (p-harmonics)
	if khn == inoscs kgoto synthdone

	$allscode

	shdone:		; return from synthesised harmonics (s-harmonics)
;	aoscs = aoscs*koscgain

	synthdone:
	; ##### END SOUND SYNTHESIS #####

;asig = (gieqpt==0 ? aoscs : aoscs+aoscpt)
;	asig = (giforceampenv==0 ? aoscp+ksenv*(asig): kenv*aoscp+ksenv*asig)

asig = (aoscp+aoscs)*kenv
; add amplitude deviance
	asig = asig*(1+kadev)
	; apply tremolo envelope
	asig = asig*(1+ktenv)
	; apply expression envelope
;	asig = asig*gkexprenv				; CHECK!
	; adjust gain level
;	asig = asig*igain*gkugain
asig = asig*igain
	; apply reverb
;	garvbsig = asig
;	out asig*(1-girvbrtn)
; bad division - do it once!
asig = (0dbfs==1 ? asig/2^(giBitsPerSample-1) : asig)
out asig
girandctl = girandctl+1
; <<< end instr 90, 'instrument' >>>
endin

instr 98
; setup connection prior to use
ires system_i 1, {{jack_connect Resurrection:out_1 system:playback_1}}
ires system_i 1, {{jack_connect Resurrection:out_1 system:playback_2}}
endin


instr 99
; temp kludge
ires system_i 1, {{kill $(/sbin/pidof csound)}}
endin
</CsInstruments>
<CsScore>
; need to be able to switch the opts/sco files
; if this is run as a score-reading rendering engine
; otherwise the uer score executes and the csound instance keeps
; running for the lifetime.opts duration
; perhaps make another call to a final instrument from the user
; score which does a system kill from the pid file (set this up)
; this instr wouldn't then need to kill itself
; score includes line 'i<n> <end of score> 1
; giving 1s to execute kill cmd. Clumsy but may work.
#include "/usr/local/etc/csound/lifetime.opts"
; instead of reading input use included score file?
#include "Resurrection.sco"
; score file needs to be present and empty for midi and other trigger input, really
e
</CsScore>
</CsoundSynthesizer>

