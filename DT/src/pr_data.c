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
    uint32_t **Y, /* [m][n] */
    uint32_t **to, /* [m][n] */
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
      uint64_t mask = 1; mask = mask << 31;
      uint8_t gval = Y[j][i] & mask;
      uint8_t yval = Y[j][i] & ~mask;
      printf("(%d,%4u,%4u),", gval, to[j][i], yval);
    }
    printf("%d\n", g[i]); // to check 
  }
BYE:
  return status;
}

