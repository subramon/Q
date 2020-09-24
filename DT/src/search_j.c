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
  uint32_t nbuf; // number  of elements in M after a call to accumulate
  //---------------------------
  // had to discontinue this because of ispc: metrics_t M[BUFSZ];
  // replaced it with M_ variables
  uint32_t M_yval[BUFSZ]; 
  uint32_t M_yidx[BUFSZ]; 
  uint32_t M_nT[BUFSZ]; 
  uint32_t M_nH[BUFSZ]; 
  double M_metric[BUFSZ]; 
  //----------------------------------------
  double   best_metric = -1; 
  uint32_t best_yval; 
  uint32_t best_yidx; 

  memset(&M_yval,   0, (BUFSZ * sizeof(uint32_t)));
  memset(&M_yidx,   0, (BUFSZ * sizeof(uint32_t)));
  memset(&M_nT,     0, (BUFSZ * sizeof(uint32_t)));
  memset(&M_nH,     0, (BUFSZ * sizeof(uint32_t)));
  memset(&M_metric, 0, (BUFSZ * sizeof(double)));
  //-------------------------------------
  uint32_t original_lb = lb;
  uint32_t new_lb = lb;
  uint32_t prev_nT = 0, prev_nH = 0;
  for ( ; ; ) { 
    if ( new_lb >= ub ) { break; }
    status = accumulate(Yj, lb, ub, prev_nT, prev_nH, 
        M_yval, M_yidx, M_nT, M_nH, &nbuf, &new_lb); 
    cBYE(status);
    lb = new_lb;
    if ( nbuf == 0 ) { break; }
#ifdef DEBUG
    for ( uint32_t i = 0; i < nbuf; i++ ) { 
      if ( (M_yidx[i]+1-original_lb) != (M_nT[i] + M_nH[i])  ) { 
        go_BYE(-1); 
      }
    }
#endif
    // start ispc 
    status = eval_metrics(M_metric, nbuf); cBYE(status);
    uint32_t loc = 0;
    status = calc_best_metric(M_metric, nbuf, &loc); cBYE(status);
    // stop  ispc 
    if ( M_metric[loc] > best_metric ) { 
      best_metric = M_metric[loc];
      best_yval   = M_yval[loc];
      best_yidx   = M_yidx[loc];
      ptr_num4->n_T_L = M_nT[loc];
      ptr_num4->n_H_L = M_nH[loc];
      ptr_num4->n_T_R = nT - ptr_num4->n_T_L;
      ptr_num4->n_H_R = nH - ptr_num4->n_H_L;
    }
    if ( nbuf < BUFSZ ) { break; }
    prev_nT = M_nT[nbuf-1];
    prev_nH = M_nH[nbuf-1];
  }
  *ptr_yval = best_yval;
  *ptr_yidx = best_yidx;
  *ptr_metric  = best_metric;
BYE:
  return status;
}
