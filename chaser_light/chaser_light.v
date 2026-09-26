module chaser_light #(
    parameter CLK_FREQ_HZ = 1_000_000,
    parameter CLOCK_DIVIDER = 1
)
(
    input  wire       clk,
    input  wire       reset,
    output reg[3:0]   light
);


localparam HALF_PERIOD = CLK_FREQ_HZ / (2 * CLOCK_DIVIDER);
localparam NBR_BITS = $clog2(HALF_PERIOD+1);
reg[NBR_BITS-1:0] timer;
reg[1:0] impulsion;


// Boucle d'impulsion

always @(posedge clk) begin
    if (reset)
        light <=4'b0001 ;
    else
        if (impulsion == 1) begin
            light <= {light[2:0], light[3]};
        end
end


//Boucle timer

always @(posedge clk) begin
    if (reset) begin
        timer <= 0;
    end
    else begin
        if (timer == HALF_PERIOD-1) begin
            timer <=0;
            impulsion <= 1;
        end else begin
            impulsion <= 0;
            timer <= timer + 1;
        end
    end
end

endmodule
