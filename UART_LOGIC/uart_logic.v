module uart_logic #(parameter MAX_LEN = 16)
(
    input wire clk,
    input wire reset,

    // Cote PARSER
    input wire logic_valid,
    input wire [MAX_LEN*8-1:0] logic_buffer, // Paquet (vecteur empaqueté)
    input wire [3:0] logic_len,

    // Cote TX
    input wire tx_ready,
    output reg tx_start,
    output reg tx_data
);

reg state;
localparam IDLE = 0;
localparam SEND = 1;

//Variables locales pour le buffer
reg [3:0] ptr;
reg [3:0] len;
reg [7:0] buffer;
integer iterator;

always @(posedge clk)begin
    if (reset) begin
        state<=IDLE;
        tx_start<=0;
        tx_data<=0;
        ptr <=0;
        len<=0;

    end else begin
        case(state)
            IDLE : begin
                tx_start<=0;
                if (logic_valid) begin
                    for (iterator=0;iterator<logic_len;iterator++) begin
                        buffer[iterator] = logic_buffer[iterator];
                    end
                    len<=logic_len;
                    ptr <=0;
                    state=SEND;
                end
            end
            SEND : begin
                if (ptr<len) begin
                    if (tx_ready && !tx_start) begin
                        tx_data <= buffer[ptr];
                        tx_start <=1;
                        state <= IDLE;
                    end else begin
                        tx_start <=1;
                    end

                end else begin
                    // Gestion de la fin du message '\n'
                    if (tx_ready && !tx_start) begin
                        tx_data <= 8'h0A;
                        tx_start <=1;
                        state <= IDLE;
                    end else begin
                        tx_start <=0;
                    end
                end
            end
        endcase
    end

end

endmodule
