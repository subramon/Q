#include "constants.h"
#include "ispc_types.h"

export void 
eval_metrics(
    uniform metrics_t *M,
    uniform double nT,
    uniform double nH,
    uniform uint32 nbuf
    )
{
  int status = 0;
  foreach ( i = 0 ... nbuf ) {
    metrics[i] = M->nH[i] / nH  + M->nT[i] / nT;
  }
}
