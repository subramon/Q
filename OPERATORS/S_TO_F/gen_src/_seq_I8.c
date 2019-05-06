
#include "_seq_I8.h"

//START_FUNC_DECL
int
seq_I8(
  int64_t *X,
  uint64_t nX,
  SEQ_I8_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  int64_t start = ptr_in->start;
  int64_t by = ptr_in->by;

  start += (idx *by); // offset based on index

  if ( by == 0 ) {
    by = (int64_t) 1;
  }

  int64_t j = start;
  for ( uint64_t i = 0; i < nX; i++ ) { 
    X[i] = (int64_t) j;
    j += by;
  }
  return status;
}

   
