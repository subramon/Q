#include "constants.h"
#include "types.h"
export void
calc_best_metric(
    uniform metrics_t *M,
    uniform uint32_t nbuf,
    uniform uint32_t loc[]
    )
{
  int status = 0;
  uint32_t xloc = 0;
  double best_metric = M->metric[0];
  for ( uint32_t i = 1; i < nbuf; i++ ) { 
    if ( M->metric[i] > best_metric ) {
      xloc = i;
      best_metric = M->metric[i];
    }
  }
  loc[0] = xloc; 
}
