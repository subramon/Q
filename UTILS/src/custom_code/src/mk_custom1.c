#include "q_incs.h"
#include "mk_custom1.h"

int
mk_custom1(
    char * X,
    uint32_t nX,
    uint32_t width,
    custom1_t *Y
    )
{
  int status = 0;
  for ( uint32_t i = 0; i < nX; i++ ) { 
    memset(Y+i, 0, sizeof(custom1_t));
  }
BYE:
  return status;
}
