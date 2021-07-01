#!/bin/bash

harmonics=10
lfpoints=128
hfpoints=64

# pplf:
hetro -f440 -h$harmonics -m0 -n$lfpoints notes/Viola.pizz.pp.sulA.A4.wav ppA4.het

# pphf:
hetro -f1567.982 -h$harmonics -m0 -n$hfpoints notes/Viola.pizz.pp.sulA.G6.wav ppG6.het

# fflf:
hetro -f440 -h$harmonics -m0 -n$lfpoints notes/Viola.pizz.ff.sulA.A4.wav ffA4.het

# ffhf:
hetro -f1567.982 -h$harmonics -m0 -n$hfpoints notes/Viola.pizz.ff.sulA.G6.wav ffG6.het

unset hfpoints
unset lfpoints
unset harmonics
