<h2 align=center>Week I</h2>

<h1 align=center>Introduction & Logic Gates</h1>

<p align=center><strong><em>Song of the day</strong>: <a href="https://youtu.be/8vEahj1dd2E?si=xolYZwJgVFHl8Qtl"><strong><u>Arcturus Beaming</u></strong></a> by The Crane Wives (2024)</em></p>

<br>

## Sections

1. [**How Does a Computer Work?**](#0)
2. [**Gates, or: How I Started Worrying About What My Computer Does**](#1)
    1. [**The `NOT` Gate**](#1-1)
    2. [**The `AND` Gate**](#1-2)
    3. [**The `OR` Gate**](#1-3)
    4. [**`XOR`, `NAND`, and `NOR`**](#1-4)
3. [**Boolean Algebraic Notation**](#2)
4. [**Circuit Analysis: Deriving Expressions and Truth Tables**](#3)
5. [**Representing Numbers in Binary**](#4)
6. [**Hexadecimal**](#5)

<br>

<a id="0"></a>

## How Does a Computer Work?

Ask someone off the street and you'll hear things like "electricity" or "there's a chip in there." None of these are exactly wrong, but none of them explain the _mechanism_ of a computer. The goal of this class is to build a complete picture: from the physics of electrons (kind of) all the way up to the software you interact with every day.

Consider, for example, what it takes to run your run-of-the-mill 1114 Python script. You don't need to know how Python is dealing with memory in order to write it—much less how a transistor works. By the same token, the transistor doesn't need to know what Python is. And yet they compose seamlessly, layer by layer, with each one speaking a completely different language than the one above it. The idea that makes this possible is something called **abstraction**:

> **Abstraction**: Layers that hide their complexity behind a clean interface and trust that the layer beneath it works. 

When you write `x + y` in Python, you are standing on top of an interpreter, an assembler, an instruction set, a datapath, a handful of logic gates, and somewhere at the bottom, a few transistors switching on and off. None of those layers know about each other—they really don't have to.

It's kind of how in a café, the cook doesn't need to know what the barista knows in order to make coffee, and the customer doesn't need to know what either of them know in order to order their lunch and afternoon espresso. That kind of thing.

<a id="fg-0"></a>

<p align=center>
    <img src="assets/abstraction-stack.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure 0</strong>: The abstraction stack from programmer to physics—each layer hides its complexity from the ones above it. This course lives in the four layers in the middle.
    </sub>
</p>

This course lives in the middle of this stack—**digital circuits**, **logic**, **microarchitecture**, and **architecture**. This is the layer where the interesting engineering decisions get made: how instructions are encoded, how a datapath is wired, how memory is organised. To understand where we're starting, it helps to trace the journey from source code down to hardware once:

1. A programmer writes **application software** in a high-level language like C or Python.
2. A **compiler** translates that source code into **assembly language**—a human-readable form of the machine's native instruction set. All Game Boy, NES, and SNES games were built using this language.
3. An **assembler** translates assembly into **machine language**—raw binary, the actual bytes the processor reads. This is not human readable.
4. The **processor** executes those bytes by switching billions of tiny transistors on and off.

### Gates, or: How I Started Worrying About What My Computer Does

A **transistor** is a semiconductor device that acts as an electrically controlled switch: apply enough voltage to the control terminal and current flows; remove it and current stops. That binary on/off behaviour is exactly what is represented by 1 and 0, `true` and `false`.

A **logic gate** is what you get when you wire a small number of transistors together in a specific configuration: a circuit element that takes binary inputs and produces a single binary output according to a fixed rule. 

They are: `AND`, `OR`, `NOT`. That's it. And yet, everything your CPU does—running a video game, encrypting a file, rendering a webpage, depriving a small town of water by querying a data centre—is ultimately just those three operations, composed in very large numbers. A modern chip contains tens of _billions_ of these switches on a piece of silicon the size of a fingernail.

That's the thing, the crux at the heart of this course: the gap between "flip a switch" and "run a program" is enormous, and crossing it is what this course is about. The gates are where we begin.

<br>

<a id="1"></a>

## Logic Gates

Every gate can be described in three different ways, and you'll encounter all three in the wild:

- **Circuit diagrams** in datasheets and textbooks
- **Boolean equations** in papers and design documents, and 
- **Truth tables** in verification and testing. 

They contain exactly the same information, just expressed in different "dialects" of the same language. Being able to code-switch between them is less about memorisation and more about having enough practice that the translation becomes automatic.

For each gate below, all three representations are given side by side. Try reading the truth table from the equation, and the equation from the diagram, until they feel like the same thing. You'll know the first three of these by heart.

<a id="1-1"></a>

### The `NOT` Gate

The `NOT` gate—also called an **inverter**—is the right place to start because it's the only gate with a single input ("unary"), and it introduces a symbol you'll see constantly (ad nauseam if you're an EE major): 

The **inversion bubble**. That small circle on the output is what makes the gate a `NOT` gate. Without it, the triangle is just a wire—it passes the signal through unchanged. The bubble is the negation. You'll see it reappear on `NAND`, `NOR`, and in the middle of complex schematics wherever a signal needs to be flipped.

**Circuit Diagram:**

<a id="fg-1"></a>

<p align=center>
    <img src="assets/gate-not.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure I</strong>: The <code>NOT</code> gate—a triangle with an inversion bubble on the output.
    </sub>
</p>

**Boolean equation:**

```
Y = Ā   (also written  Y = A',  Y = ¬A,  Y = ~A)
```

**Truth table:**

| A | Y |
|---|---|
| 0 | 1 |
| 1 | 0 |

<br>

<a id="1-2"></a>

### The `AND` Gate

The `AND` gate outputs 1 only when **all** of its inputs are 1.

A useful way to think of it is as an "enable" gate: If `A` is the signal you want to pass through, and `B` is an enable line, then `A AND B` passes `A` only when `B` is high and blocks it when `B` is low. Nearly every conditional enable in hardware has `AND` somewhere at its core.

**Circuit Diagram** (flat back, rounded/D-shaped front):

<a id="fg-2"></a>

<p align=center>
    <img src="assets/gate-and.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure II</strong>: The <code>AND</code> gate—flat back, rounded D-shaped front.
    </sub>
</p>

**Boolean equation:**

```
Y = AB   (also written  Y = A·B,  Y = A×B,  Y = A∧B)
```

The "juxtaposition notation" `AB` (no operator symbol) means AND, by direct analogy with multiplication in algebra—`AND` really does behave like multiplication over 0 and 1 (i.e. the product is only 1 when both operands are 1).

**Truth table:**

| A | B | Y |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

<br>

<a id="1-3"></a>

### The `OR` Gate

The `OR` gate outputs 1 when **at least one** input is 1. The #1 thing to remember here is that it differs from everyday English "or", which is often exclusive: "soup or salad" usually means "pick one." 

Boolean `OR`, on the other hand, is *inclusive*: it's 1 when one input is 1, when the other is 1, and also when both are 1. `OR` is what we call the "merge" primitive—if any one of several conditions holds, the output is active.

**Circuit Diagram** (curved back, pointed front):

<a id="fg-3"></a>

<p align=center>
    <img src="assets/gate-or.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure III</strong>: The <code>OR</code> gate—curved back, pointed front.
    </sub>
</p>

**Boolean equation:**

```
Y = A + B   (also written  Y = A∨B)
```

The `+` symbol for `OR` is borrowed from arithmetic. The analogy holds in a clamped way: `OR` behaves like addition, except that in Boolean algebra 1 + 1 = 1 rather than 2 (this has to do with the binary nature of these things, which don't allow symbols for any number higher than 1).

**Truth table:**

| A | B | Y |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

<br>

<a id="1-4"></a>

### `XOR`, `NAND`, and `NOR`

Three more gates appear often enough to have their own symbols. Two of them have a property so useful they could as well get their own lecture, tbh.

**`XOR`** ("exclusive OR") outputs 1 when its two inputs *differ*—exactly one of them is 1. This is the version of "or" that matches everyday English most closely. More importantly for us, `XOR` turns out to be the "addition primitive": 

> When you add two single bits...
> - The sum bit is exactly their `XOR`, and
> - The carry-out 1 is their `AND`.

We'll see this again when we build [**adders**](/lectures/02-adders).

<a id="fg-4"></a>

<p align=center>
    <img src="assets/gate-xor.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure IV</strong>: The <code>XOR</code> gate—an <code>OR</code> body with an extra curved line at the back.
    </sub>
</p>

```
Y = A ⊕ B
```

| A | B | Y |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

<br>

**`NAND`** (literally `NOT AND`) is an `AND` gate with an inversion bubble on the output—its output is 0 only when *all* inputs are 1. 

Note below that the overbar in the Boolean equation covers the *entire* AND expression, not just one variable:

```
Y = ~(AB)   i.e., NOT of the whole product
```

<a id="fg-5"></a>

<p align=center>
    <img src="assets/gate-nand.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure V</strong>: The <code>NAND</code> gate—an <code>AND</code> body with an inversion bubble on the output.
    </sub>
</p>

| A | B | Y |
|---|---|---|
| 0 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

<br>

**`NOR`** (literally `NOT OR`) is an `OR` gate with an inversion bubble on the output—its output is 1 only when *all* inputs are 0:

```
Y = ~(A+B)   i.e., NOT of the whole sum
```

<a id="fg-6"></a>

<p align=center>
    <img src="assets/gate-nor.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure VI</strong>: The <code>NOR</code> gate—an <code>OR</code> body with an inversion bubble on the output.
    </sub>
</p>

| A | B | Y |
|---|---|---|
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 0 |

<br>

So why are `NAND` and `NOR` so important? It's actually kind of hard to believe:

> **`NAND` and `NOR` are universal gates.** Any logic function—no matter how complex—can be built using *only* NAND gates, or alternatively *only* NOR gates. This is kind of insane when you think about it: one gate type is sufficient to express _literally_ all of Boolean logic. In chip fabrication it matters practically, because a design that uses only one cell type is simpler and cheaper to manufacture.

<br>

<a id="2"></a>

<a id="2-1"></a>

## Boolean Algebraic Notation

We now have six gates and a symbol for each. The problem is that as soon as a circuit involves more than, like, a handful of gates, diagrams become unmanageable—there's simply no clean way to reason about whether two different circuits compute the same function or to simplify a function to use fewer gates without a way to write it down symbolically. What we need is an algebraic language.

> **Boolean algebra**: a system for writing logic functions as formulas over variables that can only take the values 0 and 1. Boolean operators correspond directly to logic gates.

The benefit of this is that you can manipulate an expression on paper—substituting, factoring, applying identities—without touching a single wire. And if you're anything like me (i.e. afraid of a single static shock) this is a huge win.

Unfortunately, mathematicians, electrical engineers, and programmers all developed their own notation for the same operations, and none of them ever agreed to use a single one. Meaning: you'll see _all_ of these in textbooks, datasheets, and code:

| **Operation** | **Notations you will encounter** |
|-----------|------------------------------|
| **`NOT A`**     | `~A` &nbsp; `¬A` &nbsp; `Ā` &nbsp; `A'` |
| **`A AND B`**   | `A & B` &nbsp; `A ∧ B` &nbsp; `A · B` &nbsp; `AB` (juxtaposition) |
| **`A OR B`**    | `A \| B` &nbsp; `A ∨ B` &nbsp; `A + B` |
| **`A XOR B`**   | `A ^ B` &nbsp; `A ⊕ B` |

The `+` for `OR` and juxtaposition for `AND` come from George Boole's original mathematical framing. The `~`, `&`, and `|` come from C and most other programming languages. The `¬`, `∧`, and `∨` come from what is called formal logic. Knowing which tradition you're reading is usually obvious from context, but it's helpful to be able to read all of them.

<a id="2-2"></a> 

### Operator Precedence

This will be, hopefully, already [**ingrained in your head**](https://github.com/sebastianromerocruz/CS1114-Problem-Solving-And-Programming/tree/main/lectures/fundamentals_2#part-3-boolean-expressions). You can't read someone else's expression correctly if it's not—and a misread expression is a misunderstood circuit. The rule, from tightest to loosest binding:

1. **`NOT`**: applied to its immediate operand first
2. **`AND`**
3. **`OR`**: loosest binding

So `Ā · B + C` means `((NOT A) AND B) OR C`, _not_ `NOT(A AND (B OR C))`. 

When there's any potential ambiguity (or if you're paranoid like me), add parentheses. Over-parenthesising is literally free, and the cost of a precedence error is a wrong circuit.

<a id="2-3"></a> 

### DeMorgan's Theorem

The single most useful simplification rule in Boolean algebra is the following:

> **DeMorgan's Theorem**: negating an entire `AND` expression is the same as OR-ing the individual negations, and vice versa.

Id est:

```
~(AB)   =  Ā + B̄
~(A+B)  =  Ā · B̄
```

You can verify either identity by checking the truth table for both sides—they match for every input combination. 

Why should we care? Because it tells you that a `NAND` gate (output `~(AB)`) is *identical* to an `OR` gate with individually inverted inputs (`Ā + B̄`). 

Why should you care about _that_? Because it means that these are two different physical implementations of the same function. As hardware designers, we'll exploit this deliberately and constantly: we'll draw a gate one way in a schematic but think about it the other way to make the circuit's intent clearer. This technique is called **bubble pushing**, and you cannot read professional schematics fluently without it.

<a id="fg-7"></a> 

<p align=center>
    <img src="assets/demorgan.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure VII</strong>: A <code>NAND</code> gate (left) and an <code>OR</code> gate with both inputs inverted (right) are the same circuit—DeMorgan's Theorem made physical.
    </sub>
</p>

<br>

<a id="3"></a> 

## Circuit Analysis: Deriving Expressions and Truth Tables

But all of this is essentially meaningless unless we have an application. I still haven't really answered the _why should we care_ question.

Consider the following situation: given a circuit diagram—the kind you'd find in a datasheet, a textbook problem, or the output of a synthesis tool—how do you figure out what it actually computes? 

That's circuit analysis: the skill of extracting the Boolean function from the wiring.

The method is straightforward: 
- Start at the inputs and work towards the output, labelling each wire with the expression it carries as you go. 
- Every gate transforms its input expressions into an output expression according to its function. When you reach the output wire, you have the full expression.

### Example

Consider the following circuit, with inputs `A`, `B`, `C`, `D` and output `Y`:

<a id="fg-8"></a> 

<p align=center>
    <img src="assets/circuit-analysis-example.svg">
    </img>
</p>

<p align=center>
    <sub>
        <strong>Figure VIII</strong>: The example circuit redrawn—<code>A</code> and <code>B</code> inverted into the first <code>AND</code>, chained through a second <code>AND</code> with <code>C</code>, then a <code>NOR</code> with <code>D</code>.
    </sub>
</p>

**Step 1:** What result does `W1` carry?

The small circles (`○`) on the `A` and `B` input wires are **inversion bubbles**. They mean "negate this signal before it enters the gate." W1 and W2 are internal wires that don't connect to anything outside the circuit; they exist only to carry values between gates.

The first `AND` gate takes `NOT A` and `NOT B` as inputs (because of the bubbles). `AND` outputs `1` only when all inputs are `1`, so:

```
W1 = (NOT A) AND (NOT B) = ~A & ~B
```

`W1` is `1` only when both `A` and `B` are `0`.

**Step 2:** What result does W2 carry?

The second `AND` gate takes `W1 and C`, with no bubbles:

```
W2 = W1 AND C = (~A & ~B) & C = ~A & ~B & C
```

**Step 3:** What result does `Y` carry?

The `NOR` gate gives `Y = ~(W2 OR D)`:

```
Y = ~((~A & ~B & C) + D)
```

This is where applying DeMorgan's is handy, since we can push the negation inward to make this look nicer:

```
Y = ~((~A & ~B & C) + D) = ~(~A & ~B & C) & ~D
                         =  (A + B + ~C)  & ~D

Y = (A + B + ~C) & ~D
```

Now, the expression `(A + B + ~C) & ~D` is a perfectly valid description of the circuit. But, as we saw with DeMorgan's, the same function can be written in many equivalent shapes, and having everyone default to the same one makes expressions easier to compare, simplify, and read off a truth table directly. Sort of like having a standard set of units.

The "units" this course standardises on is the **sum-of-products (SOP)**: _a list of `AND`-terms `OR`'d together_, where each `AND`-term describes one specific set of inputs that makes `Y` true.

Getting there is just the ol' distributive law from ordinary algebra, `x(y + z) = xy + xz`, applied to Booleans:

```
Y = (A + B + ~C) & ~D 
  = (A(~D) + B(~D) + (~C)(~D))
```

Ok, it doesn't look _great_, so let's look at it in more programmatic terms:

```
Y = (A & ~D) | (B & ~D) | (~C & ~D)
```

Each term on the right is now a single `AND` of literals, and the three are `OR`'d together—exactly the SOP shape. In compact Boolean notation: 

```
Y = AD̄ + BD̄ + C̄D̄
```

Reading it aloud: "`Y` is 1 whenever `D` is 0 *and* at least one of `A`, `B`, or `~C` is 1." SOP form is the standard way to express a combinational function, and it's what you'll use throughout this course.

### Building the Truth Table

With the expression in hand, building the truth table is mechanical: enumerate every possible input combination and evaluate the expression. With four inputs there are **2⁴ = 16** rows. 

A good strategy is to count up in binary from 0000 to 1111, which guarantees every combination appears exactly once.

| A | B | C | D | `A & ~D` | `B & ~D` | `~C & ~D` | Y |
|---|---|---|---|:---:|:---:|:---:|:---:|
| 0 | 0 | 0 | 0 | 0 | 0 | 1 | **1** |
| 0 | 0 | 0 | 1 | 0 | 0 | 0 | **0** |
| 0 | 0 | 1 | 0 | 0 | 0 | 0 | **0** |
| 0 | 0 | 1 | 1 | 0 | 0 | 0 | **0** |
| 0 | 1 | 0 | 0 | 0 | 1 | 1 | **1** |
| 0 | 1 | 0 | 1 | 0 | 0 | 0 | **0** |
| 0 | 1 | 1 | 0 | 0 | 1 | 0 | **1** |
| 0 | 1 | 1 | 1 | 0 | 0 | 0 | **0** |
| 1 | 0 | 0 | 0 | 1 | 0 | 1 | **1** |
| 1 | 0 | 0 | 1 | 0 | 0 | 0 | **0** |
| 1 | 0 | 1 | 0 | 1 | 0 | 0 | **1** |
| 1 | 0 | 1 | 1 | 0 | 0 | 0 | **0** |
| 1 | 1 | 0 | 0 | 1 | 1 | 1 | **1** |
| 1 | 1 | 0 | 1 | 0 | 0 | 0 | **0** |
| 1 | 1 | 1 | 0 | 1 | 1 | 0 | **1** |
| 1 | 1 | 1 | 1 | 0 | 0 | 0 | **0** |

The truth table is law—i.e. it exhaustively lists every _case_. The problem is that it doesn't scale very well; a circuit with 32 inputs would require over _four billion rows_. I ain't doing that, and neither are you.

Luckily, you won't have to, but that is a story for next time. Since we talked about binary numbers, let's cover a couple of things you need to know about them.

<br>

<a id="4"></a>

## Representing Numbers in Binary

So these gates operate on 0s and 1s. But the things a computer actually processes—integers, addresses, characters, instructions—are not single bits. They're *numbers*, and we need a reliable way to encode those numbers as sequences of bits. This is where the math that we've been doing and the hardware connect.

The encoding is **positional notation**: the same idea underlying decimal, just in base 2, [**which you definitely know**](https://github.com/sebastianromerocruz/CS1114-Problem-Solving-And-Programming/tree/main/lectures/number_systems#part-1-number-systems). 

In decimal, each digit position represents a power of 10. In binary, each bit position represents a power of 2, and each digit—called a **bit**—is either 0 or 1. Because different bases can represent the same number very differently (`11` in binary is 3, not 11), technical documents use prefixes to remove ambiguity:

| Base | Name        | Allowed digits | Prefix       |
|------|-------------|----------------|--------------|
| 10   | Decimal     | 0–9            | none (or `0d`, optional) |
| 2    | Binary      | 0, 1           | `0b` (required) |
| 16   | Hexadecimal | 0–9, A–F       | `0x` or `0h` (required) |

So `0b1010` is the binary number 1010 (= 10 in decimal), and `0xFF` is the hexadecimal number FF (= 255 in decimal). When you see a bare number in hardware documentation with no prefix, assume decimal—but when precision matters, always include the prefix.

Note: if you feel comfortable with converting between these three number systems, you can safely skip to [**Hexadecimal**](#5). Just take a quick look at [**these terms**](#4-3) before you do so.

<a id="4-1"></a> 

### Binary to Decimal

Multiply each bit by its positional power of 2 and sum the results.

**Example:** Convert `0b11001` to decimal.

```
Position:  4    3    2    1    0
Bit:       1    1    0    0    1

1 × 2⁴ = 16
1 × 2³ =  8
0 × 2² =  0
0 × 2¹ =  0
1 × 2⁰ =  1
         ───
          25
```

So **0b11001 = 25₁₀**. The powers of 2 from right to left are 1, 2, 4, 8, 16, 32, 64, 128—just sum the positional values wherever a 1 bit appears.

<a id="4-2"></a> 

### Decimal to Binary

Going the other direction requires **repeated division by 2**: divide the number by 2, record the remainder (always 0 or 1), then repeat on the quotient until you reach 0. The binary representation is the remainders read *bottom to top*—because each division strips off the least-significant bit first, reading bottom-to-top puts them back in order.

**Example:** Convert 25 to binary.

| Division | Quotient | Remainder |
|----------|----------|-----------|
| 25 ÷ 2   | 12       | **1**     |
| 12 ÷ 2   | 6        | **0**     |
| 6 ÷ 2    | 3        | **0**     |
| 3 ÷ 2    | 1        | **1**     |
| 1 ÷ 2    | 0        | **1**     |

Reading remainders bottom to top: **11001**. So 25₁₀ = **0b11001**.

<a id="4-3"></a> 

### Terminology

A few grouping names appear constantly in documentation and code:

- A single binary digit is a **bit**
- A group of 4 bits is, adorably, a **nibble**
- A group of 8 bits is a **byte**
- A **word** is a grouping whose size depends on the architecture—commonly 32 or 64 bits on modern systems. When a system call says it returns a 32-bit integer, or a register is described as a 64-bit value, these are the units being referred to.

<br>

<a id="5"></a> 

## Hexadecimal

Binary is the native language of hardware, but nobody is out there actually reading it aside from your computer. A 32-bit memory address written out in binary is 32 ones and zeros. Good luck! 

This is literally the reason why we use **hexadecimal** (base 16, abbreviated *hex*) as the standard human-readable shorthand.

The reason hex works so cleanly with binary is that 16 = 2⁴: each hex digit represents exactly 4 binary bits. This means converting between binary and hex requires no math at all—just a direct digit-for-digit substitution, four bits at a time. Hex uses the digits 0–9 for values zero through nine, then A–F for ten through fifteen:

| Decimal | Binary | Hex |
|---------|--------|-----|
| 0       | 0000   | 0   |
| 1       | 0001   | 1   |
| 2       | 0010   | 2   |
| 3       | 0011   | 3   |
| 4       | 0100   | 4   |
| 5       | 0101   | 5   |
| 6       | 0110   | 6   |
| 7       | 0111   | 7   |
| 8       | 1000   | 8   |
| 9       | 1001   | 9   |
| 10      | 1010   | A   |
| 11      | 1011   | B   |
| 12      | 1100   | C   |
| 13      | 1101   | D   |
| 14      | 1110   | E   |
| 15      | 1111   | F   |

This table is worth memorising (at least, I did). Once you know it, converting between binary and hex is basically trivial.

<a id="5-1"></a> 

### Binary to Hexadecimal

Split the binary number into groups of 4 bits (or a nibble) starting from the right, then convert each group independently. If the leftmost group has fewer than 4 bits, pad it with leading zeros.

**Example:** Convert `0b1101 1001` to hexadecimal.

```
1101  →  13  →  D
1001  →   9  →  9
```

Result: **0xD9**

<a id="5-2"></a> 

### Hexadecimal to Binary

Go in reverse: replace each hex digit with its 4-bit binary equivalent, keeping the groups in order.

**Example:** Convert `0xA7F1` to binary.

```
A  →  10  →  1010
7  →   7  →  0111
F  →  15  →  1111
1  →   1  →  0001
```

Result: **0b 1010 0111 1111 0001**

Any time you see a memory address, a colour code (`#FF8800`), a network MAC address, or a register dump in a debugger, it's almost certainly in hex. The prefix `0x` is your signal. Being able to quickly read hex—and spot that `0xFF` is all ones, or that `0x80000000` has only the MSB set—is a skill you'll use constantly in systems work.

Everything above has been non-negative. Negative numbers—and the encoding that makes ordinary addition work for them too—is where we pick up [**next lecture**](/lectures/02-adders), right before we need it to explain why adders work the way they do.

<br>

<sub>**Next: [Adders](/lectures/02-adders)**</sub>
