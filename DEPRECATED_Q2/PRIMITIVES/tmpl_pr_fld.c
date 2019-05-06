#include <stdio.h>
#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "pr_fld___XTYPE__.h"
//<hdr>
int
pr_fld___XTYPE__(
    const char *in_X,
    PR_FLD_ARGS_TYPE pr_info,
    FILE *ofp
    )
//</hdr>
{
  int status = 0;
  uint64_t lb = pr_info.lb;
  uint64_t ub = pr_info.ub;
  const char *cfld_X = pr_info.cfld_X;

  __TYPE__ *X = (__TYPE__ *)in_X;
  __TYPE__ val;
  for ( uint64_t i = lb; i < ub; i++ ) { 
    if ( ( cfld_X != NULL ) && ( cfld_X[i] == 0 ) ) {
      continue;
    }
    val = X[i];
    fprintf(ofp, "__FORMAT__\n", val);
  }
  return status;
}
