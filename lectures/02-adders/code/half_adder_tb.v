// half_adder_tb.v
// Testbench for half_adder (half_adder.v)
// Expected function reflects the lecture's spec: Sum = A ^ B, Carry = A & B

module half_adder_TB;
    reg  A, B;
    wire Sum, Carry;

    half_adder DUT (.A(A), .B(B), .Sum(Sum), .Carry(Carry));

    function [1:0] expected;
        input a, b;
        begin
            expected = {a & b, a ^ b};   // {Carry, Sum}
        end
    endfunction

    integer errors;
    reg [1:0] exp;

    initial begin
        errors = 0;
        $display("A B | Sum Carry | Exp Sum Exp Carry | Status");
        $display("----|-----------|-------------------|-------");

        {A, B} = 2'b00;
        repeat (4) begin
            #10;
            exp = expected(A, B);
            if ({Carry, Sum} !== exp) begin
                $display(" %b %b |  %b    %b   |    %b       %b     | FAIL",
                          A, B, Sum, Carry, exp[0], exp[1]);
                errors = errors + 1;
            end else begin
                $display(" %b %b |  %b    %b   |    %b       %b     | pass",
                          A, B, Sum, Carry, exp[0], exp[1]);
            end
            {A, B} = {A, B} + 1;
        end

        $display("----|-----------|-------------------|-------");
        if (errors == 0)
            $display("All 4 tests passed.");
        else
            $display("%0d test(s) FAILED.", errors);

        $finish;
    end
endmodule
