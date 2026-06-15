# Compiler Optimization Passes

This document provides a technical overview of the implemented optimization passes in the first assignment.

---

## Preliminary Notes (Common Constraints)

* **Note 1: Dead Code Elimination (DCE):** These passes perform "use-replacement" but do not physically remove the original instructions from the IR. It is assumed that a subsequent Dead Code Elimination (DCE) pass will be executed later to clean up the resulting dead code.
* **Note 2: Local Scope:** Every optimization is performed strictly within the local scope of a **single basic block**. Cross-block or global data-flow analysis is not currently implemented.
* **Note 3: Type Constraints:** The optimizations strictly target integer constants (**ConstantInt**). Floating-point constants (**ConstantFP**) are not supported and are ignored.
* **Note 4: Test Cases:** Functional verification and specific test scenarios are not included in this description. They are provided in the respective `test.c` files located within the test directories for each optimization step.

## 1. Algebraic Identity Optimization

Binary algebraic operations applied with a neutral or absorbing constant can be trivially simplified, making the original operation unnecessary. This optimization step identifies these algebraic properties in the binary instructions of each basic block. It then replaces all uses of the instruction's definition with either the non-constant operand (for neutral elements) or the constant itself (for absorbing elements). We do not handle cases where both operands are constants, because this never happens in LLVM.

## Covered Cases

* **ADD:** Optimizes `a + 0` and `0 + a` $\rightarrow$ replaces all uses with `a`.
* **SUB:** Optimizes `a - 0` $\rightarrow$ replaces all uses with `a`. 
    * *Note:* The case `0 - a` is not optimized as it is not an identity.
* **MUL:**
    * **Neutral Element:** `a * 1` and `1 * a` $\rightarrow$ replaces all uses with `a`.
    * **Absorbing Element:** `a * 0` and `0 * a` $\rightarrow$ replaces all uses with `0`.
* **DIV:**
    * **Neutral Element:** `a / 1` $\rightarrow$ replaces all uses with `a`.
    * **Absorbing Element:** `0 / a` (where `a != 0`) $\rightarrow$ replaces all uses with `0`.
    * *Exclusions:* Does not handle `1 / a`, `a / 0`, or `0 / 0` (division by zero is left as undefined behavior).

---

## 2. Strength Reduction Optimization

This pass identifies computationally expensive arithmetic operations (multiplications and divisions) and replaces them with lower-latency sequences of bitwise shifts, additions, and subtractions.
 
## Covered cases
 
**Multiplication (MUL):**
* `a * 2^n` $\rightarrow$ Replaced with `a << n`
* `a * (2^n + 1)` $\rightarrow$ Replaced with `(a << n) + a`
* `a * (2^n - 1)` $\rightarrow$ Replaced with `(a << n) - a`

**Unsigned Division (UDIV):**
* `a / 2^n` $\rightarrow$ Replaced with `a >> n` (Logical Shift Right).

**Signed Division (SDIV):**
* `a / 2^n` $\rightarrow$ Replaced with `(a + bias) >> n` (Arithmetic Shift Right).
* **Correction Logic:** C integer division truncates toward zero, while `AShr` truncates toward minus infinity. For negative dividends, a correction (bias) is added to ensure the result matches standard C semantics.
* **Formula:** `(a + (a < 0 ? (2^n - 1) : 0)) >> n`

## Concluding Notes
* **Constant Constraints:** Strictly limited to strictly positive integer constants (`ConstantInt > 0`).
* **Division Constraints:** Optimized only when the divisor is a strictly positive integer power of two.
* **Adjacency:** Adjacency cases (`2^n +- 1`) are **not** handled for division, only for multiplication.
* **Architecture Independence:** The pass assumes these transformations are universally beneficial and does not query specific CPU cost models.

---

## 3. Multi Instruction Optimization

Some sequences of two consecutive instructions apply an operation and immediately reverse it using the same constant, producing a result equivalent to the original operand. This optimization identifies such pairs of inverse instructions within a single basic block. It eliminates the cost of the second operation by replacing **all uses** of the second instruction's result directly with the original operand from the first instruction.

## Covered cases

| Optimized Pattern | Condition | Result |
| :--- | :--- | :--- |
| `(a - n) + n` or `n + (a - n)` | Pointer equality of `n` | `a` |
| `(a + n) - n` or `(n + a) - n` | Pointer equality of `n` | `a` |
| `(a * n) / n` or `(n * a) / n` | Signed and Unsigned Div | `a` |
| `(a / n) * n` or `n * (a / n)` | **Requires `isExact()`** | `a` |
 
## Concluding notes

* **Addition and Multiplication Commutativity:** The implementation fully supports **commutativity** for Addition (`ADD`) and Multiplication (`MUL`). The pass identifies these patterns regardless of whether the constant is the first or second operand in the involved instructions (where mathematically applicable).
* **Subtraction and Division Constraints**: In subtraction and division, the constant `n` must appear as the second operand in the RHS. Cases where the constant is the first operand (e.g., `n - a`) are not covered because they are not linearly resolvable in a symmetric form (e.g., `(n - a) + n` results in `2 * n - a`).
* **Exact Division**: Optimization of the `(a / n) * n` pattern occurs **only if** the original division is marked as exact (`isExact()`). Otherwise, the multiplication would not correctly reverse the integer division truncation (e.g., `(7 / 2) * 2 = 6`), thus preserving original semantics.
* **Pointer Comparison**: The pass verifies that the `ConstantInt` objects in both instructions are the exact same instance in memory (pointer equality).
* **No Inverse Bitwise:** Currently limited to basic arithmetic operators (`ADD`, `SUB`, `MUL`, `DIV`).

---

## Appendix: Proof for Signed Division

The Strength Reduction pass uses a specific formula to replace Signed Division (`SDIV`) by a power of two with an Arithmetic Shift Right (`AShr`). This is necessary because C integer division for negative numbers truncates toward zero, whereas the IR `AShr` instruction truncates toward minus infinity (-inf).

Dividing a negative integer `D < 0` by a positive integer divisor `d = 2 ^ k` translates to:
*   **C Division (Truncate to 0):** `ceil(D / d)`
*   **AShr (Truncate to -inf):** `floor(D / d)`

To align the `AShr` behavior with C semantics, the pass computes `(D + d - 1) >> k`. We must prove the following identity:

`ceil(D / d) = floor((D + d - 1) / d)`

### Proof

By the Euclidean division theorem, any integer `D` can be expressed as:
`D = q * d + r`
where `q` is the quotient and `r` is the remainder, with `0 <= r <= d - 1`.

There are two scenarios:

**Case 1: D is a multiple of d (r = 0)**
Substitute `D = q * d` into both sides of the identity.
*   **Left Side:**  
    `ceil((q * d) / d) = ceil(q) = q`  
*   **Right Side:**  
    `floor((q * d + d - 1) / d) = floor(q + (d - 1) / d)`  
    Since `d > 0`, the fraction `(d - 1) / d` is strictly less than 1 and greater than or equal to 0. The floor of `q` plus a decimal `0 <= x < 1` is `q`.

`ceil((q * d) / d) = ceil(q) = q = floor(q) = floor(q + (d - 1) / d) = floor((q * d + d - 1) / d)`

**Case 2: D is NOT a multiple of d (1 <= r <= d - 1)**
Substitute `D = q * d + r` into both sides.
*   **Left Side:**  
    `ceil((q * d + r) / d) = ceil(q + r / d)`  
    Since `1 <= r <= d - 1`, the fraction `r / d` is strictly between 0 and 1. The ceiling of an integer plus a positive decimal triggers the next integer, yielding **`q + 1`**.

*   **Right Side:**  
    `floor((q * d + r + d - 1) / d) = floor(q + (r + d - 1) / d) = floor(q + 1 + (r - 1) / d)`  
    We know that `1 <= r <= d - 1`. Subtracting 1 across the inequality yields `0 <= r - 1 <= d - 2`. Dividing by d:
    `0 <= (r - 1) / d <= (d - 2) / d < 1`
    Since `(r - 1) / d` is between 0 (inclusive) and 1 (exclusive), the floor of `(q + 1)` plus this decimal is exactly **`q + 1`**.

`ceil((q * d + r) / d) = ceil(q + r / d) = q + 1 = floor(q + 1 + (r - 1) / d) = floor((q * d + r + d - 1) / d)`

In both cases, the two expressions yield the same integer:
1.  If `r = 0`, the result is `q`.
2.  If `r > 0`, the result is `q + 1`.

By adding the `2^k - 1` bias, the compiler forces the floor-based Arithmetic Shift Right `AShr` to simulate a ceiling-based division `SDIV`, preserving C semantics.