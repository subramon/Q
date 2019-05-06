
#include "_const_F4.h"


//START_FUNC_DECL
int
const_F4(
  float * const restrict X,
  uint64_t nX,
  float *ptr_val,
  uint64_t dummy
  )
//STOP_FUNC_DECL
{
  int status = 0;
  float val = *ptr_val;
#pragma omp parallel for schedule(static, 4096)
  for ( uint64_t i = 0; i < nX; i++ ) { 
   // __builtin_prefetch(X+i+1024, 1, 1);
    X[i] = val;
  }
  return status;
}


   
