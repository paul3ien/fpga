module ALU # (
    parameter DATA_WIDTH = 8
)(
    // Inputs
    input wire[DATA_WIDTH-1:0] A,
    input wire[DATA_WIDTH-1:0] B,
    // Choix de l'opération
    input wire[2:0] op,

    output reg[DATA_WIDTH-1:0] result,
    //Flag de sortie
    output reg zero
);

// Variable du FSM
localparam ADD = 0;
localparam SUB = 1;
localparam AND = 2;
localparam OR = 3;
localparam XOR = 4;
localparam SHIFT_D = 5;
localparam SHIFT_G = 6;
reg[2:0] state;
assign state = op;

reg[DATA_WIDTH-1:0] buffer;

always @(*) begin
    case (state)
        ADD : begin
            buffer <=A+B;
        end
        SUB : begin
            buffer <=A-B;
        end
        OR : begin
            buffer <=A|B;
        end
        AND : begin
            buffer <=A&B;
        end
        XOR : begin
            buffer <= A^B;
        end
        SHIFT_D : begin
            buffer <=A>>B[2:0];
        end
        SHIFT_G : begin
            buffer <= A<<B[2:0];
        end
        default: buffer= {DATA_WIDTH{1'b0}};
    endcase
    result = buffer;
end

// Renvoi 1 quand le résultat est nul
assign zero = {DATA_WIDTH{1'b0}};

endmodule
