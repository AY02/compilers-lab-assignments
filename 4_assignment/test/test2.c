// TEST 1: PERFECT CANDIDATES (Should evaluate to TRUE)
// Two adjacent loops, same bounds, no code in between.
// Depending on clang version, these might be guarded identically or unguarded.
void test_perfect_fusion(int n, int *a, int *b, int *c) {
    // Loop 0
    for (int i = 0; i < n; i++) {
        a[i] = b[i] + 1;
    }

    // Loop 1
    for (int j = 0; j < n; j++) {
        c[j] = a[j] * 2;
    }
}

// TEST 2: NON-ADJACENT LOOPS (Should evaluate to FALSE)
// There is an interfering statement between the loops.
// This breaks the adjacency condition.
void test_non_adjacent(int n, int *a, int *b) {
    // Loop 0
    for (int i = 0; i < n; i++) {
        a[i] = i;
    }

    // Interfering instruction (Breaks adjacency)
    b[0] = 99;

    // Loop 1
    for (int j = 0; j < n; j++) {
        b[j] = a[j];
    }
}

// TEST 3: NOT CONTROL FLOW EQUIVALENT (Should evaluate to FALSE)
// Loop 1 is inside an IF condition. 
// Loop 0 dominates Loop 1, but Loop 1 DOES NOT post-dominate Loop 0 
// (because we could skip the IF branch).
void test_not_cf_equivalent(int n, int flag, int *a) {
    // Loop 0
    for (int i = 0; i < n; i++) {
        a[i] = i * 2;
    }

    // Condition breaking the Post-Dominance
    if (flag > 0) {
        // Loop 1
        for (int j = 0; j < n; j++) {
            a[j] = a[j] + 1;
        }
    }
}

// TEST 4: DIFFERENT GUARD CONDITIONS (Should evaluate to FALSE)
// Loops have different boundaries (n vs m).
// If they are emitted as guarded loops, the guard conditions will differ.
// They will fail the `Guard0->getCondition() == Guard1->getCondition()` check.
void test_different_guards(int n, int m, int *a, int *b) {
    // Loop 0
    for (int i = 0; i < n; i++) {
        a[i] = i;
    }

    // Loop 1
    for (int j = 0; j < m; j++) {
        b[j] = j;
    }
}