#include "incs.h"
#include "accumulate.h"
int
accumulate(
      const uint64_t * restrict Y, // [n_in]
      uint32_t lb,
      uint32_t ub,
      uint32_t *yvals, // [bufsz] 
      uint32_t **cnts, // [2][bufsz] 
      uint32_t bufsz,
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
  yvals[nbuf-1] = yval_i;
  cnts[goal_i][nbuf-1]++;
  i++;

  for ( ; i < ub; i++ ) {
    Y_i = Y[i];
    yval_i = get_yval(Y_i);
    goal_i = get_goal(Y_i);
    if ( yval_i != curr_yval ) {
      if ( nbuf == bufsz ) { // no more space
        *ptr_lb = i;
        *ptr_nbuf = nbuf;
        return status;
      }
      // we have space in buffer
      curr_yval = yval_i;
      nbuf++;
      yvals[nbuf-1] = yval_i;
      cnts[goal_i][nbuf-1]++;
    }
    else {
      cnts[goal_i][nbuf-1]++;
    }
  }
BYE:
  return status;
}
