#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "chnk_free_resources.h"
#include "chnk_del.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

int
chnk_del(
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    bool *ptr_is_found
    )
{
  int status = 0;
  bool vctr_is_found; 
  uint32_t where_found, chnk_size, width, max_num_in_chnk;

  status = vctr_is(vctr_uqid, &vctr_is_found, &where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  width  = g_vctr_hmap.bkts[where_found].val.width;
  max_num_in_chnk = g_vctr_hmap.bkts[where_found].val.max_num_in_chnk;
  chnk_size = width * max_num_in_chnk;

  chnk_rs_hmap_key_t key = { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  chnk_rs_hmap_val_t val; memset(&val, 0, sizeof(chnk_rs_hmap_val_t));
  status = g_chnk_hmap.get(&g_chnk_hmap, &key, &val, ptr_is_found, 
      &where_found);
  if ( *ptr_is_found == false ) { goto BYE; }
  if ( g_chnk_hmap.nitems == 0 ) { go_BYE(-1); }
  chnk_rs_hmap_key_t chnk_key = 
    { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  chnk_rs_hmap_val_t chnk_val; 
  memset(&chnk_val, 0, sizeof(chnk_rs_hmap_val_t));
  status = g_chnk_hmap.del(&g_chnk_hmap, &chnk_key,&chnk_val,ptr_is_found); 
  cBYE(status);
  if ( !*ptr_is_found ) { goto BYE; } // silent exit 
  status = chnk_free_resources(chnk_size, &chnk_val); cBYE(status);
BYE:
  return status;
}
