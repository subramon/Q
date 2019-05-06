//START_INCLUDES
#include "q_incs.h"
#include <omp.h>
//STOP_INCLUDES
#include "_q_omp_get_num_procs.h"
//START_FUNC_DECL
int // TODO inline this function
q_omp_get_num_procs(
    void
    )
//STOP_FUNC_DECL
{
  return omp_get_num_procs();
}
