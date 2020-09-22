#include "incs.h"
#include "accumulate.h"
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
  uint32_t bufsz = 1024;
  uint32_t yvals[bufsz];
  uint32_t cnts[2][bufsz]; // on stack allocation

  uint32_t processed_lb = lb;
  for ( ; ; ) { 
    if ( processed_lb >= ub ) { break; }
    status = accumulate(Yj, lb, ub, yval, cnts, bufsz, &nbuf, 
        &processed_lb);
    cBYE(status);
    status = best_metric(cnts, nbuf, &metric, &loc); cBYE(status);
  }
BYE:
  return status;
}
