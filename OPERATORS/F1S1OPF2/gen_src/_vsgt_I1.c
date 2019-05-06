#include "_vsgt_I1.h"
int
vsgt_I1(  
      const int8_t * restrict in,  
      uint64_t *nn_in,
      uint64_t nR,  
      int8_t *ptr_sval,
      uint64_t * restrict out,
      uint64_t *restrict nn_out 
      )
{
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( ptr_sval == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }

  int8_t sval = *ptr_sval;
#define VECTOR_LENGTH 4096
  /* calculate number of VECTOR_LENGTH element sized chunks to process */
  uint64_t num_blocks = nR / VECTOR_LENGTH; 
  int num_last_block = VECTOR_LENGTH;
  if ( ( num_blocks * VECTOR_LENGTH ) != nR ) { 
    num_last_block = nR - ( num_blocks * VECTOR_LENGTH);
    num_blocks++; 
  }
#pragma omp parallel for schedule(static)
  for ( uint64_t blk_idx = 0; blk_idx < num_blocks; blk_idx++ ) {  
    uint64_t lb = blk_idx * VECTOR_LENGTH;;
    uint64_t ub = lb + VECTOR_LENGTH;;
    if ( blk_idx == (num_blocks-1) ) { ub = lb + num_last_block; }
    int bit_idx = 0;
    uint64_t out_idx = lb / 64;
    uint64_t oval = 0;
    for ( uint64_t iidx = lb; iidx < ub; iidx++ ) {
      int8_t inval = in[iidx]; 
      int rslt = (inval   >    sval);
      /* TODO: Avoid the if condition */
      if ( rslt == 1 ) { set_bit_u64(&oval, bit_idx, 1); }
      bit_idx++;
      if ( bit_idx == 64 ) {
        bit_idx = 0;
        out[out_idx] = oval;
        out_idx++;
        oval = 0;
      }
    }
    if ( bit_idx != 0 ) { 
      out[out_idx] = oval;
    }
  }
  BYE:
  return status;
}
   
