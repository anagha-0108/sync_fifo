module fifo_sva( input logic clk,
	input logic rst_n, 
	input logic wr_n, 
	input logic rd_n, 
	input logic full, 
	input logic empty, 
	input logic overflow, 
    	input logic underflow
	);

    //═══════════════════════════════════════ RESET when reset → next cycle 
    // overflow and underflow must be 0
    //═══════════════════════════════════════
    property reset_prty; @(posedge clk) (!rst_n) |=> (!overflow && 
        !underflow);
    endproperty
    //═══════════════════════════════════════ OVERFLOW when full AND write 
    // only next cycle overflow must go high
    //═══════════════════════════════════════
    property overflow_prty; @(posedge clk) disable iff(!rst_n) (full && !wr_n 
        && rd_n) |=> overflow;
    endproperty
    //═══════════════════════════════════════ UNDERFLOW when empty AND read 
    // only next cycle underflow must go high
    //═══════════════════════════════════════
    property underflow_prty; @(posedge clk) disable iff(!rst_n) (empty && 
        !rd_n && wr_n) |=> underflow;
    endproperty
    //═══════════════════════════════════════ FULL FLAG when overflow 
    // happens full must already be high same cycle
    //═══════════════════════════════════════
    property full_prty; @(posedge clk) disable iff(!rst_n) overflow |-> full; 
    endproperty
    //═══════════════════════════════════════ EMPTY FLAG when underflow 
    // happens empty must already be high same cycle
    //═══════════════════════════════════════
    property empty_prty; @(posedge clk) disable iff(!rst_n) underflow |-> 
        empty;
    endproperty
    //═══════════════════════════════════════ NO OVERFLOW WHEN NOT FULL if 
    // fifo not full next cycle overflow must be 0
    //═══════════════════════════════════════
    property no_overflow_prty; @(posedge clk) disable iff(!rst_n) (!full && 
        !wr_n) |=> (!overflow);
    endproperty
    //═══════════════════════════════════════ NO UNDERFLOW WHEN NOT EMPTY 
    // if fifo not empty next cycle underflow must be 0
    //═══════════════════════════════════════
    property no_underflow_prty; @(posedge clk) disable iff(!rst_n) (!empty && 
        !rd_n) |=> (!underflow);
    endproperty
    //═══════════════════════════════════════ FULL AFTER RESET full must be 
    // 0 after reset
    //═══════════════════════════════════════
    property full_reset_prty; @(posedge clk) (!rst_n) |=> (!full); 
    endproperty
    //═══════════════════════════════════════ EMPTY AFTER RESET empty must 
    // be 1 after reset
    //═══════════════════════════════════════
    property empty_reset_prty; @(posedge clk) (!rst_n) |=> (empty); 
    endproperty
    //═══════════════════════════════════════ FULL AND EMPTY NEVER SAME 
    // TIME full and empty cannot both be 1
    //═══════════════════════════════════════
    property full_empty_prty; @(posedge clk) disable iff(!rst_n) !(full && 
        empty);
    endproperty
    //═══════════════════════════════════════ ASSERT INSTANCES 
    //═══════════════════════════════════════
    RESET : assert property (reset_prty);
    OVERFLOW : assert property  (overflow_prty);
    UNDERFLOW : assert property (underflow_prty);
    FULL : assert property (full_prty); 
    EMPTY : assert property (empty_prty); 
    NO_OVERFLOW : assert property (no_overflow_prty); 
    NO_UNDERFLOW : assert property (no_underflow_prty); 
    FULL_RESET : assert property (full_reset_prty); 
    EMPTY_RESET : assert property (empty_reset_prty); 
    FULL_EMPTY : assert property (full_empty_prty);
endmodule
