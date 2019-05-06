#include <stdio.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <omp.h>
#include <unistd.h>
#include "q_macros.h"

uint64_t num_ops;

extern int
sum_prod(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double *w, /* vector of length N */
    double **A /* M vectors of length M */
);

int
sum_prod(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double *w, /* vector of length N */
    double **A /* M vectors of length M */
    )
{
  int status = 0;
  double *temp = NULL;
  temp = malloc(N * sizeof(double));
  return_if_malloc_failed(temp);
  int block_size = 8192; 

  num_ops = 0;
  uint32_t nT = sysconf(_SC_NPROCESSORS_ONLN);
  printf("nT = %d \n", nT);
#pragma omp parallel for 
  for ( uint64_t i = 0; i < M; i++ ) { 
    memset(A[i], '\0', M*sizeof(double));
    // num_ops += M;
  }

  for ( uint32_t c = 0; c <= M/nT ; c++ ) {  // TODO CHECK
    for ( uint64_t i = 0; i < M; i++ ) {
      if ( ( i + (c*nT) ) >= M ) { break; }
      float *Xi = X[i];
      double *Ai = A[i];
#pragma omp simd
      for ( uint32_t l = 0; l < N; l++ ) { 
        temp[l] = Xi[l] * w[l];  // num_ops++;
      }
      uint32_t j_lb = i    + (c*nT);
      if ( j_lb >= M ) { break; }
      uint32_t j_ub = j_lb + nT;
      if ( j_ub > M ) { j_ub = M; }
      // printf("c = %d, i = %d, j = [%d, %d]\n", c, i, j_lb, j_ub);
// #pragma omp parallel for schedule (static, 1)
#pragma omp parallel for 
      for ( uint64_t j = j_lb; j < j_ub; j++ ) {
        // printf("%d, %d, %d, %d \n", j, j_lb, j_ub, omp_get_thread_num());
        double temp2[2*block_size];
        double sum = 0;
        float *Xj = X[j];
        int num_blocks = N / block_size;
        if ( ( num_blocks * block_size ) != (int)N ) { num_blocks++; }
        for ( int b = 0; b < num_blocks; b++ ) {
          uint64_t lb = b * block_size;
          uint64_t ub = lb + block_size;
          if ( b == (num_blocks-1) ) { ub = N; }
          uint32_t tidx = 0;
#pragma omp simd
          for ( uint32_t l = lb; l < ub; l++ ) { 
            temp2[tidx++] = Xj[l] * temp[l];  // num_ops++;
          }
          tidx = 0;
#pragma omp simd reduction(+:sum)
          for ( tidx = 0; tidx < ub-lb; tidx++ ) { 
            sum += temp2[tidx]; // num_ops++; 
          }
        }
#pragma omp critical (_sum_prod)
        {
          Ai[j] = sum;
        }
      }
    }
  }

BYE:
  free_if_non_null(temp);
  return status;
}

int
main(
    )
{
  int status = 0;
  uint64_t N = 128 * 1024;
  uint64_t M = 1024;
  double **A = NULL;
  float **X = NULL;
  double *w = NULL;
  clock_t start_t, stop_t, total_t;


  w = malloc(N * sizeof(double));
  for ( int i = 0; i < N; i++ ) { 
    w[i] = 1.0 /(i+1);
  }

  X = malloc(M * sizeof(float *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    X[i] = malloc(N * sizeof(float));
  }
  for ( uint64_t i = 0; i < M; i++ ) { 
    for ( uint64_t j = 0; j < N; j++ ) { 
      X[i][j] = (i+j+1);
    }
  }

  A = malloc(M * sizeof(double *));
  for ( uint64_t i = 0; i < M; i++ ) { 
    A[i] = malloc(M * sizeof(double));
  }

  system("date");
  start_t = clock();
  status = sum_prod(X, M, N, w, A);
  stop_t = clock();
  system("date");
  fprintf(stderr, "Num clocks = %llu \n", stop_t - start_t);
  fprintf(stderr, "Num Ops = %llu \n", (unsigned long long)num_ops);
  double chk = 0;

  int ii = 2, jj = 2;
  for ( unsigned int l = 0; l < N; l++ ) { 
    chk += (X[ii][l] * X[jj][l] * w[l]);
  }
  if ( ( ( A[ii][jj] -  chk) / chk )  > 0.001 ) {
    fprintf(stderr, "chk = %lf, A = %lf \n", chk, A[ii][jj]);
    go_BYE(-1);
  }
  for ( uint64_t i = 0; i < M; i++ ) { 
    for ( uint64_t j = i; j < M; j++ ) { 
      if ( A[i][j] == 0 ) { go_BYE(-1); 
      }
    }
    for ( uint64_t j = 0; j < i; j++ ) { 
      if ( A[i][j] != 0 ) { go_BYE(-1); 
      }
    }
  }
  /* num_ops = 146231168000 */
  /* gcc -std=gnu99 -O4 expt_sum_prod.c -I../../../UTILS/inc/ -o a.out -fopenmp -lgomp*/
BYE:
  free_if_non_null(w);

  for ( uint64_t i = 0; i < M; i++ ) { free_if_non_null(A[i]); }
  free_if_non_null(A);

  for ( uint64_t i = 0; i < M; i++ ) { free_if_non_null(X[i]); }
  free_if_non_null(X);

  return status;
}

