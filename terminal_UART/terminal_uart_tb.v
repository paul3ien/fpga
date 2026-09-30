`timescale 1ns/1ps

module terminal_uart_tb;

    parameter CLK_FREQ_HZ = 1_000_000;
    parameter BAUD_RATE   = 115_200;
    parameter MAX_PKT_LEN = 16;
    parameter BIT_PERIOD = 1000_000_0000 / BAUD_RATE;

    reg clk;
    reg reset;
    reg rx_pin;
    wire tx_pin;

    // Horloge 1 MHz (période = 1000 ns)
    always #500 clk = ~clk;

    // Instance du module Top
    uart #(
        .CLK_FREQ_HZ(1_000_000),
        .BAUD_RATE  (115_200)
    ) dut (
        .clk(clk),
        .reset(reset),
        .rx_pin(rx_pin),
        .tx_pin(tx_pin)
    );


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

    // Tâche pour envoyer une chaîne de caractères suivie de '\n' (0x0A)
    task send_command(input [127:0] cmd, input integer len);
        integer i;
        begin
            for (i = len - 1; i >= 0; i = i - 1) begin
                send_byte(cmd[i*8 +: 8]);
            end
            send_byte(8'h0A); // Envoi de Entrée '\n' pour valider le parser
        end
    endtask


    initial begin
        $dumpfile("terminal_uart.vcd");
        $dumpvars(0, terminal_uart_tb);

        clk = 0;
        reset = 1;
        rx_pin = 1; // État de repos UART
        #10_000;
        reset = 0;
        #10_000;

        // Test 1: commande "help"
        $display("[%0t] Envoi de la commande 'help'", $time);
        send_command("help", 4);
        #5_000_000; // Laisser le temps à uart_tx d'émettre la réponse

        // Test 2: commande "led"
        $display("[%0t] Envoi de la commande 'led'", $time);
        send_command("led", 3);
        #3_000_000;

        // Test 3: commande "count"
        $display("[%0t] Envoi de la commande 'count'", $time);
        send_command("count", 5);
        #2_000_000;

        $finish;

endmodule
