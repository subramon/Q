#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "../../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/rs_hmap_del.h"

#include "vctr_del.h"

extern vctr_rs_hmap_t g_vctr_hmap;

int
vctr_del(
    uint32_t uqid,
    bool *ptr_is_found
    )
{
  int status = 0;
  vctr_rs_hmap_key_t key = uqid; 
  vctr_rs_hmap_val_t val;
  status = g_vctr_hmap.del(&g_vctr_hmap, &key, &val, ptr_is_found); 
  cBYE(status);
BYE:
  return status;
}
