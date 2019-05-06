#include <stdio.h>
#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "pr_fld_F8.h"

int
pr_fld_F8(
    const char *in_X,
    PR_FLD_ARGS_TYPE pr_info,
    FILE *ofp
    )

{
  int status = 0;
  uint64_t lb = pr_info.lb;
  uint64_t ub = pr_info.ub;
  const char *cfld_X = pr_info.cfld_X;

  double *X = (double *)in_X;
  double val;
  for ( uint64_t i = lb; i < ub; i++ ) { 
    if ( ( cfld_X != NULL ) && ( cfld_X[i] == 0 ) ) {
      continue;
    }
    val = X[i];
    fprintf(ofp, "%lf\n", val);
  }
  return status;
}
