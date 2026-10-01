module vga_logic (
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    output reg  [2:0] rgb
);

wire rect = (pixel_x >= 10'd200 && pixel_x <= 10'd440) &&
                   (pixel_y >= 10'd150 && pixel_y <= 10'd330);

always @(*)begin
    // Couleur de fond
    rgb = 3'b000;
    if(rect)begin
        rgb = 3'b100;
    end else begin
        rgb = 3'b000;
    end
end

endmodule
