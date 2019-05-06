
#include "_seq_F4.h"

//START_FUNC_DECL
int
seq_F4(
  float *X,
  uint64_t nX,
  SEQ_F4_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  float start = ptr_in->start;
  float by = ptr_in->by;

  start += (idx *by); // offset based on index

  if ( by == 0 ) {
    by = (float) 1;
  }

  float j = start;
  for ( uint64_t i = 0; i < nX; i++ ) { 
    X[i] = (float) j;
    j += by;
  }
  return status;
}

   
