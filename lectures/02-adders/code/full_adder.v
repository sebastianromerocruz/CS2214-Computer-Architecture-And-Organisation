module full_adder(A, B, Cin, Sum, Cout);
    input  A, B, Cin;
    output Sum, Cout;
    wire   S1, C1, C2;

    // half adder 1: A and B
    assign S1 = A ^ B;
    assign C1 = A & B;

    // half adder 2: S1 and Cin
    assign Sum = S1 ^ Cin;
    assign C2  = S1 & Cin;

    // combine the two carries
    assign Cout = C1 | C2;
endmodule
