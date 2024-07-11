#include "q_incs.h"
#include "q_macros.h"
#include "get_cli_arg.h"
// Checks the array of strings (argv) for 2 consecutive elements
// the first of which matches <key> 
// <key> can occur 0 or 1 times in argv, not more 
// <key> cannot be the last element of argv
int 
get_cli_arg(
    int argc,
    const char ** const argv,
    const char * const key,
    char **ptr_val,
    int *ptr_where_found
    )
{
  int status = 0;
  if ( argc <= 0 ) { go_BYE(-1); }
  if ( argv == NULL ) { go_BYE(-1); }
  if ( ( key == NULL ) || ( *key == '\0' ) ) { go_BYE(-1); }
  *ptr_where_found = -1;

  if ( strcmp(argv[argc-1], key ) == 0 ) {  go_BYE(-1); }
  bool arg_found = false;  int arg_where_found = -1;
  for ( int i = 0; i < argc; i++ ) { 
    if ( argv[i] == NULL ) { go_BYE(-1); } 
    if ( strcmp(argv[i], key) == 0 ) {
      if ( arg_found ) { go_BYE(-1); } // cannot have it twice
      arg_found = true;
      arg_where_found = i;
    }
  }
  if ( arg_found ) { 
    *ptr_val = strdup(argv[arg_where_found+1]); 
    *ptr_where_found = arg_where_found;
  }
BYE:
  return status;
}
