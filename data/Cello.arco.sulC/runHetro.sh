#!/bin/bash

harmonics=10
lfpoints=128
hfpoints=64

# pplf:
hetro -f65.406 -h$harmonics -m0 -n$lfpoints notes/Cello.arco.pp.sulC.C2.wav ppC2.het

# pphf:
hetro -f146.83 -h$harmonics -m0 -n$hfpoints notes/Cello.arco.pp.sulC.D5.wav ppD5.het

# fflf:
hetro -f65.406 -h$harmonics -m0 -n$lfpoints notes/Cello.arco.ff.sulC.C2.wav ffC2.het

# ffhf:
hetro -f175 -h$harmonics -m0 -n$hfpoints notes/Cello.arco.ff.sulC.B3.wav ffB3.het

unset hfpoints
unset lfpoints
unset harmonics

