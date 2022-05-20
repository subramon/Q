#include "q_incs.h"
#include "hmap_custom_types.h"
#include "key_len.h"

uint16_t
key_len(
    const hmap_key_t * const ptr_key
    )
{
  return ptr_key->str_len;
}
