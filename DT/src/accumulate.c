#include "incs.h"
#include "accumulate.h"
int
accumulate(
      const uint64_t * restrict Y, // [n_in]
      uint32_t lb,
      uint32_t ub,
      uint32_t prev0,
      uint32_t prev1,
      uint32_t M_yval[BUFSZ],
      uint32_t M_yidx[BUFSZ],
      uint32_t M_nT[BUFSZ],
      uint32_t M_nH[BUFSZ],
      uint32_t *ptr_nbuf, // how many in buffer when returning
      uint32_t *ptr_lb // how many consumed when returning.
      )
{
  int status = 0;

  // START: Basic checks on input parameters
  if ( lb >= ub ) { return status; } // nothing to do 
  //-------------------------------

  uint32_t nbuf = 1;
  uint32_t i = lb;

  uint64_t Y_i = Y[i];
  uint32_t yval_i = get_yval(Y_i);
  uint8_t goal_i  = get_goal(Y_i);
  uint64_t curr_yval = yval_i;
  M_yidx[nbuf-1] = lb;
  M_yval[nbuf-1] = yval_i;
  M_nT[nbuf-1]   = prev0;
  M_nH[nbuf-1]   = prev1;
  if ( goal_i == 0 ) { M_nT[nbuf-1]++; } else { M_nH[nbuf-1]++; } 
  i++;

  for ( ; i < ub; i++ ) {
    Y_i = Y[i];
    yval_i = get_yval(Y_i);
    goal_i = get_goal(Y_i);
    if ( yval_i != curr_yval ) {
      if ( nbuf == BUFSZ ) { // no more space
        *ptr_lb = i;
        *ptr_nbuf = nbuf;
        return status;
      }
      // we have space in buffer
      curr_yval = yval_i;
      M_yidx[nbuf]  = i;
      M_yval[nbuf]  = yval_i;
      M_nT[nbuf]   = M_nT[nbuf-1]; // counts are cumulative
      M_nH[nbuf]   = M_nH[nbuf-1]; // counts are cumulative
      if ( goal_i == 0 ) { M_nT[nbuf]++; } else { M_nH[nbuf]++; } 
      nbuf++;
    }
    else {
      M_yidx[nbuf-1] = i;
      if ( goal_i == 0 ) { M_nT[nbuf-1]++; } else { M_nH[nbuf-1]++; } 
    }
  }
  if ( nbuf > BUFSZ ) { go_BYE(-1); }
  *ptr_nbuf = nbuf; // number of elements in buffer
  *ptr_lb = ub; // we have consumed up to ub
BYE:
  return status;
}
