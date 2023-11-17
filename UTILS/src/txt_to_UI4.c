#include "txt_to_UI4.h"

//START_FUNC_DECL
int
txt_to_UI4(
      const char * const X,
      uint32_t *ptr_out
      )
//STOP_FUNC_DECL
{
  int status = 0;
  char *endptr = NULL;
  errno = 0;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  if ( !is_valid_chars_for_num(X) ) { 
  fprintf(stderr, "Invalid number [%s]\n", X); go_BYE(-1); }
  unsigned long long int out = strtoull(X, &endptr, 10);
  if ( ( endptr != NULL ) && ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  if ( out > UINT_MAX ) { go_BYE(-1); }
  if ( ( errno == ERANGE ) || ( errno == EINVAL ) ) { go_BYE(-1); } 

  if (endptr == X) { go_BYE(-1); } 

  *ptr_out = (uint32_t)out;
BYE:
  if ( status < 0 ) { 
    fprintf(stderr, "Could not convert [%s] to UI4\n", X);
  }
  return status ;
}
