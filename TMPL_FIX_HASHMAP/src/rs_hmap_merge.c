// EXTERNAL EXPOSURE
/*
 * Merges second hmap into first 
 */
 #include "rs_hmap_common.h"
 #include "rs_hmap_struct.h"
 #include "rs_hmap_put.h"
 #include "rs_hmap_merge.h"

int
rs_hmap_merge(
    rs_hmap_t *ptr_dst_hmap, 
    const rs_hmap_t * const ptr_src_hmap
    )
{
  int status = 0;

  if ( ptr_dst_hmap == NULL ) { go_BYE(-1); }
  if ( ptr_src_hmap == NULL ) { go_BYE(-1); }
  rs_hmap_bkt_t *src_bkts = ptr_src_hmap->bkts;
  bool *src_bkt_full = ptr_src_hmap->bkt_full;
  for ( uint32_t i = 0; i < ptr_src_hmap->size; i++ ) { 
    if ( src_bkt_full[i] == false ) { continue; }
    rs_hmap_key_t key = src_bkts[i].key;
    rs_hmap_val_t val = src_bkts[i].val;
    status = rs_hmap_put(ptr_dst_hmap, &key, &val); cBYE(status);
  }
BYE:
  return status;
}
