#include "incs.h"
#include "prnt_data.h"

int 
prnt_data_f(
    float **X, /* [m][n] */
    uint32_t m,
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
prnt_data_i(
    uint64_t **Y, /* [m][n] */
    uint32_t **to, /* [m][n] */
    uint32_t m,
    uint32_t lb,
    uint32_t ub
   )
{
  int status = 0;
  printf("(g   to  from val),");
  printf("(g   to  from val)\n");
  for ( uint32_t i = lb; i < ub; i++ ) { 
    for ( uint32_t j = 0; j < m; j++ ) { 
      uint32_t mask = 1; mask = mask << 31; mask = ~mask;
      uint8_t g_i = get_goal(Y[j][i]);
      uint8_t from_i = get_from(Y[j][i]);
      uint8_t y_i   = get_yval(Y[j][i]);
      printf("(%1u,%4u,%4u,%4u),", g_i, to[j][i], from_i, y_i);
    }
    printf("\n");
  }
  printf("\n==============================\n");
BYE:
  return status;
}

