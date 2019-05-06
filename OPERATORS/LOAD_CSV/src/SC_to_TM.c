//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "SC_to_TM.h"
//START_FUNC_DECL
int
SC_to_TM(
      char * const inv,
      uint32_t offset,
      uint64_t n_in,
      const char *format,
      struct tm *outv
      )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( inv  == NULL ) { go_BYE(-1); }
  if ( outv == NULL ) { go_BYE(-1); }
  if ( n_in == 0 ) { go_BYE(-1); }
  if ( offset == 0 ) { go_BYE(-1); }

// TODO #pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < n_in; i++ ) { 
    char *cptr = inv + (i*offset);
    memset(outv+i, '\0', sizeof(struct tm));
    char *rslt = strptime(cptr, format, outv+i);
    /*  If strptime() fails to match all of  the  format  string
       and therefore an error occurred, the function returns NULL. */
    if ( rslt  == NULL ) { go_BYE(-1); }
    /* In case the whole  input string  is consumed, the return value 
       points to the null byte at the end of the string. */
    // TODO: P3 This seg faults if ( *rslt == '\0' ) { go_BYE(-1); }
  }
  cBYE(status);
BYE:
  return status;
}
