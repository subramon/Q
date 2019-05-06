#include "sum_prod3.h"
#include "vanilla_sum_prod3.h"
#include "_rdtsc.h"

uint64_t num_ops;
int
main(
    )
{
  int status = 0;
  uint64_t N = 256 * 65536; // 4 * 1024 * 1024;
  uint64_t M = 32;
  double **A = NULL;
  float **X = NULL;
  double *w = NULL;
  num_ops = 0;

  w = malloc(N * sizeof(double));

  X = malloc(M * sizeof(float *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    X[i] = malloc(N * sizeof(float));
  }

  A = malloc(M * sizeof(double *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    A[i] = malloc(M * sizeof(double));
  }
  for ( uint64_t i = 0; i < N; i++ ) { 
    w[i] = 1.0 /(i+1);
  }
  for ( uint64_t i = 0; i < M; i++ ) { 
    for ( uint64_t j = 0; j < N; j++ ) { 
      X[i][j] = (i+j+1);
    }
  }

  uint64_t start_t = RDTSC();
  status = vanilla_sum_prod3(X, M, N, w, A);
  // status = sum_prod3(X, M, N, w, A);
  uint64_t delta = RDTSC() - start_t;
  system("date");
  fprintf(stderr, "Num clocks = %" PRIu64 "\n", delta);
  if ( num_ops == 0 ) { 
    num_ops += M * N;
    num_ops += 2*N*(M * (M+1))/2 ;
  }
#define CLOCKS_PER_NS 2.8
  fprintf(stderr, "M       = %" PRIu64 " \n", M);
  fprintf(stderr, "N       = %" PRIu64 " \n", N);
  fprintf(stderr, "Num Ops = %" PRIu64 " \n", num_ops);
  fprintf(stderr, "GFlops  = %lf\n",
       ((double)num_ops / (double)delta/CLOCKS_PER_NS) );

#ifdef CHECK_RESULTS
  for ( int ii = 0; ii < M; ii++ ) { 
    for ( int jj = 0; jj < M; jj++ ) { 
      double chk = 0;
      for ( unsigned int l = 0; l < N; l++ ) { 
        chk += (X[ii][l] * X[jj][l] * w[l]);
      }
      if ( ( ( A[ii][jj] -  chk) / chk )  > 0.001 ) {
        fprintf(stderr, "chk = %lf, A = %lf \n", chk, A[ii][jj]);
        go_BYE(-1);
      }
    }
  }
  for ( uint64_t i = 0; i < M; i++ ) { 
    for ( uint64_t j = i; j < M; j++ ) { 
      if ( A[i][j] == 0 ) { 
        go_BYE(-1); 
      }
    }
    for ( uint64_t j = 0; j < i; j++ ) { 
      if ( A[i][j] != 0 ) { go_BYE(-1); 
      }
    }
  }
#endif
  return status;
}
