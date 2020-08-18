//START_INCLUDES
#include <omp.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
//STOP_INCLUDES
#include "q_omp_get_num_procs.h"
//START_FUNC_DECL
int // TODO inline this function
q_omp_get_num_procs(
    void
    )
//STOP_FUNC_DECL
{
  return omp_get_num_procs();
}
