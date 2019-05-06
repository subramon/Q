
#include "_convert_B1_I1.h"

int
convert_B1_I1(
      const uint64_t * const in,
      uint64_t *nn_in,
      uint64_t nR,
      uint64_t *ptr_num_null,
      int8_t * restrict out,
      uint64_t *nn_out
      )

{
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }
  if ( ( nn_in != NULL ) && ( nn_out == NULL ) ) { go_BYE(-1); }
  uint64_t num_null = 0;

#pragma omp parallel for schedule(static)
  for ( uint64_t i = 0; i < nR; i++ ) {
    int8_t out_val = 0;
    int nn_out_val = 1;
    out_val = get_bit_u64(in, i);
    if ( nn_in != NULL ) {
      nn_out_val = get_bit_u64(nn_in, i);
      if ( nn_out_val == 0 ) {
        num_null++;
        out_val = 0;
      }
    }
    if ( nn_out != NULL ) {
      set_bit_u64(nn_out, i, nn_out_val);
    }
    out[i] = out_val;
  }
  if ( ptr_num_null != NULL ) {
    *ptr_num_null += num_null;
  }
BYE:
  if ( status < 0 ) { WHEREAMI; }
  return status;
}
   
