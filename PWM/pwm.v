module pwm #(
    parameter CLK_FREQ_HZ = 1_000_000,
    parameter CLOCK_DIVIDER = 1
)
(
    input  wire       clk,
    input  wire       reset,
    input  wire[3:0]  duty_cycle,
    output reg [3:0]  signal,
    output reg[3:0]   count
);


// Boucle comparateur

always @(posedge clk) begin
    if (reset)
        signal <=4'b0000;
    else begin
        if (count<duty_cycle)
            signal <= 4'b1111;
        else
            signal <= 4'b0000;
    end
end


// Boucle timer

always @(posedge clk) begin
    if (reset)
        count <= 4'b0000;
    else
        count <= count + 1'b1;
end

endmodule
