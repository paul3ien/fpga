`timescale 1ns/1ps

module terminal_uart_tb;

    localparam CLK_FREQ_HZ = 1_000_000;
    localparam BAUD_RATE   = 115_200;
    localparam MAX_PKT_LEN = 16;

    // uart_rx/uart_tx utilisent 2*HALF_PERIOD cycles par bit,
    // avec HALF_PERIOD = CLK_FREQ_HZ/(2*BAUD_RATE) -> ici 8 cycles = 8000 ns.
    localparam CLK_NS      = 1_000_000_000 / CLK_FREQ_HZ;   // 1000 ns
    localparam HALF_PERIOD = CLK_FREQ_HZ / (2 * BAUD_RATE); // 4
    localparam BIT_PERIOD  = 2 * HALF_PERIOD * CLK_NS;      // 8000 ns

    reg  clk;
    reg  reset;
    reg  rx_pin;
    wire tx_pin;
    wire led_pin;

    // Module sous test
    uart #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE),
        .MAX_PKT_LEN(MAX_PKT_LEN)
    ) dut (
        .clk(clk),
        .reset(reset),
        .rx_pin(rx_pin),
        .tx_pin(tx_pin),
        .led_pin(led_pin)
    );

    // Horloge
    always #(CLK_NS/2) clk = ~clk;

    // ---- Récepteur de contrôle : décode la réponse émise sur tx_pin ----
    wire       mon_done;
    wire [7:0] mon_byte;

    uart_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) monitor (
        .clk(clk), .reset(reset), .data(tx_pin),
        .done(mon_done), .rx(mon_byte)
    );

    reg [7:0] resp [0:255];
    integer   n_resp;

    always @(posedge clk) begin
        if (mon_done) begin
            resp[n_resp] = mon_byte;
            n_resp       = n_resp + 1;
        end
    end

    // ---- Émission série vers le DUT ----
    task send_byte;
        input [7:0] b;
        integer k;
        begin
            rx_pin = 1'b0; #(BIT_PERIOD);                 // start
            for (k = 0; k < 8; k = k + 1) begin           // données, LSB d'abord
                rx_pin = b[k]; #(BIT_PERIOD);
            end
            rx_pin = 1'b1; #(BIT_PERIOD);                 // stop
        end
    endtask

    // Envoie les `len` premiers octets de la commande `cmd`, puis '\n'
    task send_command;
        input [127:0] cmd;
        input integer len;
        integer j;
        begin
            for (j = len-1; j >= 0; j = j - 1)
                send_byte(cmd[j*8 +: 8]);
            send_byte(8'h0A);                             // touche Entrée
        end
    endtask

    // Vérifie que la réponse reçue correspond à la chaîne `s` (longueur `len`)
    task check_resp;
        input [8*40-1:0] s;
        input integer len;
        integer k;
        reg ok;
        begin
            if (n_resp != len) begin
                $display("  ECHEC : %0d octets recus (attendu %0d)", n_resp, len);
            end else begin
                ok = 1'b1;
                for (k = 0; k < len; k = k + 1) begin
                    if (resp[k] !== s[(len-1-k)*8 +: 8]) begin
                        $display("  ECHEC octet %0d : recu 0x%02X, attendu 0x%02X",
                                 k, resp[k], s[(len-1-k)*8 +: 8]);
                        ok = 1'b0;
                    end
                end
                if (ok) $display("  OK");
            end
        end
    endtask

    initial begin
        $dumpfile("terminal_uart.vcd");
        $dumpvars(0, terminal_uart_tb);

        clk    = 0;
        reset  = 1;
        rx_pin = 1'b1;   // repos UART
        n_resp = 0;

        repeat (10) @(posedge clk);   // reset
        reset = 0;
        repeat (10) @(posedge clk);
        n_resp = 0;

        $display("Test 'help'");
        send_command("help", 4);
        repeat (4000) @(posedge clk);
        check_resp("Cmds: led, count, reset, status\r\n", 33);
        n_resp = 0;

        $display("Test 'led'");
        send_command("led", 3);
        repeat (2000) @(posedge clk);
        check_resp("LEDs toggled\r\n", 14);
        $display("  led_pin = %b", led_pin);
        n_resp = 0;

        $display("Test 'count'");
        send_command("count", 5);
        repeat (2000) @(posedge clk);
        check_resp("1234\r\n", 6);
        n_resp = 0;

        $display("Test 'status'");
        send_command("status", 6);
        repeat (2000) @(posedge clk);
        check_resp("System OK\r\n", 11);
        n_resp = 0;

        $display("Test commande inconnue");
        send_command("xyz", 3);
        repeat (2000) @(posedge clk);
        check_resp("Error: unknown\r\n", 16);
        n_resp = 0;

        $display("Fin des tests");
        $finish;
    end

endmodule
