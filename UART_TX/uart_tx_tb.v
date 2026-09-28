`timescale 1ns/1ps

module uart_tx_tb;

    reg clk;
    reg reset;
    wire tx_line;

    top_send_string dut (
            .clk(clk),
            .reset(reset),
            .tx_line(tx_line)
    );

    // Horloge : période de 10 ns
    always #5 clk = ~clk;

    initial begin

        // Enregistrer les signaux pour Surfer
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        // État initial
        clk   = 0;
        reset = 1;

        // Maintenir le reset pendant 20 ns
        #100;

        // Libérer le compteur
        reset = 0;

        // Laisser tourner pour chaque lettre
        #1200000;

        $finish;
    end

endmodule
