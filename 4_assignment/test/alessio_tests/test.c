void test_fusable_nested(int *A, int *B) {
    for (int i = 0; i < 100; i++) {
        A[i] = i + 1;
    }
    for (int i = 0; i < 100; i++) {
        B[i] = A[i] + 1; 
    }
}