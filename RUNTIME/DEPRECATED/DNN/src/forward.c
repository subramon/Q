#include "q_incs.h"
#include "fstep_a.h"

// An entire forward pass for a mini batch 
// nl = number of layers = nhl + 2, nhl = number of hidden layers
int forward(
    float ***in,  /* [nl][n_in][nI] */
    float ***W,   /* [nl][n_in][n_out] */ /* TODO: Order to be debated */
    float **b,    /* bias [nl][n_out] */
    float ***out, /* [nl][n_out][nI] */
    int32_t nI, 
    int32_t *npl, /* [nl] */
    int32_t nl
   )
{
  int status = 0;

  for ( int l = 1; l < nl; l++ ) {
    status = fstep_a(in[l], W[l], b[l], out[l], nI, npl[l-1], npl[l]);
    cBYE(status);
  }
BYE:
  return status;
}
