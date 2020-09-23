#include "incs.h"
#include "accumulate.h"
int
accumulate(
      const uint64_t * restrict Y, // [n_in]
      uint32_t lb,
      uint32_t ub,
      uint32_t prev0,
      uint32_t prev1,
      metrics_t M[BUFSZ],
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
  M[nbuf-1].metric = -1; // initialize to bad value 
  M[nbuf-1].yidx = lb;
  M[nbuf-1].yval = yval_i;
  M[nbuf-1].cnt[0] = prev0;
  M[nbuf-1].cnt[1] = prev1;
  M[nbuf-1].cnt[goal_i]++;
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
      M[nbuf].metric = -1; 
      M[nbuf].yidx = i;
      M[nbuf].yval = yval_i;
      M[nbuf].cnt[0] = M[nbuf-1].cnt[0]; // counts are cumulative
      M[nbuf].cnt[1] = M[nbuf-1].cnt[1];
      M[nbuf].cnt[goal_i]++;
      nbuf++;
    }
    else {
      M[nbuf-1].yidx = i;
      M[nbuf-1].cnt[goal_i]++;
    }
  }
  if ( nbuf > BUFSZ ) { go_BYE(-1); }
  *ptr_nbuf = nbuf; // number of elements in buffer
  *ptr_lb = ub; // we have consumed up to ub
BYE:
  return status;
}
