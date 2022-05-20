#include "q_incs.h"
#include "hmap_custom_types.h"
#include "key_hash.h"

int
key_hash(
    const hmap_key_t * const ptr_key,
    char **ptr_str_to_hash,
    uint16_t *ptr_len_to_hash,
    bool *ptr_free_to_hash
    )
{
  int status = 0;
  if ( ptr_key == NULL ) { go_BYE(-1); }
  *ptr_str_to_hash = ptr_key->str_val;
  *ptr_len_to_hash = ptr_key->str_len;
  *ptr_free_to_hash = false;
BYE:
  return status;
}
