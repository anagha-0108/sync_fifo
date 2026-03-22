// tb_sync_fifo.sv
module tb_sync_fifo;

    // DECLARATIONS
    reg        clk;
    reg        rst_n;
    reg        wr_n;
    reg        rd_n;
    reg  [7:0] data_in;
    wire [7:0] data_out;
    wire       full;
    wire       empty;
    wire       overflow;
    wire       underflow;

    // DUT INSTANTIATION
    sync_fifo #(
        .DEPTH(16),
        .WIDTH(8)
    ) DUT (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_n     (wr_n),
        .rd_n     (rd_n),
        .data_in  (data_in),
        .data_out (data_out),
        .full     (full),
        .empty    (empty),
        .overflow (overflow),
        .underflow(underflow)
    );

    // BIND SVA
     bind DUT fifo_sva sva_inst(
         .clk      (clk),
         .rst_n    (rst_n),
         .wr_n     (wr_n),
         .rd_n     (rd_n),
         .full     (full),
         .empty    (empty),
         .overflow (overflow),
         .underflow(underflow)
     );
    // uncomment when SVA file is ready

    // CLOCK
    always
        begin
            #5 clk = 1'b0;
            #5 clk = 1'b1;
        end

    // TASK 1 — RESET
    task reset_fifo;
        begin
            rst_n   <= 1'b0;
            data_in <= $random;    // random during reset
            wr_n    <= 1'b1;
            rd_n    <= 1'b1;
            repeat(3) @(negedge clk);
            rst_n   <= 1'b1;
            @(negedge clk);
        end
    endtask

    // TASK 2 — WRITE READ
    // wr=0 rd=1 → write only
    // wr=1 rd=0 → read  only
    // wr=0 rd=0 → simultaneous
    task wr_rd(input [7:0] wr_data,
               input       wr,
               input       rd);
        begin
            data_in = wr_data;
            wr_n    = wr;
            rd_n    = rd;

            if(!wr_n)
                $display("FIFO WRITE: Data = %0d", data_in);

            @(posedge clk);
            @(negedge clk);

            if(!rd_n && !underflow)
                $display("FIFO READ:  Data = %0d", data_out);
        end
    endtask

    // STIMULUS
    initial
        begin : STIM
            integer i;

            // STEP 1: RESET
            $display("\n===== RESET =====");
            reset_fifo;

            // STEP 2: WRITE 16 LOCATIONS
            $display("\n===== WRITING 16 VALUES =====");
            for(i=1; i<=16; i=i+1)
                wr_rd(i, 1'b0, 1'b1);

            // STEP 3: WRITE WHEN FULL
            $display("\n===== WRITE WHEN FULL =====");
            wr_rd(8'd99, 1'b0, 1'b1);
            wr_rd(8'd99, 1'b0, 1'b1);

            // STEP 4: READ ALL 16
            $display("\n===== READING 16 VALUES =====");
            repeat(16)
                wr_rd(8'd0, 1'b1, 1'b0);

            // STEP 5: READ WHEN EMPTY
            $display("\n===== READ WHEN EMPTY =====");
            wr_rd(8'd0, 1'b1, 1'b0);
            wr_rd(8'd0, 1'b1, 1'b0);

            // STEP 6: WRITE THEN READ
            $display("\n===== WRITE THEN READ =====");
            wr_rd(8'd25, 1'b0, 1'b1);
            wr_rd(8'd50, 1'b0, 1'b1);
            wr_rd(8'd0,  1'b1, 1'b0);
            wr_rd(8'd0,  1'b1, 1'b0);

            // STEP 7: SIMULTANEOUS
            $display("\n===== SIMULTANEOUS READ AND WRITE =====");
            wr_rd(8'd55, 1'b0, 1'b1);   // pre-fill
            wr_rd(8'd77, 1'b0, 1'b0);   // simultaneous

            // STEP 8: FINAL STATUS
            $display("\n===== FINAL STATUS =====");
            $display("full=%b empty=%b overflow=%b underflow=%b",
                      full, empty, overflow, underflow);

            #20;
            $finish;
        end


    // MONITOR
    initial
        $monitor("TIME=%0t full=%b empty=%b overflow=%b underflow=%b",
                  $time, full, empty, overflow, underflow);

endmodule
