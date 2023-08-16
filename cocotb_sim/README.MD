![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/regression.yml/badge.svg)
![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/coverage.yml/badge.svg)

### simple two input adder RTL implementation

- used to communicate data between 2 synchronous clock domains
- configurable FIFO depth and width
- logic for generating empty/full, overflow/underflow falgs

-- CoCoTB testbench for functional verification
    - $ make
- Coverage-driven test generation
- Achieve full point coverage for inputs, outputs and cross coverage
- CoCoTB-test unit testing to exercise the CoCoTB tests across a range of values for the generic parameters
    - $  SIM=ghdl pytest -n auto -o log_cli=True --junitxml=test-results.xml --cocotbxml=test-cocotb.xml

