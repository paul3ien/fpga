module uart #(
    parameter CLK_FREQ_HZ = 1_000_000,
    parameter BAUD_RATE   = 115_200,
    parameter MAX_PKT_LEN = 16
)(
    input  wire clk,
    input  wire reset,
    // Interface série physique (I/O)
    input  wire rx_pin,
    output wire tx_pin
);

// Interconnexion : uart_rx -> parser
wire       rx_done;
wire [7:0] rx_byte;

// Interconnexion : parser -> logic
wire       pkt_valid;
wire [7:0] pkt_buffer [0:MAX_PKT_LEN-1];
wire [3:0] pkt_len;

// Interconnexion : logic -> uart_tx
wire       tx_start;
wire [7:0] tx_byte;
wire       tx_ready;

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
uart_logic #(
	.MAX_LEN(MAX_PKT_LEN)
 ) uart_logic (
	.clk         (clk),
	.reset       (reset),
	.logic_valid (pkt_valid),
	.logic_buffer(pkt_buffer),
	.logic_len   (pkt_len),
	.tx_ready    (tx_ready),
	.tx_start    (tx_start),
	.tx_data     (tx_byte)
);
uart_tx #(
	.CLK_FREQ_HZ(CLK_FREQ_HZ),
	.BAUD_RATE  (BAUD_RATE)
 ) uart_tx (
	.clk  (clk),
	.reset(reset),
	.data (tx_byte),
	.start(tx_start),
	.busy (tx_ready),
	.tx   (tx_pin)
);

endmodule
