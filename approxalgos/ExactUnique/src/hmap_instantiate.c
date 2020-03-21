#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_types.h"
#include "hmap_instantiate.h"
int 
hmap_instantiate(
    hmap_t *ptr_hmap,
    size_t minsize,
    size_t maxsize
    )
{
  int status = 0;

  ptr_hmap->size = ptr_hmap->minsize = MAX(minsize, HASH_INIT_SIZE);
  ptr_hmap->maxsize = MAX(maxsize, HASH_INIT_SIZE);

  ptr_hmap->bkts = calloc(ptr_hmap->size, sizeof(bkt_t)); 
  return_if_malloc_failed(ptr_hmap->bkts);

  ptr_hmap-> divinfo = fast_div32_init(ptr_hmap->size);
  ptr_hmap->hashkey ^= random() | (random() << 32);
BYE:
  return status;
}
