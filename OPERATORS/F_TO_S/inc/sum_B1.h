#include "q_incs.h"
#include "sum_struct.h"
#ifndef __SUM_B1
#define __SUM_B1

extern unsigned int 
popcount64(
    uint64_t value
    );
extern int
sum_B1(  
      const uint64_t  * restrict in,  
      uint64_t nR,
      SUM_I_ARGS *in_ptr_args,
      uint64_t idx
      );
#endif
