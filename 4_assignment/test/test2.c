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

// -----------------------------------------------------------------------------
// PART 2: EXPLICITLY GUARDED LOOPS TEST CASES
// Using if + do-while to force Clang to create a guard branch at -O0.
// -----------------------------------------------------------------------------

// TEST 5: MIXED GUARDS (One Guarded, One Unguarded) -> SHOULD FAIL
// The first loop executes 0 to n times (so it has a guard branch for n > 0).
// The second is a do-while, which enters always at least once (no guard).
// They are not Control Flow Equivalent.
void test_mixed_guards(int n, int *a) {
    int i = 0;
    int j = 0;
    // Loop 0 (Guarded)
    if (n > 0) {
        do {
            a[i] = i;
            i++;
        } while (i < n);
    }

    // Loop 1 (Unguarded)
    do {
        a[j] = a[j] + 1;
        j++;
    } while (j < 10);
}

// TEST 6: BOTH GUARDED (Pass Adjacency & CFE) -> SHOULD PASS
// Two identical loops, adjacent and protected by the same parameter n.
void test_both_guarded_pass(int n, int *a, int *b) {
    // Loop 0 (Guarded)
    int i = 0;
    int j = 0;
    if (1) {
        do {
            a[i] = i * 2;
            i++;
        } while (i < n);
    }

    // Loop 1 (Guarded)
    if (1) {
        do {
            b[j] = j * 2;
            j++;
        } while (j < n);
    }
}

// TEST 7: BOTH GUARDED, FAIL ADJACENCY -> SHOULD FAIL
// Both protected by n, but there is an interfering statement breaking adjacency.
void test_both_guarded_fail_adj(int n, int *a, int *b) {
    // Loop 0 (Guarded)
    int i = 0;
    int j = 0;
    if (1) {
        do {
            a[i] = i * 2;
            i++;
        } while (i < n);
    }

    // Interfering instruction (Breaks adjacency)
    a[0] = 999;

    // Loop 1 (Guarded)
    if (1) {
        do {
            b[j] = j * 2;
            j++;
        } while (j < n);
    }
}

// TEST 8: BOTH GUARDED, FAIL CFE -> SHOULD FAIL
// Both protected by bounds (n), but the second loop is conditioned 
// by an external 'if', breaking the dominance/post-dominance.
void test_both_guarded_fail_cfe(int n, int m, int *a, int *b) {
    // Loop 0 (Guarded)
    int i = 0;
    if (1) {
        do {
            a[i] = i * 2;
            i++;
        } while (i < n);
    }

    // The 'if' breaks the Control Flow Equivalence
    if (2) {
        // Loop 1 (Guarded)
        int j = 0;
        if (n > 0) {
            do {
                b[j] = j * 2;
                j++;
            } while (j < n);
        }
    }
}