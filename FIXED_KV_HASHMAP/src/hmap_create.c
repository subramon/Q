#include "hmap_common.h"
#include "hmap_struct.h"
#include "hmap_aux.h"
#include "hmap_instantiate.h"
#include "hmap_create.h"
void *
hmap_create(
    hmap_t *ptr_hmap,
    const hmap_config_t *ptr_config
    )
{
  int status = 0;
  hmap_t *ptr_hmap = NULL;

  ptr_hmap = malloc(1 * sizeof(hmap_t));

  //----------------------------------------
  if ( ptr_configi->min_size == 0 ) { 
    ptr_hmap->config.min_size = HASH_MIN_SIZE;
  }
  else {
    ptr_hmap->config.min_size = ptr_config->min_size;
  }
  //----------------------------------------
  if ( ptr_hmap->config.max_size > 0 ) { 
    if ( ptr_hmap->config.min_size >= ptr_hmap->config.max_size ) {
      go_BYE(-1);
    }
  }
  //----------------------------------------
  if ( ptr_hmap->config.max_growth_step == 0 ) { 
    ptr_hmap->config.max_growth_step = HASH_MIN_SIZE;
  }
  //----------------------------------------
  if ( ptr_hmap->config.low_water_mark == 0 ) { 
    ptr_hmap->config.low_water_mark = LOW_WATER_MARK;
  }
  if ( ( ptr_hmap->config.low_water_mark <= 0 ) || 
       ( ptr_hmap->config.low_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( ptr_hmap->config.high_water_mark == 0 ) { 
    ptr_hmap->config.high_water_mark = HIGH_WATER_MARK;
  }
  if ( ( ptr_hmap->config.high_water_mark <= 0 ) || 
       ( ptr_hmap->config.high_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( ptr_hmap->config.low_water_mark > 
       ptr_hmap->config.high_water_mark ) {
    go_BYE(-1);
  }
  //----------------------------------------

  // get smallest prime bigger than min size
  ptr_hmap->size = prime_geq(ptr_hmap->config.min_size);
  ptr_hmap->bkts = calloc(ptr_hmap->size, sizeof(bkt_t)); 
  return_if_malloc_failed(ptr_hmap->bkts);

  ptr_hmap->bkt_full = calloc(ptr_hmap->size, sizeof(bool)); 
  return_if_malloc_failed(ptr_hmap->bkt_full);

  ptr_hmap-> divinfo = fast_div32_init(ptr_hmap->size);
  ptr_hmap->hashkey = mk_hmap_key();


  if ( ptr_hmap->config.key_cmp_fn == NULL ) { go_BYE(-1); }
  if ( ptr_hmap->config.val_update_fn == NULL ) { go_BYE(-1); }

BYE:
  if ( status != 0 ) { return NULL; } else { return ptr_hmap; }
}
