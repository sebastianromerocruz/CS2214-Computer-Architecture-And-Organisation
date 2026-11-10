# Lecture 10: Practice Problems

Problems on the second half of pipelining (hazards, stalls, forwarding, reordering, branches, structural hazards) and on direct-mapped caches (decoding, tracing, sizing, average time). Each problem is followed by its solution. The numbers are new: none of these appear in a recitation or homework.

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

# Part B: Direct-mapped caches

## Warmup

### Problem 11

A direct-mapped cache has 8 rows and a block size of 4. For the addresses 150, 21 and 22, find the block, the offset, the row and the tag. Which pairs of these addresses would evict each other's blocks?

### Solution 11

Block = address // 4, offset = address % 4, row = block % 8, tag = block // 8.

| Address | Block | Offset | Row | Tag |
|---|---|---|---|---|
| 150 | 37 | 2 | 5 | 4 |
| 21 | 5 | 1 | 5 | 0 |
| 22 | 5 | 2 | 5 | 0 |

Addresses 21 and 22 are in the same block (block 5), so after one miss both are in the cache: no conflict between them.

Address 150 goes to row 5 as well, but with tag 4. Row 5 can hold only one block, so 150 and 21 (or 150 and 22) **evict each other**: same row, different tags.

---

## Standard

### Problem 12

A direct-mapped cache has 4 rows and a block size of 4, and starts empty. Trace these reads. For each, give the block, row and tag, say hit or miss, and say what a miss evicts. Then give the hit ratio and classify each miss as compulsory or conflict.

```
20, 21, 45, 22, 9, 46, 21, 37, 20, 24, 45, 25
```

### Solution 12

| Address | Block | Row | Tag | Result | Notes |
|---|---|---|---|---|---|
| 20 | 5 | 1 | 1 | MISS | row 1 empty |
| 21 | 5 | 1 | 1 | HIT | same block as 20 |
| 45 | 11 | 3 | 2 | MISS | row 3 empty |
| 22 | 5 | 1 | 1 | HIT | |
| 9 | 2 | 2 | 0 | MISS | row 2 empty |
| 46 | 11 | 3 | 2 | HIT | same block as 45 |
| 21 | 5 | 1 | 1 | HIT | |
| 37 | 9 | 1 | 2 | MISS | evicts block 5 (tag 1) |
| 20 | 5 | 1 | 1 | MISS | evicts block 9 (tag 2) |
| 24 | 6 | 2 | 1 | MISS | evicts block 2 (tag 0) |
| 45 | 11 | 3 | 2 | HIT | |
| 25 | 6 | 2 | 1 | HIT | same block as 24 |

**6 hits out of 12: hit ratio 0.5.**

Classification of the 6 misses:

- 20, 45, 9, 37 and 24 are **compulsory**: the first visit to blocks 5, 11, 2, 9 and 6.
- The second 20 is a **conflict** miss: block 5 had been in the cache, but block 9 evicted it from row 1, while row 0 never held anything.

---

### Problem 13

A cache uses 14-bit addresses, has 16 rows, and a block size of 8 bytes. How many bits are in the offset, the index and the tag? How many bits does one row take, counting the valid bit? What is the total size in bits and in bytes, and how many of those bytes are overhead rather than data?

### Solution 13

- Offset: log₂(8) = **3** bits.
- Index: log₂(16) = **4** bits.
- Tag: 14 − 4 − 3 = **7** bits.

One row: 1 valid bit + 7 tag bits + 64 data bits (8 bytes) = **72 bits**.

Total: 16 × 72 = **1152 bits = 144 bytes**.

Data alone is 16 × 8 = 128 bytes, so the overhead is 144 − 128 = **16 bytes**, about 11 percent of the data size.

---

### Problem 14

A cache hits in 3 ns, and a trip to memory takes 80 ns. Using the hit ratio from problem 12, what is the average access time? What hit ratio is needed to get the average to 10 ns or below? Which helps more: raising the hit ratio from 0.5 to 0.6, or cutting the hit time from 3 ns to 2 ns?

### Solution 14

Average time = hit time + (1 − hit ratio) × memory time.

With a hit ratio of 0.5: 3 + 0.5 × 80 = **43 ns**.

For 10 ns or below: 3 + (1 − h) × 80 ≤ 10, so (1 − h) ≤ 7/80 = 0.0875, and **h ≥ 0.9125**. The cache needs to hit about 91 percent of the time.

Raising the hit ratio from 0.5 to 0.6 saves 0.1 × 80 = **8 ns**. Cutting the hit time from 3 ns to 2 ns saves only **1 ns**. A miss is so much more expensive than a hit that a little hit ratio is worth far more than a little hit time.

---

### Problem 15

A program walks a 3 × 4 array of integers stored row by row, starting at address 0, so that element `a[r][c]` sits at address `4r + c`. The cache has 2 rows and a block size of 4. Count the misses for a row-first walk (`a[0][0]`, `a[0][1]`, … `a[2][3]`) and for a column-first walk (`a[0][0]`, `a[1][0]`, `a[2][0]`, `a[0][1]`, …). What happens in the column-first walk if the cache has 4 rows instead?

### Solution 15

Each array row is exactly one block: block 0 is addresses 0 to 3, block 1 is 4 to 7, block 2 is 8 to 11. With 2 cache rows, row = block % 2: blocks 0 and 2 both go to cache row 0, and block 1 goes to row 1.

**Row-first:** addresses 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11. The first access to each block misses, and the other three hit: **3 misses, 9 hits**.

**Column-first:** addresses 0, 4, 8, 1, 5, 9, 2, 6, 10, 3, 7, 11. This visits blocks 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2. Block 1 sits alone in row 1, so after its first miss it hits every time. Blocks 0 and 2 keep evicting each other from row 0, so every access to them misses. That is 3 + 3 + 3 = **9 misses, 3 hits**.

With **4 rows**, blocks 0, 1 and 2 go to rows 0, 1 and 2 and never collide, so the column-first walk also has only **3 misses**. The order of the walk matters when the cache is small, because of conflicts between blocks that the walk revisits.

---

## Challenge

### Problem 16

A cache has 16-bit addresses, 16-byte blocks, and a number of rows that is a power of two. Including valid bits and tags, its total size is 2192 bits. How many rows does it have?

### Solution 16

Let the number of rows be 2^k. The offset takes 4 bits (16-byte blocks), the index takes k bits, and the tag takes 16 − 4 − k = 12 − k bits. One row is 1 + (12 − k) + 128 = 141 − k bits, so the total is 2^k × (141 − k).

Try values of k:

| k | Rows | Bits per row | Total |
|---|---|---|---|
| 3 | 8 | 138 | 1104 |
| 4 | 16 | 137 | **2192** |
| 5 | 32 | 136 | 4352 |

The total is 2192 bits for **16 rows**. The totals grow with k, so no other power of two matches.

---

### Problem 17

A cache has 4 rows and a block size of 8, and a program reads only two different blocks over and over, yet the hit ratio is 0. Write a sequence of six addresses that does this, and explain it. Then say how the cache could be changed, with no other change, so that the same sequence has 4 hits.

### Solution 17

Pick two blocks that map to the same row: block 1 and block 5 (since 1 % 4 = 5 % 4 = 1). Block 1 holds addresses 8 to 15, and block 5 holds 40 to 47. Alternate between them:

```
8, 40, 9, 41, 10, 42
```

Every access finds the other block in row 1 with the wrong tag (tag 0 for block 1, tag 1 for block 5), so every access misses: **0 hits out of 6**, even though rows 0, 2 and 3 are empty throughout. The two blocks tow each other.

Change: make the cache **8 rows**. Now block 1 goes to row 1 and block 5 goes to row 5, so they no longer share a row. Only the first access to each block misses: 8 and 40. The other four hit: **4 hits out of 6**. (Next lecture we fix the same problem without adding rows, by letting a block choose between two seats in a row.)

---

### Problem 18

A cache has 4 rows, a block size of 1 and no valid bits. At power-on every stored tag is 0. Which addresses would wrongly produce a hit when they are read for the first time? Why can't we just start every tag at some special value instead of using a valid bit?

### Solution 18

With a block size of 1, block = address, row = address % 4 and tag = address // 4. A row that has never been written holds tag 0, so a first read hits wrongly whenever the address's tag is 0: addresses **0, 1, 2 and 3**. The cache would return whatever junk the cell holds at power-on, labelled as the value for that address.

We cannot reserve a special tag, because a tag is just a number from 0 up to the largest possible one, and every one of those values is a real tag that some address can have. There is no value left over to mean "empty". The valid bit adds that missing meaning in one extra bit per row: a row with the bit at 0 never counts as a hit, whatever its tag says.
