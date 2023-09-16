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
| [formal](https://github.com/npatsiatzis/fifo_synchronous/tree/main/formal) | Formal Verification using  PSL properties and [YoysHQ/sby](https://github.com/YosysHQ/oss-cad-suite-build) |


This is the tree view of the strcture of the repo.
<pre>
<font size = "2">
.
├── <font size = "4"><b><a href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/rtl">rtl</a></b> </font>
│   ├── <font size = "4"><a href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/rtl/SystemVerilog">SystemVerilog</a> </font>
│   │   └── SV files
│   └── <font size = "4"><a href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/rtl/VHDL">VHDL</a> </font>
│       └── VHD files
├── <font size = "4"><b><a href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/cocotb_sim">cocotb_sim</a></b></font>
│   ├── Makefile
│   └── python files
├── <font size = "4"><b><a 
 href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/pyuvm_sim">pyuvm_sim</a></b></font>
│   ├── Makefile
│   └── python files
├── <font size = "4"><b><a href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/uvm_sim">uvm_sim</a></b></font>
│   └── .zip file
├── <font size = "4"><b><a href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/verilator_sim">verilator_sim</a></b></font>
│   ├── Makefile
│   └── verilator tb
├── <font size = "4"><b><a href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/mcy_sim">mcy_sim</a></b></font>
│   ├── Makefile, (modified) SV files, Verilator tb
│   └── scripts
└── <font size = "4"><b><a href="https://github.com/npatsiatzis/fifo_synchronous/tree/main/formal">formal</a></b></font>
    ├── Makefile
    └── PSL properties file, scripts
</pre>