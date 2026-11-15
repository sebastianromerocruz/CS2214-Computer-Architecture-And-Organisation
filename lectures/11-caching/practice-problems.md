# Lecture 11: Practice Problems

Problems on direct-mapped caches: decoding an address, tracing, sizing, and average access time. Each problem is followed by its solution. The numbers are new: none of these appear in a recitation or homework.

---

# Part A: Direct-mapped caches

## Warmup

### Problem 1

A direct-mapped cache has 8 rows and a block size of 4. For the addresses 150, 21 and 22, find the block, the offset, the row and the tag. Which pairs of these addresses would evict each other's blocks?

### Solution 1

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

### Problem 2

A direct-mapped cache has 4 rows and a block size of 4, and starts empty. Trace these reads. For each, give the block, row and tag, say hit or miss, and say what a miss evicts. Then give the hit ratio and classify each miss as compulsory or conflict.

```
20, 21, 45, 22, 9, 46, 21, 37, 20, 24, 45, 25
```

### Solution 2

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

### Problem 3

A cache uses 14-bit addresses, has 16 rows, and a block size of 8 bytes. How many bits are in the offset, the index and the tag? How many bits does one row take, counting the valid bit? What is the total size in bits and in bytes, and how many of those bytes are overhead rather than data?

### Solution 3

- Offset: log₂(8) = **3** bits.
- Index: log₂(16) = **4** bits.
- Tag: 14 − 4 − 3 = **7** bits.

One row: 1 valid bit + 7 tag bits + 64 data bits (8 bytes) = **72 bits**.

Total: 16 × 72 = **1152 bits = 144 bytes**.

Data alone is 16 × 8 = 128 bytes, so the overhead is 144 − 128 = **16 bytes**, about 11 percent of the data size.

---

### Problem 4

A cache hits in 3 ns, and a trip to memory takes 80 ns. Using the hit ratio from problem 12, what is the average access time? What hit ratio is needed to get the average to 10 ns or below? Which helps more: raising the hit ratio from 0.5 to 0.6, or cutting the hit time from 3 ns to 2 ns?

### Solution 4

Average time = hit time + (1 − hit ratio) × memory time.

With a hit ratio of 0.5: 3 + 0.5 × 80 = **43 ns**.

For 10 ns or below: 3 + (1 − h) × 80 ≤ 10, so (1 − h) ≤ 7/80 = 0.0875, and **h ≥ 0.9125**. The cache needs to hit about 91 percent of the time.

Raising the hit ratio from 0.5 to 0.6 saves 0.1 × 80 = **8 ns**. Cutting the hit time from 3 ns to 2 ns saves only **1 ns**. A miss is so much more expensive than a hit that a little hit ratio is worth far more than a little hit time.

---

### Problem 5

A program walks a 3 × 4 array of integers stored row by row, starting at address 0, so that element `a[r][c]` sits at address `4r + c`. The cache has 2 rows and a block size of 4. Count the misses for a row-first walk (`a[0][0]`, `a[0][1]`, … `a[2][3]`) and for a column-first walk (`a[0][0]`, `a[1][0]`, `a[2][0]`, `a[0][1]`, …). What happens in the column-first walk if the cache has 4 rows instead?

### Solution 5

Each array row is exactly one block: block 0 is addresses 0 to 3, block 1 is 4 to 7, block 2 is 8 to 11. With 2 cache rows, row = block % 2: blocks 0 and 2 both go to cache row 0, and block 1 goes to row 1.

**Row-first:** addresses 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11. The first access to each block misses, and the other three hit: **3 misses, 9 hits**.

**Column-first:** addresses 0, 4, 8, 1, 5, 9, 2, 6, 10, 3, 7, 11. This visits blocks 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2. Block 1 sits alone in row 1, so after its first miss it hits every time. Blocks 0 and 2 keep evicting each other from row 0, so every access to them misses. That is 3 + 3 + 3 = **9 misses, 3 hits**.

With **4 rows**, blocks 0, 1 and 2 go to rows 0, 1 and 2 and never collide, so the column-first walk also has only **3 misses**. The order of the walk matters when the cache is small, because of conflicts between blocks that the walk revisits.

---

## Challenge

### Problem 6

A cache has 16-bit addresses, 16-byte blocks, and a number of rows that is a power of two. Including valid bits and tags, its total size is 2192 bits. How many rows does it have?

### Solution 6

Let the number of rows be 2^k. The offset takes 4 bits (16-byte blocks), the index takes k bits, and the tag takes 16 − 4 − k = 12 − k bits. One row is 1 + (12 − k) + 128 = 141 − k bits, so the total is 2^k × (141 − k).

Try values of k:

| k | Rows | Bits per row | Total |
|---|---|---|---|
| 3 | 8 | 138 | 1104 |
| 4 | 16 | 137 | **2192** |
| 5 | 32 | 136 | 4352 |

The total is 2192 bits for **16 rows**. The totals grow with k, so no other power of two matches.

---

### Problem 7

A cache has 4 rows and a block size of 8, and a program reads only two different blocks over and over, yet the hit ratio is 0. Write a sequence of six addresses that does this, and explain it. Then say how the cache could be changed, with no other change, so that the same sequence has 4 hits.

### Solution 7

Pick two blocks that map to the same row: block 1 and block 5 (since 1 % 4 = 5 % 4 = 1). Block 1 holds addresses 8 to 15, and block 5 holds 40 to 47. Alternate between them:

```
8, 40, 9, 41, 10, 42
```

Every access finds the other block in row 1 with the wrong tag (tag 0 for block 1, tag 1 for block 5), so every access misses: **0 hits out of 6**, even though rows 0, 2 and 3 are empty throughout. The two blocks tow each other.

Change: make the cache **8 rows**. Now block 1 goes to row 1 and block 5 goes to row 5, so they no longer share a row. Only the first access to each block misses: 8 and 40. The other four hit: **4 hits out of 6**. (Next lecture we fix the same problem without adding rows, by letting a block choose between two seats in a row.)

---

### Problem 8

A cache has 4 rows, a block size of 1 and no valid bits. At power-on every stored tag is 0. Which addresses would wrongly produce a hit when they are read for the first time? Why can't we just start every tag at some special value instead of using a valid bit?

### Solution 8

With a block size of 1, block = address, row = address % 4 and tag = address // 4. A row that has never been written holds tag 0, so a first read hits wrongly whenever the address's tag is 0: addresses **0, 1, 2 and 3**. The cache would return whatever junk the cell holds at power-on, labelled as the value for that address.

We cannot reserve a special tag, because a tag is just a number from 0 up to the largest possible one, and every one of those values is a real tag that some address can have. There is no value left over to mean "empty". The valid bit adds that missing meaning in one extra bit per row: a row with the bit at 0 never counts as a hit, whatever its tag says.
