#ifndef __SC_to_TM
#define __SC_to_TM
#include "q_incs.h"
extern char *strptime(const char *s, const char *format, struct tm *tm);

extern int
SC_to_TM(
      char * const inv,
      uint32_t offset,
      uint64_t n_in,
      const char *format,
      struct tm *outv
      );
#endif
