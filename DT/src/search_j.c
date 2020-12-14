#include "incs.h"
#include "accumulate.h"
#ifdef SCALAR
#include "calc_best_metric.h"
#include "eval_metrics.h"
#endif
#ifdef VECTOR
#include "calc_best_metric_isp.h"
#include "eval_metrics_isp.h"
#endif
#include "search_j.h"

extern metrics_t *g_M;  // [m][g_M_bufsz] 
extern uint32_t g_M_bufsz;

int 
search_j(
    uint64_t *Yj, /* [m][n] */
    uint32_t j,
    uint32_t lb, // 0 <= lb < n */
    uint32_t ub, // lb < ub < n */
    uint32_t m,
    uint32_t n,
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
  four_nums_t best_num4; memset(&best_num4, 0, sizeof(four_nums_t));

  if ( j >= m ) { go_BYE(-1); }
  metrics_t M = g_M[j];

  memset(M.yval,   0, (g_M_bufsz * sizeof(uint32_t)));
  memset(M.yidx,   0, (g_M_bufsz * sizeof(uint32_t)));
  memset(M.nT,     0, (g_M_bufsz * sizeof(uint32_t)));
  memset(M.nH,     0, (g_M_bufsz * sizeof(uint32_t)));
  memset(M.metric, 0, (g_M_bufsz * sizeof(double)));
  //-------------------------------------
  if ( lb >= ub ) { go_BYE(-1); }
  if ( ub >  n ) { go_BYE(-1); }
  uint32_t original_lb = lb;
  uint32_t new_lb = lb;
  uint32_t prev_nT = 0, prev_nH = 0;
  // This loop is written somewhat unusually, let's explain
  // This is because every feature value is not a candidate split
  // As we scan along feature values, we place a candidate split
  // if the following conditions are satisifed
  // (1) doing so does NOT make the left or right too small 
  // (2) the value of the feature is different from the previous
  // for e.g., if the feature values were 
  // 1, 2, 2, 3, 3, 3, 4, 4, 4, 4 at positions
  // 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
  // then the candidate split points are indicated by Y 
  // _, _, Y, Y, _, _, Y, _, _, _
  // We accumulate up to g_M_bufsz candidates, then evaluate all at once
  // keep the best seen and then continue to create more candidates
  // TODO: See bottom of file 
  for ( ; ; ) { 
    if ( new_lb >= ub ) { break; }
    status = accumulate(Yj, lb, ub, prev_nT, prev_nH, &M, &nbuf, &new_lb); 
    cBYE(status);
    lb = new_lb;
    if ( nbuf == 0 ) { break; }
#ifdef DEBUG
    if ( nbuf >= g_M_bufsz ) { go_BYE(-1); } 
    for ( uint32_t i = 0; i < nbuf; i++ ) { 
      if ( (M.yidx[i]+1-original_lb) != (M.nT[i] + M.nH[i])  ) { 
        go_BYE(-1); 
      }
    }
#endif
    uint32_t loc = 0;

#ifdef VECTOR
    eval_metrics_isp(M.nT, M.nH, nT, nH, M.metric, nbuf); 
    calc_best_metric_isp(M.metric, nbuf, &loc); cBYE(status);
#endif
#ifdef SCALAR
    status = eval_metrics(M.nT, M.nH, nT, nH, M.metric, nbuf); cBYE(status);
    status = calc_best_metric(&M, nbuf, &loc); cBYE(status);
#endif
#ifdef DEBUG
    for ( uint32_t i = 0; i < nbuf; i++ ) { 
      if ( M.metric[i] < 0 ) { 
        if ( M.metric[i] != -1 ) { // known bad value
          go_BYE(-1); 
        }
      }
    }
    if ( ( best_metric != -1 ) && ( best_yval == 0 ) ) { 
      go_BYE(-1); 
    }
#endif
    if ( M.metric[loc] > best_metric ) { 
      best_metric = M.metric[loc];
      best_yval   = M.yval[loc];
      best_yidx   = M.yidx[loc];
      best_num4.n_T_L = M.nT[loc];
      best_num4.n_H_L = M.nH[loc];
      best_num4.n_T_R = nT - best_num4.n_T_L;
      best_num4.n_H_R = nH - best_num4.n_H_L;
    }
    if ( nbuf < g_M_bufsz ) { break; }
    prev_nT = M.nT[nbuf-1];
    prev_nH = M.nH[nbuf-1];
  }
  *ptr_yval   = best_yval;
  *ptr_yidx   = best_yidx;
  *ptr_metric = best_metric;
  *ptr_num4   = best_num4;
BYE:
  return status;
}

// A further optimization is to NOT consider candidates if we can 
// tell that an existing candidate would be better 
// (without actually evaluating the metric).
// Need to think if this is possible.
