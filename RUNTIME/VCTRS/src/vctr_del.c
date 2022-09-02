#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "vctr_del.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

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
  if ( *ptr_is_found ) { 
    if ( val.num_chunks == 0 ) { go_BYE(-1); }
    for ( uint32_t i = 0; i < val.num_chunks; i++ ) { 
      if ( g_chnk_hmap.nitems == 0 ) { go_BYE(-1); }
      bool is_found;
      chnk_rs_hmap_key_t chnk_key = { .vctr_uqid = uqid, .chnk_idx = i };
      chnk_rs_hmap_val_t chnk_val;
      status = g_chnk_hmap.del(&g_chnk_hmap, &chnk_key, &chnk_val, 
          &is_found); 
      cBYE(status);
      if ( !is_found ) { go_BYE(-1); }
    }
  }
BYE:
  return status;
}
