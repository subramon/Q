#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "bs.h"
int
main()
{
  int status = 0;
  float *X = NULL;  // [n] 
  float *Y = NULL;  // [m] 
  uint32_t *C = NULL;    // [n] 
  uint32_t n = 32; uint32_t m = 1048576;

  X = malloc(n * sizeof(float));
  C = malloc((n+1) * sizeof(uint32_t));
  Y = malloc(m * sizeof(float));
  for ( int i = 0; i < n; i++ ) { 
    X[i] = i;
  }
  for ( int i = 0; i < n+1; i++ ) { 
    C[i] = 0;
  }
  for ( int i = 0; i < m; i++ ) { 
    Y[i] = random() % (n+1);
  }
  status = bs(X, n, Y, m, C); 
  printf("status = %d \n", status);
  for ( int i = 0; i < n; i++ ) { 
    printf("<=%f,%d\n", X[i], C[i]);
  }
  printf(">%f,%d\n", X[n-1], C[n]);

  free(X);
  free(Y);
  free(C);
  return 0;
}
