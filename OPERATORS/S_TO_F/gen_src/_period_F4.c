
#include "_period_F4.h"

//START_FUNC_DECL
int
period_F4(
  float *X,
  uint64_t nX,
  PERIOD_F4_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  float start = ptr_in->start;
  float by    = ptr_in->by;
  int         period = ptr_in->period;

  int offset = idx % period;
  float j = start + (by * ( idx % period));
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

   
