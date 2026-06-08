// The restrict keyword on a pointer is a promise that the memory it points to
// will only be read or written to through that pointer. This solves the problem
// of Pointer Aliasing, where two or more pointers access the same memory area.


void test_simple(int * restrict A, int * restrict B, int N) {
    for (int i = 0; i < N; i++)
        A[i] = i + 1;
    for (int i = 0; i < N; i++)
        B[i] = A[i] + 1; 
}

void test_negative_step_loop(int * restrict A, int * restrict B) {
    for (int i = 100; i > 0; i--)
        A[i] = 1;
    for (int i = 100; i > 0; i--)
        B[i] = A[i]; 
}

void test_negative_dependence(int * restrict A, int * restrict B) {
    for (int i = 0; i < 100; i++)
        A[i] = 10;
    for (int i = 0; i < 100; i++)
        B[i] = A[i + 2];
}

void test_positive_dependence(int * restrict A, int * restrict B) {
    for (int i = 0; i < 100; i++) {
        A[i + 2] = 10;
    }
    for (int i = 0; i < 100; i++) {
        B[i] = A[i];
    }
}

void test_different_trip_count(int * restrict A, int * restrict B, int N, int M) {
    for (int i = 0; i < N; i++)
        A[i] = 1;
    for (int i = 0; i < M; i++)
        B[i] = 2;
}

void test_interleaved_code(int * restrict A, int * restrict B, int x) {
    for (int i = 0; i < 100; i++)
        A[i] = 1;
    A[0] = x;
    for (int i = 0; i < 100; i++)
        B[i] = 2;
}

void test_different_step(int * restrict A, int * restrict B) {
    for (int i = 0; i < 100; i++)
        A[i] = 1;
    for (int i = 0; i < 100; i++)
        A[i * 2] = 2;
}

void test_read_after_read(int * restrict A, int * restrict B, int * restrict C) {
    for (int i = 0; i < 100; i++)
        B[i] = A[i]; 
    for (int i = 0; i < 100; i++)
        C[i] = A[i + 2];
}

void test_non_affine_access(int * restrict A, int * restrict B, int * restrict idx) {
    for (int i = 0; i < 100; i++)
        A[idx[i]] = 1;
    for (int i = 0; i < 100; i++)
        B[i] = A[i];
}

void test_same_guard(int * restrict A, int * restrict B, int n) {
    if (n > 0) {
        int i = 0;
        do {
            A[i] = 1;
            i++;
        } while (i < n);
    }
    if (n > 0) {
        int i = 0;
        do {
            B[i] = 2;
            i++;
        } while (i < n);
    }
}

void test_same_guard_exit_phi(int * restrict A, int * restrict B, int n) {
    int somma = 0;
    if (n > 0) {
        int i = 0;
        do {
            A[i] = 1;
            i++;
        } while (i < n);
    }
    if (n > 0) {
        int i = 0;
        do {
            B[i] = 2;
            somma += B[i];
            i++;
        } while (i < n);
    }
    n = somma;
}

void test_guarded_exit_phi(int * restrict A, int * restrict B, int n, int x) {
    int val_a = 0;
    int val_b = 0;

    if (n > 0) {
        int i = 0;
        do {
            A[i] = x;
            val_a = x * 2; 
            i++;
        } while (i < n);
    }

    if (n > 0) {
        int i = 0;
        do {
            B[i] = x;
            val_b = x * 3;
            i++;
        } while (i < n);
    }

    // Outside loops variable uses, forcing phi node creation in exit blocks. Still, this is blocked by adjacency
    // (it also creates phi merging instruction between the two loops)
    A[0] = val_a; 
    B[0] = val_b; 
}

void test_different_guards(int * restrict A, int * restrict B, int n, int m) {
    if (n > 0) {
        int i = 0;
        do {
            A[i] = 1;
            i++;
        } while (i < n);
    }
    if (m > 0) {
        int i = 0;
        do {
            B[i] = 2;
            i++;
        } while (i < m);
    }
}