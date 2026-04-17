// CASO 1: (x + k) - k = x
int test_add_sub(int x) {
    int add = x + 5;
    int sub = add - 5;
    return sub;
}

// CASO 2: (k + x) - k = x
int test_add_sub_comm(int x) {
    int add = 5 + x;
    int sub = add - 5;
    return sub;
}

// CASO 3: (x - k) + k = x
int test_sub_add(int x) {
    int sub = x - 10;
    int add = sub + 10;
    return add;
}

// CASO 4: (x * k) / k = x (Divisione con segno)
int test_mul_sdiv(int x) {
    int mul = x * 4;
    int div = mul / 4;
    return div;
}

// CASO 5: (x / k) * k = x
// Nota: In C standard non c'è un modo diretto per forzare "sdiv exact",
// ma Clang potrebbe dedurlo o generare una normale divisione. 
// Il tuo pass salterà l'ottimizzazione se l'istruzione non è 'exact'.
int test_sdiv_mul(int x) {
    int div = x / 8;
    int mul = div * 8;
    return mul;
}

// CASO NEGATIVO 1: Costanti diverse
int test_wrong_constants(int x) {
    int add = x + 5;
    int sub = add - 4;
    return sub;
}

// CASO NEGATIVO 3: Costante come primo operando nella sottrazione
int test_sub_wrong_order(int x) {
    int sub = 10 - x;
    int add = sub + 10;
    return add;
}