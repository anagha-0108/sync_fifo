# Synchronous FIFO
## Description
Parameterized Synchronous FIFO implemented in Verilog with SystemVerilog 
testbench and SVA assertions.
## Specifications
- Depth : 16 (configurable) - Width : 8 bits (configurable) - Single clock 
domain - Active low reset
## Files
| File | Description | ------|-------------| sync_fifo.v | Parameterized RTL 
| design | tb_sync_fifo.sv | SystemVerilog testbench | fifo_sva.sv | SVA 
| assertion module |
## Features
- Parameterized depth and width - Combinational full/empty flags - Overflow 
and underflow detection - Pointer wrap around - SVA assertions for formal 
verification
## Test Cases
- Reset verification - Write 16 locations - Overflow detection - Read 16 
locations - Underflow detection - Write then read - Simultaneous read and 
write
## SVA Assertions
- RESET: flags clear after reset - OVERFLOW: overflow when write to full fifo 
- UNDERFLOW: underflow when read from empty fifo - FULL: full flag correct - 
EMPTY: empty flag correct - NO_OVERFLOW: no overflow when not full - 
NO_UNDERFLOW: no underflow when not empty - FULL_RESET: full=0 after reset - 
EMPTY_RESET: empty=1 after reset - FULL_EMPTY: full and empty never high 
together
## Simulation
- Tool: Synopsys VCS - Language: Verilog + SystemVerilog
