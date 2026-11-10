# Lecture 10: Practice Problems (without solutions)

Problems on the second half of pipelining (hazards, stalls, forwarding, reordering, branches, structural hazards) and on direct-mapped caches (decoding, tracing, sizing, average time). The numbers are new: none of these appear in a recitation or homework.

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

### Problem 2

Six independent instructions go through the five-stage pipeline with no stalls. On which cycle does the first retire, and on which does the sixth? What is the CPI for the six? How many cycles would the six take on a machine that runs each instruction to completion before starting the next, at 5 cycles each?

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

### Problem 4

Name the forwarding wire that would be used for each RAW dependence in the excerpt below, or say that none is needed. Use `EX/MEM to EX` for a value from the instruction immediately before, and `MEM/WB to EX` for a value from the instruction two before.

```
1  movi $1, 3
2  movi $2, 4
3  add  $3, $1, $2
4  addi $5, $3, 1
```

### Problem 5

Fill in the cycle in which each instruction is in `ID` and the cycle in which it is in `WB`, first without forwarding and then with forwarding. How many cycles does each version take to retire all five instructions, and how many does a stall-free pipeline take? Assume every instruction needs its source registers at the start of `EX` when forwarding is available.

```
1  movi $1, 6
2  add  $2, $1, $1
3  lw   $3, 0($2)
4  add  $4, $3, $1
5  sw   $4, 1($2)
```

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

### Problem 7

A program executes 500 instructions, 100 of which are `jeq`. Ignore the 4 cycles spent filling the pipeline. For each strategy, give the extra cycles lost to branches and the CPI.

1. Always wait for the branch to resolve (a 2-cycle bubble every time).
2. Guess "not taken", if 70 of the 100 branches are taken.
3. Guess "taken", with the same branches.

### Problem 8

A branch has this history of outcomes (`T` taken, `N` not taken):

```
T N T N T N T N T N
```

1. How many of the ten does each of these predictors get wrong: always not taken, always taken, "same as last time" (starting from "not taken")?
2. Run the two-level predictor with a two-outcome history register, starting at `00` with an empty pattern table, where an unseen history predicts "not taken". Fill in the history, the prediction and whether it was right for each outcome, and say how many it gets wrong.
3. At 2 cycles per wrong guess, how many cycles does each predictor lose?

### Problem 9

Suppose the E20's instruction memory and data memory were one single memory with one door. A program has 400 instructions, and 100 of them are `lw` or `sw`. Which pair of stages collide, and in which cycle does a `lw` collide with an instruction fetch? With a 2 ns clock, how long does the program take on this machine, and how long with separate instruction and data memories? Ignore pipeline fill.

## Challenge

### Problem 10

A machine runs 1000 instructions. Version A has a 9 ns clock and no pipelining, so its CPI is 1. Version B has a 2 ns clock and a five-stage pipeline, and hazards add 300 stall cycles to the 1000 instructions. How much faster is B? What speedup would B reach if it had no stalls at all, and what does the gap between the two numbers tell you?

# Part B: Direct-mapped caches

## Warmup

### Problem 11

A direct-mapped cache has 8 rows and a block size of 4. For the addresses 150, 21 and 22, find the block, the offset, the row and the tag. Which pairs of these addresses would evict each other's blocks?

## Standard

### Problem 12

A direct-mapped cache has 4 rows and a block size of 4, and starts empty. Trace these reads. For each, give the block, row and tag, say hit or miss, and say what a miss evicts. Then give the hit ratio and classify each miss as compulsory or conflict.

```
20, 21, 45, 22, 9, 46, 21, 37, 20, 24, 45, 25
```

### Problem 13

A cache uses 14-bit addresses, has 16 rows, and a block size of 8 bytes. How many bits are in the offset, the index and the tag? How many bits does one row take, counting the valid bit? What is the total size in bits and in bytes, and how many of those bytes are overhead rather than data?

### Problem 14

A cache hits in 3 ns, and a trip to memory takes 80 ns. Using the hit ratio from problem 12, what is the average access time? What hit ratio is needed to get the average to 10 ns or below? Which helps more: raising the hit ratio from 0.5 to 0.6, or cutting the hit time from 3 ns to 2 ns?

### Problem 15

A program walks a 3 × 4 array of integers stored row by row, starting at address 0, so that element `a[r][c]` sits at address `4r + c`. The cache has 2 rows and a block size of 4. Count the misses for a row-first walk (`a[0][0]`, `a[0][1]`, … `a[2][3]`) and for a column-first walk (`a[0][0]`, `a[1][0]`, `a[2][0]`, `a[0][1]`, …). What happens in the column-first walk if the cache has 4 rows instead?

## Challenge

### Problem 16

A cache has 16-bit addresses, 16-byte blocks, and a number of rows that is a power of two. Including valid bits and tags, its total size is 2192 bits. How many rows does it have?

### Problem 17

A cache has 4 rows and a block size of 8, and a program reads only two different blocks over and over, yet the hit ratio is 0. Write a sequence of six addresses that does this, and explain it. Then say how the cache could be changed, with no other change, so that the same sequence has 4 hits.

### Problem 18

A cache has 4 rows, a block size of 1 and no valid bits. At power-on every stored tag is 0. Which addresses would wrongly produce a hit when they are read for the first time? Why can't we just start every tag at some special value instead of using a valid bit?
