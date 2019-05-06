
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>

extern int
shift_right_I8(  
      const int64_t * restrict in,  
      uint64_t *nn_in,
      uint64_t nR,
      int *ptr_shift_by,
      int64_t * out,
      uint64_t *nn_out
      ) 
;

   
