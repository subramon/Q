#include "q_incs.h"
#include "_bits_to_bytes.h"

//START_FUNC_DECL
int
bits_to_bytes(
    uint64_t *in,
    uint64_t n_in,
    uint8_t *out,
    uint64_t n_out
    )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( in  == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( n_out   == 0    ) { go_BYE(-1); }
  uint64_t shift = 0;
  bool done = false;
  uint64_t oidx = 0;
  for ( uint64_t i = 0; i < n_in; i++ ) { 
    uint64_t inval = in[i];
    for ( int j = 0; j < 64; j++ ) { 
      int oval = (inval >> shift) & 1;
      out[oidx++] = oval;
      if ( oidx == n_out ) { done = true; break; }
      shift++;
    }
    if ( done ) { break; }
  }
BYE:
  return status;
}
