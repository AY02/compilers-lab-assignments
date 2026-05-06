int test_nested_loops(int a, int b) {
  int sum = 0;
  // Outer Loop
  for (int i = 0; i < 10; i++) {
    int x = a + b;    // Invariant (a and b are arguments)
    // Inner Loop
    for (int j = 0; j < 10; j++) {
      int y = x * 2;  // Invariant (x is outside the loop, 2 is constant)
      int z = y + x;  // Invariant (y and x are invariants)
      sum += y + j;   // Variant (y is invariant, but j is not invariant)
    }
  }
  return sum;
}

int test_invariants_chain(int a, int b) {
  int sum = 0;
  for (int i = 0; i < 10; i++) {
    int x = a + b;  // Invariant (a and b are arguments)
    int y = x * 42; // Invariant (x is invariant, 42 is constant)
    int z = y - 5;  // Invariant (y is invariant, 5 is constant)
    sum += z + i;   // Variant (z is invariant, but i is not invariant)
  }
  return sum;
}

// This requires preliminary CSE optimisation because, in the two branches, x is
// replaced by two different variables, x (%9) and x (%11), with the same RHS.
// Consequently, y is not recognised as a loop-invariant.
int test_branch_phi(int a, int b, int cond) {
  int sum = 0;
  int x;
  // Loop
  for (int i = 0; i < 10; i++) {
    if (cond)
      x = a + b;    // Invariant (a and b are arguments)
    else
      x = a + b;    // Invariant (a and b are arguments)
    int y = x * 2;  // It should be invariant (x is invariant, 2 is constant)
    sum += y;       // Variant (y is invariant, but sum.phi (%.02) is variant)
  }
  return sum;
}

int test_conditional_mutation(int a, int cond) {
  int x = a;
  int sum = 0;
  // Loop
  for (int i = 0; i < 10; i++) {
    int y = x + 5;  // Variant (5 is constant, but x is variant)
    sum += y;
    if (cond) {
      x = i;        // Variant (i is variant)
    }
  }
  return sum;
}

// This test case does not work because, even when compiled with the -O0 option,
// the frontend performs the optimisation of replacing uses of x directly with
// val.
// See the file test_phi_invariant.ll for a test case in which the phi
// instruction has identical input values.
void test_phi_invariant(int a, int b) {
  int val = a + b;
  int sum = 0;
  int x;
  // Loop
  for (int i = 0; i < 10; i++) {
    if (i % 2 == 0) {
      x = val;  // Invariant (val is outside the loop)
    } else {
      x = val;  // Invariant (val is outside the loop)
    }
    // <-- Branch merge node (if.end), having phi with identical input values.
    sum += x;   // Variant (x is invariant, but sum.phi (%.02) is variant)
  }
}