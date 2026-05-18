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

Once the loop-invariant instructions have been identified and deterministically ordered, the second phase of LICM is the actual **Code Motion**.
This phase evaluates whether it is legally and semantically correct to move these instructions out of the loop and into its **preheader**.

To maintain the correct execution flow, moved instructions (or hoisted instructions) are inserted right before the preheader's terminator instruction (the branch that jumps to the loop header).

### 2.1 Theoretical Conditions vs. SSA

According to classic compiler theory, an instruction is a candidate for code motion if it satisfies all of the following conditions:

1. It is loop-invariant
2. It assigns a value to a variable not assigned elsewhere in the loop
3. It is located in a block that dominates all blocks in the loop that use the variable
4. It is located in a block that **dominates all exits of the loop**

Because LLVM IR strictly enforces **Static Single Assignment (SSA)** form, the second and third conditions are intrinsically guaranteed. In SSA, a virtual register is assigned exactly once, eliminating any risk of overwriting variables. Furthermore, SSA guarantees that a definition strictly dominates all of its uses.

Consequently, in the context of LLVM, the prerequisites for code motion are vastly simplified. Assuming the instruction is invariant and has no side effects, the rule reduces to the fourth condition:

**The instruction must dominate all loop exits**

#### Limits of the dominance condition
In practice, the fourth condition can be be overly conservative: in general, whenever the execution of a loop depends on a condition (e.g. a `for` loop), there are no guarantees that the body of the loop will be executed. Therefore, the body never dominates the exits, and no instruction will be hoisted.  
But reflecting on the reasons determining the presence of this condition, it is possible to formulate "relaxed" conditions that, even if the instruction does not dominate all loop exits, still allow to hoist the instruction in some specific cases. In fact, the reasons behind the fourth condition are to be retrieved in the semantic alteration caused by a hoisted instruction in a case like the following one:
```c
int x = 10;
for (int i = 0; i < n; i++) {
  x = 5;
}
y =  x + 1;
```
Here, the hoist of the instruction `x = 5` would force the propagation of the definition inside the loop, even if the loop never executes (n <= 0), altering the semantic of the program.
The fourth condition prevents this by ensuring that the hoisting is effected only if the `x = 5` instruction was a forced path (dominates the exits of the loop).
But this condition can be "relaxed" if the `x` variable is meant to be used only in the loop, because even if the instruction inside the loop is hoisted, there would not be alteration of the semantic (no instruction outside the loop would use that forcely propagated definition). 
 
A further relaxation, which strongly relies on the SSA form used in LLVM, will be shown in the 2.2 implementation section, because of its strict dependency to implementation considerations.

### 2.2 Implementation

#### Hoisting Mechanics

For each instruction in the `InvariantSet`, the hoisting itself is performed via `moveBefore`, placing the instruction immediately before the preheader's terminator (the unconditional branch that jumps to the loop header, last instruction of the preheader block). This ensures that hoisted instructions execute exactly once before the loop begins.

For this reason, a necessary precondition is that the loop has a **preheader**: a dedicated block with a single successor (the loop header) that is not part of the loop itself. If no preheader exists, code motion is skipped for that loop in this implementation. It is possible to simply overcome this limitation by executing the LLVM loop-simplify optimization before our optimization, but it is not needed for the tests we propose.

The order in which instructions are moved is determined by the order of insertion into the `InvariantSet`, which follows the RPO traversal described in the analysis phase. This guarantees that a definition is always hoisted before any instruction that depends on it, preserving correct def-use order in the preheader.

#### Restricting the Candidate Set

Not all loop-invariant instructions in the mathematical sense are admitted into the `InvariantSet` in this implementation. Instructions with side effects (such as store operations or function calls that alter program state, like `printf`) and instructions that read from memory (such as load instructions or calls like `strlen`) are excluded early during the analysis phase via the `mayHaveSideEffects` and `mayReadFromMemory` guards.

This changes the meaning of the `InvariantSet` slightly: it no longer represents the full set of loop-invariant instructions, but rather the set of invariant instructions that are candidates for hoisting. Hoisting a load could read a value before it is initialised, and hoisting a store would change the number of times the side effect is observed. Excluding them early keeps the implementation simple.

#### Implementation to overcome the practical limits of the dominance condition
As we discussed before at the end of the section 2.1, the dominance condition can be overly conservative. A first relaxed implementation relaxes the dominance condition by introducing an OR with a dead-outside-loop check for the considered instruction. The `dominatesAllExits` condition is evaluated by iterating over the exiting blocks of the loop (the blocks that have a successor outside the loop) and verifying that the block containing the candidate instruction dominates all of them via the `DominatorTree`. If this condition is not satisfied, the instruction is still hoisted if `isDeadOutsideLoop` returns `true`, which checks that all uses of the instruction are contained within the loop itself:

```cpp
if (dominatesAllExits(I, L, DT) || isDeadOutsideLoop(I, L))
```

This guarantees that the dominance condition is always evaluated first, and only if it is not satisfied, the relaxed condition is checked. In this way, instructions contained in the `InvariantSet` that are guaranteed to execute whenever the loop runs are always hoisted, while instructions that do not dominate the exits are hoisted only if their result cannot affect any computation outside the loop.  
It is interesting to note that in the SSA form, this produces a paradoxal effect: it hoists instructions that, without the SSA form, semantically should not be hoistable, but at the same time SSA preserves the semantic of the program. Let's take a look at this example:

```
int test_strange_hoist(int a, int b, int n) {
  int x = 10; 
  for (int i = 0; i < n; i++) {
    x = a + b; 
  }
  return x + 1;
}
```

In this case, it should not be possible to hoist the `x = a + b` instruction without altering the semantic of the program. But, because of how the SSA works, the `x = a + b` instruction is considered dead at the end of the loop. In fact, LLVM places internal `phi` nodes inside the loop header to collect values used outside the loop:

```
define dso_local i32 @test_strange_hoist(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %8, %3
  %.01 = phi i32 [ 10, %3 ], [ %7, %8 ]           ; this is the phi node that collect the value 
  %.0 = phi i32 [ 0, %3 ], [ %9, %8 ]
  %5 = icmp slt i32 %.0, %2
  br i1 %5, label %6, label %10

6:                                                ; preds = %4
  %7 = add nsw i32 %0, %1
  br label %8

8:                                                ; preds = %6
  %9 = add nsw i32 %.0, 1
  br label %4, !llvm.loop !6

10:                                               ; preds = %4
  %11 = add nsw i32 %.01, 1
  ret i32 %11
}
```

Because the direct user of the instruction is this internal `phi` node, our dead-outside-loop check would almost always return `true` in this kind of conditioned loops with the exit in the loop, causing the optimization to hoist the  `x = a + b` instruction!  
Hoisting the instruction in a non SSA form would be incorrect, because it would cause to overwrite the `x` variable before knowing whether the loop will start or not. But the SSA form prevents this with the single definition concept it provides: even by moving the `x = a + b` instruction, it is still possible to correctly evaluate the correct value of `%.01` thanks to the `phi` node in the header, that assign the value based on from where the program reach the `10` block (exit block).  
There is indeed speculative execution of the `x = a + b` instruction moved in the preheader, that may never be used, but if the loop cycles for 100K instruction, we are saving 99'999 evaluation of the `x = a + b` instruction.  

After making these considerations, we observed that bypassing the dominance check on this basis alone can lead to the speculative execution of unsafe instructions — such as integer division. And in conditioned loops, if they never executes (zero-trip loops) this would alter the program's semantics by causing an illegitimate trap.

To resolve this, we implemented an alternative version in which we replaced the dead-outside-loop check with an evaluation of the instruction's intrinsic safety via `isSafeToSpeculativelyExecute`. The hoisting condition becomes:

```cpp
if (dominatesAllExits(I, L, DT) || isSafeToSpeculativelyExecute(I))
```

If the instruction is intrinsically safe (e.g. a simple addition), it is hoisted speculatively: if the loop does not run, the instruction moved would just result in dead code. If the instruction is unsafe (e.g. integer division), it is only hoisted when it dominates all exits, preserving the original program semantics exactly.

It is also worth noting that LLVM often places internal `phi` nodes inside the loop header to collect values used outside the loop. Because the direct user of the instruction is this internal `phi` node, our dead-outside-loop check would almost always return `true`.


replaces the dead-outside-loop check with an evaluation of the instruction's intrinsic safety via `isSafeToSpeculativelyExecute`. If an instruction is guaranteed not to cause any trap or side effect (e.g., a simple addition or multiplication), it can be safely hoisted even when it does not dominate the exits and its result is used outside the loop: if the loop never executes, the resulting LLVM IR would correctly consider the right definition for the uses of the result, and the moved instruction would just be dead code.

### 2.3 Test Cases and Final Remarks

The following test cases demonstrate the correctness of the implementation.

#### `test_basic_hoisting`

```c
int test_basic_hoisting(int a, int b, int n) {
  int sum = 0;
  for (int i = 0; i < n; i++) {
    int x = a * b;    // Invariant, safe to speculate, hoisted
    int y = a / b;    // Invariant, unsafe, not hoited
    sum += x + i;
  }
  return sum;
}
```

`x = a * b` is hoisted because multiplication is safe to execute speculatively, even though the body does not dominate the exits.
`y = a / b` is correctly blocked: hoisting it would risk a division-by-zero trap when `n == 0`.

#### `test_dominance_needed`

```c
int test_dominance_needed(int a, int b, int n) {
  int sum = 0;
  int i = 0;
  do {
    int x = a / b;  // Invariant, unsafe, but dominates all exits, therefore hoisted
    sum += x + i;
    i++;
  } while (i < n);
  return sum;
}
```

The `do-while` structure guarantees that the body always executes before any exit is taken, so the body block dominates the exiting block. The dominance condition alone is sufficient, and the unsafe division is correctly hoisted.

#### `test_nested_hoisting`

```c
int test_nested_hoisting(int a, int b, int n) {
  int sum = 0;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      int x = a + b;  // Invariant for the inner loop, hoisted to inner preheader
                      // then invariant for the outer loop, hoisted again
      sum += x + j;
    }
  }
  return sum;
}
```

Thanks to the bottom-up post-order traversal, `x = a + b` is first hoisted to the inner loop's preheader (which lies inside the outer loop), and then recognized as invariant with respect to the outer loop and hoisted again to the outer preheader.

#### `test_memory_no_hoist`

```c
void test_memory_no_hoist(int *ptr, int n) {
  for (int i = 0; i < n; i++) {
    int val = *ptr;   // Excluded by mayReadFromMemory, not hoisted
    *ptr = 42;        // Excluded by mayHaveSideEffects, not hoisted
  }
}
```

Memory operations are excluded from the `InvariantSet` during the analysis phase.

#### `test_invariants_chain`

```c
int test_invariants_chain(int a, int b, int n) {
  int sum = 0;
  for (int i = 0; i < n; i++) {
    int x = a + b;    // Invariant, hoisted first
    int y = x * 42;   // Invariant, depends on x, correctly hoisted anyway
    sum += y + i;
  }
  return sum;
}
```

Both `x` and `y` are loop-invariant, but `y` depends on `x`. The RPO traversal guarantees that `x` is inserted into the `InvariantSet` before `y`, so definitions are always hoisted before their uses.

#### `test_2versions`

```c
int test_2versions(int a, int b, int n) {
  int x = 10;
  for (int i = 0; i < n; i++) {
    x = a + b;
  }
  return x + 1;
}
```

`x` is used outside the loop. A dead-outside-loop check would nonetheless return `true` here because LLVM places the `phi` node that collects `x` inside the loop header, making the instruction appear to have no users outside the loop. In our implementation this edge case does not arise: `x = a + b` is hoisted simply because `isSafeToSpeculativelyExecute` returns `true`.
