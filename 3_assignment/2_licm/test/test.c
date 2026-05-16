int test_basic_hoisting(int a, int b, int n) {
  int sum = 0;
  // Loop
  for (int i = 0; i < n; i++) {
    int x = a * b;    // Invariant (a and b are arguments)
    sum += x + i;     // Variant (x is invariant, but i is not invariant)
  }
  return sum;
}

int test_nested_hoisting(int a, int b, int n) {
  int sum = 0;
  // Outer Loop
  for (int i = 0; i < n; i++) {
    // Inner Loop
    for (int j = 0; j < n; j++) {
      int x = a + b;  // Invariant with respect to the inner loop and invariant
                      // with respect to the outer loop (hoisted twice).
      sum += x + j;   // Variant (x is invariant, but j is not invariant)
    }
  }
  return sum;
}

// 'x' is loop-invariant, but its block comes after a conditional break.
// The break introduces an exit edge that 'x' does not dominate: the loop
// can exit before reaching 'x'. Because dominatesAllExits fails, 'x'
// should not be hoisted.
int test_dominance_early_exit(int a, int b, int n, int *array) {
  int sum = 0;
  // Loop
  for (int i = 0; i < n; i++) {
    if (array[i] == 0) {
      break;          // Early exit (creates an exit not dominated by the block of 'x')
    }
    int x = a * b;    // Invariant (a and b are arguments), but does not dominate
                      // all exits, so it should not be hoisted.
    sum += x;
  }
  return sum;
}

// The mayReadFromMemory and mayHaveSideEffects guards prevent hoisting.
// Hoisting the load could read a value before it is initialised. Hoisting
// the store could change the number of times the side effect is observed.
void test_memory_no_hoist(int *ptr, int n) {
  // Loop
  for (int i = 0; i < n; i++) {
    int val = *ptr;   // Not invariant (reads from memory)
    *ptr = 42;        // Not invariant (has side effects)
  }
}

// Both 'x' and 'y' are loop-invariant. 'y' depends on 'x', so 'x' must be
// hoisted before 'y'. The RPO traversal guarantees that 'x' is inserted into
// the InvariantSet before 'y', preserving the correct def-use order during
// Code Motion.
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