#include "q_incs.h"
#include "rs_mmap.h"
#include "file_as_str.h"
char *
file_as_str(
    const char * const infile
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0;
  char * Y = NULL;
  if ( infile == NULL ) { go_BYE(-1); }
  status = rs_mmap(infile, &X, &nX, 0); cBYE(status);
  Y = malloc(nX+1);
  return_if_malloc_failed(Y);
  memcpy(Y, X, nX);
  Y[nX] = '\0';
BYE:
  if ( X != NULL ) { munmap(X, nX); } 
  if ( status < 0 ) { WHEREAMI; return NULL; } else { return Y; }
}
