#!/bin/bash

yosys -m ghdl -p 'ghdl --std=08 synchronous_fifo.vhd -e synchronous_fifo; write_verilog synchronous_fifo.v'