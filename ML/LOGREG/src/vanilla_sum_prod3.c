#include "q_incs.h"
#include "vanilla_sum_prod3.h"

extern uint64_t num_ops;

static inline void
_vvmul(
    float * restrict X,
    double * restrict Y,
    uint32_t n,
    double * restrict Z
    )
{
#pragma omp simd
  for ( uint32_t i = 0; i < n; i++ ) { 
    Z[i] = X[i] * Y[i];
  }
  // num_ops += n;
}
 
static inline void
_sum(
    double * restrict X,
    uint32_t n,
    double *ptr_y
    )
{
  double sum = 0;
#pragma omp simd reduction(+:sum)
  for ( uint32_t i = 0; i < n; i++ ) { 
    sum += X[i];
  }
  // num_ops += n;
  *ptr_y = sum;
}
 
int
vanilla_sum_prod3(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double *w, /* vector of length N */
    double **A /* M vectors of length M */
    )
{
  int status = 0;
  double *temp1 = NULL, *temp2 = NULL;
  int b = N; // block size 
  temp1 = malloc(b * sizeof(double));
  return_if_malloc_failed(temp1);
  temp2 = malloc(b * sizeof(double));
  return_if_malloc_failed(temp2);

  uint32_t nT = sysconf(_SC_NPROCESSORS_ONLN);
  // nT = 4; // TODO FIX HARD CODING 
#pragma omp parallel for schedule(static) num_threads(nT)
  for ( uint64_t i = 0; i < M; i++ ) { 
    memset(A[i], '\0', M*sizeof(double));
    // num_ops += M;
  }

#pragma omp parallel for schedule(static, 1) num_threads(nT)
  for ( uint64_t i = 0; i < M; i++ ) { 
    float *Xi = X[i];
    double *Ai = A[i];
    _vvmul(Xi, w, N, temp1);
    double sum = 0;
    for ( uint64_t j = i; j < M; j++ ) {
      _vvmul(X[j], temp1, N, temp2);
      _sum(temp2, N, &sum);
      Ai[j] += sum;
    }
  }
BYE:
  free_if_non_null(temp1);
  free_if_non_null(temp2);
  return status;
}
