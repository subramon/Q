#include "incs.h"
#include "preproc_j.h"
#include "preproc.h"

int 
preproc(
    float **X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t *g,
    uint64_t ***ptr_Y,
    uint32_t ***ptr_to
   )
{
  int status = 0;
  uint64_t **Y = NULL;
  uint32_t **to = NULL;
  Y  = malloc(m * sizeof(uint64_t *));
  to = malloc(m * sizeof(uint32_t *));
  for ( uint32_t j = 0; j < m; j++ ) { 
    status = preproc_j(X[j], n, g,  &(Y[j]), &(to[j]));
    cBYE(status);
  }
  *ptr_Y = Y;
  *ptr_to = to;
BYE:
  if ( status < 0 ) { free_if_non_null(Y); free_if_non_null(to); }
  return status;
}
