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

### Repo Structure

This is a short tabular description of the contents of each folder in the repo.

| Folder | Description |
| ------ | ------ |
| [rtl/SystemVerilog](https://github.com/npatsiatzis/fifo_synchronous/tree/main/rtl/SystemVerilog) | SV RTL implementation files |
| [rtl/VHDL](https://github.com/npatsiatzis/fifo_synchronous/tree/main/rtl/VHDL) | VHDL RTL implementation files |
| [cocotb_sim](https://github.com/npatsiatzis/fifo_synchronous/tree/main/cocotb_sim) | Functional Verification with CoCoTB (Python-based) |
| [pyuvm_sim](https://github.com/npatsiatzis/fifo_synchronous/tree/main/pyuvm_sim) | Functional Verification with pyUVM (Python impl. of UVM standard) |
| [uvm_sim](https://github.com/npatsiatzis/fifo_synchronous/tree/main/uvm_sim) | Functional Verification with UVM (SV impl. of UVM standard) |
| [verilator_sim](https://github.com/npatsiatzis/fifo_synchronous/tree/main/verilator_sim) | Functional Verification with Verilator (C++ based) |
| [mcy_sim](https://github.com/npatsiatzis/fifo_synchronous/tree/main/mcy_sim) | Mutation Coverage Testing of Verilator tb, using  [YoysHQ/mcy](https://github.com/YosysHQ/oss-cad-suite-build)|

