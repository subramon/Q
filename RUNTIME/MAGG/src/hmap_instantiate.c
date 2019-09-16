//START_INCLUDES
#include "hmap_utils.h"
#include "hmap_common.h"
#include "_hmap_types.h"
//STOP_INCLUDES

#include "_hmap_instantiate.h"
// Like hmap_create but ptr_hmap has been allocated prior
//START_FUNC_DECL
int 
hmap_instantiate(
    hmap_t *ptr_hmap,
    size_t minsize
    )
//STOP_FUNC_DECL
{
  int status = 0;

  ptr_hmap->size = ptr_hmap->minsize = MAX(minsize, HASH_INIT_SIZE);

  ptr_hmap->bkts = calloc(ptr_hmap->size, sizeof(bkt_t)); 
  return_if_malloc_failed(ptr_hmap->bkts);

  ptr_hmap-> divinfo = fast_div32_init(ptr_hmap->size);
  ptr_hmap->hashkey ^= random() | (random() << 32);
BYE:
  return status;
}
