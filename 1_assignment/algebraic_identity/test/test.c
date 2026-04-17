
int add(int a, int b) {
    int x1, x2, x3;

    x1 = a + 0;      // should optimize --> a
    x2 = 0 + a;      // should optimize --> a
    x3 = a + b;      // no opt

    int ret = x1 + x2 + x3;
    return ret;
}

int sub(int a, int b) {
    int x1, x2, x3;

    x1 = a - 0;      // should optimize --> a
    x2 = 0 - a;      // no opt
    x3 = a - b;      // no opt

    int ret = x1 + x2 + x3;
    return ret;
}

int mul(int a, int b) {
    int x1, x2, x3, x4;

    x1 = a * 1;      // should optimize --> a
    x2 = 1 * a;      // should optimize --> a
    x3 = a * 0;      // should optimize --> 0
    x4 = a * b;      // no opt

    int ret = x1 + x2 + x3 + x4;
    return ret;
}

int div(int a, int b) {
    int x1, x2, x3, x4, x5;

    x1 = a / 1;      // should optimize --> a
    x2 = 0 / a;      // should optimize --> 0
    x3 = 1 / a;      // no opt
    x4 = a / b;      // no opt
    x5 = a / 0;      // no opt

    int ret = x1 + x2 + x3 + x4 + x5;
    return ret;
}

// to test the nested case works with one pass execution
int nested(int a) {
    int x = a + 0;
    int y = x + 0;
    int z = y + 0;
    return z;
}