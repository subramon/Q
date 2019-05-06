#include <stdio.h>

int addInt(int n, int m) {
    return n+m;
}
int mulInt(int n, int m) {
  printf("m = %d,n = %d \n", m, n);
    return n*m;
}


int add2to3(int (*functionPtr)(int, int)) {
    return (*functionPtr)(2, 3);
}


int
main()
{
int sum, mul;
  int (*functionPtr)(int,int);

functionPtr = &addInt;

sum = (*functionPtr)(12, 13); // sum == 5
printf("sum = %d \n", sum);

sum = add2to3(functionPtr);
printf("sum = %d \n", sum);

mul = add2to3(&mulInt);
printf("mul = %d \n", mul);
}

