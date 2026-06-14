// The restrict keyword on a pointer is a promise that the memory it points to will
// only be read or written to through that pointer. This solves the problem of
// Pointer Aliasing, where two or more pointers access the same memory area.

// On 64-bit computers, the int type is 32-bit, while pointers are 64-bit. To avoid
// LLVM generating the sext instruction needed to convert a 32-bit integer to a
// 64-bit integer, we use the 64-bit size_t type directly.

#include <stddef.h>

// Loop Fusible
void test_simple_positive_step(int * restrict A, int b, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[i] = i;
  for (size_t i = 0; i < N; i++)
    b = A[i];
}

// Loop Fusible
void test_simple_negative_step(int * restrict A, int b, size_t N) {
  for (size_t i = N; i > 0; i--)
    A[i] = i;
  for (size_t i = N; i > 0; i--)
    b = A[i];
}

// Not Loop Fusible
void test_negative_dependence_positive_step(int * restrict A, int b, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[i] = i;
  for (size_t i = 0; i < N; i++)
    b = A[i+1];
}

// Not Loop Fusible
void test_positive_dependence_negative_step(int * restrict A, int b, size_t N) {
  for (size_t i = N; i > 0; i--)
    A[i] = i;
  for (size_t i = N; i > 0; i--)
    b = A[i-1];
}

// Loop Fusible
void test_positive_dependence_positive_step(int * restrict A, int b, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[i] = i;
  for (size_t i = 0; i < N; i++)
    b = A[i-1];
}

// Loop Fusible
void test_negative_dependence_negative_step(int * restrict A, int b, size_t N) {
  for (size_t i = N; i > 0; i--)
    A[i] = i;
  for (size_t i = N; i > 0; i--)
    b = A[i+1];
}

// Not Loop Fusible
void test_different_trip_count(int a, int b, size_t N, size_t M) {
  for (size_t i = 0; i < N; i++)
    a = 1;
  for (size_t i = 0; i < M; i++)
    b = 2;
}

// Not Loop Fusible
void test_interleaved_code(int a, int b, int c, size_t N) {
  for (size_t i = 0; i < N; i++)
    a = 1;
  c = a + b;
  for (size_t i = 0; i < N; i++)
    b = 2;
}

// Not Loop Fusible
void test_different_step(int * restrict A, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[i] = 1;
  for (size_t i = 0; i < N; i++)
    A[i*2] = 2;
}

// Loop Fusible
void test_read_after_read(int * restrict A, int b, int c, size_t N) {
  for (size_t i = 0; i < N; i++)
    b = A[i]; 
  for (size_t i = 0; i < N; i++)
    c = A[i+1];
}

// Not Loop Fusible
void test_write_after_read(int * restrict A, int b, int c, size_t N) {
  for (size_t i = 0; i < N; i++)
    b = A[i];
  for (size_t i = 0; i < N; i++)
    A[i+1] = c;
}

// Not Loop Fusible
void test_write_after_write(int * restrict A, int b, int c, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[i] = b;
  for (size_t i = 0; i < N; i++)
    A[i+1] = c;
}

// Not Loop Fusible
void test_complex_access(int * restrict A, int b, size_t * restrict idx, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[idx[i]] = 1;
  for (size_t i = 0; i < N; i++)
    b = A[i];
}

// Loop Fusible
void test_constant_access_1(int * restrict A, int b, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[0] = 1;
  for (size_t i = 0; i < N; i++)
    b = A[1];
}

// Loop Fusible
void test_constant_access_2(int * restrict A, int b, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[0] = 1;
  for (size_t i = 0; i < N; i++)
    b = A[0];
}

// Not Loop Fusible
// Note: There are cases where it is possible to merge them, but we ignore them.
void test_mixed_access(int * restrict A, int b, size_t N) {
  for (size_t i = 0; i < N; i++)
    A[0] = 1;
  for (size_t i = 0; i < N; i++)
    b = A[i];
}

// Loop Fusible
void test_same_guard(int * restrict A, int * restrict B, size_t N) {
  if (N > 0) {
    size_t i = 0;
    do {
      A[i] = 1;
      i++;
    } while (i < N);
  }
  if (N > 0) {
    size_t i = 0;
    do {
      B[i] = 1;
      i++;
    } while (i < N);
  }
}

// Not Loop Fusible
void test_different_guards(int * restrict A, int * restrict B, size_t N, size_t M) {
  if (N > 0) {
    size_t i = 0;
    do {
      A[i] = 1;
      i++;
    } while (i < N);
  }
  if (M > 0) {
    size_t i = 0;
    do {
      B[i] = 1;
      i++;
    } while (i < M);
  }
}

// Loop Fusible
void test_iv_use_outside_loops_1(int * restrict A, int * restrict B, size_t N) {
  size_t i = 0;
  do {
    A[i] = 1;
    i++;
  } while (i < N);
  size_t j = 0;
  do {
    B[j] = 1;
    j++;
  } while (j < N);
  size_t i_use = i + 1;
  size_t j_use = j + 1;
}

// Loop Fusible
void test_iv_use_outside_loops_2(int * restrict A, int * restrict B, size_t N) {
  size_t i = 0;
  while (i < N) {
    A[i] = 1;
    i++;
  }
  size_t j = 0;
  while (j < N) {
    B[j] = 1;
    j++;
  }
  size_t i_use = i + 1;
  size_t j_use = j + 1;
}
