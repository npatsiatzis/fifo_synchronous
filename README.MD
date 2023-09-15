![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/regression.yml/badge.svg)
![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/coverage.yml/badge.svg)
![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/formal.yml/badge.svg)
![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/regression_pyuvm.yml/badge.svg)
![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/coverage_pyuvm.yml/badge.svg)
![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/verilator_regression.yml/badge.svg)
[![codecov](https://codecov.io/gh/npatsiatzis/fifo_synchronous/graph/badge.svg?token=443SHHMU5H)](https://codecov.io/gh/npatsiatzis/fifo_synchronous)

### synchronous FIFO RTL implementation


- used to communicate data between 2 synchronous clock domains
- configurable FIFO depth and width
- logic for generating empty/full, overflow/underflow falgs

-- RTL code in:
- [VHDL](https://github.com/npatsiatzis/fifo_synchronous/tree/main/rtl/VHDL)
- [SystemVerilog](https://github.com/npatsiatzis/fifo_synchronous/tree/main/rtl/SystemVerilog)

-- Functional verification with methodologies:
- [cocotb](https://github.com/npatsiatzis/fifo_synchronous/tree/main/cocotb_sim)
- [pyuvm](https://github.com/npatsiatzis/fifo_synchronous/tree/main/pyuvm_sim)
- [UVM](https://github.com/npatsiatzis/fifo_synchronous/tree/main/uvm_sim)
- [verilator](https://github.com/npatsiatzis/fifo_synchronous/tree/main/verilator_sim)
- [mcy](https://github.com/npatsiatzis/fifo_synchronous/tree/main/mcy_sim)


