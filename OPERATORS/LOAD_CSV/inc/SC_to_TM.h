#ifndef __SC_to_TM
#define __SC_to_TM
#define _XOPEN_SOURCE
#define __USE_XOPEN
#include <time.h>
extern int
SC_to_TM(
      char * const inv,
      uint32_t offset,
      uint64_t n_in,
      const char *format,
      struct tm *outv
      );
#endif
