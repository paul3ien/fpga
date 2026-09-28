module top_send_string (
    input  wire clk,
    input  wire reset,
    output wire tx_line
);

    reg  [7:0] rom [0:12];
    initial begin
        rom[0]  = "H"; rom[1]  = "e"; rom[2]  = "l"; rom[3]  = "l";
        rom[4]  = "o"; rom[5]  = " "; rom[6]  = "W"; rom[7]  = "o";
        rom[8]  = "r"; rom[9]  = "l"; rom[10] = "d"; rom[11] = "!";
        rom[12] = "\n";
    end

    reg  [3:0] ptr;
    reg        start_tx;
    reg  [7:0] tx_byte;
    wire       busy;

    uart_tx #(
        .CLK_FREQ_HZ(100_000_000),
        .BAUD_RATE(115_200)
    ) uart_inst (
        .clk(clk),
        .reset(reset),
        .start(start_tx),
        .data(tx_byte),
        .tx(tx_line),
        .busy(busy)
    );

    // FSM de lecture de la ROM
    reg [1:0] state;
    localparam S_IDLE = 2'b00, S_SEND = 2'b01, S_WAIT = 2'b10;

    always @(posedge clk) begin
        if (reset) begin
            ptr      <= 0;
            start_tx <= 1'b0;
            state    <= S_IDLE;
        end else begin
            case (state)
                S_IDLE: begin
                    if (ptr <= 12) begin
                        tx_byte  <= rom[ptr];
                        start_tx <= 1'b1;
                        state    <= S_SEND;
                    end
                end

                S_SEND: begin
                    start_tx <= 1'b0;
                    state    <= S_WAIT;
                end

                S_WAIT: begin
                    // Attendre la fin de l'envoi
                    if (!busy) begin
                        ptr   <= ptr + 1'b1;
                        state <= S_IDLE;
                    end
                end
            endcase
        end
    end

endmodule
