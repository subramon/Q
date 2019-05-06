
#include "q_incs.h"
#include "_bytes_to_bits.h"

//START_FUNC_DECL
int
bytes_to_bits(
    uint8_t *in,
    uint64_t n,
    uint64_t *out
    )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( in  == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( n   == 0    ) { go_BYE(-1); }
  int oidx = 0;
  uint64_t oval = 0;
  int shift = 0;
  for ( uint64_t i = 0; i < n; i++ ) { 
    uint64_t inval = in[i];
    if ( inval > 1 ) { go_BYE(-1); }
    oval = oval | ( inval << shift);
    shift++;
    if ( shift == 64 ) {
      out[oidx] = oval;
      oval = 0;
      shift = 0;
      oidx++;
    }
  }
  if ( shift != 0 ) { // deal with left over
    out[oidx] = oval;
  }
BYE:
  return status;
}
