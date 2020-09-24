#include "constants.h"
#include "ispc_types.h"

export void 
eval_metrics(
    uniform double M[BUFSZ],
    uniform uint32 M_nT[BUFSZ],
    uniform uint32 M_nH[BUFSZ],
    uniform double nT,
    uniform double nH,
    uniform uint32 nbuf,
    uniform double metrics[]
    )
{
  int status = 0;
  foreach ( i = 0 ... nbuf ) {
    metrics[i] = M_nH[i] / nH  + M_nT[i] / nT;
  }
}
