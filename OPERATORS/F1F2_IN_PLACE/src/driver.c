#include "qsort2.h"
#include "qsort2_asc_I4.h"
#include<stdio.h>
#include<stdlib.h>

int main()
{
  int N = 10;
  int X[N];
  int Y[N];
  int index = 0;

  for ( int i = N; i > 0; i-- ) {
    X[index] = i;
    Y[index] = i + 2;
    index++;
  }

  printf("Before sort\n==============\n");
  for ( int i = 0; i < N; i++ ) {
    printf("%d\t%d\n", X[i], Y[i]);
  }

  //int status = qsort2(X, Y, N);
  int status = qsort_asc_I4(X, Y, N);
  printf("\nstatus = %d\n", status);

  printf("\nAfter sort\n==============\n");
  for ( int i = 0; i < N; i++ ) {
    printf("%d\t%d\n", X[i], Y[i]);
  }

go_BYE:
  return status;
}
