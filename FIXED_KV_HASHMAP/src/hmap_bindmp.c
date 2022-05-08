/*
 * Dumps the contents of the hmap in binary 
 */
 #include "hmap_common.h"
 #include "hmap_struct.h"
 #include "hmap_bindmp.h"
int
hmap_bindmp(
    hmap_t *ptr_hmap, 
    hmap_kv_t **ptr_K,
    uint32_t *ptr_nK
    )
{
  int status = 0;
  hmap_kv_t *K = NULL;
  uint32_t nK = 0;

  if ( ptr_hmap == NULL ) { go_BYE(-1); }
  nK = ptr_hmap->nitems;
  if ( nK == 0 ) { goto BYE; }
  K = malloc(nK * sizeof(hmap_kv_t));
  return_if_malloc_failed(K);
  uint32_t kidx = 0;
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( ptr_hmap->bkt_full[i] == false ) { continue; }
    K[kidx].key = ptr_hmap->bkts[i].key;
    K[kidx].val = ptr_hmap->bkts[i].val;
    kidx++;
  }
  if ( kidx != nK ) { go_BYE(-1); }
  *ptr_K = K;
  *ptr_nK = nK;
BYE:
  return status;
}
