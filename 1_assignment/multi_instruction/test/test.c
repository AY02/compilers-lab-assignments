// Test for Multi Instruction Optimization Pass

// CASE 1: (x + k) - k = x
int test_add_sub(int x) {
    int add = x + 5;
    int sub = add - 5;    // should optimize --> x
    return sub;
}

// CASE 2: (k + x) - k = x
int test_add_sub_comm(int x) {
    int add = 5 + x;
    int sub = add - 5;    // should optimize --> x
    return sub;
}

// CASE 3: (x - k) + k = x
int test_sub_add(int x) {
    int sub = x - 10;
    int add = sub + 10;   // should optimize --> x
    return add;
}

// CASE 4: (x * k) / k = x (Signed division)
int test_mul_sdiv(int x) {
    int mul = x * 4;
    int div = mul / 4;    // should optimize --> x
    return div;
}

// CASE 5: (x / k) * k = x
// Note: The pass will only optimize if the 'sdiv' is marked as 'exact'
int test_sdiv_mul(int x) {
    int div = x / 8;
    int mul = div * 8;    // should optimize --> x (if exact)
    return mul;
}

// NEGATIVE CASE 1: Different constants
int test_wrong_constants(int x) {
    int add = x + 5;
    int sub = add - 4;    // no opt
    return sub;
}

// NEGATIVE CASE 2: Constant as first operand in subtraction
int test_sub_wrong_order(int x) {
    int sub = 10 - x;
    int add = sub + 10;   // no opt
    return add;
}

// "MATRIOSKA" CASE: Multiple nested optimizations
int matrioska_case(int x) {
  int a = x * 2;
  int b = a - 5;
  int c = b + 2;
  int d = c - 2;          // should optimize --> b
  int e = d + 5;          // should optimize --> a
  int f = e / 2;          // should optimize --> x
  return f;
}