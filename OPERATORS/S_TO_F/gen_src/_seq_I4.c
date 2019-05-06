
#include "_seq_I4.h"

//START_FUNC_DECL
int
seq_I4(
  int32_t *X,
  uint64_t nX,
  SEQ_I4_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  int32_t start = ptr_in->start;
  int32_t by = ptr_in->by;

  start += (idx *by); // offset based on index

  if ( by == 0 ) {
    by = (int32_t) 1;
  }

  int32_t j = start;
  for ( uint64_t i = 0; i < nX; i++ ) { 
    X[i] = (int32_t) j;
    j += by;
  }
  return status;
}

   
