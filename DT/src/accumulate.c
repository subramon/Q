#include "incs.h"
#include "accumulate.h"
extern config_t g_C;
int
accumulate(
      const uint64_t * restrict Y, // [n_in]
      uint32_t lb,
      uint32_t ub,
      uint32_t prev_nT,
      uint32_t prev_nH,
      const metrics_t *M,
      uint32_t *ptr_nbuf, // how many in buffer when returning
      uint32_t *ptr_lb // how many consumed when returning.
      )
{
  int status = 0;

  // START: Basic checks on input parameters
  if ( lb >= ub ) { return status; } // nothing to do 
  //-------------------------------

  uint32_t consumed_so_far = prev_nT + prev_nH;
  uint32_t left_to_consume = (ub-lb) - consumed_so_far;

  uint32_t nbuf = 1;
  uint32_t i = lb;

  uint64_t Y_i = Y[i];
  uint32_t yval_i = get_yval(Y_i);
  uint8_t goal_i  = get_goal(Y_i);
  uint64_t curr_yval = yval_i;
  M->yidx[nbuf-1] = lb;
  M->yval[nbuf-1] = yval_i;
  M->nT[nbuf-1]   = prev_nT;
  M->nH[nbuf-1]   = prev_nH;
  if ( goal_i == 0 ) { M->nT[nbuf-1]++; } else { M->nH[nbuf-1]++; } 
  i++;
  consumed_so_far++;
  left_to_consume--;

  for ( ; i < ub; i++ ) {
    Y_i = Y[i];
    yval_i = get_yval(Y_i);
    goal_i = get_goal(Y_i);
    if ( ( yval_i != curr_yval ) && 
         ( consumed_so_far >= g_C.min_partition_size ) && 
         ( left_to_consume >= g_C.min_partition_size ) ) {
      if ( nbuf == g_C.metrics_buffer_size ) { // no more space
        *ptr_lb = i;
        *ptr_nbuf = nbuf;
        return status;
      }
      // we have space in buffer
      curr_yval = yval_i;
      M->yidx[nbuf]  = i;
      M->yval[nbuf]  = yval_i;
      M->nT[nbuf]   = M->nT[nbuf-1]; // counts are cumulative
      M->nH[nbuf]   = M->nH[nbuf-1]; // counts are cumulative
      if ( goal_i == 0 ) { M->nT[nbuf]++; } else { M->nH[nbuf]++; } 
      nbuf++;
    }
    else {
      M->yidx[nbuf-1] = i;
      if ( goal_i == 0 ) { M->nT[nbuf-1]++; } else { M->nH[nbuf-1]++; } 
    }
    consumed_so_far++;
    left_to_consume--;
  }
  if ( nbuf > g_C.metrics_buffer_size ) { go_BYE(-1); }
  *ptr_nbuf = nbuf; // number of elements in buffer
  *ptr_lb = ub; // we have consumed up to ub
BYE:
  return status;
}
