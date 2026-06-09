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

void test_IV1_use_outside_loops(int * restrict A, int * restrict B, int n) {
    int i = 0;
    do {
        A[i] = 1;
        i++;
    } while (i < n);
    int j = 0;
    do {
        B[j] = 2;
        j++;
    } while (j < n);
    int random_instruction = i + 5;
    int j_use = j + 1;
}