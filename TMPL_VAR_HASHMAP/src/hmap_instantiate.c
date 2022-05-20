#include <dlfcn.h>
#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_instantiate.h"
int 
hmap_instantiate(
    hmap_t *H,
    hmap_config_t *HC
    )
{
  int status = 0;

  memset(H, 0, sizeof(hmap_t));
  //----------------------------------------
  if ( HC->min_size == 0 ) { 
    H->config.min_size = HASH_MIN_SIZE;
  }
  else {
    H->config.min_size = HC->min_size;
  }
  //----------------------------------------
  H->config.max_size = HC->max_size;
  //----------------------------------------
  if ( HC->max_growth_step == 0 ) { 
    H->config.max_growth_step = HASH_MIN_SIZE;
  }
  else {
    H->config.max_growth_step = HC->max_growth_step;
  }
  //----------------------------------------
  if ( HC->low_water_mark <= 0 ) { 
    H->config.low_water_mark = LOW_WATER_MARK;
  }
  else {
    H->config.low_water_mark = HC->low_water_mark;
  }
  if ( ( H->config.low_water_mark <= 0 ) || 
       ( H->config.low_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( HC->high_water_mark <= 0 ) { 
    H->config.high_water_mark = HIGH_WATER_MARK;
  }
  else {
    H->config.high_water_mark = HC->high_water_mark;
  }
  if ( ( H->config.high_water_mark <= 0 ) || 
       ( H->config.high_water_mark >= 1 ) ) {
    go_BYE(-1);
  }
  //----------------------------------------
  if ( H->config.low_water_mark > H->config.high_water_mark ) {
    go_BYE(-1);
  }
  //----------------------------------------

  if ( ( HC->so_file == NULL ) || ( *HC->so_file == '\0' ) ) { go_BYE(-1); }
  H->config.so_file = strdup(HC->so_file);
  H->so_handle = dlopen(H->config.so_file, RTLD_NOW); 
  if ( H->so_handle == NULL ) { go_BYE(-1); }

  H->inval_update = (inval_update_fn_t) dlsym(H->so_handle, "inval_update"); 
  H->val_update = (val_update_fn_t) dlsym(H->so_handle, "val_update"); 
  H->key_chk = (key_chk_fn_t) dlsym(H->so_handle, "key_chk"); 
  H->inval_chk = (inval_chk_fn_t) dlsym(H->so_handle, "inval_chk"); 
  H->val_chk = (val_chk_fn_t) dlsym(H->so_handle, "val_chk"); 
  H->key_free = (key_free_fn_t) dlsym(H->so_handle, "key_free"); 
  H->val_free = (val_free_fn_t) dlsym(H->so_handle, "val_free"); 
  H->inval_copy = (inval_copy_fn_t) dlsym(H->so_handle, "inval_copy"); 
  H->val_copy = (val_copy_fn_t) dlsym(H->so_handle, "val_copy"); 
  H->key_hash = (key_hash_fn_t) dlsym(H->so_handle, "key_hash"); 
  H->key_copy = (key_copy_fn_t) dlsym(H->so_handle, "key_copy"); 
  H->key_len = (key_len_fn_t) dlsym(H->so_handle, "key_len"); 
  H->key_cmp = (key_cmp_fn_t) dlsym(H->so_handle, "key_cmp"); 

  // check all functions defined 
#define return_if_null(x) { if ( x == NULL ) { go_BYE(-1); } }
  return_if_null(H->inval_update);
  return_if_null(H->val_update);
  return_if_null(H->key_chk);
  return_if_null(H->inval_chk);
  return_if_null(H->val_chk);
  return_if_null(H->key_free);
  return_if_null(H->val_free);
  return_if_null(H->inval_copy);
  return_if_null(H->val_copy);
  return_if_null(H->key_hash);
  return_if_null(H->key_copy);
  return_if_null(H->key_len);
  return_if_null(H->key_cmp);

  // get smallest prime bigger than min size
  H->size = prime_geq(H->config.min_size);
  H->bkts = calloc(H->size, sizeof(bkt_t)); 
  return_if_malloc_failed(H->bkts);

  H-> divinfo = fast_div32_init(H->size);
  H->hashkey = mk_hmap_key();
BYE:
  return status;
}
