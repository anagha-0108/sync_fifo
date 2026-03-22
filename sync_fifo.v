// sync_fifo.v
module sync_fifo #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             wr_n,
    input  wire             rd_n,
    input  wire [WIDTH-1:0] data_in,
    output reg  [WIDTH-1:0] data_out,
    output wire             full,
    output wire             empty,
    output reg              overflow,
    output reg              underflow
);

    localparam PTR_SIZE   = $clog2(DEPTH);
    localparam COUNT_SIZE = PTR_SIZE + 1;

    reg [WIDTH-1:0]      fifo_mem   [0:DEPTH-1];
    reg [PTR_SIZE-1:0]   wr_ptr;
    reg [PTR_SIZE-1:0]   rd_ptr;
    reg [COUNT_SIZE-1:0] fifo_count;

    assign full  = (fifo_count == DEPTH);
    assign empty = (fifo_count == 0);

    // BLOCK 1 — WRITE
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            overflow <= 1'b0;
        else
            begin
                if(!wr_n && !full)
                    begin
                        fifo_mem[wr_ptr] <= data_in;
                        overflow         <= 1'b0;
                    end
                else if(!wr_n && full)
                    begin
                        overflow <= 1'b1;
                        $display("WRITE ERROR: FIFO FULL");
                    end
                else
                    overflow <= 1'b0;
            end
    end

    // BLOCK 2 — READ
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                data_out  <= {WIDTH{1'b0}};
                underflow <= 1'b0;
            end
        else
            begin
                if(!rd_n && !empty)
                    begin
                        data_out  <= fifo_mem[rd_ptr];
                        underflow <= 1'b0;
                    end
                else if(!rd_n && empty)
                    begin
                        underflow <= 1'b1;
                        $display("READ ERROR: FIFO EMPTY");
                    end
                else
                    underflow <= 1'b0;
            end
    end

    // BLOCK 3 — POINTERS
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                wr_ptr <= {PTR_SIZE{1'b0}};
                rd_ptr <= {PTR_SIZE{1'b0}};
            end
        else
            begin
                if(!wr_n && !full)
                    begin
                        if(wr_ptr == DEPTH-1)
                            wr_ptr <= {PTR_SIZE{1'b0}};
                        else
                            wr_ptr <= wr_ptr + 1;
                    end

                if(!rd_n && !empty)
                    begin
                        if(rd_ptr == DEPTH-1)
                            rd_ptr <= {PTR_SIZE{1'b0}};
                        else
                            rd_ptr <= rd_ptr + 1;
                    end
            end
    end

    // BLOCK 4 — COUNT
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            fifo_count <= {COUNT_SIZE{1'b0}};
        else
            begin
                if(!wr_n && !full && (rd_n || empty))
                    fifo_count <= fifo_count + 1;
                else if(!rd_n && !empty && (wr_n || full))
                    fifo_count <= fifo_count - 1;
            end
    end

endmodule

