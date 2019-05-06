#include <stdio.h>
#include "q_macros.h"
#include "_sum_F8.h"
#include "_sum_sqr_I8.h"
#include "_min_I4.h"
#include "_max_I1.h"
#include "sum_B1.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int N = 524288+17;
  double *X = NULL;
  int64_t *Y = NULL;
  int32_t *Z = NULL;
  int8_t *W = NULL;
  uint64_t *V = NULL;

  int num_blocks = 4;
  int block_size = N / num_blocks;
  X = malloc(N * sizeof(double));
  return_if_malloc_failed(X);
  for ( int i = 0; i < N; i++ ) { X[i] = i+1; }
  //----------------------------
  REDUCE_sum_F8_ARGS xargs;
  xargs.sum_val = 0; xargs.num = 0;
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * block_size;
    int ub = lb + block_size;
    if ( b == (num_blocks-1) ) { ub = N; }
    status = sum_F8(X+lb, (ub-lb), &xargs, lb); cBYE(status);
  }
  double dN = (double)N;
  if ( xargs.num != N ) { go_BYE(-1); }
  if ( xargs.sum_val != (dN*(dN+1)/2.0) ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //----------------------------
  Y = malloc(N * sizeof(int64_t));
  return_if_malloc_failed(Y);
  for ( int i = 0; i < N; i++ ) { Y[i] = i+1; }
  REDUCE_sum_sqr_I8_ARGS yargs;
  yargs.sum_sqr_val = 0; yargs.num = 0;
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * block_size;
    int ub = lb + block_size;
    if ( b == (num_blocks-1) ) { ub = N; }
    status = sum_sqr_I8(Y+lb, (ub-lb), &yargs, lb); cBYE(status);
  }
  uint64_t lN = (uint64_t)N;
  if ( yargs.num != N ) { go_BYE(-1); }
  if ( yargs.sum_sqr_val != (lN*(lN+1)*(2*lN+1)/6) ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //----------------------------
  Z = malloc(N * sizeof(int32_t));
  return_if_malloc_failed(Z);
  for ( int i = 0; i < N; i++ ) { Z[i] = i+1; }
  REDUCE_min_I4_ARGS zargs;
  zargs.min_val = INT_MAX; zargs.num = 0;
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * block_size;
    int ub = lb + block_size;
    if ( b == (num_blocks-1) ) { ub = N; }
    status = min_I4(Z+lb, (ub-lb), &zargs, lb); cBYE(status);
  }
  if ( zargs.num != N ) { go_BYE(-1); }
  if ( zargs.min_val != 1 ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //----------------------------
  W = malloc(N * sizeof(int8_t));
  return_if_malloc_failed(W);
  for ( int i = 0; i < N; i++ ) { W[i] = i; }
  REDUCE_max_I1_ARGS wargs;
  wargs.max_val = SCHAR_MIN; wargs.num = 0;
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * block_size;
    int ub = lb + block_size;
    if ( b == (num_blocks-1) ) { ub = N; }
    status = max_I1(W+lb, (ub-lb), &wargs, lb); cBYE(status);
  }
  if ( wargs.num != N ) { go_BYE(-1); }
  if ( wargs.max_val != SCHAR_MAX ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //---------------------------
  N = 129; // must be a power of 64 
  int N_bits = ((N * 64) -  3); // -3 to make things difficult
  V = malloc(N * sizeof(uint64_t));
  return_if_malloc_failed(V);
  for ( int i = 0; i < N; i++ ) { V[i] = 0xFFFFFFFF; }
  uint64_t chk_sum = 0;
  for ( int i = 0; i < N; i++ ) { chk_sum += __builtin_popcountll(V[i]); }

  REDUCE_sum_B1_ARGS vargs;
  vargs.sum_val = 0; vargs.num = 0;
  int chunk_size = 128;
  num_blocks = N_bits / chunk_size; 
  if ( ( num_blocks * chunk_size ) != N_bits ) { num_blocks++; }
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * chunk_size;
    int ub = lb + chunk_size;
    if ( b == (num_blocks-1) ) { ub = N_bits; }
    status = sum_B1(V+(lb/64), (ub-lb), &vargs, lb); cBYE(status);
    fprintf(stderr, "lb/ub/sum/N = %d, %d, %d, %d \n",  
        lb, ub, (int)vargs.sum_val, (int)vargs.num);
  }
  if ( vargs.num != N_bits ) { go_BYE(-1); }
  if ( vargs.sum_val != chk_sum ) { go_BYE(-1); }
  /*
  if ( vargs.cum_val != SCHAR_MAX ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  */
BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  free_if_non_null(W);
  free_if_non_null(V);
  return status;
}
