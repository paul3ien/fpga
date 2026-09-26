`timescale 1ns/1ps

module pwm_tb;

    reg clk;
    reg reset;
    reg[3:0] duty_cycle;
    wire[3:0] signal;
    wire[3:0] count;

    pwm #(
            .CLK_FREQ_HZ(100_000_000),
            .CLOCK_DIVIDER(10_000_000)
    ) dut (
        .clk(clk),
        .reset(reset),
        .duty_cycle(duty_cycle),
        .signal(signal),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("pwm.vcd");
        $dumpvars(0, pwm_tb);

        clk   = 0;
        reset = 1;
        duty_cycle = 4'd5;

        // Maintenir le reset pendant 20 ns
        #20;


        // Libérer le compteur
        reset = 0;

        // Laisser tourner pendant 160 ns
        #160;

        duty_cycle = 4'd12;

        #160;

        $finish;
    end

endmodule
