#include <stdio.h>


int main() {
  int x;
  unsigned y;
  scanf("%d", &x);
  scanf("%u", &y);

  int a = x * 17;
  int b = 16 * x;
  int c = x * 15;

  unsigned d = y / 16;
  int e = x / 16;

  int f = b + e;

  return 0;
}