`include "../VGA_CORE/vga_core.v"
`include "../VGA_LOGIC/vga_logic.v"

module vga (
    input  wire       clk,
    input  wire       reset,
    output wire       HSYNC,
    output wire       VSYNC,
    output wire [2:0] rgb
);

    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire       video_on;
    wire [2:0] rgb_pixel;

    // Module de contrôle de timing VGA
    VGA_CORE core_inst (
        .clk      (clk),
        .reset    (reset),
        .RGB_in   (rgb_pixel),
        .HSYNC    (HSYNC),
        .VSYNC    (VSYNC),
        .RGB_out  (rgb),
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y)
    );

    // Module de la gestion de la logique de "dessin"
    vga_logic logic_inst (
        .pixel_x (pixel_x),
        .pixel_y (pixel_y),
        .rgb     (rgb_pixel)
    );

endmodule
