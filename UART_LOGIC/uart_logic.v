module uart_logic #(parameter MAX_LEN = 16)
(
    input wire clk,
    input wire reset,

    // Cote PARSER
    input wire logic_valid,
    input wire [MAX_LEN*8-1:0] logic_buffer, // Paquet (vecteur empaqueté)
    input wire [3:0] logic_len,

    // Cote TX
    input wire       tx_ready, // Le TX peut accepter un octet
    output reg       tx_start, // Impulsion : un octet est pret
    output reg [7:0] tx_data   // Octet a envoyer
);

reg state;
localparam IDLE = 1'b0;
localparam SEND = 1'b1;

// Copie locale du paquet
reg [3:0] ptr;
reg [3:0] len;
reg [MAX_LEN*8-1:0] buffer;

always @(posedge clk) begin
    if (reset) begin
        state    <= IDLE;
        tx_start <= 1'b0;
        tx_data  <= 8'h00;
        ptr      <= 0;
        len      <= 0;
        buffer   <= 0;
    end else begin
        case (state)

            // Attente d'un paquet valide venant du parser
            IDLE: begin
                tx_start <= 1'b0;
                if (logic_valid) begin
                    buffer <= logic_buffer;
                    len    <= logic_len;
                    ptr    <= 0;
                    state  <= SEND;
                end
            end

            // Emission des octets du paquet, puis '\n'
            SEND: begin
                if (!tx_start) begin
                    // Presenter l'octet courant (ou '\n' en fin de paquet)
                    if (tx_ready) begin
                        tx_data  <= (ptr < len) ? buffer[ptr*8 +: 8] : 8'h0A;
                        tx_start <= 1'b1;
                    end
                end else begin
                    // Attendre que le TX ait pris l'octet (handshake 4 phases)
                    if (!tx_ready) begin
                        tx_start <= 1'b0;
                        if (ptr < len) ptr   <= ptr + 1;
                        else           state <= IDLE;
                    end
                end
            end

        endcase
    end
end

endmodule
