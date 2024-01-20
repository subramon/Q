#include "txt_to_F4.h"

//START_FUNC_DECL
int
txt_to_F4(
      const char * const X,
      float *ptr_out
      )
//STOP_FUNC_DECL
{
  int status = 0;
  static int n_bad_values = 0; 
  *ptr_out = 0;
  char *endptr;
  double out;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { status = -1; goto BYE; }
  out = strtold(X, &endptr);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { status = -1; goto BYE; }
  if ( endptr == X ) { status = -1; goto BYE; } 
  if ( ( out < - FLT_MAX ) || ( out > FLT_MAX ) ) { status = -1; goto BYE; }
  *ptr_out = (float)out;
BYE:
  if ( status < 0 ) {
    // TODO  printf("bad flt %8d: %s\n", ++n_bad_values, X); 
    *ptr_out = FLT_MAX;
    status = 0;
  }
  return status ;
}
