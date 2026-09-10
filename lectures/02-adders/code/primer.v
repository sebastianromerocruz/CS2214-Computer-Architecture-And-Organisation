module my_circuit(A, B, Y);
    input A, B;
    output Y;

    assign Y = A & B; // continuous
    and A1 (Y, A, B); // structural
endmodule
