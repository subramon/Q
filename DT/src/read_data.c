#include "incs.h"
#include "read_data.h"

int 
read_data(
    float ***ptr_X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t **ptr_g
   )
{
  int status = 0;
  float **X = NULL; 
  uint8_t *g = NULL;
  *ptr_X = X;
  *ptr_g = g;
BYE:
  return status;
}
