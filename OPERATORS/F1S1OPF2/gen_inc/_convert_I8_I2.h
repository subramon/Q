
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>
#include <math.h>

extern int
convert_I8_I2(  
      const int64_t * const restrict in,  
      uint64_t *nn_in,
      uint64_t nR,
      void *dummy,
      int16_t * restrict out,  
      uint64_t *nn_out
      ) 
;

   
