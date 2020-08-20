//START_INCLUDES
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
//STOP_INCLUDES
#include "SC_to_txt.h"
//START_FUNC_DECL
int
SC_to_txt(
    char * const in,
    char * X,
    size_t nX
    )
//STOP_FUNC_DECL
{
  int status = 0;
  size_t sz = 0;
  memset(X, '\0', nX);
  if ( in == NULL ) { go_BYE(-1); }
  for ( char *cptr = in; *cptr != '\0'; cptr++ ) { 
    if ( ( *cptr == '"' ) || 
        ( *cptr == ',' ) || 
        ( *cptr == '\n' ) || 
        ( *cptr == '\\' ) ) {
      if ( sz >= nX-1 ) { go_BYE(-1); } X[sz++] = '\\';
    }
    if ( sz >= nX-1 ) { go_BYE(-1); } X[sz++] = *cptr;
  }
BYE:
  return status ;
}
