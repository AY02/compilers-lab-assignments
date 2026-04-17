// Test for Strength Reduction Pass

int test_mul(int a) {
    int x1, x2, x3, x4, x5;

    x1 = a * 8;      // power of 2 (2^3) --> a << 3
    x2 = a * 9;      // power of 2 + 1 (2^3 + 1) --> (a << 3) + a
    x3 = a * 7;      // power of 2 - 1 (2^3 - 1) --> (a << 3) - a
    x4 = 15 * a;     // power of 2 - 1 (2^4 - 1) - commutativity test --> (a << 4) - a
    x5 = a * 6;      // not a power of 2 or adjacent --> no opt

    return x1 + x2 + x3 + x4 + x5;
}

unsigned int test_udiv(unsigned int a) {
    unsigned int x1, x2;

    x1 = a / 4;      // power of 2 (2^2) --> a >> 2 (lshr)
    x2 = a / 7;      // not a power of 2 --> no opt

    return x1 + x2;
}

int test_sdiv(int a) {
    int x1, x2;

    x1 = a / 16;     // power of 2 (2^4) --> (a + (a < 0 ? 15 : 0)) >> 4 (ashr)
    x2 = a / 3;      // not a power of 2 --> no opt

    return x1 + x2;
}

int test_limit_cases(int a) {
    int x1, x2, x3;

    x1 = a * -8;     // negative constant (sgt(0) check) --> no opt
    x2 = a / -4;     // negative divisor (sgt(0) check) --> no opt
    x3 = a * 1;      // constant is 1 (isPowerOf2 is true, log is 0) --> a << 0 

    return x1 + x2 + x3;
}