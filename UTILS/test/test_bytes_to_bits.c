#include "q_incs.h"
#include "_bytes_to_bits.h"
#include "_bits_to_bytes.h"
int 
main(
    )
{
  int status = 0;
  int n_in = 67; uint8_t  in[n_in]; uint8_t chk_in[n_in];
  int n_out = 2; uint64_t out[n_out];

  for ( int i = 0; i < n_in; i++ ) { 
    if ( ( i % 2 ) == 0 ) { in[i] = 1; } else { in[i] = 0; }
  }
  for ( int i = 0; i < n_out; i++ ) { 
    out[i] = 0;
  }
  status = bytes_to_bits(in,n_in, out); cBYE(status);
  status = bits_to_bytes(out, chk_in, n_in); cBYE(status);
  for ( int i = 0; i < n_in; i++ ) { 
    if ( in[i] != chk_in[i] ) { fprintf(stdout, "SUCCESS\n"); go_BYE(-1); }
  }
  fprintf(stdout, "SUCCESS\n");

BYE:
  return status;
}
