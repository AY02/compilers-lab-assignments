// The restrict keyword on a pointer is a promise that the memory it points to will
// only be read or written to through that pointer. This solves the problem of
// Pointer Aliasing, where two or more pointers access the same memory area.

// On 64-bit computers, the int type is 32-bit, while pointers are 64-bit. To avoid
// LLVM generating the sext instruction needed to convert a 32-bit integer to a
// 64-bit integer, we use the 64-bit size_t type directly.

#include <stddef.h>

// Loop Fusible
void test_nested_loops(int * restrict A, int * restrict B, size_t N) {
  for (size_t i1 = 0; i1 < N; i1++) {
    for (size_t i2 = 0; i2 < N; i2++) {
      for (size_t i4 = 0; i4 < N; i4++) {
        for (size_t i8 = 0; i8 < N; i8++) // %13
          A[i8] = 8;
        for (size_t i9 = 0; i9 < N; i9++) // %20
          B[i9] = 9;
      }
      for (size_t i5 = 0; i5 < N; i5++) {
        for (size_t i10 = 0; i10 < N; i10++) // %33
          A[i10] = 10; // %13
        for (size_t i11 = 0; i11 < N; i11++) // %40
          B[i11] = 11;
      }
    }
    for (size_t i3 = 0; i3 < N; i3++) {
      for (size_t i6 = 0; i6 < N; i6++) {
        for (size_t i12 = 0; i12 < N; i12++) // %59
          A[i12] = 12;
        for (size_t i13 = 0; i13 < N; i13++) // %66
          B[i13] = 13;
      }
      for (size_t i7 = 0; i7 < N; i7++) {
        for (size_t i14 = 0; i14 < N; i14++) // %79
          A[i14] = 14;
        for (size_t i15 = 0; i15 < N; i15++) // %86
          B[i15] = 15;
      }
    }
  }
}