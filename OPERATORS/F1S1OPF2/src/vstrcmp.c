#include "q_incs.h"
#include "vstrcmp.h"

int
vstrcmp(
    char *inv, // [n]
    bool *nn_inv, // [n]
    uint32_t n,
    uint32_t width,
    const char * const sclr,
    bool *outv, 
    bool *nn_outv
    )

{
  int status = 0;
  for ( uint32_t i = 0; i < n; i++ ) {
    outv[i] = false;
    if ( ( nn_inv == NULL ) || ( nn_inv[i] == 0 ) ) {
      if ( nn_outv != NULL ) { nn_outv[i] = false; }
      continue;
    }
    if ( strcmp(inv, sclr) == 0 ) { 
      outv[i] = true; 
    }
    if ( nn_outv != NULL ) { nn_outv[i] = 1; }
    inv += width;
  } 
BYE:
  return status;
}
