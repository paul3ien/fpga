`timescale 1ns/1ps

module fifo_tb;

    reg clk = 0;
    reg reset = 0;
    reg [7:0] data_in = 0;
    reg wr_en = 0;
    reg rd_en = 0;
    wire [7:0] data_out;
    wire full;
    wire empty;

    always #5 clk = ~clk; // Période = 10ns

    fifo #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(2)
    ) dut (
        .clk(clk),
        .reset(reset),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty),
        .full(full)
    );

    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);

        // Reset initial
        reset = 1;
        #20;
        reset = 0;
        #10;



        // --- 1. Écriture des données : 'A', 'B', 'C', 'D' ---
        $display("[\%0t] début écriture : A, B, C, D", $time);

        write_byte("A");
        write_byte("B");
        write_byte("C");
        write_byte("D");

        // À ce stade, la FIFO doit être PLEINE (`full == 1`)
        @(posedge clk);
        $display("[%0t] FIFO Pleine ? %b (Attendu: 1)", $time, full);

        // --- 2. Lecture des données ---
        $display("[%0t] début lecture...", $time);

        read_byte();
        read_byte();
        read_byte();
        read_byte();

        // À ce stade, la FIFO doit être VIDE (`empty == 1`)
        @(posedge clk);
        $display("[%0t] FIFO Vide ? %b (Attendu: 1)", $time, empty);

        #30;
        $finish;
    end

    // Tâche d'écriture d'un octet
    task write_byte(input [7:0] val);
        begin
            @(posedge clk);
            wr_en   <= 1'b1;
            data_in <= val;
            @(posedge clk);
            wr_en   <= 1'b0;
        end
    endtask

    // Tâche de lecture d'un octet
    task read_byte();
        begin
            @(posedge clk);
            rd_en <= 1'b1;
            @(posedge clk);
            rd_en <= 1'b0;
            $display("[%0t] Donnée lue = %c (0x%h)", $time, data_out, data_out);
        end
    endtask
endmodule
