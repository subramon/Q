#include <stdio.h>
#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "nn_pr_fld_I2.h"

int
nn_pr_fld_I2(
    const char *in_X,
    PR_FLD_ARGS_TYPE pr_info,
    FILE *ofp
    )

{
  int status = 0;
  uint64_t lb = pr_info.lb;
  uint64_t ub = pr_info.ub;
  const char *nn_X = pr_info.nn_X;
  const char *cfld_X = pr_info.cfld_X;

  uint16_t *X = (uint16_t *)in_X;
  uint16_t val;
  for ( uint64_t i = lb; i < ub; i++ ) { 
    if ( ( cfld_X != NULL ) && ( cfld_X[i] == 0 ) ) {
      continue;
    }
    if ( ( nn_X != NULL ) && ( nn_X[i] == 0 ) ) {
      fprintf(ofp, "\"\"\n");
      continue;
    }
    val = X[i];
    if ( nn_X == NULL ) { 
      fprintf(ofp, "%d\n", val);
    }
    else {
      fprintf(ofp, "\"%d\"\n", val);
    }
  }
  return status;
}
