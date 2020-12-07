#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_instantiate.h"
int 
hmap_instantiate(
    hmap_t *ptr_hmap,
    hmap_config_t *ptr_config
    )
{
  int status = 0;

  memset(ptr_hmap, 0, sizeof(hmap_t));
  //----------------------------------------
  if ( ptr_config->min_size == 0 ) { 
    ptr_hmap->config.min_size = HASH_MIN_SIZE;
  }
  else {
    ptr_hmap->config.min_size = ptr_config->min_size;
  }
  //----------------------------------------
  if ( ptr_config->max_size == 0 ) { 
    ptr_hmap->config.max_size = HASH_MIN_SIZE;
  }
  else {
    ptr_hmap->config.max_size = ptr_config->max_size;
  }
  //----------------------------------------
  if ( ptr_config->max_growth_step == 0 ) { 
    ptr_hmap->config.max_growth_step = HASH_MIN_SIZE;
  }
  else {
    ptr_hmap->config.max_growth_step = ptr_config->max_growth_step;
  }
  //----------------------------------------
  if ( ptr_config->low_water_mark <= 0 ) { 
    ptr_hmap->config.low_water_mark = LOW_WATER_MARK;
  }
  else {
    ptr_hmap->config.low_water_mark = ptr_config->low_water_mark;
  }
  if ( ( ptr_hmap->config.low_water_mark <= 0 ) || 
       ( ptr_hmap->config.low_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( ptr_config->high_water_mark <= 0 ) { 
    ptr_hmap->config.high_water_mark = HIGH_WATER_MARK;
  }
  else {
    ptr_hmap->config.high_water_mark = ptr_config->high_water_mark;
  }
  if ( ( ptr_hmap->config.high_water_mark <= 0 ) || 
       ( ptr_hmap->config.high_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( ptr_hmap->config.low_water_mark > ptr_hmap->config.high_water_mark ) {
    go_BYE(-1);
  }
  //----------------------------------------

  ptr_hmap->size = ptr_hmap->config.min_size;
  ptr_hmap->bkts = calloc(ptr_hmap->size, sizeof(bkt_t)); 
  return_if_malloc_failed(ptr_hmap->bkts);

  ptr_hmap-> divinfo = fast_div32_init(ptr_hmap->size);
  ptr_hmap->hashkey = mk_hmap_key();
BYE:
  return status;
}
