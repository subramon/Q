#include "q_incs.h"
#include "matrix_helpers.h"
#include "positive_solver.h"

#define DEFAULT_EPS 0.001

/* Andrew Winkler
 It has the virtue of dramatic simplicity - there's no need to explicitly construct the cholesky decomposition, no need to do the explicit backsubstitutions.
 Yet it's essentially equivalent to that more labored approach, so its performance/stability/memory, etc. should be at least as good.
*/
static int _positive_solver_rec(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  int status = 0;
  /// printf("The alpha is %f\n", A[0][0]);
  if (n < 1) { go_BYE(-1); }
  if (n == 1) {
    if (A[0][0] == 0.0) {
      if (abs(b[0]) > DEFAULT_EPS) { go_BYE(-1); }
        x[0] = 0.0;
        return 0;
    }
    x[0] = b[0] / A[0][0];
    return 0;
  }

  double * bvec = b + 1;
  double * Avec = A[0] + 1;
  double ** Asub = A + 1;
  double * xvec = x + 1;

  int m = n -1;

  if (A[0][0] != 0.0) {
    int nT = sysconf(_SC_NPROCESSORS_ONLN);
    #pragma omp parallel for
    for (int t = 0; t < nT; t++) {
      for(int i=0; i < m; i++){
        if ((i - i / nT) % nT != t) continue;
        bvec[i] -= Avec[i] * b[0] / A[0][0];
        for(int j=0; j < m - i; j++)
          Asub[i][j] -= Avec[i] * Avec[i+j] / A[0][0];
      }
    }
  } /* else check that Avec is 0 */

  status = _positive_solver_rec(Asub, xvec, bvec, m);
  cBYE(status);
  if ( status < 0 ) { return status; }

  if (A[0][0] == 0.0) {
      if (b[0] != 0.0) { go_BYE(-1); }  /* or close enough... */
      x[0] = 0.0;
      return status;
  }

  double p = 0;
  for ( int k = 0; k < m; k++ ) {
    p += Avec[k] * xvec[k];
  }

  x[0] = (b[0] - p) / A[0][0];

BYE:
  return status;
}

static bool _positive_solver_check(
    double **A,
    double *x,
    double *b,
    int n,
    double eps,
    bool is_symm
    )
{
  int status = 0;
  bool result = false;

  double *b_prime = NULL;
  b_prime = malloc(n * sizeof(double)); return_if_malloc_failed(b_prime);

  if (is_symm) {
    multiply_symm_matrix_vector(A, x, n, b_prime);
  } else {
    multiply_matrix_vector(A, x, n, b_prime);
  }

  result = true;
  for (int i = 0; i < n; i++) {
    if (abs(b_prime[i] - b[i]) > eps) {
      result = false;
      break;
    }
  }

 BYE:
  free_if_non_null(b_prime);
  if (status != 0) result = false;
  return result;
}

bool full_positive_solver_check(
    double **A,
    double *x,
    double *b,
    int n,
    double eps
    )
{
  bool is_symm = false;
  if (0 < eps) eps = DEFAULT_EPS;
  return _positive_solver_check(A, x, b, n, eps, is_symm);
}

bool symm_positive_solver_check(
    double **A,
    double *x,
    double *b,
    int n,
    double eps
    )
{
  bool is_symm = true;
  if (0 < eps) eps = DEFAULT_EPS;
  return _positive_solver_check(A, x, b, n, eps, is_symm);
}


int posdef_positive_solver_fast(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  return _positive_solver_rec(A, x, b, n);
}

int posdef_positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  int status = 0;
  // copoies of A and b to preserve input.
  double ** A_copy = NULL;
  double * b_copy = NULL;

  status = alloc_symm_matrix(&A_copy, n); cBYE(status);
  b_copy = malloc(n * sizeof(double));
  return_if_malloc_failed(b_copy);

  for ( int i = 0; i < n; i++ ) {
    for ( int j = 0; j < n-i; j++ ) {
      A_copy[i][j] = A[i][j];
    }
    b_copy[i] = b[i];
  }

  status = _positive_solver_rec(A_copy, x, b_copy, n);

BYE:
  free_matrix(A_copy, n);
  free_if_non_null(b_copy);
  return status;
}

int full_posdef_positive_solver_fast(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  int status = 0;
  for (int i = 0; i < n; i++) {
    A[i] += i;
  }

  status = _positive_solver_rec(A, x, b, n); cBYE(status);

BYE:
  for (int i = 0; i < n; i++) {
    A[i] -= i;
  }
  return status;
}

int full_posdef_positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  int status = 0;
  // copies of A and b in order to preserve input.
  double ** A_copy = NULL;
  double * b_copy = NULL;

  status = alloc_symm_matrix(&A_copy, n); cBYE(status);
  b_copy = malloc(n * sizeof(double)); return_if_malloc_failed(b_copy);

  for ( int i = 0; i < n; i++ ) {
    for ( int j = 0; j < n-i; j++ ) {
      A_copy[i][j] = A[i][j + i];
    }
    b_copy[i] = b[i];
  }

  status = _positive_solver_rec(A_copy, x, b_copy, n);

 BYE:
  free_matrix(A_copy, n);
  free_if_non_null(b_copy);
  return status;
}

int positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    )
{
  int status = 0;

  double ** AtA = NULL;
  double * Atb = NULL;
  status = alloc_symm_matrix(&AtA, n); cBYE(status);
  Atb = malloc(n * sizeof(double)); return_if_malloc_failed(Atb);

  transpose_and_multiply(A, AtA, n);
  transpose_and_multiply_matrix_vector(A, b, n, Atb);
  status = posdef_positive_solver_fast(AtA, x, Atb, n); cBYE(status);

BYE:
  free_matrix(AtA, n);
  free_if_non_null(Atb);
  return status;
}
