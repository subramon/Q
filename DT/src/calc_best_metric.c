#include "incs.h"
#include "calc_best_metric.h"
int
calc_best_metric(
    metrics_t M[BUFSZ],
    uint32_t nbuf,
    uint32_t *ptr_loc
    )
{
  int status = 0;
  uint32_t loc = 0;
  double best_metric = M[0].metric;
  for ( uint32_t i = 1; i < nbuf; i++ ) { 
    if ( M[i].metric > best_metric ) {
      loc = i;
      best_metric = M[i].metric;
    }
  }
  *ptr_loc = loc; 
BYE:
  return status;
}
