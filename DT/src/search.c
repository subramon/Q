#include "incs.h"
#include "preproc_j.h"
#include "check.h"
#include "search_j.h"
#include "search.h"
extern config_t g_C;
extern double      *g_best_metrics;
extern uint32_t    *g_best_yvals;
extern uint32_t    *g_best_yidxs;
extern four_nums_t *g_best_num4s;
extern bool        *g_is_splittables;

int 
search(
    uint64_t ** restrict Y, /* [m][lb..ub-1] */
    uint32_t lb,
    uint32_t ub,
    uint32_t nT,
    uint32_t nH,
    uint32_t m,
    uint32_t n,
    uint32_t *ptr_feature_for_split, // output 
    uint32_t *ptr_yval_for_split, // output 
    uint32_t *ptr_yidx_for_split, // output 
    four_nums_t *ptr_num4_for_split, // output 
    bool *ptr_is_splittable // output, tells us whether above 4 are defined
   )
{
  int status = 0;
  double *metrics     = g_best_metrics;
  uint32_t *yval      = g_best_yvals;
  uint32_t *yidx      = g_best_yidxs;
  four_nums_t *num4   = g_best_num4s;
  bool *is_splittable = g_is_splittables;
  int nP              = g_C.num_cores;
#ifdef SEQUENTIAL 
  nP = 1;
#endif
  // set some invalid value for the outputs
  double      best_metric = -1;
  uint32_t    best_feature = -1;
  uint32_t    best_yval = 0;
  uint32_t    best_yidx = ~0;
  four_nums_t best_num4; memset(&best_num4, 0, sizeof(four_nums_t));
#pragma omp parallel for schedule(dynamic, 1) num_threads(nP)
  for ( uint32_t j = 0; j < m; j++ ) { // search each feature
    int lstatus; // used because we cannot break out of omp loop
    lstatus = search_j(Y[j], j, lb, ub, m, n, nT, nH, &(num4[j]), 
        &(yval[j]), &(yidx[j]), &(metrics[j]), &(is_splittable[j]));
    if ( lstatus < 0 ) { status = lstatus; }
  }
  cBYE(status);
  // At this point, you have found best split for *each* feature
  // Find best split over all features 
  // starting assumption is that none of the features have a valid split
  *ptr_is_splittable = false; 
  // iterate over all features
  for ( uint32_t j = 0; j < m; j++ ) { 
    if ( !is_splittable[j] ) { continue; }
    if ( ( *ptr_is_splittable == false ) || // allows first one through
         ( metrics[j] > best_metric ) ) {
      best_feature  = j;  
      best_metric   = metrics[j]; 
      best_yval     = yval[j];;  
      best_yidx     = yidx[j];  
      memcpy(&best_num4, &(num4[j]), sizeof(four_nums_t));
      *ptr_is_splittable = true;
    }
  }
  //-----------------------------------------------
  if ( g_C.is_debug ) { 
    if ( best_feature >= m ) { go_BYE(-1); } 
    if ( best_yidx >= ub ) { go_BYE(-1); } 
    if ( best_yidx <  lb ) { go_BYE(-1); } 
  }

  // Note that the following are meaingful *ONLY* if
  // *ptr_is_splittable = true
  *ptr_feature_for_split = best_feature;
  *ptr_yval_for_split    = best_yval;
  *ptr_num4_for_split    = best_num4;
  *ptr_yidx_for_split    = best_yidx + 1;
  // Above +1 is important. Because we calculate as inclusive
  // but when we use as an upper bound it is exclusive
BYE:
  return status;
}
