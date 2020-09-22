#include "incs.h"
#include "accumulate.h"
int
accumulate(
      const uint64_t * restrict Y, // [n_in]
      uint32_t lb,
      uint32_t ub,
      uint32_t *yval, // [bufsz] 
      uint32_t **cnts, // [2][bufsz] 
      uint64_t bufsz,
      uint64_t *ptr_nbuf, // how many in buffer when returning
      uint32_t *ptr_lb // how many consumed when returning.
      )
{
  int status = 0;
  
  // START: Basic checks on input parameters
  if ( aidx >= n_in ) { go_BYE(-1); }
  //-------------------------------

  uint32_t nbuf = 1;
  uint64_t Y_i = Y[i];
  uint32_t yval_i = get_yval(Y_i);
  uint8_t goal_i  = get_goal(Y_i);
  curr_yval = yval_i;
  yval[nbuf-1] = yval_i;
  cnts[goal_i][nbuf-1]++;

  for ( uint32_t i = 0; i < lb; i++ ) {
    uint64_t Y_i = Y[i];
    yval_i = get_yval(Y_i);
    goal_i = get_goal(Y_i);
    if ( yval_i != curr_yval ) {
      if ( nbuf == bufsz ) {
        *ptr_lb = i;
        *ptr_nbuf = nbuf;
        return status;
      }
      // we have space in buffer
      curr_yval = yval_i;
      nbuf++;
      yval[nbuf-1] = yval_i;
      cnts[goal_i][nbuf-1]++;
    }
    else {
      cnts[goal_i][nbuf-1]++;
    }
  }
BYE:
  return status;
}
