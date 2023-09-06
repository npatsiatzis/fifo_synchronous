![example workflow](https://github.com/npatsiatzis/fifo_synchronous/actions/workflows/verilator_regression.yml/badge.svg)

### synchronous FIFO RTL implementation

- used to communicate data between 2 synchronous clock domains
- configurable FIFO depth and width
- logic for generating empty/full, overflow/underflow falgs

-- Verilator tb for functional verification, adapted from the work of Norbet Kremeris (https://www.itsembedded.com/dhd/verilator_4/). Added coverage class for the input and output interfaces,sequence class, coverage-based end-of-test condition and coverage-driven test generation
    - $ make sim
- Achieve full point coverage for output
- open waveform with gtkwave
    - $ make waves
- lint test
    - $make lint
