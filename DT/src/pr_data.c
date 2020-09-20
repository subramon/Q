#include "incs.h"
#include "pr_data.h"

int 
pr_data_f(
    float **X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t *g,
    uint32_t lb,
    uint32_t ub
   )
{
  int status = 0;
  for ( uint32_t i = lb; i < ub; i++ ) { 
    for ( uint32_t j = 0; j < m; j++ ) { 
      printf("%4.0f,", X[j][i]);
    }
    printf("%d\n", g[i]);
  }
BYE:
  return status;
}


int 
pr_data_i(
    float **X, /* [m][n] */
    uint32_t **Y, /* [m][n] */
    uint32_t **from, /* [m][n] */
    uint32_t **to, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t *lr,
    uint8_t *g,
    uint32_t lb,
    uint32_t ub
   )
{
  int status = 0;
  for ( uint32_t i = lb; i < ub; i++ ) { 
    for ( uint32_t j = 0; j < m; j++ ) { 
      uint32_t mask = 1; mask = mask << 31; mask = ~mask;
      uint8_t gval = Y[j][i] >> 31;
      uint32_t yval = Y[j][i] & mask;
      float xval = X[j][i];
      printf("(%1u,%4u,%4u,%4u,%4.1f),", lr[i], to[j][i], from[j][i], yval, xval);
      if ( gval != g[i] ) { go_BYE(-1); }
    }
    printf("%d\n", g[i]); // to check 
  }
BYE:
  return status;
}

