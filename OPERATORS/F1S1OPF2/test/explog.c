#include <stdio.h>
#include "q_macros.h"
#include "_exp_F8.h"
#include "_log_F8.h"
#include "_logit_F8.h"
#include "_logit2_F8.h"
#include <math.h>
int
main(
    )
{
  int status = 0;
#define N 100
  double *X = NULL;
  double *Y = NULL;
  double *Z = NULL;
  //--------MALLOC X----------------
  X = malloc(N * sizeof(double));
  return_if_malloc_failed(X);
  double vx = 1.3;
  for ( int i = 0; i < N; i++ ) {
    X[i] = vx;
    vx = vx + 1.0;
  }
  //---------MALLOC Y AND Z----------------
  Y = malloc(N * sizeof(double));
  return_if_malloc_failed(Y);
  Z = malloc(N * sizeof(double));
  return_if_malloc_failed(Y);
  //-----------TESTING-------------
  status = exp_F8(X, N, NULL, Y, NULL);
  status = log_F8(Y, N, NULL, Z, NULL);
  double threshold = 0.01;

  for ( int i = 0; i < N; i++ ) {
    if ( fabs(X[i] - Z[i] ) > threshold ) {
      printf("FAILURE\n");
      return 1;
    }
  }
  printf("EXP LOG SUCCESS\n");
  int xidx = 0;
  for ( double x = 0.01; xidx < 100; xidx++, x = x + 0.01 ) { 
    X[xidx] = x;
  }
  status = logit_F8(X, N, NULL, Y, NULL);
  for ( xidx = 0; xidx < N; xidx++ ) { 
    double temp = exp(X[xidx]) / (1 + exp(X[xidx]));
    if ( fabs(temp - Y[xidx]) > threshold) {
        printf("FAILURE\n");
        return 1;
    }
  }
  printf("LOGIT SUCCESS\n");
  status = logit2_F8(X, N, NULL, Y, NULL);
  for ( xidx = 0; xidx < N; xidx++ ) { 
    double temp = exp(X[xidx]) / ((1 + exp(X[xidx]))*(1 + exp(X[xidx])));
    if ( fabs(temp - Y[xidx]) > threshold) {
        printf("FAILURE\n");
        return 1;
    }
  }
  printf("LOGIT2 SUCCESS\n");
BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  return status;
}
