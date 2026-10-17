# Week VIII: In-Class Practice Problems

## Warmup

### Problem

In the multicycle E20, which states does `sw $2, 3($4)` pass through, in order? How many cycles does it take, and how many would `j 100` take?

---

### Solution

`sw` has an immediate and no register result, so it takes **0, 1, 3, 6, 9**:

- **State 0 (IF):** `IR <- M[pc]`.
- **State 1 (ID):** `A <- R[$4]` and `B <- R[$2]`. The base register is read into `A`, and the value to store is read into `B`.
- **State 3 (EX):** `aluOut <- A + signExtend7(3)`, the memory address.
- **State 6 (MEM):** `M[aluOut] <- B`.
- **State 9 (WB):** there is no register to write, so this state only updates the program counter, `pc <- pc + 1`.

That is **5 cycles**. `j 100` takes **5 cycles too**: 0, 2, 4, 7, 12. It uses the empty MEM state (7) because every instruction passes through every stage, which is what keeps the control module simple.

---

## Standard

### Problem 1

Five `add` instructions are issued back to back into the five-stage pipeline, with no dependencies between them. On which cycle does the first instruction retire, and on which cycle does the fifth? What is the CPI for this sequence, and what would it be without pipelining?

### Solution 1

The first instruction passes IF(1), ID(2), EX(3), MEM(4), WB(5), so it retires on **cycle 5**. Each later instruction enters one cycle behind the previous one and never stalls, so the fifth retires on **cycle 9**. Five instructions in 9 cycles gives **CPI = 9/5 = 1.8**. Without pipelining, each instruction takes 5 cycles alone: 25 cycles, **CPI = 5**.

---

### Problem 2

A machine has a 7-unit single-cycle period. Its multicycle version has a 2-unit period, with every instruction taking 5 cycles. A program runs 400 instructions. Which is faster, single-cycle or multicycle, and by how much? What would a pipelined version with a 2-unit period achieve, counting only the cycles in which the pipeline is full (CPI of about 1)?

### Solution 2

Use time = instructions × CPI × clock period.

- Single-cycle: 400 × 1 × 7 = **2800 units**.
- Multicycle: 400 × 5 × 2 = **4000 units**. Multicycle is *slower*, by a factor of 4000/2800, about 1.43.
- Pipelined: 400 × about 1 × 2 = about **800 units**, about 3.5 times faster than single-cycle.

Multicycle trades a shorter clock for more cycles per instruction and, with these numbers, loses. Pipelining keeps the short clock and brings CPI back to about 1.

---

### Problem 3

Give the state path of `jal 40`, and say what each state does. Then explain why the instruction needs `A` and `B` loaded in ID even though it names no registers.

### Solution 3

The path is **0, 2, 4, 7, 13**.

- **State 0 (IF):** `IR <- M[pc]`.
- **State 2 (ID):** `A <- R[0]`, which is 0, and `B <- zeroExtend13(40)`, which is 40.
- **State 4 (EX):** `aluOut <- A + B`, which is 40, the target.
- **State 7 (MEM):** nothing happens.
- **State 13 (WB):** `R[7] <- pc + 1` (the return address) and `pc <- aluOut`.

The ALU is the only place that can hand a value to `aluOut`, and the WB state takes the new `pc` from `aluOut`. Loading 0 into `A` and the immediate into `B` lets the ALU pass the target through by adding it to 0, so no dedicated jump-target hardware is needed.

---

## Challenge

### Problem

A classmate claims: "With EX-to-EX forwarding, a well-designed pipeline never needs to stall." Evaluate this using the sequence below.

```
lw   $1, 0($2)
add  $3, $1, $1
```

### Solution

Trace the pipeline. `lw` is in IF, ID, EX, MEM, WB in cycles 1 to 5. The `add` is in IF in cycle 2 and could reach ID in cycle 3 and EX in cycle 4.

But the value `lw` loads does not exist until it comes out of **MEM**, at the end of cycle 4. The `add` needs it at the *start* of its EX, which would be cycle 4. EX-to-EX forwarding cannot help, because the value never passes through the ALU as a result: it comes out of memory, one stage later. Even forwarding from MEM straight to EX makes the `add` wait one cycle (EX in cycle 5), so one stall cycle is required.

Forwarding moves a value sideways between stages, but it cannot send it back in time to before it has been computed. The claim is false: forwarding removes most RAW hazards but a `lw` followed immediately by an instruction that uses its result always costs **one stall cycle**.
