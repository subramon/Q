#ifndef __SC_to_TM
#define __SC_to_TM
#include "q_incs.h"
//START_FOR_CDEF
extern int
SC_to_TM(
      char * const inv,
      uint32_t offset,
      uint64_t n_in,
      const char *format,
      struct tm *outv
      );
//STOP_FOR_CDEF
#endif
