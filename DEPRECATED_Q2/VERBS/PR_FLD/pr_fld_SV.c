#include <stdio.h>
#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "pr_fld_SV.h"
//<hdr>
int
pr_fld_SV(
    const char *X,
    PR_FLD_ARGS_TYPE pr_info,
    FILE *ofp
    )
//</hdr>
{
  int status = 0;
  uint64_t lb           = pr_info.lb;
  uint64_t ub           = pr_info.ub;
  const char *cfld_X  = pr_info.cfld_X;
  const char *nn_X    = pr_info.nn_X;
  const uint16_t *len   = pr_info.len_X;
  const uint64_t *off   = pr_info.off_X;

  for ( uint8_t i = lb; i < ub; i++ ) { 
    if ( ( cfld_X != NULL ) && ( cfld_X[i] == 0 ) ) {
      // skip over this entry 
      continue;
    }
    if ( ( nn_X != NULL ) && ( nn_X[i] == 0 ) ) {
      fprintf(ofp, "\"\"\n");
      continue;
    }
    fprintf(ofp, "\"");
    char *in_X = (char *)X; in_X += off[i]; char *cptr = in_X;
    for ( int j = 0; j < len[i]; j++, cptr++ ) { 
      char c = *cptr;
      if ( c == '\0' ) { go_BYE(-1); } // DEBUGGING 
      if ( ( c == '\\' ) || ( c == '"' ) ) { 
        fprintf(ofp, "\\");
      }
      fprintf(ofp, "%c", c);
    }
    fprintf(ofp, "\"");
    fprintf(ofp, "\n");
  }
BYE:
  return status;
}
