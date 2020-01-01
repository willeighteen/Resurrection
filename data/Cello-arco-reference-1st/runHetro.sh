#!/bin/bash

harmonics=10
lfpoints=32
hfpoints=16

# pplf:
hetro -f65.406 -h$harmonics -m0 -n$lfpoints notes/arco-ppC2.wav arco-ppC2.het

# pphf:
hetro -f783.991 -h$harmonics -m0 -n$hfpoints notes/arco-ppG5.wav arco-ppG5.het

# fflf:
hetro -f65.406 -h$harmonics -m0 -n$lfpoints notes/arco-ffC2.wav arco-ffC2.het

# ffhf:
hetro -f783.991 -h$harmonics -m0 -n$hfpoints notes/arco-ffG5.wav arco-ffG5.het

unset hfpoints
unset lfpoints
unset harmonics
