module ram #(
    parameter DATA_WIDTH = 12,               //Largeur des données en octets
    parameter ADDR_WIDTH = 1,           //Nombre d'adresses totales = 2^ADDR_WIDTH
    parameter DEPTH = (1 << ADDR_WIDTH)
)(
    input wire clk,
    input wire we,                      // Writting enable
    input wire[DATA_WIDTH-1:0] addr,
    input wire[DATA_WIDTH-1:0] data_in,
    output reg[DATA_WIDTH-1:0] data_out
);

// Matrice représentant la memoire même
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

always @(posedge clk) begin
    if (we) begin
        // Écriture
        memory[addr] <=data_in;
    end else begin
    // Lecture
    data_out <=memory[addr];
    end
end

endmodule
