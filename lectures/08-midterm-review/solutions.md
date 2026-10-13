<h2 align=center>Week VII</h2>

<h1 align=center>Midterm Review: Solutions</h1>

---

These are the solutions to the [practice questions](assets/Practice%20Questions_v1.pdf). Each one gives the answer and then the reasoning behind it, so that you can see *how* to get there and not only what the answer is. When you compare with your own work, look at the reasoning first: a right answer reached by a shaky method is worth checking just as much as a wrong one.

---

## 1. Circuits and Verilog

### (a) The Verilog module

Work through the circuit one gate at a time, from the inputs to the output, and give every gate's output a name. Reading the picture:

- `A` and `B` go into an AND gate (the flat-backed, rounded shape). Call its output `w1`.
- `C` goes through a NOT gate (the triangle with a small circle on its tip). Call its output `nc`.
- `w1` and `nc` go into the last gate. Look closely at it: it is the curved OR shape, **with a small circle on its output**. A small circle on a gate's output means "negate what comes out", exactly like the circle on the NOT gate. So this gate is an OR followed by a NOT, which is called a **NOR**. Its output is `Y`.

Each gate becomes one `assign` statement, using the bitwise operators the question asked for (`&` for AND, `~` for NOT, `|` for OR):

```verilog
module testmodule (A, B, C, Y);
    input A, B, C;
    output Y;
    wire w1, nc;

    assign w1 = A & B;
    assign nc = ~C;
    assign Y  = ~(w1 | nc);
endmodule
```

Because the circuit is purely combinational (there is no memory in it), every output is a function of the current inputs only, and `assign` statements are the right tool. A shorter version that skips the named wires, `assign Y = ~((A & B) | ~C);`, is equally correct, but naming the wires makes it harder to lose track of a gate. What you must not do is use `always`, `reg` or a sequential assignment: the question rules them out.

### (b) The truth table

Do not try to compute `Y` for all eight rows in your head at once. Add a column for each wire you named in part (a), fill each column using only the columns to its left, and read `Y` off the last one. It is slower per row but far less error-prone.

| A | B | C | `w1 = A & B` | `nc = ~C` | `w1` OR `nc` | `Y` = NOT of that |
|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 | 1 | **0** |
| 0 | 0 | 1 | 0 | 0 | 0 | **1** |
| 0 | 1 | 0 | 0 | 1 | 1 | **0** |
| 0 | 1 | 1 | 0 | 0 | 0 | **1** |
| 1 | 0 | 0 | 0 | 1 | 1 | **0** |
| 1 | 0 | 1 | 0 | 0 | 0 | **1** |
| 1 | 1 | 0 | 1 | 1 | 1 | **0** |
| 1 | 1 | 1 | 1 | 0 | 1 | **0** |

The answer to submit is the last column: `0, 1, 0, 1, 0, 1, 0, 0`.

Read the finished column as a sentence: `Y` is 1 exactly when `C` is 1 **and** `A` and `B` are not both 1. In symbols, `Y = C & ~(A & B)`. You can see it in the table: every `Y = 1` row has `C = 1`, and the only `C = 1` row where `Y` is 0 is `A = B = 1`. If your column does not match a sentence like that, one of your rows has a slip.

---

## 2. Bits and two's complement

### (a) The C function

Start by being exact about *which* bits. "Least significant" means counting from the right, and the least significant bit is the first. So the **fourth** least significant bit is bit number 3, and the **third** is bit number 2, if we number the bits from 0 as we usually do. In an 8-bit picture, `x = 39 = 0010 0111`:

```
bit number   7 6 5 4 | 3 2 1 0
x = 39       0 0 1 0 | 0 1 1 1
                       ^ ^
                       bits 3 and 2 are the ones to toggle
```

*What toggles a bit?* The XOR operator. `bit ^ 1` flips the bit (0 becomes 1, 1 becomes 0), and `bit ^ 0` leaves it alone. So we need to XOR `x` with a mask that has 1s in exactly the two positions we want to flip, and 0s everywhere else: `0000 1100`, which is 12.

```c
unsigned int flipbits_fourth_third(unsigned int x) {
    return x ^ 12;
}
```

**Checking against the two examples.** `39 = 100111`; XOR with `001100` gives `101011`, which is 43. And `51 = 110011`; XOR with `001100` gives `111111`, which is 63. Always check against the examples the question gives you if you have time.

### (b) Two's complement addition

First find out what the number system can hold. With 7 bits in two's complement, the numbers run from `-2^6 = -64` up to `2^6 - 1 = 63`. Any true sum outside that range **overflows**, and the machine does not report an error: it simply keeps the low 7 bits, so the answer wraps around.

**i. `39 + 27`.** The true sum is 66, which is above 63, so we expect overflow. In binary, with 7 bits:

```
  0100111   (39)
+ 0011011   (27)
---------
  1000010
```

The leading bit is 1, so the 7-bit result reads as a negative number. Its value is `-64 + 2 = -62`. (Another way to see it: the wrapped answer is the true sum minus 128, and `66 - 128 = -62`.) The tell-tale sign of this kind of overflow is that **two positive numbers gave a negative result**.

**The answer is -62.**

**ii. `-25 + -50`.** The true sum is -75, which is below -64, so this overflows too. First write each number in 7-bit two's complement: invert the bits of the positive number and add 1.

- `25 = 0011001`; invert to `1100110`; add 1 to get `1100111`.
- `50 = 0110010`; invert to `1001101`; add 1 to get `1001110`.

```
  1100111   (-25)
+ 1001110   (-50)
---------
 10110101   (an 8-bit result: drop the leftmost carry)
```

Keeping only 7 bits leaves `0110101`, which is `32 + 16 + 4 + 1 = 53`. (Check: `-75 + 128 = 53`.) This time **two negative numbers gave a positive result**, which is the other tell-tale sign.

**The answer is 53.**

---

## 3. The E15

For all three parts, remember what the E15 is made of: instructions are 12 bits, split as opcode (4 bits), source register (2), destination register (2) and immediate (4). The `pc` and the registers are **4 bits wide**, so addresses run from 0 to 15, and any result that would be 16 or more wraps around modulo 16. The cheat sheet tells you what each instruction does.

### (a) Where does the program go after address 11?

race the four instructions, keeping track of the one thing that matters: the **zero flag**, because `jz` looks at it.

- Address 8: `movi Rg3, 1101` puts 13 in `Rg3`.
- Address 9: `movi Rg3, 1000` replaces it with 8. (The first `movi` does not matter in the end: it was overwritten.)
- Address 10: `cmp Rg3, Rg3` compares `Rg3` with **itself**. Anything is equal to itself, so the zero flag is set to **1**, whatever `Rg3` held.
- Address 11: `jz` with immediate `1111`. The flag is set, so the jump **is taken**: `pc <- pc + 15`.

The `pc` is 4 bits wide, so the new value is `(11 + 15) mod 16 = 26 mod 16 =` **10**. (If you were tempted to answer 26: that address does not exist. The E15's `pc` has 4 bits, so it can only name addresses 0 to 15.)

**The answer is address 10.** A jump of `+15` modulo 16 is the same as a jump of `-1`, which is how the E15 jumps backward without negative numbers. So this program jumps back to the `cmp`, runs the `jz` again, and loops between addresses 10 and 11 forever.

### (b) Where does the program go after address 10?

Trace it in the same way:

- Address 8: `movi Rg0, 0100` puts 4 in `Rg0`.
- Address 9: `cmp Rg0, Rg2` compares `Rg0` (which is 4) with `Rg2`, whose value **we are not told**. So we cannot say whether the zero flag ends up set or not.
- Address 10: `jnz` with immediate `0001`, which jumps to `pc + 1` if the zero flag is **not** set.

So there are two cases. If `Rg2` is not 4, the flag is 0, the jump is taken, and the `pc` becomes `10 + 1 = 11`. If `Rg2` is 4, the flag is 1, the jump is not taken, and the `pc` simply advances to `10 + 1 = 11`. 

**The answer is address 11, in both cases.** This is a trick question. It looks as if it cannot be determined, because we don't know `Rg2`, but a jump of `+1` lands on the very same instruction that falling through would reach, so the unknown flag makes no difference. The right thing to write is "11, and here's why it doesn't matter".

### (c) Interpreting 1100 00 01 0101

Cut the 12 bits up in the order opcode, source, destination, immediate, and look each field up on the cheat sheet:

```
1100 | 00  | 01  | 0101
opcode src   dst   imm
```

- The opcode `1100` is **`sub`** (the cheat sheet lists `sub` as `1100` and `subi` as `1101`, which are easy to mix up).
- The source register `00` is `Rg0`.
- The destination register `01` is `Rg1`.
- The last four bits, `0101`, are not an operand of `sub`: it takes **both** of its operands from registers, so the immediate field plays no part in what it does. (The cheat sheet writes `4'b0000` there for a clean encoding, but `sub` ignores the field.)

The instruction is `{sub, Rg0, Rg1, 4'b0101}`, read as `sub Rg0, Rg1`. Both of its registers are used, so there is no `RXX` in this one.

It subtracts the value in `Rg0` from the value in `Rg1` and stores the result in `Rg1`, so `Rg1 <- Rg1 - Rg0`. As with every arithmetic instruction, it also sets the **zero flag**: to 1 if the result is 0, and to 0 otherwise. The program counter advances normally, `pc <- pc + 1`. No other register is changed.

---

## 4. Reading E20 programs

### (a) The loop

Before tracing, work out the address of each instruction and the value of each label. Labels are not instructions: a label simply names the address of the instruction that follows it.

| Address | Instruction |
|---|---|
| 0 | `movi $1, 1` |
| 1 | `movi $2, 1` |
| 2 | `movi $3, 5` |
| 3 (`label1`) | `addi $1, $1, 1` |
| 4 | `add $2, $2, $2` |
| 5 | `jeq $1, $3, label2` |
| 6 | `j label1` |
| 7 (`label2`) | `nop` |
| 8 | `halt` |

So `label1` is **3** and `label2` is **7**.

**Tracing.** `$1` starts at 1, `$2` at 1 and `$3` at 5. Each pass through the loop adds 1 to `$1` and **doubles** `$2` (adding a number to itself is the same as multiplying it by 2). Then the `jeq` compares `$1` with `$3` and jumps to the end if they are equal.

| Pass | `$1` after `addi` | `$2` after `add` | `jeq $1, $3` jumps? |
|---|---|---|---|
| 1 | 2 | 2 | no (2 is not 5) |
| 2 | 3 | 4 | no |
| 3 | 4 | 8 | no |
| 4 | 5 | 16 | **yes**, to `label2` |

At `label2`, the `nop` does nothing, and `halt` stops the program.

- `$1` = **5**
- `$2` = **16** (that is, `2^4`: it was doubled four times)

**A tip for loops like this.** Write the table, don't try to hold the values in your head. The question is really "how many times does the loop run?", and the table answers that by finding the pass where the `jeq` fires. It also catches the common slip of counting five passes (from 1 up to 5) instead of four: the `addi` runs *before* the comparison, so `$1` reaches 5 on the fourth pass.

### (b) The `movi`, `lw`, `and` and `or`

Work out the address of each label first. The program's five instructions are at addresses 0 to 4, so the first `.fill` is at address 5 and **`label1 = 5`**. The second `.fill` is at address 6, so **`label3 = 6`**. The memory therefore holds 29 at address 5 and 13 at address 6.

Now follow each instruction:

- `movi $1, label1` puts the **value of the label** into `$1`. The value of a label is an address, so `$1 = 5`. This does **not** read memory: `movi` loads a constant, and here the constant is the number 5. (The common slip is to answer 29, the value stored *at* `label1`. That would need a `lw`.)
- `lw $2, label3($0)` loads from the address `label3 + $0 = 6 + 0 = 6`, which holds 13. So `$2 = 13`.
- `and $3, $1, $2` computes `5 & 13`. In binary, `0101 & 1101 = 0101`, which is **5**. (`and` keeps a bit only where both numbers have a 1.)
- `or $4, $1, $2` computes `5 | 13`. In binary, `0101 | 1101 = 1101`, which is **13**. (`or` keeps a bit where either number has a 1.)

**The answers:** `$1` = **5**, `$3` = **5**, `$4` = **13**. (And `$2` = 13, if you wanted to check your own work.)

---

## 5. Writing an E20 program

Do not start by writing instructions. Start by deciding what the program has to keep track of, and then what shape the loop has.

*What does the program need to remember?* There are three arrays, and for each one we need to know which element we are on. The simplest way to do that is with **three pointers**, one per array, each holding the address of the current element: `$1` for `first`, `$2` for `second` and `$3` for `third`. A `lw` or `sw` with an offset of 0 then reads or writes the element that a pointer names, and "move to the next element" is just adding 1 to the pointer.

*How do we know when to stop?* The question tells us the arrays are the same length, and that each ends with a single `0`. A value that marks the end of the data is called a **sentinel**. So we use a sentinel loop: read an element of `first`, test whether it is the sentinel **before** doing anything with it, and stop if so. Otherwise, process it, advance the pointers, and jump back to the top. (We only need to test one array, since they have the same length.)

*What is the work of one pass?* Read `first[i]`, read `second[i]`, subtract, and store the result into `third[i]`. E20's `sub` takes three registers, so the two elements go in two registers and the difference in a third.

Putting that together:

```
        movi $1, first          # $1 := address of first[0]
        movi $2, second         # $2 := address of second[0]
        movi $3, third          # $3 := address of third[0]

loop:   lw   $4, 0($1)          # $4 := first[i]
        jeq  $4, $0, done       # the 0 sentinel ends the loop
        lw   $5, 0($2)          # $5 := second[i]
        sub  $6, $4, $5         # $6 := first[i] - second[i]
        sw   $6, 0($3)          # third[i] := $6
        addi $1, $1, 1          # move to the next element of first
        addi $2, $2, 1          # move to the next element of second
        addi $3, $3, 1          # move to the next element of third
        j    loop
done:   halt
```

(The arrays themselves are provided by the question, so we don't write them.)
