//START_INCLUDES
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
//STOP_INCLUDES
#include "is_valid_chars_for_num.h"
//START_FUNC_DECL
bool
is_valid_chars_for_num(
      const char * X
      )
//STOP_FUNC_DECL
{
  static bool is_valid_char[256];
  static bool init = false;
  if ( !init ) {
    init = true;
    for ( char c = '0'; c <= '9'; c++ ) { is_valid_char[(uint8_t)c] = true; }
    for ( char c = 'A'; c <= 'F'; c++ ) { is_valid_char[(uint8_t)c] = true; }
    is_valid_char['.'] = true;
    is_valid_char['+'] = true;
    is_valid_char['-'] = true;
    is_valid_char['X'] = true; // allow hex 
    is_valid_char['e'] = true; // allow scientific notation
    is_valid_char['E'] = true; // allow scientific notation
  }
  if ( ( X == NULL ) || ( *X == '\0' ) ) { WHEREAMI; return false; }
  for ( char *cptr = (char *)X; *cptr != '\0'; cptr++ ) { 
    if ( !is_valid_char[(uint8_t)*cptr] ) { 
      fprintf(stderr, "Invalid char [%c] in string [%s] \n", *cptr, X);
      return false;
    }
  }
  return true;
}
