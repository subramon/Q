#include "hmap_common.h"
#include "hmap_update.h"

int
hmap_update(
    hmap_t *ptr_hmap, 
    uint32_t idx,
    void *val
    )
{
  int status = 0;
#ifdef DEBUG
  if ( ptr_hmap == NULL ) { go_BYE(-1); } 
  if ( val == NULL    ) { go_BYE(-1); } 
  if ( idx >= ptr_hmap->size ) { go_BYE(-1); } 
#endif
  bkt_t *this_bkt = ptr_hmap->bkts + idx;
  status = val_update(&(this_bkt->val), val);  cBYE(status);
BYE:
  return status;
}
