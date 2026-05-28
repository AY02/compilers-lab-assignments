
void fun_base (int n, int a, int b){

    // first loop
    for (int i = 0; i < n; i++){
        a = b + i;
    }

    // second loop
    for (int i = 0; i < n; i++){
        b = a + i;
    }
}
