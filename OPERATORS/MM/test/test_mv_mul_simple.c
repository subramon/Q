#include <omp.h>
#include "q_incs.h"
#include "_mv_mul_simple_F4_F4_F4.h"

static void
print_2d(
    float **X,
    int nR,
    int nC
    )
{
  for ( int i = 0; i < nR; i++ ) { 
    for ( int j = 0; j < nC; j++ ) { 
      printf("%f \t", X[j][i]);
    }
    printf("\n");
  }
  printf("\n");
}
int
main(
    )
{
  int status = 0;
  int M = 3;
  int K = 4;

  float **X = NULL;
  float *Y = NULL;
  float *Z = NULL;
  //----------------------------
  X = malloc(K * sizeof(float *));
  for ( int k = 0; k < K; k++ ) { 
    X[k] = malloc(M * sizeof(float));
  }
  for ( int k = 0; k  < K; k++ ) { 
    for ( int m = 0; m < M; m++ ) { 
      X[k][m] = (k+1)*(m+1);
    }
  }
  //----------------------------
  Y = malloc(K * sizeof(float));
  for ( int k = 0; k < K; k++ ) { 
    Y[k] = (k+1);
  }
  //----------------------------
  Z = malloc(M * sizeof(float));
  for ( int m = 0; m < M; m++ ) { Z[m] = FLT_MAX; }

  status = mv_mul_simple_F4_F4_F4(X, Y, Z, M, K);
  cBYE(status);
  print_2d(X, M, K);
  for ( int k = 0; k < K; k++ ) { printf("%f\n", Y[k]); } printf("\n");
  for ( int m = 0; m < M; m++ ) { printf("%f\n", Z[m]); } printf("\n");

BYE:
  return status;
}
