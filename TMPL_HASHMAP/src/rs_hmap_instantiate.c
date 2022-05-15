#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_aux.h"
#include "rs_hmap_int_struct.h"
#include "rs_hmap_instantiate.h"
int 
rs_hmap_instantiate(
    rs_hmap_t *H, 
    rs_hmap_config_t *C,
    const char * const so_file
    )
{
  int status = 0;
  //----------------------------------------
  if ( C->min_size == 0 ) { 
    H->config.min_size = HASH_MIN_SIZE;
  }
  else {
    H->config.min_size = C->min_size;
  }
  //----------------------------------------
  if ( C->max_size != 0 ) { 
    H->config.max_size = C->max_size;
  }
  //----------------------------------------
  if ( C->max_growth_step == 0 ) { 
    H->config.max_growth_step = MAX_GROWTH_STEP;
  }
  //----------------------------------------
  if ( C->low_water_mark == 0 ) { 
    H->config.low_water_mark = LOW_WATER_MARK;
  }
  if ( ( H->config.low_water_mark <= 0 ) || 
       ( H->config.low_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( C->high_water_mark == 0 ) { 
    H->config.high_water_mark = HIGH_WATER_MARK;
  }
  if ( ( H->config.high_water_mark <= 0 ) || 
       ( H->config.high_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( H->config.low_water_mark > 
       H->config.high_water_mark ) {
    go_BYE(-1);
  }
  //----------------------------------------

  // get smallest prime bigger than min size
  H->size = prime_geq(H->config.min_size);
  H->bkts = calloc(H->size, sizeof(bkt_t)); 
  return_if_malloc_failed(H->bkts);

  H->bkt_full = calloc(H->size, sizeof(bool)); 
  return_if_malloc_failed(H->bkt_full);

  H-> divinfo = fast_div32_init(H->size);
  H->hashkey = mk_hmap_key();

  /* TODO 
  if ( H->config.key_cmp_fn == NULL ) { go_BYE(-1); }
  if ( H->config.val_update_fn == NULL ) { go_BYE(-1); }
  */

BYE:
  return status;
}
