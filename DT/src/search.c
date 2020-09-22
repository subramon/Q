#include "incs.h"
#include "preproc_j.h"
#include "check.h"
#include "search_j.h"
#include "search.h"
int 
search(
    uint32_t lb,
    uint32_t ub,
    uint32_t m,
    uint64_t **Y, /* [m][n] */
    uint32_t *ptr_split_feature_idx,
    uint32_t *ptr_yval,
    uint32_t *ptr_yidx
   )
{
  int status = 0;
  double metrics[NUM_FEATURES];
  uint32_t yval[NUM_FEATURES];
  uint32_t yidx[NUM_FEATURES];
#pragma omp parallel for
  for ( uint32_t j = 0; j < m; j++ ) { 
    int x;
    x = search_j(lb, ub, Y[j], &(yval[j]), &(yidx[j]), &(metrics[j])); 
    if ( x < 0 ) { status = x; }
  }
  uint32_t best_feature = 0;  
  double best_metric = metrics[0]; 
  uint32_t best_feature_yval = yval[0];;  
  uint32_t best_feature_idx  = yidx[0];  
  for ( uint32_t j = 0; j < m; j++ ) { 
    if ( metrics[j] > best_metric ) { 
      best_feature = j;  
      best_metric = metrics[j]; 
      best_feature_yval = yval[j];;  
      best_feature_idx  = yidx[j];  
    }
  }
  *ptr_split_feature_idx = best_feature;
  *ptr_yval = best_feature_yval;
  *ptr_yidx = best_feature_idx;

BYE:
  return status;
}
