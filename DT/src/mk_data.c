#include "incs.h"
#include "mk_data.h"

int 
mk_data(
    float ***ptr_X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t **ptr_g
   )
{
  int status = 0;
  uint32_t maxn = 1; maxn = maxn << 31;
  if ( n  >= maxn ) { go_BYE(-1); }
  float **X = NULL;
  uint8_t *g = NULL;
  X = malloc(m * sizeof(float *));
  for ( uint32_t j = 0; j < m; j++ ) { 
    X[j] = malloc(n * sizeof(float));
  }
  g = malloc(n * sizeof(uint8_t));

  for ( uint32_t j = 0; j < m; j++ ) { 
    for ( uint32_t i = 0; i < n; i++ ) { 
      X[j][i] = (float)( random() % 1000 );
    }
  }
  for ( uint32_t i = 0; i < n; i++ ) { 
    g[i] = random() & 0x1;
  }
  *ptr_X = X;
  *ptr_g = g;
BYE:
  return status;
}

