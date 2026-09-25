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
        reset = 0;

        // Appuis avec rebond

        #1000;

        button = 1;
        #30;
        button = 0;
        #20;
        button = 1;
        #40;
        button = 0;
        #30;
        button = 1;

        // Le bouton est maintenant réellement appuyé
        #20_000;

        // Relâchement
        button = 0;


        // Appuis avec rebond

        button = 1;
        #20;
        button = 0;
        #30;
        button = 1;
        #20;
        button = 0;
        #40;
        button = 1;

        // Bouton maintenu
        #20_000;

        // Relâchement
        button = 0;

        // Laisser tourner pendant 160 ns
        #10_000;

        $finish;
    end

    initial begin
            $monitor(
                "t=%0t | button=%b | sync=%b | stable=%b | last=%b | timer=%d | count=%d",
                $time,
                button,
                dut.sync_state,
                dut.state_button,
                dut.last_state_button,
                dut.timer,
                count
        );
    end

endmodule
