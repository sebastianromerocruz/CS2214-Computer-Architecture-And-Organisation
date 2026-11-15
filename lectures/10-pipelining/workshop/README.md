# Pipelining workshop: practice problems

Work in pairs, on paper, **before** you look at anything. Use the pipeline from class: five stages (IF, ID, EX, MEM, WB), every instruction uses every stage, MEM takes one cycle, registers are read in ID and written in WB. A dependent instruction may not read a register in the same cycle (or earlier) than the one in which the writer writes it. A stalled instruction waits in IF, and the stages behind the writer fill with bubbles.

**Conflicts.** Two instructions conflict if they share a register (or the same memory cell) and at least one of them writes it: RAW, WAR or WAW. A pair that only reads is **not** a conflict. For memory, count two accesses as the same cell only when they use the same base register *and* the same offset. A control hazard is a `jeq` or a `jr`.

## 1. Name the conflicts

For each excerpt, list every data conflict (type, the two line numbers, and the register or memory cell), and every control hazard (line number). Write "none" if there are none.

**(a)**
```
1  movi $2, 9
2  add  $3, $2, $2
3  sub  $2, $3, $4
```

**(b)**
```
1  lw   $1, 0($5)
2  addi $5, $5, 2
3  sw   $1, 0($6)
```

**(c)**
```
1  lw   $2, 3($1)
2  sw   $3, 3($1)
3  lw   $4, 3($1)
```

**(d)**
```
1  addi $1, $1, -1
2  jeq  $1, $0, end
3  add  $2, $2, $3
4  addi $3, $3, 1
```

**(e)**
```
1  add  $1, $2, $3
2  add  $4, $2, $3
3  slt  $5, $2, $3
```

## 2. Which reorderings are allowed?

Never swap two instructions that conflict. For excerpts (a), (b) and (e) above, list every valid ordering as a sequence of line numbers (for example `1, 3, 2`), or say there is only the original. In (e), how many are there, and why?

## 3. A pipeline table

The program below runs on the pipeline, with **no forwarding**. Do not include `halt`.

```
    lw   $2, 0($6)        # a
    add  $3, $2, $7       # b
    addi $4, $4, 1        # c
    add  $5, $4, $1       # d
    addi $1, $1, 1        # e
    halt
```

(a) List every RAW conflict (letters, and the register).

(b) Fill in the pipeline table, resolving hazards with stalls. Write the letter of the instruction in each cell, and leave a cell empty for a bubble. How many cycles does the program take?

| Time | IF | ID | EX | MEM | WB |
|:-:|---|---|---|---|---|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |
| 6 | | | | | |
| 7 | | | | | |
| 8 | | | | | |
| 9 | | | | | |
| 10 | | | | | |
| 11 | | | | | |
| 12 | | | | | |
| 13 | | | | | |
| 14 | | | | | |
| 15 | | | | | |
| 16 | | | | | |

(c) Reorder `a` to `e` to need fewer stalls. Which reorderings are not allowed, and which conflict stops each one? Give the order you chose.

(d) Fill in the table again for your reordered program. How many cycles now?

| Time | IF | ID | EX | MEM | WB |
|:-:|---|---|---|---|---|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |
| 6 | | | | | |
| 7 | | | | | |
| 8 | | | | | |
| 9 | | | | | |
| 10 | | | | | |
| 11 | | | | | |
| 12 | | | | | |

(e) *Extension.* Now suppose the machine has full forwarding. How many cycles does the original program take, and how many your reordered one? Which stall is still left, and why?

## 4. Control hazards and branch prediction

On this pipeline a `jeq` is resolved in EX, so a wrong guess costs **2 cycles**. The program counts, in `$2`, the sum of the odd numbers from 7 down to 1.

```
    movi $1, 7
    movi $2, 0
    movi $5, 1
loop:
    jeq  $1, $0, done     # jeq A
    and  $3, $1, $5
    jeq  $3, $0, skip     # jeq B
    add  $2, $2, $1
skip:
    addi $1, $1, -1
    j    loop
done:
    halt
```

(a) Write out the outcome of jeq A each time it runs, and of jeq B each time it runs (T for taken, N for not taken).

(b) What is the total misprediction penalty, in cycles, with (i) always predict taken, (ii) always predict not taken, (iii) dynamic prediction, where each `jeq` predicts what it did last time and starts with not taken?

(c) Which predictor wins here, and why? What pattern of outcomes makes the dynamic predictor lose?

## 5. If there is time: CPI and the clock

(a) A program runs 6000 instructions on the multicycle E20 at 400 MHz: 50% ALU instructions (3 cycles), 30% `lw` and `sw` (5 cycles), 20% `jeq` and `j` (4 cycles). What is the average CPI, and how long does it take?

(b) The same program on the 5-stage pipeline at the same clock, with no stalls at all. How many cycles, how long, and how many times faster?

(c) Now add the stalls: 400 of the `lw` instructions are followed by an instruction that uses the loaded value (forwarding is on, so each costs one cycle), and 300 branches are mispredicted. How many cycles, what CPI, and what speed-up over the multicycle machine?

(d) A pipeline has stage times IF 140 ps, ID 110 ps, EX 260 ps, MEM 200 ps, WB 90 ps. What is the fastest clock it can run at? If EX is split into two stages of 130 ps each, what is the new fastest clock, and what now limits it?
