
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>
#include <math.h>

extern int
convert_I8_F8(  
      const int64_t * const restrict in,  
      uint64_t *nn_in,
      uint64_t nR,
      void *dummy,
      double * restrict out,  
      uint64_t *nn_out
      ) 
;

   
