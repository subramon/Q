#include <stdio.h>
#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "pr_fld_SC.h"
//<hdr>
int
pr_fld_SC(
    const char *X,
    PR_FLD_ARGS_TYPE pr_info,
    FILE *ofp
    )
//</hdr>
{
  int status = 0;
  uint64_t lb          = pr_info.lb;
  uint64_t ub          = pr_info.ub;
  const char *cfld_X = pr_info.cfld_X;
  const char *nn_X   = pr_info.nn_X;
  int fldlen         = pr_info.fldlen;

  if ( X == NULL    ) { go_BYE(-1); }
  if ( fldlen <=  1 ) { go_BYE(-1); }

  for ( uint64_t i = lb; i < ub; i++ ) { 
    if ( ( cfld_X != NULL ) && ( cfld_X[i] == 0 ) ) {
      continue;
    }
    if ( ( nn_X != NULL ) && ( nn_X[i] == 0 ) ) {
      fprintf(ofp, "\"\"\n");
      continue;
    }
    char *cptr = (char *)X; cptr += (i*(fldlen+1));
    fprintf(ofp, "\"");
    for ( int j = 0; *cptr != '\0' ; ) {
      if ( j >= fldlen ) { go_BYE(-1); }
      char c = *cptr;
      // Escape backslash and double-quote character
      if ( ( c == '\\' ) || ( c == '"' ) )  {
        fprintf(ofp, "\\");
      }
      fprintf(ofp, "%c", *cptr++);
    }
    fprintf(ofp, "\"");
    fprintf(ofp, "\n");
  }
BYE:
  return(status);
}
