#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_aux.h"
#include "rs_hmap_instantiate.h"
int 
rs_hmap_instantiate(
    rs_hmap_t *H, 
    rs_hmap_config_t *HC
    )
{
  int status = 0;
  //----------------------------------------
  if ( HC->min_size == 0 ) { 
    H->config.min_size = HASH_MIN_SIZE;
  }
  else {
    H->config.min_size = HC->min_size;
  }
  //----------------------------------------
  if ( HC->max_size != 0 ) { 
    H->config.max_size = HC->max_size;
  }
  //----------------------------------------
  if ( HC->max_growth_step == 0 ) { 
    H->config.max_growth_step = MAX_GROWTH_STEP;
  }
  //----------------------------------------
  if ( HC->low_water_mark == 0 ) { 
    H->config.low_water_mark = LOW_WATER_MARK;
  }
  if ( ( H->config.low_water_mark <= 0 ) || 
       ( H->config.low_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( HC->high_water_mark == 0 ) { 
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

  H->divinfo = fast_div32_init(H->size);
  H->hashkey = mk_hmap_key();

  if ( ( HC->so_file == NULL ) || ( *HC->so_file == '\0' ) ) { go_BYE(-1); }
  H->config.so_file = HC->so_file;
  HC->so_file = NULL;  // control handed over 
  H->config.so_handle = dlopen(H->config.so_file, RTLD_NOW); 
  if ( H->config.so_handle == NULL ) { go_BYE(-1); }

  H->put = (put_fn_t) dlsym(H->config.so_handle, "rs_hmap_put"); 
  H->get = (get_fn_t) dlsym(H->config.so_handle, "rs_hmap_get"); 
  H->del = (del_fn_t) dlsym(H->config.so_handle, "rs_hmap_del"); 
  H->chk = (chk_fn_t) dlsym(H->config.so_handle, "rs_hmap_chk"); 
  H->row_dmp = (row_dmp_fn_t) dlsym(H->config.so_handle, "rs_hmap_row_bindmp"); 
  H->destroy = (destroy_fn_t) dlsym(H->config.so_handle, "rs_hmap_destroy"); 
  H->key_ordr = (key_ordr_fn_t) dlsym(H->config.so_handle, "rsx_key_ordr"); 
  H->key_cmp = (key_cmp_fn_t) dlsym(H->config.so_handle, "rsx_key_cmp"); 
  H->val_update = (val_update_fn_t) dlsym(H->config.so_handle, "rsx_val_update"); 
  H->bkt_chk = (bkt_chk_fn_t) dlsym(H->config.so_handle, "rsx_bkt_chk"); 

BYE:
  return status;
}
