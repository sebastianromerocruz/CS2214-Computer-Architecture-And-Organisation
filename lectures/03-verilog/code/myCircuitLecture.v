module MyCircuit(
    input A, B, C, D,
    output Y
);

    wire nA, nB, nD; // inverted inputs
    wire W1, W2;     // internal

    // inverted inputs
    not NA (nA, A);
    not NB (nB, B);
    not ND (nD, D);

    // internal operations
    and A1 (W1, nA, nB);
    and A2 (W2, W1, C);
    or  O1 (Y, W2, nD);

endmodule

// ────────────────────────────────────────────────
// Testbench
// ────────────────────────────────────────────────
module MyCircuit_TB;
    reg  A, B, C, D;   // reg: the testbench DRIVES these, so it needs to "hold" values
    wire Y;            // wire: this is an OUTPUT of the DUT, just observed

    // Instantiate the module under test (DUT)
    MyCircuit DUT (.A(A), .B(B), .C(C), .D(D), .Y(Y));

    // Software-computed expected value, for comparison
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
            #10; // let signals settle
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
