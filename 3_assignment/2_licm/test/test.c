// 'x' is loop-invariant and safe to speculatively execute, so it is hoisted
// to the preheader. 
// Note that the body block never dominates the exiting block (which by using
// the for cycle, it is the header where the loop is "inizialized") because 
// the loop may not execute at all, so hoisting relies on isSafeToSpeculativelyExecute
// rather than dominatesAllExits
int test_basic_hoisting(int a, int b, int n) {
  int sum = 0;
  // Loop
  for (int i = 0; i < n; i++) {
    int x = a * b;    // Invariant (a and b are arguments)
    int y = a / b;    // Invariant, not safe, does not dominate the exits, therefore is not hoistes
    sum += x + i;     // Variant (x is invariant, but i is not invariant)
  }
  return sum;
}

// 'x' is loop-invariant but not safe to speculatively execute (integer
// division can raise division-by-zero). However, its block dominates all
// loop exits, meaning the division is guaranteed to execute whenever the
// loop runs, and therefore it is correct to hoist it
int test_dominance_needed(int a, int b, int n) {
  int sum = 0;
  int i = 0;
  
  // The do-while allows the body to dominate the exiting block
  do {
    int x = a / b;  // Invariant, not safe to speculate, but dominates all exits, and therefore hoisted
    int y = a + b;  // Invariant, safe to speculate and dominates all exits, both conditions are true, clearly hoisted
    sum += x + i;   // Variant (x is invariant, but i is not invariant)
    i++;
  } while (i < n);
  
  return sum;
}

int test_nested_hoisting(int a, int b, int n) {
  int sum = 0;
  // Outer Loop
  for (int i = 0; i < n; i++) {
    // Inner Loop
    for (int j = 0; j < n; j++) {
      int x = a + b;  // Invariant with respect to the inner loop and invariant
                      // with respect to the outer loop (hoisted to the inner
                      // preheader first, then to the outer preheader)
      sum += x + j;   // Variant (x is invariant, but j is not invariant)
    }
  }
  return sum;
}

// The mayReadFromMemory and mayHaveSideEffects guards prevent hoisting.
// This is made during the InvariantSet creation for code ssimplifications:
// by design, the InvariantSet contains only instructions that are candidates 
// for hoisting, not all loop-invariant instructions in the mathematical sense.
// Hoisting the load could read a value before it is initialised. Hoisting
// the store could change the number of times the side effect is observed.
void test_memory_no_hoist(int *ptr, int n) {
  // Loop
  for (int i = 0; i < n; i++) {
    int val = *ptr;   // Invariant, but excluded from the InvariantSet by the
                      // mayReadFromMemory guard, therefore not hoisted
    *ptr = 42;        // Invariant, but excluded from the InvariantSet by the
                      // mayHaveSideEffects guard, therefore not hoisted
  }
}

// Both 'x' and 'y' are loop-invariant. 'y' depends on 'x', so 'x' must be
// hoisted before 'y'. The RPO traversal guarantees that 'x' is inserted into
// the InvariantSet before 'y', preserving the correct def-use order during
// code motion.
int test_invariants_chain(int a, int b, int n) {
  int sum = 0;
  // Loop
  for (int i = 0; i < n; i++) {
    int x = a + b;    // Invariant (a and b are arguments)
    int y = x * 42;   // Invariant (x is invariant, 42 is constant)
    sum += y + i;     // Variant (y is invariant, but i is not invariant)
  }
  return sum;
}