/* To execute:
 * ./driver <n> # for some positive integer n
 * */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>
#include <time.h>
#include <lapacke.h>
#include "q_macros.h"
#include "matrix_helpers.h"
#include "positive_solver.h"

/* testing and benchmarking for AxEqualsB solver.
 * generates a random matrix A, and tests the positive semidefinite solver
 * by running iton AtA and tests the full solver by running it on A.
 *
 * the current method of generating random matrices isn't perfect, but it's
 * better than it seems because solving Ax = b is independent of any scaling
 * factor, so the size of the matrix is irrelevant.
 */

static int _bench_drop_n = 0;
static int _bench_iters = 1;
static bool _verbose = false;

static void
_print_input(
            double **A,
            double *x,
            double *b,
            int n
            )
{
  for ( int i = 0; i < n; i++ ) {
    fprintf(stderr, "[ ");
    for ( int j = 0; j < n; j++ ) {
      if ( j == 0 ) {
        fprintf(stderr, " %2d ", (int)index_symm_matrix(A, i, j));
      }
      else {
        fprintf(stderr, ", %2d ", (int)index_symm_matrix(A, i, j));
      }
    }
    fprintf(stderr, "] ");
    // print x
    fprintf(stderr, " [ ");
    fprintf(stderr, " %2d ", (int)x[i]);
    fprintf(stderr, "] ");
    // print b
    fprintf(stderr, "  = [ ");
    fprintf(stderr, " %3d ", (int)b[i]);
    fprintf(stderr, "] ");

    fprintf(stderr, "\n");
  }
}

/* assembly code to read the TSC */
static inline uint64_t
_RDTSC(void)
{
  unsigned int hi, lo;
  __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}

static void
_print_result(double *x_expected, double *x_returned,
              double *b_expected, double *b_returned,
              char *name, int n, double runtime, bool checker_success)
{
  bool error = false;
  fprintf(stderr, "CHECKING %s RESULTS\n", name);
  if (_verbose) {
    fprintf(stderr, "x(expect), x(%s), b(expect), b(%s)\n", name, name);
  }
  for (int i=0; i < n; i++) {
    if (_verbose) {
      fprintf(stderr, " %lf, %lf, %lf, %lf",
              x_expected[i], x_returned[i], b_expected[i], b_returned[i]);
    }

    if ( abs(b_returned[i] - b_expected[i]) < 0.001 ) {
      if (_verbose) {
        fprintf(stderr, " %s_MATCH\n", name);
      }
    }
    else {
      error = true;
      if (_verbose) {
        fprintf(stderr, " %s_ERROR\n", name);
      }
    }
  }
  fprintf(stderr, "%s %s in %.3e cycles, checker said %s.\n\n",
          name,
          error ? "FAILED" : "SUCCEEDED",
          runtime,
          checker_success ? "SUCCEEDED" : "FAILED");
}

static int
_run_our_tests(
    double **A,
    double *x_expected,
    double *b,
    double **A_posdef,
    double *b_posdef,
    int n
    )
{
  int status = 0;

  double **A_posdef_copy = NULL;
  double **A_posdef_full = NULL;
  double *b_posdef_copy = NULL;
  double *b_returned = NULL;
  double *x_returned = NULL;
  uint64_t begin, total;
  double avg_cycles;
  bool checker_success;

  status = alloc_symm_matrix(&A_posdef_copy, n); cBYE(status);
  status = alloc_matrix(&A_posdef_full, n); cBYE(status);
  b_posdef_copy = malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef_copy);
  b_returned = malloc(n * sizeof(double)); return_if_malloc_failed(b_returned);
  x_returned = malloc(n * sizeof(double)); return_if_malloc_failed(x_returned);

  for (int i = 0; i < n; i++) {
    b_posdef_copy[i] = b_posdef[i];
    for(int j = 0; j < n; j++) {
      A_posdef_full[i][j] = index_symm_matrix(A_posdef, i, j);
      if (j < n - i) {
        A_posdef_copy[i][j] = A_posdef[i][j];
      }
    }
  }

  // time computations for each solver
  total = 0;
  for (int i = 0; i < _bench_iters; i++) {
    begin = _RDTSC();
    status = posdef_positive_solver(A_posdef, x_returned, b_posdef, n); cBYE(status);
    if (i >= _bench_drop_n) {
      total += _RDTSC() - begin;
    }
  }
  avg_cycles = (double)total / (_bench_iters - _bench_drop_n);
  multiply_symm_matrix_vector(A_posdef, x_returned, n, b_returned);
  checker_success = symm_positive_solver_check(A_posdef, x_returned, b_posdef, n, 0.0);
  _print_result(x_expected, x_returned, b_posdef, b_returned, "POSDEF_SLOW", n, avg_cycles, checker_success);

  total = 0;
  for (int i = 0; i < _bench_iters; i++) {
    for (int i = 0; i < n; i++) {
      b_posdef_copy[i] = b_posdef[i];
      for(int j = 0; j < n - i; j++) {
        A_posdef_copy[i][j] = A_posdef[i][j];
      }
    }
    begin = _RDTSC();
    status = posdef_positive_solver_fast(A_posdef_copy, x_returned, b_posdef_copy, n); cBYE(status); cBYE(status);
    if (i >= _bench_drop_n) {
      total += _RDTSC() - begin;
    }
  }
  avg_cycles = (double)total / (_bench_iters - _bench_drop_n);
  multiply_symm_matrix_vector(A_posdef, x_returned, n, b_returned);
  checker_success = symm_positive_solver_check(A_posdef, x_returned, b_posdef, n, 0.0);
  _print_result(x_expected, x_returned, b_posdef, b_returned, "POSDEF_FAST", n, avg_cycles, checker_success);

  total = 0;
  for (int i = 0; i < _bench_iters; i++) {
    for (int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        A_posdef_full[i][j] = index_symm_matrix(A_posdef, i, j);
      }
    }
    begin = _RDTSC();
    status = full_posdef_positive_solver(A_posdef_full, x_returned, b_posdef, n); cBYE(status);
    if (i >= _bench_drop_n) {
      total += _RDTSC() - begin;
    }
  }
  avg_cycles = (double)total / (_bench_iters - _bench_drop_n);
  multiply_symm_matrix_vector(A_posdef, x_returned, n, b_returned);
  checker_success = symm_positive_solver_check(A_posdef, x_returned, b_posdef, n, 0.0);
  _print_result(x_expected, x_returned, b_posdef, b_returned, "FULL_POSDEF_SLOW", n, avg_cycles, checker_success);

  total = 0;
  for (int i = 0; i < _bench_iters; i++) {
    for (int i = 0; i < n; i++) {
      b_posdef_copy[i] = b_posdef[i];
      for(int j = 0; j < n; j++) {
        A_posdef_full[i][j] = index_symm_matrix(A_posdef, i, j);
      }
    }
    begin = _RDTSC();
    status = full_posdef_positive_solver_fast(A_posdef_full, x_returned, b_posdef_copy, n); cBYE(status);
    if (i >= _bench_drop_n) {
      total += _RDTSC() - begin;
    }
  }
  avg_cycles = (double)total / (_bench_iters - _bench_drop_n);
  multiply_symm_matrix_vector(A_posdef, x_returned, n, b_returned);
  checker_success = symm_positive_solver_check(A_posdef, x_returned, b_posdef, n, 0.0);
  _print_result(x_expected, x_returned, b_posdef, b_returned, "FULL_POSDEF_FAST", n, avg_cycles, checker_success);

  total = 0;
  for (int i = 0; i < _bench_iters; i++) {
    begin = _RDTSC();
    status = positive_solver(A, x_returned, b, n); cBYE(status);
    if (i >= _bench_drop_n) {
      total += _RDTSC() - begin;
    }
  }
  avg_cycles = (double)total / (_bench_iters - _bench_drop_n);
  multiply_matrix_vector(A, x_returned, n, b_returned);
  checker_success = full_positive_solver_check(A, x_returned, b, n, 0.0);
  _print_result(x_expected, x_returned, b, b_returned, "FULL", n, avg_cycles, checker_success);

BYE:
  free_matrix(A_posdef_copy, n);
  free_matrix(A_posdef_full, n);
  free_if_non_null(b_posdef_copy);
  free_if_non_null(b_returned);
  free_if_non_null(x_returned);

  return status;
}

static int
_run_lapack_tests(
    double **A,
    double *x_expected,
    double *b,
    double **A_posdef,
    double *b_posdef,
    int n
    )
{
  int status = 0;
  lapack_int N = n;
  lapack_int NRHS = 1;
  lapack_int LDA = N;
  lapack_int LDB = N;

  double *A_unrolled = NULL;
  double *A_posdef_unrolled = NULL;
  double *b_copy = NULL;
  double *b_posdef_copy = NULL;
  double *b_returned = NULL;
  lapack_int *ipiv = NULL;

  uint64_t begin, total;
  double avg_cycles;
  bool checker_success;

  A_unrolled = malloc(n * n * sizeof(double)); return_if_malloc_failed(A_unrolled);
  A_posdef_unrolled = malloc(n * n * sizeof(double)); return_if_malloc_failed(A_posdef_unrolled);
  b_copy = malloc(n * sizeof(double)); return_if_malloc_failed(b_copy);
  b_posdef_copy = malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef_copy);
  b_returned = malloc(n * sizeof(double)); return_if_malloc_failed(b_returned);
  ipiv = malloc(n * sizeof(lapack_int)); return_if_malloc_failed(ipiv);


  total = 0;
  for (int i = 0; i < _bench_iters; i++) {
    for (int i = 0; i < n; i++) {
      b_copy[i] = b[i];
      for (int j = 0; j < n; j++) {
        A_unrolled[n * i + j] = A[i][j];
      }
    }
    begin = _RDTSC();
    LAPACKE_dgesv(LAPACK_COL_MAJOR, N, NRHS, A_unrolled, LDA, ipiv, b_copy, LDB);
    if (i >= _bench_drop_n) {
      total += _RDTSC() - begin;
    }
  }
  avg_cycles = (double)total / (_bench_iters - _bench_drop_n);
  multiply_matrix_vector(A, b_copy, n, b_returned);
  checker_success = full_positive_solver_check(A, b_copy, b, n, 0.0);
  _print_result(x_expected, b_copy, b, b_returned, "LAPACK_FULL", n, avg_cycles, checker_success);

  total = 0;
  for (int i = 0; i < _bench_iters; i++) {
    for (int i = 0; i < n; i++) {
      b_posdef_copy[i] = b_posdef[i];
      for (int j = 0; j <= i; j++) {
        A_posdef_unrolled[n * i + j] = A_posdef[j][i - j];
      }
      for (int j = i + 1; j < n; j++) {
        A_posdef_unrolled[n * i + j] = 0;
      }
    }
    begin = _RDTSC();
    LAPACKE_dposv(LAPACK_COL_MAJOR, 'U', N, NRHS, A_posdef_unrolled, LDA, b_posdef_copy, LDB);
    if (i >= _bench_drop_n) {
      total += _RDTSC() - begin;
    }
  }
  avg_cycles = (double)total / (_bench_iters - _bench_drop_n);
  multiply_symm_matrix_vector(A_posdef, b_posdef_copy, n, b_returned);
  checker_success = symm_positive_solver_check(A_posdef, b_posdef_copy, b_posdef, n, 0.0);
  _print_result(x_expected, b_posdef_copy, b_posdef, b_returned, "LAPACK_POSDEF", n, avg_cycles, checker_success);

BYE:
  free_if_non_null(A_unrolled);
  free_if_non_null(A_posdef_unrolled);
  free_if_non_null(b_copy);
  free_if_non_null(b_posdef_copy);
  free_if_non_null(b_returned);
  free_if_non_null(ipiv);

  return status;
}

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int n = 0;                 // dimension of matrices
  double **A = NULL;         // randomly generated n * n matrix
  double **A_posdef = NULL;  // randomly generated positive definite matrix (right now just A transpose * A)
  double *x_expected = NULL; // randomly generated solution
  double *b_posdef = NULL;   // A_posdef * x_expected
  double *b_full = NULL;     // A * x_expected

  srand48(_RDTSC());

  bool print_usage = false, bench = false;
  switch ( argc ) {
  case 3 :
    if (strcmp("-vb", argv[2]) == 0 || strcmp("-bv", argv[2]) == 0) {
      _verbose = true;
      bench = true;
    } else if (strcmp("-v", argv[2]) == 0) {
      _verbose = true;
    } else if (strcmp("-b", argv[2]) == 0) {
      bench = true;
    } else {
      print_usage = true;
    } // fall through
  case 2 :
    n = atoi(argv[1]);
    break;
  default :
    print_usage = true;
    break;
  }
  if (print_usage || n <= 0) {
    printf("Usage: ./test_driver <n> [-v]\n");
    printf("where n is a positive integer and -v provides verbose output.\n");
    go_BYE(-1);
  }
  if (bench == true) {
    _bench_iters = 15;
    _bench_drop_n = 3;
  }

  status = alloc_matrix(&A, n); cBYE(status);
  status = alloc_symm_matrix(&A_posdef, n); cBYE(status);

  for ( int i = 0; i < n; i++ )  {
    for ( int j = 0; j < n; j++ ) {
      A[i][j] = (drand48() - 0.5) * 100;
    }
  }
  transpose_and_multiply(A, A_posdef, n);
  b_posdef = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_posdef);
  b_full = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(b_full);
  x_expected = (double *) malloc(n * sizeof(double)); return_if_malloc_failed(x_expected);

  // Initialize x and b
  for ( int i = 0; i < n; i++ )  {
    x_expected[i] = (lrand48() % 16) - 16/2;
  }
  multiply_symm_matrix_vector(A_posdef, x_expected, n, b_posdef);
  multiply_matrix_vector(A, x_expected, n, b_full);

  if (_verbose) {
    _print_input(A_posdef, x_expected, b_posdef, n);
  }

  _run_our_tests(A, x_expected, b_full, A_posdef, b_posdef, n);

  _run_lapack_tests(A, x_expected, b_full, A_posdef, b_posdef, n);

BYE:
  free_matrix(A, n);
  free_matrix(A_posdef, n);
  free_if_non_null(x_expected);
  free_if_non_null(b_posdef);
  free_if_non_null(b_full);

  return status;
}
