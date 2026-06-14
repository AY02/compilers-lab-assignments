void test_deep_nesting(int * restrict A, int * restrict B, int N) {
    for (int i1 = 0; i1 < N; i1++) {         
        for (int i2 = 0; i2 < N; i2++) {     
            
            for (int i4 = 0; i4 < N; i4++) { 
                for (int i8 = 0; i8 < N; i8++) A[i8] = 8; // loop body %15
                for (int i9 = 0; i9 < N; i9++) B[i9] = 9; // loop body %23
            }
            
            for (int i5 = 0; i5 < N; i5++) { 
                for (int i10 = 0; i10 < N; i10++) A[i10] = 10;
                for (int i11 = 0; i11 < N; i11++) B[i11] = 11;
            }
        }
        
        for (int i3 = 0; i3 < N; i3++) {
            
            for (int i6 = 0; i6 < N; i6++) {   
                for (int i12 = 0; i12 < N; i12++) A[i12] = 12;
                for (int i13 = 0; i13 < N; i13++) B[i13] = 13;
            }
            
            for (int i7 = 0; i7 < N; i7++) {  
                for (int i14 = 0; i14 < N; i14++) A[i14] = 14;
                for (int i15 = 0; i15 < N; i15++) B[i15] = 15;
            }
        }
    }
}

void test_four_siblings(int * restrict A, int * restrict B, int * restrict C, int * restrict D, int N) {
    for (int i = 0; i < N; i++) A[i] = 1;
    for (int i = 0; i < N; i++) B[i] = 2;
    for (int i = 0; i < N; i++) C[i] = 3;
    for (int i = 0; i < N; i++) D[i] = 4;
}