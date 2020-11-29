#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_instantiate.h"
int 
hmap_instantiate(
    hmap_t *ptr_hmap,
    config_t *ptr_config
    )
{
  int status = 0;

  memset(ptr_hmap, 0, sizeof(hmap_t));
  //----------------------------------------
  if ( ptr_config->min_size == 0 ) { 
    ptr_hmap->min_size = HASH_MIN_SIZE;
  }
  else {
    ptr_hmap->min_size = ptr_config->min_size;
  }
  //----------------------------------------
  if ( ptr_config->max_size == 0 ) { 
    ptr_hmap->max_size = HASH_MIN_SIZE;
  }
  else {
    ptr_hmap->max_size = ptr_config->max_size;
  }
  //----------------------------------------
  if ( ptr_config->max_growth_step == 0 ) { 
    ptr_hmap->max_growth_step = HASH_MIN_SIZE;
  }
  else {
    ptr_hmap->max_growth_step = ptr_config->max_growth_step;
  }
  //----------------------------------------

  ptr_hmap->size = ptr_hmap->min_size;
  ptr_hmap->bkts = calloc(ptr_hmap->size, sizeof(bkt_t)); 
  return_if_malloc_failed(ptr_hmap->bkts);

  ptr_hmap-> divinfo = fast_div32_init(ptr_hmap->size);
  ptr_hmap->hashkey = mk_hmap_key();
BYE:
  return status;
}
