module uart_parser #(parameter MAX_LEN = 16)
(
    input wire clk,
    input wire reset,

    // Cote RX
    input wire rx_done,
    input wire [7:0] rx_data,

    // Cote LOGIC
    output reg logic_valid,
    output reg [MAX_LEN*8-1:0] logic_buffer, // Paquet (vecteur empaqueté, supporté par Yosys)
    output reg [3:0] logic_len
);

reg [3:0] ptr;


always @(posedge clk) begin

    if (reset) begin
        ptr <= 0;
        logic_valid <=0;
        logic_len <=0;
    end else begin
        // Signal d'impulsion
        logic_valid <=0;
        if (rx_done) begin
            // Fin de ligne : '\n' (0x0A). Le '\r' (0x0D) est ignoré (retours CRLF).
            if (rx_data == 8'h0A) begin
                logic_len <= ptr;
                logic_valid <= 1;
                ptr <=0;
            end else if (rx_data == 8'h0D) begin
                // '\r' ignoré
            end else if (ptr < MAX_LEN) begin
                logic_buffer[ptr*8 +: 8]<=rx_data;
                ptr <= ptr + 1;
            end
        end
    end
end

endmodule
