
#include "q_incs.h"
#include "_set_bit_u64.h"
#include "_get_bit_u64.h"
#include <unistd.h>
#include <stdint.h>
#include <math.h>

extern int
convert_I8_B1(  
      const int64_t * const restrict in,  
      uint64_t *nn_in,
      uint64_t nR,
      uint64_t *ptr_num_null,
      uint64_t * out,
      uint64_t *nn_out
      ) 
;

   
