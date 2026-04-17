// Test per Strength Reduction Pass

int test_mul(int a) {
    int x1, x2, x3, x4, x5;

    x1 = a * 8;      // Power of 2 (2^3) --> a << 3
    x2 = a * 9;      // Power of 2 + 1 (2^3 + 1) --> (a << 3) + a
    x3 = a * 7;      // Power of 2 - 1 (2^3 - 1) --> (a << 3) - a
    x4 = 15 * a;     // Power of 2 - 1 (2^4 - 1) - commutativity test --> (a << 4) - a
    x5 = a * 6;      // Not a power of 2 or adjacent --> no opt

    return x1 + x2 + x3 + x4 + x5;
}

unsigned int test_udiv(unsigned int a) {
    unsigned int x1, x2;

    x1 = a / 4;      // Power of 2 (2^2) --> a >> 2 (lshr)
    x2 = a / 7;      // Not a power of 2 --> no opt

    return x1 + x2;
}

int test_sdiv(int a) {
    int x1, x2;

    x1 = a / 16;     // Power of 2 (2^4) --> (a + (a < 0 ? 15 : 0)) >> 4 (ashr)
    x2 = a / 3;      // Not a power of 2 --> no opt

    return x1 + x2;
}

int test_limit_cases(int a) {
    int x1, x2, x3;

    x1 = a * -8;     // Negative constant (sgt(0) check) --> no opt
    x2 = a / -4;     // Negative divisor (sgt(0) check) --> no opt
    x3 = a * 1;      // Constant is 1 (isPowerOf2 is true, log is 0) --> a << 0 
                     // Nota: tecnicamente x << 0 e' identita', gestita gia' da Algebraic Identity

    return x1 + x2 + x3;
}