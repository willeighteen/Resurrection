#!/bin/bash

harmonics=10
lfpoints=128
hfpoints=64

# pplf:
hetro -f220 -h$harmonics -m0 -n$lfpoints notes/AltoFlute.pp.A3.wav ppA3.het

# pphf:
hetro -f783.991 -h$harmonics -m0 -n$hfpoints notes/AltoFlute.pp.G5.wav ppG5.het

# fflf:
hetro -f220 -h$harmonics -m0 -n$lfpoints notes/AltoFlute.ff.A3.wav ffA3.het

# ffhf:
hetro -f1396.913 -h$harmonics -m0 -n$hfpoints notes/AltoFlute.ff.F6.wav ffF6.het

unset hfpoints
unset lfpoints
unset harmonics
