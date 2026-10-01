module VGA_CORE #(
    parameter CLK_FREQ_HZ = 25_000_000
)(
    input wire clk,
    input wire reset,

    input wire[2:0] RGB_in,

    // Interface physique
    output reg HSYNC,
    output reg VSYNC,
    output reg[2:0] RGB_out,

    // Interface de contrôle vers la logique
    output reg[9:0] pixel_x,
    output reg[9:0] pixel_y,
    output wire video_on

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

reg [9:0] h_cpt;
reg [9:0] v_cpt;

// Block compteur sur deux bandes
always @(posedge clk) begin
    if (reset) begin
        h_cpt <=0;
        v_cpt <=0;
    end else begin
        // Check du cas final du balayage de bandes
        if (h_cpt == horizontal_total -1) begin
            h_cpt <=0;
            if (v_cpt == vertical_total -1) begin
                v_cpt <=0;
            end else
                v_cpt <=v_cpt +1;
        end else
            h_cpt <=h_cpt +1;
    end
end

// Block de gestion des états de synchronisations des bandes (horinzontale et verticales)
always @(posedge clk) begin
    if (reset) begin
        HSYNC <=0;
        VSYNC <=0;
    end else begin
        // On verifie si le compteur se trouve dans la zone de sync du signal
        HSYNC <=~((h_cpt >= horizontal_active_pixel + horizontal_front_porch) &&
                (h_cpt < horizontal_active_pixel + horizontal_front_porch + horizontal_sync_pulse));
        VSYNC <=~((v_cpt >=vertical_active_pixel + vertical_front_porch) &&
                (v_cpt < vertical_active_pixel + vertical_front_porch + vertical_sync_pulse));
    end
end

//h_cpt   :   0               640       656              752       800
//            ├────────────────┴─────────┴────────────────┴─────────┤
//            │     Pixels     │  Front  │   SYNC PULSE   │  Back   │
//            │   (Affichage)  │  Porch  │  (Impulsion)   │  Porch  │
 //HSYNC:     1111111111111111111111111110000000000000000011111111111

 assign video_on = (h_cpt < horizontal_active_pixel) && (v_cpt < vertical_active_pixel);
 assign pixel_x = h_cpt;
 assign pixel_y = v_cpt;
 assign RGB_out  = video_on ? RGB_in : 0;

endmodule
