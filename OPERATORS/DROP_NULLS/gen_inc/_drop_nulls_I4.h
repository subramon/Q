
#include "q_incs.h"
extern int
drop_nulls_I4(  
      int32_t * restrict const y, // input field 1
      uint64_t * restrict const x, // condition field 
      const int32_t * const ptr_sval_z, // scalar val
      uint64_t n
      );
   
