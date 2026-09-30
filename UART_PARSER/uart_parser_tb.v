`timescale 1ns/1ps

module uart_parser_tb;

    localparam MAX_LEN = 16;

    reg        clk;
    reg        reset;
    reg        rx_done;
    reg  [7:0] rx_data;
    wire       logic_valid;
    wire [7:0] logic_buffer [0:MAX_LEN-1];
    wire [3:0] logic_len;

    uart_parser #(
        .MAX_LEN(MAX_LEN)
    ) dut (
        .clk(clk),
        .reset(reset),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .logic_valid(logic_valid),
        .logic_buffer(logic_buffer),
        .logic_len(logic_len)
    );

    // Horloge : période de 10 ns
    always #5 clk = ~clk;

    // Présente un octet au parser et pulse rx_done pendant 1 cycle
    task send_byte;
        input [7:0] b;
        begin
            @(negedge clk);
            rx_data = b;
            rx_done = 1'b1;
            @(negedge clk);
            rx_done = 1'b0;
        end
    endtask

    integer i;
    initial begin
        // Enregistrer les signaux pour Surfer
        $dumpfile("uart_parser.vcd");
        $dumpvars(0, uart_parser_tb);

        clk     = 0;
        reset   = 1;
        rx_done = 0;
        rx_data = 8'h00;

        repeat (10) @(posedge clk);      // maintenir le reset
        reset = 0;
        repeat (2) @(posedge clk);

        // Paquet de test : "Hello"
        send_byte(8'h48);                // 'H'
        send_byte(8'h65);                // 'e'
        send_byte(8'h6C);                // 'l'
        send_byte(8'h6C);                // 'l'
        send_byte(8'h6F);                // 'o'
        send_byte(8'h04);                // terminateur

        wait (logic_valid);              // attend l'impulsion de fin de paquet

        if (logic_len == 4'd5)
            $display("OK     : logic_valid=1, logic_len=%0d", logic_len);
        else
            $display("ERREUR : logic_valid=%b, logic_len=%0d (attendu 1 et 5)",
                     logic_valid, logic_len);

        for (i = 0; i < logic_len; i = i + 1)
            $display("  buffer[%0d] = 0x%02X", i, logic_buffer[i]);

        #100;
        $finish;
    end

    // Garde-fou : évite une simulation infinie
    initial begin
        #2_000_000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
