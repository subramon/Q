#include <stdio.h>
#include "q_macros.h"
#include "_convert_I4_I2.h"
#include <math.h>
int
main(
    )
{
  int status = 0;
#define N 100
  int32_t *X = NULL;
  int16_t *Y = NULL;
  //--------MALLOC X----------------
  X = malloc(N * sizeof(int32_t));
  return_if_malloc_failed(X);
  int32_t vx = 5;
  for ( int i = 0; i < N; i++ ) {
    X[i] = vx;
    vx = vx + 10;
  }
  //---------MALLOC Y----------------
  Y = malloc(N * sizeof(int16_t));
  return_if_malloc_failed(Y);
  //-----------TESTING-------------
  status = convert_I4_I2(X, N, NULL, Y);

  for ( int i = 0; i < N; i++ ) {
    if ( (int16_t)X[i] != Y[i] ) {
      printf("FAILURE\n");
      return 1;
    }
  }
  printf("CONVERT SUCCESS\n");
BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  return status;
}
