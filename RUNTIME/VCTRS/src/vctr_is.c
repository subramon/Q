#include "q_incs.h"
#include "rs_hmap_common.h"
#include "qtypes.h"
#include "rs_hmap_int_types.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_get.h"
#include "vctr_is.h"

extern rs_hmap_t g_vctr_hmap;

int
vctr_is(
    uint32_t v,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    )
{
  int status = 0;
  rs_hmap_key_t key = v;
  rs_hmap_val_t val;
  status = g_vctr_hmap.get(&g_vctr_hmap, &key, &val, ptr_is_found, 
      ptr_where_found);
BYE:
  return status;
}
