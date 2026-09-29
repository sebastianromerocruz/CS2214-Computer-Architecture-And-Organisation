# Week V: In-Class Practice Problems

## Warmup

### Problem

For each 16-bit E20 machine code word below, give the equivalent assembly instruction and a one-sentence English description of what it does.

1. `1110100110000101`
2. `1010010101111100`
3. `0110000000000101`

---

### Solution

1. **`1110100110000101`** — split as `111` `010` `011` `0000101`. Opcode `111` is `slti`, so this is a two-register instruction: source `$2` (`010`), destination `$3` (`011`), immediate `5` (`0000101`). **`slti $3, $2, 5`** — sets `$3` to 1 if `$2 < 5`, otherwise 0.
2. **`1010010101111100`** — split as `101` `001` `010` `1111100`. Opcode `101` is `sw`, address register `$1` (`001`), stored register `$2` (`010`), immediate `1111100` is `-4` in 7-bit two's complement (flip `0000100`, add 1). **`sw $2, -4($1)`** — writes the value in `$2` into the memory cell at address `$1 - 4`.
3. **`0110000000000101`** — split as `011` `0000000000101`. Opcode `011` is `jal`, no register fields, 13-bit absolute target `5`. **`jal 5`** — stashes the address of the next instruction into `$7`, then jumps to address 5.

**Answer:** (1) `slti $3, $2, 5`, sets `$3 = ($2 < 5)`. (2) `sw $2, -4($1)`, writes `$2` to `memory[$1 - 4]`. (3) `jal 5`, saves the return address in `$7` and jumps to address 5.

---

## Standard

### Problem

Trace the following E20 program by hand. Assume all registers start at 0.

```
movi $1, 0
movi $2, 3
loop:
    jeq  $1, $2, done
    addi $3, $3, 5
    addi $1, $1, 1
    j    loop
done:
    halt
```

What are the values of the labels `loop` and `done`? What is the final value of `$3`, and how many times does the loop body (the `addi $3, ...` line) execute?

---

### Solution

Count addresses first: `movi $1,0` is 0, `movi $2,3` is 1, so **`loop = 2`**; `jeq` is 2, `addi $3,...` is 3, `addi $1,...` is 4, `j loop` is 5, so **`done = 6`**.

Trace cycle by cycle, tracking `$1`, `$2`, and `$3`:

| Pass | `jeq $1, $2, done` fires? | `$3` after | `$1` after |
|---|---|---|---|
| setup | — | 0 | 0 (then `$2 = 3`) |
| 1 | no (`0 ≠ 3`) | 5 | 1 |
| 2 | no (`1 ≠ 3`) | 10 | 2 |
| 3 | no (`2 ≠ 3`) | 15 | 3 |
| 4 | **yes** (`3 = 3`) | 15 | 3 |

This is the "test-before-body" shape from lecture: the loop checks *before* running the body each time, so the moment `$1` reaches `3`, the body is skipped entirely on that pass — it runs exactly 3 times, not 4.

**Answer:** `loop = 2`, `done = 6`, `$3` ends at **15**, and the loop body executes **3 times**.

---

## Challenge

### Problem

Two memory cells, labeled `a` and `b`, hold unknown values. Write a complete E20 program that stores `1` into a memory cell labeled `result` if the value at `a` is less than or equal to the value at `b`, and `0` otherwise, then halts. You'll need `.fill` to declare `a`, `b`, and `result`, and you'll need to build `<=` out of `slt` and `jeq` — there's no `<=` instruction.

Test your program by hand with `a = 3, b = 7` (expect `result = 1`), then again with `a = 7, b = 3` (expect `result = 0`).

---

### Solution

The `<=` trick from lecture: `$1 <= $2` is the same as "`$2 < $1` is false." So load both values, test `b < a` with `slt`, and jump to the `result = 1` case exactly when that test comes back false.

```
main:
    lw   $1, a($0)
    lw   $2, b($0)
    slt  $3, $2, $1      # $3 = 1 if b < a, else 0
    jeq  $3, $0, yes     # $3 == 0 means "b < a" was false, i.e. a <= b
    movi $4, 0
    sw   $4, result($0)
    halt
yes:
    movi $4, 1
    sw   $4, result($0)
    halt

a:
    .fill 3
b:
    .fill 7
result:
    .fill 0
```

Code occupies addresses 0 through 9, so `a = 10`, `b = 11`, `result = 12`.

With `a = 3, b = 7`: `$1 = 3`, `$2 = 7`. `slt $3, $2, $1` asks "is `7 < 3`?" — no, so `$3 = 0`. `jeq $3, $0, yes` fires (`$3 == $0`), landing on `yes`: `result = 1`. Correct, since `3 <= 7`.

With `a = 7, b = 3`: `$1 = 7`, `$2 = 3`. `slt $3, $2, $1` asks "is `3 < 7`?" — yes, so `$3 = 1`. `jeq $3, $0, yes` does **not** fire (`$3 ≠ $0`), so execution falls through to `result = 0`. Correct, since `7 > 3`.

Worth checking by hand once: the tie case, `a = 5, b = 5`. `slt $3, $2, $1` asks "is `5 < 5`?" — no, so `$3 = 0`, `jeq` fires, `result = 1`. Ties correctly count as `<=`, for the same reason the lecture's `slt`-then-`jeq` pattern always does: the test is phrased as the *negation* of strict `<`, and a tie makes strict `<` false in both directions.

**Answer:** the program above; `result` ends up `1` when `a ≤ b` (including ties) and `0` when `a > b`. Verified against all three cases (`3,7` → `1`; `7,3` → `0`; `5,5` → `1`) with `scripts/e20_sim.py program.e20 --mem 12:12`.
