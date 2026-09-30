`include "../UART_RX/uart_rx.v"
`include "../UART_PARSER/uart_parser.v"
`include "../UART_TX/uart_tx.v"

module uart #(
    parameter CLK_FREQ_HZ = 1_000_000,
    parameter BAUD_RATE   = 115_200,
    parameter MAX_PKT_LEN = 16
)(
    input  wire clk,
    input  wire reset,
    // Interface série physique (I/O)
    input  wire rx_pin,
    output wire tx_pin,
    output wire led_pin
);

// Interconnexion : uart_rx -> parser
wire       rx_done;
wire [7:0] rx_byte;

// Interconnexion : parser -> logic
wire       pkt_valid;
wire [MAX_PKT_LEN*8-1:0] pkt_buffer;
wire [3:0] pkt_len;

// Interconnexion : logic -> uart_tx
wire       tx_start;
wire [7:0] tx_byte;
wire       tx_busy;
wire       tx_ready = ~tx_busy; // uart_tx occupé => pas prêt

uart_rx #(
	.CLK_FREQ_HZ(CLK_FREQ_HZ),
	.BAUD_RATE  (BAUD_RATE)
 ) uart_rx (
	.clk  (clk),
	.reset(reset),
	.data (rx_pin),
	.done (rx_done),
	.rx   (rx_byte)
);
uart_parser #(
	.MAX_LEN(MAX_PKT_LEN)
 ) uart_parser (
	.clk         (clk),
	.reset       (reset),
	.rx_done     (rx_done),
	.rx_data     (rx_byte),
	.logic_valid (pkt_valid),
	.logic_buffer(pkt_buffer),
	.logic_len   (pkt_len)
);
uart_logic_terminal #(
	.MAX_LEN(MAX_PKT_LEN)
 ) uart_logic_terminal (
	.clk         (clk),
	.reset       (reset),
	.logic_valid (pkt_valid),
	.logic_buffer(pkt_buffer),
	.logic_len   (pkt_len),
	.tx_ready    (tx_ready),
	.tx_start    (tx_start),
	.tx_data     (tx_byte),
	.led_pin     (led_pin)
);


uart_tx #(
	.CLK_FREQ_HZ(CLK_FREQ_HZ),
	.BAUD_RATE  (BAUD_RATE)
 ) uart_tx (
	.clk  (clk),
	.reset(reset),
	.data (tx_byte),
	.start(tx_start),
	.busy (tx_busy),
	.tx   (tx_pin)
);

endmodule


module uart_logic_terminal #(parameter MAX_LEN = 16)(
    input  wire                 clk,
    input  wire                 reset,

    // Côté PARSER
    input  wire                 logic_valid,
    input  wire [MAX_LEN*8-1:0] logic_buffer,
    input  wire [3:0]           logic_len,

    // Côté TX
    input  wire                 tx_ready,
    output reg                  tx_start,
    output reg [7:0]            tx_data,

    // Matériel / État
    output reg                  led_pin
);

// États de la FSM
localparam IDLE = 1'b0;
localparam SEND = 1'b1;

reg state;

// Buffer d'émission (64 octets, suffisant pour les réponses texte)
reg [511:0] buffer;
reg [7:0]   len;
reg [7:0]   ptr;

always @(posedge clk) begin
    if (reset) begin
        state    <= IDLE;
        tx_start <= 1'b0;
        tx_data  <= 8'h00;
        ptr      <= 0;
        len      <= 0;
        buffer   <= 0;
        led_pin  <= 1'b0;
    end else begin
        case (state)

            // Attente d'un paquet valide venant du parser
            IDLE: begin
                tx_start <= 1'b0;
                if (logic_valid) begin
                    ptr <= 0;

                    // NB : le parser stocke l'octet 0 en [7:0],
                    //      d'où les constantes "inversées" (ex. "help" -> 0x706C6568).

                    // "help"
                    if (logic_len == 4 && logic_buffer[31:0] == 32'h706C6568) begin
                        buffer <= "Cmds: led, count, reset, status\r\n";
                        len    <= 8'd33;
                    end
                    // "led"
                    else if (logic_len == 3 && logic_buffer[23:0] == 24'h64656C) begin
                        led_pin <= ~led_pin;
                        buffer  <= "LEDs toggled\r\n";
                        len     <= 8'd14;
                    end
                    // "count"
                    else if (logic_len == 5 && logic_buffer[39:0] == 40'h746E756F63) begin
                        buffer <= "1234\r\n";
                        len    <= 8'd6;
                    end
                    // "status"
                    else if (logic_len == 6 && logic_buffer[47:0] == 48'h737574617473) begin
                        buffer <= "System OK\r\n";
                        len    <= 8'd11;
                    end
                    // Commande inconnue
                    else begin
                        buffer <= "Error: unknown\r\n";
                        len    <= 8'd16;
                    end

                    state <= SEND;
                end
            end

            // Émission des octets de la réponse
            SEND: begin
                if (!tx_start) begin
                    // Présenter l'octet courant (les réponses contiennent déjà \r\n)
                    if (tx_ready && ptr < len) begin
                        tx_data  <= buffer[(len-1-ptr)*8 +: 8];
                        tx_start <= 1'b1;
                    end
                end else begin
                    // Attendre que le TX ait pris l'octet (handshake 4 phases)
                    if (!tx_ready) begin
                        tx_start <= 1'b0;
                        ptr      <= ptr + 1;
                        if (ptr + 1 >= len) state <= IDLE;
                    end
                end
            end

        endcase
    end
end

endmodule
