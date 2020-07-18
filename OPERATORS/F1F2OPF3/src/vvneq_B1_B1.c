#include <stdio.h>
#include <stdint.h>
#include "vvneq_B1_B1.h"
#include "get_bit_u64.h"
#include "set_bit_u64.h"
int
vvneq_B1_B1(  
      const uint64_t * restrict in1,  
      const uint64_t * restrict in2,  
      uint64_t nR,  
      uint64_t * restrict out 
      )
{ 
  int status = 0;
  if ( in1 == NULL ) { go_BYE(-1); }
  if ( in2 == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( nR  == 0    ) { go_BYE(-1); }
  uint64_t n = nR / 64;
  for ( uint64_t i = 0; i < n; i++ ) { 
    out[i] = in1[i] ^ in2[i];
  }
  for ( uint64_t i = n * 64; i < nR; i++ ) { 
    uint32_t b1 = get_bit_u64(in1, i);
    uint32_t b2 = get_bit_u64(in2, i);
    uint32_t b3 = b1^b2;
    set_bit_u64(out, i, b3);
  }
BYE:
return status;
}
