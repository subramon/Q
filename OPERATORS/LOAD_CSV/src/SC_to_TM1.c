//START_INCLUDES
#define _XOPEN_SOURCE       /* See feature_test_macros(7) */
#include <time.h>
#include "q_incs.h"
#include "qtypes.h"
//STOP_INCLUDES
#include "SC_to_TM1.h"
//START_FUNC_DECL
int
SC_to_TM1(
      char * const inv,
      uint32_t offset,
      uint64_t n_in,
      const char *format,
      tm_t *outv
      )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( inv  == NULL ) { go_BYE(-1); }
  if ( outv == NULL ) { go_BYE(-1); }
  if ( n_in == 0 ) { go_BYE(-1); }
  if ( offset == 0 ) { go_BYE(-1); }

  tm_t  *tptr = (tm_t *)outv;
// TODO #pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < n_in; i++ ) { 
    char *cptr = inv + (i*offset);
    memset(outv+i, '\0', sizeof(tm_t));

    struct tm l_tm;
    memset(&l_tm, 0, sizeof(struct tm));
    char *rslt = strptime(cptr, format, &l_tm);
    if ( rslt == NULL ) { WHEREAMI; status = -1; }
    tptr[i].tm_year = l_tm.tm_year;
    tptr[i].tm_mon  = l_tm.tm_mon;
    tptr[i].tm_mday = l_tm.tm_mday;
    tptr[i].tm_hour = l_tm.tm_hour;
    tptr[i].tm_min  = l_tm.tm_min;
    tptr[i].tm_sec  = l_tm.tm_sec;
    tptr[i].tm_yday = l_tm.tm_yday;
  }
  cBYE(status);
BYE:
  return status;
}
