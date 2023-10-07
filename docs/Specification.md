## Requirements Specification


### 1. SCOPE

1. **Scope**

   This document establishes the requirements for an Intellectual Property (IP) that provides a synchronous FIFO function.
1. **Purpose**
 
   These requirements shall apply to a synchronous FIFO core with a simple interface for inclusion as a component.
1. **Classification**
    
   This document defines the requirements for a hardware design.


### 2. DEFINITIONS

1. **Push**

   The action of inserting data into the FIFO.
2. **Pop**
   
   The axtion of extracting data from the FIFO.
3. **Empty** 
   The FIFO buffer with no valid data.

1. **Full**

   The FIFO buffer being at its maximum level.
1. **Read and Write pointers**

   Pointers represent the internal structure of the FIFO to identify where the data will be stored or be read.


### 3. APPLICABLE DOCUMENTS 

1. **Government Documents**

   None
1. **Non-government Documents**

   None


### 4. ARCHITECTURAL OVERVIEW

1. **Introduction**

   The synchronous FIFO component shall represent a design written in an HDL (VHDL and/or SystemVerilog) that can easily be incorporateed into a larger design. The FIFO shall be synchronous with a single clock that governs both reads and writes. This synchronous FIFO shall include the following features : 
     1. Parameterized word width, and FIFO depth.
     1. synchronous FIFO push/pop operation.
     1. Flags to indicate FIFO overflow and underflow.
     1. Synchronous active-high reset.

   The CPU interface in this case is the standard FIFO interface.

1. **System Application**
   
    The synchronous FIFO can be applied to a variety of system configurations. An example use is the FIFO being used to resolve differences in processing capabilities between a producer and a consumer operating on the same clock.

### 5. PHYSICAL LAYER

 1. i_data, word to insert to FIFO
 6. o_data, word extracted from FIFO
 7. wr, FIFO write request
 8. rd, FIFO read request
 9. full, flag indicating FIFO is full
 1. empty, flag indicating FIFO is empty with valid data
 1. overflow, flag indicating overflow condition
 1. underflow, flag indicating underflow condition
 7. clk, system clock
 8. rst, system reset, synchronous active high

### 6. PROTOCOL LAYER

The FIFO operates on single word writes or single word reads 

### 7. ROBUSTNESS

The FIFO shall indicated overflow and underflow conditions.

### 8. HARDWARE AND SOFTWARE

1. **Parameterization**

   The synchronous FIFO shall provide for the following parameters used for the definition of the implemented hardware during hardware build:

   | Param. Name | Description |
   | :------: | :------: |
   | width | width of data words |
   | depth | number of bits to express FIFO depth |

1. **CPU interface**

   The CPU shall request the write of data in the FIFO issuing a write request (wr active) and the extractiong of data from the FIFO with a read request (rd active).


### 9. PERFORMANCE

1. **Frequency**
1. **Power Dissipation**
1. **Environmental**
 
   Does not apply.
1. **Technology**

   The design shall be adaptable to any technology because the design shall be portable and defined in an HDL.

### 10. TESTABILITY
None required.

### 11. MECHANICAL
Does not apply.
