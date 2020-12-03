// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "val_free.h"

// extern int num_frees;
int
val_free(
    void **ptr_val
    )
{
  int status = 0;
  if ( ptr_val == NULL ) { go_BYE(-1); }
  // if ( *ptr_val != NULL ) { num_frees++; } 
  free_if_non_null(*ptr_val);
  *ptr_val = NULL;
BYE:
  return status;
}
