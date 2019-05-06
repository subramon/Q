
#include "q_incs.h"
#include "_set_bit_u64.h"
#include "_bin_search_F8.h"
extern int
bin_search_ainb_I4_F8(  
      const int32_t * restrict a,  
      uint64_t nA,
      const double * restrict b,  
      uint32_t nB,
      uint64_t *C // output  nA bytes
      );
   
