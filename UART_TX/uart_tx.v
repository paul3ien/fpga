module uart_tx #(
    parameter CLK_FREQ_HZ = 1_000_000,
    parameter BAUD_RATE = 115_200)
(
    input  wire       clk,
    input  wire       reset,
    input  wire[7:0]  data,
    input  wire       start, // Impulsion pour lancer l'envoi
    output reg        busy, // Transmition en cours = 1
    output reg        tx
);

localparam HALF_PERIOD = CLK_FREQ_HZ / BAUD_RATE;
localparam NBR_BITS = $clog2(HALF_PERIOD+1);
reg[NBR_BITS-1:0] timer;


// Etats du FSM
localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam DATA = 2'b10;
localparam STOP = 2'b11;

reg[1:0] state;
reg[3:0] index;
reg[7:0] buffer;

// Bloc FSM
always @(posedge clk) begin
    if (reset) begin
        state <=IDLE;
        tx <=0;
        busy <=0;
        timer = 0;
        index <=0;
    end
    case (state)

        // Cas de la preparation de la donnee pour envoi
        IDLE:
            begin
                tx <=1'b1;
                busy <=0;
                timer = 0;
                index <=0;
                if(start) begin
                    buffer<=data; // On injecte les donnees dans un buffer
                    busy   <= 1'b1;
                    state = START;
                end else
                busy <= 1'b0;
            end

        // Cas du debut de l'envoi
        START:
            begin
                tx <=1'b0;
                if (timer == HALF_PERIOD-1) begin
                    timer<=0;
                    state <= DATA;
                end else begin
                    timer <= timer + 1;
                end


            end

        // Cas de l'envoi des donnees
        DATA :
            begin
                tx <=buffer[index];
                if (timer == HALF_PERIOD-1) begin
                    timer<=0;
                    if (index == 3'd7) begin
                        index<=0;
                        state <=STOP;
                    end else begin
                        index <= index + 1'b1;
                    end
                end else begin
                    timer <= timer + 1;
                end
            end
        STOP:
            begin
                tx <=1'b1;
                if (timer == HALF_PERIOD-1) begin
                    timer<=0;
                    busy <=1'b0;
                    state <= IDLE;
                end else begin
                    timer <= timer + 1;
                end

            end
        default : state <= IDLE;
    endcase
end
endmodule
