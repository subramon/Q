#include <stdio.h>
#include "q_macros.h"
#include "_concat_I1_I2_I4.h"
int
main(
    )
{
  int status = 0;
#define N 1048576
  uint8_t *X = NULL;
  uint16_t *Y = NULL;
  uint32_t *Z = NULL;
  //--------------------------------
  uint8_t vx = 0;
  X = malloc(N * sizeof(uint8_t));
  return_if_malloc_failed(X);
  for ( int i = 0; i < N; i++, vx++ ) { 
    if ( vx == 255 ) { vx = 0; }
    X[i] = vx;
  }
  //--------------------------------
  uint16_t vy = 0;
  Y = malloc(N * sizeof(uint16_t));
  return_if_malloc_failed(Y);
  for ( int i = 0; i < N; i++, vy++ ) { 
    if ( vy == 65535 ) { vy = 0; }
    Y[i] = vy;
  }
  //--------------------------------
  vx = vy = 0;
  Z = malloc(N * sizeof(uint32_t));
  return_if_malloc_failed(Z);
  status = concat_I1_I2_I4((uint8_t *)X, (uint16_t *)Y, N, (uint32_t *)Z); cBYE(status);
  for ( int i = 0; i < N; i++, vx++, vy++ ) { 
    if ( vx == 255 ) { vx = 0; }
    if ( vy == 65535 ) { vy = 0; }
    uint64_t vz = ( (uint64_t )vx << 16 ) | vy;
    if ( vz != Z[i] ) { 
      fprintf(stdout, "C: FAILURE\n");
      go_BYE(-1);
    }
  }  
  fprintf(stdout, "C: SUCCESS\n");
  //--------------------------------

BYE:
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z);
  return status;
}
