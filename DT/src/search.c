#include "incs.h"
#include "preproc_j.h"
#include "check.h"
#include "search_j.h"
#include "search.h"
int 
search(
    uint64_t **Y, /* [m][lb..ub-1] */
    uint32_t lb,
    uint32_t ub,
    uint32_t nT,
    uint32_t nH,
    uint32_t m,
    uint32_t *ptr_split_feature_idx,
    uint32_t *ptr_split_feature_yval,
    uint32_t *ptr_split_yidx,
    four_nums_t *ptr_num4
   )
{
  int status = 0;
  double metrics[NUM_FEATURES];
  uint32_t yval[NUM_FEATURES];
  uint32_t yidx[NUM_FEATURES];
  four_nums_t num4[NUM_FEATURES];
// TODO #pragma omp parallel for
  for ( uint32_t j = 0; j < m; j++ ) { 
    int x; // used because we cannot break out of omp loop
    x = search_j(Y[j], lb, ub, nT, nH, 
        &(num4[j]), &(yval[j]), &(yidx[j]), &(metrics[j])); 
    if ( x < 0 ) { status = x; }
  }
  // start by assuming 0 is the best feature 
  uint32_t best_feature_idx = 0;   // identifies feature
  double best_metric         = metrics[0];  // metric for that feature
  uint32_t best_feature_yval = yval[0]; // split val for that feature
  uint32_t best_split_yidx   = yidx[0];   // split idx for that feature
  memcpy(ptr_num4, &(num4[0]), sizeof(four_nums_t));
  // now compare with other features
  for ( uint32_t j = 1; j < m; j++ ) { 
    if ( metrics[j] > best_metric ) { 
      best_feature_idx  = j;  
      best_metric        = metrics[j]; 
      best_feature_yval  = yval[j];;  
      best_split_yidx    = yidx[j];  
      memcpy(ptr_num4, &(num4[j]), sizeof(four_nums_t));
    }
  }
  if ( best_feature_idx >= m ) { go_BYE(-1); } 
  if ( best_split_yidx >= ub ) { go_BYE(-1); } 
  if ( best_split_yidx <  lb ) { go_BYE(-1); } 

  *ptr_split_feature_idx = best_feature_idx;
  *ptr_split_feature_yval = best_feature_yval;
  *ptr_split_yidx = best_split_yidx + 1;
  // Above +1 is important. Because we calculate as inclusive
  // but when we use as an upper bound it is exclusive

BYE:
  return status;
}
