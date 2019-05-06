
#include "_seq_I1.h"

//START_FUNC_DECL
int
seq_I1(
  int8_t *X,
  uint64_t nX,
  SEQ_I1_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  int8_t start = ptr_in->start;
  int8_t by = ptr_in->by;

  start += (idx *by); // offset based on index

  if ( by == 0 ) {
    by = (int8_t) 1;
  }

  int8_t j = start;
  for ( uint64_t i = 0; i < nX; i++ ) { 
    X[i] = (int8_t) j;
    j += by;
  }
  return status;
}

   
