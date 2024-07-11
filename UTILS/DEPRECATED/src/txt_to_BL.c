#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "q_macros.h"
#include "txt_to_BL.h"
//START_FUNC_DECL
int
txt_to_BL(
      const char * const X,
      bool *ptr_val
      )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  if ( ( strcmp(X, "true") == 0 ) || ( strcmp(X, "1") == 0 ) ) { 
    *ptr_val = true;
  }
  else if ( ( strcmp(X, "false") == 0 ) || ( strcmp(X, "0") == 0 ) ) { 
    *ptr_val = false;
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
