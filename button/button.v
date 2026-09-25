module button #(
    parameter CLK_FREQ_HZ = 1_000_000,
    parameter DEBOUNCE_MS = 1
)
(
    input  wire       clk,
    input  wire       reset,
    input wire        button,
    output reg [3:0]  count
);

localparam NBR_CYCLE = (CLK_FREQ_HZ/1000) * DEBOUNCE_MS ; // Nombre de cycle necessaire pour le debonce
localparam NBR_BITS = $clog2(NBR_CYCLE); // Nombre de bits par cycle d'ecoute pour le debonce
reg[NBR_BITS-1:0] timer; // Timer du cycle d'ecoute pour le debonce

reg state_button; // Etat stable du bouton
reg last_state_button;
reg[1:0] sync_state; // Etat de synchronisation


// Synchronisation du bouton (boucle initiale)

always @(posedge clk) begin
    if (reset)
        sync_state <= 2'b00;
    else
        sync_state <= {sync_state[0],button};
end



// Filtre anti-rebond

always @(posedge clk) begin
    if (reset) begin
        timer <= 0;
        state_button <= 1'b0;
    end else begin

        // Si le signal d'entree est different de l'etat stable
        if (sync_state[1] != state_button) begin
            if (timer <= NBR_CYCLE-1) begin
                timer <= timer + 1'b1;
            end
            // Le signal est reste stable pendant pendant la duree du DEBOUNCE_MS
            else begin
                state_button <= sync_state[1];
                timer <=0;
            end
        end
        // Pas de changement, on reinitialise le timer
        else begin
            timer <=0;
        end
    end

end



//Detection de front montant et boucle compteur

always @(posedge clk) begin
    if (reset) begin
        count <= 4'b0000;
        last_state_button <=1'b0;
    end else begin
        last_state_button <= state_button;
        if (state_button && !last_state_button) begin
            count <= count + 1'b1;
        end
    end

end

endmodule
