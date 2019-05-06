#include "q_incs.h"
#include "_get_bit_u64.h"
//START_FUNC_DECL
int // TODO inline this function
get_bit_u64(
    const uint64_t * const X,
    uint64_t i
)
//STOP_FUNC_DECL
{
  uint64_t widx = i >> 6; 
  uint64_t bidx = i & 0x3F; 
  uint64_t val = ( X[widx] >> bidx )  & 0x1; 
  return val;
}
