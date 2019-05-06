#ifndef __TM_to_SC
#define __TM_to_SC
#include <time.h>
extern int
TM_to_SC(
      struct tm *inv,
      uint64_t n_in,
      const char *format,
      char * outv,
      uint32_t offset
      );
#endif
