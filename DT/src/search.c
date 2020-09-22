#include "incs.h"
#include "preproc_j.h"
#include "check.h"
#include "search.h"

int 
search_j(
    uint32_t lb,
    uint32_t ub,
    uint64_t *Yj, /* [m][n] */
    uint32_t *ptr_yval,
    uint32_t *ptr_yidx,
    double *ptr_metric
   )
{
  int status = 0;
BYE:
  return status;
}
int 
search(
    uint32_t lb,
    uint32_t ub,
    uint32_t m,
    uint64_t **Y, /* [m][n] */
    uint32_t *ptr_split_feature_idx
    uint32_t *ptr_yval,
    uint32_t *ptr_yidx
   )
{
  int status = 0;
  double metrics[NUM_FEATURES];
  double best_metric; int best_k = 0;
#pragma omp parallel for
  for ( uint32_t j = 0; j < m; j++ ) { 
    int l_status = search(lb, ub, Y[j], &yval, &yidx, &(metrics[i])); 
    if ( l_status < 0 ) { status = l_status; }
  }

BYE:
  return status;
}
