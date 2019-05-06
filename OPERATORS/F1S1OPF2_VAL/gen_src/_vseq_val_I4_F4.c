#include "_vseq_val_I4_F4.h"
int
vseq_val_I4_F4(
      const int32_t * restrict X,
      float *ptr_sval,
      uint64_t nX,
      uint64_t *ptr_a_idx,
      int32_t * restrict out,
      uint64_t * restrict idx_buf,
      uint64_t out_size,
      uint64_t *ptr_out_idx
      )
{
  int status = 0;
  if ( X == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( idx_buf == NULL ) { go_BYE(-1); }
  if ( ptr_sval == NULL ) { go_BYE(-1); }
  if ( nX == 0 ) { go_BYE(-1); }
  if ( out_size == 0 ) { go_BYE(-1); }
  if ( ptr_out_idx == NULL ) { go_BYE(-1); }
  if ( ptr_a_idx == NULL ) { go_BYE(-1); }

  uint64_t a_idx = *ptr_a_idx;
  uint64_t out_idx = *ptr_out_idx;
  float sval = *ptr_sval;

  if ( out_idx >= out_size ) {
    fprintf(stderr, "output buffer is full\n");
    fprintf(stderr, "out_idx, out_size = %" PRIu64 ", %" PRIu64 "\n", out_size, out_size);
    go_BYE(-1);
  }

  if ( a_idx >= nX ) { go_BYE(-1); }

  for ( ; a_idx < nX; a_idx++ ) {
    if ( out_idx == out_size ) { break; }
    int32_t inval = X[a_idx];
    if ( inval   ==   sval ) {
      out[out_idx] = inval;
      idx_buf[out_idx++] = a_idx;
    }
  }

  *ptr_out_idx = out_idx;
  *ptr_a_idx = a_idx;
  if ( out_idx > out_size ) { go_BYE(-1); }
  if ( a_idx > nX ) { go_BYE(-1); }
  //-------------------------------

BYE:
  return status;
}
   
