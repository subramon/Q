#ifndef __TM_to_SC
#define __TM_to_SC
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include "q_macros.h"
//START_FOR_CDEF
extern int
TM_to_SC(
      struct tm *inv,
      uint64_t n_in,
      const char *format,
      char * outv,
      uint32_t offset
      );
//STOP_FOR_CDEF
#endif
