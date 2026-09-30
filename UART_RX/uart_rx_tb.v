`timescale 1ns/1ps

module uart_rx_tb;

    // Doivent correspondre aux paramètres du DUT et à l'horloge ci-dessous
    localparam CLK_FREQ_HZ  = 100_000_000;              // 100 MHz (période 10 ns)
    localparam BAUD_RATE    = 115_200;
    localparam CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;  // ~868 cycles par bit

    localparam [7:0] TEST_BYTE = 8'hA5;

    reg        clk;
    reg        reset;
    reg        data;    // ligne série d'entrée (1 bit)
    wire       done;
    wire [7:0] rx;

    uart_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) dut (
        .clk  (clk),
        .reset(reset),
        .data (data),
        .done (done),
        .rx   (rx)
    );

    // Horloge : période de 10 ns
    always #5 clk = ~clk;

    // Émet un bit sur la ligne, maintenu CLKS_PER_BIT cycles
    task send_bit;
        input b;
        integer i;
        begin
            data = b;
            for (i = 0; i < CLKS_PER_BIT; i = i + 1)
                @(posedge clk);
        end
    endtask

    // Émet une trame UART : start + 8 bits de données (LSB d'abord) + stop
    task send_byte;
        input [7:0] b;
        integer i;
        begin
            send_bit(1'b0);              // bit de start
            for (i = 0; i < 8; i = i + 1)
                send_bit(b[i]);          // données, LSB en premier
            send_bit(1'b1);              // bit de stop
        end
    endtask

    initial begin
        // Enregistrer les signaux pour Surfer
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);

        clk   = 0;
        reset = 1;
        data  = 1'b1;                    // ligne au repos

        repeat (10) @(posedge clk);      // maintenir le reset
        reset = 0;
        repeat (10) @(posedge clk);      // laisser le synchroniseur se stabiliser

        // Envoyer une trame de test
        send_byte(TEST_BYTE);

        // Attendre la fin de la réception
        wait (done);
        #20;

        if (rx === TEST_BYTE)
            $display("OK     : rx = 0x%02X (attendu 0x%02X)", rx, TEST_BYTE);
        else
            $display("ERREUR : rx = 0x%02X (attendu 0x%02X)", rx, TEST_BYTE);

        #100;
        $finish;
    end

    // Garde-fou : évite une simulation infinie si 'done' n'arrive jamais
    initial begin
        #2_000_000;                      // 2 ms
        $display("TIMEOUT : 'done' non reçu");
        $finish;
    end

endmodule
