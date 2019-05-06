
#include "q_incs.h"
extern int
drop_nulls_F4(  
      float * restrict const y, // input field 1
      uint64_t * restrict const x, // condition field 
      const float * const ptr_sval_z, // scalar val
      uint64_t n
      );
   
