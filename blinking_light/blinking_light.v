module blinking #(
    parameter CLK_FREQ_HZ = 1_000_000,
    parameter CLOCK_DIVIDER = 1
)
(
    input  wire       clk,
    input  wire       reset,
    output wire       light
);

localparam ON = 1'b0;
localparam OFF = 1'b1;

reg[1:0] state;
reg[1:0] next_state;


localparam HALF_PERIOD = CLK_FREQ_HZ / (2 * CLOCK_DIVIDER);
localparam NBR_BITS = $clog2(HALF_PERIOD+1);
reg[NBR_BITS-1:0] timer;
assign light = (state == ON);

// Initialisation - Registre d'etat

always @(posedge clk) begin
    if (reset)
        state <= ON;
    else
        state <= next_state;
end


// Boucle logique - FSM

always @(*) begin
    next_state = state;
    case (state)
        ON:
            begin
                if (timer >=HALF_PERIOD)
                    next_state = OFF;
            end

        OFF:
            begin
                if (timer >=HALF_PERIOD)
                    next_state = ON;
            end

        default : next_state = ON;
    endcase
end

//Boucle timer

always @(posedge clk) begin
    if (reset) begin
        timer <= 0;
    end
    else begin
        if (next_state != state)
            timer <=0;
        else
            timer <= timer + 1;
    end
end

endmodule
