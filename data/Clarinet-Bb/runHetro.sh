#!/bin/bash

harmonics=15
lfpoints=128
hfpoints=64

# pplf:
hetro -f146.832 -h$harmonics -m0 -n$lfpoints notes/BbClar.pp.D3.wav ppD3.het

# pphf:
hetro -f1567.982 -h$harmonics -m0 -n$hfpoints notes/BbClar.pp.G6.wav ppG6.het

# fflf:
hetro -f146.832 -h$harmonics -m0 -n$lfpoints notes/BbClar.ff.D3.wav ffD3.het

# ffhf:
hetro -f1567.982 -h$harmonics -m0 -n$hfpoints notes/BbClar.ff.G6.wav ffG6.het

unset hfpoints
unset lfpoints
unset harmonics
