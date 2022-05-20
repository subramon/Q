#include "q_incs.h"
#include "hmap_custom_types.h"
#include "key_copy.h"

hmap_key_t *
key_copy(
    const hmap_key_t * const kin
    )
{
  hmap_key_t * kout = malloc(sizeof(hmap_key_t));
  kout->str_val = strdup(kin->str_val);
  kout->str_len = kin->str_len;
  return kout;
}
