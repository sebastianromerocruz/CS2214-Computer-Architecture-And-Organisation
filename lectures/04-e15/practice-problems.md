# Week 2 (cont.): In-Class Practice Problems

## Warmup

### Problem

For each E15 instruction below, give a one-sentence English description of what it does. Be specific about any effect on registers, the zero flag, and the program counter.

1. `{mov, Rg3, Rg1, 4'b0000}`
2. `{addi, RXX, Rg2, 4'b0101}`
3. `{cmp, Rg1, Rg3, 4'b0000}`
4. `{jz, RXX, RXX, 4'b0011}`

---

### Solution

1. **`{mov, Rg3, Rg1, 4'b0000}`** — Copies the value currently in `Rg3` into `Rg1`. The immediate field is present (every instruction is 12 bits) but ignored, since `mov` reads its second operand from `src`, not `imm`. `zFlag` is untouched.
2. **`{addi, RXX, Rg2, 4'b0101}`** — Adds the immediate value `0101` (5) to `Rg2`, storing the result back in `Rg2`. `src` is `RXX` because the immediate variant never reads a source register. `zFlag` is set to 1 if the result is zero, 0 otherwise.
3. **`{cmp, Rg1, Rg3, 4'b0000}`** — Compares `Rg3` (the value being read from `src`) to `Rg1` (`dst`) by subtracting internally and setting `zFlag` to 1 if they're equal, 0 otherwise. Neither register is modified — that's what makes it `cmp` and not `sub`.
4. **`{jz, RXX, RXX, 4'b0011}`** — If `zFlag` is currently 1, adds `0011` (3) to the program counter; otherwise `pc` just advances by 1 as normal. Both `src` and `dst` are `RXX` since jump instructions don't touch any register.

**Answer:** (1) `Rg1 = Rg3`. (2) `Rg2 += 5`, `zFlag` updated. (3) compare `Rg3` to `Rg1`, `zFlag` updated, no register written. (4) conditional jump: `pc += 3` if `zFlag == 1`, else `pc += 1`.

---

## Standard

### Problem

Trace the following E15 program by hand. Assume all registers and the zero flag start at the value shown, and that the program counter starts at 0.

```
/*          OPCODE  SRC   DST   IMMDATA */
myROM[0] = {movi,   RXX,  Rg0,  4'b0011};   // Rg0 = 3
myROM[1] = {movi,   RXX,  Rg1,  4'b0001};   // Rg1 = 1
myROM[2] = {sub,    Rg1,  Rg0,  4'b0000};   // Rg0 -= Rg1
myROM[3] = {cmpi,   RXX,  Rg0,  4'b0000};   // compare Rg0 to 0
myROM[4] = {jnz,    RXX,  RXX,  4'b1110};   // if zFlag == 0, jump back (pc += -2, i.e. wraps to addr 2)
myROM[5] = {jmp,    RXX,  RXX,  4'b0000};   // end of program
```

What is the final value of `Rg0`, and how many times does the instruction at address 2 execute?

---

### Solution

Trace cycle by cycle, tracking `pc`, `Rg0`, `Rg1`, and `zFlag`:

| pc | instruction | effect | Rg0 after | zFlag after | next pc |
|---|---|---|---|---|---|
| 0 | `movi Rg0, 3` | `Rg0 = 3` | 3 | unchanged | 1 |
| 1 | `movi Rg1, 1` | `Rg1 = 1` | 3 | unchanged | 2 |
| 2 | `sub Rg1, Rg0` | `Rg0 -= Rg1` → 3−1 | 2 | 0 (result ≠ 0) | 3 |
| 3 | `cmpi Rg0, 0` | compare 2 to 0 | 2 | 0 (not equal) | 4 |
| 4 | `jnz, imm=1110` | zFlag=0 → jump: `pc = 4 + 1110₂` | 2 | 0 | `0100+1110 = 0010` → **2** |
| 2 | `sub Rg1, Rg0` | `Rg0 -= Rg1` → 2−1 | 1 | 0 | 3 |
| 3 | `cmpi Rg0, 0` | compare 1 to 0 | 1 | 0 | 4 |
| 4 | `jnz` | zFlag=0 → jump back to 2 | 1 | 0 | 2 |
| 2 | `sub Rg1, Rg0` | `Rg0 -= Rg1` → 1−1 | 0 | **1** (result = 0) | 3 |
| 3 | `cmpi Rg0, 0` | compare 0 to 0 | 0 | **1** (equal) | 4 |
| 4 | `jnz` | zFlag=1 → do **not** jump, pc = pc+1 | 0 | 1 | 5 |
| 5 | `jmp` (self) | infinite loop | 0 | 1 | 5 (forever) |

The immediate field `4'b1110` is the 4-bit pattern for −2 in this addition (since `pc + imm` is computed with ordinary 4-bit wraparound arithmetic): `0100 + 1110 = 0010` (i.e. 4 + 14 = 18, which wraps mod 16 to 2). This is exactly the same wraparound mechanic covered in lecture: a "backward" jump is encoded as adding a large immediate value that overflows back down to the intended address.

**Answer:** `Rg0` ends at **0**, and the instruction at address 2 executes **3 times**.

---

## Challenge

### Problem

Write a complete E15 program that uses `Rg3` to count down from 15 to 0, then stops. You must use a loop — don't just write 16 instructions that each decrement once (there isn't room in 16 words of ROM for that plus the setup and the halt anyway).

---

### Solution

The shape is: initialize `Rg3` to 15, decrement it each pass through the loop, check whether it's hit 0, and jump back if not — then halt with the mandatory self-jump.

```
/*          OPCODE  SRC   DST   IMMDATA */
myROM[0] = {movi,   RXX,  Rg3,  4'b1111};   // Rg3 = 15
myROM[1] = {cmpi,   RXX,  Rg3,  4'b0000};   // compare Rg3 to 0
myROM[2] = {jz,     RXX,  RXX,  4'b0011};   // if Rg3 == 0, skip ahead to the halt at address 5
myROM[3] = {subi,   RXX,  Rg3,  4'b0001};   // Rg3 -= 1
myROM[4] = {jmp,    RXX,  RXX,  4'b1101};   // jump back to address 1 (4 + 1101₂ = 4+13 = 17 mod 16 = 1)
myROM[5] = {jmp,    RXX,  RXX,  4'b0000};   // halt
```

Trace the loop body once to confirm the shape works: `Rg3 = 15` → compare to 0 (not equal, `zFlag=0`) → `jz` doesn't fire → `Rg3` becomes 14 → `jmp` back to address 1. Same four instructions repeat, `Rg3` ticking down 15, 14, 13, ..., 1, 0. The moment `Rg3` hits 0, `cmpi` sets `zFlag=1`, and this time `jz` *does* fire, jumping straight to address 5's halt instead of decrementing past 0.

Two details worth getting right when you construct a jump immediate yourself, both easy to get subtly wrong without tracing by hand:

- **The `jz` skip distance is counted from the jump's own address, not from the loop start.** From address 2, landing on the halt at address 5 needs `imm = 5 − 2 = 3 = 0011`. It's tempting to instead count "how many instructions am I skipping" (just the one `subi` at address 3, plus the `jmp` at 4 — two instructions) and use `imm = 2` by mistake, which actually lands you back on address 4 — right back into the loop instead of out of it. The immediate is a distance in *addresses from here*, not a count of instructions skipped over.
- **The backward jump's immediate comes from the same wraparound-subtraction trick as the Standard problem's `jnz` target.** From address 4, targeting address 1: `imm` must satisfy `4 + imm ≡ 1 (mod 16)`, i.e. `imm = 1 − 4 = −3 ≡ 13 = 1101₂` in 4-bit two's complement.

**Answer:** the program above counts `Rg3` down from 15 to 0 and halts — five instructions of loop machinery plus the mandatory closing `jmp`, well within the 16-word ROM.
