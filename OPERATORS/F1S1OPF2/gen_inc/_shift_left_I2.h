
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>

extern int
shift_left_I2(  
      const int16_t * restrict in,  
      uint64_t *nn_in,
      uint64_t nR,
      int *ptr_shift_by,
      int16_t * out,
      uint64_t *nn_out
      ) 
;

   
