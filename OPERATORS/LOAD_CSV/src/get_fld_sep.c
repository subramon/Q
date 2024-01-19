#include <stdio.h>
#include <string.h>
#include "q_macros.h"
#include "get_fld_sep.h"

int
get_fld_sep(
    const char * const str_fld_sep,
    char *ptr_fld_sep
    )
{
  int status = 0;
  if ( str_fld_sep == NULL ) { go_BYE(-1); }
  if ( strcasecmp(str_fld_sep, "comma") == 0 ) { 
    *ptr_fld_sep = ',';
  }
  else if ( strcasecmp(str_fld_sep, "tab") == 0 ) { 
    *ptr_fld_sep = '\t';
  }
  else {
    go_BYE(-1); 
  }
BYE:
  return status;
}
