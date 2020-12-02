// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "val_free.h"
int
val_free(
    val_t *ptr_val
    )
{
  int status = 0;
  if ( ptr_val == NULL ) { go_BYE(-1); }
  free_if_non_null(ptr_val->strval);
BYE:
  return status;
}
