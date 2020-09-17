#include "incs.h"
#include "preproc_j.h"
#include "split.h"

int 
split(
    float **X, /* [m][n] */
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    uint32_t m,
    uint8_t *g,
    uint32_t ***ptr_Y
   )
{
  int status = 0;
  if ( ub - lb <= MIN_LEAF_SIZE ) { return status; }

  // just for now 
  int split_k = random() % m;
  int split_idx = (ub - lb)/2;


  uint32_t **Y = NULL;
  Y = malloc(m * sizeof(uint32_t *));
  for ( uint32_t j = 0; j < m; j++ ) { 
//    status = preproc_j(X[j], n, g,  &(Y[j]));  cBYE(status);
  }
  *ptr_Y = Y;
BYE:
  return status;
}
