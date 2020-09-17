#include <stdio.h>
#include <stdlib.h>

int 
mk_data(
    float ***ptr_X, /* [m][n] */
    int m,
    uint32_t n,
    int **ptr_g
   )
{
  int status = 0;
  uint32_t maxn = 1; maxn = maxn << 31;
  if ( n  >= maxn ) { go_BYE(-1); }
  float **X = NULL;
  int *g = NULL;
  X = malloc(m * sizeof(float *));
  for ( int j = 0; j < m; j++ ) { 
    X[j] = malloc(n * sizeof(float));
  }
  g = malloc(m * sizeof(int));

  for ( int j = 0; j < m; j++ ) { 
    for ( int i = 0; i < n; i++ ) { 
      X[j][i] = random();
    }
  }
  for ( int i = 0; i < n; i++ ) { 
    g[i] = random() & 0x1;
  }
  *ptr_X = X;
  *ptr_g = g;
BYE:
  return status;
}

