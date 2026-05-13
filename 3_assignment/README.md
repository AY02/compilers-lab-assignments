# Loop-Invariant Code Motion (LICM)

This document provides a technical overview of the implemented Loop-Invariant Code Motion (LICM) optimization pass in the third assignment.

LICM optimization involves moving instructions within a loop outside of it, without altering the program’s semantics. Intuitively, we want to avoid the redundant execution of instructions that always calculate the same result.

---

## 1. Loop-Invariant Analysis

The first step in LICM is to identify the loop-invariant instructions within a loop.

### 1.1 Core Definitions

**Axioms:**
- Constants, function arguments, and global variables are loop-invariant.
- Uses of definitions outside the loop are loop-invariant.
- Uses of definitions inside the loop that have already been marked as loop-invariant are also loop-invariant.

**Definition of a loop-invariant instruction:**
- An instruction is **loop-invariant** if its operands are also loop-invariant.

**Definition of an instruction with side effects:**
- An instruction has **side effects** if it alters the state of the program (e.g., I/O operations).

**Definition of a hoistable instruction:**
- An instruction is **hoistable** if it is loop-invariant and free of side effects.

> [!NOTE]
> **On side effects and memory operations:** Even though `load` and `store` instructions can be considered loop-invariant if their operands are also loop-invariant, we conservatively treat them as not hoistable because they interact with memory and risk altering the state of the program. However, not all memory operations are un-hoistable, as there are cases where they do not alter the memory state. Our optimization pass could be extended by integrating an **Alias Analysis** to determine whether memory locations accessed by memory instructions overlap. By proving that a specific memory location is not modified by a `store` within the loop, we could safely mark its corresponding `load` instructions as hoistable.

> [!NOTE]
> **On global variables and SSA form:** In LLVM IR, global variables are represented as pointers. Consequently, while `load` and `store` instructions can alter the content pointed to by the global variable, the pointer itself cannot be altered as the IR is in **Static Single Assignment (SSA)** form. A similar observation applies to function arguments: any reassignment would simply involve the creation of a new, distinct SSA register, rather than redefining the one used to represent the original argument.

Each basic block ends with a **Terminator** instruction (such as `ret`, `br`, or `switch`), which specifies the next block to be executed. Because Terminators define the edges of the Control Flow Graph (CFG) and the structure of the loop itself, they cannot be hoisted.

A `phi` instruction is used to select a value depending on which predecessor block transferred control to the current block. Therefore, it must be the first instruction in a basic block with multiple incoming edges. In our analysis step, we consider a `phi` instruction to be loop-invariant if all the values associated with the incoming blocks are identical, and that specific value is also loop-invariant.

### 1.2 Implementation

We can think of the `LoopInfo &LI` object as a **forest** where each tree root represents a top-level loop. Consequently, we carry out the analysis step by iterating over these top-level loops, one at a time.

We perform a **Post-Order DFS traversal** over the loop tree as a preliminary step for code motion, utilizing a bottom-up algorithm. By performing code motion starting from the innermost loop, we move hoistable instructions to its preheader, effectively incorporating them into the enclosing outer loop. In this way, by the time the next iteration processes the outer loop, it is fully ready for analysis and optimization.

If we were to use a top-down approach (e.g., via the native `LI.getLoopsInPreorder()` function), we would be forced to iterate the code motion step until convergence, requiring a number of passes equal to the depth of the nested loop plus one.

#### Reverse Post-Order DFS Traversal

The order in which the blocks of a loop are natively visited via `L->blocks()` is not meaningful. If we iterate through blocks arbitrarily, there is a risk that instructions using loop-invariant definitions might be visited before their definitions are analyzed and labeled. Consequently, they would be mistakenly considered loop-variant.

**Example:**
```text
s1: x = a + b  // Loop-invariant definition
s2: y = x + 2  // Use of x
```
If the block containing `s2` is visited first, `y` would not be considered loop-invariant because `x` has not yet been processed. To resolve this, we sort the nodes in the loop using a **Reverse Post-Order (RPO) DFS Traversal**, which guarantees that predecessors are visited before their successors.

#### Why not use a Dominator Tree Traversal?

Alternatively, one might consider a Pre-Order DFS traversal on the **Dominator Tree**. In SSA form, every use is dominated by its unique definition. However, unlike an RPO traversal on the CFG, the Dominator Tree **does not guarantee the visit order among sibling nodes**. 

This introduces critical issues when visiting branches, as a merge block containing a `phi` node could be visited before its corresponding branch blocks.

**Example:**
```text
%if.header A
if (cond) {
  // %if.then B
  x1 = a + b;
} else {
  // %if.else C
  x2 = a + b;
}
%if.merge D
x = phi([x1, %B], [x2, %C]);
```
In a Dominator Tree, `A` dominates `B`, `C`, and `D`. A Pre-Order traversal could legally yield the sequence `A -> D -> C -> B`. If this happens, the `phi` instruction in block `D` would be processed before `B` and `C`, causing it to be falsely marked as loop-variant. RPO prevents this by ensuring that `D`'s predecessors (`B` and `C`) are visited first.

#### Recursive Approach

As an alternative to RPO, we can implement an algorithm that explicitly utilizes **DEF-USE chains**, disregarding the specific block visit order. Whenever an instruction's operand is a definition, the algorithm recursively executes the loop-invariant check on that operand.

In this approach, the `InvariantSet` and `VariantSet` evolve into a **caching mechanism**, preventing redundant recursive traversals:
- **`InvariantSet`**: Stores instructions already proven to be loop-invariant.
- **`VariantSet`**: Stores instructions already identified as loop-variant.

By caching both results, the algorithm ensures that each instruction is analyzed exactly once.

> [!NOTE]
> **On PHI Nodes in Recursive Analysis:** In a recursive DEF-USE analysis, PHI instructions must be treated as loop-variant. This is a mandatory constraint to prevent infinite recursion.
> In LLVM IR, a phi node in the loop header merges a value coming from the preheader (entry) with a value coming from the latch (back-edge). Since the value from the latch usually depends on instructions within the loop body that, in turn, depend on the phi itself, following the operands would result in an endless circular traversal.
**Example:**
> ```text
> entry:         ; preheader
>   br label %header
> header:
>   ; The phi node depends on %i.next (from the latch)
>   %i = phi i32 [ 0, %entry ], [ %i.next, %latch ]
>   ; The add instruction depends on %i
>   %i.next = add i32 %i, 1
>   %cond = icmp slt i32 %i.next, 10
>   br i1 %cond, label %latch, label %exit
> latch:         ; back-edge to the header
>   br label %header
> exit:
>   ret void
> ```

### 1.3 Final Observations

- **Instruction Ordering:** In both approaches, the `InvariantSet` is strictly ordered. The sequence begins with "base case" loop-invariants and ends with the most complex ones. This ensures that any instruction only depends on operands that are either external or appear earlier in the set.
- **Computational Complexity:** Both algorithms have a complexity of **O(n)**, where n denotes the number of instructions within the loop. The recursive approach introduces a slight overhead due to stack frames but remains highly efficient thanks to the caching mechanism.
- **Prerequisite for Code Motion:** The deterministic ordering of `InvariantSet` is a fundamental prerequisite for **Code Motion**. Since the set maintains the correct dependency sequence, hoisting simply involves a linear traversal of that set. Moving instructions to the preheader in this order guarantees that every hoisted instruction will find its operands already available, preserving SSA semantics.

---

## 2. Code Motion

*(Documentation for the Code Motion implementation provided by Christian)*
