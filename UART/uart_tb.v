`timescale 1ns/1ps
`include "../UART_RX/uart_rx.v"
`include "../UART_PARSER/uart_parser.v"
`include "../UART_LOGIC/uart_logic.v"
`include "../UART_TX/uart_tx.v"

module uart_tb;

    parameter CLK_FREQ_HZ = 1_000_000;
    parameter BAUD_RATE   = 115_200;
    parameter MAX_PKT_LEN = 16;
    parameter BIT_PERIOD = 1000_000_0000 / BAUD_RATE;

    reg clk =0;
    reg reset = 1;
    reg rx_pin = 1;
    reg tx_pin;

    always #500 clk = ~clk;

    uart #(
	.CLK_FREQ_HZ(CLK_FREQ_HZ),
	.BAUD_RATE  (BAUD_RATE),
	.MAX_PKT_LEN(MAX_PKT_LEN)
     ) dut (
	.clk   (clk),
	.reset (reset),
	.rx_pin(rx_pin),
	.tx_pin(tx_pin)
    );

    // --- Tâche pour envoyer un caractère ASCII complet sur rx_pin ---
        task send_byte(input [7:0] data);
            integer i;
            begin
                // Bit de Start (0)
                rx_pin = 1'b0;
                #(BIT_PERIOD);

                // 8 Bits de données (LSB first)
                for (i = 0; i < 8; i = i + 1) begin
                    rx_pin = data[i];
                    #(BIT_PERIOD);
                end

                // Bit de Stop (1)
                rx_pin = 1'b1;
                #(BIT_PERIOD);
            end
        endtask

        // --- Tâche pour envoyer une chaîne de caractères complète ---
        task send_string(input [8*16-1:0] str, input integer len);
            integer j;
            begin
                for (j = len - 1; j >= 0; j = j - 1) begin
                    send_byte(str[j*8 +: 8]);
                end
            end
        endtask


    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);

        // Reset initial
        #2000;
        reset = 0;
        #5000;

        // Envoi du message "HELLO\n"
        $display("[%0t ns] Envoi du message 'HELLO\\n'...", $time);

        send_byte("H");
        send_byte("E");
        send_byte("L");
        send_byte("L");
        send_byte("O");
        send_byte(8'h0A); // Character '\n' (délimiteur de fin)

        // Attente de la réception du retour sur tx_pin
        $display("[%0t ns] Attente de la reponse du FPGA...", $time);

        // Laisser la simulation tourner pendant l'envoi de la réponse par le FPGA
        #(BIT_PERIOD * 10 * 8);

        $display("[%0t ns] Simulation terminee !", $time);
        $finish;
    end




endmodule
