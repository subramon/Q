#include <stdio.h>
#include "q_macros.h"
#include "_qsort_asc_I4.h"
#include "_qsort_dsc_F8.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int N  = 1048576+3;
  int32_t *X = NULL;
  double *Y = NULL;
  //--------------------------------
  X = malloc(N * sizeof(int32_t)); return_if_malloc_failed(X);
  for ( int i = 0; i < N; i++ ) { 
    X[i] = i+1;
    if ( ( i % 2 ) == 0 ) { X[i] *= -1; }
  }
  //--------------------------------
  Y = malloc(N * sizeof(double)); return_if_malloc_failed(Y);
  for ( int i = 0; i < N; i++ ) { 
    Y[i] = X[i];
  }
  //--------------------------------
  qsort_asc_I4(X, N); cBYE(status);
  qsort_dsc_F8(Y, N); cBYE(status);

  for ( int i = 1; i < N; i++, i++ ) { 
    if ( X[i] < X[i-1] ) { fprintf(stdout, "FAILURE\n"); go_BYE(-1); }
    if ( Y[i] > Y[i-1] ) { fprintf(stdout, "FAILURE\n"); go_BYE(-1); }
  }  
  fprintf(stdout, "SUCCESS\n");
  //--------------------------------
BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  return status;
}
