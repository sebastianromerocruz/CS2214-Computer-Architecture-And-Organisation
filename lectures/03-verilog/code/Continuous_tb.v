// Continuous_tb.v
// Testbench for MyCircuit (Continuous.v)
// Expected function reflects the lecture's spec: Y = (~A & ~B & C) | ~D

module Continuous_TB;
    reg  A, B, C, D;
    wire Y;

    MyCircuit DUT (.A(A), .B(B), .C(C), .D(D), .Y(Y));

    function expected;
        input a, b, c, d;
        begin
            expected = (~a & ~b & c) | ~d;
        end
    endfunction

    integer errors;

    initial begin
        errors = 0;
        $display("A B C D | Y Expected | Status");
        $display("--------|------------|-------");

        {A, B, C, D} = 4'b0000;
        repeat (16) begin
            #10;
            if (Y !== expected(A, B, C, D)) begin
                $display("%b %b %b %b |  %b    %b     | FAIL", A, B, C, D, Y, expected(A,B,C,D));
                errors = errors + 1;
            end else begin
                $display("%b %b %b %b |  %b    %b     | pass", A, B, C, D, Y, expected(A,B,C,D));
            end
            {A, B, C, D} = {A, B, C, D} + 1;
        end

        $display("--------|------------|-------");
        if (errors == 0)
            $display("All 16 tests passed.");
        else
            $display("%0d test(s) FAILED.", errors);

        $finish;
    end
endmodule
