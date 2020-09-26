#include "incs.h"
#include "accumulate.h"
#ifdef SCALAR
#include "calc_best_metric.h"
#include "eval_metrics.h"
#endif
#ifdef VECTOR
#include "calc_best_metric.isp.h"
#include "eval_metrics.isp.h"
#endif
#include "search_j.h"

extern metrics_t *g_M;  // [g_M_m][g_M_bufsz] 
extern uint32_t g_M_m;
extern uint32_t g_M_bufsz;

int 
search_j(
    uint64_t *Yj, /* [m][n] */
    uint32_t j,
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
  //----------------------------------------
  double   best_metric = -1; 
  uint32_t best_yval = 0; // this is an invalid value 
  uint32_t best_yidx = 0; 

  if ( j >= g_M_m ) { go_BYE(-1); }
  metrics_t M = g_M[j];

  memset(M.yval,   0, (g_M_bufsz * sizeof(uint32_t)));
  memset(M.yidx,   0, (g_M_bufsz * sizeof(uint32_t)));
  memset(M.nT,     0, (g_M_bufsz * sizeof(uint32_t)));
  memset(M.nH,     0, (g_M_bufsz * sizeof(uint32_t)));
  memset(M.metric, 0, (g_M_bufsz * sizeof(double)));
  //-------------------------------------
  uint32_t original_lb = lb;
  uint32_t new_lb = lb;
  uint32_t prev_nT = 0, prev_nH = 0;
  for ( ; ; ) { 
    if ( new_lb >= ub ) { break; }
    status = accumulate(Yj, lb, ub, prev_nT, prev_nH, &M, &nbuf, &new_lb); 
    cBYE(status);
    lb = new_lb;
    if ( nbuf == 0 ) { break; }
#ifdef DEBUG
    for ( uint32_t i = 0; i < nbuf; i++ ) { 
      if ( (M.yidx[i]+1-original_lb) != (M.nT[i] + M.nH[i])  ) { 
        go_BYE(-1); 
      }
    }
#endif
    uint32_t loc = 0;

#ifdef VECTOR
    eval_metrics(M.nT, M.nH, nT, nH, M.metric, nbuf); 
    calc_best_metric(M.metric, nbuf, &loc); cBYE(status);
#endif
#ifdef SCALAR
    status = eval_metrics(M.nT, M.nH, nT, nH, M.metric, nbuf); cBYE(status);
    status = calc_best_metric(&M, nbuf, &loc); cBYE(status);
#endif
#ifdef DEBUG
    for ( uint32_t i = 0; i < nbuf; i++ ) { 
      if ( M.metric[i] < 0 ) { go_BYE(-1); }
    }
#endif
    if ( M.metric[loc] > best_metric ) { 
      best_metric = M.metric[loc];
      best_yval   = M.yval[loc];
      best_yidx   = M.yidx[loc];
      ptr_num4->n_T_L = M.nT[loc];
      ptr_num4->n_H_L = M.nH[loc];
      ptr_num4->n_T_R = nT - ptr_num4->n_T_L;
      ptr_num4->n_H_R = nH - ptr_num4->n_H_L;
    }
    if ( best_yval == 0 ) { 
      go_BYE(-1); 
    }
    if ( nbuf < g_M_bufsz ) { break; }
    prev_nT = M.nT[nbuf-1];
    prev_nH = M.nH[nbuf-1];
  }
  *ptr_yval = best_yval;
  *ptr_yidx = best_yidx;
  *ptr_metric  = best_metric;
BYE:
  return status;
}
