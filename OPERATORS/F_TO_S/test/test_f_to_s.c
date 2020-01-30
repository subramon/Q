#include "q_incs.h"
#include "sum_struct.h"
#include "minmax_struct.h"
#include "_sum_F8.h"
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
  SUM_F_ARGS xargs;
  xargs.val = 0; xargs.num = 0;
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * block_size;
    int ub = lb + block_size;
    if ( b == (num_blocks-1) ) { ub = N; }
    printf("lb/ub = %d, %d \n", lb, ub);
    status = sum_F8(X+lb, (ub-lb), &xargs, lb); cBYE(status);
  }
  double dN = (double)N;
  if ( xargs.num != N ) { go_BYE(-1); }
  if ( xargs.val != (dN*(dN+1)/2.0) ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //----------------------------
  Z = malloc(N * sizeof(int32_t));
  return_if_malloc_failed(Z);
  for ( int i = 0; i < N; i++ ) { Z[i] = i+1; }
  MINMAX_I4_ARGS zargs;
  zargs.val = INT_MAX; zargs.num = 0;
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * block_size;
    int ub = lb + block_size;
    if ( b == (num_blocks-1) ) { ub = N; }
    status = min_I4(Z+lb, (ub-lb), &zargs, lb); cBYE(status);
  }
  if ( zargs.num != N ) { go_BYE(-1); }
  if ( zargs.val != 1 ) { 
    fprintf(stdout, "FAILURE\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "SUCCESS\n"); 
  }
  //----------------------------
  W = malloc(N * sizeof(int8_t));
  return_if_malloc_failed(W);
  for ( int i = 0; i < N; i++ ) { W[i] = i; }
  MINMAX_I1_ARGS wargs;
  wargs.val = SCHAR_MIN; wargs.num = 0;
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * block_size;
    int ub = lb + block_size;
    if ( b == (num_blocks-1) ) { ub = N; }
    status = max_I1(W+lb, (ub-lb), &wargs, lb); cBYE(status);
  }
  if ( wargs.num != N ) { go_BYE(-1); }
  if ( wargs.val != SCHAR_MAX ) { 
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

  SUM_I_ARGS vargs;
  vargs.val = 0; vargs.num = 0;
  int chunk_size = 128;
  num_blocks = N_bits / chunk_size; 
  if ( ( num_blocks * chunk_size ) != N_bits ) { num_blocks++; }
  for ( int b = 0; b < num_blocks; b++ ) { 
    int lb = b * chunk_size;
    int ub = lb + chunk_size;
    if ( b == (num_blocks-1) ) { ub = N_bits; }
    status = sum_B1(V+(lb/64), (ub-lb), &vargs, lb); cBYE(status);
    fprintf(stderr, "lb/ub/sum/N = %d, %d, %d, %d \n",  
        lb, ub, (int)vargs.val, (int)vargs.num);
  }
  if ( vargs.num != N_bits ) { go_BYE(-1); }
  if ( vargs.val != chk_sum ) { go_BYE(-1); }
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
