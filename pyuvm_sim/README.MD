![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/regression_pyuvm.yml/badge.svg)
![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/coverage_pyuvm.yml/badge.svg)

### synchronous FIFO RTL implementation


- used to communicate data between 2 synchronous clock domains
- configurable FIFO depth and width
- logic for generating empty/full, overflow/underflow falgs
- run pyuvm testbench
    - $ make
- run unit testing of the pyuvm testbench
    - $  SIM=ghdl pytest -n auto -o log_cli=True --junitxml=test-results.xml --cocotbxml=test-cocotb.xml


