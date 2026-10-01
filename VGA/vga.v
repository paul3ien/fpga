module VGA #(
)(
    input wire clk,
    input wire reset,
    output reg HSYNC,
    output reg VSYNC,
    output wire video_on,
    output reg[9:0] pixel_x,
    output reg[9:0] pixel_y,
    output reg[2:0] RGB
);

// Découpage des signaux horizontaux et verticaux selon leurs composantes
localparam horizontal_active_pixel = 640; // zone active
localparam horizontal_front_porch = 16; // bordure avant
localparam horizontal_sync_pulse = 96;
localparam horizontal_back_porch = 48; // bordure arriere
localparam horizontal_total = 800;

localparam vertical_active_pixel = 480;
localparam vertical_front_porch = 10;
localparam vertical_sync_pulse = 2;
localparam vertical_back_porch = 33;
localparam vertical_total = 525;

reg [9:0] horizontal_cpt;
reg [9:0] vertical_cpt;

// Block compteur sur deux bandes
always @(posedge clk) begin
    if (reset) begin
        horizontal_cpt <=0;
        vertical_cpt <=0;
    end else begin
        // Check du cas final du balayage de bandes
        if (horizontal_cpt == horizontal_total -1) begin
            horizontal_cpt <=0;
            if (vertical_cpt == vertical_total -1) begin
                vertical_cpt <=0;
            end else
                vertical_cpt <=vertical_cpt +1;
        end else
            horizontal_cpt <=horizontal_cpt +1;
    end
end

// Block de gestion des états de synchronisations des bandes (horinzontale et verticales)
always @(posedge clk) begin
    // On verifie si le compteur se trouve dans la zone de sync du signal
    HSYNC <=~((horizontal_cpt >= horizontal_active_pixel + horizontal_front_porch) &&
            (horizontal_cpt < horizontal_active_pixel + horizontal_front_porch + horizontal_sync_pulse));
    VSYNC <=~((vertical_cpt >=vertical_active_pixel + vertical_front_porch) &&
            (vertical_cpt < vertical_active_pixel + vertical_front_porch + vertical_sync_pulse));
end

//h_cpt   :   0               640       656              752       800
//            ├────────────────┴─────────┴────────────────┴─────────┤
//            │     Pixels     │  Front  │   SYNC PULSE   │  Back   │
//            │   (Affichage)  │  Porch  │  (Impulsion)   │  Porch  │
 //HSYNC:     1111111111111111111111111110000000000000000011111111111

 assign video_on = (horizontal_cpt < horizontal_front_porch) && (vertical_cpt < vertical_front_porch);
 assign pixel_x = horizontal_cpt;
 assign pixel_y = vertical_cpt;

endmodule
