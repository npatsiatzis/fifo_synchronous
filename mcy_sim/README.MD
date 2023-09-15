### synchronous FIFO RTL implementation


- used to communicate data between 2 synchronous clock domains
- configurable FIFO depth and width
- logic for generating empty/full, overflow/underflow falgs


-- MCY is a tool to help understand and improve TESTBENCH coverage.
-- Mutation coverage further enhances the confidence instilled in our test from line,toggle,functional coverage.
-- Mutation coverage is applied here on the verilator tb, but can be tailored to any functional testing methodology.
-- MCY works with (System)Verilog RTL files. Hence you either need to have your source RTL in that language or use Yosys GHDL pluggin to convert VHDL source to Verilog. In such case run :

- $ bash gen_verilog.sh. In such a case, the port names (and internal signal names if used) need to be modified either of the generated file(s) or in the simulation, as they are usually modified by yosys.

-- When you have obtained your RTL files then : 
- (activate the oss-cad-suite environment)
- $ mcy purge
- $ mcy init
- $ mcy run (-j$nPROCS)

