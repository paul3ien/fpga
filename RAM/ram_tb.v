`timescale 1ns/1ps

module ram_tb;

    reg clk = 0;
    reg we = 0;
    reg [3:0] addr = 0;
    reg [7:0] data_in = 0;
    wire [7:0] data_out;

    always #5 clk = ~clk; // Période = 10ns

    ram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(4)
    ) dut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("ram_tb.vcd");
        $dumpvars(0, ram_tb);

        // --- Écriture : write(10, 42) ---
        @(posedge clk);
        addr    <= 4'd10;
        data_in <= 8'd42;
        we      <= 1'b1;

        // --- Désactivation de l'écriture ---
        @(posedge clk);
        we      <= 1'b0;

        // --- Lecture : read(10) ---
        // L'adresse est toujours 10, la donnée sort au cycle suivant
        @(posedge clk);
        $display("Lecture Adresse %d -> Valeur: %d (Attendu: 42)", addr, data_out);

        #20;
        $finish;
    end

    endmodule
