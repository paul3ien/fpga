`timescale 1ns/1ps
`include "../UART_RX/uart_rx.v"
`include "../UART_PARSER/uart_parser.v"

module uart_logic_tb;

    localparam MAX_LEN        = 16;
    localparam CLK_FREQ_HZ    = 100_000_000;
    localparam BAUD_RATE      = 115_200;
    localparam CLKS_PER_BIT   = CLK_FREQ_HZ / BAUD_RATE; // ~868 cycles par bit
    localparam TX_BUSY_CYCLES = 5;                        // duree "occupee" du TX

    reg         clk;
    reg         reset;
    reg         data;                 // ligne serie vers uart_rx

    // uart_rx -> uart_parser
    wire        rx_done;
    wire [7:0]  rx_data;

    // uart_parser -> uart_logic
    wire        logic_valid;
    wire [MAX_LEN*8-1:0] logic_buffer;
    wire [3:0]  logic_len;

    // uart_logic -> TX
    reg         tx_ready;
    wire        tx_start;
    wire [7:0]  tx_data;

    uart_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) u_rx (
        .clk(clk), .reset(reset), .data(data),
        .done(rx_done), .rx(rx_data)
    );

    uart_parser #(
        .MAX_LEN(MAX_LEN)
    ) u_parser (
        .clk(clk), .reset(reset),
        .rx_done(rx_done), .rx_data(rx_data),
        .logic_valid(logic_valid),
        .logic_buffer(logic_buffer),
        .logic_len(logic_len)
    );

    uart_logic #(
        .MAX_LEN(MAX_LEN)
    ) u_logic (
        .clk(clk), .reset(reset),
        .logic_valid(logic_valid),
        .logic_buffer(logic_buffer),
        .logic_len(logic_len),
        .tx_ready(tx_ready),
        .tx_start(tx_start),
        .tx_data(tx_data)
    );

    // Horloge : période de 10 ns
    always #5 clk = ~clk;

    // ---- Modele de TX : accepte un octet, puis reste "occupe" un moment ----
    reg [7:0] sent [0:63];
    integer   n_sent;
    reg [3:0] busy_cnt;

    always @(posedge clk) begin
        if (reset) begin
            tx_ready <= 1'b1;
            busy_cnt <= 0;
        end else if (tx_ready) begin
            if (tx_start) begin
                sent[n_sent] = tx_data;      // transfert (tx_start & tx_ready)
                n_sent       = n_sent + 1;
                tx_ready     <= 1'b0;
                busy_cnt     <= TX_BUSY_CYCLES;
            end
        end else begin
            if (busy_cnt == 0) tx_ready <= 1'b1;
            else               busy_cnt <= busy_cnt - 1;
        end
    end

    // ---- Emission d'une trame serie vers uart_rx ----
    task send_bit;
        input b;
        integer k;
        begin
            data = b;
            for (k = 0; k < CLKS_PER_BIT; k = k + 1) @(posedge clk);
        end
    endtask

    task send_byte;
        input [7:0] b;
        integer k;
        begin
            send_bit(1'b0);              // start
            for (k = 0; k < 8; k = k + 1)
                send_bit(b[k]);          // donnees, LSB d'abord
            send_bit(1'b1);              // stop
        end
    endtask

    // ---- Scenario ----
    integer   i;
    reg [7:0] expected [0:5];

    initial begin
        // Enregistrer les signaux pour Surfer
        $dumpfile("uart_logic.vcd");
        $dumpvars(0, uart_logic_tb);

        clk   = 0;
        reset = 1;
        data  = 1'b1;
        n_sent = 0;

        // Attendu en sortie de uart_logic : "Hello" + '\n'
        expected[0] = 8'h48; expected[1] = 8'h65; expected[2] = 8'h6C;
        expected[3] = 8'h6C; expected[4] = 8'h6F; expected[5] = 8'h0A;

        repeat (10) @(posedge clk);      // maintenir le reset
        reset = 0;
        repeat (10) @(posedge clk);

        // Trame serie : "Hello" puis terminateur 0x04
        send_byte(8'h48);                // 'H'
        send_byte(8'h65);                // 'e'
        send_byte(8'h6C);                // 'l'
        send_byte(8'h6C);                // 'l'
        send_byte(8'h6F);                // 'o'
        send_byte(8'h04);                // terminateur

        wait (n_sent >= 6);              // attendre la sortie des 6 octets
        repeat (5) @(posedge clk);

        // Verification
        if (n_sent != 6) begin
            $display("ERREUR : %0d octets transmis (attendu 6)", n_sent);
        end else begin
            for (i = 0; i < 6; i = i + 1)
                if (sent[i] !== expected[i])
                    $display("ERREUR : tx[%0d] = 0x%02X (attendu 0x%02X)",
                             i, sent[i], expected[i]);
            $display("OK : chaine validee, %0d octets emis", n_sent);
        end

        for (i = 0; i < n_sent; i = i + 1)
            $display("  sent[%0d] = 0x%02X", i, sent[i]);

        #100;
        $finish;
    end

    // Garde-fou : evite une simulation infinie
    initial begin
        #2_000_000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
