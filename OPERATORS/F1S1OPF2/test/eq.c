#include <stdio.h>
#include "q_macros.h"
#include "_vseq_F4.h"
int
main(
    )
{
  int status = 0;
  int N = 1048576+3;
  float *X = NULL;
  uint64_t *Z = NULL;
  //--------------------------------
  X = malloc(N * sizeof(float));
  return_if_malloc_failed(X);
  for ( int i = 0; i < N; i++ ) { X[i] = i % 2; }
  //--------------------------------
  float Y = 1;
  int M = N / 64; if ( ( M * 64 ) != N ) { M++; } 
  Z = malloc(M * sizeof(uint64_t)); 
  return_if_malloc_failed(Z);
  for ( int i = 0; i < M; i++ ) { Z[i] = 0; }
  //--------------------------------
  status = vseq_F4(X, N,&Y, Z, NULL); cBYE(status);
  //--------------------------------
  // fprintf(stderr, "len = %d \n", sizeof(unsigned long long));
  int sum = 0;
  for ( int i = 0; i < M; i++ ) { 
    int part = __builtin_popcountll((unsigned long long)Z[i]);
    // fprintf(stderr, "Z[%d] = %16x, part = %d \n", i, Z[i], part);
    sum += part;
  }
  if ( sum != 524289 ) { 
    fprintf(stdout, "C: ERROR\n");  go_BYE(-1);
  }
  else {
    fprintf(stdout, "C: SUCCESS\n"); 
  }
BYE:
  free_if_non_null(X);
  free_if_non_null(Z);
  return status;
}
