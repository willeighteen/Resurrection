sr		=	44100
kr		=	44100
ksmps	=	1
nchnls	=	1


instr 1
iamod = p4
ifmod = p5
ismod = p6
asig	adsyn	iamod, ifmod, ismod, "cello128.het"
out asig
endin
