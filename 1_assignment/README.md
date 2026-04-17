# Compiler Optimization Passes

This document provides a technical overview of the implemented optimization passes in the first assignment.

---

## Preliminary Notes (Common Constraints)

* **Note 1: Dead Code Elimination (DCE):** These passes perform "use-replacement" but do not physically remove the original instructions from the IR. It is assumed that a subsequent Dead Code Elimination (DCE) pass will be executed later to clean up the resulting dead code.
* **Note 2: Local Scope:** Every optimization is performed strictly within the local scope of a **single basic block**. Cross-block or global data-flow analysis is not currently implemented.
* **Note 3: Type Constraints:** The optimizations strictly target integer constants (**ConstantInt**). Floating-point constants (**ConstantFP**) are not supported and are ignored.
* **Note 4: Test Cases:** Functional verification and specific test scenarios are not included in this description. They are provided in the respective `test.c` files located within the test directories for each optimization step.

## 1. Algebraic Identity Optimization

Binary algebraic operations applied with a neutral or absorbing constant can be trivially simplified, making the original operation unnecessary. This optimization step identifies these algebraic properties in the binary instructions of each basic block. It then replaces all uses of the instruction's definition with either the non-constant operand (for neutral elements) or the constant itself (for absorbing elements).

## Covered Cases

* **ADD:** Optimizes `a + 0` and `0 + a` $\rightarrow$ replaces all uses with `a`.
* **SUB:** Optimizes `a - 0` $\rightarrow$ replaces all uses with `a`. 
    * *Note:* The case `0 - a` is not optimized as it is not an identity.
* **MUL:**
    * **Neutral Element:** `a * 1` and `1 * a` $\rightarrow$ replaces all uses with `a`.
    * **Absorbing Element:** `a * 0` and `0 * a` $\rightarrow$ replaces all uses with `0`.
* **DIV:**
    * **Neutral Element:** `a / 1` $\rightarrow$ replaces all uses with `a`.
    * **Absorbing Element:** `0 / a` (where `a ≠ 0`) $\rightarrow$ replaces all uses with `0`.
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
- **Subtraction and Division Constraints**: In subtraction and division, the constant `n` must appear as the second operand in the RHS. Cases where the constant is the first operand (e.g., `n - a`) are not covered because they are not linearly resolvable in a symmetric form (e.g., `(n - a) + n` results in `2 * n - a`).
- **Exact Division**: Optimization of the `(a / n) * n` pattern occurs **only if** the original division is marked as exact (`isExact()`). Otherwise, the multiplication would not correctly reverse the integer division truncation (e.g., `(7 / 2) * 2 = 6`), thus preserving original semantics.
- **Use Verification**: As no prior DCE pass is assumed, the pass explicitly verifies that the instruction still has active uses (`!use_empty()`) before proceeding.
* **Pointer Comparison**: The pass verifies that the `ConstantInt` objects in both instructions are the exact same instance in memory (pointer equality).
* **No Inverse Bitwise:** Currently limited to basic arithmetic operators (`ADD`, `SUB`, `MUL`, `DIV`).