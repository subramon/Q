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

extern uint32_t g_num_gini_calc;
extern config_t g_C;
extern metrics_t *g_M;  // [m][g_M_bufsz] 
extern uint32_t g_M_bufsz;

int 
search_j(
    uint64_t * restrict Yj, /* [m][n] */
    uint32_t j,
    uint32_t lb, // 0 <= lb < n */
    uint32_t ub, // lb < ub < n */
    uint32_t m,
    uint32_t n,
    uint32_t nT,
    uint32_t nH,
    four_nums_t *ptr_num4, // output
    uint32_t *ptr_yval, // output: split value for this feature 
    uint32_t *ptr_yidx, // output: split idx for this feature 
    double *ptr_metric, // output: metric for this split of this feature 
    // whether this interval for this feature can be split at all 
    bool *ptr_is_splittable
   )
{
  int status = 0;
  uint32_t nbuf; // number  of elements in M after a call to accumulate
  //---------------------------
  // had to discontinue this because of ispc: metrics_t M[BUFSZ];
  //----------------------------------------
  // Initialize to "bad" values where possible
  double   best_metric = -1; 
  uint32_t best_yval = 0; 
  uint32_t best_yidx = 0; 
  four_nums_t best_num4; memset(&best_num4, 0, sizeof(four_nums_t));
  // If we have too little to work with, return early
  if ( (ub-lb) <= g_C.min_leaf_size ) { 
    *ptr_is_splittable = false; return status; 
  }
  // If all values are the same, return early
  if ( Yj[lb] == Yj[ub-1] ) { 
    *ptr_is_splittable = false; return status; 
  }

  if ( j >= m ) { go_BYE(-1); }
  metrics_t Mj = g_M[j];

  memset(Mj.yval,   0, (g_M_bufsz * sizeof(uint32_t)));
  memset(Mj.yidx,   0, (g_M_bufsz * sizeof(uint32_t)));
  memset(Mj.nT,     0, (g_M_bufsz * sizeof(uint32_t)));
  memset(Mj.nH,     0, (g_M_bufsz * sizeof(uint32_t)));
  memset(Mj.metric, 0, (g_M_bufsz * sizeof(double)));
  *ptr_is_splittable = true;
  //-------------------------------------
  if ( lb >= ub ) { go_BYE(-1); }
  if ( ub >  n ) { go_BYE(-1); }
#ifdef DEBUG
  uint32_t original_lb = lb;
#endif
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
  for ( int iter = 0; ; iter++ ) {
    if ( new_lb >= ub ) { break; }
    status = accumulate(Yj, lb, ub, prev_nT, prev_nH, &Mj, &nbuf, &new_lb); 
    cBYE(status);
    if ( nbuf == 0 ) { go_BYE(-1); } // TODO P2 Is this assertion valid?
    if ( nbuf == 0 ) { break; } // TODO Which is it? break or bye?
    if ( ( iter == 0 ) && ( nbuf <= 1 ) ) {
      // Means this interval is not splittable
      *ptr_is_splittable = false;
      break;
    }
#ifdef DEBUG
    if ( nbuf > g_M_bufsz ) { go_BYE(-1); } 
    for ( uint32_t i = 0; i < nbuf; i++ ) { 
      if ( (Mj.yidx[i]+1-original_lb) != (Mj.nT[i] + Mj.nH[i])  ) { 
        go_BYE(-1); 
      }
    }
#endif
    uint32_t loc = 0;
    __atomic_add_fetch (&g_num_gini_calc, nbuf, 0);
#ifdef VECTOR
    eval_metrics_isp(Mj.nT, Mj.nH, nT, nH, Mj.metric, nbuf); 
    calc_best_metric_isp(Mj.metric, nbuf, &loc); cBYE(status);
#endif
#ifdef SCALAR
    status = eval_metrics(Mj.nT, Mj.nH, nT, nH, Mj.metric, nbuf); cBYE(status);
    status = calc_best_metric(&Mj, nbuf, &loc); cBYE(status);
#endif
#ifdef DEBUG
    for ( uint32_t i = 0; i < nbuf; i++ ) { 
      if ( Mj.metric[i] < 0 ) { 
        if ( Mj.metric[i] != -1 ) { // known bad value
          go_BYE(-1); 
        }
      }
    }
    if ( ( best_metric != -1 ) && ( best_yval == 0 ) ) { 
      go_BYE(-1); 
    }
#endif
    if ( Mj.metric[loc] > best_metric ) { 
      best_metric = Mj.metric[loc];
      best_yval   = Mj.yval[loc];
      best_yidx   = Mj.yidx[loc];
      best_num4.n_T_L = Mj.nT[loc];
      best_num4.n_H_L = Mj.nH[loc];
      best_num4.n_T_R = nT - best_num4.n_T_L;
      best_num4.n_H_R = nH - best_num4.n_H_L;
    }
    // If you could not fill up buffer => no more data 
    if ( nbuf < g_M_bufsz ) { break; }
    // Set up for next iteration
    lb = new_lb;
    prev_nT = Mj.nT[nbuf-1];
    prev_nH = Mj.nH[nbuf-1];
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
