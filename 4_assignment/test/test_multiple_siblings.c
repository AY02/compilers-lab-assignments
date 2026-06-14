// The restrict keyword on a pointer is a promise that the memory it points to will
// only be read or written to through that pointer. This solves the problem of
// Pointer Aliasing, where two or more pointers access the same memory area.

// On 64-bit computers, the int type is 32-bit, while pointers are 64-bit. To avoid
// LLVM generating the sext instruction needed to convert a 32-bit integer to a
// 64-bit integer, we use the 64-bit size_t type directly.

#include <stddef.h>

// Loop Fusible
void test_multiple_siblings(int * restrict A, int * restrict B, int * restrict C,
  int * restrict D, size_t N) {
  for (size_t i = 0; i < N; i++) // %6
    A[i] = 1;
  for (size_t i = 0; i < N; i++) // %13
    B[i] = 2;
  for (size_t i = 0; i < N; i++) // %20
    C[i] = 3;
  for (size_t i = 0; i < N; i++) // %27
    D[i] = 4;
}