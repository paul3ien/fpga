`timescale 1ns/1ps

module blinking_tb;

    reg clk;
    reg reset;
    wire  light;

    blinking #(
            .CLK_FREQ_HZ(100_000_000),
            .CLOCK_DIVIDER(10_000_000)
    ) dut (
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
    initial begin
            $monitor(
                "t=%0t | reset=%b | state=%b | next=%b | timer=%d | light=%b",
                $time,
                reset,
                dut.state,
                dut.next_state,
                dut.timer,
                light
            );
    end

endmodule
