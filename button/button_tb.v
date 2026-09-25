`timescale 1ns/1ps

module button_tb;

    reg clk;
    reg reset;
    wire [3:0] count;
    reg button;

    // Notre FPGA
    button dut (
        .clk(clk),
        .reset(reset),
        .count(count),
        .button(button)

    );

    // Horloge : période de 10 ns
    always #5 clk = ~clk;

    initial begin

        // Enregistrer les signaux pour Surfer
        $dumpfile("button.vcd");
        $dumpvars(0, button_tb);

        // État initial
        clk   = 0;
        reset = 1;

        #100;
        button = 1;
        #2;
        button = 0;
        #2;
        button = 1;
        #3;
        button = 0;
        #2;
        button = 1;

        // Maintenant il reste vraiment appuyé
        #50;
        button = 0;

        // Libérer le compteur
        reset = 0;

        // Laisser tourner pendant 160 ns
        #160;

        $finish;
    end

endmodule
