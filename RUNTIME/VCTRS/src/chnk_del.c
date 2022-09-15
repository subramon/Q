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
    bool is_persist
    )
{
  int status = 0;
  bool vctr_is_found, chnk_is_found;
  uint32_t where_found;

  status = vctr_is(vctr_uqid, &vctr_is_found, &where_found);
  cBYE(status);
  if ( !vctr_is_found ) { return -2; } // NOTE

  chnk_rs_hmap_key_t key = { .vctr_uqid = vctr_uqid, .chnk_idx = chnk_idx };
  chnk_rs_hmap_val_t val; memset(&val, 0, sizeof(chnk_rs_hmap_val_t));
  status = g_chnk_hmap.get(&g_chnk_hmap, &key, &val, &chnk_is_found, 
      &where_found);
  if ( chnk_is_found == false ) { return -3; } // NOTE 
  if ( g_chnk_hmap.nitems == 0 ) { go_BYE(-1); }
  //----------------------------------------------------
  status = chnk_free_resources( &(g_chnk_hmap.bkts[where_found].key), 
      &(g_chnk_hmap.bkts[where_found].val), is_persist);
  cBYE(status);
  //-- delete entry in hash table 
  bool is_found;
  status = g_chnk_hmap.del(&g_chnk_hmap, &key, &val, &is_found); 
  cBYE(status);
  if ( is_found == false ) { go_BYE(-1); }
BYE:
  return status;
}
