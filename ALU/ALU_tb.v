`timescale 1ns/1ps

module alu_tb;

    reg  [7:0] A;
    reg  [7:0] B;
    reg  [2:0] op;
    wire [7:0] result;
    wire       zero;

    ALU #(.DATA_WIDTH(8)) dut (
        .A(A),
        .B(B),
        .op(op),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("ALU_tb.vcd");
        $dumpvars(0,alu_tb);

        A = 8'd15; B = 8'd10; op = 1; #10; // ADD
        $display(A,B, result, zero);
        A = 8'd20; B = 8'd20; op = 2; #10; // SUB
        $display(A,B, result, zero);
        A = 8'b1100_1010; B = 8'b1010_1111; op = 3; #10; // AND
        $display(A,B, result, zero);
        A = 8'd3; B = 8'd2; op = 6; #10; // SHIFT_GAUCHE
        $display(A,B, result, zero);
        $finish;
    end
endmodule
