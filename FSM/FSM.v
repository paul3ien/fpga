module FSM (
    input  wire       clk,
    input  wire       reset,
    output wire GREEN,
    output wire ORANGE,
    output wire RED
);

// Simulation du comportement d'un feu tricolore
reg [3:0]  counter;
reg[1:0] state;
reg[1:0] next_state;
localparam STATE_GREEN  = 2'b00;
localparam STATE_ORANGE = 2'b01;
localparam STATE_RED    = 2'b10;
assign GREEN  = (state == STATE_GREEN);
assign ORANGE = (state == STATE_ORANGE);
assign RED    = (state == STATE_RED);
localparam GREEN_DURATION  = 4'd10;
localparam ORANGE_DURATION = 4'd3;
localparam RED_DURATION    = 4'd10;

//Registre d'etat
always @(posedge clk) begin
    if (reset)
        state <=STATE_GREEN;
    else
        state <=next_state;
end


// Logique de transition
always @(*) begin
    next_state = state;
    case (state)
        STATE_GREEN:
            begin
                if (counter >=GREEN_DURATION)
                    next_state = STATE_ORANGE;
            end

        STATE_ORANGE:
            begin
                if (counter >=ORANGE_DURATION)
                    next_state = STATE_RED;
            end

        STATE_RED:
            begin
                if (counter >=RED_DURATION)
                    next_state = STATE_GREEN;
            end
        default : next_state = STATE_GREEN;
    endcase
end

always @(posedge clk) begin
    if (reset) begin
        counter <= 0;
    end
    else begin
        if (next_state != state)
            counter <=0;
        else
            counter = counter + 1;
    end

end

endmodule
