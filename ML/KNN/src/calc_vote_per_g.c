#include "q_incs.h"
#include "calc_vote_per_g.h"
static uint64_t RDTSC(
    void
    )
{
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}

int 
calc_vote_per_g(
    float **d_train, /* [m][n_train] */
    int m,
    int n_train,
    float **d_test, /* [m][n_test] */
    int n_test,
    float *o_test /* [n_test] */
    )
{
  int status = 0;
  // uint64_t t_start = RDTSC();
#pragma omp simd 
  for ( int j = 0; j < n_test; j++ ) { 
    o_test[j] = 0;
  }

  float exponent = 4.0; // TODO FIX P1
#pragma omp parallel for 
  for ( int j = 0; j < n_test; j++ ) { 
    for ( int k = 0; k < n_train; k++ ) { 
      float vote_k;
      float sum = 0;
      for ( int i = 0; i < m; i++ ) { 
        float x3;
        float test_val = d_test[i][j];
        float train_val = d_train[i][k];
        float x1 = test_val - train_val;
        float x2 = x1 * x1;
        x3 = x2;
        sum += x3;
      }
      if ( exponent != 1 ) { sum = pow(sum, exponent); }
      vote_k = 1.0 / (1.0 + sum);
      o_test[j] += vote_k;
    }
  }
  // printf("%lf \n", (double)(RDTSC()-t_start));
BYE:
  return status;
}
