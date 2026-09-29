module uart_rx #(
    parameter CLK_FREQ_HZ = 1_000_000,
    parameter BAUD_RATE = 115_200)
(
    input  wire       clk,
    input  wire       reset,
    input  wire       data,
    output reg        done, // Impulsion de fin pour lancer l'envoi
    output  reg[7:0]  rx
);

// Timer sur le BAUD

localparam HALF_PERIOD = CLK_FREQ_HZ / (2*BAUD_RATE);
localparam FULL_PERIOD = HALF_PERIOD*2;
localparam NBR_BITS = $clog2(FULL_PERIOD+1);
reg[NBR_BITS-1:0] timer;

// BLoc du timer

always @(clk) begin

end


// Variable pour la synchronisation

reg sync_0;
reg sync_1;

// Synchronisateur


always @(posedge clk) begin
    if (reset) begin
        sync_0 <= 1'b1;
        sync_1 <= 1'b1;
    end else begin
        sync_0 <= data;   // Premier étage
        sync_1 <= sync_0; // Second étage (signal propre utilisé par la FSM)
    end
end


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
        sync_1 <=0;
        done <=0;
        timer <= 0;
        index <=0;
    end
    case (state)

        // Cas de la preparation de la donnee pour envoi
        IDLE:
            begin
                done <=0;
                if(sync_1 == 0) begin
                    timer <= 0;
                    index <=0;
                    state <= START;

                end
            end

        // Cas du debut de l'envoi
        START:
            begin
                if (timer == HALF_PERIOD-1) begin
                    if (sync_1 ==0) begin
                        timer<=0;
                        state <=DATA;
                    end
                end else begin
                    timer <= timer + 1;
                end


            end

        // Cas de l'envoi des donnees
        DATA :
            begin
                if (timer == FULL_PERIOD-1) begin
                    timer<=0;
                    buffer <= {sync_1, buffer[7:1]};
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
                if (timer == FULL_PERIOD-1) begin
                    timer<=0;
                    rx <= buffer;
                    done <= 1'b1;
                    state <= IDLE;
                end else begin
                    timer <= timer + 1;
                end

            end
        default : state <= IDLE;
    endcase
end
endmodule
