#include "q_incs.h"
#include "_get_I4_F8.h"

#define IN1_TYPE int32_t
#define IN2_TYPE double
#define N1 1024
#define N2 1048576

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  fprintf(stderr, "Successfully completed %s \n", argv[0]);
  IN1_TYPE *x = NULL;
  IN2_TYPE *y = NULL;
  IN2_TYPE *z = NULL;
  x = malloc(N1 * sizeof(IN1_TYPE)); return_if_malloc_failed(x);
  y = malloc(N2 * sizeof(IN2_TYPE)); return_if_malloc_failed(y);
  z = malloc(N1 * sizeof(IN2_TYPE)); return_if_malloc_failed(z);
  bool flop = true;
  for ( int i = 0; i < N1; i++ ) { 
    if ( ( i % 2 ) == 0 ) {
      if ( flop ) { 
        x[i] = -1; flop = false; 
      }
      else {
        x[i] = N2+1; flop = true; 
      }
    }
    else {
      x[i] = i*10;
    }
  }
  for ( int i = 0; i < N2; i++ ) { 
    y[i] = i+1;
  }
  double null_val[1]; null_val[0] = 0;
  status = get_I4_F8(x, y, N1, N2, null_val, z); cBYE(status);
  flop = true;
  for ( int i = 0; i < N1; i++ ) { 
    if ( ( i % 2 ) == 0 ) {
      if ( flop ) { 
        flop = false;
        if ( z[i] != null_val[0] ) { go_BYE(-1); }
      }
      else {
        if ( z[i] != null_val[0] ) { go_BYE(-1); }
        flop = true; 
      }
    }
    else {
      // TODO x[i] = i*10;
    }
  }
BYE:
  free_if_non_null(x);
  free_if_non_null(y);
  free_if_non_null(z);
  return status;
}
