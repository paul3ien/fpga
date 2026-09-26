`timescale 1ns/1ps

module blinking_tb;

    reg clk;
    reg reset;
    wire  light;

    blinking dut (
        .clk(clk),
        .reset(reset),
        .light(light)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("blinking_light.vcd");
        $dumpvars(0, blinking_tb);

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
