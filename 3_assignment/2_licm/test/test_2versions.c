
int test_2versions(int a, int b, int n) {
  int x = 10; 
  for (int i = 0; i < n; i++) {
    x = a + b; 
  }
  return x + 1;
}

int test_with_do_while(int a, int b, int n) {
  int x = 10;
  int i = 0; 
  do {
    x = a + b;
    i++;
  } while(i < n);
  return x + 1;
}

int test_with_do_while_early_exits(int a, int b, int n) {
  int x = 10;
  do {
      x = a + b;         
      if (n) break;  
      x = a + b;      
  } while (!n);       
  return x + 1;
}
