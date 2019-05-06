
#include "q_incs.h"
#include "_set_bit_u64.h"
#include "_bin_search_F4.h"
extern int
bin_search_ainb_F8_F4(  
      const double * restrict a,  
      uint64_t nA,
      const float * restrict b,  
      uint32_t nB,
      uint64_t *C // output  nA bytes
      );
   
