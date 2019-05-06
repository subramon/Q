//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "TM_to_SC.h"
//START_FUNC_DECL
int
TM_to_SC(
      struct tm *inv,
      uint64_t n_in,
      const char *format,
      char * outv,
      uint32_t width // remember that this DOES include nullc
      )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( inv  == NULL ) { go_BYE(-1); }
  if ( outv == NULL ) { go_BYE(-1); }
  if ( n_in == 0 ) { go_BYE(-1); }
  if ( width == 0 ) { go_BYE(-1); }

// TODO #pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < n_in; i++ ) { 
    memset(outv+(i*width), '\0', width);
    size_t rslt = strftime(outv+(i*width), width-1, format, inv + i);
    if ( rslt == 0 ) { go_BYE(-1); }
  }
  cBYE(status);
BYE:
  return status;
}
