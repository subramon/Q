#include "incs.h"
#include "accumulate.h"
#include "best_metric.h"
#include "search_j.h"

int 
search_j(
    uint64_t *Yj, /* [m][n] */
    uint32_t lb,
    uint32_t ub,
    uint32_t *ptr_yval,
    uint32_t *ptr_yidx,
    double *ptr_metric
   )
{
  int status = 0;
  uint32_t nbuf;
  uint32_t yvals[BUFSZ];
  uint32_t cnts[2][BUFSZ]; // on stack allocation
  double metric; uint32_t loc;

  uint32_t processed_lb = lb;
  for ( ; ; ) { 
    if ( processed_lb >= ub ) { break; }
    status = accumulate(Yj, lb, ub, yvals, cnts, BUFSZ, &nbuf, 
        &processed_lb);
    cBYE(status);
    status = best_metric(cnts, nbuf, &metric, &loc); cBYE(status);
  }
BYE:
  return status;
}
