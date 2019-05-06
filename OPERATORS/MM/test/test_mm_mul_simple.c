
#include "q_incs.h"
#include "_mm_mul_simple_F4_F4_F4.h"

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
  int K = 2;
  int N = 4;
  float **X = NULL;
  float **Y = NULL;
  float **Z = NULL;
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
  Y = malloc(N * sizeof(float *));
  for ( int n = 0; n < N; n++ ) { 
    Y[n] = malloc(K * sizeof(float));
  }
  for ( int n = 0; n  < N; n++ ) { 
    for ( int k = 0; k  < K; k++ ) { 
      Y[n][k] = (n+1)*(k+1);
    }
  }
  //----------------------------
  Z = malloc(N * sizeof(float *));
  for ( int n = 0; n < N; n++ ) { 
    Z[n] = malloc(M * sizeof(float));
  }
  status = mm_mul_simple_F4_F4_F4(X, Y, Z, M, K, N);
  cBYE(status);
  print_2d(X, M, K);
  print_2d(Y, K, N);
  print_2d(Z, M, N);
BYE:
  return status;
}
