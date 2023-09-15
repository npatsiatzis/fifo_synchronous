#!/bin/bash

exec 2>&1
set -ex

## create the mutated design
bash $SCRIPTS/create_mutated.sh
ln ../../Makefile .
ln ../../tb_mutated.cpp . 

## run the testbench with the mutated module substituted for the original
make clean
make > sim.out 2>&1 || true

if grep -q "Test Failure" sim.out; then
	echo "1 FAIL" > output.txt
else
	if grep -q "Error" sim.out; then
		echo "1 FAIL" > output.txt
	else	
		echo "1 PASS" > output.txt
	fi
fi

exit 0
