#include <stdio.h>
#include <stdlib.h>

int 
split(
    float **X, /* [m][n] */
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    int m,
    int *g,
    uint32_t ***ptr_Y
   )
{
  int status = 0;
  if ( ub - lb <= min_leaf_size ) { return status; }

  // just for now 
  int split_k = random() % m;
  int split_idx = (ub - lb)/2;


  uint32_t **Y = NULL;
  Y = malloc(m * sizeof(uint32_t *));
  for ( int j = 0; j < m; j++ ) { 
    status = preproc_j(X[j], n, g,  &(Y[j]));  cBYE(status);
  }
  *ptr_Y = Y;
BYE:
  return status;
}
