// MyCircuit.v
// Computes: Y = (~A & ~B & C) | ~D
//           Y = ĀB̄C + D̄
//
// Circuit structure:
//   A, B  -- inverted via NOT gates before entering the first AND
//   D     -- inverted via NOT gate before entering the final OR
//   W1    = ~A & ~B        (output of first AND gate)
//   W2    = ~A & ~B & C    (output of second AND gate)
//   Y     = W2 | ~D        (output of final OR gate)

// ────────────────────────────────────────────────
// Structural implementation (gate-level primitives)
// ────────────────────────────────────────────────
module MyCircuit_Structural(
    input  A, B, C, D,
    output Y
);
    wire nA, nB, nD;   // inverted input signals
    wire W1, W2;       // internal wires

    not NA (nA, A);        // nA = ~A
    not NB (nB, B);        // nB = ~B
    not ND (nD, D);        // nD = ~D

    and A1 (W1, nA, nB);   // W1 = ~A & ~B
    and A2 (W2, W1,  C);   // W2 = ~A & ~B & C
    or  O1 (Y,  W2, nD);   // Y  = (~A & ~B & C) | ~D

endmodule


// ────────────────────────────────────────────────
// Continuous-assignment implementation (behavioral)
// ────────────────────────────────────────────────
module MyCircuit_Assign(
    input  A, B, C, D,
    output Y
);
    assign Y = (~A & ~B & C) | ~D;

endmodule


// ────────────────────────────────────────────────
// Testbench — exhaustively checks all 16 input
// combinations and prints a PASS/FAIL for each.
// Run with: iverilog -o MyCircuit MyCircuit.v
//           ./MyCircuit
// ────────────────────────────────────────────────
module MyCircuit_TB;
    reg  A, B, C, D;
    wire Y_struct, Y_assign;

    // Instantiate both implementations
    MyCircuit_Structural DUT_S (.A(A), .B(B), .C(C), .D(D), .Y(Y_struct));
    MyCircuit_Assign     DUT_A (.A(A), .B(B), .C(C), .D(D), .Y(Y_assign));

    // Expected output function, computed in software for comparison
    function expected;
        input a, b, c, d;
        begin
            expected = (~a & ~b & c) | ~d;
        end
    endfunction

    integer errors;

    initial begin
        errors = 0;
        $display("A B C D | Y_struct Y_assign Expected | Status");
        $display("--------|---------------------------|-------");

        // Iterate over all 16 combinations
        {A, B, C, D} = 4'b0000;
        repeat (16) begin
            #10; // wait for signals to settle
            if (Y_struct !== expected(A,B,C,D) || Y_assign !== expected(A,B,C,D)) begin
                $display("%b %b %b %b |    %b        %b         %b      | FAIL",
                         A, B, C, D, Y_struct, Y_assign, expected(A,B,C,D));
                errors = errors + 1;
            end else begin
                $display("%b %b %b %b |    %b        %b         %b      | pass",
                         A, B, C, D, Y_struct, Y_assign, expected(A,B,C,D));
            end
            {A, B, C, D} = {A, B, C, D} + 1;
        end

        $display("--------|---------------------------|-------");
        if (errors == 0)
            $display("All 16 tests passed.");
        else
            $display("%0d test(s) FAILED.", errors);

        $finish;
    end

endmodule
