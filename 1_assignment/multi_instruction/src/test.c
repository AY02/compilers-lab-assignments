#include <stdio.h>


void test_1(int x) {
  int a = x + 1;
  int b = a - 1;
  int c = b + 30;
}

void test_2(int x) {
  int a = x + 1;
  int b = a + 2;
  int c = b - 2;
  int d = c - 1;

  int e = d + c;
}

void test_3(int x) {
  int a = 4 * x;
  int b = a / 4;
  int c = b + 30;
}

int main() {
  test_1(5);
  test_2(10);
  test_3(20);
  return 0;
}