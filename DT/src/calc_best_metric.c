#include "incs.h"
#include "calc_best_metric.h"
int
calc_best_metric(
    metrics_t *M,
    uint32_t nbuf,
    uint32_t *ptr_loc
    )
{
  int status = 0;
  uint32_t loc = 0;
  double best_metric = M->metric[0];
  for ( uint32_t i = 1; i < nbuf; i++ ) { 
    if ( M->metric[i] > best_metric ) {
      loc = i;
      best_metric = M->metric[i];
    }
  }
  *ptr_loc = loc; 
BYE:
  return status;
}
