# Lecture 10: Practice Problems

Problems on the second half of pipelining (hazards, stalls, forwarding, reordering, branches, structural hazards). Each problem is followed by its solution. The numbers are new: none of these appear in a recitation or homework.

**Conventions for the pipelining problems.** The E20 pipeline has five stages, `IF`, `ID`, `EX`, `MEM`, `WB`. The first instruction is fetched in cycle 1. An instruction reads its registers in `ID` and writes its result in `WB`. A **conflict** is any pair of instructions that share a register or memory cell. A RAW conflict is a **hazard** only if the reader is within three instructions of the writer. Without forwarding, a reader that depends on an earlier instruction waits (in `IF`, with bubbles behind it) until its `ID` can happen in the cycle after the writer's `WB`. With forwarding, an ALU result is available after `EX`, and a loaded value only after `MEM`. A branch is resolved in `EX`, so a wrong guess costs 2 cycles.

---

# Part A: Pipelining

## Warmup

### Problem 1

In which stage does an instruction read its source registers, and in which does it write its result? Use this to explain why the pair below contains a hazard, and say how many instructions apart the writer and the reader must be before the hazard disappears.

```
movi $3, 1
add  $4, $3, $3
```

### Solution 1

An instruction reads registers in **ID** (stage 2) and writes its result in **WB** (stage 5). The `movi` is in `WB` in cycle 5, but the `add` is one instruction behind, so it is in `ID` in cycle 3: it reads `$3` two cycles before `movi` has written it, and gets the old value. That is a RAW hazard.

The reader's `ID` has to fall after the writer's `WB`. Each instruction in between pushes the reader one cycle later, so with no stalls the reader's `ID` is in cycle 2 + (distance). The writer's `WB` is in cycle 5, so the reader is safe only once it is **four instructions behind** the writer. Equivalently, a RAW conflict is a hazard when the reader is within three instructions of the writer.

---

### Problem 2

Six independent instructions go through the five-stage pipeline with no stalls. On which cycle does the first retire, and on which does the sixth? What is the CPI for the six? How many cycles would the six take on a machine that runs each instruction to completion before starting the next, at 5 cycles each?

### Solution 2

The first instruction retires on cycle **5**. Each later instruction retires one cycle after the one before it, so the sixth retires on cycle **10**.

Six instructions in 10 cycles gives **CPI = 10/6, about 1.67**. The CPI falls toward 1 as the program grows, because the 4 cycles of filling the pipeline are paid only once.

Without pipelining: 6 × 5 = **30 cycles**.

---

## Standard

### Problem 3

For each pair of instructions in the excerpt below, list every conflict (RAW, WAR or WAW, with the register), and then say which of the RAW conflicts are hazards in the five-stage pipeline without forwarding. Name the control hazard if there is one. Treat `lw` and `sw` as touching different memory cells.

```
1  lw   $2, 4($6)
2  add  $3, $2, $1
3  sw   $3, 0($6)
4  addi $2, $2, 8
5  jeq  $3, $0, done
```

### Solution 3

Conflicts:

| Pair | Type | Register |
|---|---|---|
| 1 and 2 | RAW | `$2` (1 writes, 2 reads) |
| 1 and 4 | RAW | `$2` (1 writes, 4 reads) |
| 1 and 4 | WAW | `$2` (both write) |
| 2 and 3 | RAW | `$3` |
| 2 and 5 | RAW | `$3` |
| 2 and 4 | WAR | `$2` (2 reads, 4 writes) |

Instructions 1 and 3 both use `$6`, but only as a base register that nobody writes, so they share no conflict, and their memory addresses (4 and 0 plus `$6`) differ.

Which RAW conflicts are hazards: the reader must be within three instructions of the writer. 1 to 2 is one apart, **hazard**. 1 to 4 is three apart, **hazard**. 2 to 3 is one apart, **hazard**. 2 to 5 is three apart, **hazard**. All four are hazards without forwarding. The WAR and WAW conflicts are not hazards here: in-order pipelines write registers in `WB` in program order, so they cannot be reordered.

Control hazard: **instruction 5**, the `jeq`. The next instruction to fetch depends on a result that is not known until `EX`.

---

### Problem 4

Name the forwarding wire that would be used for each RAW dependence in the excerpt below, or say that none is needed. Use `EX/MEM to EX` for a value from the instruction immediately before, and `MEM/WB to EX` for a value from the instruction two before.

```
1  movi $1, 3
2  movi $2, 4
3  add  $3, $1, $2
4  addi $5, $3, 1
```

### Solution 4

- Instruction 3 reads `$1`, written by instruction 1. One instruction sits between them (instruction 2), so the value is two instructions back: **MEM/WB to EX**.
- Instruction 3 reads `$2`, written by instruction 2, the instruction immediately before: **EX/MEM to EX**.
- Instruction 4 reads `$3`, written by instruction 3, immediately before: **EX/MEM to EX**.

With these three wires, the sequence runs with no stalls. Instruction 1 and 2 have no dependences: `movi` reads no registers.

---

### Problem 5

Fill in the cycle in which each instruction is in `ID` and the cycle in which it is in `WB`, first without forwarding and then with forwarding. How many cycles does each version take to retire all five instructions, and how many does a stall-free pipeline take? Assume every instruction needs its source registers at the start of `EX` when forwarding is available.

```
1  movi $1, 6
2  add  $2, $1, $1
3  lw   $3, 0($2)
4  add  $4, $3, $1
5  sw   $4, 1($2)
```

### Solution 5

**Without forwarding.** A reader's `ID` must come after the writer's `WB`.

| Instruction | `ID` | `WB` | Why |
|---|---|---|---|
| 1 `movi` | 2 | 5 | first in the pipeline |
| 2 `add` | 6 | 9 | waits for `$1`, written in cycle 5 |
| 3 `lw` | 10 | 13 | waits for `$2`, written in cycle 9 |
| 4 `add` | 14 | 17 | waits for `$3`, written in cycle 13 |
| 5 `sw` | 18 | 21 | waits for `$4`, written in cycle 17 |

The last instruction retires on cycle **21**.

**With forwarding.** An ALU result is ready after `EX`, so a dependent instruction right behind it does not wait. A load's value is ready only after `MEM`, so the instruction after a `lw` waits one cycle.

| Instruction | `ID` | `WB` | Why |
|---|---|---|---|
| 1 `movi` | 2 | 5 | |
| 2 `add` | 3 | 6 | `$1` forwarded from `EX` |
| 3 `lw` | 4 | 7 | `$2` forwarded from `EX` |
| 4 `add` | 6 | 9 | **one bubble**: `$3` exists only after `lw`'s `MEM` |
| 5 `sw` | 7 | 10 | `$4` forwarded from `EX` |

The last instruction retires on cycle **10**. A stall-free pipeline would finish on cycle 9, so forwarding leaves just the one load-use bubble.

---

### Problem 6

The code below runs on a pipeline with forwarding.

```
1  lw   $1, 0($4)
2  add  $2, $1, $1
3  lw   $3, 1($4)
4  add  $5, $3, $3
5  movi $6, 9
```

How many bubbles does it cost? Reorder the instructions so it costs none, and check that your reordering keeps every conflict in its original order.

### Solution 6

Both loads are followed immediately by an instruction that uses the loaded register. A load-use pair costs one bubble even with forwarding, so the code costs **2 bubbles** (the last instruction retires on cycle 11 instead of 9).

Move the second load up, between the first load and its use:

```
lw   $1, 0($4)
lw   $3, 1($4)
add  $2, $1, $1
add  $5, $3, $3
movi $6, 9
```

Now each `add` has another instruction between it and its load, so each loaded value is ready in time. The last instruction retires on cycle 9: **no bubbles**.

The reordering is legal because the second `lw` conflicts with nothing it jumped over: it reads memory and `$4` and writes `$3`, and the first `add` reads `$1` and writes `$2`. There is no store in the code, so the loads cannot conflict with memory writes. The first `lw` still precedes its reader, and the second `lw` still precedes its reader.

---

### Problem 7

A program executes 500 instructions, 100 of which are `jeq`. Ignore the 4 cycles spent filling the pipeline. For each strategy, give the extra cycles lost to branches and the CPI.

1. Always wait for the branch to resolve (a 2-cycle bubble every time).
2. Guess "not taken", if 70 of the 100 branches are taken.
3. Guess "taken", with the same branches.

### Solution 7

1. **Wait:** every branch costs 2 cycles, so 100 × 2 = **200 extra**. Total 700 cycles, **CPI 1.4**.
2. **Not taken:** the guess is wrong on the 70 taken branches, so 70 × 2 = **140 extra**. Total 640 cycles, **CPI 1.28**.
3. **Taken:** the guess is wrong on the 30 branches that are not taken, so 30 × 2 = **60 extra**. Total 560 cycles, **CPI 1.12**.

Both guesses beat waiting, because a wrong guess costs the same 2 cycles as waiting and a right one costs nothing. "Taken" wins here, because this program's branches are mostly taken, like the back-edge of a loop.

---

### Problem 8

A branch has this history of outcomes (`T` taken, `N` not taken):

```
T N T N T N T N T N
```

1. How many of the ten does each of these predictors get wrong: always not taken, always taken, "same as last time" (starting from "not taken")?
2. Run the two-level predictor with a two-outcome history register, starting at `00` with an empty pattern table, where an unseen history predicts "not taken". Fill in the history, the prediction and whether it was right for each outcome, and say how many it gets wrong.
3. At 2 cycles per wrong guess, how many cycles does each predictor lose?

### Solution 8

1. **Always not taken** is wrong on every `T`: **5**. **Always taken** is wrong on every `N`: **5**. **Same as last time**, starting from `N`: the first outcome is `T` (wrong), and then each outcome is the opposite of the one before it, so it is wrong every time: **10 of 10**. An alternating branch is the worst case for it.

2. The two-level predictor keeps the last two outcomes in the history register and writes each outcome into the table entry it used:

| Run | History | Table says | Branch did | Result |
|:-:|:-:|---|---|---|
| 1 | `00` | unseen: not taken | `T` | **wrong** |
| 2 | `01` | unseen: not taken | `N` | right |
| 3 | `10` | unseen: not taken | `T` | **wrong** |
| 4 | `01` | not taken | `N` | right |
| 5 | `10` | taken | `T` | right |
| 6 | `01` | not taken | `N` | right |
| 7 | `10` | taken | `T` | right |
| 8 | `01` | not taken | `N` | right |
| 9 | `10` | taken | `T` | right |
| 10 | `01` | not taken | `N` | right |

It is wrong **2 times**, both while learning. After taken, not taken, the branch is always taken, and after not taken, taken, it is always not taken. The history register sees that, and the one-bit predictor cannot.

3. At 2 cycles per wrong guess: always not taken **10**, always taken **10**, same as last time **20**, two-level **4**.

---

### Problem 9

Suppose the E20's instruction memory and data memory were one single memory with one door. A program has 400 instructions, and 100 of them are `lw` or `sw`. Which pair of stages collide, and in which cycle does a `lw` collide with an instruction fetch? With a 2 ns clock, how long does the program take on this machine, and how long with separate instruction and data memories? Ignore pipeline fill.

### Solution 9

`IF` fetches an instruction from memory, and `MEM` reads or writes data in memory. A `lw` is in `MEM` in cycle 4 if it was fetched in cycle 1. In cycle 4 the instruction three behind it is in `IF`, so the two want the one memory door at once: a **structural hazard**.

The data access finishes an instruction, so it goes first, and the fetch waits one cycle. Every `lw` and `sw` therefore costs one bubble: 100 bubbles for the 100 memory instructions.

- One shared memory: 400 + 100 = 500 cycles, 500 × 2 ns = **1000 ns**, CPI 1.25.
- Separate memories (or separate instruction and data caches): 400 cycles, 400 × 2 ns = **800 ns**, CPI 1.

The shared design is 25 percent slower than the separate one. That cost is why real machines split the first-level cache into an instruction cache and a data cache.

---

## Challenge

### Problem 10

A machine runs 1000 instructions. Version A has a 9 ns clock and no pipelining, so its CPI is 1. Version B has a 2 ns clock and a five-stage pipeline, and hazards add 300 stall cycles to the 1000 instructions. How much faster is B? What speedup would B reach if it had no stalls at all, and what does the gap between the two numbers tell you?

### Solution 10

A: 1000 × 1 × 9 = **9000 ns**.

B: (1000 + 300) × 2 = **2600 ns**. Speedup = 9000 / 2600, about **3.46**.

With no stalls B would take 1000 × 2 = 2000 ns, a speedup of 9000 / 2000 = **4.5**, which is simply the ratio of the clock periods, 9 / 2.

The gap between 4.5 and 3.46 is what hazards cost. Pipelining shortens the clock by a factor of 4.5, but 300 stall cycles on 1000 instructions give an effective CPI of 1.3, so a quarter of the possible gain is lost. Forwarding, reordering and branch prediction all exist to close that gap.

---
