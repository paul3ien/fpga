module fifo #(

    // Meme que la RAM

    parameter DATA_WIDTH = 8,          //Largeur des données en octets
    parameter ADDR_WIDTH = 4,           //Nombre d'adresses totales = 2^ADDR_WIDTH
    parameter DEPTH = (1 << ADDR_WIDTH)
)(
    input wire clk,
    input wire reset,

    input wire[DATA_WIDTH-1:0] data_in,
    input wire wr_en,                   // writting enable
    input wire rd_en,                   // reading enable

    output reg[DATA_WIDTH-1:0] data_out,
    output reg empty,                   // File vide
    output reg full                     // File pleine
);

// Matrice représentant la memoire même
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

reg[ADDR_WIDTH-1:0] write_ptr;
reg[ADDR_WIDTH-1:0] read_ptr;

reg[ADDR_WIDTH-1:0] cpt;
assign empty = (cpt == 0);
assign full = (cpt == DEPTH);

reg[2:0] state = {wr_en && !full, rd_en && !empty};
localparam READ = 2'b01;
localparam WRITE = 2'b10;
localparam READ_WRITE = 2'b11;

always @(posedge clk) begin
    if (reset) begin
        write_ptr <= 0;
        read_ptr <= 0;
        cpt <= 0;
        data_out <= 0;
    end else begin
        case(state)
            WRITE : begin
                memory[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1;
                cpt <= cpt + 1;
            end
            READ : begin
                data_out <= memory[read_ptr];
                read_ptr <= read_ptr + 1;
                cpt <= cpt + 1;
            end
            READ_WRITE : begin
                memory[write_ptr] <= data_in;
                data_out <= memory[read_ptr];
                write_ptr <= write_ptr + 1;
                read_ptr <= read_ptr + 1;
                cpt <= cpt + 1;
            end
            default: ;
        endcase
    end

end

endmodule
