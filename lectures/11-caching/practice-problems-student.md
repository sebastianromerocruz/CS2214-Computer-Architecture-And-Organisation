# Lecture 11: Practice Problems (without solutions)

Problems on direct-mapped caches: decoding an address, tracing, sizing, and average access time. The numbers are new: none of these appear in a recitation or homework.

---

# Part A: Direct-mapped caches

## Warmup

### Problem 1

A direct-mapped cache has 8 rows and a block size of 4. For the addresses 150, 21 and 22, find the block, the offset, the row and the tag. Which pairs of these addresses would evict each other's blocks?

## Standard

### Problem 2

A direct-mapped cache has 4 rows and a block size of 4, and starts empty. Trace these reads. For each, give the block, row and tag, say hit or miss, and say what a miss evicts. Then give the hit ratio and classify each miss as compulsory or conflict.

```
20, 21, 45, 22, 9, 46, 21, 37, 20, 24, 45, 25
```

### Problem 3

A cache uses 14-bit addresses, has 16 rows, and a block size of 8 bytes. How many bits are in the offset, the index and the tag? How many bits does one row take, counting the valid bit? What is the total size in bits and in bytes, and how many of those bytes are overhead rather than data?

### Problem 4

A cache hits in 3 ns, and a trip to memory takes 80 ns. Using the hit ratio from problem 12, what is the average access time? What hit ratio is needed to get the average to 10 ns or below? Which helps more: raising the hit ratio from 0.5 to 0.6, or cutting the hit time from 3 ns to 2 ns?

### Problem 5

A program walks a 3 × 4 array of integers stored row by row, starting at address 0, so that element `a[r][c]` sits at address `4r + c`. The cache has 2 rows and a block size of 4. Count the misses for a row-first walk (`a[0][0]`, `a[0][1]`, … `a[2][3]`) and for a column-first walk (`a[0][0]`, `a[1][0]`, `a[2][0]`, `a[0][1]`, …). What happens in the column-first walk if the cache has 4 rows instead?

## Challenge

### Problem 6

A cache has 16-bit addresses, 16-byte blocks, and a number of rows that is a power of two. Including valid bits and tags, its total size is 2192 bits. How many rows does it have?

### Problem 7

A cache has 4 rows and a block size of 8, and a program reads only two different blocks over and over, yet the hit ratio is 0. Write a sequence of six addresses that does this, and explain it. Then say how the cache could be changed, with no other change, so that the same sequence has 4 hits.

### Problem 8

A cache has 4 rows, a block size of 1 and no valid bits. At power-on every stored tag is 0. Which addresses would wrongly produce a hit when they are read for the first time? Why can't we just start every tag at some special value instead of using a valid bit?
