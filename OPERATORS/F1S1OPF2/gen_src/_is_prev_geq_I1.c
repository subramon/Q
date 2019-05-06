
#include "_is_prev_geq_I1.h"

int
is_prev_geq_I1(  
      const int8_t * restrict in,  
      uint64_t nR,
      int default_val,
      int first,
      uint64_t *out,
      int8_t *ptr_last_val_prev_chunk
      )

{
  int status = 0;

  //-- Some basic checks
  if ( nR  == 0 ) { go_BYE(-1); }
  if ( in  == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( ( first != 0 ) && ( first != 1 ) ) { go_BYE(-1); }
  if ( ( default_val != 0 ) && ( default_val != 1 ) ) { go_BYE(-1); }
  //---------------------------------
  if ( first == 1 ) {
    set_bit_u64(out, 0, default_val);
  }
  else {
    set_bit_u64(out, 0, (*ptr_last_val_prev_chunk == in[0]));
  }
  for ( uint64_t i = 1; i < nR; i++ ) { 
    set_bit_u64(out, i, (in[i]  <  in[i-1]));
  }
  *ptr_last_val_prev_chunk = in[nR-1];
BYE:
  return status;
}
   
