#include "q_incs.h"
//STOP_INCLUDES
#include "_munmap.h"
//START_FUNC_DECL
int
rs_munmap(
	char *X,
	size_t nX
	)
//STOP_FUNC_DECL
{ 
  int status = 0;

  if ( ( X == NULL ) && ( nX != 0 ) ) { go_BYE(-1); }
  if ( ( X != NULL ) && ( nX == 0 ) )  { go_BYE(-1); }
  if ( X != NULL ) {
    status = munmap(X, nX); if ( status != 0 ) { go_BYE(-1); }
  }
  X = NULL; nX = 0;

BYE:
  return status;
}
