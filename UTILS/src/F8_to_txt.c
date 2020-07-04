#include "_F8_to_txt.h"

//START_FUNC_DECL
int
F8_to_txt(
//    const double * const in,
    double * in,
    const char * const fmt,
    char *X,
    size_t nX
    )
//STOP_FUNC_DECL
{
  int status = 0; size_t nw;
  if ( X == NULL ) { go_BYE(-1); }
  if ( nX < 8 ) { go_BYE(-1); }
  memset(X, '\0', nX);
  if ( ( fmt == NULL ) || ( *fmt == '\0' ) ) { 
    nw = snprintf(X, nX-1, "%" PRF8, *in);
  }
  else {
    nw = snprintf(X, nX-1, fmt, *in);
  }
  if ( nw >= nX ) { go_BYE(-1); }
BYE:
  return status ;
}
  
