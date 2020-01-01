; resurrection-17.2.5.orc
; 13/12/2019

; Resurrection - a csound sound rendering engine

; Will 18, 2002 - 2008, 2013, 2019
; will18@virginmedia.com
; eighteenwill@gmail.com
; license: GPL3

; currently developed with Csound-6.13 beta

;                   ###############################
;                   ########### Resurrection ###########
;                   ###############################

#include "controlFnDefs"	; some useful labels

sr = 96000
kr = 960		; default change rate ~1 msec at 96 kHz sr
ksmps = 100

nchnls = 1

; Macros
#define maxai			# 90.309 #		; max. ampl. index (equiv. 16 bits, maxvol)
#define maxfi			# 143.972 #		; max. freq. index (equiv. 22050 Hz)
#define maxfrq		# 22050 #
#define maxvol 		# 32767 #
#define mindur		# 1/(2*kr) #
#define minperiod		# 1/sr #
#define noisedefs		# 261 #			; instrument noise definition file
#define nyquistfrq		# sr/2 #			; max freq without aliasing
#define phasor		# 243 #
#define pi			# 3.141659 #		; should use csound macro... $M_PI...
#define random		# 256 #			; internal random number table
#define sin 			# 239 #
#define sin_hires		# 245 #			; defined in header
#define tblsize			# 256 #			; control fn: next ^2 >= gioscs
#define minTFuncVal	# 0.0000001 #	; avoid terrain fn div-by-zero
#define porttbl		# 248 #			; default (non-normalised)

; rosegarden score output fix (old versions seem to have p4 and p5 exchanged)
#define oldRS				# 0 #
#define oldRSdbBaseLevel	# 20 #

; Global parameters
	giEnableEnvelopeKludge	init	1

	; terrain control
	; giEnvPhase<terrainT><layerN>	init	n	; default whole note
										; 1 = attack
										; 2 = dcl or dcy+sus+rls
										;        if giusrdclphs is set:
										; 3 = decay
										; 4 = sustain
										; 5 = release
										; 6 = decay+sustain
										; 7 = sustain+release
	giEnvPhasea1					init	0
	giEnvPhasea2					init	0
	giEnvPhasea3					init	0
	giEnvPhasef1					init	0
	;giterrainFn<layerN><terrainT>		init	n
	giterrainFn1a	init	0				; default 0 use table axis fn defn
	giterrainFn2a	init	0				; 1 Sombrero function
	giterrainFn3a	init	0				; 2 Rosenbrock function
	giterrainFn1f	init	0
	; harmonic type applicability
	; giUseAllH<layerN><terrainT>	init	n	; default 0: apply amp terrain <n> path values  to s-harmonics  only
	giUseAllH1a	init	0										; 1 - apply to all harmonics
	giUseAllH2a	init	0
	giUseAllH3a	init	0
	giUseAllH1f	init	0

	; giTerrainMode<layerN><terrainT>	init	n	; 0 additive, 1 multiplicative
	giTerrainMode0a					init	1	; final z-value is multiplicative on harmonic amplitude, else additive
	giTerrainMode1a					init	1
	giTerrainMode2a					init	1	; subsequent layer is multiplicative on this layer
	giTerrainMode3a					init	1
	giTerrainMode1f					init	1	; final z-value is multiplicative on frequency, else additive	

	; default terrain tables (defined in header.sco) - provision for up to 3 amp terrains
	; gitbl<layerNum><terrainType><axis><orbitType>	; terrain table defaults
	gitbl1axOF = 280			; returns unity			; overwritten by declarations in i1 instr setup
	gitbl1ayOF = 280
	gitbl1axOP = 281			; returns zero
	gitbl1ayOP = 281
	gitbl2axOF = 280
	gitbl2ayOF = 280
	gitbl2axOP = 281
	gitbl2ayOP = 281
	gitbl3axOF = 280
	gitbl3ayOF = 280
	gitbl3axOP = 281
	gitbl3ayOP = 281

	gitbl1fxOF = 280			; provision for 1 frq terrain
	gitbl1fyOF = 280			; WARNING: experimental
	gitbl1fxOP = 281			; currently unused, in development
	gitbl1fyOP = 281

	gisntype			init	0	; default to octave pitch-class score notation, else Hz
							; 1 = Freq. in Hz.
	; instrument init
	girandtbltype		init	1	; positive - can be set in instrument definitions
	giporttbl			init	248	; default portamento frequency factor table
	gifsclfn			init	$expd; controls frq deviation allowed, less at hf
	ginotefscl			init	1
	ginotefoff			init	0
	gilastvol 			init	0
	gilastsuslvl		init	0		; amp env transition between tied notes
	giphmagscl		init	1		; default scaling for amplitude value of last p-harmonic
								; in data hmag table if less than maximum possible p
								; harmonics are used (for s-harmonics)
	gisgenfn			init	$sin_hires; default for oscs, allows susbtitution
	gihflvl			init	0		; fraction of table-specified frq deviation applied
	girandctl			init	0		; auto-incremented index into random table
	gioscs			init	10		; num oscs used in synthesis
	gitblbase			init	0		; default no p-h data tables; only s-h available
	gihmagtblbase		init	0		; no separate synth h amp tables
	gihmagtblnorm	init	0		; default h magnitudes, 0 = normalised
	gihrand			init 	0		; harmonic randomisation
	gimass			init	1		; mass of material ('about average')
	gires			init	1		; resonance of material (<1 absorbent)
	gigain		init	1			; global gain factor

	; harmonic partials
	gihaspt		init	0			; i13 no inharmonic partials by default
	gihpgain		init	1			; harmonic partials magnitude scalar
	giphmagscl		init	1		; scalar of last p-harmonic magnitude (amp level of succeedisng s-harmonics)

	; sample-derived transition point defaults
	giphpplf		init	0			; default number of ftable-prescribed harmonics
	giphfflf		init	0			; in note extreme cases.
	giphpphf		init	0
	giphffhf		init	0
	gipplft		init	0.15			; pplf table transition point: dcy/sus start
	gipphft		init	0.15			; pphf
	gifflft		init	0.15			; fflf
	giffhft		init	0.15			; ffhf
	girlspplft		init	0.85			; pplf table transition point: rls start
	girlspphft		init	0.85			; pphf
	girlsfflft		init	0.85			; fflf
	girlsffhft		init	0.85			; ffhf

	; envelope atk/dcy tbl index functions
	giampatkf	init $lind			; ampl attack: higher amp returns shorter attack
	giampdcyf	init $lini 			; ampl decay: higher amp returns longer release
	gifrqatkf		init $sigd			; freq attack: higher frq returns shorter attack
	gifrqdcyf		init $sigd			; freq decay:; higher frq returns shorter decay

	; default envelope shape
	giatkdelay	init	0			; delay attack onset in s-harmonics by factor of attack period
	gidcladvance	init	0			; advance release onset in s-harmonics by factor of decline/release period
	giatktbl		init	$sigi
	gidcytbl	init	$expd			; default decay (D in ADSR)
	gidcltbl	init	$sigd			; release phase (D in AD, R in ADSR)
	gisuslvl		init	1			; end-sustain scalar relative to fn end value
	gidcylen	init	0				; decay length: range [0,1]
	gidcylvl		init	1			; level to which decay drops: range [0,1]

	; instrument range
	giminvol		init	1
	gimaxvol		init 	32767		; if this is changed the entire system may malfunction
	giminfrq		init	30			; approx. lower limit of human hearing
	gimaxfrq		init	$nyquistfrq	; approx upper limit of human hearing

	; meta-expression
	giinitexpramp	init	0			; i3 last gain for portamento
	giexpramp	init	0			; i3 note amplitude level
	gkexprenv 	init	1			; i3 expression envelope
	giport		init	0			; i3 portamento duration
	giportpch		init	0			; i3 portamento pitch (default 0=portamento off)
	giportramp	init	201			; i2 portamento pitch ramp fn tbl (default linear)
	giportscl		init	0			; i2 portamento duration scale factor
	gktrmaenv	init	0			; i9 tremolo envelope, exported by i9
	gitrmffn		init	$sin			; i9 tremolo type; default sine
	gitrmfrq		init	0			; i9 if nonzero replaces frq-related auto tremolo
	gkvibaenv	init	0			; i8 vibrato amplitude envelope default 0 off
	givibafn		init	$unity		; i2 vibrato amplitude envelope function
	givibffn		init	$sin			; i8 vibrato type, default sine
	givibphs		init	0.25			; i2 vibrato phase, default cosine
	givibdly		init	0			; i2 vibrato onset flag: 0=attack phase, 1=decline phase
	givibfrq		init	0			; i8 vibrato frequency (default 0=off)
	gitrmdly		init 	0

	; note: this used to control peaking in e.g. horn sounds - missing
	; check older versions! - this was useful
	giaxafn		init	305		; change unlikely...
	giaxrptflag	init	0		; true: giaxafn^(f305 value), else giaxafn

	; chord synchronisation
	ginotestart	init	-1		; i90 disable time-domain competence in chords
	gitdev		init	0		; i90 preserve last time deviance for chords

	; instrumentalist' competence
	giadeviance	init 	0
	giaseed		init	0.5		; i19 
	giaseedhold	init	0		; i90 preserve amp rand seed for tied notes
	giadevrate	init	0		; i19
	gifdeviance	init	0		; i19
	gifseed		init	0.5		; i19
	gifdevrate	init	0		; i19
	gitdeviance	init	0		; i19
	
	; reverb
	; we could have a more sophisticated reverb unit (like the dynamic reverb for
	; the params table lookup test
	; reverb
	girvbrtn		init	0		; return level from reverb instr (wet/dry ratio)
	garvbsig		init 	0		; i0 initialise global reverb

	; user controls
	; score envelope timing
	giduradj		init	0		; true: autoscale to fit note length
	giusrdclphs	init	0		; default is AD envelope
	giuatkscl		init 	1		; i4 user attack/decline scaling - simple
	giudclscl		init	1		; i4 factor of instrument attack/decline times
	
	; noise specification
	gihasnoise	init	0
	ginsuslvl		init	1
	giforcenoiseampenv	init	0	; default - if 1, envelope noise and signal together

	; noise shape specification
	inatktbl1	init	$lini
	indcltbl1	init	$lind
	inatktbl2	init	$lini
	indcltbl2	init	$lind
	inatktbl3	init	$lini
	indcltbl3	init	$lind
	
	; level controls
	ginscl1	init	1
	ginscl2	init	1
	ginscl3	init	1

	; user level controls
	giunscl1		init	1	; global, set all noise levels
	giunscl2		init	1
	giunscl3		init	1
	; !Warning! This use of ftgen is unsupported. It may continue to work since
	; the table size is unmodified after creation.
	; noise definition defaults
	iafno ftgen $noisedefs, 0, 261, -23, "data/noisedefs"
	; MAX NUM NOISE PARAMS must be < tblsize
; end global parameters


; code macros

#define posccode
#
	khn = int((ktrk/2)+0.5)
	if khn == inposcs kgoto phdone
	$terrainA(a'p'khn)

	ktbl1 = (khn<giphpplf? ipplfhtbl+ktrk : $zero)
	ktbl2 = (khn<giphpphf? ipphfhtbl+ktrk : $zero)
	ktbl3 = (khn<giphfflf? ifflfhtbl+ktrk : $zero)
	ktbl4 = (khn<giphffhf? iffhfhtbl+ktrk : $zero)

	k1amp	tableikt	k1ix, ktbl1, 1
	k2amp	tableikt	k2ix, ktbl2, 1
	k3amp	tableikt	k3ix, ktbl3, 1
	k4amp	tableikt	k4ix, ktbl4, 1

	ktrk = ktrk+1	; frequency table index increment
	ktbl1 = ktbl1+1
	ktbl2 = ktbl2+1
	ktbl3 = ktbl3+1
	ktbl4 = ktbl4+1

	k1frq	tableikt	k1ix, ktbl1, 1
	k2frq	tableikt	k2ix, ktbl2, 1
	k3frq	tableikt	k3ix, ktbl3, 1
	k4frq	tableikt	k4ix, ktbl4, 1

	klfamp = (k3amp-k1amp)*iampi+k1amp
	khfamp = (k4amp-k2amp)*iampi+k2amp
	kamp = (khfamp-klfamp)*iocti+klfamp
	kppfrq = (k2frq-k1frq)*iocti+k1frq
	kfffrq = (k4frq-k3frq)*iocti+k3frq
	khfrq = (kfffrq-kppfrq)*iampi+kppfrq
	kpartpch = 0
	$comosccode(p'khn)
	aosc	oscili	kamp, kfrq, gisgenfn, inotephase
	$hpcode(p'khn)
	aosc = (giTerrainMode0a==0 ? aosc+kamp*kzap : aosc*kzap)
	aoscp = aoscp+aosc+aoscpt
	ktrk = ktrk+1	; next amplitude table index increment
#


#define sosccode
#
	khn = int((ktrk/2)+0.5)
	if khn == inoscs kgoto shdone
	$terrainA(a's'khn)

	k1amp	table	khn, ihgtbl1, 0, 0, 1
	k2amp	table	khn, ihgtbl2, 0, 0, 1
	k3amp	table	khn, ihgtbl3, 0, 0, 1
	k4amp	table	khn, ihgtbl4, 0, 0, 1
	; if there is a hmag table but the khn has not reached the limit, use the table
	; magnitude for the s-harmonic magnitude (iphmag is note-specific)
	k1amp = (khn<giphpplf ? k1amp : iphmag )
	k2amp = (khn<giphpphf ? k2amp : iphmag )
	k3amp = (khn<giphfflf ? k3amp : iphmag )
	k4amp = (khn<giphffhf ? k4amp : iphmag )

	klfamp = (k3amp-k1amp)*iampi+k1amp
	khfamp = (k4amp-k2amp)*iampi+k2amp
	kamp = (khfamp-klfamp)*iocti+klfamp

	kamp = (gihmagtblbase==0 ? inotevol : kamp)
	kamp = (gihmagtblnorm=0 ? kamp : kamp*inotevol)	; normalised hmag table
	khfrq = 0	; no frequency deviation data exists for synthetic harmonics
	kpartpch = 0
	khfrq = 0	; no contribution from p-harmonic frq diffs
	$comosccode(s'khn)
	aosc	oscili	kamp, kfrq, gisgenfn, inotephase
	$hpcode(s'khn)
	aosc = (giTerrainMode0a==0 ? aosc+kamp*kzas : aosc*kzas)
	aoscs = aoscs+aosc+aoscpt
	ktrk = ktrk+2
#


#define hpcode(eTime'khn)
#
; note we do not make a separate terrain call here to save processing time
	kpartpch = -kp1fincr
	$comosccode(s'khn)
	ap1	oscili	kamp, kfrq, gisgenfn, inotephase
	kpartpch = -kp2fincr
	$comosccode(s'khn)
	ap2	oscili	kamp, kfrq, gisgenfn, inotephase
	ktestValue = (khn==0 ? 0 : 1)
	aoscpt = (ap1+ap2)*ihpgain*ktestValue
	aoscpt = (giTerrainMode0a==0 ? aoscpt+kamp*kz : aoscpt*kz)
#


#define comosccode(eTime'khn)
#
	krand	tablei	khn*(1+ifrqix), $random
	krand = krand*gihrand
	kfrq = (((khn+1)*kpramp+kpartpch)+khfrq*gihflvl)*(1+kfdev)
	kfrq = kfrq*(1+krand)
;	$terrainF(f'$eTime'khn)
;	kfrq = kfrq*kzf$eTime
#


; this requires a separate call for f terrains since their number may not be the same as a terrains... it loses the plot...

#define terrainA(terrainType'eTime'khn)
#
	khNum = khn+1	; <a/f> regardless, this index is given by osc calls
	$terrainLayer(1'$terrainType'$eTime'khNum)	; returns harmonic modifier kz
	kmod = kz$terrainType$eTime
	$terrainLayer(2'$terrainType'$eTime'khNum)
	; remove offset if additive!
	kmod = (giTerrainMode1$terrainType==0 ? kmod+kz$terrainType$eTime : kmod*kz$terrainType$eTime)
;	$terrainLayer(3'$terrainType'$eTime'khNum)
;	kmod = (giTerrainMode2$terrainType==0 ? kmod+kz$terrainType$eTime : kmod*kz$terrainType$eTime)
	; Horner-Ayers contiguous group synthesis (modified)
	khpow	table	khn, giaxafn	;  group synthesis envelope powers
	; could experimentally use power of khn
	kmod	pow		kmod, khpow*giaxrptflag+1
	kz$terrainType$eTime = kmod
#


;#define terrainF(terrainType'eTime'khn)
;#
;	$terrainLayer(1'$terrainType'$eTime'khNum)	; returns harmonic freq modifier kzf
;	kfmod = kz$terrainType$eTime
;	kzf = (giTerrainMode1$terrainType==0 ? kfmod+kz$terrainType$eTime : kfmod*kz$terrainType$eTime)
;#


#define makeTerrainLayerOrbit(baseName'xaxis'yaxis'OP'OF'eTime)
#
	kxOS	tablei	kix$baseName$xaxis$OF$eTime+k$baseName$xaxis$OP$eTime, itbl$baseName$xaxis$OF, 1, itoff$baseName$xaxis$OF, itwrap$baseName$xaxis$OF
	kxOS$baseName$xaxis$eTime = kxOS*kmag$baseName$xaxis$OF$eTime+koff$baseName$xaxis$OF$eTime	; kxOS is final output
	kyOS	tablei	kix$baseName$yaxis$OF$eTime+k$baseName$yaxis$OP$eTime, itbl$baseName$yaxis$OF, 1, itoff$baseName$yaxis$OF, itwrap$baseName$yaxis$OF
	kyOS$baseName$yaxis$eTime = kyOS*kmag$baseName$yaxis$OF$eTime+koff$baseName$yaxis$OF$eTime	; kyOS is final output
#


#define makeOrbitPathComponent(baseName'axis'orbitType'eTime'kndx)
#
	kOP  tablei  kndx, itbl$baseName$axis$orbitType, 1, itoff$baseName$axis$orbitType, itwrap$baseName$axis$orbitType
	k$baseName$axis$orbitType$eTime = kOP*kmag$baseName$axis$orbitType$eTime+koff$baseName$axis$orbitType$eTime     ; kOP is final output
#

; problem here is 5th call needs eTime suffix!

#define makekvars(baseName'axis'orbitType'v1'v2'v3'v4'v5'v6'v7'v8'v9'v10'HTDC'AFTDC'vName'eTime'khNum)
#
; the indices don't change just durations (encoded in phases) - they reference the variables loaded from control file
	kharmonic = $khNum
	khNumTDC = (iTDCOP$vName$baseName$axis$orbitType==0 ? i$HTDC$baseName$axis$orbitType*kharmonic+i$AFTDC$baseName$axis$orbitType : i$HTDC$baseName$axis$orbitType*kharmonic*i$AFTDC$baseName$axis$orbitType)
	kndx	oscili	i$v1$baseName$axis$orbitType, i$v2$baseName$axis$orbitType$eTime, i$v3$baseName$axis$orbitType, i$v4$baseName$axis$orbitType
	kndx = (kndx+i$v5$baseName$axis$orbitType)*khNumTDC
	k$vName$baseName$axis$orbitType	tablei	kndx, i$v6$baseName$axis$orbitType, 1, i$v7$baseName$axis$orbitType, i$v8$baseName$axis$orbitType
	k$vName$baseName$axis$orbitType$eTime = k$vName$baseName$axis$orbitType*i$v9$baseName$axis$orbitType+i$v10$baseName$axis$orbitType
#

#define makespkvars(baseName'axis'orbitType'v1'v2'v3'v4'v5'v6'v7'v8'v9'v10'HTDC'AFTDC'vName'eTime'khNum)
#
; the indices don't change just durations (encoded in phases) - they reference the variables loaded from control file
	kharmonic = $khNum
	khNumTDC = (iTDCOP$vName$baseName$axis$orbitType==0 ? i$HTDC$baseName$axis$orbitType*kharmonic+i$AFTDC$baseName$axis$orbitType : i$HTDC$baseName$axis$orbitType*kharmonic*i$AFTDC$baseName$axis$orbitType)
	kndx	oscili	i$v1$baseName$axis$orbitType$eTime, i$v2$baseName$axis$orbitType$eTime, i$v3$baseName$axis$orbitType, i$v4$baseName$axis$orbitType
	kndx = (kndx+i$v5$baseName$axis$orbitType)*khNumTDC
	k$vName$baseName$axis$orbitType	tablei	kndx, i$v6$baseName$axis$orbitType, 1, i$v7$baseName$axis$orbitType, i$v8$baseName$axis$orbitType
	k$vName$baseName$axis$orbitType$eTime = k$vName$baseName$axis$orbitType*i$v9$baseName$axis$orbitType$eTime+i$v10$baseName$axis$orbitType
#

#define makekindices(baseName'axis'orbitType'eTime'khNum)
#
	khNumTDC0 = (iTDCOPix$baseName$axis$orbitType==0 ? iixHTDC$baseName$axis$orbitType*khNum+iixAFTDCscl$baseName$axis$orbitType : iixHTDC$baseName$axis$orbitType*khNum*iixAFTDCscl$baseName$axis$orbitType)
	; generate sectional sub-indices, one for each substituted variable
	; 1
	$makekvars($baseName'$axis'$orbitType'magixmag'magixsp'magixtbl'magixphase'magixoff'magtbl'magtoff'magtwrap'magmag'magoff'magHTDC'magAFTDCscl'mag'$eTime'khNum)
	; 2
	$makekvars($baseName'$axis'$orbitType'offixmag'offixsp'offixtbl'offixphase'offixoff'offtbl'offtoff'offtwrap'offmag'offoff'offHTDC'offAFTDCscl'off'$eTime'khNum)
	; 3
	$makekvars($baseName'$axis'$orbitType'ixmagixmag'ixmagixsp'ixmagixtbl'ixmagixphase'ixmagixoff'ixmagtbl'ixmagtoff'ixmagtwrap'ixmagmag'ixmagoff'ixmagHTDC'ixmagAFTDCscl'ixmag'$eTime'khNum)
	; 4
	$makekvars($baseName'$axis'$orbitType'ixoffixmag'ixoffixsp'ixoffixtbl'ixoffixphase'ixoffixoff'ixofftbl'ixofftoff'ixofftwrap'ixoffmag'ixoffoff'ixoffHTDC'ixoffAFTDCscl'ixoff'$eTime'khNum)
	; 5
	$makespkvars($baseName'$axis'$orbitType'ixspixmag'ixspixsp'ixspixtbl'ixspixphase'ixspixoff'ixsptbl'ixsptoff'ixsptwrap'ixspmag'ixspoff'ixspHTDC'ixspAFTDCscl'ixsp'$eTime'khNum)
	; 0
	; top-level indexing with k-rate indices above - this varies with what we have, combines OP and OF components
	kndx	oscili	kixmag$baseName$axis$orbitType$eTime, kixsp$baseName$axis$orbitType$eTime, iixtbl$baseName$axis$orbitType, iixphase$baseName$axis$orbitType
	kix$baseName$axis$orbitType$eTime = (kndx+kixoff$baseName$axis$orbitType$eTime)*khNumTDC0
#

#define terrainLayer(layerNum'terrainType'eTime'khNum)
#
	; the eTime <p/s> is obtained from the calling code, p or s-h
	$makekindices($layerNum$terrainType'x'OF'$eTime'khNum)
	$makekindices($layerNum$terrainType'y'OF'$eTime'khNum)
	$makekindices($layerNum$terrainType'x'OP'$eTime'khNum)
	$makeOrbitPathComponent($layerNum$terrainType'x'OP'$eTime'k$layerNum$$terrainType'x'OP'$eTime)
	$makekindices($layerNum$terrainType'y'OP'$eTime'khNum)
	$makeOrbitPathComponent($layerNum$terrainType'y'OP'$eTime'k$layerNum$$terrainType'y'OP'$eTime)
	$makeTerrainLayerOrbit($layerNum$terrainType'x'y'OP'OF'$eTime)
	$altitude($layerNum$terrainType'x'y''OP'OF'$eTime)
	kz$terrainType$eTime = kz
#

#define altitude(baseName'x'y''OP'OF'eTime)	; this gets the kz value, terrain surface altitude
#
	kx = kix$baseName$x$OF$eTime+k$baseName$x$OP$eTime	; kix...xOF, k...xOP
	ky = kix$baseName$y$OF$eTime+k$baseName$y$OP$eTime	; kix...yOF, k...yOP
	kx = (kx==0 ? $minTFuncVal : kx)
	ky = (ky==0 ? $minTFuncVal : ky)
	kz = kxOS$baseName$x$eTime*kyOS$baseName$y$eTime	; default output is from tables specified by control structure
	; embedded functions overwrite terrain table generated kz
	; 1: 'Sombrero'
	kz = (giterrainFn$baseName==1? kmag$baseName$x$OF$eTime*(sin(sqrt(kx*kx+ky*ky))/sqrt(kx*kx+ky*ky))+koff$baseName$x$OF$eTime : kz)
	;; 2: Rosenbrock function
	;; silly brackets to force precedence
	kz = (giterrainFn$baseName==2? kmag$baseName$x$OF$eTime*log((((1-kx)^2)+(100*((ky-(kx^2))^2))))+koff$baseName$x$OF$eTime  : kz)
	kz = kz*klvlctl$baseName$eTime+klvlctlmask$baseName$eTime
	kz = ((giUseAllH$baseName==0 && khn<inposcs && inposcs>0) ? 1 : kz)
#


#define initBetaNoise(noiseNum'indefsix)
#
	; noise type n parameters
	inbetainit$noiseNum	table	indefsix, $noisedefs
	inbetaterm$noiseNum	table	indefsix+1, $noisedefs
	inbetafn$noiseNum	table	indefsix+2, $noisedefs
	indefsix = indefsix+3
#

#define readNoiseParams(noiseNum'indefsix'eTime)
#
	inpersistent$noiseNum	table	indefsix, $noisedefs
	inatk$noiseNum	table	indefsix+1, $noisedefs
	inatk$noiseNum = (inatk$noiseNum>1 ? 1 : inatk$noiseNum)	; scalar
	indclflag$noiseNum	table	indefsix+2, $noisedefs
	indcl$noiseNum	table	indefsix+3, $noisedefs
	inatkt$noiseNum = inatk$noiseNum*ieattacka$eTime
	indclt$noiseNum = (indclflag$noiseNum==0 ? indcl$noiseNum*ieattacka$eTime: indcl$noiseNum*(itime$eTime-ieattacka$eTime))
	indclt$noiseNum = (indclt$noiseNum>itime$eTime-ieattacka$eTime ? itime$eTime-ieattacka$eTime-$minperiod : indclt$noiseNum)
	indclt$noiseNum = (ieattacka$eTime==0 ?  itime$eTime : indclt$noiseNum)
	indur$noiseNum = inatkt$noiseNum+indclt$noiseNum
	inatktbl$noiseNum	table	indefsix+4, $noisedefs
	indcltbl$noiseNum	table	indefsix+5, $noisedefs
	intype$noiseNum	table	indefsix+6, $noisedefs
	indefsix = indefsix+7
#

#define naenv(natkt'ndclt'natktbl'ndcltbl'persistent)
#
	iendnlvl = ($persistent==1? insuslvl : 0)
	iendnlvl = (itie==0 && iheld==0 ? 0 : iendnlvl)
	invol = inotevol*iendnlvl
	ivolratio = (itie==0 ? 1 : gilastvol)		; ???
	knatkaenv1	oscili	inotevol, 1/$natkt, $natktbl
	knatkaenv2	linseg 1, $natkt, 1, 0, 0; blank everything after $natkt
	knatkaenv = knatkaenv1*knatkaenv2; multiply env values to achieve attack phase envelope
	kndcl	oscil1i	$natkt, inotevol-invol, $ndclt, $ndcltbl
	kndcl = kndcl+invol
	kndcl2	linseg	0, $natkt, 0, 0, 1, $ndclt, 1, 0, 0
	kndclaenv = kndcl*kndcl2
	kndcl1a	linseg	invol*ivolratio, idur, invol
	kndcl1b	oscili	invol*ivolratio, 1/$ndclt, $ndcltbl
	kndcl1c	linseg	0, $natkt+$ndclt+$minperiod, 0, $minperiod, invol, idur-$natkt-$ndclt, invol, 0, 0
	kndclaenv = (itie==0 && iheld==1 && $persistent==1 ? kndclaenv+kndcl1c : kndclaenv)
	kndclaenv = (itie==1 && iheld==1 && $persistent==1 ? kndcl1a : kndclaenv); line from inotevol*iendlvl to notevol*ivolratio*iendlvl
	kndclaenv = (itie==1 && iheld==0 && $persistent==1 ? kndcl1b : kndclaenv)	; normal dcl env
	knaenv = knatkaenv+kndclaenv
#

#define noise(type'level)
#
	knflag = ($type==1 ? 1 : 0)
	anoise	noise	knaenv, knbeta
	ansig = anoise*knflag*$level

	knflag = ($type==2 ? 1 : 0)
	anoise  trirand	knaenv         ; Audio noise with triangle distribution
	ansig = anoise*knflag*$level+ansig

	knflag = ($type==3 ? 1 : 0)
;anoise rand knaenv, 2	; seeded from sys clk
	anoise rand knaenv
	ansig = anoise*knflag*$level+ansig

	knflag = ($type==4 ? 1 : 0)
	anoise	gauss knaenv
	ansig = anoise*knflag*$level+ansig

	knflag = ($type==5 ? 1 : 0)
	anoise cauchy knaenv
	ansig = anoise*knflag*$level+ansig

	anoise = ansig
#

#define pchnoise(cf'bwinit'bwterm'bwfn'skip'noiseNum)
#
	kpchbwdiff = $bwterm-$bwinit
	knpchbw	oscili	kpchbwdiff, 1/(indur$noiseNum+$minperiod), $bwfn
	knpchbw = knpchbw+$bwinit
	anoiser reson   anoise, $cf, knpchbw, 0, $skip
	anoiser	balance 	anoiser, anoise
	anoise = anoiser
;anoise resonx anoise, $cf, $bw	; [, inumlayer] [, iscl] [, iskip]; cf is probably fixed, but bw may vary
#

#define flangenoise(noiseNum'rinit'rterm'rfn'maxdly'flangefn)
#
	krdiff = $rterm-$rinit
	krate	oscili	krdiff, 1/(indur$noiseNum+$minperiod), $rfn
	krate = krate+$rinit
	klfo 	oscil 	$maxdly, krate/indur$noiseNum, $flangefn
	adel4 	vdelay 	anoise, klfo, $maxdly
	adel3 	vdelay 	adel4, klfo, $maxdly
	adel2 	vdelay 	adel3, klfo, $maxdly
	adel1 	vdelay 	adel2, klfo, $maxdly
	adel0 	vdelay 	adel1, klfo, $maxdly
	anoise = adel0+adel1+adel2+adel3+adel4
#

#define blnoise
#
; note - could use resony
	kcfoff = kpramp*gknroff
	knbw = kpramp*2*inratio
; this is the max bw
	kncf = kpramp*khn-kcfoff
	knbw = knblbwmod*knbw
	abnoise butterbp anoise, kncf, knbw
	abnoise butterbp abnoise, kncf, knbw
	abnoise butterbp abnoise, kncf, knbw
	abnoise	balance	abnoise, anoise
	ablnoise = (khn>=inoscs ? ablnoise : ablnoise+abnoise)
	ablnoise	balance	ablnoise, anoise
	khn = khn+1
#

#define pchfixnoise(noiseNum'indefsix'cf'bwinit'bwterm'bwfn'skip)
#
	; pitched/fixed noise
	indefsix = indefsix+1
	inpchcf		table	indefsix, $noisedefs
	inpchcf = (inpchcf<0 ? abs(inpchcf) : inpchcf*inotefrq)
	inpchbwinit	table	indefsix+1, $noisedefs
	inpchbwterm	table	indefsix+2, $noisedefs
	inpchbwfn	table	indefsix+3, $noisedefs
	inpchskip	table	indefsix+4, $noisedefs
	indefsix = indefsix+5
	$pchnoise(inpchcf'inpchbwinit'inpchbwterm'inpchbwfn'inpchskip'$noiseNum)	; skip = 0 pitched, 1 fixed
	inprocs$noiseNum = inprocs$noiseNum-1
#

#define flangednoise(noiseNum'indefsix'rinit'rterm'rfn'maxdly'flangefn)
#
	; flanged noise
	indefsix = indefsix+1
	inrinit			table	indefsix, $noisedefs
	inrterm			table	indefsix+1, $noisedefs
	inrfn				table	indefsix+2, $noisedefs
	inmaxdlyms		table	indefsix+3, $noisedefs
	inflangefn		table	indefsix+4, $noisedefs
	indefsix = indefsix+5
	$flangenoise($noiseNum'inrinit'inrterm'inrfn'inmaxdlyms'inflangefn)
	inprocs$noiseNum = inprocs$noiseNum-1
#

#define bandlimitednoise(noiseNum'indefsix)
#
	; band-limited noise
	indefsix = indefsix+1
	inblbwfn$noiseNum	table	indefsix, $noisedefs
	indefsix = indefsix+1
	inblcf$noiseNum	table	indefsix, $noisedefs
	khn = 1
	ablnoise = 0
	gknroff = inratio
	gknroff = (inblcf$noiseNum==0 ? 0 : inratio)	; if 0 harmonic noise otherwise partials
	knblbwmod$noiseNum	oscili	1, 1/(indur$noiseNum+$minperiod), inblbwfn$noiseNum
	indefsix = indefsix+1
	inblbwterm$noiseNum	table	1, inblbwfn$noiseNum, 1
	; the bwmod is applied to each harmonic in turn
	knblbwmod2	linseg	1, indur$noiseNum, 1, 0, 0
	knblbwmod3	linseg	0, indur$noiseNum, 0, $minperiod, inblbwterm$noiseNum, idur-indur$noiseNum, inblbwterm$noiseNum
	knblbwmod = knblbwmod$noiseNum*knblbwmod2
	knblbwmod$noiseNum = knblbwmod+knblbwmod3
	$allncode
	anoise0 = anoise0+ablnoise	; note - returns ablnoise!
#

#define makeblnoise
#
	khn = 1
	ablnoise = 0
	gknroff = (inblcf1==0 ? 0 : 2*inratio)	; if 0 harmonic noise otherwise partials
	$allncode
	anoise0 = anoise0+ablnoise
#


#define loadTerrainTables(baseName'axis'orbitType)
#
	iterraintbl = gitbl$baseName$axis$orbitType
	
	itbl$baseName$axis$orbitType			table	0, iterraintbl
	iixtbl$baseName$axis$orbitType			table	1, iterraintbl
	iixphase$baseName$axis$orbitType		table	2, iterraintbl
	itoff$baseName$axis$orbitType			table	3, iterraintbl
	itwrap$baseName$axis$orbitType			table	4, iterraintbl
	
	; 1
	imagmag$baseName$axis$orbitType		table	5, iterraintbl
	imagoff$baseName$axis$orbitType			table	6, iterraintbl
	imagtbl$baseName$axis$orbitType			table	7, iterraintbl
	imagixmag$baseName$axis$orbitType		table	8, iterraintbl
	imagixoff$baseName$axis$orbitType		table	9, iterraintbl
	imagixtbl$baseName$axis$orbitType		table	10, iterraintbl
	imagixphase$baseName$axis$orbitType		table	11, iterraintbl
	imagtoff$baseName$axis$orbitType		table	12, iterraintbl
	imagtwrap$baseName$axis$orbitType		table	13, iterraintbl
	imagixsp$baseName$axis$orbitType		table	14, iterraintbl
	imagixspflag$baseName$axis$orbitType		table	15, iterraintbl
	
	; 2
	ioffmag$baseName$axis$orbitType			table	16, iterraintbl
	ioffoff$baseName$axis$orbitType			table	17, iterraintbl
	iofftbl$baseName$axis$orbitType			table	18, iterraintbl
	ioffixmag$baseName$axis$orbitType		table	19, iterraintbl
	ioffixoff$baseName$axis$orbitType			table	20, iterraintbl
	ioffixtbl$baseName$axis$orbitType			table	21, iterraintbl
	ioffixphase$baseName$axis$orbitType		table	22, iterraintbl
	iofftoff$baseName$axis$orbitType			table	23, iterraintbl
	iofftwrap$baseName$axis$orbitType		table	24, iterraintbl
	ioffixsp$baseName$axis$orbitType			table	25, iterraintbl
	ioffixspflag$baseName$axis$orbitType		table	26, iterraintbl
	
	; 3
	iixmagmag$baseName$axis$orbitType		table	27, iterraintbl
	iixmagoff$baseName$axis$orbitType		table	28, iterraintbl
	iixmagtbl$baseName$axis$orbitType		table	29, iterraintbl
	iixmagixmag$baseName$axis$orbitType		table	30, iterraintbl
	iixmagixoff$baseName$axis$orbitType		table	31, iterraintbl
	iixmagixtbl$baseName$axis$orbitType		table	32, iterraintbl
	iixmagixphase$baseName$axis$orbitType	table	33, iterraintbl
	iixmagtoff$baseName$axis$orbitType		table	34, iterraintbl
	iixmagtwrap$baseName$axis$orbitType		table	35, iterraintbl
	iixmagixsp$baseName$axis$orbitType		table	36, iterraintbl
	iixmagixspflag$baseName$axis$orbitType	table	37, iterraintbl
	
	; 4
	iixoffmag$baseName$axis$orbitType		table	38, iterraintbl
	iixoffoff$baseName$axis$orbitType			table	39, iterraintbl
	iixofftbl$baseName$axis$orbitType			table	40, iterraintbl
	iixoffixmag$baseName$axis$orbitType		table	41, iterraintbl
	iixoffixoff$baseName$axis$orbitType		table	42, iterraintbl
	iixoffixtbl$baseName$axis$orbitType		table	43, iterraintbl
	iixoffixphase$baseName$axis$orbitType		table	44, iterraintbl
	iixofftoff$baseName$axis$orbitType			table	45, iterraintbl
	iixofftwrap$baseName$axis$orbitType		table	46, iterraintbl
	iixoffixsp$baseName$axis$orbitType		table	47, iterraintbl
	iixoffixspflag$baseName$axis$orbitType		table	48, iterraintbl
	
	; 5
	iixspmag$baseName$axis$orbitType		table	49, iterraintbl
	iixspoff$baseName$axis$orbitType			table	50, iterraintbl
	iixsptbl$baseName$axis$orbitType			table	51, iterraintbl
	iixspixmag$baseName$axis$orbitType		table	52, iterraintbl
	iixspixoff$baseName$axis$orbitType		table	53, iterraintbl
	iixspixtbl$baseName$axis$orbitType		table	54, iterraintbl
	iixspixphase$baseName$axis$orbitType		table	55, iterraintbl
	iixsptoff$baseName$axis$orbitType			table	56, iterraintbl
	iixsptwrap$baseName$axis$orbitType		table	57, iterraintbl
	iixspixsp$baseName$axis$orbitType		table	58, iterraintbl
	iixspixspflag$baseName$axis$orbitType		table	59, iterraintbl
	
	; 0
	iixTDCflag$baseName$axis$orbitType		table	60, iterraintbl
	iixAFTDC$baseName$axis$orbitType		table	61, iterraintbl
	iixAFTDCoff$baseName$axis$orbitType		table	62, iterraintbl
	iixHTDC$baseName$axis$orbitType			table	63, iterraintbl
	iTDCOPix$baseName$axis$orbitType		table	64, iterraintbl
	
	; 1
	imagTDCflag$baseName$axis$orbitType		table	65, iterraintbl
	imagAFTDC$baseName$axis$orbitType		table	66, iterraintbl
	imagAFTDCoff$baseName$axis$orbitType	table	67, iterraintbl
	imagHTDC$baseName$axis$orbitType		table	68, iterraintbl
	iTDCOPmag$baseName$axis$orbitType		table	69, iterraintbl
	
	; 2
	ioffTDCflag$baseName$axis$orbitType		table	70, iterraintbl
	ioffAFTDC$baseName$axis$orbitType		table	71, iterraintbl
	ioffAFTDCoff$baseName$axis$orbitType		table	72, iterraintbl
	ioffHTDC$baseName$axis$orbitType		table	73, iterraintbl
	iTDCOPoff$baseName$axis$orbitType		table	74, iterraintbl
	
	; 3
	iixmagTDCflag$baseName$axis$orbitType	table	75, iterraintbl
	iixmagAFTDC$baseName$axis$orbitType		table	76, iterraintbl
	iixmagAFTDCoff$baseName$axis$orbitType	table	77, iterraintbl
	iixmagHTDC$baseName$axis$orbitType		table	78, iterraintbl
	iTDCOPixmag$baseName$axis$orbitType		table	79, iterraintbl
	
	; 4:
	iixoffTDCflag$baseName$axis$orbitType		table	80, iterraintbl
	iixoffAFTDC$baseName$axis$orbitType		table	81, iterraintbl
	iixoffAFTDCoff$baseName$axis$orbitType	table	82, iterraintbl
	iixoffHTDC$baseName$axis$orbitType		table	83, iterraintbl
	iTDCOPixoff$baseName$axis$orbitType		table	84, iterraintbl
	
	; 5
	iixspTDCflag$baseName$axis$orbitType		table	85, iterraintbl
	iixspAFTDC$baseName$axis$orbitType		table	86, iterraintbl
	iixspAFTDCoff$baseName$axis$orbitType		table	87, iterraintbl
	iixspHTDC$baseName$axis$orbitType		table	88, iterraintbl
	iTDCOPixsp$baseName$axis$orbitType		table	89, iterraintbl
#


#define setLayerTiming(layerNum'terrainType'eTime)
#
ienvphase = giEnvPhase$terrainType$layerNum

; default modify whole note
; no offset, phase correct at note start
; does not allow for atk dly and dcl adv
iTerrainDur$layerNum$terrainType$eTime = itime$eTime
iEnvPhaseS$layerNum$terrainType$eTime = 0
iEnvPhaseE$layerNum$terrainType$eTime = itime$eTime

; attack phase
iTerrainDur$layerNum$terrainType$eTime = (ienvphase==1 ? ieattack$terrainType$eTime : iTerrainDur$layerNum$terrainType$eTime)
iEnvPhaseS$layerNum$terrainType$eTime = (ienvphase==1 ? 0 : iEnvPhaseS$layerNum$terrainType$eTime)
iEnvPhaseE$layerNum$terrainType$eTime = (ienvphase==1 ? ieattack$terrainType$eTime : iEnvPhaseE$layerNum$terrainType$eTime)

; post-attack phase
; either dcl or dcy+sus+rls
iTerrainDur$layerNum$terrainType$eTime = (ienvphase==2 ? iTerrainDur$layerNum$terrainType$eTime-ieattack$terrainType$eTime : iTerrainDur$layerNum$terrainType$eTime)
iEnvPhaseS$layerNum$terrainType$eTime = (ienvphase==2 ? ieattack$terrainType$eTime : iEnvPhaseS$layerNum$terrainType$eTime)
iEnvPhaseE$layerNum$terrainType$eTime = (ienvphase==2 ? itime$eTime : iEnvPhaseE$layerNum$terrainType$eTime )

; there is no phase greater than 2 in the default AD env so we can set test to some dummy value
ienvPhase = (giusrdclphs==0 ? 0 : ienvphase)	; we're done with this... fail further tests

; decay phase
iTerrainDur$layerNum$terrainType$eTime = (ienvphase==3 ? iedecay$terrainType$eTime : iTerrainDur$layerNum$terrainType$eTime)
iEnvPhaseS$layerNum$terrainType$eTime =(ienvphase==3 ? ieattack$terrainType$eTime : iEnvPhaseS$layerNum$terrainType$eTime)
iEnvPhaseE$layerNum$terrainType$eTime = (ienvphase==3 ? ieattack$terrainType$eTime+iedecay$terrainType$eTime : iEnvPhaseE$layerNum$terrainType$eTime)

; sustain phase
iTerrainDur$layerNum$terrainType$eTime = (ienvphase==4 ? iesustain$terrainType$eTime : iTerrainDur$layerNum$terrainType$eTime)
iEnvPhaseS$layerNum$terrainType$eTime = (ienvphase==4 ? ieattack$terrainType$eTime+iedecay$terrainType$eTime : iEnvPhaseS$layerNum$terrainType$eTime)
iEnvPhaseE$layerNum$terrainType$eTime = (ienvphase==4 ? itime$eTime-iedecay$terrainType$eTime-ierelease$terrainType$eTime : iEnvPhaseE$layerNum$terrainType$eTime)

; release phase
iTerrainDur$layerNum$terrainType$eTime = (ienvphase==5 ? ierelease$terrainType$eTime : iTerrainDur$layerNum$terrainType$eTime)
iEnvPhaseS$layerNum$terrainType$eTime =(ienvphase==5 ? itime$eTime-ierelease$terrainType$eTime : iEnvPhaseS$layerNum$terrainType$eTime)
iEnvPhaseE$layerNum$terrainType$eTime = (ienvphase==5 ? itime$eTime : iEnvPhaseE$layerNum$terrainType$eTime)

; decay+sustain phases
iTerrainDur$layerNum$terrainType$eTime = (ienvphase==6 ? iedecay$terrainType$eTime+iesustain$terrainType$eTime : iTerrainDur$layerNum$terrainType$eTime)
iEnvPhaseS$layerNum$terrainType$eTime = (ienvphase==6 ? ieattack$terrainType$eTime : iEnvPhaseS$layerNum$terrainType$eTime)
iEnvPhaseE$layerNum$terrainType$eTime = (ienvphase==6 ? itime$eTime-ierelease$terrainType$eTime : iEnvPhaseE$layerNum$terrainType$eTime)

; sustain+release phases
iTerrainDur$layerNum$terrainType$eTime = (ienvphase==7 ? iesustain$terrainType$eTime+ierelease$terrainType$eTime : iTerrainDur$layerNum$terrainType$eTime)
iEnvPhaseS$layerNum$terrainType$eTime = (ienvphase==7 ? ieattack$terrainType$eTime+iedecay$terrainType$eTime : iEnvPhaseS$layerNum$terrainType$eTime)
iEnvPhaseE$layerNum$terrainType$eTime = (ienvphase==7 ? itime$eTime : iEnvPhaseE$layerNum$terrainType$eTime)
#


#define setAFTDCscale(baseName'axis'orbitType)
#
iixHTDC$baseName$axis$orbitType = (iixTDCflag$baseName$axis$orbitType==0 ? 0 : iixHTDC$baseName$axis$orbitType)
imagHTDC$baseName$axis$orbitType = (imagTDCflag$baseName$axis$orbitType==0 ? 0 : imagHTDC$baseName$axis$orbitType)
ioffHTDC$baseName$axis$orbitType = (ioffTDCflag$baseName$axis$orbitType==0 ? 0 : ioffHTDC$baseName$axis$orbitType)
iixmagHTDC$baseName$axis$orbitType = (iixmagTDCflag$baseName$axis$orbitType==0 ? 0 : iixmagHTDC$baseName$axis$orbitType)
iixoffHTDC$baseName$axis$orbitType = (iixoffTDCflag$baseName$axis$orbitType==0 ? 0 : iixoffHTDC$baseName$axis$orbitType)
iixspHTDC$baseName$axis$orbitType = (iixspTDCflag$baseName$axis$orbitType==0 ? 0 : iixspHTDC$baseName$axis$orbitType)

iixAFTDCscl$baseName$axis$orbitType = iixAFTDC$baseName$axis$orbitType
imagAFTDCscl$baseName$axis$orbitType = imagAFTDC$baseName$axis$orbitType
ioffAFTDCscl$baseName$axis$orbitType = ioffAFTDC$baseName$axis$orbitType
iixmagAFTDCscl$baseName$axis$orbitType = iixmagAFTDC$baseName$axis$orbitType
iixoffAFTDCscl$baseName$axis$orbitType = iixoffAFTDC$baseName$axis$orbitType
iixspAFTDCscl$baseName$axis$orbitType = iixspAFTDC$baseName$axis$orbitType

$subSetAFTDCscale($baseName$axis$orbitType'0'0)
$subSetAFTDCscale($baseName$axis$orbitType'1'iampix)
$subSetAFTDCscale($baseName$axis$orbitType'2'ifrqix)
$subSetAFTDCscale($baseName$axis$orbitType'3'iafix)
$subSetAFTDCscale($baseName$axis$orbitType'4'iinvampix)
$subSetAFTDCscale($baseName$axis$orbitType'5'iinvfrqix)

iixAFTDCscl$baseName$axis$orbitType = (iixHTDC$baseName$axis$orbitType==0 && iixAFTDC$baseName$axis$orbitType==0? 1 : iixAFTDCscl$baseName$axis$orbitType)
imagAFTDCscl$baseName$axis$orbitType = (imagHTDC$baseName$axis$orbitType==0 && imagAFTDC$baseName$axis$orbitType==0? 1 : imagAFTDCscl$baseName$axis$orbitType)
ioffAFTDCscl$baseName$axis$orbitType = (ioffHTDC$baseName$axis$orbitType==0 && ioffAFTDC$baseName$axis$orbitType==0? 1 : ioffAFTDCscl$baseName$axis$orbitType)
iixmagAFTDCscl$baseName$axis$orbitType = (iixmagHTDC$baseName$axis$orbitType==0 && iixmagAFTDC$baseName$axis$orbitType==0? 1 : iixmagAFTDCscl$baseName$axis$orbitType)
iixoffAFTDCscl$baseName$axis$orbitType = (iixoffHTDC$baseName$axis$orbitType==0 && iixoffAFTDC$baseName$axis$orbitType==0? 1 : iixoffAFTDCscl$baseName$axis$orbitType)
iixspAFTDCscl$baseName$axis$orbitType = (iixspHTDC$baseName$axis$orbitType==0 && iixspAFTDC$baseName$axis$orbitType==0? 1 : iixspAFTDCscl$baseName$axis$orbitType)
#


#define subSetAFTDCscale(baseName'testValue'linkTypeValue)
#
iixAFTDCscl$baseName = (iixTDCflag$baseName==$testValue ? iixAFTDC$baseName*$linkTypeValue+iixAFTDCoff$baseName : iixAFTDCscl$baseName)
imagAFTDCscl$baseName = (imagTDCflag$baseName==$testValue ? imagAFTDC$baseName*$linkTypeValue+imagAFTDCoff$baseName : imagAFTDCscl$baseName)
ioffAFTDCscl$baseName = (ioffTDCflag$baseName==$testValue ? ioffAFTDC$baseName*$linkTypeValue+ioffAFTDCoff$baseName : ioffAFTDCscl$baseName)
iixmagAFTDCscl$baseName = (iixmagTDCflag$baseName==$testValue ? iixmagAFTDC$baseName*$linkTypeValue+iixmagAFTDCoff$baseName : iixmagAFTDCscl$baseName)
iixoffAFTDCscl$baseName = (iixoffTDCflag$baseName==$testValue ? iixoffAFTDC$baseName*$linkTypeValue+iixoffAFTDCoff$baseName : iixoffAFTDCscl$baseName)
iixspAFTDCscl$baseName = (iixspTDCflag$baseName==$testValue ? iixspAFTDC$baseName*$linkTypeValue+iixspAFTDCoff$baseName : iixspAFTDCscl$baseName)
#


#define setScanTiming(baseName'axis'orbitType'eTime)
#
iTerrainDur = (iTerrainDur$baseName$eTime>0 ? iTerrainDur$baseName$eTime : -1)	; dummy value avoids failure
imagixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && imagixsp$baseName$axis$orbitType<0 ? imagixsp$baseName$axis$orbitType*inotefrq : imagixsp$baseName$axis$orbitType)
imagixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && imagixsp$baseName$axis$orbitType>0 ? imagixsp$baseName$axis$orbitType/iTerrainDur : imagixsp$baseName$axis$orbitType$eTime)
imagixsp$baseName$axis$orbitType$eTime = abs(imagixsp$baseName$axis$orbitType$eTime)
ioffixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && ioffixsp$baseName$axis$orbitType<0 ? ioffixsp$baseName$axis$orbitType*inotefrq : ioffixsp$baseName$axis$orbitType)
ioffixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && ioffixsp$baseName$axis$orbitType>0 ? ioffixsp$baseName$axis$orbitType/iTerrainDur : ioffixsp$baseName$axis$orbitType$eTime)
ioffixsp$baseName$axis$orbitType$eTime = abs(ioffixsp$baseName$axis$orbitType$eTime)
iixmagixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixmagixsp$baseName$axis$orbitType<0 ? iixmagixsp$baseName$axis$orbitType*inotefrq : iixmagixsp$baseName$axis$orbitType)
iixmagixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixmagixsp$baseName$axis$orbitType>0 ? iixmagixsp$baseName$axis$orbitType/iTerrainDur : iixmagixsp$baseName$axis$orbitType$eTime)
iixmagixsp$baseName$axis$orbitType$eTime = abs(iixmagixsp$baseName$axis$orbitType$eTime)
iixoffixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixoffixsp$baseName$axis$orbitType<0 ? iixoffixsp$baseName$axis$orbitType*inotefrq : iixoffixsp$baseName$axis$orbitType)
iixoffixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixoffixsp$baseName$axis$orbitType>0 ? iixoffixsp$baseName$axis$orbitType/iTerrainDur : iixoffixsp$baseName$axis$orbitType$eTime)
iixoffixsp$baseName$axis$orbitType$eTime = abs(iixoffixsp$baseName$axis$orbitType$eTime)
iixspixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixspixsp$baseName$axis$orbitType<0 ? iixspixsp$baseName$axis$orbitType*inotefrq : iixspixsp$baseName$axis$orbitType)
iixspixsp$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixspixsp$baseName$axis$orbitType>0 ? iixspixsp$baseName$axis$orbitType/iTerrainDur : iixspixsp$baseName$axis$orbitType$eTime)
iixspixsp$baseName$axis$orbitType$eTime = abs(iixspixsp$baseName$axis$orbitType$eTime)
iixspmag$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixspmag$baseName$axis$orbitType<0 ? iixspmag$baseName$axis$orbitType*inotefrq : iixspmag$baseName$axis$orbitType)
iixspmag$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixspmag$baseName$axis$orbitType>0 ? iixspmag$baseName$axis$orbitType/iTerrainDur : iixspmag$baseName$axis$orbitType$eTime)
iixspmag$baseName$axis$orbitType$eTime = abs(iixspmag$baseName$axis$orbitType$eTime)
iixspixmag$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixspixmag$baseName$axis$orbitType<0 ? iixspixmag$baseName$axis$orbitType*inotefrq : iixspixmag$baseName$axis$orbitType)
iixspixmag$baseName$axis$orbitType$eTime = (iixspixspflag$baseName$axis$orbitType==1 && iixspixmag$baseName$axis$orbitType>0 ? iixspixmag$baseName$axis$orbitType/iTerrainDur : iixspixmag$baseName$axis$orbitType$eTime)
iixspixmag$baseName$axis$orbitType$eTime = abs(iixspixmag$baseName$axis$orbitType$eTime)

; defensive
imagixsp$baseName$axis$orbitType$eTime = (iTerrainDur==-1 ? 0 : imagixsp$baseName$axis$orbitType$eTime)
ioffixsp$baseName$axis$orbitType$eTime = (iTerrainDur==-1 ? 0 : ioffixsp$baseName$axis$orbitType$eTime)
iixmagixsp$baseName$axis$orbitType$eTime = (iTerrainDur==-1 ? 0 : iixmagixsp$baseName$axis$orbitType$eTime)
iixoffixsp$baseName$axis$orbitType$eTime = (iTerrainDur==-1 ? 0 : iixoffixsp$baseName$axis$orbitType$eTime)
iixspixsp$baseName$axis$orbitType$eTime = (iTerrainDur==-1 ? 0 : iixspixsp$baseName$axis$orbitType$eTime)
iixspmag$baseName$axis$orbitType$eTime = (iTerrainDur==-1 ? 0 : iixspmag$baseName$axis$orbitType$eTime)
iixspixmag$baseName$axis$orbitType$eTime = (iTerrainDur==-1 ? 0 : iixspixmag$baseName$axis$orbitType$eTime)
#


#define initLayerEnvPhase(layerNum'terrainType)
#
$setLayerEnvPhase($layerNum'$terrainType'p)	; we have to have both p- and s- or the osc code fails
$setLayerEnvPhase($layerNum'$terrainType's)	; on uninitialised k-rate variables
#


#define setLayerEnvPhase(layerNum'terrainType'eTime)
#
	iphase = giEnvPhase$terrainType$layerNum

	; amp envelope section masks
	; default whole note
	; we can't allow for atk delay or dcl advance! these envelopes are therefore wrong for s-h
	; we have to set p- and s- separately, allowing for delayed atk; could ignore release since the env takes care of it
	klvlctl	linseg	1, itime$eTime, 1, 0, 0
	klvlctlmask	linseg	0, itime$eTime, 0

	; attack phase
	klvlctl1b			linseg	1, ieattack$terrainType$eTime, 1, $mindur, 0, itime$eTime-ieattack$terrainType$eTime, 0
	klvlctlmask1b	linseg	0, ieattack$terrainType$eTime, 0, $mindur, 1, itime$eTime-ieattack$terrainType$eTime, 1, $mindur, 0
	klvlctl = (iphase==1 ? klvlctl1b : klvlctl)
	klvlctlmask = (iphase==1 ? klvlctlmask1b : klvlctlmask)

	; post-attack phase
	; either dcl or dcy+sus+rls
	klvlctl1b			linseg	0, ieattack$terrainType$eTime, 0, $mindur, 1, itime$eTime-ieattack$terrainType$eTime, 1, $mindur, 0
	klvlctlmask1b	linseg	1, ieattack$terrainType$eTime, 1, $mindur, 0, itime$eTime-ieattack$terrainType$eTime, 0
	klvlctl = (iphase==2 ? klvlctl1b : klvlctl)
	klvlctlmask = (iphase==2 ? klvlctlmask1b : klvlctlmask)

	; decay phase
	klvlctl1b	linseg	0, ieattack$terrainType$eTime, 0, $mindur, 1, iedecay$terrainType$eTime, 1, $mindur, 0, itime$eTime-ieattack$terrainType$eTime-iedecay$terrainType$eTime, 0
	klvlctlmask1b	linseg	1, ieattack$terrainType$eTime, 1, $mindur, 0, iedecay$terrainType$eTime, 0, $mindur, 1, itime$eTime-ieattack$terrainType$eTime-iedecay$terrainType$eTime, 1, $mindur, 0
	klvlctl = (iphase==3 && giusrdclphs==1 ? klvlctl1b : klvlctl)
	klvlctlmask = (iphase==3 && giusrdclphs==1? klvlctlmask1b : klvlctlmask)

	; sustain phase
	klvlctl1b	linseg	0, ieattack$terrainType$eTime+iedecay$terrainType$eTime, 0, $mindur, 1, iesustain$terrainType$eTime, 1, $mindur, 0, ierelease$terrainType$eTime, 0
	klvlctlmask1b	linseg	1, ieattack$terrainType$eTime+iedecay$terrainType$eTime, 1, $mindur, 0, iesustain$terrainType$eTime, 0, $mindur, 1, ierelease$terrainType$eTime, 1, $mindur, 0
	klvlctl = (iphase==4 && giusrdclphs==1 ? klvlctl1b : klvlctl)
	klvlctlmask = (iphase==4 && giusrdclphs==1? klvlctlmask1b : klvlctlmask)

	; release phase
	klvlctl1b		linseg	0, itime$eTime-ierelease$terrainType$eTime, 0, $mindur, 1, ierelease$terrainType$eTime, 1, $mindur, 0
	klvlctlmask1b	linseg	1, itime$eTime-ierelease$terrainType$eTime, 1, $mindur, 0, ierelease$terrainType$eTime, 0
	klvlctl = (iphase==5 && giusrdclphs==1 ? klvlctl1b : klvlctl)
	klvlctlmask = (iphase==5 && giusrdclphs==1? klvlctlmask1b : klvlctlmask)

	; decay+sustain phases
	klvlctl1b	linseg	0, ieattack$terrainType$eTime, 0, $mindur, 1, iedecay$terrainType$eTime+iesustain$terrainType$eTime, 1, $mindur, 0, ierelease$terrainType$eTime, 0
	klvlctlmask1b	linseg	1, ieattack$terrainType$eTime, 1, $mindur, 0, iedecay$terrainType$eTime+iesustain$terrainType$eTime, 0, $mindur, 1, ierelease$terrainType$eTime, 1, $mindur, 0
	klvlctl = (iphase==6 && giusrdclphs==1 ? klvlctl1b : klvlctl)
	klvlctlmask = (iphase==6 && giusrdclphs==1? klvlctlmask1b : klvlctlmask)

	; sustain+release phases
	klvlctl1b	linseg	0, ieattack$terrainType$eTime+iedecay$terrainType$eTime, 0, $mindur, 1, iesustain$terrainType$eTime+ierelease$terrainType$eTime, 1, $mindur, 0
	klvlctlmask1b	linseg	1, ieattack$terrainType$eTime+iedecay$terrainType$eTime, 1, $mindur, 0, iesustain$terrainType$eTime+ierelease$terrainType$eTime, 0
	klvlctl = (iphase==7 && giusrdclphs==1 ? klvlctl1b : klvlctl)
	klvlctlmask = (iphase==7 && giusrdclphs==1? klvlctlmask1b : klvlctlmask)

	klvlctl$layerNum$terrainType$eTime = klvlctl
	klvlctlmask$layerNum$terrainType$eTime = klvlctlmask
#


#define initTerrain(layerNum'terrainType)
#
; we have to call all defined terrains or the k-rate layerEnvPhase fails
$loadTerrainTables($layerNum$terrainType'x'OF)
$loadTerrainTables($layerNum$terrainType'y'OF)
$loadTerrainTables($layerNum$terrainType'x'OP)
$loadTerrainTables($layerNum$terrainType'y'OP)
$setLayerTiming($layerNum'$terrainType'p)				; p-envelope timing
$setLayerTiming($layerNum'$terrainType's)				; s-envelope timing
$setAFTDCscale($layerNum$terrainType'x'OF)
$setAFTDCscale($layerNum$terrainType'y'OF)
$setAFTDCscale($layerNum$terrainType'x'OP)
$setAFTDCscale($layerNum$terrainType'y'OP)
$setScanTiming($layerNum$terrainType'x'OF'p)
$setScanTiming($layerNum$terrainType'x'OF's)
$setScanTiming($layerNum$terrainType'y'OF'p)
$setScanTiming($layerNum$terrainType'y'OF's)
$setScanTiming($layerNum$terrainType'x'OP'p)
$setScanTiming($layerNum$terrainType'x'OP's)
$setScanTiming($layerNum$terrainType'y'OP'p)
$setScanTiming($layerNum$terrainType'y'OP's)
#


#define ampEnvTiming
#
	iscorenotedur = inotedur
	itdev	random	-gitdeviance*inotedur, gitdeviance*inotedur
	itdev = (ginotestart==p2 ? gitdev : itdev)	; keep chords on this
	gitdev = (ginotestart!=p2 ? itdev : gitdev)	; instr in sync.
	ginotestart = p2

	; determine a basic attack and decline default
	iaeattack = sqrt(iampa^2+iocta^2)/sqrt(2)
	iaedecline = sqrt(iampd^2+ioctd^2)/sqrt(2)

	; modify the attack and decline by scalings based
	; on acceleration given mass and resonance
	; note this latter is a very woolly term, here modifying decline phase length
	iaeattack = iaeattack*iatkdurscl*giuatkscl
	iaedecline = iaedecline*idcldurscl*giudclscl
	inotedur = inotedur*(1+itdev)
	iatkzeroperiod = giatkdelay*(1-iampi)*iaeattack
	iaeattack = iaeattack+iatkzeroperiod	; decline doesn't change default note length
	itotaldur = iaeattack+iaedecline
	iusrphsdur = 0; default

	if itotaldur>inotedur igoto adjtiming	; we need to do something
	iusrphsdur = inotedur-itotaldur
	igoto timingdone

	adjtiming:
	if giduradj == 0 igoto timingdone
	itotaldur = itotaldur+inotedur	; now rescale to inotedur
	itscl = (giusrdclphs==0 ? inotedur : inotedur/itotaldur)
	iaeattack = iaeattack*itscl
	iaedecline = iaedecline*itscl
	iusrphsdur = inotedur-iaeattack-iaedecline
	igoto timingdone

	timingdone:
	inotedur = (itotaldur>inotedur ? itotaldur : inotedur)
	iaerelease = iaedecline	; default

	if giusrdclphs==0 igoto endusrphs
	; not tied, held - no release
	iusrphsdur = (itie==0 && iheld==1 ? iusrphsdur+iaerelease-iatkzeroperiod : iusrphsdur)
	iaerelease = (itie==0 && iheld==1 ? 0 : iaerelease)

	; tied, not held - no attack
	iusrphsdur = (itie==1 && iheld==0 ? iusrphsdur+iaeattack : iusrphsdur)
	iaeattack = (itie==1 && iheld==0 ? 0 : iaeattack)

	; tied and held - no attack or release
	iusrphsdur = (itie==1 && iheld==1 ? inotedur : iusrphsdur)
	iaeattack = (itie==1 && iheld==1 ? 0 : iaeattack)
	iaerelease = (itie==1 && iheld==1 ? 0 : iaerelease)
	iaesustain = iusrphsdur	; we need to set this individually

	if (gidcylen==0 || itie==1) igoto endusrphs
	iaedecay = gidcylen*iusrphsdur
	iaesustain = iaesustain-iaedecay

	endusrphs:
	idclzeroperiod = abs(gidcladvance*(1-iampi)*iaerelease)
	iaepattack = iaeattack+$minperiod
	iaepdecay = iaedecay+$minperiod
	iaepsustain = (itie==1 && iheld==1 ? iaesustain+$minperiod: iaesustain+iatkzeroperiod+$minperiod)
	iaeprelease = iaerelease+$minperiod
	isusflag = 0	; don't do anything when flag tested

	if gidcladvance==0 igoto dcladvancedone
	if giusrdclphs==0 igoto defaultadvance
	if (itie==1 || iheld==1) igoto dcladvancedone	; fails on end tie, s/b '&&'?
	if (iaesustain-idclzeroperiod)<0 igoto subadvance	; can't sub it all from sus
	iaesustain = (giusrdclphs==0 ? 0 : iaesustain-idclzeroperiod)
	igoto dcladvancedone
	subadvance:
	iadj = iaesustain-idclzeroperiod
	if iadj>0 igoto sustrim
	isusflag = 1
	iaesustain = 0
	iaerelease = iaerelease+iadj
	igoto dcladvancedone
	sustrim:
	iaesustain = iaesustain-iadj	; all ok, enough space
	igoto dcladvancedone

	defaultadvance:	; just the release phase
	iaerelease = iaerelease-idclzeroperiod	; no check
	
	dcladvancedone:
	iatkperiod = iaeattack+iatkzeroperiod
	iaesustain = (iaesustain<0 ? 0 : iaesustain)
	if giusrdclphs==0 igoto keepattack
	iatkperiod = (itie==1 ? 0 : iatkperiod)

	keepattack:
	irlsdur = iaerelease
	irlsdly = iatkperiod+iaedecay+iaesustain

	if giusrdclphs==0 igoto keeprlsdly
	irlsdly = (itie==1 && iheld==0 ? iaedecay+iaesustain : irlsdly)

	keeprlsdly:
	if giusrdclphs==0 igoto keepattackp	; avoid table read termination
	iaepattack = (itie==1 && iheld==0 ? $minperiod : iaepattack)

	keepattackp:
	if giusrdclphs==0 igoto notie
	irlsdur = (itie==1 && iheld==1 ? 0 : irlsdur)

	notie:
	idcyperiod = (gidcylen==0 ? 0 : iaedecay)
	idcyoff = ((gidcylen==0  || iaedecay<(2*$mindur)) ? 0 : 2*$mindur)
	isusdur = iaesustain
	isuszerodur = iatkperiod+idcyperiod
	isuszerodur = (giusrdclphs==0 ? 0 : isuszerodur)
	isuszerodur = (isusflag==1 ? 0 : isuszerodur)
	isusoff = 0
	irlsdlyoff = 0
	irlsoff = 0

	if giusrdclphs==0 || giEnableEnvelopeKludge==0 igoto offsetsdone
	isusoff = ((itie==1 || iheld==1)? 0 : 3*$mindur)
	irlsdlyoff = ((itie==1 || iheld==1) ? 0 : 1.5*$mindur)
	irlsoff = ((itie==1 || iheld==1) ? 0 : 3*$mindur)

	offsetsdone:
	iatkzeroperiod = iatkzeroperiod+$minperiod	; prevent attack linseg failure
	ieattackas = iatkperiod	; 'env attack type amplitude s-h'
	iedecayas = idcyperiod
	iesustainas = isusdur
	iereleaseas = irlsdur
	
	ieattackap = iaepattack
	iedecayap = iaepdecay
	iesustainap = iaepsustain
	iereleaseap = iaeprelease
	
	ieattackfs = iatkperiod	; by default frq envelopes occupy the same section as amp envelope
	iedecayfs = idcyperiod	; but need their own labels
	iesustainfs = isusdur
	iereleasefs = irlsdur
	
	ieattackfp = iaepattack
	iedecayfp = iaepdecay
	iesustainfp = iaepsustain
	iereleasefp = iaeprelease

	itimes = iatkperiod+idcyperiod+isusdur+irlsdur
	itimep = iaepattack+iaepdecay+iaepsustain+iaeprelease
	idur = (itimes>itimep ? itimes : itimep)
print iatkperiod, idcyperiod, isusdur, irlsdur
print iaepattack, iaepdecay, iaepsustain, iaeprelease
print itimes, itimep
	p3 = idur	; idur has the maximum duration
#


#define setAmpEnvLevels
#
	irlslvl = 1
	if giusrdclphs == 0 igoto endconfig
	gilastsuslvl = (gilastsuslvl==0 || itie==0 ? 1 : gilastsuslvl)
	gilastvol = (gilastvol==0 || itie==0 ? inotevol : gilastvol)
	; idecayampl only applies to non-tied notes in the user decline phase
	idecayampl = (gidcylen==0 ? 1 : gidcylvl*(2^(log10(gires)))*iafix)
	idecayampl = (iaesustain==0 ? 0 : idecayampl)
	isustainto = (iaesustain==0 ? 1 : iafix*gisuslvl)
	isustainto = (isustainto==0 ? 1 : isustainto)	; defensive
	isustainto = (iaesustain==0 ? 0 : isustainto)
	isusinitlvl = gilastsuslvl*gilastvol/inotevol
	isusendlvl = isusinitlvl*gisuslvl*inotevol/gilastvol
	irlslvl = (isustainto==0 ? 1 : isustainto)	; if no sustain
	irlslvl = (itie==1 && iheld==0 ? isusendlvl : irlslvl)
	idcylvl = 1-idecayampl
	gilastsuslvl = (itie==1 && iheld==1 ? isusendlvl: isustainto)
	gilastvol = inotevol
	endconfig:
#


#define ampEnvShape
#
	if (itie==1 && giusrdclphs==1) igoto atkenvdone ; unless this is a default AD env
	; <<< attack phase >>>
	katkix	linseg	0, iatkzeroperiod, 0, iaeattack, 1
	katkaenv1	tablei	katkix, giatktbl, 1
	katkaenv2	linseg 1, iatkperiod, 1, 0, 0
	katkaenv = katkaenv1*katkaenv2; multiply env values to achieve attack phase envelope

	atkenvdone:
	if giusrdclphs==0 goto endtie
	tigoto dcydone; tied note, no decay

	if gidcylen==0 kgoto dcydone
	kdcyfn	oscil1i	iatkperiod, idcylvl, idcyperiod, gidcytbl
	kdcyfn = kdcyfn+idecayampl
	kdcy1	linseg	0, iatkperiod, 0, 0, 1, idcyperiod-idcyoff, 1, idcyoff, 0
	kdcy = kdcyfn*kdcy1

	dcydone:
	if itie==1 goto tie
	ksus	linseg	0, isuszerodur, 0, 0, idecayampl, isusdur-isusoff, isustainto, isusoff, 0
	goto endtie

	tie:
	ksus	linseg	isusinitlvl, isusdur, isusendlvl, 0, 0

	endtie:
	krel	oscil1i	irlsdly, irlslvl, irlsdur, gidcltbl
	krel1 linseg	0, irlsdly-irlsdlyoff, 0, irlsoff, 1, irlsdur-irlsoff, 1, 0, 0
	krel = krel*krel1
	kdcyaenv = kdcy+ksus+krel
	kenv = katkaenv+kdcyaenv	; final amplitude envelope
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

#define nblockcode
#
;	$blnoise
;	$blnoise
;	$blnoise
;	$blnoise
;	$blnoise
;	$blnoise
;	$blnoise
;	$blnoise
;	$blnoise
;	$blnoise
#

#define allpcode
#
	$pblockcode
;	$pblockcode
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
#define allscode
#
	$sblockcode
	$sblockcode
	$sblockcode
	$sblockcode
	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
;	$sblockcode
#

#define allncode
#
;	$nblockcode
;	$nblockcode
;	$nblockcode
;	$nblockcode
;	$nblockcode
;	$nblockcode
;	$nblockcode
;	$nblockcode
;	$nblockcode
;	$nblockcode
#


; instrument definitions

instr 1
	; <<< meta-instrument >>>
 	gisgenfn  = $sin_hires	; in case it has been reset, e.g. acoustic bass
	iport = 0	; portamento duration - calculated  at note time but may be
				; forced by value in wavetable instrument sections below with
				; giport = duration
	giinum = p4

	; instrument type defs
	if giinum == 0 igoto inum129	; default instrument

	; instrument 33 defaults (acoustic bass)
	inum33:
	if giinum > 33 igoto inum34
	; Note the sound is achieved by overriding the default gisgenfn (sine)
	; assumes default AD envelope (giusrdclphs = 0)
	gisgenfn = 33	; single complex wavetable defining ac bass
	gioscs = 1	;  2	; twobob timbral preference...
	gimass = 0.000001
	giuatkscl = 0.5	; we're already getting far too many zeroes...
	gires = 0.5
	giatktbl = $expi	; override default
	gidcltbl = $expd	; override default
	igoto instrSetupDone

	inum34:
	if giinum > 34 igoto inum41
	igoto instrSetupDone

	; instrument 41 defaults (viola.pizz.sulA)
	inum41:
	if giinum > 41 igoto inum43
	giphpplf = 10	; maximum value: number of ftable-prescribed harmonics
	giphfflf = 10	; in note extreme cases. If less further harmonics are
	giphpphf = 10	; synthesised rather than being table-derived
	giphffhf = 10
	gioscs = 30	; max oscs used
	gitblbase = 400	; start of cello data fn tables (0=no tables)
	gihmagtblbase = 480	; start of harmonic magnitude data (if present)
	; Viola.pizz.sulA data
	giminvol = 500		; data min and max ranges (from original sound)
	gimaxvol = 12000
	giminfrq = 440		; A4: nominal frequencies of note range (csound book)
	gimaxfrq = 1567.982; G6
	; these set the envelope by reference to the original samples
	gipplft = 0.003		; pplf A4 table atk dur (fraction of note dur.)
	gipphft = 0.002	; pphf G6
	gifflft = 0.002		; fflf A4
	giffhft = 0.001		; ffhf G6
	girlspplft = 0.84	; pp A3 release start (fraction of note dur.)
	girlspphft = 0.89
	girlsfflft = 0.84
	girlsffhft = 0.96
	; end Viola.pizz.sulA data
	igoto instrSetupDone

	; instrument 43 defaults (Cello-arco-reference-1st)
	inum43:
	if giinum > 43 igoto inum44
	girandtbltype = 1	; must return positive for this instrument
	iafno ftgen $noisedefs, 0, 261, -23, "data/Cello-arco-reference-1st/Cello.noisedefs"	; noise defs file
	gihasnoise = 0
	gimass = 10
	gires = 1
	giusrdclphs = 1
	giduradj = 1
	gisuslvl = 1.8
	gigain = 0.2
	giatkdelay = 0.9
	gidcladvance = 0.5
	gidcltbl = $expd	; override default
;giatktbl = $unity
;gisustbl = $unity
;gidcltbl = $unity
	gihaspt = 0		; default (control) range [0.2]
	gihpgain = 0.05
	giphmagscl = 0.5
	giphpplf = 10	; maximum value: number of ftable-prescribed harmonics
	giphfflf = 10	; in note extreme cases. If less further harmonics are
	giphpphf = 10	; synthesised rather than being table-derived
	giphffhf = 10
	gioscs = 50	; max oscs used
;gitblbase = 0	;	; uncomment to use only s-harmonics
	gitblbase = 500	; start of cello data fn tables (0=no tables)
;gihmagtblbase = 0		; uncomment if s-harmonics should not use p-h magnitudes
	gihmagtblbase = 580	; start of harmonic magnitude data (if present)
	; Cello-arco-reference-1st data
	giminvol = 1700		; data min and max ranges (from original sound)
	gimaxvol = 3400
	giminfrq = 65.406	; C2: nominal frequencies of note range (csound book)
	gimaxfrq = 783.991	; G5
	; these set the envelope by reference to the original samples
	gipplft = 0.19		; pplf C2 table atk dur (fraction of note dur.)
	gipphft = 0.19		; pphf G5
	gifflft = 0.29		; fflf C2
	giffhft = 0.19		; ffhf G5
	girlspplft = 0.41	; pp C2 release start (fraction of note dur.)
	girlspphft = 0.36
	girlsfflft = 0.59
	girlsffhft = 0.44
	; end Cello-arco-reference-1st data
	; terrain table numbers follow the last hmag table (here, 583)
giUseAllH1a = 1
giUseAllH2a = 1
giTerrainMode1a = 0
gitbl1axOF = 584	; define orbit/path from
;;gitbl1ayOF = 585	; parameter files in data/<instr>
gitbl2axOF = 588	; or from those in data/default if not specified here
gitbl2ayOF = 589
	igoto instrSetupDone

	inum44:
	if giinum > 44 igoto inum72
	igoto instrSetupDone

	; instrument 72 defaults (Bb clarinet )
	inum72:
	if giinum > 72 igoto inum73
	gitblbase = 600	; start of cello data fn tables (0=no tables)
	gihmagtblbase = 720	; start of harmonic magnitude data (if present)
	giphpplf = 15	; maximum value: number of ftable-prescribed harmonics
	giphfflf = 15	; in note extreme cases. If less further harmonics are
	giphpphf = 15	; synthesised rather than being table-derived
	giphffhf = 15
	gioscs = 30	; max oscs used
	; Bb Clarinet data
	giminvol = 400		; data min and max ranges (from original sound)
	gimaxvol = 6000
	giminfrq = 146.832		; D3: nominal frequencies of note range (csound book)
	gimaxfrq = 1567.982	; G6
	; these set the envelope by reference to the original samples
	gipplft = 0.32		; pplf D3 table atk dur (fraction of note dur.)
	gipphft = 0.06		; pphf G6
	gifflft = 0.10		; fflf D3
	giffhft = 0.05		; ffhf G6
	girlspplft = 0.86	; pp D3 release start (fraction of note dur.)
	girlspphft = 0.92
	girlsfflft = 0.89
	girlsffhft = 0.94
	; end Bb Clarinet data
	igoto instrSetupDone

	; instrument 73 defaults (Alto flute)
	inum73:
	if giinum > 73 igoto inum129
	gigain = 0.3
	gimass = 250
	giusrdclphs = 1
	gitblbase = 740	; start of cello data fn tables (0=no tables)
	gihmagtblbase = 820	; start of harmonic magnitude data (if present)
	giphpplf = 10	; maximum value: number of ftable-prescribed harmonics
	giphfflf = 10	; in note extreme cases. If less further harmonics are
	giphpphf = 10	; synthesised rather than being table-derived
	giphffhf = 10
	gioscs = 30	; max oscs used
	; Alto flute data
	giminvol = 650		; data min and max ranges (from original sound)
	gimaxvol = 18000
	giminfrq = 220	; A3: nominal frequencies of note range (csound book)
	gimaxfrq = 1396.913	; F6
	; these set the envelope by reference to the original samples
	gipplft = 0.13		; pplf A3 table atk dur (fraction of note dur.)
	gipphft = 0.14		; pphf G5
	gifflft = 0.17		; fflf A3
	giffhft = 0.04		; ffhf F6
	girlspplft = 0.84	; pp A3 release start (fraction of note dur.)
	girlspphft = 0.89
	girlsfflft = 0.84
	girlsffhft = 0.96
	; end Alto flute data
	igoto instrSetupDone

	; instrument 129 defaults (pure synthetic)
	inum129:
	if giinum > 129 igoto inum130
	gigain = 0.2
	giusrdclphs = 1
	giatktbl = $unity
	gisustbl = $unity
	gidcltbl = $unity
	gisuslvl = 2
	gitbl1axOF = 1000	; t-based decline
	gitbl1ayOF = 1001	; f-based decline
;	; these are for the 2Tone test files in data/default
;	giterrainFn1a = 1
;	giterrainFn2a = 0
;	giTerrainMode1a = 0
;	giTerrainMode2a = 1
	igoto instrSetupDone
	
	; first user-definable instr (unimplemented)
	inum130:
	if giinum > 130 igoto inum143
	igoto instrSetupDone

	; alternate cello based on UIOWA Cello.arco.sulC samples
	inum143:
	if giinum > 143 igoto instrSetupDone
	gioscs = 15
	gimass = 15
	gires = 3
	giusrdclphs = 1
	giduradj = 1
	gisuslvl = 1
	gigain = 0.2
	giphpplf = 15	; maximum value: number of ftable-prescribed harmonics
	giphfflf = 15	; in note extreme cases. If less further harmonics are
	giphpphf = 15	; synthesised rather than being table-derived
	giphffhf = 15
	gitblbase = 840;	start of cello data fn tables (0=no tables)
	gihmagtblbase = 960	; start of harmonic magnitude data (if present)
	; Cello.arco.sulC data
	giminvol = 1500		; data min and max ranges (from original sound)
	gimaxvol = 3500
	giminfrq = 65.406	; C2: nominal frequencies of note range (csound book)
	gimaxfrq = 783.991	; D5
	; these set the envelope by reference to the original samples
	gipplft = 0.19		; pplf C2 table atk dur (fraction of note dur.)
	gipphft = 0.21		; pphf G5
	gifflft = 0.15		; fflf C2
	giffhft = 0.09		; ffhf G5
	girlspplft = 0.4	; pp C2 release start (fraction of note dur.)
	girlspphft = 0.33
	girlsfflft = 0.58
	girlsffhft = 0.47
	; end Cello.arco.sulC data
	igoto instrSetupDone

	instrSetupDone:
	; portamento duration (unused if i2->p6 == 0)	; CHECK THIS #########
	; warning - could go out of control at extremes; tables need tuning
	; we can force port time with iport in i1 instrument definitions above
	giport = (iport>0 ? iport : log10((gimass/gires)+$minTFuncVal))
; <<< end instr 1, 'meta-instrument' >>>
endin


; sort this out to use -1 to set zero so 0 preserves existing value
instr 2
; <<< meta-expression >>>
	; p1 instr num
	; p2 start
	; p3 dur
	giportramp = (p4==0 ? giportramp : p4)	; table number ; override instr1 default
	; portamento ramp fn defaults to current definition (initially linear incr.)
	giportscl = (p5==0 ? giportscl : p5)		; portamento duration scale factor
	giportscl = (p5<0 ? abs(p3) : giportscl)
	gitrmffn = (p6==0? gitrmffn : p6)	; tremolo frequency table
	givibafn = (p7==0? givibafn : p7)	; vibrato amplitude table, default unity
	givibphs = abs(p8)				; should default to 0.25=cos
	givibdly = p9					; allow delay to init at decay phase instead of attack
	gisuslvl = (p10==0 ? gisuslvl : abs(p10)); sustain level
; <<< end instr 2, 'meta-expression' >>>
endin


instr 3
; <<< expression >>>
	; p1 instr num
	; p2 start
	; p3 dur
	if p3==0 igoto noexprenv
	giportpch = (p6>0 ? cpspch(p6) 		: giportpch)
	if p5 == 0 goto noexprenv			; avoid k-rate changes to globals if no
										; expression envelope; keep last table
	giexpramp = p4						; level to change to over duration
	kampenv	linseg	giinitexpramp, p3, giexpramp
	gkexprenv	oscili	kampenv, 1/p3, p5	; p5 fn tbl no.
	gkexprenv = gkexprenv+1				; base gain unity
	giinitexpramp = giexpramp
	noexprenv:
; <<< end instr 3, 'expression' >>>
endin


instr 4
; <<< note expression >>>
	; p1 instr num
	; p2 start
	; p3 dur
	giuatkscl = (p4==0 ? giuatkscl : p4)
	giudclscl = (p5==0 ? giudclscl : p5)
	giforcenoiseampenv = (p6==0 ? giforcenoiseampenv : p6)
	giforcenoiseampenv = (p6==-1 ? 0 : giforcenoiseampenv)
	giduradj = (p7==0 ? giduradj : p7)	; true/false but zero preserves
	giduradj = (p7==-1 ? 0: giduradj)	; previous setting
; <<< end instr 4 'note expression' >>>
endin


instr 8
;check envelope export!
; <<< vibrato >>>
	; p1 instr num
	; p2 start
	; p3 dur
	p3 = (p3==0 ? $mindur : p3)	; ?
	ivibalvl = p4/$maxvol	; vibrato amplitude
	givibfrq = p5
	ivibamps = p6
	ivibampe = p7
	givibffn = (p8==0? $sin : p8)	; default sine
	givibdly = p9
	kampenv	linseg	ivibamps, p3-$mindur, ivibampe, $mindur, 0
	gkvibaenv	oscili	kampenv*ivibalvl, 1/p3, givibafn
; <<< end instrument 8, 'vibrato' >>>
endin


instr 9
; check envelope export!
; <<< tremolo >>>
	; p1 instr num
	; p2 start
	; p3 dur
	; trm amp fn default unity
	p3 = (p3==0 ? $mindur : p3)
	itrmalvl = p4/$maxvol
	; frequency p5 is FIXED and overrides calculated mass, res. and
	; freq-related default
	gitrmfrq = p5	; if zero, auto-calculated freq is used; >0 fixed freq.
					; if <0, then abs(gitrmfrq+1)*auto-calculated-value is used
	itrmamps = p6	; override default i1 setting (off)
	itrmampe = p7
	itrmafn = (p8==0? $unity : p8)	; default const. amp env
	gitrmdly = p9	; flag, 1= post-attack onset

	kampenv	linseg	itrmamps, p3-$mindur, itrmampe, $mindur, 0
	gktrmaenv	oscili	kampenv*itrmalvl, 1/p3, itrmafn
endin


instr 15
; <<< partials >>>
	; p1 instr 13
	; p2 start
	; p3 dur
	; p4 is tristate : 0 = no partials, 1 = single partial equidistant from
	; adjacent harmonics, 2 = two partials at 1/3 and 2/3 inter-harmonic
	; distance
	gihaspt = (p4==0 ? gihaspt : p4)
;	gihp1modscl = (p7==0 ? gihp1modscl : p7)
;	gihp2modscl = (p8==0 ? gihp2modscl : p8)
; <<< end instr 13, 'partials' >>>
endin


instr 19
; <<< player competence >>>
	; p1	instr 19
	; p2	start
	; p3	dur
	; p4 amplitude competence
	icompetence = (p4==0 ? 1-giadeviance : p4)
	icompetence = (icompetence>1 ? 1 : icompetence)
	icompetence = (icompetence<0 ? 0.00001 : icompetence)	; avoid total incompetence
	giadeviance = 1-icompetence
	; p5 pitch competence
	icompetence = (p5==0 ? 1-gifdeviance : p5)
	icompetence = (icompetence>1 ? 1 : icompetence)
	icompetence = (icompetence<0 ? 0.00001 : icompetence)
	gifdeviance = 1-icompetence
	; p6 temporal competence
	icompetence = (p6==0 ? 1-gitdeviance : p6)
	icompetence = (icompetence>1 ? 1 : icompetence)
	icompetence = (icompetence<0 ? 0.00001 : icompetence)
; warning gitdeviance>0.5 may cause note initialisation errors
	gitdeviance = 1-icompetence
	giadevrate = (p7==0 ? giadevrate : p7)
	giadevrate = (giadevrate==-1 ? 0 : giadevrate)
	gifdevrate = (p8==0 ? gifdevrate : p8)
	gifdevrate = (gifdevrate==-1 ? 0 : gifdevrate)
	giaseed = (p9==0 ? giaseed : p9)
	giaseed = (giaseed==-1 ? 0 : giaseed)
	gifseed = (p10==0 ? gifseed : p10)
	gifseed = (gifseed==-1 ? 0 : gifseed)
; <<< end instr 19, 'player competence' >>>
endin


; reverb instrument included so as to have facility
; to inject some life into otherwise dry (anechoically recorded) sounds.
instr 99
; <<< simple reverb >>>
	; p1 instr num
	; p2 start
	; p3 dur
	irevtime = p4
	girvbrtn = p6
	areverb	reverb	garvbsig, irevtime
	out areverb*girvbrtn
	garvbsig = 0
; <<< end instr 99, 'simple reverb' >>>
endin


instr 90
; <<< virtual instrument >>>
	; ##### NOTE INITIALISATION #####
	insuslvl = (gihasnoise==0 ? 0 : ginsuslvl)
	itie tival                                              ; true if tied  (p3<0)
	iheld = (p3<0 ? 1 : 0)                  ; true if note is held
	
	iseed   random  0, 1 ; this needs seeing to...
;	inotephase = (itie==1 ? -1 : iseed)     ; preserve phase between tied notes
	inotephase = (itie==1 ? -1 : 0 )    ; preserve phase between tied notes
	inotedur = abs(p3)
	inotevol = p4
	inotefrq = (gisntype==0? cpspch(p5) : p5)
	ip5 = p5

	; the input amp and frq might be external not score-supplied
	if $oldRS == 0 igoto noexchange
	inotefrq = cpspch(p4)
	inotevol = p5
	inotevol ampmidid inotevol, $oldRSdbBaseLevel	; allow for velocity specification
	p5 = p4
	p4 = inotevol

	noexchange:
	inotefrq = (inotefrq>$maxfrq ? $maxfrq : inotefrq)
	iampi = dbamp(inotevol)      ; amplitude index (1-$maxai approx)
	iocti = octpch(ip5)*10       ; frequency index (0-$maxfi approx)
; if we have a flag we can use raw tables , diovisors 1, flag is norm in table access
	iampi = iampi/$maxai
	iocti = iocti/$maxfi

	iampix = (inotevol-giminvol)/(gimaxvol-giminvol)
	iampix = (iampix<0 ? 0 : iampix)
	iampix = (iampix>1 ? 1 : iampix)
	ifrqix = (inotefrq-giminfrq)/(gimaxfrq-giminfrq)
	ifrqix = (ifrqix<0 ? 0 : ifrqix)
	ifrqix = (ifrqix>1 ? 1 : ifrqix)
	iinvampix = 1-iampix
	iinvfrqix = 1-ifrqix

	 ; f = ma so
	iaccel = (inotevol+1)/gimass	; should never be zero! min accel is 1/mass
	iatkdurscl = 1/log10(iaccel)	; as accel rises atk period shortens
	idcldurscl = iatkdurscl*gires*((1+iampix)/2)

	iampa   tablei  iampi, giampatkf, 1
	iampd   tablei  iampi, giampdcyf, 1
	iocta   tablei  iocti, gifrqatkf, 1
	ioctd   tablei  iocti, gifrqdcyf, 1

	; composite amp/frq index
	iafix = sqrt((((iampa+iocta)/2)^2)+(((iampd+ioctd)/2)^2))/sqrt(2)

; some basic note information
print
print inotevol, inotefrq, inotedur
print itie, iheld
print iampix, ifrqix, iafix

	ihrno	ftgen	$random, 0, $tblsize, 21, girandtbltype	; rand table - unique for each call
	girandctl = (girandctl>ftlen($random) ? 0 : girandctl)
	; for 3D fn stack control see genInstr-retired/Misc/attic/genInstr-10 et.al.
	; now in docs/function-stack-implementation

	iharmonics = int($nyquistfrq/inotefrq)-1	; max. harmonics above f0 in audio range at this freq.
	; avoid bw-limiting the top harmonic
	inoscs = ($nyquistfrq-(iharmonics*inotefrq)<inotefrq*1.5 ? iharmonics-1 : iharmonics)

	; required to get correct AD proportions for envelope timing
	; these are the instr. specified fractions of note dur
	ipplft = (girlspplft-gipplft)+gipplft
	ipphft = (girlspphft-gipphft)+gipphft
	ifflft = (girlsfflft-gifflft)+gifflft
	iffhft = (girlsffhft-giffhft)+giffhft

	; we require the case for the particular note
	ippADt = (ipphft-ipplft)*iampix+ipplft
	iffADt = (iffhft-ifflft)*iampix+ifflft
	inoteADt = (iffADt-ippADt)*ifrqix+ippADt

	; frq diffs in tables might not be for frequencies generated
	inotefv = iocti*ginotefscl+ginotefoff
	ifrqscale	tablei	inotefv, gifsclfn, 1
	inoscs = (inoscs>gioscs ? gioscs : inoscs)

	; these need to be the number of available p-harmonics
	ilfoscs = (giphfflf-giphpplf)*iampi+giphpplf
	ihfoscs = (giphffhf-giphpphf)*iampi+giphpphf
	iamposcs = (ihfoscs-ilfoscs)*iampi+ilfoscs

	ipposcs = (giphpphf-giphpplf)*iocti+giphpplf
	iffoscs = (giphffhf-giphfflf)*iocti+giphfflf
	ifrqoscs = (iffoscs-ipposcs)*iocti+ipposcs
	; inposcs is an estimate of the ftable hamonics to be accessed for a note
	inposcs = sqrt(iamposcs^2+ifrqoscs^2)/sqrt(2)
	inposcs = int(inposcs+0.5)
	inposcs = (inposcs>inoscs ? inoscs : inposcs)
	inposcs = (gitblbase==0 ? 0 : inposcs)

	itrmfrq = (gitrmfrq==0 ? iafix*log10((gimass/gires)+$minTFuncVal) : gitrmfrq)	; auto-calculated tremolo rate, Hz
	; ##### END NOTE INITIALISATION #####

	$ampEnvTiming
	$setAmpEnvLevels
	$ampEnvShape

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
	ktenv	oscili	gktrmaenv, itrmfrq, gitrmffn, inotephase	; tremolo
	; tremolo magnitude independent of expression amplitude
	; note delay is a kludge since it overwrite the running oscillator
	ktrmenv2 = 1		; apply vibrato from attack phase unless reset below
	if gitrmdly == 0 || itie == 1 kgoto endtrmdly
	ktrmenv2	linseg	0, gitrmdly*ieattackap, 0, $mindur, 1	; delay onset of tremolo

	endtrmdly:
	ktenv = ktenv*ktrmenv2*kenv

	; deviance decreases as amplitude and frequency increase
	; (loud and higher pitched notes are rendered with less uncertainty)
	iadevrate = giadevrate*iafix
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
	;			idur - note duration - maximum duration
	;			inotefrq - current note pitch value (Hz)
	;			inotephase
	;			iocti - octave index for portamento factor table
	;			iprevfreq - pitch prior to the current pitch value (Hz)
	;			itie - tied note flag
	; supply:	kpramp (note with portamento, vibrato)

	; fdevrate falls with rising amp and frq
	ifdevrate = gifdevrate/iafix	; rate decreases as amp and frq increase
	ifseed	table	girandctl, $random
	ifseed = frac(abs(ifseed)*gifseed)
	kfdev	randi	gifdeviance, ifdevrate, ifseed

	; portamento
	; infer port table base from relation between pitch and prev pitch
	if itie == 0 || giportpch == 0 goto noport
	; note: i90.p5 == i3.p6 stops first-note portamento, as does i3.p6 == 0
	iprevfreq = giportpch
	iportix = (giporttbl==$porttbl ? iocti*$maxfi : ifrqix)	; default tbale is raw index
	; remember to use the right table for the index type!
	; if not the default table we must specify it
	; but then iocti returns 0 at note low frq
	; unless we deliberately restrict the range by scl and off of ifrqix and iocti
	iport	tablei	iportix, giporttbl	;	index by freq into port. factor table
	; giport is base portamento dur defaulted in i1
	iport = giport*iport	; giport only used when portamento is on (i3.p6 > 0)
 	; frequency-compensated port. dur.
	iport = (giportscl==0 ? iport : giportscl*iport)	; scale base port. duration
	iport = (iport>idur ? idur : iport)	; limit port dur to max. available

	kpramp	oscili	1, 1/iport, giportramp
	kpramp2	linseg	1, iport, 1, $minperiod, 0, idur-iport, 0	; we don't have p- or s- here
	kpramp = kpramp*kpramp2
	kpramp3	linseg	0, iport, 0, $minperiod, 1, idur-iport, 1, 0, 0
	kpramp = kpramp+kpramp3
	ifreqrange = inotefrq-iprevfreq

	kpramp = kpramp*ifreqrange	; ramp from to freq diff.and add to
	kpramp = kpramp+iprevfreq	; base note freq to get to current freq
	kgoto endport
		
	noport:
	giportpch = 0		; turn off portamento at end of tied notes
	kpramp	linseg	inotefrq, idur, inotefrq	; constant pitch

	endport:
	; vibrato
	ivibphs = (inotephase==0 ? givibphs : givibphs*inotephase)
	; produce a vibrato freq scaled from 0 to 1
	kvibfrq1	oscili	1, givibfrq, givibffn, ivibphs
	kvibfrq1 = (kvibfrq1+1)/2			; make +ve, range [0,1]
	kvibenv2 = 1		; apply vibrato from attack phase unless reset below

	if givibdly == 0 || itie == 1 kgoto endvibdly
	; this is post-attack onset
	kvibenv2	linseg	0, iaeattack, 0, $mindur, 1	; delay onset of vibrato	
	
	endvibdly:
	iviboscamp = (givibfrq==0 ? 0 : 1)	; reject dc as unwanted const. freq offset
	kvibenv = kvibfrq1*kvibenv2*iviboscamp*gkvibaenv
	kpramp = kpramp*(1+kvibenv)	; adjust pitch for vibrato (multiplicative)
	; ##### END FREQUENCY MODULATION #####

	; ##### TERRAIN #####
	; amp terrains
	$initTerrain(1'a)
	$initTerrain(2'a)
	$initTerrain(3'a)
	; we have to initialise these for all terrains even if unused
	; k-rate, must be separate from i-rate initTerrain
	$initLayerEnvPhase(1'a)
	$initLayerEnvPhase(2'a)
	$initLayerEnvPhase(3'a)
	; frq terrain
	$initTerrain(1'f)
	$initLayerEnvPhase(1'f)
	; ##### END TERRAIN #####

	;##### SOUND SYNTHESIS #####
	; if we have a single wavetable, gioscs is 1 and iharmonics (number available
	; within audio range) is irrelevant - harmonic sructure is encoded in the 
	; wavetable (e.g. ac bass)

	; base adresses of case harmonic data tables
	ipplfhtbl = gitblbase			; skip freq. tables
	ipphfhtbl = ipplfhtbl+2*giphpplf	; base address of next case extreme set
	ifflfhtbl = ipphfhtbl+2*giphpphf
	iffhfhtbl = ifflfhtbl+2*giphfflf
	idcyratio = 0

	if iusrphsdur==0 goto nodcyratio
	idcyratio = iaepdecay/iusrphsdur

	nodcyratio:
	idcypplft = (girlspplft-gipplft)*idcyratio+gipplft
	idcypphft = (girlspphft-gipphft)*idcyratio+gipphft
	idcyfflft = (girlsfflft-gifflft)*idcyratio+gifflft
	idcyffhft = (girlsffhft-giffhft)*idcyratio+giffhft

	; the indices reference the p harmonic data tables (if they exist)
	if giusrdclphs==1 kgoto usrdclix
	; p-harmonics have decline-sub-phases table-encoded,
	; use default AD env timing unless overridden

	; just use p-h attack and release data
	k1ix	linseg	0, iaepattack, gipplft, $minperiod, girlspplft, iaeprelease, 1, 0, 0
	k2ix	linseg	0, iaepattack, gipphft, $minperiod, girlspphft, iaeprelease, 1, 0, 0
	k3ix	linseg	0, iaepattack, gifflft, $minperiod, girlsfflft, iaeprelease, 1, 0, 0
	k4ix	linseg	0, iaepattack, giffhft, $minperiod, girlsffhft, iaeprelease, 1, 0, 0
	kgoto endnoteix

	usrdclix:
	k1ix	linseg	0,  iaepattack, gipplft, iaepdecay, idcypplft, iaepsustain, girlspplft, iaeprelease, 1
	k2ix	linseg	0, iaepattack, gipphft, iaepdecay, idcypphft, iaepsustain, girlspphft, iaeprelease, 1
	k3ix	linseg	0, iaepattack, gifflft, iaepdecay, idcyfflft, iaepsustain, girlsfflft, iaeprelease, 1
	k4ix	linseg	0, iaepattack, giffhft, iaepdecay, idcyffhft, iaepsustain, girlsffhft, iaeprelease, 1

	endnoteix:
	; harmonic magnitude table numbers fot the case extremes
	ihgtbl1 = (gihmagtblbase>0 ? gihmagtblbase : $unity)	; pp lf peak magnitude table
	ihgtbl2 = (gihmagtblbase>0 ? gihmagtblbase+1 : $unity)
	ihgtbl3 = (gihmagtblbase>0 ? gihmagtblbase+2 : $unity)
	ihgtbl4 = (gihmagtblbase>0 ? gihmagtblbase+3 : $unity)

	; we need the final entries for magnitude of s harmonics if there are also p h's
	iphpplfmag table giphpplf-1, ihgtbl1	; last entry in instr hmag data tables
	iphpphfmag table giphpphf-1, ihgtbl2
	iphfflfmag table giphfflf-1, ihgtbl3
	iphffhfmag table giphffhf-1, ihgtbl4

	; calculate magnitude of final p harmonics for limiting cases
	; and obtain specific note magnitude for this
	iphlfmag = (iphfflfmag-iphpplfmag)*iampi+iphpplfmag
	iphhfmag = (iphffhfmag -iphpphfmag)*iampi+iphpphfmag
	iphmag = (iphhfmag-iphlfmag)*iocti+iphlfmag
	; needs a scalar, default last p-harmonic level might be unsuitable
	iphmag = iphmag*giphmagscl

	; ##### INHARMONIC PARTIALS #####
	; either 1 or 2 allowed
	ihp = (gihaspt==0 ? 0 : 1)
	ihp = (gihaspt==1 ? 0.5 : ihp)
	ihpgain = (gihaspt==0 ? 0 : ihp*gihpgain)
	ipratio = (ihp==0.5 ? 0.5 : 1/3)	; 1 or 2 partials
	ihp1off = (gihaspt==0 ? 0 : ipratio)
	ihp2off = (gihaspt==0 ? 0 :1-ipratio)
	kp1fincr = kpramp*ihp1off
	kp2fincr = kpramp*ihp2off
	; ##### END INHARMONIC PARTIALS #####

	; synthesis
	kz = 1
	ktrk = 0
	aoscp = 0
	aoscs = 0
	aoscpt = 0	 	 	 	 

	$allpcode
	phdone:		; return from oscs described by ftables (p-harmonics)

	$allscode
	shdone:		; return from synthesised harmonics (s-harmonics)
	; ##### END SOUND SYNTHESIS #####

	; ##### NOISE #####
	if gihasnoise == 0 goto noisedone
	; initialisation - applies to p- and s- harmonics
	inscl1 = iafix*ginscl1*giunscl1
	inscl2 = iafix*ginscl2*giunscl2
	inscl3 = iafix*ginscl3*giunscl3

	inbetafn1 = $unity
	inbetafn2 = $unity
	inbetafn3 = $unity

	anoise0 = 0
	inratio = (gihaspt==1 ? 0.5 : 1/3)   ; 1 or 2 potential partial noise bands - s/b 'ihp'
	inratio = (gihaspt==0 ? 1 : inratio)

	anout = 0
	indefsix = 0
	inoises	table	indefsix, $noisedefs	; table containing noise setup
	if inoises<=0 kgoto noisedone
	indefsix = 1
	; noise1
	$readNoiseParams(1'indefsix'p)

	; noise type 1 parameters
	if intype1 != 1 igoto non1t1
	$initBetaNoise(1'indefsix)

	non1t1:
	invol1	table	indefsix, $noisedefs
	inprocs1	table	indefsix+1, $noisedefs	; number of processes to apply to this noise
	indefsix = indefsix+2
	$naenv(inatkt1'indclt1'inatktbl1'indcltbl1'inpersistent1)
	knbeta	oscili	inbetaterm1-inbetainit1, 1/indur1, inbetafn1
	knbeta = knbeta+inbetainit1
	$noise(intype1'invol1)	; returns anoise

	if inprocs1==0 goto inprocend1	; no processes for this noise

	; process noise - pass 1 of 3
	inproc11	table	indefsix, $noisedefs	; noise1 process type
	if inproc11!=1 goto inproc121
	$pchfixnoise(1'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc121:
	if inproc11!=2 goto inproc131
	$flangednoise(1'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc131:
	if inproc11!=3 goto inprocterm11
	$bandlimitednoise(1'indefsix)

	if gihasnoise==1 kgoto blnoisedone11;	 note -noise flag reflects partials!
	if inblcf1==0 igoto blnoisedone11
	$makeblnoise

	blnoisedone11:
	anoise = anoise0
	inprocs1 = inprocs1-1

	inprocterm11:
	if inprocs1==0 goto inprocend1

	; process noise - pass 2 of 3
	inproc12	table	indefsix, $noisedefs
	if inproc12!=1 goto inproc122
	$pchfixnoise(1'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc122:
	if inproc12!=2 goto inproc132
	$flangednoise(1'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc132:
	if inproc12!=3 goto inprocterm12
	$bandlimitednoise(1'indefsix)

	if gihasnoise==1 kgoto blnoisedone12
	if inblcf1==0 igoto blnoisedone12
	$makeblnoise
	
	blnoisedone12:
	anoise = anoise0
	inprocs1 = inprocs1-1

	inprocterm12:
	if inprocs1==0 goto inprocend1

	; process noise - pass 3 of 3
	inproc13	table	indefsix, $noisedefs
	if inproc13!=1 goto inproc123
	$pchfixnoise(1'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc123:
	if inproc13!=2 goto inproc133
	$flangednoise(1'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc133:
	if inproc13!=3 goto inprocend1
	$bandlimitednoise(1'indefsix)

	if gihasnoise==1 kgoto blnoisedone13
	if inblcf1==0 igoto blnoisedone13
	$makeblnoise

	blnoisedone13:
	anoise = anoise0
	inprocs1 = inprocs1-1

	inprocend1:
	; noise needs to be scaled here, default unity gain; iafix-related (?)
	anout = anout+(anoise*inscl1)
	inoises = inoises-1
	if inoises<=0 goto noisedone

	; noise2
	$readNoiseParams(2'indefsix'p)

	; noise type 2 parameters
	if intype2 != 1 igoto non2t1
	$initBetaNoise(2'indefsix)

	non2t1:
	invol2	table	indefsix, $noisedefs
	inprocs2	table	indefsix+1, $noisedefs	; number of processes to apply to this noise
	indefsix = indefsix+2
	$naenv(inatkt2'indclt2'inatktbl2'indcltbl2'inpersistent2)
	knbeta	oscili	inbetaterm2-inbetainit2, 1/indur2, inbetafn2
	knbeta = knbeta+inbetainit2
	$noise(intype2'invol2)	; returns anoise
	if inprocs2==0 goto inprocend2	; no processes for this noise

	; process noise - pass 1 of 3
	inproc21	table	indefsix, $noisedefs	; number of process for noise2
	if inproc21!=1 goto inproc221
	$pchfixnoise(2'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc221:
	if inproc21!=2 goto inproc231
	$flangednoise(2'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc231:
	if inproc21!=3 goto inprocterm21
	$bandlimitednoise(2'indefsix)

	if gihasnoise==1 kgoto blnoisedone21;	 note -noise flag reflects partials!
	if inblcf2==0 igoto blnoisedone21
	$makeblnoise

	blnoisedone21:
	anoise = anoise0
	inprocs2 = inprocs2-1

	inprocterm21:
	if inprocs2==0 goto inprocend2

	; process noise - pass 2 of 3
	inproc22	table	indefsix, $noisedefs
	if inproc22!=1 goto inproc222
	$pchfixnoise(2'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc222:
	if inproc22!=2 goto inproc232
	$flangednoise(2'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc232:
	if inproc22!=3 goto inprocterm22
	$bandlimitednoise(2'indefsix)

	if gihasnoise==1 kgoto blnoisedone22
	if inblcf2==0 igoto blnoisedone22
	$makeblnoise
	
	blnoisedone22:
	anoise = anoise0
	inprocs2 = inprocs2-1

	inprocterm22:
	if inprocs2==0 goto inprocend2

	; process noise - pass 3 of 3
	inproc23	table	indefsix, $noisedefs
	if inproc23!=1 goto inproc223
	$pchfixnoise(2'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc223:
	if inproc23!=2 goto inproc233
	$flangednoise(2'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc233:
	if inproc23!=3 goto inprocend2
	$bandlimitednoise(2'indefsix)

	if gihasnoise==1 kgoto blnoisedone23
	if inblcf2==0 igoto blnoisedone23
	$makeblnoise

	blnoisedone23:
	anoise = anoise0
	inprocs2 = inprocs2-1

	inprocend2:
	anout = anout+(anoise*inscl2)
	inoises = inoises-1
	if inoises<=0 goto noisedone
	
	; noise3
	$readNoiseParams(3'indefsix'p)

	; noise type 3 parameters
	if intype3 != 1 igoto non3t1
	$initBetaNoise(3'indefsix)

	non3t1:
	invol3	table	indefsix, $noisedefs
	inprocs3	table	indefsix+1, $noisedefs
	indefsix = indefsix+2
	$naenv(inatkt3'indclt3'inatktbl3'indcltbl3'inpersistent3)
	knbeta	oscili	inbetaterm3-inbetainit3, 1/indur3, inbetafn3
	knbeta = knbeta+inbetainit3
	$noise(intype3'invol3)	; returns anoise
	if inprocs3==0 goto inprocend3

	; process noise - pass 1 of 3
	inproc31	table	indefsix, $noisedefs	; number of process for noise3
	if inproc31!=1 goto inproc321
	$pchfixnoise(3'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc321:
	if inproc31!=2 goto inproc331
	$flangednoise(3'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc331:
	if inproc31!=3 goto inprocterm31
	$bandlimitednoise(3'indefsix)

	if gihasnoise==1 kgoto blnoisedone31;	 note -noise flag reflects partials!
	if inblcf3==0 igoto blnoisedone31
	$makeblnoise

	blnoisedone31:
	anoise = anoise0
	inprocs3 = inprocs3-1
	inprocterm31:
	if inprocs3==0 goto inprocend3

	; process noise - pass 2 of 3
	inproc32	table	indefsix, $noisedefs
	if inproc32!=1 goto inproc322
	$pchfixnoise(3'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc322:
	if inproc32!=2 goto inproc332
	$flangednoise(3'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc332:
	if inproc32!=3 goto inprocterm32
	$bandlimitednoise(3'indefsix)

	if gihasnoise==1 kgoto blnoisedone32
	if inblcf3==0 igoto blnoisedone32
	$makeblnoise
	
	blnoisedone32:
	anoise = anoise0
	inprocs3 = inprocs3-1

	inprocterm32:
	if inprocs3==0 goto inprocend3

	; process noise - pass 3 of 3
	inproc33	table	indefsix, $noisedefs
	if inproc33!=1 goto inproc323
	$pchfixnoise(3'indefsix'cf'bwinit'bwterm'bwfn'skip)

	inproc323:
	if inproc33!=2 goto inproc333
	$flangednoise(3'indefsix'rinit'rterm'rfn'maxdly'flangefn)

	inproc333:
	if inproc33!=3 goto inprocend3
	$bandlimitednoise(3'indefsix)

	if gihasnoise==1 kgoto blnoisedone33
	if inblcf3==0 igoto blnoisedone33
	$makeblnoise

	blnoisedone33:
	anoise = anoise0
	inprocs3 = inprocs3-1

	inprocend3:
	anout = anout+(anoise*inscl3)

	noisedone:
	; ##### END NOISE #####

;	asig = (giforcenoiseampenv==0 ? aoscp+kenv*(aoscs+aoscpt)+anout : aoscp+kenv*(aoscs+aoscpt+anout))
asig = (giforcenoiseampenv==0 ? aoscp+kenv*aoscs+anout : aoscp+kenv*(aoscs+anout))
	; add amplitude deviance
	asig = asig*(1+kadev)
	; apply tremolo envelope
	asig = asig*(1+ktenv)
	; apply expression envelope
	asig = asig*gkexprenv				; CHECK!
	; adjust gain level
	asig = asig*gigain
	; apply reverb
	garvbsig = asig
	out asig*(1-girvbrtn)
	girandctl = girandctl+1
; <<< end instr 90, 'instrument' >>>
endin
