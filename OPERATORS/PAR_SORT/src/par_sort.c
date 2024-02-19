#include "q_incs.h"
#include "q_macros.h"

int
par_sort(
    char *X,
    uint8_t *off, // [nb]
    uint8_t *cnt, // [nb]
    uint32_t nb
    )
{
  int status = 0;
// #pragma omp parallel for 
  for ( uint32_t i = 0; i < nb; i++ ) { 
    qsort_XX(X+off[i], cnt[i]);
  }
BYE:
  return status;
}

