//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "TM_to_I8.h"
//START_FUNC_DECL
int
TM_to_I8(
      struct tm *inv,
      uint64_t n_in,
      int64_t * outv
      )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( inv  == NULL ) { go_BYE(-1); }
  if ( outv == NULL ) { go_BYE(-1); }
  if ( n_in == 0 ) { go_BYE(-1); }

// TODO #pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < n_in; i++ ) { 
    struct tm ltm = inv[i];
    time_t tval = mktime(&ltm);
    outv[i] = (int64_t)tval;
  }
  cBYE(status);
BYE:
  return status;
}
