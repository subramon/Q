
#include "q_incs.h"
#include "_set_bit_u64.h"
#include "_bin_search_I8.h"
extern int
bin_search_ainb_F4_I8(  
      const float * restrict a,  
      uint64_t nA,
      const int64_t * restrict b,  
      uint32_t nB,
      uint64_t *C // output  nA bytes
      );
   
