#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>
#include "macros.h"
#include "matrix_helpers.h"

/* some utilities.
   NOTE: matrices are assumed to be stored as columns. */

extern void
free_matrix(
      double **A,
      int n
      )
{
  if ( A != NULL ) {
    for ( int i = 0; i < n; i++ ) {
      free_if_non_null(A[i]);
    }
  }
  free_if_non_null(A);
}

extern double
index_symm_matrix(
      double ** A,
      int i,
      int j
      )
{
  return i < j ? A[i][j - i] : A[j][i - j];
}

extern void
multiply_symm_matrix_vector(
    double **A,
    double *x,
    int n,
    double *b
    )
{
  for ( int i = 0; i < n; i++ ) {
    double sum = 0;
    for ( int j = 0; j < n; j++ ) {
      sum += index_symm_matrix(A, i, j) * x[j];
    }
    b[i] = sum;
  }
}

extern int
alloc_symm_matrix(
    double ***ptr_X,
    int n
    )
{
  int status = 0;
  double **X = NULL;
  *ptr_X = NULL;
  X = (double **) malloc(n * sizeof(double*));
  return_if_malloc_failed(X);
  for ( int i = 0; i < n; i++ ) { X[i] = NULL; }
  for ( int i = 0; i < n; i++ ) {
    X[i] = (double *) malloc((n - i) * sizeof(double));
    return_if_malloc_failed(X[i]);
  }
  *ptr_X = X;
BYE:
  return status;
}

// TODO: use an actual matrix multiplication algo
extern void
square_symm_matrix(
    double **A,
    double **B,
    int n
    )
{
  for ( int i = 0; i < n; i++ ) {
    for ( int j = 0; j < n - i; j++ ) {
      double sum = 0;
      for ( int k = 0; k < n; k++ ) {
        sum += index_symm_matrix(A, i, k) * index_symm_matrix(A, k, j + i);
      }
      B[i][j] = sum;
    }
  }
}

extern void
multiply_matrix_vector(
    double **A,
    double *x,
    int n,
    double *b
    )
{
  for ( int i = 0; i < n; i++ ) {
    double sum = 0;
    for ( int j = 0; j < n; j++ ) {
      sum += A[j][i] * x[j];
    }
    b[i] = sum;
  }
}

extern void
transpose_and_multiply_matrix_vector(
                       double **A,
                       double *x,
                       int n,
                       double *b
                       )
{
  for ( int i = 0; i < n; i++ ) {
    double sum = 0;
    for ( int j = 0; j < n; j++ ) {
      sum += A[i][j] * x[j];
    }
    b[i] = sum;
  }
}

extern int
alloc_matrix(
    double ***ptr_X,
    int n
    )
{
  int status = 0;
  double **X = NULL;
  *ptr_X = NULL;
  X = (double **) malloc(n * sizeof(double*));
  return_if_malloc_failed(X);
  for ( int i = 0; i < n; i++ ) { X[i] = NULL; }
  for ( int i = 0; i < n; i++ ) {
    X[i] = (double *) malloc(n * sizeof(double));
    return_if_malloc_failed(X[i]);
  }
  *ptr_X = X;
BYE:
  return status;
}

// TODO: use an actual matrix multiplication algo
extern void
transpose_and_multiply(
    double **A,
    double **B,
    int n
    )
{
  for ( int i = 0; i < n; i++ ) {
    for ( int j = 0; j < n - i; j++ ) {
      double sum = 0;
      for ( int k = 0; k < n; k++ ) {
        // a normal mat mult would use A[i][k],
        // but since we're computing A^tA we write A[k][i]
        sum += A[i][k] * A[j+i][k];
      }
      B[i][j] = sum;
    }
  }
}
