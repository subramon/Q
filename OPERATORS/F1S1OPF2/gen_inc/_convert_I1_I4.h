
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>
#include <math.h>

extern int
convert_I1_I4(  
      const int8_t * const restrict in,  
      uint64_t *nn_in,
      uint64_t nR,
      void *dummy,
      int32_t * restrict out,  
      uint64_t *nn_out
      ) 
;

   
