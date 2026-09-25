`timescale 1ns/1ps

module FSM_tb;

    reg clk;
    reg reset;
    wire GREEN;
    wire ORANGE;
    wire RED;

    FSM dut (
        .clk(clk),
        .reset(reset),
        .GREEN(GREEN),
        .ORANGE(ORANGE),
        .RED(RED)
    );

    // Horloge : période de 10 ns
    always #5 clk = ~clk;

    initial begin

        // Enregistrer les signaux pour Surfer
        $dumpfile("FSM.vcd");
        $dumpvars(0, FSM_tb);

        // État initial
        clk   = 0;
        reset = 1;

        // Maintenir le reset pendant 20 ns
        #20;

        // Libérer le compteur
        reset = 0;

        $monitor("t=%0t reset=%b state=%b counter=%d G=%b O=%b R=%b",
                 $time,
                 reset,
                 dut.state,
                 dut.counter,
                 GREEN,
                 ORANGE,
                 RED);

        // Laisser tourner pendant 160 ns
        #160;

        $display("Simulation terminée à t=%0t", $time);

        $finish;
    end

endmodule
