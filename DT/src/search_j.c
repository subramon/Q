#include "incs.h"
#include "accumulate.h"
#include "calc_best_metric.h"
#include "eval_metrics.h"
#include "search_j.h"

int 
search_j(
    uint64_t *Yj, /* [m][n] */
    uint32_t lb,
    uint32_t ub,
    uint32_t *ptr_yval, // split value for this feature 
    uint32_t *ptr_yidx, // split idx for this feature 
    double *ptr_metric  // metric for this feature 
   )
{
  int status = 0;
  uint32_t nbuf; 
  // number  of elements in M after a call to accumulate
  metrics_t M[BUFSZ];
  double   best_metric = -1; 
  uint32_t best_yval; 
  uint32_t best_yidx; 

  uint32_t new_lb = lb;
  for ( ; ; ) { 
    if ( new_lb >= ub ) { break; }
    status = accumulate(Yj, lb, ub, M, &nbuf, &new_lb); cBYE(status);
    lb = new_lb;
    status = eval_metrics(M, nbuf); cBYE(status);
    uint32_t loc = 0;
    status = calc_best_metric(M, nbuf, &loc); cBYE(status);
    if ( M[loc].metric > best_metric ) { 
      best_metric = M[loc].metric;
      best_yval   = M[loc].yval;
      best_yidx   = M[loc].yidx;
    }
  }
  *ptr_yval = best_yval;
  *ptr_yidx = best_yidx;
  *ptr_metric  = best_metric;
BYE:
  return status;
}
