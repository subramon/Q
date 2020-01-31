#include "q_incs.h"
#include "_split_I8_I4.h"

#define N 1048576

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  fprintf(stderr, "Successfully completed %s \n", argv[0]);
  uint32_t *x  = NULL;
  uint32_t *y  = NULL;
  int32_t *x1 = NULL;
  int32_t *y1 = NULL;
  uint64_t *z  = NULL;
  x   = malloc(N * sizeof(uint32_t)); return_if_malloc_failed(x);
  y   = malloc(N * sizeof(uint32_t)); return_if_malloc_failed(y);
  x1  = malloc(N * sizeof(uint32_t)); return_if_malloc_failed(x);
  y1  = malloc(N * sizeof(uint32_t)); return_if_malloc_failed(y);
  z   = malloc(N * sizeof(uint64_t)); return_if_malloc_failed(z);
  for ( int i = 0; i < N; i++ ) { 
    x[i] = i;
    y[i] = i << 10;
    x1[i] = 0;
    y1[i] = 0;
    z[i] = ((uint64_t)x[i]) << 32 | y[i];
  }
  status = split_I8_I4((int64_t *)z, N, 32, x1, y1); cBYE(status);
  for ( int i = 0; i < N; i++ ) { 
    if ( x[i] != (uint32_t)x1[i] ) { go_BYE(-1); }
    if ( y[i] != (uint32_t)y1[i] ) { go_BYE(-1); }
  }
BYE:
  free_if_non_null(x);
  free_if_non_null(y);
  free_if_non_null(z);
  free_if_non_null(x1);
  free_if_non_null(y1);
  return status;
}
