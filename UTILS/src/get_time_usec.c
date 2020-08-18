//START_INCLUDES
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
//STOP_INCLUDES
#include "get_time_usec.h"
//START_FUNC_DECL
uint64_t 
get_time_usec(
    void
    )
//STOP_FUNC_DECL
{
  struct timeval Tps; 
  struct timezone Tpf;
  gettimeofday (&Tps, &Tpf);
  return ((uint64_t )Tps.tv_usec + 1000000* (uint64_t )Tps.tv_sec);
}
