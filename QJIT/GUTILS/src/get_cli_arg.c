#include "q_incs.h"
#include "q_macros.h"
#include "get_cli_arg.h"
// Assume that command line arguments are passed something like this
// <executable> <key1> <val1> <key2> <val2> .....
// Given a key, call it K, we want to know the value corresponding to it 
// We return null (i.e., *ptr_val = NULL) if 
// \not \exists i: argv[i] == k AND (i > 0) AND (i < argc-1)
// We also assume that key cannot occur twice
// i \neq j \Rightarrow argv[i] \neq argv[j]
//START_FUNC_DECL
int 
get_cli_arg(
    int argc,
    const char ** const argv,
    const char * const key,
    char **ptr_val,
    int *ptr_where_found
    )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( argc <= 0 ) { go_BYE(-1); }
  if ( argv == NULL ) { go_BYE(-1); }
  if ( ( key == NULL ) || ( *key == '\0' ) ) { go_BYE(-1); }

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
  }
  *ptr_where_found = arg_where_found;
BYE:
  return status;
}
