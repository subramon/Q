//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "set_bit_u64.h"
//START_FUNC_DECL
int // TODO inline this function
set_bit_u64(
    uint64_t *X, 
    uint64_t i, 
    uint64_t val
    )
//STOP_FUNC_DECL
{
  int status = 0;
  uint64_t widx = i >> 6; // word index 
  uint64_t bidx = i & 0x3F; // bit index 
  if ( ( (  val != 0 ) && ( val != 1 ) ) ) { go_BYE(-1); }
  // clear the ith bit
  uint64_t mask = 1;
  mask = ~(mask << bidx);
  X[widx] = X[widx] & mask;
  // set the ith bit as per input "val"
  val = val << bidx;
  X[widx] = X[widx] | val;
BYE:
  return status;
}
