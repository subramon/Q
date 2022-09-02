// EXTERNAL EXPOSURE
/*
 * Dumps the contents of the hmap in binary in row order
 */
 #include "rs_hmap_common.h"
 #include "rs_hmap_struct.h"
 #include "rs_hmap_row_bindmp.h"

int
rs_hmap_row_bindmp(
    rs_hmap_t *ptr_hmap, 
    const char * const file_name,
    void  **ptr_K,
    uint32_t *ptr_nK
    )
{
  int status = 0;
  rs_hmap_kv_t *K = NULL;
  uint32_t nK = 0;
  FILE *fp = NULL;

  if ( ptr_hmap == NULL ) { go_BYE(-1); }
  nK = ptr_hmap->nitems;
  if ( nK == 0 ) { goto BYE; }
  register bkt_t *bkts = (bkt_t *)ptr_hmap->bkts;
  register bool *bkt_full = ptr_hmap->bkt_full;

  if ( file_name == NULL ) { 
    K = malloc(nK * sizeof(rs_hmap_kv_t));
    return_if_malloc_failed(K);
    uint32_t kidx = 0;
    for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
      if ( bkt_full[i] == false ) { continue; }
      K[kidx].key = bkts[i].key;
      K[kidx].val = bkts[i].val;
      kidx++;
    }
    if ( kidx != nK ) { go_BYE(-1); }
    *ptr_K = (void *)K;
    *ptr_nK = nK;
  }
  else {
    fp = fopen(file_name, "wb");
    return_if_fopen_failed(fp, file_name, "wb");
    for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
      if ( bkt_full[i] == false ) { continue; }
      fwrite(&(bkts[i].key), sizeof(rs_hmap_key_t), 1, fp);
      fwrite(&(bkts[i].val), sizeof(rs_hmap_key_t), 1, fp);
    }
    fclose_if_non_null(fp); 
  }
BYE:
  fclose_if_non_null(fp); 
  return status;
}
