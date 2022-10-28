#include "q_incs.h"
#include "qtypes.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"

extern chnk_rs_hmap_t g_chnk_hmap;

int
chnk_is(
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    )
{
  int status = 0;
  chnk_rs_hmap_key_t key = { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  chnk_rs_hmap_val_t val; memset(&val, 0, sizeof(chnk_rs_hmap_val_t));
  status = g_chnk_hmap.get(&g_chnk_hmap, &key, &val, ptr_is_found, 
      ptr_where_found);
  /*
  if ( *ptr_is_found ) { 
    printf("found at %u \n", *ptr_where_found);
  }
  else {
    printf("(%u, %u) not found \n", vctr_uqid, chnk_idx);
  }
  */
BYE:
  return status;
}
