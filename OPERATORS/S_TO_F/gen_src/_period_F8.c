
#include "_period_F8.h"

//START_FUNC_DECL
int
period_F8(
  double *X,
  uint64_t nX,
  PERIOD_F8_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  double start = ptr_in->start;
  double by    = ptr_in->by;
  int         period = ptr_in->period;

  int offset = idx % period;
  double j = start + (by * ( idx % period));
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

   
