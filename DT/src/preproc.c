#include "incs.h"
#include "preproc_j.h"
#include "preproc.h"

int 
preproc(
    float **X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t *g,
    uint32_t ***ptr_Y,
    uint32_t ***ptr_to,
    uint32_t ***ptr_from
   )
{
  int status = 0;
  uint32_t **Y = NULL;
  uint32_t **to = NULL;
  uint32_t **from = NULL;
  Y  = malloc(m * sizeof(uint32_t *));
  to = malloc(m * sizeof(uint32_t *));
  from = malloc(m * sizeof(uint32_t *));
  for ( uint32_t j = 0; j < m; j++ ) { 
    status = preproc_j(X[j], n, g,  &(Y[j]), &(to[j]), &(from[j]));  
    cBYE(status);
  }
  *ptr_Y = Y;
  *ptr_to = to;
  *ptr_from = from;
BYE:
  return status;
}
