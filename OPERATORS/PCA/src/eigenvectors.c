#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <lapacke.h>
#include "q_macros.h"
#include "eigenvectors.h"

int
eigenvectors(
             uint64_t n,
             double *W,
             double *A,
             double **X
            )
{
  int status = 0;

  char jobz = 'V'; /*want eigenvectors, use 'N' for eigenvalues only*/
  char uplo = 'U'; /*'U' for upper triangle of X, L for lower triangle of X*/
  int N = n;
  int LDA = N; /* dimensions of X = LDA by N*/
  
  for (uint64_t i = 0; i < n; i++ ) { 
    for (uint64_t j = 0; j < n; j++ ) { 
      A[i * n + j] = X[i][j];
    }
  }

  status = LAPACKE_dsyev(LAPACK_COL_MAJOR, jobz, uplo, N, A, LDA, W);
  return status;
}
