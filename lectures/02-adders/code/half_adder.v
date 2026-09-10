module half_adder(A, B, Sum, Carry);
    input A, B;
    output Sum, Carry;

    xor X1 (Sum, A, B);
    and A1 (Carry, A, B);

    // assign Sum = A ^ B;
    // assign Carry = A & B;
endmodule
