<h2 align=center>Week VII</h2>

<h1 align=center>Additional Practice Midterm: Solutions</h1>

---

These are the solutions to the [additional practice midterm](additional-practice-exam.md).

---

## 1. Circuits and Verilog (18 points)

### (a) The Verilog module (7 points)

```verilog
module testmodule (A, B, C, Y);
    input A, B, C;
    output Y;
    wire nc, w1, w2;

    assign nc = ~C;
    assign w1 = A & B;
    assign w2 = B | nc;
    assign Y  = w1 ^ w2;
endmodule
```

### (b) The truth table (5 points)

| A | B | C | `nc = ~C` | `w1 = A & B` | `w2 = B \| nc` | `Y = w1 ^ w2` |
|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 1 | 0 | 1 | **1** |
| 0 | 0 | 1 | 0 | 0 | 0 | **0** |
| 0 | 1 | 0 | 1 | 0 | 1 | **1** |
| 0 | 1 | 1 | 0 | 0 | 1 | **1** |
| 1 | 0 | 0 | 1 | 0 | 1 | **1** |
| 1 | 0 | 1 | 0 | 0 | 0 | **0** |
| 1 | 1 | 0 | 1 | 1 | 1 | **0** |
| 1 | 1 | 1 | 0 | 1 | 1 | **0** |

### (c) The register (6 points)

The question describes a register: something that *remembers* a value and only changes it on a clock edge. That tells you the structure before you write any code:

1. The behaviour only happens on the **rising clock edge**, so the block must be triggered by `posedge clk`. (An `always @(*)` block would describe combinational logic that changes whenever any input changes, which is not a register.)
2. The three cases are listed in order of priority, so they translate directly into an `if` / `else if` chain. Reset has priority over everything else, so it must be tested **first**.
3. Registers are updated with the non-blocking assignment `<=`, which is what the question asked for.

```verilog
always @(posedge clk) begin
    if (rst)
        q <= 4'b0000;
    else if (en)
        q <= d;
end
```

---

## 2. Bits and two's complement (14 points)

### (a) Moving three bits (6 points)

Be exact about *which* bits. We number from 0, so the three least significant bits are bits 2, 1 and 0, and the sixth, fifth and fourth least significant positions are bits 5, 4 and 3. The job is to take the group in bits 2 to 0 and slide it up by three places. In an 8-bit picture, with `x = 22`:

```
bit number    7 6 5 4 3 | 2 1 0
x = 22        0 0 0 1 0 | 1 1 0     <- the group to move is 110
result        0 0 1 1 0 | 0 0 0     <- 110 now sits in bits 5, 4, 3
```

There are two jobs, and each has its own operator:

1. **Isolate the three bits.** AND with a mask that has 1s only in the three positions we keep: `0000 0111`, which is 7. `x & 7` throws away everything above bit 2. For `22`, that gives `110 = 6`.
2. **Move them up three places.** Shift left by 3: `<<` moves every bit three positions towards the most significant end and fills the vacated low bits with 0s, which is exactly the "every other bit is 0" requirement. `6 << 3` is `110000 = 48`.

```c
return (x & 7) << 3;
```

### (b) Overflow in 5-bit two's complement (6 points)

**i. `9 + 8`.**

- `9 = 01001` and `8 = 01000`.
- Adding: `01001 + 01000 = 10001`.
- Reading `10001` as 5-bit two's complement: the leading 1 means negative, and the value is `10001 - 100000 = 17 - 32 = -15`.
- The true sum, 17, is larger than the maximum of 15, so it wraps around. This is overflow: two positive numbers have produced a negative result.

The answer is **-15**.

**ii. `-7 + -10`.**

- To write `-7` in 5 bits: `7 = 00111`, invert to `11000`, add one to get `11001`.
- To write `-10`: `10 = 01010`, invert to `10101`, add one to get `10110`.
- Adding: `11001 + 10110 = 1 01111`. This is a 6-bit result. The extra leading 1 is the carry out of the top bit, and we **discard it**, keeping five bits: `01111`.
- Reading `01111` as two's complement: the leading 0 means positive, and the value is 15.
- The true sum, -17, is smaller than the minimum of -16, so it also wraps around. Two negative numbers have produced a positive one.

The answer is **15**.

### (c) -38 in 8-bit two's complement (2 points)

The standard method for negating a two's complement number is to invert every bit and add one. Start with the positive value.

- `38` in binary is `00100110`. (Check: 32 + 4 + 2 = 38.)
- Invert every bit: `11011001`.
- Add one: `11011001 + 1 = 11011010`.
- Convert to hexadecimal, four bits at a time: `1101 = D` and `1010 = A`.

The answer is **0xDA**.

To check, add it to `38 = 0x26`: `0xDA + 0x26 = 0x100`, which is zero once the ninth bit is discarded. That is exactly what a number and its negative should do.

---

## 3. The E15 (18 points)

### (a) Tracing the program (12 points)

| Pass | `Rg1` after the `addi` | `Rg2` after the `subi` | Zero flag | What `jnz` does |
|---|---|---|---|---|
| 1 | 7 | 2 | 0 | flag is 0, so it jumps: `pc <- 4 + 14`, which is 2 |
| 2 | 14 | 1 | 0 | jumps again |
| 3 | 21, which wraps to **5** | 0 | 1 | flag is 1, so it does **not** jump: `pc <- 5` |

- i. `Rg1` = **5**
- ii. `Rg2` = **0**
- iii. `pc` = **6**, the address of the `jmp` that jumps to itself

### (b) Decoding `0011 00 00 1101` (6 points)

```
0011 | 00 | 00 | 1101
opcode  src  dst  imm
```

- The opcode `0011` is `jnz` (the cheat sheet lists `jz` as `0010` and `jnz` as `0011`, which are easy to mix up).
- The two register fields are `00`, but `jnz` ignores its registers, so we write them as `RXX`.
- The immediate is `1101`, which is 13.

The instruction is

```
{jnz, RXX, RXX, 4'b1101}
```

It reads the **zero flag**. If the flag is 0 (the last arithmetic result was not zero), it sets `pc <- pc + 13`, modulo 16. If the flag is 1, it does nothing special, and execution continues at `pc + 1`. It modifies no register and does not change the zero flag; the only thing it can change is the program counter.

If the instruction is at address 5, then `5 + 13 = 18`, and `18 mod 16 = 2`. So it jumps to **address 2**. As in part (a), `+13` modulo 16 is a backward jump of 3: the immediate is not "a jump of 13 forward", and there is no address 18.

---

## 4. Reading E20 programs (18 points)

### (a) The loop (10 points)

Before tracing, work out the address of each instruction and the value of each label. Labels are not instructions: a label simply names the address of the instruction that follows it. `movi` is a pseudo-instruction that takes one address like any other instruction.

| Address | Instruction |
|---|---|
| 0 | `movi $1, 4` |
| 1 | `movi $2, 0` |
| 2 (`top`) | `jeq $1, $0, end` |
| 3 | `add $2, $2, $1` |
| 4 | `addi $1, $1, -2` |
| 5 | `j top` |
| 6 (`end`) | `halt` |

So `top` is **2** and `end` is **6**.

**Tracing.** `$1` starts at 4 and `$2` at 0. At `top`, the `jeq` compares `$1` with `$0` (which is always zero) and jumps to `end` if they are equal.

| Pass | `$1` at the test | `jeq` jumps? | `$2` after `add` | `$1` after `addi` |
|---|---|---|---|---|
| 1 | 4 | no | 0 + 4 = 4 | 2 |
| 2 | 2 | no | 4 + 2 = 6 | 0 |
| 3 | 0 | **yes**, to `end` | | |

At address 6, `halt` is a jump to itself, so the `pc` stays at 6.

- i. `$1` = **0**
- ii. `$2` = **6** (the sum 4 + 2)
- iii. the program counter = **6**, the address of `halt`
- iv. `top` = **2** and `end` = **6**

### (b) The `lw` and `sw` (4 points)

Work out the address of the label `data`, then follow each instruction. The instructions are at addresses 0 to 4, so the first `.fill` is at address 5, and **`data = 5`**. The second `.fill` is at address 6.

- `movi $1, 1` sets `$1 = 1`.
- `lw $2, data($1)` loads from the address `data + $1 = 5 + 1 = 6`. That is the second `.fill`, which holds 20, so `$2 = 20`. (A common slip is to read the cell `data` itself, which holds 10.)
- `addi $2, $2, 3` makes `$2 = 23`.
- `sw $2, data($0)` stores `$2` at the address `data + $0 = 5 + 0 = 5`, so the cell labelled `data` now holds 23. The old value, 10, is overwritten. The cell at address 6 is not touched and still holds 20.

The answers are `$2` = **23** and the memory cell labelled `data` = **23**.

### (c) Machine code for `jeq $1, $0, end` (4 points)

First look up the layout of `jeq` in section 3 of the manual. It uses the two-register format: `opcode (3) | rA (3) | rB (3) | imm (7)`. The opcode for `jeq` is `110`.

**The immediate is special.** The 7-bit field does not hold the address of the label. It holds a **relative** offset, defined so that at run time the processor computes `pc <- pc + 1 + rel_imm`. To make the processor land on `end`, we need

`rel_imm = target - pc - 1`

where `pc` is the address of the `jeq` itself. Here the `jeq` is at address 2 and `end` is address 6, so `rel_imm = 6 - 2 - 1 = 3`. As a 7-bit number, that is `0000011`.

The registers: `rA = $1 = 001` and `rB = $0 = 000`. Putting the fields together:

```
110 | 001 | 000 | 0000011  =  1100010000000011
```

To check by running it forwards: at address 2 the processor computes `2 + 1 + 3 = 6`, which is `end`. Always do this check: it catches nearly every off-by-one in a relative offset.

---

## 5. Writing an E20 program (16 points)

*What does the program need to remember?*

- An **index** into the array, so that `lw` can read each element in turn (`$1`).
- A **count** of the even numbers found so far (`$2`).
- The element currently being examined (`$3`).
- A way to test whether the element is even.

*How do we test for even?* A number is even exactly when its lowest bit is 0. We can isolate the lowest bit with `and`. If we `and` the number with 1, we get 1 for an odd number and 0 for an even one. E20 has no immediate form of `and`, so we put the constant 1 in a register once, before the loop (`$5`).

*What shape is the loop?* The array ends with a 0 (a **sentinel**), and we do not know the length in advance. So we use a sentinel loop: read an element, test whether it is the sentinel *before* doing anything with it, and stop if so. Otherwise process it, advance the index, and jump back to the top.

Putting that together:

```
        movi $1, 0              # $1 := index into nums
        movi $2, 0              # $2 := count of even numbers
        movi $5, 1              # $5 := the mask for the lowest bit

loop:   lw   $3, nums($1)       # $3 := the current element
        jeq  $3, $0, done       # the 0 sentinel ends the loop
        and  $4, $3, $5         # $4 := lowest bit of the element
        jeq  $4, $0, even       # lowest bit 0 means even
        j    next               # odd: nothing to count
even:   addi $2, $2, 1          # count := count + 1
next:   addi $1, $1, 1          # index := index + 1
        j    loop
done:   sw   $2, evens($0)      # store the count
        halt

nums:   .fill 6
        .fill 3
        .fill 10
        .fill 7
        .fill 2
        .fill 0
evens:  .fill 0
```

---

## 6. Translating between E20 assembly and machine code (16 points)

**How to use the manual.** For every instruction, do the same three things: find its entry in section 3, note which **layout** it uses, and write the field names above the bits before filling anything in. Section 3 groups the instructions by layout:

- three-register: `opcode (3) | rA (3) | rB (3) | rC (3) | func (4)`, with opcode `000`;
- two-register: `opcode (3) | register (3) | register (3) | imm (7)`;
- jump: `opcode (3) | imm (13)`.

### (a) Decoding two numbers (8 points)

**i. `0000 1001 1001 0001`.**

Look at the top three bits: `000`. That is the three-register format, so cut the 16 bits as 3, 3, 3, 3, 4:

```
000 | 010 | 011 | 001 | 0001
```

- `rA = 010 = $2`, `rB = 011 = $3`, `rC = 001 = $1`.
- `func = 0001`. The manual's table gives `0001` for **subtract**.

Now the part that trips people up: in the assembly syntax the **destination is written first**, but in the machine code the destination is the **last** register field (`rC`). So the assembly is **`sub $1, $2, $3`**. The manual says that `sub` computes `regSrcA - regSrcB`, so it sets `$1` to `$2 - $3`. It changes no memory cell, and advances the program counter by one.

**ii. `1010 0110 0111 1110`.**

The top three bits are `101`. The manual shows that this opcode is `sw`, in the two-register format. Its fields are `opcode | regAddr | regSrc | imm`, so cut the number as 3, 3, 3, 7:

```
101 | 001 | 100 | 1111110
```

- `regAddr = 001 = $1`. This is the register that holds the **address**.
- `regSrc = 100 = $4`. This is the register whose value is stored.
- The immediate `1111110` has a leading 1, so it is a negative two's complement number. Invert to `0000001` and add one to get `0000010 = 2`, so the immediate is **-2**.

Note the order of the registers: for `sw` (and for `lw`), the first register field is the *address* register, which is not the order they appear in the assembly. The instruction is **`sw $4, -2($1)`**.

What it does: it writes the value of `$4` into the memory cell at address `$1 + (-2)`. Only the low 13 bits of that address count. It does not change any register, and the program counter advances by one.

### (b) Translating two instructions (8 points)

**i. `slti $5, $2, 20`.**

Look up `slti` in section 3. It is a two-register instruction with opcode `111`, and its fields are `opcode | regSrc | regDst | imm`.

- `regSrc` is the register being compared, `$2 = 010`.
- `regDst` is the register that receives the result, `$5 = 101`.
- The immediate is `20`. In 7 bits, `20 = 16 + 4 = 0010100`.

```
111 | 010 | 101 | 0010100  =  1110101010010100
```

**ii. `lw $6, -3($7)`.**

Look up `lw`. It has opcode `100` and the fields `opcode | regAddr | regDst | imm`. In the assembly, `-3($7)` means that the **address** register is `$7`, and `$6` receives the loaded value.

- `regAddr = $7 = 111`.
- `regDst = $6 = 110`.
- The immediate is `-3`. To write it in 7 bits: `3 = 0000011`, invert to `1111100`, add one to get `1111101`.

```
100 | 111 | 110 | 1111101  =  1001111101111101
```

Check that you wrote all 16 digits: `100 + 111 + 110 + 1111101` is 3 + 3 + 3 + 7 = 16 bits.
