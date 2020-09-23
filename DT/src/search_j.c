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
    uint32_t nT,
    uint32_t nH,
    four_nums_t *ptr_num4,
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

  memset(&M, 0, (BUFSZ * sizeof(metrics_t)));
  uint32_t new_lb = lb;
  uint32_t prev0 = 0, prev1 = 0;
  for ( ; ; ) { 
    if ( new_lb >= ub ) { break; }
    status = accumulate(Yj, lb, ub, prev0, prev1, M, &nbuf, &new_lb); cBYE(status);
    lb = new_lb;
    status = eval_metrics(M, nbuf); cBYE(status);
    uint32_t loc = 0;
    status = calc_best_metric(M, nbuf, &loc); cBYE(status);
    if ( M[loc].metric > best_metric ) { 
      best_metric = M[loc].metric;
      best_yval   = M[loc].yval;
      best_yidx   = M[loc].yidx;
      ptr_num4->n_T_L = M[loc].cnt[0];
      ptr_num4->n_H_L = M[loc].cnt[1];
      ptr_num4->n_T_R = nT - M[loc].cnt[0];
      ptr_num4->n_H_R = nH - M[loc].cnt[1];
    }
    if ( nbuf < BUFSZ ) { break; }
    prev0 = M[nbuf-1].cnt[0];
    prev1 = M[nbuf-1].cnt[1];
  }
  *ptr_yval = best_yval;
  *ptr_yidx = best_yidx;
  *ptr_metric  = best_metric;
BYE:
  return status;
}
