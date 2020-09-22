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
  *ptr_loc = random() % nbuf; // TODO 
BYE:
  return status;
}
