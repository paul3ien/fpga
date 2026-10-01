`timescale 1ns/1ps

module vga_tb;

    reg        clk = 0;
    reg        reset = 0;

    wire       HSYNC;
    wire       VSYNC;
    wire [2:0] rgb;

    // Horloge 25 MHz (Période = 40 ns)
    always #20 clk = ~clk;

    // Instance du TOP
    vga dut (
        .clk   (clk),
        .reset (reset),
        .HSYNC (HSYNC),
        .VSYNC (VSYNC),
        .rgb   (rgb)
    );

    integer file;
    integer frame_count = 0;

    initial begin
            $dumpfile("vga_top_tb.vcd");
            $dumpvars(0, vga_tb);

            // Reset
            reset = 1;
            #100;
            reset = 0;

            // Attente du pixel (X=210, Y=160) -> Zone du Rectangle Rouge (3'b100)
            wait (dut.pixel_y == 160 && dut.pixel_x == 210);
            #1;
            $display("[%0t ns] Pixel (210, 160) -> RGB: %b (Attendu: 100 - Rouge)", $time, rgb);

            // Attente du bord d'écran hors zone visible (X=650) -> Doit être Noir (3'b000)
            wait (dut.pixel_x == 650);
            #1;
            $display("[%0t ns] Pixel (650, 160) -> RGB: %b (Attendu: 000 - Masque Blanking)", $time, rgb);

            file = $fopen("output_frame.ppm", "w");
            $fwrite(file, "P3\n640 480\n255\n");
            while (dut.pixel_y < 480) begin
                @(posedge clk);
                if (dut.video_on) begin
                    // Extraction des composantes R, G, B (1 bit chacune -> 0 ou 255)
                    $fwrite(file, "%d %d %d ",
                        dut.rgb[2] ? 255 : 0,  // Red
                        dut.rgb[1] ? 255 : 0,  // Green
                        dut.rgb[0] ? 255 : 0   // Blue
                    );
                end

                // Retour à la ligne dans le fichier PPM à chaque fin de ligne VGA
                if (dut.pixel_x == 639 && dut.video_on) begin
                    $fwrite(file, "\n");
                end
            end
            $fclose(file);

            #1000;
            $finish;
    end
endmodule
