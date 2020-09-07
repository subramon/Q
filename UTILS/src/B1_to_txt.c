//START_INCLUDES
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "q_macros.h"
//STOP_INCLUDES
#include "B1_to_txt.h"
//START_FUNC_DECL
int
B1_to_txt(
    bool val,
    char * X,
    size_t nX
    )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( X == NULL ) { go_BYE(-1); }
  if ( nX < 5 ) { go_BYE(-1); }
  memset(X, '\0', nX);
  if ( val ) { 
    strncpy(X, "true", nX);
  }
  else {
    strncpy(X, "false", nX);
  }
BYE:
  return status;
}
