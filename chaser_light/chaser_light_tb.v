`timescale 1ns/1ps

module chaser_light_tb;

    reg clk;
    reg reset;
    wire[3:0] light;

    chaser_light #(
            .CLK_FREQ_HZ(100_000_000),
            .CLOCK_DIVIDER(10_000_000)
    ) dut (
        .clk(clk),
        .reset(reset),
        .light(light)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("chaser_light.vcd");
        $dumpvars(0, chaser_light_tb);

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
