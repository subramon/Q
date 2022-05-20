#include "q_incs.h"
#include "q_macros.h"
#include "hmap_custom_types.h"
#include "val_free.h"

int
val_free(
    hmap_val_t *ptr_val
    )
{
  int status = 0;
  if ( ptr_val == NULL ) { return status; }
  // num_frees++; 
  free_if_non_null(ptr_val);
BYE:
  return status;
}
