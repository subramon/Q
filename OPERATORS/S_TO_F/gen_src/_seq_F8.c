
#include "_seq_F8.h"

//START_FUNC_DECL
int
seq_F8(
  double *X,
  uint64_t nX,
  SEQ_F8_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  double start = ptr_in->start;
  double by = ptr_in->by;

  start += (idx *by); // offset based on index

  if ( by == 0 ) {
    by = (double) 1;
  }

  double j = start;
  for ( uint64_t i = 0; i < nX; i++ ) { 
    X[i] = (double) j;
    j += by;
  }
  return status;
}

   
