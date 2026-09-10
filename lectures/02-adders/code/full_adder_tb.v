// full_adder_tb.v
// Testbench for full_adder (full_adder.v)
// Expected function reflects the lecture's spec:
//   Sum  = A ^ B ^ Cin
//   Cout = (A & B) | (Cin & (A ^ B))

module full_adder_TB;
    reg  A, B, Cin;
    wire Sum, Cout;

    full_adder DUT (.A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout));

    function [1:0] expected;
        input a, b, cin;
        begin
            expected = {(a & b) | (cin & (a ^ b)), a ^ b ^ cin};   // {Cout, Sum}
        end
    endfunction

    integer errors;
    reg [1:0] exp;

    initial begin
        errors = 0;
        $display("A B Cin | Sum Cout | Exp Sum Exp Cout | Status");
        $display("--------|----------|-------------------|-------");

        {A, B, Cin} = 3'b000;
        repeat (8) begin
            #10;
            exp = expected(A, B, Cin);
            if ({Cout, Sum} !== exp) begin
                $display(" %b %b  %b  |  %b    %b   |    %b       %b     | FAIL",
                          A, B, Cin, Sum, Cout, exp[0], exp[1]);
                errors = errors + 1;
            end else begin
                $display(" %b %b  %b  |  %b    %b   |    %b       %b     | pass",
                          A, B, Cin, Sum, Cout, exp[0], exp[1]);
            end
            {A, B, Cin} = {A, B, Cin} + 1;
        end

        $display("--------|----------|-------------------|-------");
        if (errors == 0)
            $display("All 8 tests passed.");
        else
            $display("%0d test(s) FAILED.", errors);

        $finish;
    end
endmodule
