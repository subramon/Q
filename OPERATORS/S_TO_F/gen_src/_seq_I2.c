
#include "_seq_I2.h"

//START_FUNC_DECL
int
seq_I2(
  int16_t *X,
  uint64_t nX,
  SEQ_I2_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  int16_t start = ptr_in->start;
  int16_t by = ptr_in->by;

  start += (idx *by); // offset based on index

  if ( by == 0 ) {
    by = (int16_t) 1;
  }

  int16_t j = start;
  for ( uint64_t i = 0; i < nX; i++ ) { 
    X[i] = (int16_t) j;
    j += by;
  }
  return status;
}

   
