#include "hmap_common.h"
#include "hmap_instantiate.h"
int 
hmap_instantiate(
    hmap_t *ptr_hmap,
    size_t minsize,
    size_t maxsize
    )
{
  int status = 0;

  memset(ptr_hmap, 0, sizeof(hmap_t));
  ptr_hmap->size = ptr_hmap->minsize = MAX(minsize, HASH_INIT_SIZE);
  ptr_hmap->maxsize = MAX(maxsize, ptr_hmap->size);

  ptr_hmap->bkts = calloc(ptr_hmap->size, sizeof(bkt_t)); 
  return_if_malloc_failed(ptr_hmap->bkts);

  ptr_hmap-> divinfo = fast_div32_init(ptr_hmap->size);
  uint64_t r1 = random();
  uint64_t r2 = random();
  ptr_hmap->hashkey ^= (r1 | (r2 << 32)); // TODO Why the ^?
BYE:
  return status;
}
