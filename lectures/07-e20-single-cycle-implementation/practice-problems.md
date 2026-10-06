# Week VI: In-Class Practice Problems

## Warmup

### Problem

For the instruction `sub $4, $1, $2` (opcode `000`, three-register format), which control signal decides whether the ALU's other input comes from `SRC1dataOut` or from a sign-extended immediate: and what value does it take for this instruction?

---

### Solution

`MUXalu` is the signal in question. `sub`, like every three-register-format instruction, needs the *other register's value* as its second operand, not an immediate: so `MUXalu` selects `SRC1dataOut` (the "reg" option), the same as `add`, `and`, `or`, and `slt`.

**Answer:** `MUXalu` selects the register path (`SRC1dataOut`), because `sub` is a three-register-format instruction with no immediate field to draw from.

---

## Standard

### Problem

Trace `lw $2, 4($1)` through the single-cycle datapath. Assume `$1` currently holds `10`. List, in order, every port and mux whose value this instruction determines, and state what ends up in `$2`.

---

### Solution

1. **Fetch.** `pc` addresses `instrAddr`; `instrOut` yields the encoded `lw $2, 4($1)` (two-register format: opcode for `lw`, `regAddr = $1`, `regDst = $2`, `imm7 = 4`).
2. **Decode.** Fields split out: `rA = $1` (this is `regAddr`), `rB = $2` (this is `regDst`), `imm7 = 4`.
3. **Register read.** `rA` (`$1`) drives `SRC2` (through `MUXrf`); the register file outputs `SRC2dataOut = 10`.
4. **Control.** Opcode for `lw` sets: `MUXalu = imm` (use the immediate, not `SRC1dataOut`), `FUNCalu = +`, `MUXdst = rB` (destination is `$2`, per the two-register format's convention), `MUXtgt = memory` (the write-back value comes from `dataOut`, not the ALU directly), `WErf = 1`, `WEdmem = 0`.
5. **ALU.** Computes `SRC2dataOut + sign-extend(imm7) = 10 + 4 = 14`.
6. **Memory access.** ALU's output (`14`) drives `dataAddr`; `dataOut` returns whatever value is stored at memory cell 14.
7. **Write-back.** `MUXtgt` selects `dataOut` (not the ALU's `14` itself: that was only the *address*); `MUXdst` selects `$2` as the destination register name; since `WErf = 1`, `$2 <- Mem[14]` commits on the clock edge.

**Answer:** `$2` ends up holding whatever value is stored at memory cell 14 (`= $1 + 4 = 10 + 4`): **not** the address `14` itself. The single most common mistake on this trace is stopping at the ALU's output and calling *that* the answer; the ALU only ever computes the *address* for `lw`, and a second read through `MUXtgt` is what actually retrieves the value.

---

## Challenge

### Problem

Suppose a classmate proposes simplifying the datapath by deleting `MUXalu` entirely and always sending `SRC1dataOut` as the ALU's other input: reasoning that "we could just modify the assembler to translate `addi $1, $2, 5` into `movi $3, 5` followed by `add $1, $2, $3`, using an extra scratch register instead of an immediate path in hardware." Evaluate this proposal: would it work, and what would it cost?

---

### Solution

It would *work*, in the sense that the resulting program computes the same thing: but it costs more than it saves, on every axis that matters for a single-cycle design:

- **It doubles the instruction count for every immediate operation.** Every `addi`, `slti`, `lw`, `sw`, and `jeq` in every program written so far (all of Week 5's assembly programs) would need an extra `movi` beforehand, since none of them currently reserve a "scratch" register for this purpose. This isn't a hardware-simplicity win if it triples program size and instruction-fetch traffic.
- **It burns a general-purpose register as a permanent scratch slot**, silently reducing the seven usable registers (`$1`–`$7`) to six for any program that wants to use this trick: exactly the kind of "constant juggling to make room" problem that motivated moving from E15 to E20 in the first place (Week 4, Section 1).
- **It doesn't actually save hardware.** `MUXalu` is one small 2-to-1 mux; removing it saves a handful of gates. Meanwhile, the sign-extension circuit (`sign-extend(imm7)`) is *still needed* elsewhere (nowhere, actually: the whole point of proposing this was to route around ever needing to sign-extend `imm7` at all), but the `movi` pseudo-instruction *itself* still needs `addi $reg, $0, imm`, which uses `MUXalu` internally at the assembler level. So the mux doesn't disappear, it just moves: from "explicit hardware, used once per `addi`" to "implicit in every `movi` expansion," which was the mechanism being proposed for removal in the first place. The proposal doesn't eliminate the immediate path; it just makes it indirect and more expensive.

**Answer:** The proposal is correct but not cheaper: it trades one small mux (and one wire, `sign-extend(imm7)`, which is genuinely tiny in gate count) for a permanently reserved register and roughly double the instruction count for every immediate-using instruction in every program ever written for this ISA. This is a good "cost isn't just gate count" discussion: hardware minimisation has to weigh against program size, register pressure, and instruction-fetch bandwidth, not just literal transistor count.
