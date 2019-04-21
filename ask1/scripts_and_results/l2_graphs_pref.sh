#!/bin/bash

benches="blackscholes bodytrack canneal  facesim ferret fluidanimate freqmine rtview streamcluster swaptions"

for bench in $benches;do
    /home/sotiris/Documents/advarch/code/plot_l2_pref.sh "$bench"  $(ls | grep "$bench")
done