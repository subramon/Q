#include "constants.h"
export void
calc_best_metric_ispc(
    uniform double metrics[],
    uniform uint32 nbuf,
    uniform uint32 loc[]
    )
{
  int status = 0;
  uniform double best_metric = -1; 
  uniform uint32 best_loc;
  uint32 xloc = 0;
  double metric = -1;
  foreach ( i = 0 ... nbuf ) {
    if ( metrics[i] > metric ) {
      xloc = i;
      metric = metrics[i];
    }
  }
  best_metric = reduce_max(metric);
  if ( best_metric == metric ) { 
    best_loc = reduce_max(xloc);
  }
  loc[0] = best_loc; 
}
