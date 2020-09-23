#include "constants.h"
#include "ispc_types.h"

export void 
eval_metrics(
    uniform metrics_t M[BUFSZ],
    uniform int32 nbuf,
    uniform double metrics[]
    )
{
  int status = 0;
  foreach ( i = 0 ... nbuf ) {
    metrics[i] = M[i].cnt[0] + M[i].cnt[1];
  }
}
