// primer_tb.v
// Testbench for my_circuit (primer.v)
// Exercises all 4 input combinations and checks against the expected function.
// primer.v currently has the continuous-assignment line active (Y = A & B)
// and the structural line commented out — both compute the same thing,
// so this testbench passes either way. Swap which line is commented in
// primer.v to demonstrate that live, then re-run without touching this file.

module primer_TB;
    reg  A, B;
    wire Y;

    my_circuit DUT (.A(A), .B(B), .Y(Y));

    function expected;
        input a, b;
        begin
            expected = a & b;
        end
    endfunction

    integer errors;

    initial begin
        errors = 0;
        $display("A B | Y Expected | Status");
        $display("----|------------|-------");

        {A, B} = 2'b00;
        repeat (4) begin
            #10;
            if (Y !== expected(A, B)) begin
                $display("%b %b |  %b    %b     | FAIL", A, B, Y, expected(A,B));
                errors = errors + 1;
            end else begin
                $display("%b %b |  %b    %b     | pass", A, B, Y, expected(A,B));
            end
            {A, B} = {A, B} + 1;
        end

        $display("----|------------|-------");
        if (errors == 0)
            $display("All 4 tests passed.");
        else
            $display("%0d test(s) FAILED.", errors);

        $finish;
    end
endmodule
