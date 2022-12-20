#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "get_time_usec.h"
#include "rdtsc.h"

//START_FUNC_DECL
uint64_t
RDTSC(
    void
    )
//STOP_FUNC_DECL
{
  return get_time_usec();
}
