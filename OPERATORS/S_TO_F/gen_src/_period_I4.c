
#include "_period_I4.h"

//START_FUNC_DECL
int
period_I4(
  int32_t *X,
  uint64_t nX,
  PERIOD_I4_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  int32_t start = ptr_in->start;
  int32_t by    = ptr_in->by;
  int         period = ptr_in->period;

  int offset = idx % period;
  int32_t j = start + (by * ( idx % period));
  for ( uint64_t i = 0; i < nX; i += 1 ) { 
    X[i] = j;
    offset++;
    if ( offset == period ) { 
      offset = 0;
      j = start;
    }
    else {
      j += by;
    }
  }
  return status;
}

   
