#!/bin/bash

## Modify the following paths appropriately
PARSEC_PATH=/home/sotiris/Documents/advarch/parsec-3.0
PIN_EXE=/home/sotiris/Documents/advarch/pin-3.7-97619-g0d0c92f4f-gcc-linux/pin
PIN_TOOL=/home/sotiris/Documents/advarch/code/pintool/obj-intel64/simulator.so

CMDS_FILE=./cmds_simlarge.txt
outDir="/home/sotiris/Documents/advarch/parsec-3.0/parsec_workspace/outputs/"

export LD_LIBRARY_PATH=$PARSEC_PATH/pkgs/libs/hooks/inst/amd64-linux.gcc-serial/lib/

## Triples of <cache_size>_<associativity>_<block_size>
CONFS="8_4 16_4 32_4 64_1 64_2 64_4 64_8 64_16 64_32 64_64 128_4 256_4"

L1size=32
L1assoc=8
L1bsize=64

L2size=1024
L2assoc=8
L2bsize=128

TLBp=4096
TLBe=64
TLBa=4

L2prf=0


for BENCH in $@; do
	cmd=$(cat ${CMDS_FILE} | grep "$BENCH")
    outFile=$(printf "%s.dcache_cslab.temporal.out" $BENCH)
	outFile="$outDir/$outFile"

	pin_cmd="$PIN_EXE -t $PIN_TOOL -o $outFile -L1c ${L1size} -L1a ${L1assoc} -L1b ${L1bsize} -L2c ${L2size} -L2a ${L2assoc} -L2b ${L2bsize} -TLBe ${TLBe} -TLBp ${TLBp} -TLBa ${TLBa} -L2prf ${L2prf} -- $cmd"
	time $pin_cmd
done

