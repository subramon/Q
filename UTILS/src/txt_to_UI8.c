#include "txt_to_UI8.h"

//START_FUNC_DECL
int
txt_to_UI8(
      const char * const X,
      uint64_t *ptr_out
      )
//STOP_FUNC_DECL
{
  int status = 0;
  char *endptr = NULL;
  // not thread safe. TODO P3 errno = 0;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  unsigned long long int out = strtoull(X, &endptr, 10);
  if ( ( endptr != NULL ) && ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  // not thread safe TODO P3
  // if ( ( errno == ERANGE ) || ( errno == EINVAL ) ) { go_BYE(-1); } 
  if (endptr == X) { go_BYE(-1); } 

  *ptr_out = (uint64_t)out;
BYE:
  if ( status < 0 ) { 
    fprintf(stderr, "Could not convert [%s] to UI8\n", X);
  }
  return status ;
}
