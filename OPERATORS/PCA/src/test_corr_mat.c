#include <time.h>
#include "corr_mat.h"

/*
gcc -g $QC_FLAGS corr_mat.c  -I../inc/ -I$HOME/WORK/Q/UTILS/inc/
*/
int
main(
    )
{
  int status = 0;
  uint64_t N = 10;
  uint64_t M = 3;
  double **A = NULL;
  float **X = NULL;
  clock_t start_t, stop_t;

  X = malloc(M * sizeof(float *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    X[i] = malloc(N * sizeof(float));
  }

  A = malloc(M * sizeof(double *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    A[i] = malloc(M * sizeof(double));
  }

  X[0][0] = 0.0656218; X[0][1] = -1.9030321; X[0][2] = -0.5905962; X[0][3] = 0.7218398; X[0][4] = 0.7218398; 
  X[0][5] = 0.0656218; X[0][6] = -1.2468141; X[0][7] = 1.3780577; X[0][8] = 0.0656218; X[0][9] = 0.7218398;

  X[1][0] = 0.3162278; X[1][1] = -1.5811388; X[1][2] = -0.3162278; X[1][3] = 1.5811388; X[1][4] = 0.9486833; 
  X[1][5] = -0.9486833; X[1][6] = -0.3162278; X[1][7] = 0.9486833; X[1][8] = 0.3162278; X[1][9] = -0.9486833;

  X[2][0] = -0.74819953; X[2][1] = 1.03322792; X[2][2] = -0.03562855; X[2][3] = -1.46077051; X[2][4] = 0.67694243; 
  X[2][5] = 1.38951342; X[2][6] = -0.74819953; X[2][7] = 1.03322792; X[2][8] = -0.03562855; X[2][9] = -1.10448502;

  system("date");
  start_t = clock();
  status = corr_mat(X, M, N, A);
  stop_t = clock();
  system("date");
  fprintf(stderr, "Num clocks = %llu \n", (unsigned long long)stop_t - start_t);
#define CHECK_RESULTS
#ifdef CHECK_RESULTS
  for ( unsigned int ii = 0; ii < M; ii++ ) { 
    for ( unsigned int jj = 0; jj < M; jj++ ) { 
      double chk = 0;
      for ( unsigned int l = 0; l < N; l++ ) { 
        chk += (X[ii][l] * X[jj][l]);
      }
      if ( ( ( A[ii][jj] -  chk) / chk )  > 0.001 ) {
        fprintf(stderr, "chk = %lf, A = %lf \n", chk, A[ii][jj]);
        go_BYE(-1);
      }
    }
  }

  for ( unsigned int ii = 0; ii < M; ii++ ) {
    for ( unsigned int jj = 0; jj < M; jj++ ) {
      printf("%lf ", A[jj][ii]);
    }
    printf("\n");
  }

#endif
BYE:
  if ( X != NULL ) { 
    for ( uint64_t i = 0; i < M; i++ ) {
      free_if_non_null(X[i]);
    }
  }
  free_if_non_null(X);

  if ( A != NULL ) { 
    for ( uint64_t i = 0; i < M; i++ ) {
      free_if_non_null(A[i]);
    }
  }
  free_if_non_null(A);
  return status;
}

 // gcc $QC_FLAGS sum_prod.c -I../inc/  -o a.out -I../../../UTILS/inc/

