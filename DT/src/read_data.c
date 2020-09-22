#include "incs.h"
#include "read_data.h"

int 
read_data(
    float ***ptr_X, /* [m][n] */
    uint32_t *ptr_m,
    uint32_t *ptr_n,
    uint8_t **ptr_g
   )
{
  int status = 0;
  float **X = NULL; 
  uint32_t m = 0;
  uint32_t n = 0;
  uint8_t *g = NULL;
  *ptr_X = X;
  *ptr_m = m;
  *ptr_n = n;
  *ptr_g = g;
BYE:
  return status;
}
