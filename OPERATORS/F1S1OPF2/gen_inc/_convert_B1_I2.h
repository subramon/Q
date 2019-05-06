
#include "q_incs.h"
#include "_get_bit_u64.h"
#include "_set_bit_u64.h"
#include <unistd.h>
#include <stdint.h>
#include <math.h>

extern int
convert_B1_I2(
      const uint64_t * const restrict in,
      uint64_t *nn_in,
      uint64_t nR,
      uint64_t *ptr_num_null,
      int16_t * restrict out,
      uint64_t *nn_out
      )
;

   
