#include <time.h>
#include "corr_mat.h"


static inline void
_vvmul(
    float * restrict X,
    float * restrict Y,
    uint32_t n,
    double * restrict Z
    )
{
// #pragma omp simd
  for ( uint32_t i = 0; i < n; i++ ) { 
    Z[i] = X[i] * Y[i];
  }
}
 
static inline void
_sum(
    double * restrict X,
    uint32_t n,
    double *ptr_Y
    )
{
  double y = 0;
// #pragma omp simd
  for ( uint32_t i = 0; i < n; i++ ) { 
    y += X[i];
  }
  *ptr_Y = y;
}
 
int
corr_mat(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double **A /* M vectors of length M */
    )
{
  int status = 0;

  if ( X == NULL ) { go_BYE(-1); }
  if ( A == NULL ) { go_BYE(-1); }
  if ( M == 0 ) { go_BYE(-1); } 
  if ( N <= 1 ) { go_BYE(-1); } // else division by 0
  // set up parameters for blocking/multi-threading
  int block_size = 16384; 
  // uint32_t nT = sysconf(_SC_NPROCESSORS_ONLN);
  uint32_t nT = 3;
  int num_blocks = N / block_size;
  if ( ( num_blocks * block_size ) != (int)N ) { num_blocks++; }

  // #pragma omp parallel for 
  // initialize A to 0
  for ( uint64_t i = 0; i < M; i++ ) { 
    memset(A[i], '\0', M*sizeof(double));
  }
  // set diagonal to 1
  for ( uint64_t i = 0; i < M; i++ ) { 
    A[i][i] = 1;
  }

  for ( uint64_t i = 0; i < M; i++ ) { 
    float *Xi = X[i];
    double *Ai = A[i];
    if ( nT > M-i ) { nT = M-i; }
    // #pragma omp parallel for schedule(static, 1) num_threads(nT)
    // #pragma omp parallel for 
    for ( uint64_t j = i+1; j < M; j++ ) {
      double temp2[block_size];
      double sum = 0;
      for ( int b = 0; b < num_blocks; b++ ) { 
        uint64_t lb = b * block_size;
        uint64_t ub = lb + block_size;
        if ( b == (num_blocks-1) ) { ub = N; }
        double rslt;
        _vvmul(X[j] +lb, Xi+lb, (ub-lb), temp2);
        _sum(temp2, (ub-lb), &rslt);
        sum += rslt;
      }
      // #pragma omp critical (_corr_mat)
      {
        Ai[j] = sum / (N - 1);
      }
    }
  }
  
  for ( uint64_t i = 0; i < M; i++ ) {
    for ( uint64_t j = 0; j < i; j++ ) {
      A[i][j] = A[j][i];
    }
  }


BYE:
  return status;
}


