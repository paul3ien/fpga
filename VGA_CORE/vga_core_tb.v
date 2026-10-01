`timescale 1ns/1ps

module vga_core_tb;

    reg        clk = 0;
    reg        reset = 0;
    reg  [2:0] rgb_in = 3'b101; // Couleur magenta fixe pour le test

    wire       hsync;
    wire       vsync;
    wire [2:0] rgb_out;
    wire       video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    // Horloge 25 MHz (période de 40 ns)
    always #20 clk = ~clk;

    // Instance de ton module vga_core
    VGA_CORE dut (
        .clk      (clk),
        .reset    (reset),
        .RGB_in   (rgb_in),
        .HSYNC    (hsync),
        .VSYNC    (vsync),
        .RGB_out  (rgb_out),
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y)
    );

    initial begin
        $dumpfile("vga_core_tb.vcd");
        $dumpvars(0, vga_core_tb);

        // Reset
        reset = 1;
        #100;
        reset = 0;

        // Attente du franchissement de la première ligne complète (800 cycles)
        wait (pixel_x == 639);
        @(posedge clk);
        $display("[%0t ns] Fin de zone active X=639 -> video_on attendu = 0 | Reel = %b", $time, video_on);

        wait (pixel_x == 656);
        @(posedge clk);
        $display("[%0t ns] Debut HSYNC (X=656) -> hsync attendu = 0 | Reel = %b", $time, hsync);

        wait (pixel_x == 752);
        @(posedge clk);
        $display("[%0t ns] Fin HSYNC (X=752) -> hsync attendu = 1 | Reel = %b", $time, hsync);

        // Attente du passage à la ligne suivante (Y=1)
        wait (pixel_y == 1 && pixel_x == 0);
        $display("[%0t ns] Ligne 1 atteinte avec succes !", $time);

        #1000;
        $finish;
    end

endmodule
