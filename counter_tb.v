`timescale 1ns/1ps

module counter_tb;

    reg clk;
    reg reset;
    wire [3:0] count;

    // Notre FPGA
    counter dut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    // Horloge : période de 10 ns
    always #5 clk = ~clk;

    initial begin

        // Enregistrer les signaux pour Surfer
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

        // État initial
        clk   = 0;
        reset = 1;

        // Maintenir le reset pendant 20 ns
        #20;

        // Libérer le compteur
        reset = 0;

        // Laisser tourner pendant 160 ns
        #160;

        $finish;
    end

endmodule
