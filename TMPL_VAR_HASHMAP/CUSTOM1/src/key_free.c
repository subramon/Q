#include "q_incs.h"
#include "q_macros.h"
#include "hmap_custom_types.h"
#include "key_free.h"

int
key_free(
    hmap_key_t *ptr_key
    )
{
  int status = 0;
  if ( ptr_key == NULL ) { return status; }
  // num_frees++; 
  free_if_non_null(ptr_key->str_val);
  free_if_non_null(ptr_key);
BYE:
  return status;
}
